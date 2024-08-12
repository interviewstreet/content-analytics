connection: "content_rs_replica"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }

explore: recruit_companies {
  join: recruit_tests {
    type: left_outer
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
          and ${recruit_solves.aid} > 0
          and ${recruit_solves.status} = 2
      ;;
  }
  join: questions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${questions.id} = ${recruit_solves.qid} ;;
  }

  # join: question_avg_score_view {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${questions.id} = ${question_avg_score_view.qid} ;;
  # }

  # join: question_avg_score_view {
  #   type: inner
  #   relationship: one_to_one
  #   sql_on: ${questions.id} = ${question_avg_score_view.qid} ;;
  # }



  join: recruit_users {
    type: inner
    relationship: many_to_one
    sql_on: ${recruit_users.id} = ${questions.author_id}  ;;
  }

  join: derived_hrw_library_questions_mapping {
    type: inner
    relationship: one_to_one
    sql_on: ${questions.id} = ${derived_hrw_library_questions_mapping.qid} ;;
  }
  join: derived_question_skill_mapping {
    type: left_outer
    relationship: one_to_many
    sql_on: ${questions.id} = ${derived_question_skill_mapping.question_id}  ;;
  }
}
