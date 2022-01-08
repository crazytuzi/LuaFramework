--[[
******PVE推图-关卡详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local ClimbMountainDetailLayer = class("ClimbMountainDetailLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbMountainDetailLayer);
CREATE_PANEL_FUN(ClimbMountainDetailLayer);

function ClimbMountainDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self.hasLoad = false
    self:init("lua.uiconfig_mango_new.climb.ClimbMountainDetail");
end

function ClimbMountainDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    -- self.btn_close               = TFDirector:getChildByPath(ui, 'btn_close');

    self.txt_title                  = TFDirector:getChildByPath(ui, 'txt_title')

    self.txt_storydetail            = TFDirector:getChildByPath(ui, 'txt_description')

    self.panel_buzhen              = TFDirector:getChildByPath(ui, 'panel_buzhen')
    self.btn_attack_1                 = TFDirector:getChildByPath(self.panel_buzhen, 'btn_attack')
    self.btn_army_1                   = TFDirector:getChildByPath(self.panel_buzhen, 'btn_embattle')


    self.panel_saodang              = TFDirector:getChildByPath(ui, 'panel_saodang')
    self.btn_attack_2                 = TFDirector:getChildByPath(self.panel_saodang, 'btn_attack')
    self.btn_army_2                   = TFDirector:getChildByPath(self.panel_saodang, 'btn_embattle')
    self.btn_sweep                  = TFDirector:getChildByPath(self.panel_saodang, 'btn_sweep')
    self.txt_sweep_num              = TFDirector:getChildByPath(self.panel_saodang, 'txt_sweep_num')


    self.img_xingdi               = TFDirector:getChildByPath(ui, 'img_xingdi')
    self.txt_num               = TFDirector:getChildByPath(ui, 'txt_num')

    self.panel_content              = TFDirector:getChildByPath(ui, 'panel_content')
    self.panel_reward               = TFDirector:getChildByPath(ui, 'panel_reward')
    self.txt_zhanli               = TFDirector:getChildByPath(ui, 'txt_zhanli')
    self.btn_mubiao               = TFDirector:getChildByPath(ui, 'btn_mubiao')
    self.btn_qimen               = TFDirector:getChildByPath(ui, 'btn_qimen')
    self.btn_yongbing               = TFDirector:getChildByPath(ui, 'btn_yongbing')



    self.button = {};
    for i=1,9 do

        self.button[i] = TFDirector:getChildByPath(ui, "img_quality" .. i);
        self.button[i].icon = TFDirector:getChildByPath(self.button[i] ,"img_role" ..i);

        self.button[i].img_zhiye = TFDirector:getChildByPath(self.button[i], "img_zhiye");
        self.button[i].img_zhiye:setVisible(false);

        self.button[i]:setVisible(false);
        self.button[i].icon:setVisible(false);
    end
end

function ClimbMountainDetailLayer:loadData(mountainItem,homeInfo,force)
    if force == nil then
        force = true
    end
    if force == false and self.hasLoad == true then
        return
    end
    self.hasLoad = true
    self.mountainItem   = mountainItem;
    self.homeInfo       = homeInfo;

    self:refreshBaseUI();
    self:refreshUI();
end

function ClimbMountainDetailLayer:onShow()
    self.super.onShow(self)
end

function ClimbMountainDetailLayer:refreshBaseUI()

end

function ClimbMountainDetailLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    local floor = math.min(self.homeInfo.curId , ClimbConfigure:back().id)
    self.txt_num:setText(ClimbManager.climStarNum.."/"..3*floor)
    self.txt_title:setText(self.mountainItem.name) ;
    self.txt_storydetail:setText(self.mountainItem.pass_tips) ;
    self.txt_zhanli:setText(self.mountainItem.power) ;

    self.panel_reward:removeAllChildren();

    local rewardList =  ClimbManager:getRewardItemList(self.mountainItem.id);

    local index = 1;
    for reward in rewardList:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        rewardNode:setScale(0.6)
        rewardNode:setPosition(10 + 75*(index-1), -72)
        -- rewardNode:setPosition(0, -80*index)
        self.panel_reward:addChild(rewardNode)
        index = index + 1;
    end

    if  self.mountainItem.id >= self.homeInfo.curId then
        local firstRewardList =  ClimbManager:getFirstRewardItemList(self.mountainItem.id);

        for reward in firstRewardList:iterator() do
            local rewardNode = Public:createIconNumNode(reward)
            rewardNode:setScale(0.6);
            rewardNode:setPosition(10 + 75*(index-1), -72)
            -- rewardNode:setPosition(0, -80*index)
            self.panel_reward:addChild(rewardNode)
            index = index + 1
        end
    end


    local npcs = NPCData:GetNPCListByIds(self.mountainItem.npc);

    for index=1,9 do
        local role = npcs[index];
        if  role ~= nil then
            self.button[index].icon:setVisible(true);
            self.button[index].icon:setTexture(role:getHeadPath());

            self.button[index]:setVisible(true);
            self.button[index]:setTexture(GetColorRoadIconByQualitySmall(role.quality));
            -- self.button[index]:setTexture(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));
            
            self.button[index].img_zhiye:setVisible(true);
            self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. RoleData:objectByID(role.role_id).outline ..".png");

            self.button[index].role = role;
            self.button[index].logic = self;
            self.button[index]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);
        else
            self.button[index].icon:setVisible(false);
            self.button[index]:setVisible(false);     
        end
    end

    -- self.btn_attack:setVisible(false); 
    -- self.btn_army:setVisible(false);
    self.panel_buzhen:setVisible(false)
    self.panel_saodang:setVisible(false)
    if  self.mountainItem.id < self.homeInfo.curId then
        self.panel_saodang:setVisible(true)
        -- self.btn_attack:setVisible(true);  
        -- self.btn_army:setVisible(false);
        -- self.btn_sweep:setVisible(true)
        local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.CLIMB)
        local challengeTime = tonumber(challengeInfo:getLeftChallengeTimes())
        self.txt_sweep_num:setText(challengeTime)
        if challengeTime > 0 then
            self.btn_sweep:setGrayEnabled(false)
            self.btn_sweep:setTouchEnabled(true)
        else
            self.btn_sweep:setGrayEnabled(true)
            self.btn_sweep:setTouchEnabled(false)
        end
    elseif self.mountainItem.id == self.homeInfo.curId then
        self.panel_buzhen:setVisible(true)
        -- self.btn_attack:setVisible(true);  
        -- self.btn_army:setVisible(true);
        -- self.btn_sweep:setVisible(false)
    elseif self.mountainItem.id > self.homeInfo.curId then
        -- self.btn_sweep:setVisible(false)
    end
