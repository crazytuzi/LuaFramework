--[[
******PVE推图-关卡详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local MissionDetailLayer = class("MissionDetailLayer", BaseLayer);

CREATE_SCENE_FUN(MissionDetailLayer);
CREATE_PANEL_FUN(MissionDetailLayer);

MissionDetailLayer.LIST_ITEM_WIDTH = 200; 
local ResetData  = require('lua.table.t_s_reset_consume')
local SweepData  = require('lua.table.t_s_sweep')

function MissionDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.mission.MissionDetail");
    self.firstShow = true
end

function MissionDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close          = TFDirector:getChildByPath(ui, 'Btn_close')

    self.txt_title1          = TFDirector:getChildByPath(ui, 'txt_title1')
    self.txt_title2          = TFDirector:getChildByPath(ui, 'txt_title2')

    self.txt_storydetail          = TFDirector:getChildByPath(ui, 'txt_storydetail')
    self.txt_copperpoint          = TFDirector:getChildByPath(ui, 'txt_copperpoint')
    self.txt_sycee            = TFDirector:getChildByPath(ui, 'txt_gold_num')

    self.txt_exppoint         = TFDirector:getChildByPath(ui, 'txt_exppoint')
    self.txt_keypoint         = TFDirector:getChildByPath(ui, 'txt_keypoint')

    self.btn_attack           = TFDirector:getChildByPath(ui, 'panel_fight')
    self.btn_army             = TFDirector:getChildByPath(ui, 'btn_army')
    self.btn_reset            = TFDirector:getChildByPath(ui, 'btn_reset')

    self.txt_point            = TFDirector:getChildByPath(ui, 'txt_number')

    self.img_reward           = TFDirector:getChildByPath(ui, 'img_reward')

    self.img_dropiconArr = {}
    for i=1,3 do
        self.img_dropiconArr[i]         = TFDirector:getChildByPath(ui, 'img_dropicon' .. i)
    end


    self.btn_quick1            = TFDirector:getChildByPath(ui, 'btn_quick1')
    self.btn_quick3               = TFDirector:getChildByPath(ui, 'btn_quick3')
    self.txt_quick_time           = TFDirector:getChildByPath(ui, 'LabelBMFont_MissionDetail_1')
    self.txt_freequick            = TFDirector:getChildByPath(ui, 'txt_freequick')
    self.img_qucikneed            = TFDirector:getChildByPath(ui, 'img_qucikneed')
    self.txt_qucikneed            = TFDirector:getChildByPath(ui, 'txt_qucikneed')
    -- self.bg_reward                = TFDirector:getChildByPath(ui, 'img_bg2')
    self.panel_reward             = TFDirector:getChildByPath(ui, 'panel_reward')
    self.btn_yongbing             = TFDirector:getChildByPath(ui, 'btn_yongbing')

    self.button = {};
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button[i] = TFDirector:getChildByPath(ui, btnName);

        btnName = "btn_icon"..i;
        self.button[i].bg = TFDirector:getChildByPath(ui, btnName);
        self.button[i].bg:setVisible(false);

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        self.button[i].icon:setVisible(false);

        self.button[i].img_zhiye = TFDirector:getChildByPath(self.button[i], "img_zhiye");
        self.button[i].img_zhiye:setVisible(false);

        self.button[i].quality = TFDirector:getChildByPath(ui, btnName);
    end

    --推荐战力
    self.txt_zhanli            = TFDirector:getChildByPath(ui,'txt_zhanli')
    self.quick_need_money_tip = CCUserDefault:sharedUserDefault():getBoolForKey("quick_need_money_tip");
    -- if self.quick_need_money_tip == nil then
    --     self.quick_need_money_tip = true
    -- end

    self:addFightBtnEffect()
end

function MissionDetailLayer:addFightBtnEffect()
    local effectID = "tiaozhaneft"
    ModelManager:addResourceFromFile(2, effectID, 1)
    local effect = ModelManager:createResource(2, effectID)
    effect:setPosition(ccp(self.btn_attack:getSize().width / 2, self.btn_attack:getSize().height / 2))
    self.btn_attack:addChild(effect)
    ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
end

function MissionDetailLayer:loadData(missionId)
    self.missionId = missionId;
end

function MissionDetailLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
    self:refreshBaseUI();
    if self.firstShow == true then
        self.ui:runAnimation("Action0",1);
        self.firstShow = false
    end
end

function MissionDetailLayer:refreshBaseUI()

end

function MissionDetailLayer:refreshUI()

    if not self.isShow then
        return;
    end

    local mission = MissionManager:getMissionById(self.missionId);

    local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
    local curMissionlist = missionlist[mission.difficulty];
    local index = curMissionlist:indexOf(mission);
    local map = MissionManager:getMapById(mission.mapid)
    -- self.txt_title:setText( map.name .. " " .. mission.stagename .." (" .. MissionManager.DIFFICULTY_STR[mission.difficulty] .. ")") ;

    self.txt_title1:setText(map.name)
    self.txt_title2:setText(mission.stagename .." " .. MissionManager.DIFFICULTY_STR[mission.difficulty])

    self.txt_storydetail:setText(mission.description) ;
    -- self.txt_copperpoint:setText(mission.money) ;
    -- self.txt_exppoint:setText(mission.exp) ;
    -- self.txt_keypoint:setText("X" .. mission.consume) ;
    
    -- self.bg_reward:removeAllChildren();
    -- local rewardList = MissionManager:getDropItemListByMissionId(self.missionId);
    -- rewardList:insertAt(1, BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.money}));

    -- local index = 1;
    -- for reward in rewardList:iterator() do
    --     if index > 3 then
    --         break;
    --     end
    --     local rewardNode = Public:createIconNumNode(reward)
    --     rewardNode:setScale(0.7);
    --     rewardNode:setPosition(-160 + (index - 1) * 85,-50)

    --     self.bg_reward:addChild(rewardNode);
    --     index = index + 1;
    -- end

    self:drawReward()
    -- if drop then
    --     self.img_dropicon:setVisible(true);
    --     local img_icon   = TFDirector:getChildByPath( self.img_dropicon, 'img_reward');  
    --     -- local txt_name   = TFDirector:getChildByPath( self.img_dropicon, 'txt_name');  
    --     img_icon:setTexture(drop.path);
    --     -- txt_name:setText(drop.name);
    -- else
    --     self.img_dropicon:setVisible(false);
    -- end

    local npcSetting = mission.npc
    if mission.starLevel < 1 then
        if mission.npc_first and mission.npc_first ~= '' and mission.npc_first ~= 'NULL'then
            npcSetting = mission.npc_first
        end
    else
        
    end
    local npcs = NPCData:GetNPCListByIds(npcSetting)

    for index=1,9 do
        local role = npcs[index];
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
            -- self.button[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));
        else
            self.button[index].img_zhiye:setVisible(false);  

            self.button[index].icon:setVisible(false);
            self.button[index].bg:setVisible(false);     
        end
    end

    self.btn_attack:setVisible(false)
    self.btn_reset:setVisible(false)

    if mission.challengeCount >= mission.maxChallengeCount then
        self.btn_reset:setVisible(true);
    else
        self.btn_attack:setVisible(true);
    end
    self.txt_point:setText(mission.maxChallengeCount - mission.challengeCount .. "/" .. mission.maxChallengeCount)
    self:refreshQuickPass();

    --推荐战力
    local recommendPower = 0
    if mission.recommend_power then
        recommendPower = mission.recommend_power
    end
    self.txt_zhanli:setText(recommendPower)
