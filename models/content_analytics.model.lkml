connection: "content_rs_replica"
#include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project

# datagroup: content_analytics_default_datagroup {
#   # sql_trigger: SELECT MAX(id) FROM etl_log;;
#   max_cache_age: "1 hour"
# }

# persist_with: content_analytics_default_datagroup

explore: questions {

  join: recruit_companies {
    type: left_outer
    relationship: one_to_one
    sql_on: ${questions.question_company_id} =  ${recruit_companies.id}
    and ${recruit_companies.id} not in (46242,  106529 )
    and lower(${recruit_companies.name}) not in ('none', ' ', 'hackerrank','interviewstreet') --- Filter internal accounts based on company names
    and lower(${recruit_companies.name}) not like '%hackerrank%'
    and lower(${recruit_companies.name}) not like '%hacker%rank%'
    and lower(${recruit_companies.name}) not like '%interviewstreet%'
    and lower(${recruit_companies.name}) not like '%interview%street%'
    and ${recruit_companies.name} not like 'Company%';;
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
    sql_on: ${recruit_attempts.id} = abs(${recruit_solves.aid})
    and ${recruit_solves.aid} > 0
    and ${recruit_solves.status} = 2
;;
  }
}

explore: skills {}

explore: roles {}
