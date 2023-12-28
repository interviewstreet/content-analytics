view: ever_paid {
  derived_table: {
    sql: select distinct company_id as company_id from recruit_rs_replica.recruit.recruit_company_plan_changelogs
        where plan_name not in ('free', 'trial', 'user-freemium-interviews-v1','locked') -- # ever paid customers (This table has data only of companies created post 2018)
---- ^ Above query returns ever paid customer who joined 2018 onwards
union
select distinct id from recruit_rs_replica.recruit.recruit_companies rc
  where stripe_plan not in ('free', 'trial','user-freemium-interviews-v1','locked')
  and rc.type not in ('free', 'trial','locked')  -- # using this logic to cover paid customers who are not covered in the above logic [company_plan_changelog table]

      ---- ^ currently active customers being missed out on prev query (2018 onwards set)
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  set: detail {
    fields: [company_id]
  }
}
