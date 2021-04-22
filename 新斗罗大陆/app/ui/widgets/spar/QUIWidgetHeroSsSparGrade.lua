local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSsSparGrade = class("QUIWidgetHeroSsSparGrade", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetSparBox = import("...widgets.spar.QUIWidgetSparBox")
local QQuickWay = import("....utils.QQuickWay")
local QUIHeroModel = import("....models.QUIHeroModel")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSparPieceBox = import("...widgets.QUIWidgetSparPieceBox")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetFcaAnimation = import("...widgets.actorDisplay.QUIWidgetFcaAnimation")


QUIWidgetHeroSsSparGrade.EVENT_SS_SPAR_GRADE_NOT_STAR ="EVENT_SS_SPAR_GRADE_NOT_STAR"	--升星 没有多星星

function QUIWidgetHeroSsSparGrade:ctor(options)
	local ccbFile = "ccb/Widget_Ss_spar_grade.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGrade", callback = handler(self, self._onTriggerGrade)},
		{ccbCallbackName = "onTriggerInspect", callback = handler(self, self._onTriggerInspect)}
	}
	QUIWidgetHeroSsSparGrade.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_break)
	self.materials = {}
	self._costType = 0
	self._isPlayingActiton = false
	self._iconPos = ccp(self._ccbOwner.sp_spar_icon:getPositionX(),self._ccbOwner.sp_spar_icon:getPositionY())
end

function QUIWidgetHeroSsSparGrade:onEnter()
	self:initAction() 

end

function QUIWidgetHeroSsSparGrade:onExit()
   
end

function QUIWidgetHeroSsSparGrade:initAction()
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(1, ccp(self._iconPos.x,self._iconPos.y + 10)))
	arr:addObject(CCMoveTo:create(1, self._iconPos))
	self._ccbOwner.sp_spar_icon:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end 

function QUIWidgetHeroSsSparGrade:setInfo(actorId,sparId,index)
	if self._actorId~= actorId then
		self._isPlayingActiton = false
	end
	self._actorId = actorId
	self._sparId = sparId
	self._index = index

	self:updateSparInfo()
end

