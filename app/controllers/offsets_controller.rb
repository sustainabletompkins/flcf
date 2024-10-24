class OffsetsController < ApplicationController
  def create
    user_id = if user_signed_in?
                current_user.id
              else 0
              end

    @cart_items = CartItem.new(user_id: user_id, title: params[:title], cost: params[:cost], pounds: params[:pounds], session_id: params[:session_id])

    if @offset.save

      @offsets = if user_signed_in?
                   current_user.offsets.where(purchased: :false)
                 else
                   CartItem.where(session_id: params[:session_id], purchased: :false)
                 end

      respond_to do |format|
        format.js { render 'offset-saved' }
      end
    end
  end

  def filter
    case params[:mode]
    when 'log-email'
      @offsets = Offset.where(purchased: :true).order(email: params[:dir])
    when 'log-title'
      @offsets = Offset.where(purchased: :true).order(title: params[:dir])
    when 'log-pounds'
      @offsets = Offset.where(purchased: :true).order(pounds: params[:dir])
    when 'log-cost'
      @offsets = Offset.where(purchased: :true).order(cost: params[:dir])
    when 'log-date'
      @offsets = Offset.where(purchased: :true).order(created_at: params[:dir])
    end
  end

  def manual_create
    pounds = params[:offset][:cost].to_i * 80
    email = params[:offset][:email].strip.downcase
    @offset = Offset.create(user_id: '0', name: params[:offset][:name], title: params[:offset][:title], cost: params[:offset][:cost], pounds: pounds, email: email, zipcode: params[:offset][:zipcode])
    @stat = Stat.all.first
    @stat.increment!(:pounds, pounds)
    @stat.increment!(:dollars, params[:offset][:cost].to_f)
    region = Region.get_by_zip(params[:offset][:zipcde])
    if params[:team].to_i > 0
      @team = Team.find(params[:team])
      # on front-end there is a 0 option inserted for default placeholder text
      if params.has_key?(:team_member) && params[:team_member].to_i != 0
        # we don't need to keep track of offets this way any more
      else
        # let's check if there is already a team member
        tm = @team.team_members.where(email: email).first
        if tm.present?
          tm.update_attribute(:offsets, tm.offsets + 1)
        else
          TeamMember.create(email: email.downcase, name: params[:offset][:name], offsets: 1, team_id: @team.id)
        end

      end
      @offset.update_attribute(:team_id, @team.id)
      @offset.update_attribute(:name, params[:offset][:name])
    elsif params[:offset][:new_team_name] && params[:offset][:new_team_name].length > 0
      # admin is assigning user to a new team
      @team = Team.create(name: params[:offset][:new_team_name], pounds: pounds, count: 1, region: region)
      TeamMember.create(email: email.downcase, name: params[:offset][:name], offsets: 1, team_id: @team.id)
      @offset.update_attribute(:team_id, @team.id)
    else
      @i = Individual.where(email: email).first
      if @i.blank?
        @i = Individual.create(email: email, name: params[:offset][:name], pounds: 0, count: 0, region: region)
      end

      @offset.update(individual_id: @i.id, name: @i.name)
      @i.count_offsets
    end
    render 'created'
  end

  def save_donation
    @pounds = params[:cost].to_i * 80
    @offset = Offset.create(session_id: params[:session_id], user_id: '0', purchased: true, title: 'Donation', cost: params[:cost], name: params[:name], zipcode: params[:zipcode], pounds: @pounds)
  end

  def add_name_and_zip
    user_id = if user_signed_in?
                current_user.id
              else 0
              end

    Offset.where(session_id: params[:session_id]).update_all(name: params[:name], zipcode: params[:zipcode])
  end

  def destroy
    @offset = Offset.find(params[:id])
    @id = @offset.id
    if @offset.destroy
      respond_to do |format|
        format.js { render 'offset-deleted' }
      end
    end
  end

  def duplicate
    offset = Offset.find(params[:offset_id])
    new_offset = offset.dup
    new_offset.purchased = false
    if new_offset.save
      @offsets = current_user.offsets.where(purchased: :false)
      respond_to do |format|
        format.js { render 'offset-saved' }
      end
    end
  end

  def process_purchased
    current_user.session_id = nil
    current_user.save
    current_user.offsets.each do |o|
      o.purchased = true
      o.save
    end
    redirect_to :back
  end
end
