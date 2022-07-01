class CartsController < ApplicationController
    before_action :authenticate_user!
    def update
        product = params[:cart][:product_id]
        quantity = params[:cart][:quantity]
        
        current_order.add_product(product, quantity)
        
        redirect_to root_url, notice: "Product added successfuly"
    end
    
    def show
        @order = current_order
    end
        
    def pay_with_paypal
        order = Order.find(params[:cart][:order_id])
        
        #price must be in cents
        price = order.in_cents
        response = define_response(price)
        payment_method = PaymentMethod.find_by(code: "PEC")
        Payment.create_order(order, payment_method, response)
        redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    end
        
    
    def process_paypal_payment
        details = EXPRESS_GATEWAY.details_for(params[:token])
        express_purchase_options(request, params[:token], details)
        price = details.params["order_total"]to_decimal_per100(price)
        
        response = EXPRESS_GATEWAY.purchase(price, express_purchase_options)
        successfuly_response(response)
    end
end
