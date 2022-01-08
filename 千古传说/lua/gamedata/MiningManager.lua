
--[[
******采矿管理类*******
	-- yaojie
	-- 2016/1/12
]]


local MiningManager = class("MiningManager")

MiningManager.EVENT_UPDATE_MINERALINFO      = "MiningManager.EVENT_UPDATE_MINERALINFO"
MiningManager.EVENT_ASK_FOR_HELP_RESULT     = "MiningManager.EVENT_ASK_FOR_HELP_RESULT"
--MiningManager.EVENT_UPDATE_MINELIST         = "MiningManager.EVENT_UPDATE_MINELIST"
MiningManager.EVENT_UPDATE_MINERESULT       = "MiningManager.EVENT_UPDATE_MINERESULT"
MiningManager.EVENT_UPDATE_HISTORY          = "MiningManager.EVENT_UPDATE_HISTORY"
MiningManager.EVENT_UPDATE_CHONGZHIINFO     = "MiningManager.EVENT_UPDATE_CHONGZHIINFO"
MiningManager.EVENT_GET_REPLAY_RESULT       = "MiningManager.EVENT_GET_REPLAY_RESULT"
MiningManager.EVENT_GUARD_REPLAY_LIST_RESULT= "MiningManager.EVENT_GUARD_REPLAY_LIST_RESULT"
MiningManager.EVENT_UPDATE_QIANXING         = "MiningManager.EVENT_UPDATE_QIANXING"
MiningManager.EVENT_UPDATE_CHONGZHI         = "MiningManager.EVENT_UPDATE_CHONGZHI"
MiningManager.EVENT_RUBMINE_SUCCESS         = "MiningManager:EVENT_RUBMINE_SUCCESS"

MineTemplateData = require('lua.table.t_s_mine_template')
miningmineEffect = nil
miningTimer = nil

function MiningManager:ctor() 
    self:restart()
    TFDirector:addProto(s2c.MINE, self, self.roleMiningInfo)
    TFDirector:addProto(s2c.REFRESH_MINE_RESULT, self, self.refreshMineResult)
    TFDirector:addProto(s2c.MINE_RESULT, self, self.mineResult)
    TFDirector:addProto(s2c.UNLOCK_MINE_RESULT, self, self.unlockMineResult)
    TFDirector:addProto(s2c.GET_MINE_REWARD_RESULT, self, self.mineReward)
    TFDirector:addProto(s2c.GET_BROKERAGE_RESULT, self, self.brokerageSuccess)
    TFDirector:addProto(s2c.GUARD_RECORD_LIST_RESULT, self, self.guardRecordListResult)
    TFDirector:addProto(s2c.FRESH_MINE_LIST_RESULT, self, self.freshMineListResult) 
    TFDirector:addProto(s2c.GUARD_MINE_RESULT, self, self.guardMineResult)
    TFDirector:addProto(s2c.MINE_FORMATION_INFO, self, self.mineFormationInfoReSult)
    TFDirector:addProto(s2c.UNLOCK_PLAYER_MINE_RESULT, self, self.unlockPlayerMineResult)
    TFDirector:addProto(s2c.RESET_CHALLENGE_MINE_RESULT, self, self.ResetChallengeMineResult)
    TFDirector:addProto(s2c.MINE_REPLAY_RESULTS, self, self.mineReplayResult)
    TFDirector:addProto(s2c.MINE_BATTLE_REPORT_LIST, self, self.RecvReplayDetail)
    TFDirector:addProto(s2c.GUARD_MINE_PLAYER_RESULT, self, self.recvGuardPlayerCallBack)
    TFDirector:addProto(s2c.MINE_REMIND, self, self.recvMineStautsCallback)
    TFDirector:addProto(s2c.ROB_MINE_SUCCESS, self, self.robMineSuccess)

    ErrorCodeManager:addProtocolListener(s2c.MINE_FORMATION_INFO,  function(target,event) self:getMineFormationInfoError(event) end)

    self.roleMineInfo = nil
    self.guardRecordList = {}
    self.mineListResult = {}
    self.IsOpenMiningLayer = false
    self.mineFormationInfo = {}
    self.playerIndex = nil
    self.mineIndex = nil
    self.minePlayerId = nil
    self.IsOpenBuzhenLayer = false
    self.randomposArr = {1,2,3,4,5,6}
    self.randomPos = {}

    self.protectPlayList = {} --保护id
    self.protectPlayList[1] = 0
    self.protectPlayList[2] = 0

    self.MineStrategy = {} --保护id
    self.MineStrategy[1] = nil
    self.MineStrategy[2] = nil
    self.enterpage = 0

    self.cardRoleList = TFArray:new()
    self:getMineTempDate()
end

function MiningManager:restart()
    self.roleMineInfo = nil
    self.mineListResult = {}
    self.guardRecordList = {}
    self.IsOpenMiningLayer = false
    self.mineFormationInfo = {}
    self.playerIndex = nil
    self.mineIndex = nil
    self.minePlayerId = nil
    self.IsOpenBuzhenLayer = false
    self.randomposArr = {1,2,3,4,5,6}
    self.randomPos = {}

    self.protectPlayList = {}
    self.protectPlayList[1] = 0
    self.protectPlayList[2] = 0

    self.MineStrategy = {}
    self.MineStrategy[1] = nil
    self.MineStrategy[2] = nil
    
end

-- 设置我的保护者
function MiningManager:setMyProtectPlayer(index, protectPayerId)
    self.protectPlayList[index] = protectPayerId
end

-- 获取我的保护者
function MiningManager:getMyProtectPlayer()
    return self.protectPlayList
end

-- 设置我的采矿防守阵型
function MiningManager:setStrategy(index, Strategy)
    self.MineStrategy[index] = Strategy
end


-- 获取我的保护者
function MiningManager:updateRoleList(index)
    -- 筛选另外一个矿的护矿
    local StrategyType = EnumFightStrategyType.StrategyType_MINE2_DEF
    local StrategyIndex = index or 1

    if StrategyIndex == 2 then
        StrategyType = EnumFightStrategyType.StrategyType_MINE1_DEF
    end

    local Strategy = ZhengbaManager:getFightList(StrategyType)
    if Strategy == nil then
        return
    end
--     print("Strategy = ", Strategy)
--     print("+++++++++++++++++++")
-- print("self.StrategyMulitData = ", ZhengbaManager.StrategyMulitData)
    self.cardRoleList:clear()
    
    for v in CardRoleManager.cardRoleList:iterator() do
        local bFindInStrategy = false
        for i=1,10 do
            if Strategy[i] and Strategy[i] == v.gmId then
                bFindInStrategy = true
            end
        end

        if bFindInStrategy == false then
            self.cardRoleList:push(v)
        end
    end
end


function MiningManager:getRoleList()
    return self.cardRoleList
end

function MiningManager:gotoAskForHelp(miningIndex)
	local layer  = require("lua.logic.mining.MiningAskForHelpLayer"):new(miningIndex)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 

end

