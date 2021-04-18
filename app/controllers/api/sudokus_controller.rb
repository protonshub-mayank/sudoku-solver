class Api::SudokusController < ApplicationController
  # custom errors
  class NonSolavableError < StandardError; end

  before_action :validate_input, only: [:create]

  rescue_from NonSolavableError, with: :handle_non_solvable


  # {
  #   "data": [
  #     [2, null, 5, null, null, 9, null, null, 4],
  #     [null, null, null, null, null, null, 3, null, 7],
  #     [7, null, null, 8, 5, 6, null, 1, null],
  #     [4, 5, null, 7, null, null, null, null, null],
  #     [null, null, 9, null, null, null, 1, null, null],
  #     [null, null, null, null, null, 2, null, 8, 5],
  #     [null, 2, null, 4, 1, 8, null, null, 6],
  #     [6, null, 8, null, null, null, null, null, null],
  #     [1, null, null, 2, null, null, 7, null, 8]
  #   ]
  # }


  # need better algo for this
  # {
  #   "data": [
  #     [null, null, null, null, null, null, null, null, null],
  #     [null, null, null, null, null, 3, null, 8, 5],
  #     [null, null, 1, null, 2, null, null, null, null],
  #     [null, null, null, 5, null, 7, null, null, null],
  #     [null, null, 4, null, null, null, 1, null, null],
  #     [null, 9, null, null, null, null, null, null, null],
  #     [5, null, null, null, null, null, null, 7, 3],
  #     [null, null, 2, null, 1, null, null, null, null],
  #     [null, null, null, null, 4, null, null, null, 9]
  #   ]
  # }

  def create
    grid = params["data"].dup
    solve_grid!(grid)
    render json: {solution: grid}
  end

  private
    def validate_input
      unless params["data"].size == 9 && params["data"][0].size == 9
        render json: {error: "Array size should be 9X9"}, status: 422
      end
    end

    def handle_non_solvable
      render json: {error: "Can't solve sudoku"}, status: 422
    end

    def solve_grid!(grid)
      # construct three arrays for grid, row and col
      # indicating how many places we can assign particular value in grid or row or col
      construct_all_arrays(grid)
      @changes_in_grid = false

      (0...9).each do |i|
        (1..9).each do |val|
          # we are going to iterate over these three arrays for grid, row and col
          # and where we have only possible place to enter the value we assign it
          check_and_assign_grid!(grid, i, val)
          check_and_assign_row!(grid, i, val)
          check_and_assign_col!(grid, i, val)
        end
      end

      if @changes_in_grid
        # if any changes made in the grid then redo the same until all changes are done
        solve_grid!(grid)
      elsif is_solved_grid?(grid)
        # sudoku solved
        return
      else
        # not able to solve sudoku or non-solvable
        p grid
        raise NonSolavableError
      end
    end

    def check_and_assign_grid!(grid, i, val)
      arr = @grid_array[i][val-1]
      if only_one_element?(arr)
        row,col = arr.first
        assign_val!(grid, row, col, val)
      end
    end

    def check_and_assign_row!(grid, i, val)
      arr = @row_array[i][val-1]
      if only_one_element?(arr)
        row,col = i, arr.first
        assign_val!(grid, row, col, val)
      end
    end

    def check_and_assign_col!(grid, i, val)
      arr = @col_array[i][val-1]
      if only_one_element?(arr)
        row,col = arr.first, i
        assign_val!(grid, row, col, val)
      end
    end

    def assign_val!(grid, row, col, val)
      if grid[row][col].blank? || grid[row][col] == val
        grid[row][col] = val
        @changes_in_grid = true
      else
        raise NonSolavableError
      end
    end

    def construct_all_arrays(grid)
      @grid_array = init_9x9x9_array()
      @row_array = init_9x9x9_array()
      @col_array = init_9x9x9_array()

      (0...9).each do |row|
        (0...9).each do |col|
          if grid[row][col].blank?
            (1..9).each do |value|
              if valid_entry?(grid,row,col,value)
                gno = grid_number(row, col)
                @grid_array[gno][value-1].push([row, col])
                @row_array[row][value-1].push(col)
                @col_array[col][value-1].push(row)
              end
            end
          end
        end
      end
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

    def grid_number(row, col)
      gr = (row/3)
      gc = (col/3)
      gr * 3 + gc
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

    def init_9x9x9_array
      Array.new(9) { Array.new(9) { [] } }
    end

    def only_one_element?(arr)
      arr.length == 1
    end
end
