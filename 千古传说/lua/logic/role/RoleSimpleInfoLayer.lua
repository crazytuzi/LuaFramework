--[[
******角色简易面板*******
    -- by haidong.gan
    -- 2014/4/10
]]

local RoleSimpleInfoLayer = class("RoleSimpleInfoLayer", BaseLayer)

function RoleSimpleInfoLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.RoleSimpleInfoLayer")
end

function RoleSimpleInfoLayer:initUI(ui)
    self.super.initUI(self,ui)


    self.img_quality    = TFDirector:getChildByPath(ui, 'itemImg');
    self.img_role       = TFDirector:getChildByPath(ui, 'img_role');
    self.img_type       = TFDirector:getChildByPath(ui, 'img_zhiye');

    self.txt_level      = TFDirector:getChildByPath(ui, 'txt_level');
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name');
    self.txt_des        = TFDirector:getChildByPath(ui, 'txt_des');

end
function RoleSimpleInfoLayer:loadData(cardRole)
    self.cardRole = cardRole;
    self:refreshUI();
end

function RoleSimpleInfoLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function RoleSimpleInfoLayer:refreshBaseUI()

end

function RoleSimpleInfoLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end

    --角色信息
    self.img_role:setTexture(self.cardRole:getHeadPath());
    self.txt_name:setText(self.cardRole.name);

    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality));
    self.img_quality:setTexture(GetColorRoadIconByQualitySmall(self.cardRole.quality));
    print(GetColorRoadIconByQualitySmall(self.cardRole.quality))
    self.txt_level:setText(self.cardRole.level .. "d");

    if self.cardRole.description then
        self.txt_des:setText(self.cardRole.description);
        self.img_type:setTexture("ui_new/common/img_role_type" .. self.cardRole.outline .. ".png");
    else
        local cardRole = RoleData:objectByID(self.cardRole.role_id);
        self.txt_des:setText(cardRole.description);
        self.img_type:setTexture("ui_new/common/img_role_type" .. cardRole.outline .. ".png");
    end
end


return RoleSimpleInfoLayer
