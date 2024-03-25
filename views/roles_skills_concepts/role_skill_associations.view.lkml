view: role_skill_associations {
  sql_table_name: role_prod.role_skill_associations ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension: role_id {
    type: number
    sql: ${TABLE}.role_id ;;
  }
  dimension: skill_id {
    type: number
    sql: ${TABLE}.skill_id ;;
  }
  dimension: skill_importance {
    type: number
    sql: ${TABLE}.skill_importance ;;
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
  measure: count {
    type: count
    drill_fields: [id]
  }
}
