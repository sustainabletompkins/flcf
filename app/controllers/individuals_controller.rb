class IndividualsController < ApplicationController
  def create
    offsets = Offset.where(checkout_session_id: params[:checkout_session_id])
    @individual = Individual.find_or_initialize_by(email: offsets.first.email)
    
    if @individual.new_record?
      region = Region.get_by_zip(offsets.first.zipcode)
      @individual.assign_attributes(name: params[:individual][:name], region: region)
      if @individual.save
        offsets.update_all(individual_id: @individual.id)
        respond_to do |format|
          format.html { redirect_to @individual, notice: 'Individual was successfully created.' }
          format.json { render json: @individual, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.json { render json: @individual.errors, status: :unprocessable_entity }
        end
      end
    else
      offsets.update_all(individual_id: @individual.id)
      respond_to do |format|
        format.html { redirect_to @individual, notice: 'Individual was successfully updated.' }
        format.json { render json: @individual, status: :ok }
      end
    end
  end

  def update
    @individual = Individual.find(params[:id])

    respond_to do |format|
      if @individual.update(individual_params)
        format.html { redirect_to @individual, notice: 'Individual was successfully updated.' }
        format.json { render json: @individual, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def individual_params
    params.require(:individual).permit(:name, :pounds)
  end
end
