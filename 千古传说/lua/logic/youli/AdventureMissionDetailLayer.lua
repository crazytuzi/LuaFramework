--[[
******奇遇关卡推图-详情*******

    -- by quanhuan
    -- 2016/3/15
]]
local AdventureMissionDetailLayer = class("AdventureMissionDetailLayer", BaseLayer);

CREATE_SCENE_FUN(AdventureMissionDetailLayer);
CREATE_PANEL_FUN(AdventureMissionDetailLayer);

AdventureMissionDetailLayer.LIST_ITEM_WIDTH = 200

local ResetData  = require('lua.table.t_s_reset_consume')
local SweepData  = require('lua.table.t_s_sweep')

function AdventureMissionDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.youli.MissionDetail");
    self.firstShow = true
end

function AdventureMissionDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.youli,{HeadResType.BAOZI,HeadResType.YUELI,HeadResType.SYCEE}) 
    self.generalHead:setVisible(true)

    self.btn_close          = TFDirector:getChildByPath(ui, 'Btn_close');
    self.btn_close:setVisible(false)


    --今日挑战次数
    self.txt_point            = TFDirector:getChildByPath(ui, 'txt_number')
    --推荐战斗力
    self.txt_zhanli            = TFDirector:getChildByPath(ui,'txt_zhanli')
    --今日免费次数
    self.txt_freequick        = TFDirector:getChildByPath(ui, 'txt_freequick')
    --消耗元宝
    self.img_qucikneed            = TFDirector:getChildByPath(ui, 'img_qucikneed')
    self.txt_qucikneed            = TFDirector:getChildByPath(ui, 'txt_qucikneed')
    --关卡说明文字
    self.txt_storydetail          = TFDirector:getChildByPath(ui, 'txt_storydetail')
    --关卡名字
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')
    --胜利一场奖励
    self.panel_reward             = TFDirector:getChildByPath(ui, 'panel_reward')
    --胜利两场奖励
    self.panel_reward2          = TFDirector:getChildByPath(ui, 'panel_reward2')
    --敌人信息
    local texture = {
        [1] = {"ui_new/youli/btn_team1.png","ui_new/youli/btn_team1s.png"},
        [2] = {"ui_new/youli/btn_team2.png","ui_new/youli/btn_team2s.png"}
    }
    self.panel_buzhen = {}
    self.btn_team = {}
    self.button = {}
    self.panel_reward = {}
    self.panelBuzhenPos = {}
    for k=1,2 do
        self.panel_reward[k] = TFDirector:getChildByPath(ui, 'panel_reward'..k)
        self.panel_buzhen[k] = TFDirector:getChildByPath(ui, 'panel_buzhen'..k)
        self.btn_team[k] = TFDirector:getChildByPath(ui, 'btn_team'..k)   
        self.btn_team[k].selectTexture =  texture[k][2]
        self.btn_team[k].normalTexture =  texture[k][1]
        self.btn_team[k]:setZOrder(10)
        self.panelBuzhenPos[k] = self.panel_buzhen[k]:getPosition()
        for i=1,9 do
            local index = (k-1)*9 + i
            local panel = TFDirector:getChildByPath(ui, 'panel_buzhen'..k)

            local btnName = "panel_item" .. i;
            self.button[index] = TFDirector:getChildByPath(panel, btnName);

            btnName = "btn_icon"..i;
            -- print('k = ',k)
            -- print('self.button[index] = ',self.button)
            self.button[index].bg = TFDirector:getChildByPath(panel, btnName);
            self.button[index].bg:setVisible(false);

            self.button[index].icon = TFDirector:getChildByPath(self.button[index].bg ,"img_touxiang");
            self.button[index].icon:setVisible(false);

            self.button[index].img_zhiye = TFDirector:getChildByPath(self.button[index], "img_zhiye");
            self.button[index].img_zhiye:setVisible(false);

            self.button[index].quality = TFDirector:getChildByPath(panel, btnName);
        end
    end

    local bgTipsNode = TFDirector:getChildByPath(ui, "bg_xxxx")
    self.bg_xxxx = TFDirector:getChildByPath(bgTipsNode, "txt_xxxxx")
    self.bg_xxxx2 = TFDirector:getChildByPath(ui, "bg_xxxx2")

    --重置按钮
    self.btn_reset            = TFDirector:getChildByPath(ui, 'btn_reset')
    --挑战按钮
    self.btn_attack           = TFDirector:getChildByPath(ui, 'btn_attack')
    --布阵按钮
    self.btn_army             = TFDirector:getChildByPath(ui, 'btn_army')
    --佣兵按钮
    self.btn_yongbing         = TFDirector:getChildByPath(ui, 'btn_yongbing')
    self.btn_yongbing:setVisible(false)
    --扫荡按钮
    self.btn_quick1            = TFDirector:getChildByPath(ui, 'btn_quick1')
    self.btn_quick3               = TFDirector:getChildByPath(ui, 'btn_quick3')
    self.txt_quick_time           = TFDirector:getChildByPath(ui, 'LabelBMFont_MissionDetail_1')
    --查看敌方阵容按钮

    self.quick_need_money_tip = CCUserDefault:sharedUserDefault():getBoolForKey("youli_quick_need_money_tip")    
