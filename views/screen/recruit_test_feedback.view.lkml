view: recruit_test_feedback {
  sql_table_name: recruit_rs_replica.recruit.recruit_test_feedback ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: col1 {
    type: number
    sql: ${TABLE}.col1 ;;
  }
  dimension: col2 {
    type: number
    sql: ${TABLE}.col2 ;;
  }
  dimension: col3 {
    type: number
    sql: ${TABLE}.col3 ;;
  }
  dimension: col4 {
    type: number
    sql: ${TABLE}.col4 ;;
  }
  dimension: col5 {
    type: number
    sql: ${TABLE}.col5 ;;
  }
  dimension: col6 {
    type: number
    sql: ${TABLE}.col6 ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}.comments ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  dimension_group: inserttime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.inserttime ;;
  }
  dimension: interface {
    type: string
    sql: ${TABLE}.interface ;;
  }
  dimension: mail_sent {
    type: number
    sql: ${TABLE}.mail_sent ;;
  }
  dimension: metadata {
    type: string
    sql: ${TABLE}.metadata ;;
  }
  dimension: product_rating {
    type: number
    sql: ${TABLE}.product_rating ;;
  }
  dimension: question_rating {
    type: number
    sql: ${TABLE}.question_rating ;;
  }
  dimension: test_candidate_id {
    type: number
    sql: ${TABLE}.test_candidate_id ;;
  }
  dimension: test_hash {
    type: string
    sql: ${TABLE}.test_hash ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
  }
  dimension: user_email {
    type: string
    sql: ${TABLE}.user_email ;;
  }
  measure: count {
    type: count
    drill_fields: [id]
  }

#### {{recruit_attempts.Count_distinct_id}}
  measure: average_rating {
    type: average
    sql: round(${TABLE}.product_rating*1.00,2) ;;
    drill_fields: [average_rating_company_level,average_rating_test_level]
    value_format: "0.00"
  }

  # measure: weighted_rating {
  #   type: number
  #   sql: ${recruit_attempts.Count_distinct_id} * ${TABLE}.product_rating * 1.00 ;;
  # }

  # measure: weighted_average_rating {
  #   type: number
  #   sql: sum(${weighted_rating})/sum(${recruit_attempts.Count_distinct_id}) ;;
  # }


  measure: average_rating_test_level {
    label: "Click # for Test Level Drill-Down"
    type: average
    sql: ${TABLE}.product_rating*1.00 ;;
    drill_fields: [recruit_companies.id,recruit_companies.name,recruit_tests.id,recruit_tests.name,average_rating]
  }

  measure: average_rating_company_level {
    label: "Click # for Company Level Drill-Down"
    type: average
    sql: ${TABLE}.product_rating*1.00 ;;
    drill_fields: [recruit_companies.id,recruit_companies.name,average_rating]
  }



}
