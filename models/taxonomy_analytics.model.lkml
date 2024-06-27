connection: "role_rs_replica"

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
# }

explore: job_families {
  join: roles {
    type: left_outer
    relationship: one_to_many
    sql_where: ${roles.standard} = 1 ;;
    sql_on: ${job_families.id} = ${roles.job_family_id} ;;
  }

  join: role_skill_associations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${roles.id} = ${role_skill_associations.role_id} ;;
  }

  join: skills {
    type: left_outer
    relationship: many_to_one
    sql_where: ${skills.standard} = 1 and ${skills.state} = 1 ;;
    sql_on: ${role_skill_associations.skill_id} = ${skills.id} ;;
  }

  join: ca_questions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${questions.id} = ${ca_questions.question_id};;
  }

  join: library_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${skills.name} = ${library_questions.skill};;
  }

  join: questions {
    type: left_outer
    relationship: many_to_one
    sql_on: ${questions.id} = ${library_questions.qid};;
  }

  join: recruit_tests_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${library_questions.qid} = ${recruit_tests_questions.question_id} ;;
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
  }
}

explore: skills {

  join: library_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${skills.name} = ${library_questions.skill};;
  }
}


explore: question_tag_mapping {}

explore: question_skill_tag_mapping {
  join: questions {
    type: inner
    relationship: many_to_one
    sql_on: ${questions.id} = ${question_skill_tag_mapping.qid}  ;;
  }
}
