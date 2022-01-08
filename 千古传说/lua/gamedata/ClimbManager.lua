--[[
******无量山管理类*******

	-- by haidong.gan
	-- 2013/12/27
]]


local ClimbManager = class("ClimbManager")


ClimbManager.EVENT_ATTACK_COMPELETE   = "ClimbManager.EVENT_ATTACK_COMPELETE"
ClimbManager.CLIMB_INFORMATION = "ClimbManager.CLIMB_INFORMATION"
ClimbManager.AddClimbStarInfoMessage = "ClimbManager.AddClimbStarInfoMessage"

ClimbManager.CLIMB_SWEEP_RESULT_NOTIFY = "ClimbManager.CLIMB_SWEEP_RESULT_NOTIFY"

function ClimbManager:ctor()
    TFDirector:addProto(s2c.CLIMB_HOME_INFO, self, self.onReceiveHomeInfo)
    TFDirector:addProto(s2c.CLIMB_CHALLENGE_RESULT, self, self.onReceiveChallengeResult)
    TFDirector:addProto(s2c.CLIMB_SWEEP_RESULT, self, self.onReceiveSweepResult)
    TFDirector:addProto(s2c.MHYPASS_INFO_LIST, self, self.carbonStarInfoReceive)
    TFDirector:addProto(s2c.MHYSWEEP_RESULT, self, self.carbonQuickPassReceive)
    TFDirector:addProto(s2c.CLIMB_STAR_RESP, self, self.ClimbStarResp)

    self.mountainPower = {mountainItemId = 1 ,power = 1}
    self.climbStarInfo ={}
    self.climStarNum = 0
end

function ClimbManager:onReceiveChallengeResult( event )
    hideLoading();
    local win = event.data.win;
    if win == true then
        self.climbInfo.curId = event.data.curId;
        TFDirector:dispatchGlobalEventWith(ClimbManager.EVENT_ATTACK_COMPELETE, self.climbInfo);
    end
end

function ClimbManager:onReceiveHomeInfo( event )
    hideLoading();
    self.climbInfo = event.data
    if self.climbHomeOpenCallback then
        self.climbHomeOpenCallback()
        self.climbHomeOpenCallback = nil
    end
    TFDirector:dispatchGlobalEventWith(ClimbManager.CLIMB_INFORMATION, self.climbInfo);
end

function ClimbManager:getClimbFloorNum()
    if self.climbInfo and self.climbInfo.curId then
        return (self.climbInfo.curId - 1)
    end
    return 1
end

function ClimbManager:challengeMountain(mountainId,fightType)

    local mountainItem = ClimbConfigure:objectByID(mountainId)
    if mountainItem.min_level > MainPlayer:getLevel() then
        -- toastMessage("团队等级"..mountainItem.min_level.."级时开放！")
        toastMessage(stringUtils.format(localizable.common_function_openlevel, mountainItem.min_level))
        return
    end
    self.mountainPower = {mountainItemId = mountainId ,power = MainPlayer:getPower() /mountainItem.power}
    showLoading();
    if fightType == nil then
        fightType = 0
    end
    TFDirector:send(c2s.CLIMB_CHALLENGE_MOUNTAIN, { mountainId ,fightType} )
end

function ClimbManager:getMountainPower()
    return self.mountainPower
end
function ClimbManager:getAtkSuppress( attack , target )
    if attack == target then
        return 1
    end
    local percent = self.mountainPower.power
    if percent >= 1 then
        return 1
    end
    local rule = ClimbRuleConfigure:getRuleData( self.mountainPower.mountainItemId , percent )
    if rule == nil then
        return 1
    end
    if attack == false then
        return 1 + rule.user_atk
    end
    return 1 + rule.npc_atk
end
function ClimbManager:getBufRateSuppress( attack , target )
    if attack == target then
        return 0
    end
    local percent = self.mountainPower.power
    if percent >= 1 then
        return 0
    end
    local rule = ClimbRuleConfigure:getRuleData( self.mountainPower.mountainItemId , percent )
    if rule == nil then
        return 0
    end
    if attack == false then
        return rule.user_buff_rate
    end
    return rule.npc_buff_rate
end

function ClimbManager:challengeClimbWanneng(id,fightType)
    showLoading();
    if fightType == nil then
        fightType = 0
    end

    TFDirector:send(c2s.CHALLENGE_CLIMB_WANNENG, {id,fightType} );
