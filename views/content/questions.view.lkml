view: questions {
  sql_table_name: content.questions ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: authkey {
    type: string
    sql: ${TABLE}.authkey ;;
  }
  dimension: author {
    type: string
    sql: ${TABLE}.author ;;
  }
  dimension: content_quality {
    type: string
    sql: ${TABLE}.content_quality ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension: custom {
    type: string
    sql: ${TABLE}.custom ;;
  }
  dimension: deleted {
    type: number
    sql: ${TABLE}.deleted ;;
  }
  dimension: draft {
    type: number
    sql: ${TABLE}.draft ;;
  }
  dimension: evaluator_params {
    type: string
    sql: ${TABLE}.evaluator_params ;;
  }
  dimension: format {
    type: string
    sql: ${TABLE}.format ;;
  }
  dimension: internal_notes {
    type: string
    sql: ${TABLE}.internal_notes ;;
  }
  dimension: is_valid {
    type: number
    value_format_name: id
    sql: ${TABLE}.is_valid ;;
  }
  dimension: leaked_data {
    type: string
    sql: ${TABLE}.leaked_data ;;
  }
  dimension: level {
    type: string
    sql: ${TABLE}.level ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
  dimension: parent_id {
    type: number
    sql: ${TABLE}.parent_id ;;
  }
  dimension: problem_statement {
    type: string
    sql: ${TABLE}.problem_statement ;;
  }
  dimension: product {
    type: number
    sql: ${TABLE}.product ;;
  }
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }
  dimension: score {
    type: number
    sql: ${TABLE}.score ;;
  }
  dimension: stack {
    type: string
    sql: ${TABLE}.stack ;;
  }
  dimension: status {
    type: number
    sql: ${TABLE}.status ;;
  }
  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }
  dimension: templates {
    type: string
    sql: ${TABLE}.templates ;;
  }
  dimension: testcases {
    type: string
    sql: ${TABLE}.testcases ;;
  }
  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }
  dimension: type_attributes {
    type: string
    sql: ${TABLE}.type_attributes ;;
  }
  dimension: unique_id {
    type: string
    sql: ${TABLE}.unique_id ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
  }
  dimension: version {
    type: number
    sql: ${TABLE}.version ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name]
  }

  # derived measure & dimension
  dimension: question_company_id {
    type: number
    sql: json_extract_path_text(custom,'company',true) ;;
  }

  dimension: question_role_type {
    type: string
    sql: case WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') = 'fullstack' THEN 'Fullstack-Fullstack'
              WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') = 'mobile' THEN 'Fullstack-Mobile'
              WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') = 'frontend' THEN 'Fullstack-Frontend'
              WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') = 'backend' THEN 'Fullstack-Backend'
              WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') = 'datascience' THEN 'Fullstack-Datascience'
              WHEN type = 'sudorank' THEN 'Fullstack-Devops'
              WHEN type = 'database' THEN 'Database'
              WHEN type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type') IS NULL THEN 'Fullstack-NULL'
              else type
              end;;
  }

  dimension: company_id {
    type: number
    sql: json_extract_path_text(custom,'company',true) ;;
  }

  dimension: role_type {
    type: string
    sql: json_extract_path_text(type_attributes,'role_type',true) ;;
  }

  measure: library_questions {
    type: count_distinct
    sql: case when json_extract_path_text(custom,'company',true) = 14357 then id else null end ;;
    }

  dimension: is_library_question {
    type: string
    sql: case when json_extract_path_text(custom,'company',true) = 14357 then 'yes' else 'no' end ;;
  }
  measure: custom_questions {
    type: count_distinct
    sql: case when json_extract_path_text(custom,'company',true) <> 14357 then id else null end ;;
}
}
