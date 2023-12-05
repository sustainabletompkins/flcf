class TeamsController < ApplicationController
  def create
    @team = Team.where(name: team_params[:name]).first
    if @team.present? || team_params[:name].length == 0
      render 'creation_failed'
    else

      if params.has_key?(:checkout_session_id)
        offsets = Offset.where(checkout_session_id: params[:checkout_session_id])
        region = Region.get_by_zip(offsets.first.zipcode)
        @team = Team.create(team_params)
        @team.update_attribute(:region_id, region.id)
        TeamMember.create(email: offsets.first.email.downcase, name: params[:member_name], founder: 'TRUE', team_id: @team.id)

        offsets.update_all(team_id: @team.id)
        @team.update_offset_count
        render 'team_created_after_offset'
      else
        # team is not being created through checkout process
        @team = Team.create(team_params)
        TeamMember.create(email: params[:user_email].downcase, name: params[:member_name], founder: 'TRUE', team_id: @team.id)

        @count = Team.all.count
        render 'team_created'
      end

      TeamMailer.send_thanks(params[:user_email], @team).deliver

    end
  end

  def update
    @team = Team.find(params[:id])
    puts team_params
    if @team.update_attributes(team_params)
      @team.offsets.update_all(region_id: @team.region_id)
      redirect_to '/calc-admin'
    else
      # error
    end
  end

  def join
    if params.has_key?(:checkout_session_id)
      @team = Team.find(params[:id])
      offsets = Offset.where(checkout_session_id: params[:checkout_session_id])
      offsets.update_all(team_id: @team.id)
      TeamMember.create(email: offsets.first.email.downcase, team_id: @team.id, name: params[:name])
      TeamMailer.send_thanks(params[:user_email], @team).deliver
      render 'team_joined_after_offset'
    end
  end

  def members
    @team = Team.find(params[:id])
    render json: @team.team_members.to_json
  end

  def change
    @new_team = Team.find(params[:new_team_id])
    @old_team = Team.find(params[:old_team_id])

    # change offsets
    offsets = Offset.where(checkout_session_id: params[:checkout_session_id])
    offsets.update_all(team_id: @new_team.id)

    tm = TeamMember.find_by_email(offsets.first.email)
    # change default team
    member = TeamMember.where(email: tm.email, team_id: @new_team.id).first
    if member.present?
      # make this the most recently updated team member entry
      member.save
    else
      member = TeamMember.create(email: tm.email, team_id: @new_team.id, name: tm.name)
    end
    # TeamMailer.send_thanks(params[:user_email], @team).deliver
    render 'team_changed'
  end

  def show
    @team = Team.find(params[:id])
    @leaders = Team.all.order(pounds: :desc)
  end

  def index
    @begin_date = if params.key?(:begin_date) && params[:begin_date].length > 0
                    params[:begin_date]
                  else
                    '1/1/15'
                  end
    @teams = if params.has_key?(:region)
               Team.where(region_id: params[:region]).order(pounds: :desc)
             else
               Team.all.order(pounds: :desc)
             end
    render 'list'
  end

  def detail
    @team = Team.find(params[:id])
  end

  private

  def team_params
    params.require(:team).permit(:name, :pounds, :region_id, :image)
  end
end
