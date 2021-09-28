-- 新屠龙传说 数据层
DragonData = class("DragonData");

function DragonData:Init()
    self.m_callbacks = {};

    -- 已通关副本id
    self.m_passedCarbons = {};

    -- 日常挑战id
    self.m_dailyCarbon = 0;

    -- 日常挑战是否已通关
    self.m_dailyPassed = false;

    -- 当前所处的页数 [初始0，获取到网络数据后>0]
    self.m_curIdx = 0;

    -- 页显示信息
    self.m_pageCfg = nil;

    ----------------------------------------------------------------------
    -- 滴血的矿石一
    self.BLEEDING_ORE_ONE = 15;
        --滴血矿石2
    self.BLEEDING_ORE_TWO = 16 ;
    -- 备战热身一
    self.PREPARE_FOR_WAR_ONE = 24;
    -- 守护公主一
    self.GUARD_PRINCESS_ONE = 10;
    -- 运送物资一
    self.FERRY_SUPPLIES_ONE = 20;

    ----------------------------------------------------------------------

    -- BOSS关卡 开始
    self.DRAGON_SLIAYER_BEGIN = 1;
    -- BOSS关卡 结束
    self.DRAGON_SLIAYER_END = 7;

    -- 猎杀精英 开始
    self.HUNT_ELITE_BEGIN = 28;
    -- 猎杀精英 结束
    self.HUNT_ELITE_END = 34;
    -------------------------------------------------------------------------

    -- 标识上一次处于 屠龙传说界面中
    self.DRAGON_SLIAYER_WINDOW = false;
    -------------------------------------------------------------------------
end

function DragonData:SetCarbonInfo(proto)
    if proto.passed_insts then
        self.m_passedCarbons = {};

        for i=1, #(proto.passed_insts) do
            table.insert(self.m_passedCarbons, proto.passed_insts[i]);
        end
    end

    -- 如果是初始进入游戏状态
    if self.m_curIdx == 0 then
        self:InitPageInfo();

        -- 获取当前未打通的页
        local totalPage = #(self.m_pageCfg);
        for i=1, totalPage do
            -- 一页页开始检查
            local pageCarbonNums = #(self.m_pageCfg[i]);
            local count = 0;
            for j=1, pageCarbonNums do
                if self:IsClearnce(self.m_pageCfg[i][j].q_id) then
                    count = count + 1;
                end
            end

            if count < pageCarbonNums then
                self.m_curIdx = i;
                break;
            end

            if i == totalPage then
                self.m_curIdx = i;
                break;
            end
        end
    end

    self.m_dailyCarbon = proto.daily_inst;
    self.m_dailyPassed = proto.daily_passed;

    self:ExecuteCallback("DragonSliayer", 0);
end

function DragonData:InitPageInfo()
    -- 获取界面显示的具体配置
    self.m_pageCfg = {};
    
    local dragonCfg = require("src/config/instanceInfolist");
    for i=1, #(dragonCfg) do
        if dragonCfg[i].q_show and dragonCfg[i].q_show > 0 then
            -- 获取页，页位置
            local tmpLabel = dragonCfg[i].q_label;
            local tmpLabelPos = dragonCfg[i].q_xy;
            
            if tmpLabel ~= nil and tmpLabelPos ~= nil then
                local pageStr = nil;
                if type(tmpLabel) == "string" then
                    pageStr = stringsplit(tmpLabel, ",");
                else
                    pageStr = {};
                    pageStr[1] = tostring(tmpLabel);
                end
                local posStr = stringsplit(tmpLabelPos, ";");

                for j=1, #pageStr do
                    local tmpPage = tonumber(pageStr[j]);

                    if self.m_pageCfg[tmpPage] == nil then
                        self.m_pageCfg[tmpPage] = {};
                    end

                    local tmpPosStr = posStr[j];
                    local commaPos = string.find(tmpPosStr, ",", 1, true);
                    local tmpX = string.sub(tmpPosStr, 1, commaPos - 1)
                    local tmpY = string.sub(tmpPosStr, commaPos+1, string.len(tmpPosStr));

                    local tmpPageTable = copyTable(dragonCfg[i]);
                    tmpPageTable.q_page_x = tonumber(tmpX);
                    tmpPageTable.q_page_y = tonumber(tmpY);
                    
                    table.insert(self.m_pageCfg[tmpPage], tmpPageTable);
                end
            end            
        end
    end
end

function DragonData:AddPassedCarbon(newId)
    -- 已经通关了
    if self:IsClearnce(newId) then
        -- 表示每日挑战已经完成过了
        if self.m_dailyCarbon == newId then
            self:ShowRewardPanel(newId, true);
            self.m_dailyPassed = true;
        else
            local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", newId);
            -- 非客户端模拟副本通用处理
            if carbonCfg and carbonCfg.q_com == 0 then
                if G_MAINSCENE then
                    -- 添加副本结束效果
                    addFBTipsEffect(G_MAINSCENE, cc.p(display.width/2, display.height/2), "res/fb/win_2.png");
                end
            end
        end
    else
        self:ShowRewardPanel(newId, false);
        table.insert(self.m_passedCarbons, newId);
    end

    if G_MAINSCENE and G_MAINSCENE.map_layer then
        if G_MAINSCENE.map_layer.updateProgress then
            G_MAINSCENE.map_layer:updateProgress(true);
        end

        if not ((newId >= self.DRAGON_SLIAYER_BEGIN and newId <= self.DRAGON_SLIAYER_END) or (newId >= self.HUNT_ELITE_BEGIN and newId <= self.HUNT_ELITE_END)) then
            if G_MAINSCENE.map_layer.m_timePanel ~= nil then
                local tmpSpr = tolua.cast(G_MAINSCENE.map_layer.m_timePanel, "cc.Sprite");
                if tmpSpr ~= nil then
                    tmpSpr:setVisible(false);
                end
            end

            if G_MAINSCENE.map_layer.timeLeft ~= nil then
                G_MAINSCENE.map_layer.timeLeft = 20;
            end

            if G_MAINSCENE.map_layer.RemoveMasterThunderEff ~= nil then
                G_MAINSCENE.map_layer:RemoveMasterThunderEff(true);
            end
        end
    end

    self:ExecuteCallback("DragonSliayer", 0);
