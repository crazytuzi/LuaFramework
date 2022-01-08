--[[
******PVE推图-关卡详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local NorthMountainDetailLayer = class("NorthMountainDetailLayer", BaseLayer);

CREATE_SCENE_FUN(NorthMountainDetailLayer);
CREATE_PANEL_FUN(NorthMountainDetailLayer);

function NorthMountainDetailLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.climb.NorthMountainDetail");
end

function NorthMountainDetailLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.txt_title                  = TFDirector:getChildByPath(ui, 'txt_title')
    self.txt_storydetail            = TFDirector:getChildByPath(ui, 'txt_description')
    self.btn_attack                 = TFDirector:getChildByPath(ui, 'btn_attack2')
    local btn_attack2               = TFDirector:getChildByPath(ui, 'btn_attack')
    btn_attack2:setVisible(false)
    self.btn_army                   = TFDirector:getChildByPath(ui, 'btn_embattle')
    self.btn_sweep                  = TFDirector:getChildByPath(ui, 'btn_sweep')
    self.txt_sweep_num              = TFDirector:getChildByPath(ui, 'txt_sweep_num')
    self.panel_content              = TFDirector:getChildByPath(ui, 'panel_content')
    self.panel_reward               = TFDirector:getChildByPath(ui, 'panel_reward')
    self.txt_zhanli                 = TFDirector:getChildByPath(ui, 'txt_zhanli')
    self.btn_bangzhu                = TFDirector:getChildByPath(ui, 'btn_bangzhu')   


    self.button = {};
    for i=1,9 do

        self.button[i] = TFDirector:getChildByPath(ui, "img_quality" .. i);
        self.button[i].icon = TFDirector:getChildByPath(self.button[i] ,"img_role" ..i);

        self.button[i].img_zhiye = TFDirector:getChildByPath(self.button[i], "img_zhiye");
        self.button[i].img_zhiye:setVisible(false);

        self.button[i]:setVisible(false);
        self.button[i].icon:setVisible(false);
    end

    self.rewardBox = require('lua.logic.climb.ClimbMountainItembox'):new()
    self.box_img = TFDirector:getChildByPath(self.rewardBox, 'img_icon')
    self.rewardBox:setZOrder(10)
    self.rewardBox:setPosition(ccp(830,230))
    self.panel_content:addChild(self.rewardBox)
    self.rewardBox:setScale(0.8)
end

function NorthMountainDetailLayer:loadData(mountainData)
    self.mountainData   = mountainData;

    self.mountainInfo   = NorthCaveData:objectByID(mountainData.sectionId);
    self.northCaveNpcInfo = NorthCaveNpcData:objectByID(mountainData.formationId )

    self:refreshBaseUI();
    self:refreshUI();
end

function NorthMountainDetailLayer:onShow()
    self.super.onShow(self)
end

function NorthMountainDetailLayer:refreshBaseUI()

end

function NorthMountainDetailLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end

    local floor_num = math.mod(self.mountainInfo.id,3)
    floor_num = floor_num == 0 and 3 or floor_num
    --self.txt_title:setText("第" .. floor_num .. "关") ;
    self.txt_title:setText(stringUtils.format(localizable.common_index_round,floor_num))
    self.txt_storydetail:setText(self.northCaveNpcInfo.desc);
    self.txt_zhanli:setText(self.mountainInfo.power) ;

    self.panel_reward:removeAllChildren();

    local rewardList =  NorthClimbManager:getRewardItemList(self.mountainInfo.id);

    local index = 1;
    for reward in rewardList:iterator() do
        local rewardNode = Public:createIconNumNode(reward)
        rewardNode:setScale(0.6)
        -- rewardNode:setPosition(0, -80*index)
        rewardNode:setPosition(10 + 75*(index-1), -72)
        self.panel_reward:addChild(rewardNode)
        index = index + 1;
    end


    local npcs = NPCData:GetNPCListByIds(self.northCaveNpcInfo.formation);

    for index=1,9 do
        local role = npcs[index];
        if  role ~= nil then
            role.level = self.mountainInfo.npc_level
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


    self.btn_attack:setVisible(true);  
    self.btn_army:setVisible(true);
    self.btn_sweep:setVisible(false)

end

function NorthMountainDetailLayer.cellClickHandle(sender)
    local self = sender.logic;
    local role = sender.role;
    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
    -- CardRoleManager:openRoleSimpleInfo(role);
end

function NorthMountainDetailLayer.onAttackClickHandle(sender)
    local self = sender.logic;

    NorthClimbManager:showClimbChooseLayer(self.mountainData)
end

function NorthMountainDetailLayer.onArmyClickHandle(sender)
    CardRoleManager:openRoleList(false);
end

function NorthMountainDetailLayer.onClickNorthClimbHelp(sender)
    CommonManager:showRuleLyaer("wuliangshanbeiku")
end

--注册事件
function NorthMountainDetailLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);

    -- self.btn_close:setClickAreaLength(100);

    self.btn_bangzhu:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickNorthClimbHelp))
    
   self.btn_attack.logic = self;
   self.btn_attack:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAttackClickHandle),1)

   self.btn_army.logic = self;
   self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1)

    self.onReceivNorthCaveChestGotMarkUpdate = function(event)
        self:showBoxVisible(false)
    end;
    TFDirector:addMEGlobalListener(NorthClimbManager.NORTH_CAVE_CHEST_GOT_MARK_UPDATE ,self.onReceivNorthCaveChestGotMarkUpdate)


end

function NorthMountainDetailLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(NorthClimbManager.NORTH_CAVE_CHEST_GOT_MARK_UPDATE,self.onReceivNorthCaveChestGotMarkUpdate)
end
function NorthMountainDetailLayer:setAttackEnable(enable)
    self.btn_attack:setTouchEnabled(enable)
end
function NorthMountainDetailLayer:showBoxVisible(enable)
    if enable == false and self.boxEffect == nil then
        return
    end
    if self.boxEffect == nil then
         TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/northClimbBox.xml")
        local effect = TFArmature:create("northClimbBox_anim")
        if effect == nil then
            return
        end
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 1)
        effect:setPosition(ccp(101, 56))
        effect:setZOrder(10)
        self.rewardBox:addChild(effect)
        self.boxEffect = effect
    end
    self.box_img:setVisible(not enable)
    self.boxEffect:setVisible(enable)
end

return NorthMountainDetailLayer;
