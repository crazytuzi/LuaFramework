local tMELabel = {}
tMELabel.__index = tMELabel
-- setmetatable(tMELabel, EditLua)

function EditLua:createLabel(szId, tParams)
	print("createLabel")
	if targets[szId] ~= nil then
		return
	end
	local label = TFLabel:create()
	label:setText("TestLabel")
	label:setFontName("simsun")
	label:setFontSize(20)
	label:setAnchorPoint(ccp(0.5, 0.5))
	-- tTouchEventManager:registerEvents(label)
	targets[szId] = label
	targets[szId]._LabelStrokeSize 		= 1
	targets[szId]._LabelStrokeColor 	= ccc3(0, 0, 0)
	targets[szId]._LabelFontFillColor 	= ccc3(255, 255, 255)
	targets[szId]._LabelMixColor		= ccc3(255, 255, 255)
	targets[szId]._LabelShadowOffset 	= CCSizeMake(1, 1)
	targets[szId]._LabelShadowColor 	= ccc3(0, 0, 0)
	targets[szId]._LabelShadowOpacity 	= 1

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMELabel:setText(szId, tParams)
	print("setText")
	if tParams.szText and targets[szId].setText then
		targets[szId]:setText(tParams.szText)
		print("setText run success")
	end
end

function tMELabel:setFontSize(szId, tParams)
	print("setFontSize")
	if tParams.nSize ~= nil and targets[szId].setFontSize then
		targets[szId]:setFontSize(tParams.nSize)
		print("setFontSize run success")
	end
end

function tMELabel:setFontName(szId, tParams)
	print("setFontName")
	if tParams.szFontName ~= nil and targets[szId].setFontName then
		targets[szId]:setFontName(tParams.szFontName)
		print("setFontName run success")
	end
end

function tMELabel:setTextAreaSize(szId, tParams)
	print("setTextAreaSize")
	if tParams.nWidth and tParams.nHeight and targets[szId].setTextAreaSize then
		if not targets[szId]:isIgnoreContentAdaptWithSize()  then
			targets[szId]:setTextAreaSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		end
		print("setTextAreaSize run success")
	end
end
--[[
typedef enum
{
	kCCVerticalTextAlignmentTop,
	kCCVerticalTextAlignmentCenter,
	kCCVerticalTextAlignmentBottom,
} CCVerticalTextAlignment;

// XXX: If any of these enums are edited and/or reordered, update CCTexture2D.m
//! Horizontal text alignment type
typedef enum
{
	kCCTextAlignmentLeft,
	kCCTextAlignmentCenter,
	kCCTextAlignmentRight,
} CCTextAlignment;
]]
function tMELabel:setTextHorizontalAlignment(szId, tParams)
	print("setTextHorizontalAlignment")
	if tParams.nHAlignment ~= nil and targets[szId].setTextHorizontalAlignment then
		targets[szId]:setTextHorizontalAlignment(tParams.nHAlignment)
		print("setTextHorizontalAlignment run success")
	end
end

function tMELabel:setTextVerticalAlignment(szId, tParams)
	print("setTextVerticalAlignment")
	if tParams.nVAlignment ~= nil and targets[szId].setTextVerticalAlignment then
		targets[szId]:setTextVerticalAlignment(tParams.nVAlignment)
		print("setTextVerticalAlignment run success")
	end
end

function tMELabel:setTouchScaleChangeAble(szId, tParams)
	print("setTouchScaleChangeAble")
	if targets[szId] and targets[szId].setTouchScaleChangeAble and tParams.bRet ~= nil then
		targets[szId]:setTouchScaleChangeAble(tParams.bRet)
		print("setTouchScaleChangeAble success")
	end
end

function tMELabel:setLabelStroke(szId, tParams)
	print("setLabelStroke")
	if tParams.bRet then
		targets[szId]:enableStroke(ccc3(tParams.r, tParams.g, tParams.b), tParams.nStrokeSize, true)
	else
		targets[szId]:disableStroke(true)
	end
	print("setLabelStroke success")
end

function tMELabel:setShadowEnabled(szId, tParams)
	print("setLabelShadow")
	if tParams.bEnabled then
		targets[szId]:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset, targets[szId]._LabelShadowOpacity)
	else
		targets[szId]:disableShadow()
	end
	print("setLabelShadow success")
end

function tMELabel:setShadowColor(szId, tParams)
	print("setShadowColor")
	targets[szId]._LabelShadowColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
	if targets[szId]:isShadowEnabled() then
		targets[szId]:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset, targets[szId]._LabelShadowOpacity)
	end
	print("setShadowColor success")
end

function tMELabel:setShadowOffset(szId, tParams)
	print("setShadowOffset")
	targets[szId]._LabelShadowOffset = CCSizeMake(tParams.nX, tParams.nY)
	if targets[szId]:isShadowEnabled() then
		targets[szId]:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset, targets[szId]._LabelShadowOpacity)
	end
	print("setShadowOffset success")
end

function tMELabel:setShadowOpacity(szId, tParams)
	print("setShadowOpacity")
	targets[szId]._LabelShadowOpacity = tParams.nOpacity / 255
	if targets[szId]:isShadowEnabled() then
		targets[szId]:enableShadow(targets[szId]._LabelShadowColor, targets[szId]._LabelShadowOffset, targets[szId]._LabelShadowOpacity)
	end
	print("setShadowOpacity success")
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function tMELabel:setColor(szId, tParams)
	print("setColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setFontFillColor then
		targets[szId]._LabelMixColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
		if me.platform == me.platforms[me.PLATFORM_WIN32] then
			local color = targets[szId]._LabelFontFillColor
			targets[szId]:setColor(ccc3(color.r*tParams.nR/255, color.g*tParams.nG/255, color.b*tParams.nB/255))
		else
			targets[szId]:setColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		end
		print("setColor run success")
	end
end

function tMELabel:setFontColor(szId, tParams)
	print("setFontColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setFontFillColor then
		targets[szId]:setFontFillColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		targets[szId]._LabelFontFillColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
		if me.platform == me.platforms[me.PLATFORM_WIN32] then
			local color = targets[szId]._LabelMixColor
			targets[szId]:setColor(ccc3(color.r*tParams.nR/255, color.g*tParams.nG/255, color.b*tParams.nB/255) )
		end
		print("setFontColor run success")
	end
end

function tMELabel:setStrokeEnabled(szId, tParams)
	print("setStrokeEnabled")
	if tParams.bEnabled then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	else
		targets[szId]:disableStroke(true)
	end
	print("setStrokeEnabled success")
end

function tMELabel:setStrokeSize(szId, tParams)
	print("setStrokeSize")
	targets[szId]._LabelStrokeSize = tParams.nSize
	if targets[szId]:isStrokeEnabled() then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	end
	print("setStrokeSize success")
end

function tMELabel:setStrokeColor(szId, tParams)
	print("setStrokeColor")
	targets[szId]._LabelStrokeColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
	if targets[szId]:isStrokeEnabled() then
		targets[szId]:enableStroke(targets[szId]._LabelStrokeColor, targets[szId]._LabelStrokeSize, true)
	end
	print("setStrokeColor success")
end

function tMELabel:setSize(szId, tParams)
	tMELabel:setTextAreaSize(szId, tParams)
end

return tMELabel