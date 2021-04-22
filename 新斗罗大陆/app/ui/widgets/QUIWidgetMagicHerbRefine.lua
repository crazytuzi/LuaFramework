
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbRefine = class("QUIWidgetMagicHerbRefine", QUIWidget)

local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetMagicHerbRefine:ctor( options )
    local ccbFile = "ccb/Widget_MagicHerb_Refine.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
        {ccbCallbackName = "onTriggerOneKey", callback = handler(self, self._onTriggerOneKey)},
        {ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
        {ccbCallbackName = "onTriggerLockOne", callback = handler(self, self._onTriggerLockOne)},
        {ccbCallbackName = "onTriggerLockTwo", callback = handler(self, self._onTriggerLockTwo)},
        {ccbCallbackName = "onTriggerLockThree", callback = handler(self, self._onTriggerLockThree)},
    }
    QUIWidgetMagicHerbRefine.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_preview)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_change)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
    q.setButtonEnableShadow(self._ccbOwner.btn_oneKey)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
    self._lockTbl = {false,false,false}	--初始化三个不锁的
    self._oldTFOffside = 0
	self._delayUpdate = false
	self._needTipProp = false
end

function QUIWidgetMagicHerbRefine:onEnter()
	self:_init()
end

function QUIWidgetMagicHerbRefine:onExit()
end

function QUIWidgetMagicHerbRefine:_reset()
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_client:setVisible(false)

	self._ccbOwner.tf_magicHerb_info:setVisible(true)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:setVisible(true)
	self._ccbOwner.node_client_old:setVisible(true)
	self._ccbOwner.tf_state_old:setVisible(true)
	self._ccbOwner.node_richText_old:removeAllChildren()
	self._ccbOwner.node_richText_old:setVisible(true)
	self._ccbOwner.node_client_new:setVisible(true)
	self._ccbOwner.tf_state_new:setVisible(true)
	self._ccbOwner.node_richText_new:removeAllChildren()
	self._ccbOwner.node_richText_new:setVisible(true)
	self._ccbOwner.btn_preview:setVisible(true)
	self._ccbOwner.node_btn_ok:setVisible(true)
	self._ccbOwner.btn_ok:setVisible(true)
	self._ccbOwner.tf_price_num:setVisible(true)
	self._ccbOwner.sp_price_icon:setVisible(true)
	self._ccbOwner.node_btn_select:setVisible(false)
	self._ccbOwner.btn_change:setVisible(true)
	self._ccbOwner.btn_cancel:setVisible(true)

	self._ccbOwner.tf_price_num_one_key:setVisible(true)
	self._ccbOwner.sp_price_icon_one_key:setVisible(true)
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.node_perlock:setVisible(false)
	self._ccbOwner.tf_lock_tips:setVisible(false)
	self._ccbOwner.tf_canlock_tips:setVisible(false)
	self._nowPropTf = nil
	self._newPropTf = nil
	self._canLock = true
	self._needTipProp = false


end

function QUIWidgetMagicHerbRefine:_init()
	self:_reset()
end

