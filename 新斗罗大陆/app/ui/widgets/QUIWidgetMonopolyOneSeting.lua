-- @Author: liaoxianbo
-- @Date:   2019-07-22 12:30:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-16 14:50:58
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonopolyOneSeting = class("QUIWidgetMonopolyOneSeting", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetMonopolyOneSeting.EVENT_ONE_SELECT_CLICK = "EVENT_ONE_SELECT_CLICK"
QUIWidgetMonopolyOneSeting.EVENT_ONE_SETTING_CLICK = "EVENT_ONE_SETTING_CLICK"

function QUIWidgetMonopolyOneSeting:ctor(options)
	--这里使用的ccb应该是和小舞助手一样的 Widget_Secretary_client2，但是UI翻新的关系新增 Widget_Secretary_client3
	--等冰火翻新的时候可以直接换回 Widget_Secretary_client2
	local ccbFile = "ccb/Widget_Secretary_client3.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerSet", callback = handler(self, self._onTriggerSet)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIWidgetMonopolyOneSeting.super.ctor(self, ccbFile, callBacks, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_go)
  	q.setButtonEnableShadow(self._ccbOwner.btn_set)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._nameMaxSize = 90
	self._setType = nil
end

function QUIWidgetMonopolyOneSeting:setSelected(bSelected)
	self._ccbOwner.sp_select:setVisible(bSelected)
end

function QUIWidgetMonopolyOneSeting:setInfo(info)
	self:resetAll()

	self._info = info
	self._ccbOwner.tf_name:setString(info.name or "")

	self._ccbOwner.node_select:setVisible(true)
	-- icon
	local icon = CCSprite:create(info.icon)
	icon:setScale(86/icon:getContentSize().width)
    self._ccbOwner.node_icon:addChild(icon)

    -- 设置开启
	local isOpen = self._info.havesetbtn or false
	self._ccbOwner.node_btn_set:setVisible(isOpen)
	self._ccbOwner.tf_set_desc:setVisible(isOpen)
	self._ccbOwner.tf_set_desc:setString("")

	local curSetting = remote.monopoly:getOneSetMonopolyId(self._info.tabId) 
	local isOpen = curSetting.isOpen or false
	self:setSelected(isOpen)

	local isSubOpen = curSetting.isSubOpen or false

	local haveContent = self._info.haveContent
	if haveContent then
		self._ccbOwner.node_rank:setVisible(true)
		self._ccbOwner.tf_rank_name:setString("仙品管家:")
		
		if self._info.type == remote.monopoly.ZIDONG_OPEN then
			-- 开箱次数
			local xpgjopen = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_OPEN)
			if xpgjopen then
				if curSetting.openNum and curSetting.openNum > 1 then
					self._ccbOwner.tf_rank:setString("开箱"..curSetting.openNum.."次")					
				else
					local setconfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_OPEN)
	    			if setconfig and setconfig.openNum then
	    				self._ccbOwner.tf_rank:setString("开箱"..setconfig.openNum.."次")
	    			else
	    				self._ccbOwner.tf_rank:setString("免费一次")
	    			end
				end
			else
				self._ccbOwner.tf_rank:setString("未开启(默认开1次)")
			end
		end
		if self._info.type == remote.monopoly.ZIDONG_CAIQUAN then
			-- 猜拳次数
			local xpgjopen = remote.monopoly:getIsSettingOpen(remote.monopoly.ZIDONG_CAIQUAN)
			if xpgjopen then
				if curSetting.caiQuanNum then
					self._ccbOwner.tf_rank:setString("猜拳"..curSetting.caiQuanNum.."次")	
				else
				    local setconfig = remote.monopoly:getSelectByMonopolyId(remote.monopoly.ZIDONG_CAIQUAN)
					if setconfig and setconfig.caiQuanNum then
						self._ccbOwner.tf_rank:setString("猜拳"..setconfig.caiQuanNum.."次")	
					else
						self._ccbOwner.tf_rank:setString("猜拳1次")
					end				
				end
			else
				self._ccbOwner.tf_rank:setString("未开启(默认猜1次)")
			end
		end

		if self._info.type == remote.monopoly.ZIDONG_LEVELUP then
			self._ccbOwner.tf_rank:setString("")
			self._ccbOwner.tf_rank_name:setString("勾选后将自动升级")
		end
		if self._info.type == remote.monopoly.ZIDONG_LIANYAO then
			self._ccbOwner.node_select:setVisible(false)
			self._ccbOwner.tf_rank:setString("")
			self._ccbOwner.tf_rank_name:setString("一键投掷中默认开启")
		end
		self._ccbOwner.tf_name:setPositionY(-44)
	else
		self._ccbOwner.tf_name:setPositionY(-66)
	end

	if self._info.tabId == 1 then  --大奖领取设置
		self._setType = remote.monopoly.MONOPOLY_GETAWARS
		self._ccbOwner.node_select:setVisible(false)
		local finalAwardType = curSetting.finalAwardType

		local saveItemInfo = remote.monopoly:getLuckyDrawByKey(curSetting.finalSaveId)
		if saveItemInfo then
			if saveItemInfo.id_1 == remote.monopoly.mainHeroItemId then
				saveItemInfo.id_1 = remote.monopoly:getMainHeroSoulItemId()
			end
			if saveItemInfo.type_1 == "item" then
				local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(saveItemInfo.id_1)
				if itemInfo then
					self._ccbOwner.tf_set_desc:setString(itemInfo.name or "")
				end
			else
				local currencyInfo = remote.items:getWalletByType(saveItemInfo.type_1)
				if currencyInfo then
					self._ccbOwner.tf_set_desc:setString(currencyInfo.nativeName or "")
				end
			end	
		else
			self._ccbOwner.tf_set_desc:setString("尚未设置")
		end
	end

	if self._info.tabId == 2 then  --购买次数设置
		self._setType = remote.monopoly.MONOPOLY_BUYNUM_CHEAST
		if curSetting.buyNum then
			self._ccbOwner.tf_set_desc:setString("购买"..curSetting.buyNum.."次")
		else
			self._ccbOwner.tf_set_desc:setString("购买1次")
		end
	end
end

function QUIWidgetMonopolyOneSeting:_onTriggerSelect()
    app.sound:playSound("common_switch")
    local checkState = self._ccbOwner.sp_select:isVisible()
    self:setSelected(not checkState)
	self:dispatchEvent({name = QUIWidgetMonopolyOneSeting.EVENT_ONE_SELECT_CLICK, id = self._info.tabId})
end

function QUIWidgetMonopolyOneSeting:_onTriggerSet()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetMonopolyOneSeting.EVENT_ONE_SETTING_CLICK, id = self._info.tabId,setType = self._setType})
end

function QUIWidgetMonopolyOneSeting:_onTriggerGo()
end

function QUIWidgetMonopolyOneSeting:resetAll()
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_select:setVisible(false)
	self._ccbOwner.node_ok:setVisible(false)
	self._ccbOwner.node_go:setVisible(false)
	self._ccbOwner.node_rank:setVisible(false)
	self._ccbOwner.node_btn_set:setVisible(false)
	self._ccbOwner.tf_set_desc:setVisible(false)
	self._ccbOwner.node_money:setVisible(false)
	self._ccbOwner.node_active_tips:setVisible(false)
end

function QUIWidgetMonopolyOneSeting:onEnter()
end

function QUIWidgetMonopolyOneSeting:onExit()
end

function QUIWidgetMonopolyOneSeting:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetMonopolyOneSeting
