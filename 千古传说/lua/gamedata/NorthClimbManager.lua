--[[
******无量山管理类*******

    -- by haidong.gan
    -- 2013/12/27
]]


local NorthClimbManager = class("NorthClimbManager")


NorthClimbManager.NORTH_CAVE_CHANGE_OPTION_SUCCESS   = "NorthClimbManager.NORTH_CAVE_CHANGE_OPTION_SUCCESS"
NorthClimbManager.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS   = "NorthClimbManager.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS"
NorthClimbManager.RESET_NORTH_CAVE_RESULT   = "NorthClimbManager.RESET_NORTH_CAVE_RESULT"
NorthClimbManager.NORTH_CAVE_CHEST_GOT_MARK_UPDATE   = "NorthClimbManager.NORTH_CAVE_CHEST_GOT_MARK_UPDATE"

function NorthClimbManager:ctor()
    
    TFDirector:addProto(s2c.RESET_NORTH_CAVE_RESULT, self, self.onReceiveResetNorthCaveResult)
    TFDirector:addProto(s2c.CHALLENGE_NORTH_CAVE_RESULT, self, self.onReceiveChallengeNorthCaveResult)
    TFDirector:addProto(s2c.NORTH_CAVE_DETAILS, self, self.onReceiveNorthCaveDetails)
    TFDirector:addProto(s2c.NORTH_CAVE_GAME_LEVEL_LIST, self, self.onReceiveNorthCaveGameLevelListMsg)
    TFDirector:addProto(s2c.NORTH_CAVE_SWEEP_RESULT, self, self.onReceiveNorthCaveSweepResult)
    TFDirector:addProto(s2c.NORTH_CAVE_ATTRIBUTE_INFO, self, self.onReceiveNorthCaveAttributeInfo)
    TFDirector:addProto(s2c.NORTH_CAVE_ATTRIBUTE_LIST, self, self.onReceiveNorthCaveAttributeList)
    TFDirector:addProto(s2c.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS, self, self.onReceiveNorthCaveAttributeChoiceSuccess)
    TFDirector:addProto(s2c.NORTH_CAVE_CHANGE_OPTION_SUCCESS, self, self.onReceivNorthCaveChangeOptionSuccess)
    TFDirector:addProto(s2c.NORTH_CAVE_CHEST_GOT_MARK_UPDATE, self, self.onReceivNorthCaveChestGotMarkUpdate)
    self:restart()
    self.maxLength = NorthCaveData:length()
end
function NorthClimbManager:restart()
    self.northDiamod = 0
    self.floor = 0
    self.floorMax = 0
    self.maxPassCount = 0
    self.maxSweepCount = 0
    self.chestGotMark = 0
    self.remainResetCount = 0
    self.needGetInfo = true
    self.isFail = false
    self.northCaveFloorInfo = {}
    self.northCaveAttributeInfo = {}
end

function NorthClimbManager:resetByDay()
    self.remainResetCount = 1
end

--重置操作结果
function NorthClimbManager:onReceiveResetNorthCaveResult( event )
    self.northDiamod = 0
    self.chestGotMark = 0
    self.isFail = false
    self.floor = 1
    self.floorMax = 1
    self.northCaveFloorInfo = {}
    self.northCaveAttributeInfo = {}

end
--挑战结果
function NorthClimbManager:onReceiveChallengeNorthCaveResult( event )
    print("onReceiveChallengeNorthCaveResult")
    local data = event.data
    if data.score == 0 then
        self.isFail = true
        return
    end
    self.floorMax = data.nextId
    if data.nextId == 0 then
        self.floorMax = self.maxLength+1
    end
    self.northCaveFloorInfo[self.floor].score = data.score
    self.northDiamod = data.tokens
    TFDirector:dispatchGlobalEventWith(MainPlayer.ResourceUpdateNotifyBatch , {})
    self:mathFloorState()
