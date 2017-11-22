class PagesController < ApplicationController

  def home
    if user_signed_in?
      @saved_offsets = current_user.offsets.where(:purchased=>:true)
    end
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)

    @recent_prizes = PrizeWinner.where.not(:email=>nil).order(created_at: :desc)
    @prizes = Prize.all.order(count: :asc)
    @stats = Stat.first
    @leaders = Team.where('pounds > 0').order(pounds: :desc).limit(3)
    @individual_leaders = Individual.where('pounds > 0').order(pounds: :desc).limit(3)

    @cracks_money = Offset.where(:purchased=>:true).where('created_at > ?',DateTime.parse('2017-09-01T21:00:00-06:00')).sum(:cost)
    @cracks_pct = (@cracks_money/125).round(1)

    @offsetter = Offsetter.order(id: :desc).limit(5).sample
    @awardee = Awardee.order(id: :desc).limit(3).sample
    @awardee_count = Awardee.all.count+2

  end

  def index
    @page = Page.where(:slug=>params[:page_name]).first
    if @page.present?
      render 'index'
    else
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
        @leaders = Team.where('pounds > 0').order(pounds: :desc)
        @individual_leaders = Individual.where('pounds > 0').order(pounds: :desc)
        render params[:page_name], :layout => "full"
      else
        render params[:page_name]
      end
    end

  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(page_params)
      render 'saved'
    else
      render 'edit'
    end
  end

  def create
    @page = Page.new(page_params)
    @page.slug = params[:page][:title].downcase.gsub(' ','-')
    if @page.save
      @url = "http://fingerlakesclimatefund.org/pages/"+@page.slug
      render 'created'
    else
      render 'error'
    end
  end
  def index2



  end

  def admin
    @prizes = PrizeWinner.where.not(:email=>nil).order(updated_at: :desc)
    @prize_list = Prize.all
    @offsetters = Offsetter.all
    @teams = Team.all
    @awardees = Awardee.all
    @individuals = Individual.all
    @teams = Team.all
    @stat = Stat.find(1)
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
    @offsets = Offset.where(:purchased => :true).order(created_at: :desc)
    render 'offset_log', :layout => 'blank'
  end

  def calculator
    render 'calculator', :layout => "blank"
  end

  def page_params
    params.require(:page).permit(:body, :title)
  end
end
