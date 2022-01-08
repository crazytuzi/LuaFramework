--[[
******铁匠铺装备详情*******

	-- by david.dai
	-- 2014/06/27
]]

local EquipInfoPanel = class("EquipInfoPanel", BaseLayer)

function EquipInfoPanel:ctor(gmId)
    self.super.ctor(self,data)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.EquipInfoPanel")
end

function EquipInfoPanel:initUI(ui)
	self.super.initUI(self,ui)

    --装备图标信息区
	self.img_quality 	    = TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon 	        = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.lbl_power          = TFDirector:getChildByPath(ui, 'lbl_power')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
	self.txt_intensify_lv 	= TFDirector:getChildByPath(ui, 'txt_intensify_lv')
   
    self.bg                 = TFDirector:getChildByPath(ui, 'bg')

    --提示性控件
    self.img_improve        = TFDirector:getChildByPath(ui, 'img_improve')
    self.img_equiped        = TFDirector:getChildByPath(ui, 'img_equiped')
    self.txt_equiped_name   = TFDirector:getChildByPath(ui, 'txt_equiped_name')
    
    --星级，目前设定为屏蔽不显示
    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_star')
    --self.panel_star:setVisible(false)
    self.img_star = {}
    for i=1,EquipmentManager.kMaxStarLevel do
        local str           = "img_star_"..i
	   self.img_star[i]     = TFDirector:getChildByPath(ui, str)
    end

    --装备属性详情
    self.panel_details      = TFDirector:getChildByPath(ui, "panel_details")
    --基础属性
    self.txt_attr_base      = TFDirector:getChildByPath(ui, "txt_attr_base")
    self.txt_attr_base_val  = TFDirector:getChildByPath(ui, "txt_attr_base_val")
    --附加属性
    self.txt_attr_extra     = {}
    self.txt_attr_extra_val = {}
    for i = 1,EquipmentManager.kMaxExtraAttributeSize do
        self.txt_attr_extra[i]          = TFDirector:getChildByPath(ui, "txt_attr_extra_" .. i)
        self.txt_attr_extra_val[i]      = TFDirector:getChildByPath(ui, "txt_attr_extra_val_" .. i)
    end
    --宝石
    self.txt_attr_gem = {}
    self.txt_attr_gem_val = {}
    self.img_gem = {}
    self.img_gembg = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
    -- self.txt_gem_name                   = TFDirector:getChildByPath(ui, "txt_gem_name")
        self.img_gem[i]            = TFDirector:getChildByPath(ui, 'img_gem'..i)
        self.img_gembg[i]          = TFDirector:getChildByPath(ui, 'img_gembg'..i)
        self.txt_attr_gem[i]                   = TFDirector:getChildByPath(ui, "txt_attr_gem"..i)
        self.txt_attr_gem_val[i]               = TFDirector:getChildByPath(ui, "txt_attr_gem_val"..i)
    end
    --总战斗力
    self.txt_power_details                      = TFDirector:getChildByPath(ui, "txt_power_details")

end

function EquipInfoPanel:removeUI()
    self.super.removeUI(self)
end

function EquipInfoPanel:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function EquipInfoPanel:dispose()
    self.super.dispose(self)
end

function EquipInfoPanel:setLogic( layer )
    self.logic = layer
end

function EquipInfoPanel:setEquipGmId(gmId)
    self.gmId   = gmId
    self:refreshUI()
end
    
--刷新显示方法
function EquipInfoPanel:refreshUI()
    self:refreshIcon()
    self:refreshDetails()
end

--刷新图标区信息
function EquipInfoPanel:refreshIcon()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    self.img_icon:setTexture(equip:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(equip.quality))
    
    EquipmentManager:BindEffectOnEquip(self.img_quality, equip)

    self.txt_name:setText(equip.name)

    --字符D为图片+
    self.txt_power:setText(equip:getpower())

    self.txt_intensify_lv:setText("+"..equip.level)

    --装备于谁
    if equip.equip ~= nil and equip.equip ~= 0 then 
        local role = CardRoleManager:getRoleById(equip.equip)
        if role then
            self.txt_equiped_name:setVisible(true)
            self.img_equiped:setVisible(true)
            if role.isMainPlayer then
                self.txt_equiped_name:setText(MainPlayer.verticalName)
            else
                self.txt_equiped_name:setText(role.name)
            end
        else
            self.img_equiped:setVisible(false)
        end
    else
        self.img_equiped:setVisible(false)
    end

    if equip.level < MainPlayer:getLevel() * 3 then
        self.img_improve:setVisible(false)
    else
        self.img_improve:setVisible(false)
    end

    local star = equip:getStar()
    for i=1,5 do
        if i <= star then
            self.img_star[i]:setVisible(true)
        else
            self.img_star[i]:setVisible(false)
        end
    end

    for i=1,EquipmentManager.kGemMergeTargetNum do
        if equip:getGemPos(i) then
            self.img_gembg[i]:setVisible(true)
            local item = ItemData:objectByID(equip:getGemPos(i))
            if item then
                self.img_gem[i]:setTexture(item:GetPath())
            end
        else
            self.img_gembg[i]:setVisible(false)
        end
    end
