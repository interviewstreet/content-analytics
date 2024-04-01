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

  join: library_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${skills.name} = ${library_questions.skill};;
  }

}

explore: skills {

  join: library_questions {
    type: left_outer
    relationship: one_to_many
    sql_on: ${skills.name} = ${library_questions.skill};;
  }
}
