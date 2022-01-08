local tMEButton = {}
tMEButton.__index = tMEButton
-- setmetatable(tMEButton, EditLua)
function EditLua:createButton(szId, tParams)
	print("createButton")
	if targets[szId] ~= nil then
		print("targets is not null", targets[szId])
		return
	end
	local button = TFButton:create()
	button:setTextureNormal("test/button/com_btn3_n.png")
	-- tTouchEventManager:registerEvents(button)
	targets[szId] = button
	targets[szId]._LabelStrokeSize = 1
	targets[szId]._LabelColor = ccc3(0, 0, 0)
	
	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMEButton:loadTextureNormal(szId, tParams)
	print("loadTextureNormal")
	if tParams.szNormalName ~= nil and targets[szId] ~= nil and targets[szId].setTextureNormal then
		if tParams.szNormalName == "" then
			tParams.szNormalName = "test/button/com_btn3_n.png"
		end
		targets[szId]:setTextureNormal(tParams.szNormalName)
		print("loadTextureNormal run success")
	end
end

function tMEButton:loadTexturePressed(szId, tParams)
	print("loadTexturePressed")
	if tParams.szPressName ~= nil and targets[szId] ~= nil and targets[szId].setTexturePressed then

		targets[szId]:setTexturePressed(tParams.szPressName)
		-- if tParams.szPressName == "" then
		-- 	targets[szId]:setTexturePressed("test/button/com_btn3_p.png")
		-- end

		print("loadTexturePressed run success")
	end
end

function tMEButton:loadTextureDisabled(szId, tParams)
	print("loadTextureDisabled")
	if tParams.szDisableName ~= nil and targets[szId] ~= nil and targets[szId].setTextureDisabled then

		targets[szId]:setTextureDisabled(tParams.szDisableName)
		-- if tParams.szDisableName == "" then
		-- 	targets[szId]:setTextureDisabled("test/button/com_btn3_d.png")
		-- end
		print("loadTextureDisabled run success")
	end
end

function tMEButton:setTitleText(szId, tParams)
	print("setTitleText")
	if tParams.szText ~= nil and targets[szId] ~= nil and targets[szId].setText then
		targets[szId]:setText(tParams.szText)
		print("setTitleText run success")
	end
end

function tMEButton:setTitleColor(szId, tParams)
	print("setTitleColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setFontColor then
		targets[szId]:setFontColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setTitleColor run success")
	end
end

function tMEButton:setTitleFontSize(szId, tParams)
	print("setTitleFontSize")
	if tParams.nSize ~= nil and targets[szId] ~= nil and targets[szId].setFontSize then
		targets[szId]:setFontSize(tParams.nSize)
		print("setTitleFontSize run success")
	end
end

function tMEButton:setTitleFontName(szId, tParams)
	print("setTitleFontName")
	if tParams.szFontName ~= nil and targets[szId] ~= nil and targets[szId].setFontName then
		targets[szId]:setFontName(tParams.szFontName)
		print("setTitleFontName run success")
	end
end

function tMEButton:setClickHighLightEnabled(szId, tParams)
	print("setClickHighLightEnabled")
	if tParams.bRet ~= nil then
		targets[szId]:setClickHighLightEnabled(tParams.bRet)
	end
	print("setClickHighLightEnabled run success")
end

function tMEButton:setClickImgAdd(szId, tParams)
	print("setClickImgAdd")
	if tParams.bRet ~= nil then
		targets[szId]:setClickImgAdd(tParams.bRet)
	end
	print("setClickImgAdd run success")
end


---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function tMEButton:setText(szId, tParams)
	print("setText")
	if tParams.szText ~= nil and targets[szId] ~= nil and targets[szId].setText then
		targets[szId]:setText(tParams.szText)
		print("setText run success")
	end
end

function tMEButton:setFontColor(szId, tParams)
	print("setFontColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setFontColor then
		targets[szId]:setFontColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setFontColor run success")
	end
end

function tMEButton:setFontSize(szId, tParams)
	print("setFontSize")
	if tParams.nSize ~= nil and targets[szId] ~= nil and targets[szId].setFontSize then
		targets[szId]:setFontSize(tParams.nSize)
		print("setFontSize run success")
	end
end

function tMEButton:setFontName(szId, tParams)
	print("setTitleFontName")
	if tParams.szFontName ~= nil and targets[szId] ~= nil and targets[szId].setFontName then
		targets[szId]:setFontName(tParams.szFontName)
		print("setTitleFontName run success")
	end
end

function tMEButton:setTextHorizontalAlignment(szId, tParams)
	print("setTextHorizontalAlignment")
	if tParams.nHAlignment ~= nil and targets[szId].setTextHorizontalAlignment then
		targets[szId]:setTextHorizontalAlignment(tParams.nHAlignment)
		print("setTextHorizontalAlignment run success")
	end
end

function tMEButton:setTextVerticalAlignment(szId, tParams)
	print("setTextVerticalAlignment")
	if tParams.nVAlignment ~= nil and targets[szId].setTextVerticalAlignment then
		targets[szId]:setTextVerticalAlignment(tParams.nVAlignment)
		print("setTextVerticalAlignment run success")
	end
end

function tMEButton:setStrokeEnabled(szId, tParams)
	print("setStrokeEnabled")
	local label = targets[szId]:getLabel()
	if tParams.bEnabled then
		label:enableStroke(targets[szId].LabelColor, targets[szId]._LabelStrokeSize, true)
	else
		label:disableStroke(true)
	end
	print("setStrokeEnabled success")
end

function tMEButton:setStrokeSize(szId, tParams)
	print("setStrokeSize")
	local label = targets[szId]:getLabel()
	targets[szId]._LabelStrokeSize = tParams.nSize
	label:enableStroke(targets[szId].LabelColor, targets[szId]._LabelStrokeSize, true)
	print("setStrokeSize success")
end

function tMEButton:setStrokeColor(szId, tParams)
	print("setStrokeColor")
	local label = targets[szId]:getLabel()
	targets[szId].LabelColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
	label:enableStroke(targets[szId].LabelColor, targets[szId]._LabelStrokeSize, true)
	print("setStrokeColor success")
end

return tMEButton