view: median {
  derived_table: {
    sql: SELECT
                  recruit_tests.company_id as company_id,
                  recruit_solves.qid  AS question_ID,
                  case when json_extract_path_text(custom,'company',true) = 14357 then 'Library' else 'Custom' end  AS Is_library_question,
                  median(case when json_extract_path_text(recruit_solves.metadata,'max_score',true) is not null
                    AND trim(json_extract_path_text(recruit_solves.metadata,'max_score',true)) != ''
                    AND cast((json_extract_path_text(recruit_solves.metadata,'max_score',true))*1.0 as DOUBLE PRECISION) != 0
                    then
                    cast(recruit_solves.score as double precision)*100.0/cast( json_extract_path_text(recruit_solves.metadata,'max_score',true) as DOUBLE PRECISION)
                    else 0 end ) AS median_percentage_score

      FROM recruit_rs_replica.recruit.recruit_companies as recruit_companies
      LEFT JOIN recruit_rs_replica.recruit.recruit_tests  AS recruit_tests ON recruit_tests.company_id = recruit_companies.id
      and recruit_tests.draft =0
      and recruit_tests.state <> 3
      --              LEFT JOIN recruit_rs_replica.recruit.recruit_tests_questions  AS recruit_tests_questions ON recruit_tests.id = recruit_tests_questions.test_id

      LEFT JOIN recruit_rs_replica.recruit.recruit_attempts  AS recruit_attempts ON abs(recruit_attempts.tid) = recruit_tests.id
      ----- ATTEMPT LEVEL FILTERS
      and lower(recruit_attempts.email) not like '%@hackerrank.com%'  --- Exclude HR internal emails
      and lower(recruit_attempts.email) not like '%@hackerrank.net%'
      and lower(recruit_attempts.email) not like '%@interviewstreet.com%'
      and lower(recruit_attempts.email) not like '%sandbox17e2d93e4afe44ea889d89aadf6d413f.mailgun.org%'
      and lower(recruit_attempts.email) not like '%strongqa.com%'
      AND recruit_attempts.status =  7  ---- attempt submitted

      LEFT JOIN recruit_rs_replica.recruit.recruit_solves  AS recruit_solves ON recruit_attempts.id = recruit_solves.aid
      --and recruit_tests_questions.question_id = recruit_solves.qid

      and recruit_solves.aid > 0
      and recruit_solves.status = 2
      INNER JOIN content.questions  AS questions ON questions.id = recruit_solves.qid
      WHERE (recruit_solves.qid ) IS NOT NULL
      GROUP BY
      1,
      2,
      3;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: question_id {
    type: number
    sql: ${TABLE}.question_id ;;
  }

  dimension: is_library_question {
    type: string
    sql: ${TABLE}.is_library_question ;;
  }

  dimension: median_percentage_score {
    type: number
    sql: ${TABLE}.median_percentage_score ;;
  }

  set: detail {
    fields: [
      company_id,
      question_id,
      is_library_question,
      median_percentage_score
    ]
  }
}
