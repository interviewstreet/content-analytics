view: time_taken_per_question {
    derived_table: {
      sql: select
            rc.id as company_id,
            rc.name as company_name,
            rt.id as test_id,
            ra.id as attempt_id,
            ra.starttime as attempt_starttime,
            rs.id as solve_id,
            cq.id as question_id,
            concat(solve_id, question_id) as id,
            json_extract_path_text(a.question_time_split, split_part(b.questions,'-',seq.n), true)::integer as time_taken_per_question

            from recruit_rs_replica.recruit.recruit_solves rs
            inner join recruit_rs_replica.recruit.recruit_attempts ra
                on rs.aid = ra.id
                -- and attempt_email not like '%@hackerrank.com'
                -- and attempt_email not like '%@hackerrank.net'
                -- and attempt_email not like '%sandbox17e2d93e4afe44ea889d89aadf6d413f.mailgun.org'
                -- and attempt_email not like '@strongqa.com'
                and rs.status = 2
            inner join recruit_rs_replica.recruit.recruit_tests rt
                on abs(ra.tid) = rt.id
            inner join recruit_rs_replica.recruit.recruit_companies rc
                on rt.company_id = rc.id
                and 1=1 -- no filter on 'fact_attempt_time_taken_per_question.company_id'
       -- # This is Templated Filter in Looker which compulsarily requires users to enter value for this filter. So that this filter is also applied while creating the Temporary Table
                -- AND rc.company_stripe_plan NOT IN ('free', 'trial')
                -- AND lower(rc.company_name) NOT IN ('none', ' ', 'hackerrank','interviewstreet')
                -- AND lower(rc.company_name) NOT LIKE '%hackerrank%'
                -- AND lower(rc.company_name) NOT LIKE '%hacker%rank%'
                -- AND lower(rc.company_name) NOT LIKE '%interviewstreet%'
                -- AND lower(rc.company_name) NOT LIKE '%interview%street%'
                -- AND lower(rc.company_name) NOT LIKE 'Company%'
            inner join content_rs_replica.content.questions cq
                on rs.qid = cq.id
            inner join
                (select aid as attempt_id, key, value as question_time_split, regexp_count(value, ':') as question_time_count
                      from recruit_rs_replica.recruit.recruit_attempt_data
                      where key = 'time_questions_split'
                -- and attempt_data_attempt_id in (28477881,28450425,28402699)
                ) a
            on rs.aid = a.attempt_id
            inner join
                (select aid as attempt_id, key, value as questions, regexp_count(value, '-') + 1 as question_count
                      from recruit_rs_replica.recruit.recruit_attempt_data
                      where key = 'questions'
                -- and attempt_data_attempt_id in (28477881,28450425,28402699)
                ) b
            on a.attempt_id = b.attempt_id

            inner join
                (select row_number() over(order by true)::integer as n from content_rs_replica.content.questions limit 1000) seq
            on seq.n <= b.question_count
                and rs.qid = split_part(b.questions,'-',seq.n)
                -- and rs.solve_question_id = 111166
                -- and cq.question_company_id = 14357
                and cq.product = 1
                --and ( cq.id  = 1201636) -- # This is Templated Filter in Looker which compulsarily requires users to enter value for this filter. So that this filter is also applied while creating the Temporary Table
                -- and cq.question_id = 654355 -- 111166
                -- and rc.company_id = 3342
                -- and date(ra.attempt_starttime) >= '2021-01-01'
            order by rs.aid ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: company_id {
      type: number
      sql: ${TABLE}.company_id ;;
    }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

    dimension: company_name {
      type: string
      sql: ${TABLE}.company_name ;;
    }

    dimension: test_id {
      type: number
      sql: ${TABLE}.test_id ;;
    }

    dimension: attempt_id {
      type: number
      sql: ${TABLE}.attempt_id ;;
    }

    dimension_group: attempt_starttime {
      type: time
      sql: ${TABLE}.attempt_starttime ;;
    }

    dimension: solve_id {
      type: number
      sql: ${TABLE}.solve_id ;;
    }

    dimension: question_id {
      type: number
      sql: ${TABLE}.question_id ;;
    }

    dimension: time_taken_per_question {
      type: number
      sql: ${TABLE}.time_taken_per_question ;;
    }

    set: detail {
      fields: [
        id,
        company_id,
        company_name,
        test_id,
        attempt_id,
        attempt_starttime_time,
        solve_id,
        question_id,
        time_taken_per_question
      ]
    }
  }
