with

source as (
    select * from {{ source('boxscore_traditional', 'teams') }}
),

renamed_source as (
    select distinct
        gameID::integer as game_id,
        teamID as team_id,
        teamCity as team_city,
        teamName as team_name,
        teamTricode as team_tricode,
        teamSlug as team_slug,
        minutes,
        fieldGoalsMade as field_goals_made,
        fieldGoalsAttempted as field_goals_attempted,
        fieldGoalsPercentage as field_goals_percentage,
        threePointersMade as three_pointers_made,
        threePointersAttempted as three_pointers_attemped,
        threePointersPercentage as three_pointers_percentage,
        freeThrowsMade as free_throws_made,
        freeThrowsAttempted as free_throws_attemped,
        freeThrowsPercentage as free_throws_percentage,
        reboundsOffensive as rebounds_offensive,
        reboundsDefensive as rebounds_defensive,
        reboundsTotal as rebounds_total,
        assists,
        steals,
        blocks,
        turnovers,
        foulsPersonal as fouls_personal,
        points,
        plusMinusPoints as plus_minus_points
    from
        source
)

select * from renamed_source