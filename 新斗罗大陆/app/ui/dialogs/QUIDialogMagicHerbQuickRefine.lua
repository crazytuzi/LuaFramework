


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbQuickRefine = class("QUIDialogMagicHerbQuickRefine", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView") 
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local QUIWidgetMagicHerbQuickRefine = import("..widgets.QUIWidgetMagicHerbQuickRefine")

QUIDialogMagicHerbQuickRefine.SELECT_NULL = 0

function QUIDialogMagicHerbQuickRefine:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_Quick_Refine.ccbi" 
	if options.small then
		 ccbFile = "ccb/Dialog_MagicHerb_Quick_Refine_Small.ccbi" 
	end
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
    }
    QUIDialogMagicHerbQuickRefine.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._sid = options.sid
	self._successCb = options.successCb
	self._continueCb = options.continueCb
	self._showAction = options.showAction
	self._isSmall = options.small or false
	self._lockIndex = options.lockIdx
	self._itemId = options.itemId
	self._needNum = options.needNum
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
    self._actionEnd = false
	self._selectIndex = 1
end

function QUIDialogMagicHerbQuickRefine:viewDidAppear()
	QUIDialogMagicHerbQuickRefine.super.viewDidAppear(self)

	self:handleData()
	self:setInfo()
end

function QUIDialogMagicHerbQuickRefine:viewAnimationInHandler()
	QUIDialogMagicHerbQuickRefine.super.viewDidAppear(self)

end

function QUIDialogMagicHerbQuickRefine:viewWillDisappear()
  	QUIDialogMagicHerbQuickRefine.super.viewWillDisappear(self)
end


function QUIDialogMagicHerbQuickRefine:setInfo()
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo then return end

	self._nowPropTable ,self._newPropTable  = remote.magicHerb:_getOldNewPropTable(self._sid)

	if not q.isEmpty(self._nowPropTable) and self._nowPropTable[1].value then
		local propList = self._nowPropTable[1].value
		self._propList = propList
		if propList then
			if self._nowPropTf == nil then
		        self._nowPropTf = QRichText.new(nil, nil, {lineSpacing = 15})
		        self._nowPropTf:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.node_rich_text:addChild(self._nowPropTf)
		    end

		    local nowPropTfConfig = {}
			for _, value in ipairs(propList) do
				local str = value.name.."：+"..value.num
				if value.isMax then
					str = str.."（满）"
				end
				local color = COLORS[value.color]
				local strokeColor = getShadowColorByFontColor(color)
			 	table.insert(nowPropTfConfig, {oType = "font", content = str, size = 22, color = color, strokeColor = strokeColor})
			 	table.insert(nowPropTfConfig, {oType = "font", content = " ", size = 20, color = color, strokeColor = strokeColor})				
			end

			self._nowPropTf:setString(nowPropTfConfig)
		end
	end
	self.widgets = {}
	-- QPrintTable(self._newPropTable)
	if not q.isEmpty(self._newPropTable) then
		self._newPropList = self._newPropTable[self._selectIndex].value
		for i,newPropValue in ipairs(self._newPropTable) do
			-- QPrintTable(newPropValue)
			if self._isSmall and i > 5 then
				break
			end

			local Index_ = i - 1
			local choosePropTfConfig = {}
			local posIdx = newPropValue.replaceIndex
			for k,value in pairs(newPropValue.value or {}) do
				local str = value.name.."：+"..value.num
				if value.isMax then
					str = str.."（满）"
				end
				local color = COLORS[value.color]
				local strokeColor = getShadowColorByFontColor(color)
			 	table.insert(choosePropTfConfig, {oType = "font", content = str, size = 22, color = color, strokeColor = strokeColor})							
			end

			local widget = QUIWidgetMagicHerbQuickRefine.new()
			widget:setInfo(choosePropTfConfig , i , posIdx + 1,self._isSmall)
			widget:addEventListener(QUIWidgetMagicHerbQuickRefine.EVENT_CLICK_ATTR_SELECT, handler(self, self._onEvent))
			if self._showAction then
				widget:playAction()
				Index_ = posIdx
			end

			if self._isSmall then
				widget:setPosition( 0,((5 - Index_  ) * 60 + 8 ))
			else
				local num1,num2=math.modf(Index_ /2)
    			local n1 = num2 == 0 and 0 or 1
				widget:setPosition( n1 * 460 + 10,((5 - num1 ) * 60 + 2 ))
			end
			self._ccbOwner.sheet_layout:addChild(widget)
			widget:setSelectState(self._selectIndex)
			table.insert(self.widgets, widget)			
		end
	end
	if self._showAction then
		self:playAction()
	else
		self._actionEnd =  true
	end
