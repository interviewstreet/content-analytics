view: questions {
  sql_table_name: content_rs_replica.content.questions ;;
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

  # Modified by Ashish
  # on May 20
  dimension: stack_json {
    type: string
    sql: ${TABLE}.stack ;;
  }

  # added by Ashish
  # on May 20
  dimension: stack_name {
    type: string
    sql: json_extract_path_text(${TABLE}.stack, 'name',true) ;;
    description: "Stack is only present for project (fullstack) question types"
  }

  # added by Sourabh
  # on May 28
  dimension: languages {
    type: string
    sql: json_extract_path_text(${TABLE}.type_attributes, 'languages', true) ;;
    description: "langs. associated with question"
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

  measure: question_count {
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [id, name, is_library_question, question_company_id, tags, author, type, created_date]
  }
  dimension: question_company_id {
    type: number
    sql: json_extract_path_text(custom,'company',true) ;;
  }

  dimension: question_role_type {
    type: string
    sql: case WHEN ${TABLE}.type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type',true) = 'fullstack' THEN 'Fullstack-Fullstack'
              WHEN ${TABLE}.type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type',true) = 'mobile' THEN 'Fullstack-Mobile'
              WHEN ${TABLE}.type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type',true) = 'frontend' THEN 'Fullstack-Frontend'
              WHEN ${TABLE}.type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type',true) = 'backend' THEN 'Fullstack-Backend'
              WHEN ${TABLE}.type = 'fullstack'
                   AND json_extract_path_text(type_attributes, 'role_type',true) = 'datascience' THEN 'Fullstack-Datascience'
              WHEN ${TABLE}.type = 'sudorank' THEN 'Fullstack-Devops'
              WHEN ${TABLE}.type = 'database' THEN 'Database'
              else ${TABLE}.type
              end;;
  }

  dimension: Mcq_NonMcq {
    type: string
    sql: case WHEN ${TABLE}.type = 'mcq' or ${TABLE}.type = 'multiple_mcq' THEN 'MCQ'
              else 'Non MCQ'
              end;;
  }

  dimension: company_id {
    type: number
    sql: json_extract_path_text(custom,'company',true)::integer ;;
  }

  dimension: author_id {
    type: string
    sql: json_extract_path_text(author,'id',true) ;;
  }

  dimension: role_type {
    type: string
    sql: json_extract_path_text(type_attributes,'role_type',true) ;;
  }

  measure: library_questions {
    type: count_distinct
    sql: case when json_extract_path_text(custom,'company',true) = 14357 then ${id} else null end ;;
    }

  dimension: is_library_question {
    type: string
    sql: case when json_extract_path_text(custom,'company',true) = 14357 then 'Library' else 'Custom' end ;;
  }
  measure: custom_questions {
    type: count_distinct
    sql: case when json_extract_path_text(custom,'company',true) <> 14357 then ${id} else null end ;;
}

  dimension: MCQ_NonMCQ {
    type: string
    sql: case when ${type} = 'mcq' or ${type} = 'multiple_mcq' then 'MCQ' else 'Non_MCQ' end ;;
  }

  dimension: is_leaked {
    type: string
    sql: case when json_extract_path_text(${leaked_data},'show',true) = 'true' then 'True'
    when json_extract_path_text(${leaked_data},'show',true) = 'false' then 'False'
    else null end ;;
  }

  dimension: skills {
    type: string
    sql: json_extract_path_text(custom,'skills',true) ;;
  }

  dimension: points {
    type: number
    sql: CASE
        WHEN trim(json_extract_path_text(type_attributes,'points', true)) ~ '^[0-9.]+$' THEN json_extract_path_text(type_attributes,'points', true)::decimal
        ELSE NULL
    END;;
  }

  dimension: recommended_duration {
    type: number
    sql: json_extract_path_text(${custom},'recommended_duration',true)::int ;;
  }

  parameter: date_granularity {
    type: unquoted
    description: "Select the appropiate level of granularity for dashboard."
    default_value: "day"

    allowed_value: {
      label: "Day"
      value: "day"
    }
    allowed_value: {
      label: "Month"
      value: "month"
    }
    allowed_value: {
      label: "Quarter"
      value: "quarter"
    }
    allowed_value: {
      label: "Year"
      value: "year"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
  }
}
