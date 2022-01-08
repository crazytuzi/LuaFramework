EditorUtils = {}

function EditorUtils:GetIntPart(x)
	if x <= 0 then
		return math.ceil(x)
	end

	if math.ceil(x) == x then
		x = math.ceil(x)
	else
		x = math.ceil(x) - 1
	end
	return x
end

-- declear in TFfuntionUtils
-- function EditorUtils:isNaN(x)
-- 	return x ~= x
-- end


function EditorUtils:TargetIsContainer(target)
	return TFFunction.call(target.getNodeType, target) == TFWIDGET_TYPE_CONTAINER
end

function EditorUtils:TargetIsAbsoluteLayout(target)
	return TFFunction.call(target.getLayoutType, target) == TF_LAYOUT_ABSOLUTE
end

function EditorUtils:TargetIsLinearLayout(target)
	return TFFunction.call(target.getLayoutType, target) == TF_LAYOUT_LINEAR_VERTICAL or TFFunction.call(target.getLayoutType, target) == TF_LAYOUT_LINEAR_HORIZONTAL
end

function EditorUtils:TargetIsRelativeLayout(target)
	return TFFunction.call(target.getLayoutType, target) == TF_LAYOUT_RELATIVE
end

function EditorUtils:TargetIsGridLayout(target)
	return TFFunction.call(target.getLayoutType, target) == TF_LAYOUT_GRID
end

local results = {}
local index = 0
function EditorUtils:load(command)
	local res = results[command]
	if res then
		index = index + 1
		-- print("already load this function.", index)
		return results[command](), true
	end
	local tParams = {}
	_, __ = pcall(loadstring, command)
	if __ and type(__) == "function" then
		results[command] = __
		tParams = __()
	elseif not __ then
		TFLOGERROR("!!!!!!!!!!!!!!!!! arguments is invailed !!!!!!!!!!!!!!\n\n")
		bIsError = true
		return nil, false
	end
	return tParams, true
end

function EditorUtils:recordInfo(szId, command, arg)
	TFLOGINFO("\n\t\t\trecived command:")
	TFLOGINFO("\tID:\t\t" .. szId)
	if targets[szId] then TFLOGINFO("\tName&Type:\t" .. targets[szId]:getName() .. '\t' .. tolua.type(targets[szId])) end
	TFLOGINFO("\tcommands:\t" .. command)
	TFLOGINFO("\tparams:\t\t" .. arg)
end

function EditorUtils:convertSpecialChar(tParam)
	if tParam and tParam.szText then
		tParam.szText = string.gsub(tParam.szText, "&amp;", "&")
		tParam.szText = string.gsub(tParam.szText, "&lt;", "<")
		tParam.szText = string.gsub(tParam.szText, "&gt;", ">")
		tParam.szText = string.gsub(tParam.szText, "&apos;", "'")
		tParam.szText = string.gsub(tParam.szText, "&quot;", [["]])
		tParam.szText = string.gsub(tParam.szText, "&bslash;", [[\]])
	end
end

return EditorUtils