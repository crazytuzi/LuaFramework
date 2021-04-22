-- @Author: xurui
-- @Date:   2019-04-15 11:40:47
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-05-13 15:37:33


local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityForge = class("QActivityForge",QActivityRoundsBaseChild)
local QActivity = import(".QActivity")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QActivityForge:ctor( ... )
    QActivityForge.super.ctor(self,...)

    self._myForgeInfo = {}   --存放玩家铸造信息
    self._tConsumeItemList = {}   --存放铸造消耗道具
end

function QActivityForge:checkRedTips()
    if self:getActivityActiveState() == false then
        return false
    end

    local maxCount = self:getCurrentForgeCount()
    if maxCount and maxCount > 0 then
        return true 
    end 

    local myForgeInfo = self:getMyForgeInfo()
    if myForgeInfo and myForgeInfo.activeState == 1 then
        return true 
    end 

    return false
end

function QActivityForge:checkActivityComplete()
    return self:checkRedTips()
end

--设置周基金信息
function QActivityForge:updateMyForgeInfo(data)
    self._myForgeInfo = data or {}
end

--获取周基金信息
function QActivityForge:getMyForgeInfo()
    return self._myForgeInfo or {}
end

function QActivityForge:loadActivity()
    if self.isOpen and self:getActivityActiveState() then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_FORGE) or {}
        table.insert(activities, {type = QActivity.TYPE_FORGE, activityId = self.activityId, title = (themeInfo.title or "名匠锻造"), description = "", roundType = "FORGE_ACTIVITY",
        start_at = self.startAt * 1000, end_at = self.endAt * 1000, award_at = self.startAt * 1000, award_end_at = self.endAt * 1000, weight = 14, targets = {}, subject = QActivity.THEME_ACTIVITY_FORGE})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

function QActivityForge:getActivityActiveState()
    return true
end

function QActivityForge:getActivityInfoWhenLogin( success, fail )
    self:requestMyForge(function(data)
            self:loadActivity()
            if success then
                success()
            end
        end, fail)
end

function QActivityForge:activityShowEndCallBack(  )
    self:handleOffLine()
end

function QActivityForge:activityEndCallBack(  )
    self:handleOffLine()
end

function QActivityForge:handleOnLine( )
    if not self.isOpen then
        return
    end

    self:requestMyForge(function(data)
            self:loadActivity()

            self:handleEvent()
        end, fail)
end

function QActivityForge:handleOffLine( )
    -- body
    self._myForgeInfo = {} 
    self._tConsumeItemList = {} 
    remote.activity:removeActivity(self.activityId , true)
    self.isOpen = false
    self:handleEvent()
end

function QActivityForge:handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.FORGE_UPDATE, isForce = true})
end

function QActivityForge:getCurrentForgeCount()
    if q.isEmpty(self._tConsumeItemList) then
        local consumeItemStr = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_make_need_item")
        self._tConsumeItemList = {}
        remote.items:analysisServerItem(consumeItemStr, self._tConsumeItemList)
    end

    local minCount = 999999
    for _, value in ipairs(self._tConsumeItemList) do
        local num
        if value.typeName ~= ITEM_TYPE.ITEM then
            num = remote.user[value.typeName] or 0
        else
            num = remote.items:getItemsNumByID(value.id)
        end
        
        local count = math.floor(num / value.count)
        if count < minCount then
            minCount = count
        end 
    end

    return minCount
end

-----------------request--------------------------

function QActivityForge:requestMyForge(success, fail)
    local request = {api = "FORGE_GET_MY_INFO", forgeGetMyInfoRequest = {activityId = self.activityId}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data and data.forgeGetMyInfoResponse then
                self:updateMyForgeInfo(data.forgeGetMyInfoResponse)
            end
            if success then
                success()
            end
        end, fail)
end

function QActivityForge:requestForgeMake(count, success, fail)
    local request = {api = "FORGE_MAKE", forgeMakeRequest = {activityId = self.activityId, count = count}}
    app:getClient():requestPackageHandler(request.api, request, success, fail)
end

function QActivityForge:requestForgeBestHammer(success, fail)
    local request = {api = "FORGE_GET_BEST_HAMMER", forgeGetBestHammerRequest = {activityId = self.activityId}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data and data.forgeGetBestHammerResponse then
                self:updateMyForgeInfo(data.forgeGetBestHammerResponse)
            end
            if success then
                success()
            end
        end, fail)
end

return QActivityForge