end

function AdventureMissionDetailLayer:loadData(missionId)

    self.missionId = missionId
    self.selectTeamIndex = 1
end

function AdventureMissionDetailLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
    self:refreshBaseUI();

    self.generalHead:onShow()
    -- if self.firstShow == true then
    --     self.ui:runAnimation("Action0",1);
    --     self.firstShow = false
    -- end
end

function AdventureMissionDetailLayer:refreshBaseUI()

end

function AdventureMissionDetailLayer:refreshUI()

    if not self.isShow then
        return;
    end

    local mission = AdventureMissionManager:getMissionById(self.missionId)
    print('mission = ',mission)
    local map = AdventureMissionManager:getMapById(mission.map_id)
    
    self.txt_title:setText( map.name .. " " .. mission.name )
    self.txt_storydetail:setText(mission.description)

    self:drawReward()

    local panelCount = 1
    self.btn_team[1]:setVisible(false)
    self.btn_team[2]:setVisible(false)
    self.panel_buzhen[2]:setVisible(false)
    if mission.type == 4 then
        panelCount = 2
        self.btn_team[1]:setVisible(true)
        self.btn_team[2]:setVisible(true)
        self.panel_buzhen[2]:setVisible(true)
    end
    
    for k=1,panelCount do

        local npcSetting = mission.npc
        if k == 2 then
            npcSetting = mission.second_npc
        end

        local npcs = NPCData:GetNPCListByIds(npcSetting)
        for i=1,9 do
            local role = npcs[i];
            local index = (k-1)*9 + i
            if  role ~= nil then
                self.button[index].icon:setVisible(true);
                self.button[index].icon:setTexture(role:getHeadPath());

                self.button[index].bg:setVisible(true);
                self.button[index].bg.role = role;

                self.button[index].bg.logic = self;
                self.button[index].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);

                self.button[index].img_zhiye:setVisible(true);
                self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. RoleData:objectByID(role.role_id).outline ..".png");
                
                self.button[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
            else
                self.button[index].img_zhiye:setVisible(false);  
                self.button[index].icon:setVisible(false);
                self.button[index].bg:setVisible(false);     
            end
        end
    end

    self.btn_attack:setVisible(false)
    self.btn_reset:setVisible(false)

    if mission.challengeCount >= mission.max_challenge_count then
        self.btn_reset:setVisible(true);
    else
        self.btn_attack:setVisible(true);
    end
    self.txt_point:setText(mission.max_challenge_count - mission.challengeCount .. "/" .. mission.max_challenge_count)
    self:refreshQuickPass();

    --推荐战力
    local recommendPower = 0
    if mission.recommend_power then
        recommendPower = mission.recommend_power
    end
    self.txt_zhanli:setText(recommendPower)
end

function AdventureMissionDetailLayer:refreshQuickPass()
    local mission = AdventureMissionManager:getMissionById(self.missionId);

    self.btn_quick1:setVisible(false);
    self.btn_quick3:setVisible(false);

    self.txt_freequick:setVisible(false);
    self.img_qucikneed:setVisible(false);
    self.btn_army:setVisible(false);
    self.btn_yongbing:setVisible(false);

    if mission.starLevel < MissionManager.STARLEVEL3 then
        self.btn_army:setVisible(true);
        -- self.btn_yongbing:setVisible(true);
        return;
    end

    self.btn_quick1:setVisible(true);
    self.btn_quick3:setVisible(true);

    if mission.type == AdventureMissionManager.singleFight then
        self.maxChallengeCount = 9
    else
        self.maxChallengeCount = 5
    end   

    local leftChallengeTimes = mission.max_challenge_count - mission.challengeCount;
    self.txt_quick_time:setText(math.min(self.maxChallengeCount, leftChallengeTimes))


    local freeQuickTimes = ConstantData:getValue("Mission.FreeQuick.Times");

    local vipItem = VipData:getVipItemByTypeAndVip(2060, MainPlayer:getVipLevel()) --- vip对应的扫荡次数

    local vipQuickTimes = (vipItem and vipItem.benefit_value) or 0

    freeQuickTimes = 0 + vipQuickTimes

    if MissionManager.useQuickPassTimes >= freeQuickTimes then

        -- 判断扫荡道具
        local tool = BagManager:getItemById(30035)
        if tool and tool.num > 0 then
            self.txt_freequick:setVisible(true)
            self.txt_freequick:setText(localizable.youli_saodangling .. tool.num)
            return
        end


        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
        self.img_qucikneed:setVisible(true);
        self.txt_qucikneed:setText(localizable.youli_xiaohao .. freeQuickprice)
        self.txt_qucikneed.cost = freeQuickprice;
    else
        self.txt_freequick:setVisible(true);
        self.txt_freequick:setText(localizable.youli_freeTimes .. (freeQuickTimes - MissionManager.useQuickPassTimes));
        self.txt_qucikneed.cost = 0;
    end

end

function AdventureMissionDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;

    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
end

function AdventureMissionDetailLayer.onCloseClickHandle(sender)
    local self = sender.logic;
    -- self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
        AlertManager:close()
    -- end)

    -- self.ui:runAnimation("Action1",1)