function QUIWidgetMagicHerbRefine:setInfo(actorId, pos)
	if self._delayUpdate then
		return
	end
	self:_reset()

	if self._actorId ~= actorId or self._pos ~= pos then
		 self:resetLock()
	end

	self._actorId = actorId
	self._pos = pos
	self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local wearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)


	if not wearedInfo then return end
	self._sid = wearedInfo.sid


	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)



	if not magicHerbItemInfo then return end
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
	if not magicHerbConfig then return end
	local maigcHerbItemConfig = db:getItemByID(magicHerbItemInfo.itemId)
	if not maigcHerbItemConfig then return end
	
	self._ccbOwner.node_info:setVisible(true)

	local breedLv = magicHerbItemInfo.breedLevel or 0
	local itemId = magicHerbItemInfo.itemId
	self._aptitude = remote.magicHerb:getAptitudeByIdAndBreedLv(itemId,breedLv)
	if self._aptitude == APTITUDE.SS then
		self._ccbOwner.node_lock:setVisible(true)
		self._oldTFOffside = 20
	end
	if self._aptitude == APTITUDE.S then
		self._needTipProp = true
		self._oldTFOffside = 20
		self._ccbOwner.node_perlock:setVisible(true)
	end

	local icon = QUIWidgetMagicHerbEffectBox.new()
	icon:setInfo(self._sid)
	icon:hideName()
	self._ccbOwner.node_icon:addChild(icon)
	local name = magicHerbConfig.name
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour]]
	local  breedLevel = magicHerbItemInfo.breedLevel or 0
    if breedLevel == remote.magicHerb.BREED_LV_MAX then
    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour + 1]]
	elseif breedLevel > 0 then
		name = name.."+"..breedLevel
    end

	self._ccbOwner.tf_magicHerb_info:setString(name.."【"..magicHerbConfig.type_name.."类】")
	
	self._ccbOwner.tf_magicHerb_info:setColor(fontColor)
	self._ccbOwner.tf_magicHerb_info = setShadowByFontColor(self._ccbOwner.tf_magicHerb_info, fontColor)

	self._ccbOwner.node_client:setVisible(true)

	self._itemId, self._price = remote.magicHerb:getRefineItemIdAndPriceByAptitude(self._aptitude )
	local url = remote.items:getURLForId(self._itemId, "icon_1")
	QSetDisplayFrameByPath(self._ccbOwner.sp_price_icon, url)
	QSetDisplayFrameByPath(self._ccbOwner.sp_price_icon_one_key, url)


    if not app.unlock:checkLock("XIANPIN_QUICK_ZHUANGSHENG", false)  then
		self._ccbOwner.node_onekey:setVisible(false)
		self._ccbOwner.node_ok:setPositionX(0)
        
	else
		self._ccbOwner.node_ok:setPositionX(-140)
		self._ccbOwner.node_onekey:setVisible(true)
    end

	if magicHerbItemInfo.lockAttrIndex ~= nil and self._lockTbl[tonumber(magicHerbItemInfo.lockAttrIndex)] == false then
		self:setLockByIndex(tonumber(magicHerbItemInfo.lockAttrIndex))
	else
		self:_update()
	end

end

function QUIWidgetMagicHerbRefine:_update()
	local num = remote.items:getItemsNumByID(self._itemId)

	local refineOneKeyNum = 10
	local refineOneKeyNumStr = "十连转生"
	local  isLock = false
	if self._aptitude == APTITUDE.SS then
		refineOneKeyNum = 5
		refineOneKeyNumStr = "五连转生"
	end
	for i,v in ipairs(self._lockTbl) do
		if v then
			isLock = true
			break
		end
	end

	self._itemId, self._price = remote.magicHerb:getRefineItemIdAndPriceByAptitude( self._aptitude , isLock )
	self._ccbOwner.tf_price_num:setString(num.."/"..self._price)
	
	if num < self._price then
		self._ccbOwner.tf_price_num:setColor(COLORS.m)
	else
		self._ccbOwner.tf_price_num:setColor(COLORS.j)
	end
	local price = self._price * refineOneKeyNum
	self._ccbOwner.tf_price_num_one_key:setString(num.."/"..price)
	self._ccbOwner.tf_refine_onekey:setString(refineOneKeyNumStr)
	if num < price then
		self._ccbOwner.tf_price_num_one_key:setColor(COLORS.m)
	else
		self._ccbOwner.tf_price_num_one_key:setColor(COLORS.j)
	end
	self:_updateProp()
end

