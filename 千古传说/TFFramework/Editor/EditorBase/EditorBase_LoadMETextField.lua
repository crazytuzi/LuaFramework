local tMETextField = {}
-- tMETextField.__index = tMETextField
-- setmetatable(tMETextField, EditLua)

function EditLua:createTextField(szId, tParams)
	print("createTextField")
	if targets[szId] ~= nil then
		return
	end
	local textField = TFTextField:create()
	textField:setPlaceHolder("input TextField")
	textField:setFontName("宋体")
	textField:setFontSize(32)
	
	-- tTouchEventManager:registerEvents(textField)
	targets[szId] = textField
	targets[szId]._LabelFontFillColor = ccc3(255, 255, 255)
	targets[szId]._LabelMixColor		= ccc3(255, 255, 255)
	
	EditLua:addToParent(szId, tParams)

	print("create success")
end

function tMETextField:setPasswordEnabled(szId, tParams)
	print("setPasswordEnabled")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setPasswordEnabled then
		targets[szId]:setPasswordEnabled(tParams.bRet)
		-- targets[szId]:setText(targets[szId]:getText())
		print("setPasswordEnabled run success")
	end
end

function tMETextField:setPasswordStyleText(szId, tParams)
	print("setPasswordStyleText")
	if tParams.szStyleText ~= nil and targets[szId] ~= nil and targets[szId].setPasswordStyleText then
		targets[szId]:setPasswordStyleText(tParams.szStyleText)
		-- targets[szId]:setText(targets[szId]:getText())
		print("setPasswordStyleText run success")
	end
end

function tMETextField:setMaxLengthEnabled(szId, tParams)
	print("setMaxLengthEnabled")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setMaxLengthEnabled then
		targets[szId]:setMaxLengthEnabled(tParams.bRet)
		print("setMaxLengthEnabled run success")
	end
end

function tMETextField:setMaxLength(szId, tParams)
	print("setMaxLength")
	if tParams.nLength ~= nil and targets[szId] ~= nil and targets[szId].setMaxLength then
		targets[szId]:setMaxLength(tParams.nLength)
		print("setMaxLength run success")
	end
end

function tMETextField:setPlaceHolder(szId, tParams)
	print("setPlaceHolder")
	if tParams.szPlaceHolder ~= nil and targets[szId] ~= nil and targets[szId].setPlaceHolder then
		targets[szId]:setPlaceHolder(tParams.szPlaceHolder)
		print("setPlaceHolder run success")
	end
end

function tMETextField:setText(szId, tParams)
	print("setText")
	if tParams.szText and targets[szId] ~= nil and targets[szId].setText then
		targets[szId]:setText(tParams.szText)
		print("setText run success")
	end
end

function tMETextField:setFontSize(szId, tParams)
	print("setFontSize")
	if tParams.nSize ~= nil and targets[szId] ~= nil and targets[szId].setFontSize then
		targets[szId]:setFontSize(tParams.nSize)
		print("setFontSize run success")
	end
end

function tMETextField:setFontName(szId, tParams)
	print("setFontName")
	if tParams.szFontName ~= nil and targets[szId] ~= nil and targets[szId].setFontName then
		targets[szId]:setFontName(tParams.szFontName)
		print("setFontName run success")
	end
end

function tMETextField:setCursorEnabled(szId, tParams)
	print("setCursorEnabled")
	if tParams.bRet ~= nil and targets[szId].setCursorEnabled then
		targets[szId]:setCursorEnabled(tParams.bRet)
		print("setCursorEnabled run success")
	end
end

function tMETextField:setTextAreaSize(szId, tParams)
	print("setTextAreaSize")
	if tParams.nWidth and tParams.nHeight and targets[szId].setTextAreaSize then
		if not targets[szId]:isIgnoreContentAdaptWithSize()  then
			targets[szId]:setTextAreaSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		end
		print("setTextAreaSize run success")
	end
end

function tMETextField:setTextHorizontalAlignment(szId, tParams)
	print("setTextHorizontalAlignment")
	if tParams.nHAlignment ~= nil and targets[szId].setTextHorizontalAlignment then
		targets[szId]:setTextHorizontalAlignment(tParams.nHAlignment)
		print("setTextHorizontalAlignment run success")
	end
end

function tMETextField:setTextVerticalAlignment(szId, tParams)
	print("setTextVerticalAlignment")
	if tParams.nVAlignment ~= nil and targets[szId].setTextVerticalAlignment then
		targets[szId]:setTextVerticalAlignment(tParams.nVAlignment)
		print("setTextVerticalAlignment run success")
	end
end

function tMETextField:setKeyBoardType(szId, tParams)
	print("setKeyBoardType")
	targets[szId]:setKeyBoardType(tParams.nType)
	print("setKeyBoardType success")
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function tMETextField:setColor(szId, tParams)
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

function tMETextField:setFontColor(szId, tParams)
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

function tMETextField:setSize(szId, tParams)
	tMETextField:setTextAreaSize(szId, tParams)
end

function tMETextField:setTextMaxLength(szId, tParams)
	print("setTextMaxLength")
	if tParams.nLength == -1 then
		targets[szId]:setMaxLengthEnabled(false)  
	else
		targets[szId]:setMaxLengthEnabled(true)
		targets[szId]:setMaxLength(tParams.nLength)
	end
	print("setTextMaxLength run success")
end


return tMETextField