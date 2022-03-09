class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show = flash[:ratings]
    @order = flash[:order]
    
    redir = false
    
    if @ratings_to_show
    elsif params[:ratings] and not params[:ratings].empty?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    else
      if session[:ratings]
        @ratings_to_show = session[:ratings]
        redir = true
      else
        @ratings_to_show = @all_ratings
      end
    end
    
    if @order
    elsif params[:order]
      @order = params[:order]
      session[:order] = @order
    else
      if session[:order]
        @order = session[:order]
        redir = true
      else
        @order = ''
      end
    end
    
    if redir
      flash[:ratings] = @ratings_to_show
      flash[:order] = @order
      flash.keep
      redirect_to movies_path({order: @order, ratings_to_show: @ratings_to_show})
    end
    
    @order = @order.to_sym
    @movies = Movie.with_ratings(@ratings_to_show).order(@order == :title ? :title : :release_date)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