end
--[[
//获取北窟关卡信息
// code = 0x4902
message NorthCaveDetails{
    required int32 currentId = 1;                       //当前关卡
    repeated NorthCaveGameLevelStruct gameLevel = 2;    //关卡
    repeated NorthCaveAttributeInfo attribute = 3;      //属性
    required int32 maxPassCount = 4;                    //最大通关数
    required int32 maxSweepCount = 5;                   //最大可扫荡关卡数量
    required int32 tokens = 6;                          //剩余无量山钻数量，代币
}

//北窟关卡信息
message NorthCaveGameLevelStruct{
    required int32 sectionId = 1;                       //关卡ID
    required int32 formationId = 2;                     //npc阵形Id,对应t_s_north_cave_npc表格ID
    repeated int32 options = 3;                         //通关选项
    required int32 choice = 4;                          //通关选项选中状态，根据位运算来进行存储
    required int32 score = 5;                           //通关分数，星数
}
]]
--获取北窟关卡信息
function NorthClimbManager:onReceiveNorthCaveDetails( event )
    hideLoading();
    local data = event.data
    -- Lua_writeFile("NorthCaveDetails",false,data)
    self.floorMax = data.currentId
    if self.floorMax == 0 then
        self.floorMax = self.maxLength+1
    end
    self.floor = self.floorMax
    self.maxPassCount = data.maxPassCount
    self.maxSweepCount = data.maxSweepCount
    self.northDiamod = data.tokens
    TFDirector:dispatchGlobalEventWith(MainPlayer.ResourceUpdateNotifyBatch , {})
    self.chestGotMark = data.chestGotMark
    self.remainResetCount = data.remainResetCount
    self.isFail = data.hasNotPass

    self.northCaveFloorInfo = data.gameLevel
    self.northCaveAttributeInfo = data.attribute
    if self.needGetInfo then
        self.needGetInfo = false
        self:showNorthMountainLayer()
    else
        self:mathFloorState()
        TFDirector:dispatchGlobalEventWith(NorthClimbManager.RESET_NORTH_CAVE_RESULT, {});
    end
end
 --下发新的关卡信息
function NorthClimbManager:onReceiveNorthCaveGameLevelListMsg( event )
    print("NorthClimbManager:onReceiveNorthCaveGameLevelListMsg")
    local data = event.data
    -- Lua_writeFile("newLevel/newLevel",true,data)
    if data.gameLevel == nil then
        return
    end
    for i=1,#data.gameLevel do
        local info = data.gameLevel[i]
        self.northCaveFloorInfo[info.sectionId] = info
    end
end

--[[
// 扫荡结果
// code = 0x4910
message NorthCaveSweepResult{
    repeated NorthCaveSweepResultItem result = 1;       //结果列表
    required int32 nextId = 2;                          //下一关ID
    required int32 tokens = 3;                          //无量山钻数量
}
]]
 --扫荡结果
function NorthClimbManager:onReceiveNorthCaveSweepResult( event )
    hideLoading()
    local data = event.data
    print("onReceiveNorthCaveSweepResult = ",data)
    self.floorMax = data.nextId
    if self.floorMax == 0 then
        self.floorMax = self.maxLength+1
    end
    self.northDiamod = data.tokens
    TFDirector:dispatchGlobalEventWith(MainPlayer.ResourceUpdateNotifyBatch , {})
    self:mathFloorState()
    for k,v in pairs(data.result) do
        if self.northCaveFloorInfo[v.id] ~= nil then
            self.northCaveFloorInfo[v.id].score = 3
        end
    end
    self:showQuickPassReslutListLayer(data.result)
end
 --属性选择添加
function NorthClimbManager:onReceiveNorthCaveAttributeInfo( event )
    local data = event.data
    self.northCaveAttributeInfo[data.index] = data
end
 --属性选择列表
function NorthClimbManager:onReceiveNorthCaveAttributeList( event )

end

 --属性选择
function NorthClimbManager:RequestChoiceCaveAttribute( targetId )
    if targetId ~= 0 then
        local exterAttr = NorthCaveExterAttrData:objectByID(targetId)
        if exterAttr == nil then
            print("鼓舞属性信息 == null ， id ==",targetId)
            return
        end

        if self.northDiamod < exterAttr.consume then
            toastMessage(localizable.BEIKU_NOT_ENOUGH_TOKENS)
            return
        end
    end
    local floor = math.floor(self.floor/3)
    if floor <= 0 then
        return
    end
    showLoading();
    TFDirector:send(c2s.REQUEST_CHOICE_CAVE_ATTRIBUTE,{targetId,floor})
end

 --属性选择成功通知
