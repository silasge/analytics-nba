select
    season_year,
    season_type,
    game_id,
    game_date,
    team_game_number,
    team_id,
    team_name,
    opp_team_name,
    home_away,
    win_lose,
    points,
    rebounds_total,
    assists,
    steals,
    blocks,
    turnovers,
    fouls_personal,
    -- running avg 10 days general
    avg(points) over teams_window as avg_points_10g,
    avg(rebounds_total) over teams_window as avg_rebounds_total_10g,
    avg(assists) over teams_window as avg_assists_10g,
    avg(steals) over teams_window as avg_steals_10g,
    avg(blocks) over teams_window as avg_blocks_10g,
    avg(turnovers) over teams_window as avg_turnovers_10g,
    avg(fouls_personal) over teams_window as avg_fouls_personal_10g
from
    {{ ref("int_teams_unified") }}
window
    teams_window as (
        partition by
            season_year,
            season_type,
            team_id
        order by
            game_id asc
        rows between 10 preceding
        and 0 following
    )
