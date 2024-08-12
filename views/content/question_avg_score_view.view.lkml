view: question_avg_score_view {
 derived_table: {
      sql: SELECT
            a.id as qid,
            json_extract_path_text(a.type_attributes,'points',true) as max_score,
            avg(b.score) as avg_score
          FROM content_rs_replica.content.questions AS a
          JOIN recruit_rs_replica.recruit.recruit_solves AS b
          ON a.id = b.qid
          group by 1,2;;  # Replace with your actual join condition
    }


  dimension: qid {
    type: number
    sql: ${TABLE}.qid ;;
  }
    dimension: max_score {
      type: number
      sql: ${TABLE}.max_score ;;
    }

    dimension: avg_score {
      type: number
      sql: ${TABLE}.avg_score ;;
    }

    measure: avg_percentage_score {
      type: number
      sql: ${avg_score} / ${max_score} ;;
    }
  }
