--[[
******铁匠铺装备宝石镶嵌详情*******

    -- by david.dai
    -- 2014/06/27
]]

local MosaicGemPanel = class("MosaicGemPanel", BaseLayer)

function MosaicGemPanel:ctor(gmId)
    self.super.ctor(self,gmId)
    self.gmId = gmId
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    self.selectPos = 1
    if equip and equip:getTotalGemNum() <= 1 then
        self.selectPos = 1
    end
    self:init("lua.uiconfig_mango_new.smithy.MosaicGemPanel")
end

function MosaicGemPanel:initUI(ui)
    self.super.initUI(self,ui)

    --装备图标信息区
    self.img_quality        = TFDirector:getChildByPath(ui, 'img_quality')
    self.img_icon           = TFDirector:getChildByPath(ui, 'img_icon')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.lbl_power          = TFDirector:getChildByPath(ui, 'lbl_power')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
    self.txt_intensify_lv   = TFDirector:getChildByPath(ui, 'txt_intensify_lv')

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
    -- self.txt_attr_base      = TFDirector:getChildByPath(ui, "txt_attr_base")
    -- self.txt_attr_base_val  = TFDirector:getChildByPath(ui, "txt_attr_base_val")
    --附加属性
    -- self.txt_attr_extra     = {}
    -- self.txt_attr_extra_val = {}
    -- for i = 1,EquipmentManager.kMaxExtraAttributeSize do
    --     self.txt_attr_extra[i]          = TFDirector:getChildByPath(ui, "txt_attr_extra_" .. i)
    --     self.txt_attr_extra_val[i]      = TFDirector:getChildByPath(ui, "txt_attr_extra_val_" .. i)
    -- end
    --宝石
    self.img_gem = {}
    self.img_gemLock = {}
    self.txt_gem_name = {}
    self.txt_attr_gem = {}
    self.imgGemNode = {}
    self.txt_attr_gem_val = {}
    self.icon_xuanzhong = {}
    for i=1,EquipmentManager.kGemMergeTargetNum do
        local imgGemNode = TFDirector:getChildByPath(ui, 'img_background'..i)
        self.imgGemNode[i] = TFDirector:getChildByPath(ui, 'img_background'..i)
        self.img_gem[i]            = TFDirector:getChildByPath(imgGemNode, 'img_gem')
        self.img_gemLock[i]          = TFDirector:getChildByPath(imgGemNode, 'icon_suo')
        local gemNameNode = TFDirector:getChildByPath(ui, "txt_gem_name"..i)      
        self.txt_gem_name[i]       = TFDirector:getChildByPath(ui, "txt_gem_name"..i)        
        self.txt_attr_gem[i]                   = TFDirector:getChildByPath(gemNameNode, "txt_attr_gem"..i)
        self.txt_attr_gem_val[i]               = TFDirector:getChildByPath(gemNameNode, "txt_attr_gem_val"..i)

        self.imgGemNode[i].logic      = self
        self.imgGemNode[i]:setTouchEnabled(true)

        self.icon_xuanzhong[i] = TFDirector:getChildByPath(imgGemNode, "icon_xuanzhong")
    end
    --总战斗力
    self.txt_power_details                      = TFDirector:getChildByPath(ui, "txt_power_details")

end

function MosaicGemPanel:removeUI()
    self.super.removeUI(self)
end

function MosaicGemPanel:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function MosaicGemPanel:setLogic( layer )
    self.logic = layer
end

function MosaicGemPanel:setEquipGmId(gmId)
    self.gmId   = gmId  
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip and equip:getTotalGemNum() <= 1 then
        self.selectPos = 1
    end  
    self:refreshUI()
end

function MosaicGemPanel:dispose()
    self.super.dispose(self)
end
    
--刷新显示方法
function MosaicGemPanel:refreshUI()
    self:refreshIcon()
    self:refreshDetails()
end

--刷新图标区信息
function MosaicGemPanel:refreshIcon()
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
    self.txt_power:setText("D"..equip:getpower())

    self.txt_intensify_lv:setText("+"..equip.level)

    --装备于谁
    if equip.equip ~= nil and equip.equip ~= 0 then 
        local role = CardRoleManager:getRoleById(equip.equip)
        if role then
            self.txt_equiped_name:setVisible(true)
            self.img_equiped:setVisible(true)
            -- self.txt_equiped_name:setText(role.name)
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
        local item = ItemData:objectByID(equip:getGemPos(i))
        if item then
            self.img_gem[i]:setTexture(item:GetPath())
            self.img_gem[i]:setVisible(true)
        else
            self.img_gem[i]:setVisible(false)
        end
    end
    self.img_gemLock[1]:setVisible(false)
    self.img_gemLock[2]:setVisible(true)
    if equip:getTotalGemNum() > 1 then
        self.img_gemLock[2]:setVisible(false)
    end

    for i=1,EquipmentManager.kGemMergeTargetNum do
        if self.selectPos == i then
            self.icon_xuanzhong[i]:setVisible(true)
        else
            self.icon_xuanzhong[i]:setVisible(false)
        end
    end
   

    --[[
for i=1,EquipmentManager.kGemMergeTargetNum do
        local imgGemNode = TFDirector:getChildByPath(ui, 'img_background'..i)
        self.img_gem[i]            = TFDirector:getChildByPath(imgGemNode, 'img_gem')
        self.img_gemLock[i]          = TFDirector:getChildByPath(imgGemNode, 'icon_suo')
        local gemNameNode = TFDirector:getChildByPath(ui, "txt_gem_name"..i)      
        self.txt_gem_name[i]       = TFDirector:getChildByPath(ui, "txt_gem_name"..i)        
        self.txt_attr_gem[i]                   = TFDirector:getChildByPath(gemNameNode, "txt_attr_gem"..i)
        self.txt_attr_gem_val[i]               = TFDirector:getChildByPath(gemNameNode, "txt_attr_gem_val"..i)
    end
    ]]
