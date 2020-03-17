_G.wuhunActionMap = {}
_G.GetWuHunAnimaTable = function(action, nameString)
	action = string.lower(action);
	if not wuhunActionMap[action .. nameString] then
	    local file = string.gsub(action, "zhujue", nameString)
        local filetable = split(file, "|")
        wuhunActionMap[action .. nameString] = filetable[1]
    end
    return wuhunActionMap[action .. nameString]
end

_G.horseActionMap = {}
_G.GetHorseAnimaTable = function(action, string1, string2, isHorse)
	action = string.lower(action);
	if not horseActionMap[action .. string1 .. string2] then
	    local file = string.gsub(action, string1, string2)
        local filetable = GetVerticalTable(file)
        horseActionMap[action .. string1 .. string2] = filetable[1]
    end
    return horseActionMap[action .. string1 .. string2]
end

_G.poundTable = {}
_G.GetPoundTable = function(string)
	if not string or #string==0 then
		return;
	end
	if not poundTable[string] then
		poundTable[string] = split(string, '#')
	end
	return poundTable[string]
end

_G.verticalTable = {}
_G.GetVerticalTable = function(string)
	if not verticalTable[string] then
		verticalTable[string] = split(string, '|')
	end
	return verticalTable[string]
end

_G.colonTable = {}
_G.GetColonTable = function(string)
	if not colonTable[string] then
		colonTable[string] = split(string, ':')
	end
	return colonTable[string]
end

_G.commaTable = {}
	_G.GetCommaTable = function(string)
	if not commaTable[string] then
		commaTable[string] = split(string, ',')
	end
	return commaTable[string]
end

_G.slantedTable = {}
_G.GetSlantedTable = function(string)
	if not slantedTable[string] then
		slantedTable[string] = split(string, '/')
	end
	return slantedTable[string]
end