end

function ClimbManager:updateHomeInfo()
    showLoading();
    TFDirector:send(c2s.CLIMB_GET_HOME_INFO, {} );

end

function ClimbManager:updateCarbonList()
    showLoading();
    TFDirector:send(c2s.CLIMB_GET_CARBON_LIST, {} );
end

function ClimbManager:getRewardItemList(mountainId)
    local mountainItem = ClimbConfigure:objectByID(mountainId) 
    return DropGroupData:GetDropItemListByIdsStr(mountainItem.drop);
end
function ClimbManager:getFirstRewardItemList(mountainId)
    local mountainItem = ClimbConfigure:objectByID(mountainId) 
    return DropGroupData:GetDropItemListByIdsStr(mountainItem.first_drop);
end

function ClimbManager:getSoulRewardItemList(soulId)
    local carbonItem = MoHeYaConfigure:objectByID(soulId) 
    return DropGroupData:GetDropItemListByIdsStr(carbonItem.drop_id);
end

function ClimbManager:restart()
    self.climbInfo = nil
    self.climbStarInfo = {}
    self.climStarNum = 0
end

function ClimbManager:showMountainLayer()
    if not self.climbInfo then
        self.climbHomeOpenCallback = function()
            AlertManager:addLayerByFile("lua.logic.climb.ClimbMountainListLayer")
            AlertManager:show()
        end
        self:updateHomeInfo()
    else
        local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbMountainListLayer")
        layer:loadHomeData(self.climbInfo)
        AlertManager:show()
    end
    
end

function ClimbManager:showDetail(mountainItem,homeInfo)
    local layer =  AlertManager:addLayerByFile("lua.logic.climb.ClimbMountainDetailLayer",AlertManager.NONE);
    layer:loadData(mountainItem,homeInfo);
    AlertManager:show();
end

function ClimbManager:showCarbonListLayer()
    AlertManager:addLayerByFile("lua.logic.climb.ClimbCarbonListLayer",AlertManager.BLOCK_AND_GRAY);
    AlertManager:show()
end

