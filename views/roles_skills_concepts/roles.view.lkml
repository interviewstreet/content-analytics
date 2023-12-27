view: roles {
  sql_table_name: role_rs_replica.role_prod.roles ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: aliases {
    type: string
    sql: ${TABLE}.aliases ;;
  }
  dimension: cloned_from {
    type: number
    sql: ${TABLE}.cloned_from ;;
  }
  dimension: cluster {
    type: number
    sql: ${TABLE}.cluster ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }
  dimension: job_family_id {
    type: number
    sql: ${TABLE}.job_family_id ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
  dimension: priority {
    type: number
    sql: ${TABLE}.priority ;;
  }
  dimension: seniority {
    type: number
    sql: ${TABLE}.seniority ;;
  }
  dimension: standard {
    type: number
    sql: ${TABLE}.standard ;;
  }
  dimension: state {
    type: number
    sql: ${TABLE}.state ;;
  }
  dimension: test_type {
    type: number
    sql: ${TABLE}.test_type ;;
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
  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }
  dimension: user_name {
    type: string
    sql: ${TABLE}.user_name ;;
  }
  dimension: years_of_experience {
    type: number
    sql: ${TABLE}.years_of_experience ;;
  }
  measure: count {
    type: count
    drill_fields: [id, user_name, name]
  }
}
