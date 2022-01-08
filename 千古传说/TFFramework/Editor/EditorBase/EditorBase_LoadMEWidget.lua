
function EditLua:setReferenceImage(szId, tParams)
	print("setReferenceImage")
	if targets[szId].objReferenceImage == nil then
		local image = TFImage:create()
		image:setMEFlagEnabled(TFNODE_PRIVATE_CHILD, true)
		targets[szId]:addChild(image)
		targets[szId].objReferenceImage = image
	end
	targets[szId].objReferenceImage:setTexture(tParams.szFileName)
	print("setReferenceImage success")
end

function EditLua:setReferenceImageVisible(szId, tParams)
	print("setReferenceImageVisible")
	if targets[szId].objReferenceImage then
		targets[szId].objReferenceImage:setVisible(tParams.bVisible)
	end
	print("setReferenceImageVisible success")
end

function EditLua:setCCRectHitRect(szId, tParams)
	print("setCCRectHitRect")
	targets[szId]:setHitRect(CCSizeMake(tParams.nWidth, tParams.nHeight), ccp(tParams.nX, tParams.nY))
	print("setCCRectHitRect success")
end

function EditLua:setCircleHitRadius(szId, tParams)
	print("setCircleHitRadius")
	targets[szId]:setHitRadius(tParams.nRadius)
	print("setCircleHitRadius success")
end

function EditLua:setWidgetHitType(szId, tParams)
	print("setWidgetHitType")
	targets[szId]:setHitType(tParams.nType)
	print("setWidgetHitType success")
end

function EditLua:showTouchRangeRect(szId, tParams)
	print("showHitRangeRect")
	targets[szId].touchRect:setVisible(tParams.bRet)
	print("showHitRangeRect success")
end

function EditLua:pause(szId, tParams)
	print("pause")
	if targets[szId] == nil then
		return
	end
	-- targets[szId]:pause()
	TFFunction.call(targets[szId].pause, targets[szId])
end

function EditLua:resume(szId, tParams)
	print("resume")
	if targets[szId] == nil then
		return
	end
	TFFunction.call(targets[szId].resume, targets[szId])
end

function EditLua:stop(szId, tParams)
	print("stop")
	if targets[szId] == nil then
		return
	end
	TFFunction.call(targets[szId].stop, targets[szId])
	print("stop success")
end

function EditLua:setPositionPercent(szId, tParams)
	print("setPositionPercent")
	if targets[szId].setPositionPercent and tParams.nXper ~= nil and tParams.nYper ~= nil then

		tParams.nXper = tParams.nXper / 100
		tParams.nYper = tParams.nYper / 100

		targets[szId]:setPositionPercent(ccp(tParams.nXper, tParams.nYper))
		print("setPositionPercent success")
	end
end

function EditLua:setPositionType(szId, tParams)
	print("setPositionType")
	if targets[szId].setPositionType and tParams.nType ~= nil then
		targets[szId]:setPositionType(tParams.nType)
		print("setPositionType success")
	end
end

function EditLua:setSizeRelative(szId, tParams)
	print("setSizeRelative")
	if targets[szId].setSizeRelative and tParams.nXper ~= nil and tParams.nYper ~= nil then
		targets[szId]:setSizeRelative(ccp(tParams.nXper, tParams.nYper))
		print("setSizeRelative success")
	end
end

function EditLua:setSizePercent(szId, tParams)
	print("setSizePercent", tParams.nPerWidth, tParams.nPerHeight)
	if targets[szId].setSizePercent and tParams.nPerWidth ~= nil and tParams.nPerHeight ~= nil then
		tParams.nPerWidth = tParams.nPerWidth / 100
		tParams.nPerHeight = tParams.nPerHeight / 100
		if targets[szId]:getSizeType() == TF_SIZE_FRAMESIZE then
			targets[szId]:setSize(CCSizeMake(targets["root"]:getSize().width * tParams.nPerWidth, targets["root"]:getSize().height * tParams.nPerHeight))
		else
			targets[szId]:setSizePercent(ccp(tParams.nPerWidth, tParams.nPerHeight))
			if targets[szId].setRichTextSize then
				targets[szId]:setRichTextSize(targets[szId]:getSize())
				targets[szId]:setText(targets[szId]:getText())
			end
		end
		print("setSizePercent success")
	end