end

--刷新详细信息
function EquipInfoPanel:refreshDetails()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    --装备属性详情
    self.panel_details      = TFDirector:getChildByPath(ui, "panel_details")
    --基础属性
    -- local baseAttr = equip:getBaseAttribute():getAttribute()
    local baseAttr = equip:getBaseAttributeWithRecast():getAttribute()
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttr[i] then
            self.txt_attr_base:setText(AttributeTypeStr[i])
            self.txt_attr_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
        end
    end

    --附加属性
    -- local extraAttr,indexTable = equip:getExtraAttribute():getAttribute()
    local extraAttr,indexTable = equip:getExtraAttributeWithRecast():getAttribute()
    -- local extraAttrWithOutGem,indexTableWithOutGem = equip:getAttrWithOutGem():getAttribute()
    local notEmptyIndex = 1
    for k,i in pairs(indexTable) do
        if extraAttr[i] then
            self.txt_attr_extra[notEmptyIndex]:setVisible(true)
            self.txt_attr_extra_val[notEmptyIndex]:setVisible(true)
            self.txt_attr_extra[notEmptyIndex]:setText(AttributeTypeStr[i])
            self.txt_attr_extra_val[notEmptyIndex]:setText("+ " .. covertToDisplayValue(i,extraAttr[i]))
            notEmptyIndex = notEmptyIndex + 1
        end
    end
    --检测是否附加属性不足3条
    for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do
        self.txt_attr_extra[i]:setVisible(false)
        self.txt_attr_extra_val[i]:setVisible(false)
    end

    --宝石
    for i=1,EquipmentManager.kGemMergeTargetNum do
        -- if equip:getGemPos(i) then
        local item = ItemData:objectByID(equip:getGemPos(i))
        if item then
            -- self.txt_gem_name:setVisible(true)
            self.txt_attr_gem[i]:setVisible(true)
            self.txt_attr_gem_val[i]:setVisible(true)
            local gem = GemData:objectByID(equip:getGemPos(i))
            if gem then
                -- self.txt_gem_name:setText(item.name)
                local attributekind , attributenum = gem:getAttribute()
                self.txt_attr_gem[i]:setText(AttributeTypeStr[attributekind])
                self.txt_attr_gem_val[i]:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
            end
        else
            -- self.txt_gem_name:setVisible(false)
            self.txt_attr_gem[i]:setVisible(false)
            self.txt_attr_gem_val[i]:setVisible(false)
        end
        -- else
        --     -- self.txt_gem_name:setVisible(false)
        --     self.txt_attr_gem:setVisible(false)
        --     self.txt_attr_gem_val:setVisible(false)
        -- end
    end

    --总战斗力
    self.txt_power_details:setText(equip:getpower())
end

function EquipInfoPanel:registerEvents()
	self.super.registerEvents(self)

    --self.EquipUpdateCallBack = function (event)
    --    if event.data[1].equip then
    --        if self.gmid == event.data[1].equip.gmId then
    --            self:refreshUI()
    --        end
    --    end
    --end
    --TFDirector:addMEGlobalListener(EquipmentManager.EQUIP_OPERATION,  self.EquipUpdateCallBack)
    --TFDirector:addMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION ,  self.EquipUpdateCallBack) 
    --self.GemMosaicResuleCallBack = function(event)
    --    if self.gmid == event.data[1].userid then
    --        self:refreshUI()
    --    end
    --end
    --TFDirector:addMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.GemMosaicResuleCallBack)
    --self.EquipmentIntensifyResultCallBack = function (event)
    --    if self.gmid == event.data[1].gmid then
    --        self:refreshUI()
    --    end
    --end
    --TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.EquipmentIntensifyResultCallBack)
    --self.GemUnMosaicResuleCallBack = function(event)
    --    if self.gmid == event.data[1].userid then
    --        self:refreshUI()
    --    end
    --end
    --TFDirector:addMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.GemUnMosaicResuleCallBack)
end

function EquipInfoPanel:removeEvents()
    --TFDirector:removeMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.GemMosaicResuleCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.GemUnMosaicResuleCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_OPERATION, self.EquipUpdateCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION, self.EquipUpdateCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.EquipmentIntensifyResultCallBack)
    self.super.removeEvents(self)
end

function EquipInfoPanel:getIconCenterWorldPos()
    local _parent = self.img_icon:getParent()
    local pos = _parent:convertToWorldSpaceAR(self.img_icon:getPosition())
    return pos
end

function EquipInfoPanel:getPowerWorldPos()
    local _parent = self.txt_power_details:getParent()
    local pos = _parent:convertToWorldSpaceAR(self.txt_power_details:getPosition())
    return pos
end

return EquipInfoPanel
