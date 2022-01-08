local tMEIconLabel = {}
tMEIconLabel.__index = tMEIconLabel
-- setmetatable(tMEIconLabel, require("TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel"))

function EditLua:createIconLabel(szId, tParams)
	print("createIconLabel")
	if targets[szId] ~= nil then
		return
	end
	local label = TFIconLabel:create()
	label:setText("TestLabel")
	label:setFontName("simsun")
	label:setFontSize(20)
	-- tTouchEventManager:registerEvents(label)
	targets[szId] = label
	targets[szId]._LabelStrokeSize = 1
	targets[szId]._LabelStrokeColor = ccc3(0, 0, 0)
	targets[szId]._LabelShadowOffset = CCSizeMake(1, 1)
	targets[szId]._LabelShadowColor = ccc3(0, 0, 0)
	targets[szId]._LabelShadowOpacity = 1

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMEIconLabel:setFontSize(szId, tParams)
	print("tMEIconLabel setFontSize")
	targets[szId]:setFontSize(tParams.nSize)
	print("setFontSize run success")
end

function tMEIconLabel:setFontName(szId, tParams)
	print("tMEIconLabel setFontName")
	targets[szId]:setFontName(tParams.szFontName)
	print("setFontName run success")
end

function tMEIconLabel:setText(szId, tParams)
	print("tMEIconLabel setText")
	targets[szId]:setText(tParams.szText)
	print("setText run success")
end

function tMEIconLabel:setTextColor(szId, tParams)
	print("tMEIconLabel setTextColor")
	targets[szId]:setTextColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
	print("setTextColor run success")
end

function tMEIconLabel:setTouchScaleChangeAble(szId, tParams)
	print("tMEIconLabel setTouchScaleChangeAble")
	targets[szId].Label:setTouchScaleChangeAble(tParams.bRet)
	print("setTouchScaleChangeAble success")
end

function tMEIconLabel:setIcon(szId, tParams)
	print("setIcon")
	targets[szId]:setIcon(tParams.szFileName)
	print("setIcon success")
end

function tMEIconLabel:setIconDir(szId, tParams)
	print("setIconDir")
	targets[szId]:setIconDir(tParams.nDir)
	print("setIconDir success")
end

function tMEIconLabel:setGap(szId, tParams)
	print("setGap")
	targets[szId]:setGap(tParams.nGap)
	print("setGap success")
end

function tMEIconLabel:setIconVAlign(szId, tParams)
	print("setIconVAlign")
	targets[szId]:setIconVAlign(tParams.nType)
	print("setIconVAlign success")
end

function tMEIconLabel:setTextVAlign(szId, tParams)
	print("setTextVAlign")
	targets[szId]:setTextVAlign(tParams.nType)
	print("setTextVAlign success")
end

function tMEIconLabel:setTouchScaleChangeAble(szId, tParams)
	print("setTouchScaleChangeAble")
	if targets[szId] and targets[szId].setTouchScaleChangeAble and tParams.bRet ~= nil then
		targets[szId]:setTouchScaleChangeAble(tParams.bRet)
		print("setTouchScaleChangeAble success")
	end
end

function tMEIconLabel:setLabelStroke(szId, tParams)
	print("tMEIconLabel setLabelStroke")
	if tParams.bRet then
		targets[szId].Label:enableStroke(ccc3(tParams.r, tParams.g, tParams.b), tParams.nStrokeSize, true)
	else
		targets[szId].Label:disableStroke(true)
	end
	print("setLabelStroke success")
end

function tMEIconLabel:setColor(szId, tParams)
	print("tMEIconLabel setColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setColor then
		targets[szId]:setColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("tMEIconLabel setColor success")
	end
end

function tMEIconLabel:setShadowEnabled(szId, tParams)
	print("setLabelShadow")
	if tParams.bEnabled then
		targets[szId].Label:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset)
	else
		targets[szId].Label:disableShadow()
	end
	print("setLabelShadow success")
end

function tMEIconLabel:setShadowColor(szId, tParams)
	print("setShadowColor")
	local color = targets[szId]:getColor()
	targets[szId]._LabelShadowColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
	if targets[szId].Label:isShadowEnabled() then
		targets[szId].Label:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset)
	end
	targets[szId]:setColor(color)
	print("setShadowColor success")
end

function tMEIconLabel:setShadowOffset(szId, tParams)
	print("setShadowOffset")
	targets[szId]._LabelShadowOffset = CCSizeMake(tParams.nX, tParams.nY)
	if targets[szId].Label:isShadowEnabled() then
		targets[szId].Label:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset)
	end
	print("setShadowOffset success")
end

function tMEIconLabel:setShadowOpacity(szId, tParams)
	print("setShadowOpacity")
	targets[szId]._LabelShadowOpacity = tParams.nOpacity / 255
	if targets[szId].Label:isShadowEnabled() then
		targets[szId].Label:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset, targets[szId]._LabelShadowOpacity)
	end
	print("setShadowOpacity success")
end

function tMEIconLabel:setTouchEnabled(szId, tParams)
	print("setTouchEnabled")
	if tParams.bRet ~= nil and targets[szId].setTouchEnabled ~= nil then
		targets[szId]:setTouchEnabled(tParams.bRet)
		targets[szId].Label:setTouchEnabled(tParams.bRet)
		print("setTouchEnabled run success")
	end	
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function tMEIconLabel:setFontColor(szId, tParams)
	print("setFontColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setTextColor then
		targets[szId]:setTextColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setFontColor run success")
	end
end

-- function tMEIconLabel:setTextHorizontalAlignment(szId, tParams)
-- 	print("setTextHorizontalAlignment")
-- 	targets[szId]:setTextHorizontalAlignment(tParams.nHAlignment)
-- 	print("setTextHorizontalAlignment run success")
-- end

function tMEIconLabel:setTextVerticalAlignment(szId, tParams)
	print("setTextVerticalAlignment")
	targets[szId]:setTextVerticalAlignment(tParams.nVAlignment)
	print("setTextVerticalAlignment run success")
end

function tMEIconLabel:setStrokeEnabled(szId, tParams)
	print("setStrokeEnabled")
	if tParams.bEnabled then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	else
		targets[szId]:disableStroke(true)
	end
	print("setStrokeEnabled success")
end

function tMEIconLabel:setStrokeSize(szId, tParams)
	print("setStrokeSize")
	targets[szId]._LabelStrokeSize = tParams.nSize
	if targets[szId].Label:isStrokeEnabled() then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	end
	print("setStrokeSize success")
end

function tMEIconLabel:setStrokeColor(szId, tParams)
	print("setStrokeColor")
	targets[szId]._LabelStrokeColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
	if targets[szId].Label:isStrokeEnabled() then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	end
	print("setStrokeColor success")
end


return tMEIconLabel