function NorthClimbManager:onReceiveNorthCaveAttributeChoiceSuccess( event )
    hideLoading()
    local data = event.data
    local attributeInfo = data.info
    self.northCaveAttributeInfo[attributeInfo.index] = attributeInfo
    if attributeInfo.skip == false and attributeInfo.choice ~= 0 then
        local exterAttr = NorthCaveExterAttrData:objectByID(attributeInfo.choice)
        if exterAttr then
            self.northDiamod = self.northDiamod - exterAttr.consume
            TFDirector:dispatchGlobalEventWith(MainPlayer.ResourceUpdateNotifyBatch , {})
        end
    end

    AlertManager:close()
    self.floor = self.floorMax
    TFDirector:dispatchGlobalEventWith(NorthClimbManager.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS, {});
end

 --选项刷新成功通知
function NorthClimbManager:onReceivNorthCaveChangeOptionSuccess( event )
    hideLoading()
    local data = event.data
    if self.northCaveFloorInfo[data.sectionId] == nil then
        return
    end
    self.northCaveFloorInfo[data.sectionId].options = data.options
    self.northCaveFloorInfo[data.sectionId].choice = 0
    TFDirector:dispatchGlobalEventWith(NorthClimbManager.NORTH_CAVE_CHANGE_OPTION_SUCCESS, {});
end

 --箱子领取记录更新
function NorthClimbManager:onReceivNorthCaveChestGotMarkUpdate( event )
    hideLoading()
    local data = event.data
    self.chestGotMark = data.chestGotMark
    local state = self:mathFloorState()
    if state == 2 then
        local temp_floor = math.ceil(self.floor/3)*3
        local northCaveInfo = NorthCaveData:objectByID(temp_floor)
        if northCaveInfo == nil then
            print("关卡数据为空  id== ",temp_floor)
            return 0
        end

        local rewardConfigure = RewardConfigureData:objectByID(northCaveInfo.chest)
        if rewardConfigure == nil then
            print("找不到奖励配置 id == ",northCaveInfo.chest)
            return 0
        end
        local reward_num = 0
        local rewardItems = rewardConfigure:getReward()
        for k,v in pairs(rewardItems.m_list) do
            reward_num = reward_num + 1
        end
        if reward_num == 1 then
            self:showClimbInspireLayer()
        end
    end

    TFDirector:dispatchGlobalEventWith(NorthClimbManager.NORTH_CAVE_CHEST_GOT_MARK_UPDATE, {});
end


function NorthClimbManager:ChallengeNorthCave(sectionId, choice,fightType)
    AlertManager:close()
    showLoading();
    if fightType == nil then
        fightType = 0
    end
    local msg = {
        sectionId,
        choice,
        fightType,
    }
    self.sectionId = sectionId;
    TFDirector:send(c2s.CHALLENGE_NORTH_CAVE,msg)
end
function NorthClimbManager:RequestChangeCaveOption(sectionId)
    showLoading();
    TFDirector:send(c2s.REQUEST_CHANGE_CAVE_OPTION,{sectionId})
end
--重置无量山北窟
function NorthClimbManager:RequestResetNorthCave()
    if self.remainResetCount <= 0 then
        toastMessage(localizable.BEIKU_CAN_NOT_RESET)
        return
    end
    showLoading();
    TFDirector:send(c2s.REQUEST_RESET_NORTH_CAVE,{})
end
--扫荡
function NorthClimbManager:NorthCaveSweepRequest()
    if self.isFail then
        toastMessage(localizable.BEIKU_HAS_NOT_PASS)
        return
    end
    if self:mathFloorState() == 1 then
        toastMessage(localizable.BEIKU_GET_AND_SWEEP)
        return;
    elseif self:mathFloorState() ==2 then
        toastMessage(localizable.BEIKU_CHOICE_ATTRIBUTE_AND_SWEEP)
        return;
    elseif self:mathFloorState() ==3 then
        toastMessage(localizable.BEIKU_ALL_PASS)
        return;
    end
    if self.floor > self.maxSweepCount then
        toastMessage(localizable.BEIKU_CAN_NOT_SWEEP)
        return
    end

    -- self:OneKeySweepRequest()
    showLoading();
    -- local floor = math.min(math.ceil(self.floor/3)*3,self.maxSweepCount)
    -- local length =  floor - self.floor
    -- if length <= 0 then
    --     return
    -- end
    -- print("扫荡了"..length.."层")
    TFDirector:send(c2s.NORTH_CAVE_SWEEP_REQUEST,{0})