end

function EditLua:setSizeType(szId, tParams)
	print("setSizeType")
	if targets[szId].setSizeType and tParams.nType ~= nil then
		targets[szId]:setSizeType(tParams.nType)
		print("setSizeType success")
	end
end

function EditLua:setName(szId, tParams)
	print("setName")
	if tParams and tParams.szName then
		targets[szId]:setName(tParams.szName)
		local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		if lp then
			lp:setRelativeName(tParams.szName)
		end
		print("setName success")
	end
end

function EditLua:ignoreContentAdaptWithSize(szId, tParams)
	print("ignoreContentAdaptWithSize")
	targets[szId]._bUseCustomSize = not tParams.bRet
	if targets[szId].ignoreContentAdaptWithSize then
		targets[szId]:ignoreContentAdaptWithSize(tParams.bRet)
		print("ignoreContentAdaptWithSize run success, function")
	end
	if tParams.bRet then
		targets[szId]:setSize(targets[szId]:getAutoSize())
		print("ignoreContentAdaptWithSize run success")
	else
		targets[szId]._tCustomSize = targets[szId]:getSize()
		szGlobleResult = "1"
		setGlobleString(szGlobleResult)
		print("ignoreContentAdaptWithSize run success, false")
	end
end

function EditLua:setTouchEnabled(szId, tParams)
	print("setTouchEnabled")
	if tParams.bRet ~= nil and targets[szId].setTouchEnabled ~= nil then
		targets[szId]:setTouchEnabled(tParams.bRet)
		print("setTouchEnabled run success")
	end	
end

function EditLua:setScaleX(szId, tParams)
	print("setScaleX")
	if tParams.nScaleX ~= nil and targets[szId].setScaleX ~= nil then
		targets[szId]:setScaleX(tParams.nScaleX)
		print("setScaleX run success")
	end	
end

function EditLua:setScaleY(szId, tParams)
	print("setScaleY")
	if tParams.nScaleY ~= nil and targets[szId].setScaleY ~= nil then
		targets[szId]:setScaleY(tParams.nScaleY)
		print("setScaleY run success")
	end	
end

function EditLua:setScaleXY(szId, tParams)
	print("setScaleXY")
	if tParams.nX ~= nil then
		targets[szId]:setScaleX(tParams.nX)
		print("setScaleX run success")
	end	
	if tParams.nY ~= nil then
		targets[szId]:setScaleY(tParams.nY)
		print("setScaleXY run success")
	end	
end

function EditLua:setTouchSize(szId, tParams)
	print("setTouchSize")
	if tParams.nWidth ~= nil and targets[szId] ~= nil and targets[szId].setTouchSize then
		targets[szId]:setTouchSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		targets[szId]:setSize(CCSize(tParams.nWidth, tParams.nHeight))
		print("setTouchSize run success")
	end
end

function EditLua:setSize(szId, tParams)
	print("setSize")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil and targets[szId] ~= nil and targets[szId].setSize then 
		if targets[szId]._bIsRoot and targets[szId]._bIsSetPercentage then
			print("isRoot panel and isSetPercentage")
			return
		end
		if targets[szId]._bUseCustomSize then
			targets[szId]._tCustomSize = CCSizeMake(tParams.nWidth, tParams.nHeight)
		end
		
		if targets[szId].isIgnoreContentAdaptWithSize and targets[szId]:isIgnoreContentAdaptWithSize() then
			print("====== is auto size ==========")
			return
		end
		if targets[szId].setRichTextSize then
	        targets[szId]:setRichTextSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
	        targets[szId]:setText(targets[szId]:getText())
		end
		targets[szId]:setSize(CCSizeMake(tParams.nWidth, tParams.nHeight))
		print("setSize run success", targets[szId]:getSize().width, targets[szId]:getSize().height)
	end
end

