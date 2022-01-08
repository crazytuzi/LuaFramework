--[[
    更换天书,已穿戴
]]

local EquipreplaceTianshuLayer = class("EquipreplaceTianshuLayer", BaseLayer)

EquipreplaceTianshuLayer.MAX_ATTR_SIZE = 9

function EquipreplaceTianshuLayer:ctor()
    self.super.ctor(self, data)

    self:init("lua.uiconfig_mango_new.role.EquipReplaceTianShu")

end

function EquipreplaceTianshuLayer:loadData(roleGmId,equipGmId)
    self.roleGmId   = roleGmId;
    self.equipGmId  = equipGmId;
end

function EquipreplaceTianshuLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function EquipreplaceTianshuLayer:initUI(ui)
    self.super.initUI(self, ui)
    
    self.btn_genghuan        = TFDirector:getChildByPath(ui, 'btn_genghuan')
    self.panel_close        = TFDirector:getChildByPath(ui, 'panel_close')

    self.panel_chuandaizhuangbei        = TFDirector:getChildByPath(ui, 'panel_chuandaizhuangbei');
    self.panel_dangqianzhuangbei        = TFDirector:getChildByPath(ui, 'panel_dangqianzhuangbei');
end

function EquipreplaceTianshuLayer:refreshUI()
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);

    local equip = SkyBookManager:getItemByInstanceId(self.equipGmId);
    self:initAttr(self.panel_chuandaizhuangbei, equip);

    local cur_equip = self.cardRole:getSkyBook()
    self:initAttr(self.panel_dangqianzhuangbei, cur_equip);
end


function EquipreplaceTianshuLayer:initAttr(panel_node,equip)
    local img_zhuangbeibeijing_bg = TFDirector:getChildByPath(panel_node, 'img_zhuangbeibeijing_bg');
    
    local img_quality = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'btn_equip');
    img_quality:setTextureNormal(GetColorIconByQuality(equip.quality));
    --EquipmentManager:BindEffectOnEquip(img_quality, equip)

    local img_icon = TFDirector:getChildByPath(img_quality, 'img_tianshu_icon');
    img_icon:setTexture(equip:GetTextrue());

    local txt_name = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_zhuangbeiming');
    txt_name:setText(equip:getConfigName());
    --txt_name:setColor(GetColorByQuality(equip.quality));

    local txt_qianghualv = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_qianghualv');
    if equip.level == 0 then
        txt_qianghualv:setVisible(false)
    else
        --txt_qianghualv:setText(EnumSkyBookLevelType[equip.level] .. "重")
        txt_qianghualv:setText(stringUtils.format(localizable.common_chong,EnumSkyBookLevelType[equip.level] ))
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

function EquipreplaceTianshuLayer:removeUI()
    self.super.removeUI(self)
end

function EquipreplaceTianshuLayer:registerEvents(ui)
    self.super.registerEvents(self);

    self.btn_genghuan.logic = self;
    self.btn_genghuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGenghuanClickHandle),1);
end

function EquipreplaceTianshuLayer.onGenghuanClickHandle(sender) 
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


function EquipreplaceTianshuLayer:removeEvents()
    self.super.removeEvents(self)
end

return EquipreplaceTianshuLayer