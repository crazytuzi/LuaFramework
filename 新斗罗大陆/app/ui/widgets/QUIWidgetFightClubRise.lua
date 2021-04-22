-- 
--  zxs
--	搏击俱乐部晋级界面
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetFightClubRise = class("QUIWidgetFightClubRise", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFloorIcon = import("..Widgets.QUIWidgetFloorIcon")
local QUIWidgetItemsBox = import("..Widgets.QUIWidgetItemsBox")
local QScrollView = import("...views.QScrollView")

function QUIWidgetFightClubRise:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_jinji.ccbi"
	local callBacks = {}
	QUIWidgetFightClubRise.super.ctor(self, ccbFile, callBacks, options)
   
    self.isAnimation = true --是否动画显示

    self:reset()
    self._info = options
end

function QUIWidgetFightClubRise:onEnter()
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)
    self._scrollView:setTouchState(true)

    if self._info then
        self:setInfo(self._info)
    end
end

function QUIWidgetFightClubRise:reset()
    self._ccbOwner.frame_tf_title:setString("赛季结算")
    self._ccbOwner.node_season_title:setVisible(true)
    self._ccbOwner.node_floor_title:setVisible(false)
    self._ccbOwner.sp_arrow:setVisible(false)
    self._ccbOwner.node_old:setVisible(false)
    self._ccbOwner.node_new:setVisible(false)
    self._ccbOwner.node_now:setVisible(true)
    self._ccbOwner.node_ok:setVisible(false)
    self._ccbOwner.tf_award_tips:setVisible(true)

    self._ccbOwner.now_rank_1:setString(0)
    self._ccbOwner.now_rank_2:setString(0)
    self._ccbOwner.now_rank_3:setString(0)

    local nowFloor = QUIWidgetFloorIcon.new({floor = 0})
    self._ccbOwner.now_floor:addChild(nowFloor)
end

function QUIWidgetFightClubRise:setInfo(info)
    self.rewardId = info.rewardId

    self._ccbOwner.now_floor:removeAllChildren()
    local nowFloor = QUIWidgetFloorIcon.new({floor = info.floor})
    self._ccbOwner.now_floor:addChild(nowFloor)

    self._ccbOwner.now_rank_1:setString(info.roomRank)
    self._ccbOwner.now_rank_2:setString(info.envRank)
    self._ccbOwner.now_rank_3:setString(info.oldEnvRank)

    local awards = {}
    local rewards = string.split(info.rewards, ";")
    for i, v in pairs(rewards) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(awards, {type = reward[1], typeName = itemType, count = tonumber(reward[2])})
        end
    end
    local itemCount = #awards
	for i = 1, itemCount do
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setPromptIsOpen(true)
        itemBox:setGoodsInfo(awards[i].type, awards[i].typeName, awards[i].count)
        itemBox:setPosition(ccp(60+(i-1)*130, -55))
        self._scrollView:addItemBox(itemBox)
	end
    self._scrollView:setRect(0, 200, 0, 130*itemCount-10)
    self._scrollView:moveTo(0, 0, false)
end

return QUIWidgetFightClubRise