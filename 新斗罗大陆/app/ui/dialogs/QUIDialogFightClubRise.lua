-- 
--  zxs
--	搏击俱乐部晋级界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubRise = class("QUIDialogFightClubRise", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFloorIcon = import("..Widgets.QUIWidgetFloorIcon")
local QUIWidgetItemsBox = import("..Widgets.QUIWidgetItemsBox")
local QScrollView = import("...views.QScrollView")

function QUIDialogFightClubRise:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_jinji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogFightClubRise._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogFightClubRise._onTriggerOK)},
	}
	QUIDialogFightClubRise.super.ctor(self, ccbFile, callBacks, options)
   
    self.isAnimation = true --是否动画显示

    self._ccbOwner.tf_award_tips:setVisible(false)
    self._isDummy = options.isDummy

    if self._isDummy then
        self:setDummyInfo(options.info)
    else
	    self:setInfo(options.info)
    end
    self:setAwardInfo(options.info)
end

function QUIDialogFightClubRise:setInfo(info)
    self.rewardId = info.rewardId
    self.upRewards = info.upRewards
    if info.type == 2 then
        self._ccbOwner.frame_tf_title:setString("赛季结算")
        self._ccbOwner.node_season_title:setVisible(true)
        self._ccbOwner.node_floor_title:setVisible(false)
        self._ccbOwner.sp_arrow:setVisible(false)
        self._ccbOwner.node_old:setVisible(false)
        self._ccbOwner.node_new:setVisible(false)
        self._ccbOwner.node_now:setVisible(true)

        local nowFloor = QUIWidgetFloorIcon.new({floor = info.floor, isLarge = false})
        self._ccbOwner.now_floor:addChild(nowFloor)

        self._ccbOwner.now_rank_1:setString(info.roomRank)
        self._ccbOwner.now_rank_2:setString(info.envRank)
        self._ccbOwner.now_rank_3:setString(info.oldEnvRank)

    elseif info.type == 3 then
        self._ccbOwner.frame_tf_title:setString("升段奖励")
        self._ccbOwner.node_season_title:setVisible(true)
        self._ccbOwner.node_floor_title:setVisible(false)
        self._ccbOwner.node_old:setVisible(false)
        self._ccbOwner.node_new:setVisible(false)
        self._ccbOwner.node_now:setVisible(false)
        self._ccbOwner.sp_arrow:setVisible(false)

        local newFloor = QUIWidgetFloorIcon.new({floor = info.floor, isLarge = false})
        self._ccbOwner.node_new_floor:addChild(newFloor)
        self._ccbOwner.node_new_floor:setPositionX(0)

        local rankInfo = remote.fightClub:getFightClubRankInfo(info.floor)
        local rankName = rankInfo.name or "黑铁"
        local str = "赛季结算后，您的段位保留到"..rankName.."，并获得到"..rankName.."的升段奖励"
        self._ccbOwner.tf_season_title:setString(str)

    else
        self._ccbOwner.node_season_title:setVisible(false)
        self._ccbOwner.node_floor_title:setVisible(true)
        self._ccbOwner.node_now:setVisible(false)
        
    	local oldFloor = QUIWidgetFloorIcon.new({floor = info.oldFloor, isLarge = false})
        self._ccbOwner.old_floor:addChild(oldFloor)

        local newFloor = QUIWidgetFloorIcon.new({floor = info.floor, isLarge = false})
        self._ccbOwner.new_floor:addChild(newFloor)

        self._ccbOwner.old_win_count:setString(" x"..info.winCount)
        self._ccbOwner.old_rank_1:setString(info.oldRoomRank)
        self._ccbOwner.old_rank_2:setString(info.oldEnvRank)

        self._ccbOwner.new_win_count:setString(" x"..info.newWinCount)
        self._ccbOwner.new_rank_1:setString(info.roomRank)
        self._ccbOwner.new_rank_2:setString(info.envRank)

        local str1 = "您已晋级到下一段位，并获得晋级奖励"
        local str2 = "您已保留在当前段位，并获得保级奖励"
        local str3 = "您已降级到上一段位，并获得降级奖励"

        if info.oldFloor < info.floor then
            self._ccbOwner.tf_title_tips:setString(str1)
            self._ccbOwner.frame_tf_title:setString("晋级")
        elseif info.oldFloor == info.floor then
            self._ccbOwner.tf_title_tips:setString(str2)
            self._ccbOwner.frame_tf_title:setString("保级")
        else
            self._ccbOwner.tf_title_tips:setString(str3)
            self._ccbOwner.frame_tf_title:setString("降级")
        end
    end
