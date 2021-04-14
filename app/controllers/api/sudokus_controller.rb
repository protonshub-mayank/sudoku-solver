class Api::SudokusController < ApplicationController
  before_action :validate_input, only: [:create]
  
  def create
    input_grid = params["data"].dup
    if solved_grid?(input_grid)
      render json: {solution: input_grid}
    else
      render json: {error: "Can't solve sudoku"},status: 422
    end  
  end

  private
    def validate_input
      unless params["data"].size == 9 && params["data"][0].size == 9
        render json: {error: "Array size should be 9X9"}, status: 422
      end
    end

    def solved_grid?(grid)
      return true if is_solved_grid?(grid)
      (0...9).each do |row|
        (0...9).each do |col|
          if grid[row][col].blank?
            (1..9).each do |value|
              if valid_entry?(grid,row,col,value)
                grid[row][col] = value
                return true if solved_grid?(grid)
                grid[row][col] = nil
              end
            end 
          end
        end
      end
      return false
    end

    def is_solved_grid?(grid)
      (0...9).each do |row|
        (0...9).each do |col|
          return false if grid[row][col].blank?
        end
      end
      return true
    end

    def valid_entry?(grid,row,col,value)
      !contains_in_grid?(grid,row,col,value) &&
        !contains_in_row?(grid,row,value) && 
        !contains_in_column?(grid,col,value)
    end
      
    def contains_in_grid?(grid,row,col,value)
      gr = (row/3) * 3
      gc = (col/3) * 3
      (gr...(gr+3)).each do |gr_index|
        (gc...(gc+3)).each do |gc_index|
          return true if grid[gr_index][gc_index] == value
        end
      end
      return false
    end

    def contains_in_row?(grid,row,value)
      (0...9).each do |col|
        return true if grid[row][col] == value
      end
      return false 
    end

    def contains_in_column?(grid,col,value)
      (0...9).each do |row|
        return true if grid[row][col] == value
      end
      return false 
    end
end