function QUIWidgetHeroSsSparGrade:updateSparInfo()

	if self._isPlayingActiton then
		return
	end

	local heroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	self._sparInfo = heroModle:getSparInfoByPos(self._index).info or {}
	self._itemConfig = db:getItemByID(self._sparInfo.itemId)
	self._ccbOwner.tf_spar_name:setString(self._itemConfig.name or "")

	local fontColor = EQUIPMENT_COLOR[self._itemConfig.colour]
	self._ccbOwner.tf_spar_name:setColor(fontColor)
	self._ccbOwner.tf_spar_name = setShadowByFontColor(self._ccbOwner.tf_spar_name, fontColor)

	if self._sparBox == nil then
		self._sparBox = QUIWidgetSparBox.new()
		self._ccbOwner.node_spar_icon:addChild(self._sparBox)
		self._sparBox:setNameVisible(false)
	end
	self._sparBox:setGemstoneInfo(self._sparInfo, self._index)
	self._sparBox:hideSabc()
	self._sparBox:setStrengthVisible(false)

	local gradeConfig1 = db:getGradeByHeroActorLevel(self._sparInfo.itemId, self._sparInfo.grade)
	local gradeConfig2 = db:getGradeByHeroActorLevel(self._sparInfo.itemId, self._sparInfo.grade+1)
	self._ccbOwner.node_max:setVisible(false)
	self._ccbOwner.node_normal:setVisible(false)


	local line = self._sparInfo.grade % 5
	-- if line == 0 and self._sparInfo.grade > 0 then
	-- 	line = 5
	-- end
	for i=1,5 do
		self._ccbOwner["node_star_effect_"..i]:setVisible(i <= line)
	end		
	self._ccbOwner.node_not_full:setVisible(true)
	self._ccbOwner.node_full:setVisible(false)
	self._ccbOwner.node_grade_effect:setVisible(false)




	if gradeConfig2 == nil then--已经升星到顶级了
		self._ccbOwner.node_max:setVisible(true)
		self:setSparPropInfo("max",gradeConfig1)
		self._ccbOwner.node_full:setVisible(true)
		self._ccbOwner.node_not_full:setVisible(false)

   	 	local frame =QSpriteFrameByPath(QResPath("ss_spar_icon")[tostring(self._sparInfo.itemId)])
	    if frame then
	    	self._ccbOwner.sp_spar_icon:setVisible(true)
	        self._ccbOwner.sp_spar_icon:setDisplayFrame(frame)
	    end
		return
	end

	self._ccbOwner.node_normal:setVisible(true)
	self:setSparPropInfo("old",gradeConfig1)
	self:setSparPropInfo("new",gradeConfig2)

	--金币
	self._needMoney = gradeConfig2.money or 0

	if self._needMoney > 0 then
		self._ccbOwner.tf_money:setVisible(true)
		self._ccbOwner.icon_money:setVisible(true)

		self._ccbOwner.tf_money:setString(self._needMoney)
		if self._needMoney > remote.user.money then
			self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_money:setColor(COLORS.k)
		end
	else
		self._ccbOwner.tf_money:setVisible(false)
		self._ccbOwner.icon_money:setVisible(false)
	end

	self._ccbOwner.node_item:removeAllChildren()
	self._sparItem = nil
	--突破所需材料
	if gradeConfig2.soul_gem ~= nil then
		local itemId = gradeConfig2.soul_gem
		itemId = gradeConfig2.soul_gem
		local itemConfig = db:getItemByID(itemId)
		-- QPrintTable(gradeConfig2)
		if itemConfig then 
			-- QPrintTable(itemConfig)
			self._needMateril = {info = {itemId = itemId, grade = 0, content = ""}, needNum = gradeConfig2.soul_gem_count}

			local haveNum, isStrength = remote.spar:checkSparCanUpGrade(self._sparInfo.sparId, self._index)
			self._costType = itemConfig.category
			if itemConfig.category == ITEM_CONFIG_CATEGORY.SPAR_PIECE then
				if self._sparItem == nil then
					self._sparItem = QUIWidgetSparPieceBox.new()
					self._ccbOwner.node_item:addChild(self._sparItem)
					self._sparItem:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._itemClickHandler))
					self._sparItem:setScale(0.6)
				end
				self._sparItem:setGoodsInfo( itemId , ITEM_TYPE.SPAR_PIECE ,"",false,false)
				self._sparItem:setName("")
				print("QUIWidgetSparPieceBox")
			elseif itemConfig.category ==ITEM_CONFIG_CATEGORY.SPAR then	
				if self._sparItem == nil then
					self._sparItem = QUIWidgetSparBox.new()
					self._ccbOwner.node_item:addChild(self._sparItem)
					self._sparItem:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self._itemClickHandler))
					self._sparItem:setScale(0.6)
					self._sparItem:setNameVisible(false)
				end
				self._sparItem:setGemstoneInfo(self._needMateril.info, self._index)
			end


			self._ccbOwner.tf_need_num:setString("/"..(self._needMateril.needNum or 0))
			self._ccbOwner.tf_have_num:setString(haveNum)

			if haveNum >= self._needMateril.needNum then
				self._ccbOwner.tf_need_num:setColor(UNITY_COLOR.green)
				self._ccbOwner.tf_have_num:setColor(UNITY_COLOR.green)
			else
				self._ccbOwner.tf_need_num:setColor(UNITY_COLOR.red)
				self._ccbOwner.tf_have_num:setColor(UNITY_COLOR.red)
			end
		end
	end


	if line == 4 then
		self._ccbOwner.node_grade_effect:setVisible(self:_checkCanGrade())
		-- self._ccbOwner.tf_button_name:setString("升 星")
	else
		-- self._ccbOwner.tf_button_name:setString("神 炼")
	end

end

function QUIWidgetHeroSsSparGrade:playEffectAction(gradeAdd)

	local line = gradeAdd % 5
	if line == 0 then
		return
	end

	self._ccbOwner["node_star_effect_"..line]:setScale(0.1)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.3, 1.5))
	arr:addObject(CCScaleTo:create(0.3, 1.0))
	self._ccbOwner["node_star_effect_"..line]:stopAllActions()
	self._ccbOwner["node_star_effect_"..line]:runAction(CCSequence:create(arr))

	self:addFcaAni(self._ccbOwner["node_star_effect_"..line], 1)
	app.sound:playSound("gem_drop")
end

