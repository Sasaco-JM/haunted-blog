# frozen_string_literal: true

class BlogsController < ApplicationController
  include ERB::Util

  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :check_edit_blog_authorization, only: %i[edit update destroy]
  before_action :check_premium_user, only: %i[create update]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(sanitized_blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(sanitized_blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound if @blog.secret && !@blog.owned_by?(current_user)
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def sanitized_blog_params
    params = blog_params
    params[:content] = html_escape(params[:content])
    params
  end

  def check_edit_blog_authorization
    raise ActiveRecord::RecordNotFound unless @blog.owned_by?(current_user)
  end

  def check_premium_user
    return if current_user.premium? || params[:blog][:random_eyecatch].nil?

    flash[:error] = '一部の機能はPremiumユーザーのみ利用可能です。'
    redirect_to root_path
  end
end
