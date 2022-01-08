local tMEButtonGroup = {}
tMEButtonGroup.__index = tMEButtonGroup
setmetatable(tMEButtonGroup, require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel'))

function EditLua:createButtonGroup(szId, tParams)
	print("createButtonGroup")

	local btnGroup = TFButtonGroup:create()
	btnGroup:setBackGroundColorOpacity(50)
	btnGroup:setSize(CCSize(210, 100))
	btnGroup:setLayoutType('vertical')
	btnGroup:setRows(1)
	btnGroup:setColumn(1)
	btnGroup:setLayoutDirect("left_top")
	btnGroup:setHGap(0)
	btnGroup:setVGap(0)
	
	btnGroup:doLayout()

	tTouchEventManager:registerEvents(btnGroup)
	targets[szId] = btnGroup
	
	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMEButtonGroup:setRow(szId, tParams)
	print("tMEButtonGroup setRow")
	print(targets[szId]:getLayoutType())
	-- if targets[szId]:getLayoutType() == "vertical" then
		targets[szId]:setColumn(tParams.nRow)
	-- else
		targets[szId]:setRows(tParams.nRow)
	-- end
	print("tMEButtonGroup setRow success")
end

function tMEButtonGroup:setColumn(szId, tParams)
	print("tMEButtonGroup setColumn")
	targets[szId]:setColumn(tParams.nColumn)
	print("tMEButtonGroup setColumn success")
end

-- function tMEButtonGroup:setLayoutType(szId, tParams)
-- 	print("tMEButtonGroup setLayoutType")
-- 	targets[szId]:setLayoutType(tParams.szType)
-- 	print("tMEButtonGroup setLayoutType success")
-- end

-- function tMEButtonGroup:setLayoutDirect(szId, tParams)
-- 	print("tMEButtonGroup setLayoutDirect")
-- 	targets[szId]:setLayoutDirect(tParams.szType)
-- 	print("tMEButtonGroup setLayoutDirect success")
-- end

function tMEButtonGroup:setHGap(szId, tParams)
	print("tMEButtonGroup setHGap")
	targets[szId]:setHGap(tParams.nGap)
	print("tMEButtonGroup setHGap success")
end

function tMEButtonGroup:setVGap(szId, tParams)
	print("tMEButtonGroup setVGap")
	targets[szId]:setVGap(tParams.nGap)
	print("tMEButtonGroup setVGap success")
end

function tMEButtonGroup:addGroupButton(szId, tParams)
	print("tMEButtonGroup addGroupButton")
	local groupBtn = TFGroupButton:create()
	groupBtn:setNormalTexture("test/groupbutton/com_btn3_n.png")
	groupBtn:setPressedTexture("test/groupbutton/com_btn3_p.png")
	groupBtn:setFontName("宋体")
	local index = tParams.nIndex or -1
	if tParams.szNormalTexture and tParams.szNormalTexture ~= "" then
		groupBtn:setNormalTexture(tParams.szNormalTexture)
	end
	if tParams.szPressTexture and  tParams.szPressTexture ~= "" then
		groupBtn:setPressedTexture(tParams.szPressTexture)
	end

	if tParams.szText then
		groupBtn:setText(tParams.szText)
	end
	if tParams.bRet ~= nil then
		groupBtn:setSelect(tParams.bRet)
	end
	targets[szId]:addGroupButton(groupBtn)
	targets[szId]:doLayout()
	print("tMEButtonGroup addGroupButton success")
end

function tMEButtonGroup:setGroupButtonNormalTexture(szId, tParams)
	print("tMEButtonGroup setGroupButtonNormalTexture")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			if tParams.szNormalTexture == "" then
				tParams.szNormalTexture = "test/groupbutton/com_btn3_n.png"
			end
			pBtn:setNormalTexture(tParams.szNormalTexture)
			targets[szId]:doLayout()
			print("tMEButtonGroup setGroupButtonNormalTexture success")
		end
	end
end

function tMEButtonGroup:setGroupButtonPressTexture(szId, tParams)
	print("tMEButtonGroup setGroupButtonPressTexture")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			if tParams.szText == "" then
				tParams.szText = "test/groupbutton/com_btn3_p.png"
			end
			pBtn:setPressedTexture(tParams.szText)
			targets[szId]:doLayout()
			print("tMEButtonGroup setGroupButtonPressTexture success")
		end
	end
end

function tMEButtonGroup:changeGroupButtonIndex(szId, tParams)
	print("tMEButtonGroup changeGroupButtonIndex")
	targets[szId]:changeGroupButtonIndex(tParams.nTargetIndex, tParams.nIndex)
	print("tMEButtonGroup changeGroupButtonIndex success")
end

function tMEButtonGroup:setSelect(szId, tParams)
	print("tMEButtonGroup setSelect")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setSelect(tParams.bRet)
			targets[szId]:doLayout()
			print("tMEButtonGroup setSelect success")
		end
	end
end

function tMEButtonGroup:removeButton(szId, tParams)
	print("tMEButtonGroup removeButton")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			targets[szId]:removeChild(pBtn, true)
			targets[szId]:doLayout()
		end
	end
end

function tMEButtonGroup:setButtonText(szId, tParams)
	print("tMEButtonGroup setButtonText")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setText(tParams.szText)
			print("tMEButtonGroup setButtonText success")
		end
	end
end

-- group button
function tMEButtonGroup:setButtonScale9Enabled(szId, tParams)
	print("setButtonScale9Enabled")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setScale9Enabled(tParams.bRet)
			print("setButtonScale9Enabled setButtonText success")
		end
	end
end

function tMEButtonGroup:setButtonCapInset(szId, tParams)
	print("setButtonCapInset")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setCapInsets(CCRectMake(tParams.nX, tParams.nY, tParams.nWidth, tParams.nHeight))
			print("setButtonCapInset setButtonText success")
		end
	end
end

function tMEButtonGroup:setButtonFontSize(szId, tParams)
	print("setButtonFontSize")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setFontSize(tParams.nSize)
			print("setButtonFontSize setButtonText success")
		end
	end
end

function tMEButtonGroup:setButtonFontColor(szId, tParams)
	print("setButtonFontColor")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setNormalColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
			print("setButtonFontColor setButtonText success")
		end
	end
	targets[szId]:doLayout()
end

function tMEButtonGroup:setButtonFontName(szId, tParams)
	print("setButtonFontName")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setFontName(tParams.szFontName)
			print("setButtonFontName setButtonText success")
		end
	end
	targets[szId]:doLayout()
end

function tMEButtonGroup:setButtonSize(szId, tParams)
	print("setButtonSize")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
			print("setButtonSize success")
		end
	end
	targets[szId]:doLayout()
end

function tMEButtonGroup:setButtonSelectedColor(szId, tParams)
	print("setButtonSelectedColor")
	local index = tParams.nIndex
	if index then
		local pBtn = targets[szId]:getGroupButtonByIndex(index)
		if pBtn then
			pBtn:setSelectedColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
			print("setButtonSelectedColor success")
		end
	end
	targets[szId]:doLayout()
end


---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------
-- setUp layout priority (horizontal or vertical)
function tMEButtonGroup:setLayoutType(szId, tParams)
	print("setLayoutType")
	-- for old version
	if tParams.szType ~= nil then
		targets[szId]:setLayoutType(tParams.szType)
	elseif tParams.nType ~= nil then
		-- for new version
		if tParams.nType+0 == 0 then
			targets[szId]:setLayoutType("horizontal")
		elseif tParams.nType+0 == 1 then
			targets[szId]:setLayoutType("vertical")
		end
	end
	print("setLayoutType success", targets[szId]:getLayoutType())
	targets[szId]:doLayout()
end

--setUp layout begin point
function tMEButtonGroup:setLayoutDirect(szId, tParams)
	print("tMEButtonGroup setLayoutDirect")
	if type(tParams.szType) == 'number' then
		if tParams.szType == 0 then
			tParams.szType = "left_top"
		elseif tParams.szType == 1 then
			tParams.szType = "right_top"
		elseif tParams.szType == 2 then
			tParams.szType = "left_bottom"
		elseif tParams.szType == 3 then
			tParams.szType = "right_bottom"
		end
	end
	targets[szId]:setLayoutDirect(tParams.szType)
	print("tMEButtonGroup setLayoutDirect success")
end

function tMEButtonGroup:setLayoutGap(szId, tParams)
	print("setLayoutGap")
	targets[szId]:setHGap(tParams.nX)
	targets[szId]:setVGap(tParams.nY)
	print("setLayoutGap success")
	targets[szId]:doLayout()
end

-- spacing

return tMEButtonGroup