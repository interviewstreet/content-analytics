view: derived_hrw_library_questions_mapping {
      derived_table: {
      sql: with lib_qstn as
              (select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
                    from recruit_rs_replica.recruit.recruit_library as rl
                    inner join
                    (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
                    on seq.rn < JSON_ARRAY_LENGTH(rl.questions)
                    and rl.id IN (1,2,3,110,162,166,383,2188,2189,2190)
              )

              select qid
              from
              lib_qstn ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: qid {
      type: string
      sql: ${TABLE}.qid ;;
    }

    set: detail {
      fields: [
        qid
      ]
    }
  }
