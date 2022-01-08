tTouchEventManager = {}
local szSelectedID = nil

local objMoveCreateParent = nil
local nCreatePos = ccp(0, 0)
local startPos_SpaceDown
tTouchEventManager.bIsCreate = false

function tTouchEventManager:registerEvents(target)
	target:addMEListener(TFWIDGET_CLICK, tTouchEventManager.onTouchClick)
end

function tTouchEventManager:lostFocus()
	tTouchEventManager.bIsCreate = false
	if objMoveCreateParent ~= nil then
		if objMoveCreateParent._shader then
			objMoveCreateParent:setShaderProgram(objMoveCreateParent._shader)
		end
		objMoveCreateParent._shader = nil
	end
end

function tTouchEventManager:onTouchClick( ... )
	local szRes = ""
	if self:getDescription() == "TFCheckBox" and self.getSelectedState then
		local nSelect = 0
		if self:getSelectedState()  then
			nSelect = 1
		end
		szRes = string.format("ID=%s;bIsCheckBoxSelected=%d|", self.szId, nSelect)
	end
	if self.getPercent then
		szRes = string.format("ID=%s;nPercent=%d|", self.szId, self:getPercent())
	end
	-- if self:getDescription() == "TFSlider" then
	-- 	szRes = string.format("ID=%s;nPercent=%d|", self.szId, self:getPercent())
	-- end
	if self:getDescription() == "TFGroupButton" then
		local szParentID = self.szParentID
		local szId = self.szId
		for v in targets[szParentID].children:iterator() do
			if targets[szId]:getDescription() == "TFGroupButton" and v ~= szId then
				szRes = szRes .. string.format("ID=%s;bIsGroupButtonSelected=false|", v)
			end
		end
	end
	setCmdGetString(szRes)
end

-- scale touch begin
function tTouchEventManager:touchBegan_TargetCornerToScale(target, seekPos)
	self.objPos = self:getPosition()
	self.objCurPos = self:getPosition()
	for v in tSelectedIDs:iterator() do
		targets[v]._scaleX = targets[v]:getScaleX()
		targets[v]._scaleY = targets[v]:getScaleY()
		if targets[v]._scaleX == 0 then targets[v]._scaleX = 0.01 end
		if targets[v]._scaleY == 0 then targets[v]._scaleY = 0.01 end
	end
end

-- scale touch move
function tTouchEventManager:touchMove_TargetCornerToScale(target, seekPos)
	local tag =  self:getTag()
	local scaleX, scaleY
	local objPos = self.objPos
	local objCurPos = ccpAdd(self.objCurPos, seekPos)
	local bScaleX, bScaleY = true, true

	if math.abs(objPos.x) < 0.01 then bScaleX = false end
	if math.abs(objPos.y) < 0.01 then bScaleY = false end

	scaleX = objCurPos.x / objPos.x
	scaleY = objCurPos.y / objPos.y
	local szRes = ""
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and not (targets[targets[v].szParentID]:getDescription() == "TFPageView") and tLockTargets:indexOf(v) == -1 then
			local tempX, tempY = targets[v]._scaleX * scaleX, targets[v]._scaleY * scaleY
			if tempX < -100 or tempX > 100 then
				if tempX > 100 then tempX = 100 end
				if tempX < -100 then tempX = -100 end
			end
			if tempY < -100 or tempY > 100 then
				if tempY > 100 then tempY = 100 end
				if tempY < -100 then tempY = -100 end
			end
			if bScaleX then targets[v]:setScaleX(tempX) end
			if bScaleY then targets[v]:setScaleY(tempY) end
			if EditorKeyManager.bShiftDown then
				targets[v]:setScale(math.min(tempX, tempY))
			end
		end
	end

	tSelectedRectManager:updateSelectedRect()

	self.objCurPos = objCurPos
end

