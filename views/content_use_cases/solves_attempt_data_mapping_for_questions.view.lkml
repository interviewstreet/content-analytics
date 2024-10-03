view: solves_attempt_data_mapping_for_questions {
    derived_table: {
      sql: select aid as attempt_id, key, value as questions, regexp_count(value, '-') + 1 as question_count
                from recruit_rs_replica.recruit.recruit_attempt_data
                where key = 'questions';;
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

    dimension: questions {
      type: string
      sql: ${TABLE}.questions ;;
    }

    dimension: question_count {
      type: number
      sql: ${TABLE}.question_count ;;
    }

    set: detail {
      fields: [
        attempt_id,
        key,
        questions,
        question_count
      ]
    }
  }
