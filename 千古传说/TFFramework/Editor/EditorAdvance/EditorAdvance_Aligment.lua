-- aligment for absolute layout only
local function setReturnMsg()
	for v in tSelectedIDs:iterator() do
		local touchObj = targets[v]
		if touchObj ~= nil and touchObj:isEnabled() and touchObj:getPosition().x then
			tRetureMsgTarget:push(v)
			tRetureMsgSelectedTarget:push(v)
			bIsNeedToSetCmdGet = true
		end
	end
end

function EditVirtualBase:alignTheLeft()
	print("alignTheLeft")
	if tSelectedIDs:length() <= 1 then return end
	local szRes = ""
	local nPosX = 0x7fffffff
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" and nPosX > targets[v]:getMeRect().origin.x then
			nPosX = targets[v]:getMeRect().origin.x
		end
	end
	local rect, nPos, targetPos
	for v in tSelectedIDs:iterator() do
		if math.abs(targets[v]:getMeRect().origin.x - nPosX) > 0.001 and not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" then
			rect = targets[v]:getMeRect()
			nPos = ccp(rect.origin.x, 0)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(nPosX, 0))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
			rect = targets[v]:getMeRect()
		end
	end
	setReturnMsg()
	print("alignTheLeft success")
end

function EditVirtualBase:alignTheRight()
	print("alignTheRight")
	if tSelectedIDs:length() <= 1 then return end
	local nPosX = 0x7fffffff * -1
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" and nPosX <  targets[v]:getMeRect().origin.x +  targets[v]:getMeRect().size.width then
			nPosX = targets[v]:getMeRect().origin.x +  targets[v]:getMeRect().size.width
		end
	end
	local rect, nPos, targetPos
	for v in tSelectedIDs:iterator() do
		if math.abs(targets[v]:getMeRect().origin.x +  targets[v]:getMeRect().size.width - nPosX) > 0.001 and not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" then
			rect = targets[v]:getMeRect()
			nPos = ccp(rect.origin.x + rect.size.width, 0)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(nPosX, 0))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
			rect = targets[v]:getMeRect()
		end
	end
	setReturnMsg()
	print("alignTheRight success")
end

function EditVirtualBase:alignTheTop()
	print("alignTheTop")
	if tSelectedIDs:length() <= 1 then return end
	local nPosY = 0x7fffffff * -1
	local posY
	for v in tSelectedIDs:iterator() do
		posY = targets[v]:getMeRect().origin.y +  targets[v]:getMeRect().size.height
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" and nPosY < posY then
			nPosY = posY
		end
	end
	local rect, nPos, targetPos
	for v in tSelectedIDs:iterator() do
		if math.abs(targets[v]:getMeRect().origin.y +  targets[v]:getMeRect().size.height - nPosY) > 0.001  and not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" then
			rect = targets[v]:getMeRect()
			nPos = ccp(0, rect.origin.y + rect.size.height)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(0, nPosY))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
			rect = targets[v]:getMeRect()
		end
	end
	setReturnMsg()
	print("alignTheTop success")
end

function EditVirtualBase:alignTheBottom()
	print("alignTheBottom")
	if tSelectedIDs:length() <= 1 then return end
	local nPosY = 0x7fffffff
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView" and nPosY > targets[v]:getMeRect().origin.y then
			nPosY = targets[v]:getMeRect().origin.y
		end
	end
	local rect, nPos, targetPos
	for v in tSelectedIDs:iterator() do
		if math.abs(targets[v]:getMeRect().origin.y - nPosY) > 0.001 and not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"  then
			rect = targets[v]:getMeRect()
			nPos = ccp(0, rect.origin.y)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(0, nPosY))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
			rect = targets[v]:getMeRect()
		end
	end
	setReturnMsg()
	print("alignTheBottom success")
end

function EditVirtualBase:alignTheHorizonCenter()
	print("alignTheHorizonCenter")
	if tSelectedIDs:length() <= 1 then return end
	local nMinPosX, nMaxPosX = 0x7fffffff, 0x7fffffff * -1
	local rect, pos, nPos
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"  then
			rect = targets[v]:getMeRect()
			pos = rect.origin.x
			if pos < nMinPosX then nMinPosX = pos end
			pos = rect.origin.x + rect.size.width
			if pos > nMaxPosX then nMaxPosX = pos end
		end
	end
	local posX = (nMaxPosX + nMinPosX)/2
	local targetPos
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"  then
			rect = targets[v]:getMeRect()
			nPos = ccp(rect.origin.x + rect.size.width/2, 0)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(posX, 0))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
		end
	end
	setReturnMsg()
	print("alignTheHorizonCenter success")
end

function EditVirtualBase:alignTheVerticalCenter()
	print("alignTheVerticalCenter")
	if tSelectedIDs:length() <= 1 then return end
	local nMinPosY, nMaxPosY = 0x7fffffff, 0x7fffffff * -1
	local rect, pos, nPos
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"  then
			rect = targets[v]:getMeRect()
			pos = rect.origin.y
			if pos < nMinPosY then nMinPosY = pos end
			pos = rect.origin.y + rect.size.height
			if pos > nMaxPosY then nMaxPosY = pos end
		end
	end
	-- do return end
	local posY = (nMaxPosY + nMinPosY)/2
	local targetPos
	for v in tSelectedIDs:iterator() do
		if not tTouchEventManager:checkIsParentInSelected(v) and targets[v]:getParent():getDescription() ~= "TFPageView"  then
			rect = targets[v]:getMeRect()
			nPos = ccp(0, rect.origin.y + rect.size.height/2)
			targetPos = targets[v]:getParent():convertToNodeSpaceAR(ccp(0, posY))
			nPos = targets[v]:getParent():convertToNodeSpaceAR(nPos)
			targetPos = ccpSub(targetPos, nPos)

			local oldType = targets[v]:getPositionType()
			targets[v]:setPositionType(0)
			targets[v]:setPosition(ccpAdd(targets[v]:getPosition(), targetPos))
			if oldType ~= 0 then
				targets[v]:setPositionType(oldType)
			end
			rect = targets[v]:getMeRect()
		end
	end
	setReturnMsg()
	print("alignTheVerticalCenter success")
end