-- scale touch end
function tTouchEventManager:touchEnd_TargetCornerToScale(target, seekPos)
	local szRes = ""
	local scaleX, scaleY
	for v in tSelectedIDs:iterator() do
		scaleX, scaleY = targets[v]:getScaleX(), targets[v]:getScaleY()
		-- print("scale:", scaleX, scaleY)
		if EditLua._UIActionModel and targets[v]._actionBaseAttribute then
			-- print("base===================================", targets[v]._actionBaseAttribute.scaleX, targets[v]._actionBaseAttribute.scaleY)
			scaleX = scaleX / targets[v]._actionBaseAttribute.scaleX
			scaleY = scaleY / targets[v]._actionBaseAttribute.scaleY
		end
		if not tTouchEventManager:checkIsParentInSelected(v) and not (targets[targets[v].szParentID]:getDescription() == "TFPageView") and tLockTargets:indexOf(v) == -1 then
			szRes = szRes .. string.format("ID=%s;bIsSelected=true,nScaleX=%.1f,nScaleY=%.1f|", v, scaleX, scaleY)
			TFFunction.call(targets[v]:getParent().doLayout, targets[v]:getParent())
		end
	end
	setCmdGetString(szRes)
	tSelectedRectManager:updateSelectedRect()
end

-------------------------------------create function--------------------------------------

-- use by author
function tTouchEventManager:setMoveCreate(target, tParams)
	if objMoveCreateParent ~= nil then
		if tParams.szParent ~= objMoveCreateParent.szId then
			-- reset in tLuaDataManager:addObjLuaData
			-- tTouchEventManager.bIsCreate  = false
			return tParams
		end
		tParams.szParent = objMoveCreateParent.szId
		target:setPosition(objMoveCreateParent:convertToNodeSpaceAR(nCreatePos))
		if objMoveCreateParent.getInnerContainer then
			target:setPosition(objMoveCreateParent:getInnerContainer():convertToNodeSpaceAR(nCreatePos))
		end
		objMoveCreateParent = nil
	elseif nCreatePos then
		if targets[tParams.szParent] then
			target:setPosition(targets[tParams.szParent]:convertToNodeSpaceAR(nCreatePos))
		else
			target:setPosition(targets["root"]:convertToNodeSpaceAR(nCreatePos))
		end
	end
	nCreatePos = ccp(0, 0)
	return tParams
end
-- use by author end

-- create move call by WPF begin
local function canAddChild(szId)
	local objType = targets[szId]:getDescription()
	if objType == "TFArmature" or objType == "TFMovieClip" or objType == "TFBigMap" or objType == "TFRichText" or
		objType == "TFParticle" or objType == "TFPageView" then
		return false
	end
	return true
end

function EditLua:createWidgetTouchMoved(szId, tParams)
	print("createWidgetTouchMoved")
	if tParams and tParams.nX ~= nil then
		local movePos = ccp(tParams.nX, tParams.nY)
		local _szSelectedID = tTouchEventManager:checkTouchEvent("root", movePos)
		if _szSelectedID ~= nil and not canAddChild(_szSelectedID) then
			_szSelectedID = nil
		end
		if _szSelectedID ==  nil then _szSelectedID = szCurRootPanelID end

		if objMoveCreateParent ~= nil then
			if objMoveCreateParent._shader then
				objMoveCreateParent:setShaderProgram(objMoveCreateParent._shader)
				objMoveCreateParent._shader = nil
			end
			tSelectedRectManager:updateSelectedID(nil)
		end
		if _szSelectedID ~= nil and targets[_szSelectedID] then
			objMoveCreateParent = targets[_szSelectedID]
			objMoveCreateParent._shader = objMoveCreateParent:getShaderProgram()
			objMoveCreateParent:setShaderProgram("HighLight")
			tSelectedRectManager:updateSelectedID(objMoveCreateParent.szId)
		end

		szGlobleResult = string.format("ID=%s", _szSelectedID)
		setGlobleString(szGlobleResult)
		-- local szRes = string.format("ID=%s;bIsSelected=true|", _szSelectedID)
		-- setCmdGetString(szRes)

		nCreatePos = ccp(tParams.nX, tParams.nY)
	end
	print("createWidgetTouchMoved success")
