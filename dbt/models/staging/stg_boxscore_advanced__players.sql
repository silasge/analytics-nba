with

source as (
    select * from {{ source('boxscore_advanced', 'players') }}
),

renamed_source as (
    select distinct
        gameID::integer as game_id,
        teamID as team_id,
        teamCity as team_city,
        teamName as team_name,
        teamTricode as team_tricode,
        teamSlug as team_slug,
        personID::integer as person_id,
        firstName || ' ' || familyName as player_name,
        position,
        if(position <> '', 1, 0) as flg_starter,
        comment,
        if(comment = '', 1, 0) as flg_played,
        jerseyNum as jersey_num,
        try_cast(
            substring(minutes, 1, strpos(minutes, ':')-1) as int
        ) as minutes_played,
        estimatedOffensiveRating as estimated_offensive_rating,
        offensiveRating as offensive_rating,
        estimatedDefensiveRating as estimated_defensive_rating,
        defensiveRating as defensive_rating,
        estimatedNetRating as estimated_net_rating,
        netRating as net_rating,
        assistPercentage as assist_percentage,
        assistToTurnover as assist_to_turnover,
        assistRatio as assist_ratio,
        offensiveReboundPercentage as offensive_rebound_percentage,
        defensiveReboundPercentage as defensive_rebound_percentage,
        reboundPercentage as rebound_percentage,
        turnoverRatio as turnover_ratio,
        effectiveFieldGoalPercentage as effective_fiel_goal_percentage,
        trueShootingPercentage as true_shooting_percentage,
        usagePercentage as usage_percentage,
        estimatedUsagePercentage as estimated_usage_percentage,
        estimatedPace as estimated_pace,
        pace,
        pacePer40 as pace_per_40,
        possessions,
        PIE as pie
    from
        source
)

select * from renamed_source