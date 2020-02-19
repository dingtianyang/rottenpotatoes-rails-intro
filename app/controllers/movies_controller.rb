class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # def index
  #   ## @movies = Movie.all
  #   # sort = params[:sort]
  #   # @movies = Movie.order(sort)
  #   @sort = params[:sort]
  #   @all_ratings = Movie.all_ratings.keys
  #   @ratings = params[:ratings]
  #   if(@ratings != nil)
  #     ratings = @ratings.keys
  #     @movies = Movie.where(rating: ratings).order(@sort)
  #   else
  #     @movies = Movie.order(@sort)
  #   end
  # end
  
  def index
    # session.clear
    sorted = params[:sort] || session[:sort]
    case sorted
    when 'title'
      @title_header = 'hilite'
    when 'release_date'
      @date_header = 'hilite'
    end
    
    @sort = params[:sort]
    if(!params.has_key?(:sort) && !params.has_key?(:ratings))
      if(session.has_key?(:sort))
          if(session.has_key?(:ratings))
            redirect_to movies_path(:sort=>session[:sort], :ratings=>session[:ratings])
          else
            redirect_to movies_path(:sort=>session[:sort])
          end
      else
        if(session.has_key?(:ratings))
          redirect_to movies_path(:ratings=>session[:ratings])
        end
      end
    end
    @sort = params.has_key?(:sort) ? (session[:sort] = params[:sort]) : session[:sort]
    @all_ratings = Movie.all_ratings.keys
    @select_rating = params[:ratings] || session[:ratings]||{}
    if @select_rating == {}
      @select_rating = Hash[Movie.all_ratings.map {|rating| [rating,rating]}]
    end
    @ratings = params[:ratings]
    if(@ratings != nil)
      ratings = @ratings.keys
      @movies = Movie.where(rating: ratings).order(@sort)
      session[:ratings] = @ratings
    else
      @movies = Movie.order(@sort)
      if(!params.has_key?(:commit) && !params.has_key?(:sort))
        ratings = Movie.all_ratings.keys
        session[:ratings] = Movie.all_ratings
      else
        ratings = session[:ratings]
      end
    end
  @movies = Movie.where(rating: @select_rating.keys).order(@sort)
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

end
