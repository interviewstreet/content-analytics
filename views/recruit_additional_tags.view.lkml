view: recruit_additional_tags {
  sql_table_name: recruit.recruit_additional_tags ;;
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
  dimension: created_by {
    type: number
    sql: ${TABLE}.created_by ;;
  }
  dimension: eid {
    type: number
    value_format_name: id
    sql: ${TABLE}.eid ;;
  }
  dimension: tag {
    type: string
    sql: ${TABLE}.tag ;;
  }
  dimension: tag_type {
    type: number
    sql: ${TABLE}.tag_type ;;
  }
  dimension: taggable_type {
    type: string
    sql: ${TABLE}.taggable_type ;;
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
