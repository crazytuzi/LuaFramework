EditVirtualBase = {}
EditVirtualBase.__index = EditVirtualBase
function EditVirtualBase:setGridEnabled(szId, tParams)
	print('setGridEnabel')
	EditMapData:setGridEnabled(szId, tParams)
end

function EditVirtualBase:setDesignMode(szId, tParams)
	print("setDesignMode")
	if tParams.bRet ~= nil then
		targets["touchPanel"]:setTouchEnabled(tParams.bRet)
		print("setDesignMode success")
	end
end

function EditVirtualBase:setUIActionModel(szId, tParams)
	print("setUIActionModel")
	EditLua._UIActionModel = tParams.bEnable
	print("setUIActionModel success")
end

function EditVirtualBase:saveData(szId, tParams)
	EditMapData:saveData(szId, tParams)
end

function EditVirtualBase:removeChild(szParentID, szID, bNotToCleanLua)
	-- todo if child is other control
	if not bNotToCleanLua then
		tLuaDataManager:removeLuaData(szID, szParentID)
	end
	if targets[szParentID]:getDescription() == "TFPageView" then
		print("pageView removeChild")
		targets[szParentID]:removePage(targets[szID])
	-- elseif targets[szParentID]:getDescription() == "TFButtonGroup" and targets[szID]:getDescription() == "TFGroupButton" then
	-- 	targets[szParentID]:removeChild(targets[szID])
	else
		targets[szID]:removeFromParent(false)
	end
end

function EditVirtualBase:addChild(szParentID, szID)
	if targets[szParentID]:getDescription() == "TFPageView" and targets[szID]:getDescription() == "TFPanel" then
		print("pageView addChild")
		targets[szParentID]:addPage(targets[szID])
	elseif targets[szParentID]:getDescription() == "TFButtonGroup" and targets[szID]:getDescription() == "TFGroupButton" then
		targets[szParentID]:addGroupButton(targets[szID])
	else
		targets[szParentID]:addChild(targets[szID])
	end
end

function EditVirtualBase:removeFromParent(szId, tParams)
	print("removeFromParent",szId)
	if targets[szId] then
		local szParentID = targets[szId].szParentID
		local tChildren = TFArray:new()
		-- to avoid remove iterator items cause chaos of the loop of for...
		for v in targets[szId].children:iterator() do
			if targets[v] then
				tChildren:push(v)
			end
		end
		for v in tChildren:iterator() do
			if targets[v] then
				EditVirtualBase:removeFromParent(v, {})
			end
		end
		EditVirtualBase:removeChild(szParentID, szId)
		targets[szId] = nil

		if targets[szParentID]:getNodeType() == TFWIDGET_TYPE_CONTAINER then
			targets[szParentID]:doLayout()
		end
	end
	print("removeFromParent success")
end

function EditVirtualBase:removeAllChildren(szId, tParams)
	print("removeAllChildren")
	if szId == "" then
		if targets['root'].objGridLayer then
			EditMapData.dispose(nil)
		end
		targets["UILayer"]:removeAllChildren()
		targets = {}
		EditVirtualBase:cleanUpResource(nil, nil)
		EditLua:init()
	else
		EditVirtualBase:removeFromParent(szId, {})
	end
	print("removeAllChildren success")
end

function EditVirtualBase:cleanUpResource(szId, tParams)
	print("cleanUpResource")
	me.MCManager:clear()
	me.FrameCache:removeUnusedSpriteFrames()
	me.TextureCache:removeUnusedTextures()
	print("cleanUpResource success")
end

