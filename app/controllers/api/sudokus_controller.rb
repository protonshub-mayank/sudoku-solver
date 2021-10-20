class Api::SudokusController < ApplicationController

  def create
    data = params[:data]
    data = JSON.parse(data) if data.is_a?(String)
    
    sudoku = Solver.new(data)
    sudoku.solve
    render json: { solution: sudoku.board }
  end
 
  class Solver
    attr_accessor :board
    attr_accessor :backtracks

    def initialize(board)
      @backtracks = 0
      @board = board
    end

    def solve
      r_index, c_index = empty_cell 
    
      guesses = possible_values(r_index, c_index)

      return unless guesses.any?

      guesses.each do |guess|
        board[r_index][c_index] = guess
        solve
        return board unless empty_cell 

        @backtracks += 1
        board[r_index][c_index] = nil
      end
    end

    def empty_cell
      r_index = board.index { |row| row.include?(nil) }  
      return nil unless r_index
      
      c_index = board[r_index].index(&:nil?)
      [r_index, c_index]
    end

    def possible_values(r_index, c_index)
      return [] unless [r_index, c_index].any?

      (1..9).each_with_object([]) do |value, result|
        result << value if valid?(r_index, c_index, value)
      end
    end

    def valid?(row, column, guess)
      valid_row?(row, guess) &&
      valid_column?(column, guess) &&
      valid_square?(row, column, guess)
    end
    
    def valid_row?(row, guess)
      board[row].none? { |cell| cell == guess }
    end

    def valid_column?(column, guess)
      board.none? { |row| row[column] == guess }
    end

    def valid_square?(row, column, guess)
      square_x = (row / 3) * 3
      square_y = (column / 3) * 3
      (0..2).each do |x_index|
        (0..2).each do |y_index|
          return false if board[square_x + x_index][square_y + y_index] == guess
        end
      end
      true
    end
  end
  
end