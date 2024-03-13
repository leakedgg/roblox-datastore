-- THIS NEEDS TO BE A MODULE! -- 

-- Define a type alias for functions that take any argument and return nil
type Function = (any) -> nil

-- Define and return a table containing the pairsForLoop function
return {
	pairsForLoop = function(func: Function, data: array)
		-- Iterate over the key-value pairs of the data table
		for key: any, value: any in pairs(data) do
			-- Call the provided function with the current key and value
			func(key, value)
		end
	end
}
