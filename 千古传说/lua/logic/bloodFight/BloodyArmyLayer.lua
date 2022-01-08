--[[
******布阵-对方详情*******

    -- by haidong.gan
    -- 2013/11/27

    -- modify by king
    -- 2014/8/18
]]
local BloodyArmyLayer = class("BloodyArmyLayer", BaseLayer);
-- local CardRole = require('lua.gamedata.base.CardRole')
CREATE_SCENE_FUN(BloodyArmyLayer);
CREATE_PANEL_FUN(BloodyArmyLayer);

BloodyArmyLayer.LIST_ITEM_WIDTH = 200; 

function BloodyArmyLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleOtherArmyLayer");
end

function BloodyArmyLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_army       = TFDirector:getChildByPath(ui, 'btn_continue')
    -- self.btn_challenge  = TFDirector:getChildByPath(ui, 'btn_challenge')

    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_mingcheng_word')

    self.txt_rank       = TFDirector:getChildByPath(ui, 'txt_paiming_word')
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

        self.button[i].bar_bg       = TFDirector:getChildByPath(self.button[i],"img_xuetiao"..i);
        self.button[i].bar_hp       = TFDirector:getChildByPath(self.button[i],"bar_xuetiao"..i);
        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye"..i);
        self.button[i].img_death    = TFDirector:getChildByPath(self.button[i],"img_death"..i);

        self.button[i].quality = TFDirector:getChildByPath(ui, btnName);


        self.button[i].img_death:setVisible(false)
    end
end

function BloodyArmyLayer:loadData(userData)
    self.userData = userData
end

function BloodyArmyLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function BloodyArmyLayer:refreshBaseUI()

end

function BloodyArmyLayer:refreshUI()
    self.txt_name:setText(self.userData.name)
    self.txt_power:setText(self.userData.power)

    for index=1,9 do
        local role = self:getRoleBtPos(index);
        if  role ~= nil then
            self.button[index].icon:setVisible(true);
            self.button[index].icon:setTexture(role:getHeadPath());

            self.button[index].bg:setVisible(true);
            self.button[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality));
            -- self.button[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            self.button[index].bg.cardRoleId = role.id;
            self.button[index].bg.role = role;

            self.button[index].img_type:setVisible(true);
            self.button[index].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            if role.currHp <= 0 then
                self.button[index].img_death:setVisible(true)
                self.button[index].icon:setShaderProgram("GrayShader", true)
            else
                self.button[index].img_death:setVisible(false)
                self.button[index].icon:setShaderProgramDefault(true)
            end

            self.button[index].bar_hp:setPercent(role.currHp * 100 / role.maxHp)
        else
            self.button[index].icon:setVisible(false);
            self.button[index].bg:setVisible(false);     
        
            self.button[index].bar_bg:setVisible(false)
            self.button[index].img_type:setVisible(false)
        end
    end
end

function BloodyArmyLayer:getRoleBtPos(pos)
    for _,v in pairs(self.userData.roles) do
        local idx = v.index + 1
        if idx == pos then
            local roleId = v.profession
            print("role = ", roleId)
            local cardRole = RoleData:objectByID(roleId);
            -- self.cardRole   = CardRole:new(self.roleid)
            cardRole.level  = v.lv
            cardRole.maxHp  = v.maxHp
            cardRole.currHp = v.currHp
            return cardRole
        end
    end
end

function BloodyArmyLayer.cellClickHandle(sender)
    local self = sender.logic;
    local cardRoleId = sender.cardRoleId;
    -- OtherPlayerManager:openRoleInfo(self.userData,cardRoleId);
    -- print("cardRoleId = ", cardRoleId)
    -- local cardRole   = CardRole:new(cardRoleId)
    -- print("sender.role = ", sender.role)
    Public:ShowItemTipLayer(sender.role.id, EnumDropType.ROLE, 1,sender.role.level)
    -- CardRoleManager:openRoleSimpleInfo(sender.role)
end

function BloodyArmyLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    -- CardRoleManager:openRoleList(false);
end

function BloodyArmyLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function BloodyArmyLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);
    
   
    self.btn_army.logic = self;
    -- self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

    for i=1,9 do
        self.button[i].bg.logic = self;
        self.button[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cellClickHandle),1);
    end
   -- self.btn_challenge.logic = self;
end

function BloodyArmyLayer:removeEvents()

end

return BloodyArmyLayer;