end

function AdventureMissionDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;
    
    local missionId = self.missionId;
    local mission = AdventureMissionManager:getMissionById(missionId);


    local leftChallengeTimes = mission.max_challenge_count - mission.challengeCount;
    local openVip = ConstantData:getValue("Mission.ManyQuick.NeedVIP");

    MissionManager.attackDes = nil;
    if sender == self.btn_attack then

    elseif sender == self.btn_quick1 then
    elseif sender == self.btn_quick3 then

        if MainPlayer:getVipLevel() < openVip then
            --local msg =  string.format(localizable.youli_text1, openVip)
			local msg = stringUtils.format(localizable.youli_text1, openVip)
            CommonManager:showOperateSureLayer(
                    function()
                        PayManager:showPayLayer();
                    end,
                    nil,
                    {
                    title = localizable.youli_text2,
                    msg = msg,
                    uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                    }
            )
            return;
        end
        if leftChallengeTimes >= self.maxChallengeCount then
            leftChallengeTimes = self.maxChallengeCount
        end
        
        if not MainPlayer:isEnoughTimes( EnumRecoverableResType.BAOZI , mission.consume_body_strength * leftChallengeTimes, false )  then
            -- MissionManager.attackDes = "体力不足，无法继续扫荡"
            -- toastMessage("体力不足，无法继续扫荡");
            VipRuleManager:showReplyLayer(EnumRecoverableResType.BAOZI)
            return
        end
    end

    --判断体力
    if not MainPlayer:isEnoughTimes(EnumRecoverableResType.BAOZI , mission.consume_body_strength * 1, true )  then
        return;
    end
    
    --判断剩余挑战次数
    if mission.challengeCount >= mission.max_challenge_count then
        -- local useResetTime = MissionManager.useResetTimes;
        local useResetTime = mission.resetCount
        
        local vipItem = VipData:getVipItemByTypeAndVip(2021,MainPlayer:getVipLevel());
        local maxResetTime = (vipItem and vipItem.benefit_value) or 0;

        local need = (useResetTime + 1) * ConstantData:getValue("Mission.Reset.Times.price");

        

        if maxResetTime - useResetTime < 1 then
            local nextUpVip = VipData:getVipNextAddValueVip(2021,MainPlayer:getVipLevel())
            if nextUpVip then
                -- local msg = (maxResetTime <= 0 
                --     and "提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                --     or "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                --     );
                local str1 = stringUtils.format(localizable.youli_text8, nextUpVip.vip_level, nextUpVip.benefit_value)
                local str2 = stringUtils.format(localizable.youli_text9, nextUpVip.vip_level, nextUpVip.benefit_value)
                local msg = (maxResetTime <= 0 and str1 or str2);
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        title = (maxResetTime <= 0 and localizable.youli_text2 or localizable.youli_text10),
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
            else
                -- toastMessage("挑战次数已用完，今日重置次数已用完");
                toastMessage(localizable.youli_text11)
            end
        else

            local configure = ResetData:objectByID(1)

            if configure then
                local toolId  = configure.token_id
                local temptbl = string.split(configure.token_num, ',')
                local usedResetIndex = useResetTime + 1
                if usedResetIndex > #temptbl then
                    usedResetIndex = #temptbl
                end

                print("useResetTime = ", useResetTime)
                print("temptbl = ", temptbl)
                print("usedResetIndex = ", usedResetIndex)
                local cost = tonumber(temptbl[usedResetIndex])

                print("cost = ", cost)
                -- 重置令 30034
                local resetTool = BagManager:getItemById(toolId)
                if resetTool  then
                    print("当前拥有重置令 = ", resetTool.num)
                end

                if resetTool and resetTool.num >= cost then
                    
                    -- local msg = "此次重置需要重置令" .. cost .. "个，是否确定重置？" ;
                    -- msg = msg .. "\n\n(当前拥有重置令：" .. resetTool.num..",今日还可以重置" .. maxResetTime - useResetTime .. "次)";
                    local msg = stringUtils.format(localizable.youli_text12, cost,resetTool.num,(maxResetTime - useResetTime))
                    
                    CommonManager:showOperateSureLayer(
                            function()
                                 MissionManager:resetChallengeCount( missionId );
                            end,
                            nil,
                            {
                                msg = msg
                            }
                    )
                    return
                end

            end
        
            -- local msg = "是否花费" .. need .. "元宝重置此关卡挑战次数？" ;
            -- msg = msg .. "\n\n(今日还可以重置" .. maxResetTime - useResetTime .. "次)";
            local msg = stringUtils.format(localizable.youli_text13, need,(maxResetTime - useResetTime))
            CommonManager:showOperateSureLayer(
                    function()
                         if MainPlayer:isEnoughSycee( need , true) then
                                MissionManager:resetChallengeCount( missionId );
                         end
                    end,
                    nil,
                    {
                    msg = msg
                    }
            )
        end

        return false;
    end

    if sender == self.btn_attack then
        AlertManager:close(AlertManager.TWEEN_NONE);
        AdventureManager:requestEventComplete( mission.id )
    else
        print("----扫荡")
        --具体的扫荡次数
        local challengeTimes = 1;

        if sender == self.btn_quick1 then
            challengeTimes = 1;
        elseif sender == self.btn_quick3 then
            challengeTimes = math.min(mission.max_challenge_count - mission.challengeCount, self.maxChallengeCount)
        end


        --- vip对应的扫荡次数
        local vipQuickData  = VipData:getVipItemByTypeAndVip(2060, MainPlayer:getVipLevel()) 
        local vipQuickTimes = (vipQuickData and vipQuickData.benefit_value) or 0



        local saoDangCardNum = 0
        local sweepConfigure = SweepData:objectByID(1)
        if sweepConfigure then
            local cost = sweepConfigure.token_num or 1

            local sweepID = sweepConfigure.token_id
            -- 判断扫荡道具 30035
            local tool = BagManager:getItemById(sweepID)
            if tool and tool.num > 0 then
                saoDangCardNum = tool.num
            end

            saoDangCardNum = math.floor(saoDangCardNum/cost)
        end
        
        local totalFreeTimes = vipQuickTimes + saoDangCardNum - MissionManager.useQuickPassTimes

        print("vip扫荡次数----", vipQuickTimes)
        print("拥有扫荡卡----",  saoDangCardNum)
        print("扫荡用掉的次数----",  MissionManager.useQuickPassTimes)
        print("总的次数 ----",  totalFreeTimes)

        -- 需要花钱的次数
        local needCostTimes = challengeTimes - totalFreeTimes
        -- if needCostTimes < 0 then
            
        -- end

        if needCostTimes <= 0 then
            needCostTimes = 0
            if sender == self.btn_quick3 then
                --扫荡N次
                -- AlertManager:close(AlertManager.TWEEN_NONE);
                MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            elseif sender == self.btn_quick1 then
                --扫荡1次
                -- AlertManager:close(AlertManager.TWEEN_NONE);
                MissionManager:singleQuickPassMission(missionId);
            end
        else

            
            local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
            
            if challengeTimes == 1 then
                if MainPlayer:isEnoughSycee( freeQuickprice , true) then
                    if sender == self.btn_quick3 then
                        --扫荡N次
                         -- AlertManager:close(AlertManager.TWEEN_NONE);
                        MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
                    elseif sender == self.btn_quick1 then
                        --扫荡1次
                        -- AlertManager:close(AlertManager.TWEEN_NONE);
                        MissionManager:singleQuickPassMission(missionId);
                    end
                end
                return
            end

            local costNum =  freeQuickprice * needCostTimes
            -- print("self.txt_qucikneed.cost = ", self.txt_qucikneed.cost)
            -- print("needCostTimes = ", needCostTimes)
            -- local msg = "剩余免费次数和扫荡令总和不足,是否花费" .. costNum .. "元宝进行扫荡？" ;
            local msg = stringUtils.format(localizable.youli_text14,costNum)

            if not self.quick_need_money_tip then
                CommonManager:showOperateSureTipLayer(
                        function(data, widget)
                            if MainPlayer:isEnoughSycee( costNum , true) then
                                if sender == self.btn_quick3 then
                                    --扫荡N次
                                    -- AlertManager:close(AlertManager.TWEEN_NONE);
                                    MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
                                elseif sender == self.btn_quick1 then
                                    --扫荡1次
                                    -- AlertManager:close(AlertManager.TWEEN_NONE);
                                    MissionManager:singleQuickPassMission(missionId);
                                end
                                self:getHasTip(widget)
                            end
                        end,
                        function(data, widget)
                            AlertManager:close()
                            self:getHasTip(widget)
                        end,
                        {
                            msg = msg
                        }
                )
            else
                if MainPlayer:isEnoughSycee( costNum , true) then
                    if sender == self.btn_quick3 then
                        --扫荡N次
                        -- AlertManager:close(AlertManager.TWEEN_NONE);
                        MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
                    elseif sender == self.btn_quick1 then
                        --扫荡1次
                        -- AlertManager:close(AlertManager.TWEEN_NONE);
                        MissionManager:singleQuickPassMission(missionId);
                    end
                end
            end
        end
    end
