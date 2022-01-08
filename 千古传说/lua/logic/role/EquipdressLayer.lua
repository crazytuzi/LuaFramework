--[[
******穿装备，目前未穿戴*******

	-- by haidong.gan
	-- 2013/12/5
]]

local EquipdressLayer = class("EquipdressLayer", BaseLayer)


--CREATE_SCENE_FUN(EquipdressLayer)
CREATE_PANEL_FUN(EquipdressLayer)

function EquipdressLayer:ctor()
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.EquipdressLayer")
    self.isfirst = true

end

function EquipdressLayer:loadData(roleGmId,equipGmId)
    self.roleGmId   = roleGmId;
    self.equipGmId  = equipGmId;
end

function EquipdressLayer:onShow()
    self.super.onShow(self)
    
    self:refreshBaseUI();
    self:refreshUI();

    if self.isfirst == true then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function EquipdressLayer:refreshBaseUI()

end

function EquipdressLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_unEquip        = TFDirector:getChildByPath(ui, 'btn_zhuangbei')
    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_close        = TFDirector:getChildByPath(ui, 'panel_close')

    self.btn_improve        = TFDirector:getChildByPath(ui, 'btn_qianghua');


    self.panel_chuandaizhuangbei        = TFDirector:getChildByPath(ui, 'panel_chuandaizhuangbei');

end

function EquipdressLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    
    local equip =EquipmentManager:getEquipByGmid(self.equipGmId);
    -- print(equip)
    self:initAttr(self.panel_chuandaizhuangbei,equip);

end


function EquipdressLayer:initAttr(pannl_node,equip)
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

    local img_gem_bg = {}
    local img_gem = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
        img_gem_bg[i] = TFDirector:getChildByPath(img_zhuangbeibeijing_bg, 'img_baoshicao'..i);
        img_gem[i] = TFDirector:getChildByPath(img_gem_bg[i], 'img_gem');
    end
    for i=1,EquipmentManager.kGemMergeTargetNum do
        local gemId = equip:getGemPos(i);
        if (gemId == nil) then
            img_gem_bg[i]:setVisible(false);
        else
            img_gem_bg[i]:setVisible(true);
            img_gem[i]:setTexture(ItemData:objectByID(gemId):GetPath())
        end
    end

    local img_zhuangbeibeijing_bg        = TFDirector:getChildByPath(pannl_node, 'img_zhuangbeibeijing_bg');

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
    local img_gem_bg = {}
    local img_gem = {}
    local txt_attr_gem = {}
    local txt_attr_gem_val = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
        img_gem_bg[i]                     = TFDirector:getChildByPath(pannl_node, "img_baoshicao"..i)
        img_gem[i]                        = TFDirector:getChildByPath(img_gem_bg[i], "img_baoshi")
        txt_attr_gem[i]                   = TFDirector:getChildByPath(img_gem_bg[i], "txt_baoshishuxing")
        txt_attr_gem_val[i]               = TFDirector:getChildByPath(img_gem_bg[i], "txt_shuxingzhi")        
    end
    
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
            img_attr_point[notEmptyIndex]:setVisible(true)
        
            txt_attr_extra[notEmptyIndex]:setText(AttributeTypeStr[i])
            txt_attr_extra_val[notEmptyIndex]:setText("+ " .. covertToDisplayValue(i,extraAttr[i]))
            notEmptyIndex = notEmptyIndex + 1
        end
    end
    --检测是否附加属性不足3条
    for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do
        txt_attr_extra[i]:setVisible(false)
        txt_attr_extra_val[i]:setVisible(false)
        img_attr_point[i]:setVisible(false)
        
    end

    --宝石
    for i=1,EquipmentManager.kGemMergeTargetNum do
        if equip:getGemPos(i) then
            local item = ItemData:objectByID(equip:getGemPos(i))
            if item then
                img_gem_bg[i]:setVisible(true);
                local gem = GemData:objectByID(equip:getGemPos(i))
                if gem then
                    -- txt_gem_name:setText(item.name)
                    img_gem[i]:setTexture(item:GetPath())
                    local attributekind , attributenum = gem:getAttribute()
                    txt_attr_gem[i]:setText(AttributeTypeStr[attributekind])
                    txt_attr_gem_val[i]:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
                end
            else
                img_gem_bg[i]:setVisible(false);
            end
        else
            img_gem_bg[i]:setVisible(false);
        end
    end
    txt_power:setText(equip:getpower());

    Public:addStarImg(img_icon,equip.star)
end

function EquipdressLayer:removeUI()
	self.super.removeUI(self)
end

function EquipdressLayer:registerEvents(ui)
    self.super.registerEvents(self);

    -- self.panel_close.logic     = self;
    -- self.panel_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle));

    -- self.btn_close.logic     = self;
    -- self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle));
    -- self.btn_close:setClickAreaLength(100);

    self.btn_unEquip.logic     = self;
    self.btn_unEquip:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEquipmentClickHandle),1);
    self.btn_improve.logic     = self;
    self.btn_improve:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onImproveClickHandle),1);


end

function EquipdressLayer.onImproveClickHandle(sender)
     local self = sender.logic;

     local equipItem =EquipmentManager:getEquipByGmid(self.equipGmId);
     local equipList = EquipmentManager:GetEquipByType(equipItem.equipType);

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

function EquipdressLayer.onCloseClickHandle(sender) 
    local self = sender.logic;
    self:getParent():removeLayer(self, not self.isCache);

    self.ui:runAnimation("Action1", 1)
end

function EquipdressLayer.onEquipmentClickHandle(sender) 
    local self = sender.logic;
    TFAudio.playEffect("sound/effect/btn_wear.mp3", false)

    TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{});    

    EquipmentManager:EquipmentChange({gmid = self.equipGmId,roleid = self.cardRole.id});
    self:getParent():removeLayer(self, not self.isCache);
end


function EquipdressLayer:removeEvents()
	self.super.removeEvents(self)
    self.isfirst = true
end

return EquipdressLayer