function QUIWidgetMagicHerbRefine:_updateProp()
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo then return end

	local nowPropTable ,newPropTable  = remote.magicHerb:_getOldNewPropTable(self._sid)
	local attrNum = 1
	local lockPropStr = {}
	self._canLock = #newPropTable < 1
	local lineSpacing = 6
	
	if not q.isEmpty(nowPropTable) and nowPropTable[1].value then
		local propList = nowPropTable[1].value
		self._propList = propList
		if propList then
			if self._nowPropTf == nil then
		        self._nowPropTf = QRichText.new(nil, nil, {lineSpacing = lineSpacing})
		        self._nowPropTf:setAnchorPoint(ccp(0, 0.5))

		        self._ccbOwner.node_richText_old:addChild(self._nowPropTf)
		    end

		    local nowPropTfConfig = {}
		    attrNum = #propList
			for i, value in ipairs(propList) do
				local str = value.name.."：+"..value.num
				if value.isMax then
					str = str.."（满）"
				end
				local color = COLORS[value.color]
				local strokeColor = getShadowColorByFontColor(color)
			 	table.insert(nowPropTfConfig, {oType = "font", content = str, size = 20, color = color, strokeColor = strokeColor})
			 	if i<3 then
	        		table.insert(nowPropTfConfig, {oType = "wrap"})
			 	end
	        	if self._lockTbl[i] then
	        		lockPropStr = {oType = "font", content = str, size = 20, color = color, strokeColor = strokeColor}
	        	end
			end
			if self._needTipProp then
				table.insert(nowPropTfConfig, {oType = "font", content = "培育到SS解锁", size = 20, color = COLORS.n})
			end
			self._nowPropTf:setString(nowPropTfConfig)
			self._nowPropTf:setPositionX(self._oldTFOffside)
		end
	end

	if not q.isEmpty(newPropTable) then
		--出替换功能后，这次显示缓存属性
		local propList = newPropTable[1].value
		self._newPropList = propList
		local isOneKeyAttr = #newPropTable > 1

		if propList then
			if self._newPropTf == nil then
		        self._newPropTf = QRichText.new(nil, nil, {lineSpacing = lineSpacing})
		        self._newPropTf:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.node_richText_new:addChild(self._newPropTf)
		    end

		    local newPropTfConfig = {}

			for i=1,attrNum do
				if i > #propList then
					table.insert(newPropTfConfig, {oType = "font", content =  "     ??????", size = 20, color = COLORS.n})
					break
				end
				if isOneKeyAttr and i >= 3 then
		    		break
		   		end

				local value = propList[i]
				local str = value.name.."：+"..value.num
				if value.isMax then
					str = str.."（满）"
				end
				local color = COLORS[value.color]
				local strokeColor = getShadowColorByFontColor(color)
	        	if self._lockTbl[i] then
			 		table.insert(newPropTfConfig, lockPropStr)
	        	else
			 		table.insert(newPropTfConfig, {oType = "font", content = str, size = 20, color = color, strokeColor = strokeColor})
	        	end
	        	table.insert(newPropTfConfig, {oType = "wrap"})
			end
			if isOneKeyAttr then
			 	table.insert(newPropTfConfig, {oType = "font", content = "     ......", size = 20, color = COLORS.j})
			elseif self._needTipProp then
				table.insert(newPropTfConfig, {oType = "font", content = "培育到SS解锁", size = 20, color = COLORS.n})
			end

			self._newPropTf:setString(newPropTfConfig)
		end

		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.node_btn_select:setVisible(not isOneKeyAttr)
		self._ccbOwner.node_btn_continue:setVisible(isOneKeyAttr)

	else
		if self._newPropTf == nil then
	        self._newPropTf = QRichText.new(nil, nil, {lineSpacing = lineSpacing})
	        self._newPropTf:setAnchorPoint(ccp(0, 0.5))
	        self._ccbOwner.node_richText_new:addChild(self._newPropTf)
	    end

	    local nowPropTfConfig = {}
	    local str = "     ??????" -- 加點空格，為了居中
	    local color = COLORS.j
		local strokeColor = getShadowColorByFontColor(color)
		local isLock = false
		for i=1,#self._propList do
	    	if self._lockTbl[i] then
		 		table.insert(nowPropTfConfig, lockPropStr)
		 		isLock= true
	    	else
				table.insert(nowPropTfConfig, {oType = "font", content = str, size = 20, color = color})
	    	end
	 		if i<3 then
	        	table.insert(nowPropTfConfig, {oType = "wrap"})
			end
		end

		if self._needTipProp then
			table.insert(nowPropTfConfig, {oType = "font", content = "  培育到SS解锁", size = 20, color = COLORS.n})
		end
		self._ccbOwner.tf_lock_tips:setVisible(isLock)
		if self._aptitude == APTITUDE.SS then
			self._ccbOwner.tf_canlock_tips:setVisible(not isLock)
		end
		-- table.insert(nowPropTfConfig, {oType = "font", content = str, size = 20, color = color})
  --   	table.insert(nowPropTfConfig, {oType = "wrap"})
  --   	if #self._propList > 1 then
	 --    	table.insert(nowPropTfConfig, {oType = "font", content = str, size = 20, color = color})
	 --    	table.insert(nowPropTfConfig, {oType = "wrap"})
	 -- end
		self._newPropTf:setString(nowPropTfConfig)

		self._ccbOwner.node_btn_ok:setVisible(true)
		self._ccbOwner.node_btn_select:setVisible(false)
		self._ccbOwner.node_btn_continue:setVisible(false)
	end

end


function QUIWidgetMagicHerbRefine:resetLock()
	print("resetLock")
	for i=1,3 do
		self._ccbOwner["btn_lock_"..i]:setHighlighted(false)
		self._ccbOwner["btn_lock_"..i]:setScale(0.8)
		self._lockTbl[i] =false
	end
end

