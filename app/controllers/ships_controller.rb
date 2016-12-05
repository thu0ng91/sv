class ShipsController < ApplicationController  

  def this_week_hot
    @ships = ThisWeekHotShip.includes(:novel).order("id desc").all
  end

  def this_month_hot
    @ships = ThisMonthHotShip.includes(:novel).order("id desc").all
    render :this_week_hot
  end

  def hot
    @ships = HotShip.includes(:novel).order("id desc").all
    render :this_week_hot
  end

  def destroy
    if(params[:ship_type] == "ThisMonthHotShip")
      ThisMonthHotShip.find(params[:id]).destroy
      redirect_to this_month_hot_ships_path
    elsif (params[:ship_type] == "ThisWeekHotShip")
      ThisWeekHotShip.find(params[:id]).destroy
      redirect_to this_week_hot_ships_path
    elsif (params[:ship_type] == "HotShip")
      HotShip.find(params[:id]).destroy
      redirect_to hot_ships_path
    end
  end

  def new
    @ship = eval (params[:ship_type] + ".new")
  end

  def create
    @ship = eval (params[:ship_type] + ".new")
    @ship.novel_id = params[:novel_id]
    @ship.save

    if(params[:ship_type] == "ThisMonthHotShip")
      redirect_to this_month_hot_ships_path
    elsif (params[:ship_type] == "ThisWeekHotShip")
      redirect_to this_week_hot_ships_path
    elsif (params[:ship_type] == "HotShip")
      redirect_to hot_ships_path
    end
  end
end
