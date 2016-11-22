class PagesController < ApplicationController

  def home
    if user_signed_in?
      @saved_offsets = current_user.offsets.where(:purchased=>:true)
    end
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)

    @recent_prizes = PrizeWinner.where.not(:email=>nil).order(created_at: :desc)
    @prizes = Prize.all.order(count: :asc)
    @stats = Stat.first
    @leaders = Team.all.order(pounds: :desc).limit(3)
    @individual_leaders = Individual.all.order(pounds: :desc).limit(3)

    @cracks_money = Offset.where(:purchased=>:true).where('created_at > ?',DateTime.parse('2016-09-01T21:00:00-06:00')).sum(:cost)
    @cracks_pct = (@cracks_money/125).round(1)

    @offsetter = Offsetter.order(id: :desc).limit(5).sample
    @awardee = Awardee.order(id: :desc).limit(3).sample

  end

  def index
    if params[:page_name] == 'prize-wheel'
      @teams = Team.all
      @prizes = Prize.where('count > 0')
      count = 0
      @prizes.each do |p|
        count = count+p.count
      end
      @empties = count*4
      render params[:page_name], :layout => "full"
    elsif params[:page_name] == 'carbon-races'
      @teams = Team.all
      @leaders = Team.all.order(pounds: :desc)
      @individual_leaders = Individual.all.order(pounds: :desc)
      render params[:page_name], :layout => "full"
    elsif params[:page_name] == 'portfolio'
      @awardees = Awardee.all.order(id: :desc)
      render params[:page_name]
    else
      render params[:page_name]
    end


  end

  def admin
    @prizes = PrizeWinner.where.not(:email=>nil).order(updated_at: :desc)
    @prize_list = Prize.all
    @offsetters = Offsetter.all
    @teams = Team.all
    @awardees = Awardee.all
    @individuals = Individual.all
    @teams = Team.all
  end

  def prize_wheel
    @teams = Team.all
    @prizes = Prize.where('count > 0')
    count = 0
    @prizes.each do |p|
      count = count+p.count
    end
    @empties = count*3
  end

  def offset_log
    @offsets = Offset.where(:purchased => :true).order(updated_at: :desc)
    render 'offset_log', :layout => 'blank'
  end

  def calculator
    render 'calculator', :layout => "blank"
  end

end
