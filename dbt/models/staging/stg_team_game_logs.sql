with

source as (
    select * from {{ source('game_logs', 'team_game_logs') }}
),

renamed_source as (
    select distinct
        SEASON_YEAR as season_year,
        SEASON_TYPE as season_type,
        GAME_ID::integer AS game_id,
        GAME_DATE AS game_date,
        TEAM_ID as team_id,
        TEAM_NAME as team_name,
        TEAM_ABBREVIATION as team_tricode,
        MATCHUP as matchup,
        if(matchup like '%@%', 'Away', 'Home') as home_away,
        WL as win_lose,
        MIN as minutes,
        FGM as field_goals_made,
        FGA as field_goals_attempted,
        FG_PCT as field_goals_percentage,
        FG3M as three_pointers_made,
        FG3A as three_pointers_attemped,
        FG3_PCT as three_pointers_percentage,
        FTM as free_throws_made,
        FTA as free_throws_attemped,
        FT_PCT as free_throws_percentage,
        OREB as rebounds_offensive,
        DREB as rebounds_defensive,
        REB as rebounds_total,
        AST as assists,
        STL as steals,
        BLK as blocks,
        BLKA as blocks_attemped,
        TOV as turnovers,
        PF as fouls_personal,
        PFD as fouls_personal_drawn,
        PTS as points,
        PLUS_MINUS as plus_minus_points
    from
        source
)

select * from renamed_source