end

function QUIDialogMagicHerbQuickRefine:handleData()

end

function QUIDialogMagicHerbQuickRefine:playAction()
	self._actionEnd = false
	if self._actionHandler ~= nil then
		self._ccbOwner.node_ui:stopAction(self._actionHandler)
		self._actionHandler = nil
	end

   	local dur = 0.15
	local dur1 = q.flashFrameTransferDur(10)
	local divDur = 7 * dur - dur1
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(divDur))
    arr:addObject(CCCallFunc:create(function()
    	local resAni = "fca/xpzs_1"
    	if self._isSmall then
    		resAni = "fca/xpzs_2"
    	end
		local fcaAnimation = QUIWidgetFcaAnimation.new(resAni, "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)
		self._ccbOwner.node_action:addChild(fcaAnimation)
    end))
    arr:addObject(CCDelayTime:create(dur1))
    arr:addObject(CCCallFunc:create(function()
   		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.sheet ,0,0)
    end))
    arr:addObject(CCDelayTime:create(0.05))
    arr:addObject(CCCallFunc:create(function()
   		for i,widget in ipairs(self.widgets) do
   			if self._isSmall then
   				widget:setPosition(0,((5 - i + 1) * 60 + 8 ))
   			else
				local num1,num2=math.modf((i - 1)/2)--返回整数和小数部分
    			local n1 = num2 == 0 and 0 or 1
				widget:setPosition( n1 * 460 + 10,((5 - num1 ) * 60 + 2 ))
			end
   		end
    end))
    arr:addObject(CCDelayTime:create(0.05))
    arr:addObject(CCCallFunc:create(function()
   		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.sheet ,dur,255)
   		self._actionEnd =  true
	end))
	
	self._actionHandler = CCSequence:create(arr)
	self._ccbOwner.node_ui:runAction(self._actionHandler)
end


function QUIDialogMagicHerbQuickRefine:_onEvent(event)
	if event.name == QUIWidgetMagicHerbQuickRefine.EVENT_CLICK_ATTR_SELECT then

		if self._selectIndex == event.chooseIndex then
			-- self._selectIndex = QUIDialogMagicHerbQuickRefine.SELECT_NULL
			-- self._newPropList = {}
			return
		else
			self._selectIndex = event.chooseIndex
			self._newPropList = self._newPropTable[self._selectIndex].value
		end

		for k,widget in pairs(self.widgets) do
			widget:setSelectState(self._selectIndex)
		end
	end
end


function QUIDialogMagicHerbQuickRefine:_onTriggerOK(event)
	app.sound:playSound("common_small")
	if not self._actionEnd then
		return
	end


	if self._selectIndex == QUIDialogMagicHerbQuickRefine.SELECT_NULL then
		app.tip:floatTip("请选择您需要替换的属性")
		return
	end

	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo or not magicHerbItemInfo.replaceAttributes then return end

	local oldPropList = self._propList
	local nowPropList = self._newPropList
	-- QPrintTable(self._newPropTable[self._selectIndex])
	if not self:_isPropBetter() then
		app:alert({content = "魂师大人，转生后的属性比当前的要低哦，是否确认替换？", title = "替换提示", 
			btns = {ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_OK},
	        callback = function(state)
	            if state == ALERT_TYPE.CONFIRM then
	                remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, true, self._newPropTable[self._selectIndex].replaceIndex, function()
								local callback = function()
									if self:safeCheck() then
										if self._successCb then
											self._successCb()
										end
										self:playEffectOut()
									end
								end
								app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuccess", 
									options = {sid = self._sid, oldPropList = oldPropList, nowPropList = nowPropList, callback = callback}})
						end)
	            end
	        end, isAnimation = false}, false, true)
	else
        remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, true,self._newPropTable[self._selectIndex].replaceIndex, function()
				local callback = function()
					if self:safeCheck() then
						if self._successCb then
							self._successCb()
						end
						self:playEffectOut()
					end
				end
				app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuccess", 
					options = {sid = self._sid, oldPropList = oldPropList, nowPropList = nowPropList, callback = callback}})
			end)
	end