function MiningManager:gotoFightReport()
	local layer  = require("lua.logic.mining.MiningFightReportLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 
end

-- 一条战报更详细的
function MiningManager:gotoMoreFightReport(fightId)
	local layer  = require("lua.logic.mining.MiningFightReportMoreLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 
end


-- 
function MiningManager:gotoMiningResult()
	local layer  = require("lua.logic.mining.MiningProtectRecordLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 
end


function MiningManager:gotoMiningArmyLayer(index)
    local StrategyIndex = index or 1
    StrategyIndex = StrategyIndex - 1 + EnumFightStrategyType.StrategyType_MINE1_DEF



    self:updateRoleList(index)

    --print("MiningManager:gotoMiningArmyLayer = ", StrategyIndex)
    local layer  = require("lua.logic.mining.MiningArmyLayer"):new(StrategyIndex)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 
end


function MiningManager:EnterMainArmy()
    if 1 then
        CardRoleManager:openRoleList(false);
        return
    end

    local StrategyList = StrategyManager:getList()
    for i=1,9 do
        if StrategyList[i] == nil then
            StrategyList[i] = 0
        end
    end
    -- print("StrategyManager:getList() = ", StrategyManager:getList())

    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_PVE, StrategyList)

    local layer  = require("lua.logic.mining.MiningMainArmyLayer"):new(EnumFightStrategyType.StrategyType_PVE)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    AlertManager:show() 
end



--显示采矿界面
function MiningManager:showMiningLayer()
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mining.MiningLayer");  
    AlertManager:show();
    self.IsOpenMiningLayer = true

    local info1 = self.roleMineInfo.info[1]
    local info2 = self.roleMineInfo.info[2]
    if info1.status == 0 or info1.status == 2 or info2.status==0 or info2.status == 2 then
        layer:loadData(2);
        self.enterpage = 2
    else
        layer:loadData(1);
        self.enterpage = 1
    end
end

--查询挖矿信息请求
function MiningManager:requestMiningInfo()  
    local Msg = {
    }
    TFDirector:send(c2s.QUERY_MINE,Msg)
    showLoading()
end

--返回挖矿信息
function MiningManager:roleMiningInfo(event)
    --print(" MiningManager:getRoleMiningInfo event ==== ",event.data)
    hideLoading()
    self.roleMineInfo = event.data

    if self.roleMineInfo ~= nil  and self.roleMineInfo.info ~= nil then
        if self.roleMineInfo.info[1] then
            ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MINE1_DEF, self.roleMineInfo.info[1].formation)
        end

        if self.roleMineInfo.info[2] then
            ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MINE2_DEF, self.roleMineInfo.info[2].formation)
        end

        for i=1,2 do
            if self.roleMineInfo.info[i] ~= nil and self.roleMineInfo.info[i].guardInfo ~= nil then
                self:setMyProtectPlayer(i, self.roleMineInfo.info[i].guardInfo.playerId)
            else
                self:setMyProtectPlayer(i, 0)
            end
        end  
    end
    
    if self.IsOpenMiningLayer == false then
        self:showMiningLayer()
    end
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_UPDATE_MINERALINFO, {})
end

--刷新矿请求
function MiningManager:requestRefreshMine(id)  
    local Msg = {
        id,
    }
    TFDirector:send(c2s.REFRESH_MINE,Msg)
    showLoading()
end

--返回刷新矿结果
function MiningManager:refreshMineResult(event)
    hideLoading()
end

--采矿请求
function MiningManager:requestMine(id,friendId)  
    local Msg = {
        id,
        friendId,
    }
    TFDirector:send(c2s.MINE,Msg)
    showLoading()
end

--返回采矿结果结果
function MiningManager:mineResult(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_UPDATE_MINERESULT, {})
    self:requestMiningInfo()
end

--请求领取挖矿奖励
function MiningManager:requestGetMineReward(id)  
    local Msg = {
        id,
    }
    TFDirector:send(c2s.GET_MINE_REWARD,Msg)
    showLoading()
end

--返回领取挖矿奖励结果
function MiningManager:mineReward(event)
    hideLoading()
    --print("领取挖矿奖励成功")
    self:requestMiningInfo() 
end

--请求解锁矿2
function MiningManager:requestUnlockMine()
    local Msg = {
    }
    TFDirector:send(c2s.UNLOCK_MINE,Msg)
    showLoading() 
end

--返回请求解锁矿2
function MiningManager:unlockMineResult(event)
    hideLoading()
    -- toastMessage("解锁成功")
    toastMessage(localizable.common_unlock_suc)
end

--领取佣金请求
function MiningManager:requestBrokerage()  
    local Msg = {
    }
    TFDirector:send(c2s.GET_BROKERAGE,Msg)
    showLoading()
end

