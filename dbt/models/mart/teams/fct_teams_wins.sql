with

window_calculations_from_source as (
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
        / count(win_lose) over teams_umb_window as win_percentage,
        sum(if(win_lose = 'W' and home_away = 'Home', 1, 0)) over teams_umb_window
        / sum(if(home_away = 'Home', 1, 0)) over teams_umb_window as home_win_percentage,
        sum(if(win_lose = 'W' and home_away = 'Away', 1, 0)) over teams_umb_window
        / sum(if(home_away = 'Away', 1, 0)) over teams_umb_window as away_win_percentage,
        sum(if(win_lose = 'W', 1, 0)) over teams_opp_umb_window
        / count(win_lose) over teams_opp_umb_window as win_percentage_against_opponent,
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
        ),
        teams_opp_umb_window as (
            partition by
                season_year,
                season_type,
                team_id,
                opp_team_name
            order by
                game_id
        )
),

get_rankings_from_window_calculations as (
    select
        *,
        -- win rankings
        {{ get_ranking('win_percentage') }} as rkg_win_percentage,
        {{ get_ranking('home_win_percentage') }} as rkg_home_win_percentage,
        {{ get_ranking('away_win_percentage') }} as rkg_away_win_percentage
    from
        window_calculations_from_source

)

select * from get_rankings_from_window_calculations