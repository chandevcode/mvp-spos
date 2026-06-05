class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products
  def index
    @products = Product.all
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @gallery_images = Product.all.filter_map { |p| p.image if p.image.attached? }
  end

  # GET /products/1/edit
  def edit
    @gallery_images = Product.all.filter_map { |p| p.image if p.image.attached? }
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    attach_image_from_gallery if params[:image_blob_signed_id].present?

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      @gallery_images = Product.all.filter_map { |p| p.image if p.image.attached? }
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /products/1
  def update
    @product.assign_attributes(product_params)

    if params[:remove_image] == "1"
      @product.image.purge
    elsif params[:image_blob_signed_id].present?
      attach_image_from_gallery
    end

    if @product.save
      redirect_to @product, notice: "Product was successfully updated.", status: :see_other
    else
      @gallery_images = Product.all.filter_map { |p| p.image if p.image.attached? }
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!
    redirect_to products_path, notice: "Product was successfully destroyed.", status: :see_other
  end

  private
    def set_product
      @product = Product.find(params.expect(:id))
    end

    def product_params
      params.expect(product: [ :name, :description, :price, :category, :image ])
    end

    def attach_image_from_gallery
      blob = ActiveStorage::Blob.find_signed(params[:image_blob_signed_id])
      @product.image.attach(blob) if blob
    end
end
