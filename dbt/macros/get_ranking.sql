{% macro get_ranking(column_name) %}
    dense_rank() over (
        partition by
            season_year,
            season_type,
            team_game_number
        order by
            {{ column_name }} desc
    )
{% endmacro %}