end

function EditLua:createWidgetTouchEnded(szId, tParams)
	print("createWidgetTouchEnded")
	if tParams and tParams.nX ~= nil then
		if objMoveCreateParent ~= nil then
			if objMoveCreateParent._shader then
				objMoveCreateParent:setShaderProgram(objMoveCreateParent._shader)
			end
			objMoveCreateParent._shader = nil
		end
		tTouchEventManager.bIsCreate = true
		print("createWidgetTouchEnded success:")
	end
end
-- create move call by WPF end

function tTouchEventManager:checkIsParentInSelected(szId)
	local obj = targets[szId]
	while true do
		if obj.szParentID == "root" then
			return false
		end
		if tSelectedIDs:indexOf(obj.szParentID) ~= -1 then
			return true
		end
		obj = targets[obj.szParentID]
	end
end

function tTouchEventManager:checkTouchEvent(rootID, touchPoint)
	local root = targets[rootID]
	if not root or not root:isVisible() then return end
	if root.children then
	local length = root.children:length()
		for i = length, 1, -1 do
			local szTouchID = tTouchEventManager:checkTouchEvent(root.children:objectAt(i), touchPoint)
			if szTouchID then
				return szTouchID
			end
		end
	end
	if root:isEnabled() and root:hitTest(touchPoint) and root.szId ~= "root" and tLockTargets:indexOf(root.szId) == -1 then
		return root.szId
	end
end

function EditLua:rightButtonDown(szId, tParams)
	print("rightButtonDown")
	if tParams and tParams.nX ~= nil and targets["touchPanel"]:isTouchEnabled() then
		local touchPos = ccp(tParams.nX, tParams.nY)
		local bTouchInTargets = false
		for v in tSelectedIDs:iterator() do
			local root = targets[v]
			if root:isEnabled() and root and root:hitTest(touchPos) and tLockTargets:indexOf(root.szId) == -1 then
				bTouchInTargets = true
				break
			end
		end
		if not bTouchInTargets then
			local szRightButtonSelectedID = tTouchEventManager:checkTouchEvent("root", touchPos)
			if szRightButtonSelectedID ==  nil then szRightButtonSelectedID = szCurRootPanelID end

			if targets[szRightButtonSelectedID] then
				tSelectedRectManager:updateSelectedID(szRightButtonSelectedID)
			end

			-- local szRes = string.format("ID=%s;bIsSelected=true", szRightButtonSelectedID)
			-- setCmdGetString(szRes)
			szGlobleResult = string.format("ID=%s", szRightButtonSelectedID)
			setGlobleString(szGlobleResult)
		end
		tTouchEventManager.bIsCreate = true
		nCreatePos = touchPos
		objMoveCreateParent = targets[szRightButtonSelectedID]
	end
	print("rightButtonDown success")
end

------------------------------------------------- Touch panel -------------------------------------------------
function tTouchEventManager:onTouchPanelBegan( ... )
	if EditorKeyManager.bSpaceDown then
		tTouchEventManager:onTouchPanelBegan_SpaceDown(self:getTouchStartPos())
		return
	end
	if tCurState ~= EditLua then
		tSelectedRectManager:setSelectedRectVisible(nil, false)
		return
	end
	tTouchEventManager.bIsCreate = false
	self.startPos = self:getTouchStartPos()
	EditLua.bTouchInTargets = false
	for v in tSelectedIDs:iterator() do
		local root = targets[v]
		if root:isVisible() and root:isEnabled() and root:hitTest(self.startPos) and tLockTargets:indexOf(root.szId) == -1 then
			EditLua.bTouchInTargets = true
			szSelectedID = v
			if TFDirector.bCTRLDown then
				tSelectedRectManager:updateSelectedID(szSelectedID)
				print("bCTRLDown")
			end
			break
		end
	end
	if not EditLua.bTouchInTargets then
		szSelectedID = tTouchEventManager:checkTouchEvent("root", self.startPos)
		if szSelectedID ~= nil and not targets[szSelectedID]._bIsRoot then
			EditLua.bTouchInTargets = true
			tSelectedRectManager:updateSelectedID(szSelectedID)
		end
	end
	if not EditLua.bTouchInTargets then
		tSelectedRectManager:setSelectedRectVisible(nil, false)
		targets["root"].objMultiSelectRect:setVisible(true)
		targets["root"].objMultiSelectRect:addRect(self.startPos, self.startPos, ccc4f(1, 1, 1, 0), ccc4f(1 , 1 , 1 , 1.0), 0.5)
		targets["root"].objMultiSelectRect.startPos = self.startPos
		targets["root"].objMultiSelectRect.endPos = self.startPos
	end
	self.bIsMoved = false
