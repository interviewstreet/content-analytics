view: derived_question_skill_mapping {

  derived_table: {
    sql: with  lib_q_skill_map as
            (
            select
            content_rs_replica.content.questions.id as question_id,
            json_extract_path_text(custom,'company',true) as company_id,
            created_at ,
            json_extract_path_text(custom,'skills',true) as skills,
            seq.n,
            json_array_length(json_extract_path_text(custom,'skills',true), true) as no_of_skills,
            --json_extract_path_text(json_extract_array_element_text(cq.skills_obj,seq.n, true),'name', true) as skill,
            --json_extract_path_text(json_extract_path_text(custom,'skills',true),seq.n, true) as skill_name
            json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) as skill,
            case when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Basic)%' then rtrim(json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true), '(Basic)')
                when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Advanced)%' then rtrim(json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true), '(Advanced)')
                when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Intermediate)%' then rtrim(json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true), '(Intermediate)')
                else json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) end as modified_skill_name -- Considering all 3 skills (basic, intermediate and advanced as one) )
            --json_extract_array_element_text(json_extract_path_text(custom,'skills_obj',true),seq.n, true) as skill_unique_id

      from content_rs_replica.content.questions
      inner join
      (select row_number() over(order by true)::integer - 1 as n from content_rs_replica.content.questions limit 20) seq
      on seq.n <= json_array_length(json_extract_path_text(custom,'skills',true), true) - 1
      and product = 1
      )

      select distinct question_id,created_at,skill,modified_skill_name, company_id
      from
      lib_q_skill_map ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: question_id {
    type: number
    sql: ${TABLE}.question_id ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: skill {
    type: string
    sql: ${TABLE}.skill ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: modified_skill_name {
    type: string
    sql: ${TABLE}.modified_skill_name ;;
  }

  set: detail {
    fields: [
      question_id,
      created_at_time,
      skill,
      modified_skill_name,
      company_id
    ]
  }

  measure: library_questions {
    type: count_distinct
    sql:case when company_id = 14357 then question_id else null end;;
  }

  measure: custom_questions {
    type: count_distinct
    sql:case when company_id <> 14357 then question_id else null end;;
  }
}