end

--刷新详细信息
function MosaicGemPanel:refreshDetails()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    --装备属性详情
    -- self.panel_details      = TFDirector:getChildByPath(ui, "panel_details")
    --基础属性
    -- local baseAttr = equip:getBaseAttribute():getAttribute()
    -- for i=1,(EnumAttributeType.Max-1) do
    --     if baseAttr[i] then
    --         self.txt_attr_base:setText(AttributeTypeStr[i])
    --         self.txt_attr_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))
    --     end
    -- end

    --附加属性
    -- local extraAttr = equip:getExtraAttribute():getAttribute()
    -- local notEmptyIndex = 1
    -- for i=1,(EnumAttributeType.Max-1) do
    --     if extraAttr[i] then
    --         self.txt_attr_extra[notEmptyIndex]:setVisible(true)
    --         self.txt_attr_extra_val[notEmptyIndex]:setVisible(true)
    --         self.txt_attr_extra[notEmptyIndex]:setText(AttributeTypeStr[i])
    --         self.txt_attr_extra_val[notEmptyIndex]:setText("+ " .. covertToDisplayValue(i,extraAttr[i]))
    --         notEmptyIndex = notEmptyIndex + 1
    --     end
    -- end
    --检测是否附加属性不足3条
    -- for i = notEmptyIndex,EquipmentManager.kMaxExtraAttributeSize do
    --     self.txt_attr_extra[i]:setVisible(false)
    --     self.txt_attr_extra_val[i]:setVisible(false)
    -- end

    --宝石
    --[[
self.txt_gem_name[i]:setVisible(true)    
            self.txt_gem_name[i]
            self.txt_attr_gem[i]                   = TFDirector:getChildByPath(gemNameNode, "txt_attr_gem"..i)
            self.txt_attr_gem_val[i] 
    ]]
    for i=1,EquipmentManager.kGemMergeTargetNum do
        local item = ItemData:objectByID(equip:getGemPos(i))
        if item then
            self.txt_gem_name[i]:setVisible(true)           
            local gem = GemData:objectByID(equip:getGemPos(i))
            if gem then
                self.txt_gem_name[i]:setText(item.name)
                local attributekind , attributenum = gem:getAttribute()
                self.txt_attr_gem[i]:setText(AttributeTypeStr[attributekind])
                self.txt_attr_gem_val[i]:setText("+ " .. covertToDisplayValue(attributekind,attributenum))            
            else
                self.txt_gem_name[i]:setVisible(false)                
            end
        else
            self.txt_gem_name[i]:setVisible(false)            
        end
    end

    --总战斗力
    self.txt_power_details:setText(equip:getpower())
end

function MosaicGemPanel.unGemMosaicBtnClickHandle(btn)
    local self = btn.logic
    local idx = btn.idx    
    print('unGemMosaicBtnClickHandle = ',idx)

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip then
        if equip:getTotalGemNum() >= idx then
            self.selectPos = idx
            TFDirector:dispatchGlobalEventWith(EquipmentManager.SELECT_GEM_POS,{})
        else
            toastMessage(localizable.Recast_Gems)
        end
    end
    for i=1,EquipmentManager.kGemMergeTargetNum do
        if self.selectPos == i then
            self.icon_xuanzhong[i]:setVisible(true)
        else
            self.icon_xuanzhong[i]:setVisible(false)
        end
    end

    -- if self then
    --     local equip = EquipmentManager:getEquipByGmid(self.gmId)
    --     if equip == nil  then
    --         print("equipment not found .",self.gmId)
    --         return false
    --     end
    --     if equip:getGemPos(idx) then
    --         EquipmentManager:GemUnMosaic(self.gmId , idx )
    --     else
    --         toastMessage("没有镶嵌宝石")
    --     end
    -- end
end

function MosaicGemPanel:registerEvents()
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
    for i=1,EquipmentManager.kGemMergeTargetNum do
        self.imgGemNode[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.unGemMosaicBtnClickHandle),1)
        self.imgGemNode[i].idx = i
    end
end

function MosaicGemPanel:removeEvents()
    --TFDirector:removeMEGlobalListener(EquipmentManager.GEM_MOSAIC_RESULT,self.GemMosaicResuleCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.GEM_UN_MOSAIC_RESULT,self.GemUnMosaicResuleCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_OPERATION, self.EquipUpdateCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION, self.EquipUpdateCallBack)
    --TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.EquipmentIntensifyResultCallBack)
    for i=1,EquipmentManager.kGemMergeTargetNum do
        self.imgGemNode[i]:removeMEListener(TFWIDGET_CLICK)
    end
    self.super.removeEvents(self)
end

function MosaicGemPanel:getSelectPos()
    return self.selectPos
end

function MosaicGemPanel:getGemPositionByPos(pos)
    --return self.selectPos
end

return MosaicGemPanel