end

function ClimbMountainDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;
    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
    -- CardRoleManager:openRoleSimpleInfo(role);
end

function ClimbMountainDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;

    if not MainPlayer:isEnoughTimes(EnumRecoverableResType.CLIMB,1, true) then
        return ;
    end
    
    local mountainItemId = self.mountainItem.id;
    -- AlertManager:close();

    
    ClimbManager:challengeMountain(mountainItemId);
end
function ClimbMountainDetailLayer.onYongbingClickHandle(sender)
    local self = sender.logic;

    if not MainPlayer:isEnoughTimes(EnumRecoverableResType.CLIMB,1, true) then
        return ;
    end

    local mountainItemId = self.mountainItem.id;
    -- AlertManager:close();


    EmployManager:openRoleList(function ()
        AlertManager:close()
        ClimbManager:challengeMountain(mountainItemId,EnumFightStrategyType.StrategyType_HIRE_TEAM);
    end)

end

function ClimbMountainDetailLayer.onMubiaoClickHandle(sender)
    local self = sender.logic;
    local layer = AlertManager:addLayerByFile("lua.logic.climb.ClimbGoalLayer",AlertManager.BLOCK_AND_GRAY);
    layer:loadFloor(self.mountainItem.id)
    AlertManager:show()

end

function ClimbMountainDetailLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleList(false);
end

function ClimbMountainDetailLayer.onSweepButtonClick(sender)
    local self = sender.logic
    ClimbManager:requestSweep(self.mountainItem.id,nil)
end

function ClimbMountainDetailLayer.onQiMenButtonClick(sender)
    CardRoleManager:openMainRoleStarUpLayer()
end

--注册事件
function ClimbMountainDetailLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);

    -- self.btn_close:setClickAreaLength(100);
    
   self.btn_attack_1.logic = self;
   self.btn_attack_1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAttackClickHandle),1);

   self.btn_yongbing.logic = self;
   self.btn_yongbing:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onYongbingClickHandle),1);

   self.btn_attack_2.logic = self;
   self.btn_attack_2:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAttackClickHandle),1);

   self.btn_mubiao.logic = self;
   self.btn_mubiao:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onMubiaoClickHandle),1);

   self.btn_army_1.logic = self;
   self.btn_army_1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

   self.btn_army_2.logic = self;
   self.btn_army_2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

   self.btn_sweep.logic = self;
   self.btn_sweep:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSweepButtonClick),1);
   self.btn_qimen.logic = self;
   self.btn_qimen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQiMenButtonClick),1);

   if not self.sweepResultCallback then
        self.sweepResultCallback = function (netData)
           self:refreshUI()
        end
        TFDirector:addMEGlobalListener(ClimbManager.CLIMB_SWEEP_RESULT_NOTIFY,self.sweepResultCallback)

        self.AddClimbStarInfoMessageCallBack = function(event)    
            local floor = math.min(self.homeInfo.curId , ClimbConfigure:back().id)
            self.txt_num:setText(ClimbManager.climStarNum.."/"..3*floor)
        end;
        TFDirector:addMEGlobalListener(ClimbManager.AddClimbStarInfoMessage ,self.AddClimbStarInfoMessageCallBack ) ;
    end


end

function ClimbMountainDetailLayer:removeEvents()
    TFDirector:removeMEGlobalListener(ClimbManager.CLIMB_SWEEP_RESULT_NOTIFY,self.sweepResultCallback)
    self.sweepResultCallback = nil
    TFDirector:removeMEGlobalListener(ClimbManager.AddClimbStarInfoMessage ,self.AddClimbStarInfoMessageCallBack);
    self.AddClimbStarInfoMessageCallBack = nil
    self.super.removeEvents(self)
end

return ClimbMountainDetailLayer;
