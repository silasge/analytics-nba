from pathlib import Path
from time import sleep
from typing import List

from fastparquet import write
import pandas as pd
from nba_api.stats.endpoints import (
    BoxScoreAdvancedV3,
    BoxScoreTraditionalV3,
    TeamGameLogs,
)
from tqdm import tqdm

from .decorators import retry
from .parse_configs import configs


class NBAApi:
    def __init__(self, season: str, season_type: str):
        self.season = season
        self.season_type = season_type
        self.base_game_logs = (
            Path(configs["paths"]["team_game_logs"]) / "team_game_logs.parquet"
        )

        self.base_box_traditional = Path(configs["paths"]["boxscore_traditional"])
        self.trad_players_path = self.base_box_traditional / "players.parquet"
        self.trad_bench_path = self.base_box_traditional / "bench.parquet"
        self.trad_teams_path = self.base_box_traditional / "teams.parquet"

        self.base_box_advanced = Path(configs["paths"]["boxscore_advanced"])
        self.adv_players_path = self.base_box_advanced / "players.parquet"
        self.adv_teams_path = self.base_box_advanced / "teams.parquet"

    @staticmethod
    def _write_to_parquet(df: pd.DataFrame, path: Path) -> None:
        path.parent.mkdir(exist_ok=True, parents=True)
        
        kwargs = {"filename": path, "data": df, "compression": "SNAPPY"}
        
        if path.is_file():
            kwargs["append"] = True
        
        write(**kwargs)


    def _get_unique_ids(self):
        game_ids = set(
            pd.read_parquet(self.base_game_logs, columns=["GAME_ID"])
            .iloc[:, 0]
            .apply(lambda x: str(x).rjust(10, "0"))
            .to_list()
        )

        existing_paths = [
            self.trad_players_path,
            self.trad_teams_path,
            self.adv_players_path,
            self.adv_teams_path,
        ]

        try:
            new_game_ids = []
            for p in existing_paths:
                existing_ids = (
                    pd.read_parquet(p, columns=["gameId"])
                    .iloc[:, 0]
                    .apply(lambda x: str(x).rjust(10, "0"))
                    .to_list()
                )
                new_game_ids += list(filter(lambda x: x not in existing_ids, game_ids))
            return set(new_game_ids)
        except Exception:
            return set(game_ids)

    @retry(retries=10, delay=60, jitter=10)
    def get_team_game_logs(self) -> pd.DataFrame:
        team_game_logs = TeamGameLogs(
            season_nullable=self.season, season_type_nullable=self.season_type
        ).get_data_frames()[0]
        team_game_logs["SEASON_TYPE"] = self.season_type
        team_game_logs["GAME_DATE"] = pd.to_datetime(team_game_logs["GAME_DATE"])
        sleep(0.5)
        return team_game_logs

    @retry(retries=10, delay=60, jitter=10)
    def get_box_score_traditionalv3(self, game_id: int) -> List[pd.DataFrame]:
        box_score_tradicionalv3 = BoxScoreTraditionalV3(
            game_id=game_id
        ).get_data_frames()
        sleep(0.5)
        return box_score_tradicionalv3

    @retry(retries=10, delay=60, jitter=10)
    def get_box_score_advancedv3(self, game_id: int) -> List[pd.DataFrame]:
        box_score_advancedv3 = BoxScoreAdvancedV3(game_id=game_id).get_data_frames()
        sleep(0.5)
        return box_score_advancedv3

    def write_team_game_logs(self) -> None:
        
        team_game_logs = self.get_team_game_logs()
        
        if self.base_game_logs.is_file():
            existing_game_ids = set( # noqa: F841
                pd.read_parquet(self.base_game_logs, columns=["GAME_ID"])
                .iloc[:, 0]
                .to_list()
            )

            team_game_logs = team_game_logs.query("GAME_ID not in @existing_game_ids")
        
        self._write_to_parquet(
            df=team_game_logs,
            path=self.base_game_logs
        )

    def write_boxscores(self):
        game_ids = self._get_unique_ids()

        for gid in (pbar := tqdm(game_ids)):
            pbar.set_description(f"Processing {gid}")

            trad_players, trad_bench, trad_teams = self.get_box_score_traditionalv3(
                game_id=gid
            )
            adv_players, adv_teams = self.get_box_score_advancedv3(game_id=gid)

            to_loop = [
                (trad_players, self.trad_players_path),
                (trad_bench, self.trad_bench_path),
                (trad_teams, self.trad_teams_path),
                (adv_players, self.adv_players_path),
                (adv_teams, self.adv_teams_path),
            ]

            for df, p in to_loop:
                self._write_to_parquet(df=df, path=p)
