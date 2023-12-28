connection: "content_rs_replica"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

explore: ever_paid {
  join: recruit_companies {
    type: inner
    relationship: one_to_one
    sql_on: ${ever_paid.company_id} = ${recruit_companies.id} ;;
  }
  join: recruit_tests {
    type: left_outer
    relationship: one_to_many
    sql_on: ${recruit_tests.company_id} = ${recruit_companies.id}
        and ${recruit_tests.draft} =0
    and ${recruit_tests.state} <> 3;;
  }

  join: recruit_attempts {
    type: left_outer
    relationship: one_to_many
    sql_on: abs(${recruit_attempts.tid}) = ${recruit_tests.id}
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
    and ${recruit_solves.status} = 2;;
  }

  join: questions {
    type: inner
    relationship: many_to_one
    sql_on: ${questions.id} = ${recruit_solves.qid};;
  }
}
