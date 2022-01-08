--[[
    穿天书，目前未穿戴
]]

local EquipdressTianshuLayer = class("EquipdressTianshuLayer", BaseLayer)

EquipdressTianshuLayer.MAX_ATTR_SIZE = 9

function EquipdressTianshuLayer:ctor()
    self.super.ctor(self,data)
    
    self.isfirst = true
    self:init("lua.uiconfig_mango_new.role.EquipdressTianShu")
end

function EquipdressTianshuLayer:loadData(roleGmId, equipGmId)
    self.roleGmId   = roleGmId;
    self.equipGmId  = equipGmId;
end

function EquipdressTianshuLayer:onShow()
    self.super.onShow(self)

    self:refreshUI();
    if self.isfirst == true then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function EquipdressTianshuLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_dress        = TFDirector:getChildByPath(ui, 'btn_zhuangpei')
    self.panel_close        = TFDirector:getChildByPath(ui, 'panel_close')
    self.panel_chuandaizhuangbei        = TFDirector:getChildByPath(ui, 'panel_chuandaizhuangbei');
end

function EquipdressTianshuLayer:refreshUI()
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    
    local equip = SkyBookManager:getItemByInstanceId(self.equipGmId)
    self:initAttr(self.panel_chuandaizhuangbei, equip);
end

function EquipdressTianshuLayer:initAttr(panel_node,equip)
    local img_zhuangbeibeijing_bg = TFDirector:getChildByPath(panel_node, 'img_zhuangbeibeijing_bg');
    
    local img_icon = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_tianshu_icon');
    img_icon:setTexture(equip:GetTextrue());

    local img_quality = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'btn_equip');
    img_quality:setTextureNormal(GetColorIconByQuality(equip.quality));
    --EquipmentManager:BindEffectOnEquip(img_quality, equip)

    local txt_name = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_zhuangbeiming');
    txt_name:setText(equip:getConfigName());
    --txt_name:setColor(GetColorByQuality(equip.quality));

    local txt_qianghualv = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_qianghualv');
    if equip.level == 0 then
        txt_qianghualv:setVisible(false)
    else
        --txt_qianghualv:setText(EnumSkyBookLevelType[equip.level] .. "重")  common_chong
        txt_qianghualv:setText( stringUtils.format(localizable.common_chong, EnumSkyBookLevelType[equip.level] ))
        txt_qianghualv:setVisible(true)
    end

    local img_arrow = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_jiantousheng');
    
    local equipInfo = self.cardRole:getSkyBook()

    if (equipInfo ~= nil and  equipInfo.instanceId == equip.instanceId) then
        img_arrow:setVisible(false);
    elseif equipInfo == nil or equip:getpower() > equipInfo:getpower() then
        img_arrow:setVisible(true);
        img_arrow:setTexture("ui_new/roleequip/js_jts_icon.png");
    else
        img_arrow:setVisible(true);
        img_arrow:setTexture("ui_new/roleequip/js_jtx_icon.png");
    end
   
    --战力值
    local txt_power = TFDirector:getChildByPath(panel_node, 'txt_zhanlizhi')

    --总属性
    local txt_attr = {}
    local txt_attr_num = {}

    for i = 1, self.MAX_ATTR_SIZE do
        txt_attr[i] = TFDirector:getChildByPath(panel_node, "txt_attr" .. i)
        txt_attr_num[i] = TFDirector:getChildByPath(panel_node, "txt_attr" .. i .. "_num")
        txt_attr[i]:setVisible(false)
        txt_attr_num[i]:setVisible(false)
    end

    local totalAttr = equip:getTotalAttr()
    local count = 0
    for i = 1, EnumAttributeType.Max - 1 do
        if totalAttr[i] and totalAttr[i] ~= 0 and count < self.MAX_ATTR_SIZE then
            count = count + 1
            txt_attr[count]:setText(AttributeTypeStr[i])
            txt_attr_num[count]:setText("+ " .. totalAttr[i])
            txt_attr[count]:setVisible(true)
            txt_attr_num[count]:setVisible(true)
        end
    end

    txt_power:setText(equip:getpower())

    Public:addStarImg(img_icon, equip.tupoLevel)
end

function EquipdressTianshuLayer:removeUI()
	self.super.removeUI(self)
end

function EquipdressTianshuLayer:registerEvents(ui)
    self.super.registerEvents(self);

    self.btn_dress.logic     = self;
    self.btn_dress:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onDressClickHandle), 1);
end

function EquipdressTianshuLayer.onDressClickHandle(sender) 
    local self = sender.logic;
    TFAudio.playEffect("sound/effect/btn_wear.mp3", false)
    local item = SkyBookManager:getItemByInstanceId(self.equipGmId)

    local data = 
    {
        roleId = self.roleGmId,
        bibleId = self.equipGmId,
        itemId = item.id
    }
    TFDirector:dispatchGlobalEventWith("SkyBookChangeBegin", {})
    SkyBookManager:requestBibleEquip(data)
    self:getParent():removeLayer(self, not self.isCache)
end


function EquipdressTianshuLayer:removeEvents()
	self.super.removeEvents(self)
    self.isfirst = true
end

return EquipdressTianshuLayer

