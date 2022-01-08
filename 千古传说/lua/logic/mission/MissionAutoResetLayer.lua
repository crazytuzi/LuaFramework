--[[
******自动重置挑战次数和体力确认框-关卡详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local MissionAutoResetLayer = class("MissionAutoResetLayer", BaseLayer);

CREATE_SCENE_FUN(MissionAutoResetLayer);
CREATE_PANEL_FUN(MissionAutoResetLayer);

MissionAutoResetLayer.LIST_ITEM_WIDTH = 200; 

function MissionAutoResetLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.mission.MissionAutoResetLayer");
end

function MissionAutoResetLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close               = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_quick               = TFDirector:getChildByPath(ui, 'btn_quick')

    self.btn_selectAuto               = TFDirector:getChildByPath(ui, 'btn_selectAuto')
    self.btn_selectTili               = TFDirector:getChildByPath(ui, 'btn_selectTili')
    self.btn_selectTimes              = TFDirector:getChildByPath(ui, 'btn_selectTimes')

    self.txt_autoResetTili               = TFDirector:getChildByPath(ui, 'txt_autoResetTili')
    self.txt_autoResetTimes              = TFDirector:getChildByPath(ui, 'txt_autoResetTimes')

    self.panel_auto              = TFDirector:getChildByPath(ui, 'img_auto_bg')
    self.txt_cost                = TFDirector:getChildByPath(ui, 'txt_cost')
    self.txt_times                = TFDirector:getChildByPath(ui, 'txt_times')

    self.img_cost                = TFDirector:getChildByPath(ui, 'img_cost')
    self.txt_cannotattack        = TFDirector:getChildByPath(ui, 'txt_cannotattack')

    self.img_selectAtuo          = TFDirector:getChildByPath(ui, 'img_selectAtuo');
    self.img_selectTili          = TFDirector:getChildByPath(ui, 'img_selectTili');
    self.img_selectTimes         = TFDirector:getChildByPath(ui, 'img_selectTimes');

    self:loadCache();

end

function MissionAutoResetLayer:loadCache()
    local selectAtuo  = CCUserDefault:sharedUserDefault():getBoolForKey("mission.quickpass.selectAtuo") or false;
    local selectTili  = CCUserDefault:sharedUserDefault():getBoolForKey("mission.quickpass.selectTili") or false;
    local selectTimes = CCUserDefault:sharedUserDefault():getBoolForKey("mission.quickpass.selectTimes") or false;

    self.img_selectAtuo:setVisible(selectAtuo)  
    self.panel_auto:setVisible(not selectAtuo)  

    self.img_selectTili:setVisible(selectTili)  
    self.img_selectTimes:setVisible(selectTimes)  


end

function MissionAutoResetLayer:refreshCost()
    local mission = MissionManager:getMissionById(self.missionId);
    print("===========================================================================")
    -- local useResetTime = MissionManager.useResetTimes;
    local useResetTime = mission.resetCount
    local vipItem = VipData:getVipItemByTypeAndVip(2000,MainPlayer:getVipLevel());
    local maxResetTime = (vipItem and vipItem.benefit_value) or 0;
    local leftChallengeCount = mission.maxChallengeCount - mission.challengeCount
    local leftResetTime = maxResetTime - useResetTime
    
    local maxChallengeTimes = leftChallengeCount + mission.maxChallengeCount * (leftResetTime);
    print("maxResetTime,maxChallengeTimes:",leftResetTime,maxChallengeTimes)

    local timesInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP);
    local resConfig = PlayerResConfigure:objectByID(EnumRecoverableResType.PUSH_MAP)
    local leftTili = timesInfo:getLeftChallengeTimes()
    local leftResetTili = resConfig:getMaxBuyTime(MainPlayer:getVipLevel()) - timesInfo.todayBuyTime
    
    local maxTili = leftTili + timesInfo.maxValue * (leftResetTili);
    print("todayBuyTime,maxTili:",leftResetTili,maxTili)

    if self.img_selectAtuo:isVisible()  then
        --选择了自动重置次数
       if self.img_selectTimes:isVisible()  then
            if self.img_selectTili:isVisible()  then
                local tempMaxChallengeTimes = math.floor(maxTili/mission.consume);
                maxChallengeTimes = math.min(maxChallengeTimes,tempMaxChallengeTimes);
            else
                local tempMaxChallengeTimes = math.floor(leftTili/mission.consume);
                maxChallengeTimes = math.min(maxChallengeTimes,tempMaxChallengeTimes);
            end
        else
            if self.img_selectTili:isVisible()  then
                local tempMaxChallengeTimes = math.floor(maxTili/mission.consume);
                maxChallengeTimes = math.min(leftChallengeCount,tempMaxChallengeTimes);
            else
                local tempMaxChallengeTimes = math.floor(leftTili/mission.consume);
                maxChallengeTimes = math.min(leftChallengeCount,tempMaxChallengeTimes);
            end
        end
    else
        local tempMaxChallengeTimes = math.floor(leftTili/mission.consume);
        maxChallengeTimes = math.min(leftChallengeCount,tempMaxChallengeTimes);
        if mission.difficulty < MissionManager.DIFFICULTY1 then
            maxChallengeTimes = math.min(maxChallengeTimes,9);
        else
            maxChallengeTimes = math.min(maxChallengeTimes,3);
        end
    end


    --扫荡花钱
    local freeQuickTimes = ConstantData:getValue("Mission.FreeQuick.Times");
    local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
    local resetTimesPrice = ConstantData:getValue("Mission.Reset.Times.price");
    local resetTiliPrice = ConstantData:getValue("Challenge.Time.Chapter.price");


    local cost = 0;
    if MissionManager.useQuickPassTimes >= freeQuickTimes then
        cost = cost + maxChallengeTimes * freeQuickprice;
    else
        cost = cost + math.max(0, (maxChallengeTimes - (freeQuickTimes - MissionManager.useQuickPassTimes)) * freeQuickprice);
    end
    print("maxChallengeTimes:",maxChallengeTimes)
    print("maxChallengeTimes *mission.consume:",maxChallengeTimes *mission.consume)
    print("freeQuick:",cost)

  
    local needResetTimesNum = math.ceil((maxChallengeTimes - leftChallengeCount)/mission.maxChallengeCount);
    function getResetTimesCost( num,price )
        if num <= 0 then
            return 0;
        end
        return (useResetTime + num ) * price + getResetTimesCost( num -1 ,price )
    end
    cost = cost + getResetTimesCost( needResetTimesNum , resetTimesPrice);
    print("needResetTimesNum:",needResetTimesNum,cost)


    local needResetTiliNum =  math.ceil((maxChallengeTimes * mission.consume - leftTili)/timesInfo.maxValue);
    function getResetTiliCost( num,price )
        if num <= 0 then
            return 0;
        end
        return (timesInfo.todayBuyTime + num ) * price + getResetTiliCost( num -1 ,price )
    end
    cost = cost + getResetTiliCost(needResetTiliNum , resetTiliPrice);
    print("needResetTiliNum:",needResetTiliNum,cost)


    --self.txt_cost:setText("(预计花费：" .. cost)
    self.txt_cost:setText(stringUtils.format(localizable.missionAuto_cost,cost))
    --self.txt_times:setText("挑战".. maxChallengeTimes .. "次)") 
    self.txt_times:setText(stringUtils.format(localizable.missionAuto_times,maxChallengeTimes)) 
    self.txt_cost.cost =  txt_cost;
    self.txt_times.maxChallengeTimes = maxChallengeTimes;
    -- if MainPlayer:isEnoughSycee( cost , false) then
    --     self:txt_cost:setColor(ccc3(255, 255, 255));
    -- else
    --     self:txt_cost:setColor(ccc3(255,   0,   0));
    -- end

    --self.txt_autoResetTili:setText("（剩余可购买" .. leftResetTili .. "次）")
    self.txt_autoResetTili:setText(stringUtils.format(localizable.common_buy_times,leftResetTili))
    self.txt_autoResetTili.leftResetTili = leftResetTili;

    --self.txt_autoResetTimes:setText("（剩余可重置" .. leftResetTime .. "次）")
    self.txt_autoResetTimes:setText(stringUtils.format(localizable.common_reset_times, leftResetTime ))
    self.txt_autoResetTimes.leftResetTime = leftResetTime

end

function MissionAutoResetLayer:loadData(missionId)
    self.missionId = missionId;
end

function MissionAutoResetLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
    self:refreshBaseUI();
end

function MissionAutoResetLayer:refreshBaseUI()

end

function MissionAutoResetLayer:refreshUI()
    if not self.isShow then
        return;
    end

    self:refreshCost();
end

function MissionAutoResetLayer.onSelectAtuoClickHandle(sender)
    local self = sender.logic;

    self.img_selectAtuo:setVisible(not self.img_selectAtuo:isVisible())  
    self.panel_auto:setVisible(not self.panel_auto:isVisible())  
    self:refreshCost();

    CCUserDefault:sharedUserDefault():setBoolForKey("mission.quickpass.selectAtuo",self.img_selectAtuo:isVisible());
    CCUserDefault:sharedUserDefault():flush();
end

function MissionAutoResetLayer.onSelectTiliClickHandle(sender)
    local self = sender.logic;
    self.img_selectTili:setVisible(not self.img_selectTili:isVisible())  
    self:refreshCost();

    CCUserDefault:sharedUserDefault():setBoolForKey("mission.quickpass.selectTili",self.img_selectTili:isVisible());
    CCUserDefault:sharedUserDefault():flush();
end

function MissionAutoResetLayer.onSelectTimesClickHandle(sender)
    local self = sender.logic;
    self.img_selectTimes:setVisible(not self.img_selectTimes:isVisible())
    self:refreshCost();

    CCUserDefault:sharedUserDefault():setBoolForKey("mission.quickpass.selectTimes",self.img_selectTimes:isVisible());
    CCUserDefault:sharedUserDefault():flush();
end

--   local status = MissionManager:getMissionPassStatus(missionId);
function MissionAutoResetLayer.onQuickClickHandle(sender)
    local self = sender.logic;
    
    local missionId = self.missionId;
    local mission = MissionManager:getMissionById(missionId);

    local selectAtuo  = self.img_selectAtuo:isVisible();
    local selectTili  = self.img_selectTili:isVisible();
    local selectTimes = self.img_selectTimes:isVisible();

    if (selectTimes and (self.txt_times.maxChallengeTimes or 0) < 1)  then
        --toastMessage("大侠，明天再来吧，")
        toastMessage(localizable.missionAuto_tomorrow)
        return;
    end

    --判断剩余挑战次数
    if mission.challengeCount >= mission.maxChallengeCount then
        
        if (selectTimes and (self.txt_autoResetTimes.leftResetTime or 0) < 1) or not selectTimes then

            local vipItem = VipData:getVipItemByTypeAndVip(2000,MainPlayer:getVipLevel());
            local maxResetTime = (vipItem and vipItem.benefit_value) or 0;

            local openVip = ConstantData:getValue("Mission.Reset.Times.NeedVIP");

            if MainPlayer:getVipLevel() < openVip then
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        --title = "VIP不足",
                        --msg = "VIP" .. openVip .. "可重置挑战次数",
                        title = localizable.missionAuto_vip,
                        msg = stringUtils.format(localizable.missionAuto_vip_reset,openVip),
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )

                return false;
            end

            -- local useResetTime = MissionManager.useResetTimes;
            local useResetTime = mission.resetCount
            local need = (useResetTime + 1) * ConstantData:getValue("Mission.Reset.Times.price"); 
            --local msg = "是否花费" .. need .. "重置此关卡挑战次数？" ;
            local msg = stringUtils.format(localizable.missionAuto_reset,need) ;

            if maxResetTime - useResetTime < 1 then
                --msg = msg .. "\n\n(今日重置次数已用完)";
                msg = msg .. localizable.missionAuto_reset_over;
            else
                --msg = msg .. "\n\n(今日还可以重置" .. maxResetTime - useResetTime .. "次)";
                msg = msg .. stringUtils.format(localizable.missionAuto_reset_times, maxResetTime - useResetTime )
            end

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

            return false;
        end
    end

    --判断体力
    if not MainPlayer:isEnoughTimes( EnumRecoverableResType.PUSH_MAP , mission.consume, false )  then
        if (selectTili and (self.txt_autoResetTili.leftResetTili or 0) < 1) or not selectTili then
            MainPlayer:isEnoughTimes( EnumRecoverableResType.PUSH_MAP , mission.consume, true ) 
            return false;
        end
    end

    --判断消耗的元宝
    if MainPlayer:isEnoughSycee((self.txt_cost.cost or 0) , true) then
        AlertManager:close();
        AlertManager:close();

        MissionManager:manyQuickPassMission(missionId,selectAtuo and selectTili,selectAtuo and selectTimes);
    end

end


--注册事件
function MissionAutoResetLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);
    
   self.btn_quick.logic = self;
   self.btn_quick:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQuickClickHandle),1);

  self.btn_selectAuto.logic = self;
   self.btn_selectAuto:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectAtuoClickHandle),1);

  self.btn_selectTili.logic = self;
   self.btn_selectTili:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectTiliClickHandle),1);

  self.btn_selectTimes.logic = self;
   self.btn_selectTimes:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSelectTimesClickHandle),1);

    self.updateChallengeTimesCallBack = function(event)
        self:refreshUI();
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack ) ;

end

function MissionAutoResetLayer:removeEvents()
    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack);
end

return MissionAutoResetLayer;