--返回领取佣金结果
function MiningManager:brokerageSuccess(event)
    hideLoading()
    play_lingquyongjin()
end

--请求护卫记录
function MiningManager:requestGuardRecord(curCount)
    local Msg = {
        curCount,
    }
    TFDirector:send(c2s.GUARD_RECORD_LIST,Msg)
    showLoading()
end

--返回护卫记录
function MiningManager:guardRecordListResult(event)
    self.guardRecordList = event.data.recordList
    --print("self.guardRecordList===",self.guardRecordList)
    hideLoading()

    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_UPDATE_HISTORY, {})
end

--请求刷新正在挖矿者信息（前行）
function MiningManager:requestFreshMineList()
    local Msg = {
    }
    TFDirector:send(c2s.FRESH_MINE_LIST,Msg)
    showLoading()
end
--返回挖矿者的信息
function MiningManager:freshMineListResult(event)
    --print("self.mineListResult == ",event.data.info)
    if event.data.info ~= nil then
        --print("挖矿者信息")
        self.mineListResult = event.data.info
    else
        self.mineListResult = {}
        -- toastMessage("暂时没有挖矿玩家")
        toastMessage(localizable.MiningManager_no_mine_user)
    end
    self.randomPos = {1,2,3,4,5,6}
    self.randomposArr = {}
    for i=1,6 do
        local pos = self:getRoleRandomPos()
        table.insert(self.randomposArr,pos)
    end
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_UPDATE_QIANXING, {})
    hideLoading()
end

--护矿请求
function MiningManager:reauestGuardMine(friendId,id)
    local Msg = {
        friendId,
        id,
    }
    TFDirector:send(c2s.GUARD_MINE,Msg)
    showLoading()
end

--返回护矿请求结果
function MiningManager:guardMineResult(event)   
    hideLoading()
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_ASK_FOR_HELP_RESULT, {})
end

--锁定
function MiningManager:requestLockPlayerMine(minePlayerId,id)
    local Msg = {
        minePlayerId,
        id,
    }
    TFDirector:send(c2s.LOCK_PLAYER_MINE,Msg)
    showLoading()
end

--锁定返回
function MiningManager:mineFormationInfoReSult(event)
    hideLoading()
    self.mineFormationInfo = event.data
    --print("self.mineFormationInfo:",self.mineFormationInfo)
    --print("锁定返回")
    if self.IsOpenBuzhenLayer == false then
        local layer = require("lua.logic.mining.LootEmbattleLayer"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
        AlertManager:show()
        self.IsOpenBuzhenLayer = true
    else
        TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_GET_REPLAY_RESULT, {})
    end  
end

--解锁请求
function MiningManager:requestUnlockPlayerMine(minePlayerId,id)
    local Msg = {
        minePlayerId,
        id,
    }
    TFDirector:send(c2s.UNLOCK_PLAYER_MINE,Msg)
    showLoading()
end

--返回解锁请求
function MiningManager:unlockPlayerMineResult()
    hideLoading()
    --print("返回解锁请求")
end

--打劫请求
function MiningManager:requestChallengeMine(playerId,type,challengeIndex)
    local Msg = {
        playerId,
        type,
        challengeIndex,
    }
    TFDirector:send(c2s.CHALLENGE_MINE,Msg)
    showLoading()
end

--重置请求
function MiningManager:requestResetChallengeMine(type,minePlayerId)
    local Msg = {
        type,
        minePlayerId,
    }
    TFDirector:send(c2s.RESET_CHALLENGE_MINE,Msg)
    showLoading()
end

--返回重置结果
function MiningManager:ResetChallengeMineResult(event)
    hideLoading()
    --self:requestLockPlayerMine(self.minePlayerId,self.mineIndex)
    --print("chong zhi cheng gong 22222")
    --print("chongzhi==="，)
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_UPDATE_CHONGZHI, {})
    play_lingqu()
end