end

function QUIDialogMagicHerbQuickRefine:_reset()
	self._showAction = true
	self._ccbOwner.sheet_layout:removeAllChildren()
end

-- 继续十连或五连
function QUIDialogMagicHerbQuickRefine:_refresh()

	remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, false, 0, function()
		if self:safeCheck() then
			if self._successCb then
				self._successCb()
			end
		end
	end)

	remote.magicHerb:magicHerbRefineRequest(self._sid, self._lockIndex, true, function()
		self:_reset()
		if self._continueCb then
			self:_continueCb()
		end
		self:setInfo()
	end)
end

function QUIDialogMagicHerbQuickRefine:_onTriggerContinue()
	app.sound:playSound("common_small")
	if not self._actionEnd then
		return
	end

	local num = remote.items:getItemsNumByID(self._itemId)
	if num >= self._needNum then
		self:_refresh()
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, nil, nil, nil, nil, false)
	end
end

function QUIDialogMagicHerbQuickRefine:_onTriggerCancel(event)
	app.sound:playSound("common_small")
	if not self._actionEnd then
		return
	end

	if self:_isPropBetter() then

		app:alert({content = "魂师大人，转生后的属性比当前的要高哦，是否放弃替换？", title = "放弃提示", 
			btns = {ALERT_BTN.BTN_CANCEL, ALERT_BTN.BTN_OK},
	        callback = function(state)
	            if state == ALERT_TYPE.CONFIRM then
	               	remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, false, 0,  
	               		function()
	               			if self:safeCheck() then
								if self._successCb then
									self._successCb()
								end
								self:playEffectOut()
							end
						end)
	            end
	        end, isAnimation = false}, false, true)

	else
		remote.magicHerb:magicHerbReplaceAttributesRequest(self._sid, false, 0,  function()
				if self:safeCheck() then
					if self._successCb then
						self._successCb()
					end
					self:playEffectOut()
				end
			end)
	end
end

function QUIDialogMagicHerbQuickRefine:_isPropBetter()
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

	-- local countColorTable = { A = 1 ,B = 2 ,C = 3 ,D = 4 ,E = 5 ,F = 6 ,G = 7 }
	-- local colorStr = ""
	-- local num = 0
	-- local maxNewProp = {}
	-- local newcountColor = 0
	-- for _, prop in ipairs(newProp) do
	-- 	prop.num = string.gsub(prop.num, "%%", "")
	-- 	newcountColor = newcountColor + countColorTable[prop.color]

	-- 	if colorStr == "" or countColorTable[colorStr] < countColorTable[prop.color] then
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
	-- oldcountColor = 0
	-- for _, prop in ipairs(oldProp) do
	-- 	prop.num = string.gsub(prop.num, "%%", "")
	-- 	oldcountColor = oldcountColor + countColorTable[prop.color]
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

	-- if maxNewProp.color < maxOldProp.color or  newcountColor <= oldcountColor then
	-- 	return false
	-- end
	-- return true
end

function QUIDialogMagicHerbQuickRefine:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMagicHerbQuickRefine:_onTriggerClose(event)
  	-- app.sound:playSound("common_close")
	-- self:playEffectOut()

	self:_onTriggerCancel(event)
end

function QUIDialogMagicHerbQuickRefine:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end


return QUIDialogMagicHerbQuickRefine