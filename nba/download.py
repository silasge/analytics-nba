from itertools import product

from loguru import logger

from .api import NBAApi
from .parse_configs import configs


def main():
    season = configs["params"]["season"]
    season_type = configs["params"]["season_type"]

    if not isinstance(season, list):
        season = [season]

    if not isinstance(season_type, list):
        season_type = [season_type]

    for s, st in product(season, season_type):
        logger.info(f"Downloading {st} from Season {s}...")
        nba = NBAApi(season=s, season_type=st)
        nba.write_team_game_logs()
        logger.info("Team Game Logs finished. Starting Box Scores...")
        nba.write_boxscores()
        logger.info("Box Scores finished")
        logger.info(f"Finished {st} from season {s}.")

if __name__ == "__main__":
    main()