--重播
function MiningManager:requestChongbo(reportId)
    local Msg = {
        reportId,
    }
    TFDirector:send(c2s.PLAY_ARENA_TOP_BATTLE_REPORT,Msg)
    showLoading()
end

--获取人物挖矿信息
function MiningManager:getRoleMineInfo()
    return self.roleMineInfo
end

--历史请求
function MiningManager:requestReplayList()
    showLoading()
    TFDirector:send(c2s.GAIN_RELPYS,{})
end

function MiningManager:mineReplayResult(event)
    hideLoading()

    --print("event.data = ", event.data)

    self.MineReplayResult = event.data.results

    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_GET_REPLAY_RESULT, {})
end


-- 请求个更加详细的地址  展开战报
function MiningManager:requestReplayDetail(id)
    showLoading()
    TFDirector:send(c2s.GAIN_MINE_BATTLE_REPORT,{id})
end

function MiningManager:RecvReplayDetail(event)
    hideLoading()
    self.reportList = event.data.report

    if self.reportList == nil then
        -- toastMessage("没有详细的战报")
        toastMessage(localizable.MiningManager_no_fight_report)
        return
    end

    MiningManager:gotoMoreFightReport()
end


-- 请求已经护矿人的
function MiningManager:requestGuardPlayer()
    showLoading()
    TFDirector:send(c2s.GUARD_MINE_PLAYER,{})
end

-- 
function MiningManager:recvGuardPlayerCallBack(event)
    hideLoading()

    self.GuardPlayerList = event.data.guardPlayerIds
    --print("event.data.guardPlayerIds = ", event.data.guardPlayerIds)

    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_GUARD_REPLAY_LIST_RESULT, {})
end

--打劫成功
function MiningManager:robMineSuccess() 
    --print("da jie cheng gong")
    TFDirector:dispatchGlobalEventWith(MiningManager.EVENT_RUBMINE_SUCCESS, {})
end


--获取矿洞详情
function MiningManager:getMineralDetailInfo()
    local mineralInfo  = {}
    if self.roleMineInfo~= nil then 
         mineralInfo = self.roleMineInfo.info
    end
    return mineralInfo
end

--获取护卫记录
function MiningManager:getGuardRecordListResult()
    return self.guardRecordList
end

--获取挖矿者的信息
function MiningManager:getFreshMineListResult()
    return self.mineListResult
end

--设置是否打开采矿界面
function MiningManager:setIsOpenMiningLayer(isopen)
    self.IsOpenMiningLayer = isopen
end

--获得是否打开采矿界面
function MiningManager:getIsOpenMiningLayer()
    return self.IsOpenMiningLayer
end

--获得刷新矿消耗元宝
function MiningManager:getRefreshNeedYuanbao()
    local refreshNeed = ConstantData:objectByID("Mine.Refresh.Cost")
    return refreshNeed.value
end

--矿2解锁等级
function MiningManager:getMineTwoUnlockLevel()
    local unlocakLevel = ConstantData:objectByID("Mine.Unlock.Level")
    return unlocakLevel.value
end
--挖矿开放等级
function MiningManager:getMineOpenLevel()
    -- local openlevel = ConstantData:objectByID("Mine.Open.Level")
    local openLev = FunctionOpenConfigure:getOpenLevel(2101)
    return openLev
end

--获取配置表数据
function MiningManager:getMineTempDate()
    function MineTemplateData:getMinetempById(typeId,index)
        local mineTemplateInfo = nil
        for v in MineTemplateData:iterator() do
            if v.quality == typeId and v.mine_index == index then
                mineTemplateInfo = v
            end
        end
        return mineTemplateInfo
    end
end

--获得阵型数据
function MiningManager:getMineFormationInfo()
    --print()
    return self.mineFormationInfo
end

--设置打劫第几个玩家和第几个矿洞
function MiningManager:setLootPlayerIndexAndMine(mineIndex,minePlayerId,index)
    --self.mineIndex = nil
    --self.minePlayerId = nil
    self.mineIndex = mineIndex
    self.minePlayerId = minePlayerId
    self.playerIndex = index
