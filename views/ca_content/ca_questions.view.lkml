
view: ca_questions {
  derived_table: {
    sql: WITH dense_data AS (
      WITH data AS (
      WITH All_Questions_Details AS
          (WITH ever_paid AS
              (select distinct company_id as company_id from recruit_rs_replica.recruit.recruit_company_plan_changelogs
               where plan_name not in ('free', 'trial', 'user-freemium-interviews-v1','locked')
               -- # ever paid customers (This table has data only of companies created post 2018)
               ---- ^ Above query returns ever paid customer who joined 2018 onwards
              union
              select distinct id from recruit_rs_replica.recruit.recruit_companies rc
              where stripe_plan not in ('free', 'trial','user-freemium-interviews-v1','locked')
              and rc.type not in ('free', 'trial','locked')
              -- # using this logic to cover paid customers who are not covered in the above logic [company_plan_changelog table]
              ---- ^ currently active customers being missed out on prev query (2018 onwards set)
            ),

            questions as
            (
            Select
            cq.id,
            cq.name,
            json_extract_path_text(custom, 'added_to_library_on',true)  as Library_added_Details,
            case when json_extract_path_text(custom, 'recommended_duration',true) = '' then null
                 else json_extract_path_text(custom, 'recommended_duration',true)::integer end as Recm_Time,
            case when tags LIKE '%Easy%' then 'Easy'
                 when tags LIKE '%Medium%' then 'Medium'
                 when tags LIKE '%Hard%' THEN 'Hard'
                 else 'Undefined' end difficulty,
            case when json_extract_path_text(leaked_data,'show',true) = 'true' then 'true'
                 else 'false' end as leaked_data,
            cq.tags,
            json_extract_path_text(json_extract_array_element_text(json_extract_path_text(custom, 'skills_obj',true),0,true),'name',true) as  skill_obj,
            rtrim(ltrim(replace(replace(replace(skill_obj,'(Advanced)',''),'(Intermediate)',''),'(Basic)',''))) as Skills_new,
            custom,
            dcq.question_points,
            case when lower(json_extract_path_text(json_extract_array_element_text(json_extract_path_text(custom, 'skills_obj',true),0,true),'name',true)) like '%basic%' then 'Basic'
            when lower(json_extract_path_text(json_extract_array_element_text(json_extract_path_text(custom, 'skills_obj',true),0,true),'name',true)) like '%intermediate%' then 'Intermediate'
            when lower(json_extract_path_text(json_extract_array_element_text(json_extract_path_text(custom, 'skills_obj',true),0,true),'name',true)) like '%advanced%' then 'Advanced'
            else 'Undefined' end as Proficiency,
            type as Type_,
            case when Skills_new is null then 'Undefined' else Skills_new end || Proficiency||Type || difficulty as Concat
            from content_rs_replica.content.questions cq
            left join hr_analytics.global.dim_content_questions dcq on dcq.question_id=cq.id
            inner join (
                          select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
                          from recruit_rs_replica.recruit.recruit_library as rl, (select row_number() OVER (order by true)::integer - 1 as rn
                          from  content_rs_replica.content.questions limit 10000) as seq
                          where seq.rn < JSON_ARRAY_LENGTH(rl.questions)
                          and id IN (1,2,3,110,162,166,383,921,1910)
                        ) lib
            on cq.id=lib.qid
            where status = 1
            and deleted = 0
            and is_valid = 1
            ),

            question_scores as
            (
            SELECT
            q.id as Question_id,
            count(distinct rs.aid) as attempts,
            max(rs.aid) as attempt_id_max,
            avg(case when question_points <= 0 or rs.score <= 0 then 0
                     when rs.score*100.0/q.question_points >100 then 100
                     else rs.score*100.0/q.question_points end ) as avg_perc_score,
            count(distinct case when rs.score >= q.question_points then rs.aid end) as full_score_candidates
            FROM recruit.recruit_tests  AS recruit_tests
            INNER JOIN recruit.recruit_attempts  AS recruit_attempts ON recruit_attempts.tid = recruit_tests.id
            and isnull(recruit_attempts.email, '')  NOT like '%@hackerrank.com'
            and isnull(recruit_attempts.email, '')  NOT like '%@hackerrank.net'
            and isnull(recruit_attempts.email, '')  NOT like '%sandbox17e2d93e4afe44ea889d89aadf6d413f.mailgun.org'
            and isnull(recruit_attempts.email, '')  NOT like '%@strongqa.com'
            and recruit_tests.draft = 0
            and recruit_tests.state <> 3
            and not exists (Select 1 from recruit.recruit_users ru
                            where recruit_attempts.email= ru.email and abs(recruit_tests.company_id)=ru.company_id)
            INNER JOIN recruit.recruit_companies AS recruit_companies ON recruit_companies.id = abs(recruit_tests.company_id)
            and recruit_companies.id not in (65904,107170,106529,46242)
            and lower(recruit_companies.name) not in ('none', ' ', 'hackerrank','interviewstreet') --- Filter internal accounts based on company names
            and lower(recruit_companies.name) not like '%hackerrank%'
            and lower(recruit_companies.name) not like '%hacker%rank%'
            and lower(recruit_companies.name) not like '%interviewstreet%'
            and lower(recruit_companies.name) not like '%interview%street%'
            and recruit_companies.name not like 'Company%'
            inner join recruit_rs_replica.recruit.recruit_solves rs on rs.aid=recruit_attempts.id
            INNER JOIN ever_paid ON recruit_companies.id = ever_paid.company_id
            INNER JOIN recruit.recruit_users  AS recruit_users ON abs(recruit_tests.owner) = recruit_users.id
            inner join questions q on q.id=rs.qid
            WHERE isnull(recruit_users.email, '')  NOT like '%@hackerrank.com'
            AND isnull(recruit_users.email, '')  NOT like '%@hackerrank.net'
            AND isnull(recruit_users.email, '')  NOT like '%sandbox17e2d93e4afe44ea889d89aadf6d413f.mailgun.org'
            AND isnull(recruit_users.email, '')  NOT like '%@strongqa.com'
            group by 1
            ),

            final_data as
            (
            Select
              q.id,
              q.name as Question_name,
              q.Library_added_Details,
              q.Recm_Time,
              q.difficulty,
              q.leaked_data,
              q.tags,
              q.Skills_new,
              q.question_points,
              q.Proficiency,
              q.Type_,
              q.Concat,
              qs.avg_Perc_score,
              qs.full_score_candidates,
              avg(case when
                      (case when Proficiency = 'Advanced' and Recm_Time > 120 then False
                       when Proficiency = 'Intermediate' and Recm_Time > 90 then false
                       when Proficiency = 'Basic' and Recm_Time > 60 then false
                       else true end)
                  and not (isnull(qs.attempts,0) > 200 and isnull(full_score_candidates,0)*100.0/isnull(qs.attempts,0) < 2.0)
                  and qs.attempts > 0 then avg_perc_score end) over(partition by q.concat) as concat_avg,
              avg(case when
                      (case when Proficiency = 'Advanced' and Recm_Time > 120 then False
                       when Proficiency = 'Intermediate' and Recm_Time > 90 then false
                       when Proficiency = 'Basic' and Recm_Time > 60 then false
                       else true end)
                  and not (isnull(qs.attempts,0) > 200 and isnull(full_score_candidates,0)*100.0/isnull(qs.attempts,0) < 2.0)
                  and qs.attempts > 0 then Recm_Time end) over(partition by q.concat) as concat_recm_time,
              stddev_samp(case when
                      (case when Proficiency = 'Advanced' and Recm_Time > 120 then False
                       when Proficiency = 'Intermediate' and Recm_Time > 90 then false
                       when Proficiency = 'Basic' and Recm_Time > 60 then false
                       else true end)
                  and not (isnull(qs.attempts,0) > 200 and isnull(full_score_candidates,0)*100.0/isnull(qs.attempts,0) < 2.0)
                  and qs.attempts>0  then Recm_Time end ) over(partition by q.concat) as Concat_recm_time_std,
              Concat_avg - 7.5 avg_Perc_score_lower_limit,
              Concat_avg+ 22.5 avg_Perc_score_upper_limit,
              case when proficiency = 'Advanced' then Concat_recm_time-10 else Concat_recm_time-7.5 end as Rec_Time_Lower_Limit,
              case when proficiency = 'Advanced' then Concat_recm_time+10 else Concat_recm_time+7.5 end as Rec_Time_Upper_Limit,
              qs.attempts,
              qs.Attempt_id_max
              from question_scores qs
              right join questions q
              on q.id = qs.Question_id
              where
              true
              group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,22,23)

      Select * , id in
      (
      111164,
      111166,
      111168,
      127473,
      127486,
      127569,
      127846,
      127852,
      129099,
      130302,
      130306,
      130309,
      133529,
      133563,
      133564,
      133565,
      138985,
      138988,
      152001,
      157141,
      157954,
      157957,
      159956,
      161850,
      203144,
      207299,
      207533,
      222784,
      222912,
      222916,
      222918,
      222919,
      222923,
      230426,
      232646,
      241340,
      242228,
      242235,
      250126,
      250305,
      253248,
      255044,
      263255,
      287483,
      296164,
      299452,
      308704,
      314070,
      314436,
      317984,
      318334,
      318890,
      321536,
      333418,
      342567,
      432109,
      432110,
      440905,
      451038,
      463750,
      463752,
      471240,
      472553,
      472555,
      478608,
      479343,
      480351,
      482024,
      483740,
      483758,
      554079,
      555004,
      555314,
      558363,
      558403,
      561216,
      569447,
      569451,
      573606,
      598407,
      616680,
      617208,
      620610,
      622265,
      622874,
      667506,
      667682,
      667979,
      670464,
      672952,
      748395,
      748679,
      748692,
      750142,
      757882,
      757892,
      757894,
      757895,
      757896,
      757898,
      795828,
      795851,
      832714,
      832716,
      953845,
      954788,
      957469,
      995580,
      997671,
      1019351,
      1019783,
      1019800,
      1021930,
      1022019,
      1022072,
      1022796,
      1023254,
      1034575,
      1083660,
      1089085,
      1095584,
      1121600,
      1151606,
      1177851,
      1182096,
      1202011,
      1203252,
      1211503,
      1230058,
      1230082,
      1230090,
      1230189,
      1252022,
      1266907,
      1275496,
      1275498,
      1275500,
      1329866,
      1376428,
      1384726,
      1384728,
      1384737,
      1397686,
      1429608,
      1435933) as AI_Solvable from final_data)

      SELECT
          All_Questions_Details.id  AS "question_id",
          All_Questions_Details.question_name  AS "question_name",
          All_Questions_Details.library_added_details  AS "library_added_details",
          All_Questions_Details.recm_time  AS "recm_time",
          All_Questions_Details.recm_time + 15  AS "recm_time_plus_15",
          case when All_Questions_Details.rec_time_lower_limit < 0 then 0 else All_Questions_Details.rec_time_lower_limit end AS "recm_time_lower_limit",
          All_Questions_Details.rec_time_upper_limit  AS "recm_time_upper_limit",
          All_Questions_Details.leaked_data  AS "leaked_question",
          All_Questions_Details.tags  AS "tags",
          All_Questions_Details.difficulty  AS "difficulty",
          All_Questions_Details.skills_new  AS "skills_new",
          All_Questions_Details.question_points  AS "question_points",
          All_Questions_Details.proficiency  AS "proficiency",
          All_Questions_Details.attempts  AS "attempts_count",
          All_Questions_Details.full_score_candidates  AS "full_score_candidates_count",
          All_Questions_Details.type_  AS "type_",
          All_Questions_Details.avg_perc_score  AS "avg_perc_score",
          All_Questions_Details.avg_perc_score + 25  AS "avg_perc_score_plus_25",
          case when All_Questions_Details.avg_perc_score_lower_limit < 0 then 0 else All_Questions_Details.avg_perc_score_lower_limit end  AS "avg_perc_score_lower_limit",
          All_Questions_Details.avg_perc_score_upper_limit  AS "avg_perc_score_upper_limit",
          All_Questions_Details.concat  AS "concat",
          All_Questions_Details.concat_avg  AS "concat_avg",
          All_Questions_Details.concat_recm_time  AS "concat_recm_time",
          All_Questions_Details.Concat_recm_time_std  AS "concat_recm_time_std",
          All_Questions_Details.Attempt_id_max  AS "attempt_id_max",
          All_Questions_Details.AI_Solvable  AS "ai_solvable"
      FROM All_Questions_Details
      --where all_questions_details.ai_solvable = 'false' and all_questions_details.leaked_data = 'false'
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
      ORDER BY 1
      LIMIT 50000
      )

      select
      d1.*,
      sum (case when d1.ai_solvable = 'false' and d1.leaked_question = 'false' and
      d2."recm_time" >= d1."recm_time" and d2."recm_time" <= d1."recm_time_plus_15" then 1 else 0 end) as time_density,
      max(time_density) over (partition by d1."concat") as max_time_density,
      sum (case when d1.ai_solvable = 'false' and d1.leaked_question = 'false' and
      d2."avg_perc_score" >= d1."avg_perc_score" and d2."avg_perc_score" <= d1."avg_perc_score_plus_25" then 1 else 0 end) as score_density,
      max(score_density) over (partition by d1."concat") as max_score_density
      from data d1
      join data d2
      on d1."concat" = d2."concat"
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
      ORDER BY 21, 4
      )

      select *,
      min(case when ai_solvable = 'false' and leaked_question = 'false' and
      (time_density = max_time_density) then "recm_time" end) over (partition by "concat") as recm_time_lower_limit_new,
      min(case when ai_solvable = 'false' and leaked_question = 'false' and
      (time_density = max_time_density) then "recm_time_plus_15" end) over (partition by "concat") as recm_time_upper_limit_new,
      -- max(case when ai_solvable = 'false' and leaked_question = 'false' and
      -- (time_density = max_time_density) then "recm_time_plus_15" end) over (partition by "concat") as recm_time_upper_limit_new,
      min(case when ai_solvable = 'false' and leaked_question = 'false' and
      (score_density = max_score_density) then "avg_perc_score" end) over (partition by "concat") as score_lower_limit_new,
      min(case when ai_solvable = 'false' and leaked_question = 'false' and
      (score_density = max_score_density) then "avg_perc_score_plus_25" end) over (partition by "concat") as score_upper_limit_new_2,
      -- max(case when ai_solvable = 'false' and leaked_question = 'false' and
      -- (score_density = max_score_density) then "avg_perc_score_plus_25" end) over (partition by "concat") as score_upper_limit_new_2,
      case when score_upper_limit_new_2 > 100 then 100 else score_upper_limit_new_2 end score_upper_limit_new,
      case when (ai_solvable = 'false' and leaked_question = 'false' and
      "recm_time" >= recm_time_lower_limit_new and "recm_time" <= recm_time_upper_limit_new) then 'Yes' ELSE 'No' END as time_satisfied,
      case when (ai_solvable = 'false' and leaked_question = 'false' and
      "avg_perc_score" >= score_lower_limit_new and "avg_perc_score" <= score_upper_limit_new) then 'Yes' ELSE 'No' END as score_satisfied,
      case when (ai_solvable = 'false' and leaked_question = 'false' and
      time_satisfied = 'Yes' and score_satisfied = 'Yes') then 'Yes' else 'No' end as both_satified
      from dense_data
      where both_satified = 'Yes'

      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
      ORDER BY 21, 4 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: question_id {
    type: number
    sql: ${TABLE}.question_id ;;
  }

  dimension: question_name {
    type: string
    sql: ${TABLE}.question_name ;;
  }

  dimension: library_added_details {
    type: string
    sql: ${TABLE}.library_added_details ;;
  }

  dimension: recm_time {
    type: number
    sql: ${TABLE}.recm_time ;;
  }

  dimension: recm_time_plus_15 {
    type: number
    sql: ${TABLE}.recm_time_plus_15 ;;
  }

  dimension: recm_time_lower_limit {
    type: number
    sql: ${TABLE}.recm_time_lower_limit ;;
  }

  dimension: recm_time_upper_limit {
    type: number
    sql: ${TABLE}.recm_time_upper_limit ;;
  }

  dimension: leaked_question {
    type: string
    sql: ${TABLE}.leaked_question ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }

  dimension: difficulty {
    type: string
    sql: ${TABLE}.difficulty ;;
  }

  dimension: skills_new {
    type: string
    sql: ${TABLE}.skills_new ;;
  }

  dimension: question_points {
    type: number
    sql: ${TABLE}.question_points ;;
  }

  dimension: proficiency {
    type: string
    sql: ${TABLE}.proficiency ;;
  }

  dimension: attempts_count {
    type: number
    sql: ${TABLE}.attempts_count ;;
  }

  dimension: full_score_candidates_count {
    type: number
    sql: ${TABLE}.full_score_candidates_count ;;
  }

  dimension: type_ {
    type: string
    sql: ${TABLE}.type_ ;;
  }

  dimension: avg_perc_score {
    type: number
    sql: ${TABLE}.avg_perc_score ;;
  }

  dimension: avg_perc_score_plus_25 {
    type: number
    sql: ${TABLE}.avg_perc_score_plus_25 ;;
  }

  dimension: avg_perc_score_lower_limit {
    type: number
    sql: ${TABLE}.avg_perc_score_lower_limit ;;
  }

  dimension: avg_perc_score_upper_limit {
    type: number
    sql: ${TABLE}.avg_perc_score_upper_limit ;;
  }

  dimension: concat {
    type: string
    sql: ${TABLE}.concat ;;
  }

  dimension: concat_avg {
    type: number
    sql: ${TABLE}.concat_avg ;;
  }

  dimension: concat_recm_time {
    type: number
    sql: ${TABLE}.concat_recm_time ;;
  }

  dimension: concat_recm_time_std {
    type: number
    sql: ${TABLE}.concat_recm_time_std ;;
  }

  dimension: attempt_id_max {
    type: number
    sql: ${TABLE}.attempt_id_max ;;
  }

  dimension: ai_solvable {
    type: string
    sql: ${TABLE}.ai_solvable ;;
  }

  dimension: time_density {
    type: number
    sql: ${TABLE}.time_density ;;
  }

  dimension: max_time_density {
    type: number
    sql: ${TABLE}.max_time_density ;;
  }

  dimension: score_density {
    type: number
    sql: ${TABLE}.score_density ;;
  }

  dimension: max_score_density {
    type: number
    sql: ${TABLE}.max_score_density ;;
  }

  dimension: recm_time_lower_limit_new {
    type: number
    sql: ${TABLE}.recm_time_lower_limit_new ;;
  }

  dimension: recm_time_upper_limit_new {
    type: number
    sql: ${TABLE}.recm_time_upper_limit_new ;;
  }

  dimension: score_lower_limit_new {
    type: number
    sql: ${TABLE}.score_lower_limit_new ;;
  }

  dimension: score_upper_limit_new_2 {
    type: number
    sql: ${TABLE}.score_upper_limit_new_2 ;;
  }

  dimension: score_upper_limit_new {
    type: number
    sql: ${TABLE}.score_upper_limit_new ;;
  }

  dimension: time_satisfied {
    type: string
    sql: ${TABLE}.time_satisfied ;;
  }

  dimension: score_satisfied {
    type: string
    sql: ${TABLE}.score_satisfied ;;
  }

  dimension: both_satified {
    type: string
    sql: ${TABLE}.both_satified ;;
  }

  set: detail {
    fields: [
      question_id,
      question_name,
      library_added_details,
      recm_time,
      recm_time_plus_15,
      recm_time_lower_limit,
      recm_time_upper_limit,
      leaked_question,
      tags,
      difficulty,
      skills_new,
      question_points,
      proficiency,
      attempts_count,
      full_score_candidates_count,
      type_,
      avg_perc_score,
      avg_perc_score_plus_25,
      avg_perc_score_lower_limit,
      avg_perc_score_upper_limit,
      concat,
      concat_avg,
      concat_recm_time,
      concat_recm_time_std,
      attempt_id_max,
      ai_solvable,
      time_density,
      max_time_density,
      score_density,
      max_score_density,
      recm_time_lower_limit_new,
      recm_time_upper_limit_new,
      score_lower_limit_new,
      score_upper_limit_new_2,
      score_upper_limit_new,
      time_satisfied,
      score_satisfied,
      both_satified
    ]
  }
}