end

function MissionDetailLayer:refreshQuickPass()
    local mission = MissionManager:getMissionById(self.missionId);

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

    if mission.difficulty == MissionManager.DIFFICULTY0  then
        if mission.type == MissionManager.TYPE_COMMON then
            self.maxChallengeCount = 9
        else
            self.maxChallengeCount = 5
        end
    elseif mission.difficulty == MissionManager.DIFFICULTY1  then
        if mission.type == MissionManager.TYPE_COMMON then
            self.maxChallengeCount = 9
        else
            self.maxChallengeCount = 3
        end
    end
    local leftChallengeTimes = mission.maxChallengeCount - mission.challengeCount;
    self.txt_quick_time:setText(math.min(self.maxChallengeCount , leftChallengeTimes))


    local freeQuickTimes = ConstantData:getValue("Mission.FreeQuick.Times");

    local vipItem = VipData:getVipItemByTypeAndVip(2060, MainPlayer:getVipLevel()) --- vip对应的扫荡次数

    local vipQuickTimes = (vipItem and vipItem.benefit_value) or 0


    -- local ChapterSweepTimes = MainPlayer:getChapterSweepTimes() -- 今天用掉的次数

    freeQuickTimes = 0 + vipQuickTimes -- ChapterSweepTimes

    -- print("vipQuickTimes = ", vipQuickTimes)
    -- print("ChapterSweepTimes = ", ChapterSweepTimes)
    -- print("freeQuickTimes = ", freeQuickTimes)
    -- print("MissionManager.useQuickPassTimes = ", MissionManager.useQuickPassTimes)

    if MissionManager.useQuickPassTimes >= freeQuickTimes then

        -- 判断扫荡道具
        local tool = BagManager:getItemById(30035)
        if tool and tool.num > 0 then
            self.txt_freequick:setVisible(true)
            --self.txt_freequick:setText("扫荡令：" .. tool.num)
            self.txt_freequick:setText(stringUtils.format(localizable.carbonDetailLayer_sweep_pro, tool.num))
            
            return
        end


        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
        self.img_qucikneed:setVisible(true);
        --self.txt_qucikneed:setText("每次扫荡消耗" .. freeQuickprice)
        self.txt_qucikneed:setText(stringUtils.format(localizable.missionDetail_xiaohao, freeQuickprice))
        self.txt_qucikneed.cost = freeQuickprice;
    else
        self.txt_freequick:setVisible(true);
        --self.txt_freequick:setText("今日免费：" .. (freeQuickTimes - MissionManager.useQuickPassTimes));
        self.txt_freequick:setText(stringUtils.format(localizable.missionDetail_today_free, freeQuickTimes - MissionManager.useQuickPassTimes ))
        self.txt_qucikneed.cost = 0;
    end

