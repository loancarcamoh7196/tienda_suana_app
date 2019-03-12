class BillingsController < ApplicationController
  before_action :authenticate_user!
  
  #Metodo que realia pre proceso para pago via paypal
  def pre_pay
    orders = current_user.cart
    total = orders.get_total
    items = orders.to_paypal_items
    
    
    payment = Billing.init_payment(items, total)
    
    if payment.create
      #@payment.id
      redirect_url = payment.links.find{ |v| v.method == 'REDIRECT' }.href
      redirect_to redirect_url
    else
      payment.error
		end
  end

  #Método que ejecuta pago por paypal
  def execute
    paypal_payment = PayPal::SDK::REST::Payment.find(params[:paymentId])
    
    if paypal_payment.execute(payer_id: params[:PayerID])
      #render plain: ':)'
      total = paypal_payment.transactions.first.amount.total
      billing = Billing.create(
        user: current_user,
        code: paypal_payment.id,
        payment_method: 'paypal',
        amount: total.to_i,
        currency: 'USD'
      )
    
      orders = current_user.cart

      
      #Actualiza monto disponible  
      orders.each do |o|
        Detail.where(id: o.detail.id).update_all(quantity: o.detail.quantity - o.quantity)
        #Pendiente
        user = User.find(current_user.id);
        User.update_all(points: user.points + o.detail.product.point_quantity)
      end
      orders.update_all(paided: true, billing_id: billing.id)
      flash[:success] = 'El pago se ha realizado con éxito. Si deseas ver tu boleta, ve a tu perfil sección Tus compras.<br>Gracias por preferirnos y vuelve pronto '
      redirect_to root_path
    else
      render plain: ':('
    end
  end

  #Metodo que devuelve billing de usuario actual(current_user)
  def my_billing
    @billings = Billing.where(user: current_user)
  end

  #Método que devuelve una boleta  y sus detalles
  def detail_billing
    @billing = Billing.find(params[:id])
    @orders = current_user.orders.where(paided: true, billing_id: params[:id])
    respond_to do |format|
      format.js
      format.html
    end
  end

  #Método que devuelve una boleta  y sus detalles, pero en pdf
  def show
    @billing = Billing.find(params[:id])
    @orders = current_user.orders.where(paided: true, billing_id: params[:id])
    @total = @orders.inject(0){|sum, order| sum += order.price.to_i * order.quantity }
    @count = @orders.inject(0){|sum, order| sum +=  order.quantity }
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "billing #{@billing.code}",
        template: "billings/show.html.erb",
        layout: 'pdf.html'
      end
    end
  end

  # GET /choose_address
  #Página de selección de dirección de envío
  def direction
    orders = current_user.cart
    total = orders.get_total
    items = orders.to_paypal_items
    @addresses = Address.where(user: current_user).order('id DESC')
    @direction = Address.new
  end


  def set_direction
    @address = Address.find(params[:id])
  end
  
end
