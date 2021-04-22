--
-- zxs
-- 宗门武魂伤害
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoDamage = class("QUIWidgetUnionDragonWarInfoDamage", QUIWidget)
local QUIWidgetUnionDragonWarInfoClient = import(".QUIWidgetUnionDragonWarInfoClient")
local QListView = import("....views.QListView")
local QUnionAvatar = import("....utils.QUnionAvatar")

function QUIWidgetUnionDragonWarInfoDamage:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_info_client.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonWarInfoDamage.super.ctor(self, ccbFile, callBacks, options)

	self._data = {}
end

function QUIWidgetUnionDragonWarInfoDamage:onEnter()
	QUIWidgetUnionDragonWarInfoDamage.super.onEnter(self)

   	self:initUnionInfo()
   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoDamage:onExit()
    QUIWidgetUnionDragonWarInfoDamage.super.onExit(self)
end

function QUIWidgetUnionDragonWarInfoDamage:setInfo(info)
    self._data = info
    self:initListView()
end

function QUIWidgetUnionDragonWarInfoDamage:initUnionInfo()
	local consortia = remote.union.consortia
	local unionName = consortia.name or ""
	self._ccbOwner.tf_union_name:setString(consortia.name or "")
	self._ccbOwner.tf_union_level:setString(("LV "..(consortia.level or "")))

	local unionAvatar = QUnionAvatar.new(consortia.icon)
	unionAvatar:setConsortiaWarFloor(consortia.consortiaWarFloor)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(unionAvatar)

	local myInfo = remote.unionDragonWar:getMyDragonFighterInfo()
	self._ccbOwner.tf_dragon_level:setString("LV."..myInfo.dragonLevel)

	local memberLimit = db:getSocietyMemberLimitByLevel(consortia.level) or 1
	self._ccbOwner.tf_count:setString(string.format("%d/%d",(consortia.memberCount or 1), tonumber(memberLimit)))
end

function QUIWidgetUnionDragonWarInfoDamage:initListView()
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

function QUIWidgetUnionDragonWarInfoDamage:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetUnionDragonWarInfoClient.new()
        isCacheNode = false
    end
    item:setInfo(data, "DAMAGE")
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

return QUIWidgetUnionDragonWarInfoDamage