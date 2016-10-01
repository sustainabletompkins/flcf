class PagesController < ApplicationController

  def home
    if user_signed_in?
      @saved_offsets = current_user.offsets.where(:purchased=>:true)
    end
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)

    @recent_prizes = PrizeWinner.where.not(:email=>nil).order(created_at: :desc)
    @prizes = Prize.all.order(count: :asc)
  end

  def index
    if params[:page_name] == 'prize-wheel'
      @prizes = Prize.where('count > 0')
      count = 0
      @prizes.each do |p|
        count = count+p.count
      end
      @empties = count*2
    end

    render params[:page_name], :layout => "full"
  end

  def offset_log
    @offsets = Offset.where(:purchased => :true)
    render 'offset_log', :layout => false
  end

  def calculator
    render 'calculator', :layout => "blank"
  end

end
