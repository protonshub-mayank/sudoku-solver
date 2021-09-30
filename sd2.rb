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
      board[r_index][c_index] = 0
    end
  end

  def empty_cell
    r_index = board.index { |row| row.include?(0) }

    return nil unless r_index

    c_index = board[r_index].index(&:zero?)
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

# data = [
#   [1, 7, 4, 0, 9, 0, 6, 0, 0],
#   [0, 0, 0, 0, 3, 8, 1, 5, 7],
#   [5, 3, 0, 7, 0, 1, 0, 0, 4],
#   [0, 0, 7, 3, 4, 9, 8, 0, 0],
#   [8, 4, 0, 5, 0, 0, 3, 6, 0],
#   [3, 0, 5, 0, 0, 6, 4, 7, 0],
#   [2, 8, 6, 9, 0, 0, 0, 0, 1],
#   [0, 0, 0, 6, 2, 7, 0, 3, 8],
#   [0, 5, 3, 0, 8, 0, 0, 9, 6]
# ]

data = [
  [2,9,5,7,4,3,8,6,1],
  [4,3,1,8,6,5,9,0,0],
  [8,7,6,1,9,2,5,4,3],
  [3,8,7,4,5,9,2,1,6],
  [6,1,2,3,8,7,4,9,5],
  [5,4,9,2,1,6,7,3,8],
  [7,6,3,5,2,4,1,8,9],
  [9,2,8,6,7,1,3,5,4],
  [1,5,4,9,3,8,6,0,0]
]

obj = Solver.new(data)
obj.solve
(0..8).each do |i|
  (0..8).each do |j|
    print obj.board[i][j]
  end
  puts
end


# https://blog.cloudboost.io/sudoku-solver-ruby-recursive-implementation-backtracking-technique-b69582427353