function QUIWidgetHeroSsSparGrade:addFcaAni(node , type)

	if node == nil  then 
		return
	end 

    local buildAni = QResPath("ss_spar_grade_ani")[type]
    if buildAni then
        local fcaAnimation = QUIWidgetFcaAnimation.new(buildAni, "res")
        node:addChild(fcaAnimation)
        --fcaAnimation:setTransformColor(ccc3(0, 255, 255))
        fcaAnimation:playAnimation("animation", false)
        fcaAnimation:setEndCallback(function( )
            fcaAnimation:removeFromParent()
        end)
    end
end


function QUIWidgetHeroSsSparGrade:playGradeUpEffectAction(oldSparInfo)
	self._isPlayingActiton = true
	local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local newSparInfo = newUIModel:getSparInfoByPos(self._index).info
	local grade = newSparInfo.grade
	print("	playGradeUpEffectAction grade 	:"..grade)
	for i=1,5 do
		self._ccbOwner["node_star_effect_"..i]:setVisible(true)
	end			
	if self._sparBox then
		self._sparBox:setStar(grade)
	end
	local dur = q.flashFrameTransferDur(5)
	local dur2 = q.flashFrameTransferDur(25)
	local dur3 = q.flashFrameTransferDur(10)
    local arr = CCArray:create()
  	for i=1,5 do
	    arr:addObject(CCCallFunc:create(function()
			self:addFcaAni(self._ccbOwner["node_star_effect_"..i] , 1)
	    end))
	    arr:addObject(CCDelayTime:create(dur))
  	end
    arr:addObject(CCCallFunc:create(function()
		self:addFcaAni(self._ccbOwner.node_fca_effect , 2)
    end))
	arr:addObject(CCDelayTime:create(dur2))
    arr:addObject(CCCallFunc:create(function()
		for i=1,5 do
			self._ccbOwner["node_star_effect_"..i]:setVisible(false)
		end			
		if self._sparBox then
			self._sparBox:setStar(grade + 1)
		end    	
    end))
	arr:addObject(CCDelayTime:create(dur3))
    arr:addObject(CCCallFunc:create(function()
    	self._isPlayingActiton = false
    	self:updateSparInfo()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSparUpGradeSuccess", 
	        	options = {oldSparInfo = oldSparInfo, newSparInfo = newSparInfo, pos = self._index, actorId = self._actorId, callback = handler(self, self._checkSuitIsActive)}}
	        	, {isPopCurrentDialog = false})	 	
    end))

    self._ccbOwner.node_fca_effect:stopAllActions()
    self._ccbOwner.node_fca_effect:runAction(CCSequence:create(arr))

end


function QUIWidgetHeroSsSparGrade:setSparPropInfo(typeStr,gradeConfig)

	local propDesc = remote.spar:setPropInfo(gradeConfig)
	local grade = gradeConfig.grade_level or 0

	local cnDesc = {"零","一","二","三","四","五"}
	if grade == 0 then
		self._ccbOwner["tf_"..typeStr.."_star_name"]:setString("【零星】")
	else
		local idx = math.floor( grade  / 5) + 1
		local line = grade % 5
		if line == 0 then
			self._ccbOwner["tf_"..typeStr.."_star_name"]:setString("【"..cnDesc[idx].."星】")
		else
			self._ccbOwner["tf_"..typeStr.."_star_name"]:setString("【"..cnDesc[idx].."星+"..line.."】")
		end
	end

	for i=1,4 do
		local  prop = propDesc[i]
		self._ccbOwner["tf_"..typeStr.."_name"..i]:setString((prop.name or "").."：")
		self._ccbOwner["tf_"..typeStr.."_value"..i]:setString("+"..(prop.value or ""))
	end
end


