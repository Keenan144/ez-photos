class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show edit update destroy ]

  # GET /photos or /photos.json
  def index
    signer = Aws::S3::Presigner.new
    @photos = Photo.all
    @photos.each do |photo|
      p photo.expires_at
      p photo.expires_at.past?
      if photo.expires_at.past?
        url, headers = signer.presigned_request(
          :get_object, bucket: ENV['S3_BUCKET'], key: photo.key, expires_in: 604800
        )
        d = DateTime.now

        photo.update(
          signed_url: url,
          expires_at: d + 7.days
        )
      end
    end
  end

  # GET /photos/1 or /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos or /photos.json
  def create

    obj = S3_Client.put_object(bucket: ENV['S3_BUCKET'], body: params[:file], key: params[:file].original_filename)


    resp = S3_Client.get_object({
      bucket: ENV['S3_BUCKET'], 
      key: params[:file].original_filename, 
    })

    if resp.etag
      signer = Aws::S3::Presigner.new
      url, headers = signer.presigned_request(
        :get_object, bucket: ENV['S3_BUCKET'], key: params[:file].original_filename, expires_in: 200
      )

      d = DateTime.now

      @upload = Photo.create(
        title: params[:file].original_filename,
        key: params[:file].original_filename,
        bucket: ENV['S3_BUCKET'],
        signed_url: url,
        expires_at: d + 200.seconds
      )

      return true
    else
      return false
    end
  end
  
    # rescue StandardError => e
    #   puts "Error uploading object: #{e.message}"
    #   return false
  # end

  # PATCH/PUT /photos/1 or /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to photo_url(@photo), notice: "Photo was successfully updated." }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1 or /photos/1.json
  def destroy
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to photos_url, notice: "Photo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.fetch(:photo, {})
    end
end