end
function NorthClimbManager:getRewardItemList(mountainId)
    local mountainInfo = NorthCaveData:objectByID(mountainId)
    return DropGroupData:GetDropItemListByIdsStr(mountainInfo.drop_1);
end
function NorthClimbManager:getRewardItemListByIndex(mountainId,index)
    local mountainInfo = NorthCaveData:objectByID(mountainId)
    return DropGroupData:GetDropItemListByIdsStr(mountainInfo["drop_"..index]);
end

function NorthClimbManager:showNorthMountainLayer()
    if self.needGetInfo then
        print("=================showNorthMountainLayer==================")
        showLoading();
        TFDirector:send(c2s.GET_NORTH_CAVE_DETAILS,{})
        return
    end
    AlertManager:close()
    local state = self:mathFloorState()
    AlertManager:addLayerByFile("lua.logic.climb.ClimbNorthMountainLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end


function NorthClimbManager:showClimbChooseLayer(mountainInfo)
    if self.isFail then
        toastMessage(localizable.BEIKU_HAS_NOT_PASS)
        return
    end
    local state = self:mathFloorState()
    if state == 1 then
        toastMessage(localizable.BEIKU_GET_AND_PASS)
        return
    end
    if state == 2 then
        -- toastMessage("请选择属性后进行下一关")
        toastMessage(localizable.NorthClimbManager_choose_att_next_level)
        return
    end
    if state == 3 then
        toastMessage(localizable.BEIKU_ALL_PASS)
        return
    end
    local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbChooseLayer",AlertManager.BLOCK_AND_GRAY);
    layer:loadMissionInfo(mountainInfo)
    AlertManager:show()
end

function NorthClimbManager:showClimbInspireLayer()
    local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbInspireLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end

function NorthClimbManager:showOpenBoxLayer()
    local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbOpenBox",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end


function NorthClimbManager:getNorthCaveAttributeInfoByFloor()
    local floor = math.floor(self.floor/3)
    if floor <= 0 then
        return nil
    end
    return self.northCaveAttributeInfo[floor]
end

function NorthClimbManager:getNowFloorOption()
    local tbl = {}
    local floorInfo = self.northCaveFloorInfo[self.sectionId]
    for i=1,2 do
        local choice = bit_and(floorInfo.choice,2^(i-1))
        if choice ~= 0 then
            tbl[#tbl+1] = floorInfo.options[i]
        end
    end
    return tbl
end

function NorthClimbManager:changeNextFloor()
    if self.northCaveFloorInfo[self.floor + 1] == nil then
        return
    end
    self.floor = self.floor + 1
end

function NorthClimbManager:mathFloorState()
    local compelteFloor = self.floorMax - 1
    if compelteFloor == 0 then
        self.floor = self.floorMax
        return 0
    end
    if math.mod(compelteFloor,3) ~= 0 then
        self.floor = self.floorMax
        return 0
    end
    local temp_floor = compelteFloor/3
    local isget = self.chestGotMark >= temp_floor --bit_and_64(self.chestGotMark,2^(temp_floor-1))
    if not isget then --== 0 then
        self.floor = compelteFloor
        return 1
    end

    if self.floorMax >= NorthCaveData:length() then
        self.floor = NorthCaveData:length()
        return 3
    end

    if self.northCaveAttributeInfo[temp_floor] then
        if self.northCaveAttributeInfo[temp_floor].choice == 0 and self.northCaveAttributeInfo[temp_floor].skip == false then
            self.floor = compelteFloor
            return 2
        end
    end
    self.floor = self.floorMax
    return 0
end

function NorthClimbManager:showBox()
    local state = self:mathFloorState()
    if state == 2 then
        toastMessage(localizable.BEIKU_CHEST_ALREAY_OPEN)
        return 2
    elseif state == 1 then
        self:requestGetCaveChestReward()
        return 1
    elseif state == 3 then
        toastMessage(localizable.BEIKU_ALL_PASS)
        return 2
    end
    local temp_floor = math.ceil(self.floor/3)*3
    local northCaveInfo = NorthCaveData:objectByID(temp_floor)
    if northCaveInfo == nil then
        print("关卡数据为空  id== ",temp_floor)
        return 0
    end

    local calculateRewardList = TFArray:new();
    local rewardConfigure = RewardConfigureData:objectByID(northCaveInfo.chest)
    if rewardConfigure == nil then
        print("找不到奖励配置 id == ",northCaveInfo.chest)
        return 0
    end

    local rewardItems = rewardConfigure:getReward()
    for k,v in pairs(rewardItems.m_list) do
        local rewardInfo = {}
        rewardInfo.type = v.type
        rewardInfo.itemId = v.itemid
        rewardInfo.number = v.number
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.climb.ClimbBoxShow",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    -- layer:loadData(calculateRewardList, "通关本层可领");
    layer:loadData(calculateRewardList, localizable.NorthClimbManager_reward_title)
    AlertManager:show();       

    return 3
end

function NorthClimbManager:requestGetCaveChestReward()
    -- AlertManager:close()
    local floor = math.floor(self.floor/3)
    if floor <= 0 then
        return
    end
    showLoading();
    TFDirector:send(c2s.REQUEST_GET_CAVE_CHEST_REWARD ,{floor})
end

function NorthClimbManager:showQuickPassReslutListLayer(data)
    local layer = AlertManager:addLayerByFile("lua.logic.climb.QuickPassNorthClimbLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(data);
    AlertManager:show();
end


function NorthClimbManager:getAttributeInfo()
    local attribute_list = {}
    local length = 0
    for k,v in pairs(self.northCaveAttributeInfo) do
        if v.choice ~= 0 and v.skip == false then
            local exterAttr = NorthCaveExterAttrData:objectByID(v.choice)
            if exterAttr == nil then
                print("鼓舞属性信息 == null ， id ==",v.choice)
                break;
            end
            attribute_list[exterAttr.attribute_key] = attribute_list[exterAttr.attribute_key] or 0
            attribute_list[exterAttr.attribute_key] = math.floor(exterAttr.attribute_value/100) + attribute_list[exterAttr.attribute_key]
            length = length + 1
        end
    end
    return attribute_list ,length
end

function NorthClimbManager:getAtkSuppress( attack , target )
    if attack == target then
        return 1
    end
    local mountainItem = NorthCaveData:objectByID(self.floor)
    local percent = MainPlayer:getPower() /mountainItem.power
    if percent >= 1 then
        return 1
    end
    local rule = ClimbRuleConfigure:getNorthRuleData( self.floor , percent )
    if rule == nil then
        return 1
    end
    if attack == false then
        return 1 + rule.user_atk
    end
    return 1 + rule.npc_atk
end
function NorthClimbManager:getBufRateSuppress( attack , target )
    if attack == target then
        return 0
    end
    local mountainItem = NorthCaveData:objectByID(self.floor)
    local percent = MainPlayer:getPower() /mountainItem.power
    if percent >= 1 then
        return 0
    end
    local rule = ClimbRuleConfigure:getNorthRuleData( self.floor , percent )
    if rule == nil then
        return 0
    end
    if attack == false then
        return rule.user_buff_rate
    end
    return rule.npc_buff_rate
end


function NorthClimbManager:OneKeySweepRequest()
    print("NorthClimbManager:OneKeySweepRequest")
    if self.isFail then
        toastMessage(localizable.BEIKU_HAS_NOT_PASS)
        return
    end
    if self:mathFloorState() == 1 then
        toastMessage(localizable.BEIKU_GET_AND_SWEEP)
        return;
    elseif self:mathFloorState() ==2 then
        toastMessage(localizable.BEIKU_CHOICE_ATTRIBUTE_AND_SWEEP)
        return;
    elseif self:mathFloorState() ==3 then
        toastMessage(localizable.BEIKU_ALL_PASS)
        return;
    end
    if self.floor > self.maxSweepCount then
        toastMessage(localizable.BEIKU_CAN_NOT_SWEEP)
        return
    end
    showLoading()
    TFDirector:send(c2s.ONE_KEY_SWEEP_REQUEST, {})
end
function NorthClimbManager:getMapId()
    local northCaveInfo = NorthCaveData:objectByID(self.floor)
    if northCaveInfo then
        return northCaveInfo.scene_id
    end
    return 22
end

return NorthClimbManager:new()
