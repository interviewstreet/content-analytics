view: recruit_companies_test_company_mapping {
    sql_table_name: recruit_rs_replica.recruit.recruit_companies ;;
    drill_fields: [id]

    dimension: id {
      primary_key: yes
      type: number
      sql: ${TABLE}.id ;;
    }
    dimension: codepair {
      type: number
      sql: ${TABLE}.codepair ;;
    }
    dimension_group: contract {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}.contract_date ;;
    }
    dimension_group: contract_start {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}.contract_start_date ;;
    }
    dimension: country {
      type: string
      map_layer_name: countries
      sql: ${TABLE}.country ;;
    }
    dimension_group: created {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: ${TABLE}.created_at ;;
    }
    dimension: email_domain {
      type: string
      sql: ${TABLE}.email_domain ;;
    }
    dimension: email_from {
      type: string
      sql: ${TABLE}.email_from ;;
    }
    dimension: hr_company_id {
      type: number
      sql: ${TABLE}.hr_company_id ;;
    }
    dimension: industry_segment {
      type: string
      sql: ${TABLE}.industry_segment ;;
    }
    dimension: invites {
      type: number
      sql: ${TABLE}.invites ;;
    }
    dimension: libraries {
      type: string
      sql: ${TABLE}.libraries ;;
    }
    dimension: logo {
      type: string
      sql: ${TABLE}.logo ;;
    }
    dimension: name {
      type: string
      sql: ${TABLE}.name ;;
      case_sensitive: no
    }
    dimension: organization_size {
      type: string
      sql: ${TABLE}.organization_size ;;
    }
    dimension: owner {
      type: number
      sql: ${TABLE}.owner ;;
    }
    dimension: owners_team_id {
      type: number
      sql: ${TABLE}.owners_team_id ;;
    }
    dimension: paid_accounts {
      type: number
      sql: ${TABLE}.paid_accounts ;;
    }
    dimension: paid_codepair_pro_accounts {
      type: number
      sql: ${TABLE}.paid_codepair_pro_accounts ;;
    }
    dimension: paid_codescreen_accounts {
      type: number
      sql: ${TABLE}.paid_codescreen_accounts ;;
    }
    dimension: paid_codescreen_review_accounts {
      type: number
      sql: ${TABLE}.paid_codescreen_review_accounts ;;
    }
    dimension: paid_developer_accounts {
      type: number
      sql: ${TABLE}.paid_developer_accounts ;;
    }
    dimension: paid_interviewer_accounts {
      type: number
      sql: ${TABLE}.paid_interviewer_accounts ;;
    }
    dimension_group: payment {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}.payment_date ;;
    }
    dimension: payment_day {
      type: number
      sql: ${TABLE}.payment_day ;;
    }
    dimension: payment_method {
      type: string
      sql: ${TABLE}.payment_method ;;
    }
    dimension: plagiarism {
      type: number
      sql: ${TABLE}.plagiarism ;;
    }
    dimension: pricing_model {
      type: string
      sql: ${TABLE}.pricing_model ;;
    }
    dimension_group: refill {
      type: time
      timeframes: [raw, date, week, month, quarter, year]
      convert_tz: no
      datatype: date
      sql: ${TABLE}.refill_date ;;
    }
    dimension: slug {
      type: string
      sql: ${TABLE}.slug ;;
    }
    dimension: stripe_plan {
      type: string
      sql: ${TABLE}.stripe_plan ;;
    }
    dimension: stripe_subscription {
      type: string
      sql: ${TABLE}.stripe_subscription ;;
    }
    dimension: subscription_invites {
      type: number
      sql: ${TABLE}.subscription_invites ;;
    }
    dimension: tasks {
      type: number
      sql: ${TABLE}.tasks ;;
    }
    dimension: type {
      type: string
      sql: ${TABLE}.type ;;
    }
    dimension: unique_id {
      type: string
      sql: ${TABLE}.unique_id ;;
    }
    dimension_group: updated {
      type: time
      timeframes: [raw, time, date, week, month, quarter, year]
      sql: ${TABLE}.updated_at ;;
    }
    measure: count {
      type: count
      drill_fields: [id, name]
    }
  }