end

function AdventureMissionDetailLayer:getHasTip( widget )
    local state = widget:getSelectedState();
    if state == true then
        self.quick_need_money_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("youli_quick_need_money_tip", self.quick_need_money_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end
function AdventureMissionDetailLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    if self.selectTeamIndex == 1 then
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_1, false)
    else
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_2, false)
    end
end
function AdventureMissionDetailLayer.onMercenaryClickHandle(sender)
    local self = sender.logic;
    local missionId = self.missionId;
    EmployManager:openRoleList(function ()
        AlertManager:close()
        AlertManager:close()
        MissionManager:attackMission(missionId,EnumFightStrategyType.StrategyType_HIRE_TEAM);
    end)
end

--注册事件
function AdventureMissionDetailLayer:registerEvents()
    self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);

    -- local ui_panel            = TFDirector:getChildByPath(ui, 'Panel')
    self.ui:setTouchEnabled(true)
    -- ADD_ALERT_CLOSE_LISTENER(self,self.ui);

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_close.logic = self
    self.ui.logic = self
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1);
    self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1);

    self.btn_attack.logic = self;
    self.btn_attack:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);

    self.btn_reset.logic = self;
    self.btn_reset:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);

    self.btn_quick1.logic = self;
    self.btn_quick1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);

    self.btn_quick3.logic = self;
    self.btn_quick3:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAttackClickHandle),1);
   

    for i=1,2 do
        self.btn_team[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnTeamClick),1);
        self.btn_team[i].logic = self
        self.btn_team[i].idx = i
    end

   self.btn_army.logic = self;
   self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

   self.btn_yongbing.logic = self;
   self.btn_yongbing:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onMercenaryClickHandle),1);

    self.updateChallengeCountCallBack = function(event)
        self:refreshUI();
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.CoinChange ,self.updateChallengeCountCallBack ) ;
    TFDirector:addMEGlobalListener(MissionManager.RESET_CHALLENGE_COUNT_RESULT ,self.updateChallengeCountCallBack ) ;
    
