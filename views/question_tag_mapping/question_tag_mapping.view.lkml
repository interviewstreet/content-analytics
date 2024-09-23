view: question_tag_mapping {
      derived_table: {
      sql: with lib_tags as
        (select q.id as qid, json_extract_array_element_text(q.tags, seq.rn) as "tag"
              from content_rs_replica.content.questions as q
              inner join
              (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
              on seq.rn < JSON_ARRAY_LENGTH(q.tags)
              and json_extract_path_text(custom, 'company',true) = 14357
             -- and rl.id IN (1,2,3,110,162,166,383,2188,2189,2190)
        )
--      ,lib_qstn as
--        (select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
--              from recruit_rs_replica.recruit.recruit_library as rl
--              inner join
--              (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
--              on seq.rn < JSON_ARRAY_LENGTH(rl.questions)
--              and rl.id IN (1,2,3,110,162,166,383,2188,2189,2190)
--        )

                    select distinct "tag", qid as qid
                    from
                    lib_tags
--                    join
--                    lib_qstn
--                    on lib_qstn.qid = lib_tags.qid
                    --group by 1
                    ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: tag {
      type: string
      sql: ${TABLE}."tag" ;;
    }

    dimension: qid {
      type: number
      sql: ${TABLE}.qid ;;
    }

    measure: distinct_qid_count {
      type: count_distinct
      drill_fields: [qid]
      sql: ${TABLE}.qid       ;;
    }

  measure: distinct_tag_count {
    type: count_distinct
    drill_fields: [tag, distinct_qid_count]
    sql: ${TABLE}."tag";;
  }

    set: detail {
      fields: [
        "tag",
        qid
      ]
    }
  }
