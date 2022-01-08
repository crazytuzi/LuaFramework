local TreasureManager = class("TreasureManager")


TreasureManager.ConfigMessage = "TreasureManager.ConfigMessage"
TreasureManager.RewardMessageOnce = "TreasureManager.RewardMessageOnce"
TreasureManager.HistoryMessage = "TreasureManager.HistoryMessage"
TreasureManager.PlayerHistoryMessage = "TreasureManager.PlayerHistoryMessage"
TreasureManager.BoxMessage = "TreasureManager.BoxMessage"
TreasureManager.Fresh_Rank_Notice      = "TreasureManager.Fresh_Rank_Notice"

function TreasureManager:ctor()
    self.configMessageList ={}
    self.count = 0
    self.rewardList = {}
    self.recordList ={}
    self.recordList[1] =  {}
    self.recordList[2] =  {}
    self.bRed = true
    self.bFreeRed = true
    self.bTips = false
    self.bMeClick = false
    --配置信息
    TFDirector:addProto(s2c.TREASURE_HUNT_CONFIG, self, self.onConfigMessageCallBack)
    --历史记录信息
    TFDirector:addProto(s2c.TREASURE_HUNT_HISTORY_LIST, self, self.onRecordCallBack)
    --寻宝结果
    TFDirector:addProto(s2c.TREASURE_HUNT_RESULT, self, self.onRewardCallBack)
    --额外宝箱
    TFDirector:addProto(s2c.TREASURE_HUNT_EXTRA_REWARD, self, self.onBoxRewardCallBack)

    TFDirector:addProto(s2c.FRESH_TREASURE_HUNT_RANK_RESULT, self, self.onReceiveFreshTreasureRankResult)
    TFDirector:addProto(s2c.FRESH_TREASURE_HUNT_CROSS_RANK_RESULT, self, self.onReceiveFreshTreasureRankResult)



    self.myRank = {}
    self.rankList = TFArray:new()
    --self:createRecordList()
end


function TreasureManager:restart()
    self.myRank = {}
    self.rankList:clear()
end
function TreasureManager:requestConfigMessage()
    showLoading()
    TFDirector:send(c2s.TREASURE_HUNT_CONFIG, {})
    self.bMeClick = true
end


function TreasureManager:onConfigMessageCallBack(event)
    hideLoading()
    local data = event.data
    print("data-------------------------")
    print(data)
    print("data-------------------------")
    
    local configMessageList = data.configList
    local count = data.count
    local boxIndex = data.boxIndex
    local round = data.round
    local golds = string.split(data.consumeSycee,'_') 
    local props = string.split(data.consumeGoods,'_') 
    local boxCounts = string.split(data.boxCount,'_')
    local boxRewardList = data.boxRewardList
    local actTime = data.actTime
    local isFirstFree = data.isFirstFree
    self.bRed = true
    local nextBoxCount = boxCounts[boxIndex + 1] + round * boxCounts[5]

    if count < nextBoxCount then
        self.bRed = false
    end 
    if isFirstFree < 1 then
        self.bFreeRed = false
    end    

    if OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Active_XunBao) == false then
        --toastMessage("寻宝活动未开启")
        toastMessage(localizable.TreasureManager_text1)
        return
    end
    print(self.bMeClick)
    if self.bMeClick then
        self:openTreasureLayer(count,configMessageList,golds,props,boxCounts,boxIndex,round,boxRewardList,actTime,isFirstFree)
        self.bMeClick = false
    end
end

function TreasureManager:requestRecord(nowCount, getCount, type)
    -- required int32 curCount  = 1;           //当前数量
    -- required int32 count = 2;               //拉取数量
    -- required int32 type = 3;                //1个人历史2玩家历史
    
    showLoading()
    TFDirector:send(c2s.TREASURE_HUNT_HISTORY_LIST, {nowCount, getCount, type})
end

