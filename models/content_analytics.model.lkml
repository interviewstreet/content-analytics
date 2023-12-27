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
    sql_on: ${questions.question_company_id} =  ${recruit_companies.id};;
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
    sql_on: ${recruit_tests.id} = ${recruit_tests_questions.test_id} ;;
  }

  join: recruit_attempts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${recruit_tests.id} = ${recruit_attempts.tid} ;;
  }
}