end

function DragonData:ShowRewardPanel(newId, isDaily)   
    local dragonCfg = getConfigItemByKey("instanceInfolist", "q_id", newId);
    if dragonCfg then
        -- 奖励
        local awards = {}
        local DropOp = require("src/config/DropAwardOp")
        local tmpAwardId = 0;
        if isDaily then
            tmpAwardId = dragonCfg.q_er_show_id;
        else
            tmpAwardId = dragonCfg.q_fr_show_id;
        end
        local awardsConfig = DropOp:dropItem_ex(tmpAwardId);
        if awardsConfig and tablenums(awardsConfig) >0 then
            table.sort( awardsConfig , function(a, b)
                if a == nil or a.px == nil or b == nil or b.px == nil then
                    return false;
                else
                    return a.px > b.px;
                end
            end)
        end

        -----------------------------------------------------------------------------------------------
        -- 声望、经验数目
        local expNum = 0;
        local prestigeNum = 0;

        local commConst = require("src/config/CommDef");

        for i=1, #awardsConfig do
            ---------------------------------------------------------------------------------------------
            if awardsConfig[i]["q_item"] == commConst.ITEM_ID_PRESTIGE then
                prestigeNum = prestigeNum + tonumber(awardsConfig[i]["q_count"]);
            elseif awardsConfig[i]["q_item"] == commConst.ITEM_ID_EXP then
                expNum = expNum + tonumber(awardsConfig[i]["q_count"]);
            end
            ---------------------------------------------------------------------------------------------

            awards[i] =  { 
                                id = awardsConfig[i]["q_item"] ,       -- 奖励ID
                                num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
                                streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
                                quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
                                upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
                                time = awardsConfig[i]["q_time"] ,     -- 限时时间
                                showBind = true,
                                isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1,                          
                            }
        end

        if tablenums( awards ) > 0 then
            local awardTip = "";
            if isDaily then
                awardTip = game.getStrByKey("dragonDailyReward");
            else
                awardTip = game.getStrByKey("dragonReward");
            end

            local func = function()
                print("carbon prepare exit!");
                -- 非客户端模拟副本通用处理
                if dragonCfg.q_com == 0 then
                    if G_MAINSCENE then
                        -- 添加副本结束效果
                        addFBTipsEffect(G_MAINSCENE, cc.p(display.width/2, display.height/2), "res/fb/win_2.png");
                    end
                end
            end

            Awards_Panel( { awards = awards , award_tip = awardTip, getCallBack = func} )

            if G_MAINSCENE and G_MAINSCENE.map_layer then
                if expNum > 0 then
                    -- 经验展示
		            G_MAINSCENE.map_layer:showExpNumer(expNum, nil, 0.1, "res/mainui/number/4.png" , commConst.ePickUp_XP )
                end
	            if prestigeNum > 0 then
		            -- 声望展示
		            G_MAINSCENE.map_layer:showExpNumer(prestigeNum, nil, 0.1, "res/mainui/number/5.png" , commConst.ePickUp_Prestige)
                end
            end
        end
        -----------------------------------------------------------------------------------------------
    end

end

function DragonData:ExecuteCallback(name, para)
    if self.m_callbacks == nil then
        return;
    end

    if self.m_callbacks[name] ~= nil then
        self.m_callbacks[name](para);
    end
end

function DragonData:RegisterCallback(name, func)
    self.m_callbacks[name] = func;
end

-- 当前副本是否通关
function DragonData:IsClearnce(id)
    for i=1, #(self.m_passedCarbons) do
        if id == self.m_passedCarbons[i] then
            return true;
        end
    end

    return false;
end

-- 每日挑战是否解锁
function DragonData:IsTodayChallengeOpen()
    local count = 0;
    for i=1, #(self.m_passedCarbons) do
        if self.m_passedCarbons[i] == self.BLEEDING_ORE_ONE then
            count = count+1;
        elseif self.m_passedCarbons[i] == self.PREPARE_FOR_WAR_ONE then
            count = count+1;
        elseif self.m_passedCarbons[i] == self.GUARD_PRINCESS_ONE then
            count = count+1;
        elseif self.m_passedCarbons[i] == self.FERRY_SUPPLIES_ONE then
            count = count+1;
        end
    end

    if count >= 4 then
        return true;
    end

    return false;
end

--------------------------------------------------------------------------------------------------------------------

-- 发送通关协议(客户端主动完成的副本)
-- id: instanceInfolist.lua 第一列的id
function DragonData:SendFinishedStatusForClient(id)
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = id});
end

-- 请求新单人副本数据
function DragonData:SendSingleInstanceData()
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_SINGLEINSTANCE_DATA, "SingleInstanceDataProtocol", {});
end

-- 请求进入新单人副本
function DragonData:SendEnterSingleInstance(id)
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTER_SINGLEINSTANCE, "EnterSingleInstProtocol", {instID = id});
end

-- 请求生成每日随机单人副本
function DragonData:SendRandomDailySingleInst()
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_RANDOM_DAILY_SINGLEINST, "RequestRandomDailySingleInst", {});
end

--------------------------------------------------------------------------------------------------------------------