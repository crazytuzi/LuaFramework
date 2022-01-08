--[[
******铁匠铺装备详情*******

	-- by david.dai
	-- 2014/06/27
]]

local EquipDetailsDialog = class("EquipDetailsDialog", BaseLayer)

function EquipDetailsDialog:ctor(gmId,list,equipType,allList)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.smithy.Equipgo")
end

function EquipDetailsDialog:loadData(gmId,list,equipType,allList)
    self.gmId = gmId
    self.equipList = list
    if equipType and equipType ~=0 then
        self.equipType = equipType
    end
    self.allList = allList
end
function EquipDetailsDialog:initUI(ui)
	self.super.initUI(self,ui)

    --装备图标信息区
	self.img_quality 	    = TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon 	        = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.lbl_power          = TFDirector:getChildByPath(ui, 'lbl_power')
    --self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
	self.txt_intensify_lv 	= TFDirector:getChildByPath(ui, 'txt_intensify_lv')
    -- self.img_gem            = TFDirector:getChildByPath(ui, 'img_gem')
    -- self.img_gembg          = TFDirector:getChildByPath(ui, 'img_gembg')
    -- self.img_gem_2          = TFDirector:getChildByPath(ui, 'img_gem_2')
    -- self.img_gembg_2        = TFDirector:getChildByPath(ui, 'img_gembg_2')
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
    --img_gembg_1
    self.img_gembg = {}
    self.img_gem = {}
    self.txt_gem_name = {}
    self.icon_gembg = {}
    self.icon_gem = {}
    local img_infoNode = TFDirector:getChildByPath(ui, "img_info")
    local img_greyNode = TFDirector:getChildByPath(ui, "img_grey")
    for i = 1,EquipmentManager.kGemMergeTargetNum do
        self.txt_gem_name[i]  = TFDirector:getChildByPath(img_infoNode, "txt_gem_name"..i)
        self.img_gembg[i]  = TFDirector:getChildByPath(img_infoNode, "img_gembg_"..i)
        self.img_gem[i]   = TFDirector:getChildByPath(img_infoNode, "img_gem_"..i)
        self.icon_gembg[i]  = TFDirector:getChildByPath(img_greyNode, "img_gembg_"..i)
        self.icon_gem[i]   = TFDirector:getChildByPath(img_greyNode, "img_gem_"..i)
    end
    --self.txt_attr_gem                   = TFDirector:getChildByPath(ui, "txt_attr_gem")
    --self.txt_attr_gem_val               = TFDirector:getChildByPath(ui, "txt_attr_gem_val")
    --总战斗力
    self.txt_power_details              = TFDirector:getChildByPath(ui, "txt_power_details")
    self.txt_info                       = TFDirector:getChildByPath(ui, "txt_info")

    --功能按钮
    self.btn_equip                      = TFDirector:getChildByPath(ui, "btn_equip")
    self.btn_equip.logic = self
    self.btn_equip:setVisible(false)
    self.btn_qianghua                   = TFDirector:getChildByPath(ui, "btn_qianghua")
    self.btn_qianghua.logic = self

    self.btn_close                      = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close.logic = self

end

function EquipDetailsDialog:removeUI()
    self.super.removeUI(self)
end

function EquipDetailsDialog:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function EquipDetailsDialog:setLogic( layer )
    self.logic = layer
end

function EquipDetailsDialog:setEquipGmId(gmId)
    self.gmId   = gmId
    self:refreshUI()
end

function EquipDetailsDialog:dispose()
    self.super.dispose(self)
end
    
--刷新显示方法
function EquipDetailsDialog:refreshUI()
    self:refreshIcon()
    self:refreshDetails()

    local winSize = GameConfig.WS
    local position = self.ui:getPosition()
    self.ui:setPosition(ccp(position.x,winSize.height/2))
end

--刷新图标区信息
function EquipDetailsDialog:refreshIcon()
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
    --self.txt_power:setText("D"..equip:getpower())

    self.txt_intensify_lv:setText("+"..equip.level)

    --装备于谁
    if equip.equip ~= nil and equip.equip ~= 0 then 
        local role = CardRoleManager:getRoleById(equip.equip)
        if role then
            self.txt_equiped_name:setVisible(true)
            self.img_equiped:setVisible(true)
            self.txt_equiped_name:setText(role.name)
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

--[[
        self.icon_gembg[i]  = TFDirector:getChildByPath(img_greyNode, "img_gembg_"..i)
        self.icon_gem[i]   = TFDirector:getChildByPath(img_greyNode, "img_gem_"..i)
]]
    for i=1,EquipmentManager.kGemMergeTargetNum do
        if equip:getGemPos(i) then
            self.icon_gembg[i]:setVisible(true)
            self.icon_gem[i]:setVisible(true)
            local item = ItemData:objectByID(equip:getGemPos(i))
            if item then
                self.icon_gembg[i]:setTexture(item:GetPath())
                self.icon_gem[i]:setTexture(item:GetPath())
            end
        else
            self.icon_gembg[i]:setVisible(false)
            self.icon_gem[i]:setVisible(false)
        end
    end
