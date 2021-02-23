class ChargesController < ApplicationController

  def new
  end

  def create
    if params[:stripeSession].length > 1
      if user_signed_in?
        current_user.session_id = nil
        current_user.save
      end
      @stat = Stat.all.first
      @offset_data = {:pounds=>0, :cost=>0, :count=>0}


      @offsets = Offset.where(:session_id=>params[:stripeSession]).where('purchased = FALSE')
      if @offsets.count > 0
        @offset_data[:ids] = []
        @offsets.each do |o|
          o.purchased = true
          o.email = params[:stripeEmail]
          o.save
          @offset_data[:pounds] = @offset_data[:pounds] + o.pounds
          @offset_data[:cost] = @offset_data[:cost] + o.cost
          @offset_data[:count] = @offset_data[:count] + 1
          @offset_data[:email] = params[:stripeEmail]
          @offset_data[:name] = o.name
          @offset_data[:ids] << o.id
          @stat.increment!(:pounds, o.pounds)
          @stat.increment!(:dollars, o.cost)
        end
        @offset_data[:ids] = @offset_data[:ids].join(',')
      else
        @donation_mode = true
        puts 'its a donation'
      end
      @player = TeamMember.where(:email=>params[:stripeEmail]).last
      if @player

        @team = Team.find(@player.team_id)
        @team.increment!(:count,@offset_data[:count].to_i)
        @team.increment!(:pounds,@offset_data[:pounds].to_i)
        TeamMailer.send_thanks(@player.email, @player.team).deliver
        @player.increment!(:offsets)
      end
      @individual = Individual.where(:email=>params[:stripeEmail]).first

      if @individual
        @individual.increment!(:count)
        @individual.increment!(:pounds,@offset_data[:pounds].to_i)
      end
      @teams = Team.all
      @prizes = Prize.where('count > 0')
      count = 0
      @prizes.each do |p|
        count = count+p.count
      end
      @empties = count*2

      

      customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :card  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => params[:stripeCharge],
        :description => 'Carbon offset',
        :currency    => 'usd'
      )

      #send offset info to little green light
      # put this above the offset mailer, in case that runs into a problem
      require 'net/http'
      require 'uri'
      require 'json'
      uri = URI.parse("https://sustainabletompkins.littlegreenlight.com/integrations/e43d9598-3876-47a8-9411-9a6afdff1647/listener")

      OffsetMailer.send_offset_details(params[:stripeEmail],@offsets).deliver

      @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)
      @teams = Team.all



      data = {:payment_type => 'Credit Card', :email=>params[:stripeEmail],:amount=>params[:stripeCharge].to_i/100.round(2),:name => @offset_data[:name], :zip_code => @offset_data[:zip_code] || 12314, :date => Date.today, :fund => 'Finger Lakes Climate Fund'}
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.post(uri, data.to_json, {"Content-Type" => "application/json", "Accept" => "application/json"})


      render :layout=>"full"

    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    # fix this so it goes to an error page
    redirect_to '/error'
  end


end
