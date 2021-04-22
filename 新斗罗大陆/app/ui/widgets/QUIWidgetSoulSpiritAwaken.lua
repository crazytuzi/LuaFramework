
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritAwaken = class("QUIWidgetSoulSpiritAwaken", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QUIWidgetSoulSpiritEffectBox = import(".QUIWidgetSoulSpiritEffectBox")

QUIWidgetSoulSpiritAwaken.NEW_TYPE_STRING = "new"
QUIWidgetSoulSpiritAwaken.OLD_TYPE_STRING = "old"
QUIWidgetSoulSpiritAwaken.MAX_TYPE_STRING = "max"

QUIWidgetSoulSpiritAwaken.DESC ="出战属性+"

function QUIWidgetSoulSpiritAwaken:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_Awaken.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAwaken", callback = handler(self, self._onTriggerAwaken)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
	}
	QUIWidgetSoulSpiritAwaken.super.ctor(self,ccbFile,callBacks,options)
    q.setButtonEnableShadow(self._ccbOwner.btn_awaken)
    q.setButtonEnableShadow(self._ccbOwner.btn_info)
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
	self.materials= {}
	self._Awakening = false
end

function QUIWidgetSoulSpiritAwaken:onEnter()
	QUIWidgetSoulSpiritAwaken.super.onEnter(self)

end

function QUIWidgetSoulSpiritAwaken:onExit()
	QUIWidgetSoulSpiritAwaken.super.onExit(self)
    -- if self._canEvolutionScheduler then
    -- 	scheduler.unscheduleGlobal(self._canEvolutionScheduler)
    -- 	self._canEvolutionScheduler = nil
    -- end


end

function QUIWidgetSoulSpiritAwaken:resetAll()
	if self.materials ~= nil and #self.materials > 0 then
		for _,item in ipairs(self.materials) do
			item:removeAllEventListeners()
			item:removeFromParent()
		end
		self.materials = {}
	end

	self._needMoney = 0
	self._isMaterilEnough = true
end


function QUIWidgetSoulSpiritAwaken:setInfo(id, heroId)
	if not id and not heroId then
        return
    elseif id and heroId then
        self._id = id
        self._heroId = heroId
    elseif id then
        self._id = id
        self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = self._soulSpiritInfo and self._soulSpiritInfo.heroId or 0
    elseif heroId then
        self._heroId = heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        self._soulSpiritInfo = heroInfo.soulSpirit
        self._id = self._soulSpiritInfo and self._soulSpiritInfo.id or 0
    end

    self:updateInfo()
    
    if remote.soulSpirit:isAwakenRedTipsById(self._id) and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SOUL_SPIRIT_AWAKEN) then 
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SOUL_SPIRIT_AWAKEN)
	end
end

function QUIWidgetSoulSpiritAwaken:updateInfo()
	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)

    if self._soulSpiritInfo == nil then
    	return
    end
    self._characterConfig = db:getCharacterByID(self._id)
    self:resetAll()

    local quality = self._characterConfig.aptitude
    local curLv= self._soulSpiritInfo.awaken_level or 0
	local maxLevel = remote.soulSpirit:getSoulSpiritAwakenConfigMaxLevel(quality)
	if curLv > 0 then
		self._ccbOwner.btn_reset:setVisible(true)
		self._ccbOwner.btn_info:setPositionX(200)		
	else
		self._ccbOwner.btn_reset:setVisible(false)
		self._ccbOwner.btn_info:setPositionX(238)
	end
	print("quality"..quality)
	print("curLv"..curLv)
	print("maxLevel"..maxLevel)
	if curLv < maxLevel then
		self:showInfo(curLv)
		self._ccbOwner.btn_reset:setPosition(ccp(528,-285))
	else
		self:showMaxInfo(maxLevel)
		self._ccbOwner.btn_reset:setPosition(ccp(528,-188))
	end
end