function EditVirtualBase:changeParent(szId, tParams)
	print("changeParent", szId, tParams.szParentId)
	if targets[szId] and targets[szId].szParentID ~= tParams.szParentId then
		local pos = targets[szId]:convertToWorldSpaceAR(ccp(0, 0))
		local szParentID = targets[szId].szParentID
		targets[szId]:retain()

		EditVirtualBase:removeChild(szParentID, szId, true)

		szParentID = tParams.szParentId
		if szParentID  and targets[szParentID] then
			targets[targets[szId].szParentID].children:removeObject(szId)
		else
			print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! What's the fucking parent !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			szParentID = "root"
		end
		EditVirtualBase:addChild(szParentID, szId)
		if targets[szParentID]:getDescription() ~= "TFPageView" then
			targets[szId]:setPosition(targets[szParentID]:convertToNodeSpaceAR(pos))
		end
		targets[szId].szParentID = szParentID
		targets[szParentID].children:push(szId)
		targets[szId]:release()

		tRetureMsgTarget:push(szId)
		bIsNeedToSetCmdGet = true

		print("changeParent success")
	end
end

local __lastDeltaX = 0
local __lastDeltaY = 0
function EditVirtualBase:moveAllWidgetBy(szId, tParams)
	print("moveAllWidgetBy")
	if tParams.nDeltX ~= nil and tParams.nDeltY ~= nil then

		local nDeltaSeekX =  tParams.nDeltX - __lastDeltaX
		local nDeltaSeekY =  tParams.nDeltY - __lastDeltaY
		
		__lastDeltaX = tParams.nDeltX
		__lastDeltaY = tParams.nDeltY

		tParams.nDeltX = -5000 * nDeltaSeekX + targets["root"]:getPosition().x
		tParams.nDeltY = -5000 * nDeltaSeekY + targets["root"]:getPosition().y

		targets["root"]:setPosition(ccp(tParams.nDeltX, tParams.nDeltY))
		if targets["root"].objGridLayer then
			targets["root"].objGridLayer:setPosition(targets["root"]:getPosition())
		end
		
		for v in tSelectedIDs:iterator() do
			targets[v].rect:setPosition(ccpAdd(targets[v].rect:getPosition(), ccp(-5000*nDeltaSeekX,-5000*nDeltaSeekY)))
			if targets[v].scrollRect then
				targets[v].scrollRect:setPosition(ccpAdd(targets[v].rect:getPosition(), ccp(-5000*nDeltaSeekX,-5000*nDeltaSeekY)))
			end
		end
		-- targets["root"].objMaxSelectRect:setPosition(ccpAdd(targets["root"].objMaxSelectRect:getPosition(), ccp(-5000*nDeltaSeekX,-5000*nDeltaSeekY)))

		if __lastDeltaX == __lastDeltaY and __lastDeltaX == 0 then
			EditVirtualBase:setDesignPanelPos("", {nWidth = 0, nHeight = 0})
		end
		print("moveAllWidgetBy success")
	end
end

