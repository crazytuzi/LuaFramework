--[[
******卸装备*******

	-- by haidong.gan
	-- 2013/12/5
]]

local EquipuninstallLayer = class("EquipuninstallLayer", BaseLayer)


--CREATE_SCENE_FUN(EquipuninstallLayer)
CREATE_PANEL_FUN(EquipuninstallLayer)

function EquipuninstallLayer:ctor()
    self.super.ctor(self,data)
    self.isfirst = true
    self:init("lua.uiconfig_mango_new.role.EquipuninstallLayer")

end
function EquipuninstallLayer:loadData(roleGmId,equipGmId)
    self.roleGmId   = roleGmId;
    self.equipGmId  = equipGmId
end

function EquipuninstallLayer:onShow()
    self.super.onShow(self)
    
    self:refreshBaseUI();
    self:refreshUI();
    if self.isfirst == true then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function EquipuninstallLayer:refreshBaseUI()

end

function EquipuninstallLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_unEquip        = TFDirector:getChildByPath(ui, 'btn_zhuangbei')
    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_close        = TFDirector:getChildByPath(ui, 'panel_close');
    self.btn_improve        = TFDirector:getChildByPath(ui, 'btn_qianghua');

    self.panel_chuandaizhuangbei        = TFDirector:getChildByPath(ui, 'panel_chuandaizhuangbei');
end


function EquipuninstallLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    
    local equip =EquipmentManager:getEquipByGmid(self.equipGmId);
    self:initAttr(self.panel_chuandaizhuangbei,equip);

end


function EquipuninstallLayer:initAttr(pannl_node,equip)

    local img_zhuangbeibeijing_bg = TFDirector:getChildByPath(pannl_node, 'img_zhuangbeibeijing_bg');
    
    local img_icon = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_skill_icon');
    img_icon:setTexture(equip:GetTextrue());

    local img_quality = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'btn_equip');
    img_quality:setTextureNormal(GetColorIconByQuality(equip.quality));
    EquipmentManager:BindEffectOnEquip(img_quality, equip)

    local txt_name = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_zhuangbeiming');
    txt_name:setText(equip.name);
    -- txt_name:setColor(GetColorByQuality(equip.quality));

    local txt_level = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'txt_qianghualv');
    txt_level:setText("+" .. equip.level);
    
    -- for i=1,5 do
    --    local img_star = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_xingxing' .. i);
    --     if (equip.star >= i) then
    --         img_star:setVisible(true);
    --     else
    --         img_star:setVisible(false);
    --     end
    -- end
    local img_arrow = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_jiantousheng');
    
    local equipInfo = self.cardRole:getEquipment():GetEquipByType(equip.equipType)

    if (equipInfo ~= nil and  equipInfo.gmId == equip.gmId) then
        img_arrow:setVisible(false);
    elseif equipInfo == nil or equip:getpower() > equipInfo:getpower() then
        img_arrow:setVisible(true);
        img_arrow:setTexture("ui_new/roleequip/js_jts_icon.png");
    else
        img_arrow:setVisible(true);
        img_arrow:setTexture("ui_new/roleequip/js_jtx_icon.png");
    end

    local img_gem_bg = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_baoshicao');
    local img_gem = TFDirector:getChildByPath(img_gem_bg, 'img_gem');
    local gemId = equip:getGemPos(1);
    if (gemId == nil) then
        img_gem_bg:setVisible(false);
    else
        img_gem_bg:setVisible(true);
        img_gem:setTexture(ItemData:objectByID(gemId):GetPath())
    end

    -- 宝石2
    img_gem_bg = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_baoshicao2');
    img_gem = TFDirector:getChildByPath(img_gem_bg, 'img_gem');
    local gemId = equip:getGemPos(2);
    if (gemId == nil) then
        img_gem_bg:setVisible(false);
    else
        img_gem_bg:setVisible(true);
        img_gem:setTexture(ItemData:objectByID(gemId):GetPath())
    end


    -- local img_zhuangbeibeijing_bg        = TFDirector:getChildByPath(pannl_node, 'img_zhuangbeibeijing_bg');

    --基础属性
    local txt_attr_base      = TFDirector:getChildByPath(pannl_node, "txt_baseattr_index")
    local txt_attr_base_val  = TFDirector:getChildByPath(pannl_node, "txt_baseattr_num")
    --附加属性
    local txt_attr_extra     = {}
    local txt_attr_extra_val = {}
    local img_attr_point = {}
    
    for i = 1,EquipmentManager.kMaxExtraAttributeSize do
        txt_attr_extra[i]          = TFDirector:getChildByPath(pannl_node, "txt_extraattr_" .. i)
        txt_attr_extra_val[i]      = TFDirector:getChildByPath(pannl_node, "txt_extraattr_num_" .. i)
        img_attr_point[i]          = TFDirector:getChildByPath(pannl_node, "img_point" .. i)
    end

    --宝石
    local img_gem_bg                    = TFDirector:getChildByPath(pannl_node, "img_baoshicao_att1")
    local img_gem                        = TFDirector:getChildByPath(img_gem_bg, "img_baoshi")
    local txt_attr_gem                   = TFDirector:getChildByPath(img_gem_bg, "txt_baoshishuxing")
    local txt_attr_gem_val               = TFDirector:getChildByPath(img_gem_bg, "txt_shuxingzhi")


    local txt_power                      = TFDirector:getChildByPath(pannl_node, 'txt_zhanlizhi');

    --基础属性
    -- local baseAttr = equip:getBaseAttribute():getAttribute()
    local baseAttr = equip:getBaseAttributeWithRecast():getAttribute()
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttr[i] then
            txt_attr_base:setText(AttributeTypeStr[i])
            txt_attr_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
        end
    end

    --附加属性
    -- local extraAttr,indexTable = equip:getExtraAttribute():getAttribute()
    local extraAttr,indexTable = equip:getExtraAttributeWithRecast():getAttribute()
    local notEmptyIndex = 1
    for k,i in pairs(indexTable) do
        if extraAttr[i] then
            txt_attr_extra[notEmptyIndex]:setVisible(true)
            txt_attr_extra_val[notEmptyIndex]:setVisible(true)
            if img_attr_point[notEmptyIndex] then
                img_attr_point[notEmptyIndex]:setVisible(true)
            end
        
            txt_attr_extra[notEmptyIndex]:setText(AttributeTypeStr[i])
            txt_attr_extra_val[notEmptyIndex]:setText("+ " .. covertToDisplayValue(i,extraAttr[i]))
            notEmptyIndex = notEmptyIndex + 1
        end
    end
    --检测是否附加属性不足3条
    for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do
        txt_attr_extra[i]:setVisible(false)
        txt_attr_extra_val[i]:setVisible(false)

        if img_attr_point[i] then
            img_attr_point[i]:setVisible(false)
        end
    end

    --宝石
    if equip:getGemPos(1) then
        local item = ItemData:objectByID(equip:getGemPos(1))
        if item then
            img_gem_bg:setVisible(true);


            local gem = GemData:objectByID(equip:getGemPos(1))
            if gem then
                -- txt_gem_name:setText(item.name)
                img_gem:setTexture(item:GetPath())
                local attributekind , attributenum = gem:getAttribute()
                txt_attr_gem:setText(AttributeTypeStr[attributekind])
                txt_attr_gem_val:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
            end
        else
            img_gem_bg:setVisible(false);
        end
    else
        img_gem_bg:setVisible(false);
    end

    img_gem_bg                    = TFDirector:getChildByPath(pannl_node, "img_baoshicao_att2")
    img_gem                        = TFDirector:getChildByPath(img_gem_bg, "img_baoshi")
    txt_attr_gem                   = TFDirector:getChildByPath(img_gem_bg, "txt_baoshishuxing")
    txt_attr_gem_val               = TFDirector:getChildByPath(img_gem_bg, "txt_shuxingzhi")
    --宝石
    if equip:getGemPos(2) then
        local item = ItemData:objectByID(equip:getGemPos(2))
        if item then
            img_gem_bg:setVisible(true);


            local gem = GemData:objectByID(equip:getGemPos(2))
            if gem then
                -- txt_gem_name:setText(item.name)
                img_gem:setTexture(item:GetPath())
                local attributekind , attributenum = gem:getAttribute()
                txt_attr_gem:setText(AttributeTypeStr[attributekind])
                txt_attr_gem_val:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
            end
        else
            img_gem_bg:setVisible(false);
        end
    else
        img_gem_bg:setVisible(false);
    end

    txt_power:setText(equip:getpower());

    Public:addStarImg(img_icon,equip.star)