function ClimbManager:showCarbonDetailLayer(index)
    local layer = AlertManager:addLayerByFile("lua.logic.climb.CarbonDetailLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(index);
    AlertManager:show()
end

function ClimbManager:showCarbonNotOpenLayer(index)
    local layer = AlertManager:addLayerByFile("lua.logic.climb.CarbonNotOpenLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(index);
    AlertManager:show()
end

function ClimbManager:showCarbonChooseLayer(index)
    self:requestCarbonStarInfo()
    self.carbonIdx = index
end

--quanhuan add
function ClimbManager:requestCarbonStarInfo()
    TFDirector:send(c2s.GET_MHYPASS_INFO_REQUEST,{})
    showLoading()
end

function ClimbManager:carbonStarInfoReceive( event )
    hideLoading()
    self.carbonStar = event.data.info

    print('carbonStarInfoReceive.data = ',event.data)

    local layer = AlertManager:addLayerByFile("lua.logic.climb.CarbonMountainChoose",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(self.carbonIdx);
    AlertManager:show()
end


function ClimbManager:ClimbStarResp( event )
    hideLoading()
    self.climbStarInfo = event.data.star or {}
    self.climStarNum = 0
    for i=1,#self.climbStarInfo do
        self.climStarNum = self.climStarNum + self.climbStarInfo[i].star
    end
end

function ClimbManager:getClimbStarInfo( id )
    self.climbStarInfo[id] = self.climbStarInfo[id] or {}
    return self.climbStarInfo[id].star or 0
end

function ClimbManager:addClimbStarInfo( id,passLimit )
    self.climbStarInfo[id] = self.climbStarInfo[id] or {}
    self.climbStarInfo[id].sectionId = id
    self.climbStarInfo[id].passLimit = passLimit
    local oldNum = self.climbStarInfo[id].star or 0
    if passLimit == 0 then
        self.climbStarInfo[id].star = 1
    elseif passLimit == 3 then
        self.climbStarInfo[id].star = 3
    else
        self.climbStarInfo[id].star = 2
    end
    self.climbStarInfo[id].star = math.max(self.climbStarInfo[id].star,oldNum)
    self.climStarNum = self.climStarNum + self.climbStarInfo[id].star - oldNum
    TFDirector:dispatchGlobalEventWith(ClimbManager.AddClimbStarInfoMessage, self.climbInfo);
end

function ClimbManager:getCarbonStarByID( id )
    if self.carbonStar then
        for k,v in pairs(self.carbonStar) do
            if v.id == id then
                return v.star
            end
        end
    end
    return 0
end
--扫荡
function ClimbManager:requestCarbonQuickPass(id, count)
    print('id = ',id)
    print('count = ',count)
    TFDirector:send(c2s.MHYSWEEP_REQUEST,{id,count})
    showLoading()
end

function ClimbManager:carbonQuickPassReceive(event)
    hideLoading()


    local datalist = event.data.result
    print('carbonQuickPassReceive = ',event.data)
    
        -- datalist = {}
        -- datalist[1] = {}
        -- datalist[1].exp = 0
        -- datalist[1].oldLevel = 0
        -- datalist[1].currentLevel = 0
        -- datalist[1].coin = 100
        -- datalist[1].item = {}
        -- for i=1,4 do
        --     datalist[1].item[i] = {}
        --     datalist[1].item[i].type = 1
        --     datalist[1].item[i].number = 1
        --     datalist[1].item[i].itemId = 3000
        -- end       
        -- datalist[2] = {}
        -- datalist[2].exp = 0
        -- datalist[2].oldLevel = 0
        -- datalist[2].currentLevel = 0
        -- datalist[2].coin = 100
        -- datalist[2].item = {}
        -- datalist[2].item[1] = {}
        -- datalist[2].item[1].type = 1
        -- datalist[2].item[1].number = 1
        -- datalist[2].item[1].itemId = 3000
        -- datalist[2].item[2] = {}
        -- datalist[2].item[2].type = 1
        -- datalist[2].item[2].number = 1
        -- datalist[2].item[2].itemId = 3000  
            

    
    local ccdata = {}
    for i=1,#datalist do
        ccdata[i] = {}
        ccdata[i].currLev = datalist[i].currentLevel
        ccdata[i].addCoin = datalist[i].coin
        ccdata[i].addExp = datalist[i].exp
        ccdata[i].oldLev = datalist[i].oldLevel
        ccdata[i].itemlist = datalist[i].item
    end
    
    local layer = AlertManager:addLayerByFile("lua.logic.climb.CarbonQuickPassLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(ccdata)

    AlertManager:show();

--[[
    [1] = {--MHYSweepResult
        [1] = 'int32':id    [目标关卡ID]
        [2] = {--repeated MHYSweepResultItem
            [1] = 'int32':exp   [增加团队经验]
            [2] = 'int32':oldLevel  [原先团队等级]
            [3] = 'int32':currentLevel  [当前团队等级]
            [4] = 'int32':coin  [获得的金币数量]
            [5] = {--repeated RewardItem
                [1] = 'int32':type  [资源类型:1.物品;2.卡牌;3.铜币;等----]
                [2] = 'int32':number    [数量]
                [3] = 'int32':itemId    [资源id ,在非数值资源类型的情况下会发送,即有多种情况的时候会通过这个字段描述具体的id.当type为物品时表示物品id,为卡牌时表示卡牌id]
            },
        },
    }
--]]    

end

function function_name( ... )
    -- body
end

function ClimbManager:addLayerToCache()

end

function ClimbManager:requestSweep(targetId,times)
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.CLIMB)
    local maxTimes = tonumber(challengeInfo:getLeftChallengeTimes())
    local sweepTime = 0
    if not times then
        sweepTime = maxTimes
    elseif times <=0 then
       sweepTime = maxTimes
    else
        if times > maxTimes then
            sweepTime = maxTimes
        else
            sweepTime = times
        end
    end

    if sweepTime < 1 then
        -- toastMessage("没有足够的挑战次数...")
        toastMessage(localizable.common_no_tiaozhancishu)
        return
    end
    
    local message = 
    {
        targetId,
        sweepTime
    }
    showLoading()
    TFDirector:send(c2s.CLIMB_SWEEP_REQUEST, message)
end

function ClimbManager:onReceiveSweepResult(event)
    hideLoading()
    self:showSweepReslutLayer(event.data)
    TFDirector:dispatchGlobalEventWith(ClimbManager.CLIMB_SWEEP_RESULT_NOTIFY, event.data)
end

function ClimbManager:showSweepReslutLayer(data)
    local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbSweepLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1)
    layer:loadData(data)
    AlertManager:show()
end

return ClimbManager:new()
