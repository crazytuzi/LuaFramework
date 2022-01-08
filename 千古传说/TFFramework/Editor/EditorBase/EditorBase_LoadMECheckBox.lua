local tMECheckBox = {}
-- tMECheckBox.__index = tMECheckBox
-- setmetatable(tMECheckBox, EditLua)
function EditLua:createCheckBox(szId, tParams)
	print("createCheckBox")
	if targets[szId] ~= nil then
		return
	end
	local checkBox = TFCheckBox:create()
	checkBox:setTextureBackGround("test/selected01.png")
	checkBox:setTextureBackGroundSelected("test/selected01.png")
	checkBox:setTextureFrontCross("test/selected02.png")

	tTouchEventManager:registerEvents(checkBox)
	targets[szId] = checkBox

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMECheckBox:setSelectedState(szId, tParams)
	print("setSelectedState")
	if targets[szId] ~= nil and targets[szId].setSelectedState and tParams.bRet ~= nil then
		targets[szId]:setSelectedState(tParams.bRet)
		print("setSelectedState success")
	end
end

function tMECheckBox:setClickType(szId, tParams)
	print("setClickType")
	if targets[szId] ~= nil and targets[szId].setClickType then
		targets[szId]:setClickType(tParams.nType)
		print("setClickType success")
	end
end

function tMECheckBox:setBackGroundTexture(szId, tParams)
	print("setBackGroundTexture")
	if tParams.szBgTexture ~= nil and targets[szId] ~= nil and targets[szId].setTextureBackGround then

		targets[szId]:setTextureBackGround(tParams.szBgTexture)
		if tParams.szBgTexture == "" then
			targets[szId]:setTextureBackGround("test/selected01.png")
		end

		print("setBackGroundTexture run success")
	end
end

function tMECheckBox:setBackGroundSelectedTexture(szId, tParams)
	print("setBackGroundSelectedTexture")
	if tParams.szBgSelectedTexture ~= nil and targets[szId] ~= nil and targets[szId].setTextureBackGroundSelected then

		targets[szId]:setTextureBackGroundSelected(tParams.szBgSelectedTexture)
		if tParams.szBgSelectedTexture == "" then
			targets[szId]:setTextureBackGroundSelected("test/selected01.png")
		end

		print("setBackGroundSelectedTexture run success")
	end
end

function tMECheckBox:setBackGroundDisabledTexture(szId, tParams)
	print("setBackGroundDisabledTexture")
	if tParams.szBgDisabledTexture ~= nil and targets[szId] ~= nil and targets[szId].setTextureBackGroundDisabled then
		if tParams.szBgDisabledTexture == "" then
			tParams.szBgDisabledTexture = "test/selected01.png"
		end
		targets[szId]:setTextureBackGroundDisabled(tParams.szBgDisabledTexture)
		print("setBackGroundDisabledTexture run success")
	end
end

function tMECheckBox:setFrontCrossTexture(szId, tParams)
	print("setFrontCrossTexture")
	if tParams.szFrontCrossTexture ~= nil and targets[szId] ~= nil and targets[szId].setTextureFrontCross then

		targets[szId]:setTextureFrontCross(tParams.szFrontCrossTexture)
		if tParams.szFrontCrossTexture == "" then
			targets[szId]:setTextureFrontCross("test/selected02.png")
		end

		print("setFrontCrossTexture run success")
	end
end

function tMECheckBox:setFrontCrossDisabledTexture(szId, tParams)
	print("setFrontCrossDisabledTexture")
	if tParams.szFrontCrossDisabledTexture ~= nil and targets[szId] ~= nil and targets[szId].setTextureFrontCrossDisabled then
		if tParams.szFontCrossDisabledTexture == "" then
			tParams.szFontCrossDisabledTexture = "test/selected01.png"
		end
		targets[szId]:setTextureFrontCrossDisabled(tParams.szFontCrossDisabledTexture)
		print("setFrontCrossDisabledTexture run success")
	end
end

return tMECheckBox