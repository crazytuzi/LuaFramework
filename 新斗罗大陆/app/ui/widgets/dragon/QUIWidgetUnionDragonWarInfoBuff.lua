--
-- zxs
-- 宗门武魂伤害
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoBuff = class("QUIWidgetUnionDragonWarInfoBuff", QUIWidget)
local QUIWidgetUnionDragonWarInfoClient = import(".QUIWidgetUnionDragonWarInfoClient")
local QListView = import("....views.QListView")
local QRichText = import("....utils.QRichText")

function QUIWidgetUnionDragonWarInfoBuff:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_info_client1.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonWarInfoBuff.super.ctor(self, ccbFile, callBacks, options)

	self._data = {}

	self._tfDesc = QRichText.new(nil, 480, {defaultSize = 22, defaultColor = COLORS.k})
	self._tfDesc:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_tf_buff:addChild(self._tfDesc)
   	self._ccbOwner.tf_desc:setVisible(false)
end

function QUIWidgetUnionDragonWarInfoBuff:onEnter()
	QUIWidgetUnionDragonWarInfoBuff.super.onEnter(self)

    self._unionDragonWarPeoxy = cc.EventProxy.new(remote.unionDragonWar)
    self._unionDragonWarPeoxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_BUFF_INFO, handler(self, self._updateBuffInfo))

   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoBuff:onExit()
    QUIWidgetUnionDragonWarInfoBuff.super.onExit(self)

	self._unionDragonWarPeoxy:removeAllEventListeners()
end

function QUIWidgetUnionDragonWarInfoBuff:_updateBuffInfo()
	self:initListView()
   	self:initUnionInfo()
end

function QUIWidgetUnionDragonWarInfoBuff:setInfo(info)
    self._data = info

   	self:initListView()
   	self:initUnionInfo()
end

function QUIWidgetUnionDragonWarInfoBuff:initUnionInfo()
	local myInfo = remote.unionDragonWar:getMyDragonFighterInfo()
	local buffCount = myInfo.holyCount or 0
	local totalCount = remote.unionDragonWar:getBuffTotalCount()
    local holyBonous = db:getConfiguration()["sociaty_dragon_holy_bonous"].value or 0

	local desc = {
		{oType = "font", content = "宗主、副宗主可为一名成员开启武魂祝福，开启后",size = 22, color = GAME_COLOR_LIGHT.normal},
		{oType = "font", content = string.format("“该玩家24小时内伤害x%d%%”，", (holyBonous*100)),size = 22, color = GAME_COLOR_LIGHT.stress},
		{oType = "font", content = "本周武魂祝福剩余开启次数：",size = 22, color = GAME_COLOR_LIGHT.normal},
		{oType = "font", content = string.format("%d/%d。", (totalCount-buffCount), totalCount),size = 22, color = GAME_COLOR_LIGHT.stress},
	}
	self._tfDesc:setString(desc)
end

function QUIWidgetUnionDragonWarInfoBuff:initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = true,
	        spaceY = -4,
	        curOffset = 5,
	        enableShadow = false,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetUnionDragonWarInfoBuff:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetUnionDragonWarInfoClient.new()
        isCacheNode = false
    end
    item:setInfo(data, "BUFF")
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index,"btn_wear", handler(self, self.clickWearHandler), nil, true)

    return isCacheNode
end

function QUIWidgetUnionDragonWarInfoBuff:clickWearHandler(x, y, touchNode, listView)
	app.sound:playSound("common_small")
	if not remote.union:checkUnionRight() then
		app.tip:floatTip("魂师大人，宗主、副宗主才有权限开启武魂祝福哟～")
		return
	end
	local myInfo = remote.unionDragonWar:getMyInfo()
	self._buffCount = myInfo.holyCount or 0
	local totalCount = remote.unionDragonWar:getBuffTotalCount()
	if self._buffCount >= totalCount then
		app.tip:floatTip("宗主大人，本赛季的祝福次数已用完。")
		return
	end
	local index = listView:getCurTouchIndex()
    local dragonWarUserRankInfo = self._data[index]
    remote.unionDragonWar:dragonWarSetUserHolyStsRequest(dragonWarUserRankInfo.memberId, function ()
    	dragonWarUserRankInfo.isHolyedWeekly = true
    	app.tip:floatTip("武魂祝福开启成功~")
    	if self._listView then
    		self:initUnionInfo()
    		self._listView:refreshData()
    	end
    end)
end

return QUIWidgetUnionDragonWarInfoBuff