end

function EquipuninstallLayer:removeUI()
	self.super.removeUI(self)
end

function EquipuninstallLayer:registerEvents(ui)
    self.super.registerEvents(self);

    -- self.panel_close.logic     = self;
    -- self.panel_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle));

    -- self.btn_close.logic     = self;
    -- self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle));
    -- self.btn_close:setClickAreaLength(100);

    self.btn_unEquip.logic     = self;
    self.btn_unEquip:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUnEquipmentClickHandle),1);
    self.btn_improve.logic     = self;
    self.btn_improve:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onImproveClickHandle),1);

end
function EquipuninstallLayer.onImproveClickHandle(sender)
     local self = sender.logic;

     local equipItem =EquipmentManager:getEquipByGmid(self.equipGmId);
     --local equipList = nil;
     --if equipItem.equip ~= 0 then
     --   local role = CardRoleManager:getRoleById(equipItem.equip)
     --   equipList = role.equipment:allAsArray()
     --else
     --   equipList = EquipmentManager:GetAllEquipInWarSideFirst(equipItem.equipType)
     --end
     
     if self.equipGmId then
        if equipItem.equip ~= 0 then
            EquipmentManager:openSmithyLayer(self.equipGmId, nil, nil,false) 
        else
            EquipmentManager:openSmithyLayer(self.equipGmId,equipList,equipItem.equipType,true)
        end
     else
        EquipmentManager:OpenSmithyMainLaye();
     end
end
function EquipuninstallLayer.onCloseClickHandle(sender) 
    local self = sender.logic;
    self:getParent():removeLayer(self, not self.isCache);
end

function EquipuninstallLayer.onUnEquipmentClickHandle(sender) 
    local self = sender.logic;
    TFAudio.playEffect("sound/effect/btn_drop.mp3", false)

    TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{});

    --穿裝
    EquipmentManager:unEquipmentChange({gmid = self.equipGmId,roleid = self.cardRole.id});
    -- self:getParent():removeLayer(self, not self.isCache);
end

function EquipuninstallLayer:removeEvents()
	self.super.removeEvents(self)
    self.isfirst = true
end

return EquipuninstallLayer

