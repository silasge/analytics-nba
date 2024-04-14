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
    plus_minus_points,
    offensive_rating,
    defensive_rating,
    net_rating,
    true_shooting_percentage,
    pace,
    pie,
    -- running avg 10 games
    avg(plus_minus_points) over teams_window as avg_plus_minus_points_10g,
    avg(offensive_rating) over teams_window as avg_offensive_rating_10g,
    avg(defensive_rating) over teams_window as avg_defensive_rating_10g,
    avg(net_rating) over teams_window as avg_net_rating_10g,
    avg(true_shooting_percentage)
        over teams_window
    as avg_true_shooting_percentage_10g,
    avg(pace) over teams_window as avg_pace_10g,
    avg(pie) over teams_window as avg_pie_10g
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