end

function MissionDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;

    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)

    -- CardRoleManager:openRoleSimpleInfo(role);
end

function MissionDetailLayer.onCloseClickHandle(sender)
    local self = sender.logic;
    self.ui:setAnimationCallBack("Action1", TFANIMATION_END, function()
        AlertManager:close()
    end)

    self.ui:runAnimation("Action1",1)
end

--   local status = MissionManager:getMissionPassStatus(missionId);
function MissionDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;
    
    local missionId = self.missionId;
    local mission = MissionManager:getMissionById(missionId);


    local leftChallengeTimes = mission.maxChallengeCount - mission.challengeCount;
    local openVip = ConstantData:getValue("Mission.ManyQuick.NeedVIP");

     MissionManager.attackDes = nil;
    if sender == self.btn_attack then

    elseif sender == self.btn_quick1 then
    elseif sender == self.btn_quick3 then

        if MainPlayer:getVipLevel() < openVip then
            -- local msg =  "VIP" .. openVip .. "开启一键扫荡多次功能。";
            local msg =  stringUtils.format(localizable.missionDetail_sweep,openVip);
            CommonManager:showOperateSureLayer(
                    function()
                        PayManager:showPayLayer();
                    end,
                    nil,
                    {
                    --title = "提升VIP",
                    title = localizable.bloodBattleMainLayer_up_vip,
                    msg = msg,
                    uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                    }
            )
            return;
        end
        if leftChallengeTimes >= self.maxChallengeCount then
            leftChallengeTimes = self.maxChallengeCount
        end
        -- if leftChallengeTimes < 3 then
        --     MissionManager.attackDes = "挑战次数不足，无法继续扫荡"
        -- --判断体力
        -- else
        if not MainPlayer:isEnoughTimes( EnumRecoverableResType.PUSH_MAP , mission.consume * leftChallengeTimes, false )  then
            -- MissionManager.attackDes = "体力不足，无法继续扫荡"
            -- toastMessage("体力不足，无法继续扫荡");
            VipRuleManager:showReplyLayer(EnumRecoverableResType.PUSH_MAP)
            return
        end
    end

    --判断体力
    if not MainPlayer:isEnoughTimes(EnumRecoverableResType.PUSH_MAP , mission.consume * 1, true )  then
        return;
    end
    
    -- local openResetVip = ConstantData:getValue("Mission.Auto.Reset.NeedVIP");
    -- if sender == self.btn_quick3 or sender == self.btn_quick9 and mission.difficulty > MissionManager.DIFFICULTY1  then
    --     if MainPlayer:getVipLevel() >= openResetVip then
    --         MissionManager:showAutoResetLayer(missionId);
    --         return;
    --     end
    -- end


    --判断剩余挑战次数
    if mission.challengeCount >= mission.maxChallengeCount then
        -- local useResetTime = MissionManager.useResetTimes;
        local useResetTime = mission.resetCount
        
        local vipItem = VipData:getVipItemByTypeAndVip(2020,MainPlayer:getVipLevel());
        local maxResetTime = (vipItem and vipItem.benefit_value) or 0;

        local need = (useResetTime + 1) * ConstantData:getValue("Mission.Reset.Times.price");

        

        if maxResetTime - useResetTime < 1 then
            local nextUpVip = VipData:getVipNextAddValueVip(2020,MainPlayer:getVipLevel())
            if nextUpVip then
                -- local msg = (maxResetTime <= 0 
                --     and "提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。"
                --     or "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。"
                --     );
                local msg = (maxResetTime <= 0 
                    --and "提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    and stringUtils.format(localizable.missionDetail_upvip,nextUpVip.vip_level,nextUpVip.benefit_value)
                   -- or "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    or stringUtils.format(localizable.missionDetail_upvip_over,nextUpVip.vip_level,nextUpVip.benefit_value)
                    );
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = (maxResetTime <= 0 and "提升VIP" or "挑战次数已用完") ,
                        title = (maxResetTime <= 0 and localizable.bloodBattleMainLayer_up_vip or localizable.common_fight_times) ,
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
            else
                --toastMessage("挑战次数已用完，今日重置次数已用完");
                toastMessage(localizable.missionDetail_all_over)
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
                    
                    --local msg = "此次重置需要重置令" .. cost .. "个，是否确定重置？" ;
                    local msg = stringUtils.format(localizable.missionDetail_reset,cost);
                    --msg = msg .. "\n\n(当前拥有重置令：" .. resetTool.num..",今日还可以重置" .. maxResetTime - useResetTime .. "次)";
                    msg = msg ..stringUtils.format(localizable.missionDetail_reset_text,resetTool.num,maxResetTime - useResetTime);
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
        
            --local msg = "是否花费" .. need .. "元宝重置此关卡挑战次数？" ;
            local msg = stringUtils.format(localizable.missionAuto_reset,need) ;
            --msg = msg .. "\n\n(今日还可以重置" .. maxResetTime - useResetTime .. "次)";
            msg = msg .. stringUtils.format(localizable.missionAuto_reset_times,maxResetTime - useResetTime);
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
        MissionManager:attackMission(missionId);
    else
        print("----扫荡")
        --具体的扫荡次数
        local challengeTimes = 1;

        if sender == self.btn_quick1 then
            challengeTimes = 1;
        elseif sender == self.btn_quick3 then
            challengeTimes = math.min(mission.maxChallengeCount - mission.challengeCount, self.maxChallengeCount)
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
            --local msg = "剩余免费次数和扫荡令总和不足,是否花费" .. costNum .. "元宝进行扫荡？" ;
            local msg = stringUtils.format(localizable.missionDetail_sweep_times,costNum) ;

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


            -- --判断消耗的元宝
            -- if MainPlayer:isEnoughSycee( (self.txt_qucikneed.cost or 0) * challengeTimes, true) then
            --     if sender == self.btn_quick3 then
            --         --扫荡N次
            --         -- AlertManager:close(AlertManager.TWEEN_NONE);
            --         MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            --     elseif sender == self.btn_quick1 then
            --         --扫荡1次
            --         -- AlertManager:close(AlertManager.TWEEN_NONE);
            --         MissionManager:singleQuickPassMission(missionId);
            --     end
            -- end

        -- --判断消耗的元宝
        -- if MainPlayer:isEnoughSycee( (self.txt_qucikneed.cost or 0) * challengeTimes, true) then
        --     if sender == self.btn_quick3 then
        --         --扫荡N次
        --         -- AlertManager:close(AlertManager.TWEEN_NONE);
        --         MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
        --     elseif sender == self.btn_quick1 then
        --         --扫荡1次
        --         -- AlertManager:close(AlertManager.TWEEN_NONE);
        --         MissionManager:singleQuickPassMission(missionId);
        --     end
        -- end
    end
