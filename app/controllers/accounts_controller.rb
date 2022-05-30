class AccountsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_account, only: %i[ show edit update update_profile_picture destroy ]

  # GET /accounts or /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1 or /accounts/1.json
  def show
    p @account
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  def update_profile_picture
    key = 'dev/users/' + current_user.id.to_s + '/profile/' + params[:file].original_filename

    obj = S3_Client.put_object(bucket: ENV['S3_BUCKET'], body: params[:file], key: key)

    signer = Aws::S3::Presigner.new
      url, headers = signer.presigned_request(
        :get_object, bucket: ENV['S3_BUCKET'], key: key, expires_in: 604800
      )

    @upload = Photo.create(
      bucket: ENV['S3_BUCKET'],
      expires_at: DateTime.now + 7.days,
      key: key,
      signed_url: url,
      title: params[:file].original_filename,
      user_id: current_user.id
    )

    p @upload

    @account.update(profile_pic_url: url)
  end

  # POST /accounts or /accounts.json
  def create
    @account = Account.new(account_params)
    @account.user_id = current_user.id

    respond_to do |format|
      if @account.save
        format.html { redirect_to account_url(@account), notice: "Account was successfully created." }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to account_url(@account), notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url, notice: "Account was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      if current_user.account
        @account = Account.find(current_user.account.id)
      else 
        redirect_to new_account_path
      end
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.fetch(:account, {}).permit(:first_name,
       :last_name,
       :phone,
       :mobile,
       :street_address,
       :city,
       :state,
       :zip,
       :facebook,
       :twitter,
       :website,
       :instagram,
       :tiktok
     )
    end
end