function TreasureManager:onRecordCallBack(event)    
    hideLoading()     
    ----------------
    local recordType = event.data.type
    print("recordType = ", recordType)
    if self.recordList[recordType] == nil then
        self.recordList[recordType] =  {}
    end
    print("event.data.HistoryList---------------------------start")
    print(event.data.HistoryList)
    print("event.data.HistoryList---------------------------end")
    if event.data.HistoryList == nil then
        --toastMessage("没有更多历史了")
        TFDirector:dispatchGlobalEventWith(self.HistoryMessage, {recordType = event.data.type, newcount = 0})
        return
    end

    local count = 0 
    if recordType == 1 then
        for i,v in pairs(event.data.HistoryList) do
            table.insert(self.recordList[recordType] , v)
            count = count + 1
        end    
    elseif recordType == 2 then
        self.recordList[recordType] = {}
        self.recordList[recordType] = event.data.HistoryList
    end
    --TFDirector:dispatchGlobalEventWith(self.GET_RECORD_EGG_EVENT, {recordType = event.data.type, newcount = count})
    --TFDirector:dispatchGlobalEventWith(TreasureManager.HistoryMessage, {recordType = event.data.type, newcount = count})
    TFDirector:dispatchGlobalEventWith(TreasureManager.HistoryMessage, {recordType = event.data.type, newcount = count})
end

function TreasureManager:requestReward(count)
    showLoading()
    TFDirector:send(c2s.TREASURE_HUNT_RESULT, {count})
end



function TreasureManager:onRewardCallBack(event)
    hideLoading()

    self.rewardData ={}
    self.rewardData = event.data
    if event.data.index then
        --self.
        TFDirector:dispatchGlobalEventWith(TreasureManager.RewardMessageOnce, {})
    end
end

function TreasureManager:getReward()
    return self.rewardData
end

function TreasureManager:requestBoxReward(boxIndex)
    showLoading()
    TFDirector:send(c2s.TREASURE_HUNT_EXTRA_REWARD, {boxIndex})
end

function TreasureManager:onBoxRewardCallBack(event)
    hideLoading()
    --required int32 success = 1;             //1yes 2no
    --required int32 boxIndex = 2;            //开启到哪个宝箱
    --required int32 round = 3;               //当前宝箱轮次
    local success = event.data.success
    local boxIndex = event.data.boxIndex
    local round = event.data.round
    TFDirector:dispatchGlobalEventWith(TreasureManager.BoxMessage, {success = success,boxIndex = boxIndex,round=round})
end

function TreasureManager:isRedPoint()
    if self.bRed or self.bFreeRed then
        return true
    else    
        return false
    end    
end 

function TreasureManager:openTreasureMainLayer()
    if OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Active_XunBao) == false then
        --toastMessage("寻宝活动未开启")
        toastMessage(localizable.TreasureManager_text1)
        return
    end

    local layer = require("lua.logic.treasure.TreasureMain"):new()
    layer:loadData(self.configData)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end


function TreasureManager:openTreasureLayer(count,ConfigMessage,golds,props,boxCounts,boxIndex,round,boxRewardList,actTime,freeTimes)
    local layer = require("lua.logic.treasure.TreasureMain"):new()
    layer:loadData(count,ConfigMessage,golds,props,boxCounts,boxIndex,round,boxRewardList,actTime,freeTimes)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end


function TreasureManager:openBoxLayer()
    local layer = require("lua.logic.treasure.TreasureBox"):new()
    --layer:initData()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show()
end

function TreasureManager:openResultLayer(data)
    local layer = require("lua.logic.treasure.TreasureResult"):new()
    layer:loadData(data)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show()
end
function TreasureManager:onReceiveFreshTreasureRankResult(event)
    local data = event.data
    self.myRank = data.own
    if data.list then
        self.rankList:clear()
        for i=1,#data.list do
            local score = data.list[i]
            self.rankList:pushBack(score)
        end
    end
    TFDirector:dispatchGlobalEventWith(self.Fresh_Rank_Notice, {})
end

function TreasureManager:refreshRankList()
    TFDirector:send(c2s.FRESH_TREASURE_HUNT_RANK,{})
end
return TreasureManager:new();