function QUIWidgetMagicHerbRefine:setLockByIndex(lockIdx)
	print("setLockByIndex 	"..lockIdx)

	if self._canLock == false then
		app.tip:floatTip("当前转生未完成无法上锁")
		return
	end

	for i=1,3 do
		local beforeLockState = self._lockTbl[i]
		local curLockState = not beforeLockState and lockIdx==i
		self._ccbOwner["btn_lock_"..i]:setHighlighted(curLockState)
		self._ccbOwner["btn_lock_"..i]:setScale(0.8)
		self._lockTbl[i] = curLockState
	end
	self:_update()
end



function QUIWidgetMagicHerbRefine:_onTriggerOK(event)	
	app.sound:playSound("common_small")
	local num = remote.items:getItemsNumByID(self._itemId)
	if num >= self._price then
		local lockIdx = nil
		for i,v in ipairs(self._lockTbl) do
			if v then
				lockIdx = i
				break
			end
		end
		remote.magicHerb:magicHerbRefineRequest(self._sid, lockIdx, false ,  function()
				if self._ccbView then
					self:_update()
				end
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
		-- app.tip:floatTip("道具不足")
	end
end

function QUIWidgetMagicHerbRefine:_isPropBetter()
	if not self._propList or #self._propList == 0 then return false end
	if not self._newPropList or #self._newPropList == 0 then return false end
	-- local oldProp = clone(self._propList)
	-- local newProp = clone(self._newPropList)
	-- if not newProp or #newProp == 0 then return false end
	QPrintTable(self._propList)
	QPrintTable(self._newPropList)
	local oldScore = 0
	for i,v in ipairs(self._propList) do
		oldScore = oldScore + v.score
	end
	local newScore = 0
	for i,v in ipairs(self._newPropList) do
		newScore = newScore + v.score
	end

	return newScore > oldScore
	-- local colorStr = ""
	-- local num = 0
	-- local maxNewProp = {}
	-- for _, prop in ipairs(newProp) do
	-- 	prop.num = string.gsub(prop.num, "%%", "")
	-- 	if colorStr == "" or colorStr < prop.color then
	-- 		-- 字符串，ABCDEFG
	-- 		colorStr = prop.color
	-- 		num = tonumber(prop.num)
	-- 		maxNewProp = prop
	-- 	elseif colorStr == prop.color and num < tonumber(prop.num) then 
	-- 		colorStr = prop.color
	-- 		num = tonumber(prop.num)
	-- 		maxNewProp = prop
	-- 	end
	-- end

	-- colorStr = ""
	-- num = 0
	-- local maxOldProp = {}
	-- for _, prop in ipairs(oldProp) do
	-- 	prop.num = string.gsub(prop.num, "%%", "")
	-- 	if colorStr == "" or colorStr < prop.color then
	-- 		-- 字符串，ABCDEFG
	-- 		colorStr = prop.color
	-- 		num = tonumber(prop.num)
	-- 		maxOldProp = prop
	-- 	elseif colorStr == prop.color and num < tonumber(prop.num) then 
	-- 		colorStr = prop.color
	-- 		num = tonumber(prop.num)
	-- 		maxNewProp = prop
	-- 	end
	-- end

	-- if maxNewProp.color < maxOldProp.color then
	-- 	-- print("color ", maxNewProp.color, maxOldProp.color)
	-- 	return false
	-- -- elseif maxNewProp.color == maxOldProp.color and maxNewProp.num < maxOldProp.num then
	-- -- 	print("num ", maxNewProp.color, maxOldProp.color, maxNewProp.num, maxOldProp.num)
	-- -- 	return false
	-- end
	-- -- QPrintTable(maxOldProp)
	-- -- QPrintTable(maxNewProp)
	-- return true
end

function QUIWidgetMagicHerbRefine:_onTriggerChange(event)
	app.sound:playSound("common_small")
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo or not magicHerbItemInfo.replaceAttributes then return end

	local oldPropList = self._propList
	local nowPropList = self._newPropList
	
	if not self:_isPropBetter() then
		app:alert({content = "魂师大人，转生后的属性比当前的要低哦，是否确认替换？", title = "转生提示", 
			btns = {ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_OK},
	        callback = function(state)
	            if state == ALERT_TYPE.CONFIRM then
	            	self._delayUpdate = true
	                remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, true, 0,  function()
							if self._ccbView then
								local callback = function()
									self._delayUpdate = false
									self:setInfo(self._actorId, self._pos)
								end
								app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuccess", 
									options = {sid = self._sid, oldPropList = oldPropList, nowPropList = nowPropList, callback = callback}})
							end
						end)
	            end
	        end, isAnimation = false}, false, true)
	else
		self._delayUpdate = true
        remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, true, 0,  function()
				if self._ccbView then
					local callback = function()
						self._delayUpdate = false
						self:setInfo(self._actorId, self._pos)
					end
					app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuccess", 
						options = {sid = self._sid, oldPropList = oldPropList, nowPropList = nowPropList, callback = callback}})
				end
			end)
	end
