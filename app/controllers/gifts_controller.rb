class GiftsController < ApplicationController
  before_action :authenticate_user!

  #Metodo que realiza "compra" de regalo
  def execute
    byebug
    #order = current_user.order
    detail = Detail.find(params[:detail_id])
    address = Address.find(params[:address_id])
    
    #Info de usuario
    user = User.find(current_user.id)
    order = Order.new(
      user: current_user, 
      detail: detail, 
      address: address
    )
    byebug
    if user.points >= detail.price
      
      order.quantity = 1
      order.price = detail.price 
      gift = Gift.create( user: current_user, points: order.price, quantity: order.quantity )

      order.save
      
      Detail.where(id: detail.id).update_all(quantity: detail.quantity - gift.quantity)
      user = User.find(current_user.id);
      user.update_all(points: user.points - detail.price)

      order.update_all(paided: true, gift_id: gift.id)

      flash[:success] = 'Has canjeado con éxito tu regalo. Si deseas ver tu boleta, ve a tu perfil sección Tus compras.<br>Gracias por preferirnos y vuelve pronto '

      redirect_to root_path
    else
      flash[:danger] = 'Algo salió mal, sentimos las molestias y por favor vuelve a intentar más tarde.'

      redirect_to root_path
    end
    
  end

  #Metodo que devuelve billing de usuario actual(current_user)
  def my_gift
    @gifts = Gift.where(user: current_user).order('id DESC')
  end

  #Método que devuelve una boleta  y sus detalles
  def detail_billing
    @billing = Gift.find(params[:id])
    @orders = current_user.orders.where(paided: true, gift_id: params[:id])
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
        template: "gifts/show.html.erb",
        layout: 'pdf.html'
      end
    end
  end

  # GET /choose_address
  #Página de selección de dirección de envío
  def direction
    #orders = current_user.cart
    byebug
    @detail = Detail.find(params[:detail_id])
    @addresses = Address.where(user: current_user).order('id DESC')
    
  end
end
