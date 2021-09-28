local recycle = import("csv2cfg.RecyleEquip")
local refine = import("csv2cfg.RefineEquip")
local secdefine = import("csv2cfg.SecRefineEquip")
local identify = {}
local property_name = {
	"AC",
	"MAC",
	"DC",
	"MC",
	"SC",
	"MAXHP"
}
local property_name2text = {
	AC = "防御: ",
	MC = "魔法: ",
	MAXHP = "生命值: +",
	DC = "攻击: ",
	MAC = "魔御: ",
	SC = "道术: "
}
identify.getList = function (self, tb, idx)
	for k, v in pairs(tb) do
		if tostring(k) == tostring(idx) then
			local result = {}

			for i = 1, #property_name, 1 do
				if property_name[i] ~= "MAXHP" then
					local value = tonumber(v[property_name[i]])
					local maxValue = tonumber(v["Max" .. property_name[i]])

					if value ~= 0 or maxValue ~= 0 then
						local temp = {
							text = property_name2text[property_name[i]],
							value = value .. "-" .. maxValue
						}

						table.insert(result, temp)
					end
				else
					local value = tonumber(v[property_name[i]])

					if value ~= 0 then
						local temp = {
							text = property_name2text[property_name[i]],
							value = value
						}

						table.insert(result, temp)
					end
				end
			end

			return result
		end
	end

	return 
end
identify.getIdentifyListByIdx = function (idx)
	return identify:getList(refine, idx)
end
identify.getIdentifyConfigByIdx = function (idx)
	for k, v in pairs(refine) do
		if tostring(k) == tostring(idx) then
			return v
		end
	end

	return 
end
identify.getRecycleConfigByIdx = function (idx)
	for k, v in pairs(recycle) do
		if tostring(k) == tostring(idx) then
			return v
		end
	end

	return 
end
identify.getSecDefineListByIdx = function (idx)
	return identify:getList(secdefine, idx)
end
identify.getSecDefineConfigByIdx = function (idx)
	for k, v in pairs(secdefine) do
		if tostring(k) == tostring(idx) then
			return v
		end
	end

	return 
end
identify.getSecPropertyListByIdx = function (idx)
	local result = {}
	local define1 = {}

	for k, v in pairs(refine) do
		if tostring(k) == tostring(idx) then
			define1 = v

			break
		end
	end

	local define2 = {}

	for k, v in pairs(secdefine) do
		if tostring(k) == tostring(idx) then
			define2 = v

			break
		end
	end

	for i = 1, #property_name, 1 do
		if property_name[i] ~= "MAXHP" then
			local value = tonumber(define1[property_name[i]]) + tonumber(define2[property_name[i]])
			local maxValue = tonumber(define1["Max" .. property_name[i]]) + tonumber(define2["Max" .. property_name[i]])

			if value ~= 0 or maxValue ~= 0 then
				local temp = {
					text = property_name2text[property_name[i]],
					value = value .. "-" .. maxValue
				}

				table.insert(result, temp)
			end
		else
			local value = tonumber(define1[property_name[i]]) + tonumber(define2[property_name[i]])

			if value ~= 0 then
				local temp = {
					text = property_name2text[property_name[i]],
					value = value
				}

				table.insert(result, temp)
			end
		end
	end

	return result
end

return identify
