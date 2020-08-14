module Spree
  module OrdersHelper
    def order_just_completed?(order)
      flash[:order_completed] && order.present?
    end

    def vendor_compare_list(order)
      valid_vendors = []
      valid_vendor = {}
      ordered_product_ids = order.product_ids

      Spree::Vendor.active.each do |vendor|
        vendor_product_ids = vendor.variants_product_ids
        if (ordered_product_ids - vendor_product_ids).empty?
          valid_vendor[:vendor] = vendor
          valid_vendor[:line_items] = []

          order.line_items.includes(:product).each do |line_item|
            quantity = line_item.quantity
            price = vendor.variants.find_by(product_id: line_item.product_id).price
            valid_vendor[:line_items].append({
                name: line_item.product.name,
                quantity: quantity,
                price: price,
                subtotal: quantity * price
              })
          end

          valid_vendor[:total] = valid_vendor[:line_items].sum {|x| x[:subtotal]}
          valid_vendors.append(valid_vendor.deep_dup)
        end
      end
      valid_vendors.sort {|x| x[:total]}
    end
  end
end
