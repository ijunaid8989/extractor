defmodule Extractor.For do
    # Create a closure which contains a function that applies itself to itself.
    # Call this function with as argument a function that calls the passed function with the passed `arg`.
    # In lambda calculus: `Y = λf.(λx.f(x x))(λx.f(x x))`
    # An easier definition: `Y f = f (Y f)`
    # If there exist at least one 'fixed point' where the function `f` does not call the passed function, this structure terminates.
    # 
    # This `y_combinator/0` can be called with a double anonymous function: 
    #   The outermost receives the fixpoint function as input, which can be called when you want to recurse.
    #   The innermost receives whatever argument needs to be passed during iterations.
  def y_combinator do
   fn f -> 
      (fn x -> 
        x.(x) 
      end).(
        fn y -> 
          f.(
            fn arg -> 
              y.(y).(arg) 
            end
          ) 
        end
      ) 
    end
  end

  def loop(initialization, condition, body) do
    y_combinator.(fn recurse ->
      fn state ->
        if !condition.(state) do 
          state
        else
          state
          |> body.()
          |> recurse.()
        end
      end
    end).(initialization)
  end
end