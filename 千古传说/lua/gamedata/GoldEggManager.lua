--[[
******金蛋管理类*******

	-- by king
	-- 2015/12/16
]]


local GoldEggManager = class("GoldEggManager")
local TFLengthArray = require('lua.public.TFLengthArray')
GoldEggManager.SliverEgg = 1
GoldEggManager.GoldEgg   = 2
GoldEggManager.ShowHistoryLength   = 5

GoldEggManager.GET_HIT_EGG_EVENT    = "GoldEggManager.GET_HIT_EGG_EVENT"
GoldEggManager.GET_RECORD_EGG_EVENT = "GoldEggManager.GET_RECORD_EGG_EVENT"
GoldEggManager.GOLD_EGG_UPDATE      = "GoldEggManager.GOLD_EGG_UPDATE"
GoldEggManager.Show_Histroy_Notice      = "GoldEggManager.Show_Histroy_Notice"
GoldEggManager.Fresh_Rank_Notice      = "GoldEggManager.Fresh_Rank_Notice"

function GoldEggManager:ctor()
    TFDirector:addProto(s2c.GOLD_EGG_INFO, self, self.onReceiveInfoResult)
    TFDirector:addProto(s2c.GOLD_EGG_RESULT, self, self.onReceiveEggResult)
    TFDirector:addProto(s2c.EGG_RECORD_LIST, self, self.onReceiveEggHistoryResult)
    TFDirector:addProto(s2c.EGG_RECORD_SHOW_LIST, self, self.onReceiveEggRecordShowResult)
    TFDirector:addProto(s2c.FRESH_EGG_RANK_RESULT, self, self.onReceiveFreshEggRankResult)
    TFDirector:addProto(s2c.FRESH_EGG_CROSS_RANK_RESULT, self, self.onReceiveFreshEggRankResult)


    self.EggInfoList    = {}
    self.EggRecordList  = {}
    self.EggRecordList[1] =  TFArray:new()
    self.EggRecordList[2] =  TFArray:new()


    self.showOtherHistory = TFArray:new()

    self.myRank = {}
    self.rankList = TFArray:new()
end

function GoldEggManager:restart()
    self.showOtherHistory:clear()
    self.myRank = {}
    self.rankList:clear()
end

function GoldEggManager:onReceiveInfoResult(event)
    hideLoading()

    --local eggDesc = {"1银蛋","2金蛋"}
    local eggDesc = localizable.GoldEggManager_type
    local configList = event.data.configList

    print("configList = ", configList)

    for i,v in pairs(configList) do
        local eggType = v.type

        self.EggInfoList[eggType] = v
        self.EggInfoList[eggType].rewardList = MEArray:new()
        print("-----收到"..eggDesc[eggType].."数据")
        -- required string reward = 7;          //随机奖励配置 类型,id,数量&类型,id,数量
        -- 解析奖励
        local temptbl = string.split(v.reward,'&')
        for k,v2 in pairs(temptbl) do
            local reward      = string.split(v2,',')
            local commonReward = {}
            commonReward.type   = tonumber(reward[1])
            commonReward.itemId = tonumber(reward[2])
            commonReward.number = 1--tonumber(reward[3])
            self.EggInfoList[eggType].rewardList:push(BaseDataManager:getReward(commonReward))
        end
    end
end