end

function tTouchEventManager:onTouchPanelMoved(pos, seekPos)
	if self.startPos == nil then return end 	-- for defence; changeModel from map model may be errors

	if EditorKeyManager.bSpaceDown then
		tTouchEventManager:onTouchPanelMoved_SpaceDown(self:getTouchMovePos())
		return
	end

	local endPos = self:getTouchMovePos()
	startPos_SpaceDown = endPos
	if not EditLua.bTouchInTargets then
		targets["root"].objMultiSelectRect:clear()
		targets["root"].objMultiSelectRect:addRect(self.startPos, endPos, ccc4f(1, 1, 1, 0), ccc4f(1 , 1 , 1 , 1.0), 0.5)
		targets["root"].objMultiSelectRect.startPos = self.startPos
		targets["root"].objMultiSelectRect.endPos = endPos
	else
		for v in tSelectedIDs:iterator() do
			if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"
					and ( not EditorUtils:TargetIsContainer(targets[v]:getParent()) or 
						EditorUtils:TargetIsContainer(targets[v]:getParent()) and not EditorUtils:TargetIsGridLayout(targets[v]:getParent()) )then
				local touchObj = targets[v]
				local posType = touchObj:getPositionType()
				local curPos = touchObj:getPosition()
				local rotation = touchObj:getRotation()
				touchObj:setRotation(0)
				touchObj:setPositionType(0)

				local nStartPos = self:convertToWorldSpace(self.startPos)
				local nEndPos = self:convertToWorldSpace(endPos)
				nStartPos, nEndPos = touchObj:convertToNodeSpace(nStartPos), touchObj:convertToNodeSpace(nEndPos)
				local nSeekPos = ccpSub(nEndPos, nStartPos)
				nSeekPos.x = nSeekPos.x * touchObj:getScaleX()
				nSeekPos.y = nSeekPos.y * touchObj:getScaleY()

				touchObj:setPosition(ccpAdd(curPos, nSeekPos))
				if not EditorUtils:TargetIsRelativeLayout(touchObj:getParent()) then
					-- EditLua:setNewMargin(touchObj, nSeekPos)
				end
				if targets[touchObj.szParentID].doLayout then
					targets[touchObj.szParentID]:doLayout()
				end

				touchObj:setRotation(rotation)
				if posType ~= 0 then
					touchObj:setPositionType(posType)
				end
			end
		end
		tSelectedRectManager:updateSelectedRect()
		-- EditLua:testMaxSelectedRect()
		self.startPos = endPos
		self.bIsMoved = true
	end
end

