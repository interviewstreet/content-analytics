connection: "content_rs_replica"
include: "/**/*.view.lkml"


explore: questions {
  label: "content_analytics"

  join: recruit_companies {
    type: inner
    relationship: many_to_one
    sql_on: ${questions.question_company_id} =  ${recruit_companies.id}
          and ${recruit_companies.id} not in (46242,  106529 )
          and lower(${recruit_companies.name}) not in ('none', ' ', 'hackerrank','interviewstreet') --- Filter internal accounts based on company names
          and lower(${recruit_companies.name}) not like '%hackerrank%'
          and lower(${recruit_companies.name}) not like '%hacker%rank%'
          and lower(${recruit_companies.name}) not like '%interviewstreet%'
          and lower(${recruit_companies.name}) not like '%interview%street%';;

  }

  join: recruit_users {
    type: inner
    relationship: many_to_one
    sql_on: ${recruit_users.id} = ${questions.author_id}  ;;
  }

  join: derived_hrw_library_questions_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${derived_hrw_library_questions_mapping.qid} ;;
  }

  join: content_use_case_skills_tags_mapping {
  type: left_outer
  relationship: one_to_one
  sql_on: ${content_use_case_skills_tags_mapping.questions_id} = ${questions.id} ;;
  }

  join: derived_question_skill_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${derived_question_skill_mapping.question_id}  ;;
  }

  join: question_tag_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${question_tag_mapping.qid}  ;;
  }

  join: recruit_tests_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${recruit_tests_questions.question_id} ;;
  }

  join: recruit_tests {
    type: left_outer
    relationship: many_to_one
    sql_on: ${recruit_tests.id} = ${recruit_tests_questions.test_id}
          and ${recruit_tests.draft} =0
          and ${recruit_tests.state} <> 3;;
  }

  join: recruit_companies_test_company_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${recruit_tests.company_id} = ${recruit_companies_test_company_mapping.id}
      ;;  }

  join: recruit_attempts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${recruit_tests.id} = abs(${recruit_attempts.tid})
          ----- ATTEMPT LEVEL FILTERS
      and lower(${recruit_attempts.email}) not like '%@hackerrank.com%'  --- Exclude HR internal emails
      and lower(${recruit_attempts.email}) not like '%@hackerrank.net%'
      and lower(${recruit_attempts.email}) not like '%@interviewstreet.com%'
      and lower(${recruit_attempts.email}) not like '%sandbox17e2d93e4afe44ea889d89aadf6d413f.mailgun.org%'
      and lower(${recruit_attempts.email}) not like '%strongqa.com%'
      AND ${recruit_attempts.status} =  7  ---- attempt submitted
      ;;
  }

  join: recruit_solves {
    type: left_outer
    relationship: one_to_many
    sql_on: ${recruit_attempts.id} = ${recruit_solves.aid}
          and ${recruit_tests_questions.question_id} = ${recruit_solves.qid}
          and ${recruit_solves.aid} > 0
          and ${recruit_solves.status} = 2
      ;;
  }}


explore: recruit_companies {
  label: "content_analytics_v2"

  join: recruit_tests {
    type: inner
    relationship: many_to_one
    sql_on: ${recruit_tests.company_id} = ${recruit_companies.id}
          and ${recruit_tests.draft} =0
          and ${recruit_tests.state} <> 3
          and ${recruit_companies.id} not in (46242,  106529 )
          and lower(${recruit_companies.name}) not in ('none', ' ', 'hackerrank','interviewstreet') --- Filter internal accounts based on company names
          and lower(${recruit_companies.name}) not like '%hackerrank%'
          and lower(${recruit_companies.name}) not like '%hacker%rank%'
          and lower(${recruit_companies.name}) not like '%interviewstreet%'
          and lower(${recruit_companies.name}) not like '%interview%street%'
          and ${recruit_companies.name} not like 'Company%';;
  }

  join: recruit_tests_questions {
    type: inner
    relationship: one_to_many
    sql_on: ${recruit_tests.id} = ${recruit_tests_questions.test_id} ;;
  }

  join: questions {
    type: inner
    relationship: many_to_one
    sql_on: ${questions.id} = ${recruit_tests_questions.question_id} ;;
  }

  join: recruit_solves {
    type: left_outer
    relationship: many_to_one
    sql_on: ${recruit_tests_questions.question_id} = ${recruit_solves.qid}
          and ${recruit_solves.aid} > 0
          and ${recruit_solves.status} = 2
      ;;
  }


  join: recruit_users {
    type: inner
    relationship: many_to_one
    sql_on: ${recruit_users.id} = ${questions.author_id}  ;;
  }

  join: derived_hrw_library_questions_mapping {
    type: left_outer
    relationship: one_to_one
    sql_on: ${questions.id} = ${derived_hrw_library_questions_mapping.qid} ;;
  }



  join: derived_question_skill_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${derived_question_skill_mapping.question_id}  ;;
  }

}

explore: skills {}

explore: roles {}
