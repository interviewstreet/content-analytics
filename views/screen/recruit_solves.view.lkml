view: recruit_solves {
  sql_table_name: recruit_rs_replica.recruit.recruit_solves ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: aid {
    type: number
    value_format_name: id
    sql: ${TABLE}.aid ;;
  }
  dimension: answer {
    type: string
    sql: ${TABLE}.answer ;;
  }
  dimension: bonusscore {
    type: number
    sql: ${TABLE}.bonusscore ;;
  }
  dimension: frames {
    type: string
    sql: ${TABLE}.frames ;;
  }
  dimension_group: inserttime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.inserttime ;;
  }
  dimension: metadata {
    type: string
    sql: ${TABLE}.metadata ;;
  }

  dimension: language_used {
    type: string
    sql:  json_extract_path_text(${metadata},'language',true);;
  }

  dimension: language_used_simplified {
    type: string
    sql:      case
    WHEN  ${language_used} = 'java' THEN 'Java'
    WHEN  ${language_used} = 'java15' THEN 'Java'
    WHEN  ${language_used} = 'java8' THEN 'Java'
    WHEN  ${language_used} = 'pypy' THEN 'Python'
    WHEN  ${language_used} = 'pypy3' THEN 'Python'
    WHEN  ${language_used} = 'python' THEN 'Python'
    WHEN  ${language_used} = 'python3' THEN 'Python'
    WHEN  ${language_used} = 'cpp' THEN 'C++'
    WHEN  ${language_used} = 'cpp14' THEN 'C++'
    WHEN  ${language_used} = 'cpp20' THEN 'C++'
    WHEN  ${language_used} = 'csharp' THEN 'Csharp/.NET'
    else ${language_used} end ;;
  }


  dimension: processed {
    type: number
    sql: ${TABLE}.processed ;;
  }
  dimension: qid {
    type: number
    value_format_name: id
    sql: ${TABLE}.qid ;;
  }
  dimension: score {
    type: number
    sql: ${TABLE}.score ;;
  }
  dimension: status {
    type: number
    sql: ${TABLE}.status ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
  }
  measure: count {
    type: count
    drill_fields: [id]
  }

  dimension: percentage {
    type: number
    sql: case when json_extract_path_text(${TABLE}.metadata,'max_score',true) is not null
AND trim(json_extract_path_text(${TABLE}.metadata,'max_score',true)) != ''
AND cast((json_extract_path_text(${TABLE}.metadata,'max_score',true))*1.0 as DOUBLE PRECISION) != 0
then
cast(${TABLE}.score as double precision)*100.0/cast( json_extract_path_text(${TABLE}.metadata,'max_score',true) as DOUBLE PRECISION)
else 0 end;;
  }

  dimension: max_score {
    type: number
    sql: ${questions.points} ;;
  }



  measure: avg_percentage_score {
    type: average
    sql:  case when json_extract_path_text(${TABLE}.metadata,'max_score',true) is not null
AND trim(json_extract_path_text(${TABLE}.metadata,'max_score',true)) != ''
AND cast((json_extract_path_text(${TABLE}.metadata,'max_score',true))*1.0 as DOUBLE PRECISION) != 0
then
cast(${TABLE}.score as double precision)*100.0/cast( json_extract_path_text(${TABLE}.metadata,'max_score',true) as DOUBLE PRECISION)
else 0 end ;;
  }

  measure: medain_percentage_score {
    type: median
    sql:  case when json_extract_path_text(${TABLE}.metadata,'max_score',true) is not null
AND trim(json_extract_path_text(${TABLE}.metadata,'max_score',true)) != ''
AND cast((json_extract_path_text(${TABLE}.metadata,'max_score',true))*1.0 as DOUBLE PRECISION) != 0
then
cast(${TABLE}.score as double precision)*100.0/cast( json_extract_path_text(${TABLE}.metadata,'max_score',true) as DOUBLE PRECISION)
else 0 end ;;
  }

  measure: solves_count {
    type: count_distinct
    sql: ${id} ;;
  }


}