function QUIWidgetSoulSpiritAwaken:showInfo(curLv)
	local nextLv = curLv + 1
	self._ccbOwner.node_max_prop:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)
	self._ccbOwner.node_old:setVisible(true)
	self._ccbOwner.node_new:setVisible(true)
	self._ccbOwner.node_normal:setVisible(true)
	local quality = self._characterConfig.aptitude

	local curLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(curLv,quality)
	local nextLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(nextLv,quality)
	if not curLvMod or not nextLvMod then
		return
	end

	self:_updateDisplayNode(QUIWidgetSoulSpiritAwaken.OLD_TYPE_STRING , curLvMod)
	self:_updateDisplayNode(QUIWidgetSoulSpiritAwaken.NEW_TYPE_STRING , nextLvMod)

	--觉醒所需钱
	-- self._needMoney = breakconfig2.price or 0
	self._needMoney = 0
	self._ccbOwner.tf_money:setString(self._needMoney)


	--觉醒所需材料
	local items = {}
	remote.items:analysisServerItem(nextLvMod.item, items)
	-- QPrintTable(items)
	self._ccbOwner.node_cost_icon:removeAllChildren()

	local posX = -(#items - 1) * 153/2
	local itemBox = nil
	self._needMateril = nil
	for index,item in ipairs(items) do
		itemBox = QUIWidgetHeroEquipmentEvolutionItem.new()
		itemBox:setPositionX(posX)
		itemBox:setTextOffsideY(10)
		itemBox:setScale(0.9)
		itemBox:addEventListener(QUIWidgetHeroEquipmentEvolutionItem.EVENT_CLICK, handler(self, self._itemClickHandler))
		itemBox:setInfo(item.id, item.count, item.type)
		self._ccbOwner.node_cost_icon:setVisible(true)
		self._ccbOwner.node_cost_icon:addChild(itemBox)
		table.insert(self.materials, itemBox)
		posX = posX + 153
		if self._isMaterilEnough == true then
			self._isMaterilEnough = itemBox:isEnough()
			if self._isMaterilEnough == false then
				self._needMateril = item
			end
		end
	end
end

function QUIWidgetSoulSpiritAwaken:showMaxInfo(maxLevel)
	local quality = self._characterConfig.aptitude

	local maxLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(maxLevel,quality)

	self._ccbOwner.node_max_prop:setVisible(true)
	self._ccbOwner.node_max:setVisible(true)
	self._ccbOwner.node_old:setVisible(false)
	self._ccbOwner.node_new:setVisible(false)
	self._ccbOwner.node_normal:setVisible(false)

	if maxLvMod then
		self:_updateDisplayNode(QUIWidgetSoulSpiritAwaken.MAX_TYPE_STRING , maxLvMod)
	end
end

function QUIWidgetSoulSpiritAwaken:_updateDisplayNode(_typeStr,_lvMod)

	self._ccbOwner["node_".._typeStr.."_icon"]:removeAllChildren()

	local curItemAvatar = QUIWidgetSoulSpiritEffectBox.new()
	curItemAvatar:setInfo(self._id,true)
	curItemAvatar:setStarNum(self._soulSpiritInfo.grade)
	self._ccbOwner["node_".._typeStr.."_icon"]:addChild(curItemAvatar)
	--itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel,1.0,advancedLevel) --需要时装魂灵avatar


	self._ccbOwner["tf_".._typeStr.."_prop_name"]:setString(QUIWidgetSoulSpiritAwaken.DESC )
	self._ccbOwner["tf_".._typeStr.."_prop_value"]:setString(q.PropPercentHanderFun(_lvMod.conmbat_succession))
	self._ccbOwner["tf_".._typeStr.."_name"]:setString(self._characterConfig.name .."+".._lvMod.level )
	local color = COLORS.B
    for _,value in ipairs(HERO_SABC) do
        if value.aptitude == self._characterConfig.aptitude then
            color = value.colour3
        end
    end	
    local colorInfo = nil
    for _,value in ipairs(FONTCOLOR_TO_OUTLINECOLOR) do
        if value.fontColor == color then
            colorInfo = value
        end
    end	

	if colorInfo then
		self._ccbOwner["tf_".._typeStr.."_name"]:setColor(colorInfo.fontColor)
		self._ccbOwner["tf_".._typeStr.."_name"]:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner["tf_".._typeStr.."_name"]:enableOutline()
	end


	--适配
	self._ccbOwner["tf_".._typeStr.."_prop_value"]:setPositionX(self._ccbOwner["tf_".._typeStr.."_prop_name"]:getPositionX()
	 + self._ccbOwner["tf_".._typeStr.."_prop_name"]:getContentSize().width)