function QUIWidgetHeroSsSparGrade:_onTriggerGrade(event)
	if self._isPlayingActiton then return end 

	if self._needMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end

	local haveNum, isStrength, strengthCount = remote.spar:checkSparCanUpGrade(self._sparInfo.sparId, self._index)
	if haveNum < self._needMateril.needNum then

		if self._costType == ITEM_CONFIG_CATEGORY.SPAR then

			local pieceInfo = db:getItemCraftByItemId(self._needMateril.info.itemId)
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", 
						options = {tab = "TAB_SPAR_PIECE", selectItem = pieceInfo.component_id_1}})
		else
			local needNum = self._needMateril.needNum - haveNum
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
			    		options = {id = self._needMateril.info.itemId, count = needNum}}, {isPopCurrentDialog = false})
		end
		return
	end

	if isStrength and self._costType == ITEM_CONFIG_CATEGORY.SPAR then
    	app:alert({content="升星所用的一星外附魂骨中有"..strengthCount.."个被强化，继续升星则自动将强化经验转换成强化材料放进背包，是否继续升星？", 
    			btnDesc = {"升 星"}, title = "系统提示", callback = handler(self, self._upgrade) })
    else
    	self:_upgrade()
	end
end

function QUIWidgetHeroSsSparGrade:_onTriggerInspect(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_inspect) == false then return end

	app.sound:playSound("common_common")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSsSparGradeRule"})
end

function QUIWidgetHeroSsSparGrade:_checkCanGrade()
	if self._needMoney > remote.user.money then
		return false
	end

	local haveNum, isStrength, strengthCount = remote.spar:checkSparCanUpGrade(self._sparInfo.sparId, self._index)
	if haveNum < self._needMateril.needNum then
		return false

	end
	return true
end


function QUIWidgetHeroSsSparGrade:_upgrade(callType)
	if callType == nil or callType == ALERT_TYPE.CONFIRM then
		local oldSparInfo = self._sparInfo
		self._oldSuit = self:getSparInfoByActorId(self._actorId)
		local oldgrade = self._sparInfo.grade
		oldgrade = oldgrade + 1
		self._isPlayingActiton = ( oldgrade % 5 == 0 ) and oldgrade > 0
		remote.spar:requestSparUpgrade(self._sparId , function ()
				local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
				local newSparInfo = newUIModel:getSparInfoByPos(self._index).info
				local grade = newSparInfo.grade
				if ( grade % 5 == 0 ) and grade > 0 then
					self:playGradeUpEffectAction(oldSparInfo)
					-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSparUpGradeSuccess", 
			  --       	options = {oldSparInfo = oldSparInfo, newSparInfo = newSparInfo, pos = self._index, actorId = self._actorId, callback = handler(self, self._checkSuitIsActive)}}
			  --       	, {isPopCurrentDialog = false})
				else
					QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroSsSparGrade.EVENT_SS_SPAR_GRADE_NOT_STAR, options = {itemId = newSparInfo.itemId, grade = grade}})
				end
	    	end)
	end
end


function QUIWidgetHeroSsSparGrade:_checkSuitIsActive()
    local suits = self:getSparInfoByActorId(self._actorId)
    -- QPrintTable(suits)
    local isHaveSuit = false
    if next(self._oldSuit) ~= nil then
		if self._oldSuit.id == suits.id and self._oldSuit.star_min == suits.star_min then
			isHaveSuit = true
		end
    end
    
    local successTip = app.master.SPAR_BREAK_TIP
    if next(suits) ~= nil and isHaveSuit == false and app.master:getMasterShowState(successTip) then
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparSuitActiveSuccess", 
            options = {suitInfo = suits,successTip = successTip, actorId = self._actorId}}, {isPopCurrentDialog = false})
    end
    
	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
end

function QUIWidgetHeroSsSparGrade:getSparInfoByActorId(actorId)
    local suits = {}
	local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local sparInfo1 = newUIModel:getSparInfoByPos(1).info
	local sparInfo2 = newUIModel:getSparInfoByPos(2).info
	local minGrade = newUIModel:getHeroSparMinGrade()
	if sparInfo1 ~= nil and sparInfo2 ~= nil then
    	print("minGrade  	"..minGrade)
		suits = db:getActiveSparSuitInfoBySparId(sparInfo1.itemId, sparInfo2.itemId, minGrade)
	end
	return suits
end

function QUIWidgetHeroSsSparGrade:_itemClickHandler(event)
	app.sound:playSound("common_item")
	if self._costType == ITEM_CONFIG_CATEGORY.SPAR then
		local pieceInfo = db:getItemCraftByItemId(self._needMateril.info.itemId)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", 
				options = {tab = "TAB_SPAR_PIECE", selectItem = pieceInfo.component_id_1}})
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._needMateril.info.itemId, nil, nil, false)
	end
end


return QUIWidgetHeroSsSparGrade