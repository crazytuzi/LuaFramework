tSelectedRectManager = {}

local objSelectedColor = ccc3(100, 149, 237)
	
function tSelectedRectManager:setSelectedRectVisible(szId, bRet)
	if szId == nil or szId == "" then
		for v in tSelectedIDs:iterator() do
			targets[v].rect:setVisible(false)
			if targets[v] and targets[v]:getDescription() == "TFScrollView" then
				targets[v].scrollRect:setVisible(bRet)
			end
			targets[v]:showHitRange(false)
		end
		tSelectedIDs:clear()
		return
	end
	targets[szId].rect:setVisible(bRet)
	if targets[szId] and targets[szId]:getDescription() == "TFScrollView" then
		targets[szId].scrollRect:setVisible(bRet)
	end
	targets[szId]:showHitRange(bRet)
end

function tSelectedRectManager:updateSelectedID(szId)
	if not TFDirector.bCTRLDown and tSelectedIDs:indexOf(szId) == -1 then
		tSelectedRectManager:setSelectedRectVisible(nil, false)
		-- tSelectedIDs:clear()
	end
	if targets[szId] then
		if  tSelectedIDs:indexOf(szId) == -1 then
			tSelectedIDs:push(szId)
		elseif tSelectedIDs:length() > 1 then
			tSelectedIDs:removeObject(szId)
			tSelectedRectManager:setSelectedRectVisible(szId, false)
		end
	end
	tSelectedRectManager:updateSelectedRect()
end

function tSelectedRectManager:updateSelectedRect()
	local extendSize = 3;
	local function setNormalRectRect(v)
		if targets[v] then
			local size, flag
			size = targets[v]:getSize()
			local objAnchorPoint = targets[v]:getAnchorPoint()
			local pos = targets[v]:getPosition()
			targets[v].rect:setVisible(targets[v]:isVisible())
			targets[v].rect:setColor(objSelectedColor)
			if targets[v]:isIgnoreAnchorPointForPosition() then
				pos = targets[v]:convertToWorldSpace(ccp(0, 0))
			else
				pos = targets[v]:convertToWorldSpaceAR(ccp(0, 0))
			end
			pos = ccpAdd(pos, ccp((objAnchorPoint.x-0.5) * extendSize, (objAnchorPoint.y-0.5) * extendSize))
			targets[v].rect:setPosition(targets["UILayer"]:convertToNodeSpace(pos))
			local nScaleX, nScaleY, nRotate = targets[v]:getScaleX(), targets[v]:getScaleY(), targets[v]:getRotation()
			local obj = targets[targets[v].szParentID]
			while true do
				nScaleX = nScaleX * obj:getScaleX()
				nScaleY = nScaleY * obj:getScaleY()
				nRotate = nRotate + obj:getRotation()
				if obj.szId == "root" then
					break
				end
				obj = targets[obj.szParentID]
			end
			local width = size.width*nScaleX + extendSize
			local height = size.height*nScaleY + extendSize
			targets[v].rect:setScaleX(1)
			targets[v].rect:setScaleY(1)
			if width < 0 then targets[v].rect:setScaleX(-1); width = width * -1 end
			if height < 0 then targets[v].rect:setScaleY(-1); height = height * -1 end
			targets[v].rect:setSize(CCSize(width, height))
			targets[v].rect:setAnchorPoint(objAnchorPoint)
			targets[v].rect:setRotation(nRotate)
			local anchorImg = targets[v].rect:getChildByTag(10)	-- nAnchorImgTag
			anchorImg:setScaleX(targets["root"]:getScaleX())
			anchorImg:setScaleY(targets["root"]:getScaleY())
			anchorImg:setPosition(ccpSub(ccp(0, 0), ccp((objAnchorPoint.x-0.5) * extendSize, (objAnchorPoint.y-0.5) * extendSize)))

			targets[v].rect.setFourCorner(targets[v].rect)
		else
			targets[v].rect:setVisible(false)
		end
	end
	local function setScrollRect(v)
		if targets[v] and targets[v].scrollRect and targets[v].getInnerContainerSize and targets[v].rect:isVisible() then
			targets[v].scrollRect:setVisible(true)
			local size = targets[v]:getInnerContainerSize()
			local objAnchorPoint = targets[v]:getAnchorPoint()
			local pos = targets[v]:getInnerContainer():convertToWorldSpaceAR(ccp(0, 0))
			-- pos = ccpAdd(pos, ccp((objAnchorPoint.x-0.5) * extendSize, (objAnchorPoint.y-0.5) * extendSize))
			targets[v].scrollRect:setPosition(targets["UILayer"]:convertToNodeSpace(pos))
			local nScaleX, nScaleY, nRotate = targets[v]:getScaleX(), targets[v]:getScaleY(), targets[v]:getRotation()
			local obj = targets[targets[v].szParentID]
			while true do
				nScaleX = nScaleX * obj:getScaleX()
				nScaleY = nScaleY * obj:getScaleY()
				nRotate = nRotate + obj:getRotation()
				if obj.szId == "root" then
					break
				end
				obj = targets[obj.szParentID]
			end
			width = size.width*nScaleX + extendSize
			height = size.height*nScaleY + extendSize
			targets[v].scrollRect:setSize(CCSize(width, height))
			targets[v].scrollRect:setAnchorPoint(targets[v]:getInnerContainer():getAnchorPoint())
			targets[v].scrollRect:setRotation(nRotate)
		elseif targets[v].scrollRect then
			targets[v].scrollRect:setVisible(false)
		end
	end
	-- set selected attribute
	for v in tSelectedIDs:iterator() do
		setNormalRectRect(v)
		setScrollRect(v)
		targets[v]:showHitRange(true)
	end
end

function EditLua:isControlSelect(szId, tParams)
	print("isControlSelect:",szId)
	-- do return end
	if tParams.bSelected ~= nil and targets[szId] ~= nil then
		if not tParams.bIsMutilSelected then
			tSelectedRectManager:setSelectedRectVisible(nil, false)
		end
		if tSelectedIDs:indexOf(szId) == -1 then
			tSelectedIDs:push(szId)
		end
		tSelectedRectManager:setSelectedRectVisible(szId, tParams.bSelected)
		print("setControlSelect success", tParams.bSelected)
	end
end

function EditLua:cancelAllSelected()
	print("cancelAllSelected")
	tSelectedRectManager:updateSelectedID(nil)
	print("cancelAllSelected success")
end

function EditLua:setSelectedColor(szId, tParams)
	for v in tSelectedIDs:iterator() do
		targets[v].rect:setColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
	end
	objSelectedColor = ccc3(tParams.nR, tParams.nG, tParams.nB)
end

return tSelectedRectManager