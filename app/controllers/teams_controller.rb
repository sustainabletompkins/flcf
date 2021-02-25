class TeamsController < ApplicationController

  def create
    @team = Team.where(:name=>team_params[:name]).first
    if @team.present? || team_params[:name].length == 0
      render 'creation_failed'
    else
      @team=Team.create(team_params)
      TeamMember.create(:email => params[:user_email], :name=> params[:member_name], :offsets => params[:count].to_i, :founder=> "TRUE", :team_id=>@team.id)
      TeamMailer.send_thanks(params[:user_email], @team).deliver
      if team_params.has_key?(:pounds)
        @team.update_attribute(:count, params[:count].to_i)
        @team.update_attribute(:members, 1)
        @team.increment!(:pounds, params[:pounds].to_i)
        @offsets = Offset.where('id in (?)',params[:offset_ids].split(','))
        @offsets.update_all(:team_id => @team.id)
        render 'team_created_after_offset'
      else
        @count = Team.all.count
        render 'team_created'
      end

    end
  end
  def update
    @user = Team.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(team_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end
  def join
    @team = Team.find(params[:league_id])
    @pounds = params[:pounds]
    @team.increment!(:count, params[:count].to_i)
    @team.increment!(:members, 1)
    @team.increment!(:pounds, params[:pounds].to_i)
    @offsets = Offset.where('id in (?)',params[:offset_ids].split(','))
    @offsets.update_all(:team_id => @team.id)
    TeamMember.create(:email => params[:user_email], :offsets => params[:count].to_i, :team_id=>@team.id, :name=> params[:name])
    TeamMailer.send_thanks(params[:user_email], @team).deliver
    render 'team_joined_after_offset'

  end

  def members
    @team = Team.find(params[:id])
    render :json=>@team.team_members.to_json
  end

  def change
    @new_team = Team.find(params[:new_team_id])
    @old_team = Team.find(params[:old_team_id])

    @offsets = Offset.where(:id=>Array(params[:offset_ids]))
    @new_team.increment!(:count, @offsets.count)
    @new_team.increment!(:members, 1)
    @new_team.increment!(:pounds, @offsets.sum(:pounds))
    @old_team.decrement!(:count, @offsets.count)
    @old_team.decrement!(:members, 1)
    @old_team.decrement!(:pounds, @offsets.sum(:pounds))
    # change offsets
    tm = TeamMember.find_by_email(params[:offset_email])
    TeamMember.create(:email => params[:offset_email], :offsets => @offsets.count, :team_id=>@new_team.id, :name=> tm.name)
    #TeamMailer.send_thanks(params[:user_email], @team).deliver
    render 'team_changed'

  end

  def show
    @team = Team.find(params[:id])
    @leaders = Team.all.order(pounds: :desc)
  end

  private
  def team_params
    params.require(:team).permit(:name, :pounds)
  end

end