end

function QUIWidgetMagicHerbRefine:_onTriggerCancel(event)
	app.sound:playSound("common_small")

	remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, false, 0,  function()
			if self._ccbView then
				self:_updateProp()	
			end
		end)
end

function QUIWidgetMagicHerbRefine:_onTriggerPreview()
	app.sound:playSound("common_small")
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo then return end
	local additional_attributes = remote.magicHerb:getMagicHerbAdditionalAttributes(magicHerbItemInfo)
	app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbRefinePreview", 
		options = {refineId = additional_attributes}})
end



function QUIWidgetMagicHerbRefine:_onTriggerOneKey(event)
	app.sound:playSound("common_small")

    if not app.unlock:checkLock("XIANPIN_QUICK_ZHUANGSHENG", true)  then
        return false
    end

	local refineOneKeyNum = 10
	local isSmale = false
	local lockIdx = nil
	if self._aptitude == APTITUDE.SS then
		refineOneKeyNum = 5
		isSmale = true
	end

	for i,v in ipairs(self._lockTbl) do
		if v then
			lockIdx = i
			break
		end
	end
	local num = remote.items:getItemsNumByID(self._itemId)
	if num >= self._price * refineOneKeyNum then
		local sid = self._sid

		remote.magicHerb:magicHerbRefineRequest(self._sid, lockIdx , true, function()
			self:_update()

			local successCb = function()
				if self._ccbView then
				self._delayUpdate = false
				self:setInfo(self._actorId, self._pos)
				end
			end
			local continueCb = function()
				if self._ccbView then
					self:_update()
				end
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbQuickRefine", 
				options = {sid = sid, successCb = successCb ,continueCb = continueCb, showAction = true ,small = self._aptitude == APTITUDE.SS, 
						lockIdx = lockIdx, itemId = self._itemId, needNum = self._price * refineOneKeyNum}})
			end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId)
		-- app.tip:floatTip("道具不足")
	end
end

function QUIWidgetMagicHerbRefine:_onTriggerContinue(event)
	app.sound:playSound("common_small")
	local sid = self._sid
	local successCb = function()
		if self._ccbView then
		self._delayUpdate = false
		self:setInfo(self._actorId, self._pos)
		end
	end
	local continueCb = function()
		if self._ccbView then
			self:_updateProp()
		end
	end

	local refineOneKeyNum = 10
	if self._aptitude == APTITUDE.SS then
		refineOneKeyNum = 5
	end

	local isSmale = false
	local lockIdx = nil
	for i,v in ipairs(self._lockTbl) do
		if v then
			lockIdx = i
			isSmale = true
			break
		end
	end	
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbQuickRefine", 
		options = {sid = sid , successCb =successCb ,continueCb = continueCb , showAction = false ,small = self._aptitude == APTITUDE.SS,
				lockIdx = lockIdx, itemId = self._itemId, needNum = self._price * refineOneKeyNum}})
end

function QUIWidgetMagicHerbRefine:_onTriggerLockOne(event)
	self:setLockByIndex(1)
end

function QUIWidgetMagicHerbRefine:_onTriggerLockTwo(event)
	self:setLockByIndex(2)
end

function QUIWidgetMagicHerbRefine:_onTriggerLockThree(event)
	self:setLockByIndex(3)
end


function QUIWidgetMagicHerbRefine:_getPropList( prop, refineId )
	local tbl = {}
	if prop then
		for _, value in pairs(prop) do
			local key = value.attribute
			local num = value.refineValue--math.floor(value.refineValue*1000)/1000
			if QActorProp._field[key] then
				local color, isMax = remote.magicHerb:getRefineValueColorAndMax(key, num, refineId)
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				num = q.getFilteredNumberToString(num, QActorProp._field[key].isPercent, 2)		
				table.insert(tbl, {name = name, num = num, color = color, isMax = isMax})
			end
		end
	end

	return tbl
end

return QUIWidgetMagicHerbRefine