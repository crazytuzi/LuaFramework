EditorKeyManager = {}
EditorKeyManager.nNormalStep = 1
EditorKeyManager.nCtrlStep = 10

function EditLua:setKeyMoveStep(szId, tParams)
	print("setKeyMoveStep")
	EditorKeyManager.nNormalStep = tParams.nNormalStep
	EditorKeyManager.nCtrlStep = tParams.nCtrlStep
	print("setKeyMoveStep success, normal, ctrl:", EditorKeyManager.nNormalStep, EditorKeyManager.nCtrlStep)
end

function EditorKeyManager:registerKeyLostFocus()
	TFDirector:registerKeyUp(8, {nGap = 10}, function() -- 'esc'
		EditorKeyManager.bSpaceDown = false
		-- TFDirector.bCTRLDown = false
		EditorKeyManager.bShiftDown = false
		tTouchEventManager:lostFocus()
		print("==================== lost focus")
	end)
end

local function movePos(pos)
	if not targets["touchPanel"]:isTouchEnabled() then
		print("---------------------------------------------------- now is not in designed model !!!!!!!!!!!!!")
		return
	end
	local szRes = ""
	for v in tSelectedIDs:iterator() do
		local touchObj = targets[v]
		local parent = targets[touchObj.szParentID]
		if ( EditorUtils:TargetIsContainer(parent) and (EditorUtils:TargetIsAbsoluteLayout(parent) or EditorUtils:TargetIsRelativeLayout(parent)) ) or not EditorUtils:TargetIsContainer(parent) then
			if touchObj and not tTouchEventManager:checkIsParentInSelected(v) then
				local oldType = touchObj:getPositionType()
				touchObj:setPositionType(0)
				touchObj:setPosition(ccpAdd(touchObj:getPosition(), pos))
				if oldType ~= 0 then
					touchObj:setPositionType(oldType)
				end
				-- todo remove this doLayout
				if EditorUtils:TargetIsContainer(parent) and parent.doLayout then
					parent:doLayout()
				end
				szRes = szRes .. EditLua:getTargetMarginOrPosition_CmdGet(v)
			end
		end
	end
	tSelectedRectManager:updateSelectedRect()
	setCmdGetString(szRes)
end

function EditorKeyManager:registerKeyLeft()
	TFDirector:registerKeyDown(37, {nGap = 10}, function() -- 'left'
		if TFDirector.bCTRLDown then
			seek = EditorKeyManager.nCtrlStep
		else
			seek = EditorKeyManager.nNormalStep
		end
		movePos(ccp(-seek, 0))
	end)
end

function EditorKeyManager:registerKeyUp()
	TFDirector:registerKeyDown(38, {nGap = 10}, function() -- 'up'
		if TFDirector.bCTRLDown then
			seek = EditorKeyManager.nCtrlStep
		else
			seek = EditorKeyManager.nNormalStep
		end
		movePos(ccp(0, seek))
	end)
end

function EditorKeyManager:registerKeyRight()
	TFDirector:registerKeyDown(39, {nGap = 10}, function() -- 'right'
		if TFDirector.bCTRLDown then
			seek = EditorKeyManager.nCtrlStep
		else
			seek = EditorKeyManager.nNormalStep
		end
		movePos(ccp(seek, 0))
	end)
end

function EditorKeyManager:registerKeyDown()
	TFDirector:registerKeyDown(40, {nGap = 10}, function() -- 'down'
		if TFDirector.bCTRLDown then
			seek = EditorKeyManager.nCtrlStep
		else
			seek = EditorKeyManager.nNormalStep
		end
		movePos(ccp(0, -seek))
	end)
end

function EditorKeyManager:registerKeySpace()
	TFDirector:registerKeyDown(32, {nGap = 10}, function() -- 'space'
		EditorKeyManager.bSpaceDown = true
	end)
	TFDirector:registerKeyUp(32, {nGap = 10}, function() -- 'space'
		EditorKeyManager.bSpaceDown = false
	end)
end

function EditorKeyManager:registerKeyShift()
	TFDirector:registerKeyDown(16, {nGap = 10}, function() -- 'shift'
		EditorKeyManager.bShiftDown = true
	end)
	TFDirector:registerKeyUp(16, {nGap = 10}, function() -- 'shift'
		EditorKeyManager.bShiftDown = false
	end)
end

function EditorKeyManager:registerKeyBoardEvent()
	self:registerKeyLostFocus()

	self:registerKeyLeft()
	self:registerKeyUp()
	self:registerKeyRight()
	self:registerKeyDown()

	self:registerKeySpace()
	self:registerKeyShift()
end

return EditorKeyManager