function GoldEggManager:onReceiveEggResult(event)
    hideLoading()

    self.GoldEggReward = event.data

    local eggType   = event.data.type

    self.getCardTypeList = event.data.rewardList

    -- if #self.getCardTypeList > 0 and cardType == 3 then
    if #self.getCardTypeList > 10 then
        for i=1,30 do
            local first =  math.random(1, #self.getCardTypeList)
            local second =  math.random(1, #self.getCardTypeList)
            if first ~= second then
                local temp_typid = self.getCardTypeList[first]
                self.getCardTypeList[first] = self.getCardTypeList[second]
                self.getCardTypeList[second] = temp_typid
            end
        end
    end

    if self.EggInfoList and self.EggInfoList[eggType] then
        self.EggInfoList[eggType].freeTime = 0
    end

    TFDirector:dispatchGlobalEventWith(self.GET_HIT_EGG_EVENT, {reward = event.data})
end

function GoldEggManager:onReceiveEggHistoryResult(event)
    hideLoading()

    local recordType = event.data.type


    print("recordType = ", recordType)

    if self.EggRecordList[recordType] == nil then
        self.EggRecordList[recordType] =  TFArray:new()
    end

    if event.data.recordList == nil then
        -- toastMessage("没有更多的砸蛋历史了")
        TFDirector:dispatchGlobalEventWith(self.GET_RECORD_EGG_EVENT, {recordType = event.data.type, newcount = 0})
        return
    end

    local count = 0
    for i,v in pairs(event.data.recordList) do
        self.EggRecordList[recordType]:push(v)

        count = count + 1
    end
    
    if recordType == 2 then
        print("====================onReceiveEggHistoryResult===========================")
        self.showOtherHistory:clear()
        for i=1,math.min(5,self.EggRecordList[recordType]:length()) do
            local record = self.EggRecordList[recordType]:objectAt(i)
            self.showOtherHistory:pushBack(record)
        end
        TFDirector:dispatchGlobalEventWith(self.Show_Histroy_Notice, {})
    end
    -- if count == 0 then
    --     toastMessage("没有更多的砸蛋历史了")
    -- end
    -- print("count = ", count)
    -- print("event.data = ", event.data)


    TFDirector:dispatchGlobalEventWith(self.GET_RECORD_EGG_EVENT, {recordType = event.data.type, newcount = count})
end
function GoldEggManager:onReceiveEggRecordShowResult(event)
    print("GoldEggManager:onReceiveEggRecordShowResult=======>")
    local data = event.data
    local record = data.recordList
    self.showOtherHistory:pushFront(record)
    if self.showOtherHistory:length() >= GoldEggManager.ShowHistoryLength then
        self.showOtherHistory:popBack()
    end
    TFDirector:dispatchGlobalEventWith(self.Show_Histroy_Notice, {})
end
function GoldEggManager:onReceiveFreshEggRankResult(event)
    local data = event.data
    self.myRank = data.player
    if data.list then
        self.rankList:clear()
        for i=1,#data.list do
            local score = data.list[i]
            self.rankList:pushBack(score)
        end
    end
    TFDirector:dispatchGlobalEventWith(self.Fresh_Rank_Notice, {})
end

function GoldEggManager:RequestCheckGoldEggInfo()
    showLoading()
    TFDirector:send(c2s.GOLD_EGG_INFO, {})
end
-- 1银蛋2金蛋
--count 1 10
function GoldEggManager:RequestBreakGoldEgg(eggType, count)
    -- 1银蛋2金蛋
    showLoading()
    TFDirector:send(c2s.GOLD_EGG_RESULT, {eggType, count})
end

function GoldEggManager:RequestGoldEggRecord(nowCount, getCount, type)
    -- required int32 curCount  = 1;           //当前数量
    -- required int32 count = 2;               //拉取数量
    -- required int32 type = 3;                //1个人历史2玩家历史

    showLoading  ()
    TFDirector:send(c2s.EGG_RECORD_LIST, {nowCount, getCount, type})
end


function GoldEggManager:getEggInfo(eggType)
    -- 1银蛋2金蛋
    return self.EggInfoList[eggType]
end


function GoldEggManager:showResult()
    local cardType   = self.GoldEggReward.type
    local rewardList = self.GoldEggReward.rewardList

    if #rewardList > 0 then
        if #rewardList <= 1 then
            if rewardList[1].resType == EnumDropType.ROLE then
                self:ShowGetOneRoleLayer(1, 1)
            else
                self:ShowGetOneItemLayer(1, 1)
            end
        else
            local layer = require("lua.logic.gameactivity.GoldEgg.GoldEggTenRoleResultLayer"):new(3)
            layer.name = "lua.logic.gameactivity.GoldEgg.GoldEggTenRoleResultLayer"
            AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
            layer:setEggType(self.GoldEggReward.type)
            AlertManager:show()
        end
    end
end

function GoldEggManager:CheckEggReward(eggType)
    local eggInfo = self.EggInfoList[eggType]

    local layer  = require("lua.logic.gameactivity.GoldEgg.GoldEggCheckRewardLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:setRewardList(eggInfo.rewardList)
    AlertManager:show()
end

function GoldEggManager:ShowGetOneRoleLayer(cardType, roleIndex)
    local layer = require("lua.logic.gameactivity.GoldEgg.GoldEggRoleResultLayer"):new({cardType, roleIndex})
    AlertManager:addLayer(layer, AlertManager.BLOCK)
    layer:setEggType(self.GoldEggReward.type)
    AlertManager:show()
end

function GoldEggManager:ShowGetOneItemLayer(cardType, roleIndex)
    local layer = require("lua.logic.gameactivity.GoldEgg.GoldEggItemResultLayer"):new({cardType, roleIndex})
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    layer:setEggType(self.GoldEggReward.type)
    AlertManager:show()
end

function GoldEggManager:ShowRecordLayer()
    local layer = require("lua.logic.gameactivity.GoldEgg.GoldEggRecordLayer"):new()
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end


function GoldEggManager:openGoldEggMainLayer()
    if OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Hit_Egg) == false then
        -- toastMessage("砸蛋活动未开启")
        toastMessage(localizable.GoldEggManager_no_eggacitivty)
        return
    end
    GoldEggManager:getOtherRewardHistory()
    local layer  = require("lua.logic.gameactivity.GoldEgg.GoldEggMainLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function GoldEggManager:isRedPoint()
    if self.EggInfoList and self.EggInfoList[1] then

        if self.EggInfoList[1].freeTime > 0 then
            return true
        end
    end

    return false
end


function GoldEggManager:resetFreeTime()
    if self.EggInfoList and self.EggInfoList[1] then

        if self.EggInfoList[1].freeTime then
            self.EggInfoList[1].freeTime = 1
        end
    end

    TFDirector:dispatchGlobalEventWith(self.GOLD_EGG_UPDATE, {})
end

function GoldEggManager:getOtherRewardHistory()
    if self.EggRecordList == nil then
        self.EggRecordList = {}
    end
    if self.EggRecordList[2] == nil then
        self.EggRecordList[2] =  TFArray:new()
    end
    if self.EggRecordList[2]:length() == 0 then
        self:RequestGoldEggRecord(0, GoldEggManager.ShowHistoryLength, 2)
    end
end
function GoldEggManager:refreshRankList()
    TFDirector:send(c2s.FRESH_EGG_RANK,{})
end

return GoldEggManager:new()