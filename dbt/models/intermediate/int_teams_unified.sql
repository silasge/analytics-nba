with
import_team_game_logs as (
    select
        season_year,
        season_type,
        game_id,
        game_date,
        row_number() over (
            partition by
                season_year,
                season_type,
                team_id
            order by
                game_id
        ) as team_game_number,
        team_id,
        team_name,
        home_away,
        win_lose
    from
        {{ ref("stg_team_game_logs") }}
    
),

add_traditional_and_advanced_stats as (
    select
        a.season_year,
        a.season_type,
        a.game_id,
        a.game_date,
        a.team_game_number,
        a.team_id,
        a.team_name,
        b.team_name as opp_team_name,
        a.home_away,
        a.win_lose,
        c.field_goals_made,
        c.field_goals_attempted,
        c.field_goals_percentage,
        c.three_pointers_made,
        c.three_pointers_attemped,
        c.three_pointers_percentage,
        c.free_throws_made,
        c.free_throws_attemped,
        c.free_throws_percentage,
        c.rebounds_offensive,
        c.rebounds_defensive,
        c.rebounds_total,
        c.assists,
        c.steals,
        c.blocks,
        c.turnovers,
        c.fouls_personal,
        c.points,
        c.plus_minus_points,
        d.offensive_rating,
        d.defensive_rating,
        d.net_rating,
        d.true_shooting_percentage,
        d.usage_percentage,
        d.pace,
        d.pie
    from
        import_team_game_logs as a
    left join
        import_team_game_logs as b
        on a.game_id = b.game_id
        and a.team_id <> b.team_id
    left join
        {{ ref("stg_boxscore_traditional__teams") }} as c
        on a.game_id = c.game_id
        and a.team_id = c.team_id
    left join
        {{ ref("stg_boxscore_advanced__teams") }} as d
        on a.game_id = d.game_id
        and a.team_id = d.team_id
)

select * from add_traditional_and_advanced_stats