function tTouchEventManager:onTouchPanelEnded( ... )
	if EditorKeyManager.bSpaceDown then
		tTouchEventManager:onTouchPanelEnded_SpaceDown(self:getTouchEndPos())
		return
	end
	local endPos = self:getTouchEndPos()
	if not self.bIsMoved and szSelectedID ~= nil and szSelectedID ~= "" and not TFDirector.bCTRLDown and tSelectedIDs:length() > 1 then
		tSelectedRectManager:setSelectedRectVisible(nil, false)
		tSelectedRectManager:updateSelectedID(szSelectedID)
	end
	local function setReturnMsg()
		local szRes = ""
		local msg = ""
		local index = 0
		for v in tSelectedIDs:iterator() do
			local touchObj = targets[v]
			if touchObj ~= nil and touchObj:isEnabled() and touchObj:getPosition().x then
				szRes = szRes .. string.format("ID=%s;bIsSelected=true,", touchObj.szId or "root", touchObj:getPosition().x, touchObj:getPosition().y)
				msg = EditLua:getTargetMarginOrPosition_CmdGet(v)
				msg = msg[string.format("%d:-1", string.find(msg, ";") + 1)]
				szRes = szRes .. msg
			end
		end
		if tSelectedIDs:length() == 0 then
			szRes = string.format("ID=%s;|", "")
		end
		return szRes
	end
	local function checkLegalSelectTarget(szId)
		if targets[szId] then
			for i in targets[szId].children:iterator() do
				if targets[i].szId and i ~= "root" and targets[i]:isVisible() and targets[i]:isEnabled() and tLockTargets:indexOf(i) == -1 then 
					tSelectedIDs:push(i)
					checkLegalSelectTarget(i)
				end
			end
		end
	end
	if tSelectedIDs:length() == 0 and targets["root"].objMultiSelectRect:isVisible() then
		local startPos, endPos = targets["root"].objMultiSelectRect.startPos, targets["root"].objMultiSelectRect.endPos
		if startPos ~= endPos then
			local testRect = CCRect(math.min(startPos.x, endPos.x), math.min(startPos.y, endPos.y), math.abs(endPos.x - startPos.x), math.abs(endPos.y - startPos.y))
			checkLegalSelectTarget(szCurRootPanelID)
			tSelectedRectManager:updateSelectedRect()	-- update selected pos
			-- getMeRect() didn't represent touch rect
			local tRemoveObject = TFArray:new()
			for v in tSelectedIDs:iterator() do
				if not targets[v].rect:intersectsRect(testRect) then
					tSelectedRectManager:setSelectedRectVisible(v, false)
					tRemoveObject:push(v)
				end
			end
			for v in tRemoveObject:iterator() do
				tSelectedIDs:removeObject(v)
			end
			tSelectedRectManager:updateSelectedRect()	-- update selected pos

			targets["root"].objMultiSelectRect:setVisible(false)
			targets["root"].objMultiSelectRect:clear()
			targets["root"].objMultiSelectRect.startPos, targets["root"].objMultiSelectRect.endPos = ccp(0, 0), ccp(0, 0)
		end
	end
	setCmdGetString(setReturnMsg())
end


-- touch when spaceDowned: move the whole scene
function tTouchEventManager:onTouchPanelBegan_SpaceDown(pos)
	startPos_SpaceDown = pos
end

function tTouchEventManager:onTouchPanelMoved_SpaceDown(pos)
	targets["root"].objMultiSelectRect:clear()
	tSelectedRectManager:setSelectedRectVisible(nil, false)
	
	local endPos = pos
	if startPos_SpaceDown == nil then startPos_SpaceDown = endPos end
	local tEndPos = targets["root"]:convertToNodeSpace(endPos)
	local tStartPos = targets["root"]:convertToNodeSpace(startPos_SpaceDown)

	local curPos = targets["root"]:getPosition()
	local rotation = targets["root"]:getRotation()
	targets["root"]:setRotation(0)
	local nSeekPos = ccpSub(tEndPos, tStartPos)
	nSeekPos.x = nSeekPos.x * targets["root"]:getScaleX()
	nSeekPos.y = nSeekPos.y * targets["root"]:getScaleY()

	targets["root"]:setPosition(ccpAdd(curPos, nSeekPos))
	targets["root"]:setRotation(rotation)

	startPos_SpaceDown = endPos
end

function tTouchEventManager:onTouchPanelEnded_SpaceDown(pos)
	local szRes = string.format("originX = %d, originY = %d", targets["root"]:convertToWorldSpace(ccp(0, 0)).x, targets["root"]:convertToWorldSpace(ccp(0, 0)).y)
	setCmdGetString(szRes)
end

return tTouchEventManager