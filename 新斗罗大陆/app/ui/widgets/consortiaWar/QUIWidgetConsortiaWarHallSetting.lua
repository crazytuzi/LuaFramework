-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 10:41:04
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-13 16:59:15
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarHallSetting = class("QUIWidgetConsortiaWarHallSetting", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QUIWidgetConsortiaWarHead = import("...widgets.consortiaWar.QUIWidgetConsortiaWarHead")
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

QUIWidgetConsortiaWarHallSetting.EVENT_HEAD_CLICK = "EVENT_HEAD_CLICK"

function QUIWidgetConsortiaWarHallSetting:ctor(options)
	local ccbFile = "ccb/Widget_Unionwar_arrange.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetConsortiaWarHallSetting.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self._headList = {}
    self._leadHead = nil
    local maxCount = remote.consortiaWar:getHallMemberCount()
    for i = 1, maxCount-1 do
        local head = QUIWidgetConsortiaWarHead.new()
        head:setPosition(92*i+20, -10)
        head:setScale(0.88)
        head:setInfo()
        self._ccbOwner.node_head:addChild(head)
        self._headList[i] = head
    end
    self._leadHead = QUIWidgetConsortiaWarHead.new()
    self._leadHead:setInfo()
    self._leadHead:setPosition(0, -10)
    self._ccbOwner.node_head:addChild(self._leadHead)
end

function QUIWidgetConsortiaWarHallSetting:setInfo(info)
	self._hallId = info.index
    local hallConfig = remote.consortiaWar:getHallConfigByHallId(self._hallId)
    self._ccbOwner.tf_genre:setString(hallConfig.name.."成员")

    local hallInfo = remote.consortiaWar:getTempHallByHallId(self._hallId)
    local hallPlayers = hallInfo.memberList or {}
    table.sort(hallPlayers, function(a, b)
        return a.memberFighter.force > b.memberFighter.force
    end)
    
    local index = 1
    local hasLeader = false
    for i, player in pairs(hallPlayers) do
        if player.isLeader then
            self._leadHead:setInfo(player)
            self._leadHead:hideNameForce()
            self._ccbOwner.tf_name:setString(player.memberFighter.name)
            local force = player.memberFighter.force or 0
            local num, uint = q.convertLargerNumber(force)
            self._ccbOwner.tf_force:setString(num..uint)
            hasLeader = true
        else
            self._headList[index]:setInfo(player)
            index = index + 1
        end
    end

    local maxCount = remote.consortiaWar:getHallMemberCount()
    for i = index, maxCount - 1 do
        self._headList[i]:setInfo()
    end

    -- 是否设置堂主
    if hasLeader then
        self._ccbOwner.tf_name:setVisible(true)
        self._ccbOwner.tf_force:setVisible(true)
    else
        self._leadHead:setInfo()
        self._ccbOwner.tf_name:setVisible(false)
        self._ccbOwner.tf_force:setVisible(false)
    end
end

function QUIWidgetConsortiaWarHallSetting:getContentSize()
    return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetConsortiaWarHallSetting:registerItemBoxPrompt( index, list )
    list:registerItemBoxPrompt(index, 0, self._leadHead, 0, function()
        local info = {hallId = self._hallId, isLeader = true, userId = self._leadHead:getUserId()}
        self:dispatchEvent({name = QUIWidgetConsortiaWarHallSetting.EVENT_HEAD_CLICK, info = info})
    end)

    for k, headBox in pairs(self._headList) do
        list:registerItemBoxPrompt(index, k, headBox, 0, function()
            local info = {hallId = self._hallId, isLeader = false, userId = headBox:getUserId()}
            self:dispatchEvent({name = QUIWidgetConsortiaWarHallSetting.EVENT_HEAD_CLICK, info = info})
        end)
    end
end

return QUIWidgetConsortiaWarHallSetting