end
--获取打劫第几个玩家和第几个矿洞
function MiningManager:getLootPlayerIndexAndMine()
    local info = {mineIndex = self.mineIndex,minePlayerId = self.minePlayerId,index = self.playerIndex}
    return info
end

--敌方阵型信息
function MiningManager:getOtherPlayerInfoByIndex(index)
    --index：1为采矿信息 2为护矿信息
    local mineFormation = self:getMineFormationInfo()
    local otherInfo = mineFormation.infos
    local roleInfo = nil
    if otherInfo[index] ~= nil then
        roleInfo = otherInfo[index]
    end
    return roleInfo
end

--敌方阵型详细信息（index 1:采矿2护矿）
function MiningManager:getDetailInfoByIndex(index)
    local detailinfo = {}
    local roleInfo = self:getOtherPlayerInfoByIndex(index)
    if roleInfo == nil then
        return detailinfo
    else
        detailinfo = roleInfo.details
        return detailinfo
    end
end

--敌方血量信息（index 1:采矿2护矿 pos位置）
function MiningManager:getMineParatInfoByPos(index,pos)
    local role_Info = nil
    local paratInfo = {}
    local roleInfo = self:getOtherPlayerInfoByIndex(index)
    --print("roleInfo22:",roleInfo)
    --print("index:",index)
    --print("roleInfo = ",roleInfo)
    if roleInfo == nil then
        return nil
    else
        paratInfo = roleInfo.paratInfo
        if next(paratInfo)~=nil then
            for m,n in pairs(paratInfo) do
                --服务器位置传过来从0开始的
                if n.index + 1 == pos then
                    role_Info = n
                end
            end
        else
            return nil
        end     
    end
    return role_Info
end

--获得敌方总血量
function MiningManager:getArmyTotalBloodByIndex(index)
    local totalblood = 0
    for i=1,9 do
        local roleinfo = self:getMineParatInfoByPos(index,i)
        if roleinfo ~= nil then
            totalblood = totalblood + roleinfo.currHp
        end
    end
    return totalblood
end

--获得己方血量信息
function MiningManager:getOwnBloodByPos(gmid)
    local curHp = nil
    local mineFormationInfo = self:getMineFormationInfo()
    local myInfos = mineFormationInfo.myInfos
    if myInfos ~= nil then
        for m,n in pairs(myInfos) do
            if n.instanceId == gmid then
                curHp = n.currHp
                --print("currHp:",currHp)

                return curHp
            end
        end
    end

    local roleItem = CardRoleManager:getRoleByGmid(gmid)
    if roleItem == nil then
        return 0
    end

    local maxHp = roleItem.totalAttribute:getAttribute(1)
    
    curHp = curHp or maxHp

    return curHp
end

--获得己方总血量
function MiningManager:getOwnTotalBlood()
    local totalblood = 0
    local isHaveBlood = false
    for i=1,9 do
        local role = StrategyManager:getRoleByIndex(i)
        if role ~= nil then
            --print("role nil 1111111111111")
            local blood = self:getOwnBloodByPos(role.gmId)
            if blood ~= nil then
                totalblood = totalblood + blood
                --print("totalblood+++:",totalblood)
                isHaveBlood = true
            end
        end
    end
    if isHaveBlood == false then
        return nil
    else
        return totalblood
    end
end

--己方血量是否已满
function MiningManager:getOwnBloodIsMax()
    local isBloodMax = true
    for i=1,9 do
        local role = StrategyManager:getRoleByIndex(i)
        if role ~= nil then
            local maxHp = role.totalAttribute:getAttribute(1)
            local currHp = self:getOwnBloodByPos(role.gmId)
            if currHp ~= maxHp then
                isBloodMax = false
            end
        end
    end
    return isBloodMax
end


