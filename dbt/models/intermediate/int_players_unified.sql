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
        c.season_year,
        c.season_type,
        c.game_id,
        c.game_date,
        c.team_game_number,
        c.team_id,
        c.team_name,
        d.team_name as opp_team_name,
        c.home_away,
        c.win_lose,
        a.player_name,
        a.flg_starter,
        a.flg_played,
        a.minutes_played,
        a.field_goals_made,
        a.field_goals_attempted,
        a.field_goals_percentage,
        a.three_pointers_made,
        a.three_pointers_attemped,
        a.three_pointers_percentage,
        a.free_throws_made,
        a.free_throws_attemped,
        a.free_throws_percentage,
        a.rebounds_offensive,
        a.rebounds_defensive,
        a.rebounds_total,
        a.assists,
        a.steals,
        a.blocks,
        a.turnovers,
        a.fouls_personal,
        a.points,
        a.plus_minus_points,
        b.offensive_rating,
        b.defensive_rating,
        b.net_rating,
        b.true_shooting_percentage,
        b.usage_percentage,
        b.pace,
        b.pie
    from
        {{ ref('stg_boxscore_traditional__players') }} as a
    left join
        {{ ref('stg_boxscore_advanced__players') }} as b
        on a.game_id = b.game_id
        and a.team_id = b.team_id
        and a.person_id = b.person_id
    left join
        import_team_game_logs as c
        on a.game_id = c.game_id
        and a.team_id = c.team_id
    left join
        import_team_game_logs as d
        on a.game_id = d.game_id
        and a.team_id <> d.team_id
)

select * from add_traditional_and_advanced_stats