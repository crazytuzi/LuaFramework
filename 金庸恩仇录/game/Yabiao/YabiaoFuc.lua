local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local timeGourp = {}

function randomPosX(time)
	local timeTotal = data_config_yabiao_config_yabiao[16].value
	local timeSpan = data_config_yabiao_config_yabiao[20].value
	for i = 0, timeTotal, timeSpan do
		if time >= i * 60 and time < (i + timeSpan) * 60 then
			if #timeGourp[i + 1] == 4 then
				timeGourp[i + 1] = {}
			end
			local countIndex = 0
			local getRandom
			function getRandom()
				local seed = math.random(1, 4)
				if #timeGourp[i + 1] == 0 then
					table.insert(timeGourp[i + 1], seed)
					return seed
				end
				local isDouble = false
				for key1, v1 in pairs(timeGourp[i + 1]) do
					if v1 == seed then
						isDouble = true
						break
					end
				end
				if not isDouble then
					table.insert(timeGourp[i + 1], seed)
					return seed
				end
				countIndex = countIndex + 1
				if countIndex > 5 then
					countIndex = 0
					return math.random(1, 4)
				end
				return getRandom()
			end
			return getRandom()
			
		end
	end
end

function initTimeGroup()
	local timeTotal = data_config_yabiao_config_yabiao[16].value
	local timeSpan = data_config_yabiao_config_yabiao[20].value
	for i = 0, timeTotal, timeSpan do
		timeGourp[i + 1] = {}
	end
end