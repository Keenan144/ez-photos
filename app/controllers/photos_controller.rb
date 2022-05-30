class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :check_permissions
  before_action :set_photo, only: %i[ show edit update destroy ]

  # GET /photos or /photos.json
  def index
    signer = Aws::S3::Presigner.new
    p current_user
    @photos = Photo.where({user_id: current_user.id})
    @photos.each do |photo|
      if !photo.signed_url || photo.expires_at.past?
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
    key = 'dev/users/' + current_user.id.to_s + '/upload/' + params[:file].original_filename

    obj = S3_Client.put_object(bucket: ENV['S3_BUCKET'], body: params[:file], key: key)

    # resp = S3_Client.get_object({bucket: ENV['S3_BUCKET'], key: key})

    # if resp.etag
      signer = Aws::S3::Presigner.new
      url, headers = signer.presigned_request(
        :get_object, bucket: ENV['S3_BUCKET'], key: key, expires_in: 604800
      )

      @upload = Photo.create(
        bucket: ENV['S3_BUCKET'],
        expires_at: DateTime.now + 7.days,
        key: key,
        # signed_url: url,
        title: params[:file].original_filename,
        user_id: current_user.id
      )

      redirect_to photos_path, notice: "Photo was successfully updated."
    # else
      # return false
    # end
    rescue StandardError => e
        puts "Error uploading object: #{e.message}"
  end

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
    resp = S3_Client.delete_object({
      bucket: ENV['S3_BUCKET'], 
      key: @photo.key, 
    })

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
      if !@photo.signed_url || @photo.expires_at.past?
        url, headers = signer.presigned_request(
          :get_object, bucket: ENV['S3_BUCKET'], key: photo.key, expires_in: 604800
        )
        d = DateTime.now

        @photo.update(
          signed_url: url,
          expires_at: d + 7.days
        )
      end
    end

    def check_permissions
      if current_user.account.account_type === 'customer'
        redirect_to root_path
      end
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.fetch(:photo, {})
    end
end
