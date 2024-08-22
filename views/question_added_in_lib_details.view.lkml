view: question_added_in_lib_details {
      derived_table: {
      sql: with lib_qstn as
            (select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
                  from recruit_rs_replica.recruit.recruit_library as rl
                  inner join
                  (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
                  on seq.rn < JSON_ARRAY_LENGTH(rl.questions)
                  and id IN (1,2,3,110,162,166,383,2188,2189,2190,2164, 1910)
            ),

       question_add_to_lib as
      (SELECT id,
      json_extract_path_text(custom, 'added_to_library_on') as library_details,
              CASE seq.seq
                  WHEN 1 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 1), ':', 2))
                  WHEN 2 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 2), ':', 2))
                  WHEN 3 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 3), ':', 2))
                  WHEN 4 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 4), ':', 2))
                  WHEN 5 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 5), ':', 2))
                  WHEN 6 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 6), ':', 2))
                  WHEN 7 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 7), ':', 2))
                  WHEN 8 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 8), ':', 2))
                  WHEN 9 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 9), ':', 2))
                  WHEN 10 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 10), ':', 2))
                  WHEN 11 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 11), ':', 2))
                  WHEN 12 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 12), ':', 2))

              END AS date_value,
              CASE seq.seq
                  WHEN 1 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 1), ':', 1))
                  WHEN 2 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 2), ':', 1))
                  WHEN 3 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 3), ':', 1))
                  WHEN 4 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 4), ':', 1))
                  WHEN 5 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 5), ':', 1))
                  WHEN 6 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 6), ':', 1))
                  WHEN 7 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 7), ':', 1))
                  WHEN 8 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 8), ':', 1))
                  WHEN 9 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 9), ':', 1))
                  WHEN 10 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 10), ':', 1))
                  WHEN 11 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 11), ':', 1))
                  WHEN 12 THEN TRIM(BOTH '"' FROM SPLIT_PART(SPLIT_PART(json_extract_path_text(custom, 'added_to_library_on'), ',', 12), ':', 1))

              END AS lib_id
          FROM
              content_rs_replica.content.questions
          CROSS JOIN
              (SELECT 1 AS seq UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) AS seq
              JOIN
              lib_qstn on lib_qstn.qid = questions.id
          WHERE
              json_extract_path_text(custom, 'added_to_library_on') IS NOT NULL
              )

              select question_add_to_lib.id as id, cq.type as question_type, library_details, max(to_date(left(date_value, 10),'YYYY-MM-DD'))
              from
              question_add_to_lib
              join
              content_rs_replica.content.questions cq
              on cq.id = question_add_to_lib.id
              group by 1,2,3 ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: id {
      type: number
      sql: ${TABLE}.id ;;
    }

    dimension: library_details {
      type: string
      sql: ${TABLE}.library_details ;;
    }

  dimension: question_type {
    type: string
    sql: ${TABLE}.question_type ;;
  }

    dimension: max {
      type: date
      sql: ${TABLE}.max ;;
    }

    set: detail {
      fields: [
        id,
        library_details,
        max
      ]
    }
  }