function EditVirtualBase:setResourcePath(szId, tParams)
	print("setResourcePath")
	if tParams.szPathName ~= nil then
		if tParams.szPathName[#tParams.szPathName] ~= "/" then
			tParams.szPathName = tParams.szPathName .. "/"
		end
		TFFileUtil:addPathToSearchAtFront(tParams.szPathName)
		print(tParams.szPathName)
		print("setResourcePath success")
	end
end

-- use by author
function EditVirtualBase:setDesignPanelPos(szId, tParams)
	print("setDesignPanelPos")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil then
		local size = CCDirector:sharedDirector():getWinSize()
		local panelSize = targets["root"].bgSize
		local x, y = targets["root"]:getPosition().x, targets["root"]:getPosition().y
		targets["UILayer"]:setSize(size)
		targets["touchPanel"]:setSize(size)
		targets["root"].bgImg0:setSize(size)
		targets["root"]:setPosition(ccp((size.width-panelSize.width)/2, (size.height-panelSize.height)/2))

		local curScale = targets["root"]:getScale()
		local curPos = targets["root"]:getPosition()
		local nDeltX = (curScale-1)*panelSize.width/2
		local nDeltY = (curScale-1)*panelSize.height/2
		targets["root"]:setPosition( ccpSub(curPos, ccp(nDeltX, nDeltY)) )

		targets["root"]:setPosition( ccpAdd(targets["root"]:getPosition(), ccp(-5000*__lastDeltaX, -5000*__lastDeltaY)) )

		if targets["root"].objGridLayer then
			targets["root"].objGridLayer:setPosition(targets["root"]:getPosition())
		end
		local pos = ccpSub(targets["root"]:getPosition(), ccp(x, y))

		for v in tSelectedIDs:iterator() do
			targets[v].rect:setPosition(ccpAdd(targets[v].rect:getPosition(), pos))
			if targets[v].scrollRect then
				targets[v].scrollRect:setPosition(ccpAdd(targets[v].rect:getPosition(), pos))
			end
		end
		-- if targets["root"].objMaxSelectRect:isVisible() then
		-- 	targets["root"].objMaxSelectRect:setPosition(ccpAdd(targets["root"].objMaxSelectRect:getPosition(), pos))
		-- end

		print("setDesignPanelPos success")
	end	
end

local function checkPanelSize(rootID)
	local root = targets[rootID]
	if not root then return end
	if root.children then
		local length = root.children:length()
		for i = length, 1, -1 do
			local szTouchID = checkPanelSize(root.children:objectAt(i))
		end
	end
	if root.setDesignResolutionSize and root:getSizeType() == 4 then
		local tParams = {}
		tParams.nWidth = root._tDesignSize.width
		tParams.nHeight = root._tDesignSize.height
		require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel'):setDesignResolutionSize(rootID, tParams)
	end
end

function EditVirtualBase:setDesignPanelSize(szId, tParams)
	print("setDesignPanelSize")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil then
		targets["root"].bgImg:setSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		targets["root"].bgSize = CCSize(tParams.nWidth, tParams.nHeight)
		targets["root"]:setSize(CCSize(tParams.nWidth, tParams.nHeight))
		EditVirtualBase:setDesignPanelPos("", tParams)
		-- todo 先发visible 再发这个
		for v in tRootPanel:iterator() do
			if targets[v] and targets[v]:isVisible() then
				checkPanelSize(v)
				if targets[v]._bIsSetPercentage and targets[v].visibleRectPercent == 100 then
					targets[v]:setSize(CCSize(tParams.nWidth * targets[v].visibleRectPercent/100, tParams.nHeight * targets[v].visibleRectPercent/100))
					break
				end
			end
		end
		print("setDesignPanelSize success")
	end
end

function EditVirtualBase:setDesignPanelScale(szId, tParams)
	print("setDesignPanelScale", tParams)
	if tParams.nScale ~= nil then
		local curScale = targets["root"]:getScale()
		--中点缩放
		local size = targets["root"]:getSize()

		local frameSize = CCEGLView:sharedOpenGLView():getFrameSize()
		tParams.nX = tParams.nX or frameSize.width / 2
		tParams.nY = tParams.nY or frameSize.height / 2

		local scalePos = targets["root"]:convertToNodeSpace(ccp(tParams.nX, tParams.nY))

		local curPos = targets["root"]:getPosition()
		local nDeltX = (tParams.nScale-curScale)*size.width * ( scalePos.x / size.width )
		local nDeltY = (tParams.nScale-curScale)*size.height * ( scalePos.y / size.height )
		targets["root"]:setPosition( ccpSub(curPos, ccp(nDeltX, nDeltY)) )
		if targets["root"].objGridLayer then
			targets["root"].objGridLayer:setScale(tParams.nScale)
			targets["root"].objGridLayer:setPosition(targets["root"]:getPosition())
		end

		targets["root"]:setScale(tParams.nScale)

		local originPos = targets["root"]:convertToWorldSpace(ccp(0, 0))
		szGlobleResult = string.format("originX = %d, originY = %d", originPos.x, originPos.y)
		setGlobleString(szGlobleResult)
		print("setDesignPanelScale success")
	end
end

function EditVirtualBase:lockTarget(szId, tParams)
	print("lockTarget")
	if tParams.isLock then
		tLockTargets:push(szId)
	else
		tLockTargets:removeObject(szId)
	end
	print("lockTarget success")
end

return EditVirtualBase