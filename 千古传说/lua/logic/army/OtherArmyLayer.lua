--[[
******布阵-对方详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local OtherArmyLayer = class("OtherArmyLayer", BaseLayer);

CREATE_SCENE_FUN(OtherArmyLayer);
CREATE_PANEL_FUN(OtherArmyLayer);

OtherArmyLayer.LIST_ITEM_WIDTH = 200; 

function OtherArmyLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.role.OtherArmyLayer");
end

function OtherArmyLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_challenge  = TFDirector:getChildByPath(ui, 'btn_challenge')
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_mingcheng_word')

    self.txt_rank       = TFDirector:getChildByPath(ui, 'txt_paiming_word')
    self.btn_army       = TFDirector:getChildByPath(ui, 'btn_buzhen')

    -- self.txt_level      = TFDirector:getChildByPath(ui, 'txt_level')
    -- self.txt_vipLevel   = TFDirector:getChildByPath(ui, 'txt_vipLevel')

    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_zhandouli_word')
    self.txt_winRate    = TFDirector:getChildByPath(ui, 'txt_shenglv_word')

    self.img_rolebg = {}
    self.img_role = {}
    self.img_role_quility = {}

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
end

function OtherArmyLayer:loadData(userData)
    self.userData = userData;
end

function OtherArmyLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function OtherArmyLayer:refreshBaseUI()

end

function OtherArmyLayer:refreshUI()
    if not self.isShow then
        return;
    end

    self.txt_name:setText(self.userData.name)
    -- self.txt_level:setText(self.userData.level)
    -- self.txt_vipLevel:setText(self.userData.vipLevel)
    self.txt_power:setText(self.userData.power)

    for index=1,9 do
        local role,roleData = self:getRoleBtPos(index);
        if  role ~= nil then
            self.button[index].icon:setVisible(true);
            self.button[index].icon:setTexture(role:getHeadPath());

            self.button[index].bg:setVisible(true);
            self.button[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(roleData.quality));
            self.button[index].img_zhiye:setVisible(true);
            self.button[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            self.button[index].bg.cardRoleId = role.id;
            Public:addLianTiEffect(self.button[index].icon,roleData.forgingQuality,true)
        else
            self.button[index].img_zhiye:setVisible(false);
            self.button[index].icon:setVisible(false);
            self.button[index].bg:setVisible(false);
            Public:addLianTiEffect(self.button[index].icon,0,false)
        end
    end
end

function OtherArmyLayer:getRoleBtPos(pos)
    for _,v in pairs(self.userData.warside) do
        local idx = v.warIndex + 1
        if idx == pos then
            return RoleData:objectByID(v.id),OtherPlayerManager.cardRoleDic[v.id];
        end
    end
end

function OtherArmyLayer.cellClickHandle(sender)
    local self = sender.logic;
    local cardRoleId = sender.cardRoleId;
    OtherPlayerManager:openRoleInfo(self.userData,cardRoleId);
end
function OtherArmyLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleList();
end

function OtherArmyLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function OtherArmyLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);
    
   
    self.btn_army.logic = self;
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

    for i=1,9 do
        self.button[i].bg.logic = self;
        self.button[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cellClickHandle),1);
    end
   self.btn_challenge.logic = self;
end

function OtherArmyLayer:removeEvents()

end

return OtherArmyLayer;
