include: "//@{CONFIG_PROJECT_NAME}/views/base_transactions_line_items.view"

view: transactions__line_items {
  extends: [transactions__line_items_config]
}

view: transactions__line_items_core {
  label: "Transactions"

  dimension: product_id {
    type: string
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: cost_of_goods_sold {
    type: number
    sql: ${TABLE}.cost_of_goods_sold ;;
  }

  ##### DERIVED DIMENSIONS #####

  dimension: gross_margin {
    type: number
    sql: ${sale_price} - ${cost_of_goods_sold} ;;
  }


  ##### MEASURES #####

  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    value_format_name: usd_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_quantity {
    type: sum
    sql: 1 ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: average_basket_size {
    type: number
    sql: ${total_sales}/NULLIF(${transactions.number_of_transactions},0) ;;
    value_format_name: usd
    drill_fields: [transactions.drill_detail*]
  }

  measure: average_item_price {
    type: number
    sql: ${total_sales}/NULLIF(${total_quantity},0) ;;
    value_format_name: usd
    drill_fields: [transactions.drill_detail*]
  }

  ##### DATE COMPARISON MEASURES #####

  measure: sales_change {
    view_label: "Date Comparison"
    label: "Sales Change (%)"
    type: number
    sql: SUM(CASE WHEN ${transactions.selected_comparison} LIKE 'This%' THEN ${transactions__line_items.sale_price} ELSE NULL END) / NULLIF(SUM(CASE WHEN ${transactions.selected_comparison} LIKE 'Prior%' THEN ${transactions__line_items.sale_price} ELSE NULL END),0) -1;;
    value_format_name: percent_1
    drill_fields: [transactions.drill_detail*]
  }

  ##### PER STORE MEASURES #####

  measure: total_sales_per_store {
    view_label: "Stores 🏪"
    type: number
    sql: ${total_sales}/NULLIF(${transactions.number_of_stores},0) ;;
    value_format_name: usd_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_quantity_per_store {
    view_label: "Stores 🏪"
    type: number
    sql: ${total_quantity}/NULLIF(${transactions.number_of_stores},0) ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  ##### PER ADDRESS MEASURES #####

  measure: number_of_addresses {
    hidden: yes
    view_label: "Customers"
    type: count_distinct
    sql: ${customers.address};;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_customers_per_address {
    view_label: "Customers"
    type: number
    sql: ${transactions.number_of_customers}/NULLIF(${number_of_addresses},0) ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }
}
