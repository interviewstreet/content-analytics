view: solves_attempt_data_mapping_for_time {
      derived_table: {
      sql: select aid as attempt_id, key, value as question_time_split, regexp_count(value, ':') as question_time_count
                from recruit_rs_replica.recruit.recruit_attempt_data
                where key = 'time_questions_split';;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: attempt_id {
      type: number
      sql: ${TABLE}.attempt_id ;;
    }

    dimension: key {
      type: string
      sql: ${TABLE}.key ;;
    }

    dimension: question_time_split {
      type: string
      sql: ${TABLE}.question_time_split ;;
    }

    dimension: question_time_count {
      type: number
      sql: ${TABLE}.question_time_count ;;
    }

    set: detail {
      fields: [
        attempt_id,
        key,
        question_time_split,
        question_time_count
      ]
    }
  }
