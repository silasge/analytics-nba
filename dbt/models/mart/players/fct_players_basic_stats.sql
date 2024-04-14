select
    season_year,
    season_type,
    game_id,
    game_date,
    team_game_number,
    team_id,
    team_name,
    opp_team_name,
    person_id,
    player_name,
    player_game_number,
    home_away,
    win_lose,
    points,
    rebounds_total,
    assists,
    steals,
    blocks,
    turnovers,
    fouls_personal,
    -- running avg 10 games
    avg(points) over players_window as avg_points_10g,
    avg(rebounds_total) over players_window as avg_rebounds_total_10g,
    avg(assists) over players_window as avg_assists_10g,
    avg(steals) over players_window as avg_steals_10g,
    avg(blocks) over players_window as avg_blocks_10g,
    avg(turnovers) over players_window as avg_turnovers_10g,
    avg(fouls_personal) over players_window as avg_fouls_personal_10g
from
    {{ ref("int_players_unified") }}
window
    players_window as (
        partition by
            season_year,
            season_type,
            person_id
        order by
            game_id asc
        rows between 10 preceding
        and 0 following
    )