end

function QUIWidgetSoulSpiritAwaken:quickWayHandler(id, itemType, count)
	if itemType ~= ITEM_TYPE.ITEM then
		local dropType = nil
		if itemType == ITEM_TYPE.THUNDER_MONEY then
			dropType = ITEM_TYPE.THUNDER_MONEY
		elseif itemType == ITEM_TYPE.ARENA_MONEY then
			dropType = ITEM_TYPE.ARENA_MONEY
		end
		if dropType ~= nil then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, dropType)
    	end
		return
	end 

	-- if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 then
	-- 	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, id, count)
	-- elseif self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
	-- 	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, id, count)
	-- else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
    		options = {id = id, count = count}}, {isPopCurrentDialog = false})
	-- end
end

function QUIWidgetSoulSpiritAwaken:_itemClickHandler(event)
	app.sound:playSound("common_item")
	self:quickWayHandler(event.itemID, event.itemType, event.needNum)
end

function QUIWidgetSoulSpiritAwaken:_onTriggerAwaken(e)
	app.sound:playSound("common_small")

	if self._Awakening  then 
		app.tip:floatTip("正在觉醒中～")
		return 
	end

	if self._isMaterilEnough == false then
		print("self._isMaterilEnough == false")
		self:quickWayHandler(self._needMateril.id, ITEM_TYPE.ITEM , self._needMateril.count)
		return 
	end

	local soulSpiritId = self._id
	self._Awakening = true
	remote.soulSpirit:soulSpiritAwakenRequest(soulSpiritId, function(data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritAwakenSuccess",
				options = {id = soulSpiritId , callback = function ()
					-- remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    			self:updateInfo()
				self._Awakening = false	
				end}},{isPopCurrentDialog = false})
		end, function(data)
			self._Awakening = false	
		end)
	-- self._canEvolutionScheduler = scheduler.performWithDelayGlobal(function()
	-- 		self._Awakening = false
	-- 	end, 1)
end

function QUIWidgetSoulSpiritAwaken:_onTriggerInfo(e)
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritAwakenSkillInfo", 
        options = {id = self._id}})
end

function QUIWidgetSoulSpiritAwaken:resetSoulSpritAwaken( )

	local soulSpiritId = self._id
	local curLv= self._soulSpiritInfo.awaken_level or 0
	local quality = self._characterConfig.aptitude
	local items = {}
	for ii=0,curLv do
		local curLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(ii,quality)
		remote.items:analysisServerItem(curLvMod.item, items)
	end
	

	self._Awakening = true
	remote.soulSpirit:resetSoulSpiritAwakenRequest(soulSpiritId, function(data)

		self:updateInfo()
		self._Awakening = false	
		-- 更新背包
		local wallet = {}
		wallet.money = data.money
		wallet.token = data.token
		remote.user:update( wallet )
		if data.items then remote.items:setItems(data.items) end
		-- -- 展示奖励页面
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
    		options = {awards = items, callBack = function()
    		end}}, {isPopCurrentDialog = false} )
		dialog:setTitle("魂灵觉醒摘除返还以下道具")
	end,function(data)
			self._Awakening = false	
	end)
end
function QUIWidgetSoulSpiritAwaken:_onTriggerReset( )
	app.sound:playSound("common_small")
	local costToken = db:getConfigurationValue("HUNLING_DEMOLITION_RETURN")
	if remote.user.token < costToken then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
	else
		local contentStr = string.format("##n花费##e%d钻石##n，摘除这个魂灵上的##e所有觉醒神木##n？确认后，返还##e全部觉醒神木##n。",costToken)
		app:alert({content = contentStr, title = "系统提示", 
	        callback = function(callType)
	        	if callType == ALERT_TYPE.CONFIRM then
	            	self:resetSoulSpritAwaken()
	            end
	        end, isAnimation = true, colorful = true}, true, true)
	end
end

return QUIWidgetSoulSpiritAwaken