end

function AdventureMissionDetailLayer:removeEvents()
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateChallengeCountCallBack);
    TFDirector:removeMEGlobalListener(MissionManager.RESET_CHALLENGE_COUNT_RESULT ,self.updateChallengeCountCallBack ) ;
    self.firstShow = true
end

function AdventureMissionDetailLayer:drawReward()

    local mission = AdventureMissionManager:getMissionById(self.missionId)
    local panelCount = 1
    self.panel_reward[2]:setVisible(false)
    self.bg_xxxx2:setVisible(false)
    if mission.type == 4 then
        self.bg_xxxx:setText(localizable.youli_reward_tips2)
        local txtTips = TFDirector:getChildByPath(self.bg_xxxx2, "txt_xxxxx")
        txtTips:setText(localizable.youli_reward_tips3)
        panelCount = 2
        self.bg_xxxx2:setVisible(true)
        self.panel_reward[2]:setVisible(true)
    else
        self.bg_xxxx:setText(localizable.youli_reward_tips1)
    end
    self.rewardList = {}
    self.tableView = self.tableView or {}
    for k=1,panelCount do
        local rewardList
        if k==1 then
            rewardList = DropGroupData:GetDropItemListByIdsStr(mission.goods_drop)
            if mission.experience and mission.experience > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.YUELI,number = mission.experience}))
            end
            if mission.coin and mission.coin > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.coin}))
            end
        else
            rewardList = DropGroupData:GetDropItemListByIdsStr(mission.second_goods_drop)
            if mission.second_experience and mission.second_experience > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.YUELI,number = mission.second_experience}))
            end
            if mission.second_coin and mission.second_coin > 0 then
                rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.second_coin}))
            end
        end
        
        self.rewardList[k] = rewardList

        if self.tableView[k] == nil then
            local  tableView =  TFTableView:create()
            tableView:setTableViewSize(self.panel_reward[k]:getContentSize())
            tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
            tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
            tableView:setPosition(ccp(0,0))
            self.tableView[k] = tableView
            self.tableView[k].logic = self
            self.tableView[k].index = k

            self.panel_reward[k]:addChild(self.tableView[k],1)

            tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
            tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
            tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
            tableView:reloadData()
        else
            self.tableView[k]:reloadData()
            -- self.tableView[k]:setScrollToBegin(false)
        end
    end