--重置己方血量
function MiningManager:resetOwnBlood()
    if self.mineFormationInfo.myInfos ~= nil then
        for k,v in  pairs(self.mineFormationInfo.myInfos) do
            local roleItem = CardRoleManager:getRoleByGmid(v.instanceId)
            local maxHp = roleItem.totalAttribute:getAttribute(1)
            v.currHp = maxHp
        end
    end    
end

--获取自己死亡角色的个数
function MiningManager:getMyDeadRoleNum()
    local num = 0

    local mineFormationInfo = self:getMineFormationInfo()
    local myInfos = mineFormationInfo.myInfos
    if myInfos ~= nil then
        for m,n in pairs(myInfos) do
            if n.currHp and n.currHp <= 0 then
                num = num + 1
            end
        end
    end

    return num
end

--设置是否打开布阵界面
function MiningManager:setIsOpenBuzhenLayer(isopen)
    self.IsOpenBuzhenLayer = isopen
end

--获得前行的随机位置
function MiningManager:getRoleRandomPos()
    local num = #self.randomPos
    local index = math.random(1,num)
    local pos = self.randomPos[index]
    table.remove(self.randomPos,index)
    return pos
end

--获取随机的挖矿者位置表
function MiningManager:getRandomPostable()
    return self.randomposArr
end

function MiningManager:recvMineStautsCallback(event)
    self.mineStatus = event.data.remind
end

    -- required int32 status = 1;  //状态 -1 未解锁0未开采 1开采中2待收获
    -- required int64 endTime = 2; //采矿结束时间
function MiningManager:setMineStauts(mineIndex, status, endTime)
    if self.mineStatus == nil then
        return
    end

    self.mineStatus[mineIndex].status   = status
    self.mineStatus[mineIndex].endTime  = endTime
end


function MiningManager:redPoint()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2101)
    if teamLev < openLev then
        return false
    end

    if self.mineStatus == nil then
        return false
    end

    --print("self.mineStatus 1 = ", self.mineStatus[1])
    --print("self.mineStatus 2 = ", self.mineStatus[2])

    -- required int32 status = 1;  //状态 -1 未解锁0未开采 1开采中2待收获
    -- required int64 endTime = 2; //采矿结束时间
    for k,v in pairs(self.mineStatus) do
        if v.status then
            if v.status == 0 or v.status == 2 then
                return true
            elseif v.status == 1 and v.endTime then
                local endTime = math.ceil(v.endTime/1000)
                if MainPlayer:getNowtime() >= endTime then
                    return true
                end
            end

        end
    end

    return false
end

-- 获取我的采矿布阵
function MiningManager:getIsHaveRoleListByIndex(index)
    local StrategyType = EnumFightStrategyType.StrategyType_MINE1_DEF
    local StrategyIndex = index or 1

    if StrategyIndex == 2 then
        StrategyType = EnumFightStrategyType.StrategyType_MINE2_DEF
    end

    local Strategy = ZhengbaManager:getFightList(StrategyType)
    if Strategy == nil then
        return
    end
    local bFindInStrategy = false
    for k,v in pairs(Strategy) do
        if v~=0 then
            bFindInStrategy = true
        end
    end
    return bFindInStrategy
end

--锁定时错误
function MiningManager:getMineFormationInfoError(event)
    --print("event ====",event.errorCode)
    self:requestFreshMineList()
end

--设置进入界面第几页
function MiningManager:setPage(page)
    self.enterpage = page
end

--获取进入界面第几页
function MiningManager:getPage()
    return self.enterpage
end

--显示采矿阵容
function MiningManager:showOwnMiningformation(index)
    local StrategyIndex = index or 1
    StrategyIndex = StrategyIndex - 1 + EnumFightStrategyType.StrategyType_MINE1_DEF

    --print("MiningManager:gotoMiningArmyLayer = ", StrategyIndex)
    local layer  = require("lua.logic.mining.MiningTeam"):new(StrategyIndex)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_0)
    AlertManager:show() 
end

return MiningManager:new();
