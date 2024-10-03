view: sequence {
      derived_table: {
      sql: select row_number() over(order by true)::integer as n from content_rs_replica.content.questions limit 1000 ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: n {
      type: number
      sql: ${TABLE}.n ;;
    }

    set: detail {
      fields: [
        n
      ]
    }
  }
