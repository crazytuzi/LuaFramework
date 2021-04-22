
-- @Author: liaoxianbo
-- @Date:   2019-06-03 10:10:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 21:59:10
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityCrystalShopClient = class("QUIWidgetActivityCrystalShopClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivityCrystalShopClient.EVENT_FASTBUY = "EVENT_FASTBUY"
QUIWidgetActivityCrystalShopClient.EVENT_FASTGET = "EVENT_FASTGET"

function QUIWidgetActivityCrystalShopClient:ctor(options)
	local ccbFile = "ccb/Widget_crystal_shop_client.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfig)},
    }
    QUIWidgetActivityCrystalShopClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._clickType = 1 --1充值，2领取 3已领取
end

function QUIWidgetActivityCrystalShopClient:setDataInfo(info,lastDay)

	self._info = info 
	self._ccbOwner.tf_title:setString(self._info.title or "")
	self._awardsList = self:switchAwards(self._info.reward,self._info.high_light or "")

	self._ccbOwner.sp_received:setVisible(false)
	self._ccbOwner.tf_btn:setString((self._info.prize or 0).." 元")
	self._ccbOwner.tf_token:setString(self._info.token_num or 0)

	for ii=1,3 do
		self._ccbOwner["node_item"..ii]:removeAllChildren()
	end

	for index,award in pairs(self._awardsList) do
		local itembox = QUIWidgetItemsBox.new()
		self._ccbOwner["node_item"..index]:addChild(itembox)
		itembox:setGoodsInfo(award.id, award.typeName, award.count)
		itembox:setPromptIsOpen(true)
		if award.showEffect then
			itembox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
		end
	end

	self:showBtnState(self._info.reciveState,self._info.rechargeState,lastDay)
end

function QUIWidgetActivityCrystalShopClient:showBtnState(reciveState, rechargeState,lastDay)
	if reciveState then
		self._clickType = 3
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.sp_received:setVisible(true)
	elseif rechargeState or (lastDay > 0 and lastDay < 8 ) then
		self._clickType = 2
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.tf_btn:setString("领 取")
		self._ccbOwner.red_tips:setVisible(true)
		self._ccbOwner.sp_received:setVisible(false)			
	else
		self._clickType = 1
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.red_tips:setVisible(false)
		self._ccbOwner.tf_btn:setString((self._info.prize or 0).." 元")
		self._ccbOwner.sp_received:setVisible(false)			
	end
end

function QUIWidgetActivityCrystalShopClient:switchAwards( giftList ,highlight)
	if giftList == nil then return {} end
	local a = string.split(giftList, ";")
	local awardseffectTbl = string.split(highlight,";")
    local tbl = {}
    local awardList = {}
    for _, value in pairs(a) do
        tbl = {}
        local s, e = string.find(value, "%^")
        local idOrType = string.sub(value, 1, s - 1)
        local itemCount = tonumber(string.sub(value, e + 1))
        local itemType = remote.items:getItemType(idOrType)
        if itemType == nil then
            itemType = ITEM_TYPE.ITEM
        end        
        local showEffect = false
        if awardseffectTbl then
        	for _,awardsEf in pairs(awardseffectTbl) do
        		if idOrType == awardsEf then
        			showEffect = true
        			break
        		end
        	end
        end
		table.insert(awardList, {id = idOrType, typeName = itemType, count = itemCount,showEffect = showEffect})
    end
    return awardList
end

function QUIWidgetActivityCrystalShopClient:_onTriggerConfig(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_1) == false then return end
	if self._clickType == 1 then
		self:dispatchEvent({name = QUIWidgetActivityCrystalShopClient.EVENT_FASTBUY,id = self._info.gifts_id,prize = self._info.prize})
	else
		self:dispatchEvent({name = QUIWidgetActivityCrystalShopClient.EVENT_FASTGET,id = self._info.gifts_id,awards = self._awardsList})
	end
end
function QUIWidgetActivityCrystalShopClient:onEnter()
end

function QUIWidgetActivityCrystalShopClient:onExit()
end

function QUIWidgetActivityCrystalShopClient:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

return QUIWidgetActivityCrystalShopClient