end

--刷新详细信息
function EquipDetailsDialog:refreshDetails()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    --装备属性详情
    self.panel_details      = TFDirector:getChildByPath(ui, "panel_details")
    --基础属性
    local baseAttr = equip:getBaseAttribute():getAttribute()
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttr[i] then
            self.txt_attr_base:setText(AttributeTypeStr[i])
            self.txt_attr_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
        end
    end

    --附加属性
    local extraAttr,indexTable = equip:getExtraAttribute():getAttribute()
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

--[[
 self.txt_gem_name[i]  = TFDirector:getChildByPath(img_infoNode, "txt_gem_name"..i)
        self.img_gembg[i]  = TFDirector:getChildByPath(img_infoNode, "img_gembg_"..i)
        self.img_gem[i]   = TFDirector:getChildByPath(img_infoNode, "img_gem_"..i)
        self.icon_gembg[i]  = TFDirector:getChildByPath(img_greyNode, "img_gembg_"..i)
        self.icon_gem[i]   = TFDirector:getChildByPath(img_greyNode, "img_gem_"..i)
]]
    --宝石
    for i=1,EquipmentManager.kGemMergeTargetNum do
        if equip:getGemPos(i) then
            local item = ItemData:objectByID(equip:getGemPos(i))
            if item then
                self.txt_gem_name[i]:setVisible(true)
                --self.txt_attr_gem:setVisible(true)
                --self.txt_attr_gem_val:setVisible(true)
                local gem = GemData:objectByID(equip:getGemPos(i))
                if gem then
                    local attributekind , attributenum = gem:getAttribute()
                    self.txt_gem_name[i]:setText(item.name .. ": +" .. covertToDisplayValue(attributekind,attributenum))
                    --self.txt_attr_gem:setText(AttributeTypeStr[attributekind])
                    --self.txt_attr_gem_val:setText("+ " .. covertToDisplayValue(attributekind,attributenum))
                end
            else
                self.txt_gem_name[i]:setVisible(false)
                --self.txt_attr_gem:setVisible(false)
                --self.txt_attr_gem_val:setVisible(false)
            end
        else
            self.txt_gem_name[i]:setVisible(false)
            --self.txt_attr_gem:setVisible(false)
            --self.txt_attr_gem_val:setVisible(false)
        end
    end

    --总战斗力
    self.txt_power_details:setText(equip:getpower())
    self.txt_info:setText(equip.describe2)
end

function EquipDetailsDialog:registerEvents()
	self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    self.GotoEquipClickHandle = function(event)
        local topPowerRole = StrategyManager:getTopPowerRole()
        CardRoleManager:openRoleInfo(topPowerRole.gmId,function() AlertManager:close() end)
    end
    self.btn_equip:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GotoEquipClickHandle),1)

    self.GotoQiangHuaClickHandle = function(event)
        EquipmentManager:openSmithyLayer(self.gmId,self.equipList,self.equipType,self.allList,function() AlertManager:close() end)
    end
    self.btn_qianghua:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GotoQiangHuaClickHandle),1)

    self.EquipUpdateCallBack = function (event)
        if event.data[1].equip then
            if self.gmid == event.data[1].equip.gmId then
                self:refreshUI()
            end
        end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIP_OPERATION,  self.EquipUpdateCallBack)
    TFDirector:addMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION ,  self.EquipUpdateCallBack) 
    self.GemMosaicResuleCallBack = function(event)
        if self.gmid == event.data[1].userid then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.GemMosaicResuleCallBack)
    self.EquipmentIntensifyResultCallBack = function (event)
        if self.gmid == event.data[1].gmid then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.EquipmentIntensifyResultCallBack)
    self.GemUnMosaicResuleCallBack = function(event)
        if self.gmid == event.data[1].userid then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.GemUnMosaicResuleCallBack)
end

function EquipDetailsDialog:removeEvents()
    TFDirector:removeMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.GemMosaicResuleCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.GemUnMosaicResuleCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_OPERATION, self.EquipUpdateCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION, self.EquipUpdateCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.EquipmentIntensifyResultCallBack)
    self.super.removeEvents(self)
end

function EquipDetailsDialog:getIconCenterWorldPos()
    local _parent = self.img_icon:getParent()
    local pos = _parent:convertToWorldSpaceAR(self.img_icon:getPosition())
    return pos
end

function EquipDetailsDialog:getPowerWorldPos()
    local _parent = self.txt_power_details:getParent()
    local pos = _parent:convertToWorldSpaceAR(self.txt_power_details:getPosition())
    return pos
end

return EquipDetailsDialog
