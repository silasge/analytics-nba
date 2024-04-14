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
    field_goals_made,
    field_goals_attempted,
    field_goals_percentage,
    three_pointers_made,
    three_pointers_attemped,
    three_pointers_percentage,
    free_throws_made,
    free_throws_attemped,
    free_throws_percentage,
    -- fg running avg 10 games
    avg(field_goals_made) over players_window as avg_field_goals_made_10g,
    avg(field_goals_attempted)
        over players_window
    as avg_field_goals_attempted_10g,
    avg(field_goals_percentage)
        over players_window
    as avg_field_goals_percentage_10g,
    -- 3pts running avg 10 games
    avg(three_pointers_made) over players_window as avg_three_pointers_made_10g,
    avg(three_pointers_attemped)
        over players_window
    as avg_three_pointers_attemped_10g,
    avg(three_pointers_percentage)
        over players_window
    as avg_three_pointers_percentage_10g,
    -- ft running avg 10 games
    avg(free_throws_made) over players_window as avg_free_throws_made_10g,
    avg(free_throws_attemped)
        over players_window
    as avg_free_throws_attemped_10g,
    avg(free_throws_percentage)
        over players_window
    as avg_free_throws_percentage_10g
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
