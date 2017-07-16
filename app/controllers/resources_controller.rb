class ResourcesController < ApplicationController
  include ResourcesHelper
  helper_method :get_channel_by_url

  before_filter :authenticate_user!, only: [:index, :show, :new, :create, :update, :edit, :destroy]
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
    # set_urls # add the urls of channels for fast adds
  end

  def set_urls
    urls = []
    urls.push "https://www.youtube.com/user/Archetapp"
    urls.push "https://www.youtube.com/channel/UCuP2vJ6kRutQBfRmdcI92mA"
    urls.push "https://www.youtube.com/channel/UCysEngjfeIYapEER9K8aikw"
    urls.push "https://www.youtube.com/channel/UChH6WbyYeX0INJjrK2-6WSg"
    urls.push "https://www.youtube.com/channel/UCvPFGq6luCqAVGiFpzTvkIA"
    urls.push "https://www.youtube.com/user/CodeWithChris"
    urls.push "https://www.youtube.com/user/GeekyLemon"
    urls.push "https://www.youtube.com/channel/UC-d1NWv5IWtIkfH47ux4dWA"
    urls.push "https://www.youtube.com/user/jsonmez"
    urls.push "https://www.youtube.com/user/DevTipsForDesigners"
    urls.push "https://www.youtube.com/user/mackenziechild"
    urls.push "https://www.youtube.com/user/learncodeacademy"
    urls.push "https://www.youtube.com/user/derekbanas"
    urls.push "https://www.youtube.com/user/TheSkoolRocks"
    urls.push "https://www.youtube.com/user/thenewboston"
    urls.push "https://www.youtube.com/channel/UCIQmhQxCvLHRr3Beku77tww"
    urls.push "https://www.youtube.com/user/RailscastsReloaded"
    urls.push "https://www.youtube.com/user/codemynet"
    urls.push "https://www.youtube.com/user/PaulSolt"
    urls.push "https://www.youtube.com/user/schafer5"
    urls.push "https://www.youtube.com/user/elithecomputerguy"
    urls.push "https://www.youtube.com/user/killerphp"
    urls.push "https://www.youtube.com/user/AskADev"
    urls.push "https://www.youtube.com/channel/UCZHkx_OyRXHb1D3XTqOidRw"
    urls.push "https://www.youtube.com/user/sentdex"
    urls.push

    urls.each do |u|
      get_channel_by_url u
    end
  end

  def get_channel_by_url(url)
    if url.length > 0
      add_youtube_channel_by url
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: 'Resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:title, :resource_url, :resource_type, :image, :desc, :about_url)
    end
end