function EditLua:setCapInsets(szId, tParams)
	print("setCapInsets")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil and targets[szId] ~= nil and targets[szId].setCapInsets then 
		targets[szId]:setCapInsets(CCRectMake(tParams.nX, tParams.nY, tParams.nWidth, tParams.nHeight))
		print("setCapInsets run success")
	end
end

function EditLua:setScale9Enabled(szId, tParams)
	print("setScale9Enabled")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setScale9Enabled then
		targets[szId]:setScale9Enabled(tParams.bRet)
		print("setScale9Enabled run success")
	end
end

function EditLua:setFlipX(szId, tParams)
	print("setFlipX")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setFlipX then
		targets[szId]:setFlipX(tParams.bRet)
		print("setFlipX run success")
	end
end

function EditLua:setFlipY(szId, tParams)
	print("setFlipY")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setFlipY then
		targets[szId]:setFlipY(tParams.bRet)
		print("setFlipY run success")
	end
end

function EditLua:setFlipXY(szId, tParams)
	print("setFlipXY")
	if tParams.bFlipX ~= nil and targets[szId].setFlipX then
		targets[szId]:setFlipX(tParams.bFlipX)
		print("setFlipX run success")
	end
	if tParams.bFlipY ~= nil and targets[szId].setFlipY then
		targets[szId]:setFlipY(tParams.bFlipY)
		print("setFlipY run success")
	end
end