end

function QUIDialogFightClubRise:setDummyInfo(info)
    self._ccbOwner.tf_title:setString("升段奖励")
    self._ccbOwner.node_season_title:setVisible(true)
    self._ccbOwner.node_floor_title:setVisible(false)
    self._ccbOwner.node_old:setVisible(false)
    self._ccbOwner.node_new:setVisible(false)
    self._ccbOwner.node_now:setVisible(false)
    self._ccbOwner.sp_arrow:setVisible(false)

    local newFloor = QUIWidgetFloorIcon.new({floor = info.floor})
    self._ccbOwner.node_new_floor:addChild(newFloor)
    self._ccbOwner.node_new_floor:setPositionX(0)

    local rankInfo = remote.fightClub:getFightClubRankInfo(info.floor)
    local rankName = rankInfo.name or "黑铁"
    local str4 = "赛季结算后，您的段位保留到"..rankName.."，并获得到"..rankName.."的升段奖励"
    self._ccbOwner.tf_season_title:setString(str4)
end

function QUIDialogFightClubRise:setAwardInfo(info)
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

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
        itemBox:setScale(0.8)
        self._scrollView:addItemBox(itemBox)
	end
    self._scrollView:setRect(0, scrollSize.height, 0, 130*itemCount-10)
    self._scrollView:moveTo(0, 0, false)

    self._awards = awards
end

function QUIDialogFightClubRise:_onTriggerClose()
    self:_close()
end

function QUIDialogFightClubRise:_close()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogFightClubRise:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    local rewardId = self.rewardId
    local upRewards = self.upRewards
    
    -- 虚拟奖励
    if self._isDummy then
        self:viewAnimationOutHandler()
        
        local awards = {}
        if self._awards then
            for _,value in ipairs(self._awards) do
                table.insert(awards, {id = value.type, typeName = value.typeName, count = value.count})
            end
        end

        if #awards > 0 then
            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
                options = {awards = awards}},{isPopCurrentDialog = true})
            dialog:setTitle("恭喜获得升段奖励")
        end
        return
    end


    remote.fightClub:requestFightClubGetReward(rewardId, function(data)
        if self:safeCheck() then
            self:viewAnimationOutHandler()

            local callBack = function () remote.fightClub:updateReaward(rewardId) end
            -- 有升段奖励
            if upRewards and upRewards ~= "" then
                callBack = function ()
                    local awards = {}
                    local rewards = string.split(upRewards, ";")
                    for i, v in pairs(rewards) do
                        if v ~= "" then
                            local reward = string.split(v, "^")
                            local itemType = ITEM_TYPE.ITEM
                            if tonumber(reward[1]) == nil then
                                itemType = remote.items:getItemType(reward[1])
                            end
                            table.insert(awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
                        end
                    end
                    if #awards > 0 then
                        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", options = {awards = awards,
                            callBack = function () remote.fightClub:updateReaward(rewardId) end}},{isPopCurrentDialog = true})
                        dialog:setTitle("恭喜获得升段奖励")
                    end
                end
            end

            local awards = {}
            if self._awards then
                for _,value in ipairs(self._awards) do
                    table.insert(awards, {id = value.type, typeName = value.typeName, count = value.count})
                end
            end
            if #awards > 0 then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
                    options = {awards = awards, callBack = callBack}},{isPopCurrentDialog = true} )
                dialog:setTitle("恭喜获得奖励")
            end
        end
    end)
end

return QUIDialogFightClubRise