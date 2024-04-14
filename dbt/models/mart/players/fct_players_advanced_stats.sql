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
    plus_minus_points,
    offensive_rating,
    defensive_rating,
    net_rating,
    true_shooting_percentage,
    usage_percentage,
    pace,
    pie,
    -- running avg 10 games
    avg(plus_minus_points) over players_window as avg_plus_minus_points_10g,
    avg(offensive_rating) over players_window as avg_offensive_rating_10g,
    avg(defensive_rating) over players_window as avg_defensive_rating_10g,
    avg(net_rating) over players_window as avg_net_rating_10g,
    avg(true_shooting_percentage)
        over players_window
    as avg_true_shooting_percentage_10g,
    avg(usage_percentage) over players_window as avg_usage_percentage_10g,
    avg(pace) over players_window as avg_pace_10g,
    avg(pie) over players_window as avg_pie_10g
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