end

function MissionDetailLayer:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.quick_need_money_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("quick_need_money_tip", self.quick_need_money_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end
function MissionDetailLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleList(false);
end
function MissionDetailLayer.onMercenaryClickHandle(sender)
    local self = sender.logic;
    local missionId = self.missionId;
    EmployManager:openRoleList(function ()
        AlertManager:close()
        AlertManager:close()
        MissionManager:attackMission(missionId,EnumFightStrategyType.StrategyType_HIRE_TEAM);
    end)
end

--注册事件
function MissionDetailLayer:registerEvents()
    self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);

    -- local ui_panel            = TFDirector:getChildByPath(ui, 'Panel')
    self.ui:setTouchEnabled(true)
    -- ADD_ALERT_CLOSE_LISTENER(self,self.ui);

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

function MissionDetailLayer:removeEvents()
    print("<<<<<<<<<<<<<<<removeEvents<<<<<<<<<<<<<<")
    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateChallengeCountCallBack);
    TFDirector:removeMEGlobalListener(MissionManager.RESET_CHALLENGE_COUNT_RESULT ,self.updateChallengeCountCallBack ) ;
    self.firstShow = true
end

function MissionDetailLayer:drawReward()

    local mission = MissionManager:getMissionById(self.missionId)
    local rewardList = MissionManager:getDropItemListByMissionId(self.missionId)
    rewardList:pushBack(BaseDataManager:getReward({type = EnumDropType.COIN,number = mission.money}))
    self.rewardList = rewardList

    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end


    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_reward:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, MissionDetailLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, MissionDetailLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, MissionDetailLayer.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.panel_reward:addChild(self.tableView,1)
