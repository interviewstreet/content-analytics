view: skills {
  sql_table_name: role_rs_replica.role_prod.skills ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: archived_at {
    type: number
    sql: ${TABLE}.archived_at ;;
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
  dimension: logo_url {
    type: string
    sql: ${TABLE}.logo_url ;;
  }
  dimension: master_skill_id {
    type: number
    sql: ${TABLE}.master_skill_id ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: name_wo_prof {
    type: string
    sql: rtrim(ltrim(replace(replace(replace(name,'(Advanced)',''),'(Intermediate)',''),'(Basic)',''))) ;;
  }
  dimension: proficiency {
    type: number
    sql: ${TABLE}.proficiency ;;
  }
  dimension: similar_skills {
    type: string
    sql: ${TABLE}.similar_skills ;;
  }
  dimension: slug {
    type: string
    sql: ${TABLE}.slug ;;
  }
  dimension: standard {
    type: number
    sql: ${TABLE}.standard ;;
  }
  dimension: state {
    type: number
    sql: ${TABLE}.state ;;
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
  dimension: version_id {
    type: number
    sql: ${TABLE}.version_id ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name]
  }


  measure: count_skills_wo_prof{
    type: count_distinct
    sql: ${name_wo_prof} ;;
    drill_fields: [name_wo_prof]
  }

  measure: count_skills_w_prof{
    type: count_distinct
    sql: ${name} ;;
    drill_fields: [name]
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
