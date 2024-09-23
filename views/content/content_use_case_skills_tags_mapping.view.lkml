view: content_use_case_skills_tags_mapping {
      derived_table: {
      sql: WITH derived_question_skill_mapping AS (with  lib_q_skill_map as
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
                      else json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) end as modified_skill_name, -- Considering all 3 skills (basic, intermediate and advanced as one) )
                  --json_extract_array_element_text(json_extract_path_text(custom,'skills_obj',true),seq.n, true) as skill_unique_id
                  case when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Basic)%' then  'Basic'
                      when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Advanced)%' then 'Advanced'
                      when json_extract_array_element_text(json_extract_path_text(custom,'skills',true),seq.n, true) like '% (Intermediate)%' then 'Intermediate'
                      else 'No Proficiency Defined' end as proficiency
            from content_rs_replica.content.questions
            inner join
            (select row_number() over(order by true)::integer - 1 as n from content_rs_replica.content.questions limit 20) seq
            on seq.n <= json_array_length(json_extract_path_text(custom,'skills',true), true) - 1
            and product = 1
            )

            select distinct question_id,created_at,skill,modified_skill_name,proficiency, company_id
            from
            lib_q_skill_map )
        ,  question_tag_mapping AS (with lib_tags as
              (select q.id as qid, json_extract_array_element_text(q.tags, seq.rn) as "tag"
                    from content_rs_replica.content.questions as q
                    inner join
                    (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
                    on seq.rn < JSON_ARRAY_LENGTH(q.tags)
                    and json_extract_path_text(custom, 'company',true) = 14357
                   -- and rl.id IN (1,2,3,110,162,166,383,2188,2189,2190)
              )
                          select distinct "tag", qid as qid
                          from
                          lib_tags

                          )
      SELECT
          questions.id  AS "questions.id",
          LISTAGG(DISTINCT derived_question_skill_mapping.skill ,' | ') AS "Skills",
          LISTAGG(DISTINCT question_tag_mapping."tag" ,' | ') AS "Tags"
      FROM content_rs_replica.content.questions  AS questions
      LEFT JOIN derived_question_skill_mapping ON questions.id = derived_question_skill_mapping.question_id
      LEFT JOIN question_tag_mapping ON questions.id = question_tag_mapping.qid
      GROUP BY
          1
      ORDER BY
          1 ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: questions_id {
      type: number
      sql: ${TABLE}."questions.id" ;;
    }

    dimension: skills {
      type: string
      sql: ${TABLE}.skills ;;
    }

    dimension: tags {
      type: string
      sql: ${TABLE}.tags ;;
    }

    set: detail {
      fields: [
        questions_id,
        skills,
        tags
      ]
    }
  }
