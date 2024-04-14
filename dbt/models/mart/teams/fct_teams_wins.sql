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
    -- win percentages
    sum(if(win_lose = 'W', 1, 0)) over teams_umb_window
    / count(win_lose) over teams_umb_window as win_percentage
from
    {{ ref("int_teams_unified") }}
window
    teams_umb_window as (
        partition by
            season_year,
            season_type,
            team_id
        order by
            game_id asc
    )
