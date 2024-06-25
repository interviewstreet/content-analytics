
view: library_questions {
  derived_table: {
    sql: with lib_qstn as
      (select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
            from recruit_rs_replica.recruit.recruit_library as rl
            inner join
            (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
            on seq.rn < JSON_ARRAY_LENGTH(rl.questions)
            and id IN (1,2,3,110,162,166,383,2188,2189,2190,2164, 1910)
      ),

      skill_map as (
      select
                          question_id,
                          question_skills_obj as skills,
                          seq.n,
                          json_array_length(question_skills_obj, true) as no_of_skills,
                          json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true) as skill,
                          case when json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true) like '% (Basic)%' then rtrim(json_extract_path_text (json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true), '(Basic)')
                              when json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true) like '% (Advanced)%' then rtrim(json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true), '(Advanced)')
                              when json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true) like '% (Intermediate)%' then rtrim(json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true), '(Intermediate)')
                              else json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'name', true) end as modified_skill_name, -- Considering all 3 skills (basic, intermediate and advanced as one) )
                          json_extract_path_text(json_extract_array_element_text(cq.question_skills_obj,seq.n, true),'unique_id', true) as skill_unique_id
                          from hr_analytics.global.dim_content_questions cq
                          inner join
                            (select row_number() over(order by true)::integer - 1 as n from hr_analytics.global.dim_content_questions limit 20) seq
                          on seq.n <= json_array_length(question_skills_obj, true) - 1
                            and question_product = 1
      )

      select lib_qstn.qid as qid, skill_map.skill as skill, cq.type as type, cq.created_at,
      ROW_NUMBER() OVER (ORDER BY qid) as row_num
      from
      lib_qstn
      inner join
      content_rs_replica.content.questions cq
      on cq.id = lib_qstn.qid
      inner join
      skill_map
      on skill_map.question_id = lib_qstn.qid;;
  }
  dimension: row_num {
    type: number
    primary_key: yes
    sql: ${TABLE}.row_num ;;
    }

  measure: count {
    type: count
    drill_fields: [qid, skill, type]
  }

  dimension: qid {
    type: string
    sql: ${TABLE}.qid ;;
  }

  dimension: skill {
    type: string
    sql: ${TABLE}.skill ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: Mcq_NonMcq {
    type: string
    sql: case WHEN ${TABLE}.type = 'mcq' or ${TABLE}.type = 'multiple_mcq' THEN 'MCQ'
              else 'Non MCQ'
              end;;
  }

  set: detail {
    fields: [
      qid,
      skill
    ]
  }
}