end

function AdventureMissionDetailLayer.cellSizeForTable(table, idx)
    return 90, 82
end

function AdventureMissionDetailLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        
        local node = Public:createIconNumNode(reward)
        node:setScale(0.65)

        node:setPosition(ccp(0, 0))
        cell:addChild(node)
        cell.node = node
    end
    self:drawCell(cell, idx + 1, table.index)
    return cell
end

function AdventureMissionDetailLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local index = table.index
    local totalNum = self.rewardList[index]:length()
    return totalNum
end

function AdventureMissionDetailLayer:drawCell(cell, cellIndex, tableIndex)
    local node  = cell.node
    node.index = cellIndex
    node:setVisible(true)
    self:drawRewardNode(node, tableIndex)
end

function AdventureMissionDetailLayer:drawRewardNode(node,tableIndex)

    local index = node.index
    local totalNum = self.rewardList[1]:length()
    local rewardItem = self.rewardList[tableIndex]:getObjectAt(index)

    -- print('self.rewardList = ',self.rewardList)
    -- print('rewardItem = ',rewardItem)
    -- print('index = ',index)
    -- print('totalNum = ',totalNum)
    Public:loadIconNode(node,rewardItem)

    CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
end

function AdventureMissionDetailLayer.onBtnTeamClick( btn )
    local self = btn.logic
    local idx = btn.idx
    if idx == self.selectTeamIndex or self.ismoveEnd then
        return
    end
    self:qieHuanAction()