function EditLua:setColor(szId, tParams)
	print("setColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setColor then
		targets[szId]:setColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setColor success")
	end
end

function EditLua:setVisible(szId, tParams)
	print("setVisible")
	if tParams.bRet ~= nil and targets[szId] ~= nil and targets[szId].setVisible then
		targets[szId]:setVisible(tParams.bRet)
		if targets[szId]._bIsRoot then
			if tParams.bRet then
				szCurRootPanelID = szId
			else
				szCurRootPanelID = ""
			end
		end

		local function checkSelecteds(szId)
			if tSelectedIDs:indexOf(szId) ~= -1 then
				tSelectedIDs:removeObject(szId)
				tSelectedRectManager:setSelectedRectVisible(szId, false)
			end
			if tSelectedIDs:count() == 0 then return end
			for v in targets[szId].children:iterator() do
				if targets[v] then
					checkSelecteds(v)
				end
			end
		end
		if not tParams.bRet then
			checkSelecteds(szId)
			for v in tSelectedIDs:iterator() do
				local touchObj = targets[v]
				if touchObj then
					tRetureMsgTarget:push(v)
					tRetureMsgSelectedTarget:push(v)
					bIsNeedToSetCmdGet = true
				end
			end
		end
		print("setVisible run success")
	end
end

function EditLua:setContentSize(szId, tParams)
	print("setContentSize")
	if tParams.nWidth and tParams.nHeight and targets[szId] ~= nil and targets[szId].setContentSize then
		targets[szId]:setContentSize(CCSize(tParams.nWidth, tParams.nHeight))
		print("setContentSize run success")
	end
end

function EditLua:setRotation(szId, tParams)
	print("setRotation")
	if tParams.fDegree ~= nil and targets[szId] ~= nil and targets[szId].setRotation then
		targets[szId]:setRotation(tParams.fDegree)
		print("setRotation run success")
	end
end

function EditLua:setTag(szId, tParams)
	print("setTag")
	if tParams.nTag ~= nil and targets[szId] ~= nil and targets[szId].setTag then
		targets[szId]:setTag(tParams.nTag)
		print("setTag run success")
	end
end

function EditLua:reorderChild(szId, childrenID)
	if targets[szId].children:length() == 1 then
		return
	else
		targets[szId].children:removeObject(childrenID)
		local length = targets[szId].children:length()
		for i = length, 1, -1 do
			if targets[childrenID]:getZOrder() >= targets[targets[szId].children:getObjectAt(i)]:getZOrder() then
				targets[szId].children:insertAt(i+1, childrenID)
				return
			end
		end
		targets[szId].children:insertAt(1, childrenID)
	end
end

function EditLua:setZOrder(szId, tParams)
	print("setZOrder")
	if tParams.nOrder and targets[szId] ~= nil and targets[szId].setZOrder then
		targets[szId]:setZOrder(tParams.nOrder)
		if targets[szId] ~= targets["root"] then
			EditLua:reorderChild(targets[szId].szParentID, szId)
		end		
		if targets[targets[szId].szParentID]:getNodeType() == TFWIDGET_TYPE_CONTAINER then
			targets[targets[szId].szParentID]:doLayout()
		end
		print("setZOrder run success")
	end
end

function EditLua:setOpacity(szId, tParams)
	print("setOpacity")
	if tParams.nOpacity and targets[szId] ~= nil and targets[szId].setOpacity then
		targets[szId]:setOpacity(tParams.nOpacity)
		print("setOpacity run success")
	end
end

function EditLua:setAnchorPoint(szId, tParams)
	print("setAnchorPoint")
	if tParams.nX and tParams.nY and targets[szId] ~= nil and targets[szId].setAnchorPoint then
		targets[szId]:setAnchorPoint(ccp(tParams.nX, tParams.nY))

		local szRes = ""
		for v in targets[szId].children:iterator() do
			tRetureMsgTarget:push(v)
		end
		tRetureMsgTarget:push(szId)
		bIsNeedToSetCmdGet = true
		print("setAnchorPoint run success")
	end
end

function EditLua:setPosition(szId, tParams)
	print("setPosition")
	if tParams.nX and tParams.nY and targets[szId] ~= nil and targets[szId].setPosition then
		targets[szId]:setPosition(ccp(tParams.nX, tParams.nY))
		print("setPosition run success")
	end
end


---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function EditLua:setCapInsetsPos(szId, tParams)
	print("setCapInsetsPos")
	if targets[szId].setCapInsets then 
		local rect = targets[szId]:getCapInsets()
		targets[szId]:setCapInsets(CCRectMake(tParams.nX, tParams.nY, rect.size.width, rect.size.height))
		print("setCapInsetsPos run success")
	end
end

function EditLua:setCapInsetsSize(szId, tParams)
	print("setCapInsetsSize")
	if targets[szId].setCapInsets then 
		local rect = targets[szId]:getCapInsets()
		targets[szId]:setCapInsets(CCRectMake(rect.origin.x, rect.origin.y, tParams.nWidth, tParams.nHeight))
		print("setCapInsetsSize run success")
	end
end

function EditLua:setBlendFuncSrc(szId, tParams)
	print("setBlendFuncSrc")
	if targets[szId].setBlendFunc and targets[szId].getBlendFunc then
		if not targets[szId].getBlendFunc then
			print("did't have getBlendFunction")
			return
		end
		targets[szId]:setBlendFunc(tParams.nSrc, targets[szId]:getBlendFunc().dst)
		print("setBlendFuncSrc success")
	end
	print("didn't have blendFunction")
end

function EditLua:setBlendFuncDst(szId, tParams)
	print("setBlendFuncDst")
	if targets[szId].setBlendFunc and targets[szId].getBlendFunc then
		if not targets[szId].getBlendFunc then
			print("did't have getBlendFunction")
			return
		end
		targets[szId]:setBlendFunc(targets[szId]:getBlendFunc().src, tParams.nDst)
		print("setBlendFuncDst success")
	end
	print("didn't have blendFunction")
end

function EditLua:setHitRectPos(szId, tParams)
	print("setHitRectPos")
	local rect = targets[szId]:getHitRect()
	targets[szId]:setHitRect(rect.size, ccp(tParams.nX, tParams.nY))
	print("setHitRectPos success")
end

function EditLua:setHitRectSize(szId, tParams)
	print("setHitRectSize")
	local rect = targets[szId]:getHitRect()
	targets[szId]:setHitRect(CCSizeMake(tParams.nWidth, tParams.nHeight), rect.origin)
	print("setHitRectSize success")
end

function EditLua:setPositionType2(szId, tParams)
	print("setPositionType")
	if targets[szId].setPositionType and tParams.bType ~= nil then
		if tParams.bType then
			targets[szId]:setPositionType(1)
		else
			targets[szId]:setPositionType(0)
		end
		print("setPositionType success")
	end
end