end

function MissionDetailLayer.cellSizeForTable(table, idx)
    return 100, 90
end

function MissionDetailLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        -- local node = Public:createIconNumNode(reward)
        -- node:setScale(0.7);
        -- -- node:setPosition(-160 + (index - 1) * 85,-50)

        -- node:setPosition(ccp(0, 0))
        -- cell:addChild(node)
        -- node:setTag(617)

        -- for i=1,3 do
        --     local node = Public:createIconNumNode(reward)
        --     node:setScale(0.7);
        --     -- node:setPosition(-160 + (index - 1) * 85,-50)

        --     node:setPosition(ccp(100*(i-1), 0))
        --     cell:addChild(node)
        --     node:setTag(600 + i)
        -- end

        local node = Public:createIconNumNode(reward)
        node:setScale(0.65)
        cell:addChild(node)
        cell.node = node
    end

    -- node = cell:getChildByTag(617)
    -- node.index = idx + 1
    -- self:drawRewardNode(node)
    local node = cell.node
    -- self:drawCell(node, idx)
    self:drawRewardNode(node, idx)
    return cell
end

function MissionDetailLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local totalNum = self.rewardList:length()

    -- return math.ceil(totalNum/3)
    return totalNum
end

function MissionDetailLayer:drawCell(node, cellIndex)
    local totalNum = self.rewardList:length()

    for i=1,3 do
        local index = cellIndex * 3 + i
        local node  = cell:getChildByTag(600+i)

        node:setVisible(false)
        if index <= totalNum then
            node.index = index
            node:setVisible(true)
            self:drawRewardNode(node)
        end

    end
end

-- function MissionDetailLayer:drawRewardNode(node)
--     local index = node.index
--     local rewardItem = self.rewardList:getObjectAt(index)
--     Public:loadIconNode(node,rewardItem)

--     CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
-- end

function MissionDetailLayer:drawRewardNode(node, idx)
    -- local index = node.index
    local rewardItem = self.rewardList:getObjectAt(idx + 1)
    Public:loadIconNode(node,rewardItem)

    CommonManager:setRedPoint(node, MartialManager:dropRewardRedPoint(rewardItem), "dropRewardRedPoint", ccp(80,80))
end

-- function MissionDetailLayer:dropRewardRedPoint(rewardItem)
--     -- print("rewardItem = ", rewardItem)
--     if rewardItem.type ~= EnumDropType.GOODS then
--         return false
--     end

--     return CardRoleManager:bookIsCanBeLearn(rewardItem.itemid)
-- end

return MissionDetailLayer;