end


--切换动作
function AdventureMissionDetailLayer:qieHuanAction()
    if self.ismoveEnd then
        return
    end
    self.ismoveEnd = true
    local move1 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[2].x-50,self.panelBuzhenPos[2].y))
    local move2 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[1].x+50,self.panelBuzhenPos[1].y))
    local move3 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[2].x,self.panelBuzhenPos[2].y))
    local move4 = CCMoveTo:create(0.2,ccp(self.panelBuzhenPos[1].x,self.panelBuzhenPos[1].y))
 
    local function changeOrder()
        self.panel_buzhen[1]:setZOrder(1)
        self.panel_buzhen[2]:setZOrder(2)
    end
    local function changeOrder2()
        self.panel_buzhen[1]:setZOrder(2)
        self.panel_buzhen[2]:setZOrder(1)
    end
    local function moveEnd()
        self.ismoveEnd = false
        for i=1,2 do
            if i == self.selectTeamIndex then
                self.btn_team[i]:setTextureNormal(self.btn_team[i].selectTexture)
            else
                self.btn_team[i]:setTextureNormal(self.btn_team[i].normalTexture)
            end
        end
    end
    if self.selectTeamIndex == 1 then
        self.selectTeamIndex = 2

        local act1 = CCSequence:createWithTwoActions(move1,move4)
        self.panel_buzhen[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move2,CCCallFunc:create(changeOrder))
        local act3 = CCSequence:createWithTwoActions(act2,move3)
        self.panel_buzhen[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    else
        self.selectTeamIndex = 1

        local act1 = CCSequence:createWithTwoActions(move2,move3)
        self.panel_buzhen[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move1,CCCallFunc:create(changeOrder2))
        local act3 = CCSequence:createWithTwoActions(act2,move4)
        self.panel_buzhen[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))
    end  
end


function AdventureMissionDetailLayer:dispose()

    self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end
return AdventureMissionDetailLayer;
