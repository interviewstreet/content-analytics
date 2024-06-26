view: question_skill_tag_mapping {

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
      ,lib_qstn as
        (select DISTINCT json_extract_array_element_text(rl.questions, seq.rn) as qid
              from recruit_rs_replica.recruit.recruit_library as rl
              inner join
              (select row_number() OVER (order by true)::integer - 1 as rn from  content_rs_replica.content.questions limit 10000) as seq
              on seq.rn < JSON_ARRAY_LENGTH(rl.questions)
              and rl.id IN (1,2,3,110,162,166,383,2188,2189,2190)
        )
      ,lib_q_skill_map as
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
        select  distinct modified_skill_name, skill, lib_tags."tag" ,lib_qstn.qid as qid
                    from
                    lib_qstn
                    join
                    lib_tags
                    on lib_qstn.qid = lib_tags.qid
                    join
                    lib_q_skill_map
                    on lib_q_skill_map.question_id = lib_qstn.qid
                    group by 1,2,3,4
                    order by 1,2,3 ;;
    }

  measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: modified_skill_name {
      type: string
      sql: ${TABLE}.modified_skill_name ;;
    }

    dimension: skill {
      type: string
      sql: ${TABLE}.skill ;;
    }

    dimension: tag {
      type: string
      sql: ${TABLE}."tag" ;;
    }

    dimension: qid {
      type: number
      sql: ${TABLE}.qid ;;
    }


    set: detail {
      fields: [
        modified_skill_name,
        skill,
        tag,
        qid
      ]
    }
  }
