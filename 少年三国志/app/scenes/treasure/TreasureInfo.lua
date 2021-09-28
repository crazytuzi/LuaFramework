

local TreasureInfo = class("TreasureInfo", UFCCSModelLayer)

local MergeEquipment = require("app.data.MergeEquipment")
local EquipmentConst = require("app.const.EquipmentConst")
local funLevelConst = require("app.const.FunctionLevelConst")
local BagConst = require("app.const.BagConst")
local Colors = require("app.setting.Colors")
local EffectNode = require "app.common.effects.EffectNode"
require "app.cfg.equipment_suit_info"
require "app.cfg.equipment_info"

function TreasureInfo:ctor( ... )
	self._equipment = nil
    self._slotInfo = nil 
	self.super.ctor(self, ...)

	self:adapterWithScreen()

	self:registerBtnClickEvent("Button_back", function ( widget )
		self:close()
	end)
	self:registerBtnClickEvent("Button_xiexia", function ( widget )
                    
		G_HandlersManager.fightResourcesHandler:sendClearFightTreasure( self._slotInfo.teamId , self._slotInfo.pos, self._slotInfo.slot)

       
		self:close()
	end)
	self:registerBtnClickEvent("Button_strength", function ( widget )

        if require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.StrengthMode) then
            self:close()
        end
		
	end)
	self:registerBtnClickEvent("Button_jinglian", function ( widget )
      

        if require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.RefineMode)  then
            self:close()
        end

	end)

    self:registerBtnClickEvent("Button_Forge", function ( widget )
        if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_FORGE) then
            if require("app.scenes.treasure.TreasureDevelopeScene").show(self._equipment, EquipmentConst.ForgeMode) then
                self:close()
            end
        end
    end)

    self:attachImageTextForBtn("Button_strength","Image_strtxt")
    self:attachImageTextForBtn("Button_jinglian","Image_reftxt")
end

function TreasureInfo:onLayerEnter( )
    --self:closeAtReturn(true)
    self:registerKeypadEvent(true, false)
end

function TreasureInfo:onBackKeyEvent( ... )
    self:close()
    return true
end

function TreasureInfo:initTreasureWithEquip( equipment, style, slotInfo )
	self._equipment = equipment


    if style == 1 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "", 0, 0)
        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 10, 10)

        self:getPanelByName("Panel_btns1"):setVisible(false)
    elseif style== 2 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "Panel_btns1", 0, -15)
        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 95, 10)

        self:getPanelByName("Panel_btns1"):setVisible(true)
        self._slotInfo = slotInfo

        if slotInfo.flag then 
            local around = nil
            around = EffectNode.new("effect_around1", 
                function(event)
                    if event == "finish" and around then 
                        around:removeFromParentAndCleanup(true)
                        around = nil
                    end
            end)
            around:setScaleX(3.4)

            local changeBtn = self:getWidgetByName("Button_genghuan")
            if changeBtn then 
                changeBtn:addNode(around)
                around:setPositionXY(5, 0)
                around:play()
            end
        end
        self:showWidgetByName("Image_tip", false)
    end

    self:registerBtnClickEvent("Button_genghuan", function ( widget )
        if slotInfo and slotInfo.teamId and slotInfo.pos and slotInfo.slot then
            local equiplist = G_Me.bagData:getTreasureListByType( slotInfo.slot )
            local equipWearOn = G_Me.formationData:getFightTreasureList(slotInfo.slot)
            local unWearEquip = 0
            for key, value in pairs(equiplist) do 
                if value and not equipWearOn[value["id"]] then
                    unWearEquip = unWearEquip + 1
                end
            end

            if unWearEquip == 0 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_NO_TREASURE"))
                return 
            else
                local equipSelectLayer = require("app.scenes.common.EquipSelectLayer")
                local equiplist = G_Me.bagData:getTreasureListByType( slotInfo.slot )
                local knightId, index = G_Me.formationData:getWearTreasureKnightId(equipment.id)
                equipSelectLayer.showEquipSelectLayer(uf_notifyLayer:getModelNode(), index, slotInfo.slot + 4, equiplist, function ( equipId )
                    G_HandlersManager.fightResourcesHandler:sendAddFightTreasure( slotInfo.teamId, slotInfo.pos, slotInfo.slot, equipId)
                end)
            end
        end
        self:close()
    end) 
    
   
    local info = equipment and equipment:getInfo()
    if info and info.type == 3 then 
        -- 经验宝物
        self:_updateTop()
        self:_updateDesc()
        self:getPanelByName("Panel_attr"):setVisible(false)
        self:getPanelByName("Panel_desc"):setPosition(ccp(5,330))
    else
        self:_updateCommonAttrs()
        self:getPanelByName("Panel_attr"):setVisible(true)
    end
    
    self._skillHeight = self:setSkill()
    self:adapterInfo()


    -- 非橙色宝物和经验宝物不显示“铸造”按钮
    -- 橙色宝物，到了可预览等级时显示“铸造”按钮
    local isExpTreasure = info and info.type == 3
    local isOrangeTreasure = info and info.quality == BagConst.QUALITY_TYPE.ORANGE
    local canPreview = G_moduleUnlock:canPreviewModule(funLevelConst.TREASURE_FORGE)
    self:showWidgetByName("Button_Forge", not isExpTreasure and isOrangeTreasure and canPreview)
end



--style 取值
-- 1 显示强化 ,精炼
-- 2 显示强化,精炼, 卸下, 更换 , 此时slotInfo必须有值为: {teamId=, slot=, pos=}
function TreasureInfo.showTreasureInfo( equipment, style, slotInfo)
   
	local equipDesc = require("app.scenes.treasure.TreasureInfo").new("ui_layout/treasure_TreasureInfo.json", Colors.modelColor)
	uf_notifyLayer:getModelNode():addChild(equipDesc)
	equipDesc:initTreasureWithEquip(equipment, style, slotInfo)

    
    
    return equipDesc
end


function TreasureInfo:adapterInfo()
    local height = 5
    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5
    if self._skillHeight > 0 then
        panel = self:getPanelByName("Panel_skill")
        panel:setVisible(true)
        panel:setPosition(ccp(0,height))
        height = height + panel:getSize().height + 5
    else
        panel = self:getPanelByName("Panel_skill")
        panel:setVisible(false)
    end
    local info = self._equipment and self._equipment:getInfo()
    if info and info.type == 3 then 
        panel = self:getPanelByName("Panel_attr")
        panel:setVisible(false)
    else
        panel = self:getPanelByName("Panel_attr")
        panel:setPosition(ccp(0,height))
        height = height + panel:getSize().height + 5
        panel:setVisible(true)
    end

    height = height - 5
    local content = self:getPanelByName("Panel_scrollContent")
    content:setContentSize(CCSizeMake(scrollSize.width,height))
    local scrollHeight = scrollView:getContentSize().height
    if height < scrollHeight then
        content:setPosition(ccp(0,scrollHeight-height))
        scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, scrollHeight))
    else
        scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, height))
    end

end


-- 更新通用的属性, 名字啊, star啥的
function TreasureInfo:_updateCommonAttrs()
    local info = self._equipment:getInfo()
    
    self:_updateTop()
    
    ------------------属性部分
    ----强化
    self:getLabelByName("Label_attr1_title"):setText( G_lang:get("LANG_QIANGHUA_SHUXING")  )
    self:getLabelByName("Label_attr1_title"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_attr1_slot1_title"):setText( G_lang:get("LANG_QIANGHUA_DENGJI")..  G_lang:get("LANG_MAOHAO") )
    self:getLabelByName("Label_attr1_slot1_value"):setText( self._equipment.level .. "/" .. self._equipment:getMaxStrengthLevel() )
    -- self:getLabelByName("Label_attr1_slot1_title"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_attr1_slot1_value"):createStroke(Colors.strokeBrown, 1)

    local attrs = self._equipment:getStrengthAttrs(self._equipment.level)
    TreasureInfo.setAttrLabels(self, attrs,{"Label_attr1_slot2_title", "Label_attr1_slot2_value", "Label_attr1_slot3_title", "Label_attr1_slot3_value"})

    --精炼
    self:getLabelByName("Label_attr2_title"):setText( G_lang:get("LANG_JINGLIAN_SHUXING")  )
    self:getLabelByName("Label_attr2_title"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_attr2_slot1_title"):setText( G_lang:get("LANG_JINGLIAN_JIESHU")..  G_lang:get("LANG_MAOHAO") )
    self:getLabelByName("Label_attr2_slot1_value"):setText( self._equipment.refining_level .. "/" .. self._equipment:getMaxRefineLevel() )
    -- self:getLabelByName("Label_attr2_slot1_title"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_attr2_slot1_value"):createStroke(Colors.strokeBrown, 1)

    local attrsRefine = self._equipment:getRefineAttrs(self._equipment.refining_level)
    TreasureInfo.setAttrLabels(self, attrsRefine, {"Label_attr2_slot2_title", "Label_attr2_slot2_value", "Label_attr2_slot3_title", "Label_attr2_slot3_value"})

    -- local funLevelConst = require("app.const.FunctionLevelConst")
    -- local StrUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_STRENGTH)
    -- local RefUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_TRAINING)

    -- self:enableWidgetByName("Button_strength", StrUnlock and self._equipment:getInfo().type ~= 3 and self._equipment:getMaxStrengthLevel() > self._equipment.level)
    -- self:enableWidgetByName("Button_jinglian", RefUnlock and self._equipment:getInfo().type ~= 3 and self._equipment:getMaxRefineLevel() > self._equipment.refining_level)

    self:_updateDesc()
   
end

function TreasureInfo:_updateTop()
    local info = self._equipment:getInfo()
    ---------------顶部部分
    --名字
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 2)
    --颜色图片
    self:getImageViewByName("ImageView_color"):loadTexture(G_Path.getEquipmentColorImage(info.quality))

    --资质
    --self:getLabelBMFontByName("LabelBMFont_zizhi"):setText( info.potentiality )
    self:getLabelByName("Label_zizhi"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_zizhi"):setText( G_lang:get("LANG_ZIZHI_VALUE", {zizhi=info.potentiality}) )
    self:getLabelByName("Label_zizhi"):createStroke(Colors.strokeBrown, 1)

    --大图
    self:getImageViewByName("ImageView_pic"):loadTexture(self._equipment:getPic())

    --类型文字图片    
    self:getImageViewByName("ImageView_type"):loadTexture(self._equipment:getTypeImagePath() )
end

function TreasureInfo:_updateDesc()
    local info = self._equipment:getInfo()
    ----------------描述部分
    self:getLabelByName("Label_desc_txt"):setText( G_lang:get("LANG_MIAOSU") )
    self:getLabelByName("Label_desc_txt"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_desc_content"):setText( info.directions )
    -- self:getLabelByName("Label_desc_content"):createStroke(Colors.strokeBrown, 1)
end

--给所有的属性label赋值, 还要设置隐藏和显示.
--labels 包含 4个元素, 第一个属性名字,第一个属性值, 第2个属性名字,第2个属性值
function TreasureInfo.setAttrLabels(container, attrs, labels)

    container:showWidgetByName(labels[1], false)
    container:showWidgetByName(labels[2], false)
    container:showWidgetByName(labels[3], false)
    container:showWidgetByName(labels[4], false)

    if #attrs >= 2 then
        container:showWidgetByName(labels[3], true)
        container:showWidgetByName(labels[4], true)
        container:getLabelByName(labels[3]):setText(attrs[2].typeString)
        container:getLabelByName(labels[4]):setText("+" ..  attrs[2].valueString)
        -- container:getLabelByName(labels[3]):createStroke(Colors.strokeBrown, 1)
        -- container:getLabelByName(labels[4]):createStroke(Colors.strokeBrown, 1)
    end


    if #attrs >= 1 then
        container:showWidgetByName(labels[1], true)
        container:showWidgetByName(labels[2], true)
        container:getLabelByName(labels[1]):setText(attrs[1].typeString)
        container:getLabelByName(labels[2]):setText("+" ..  attrs[1].valueString)
        -- container:getLabelByName(labels[1]):createStroke(Colors.strokeBrown, 1)
        -- container:getLabelByName(labels[2]):createStroke(Colors.strokeBrown, 1)

    end
end

function TreasureInfo:setSkill( )
    local skillTitle = self:getLabelByName("Label_skill_txt")
    skillTitle:setText(G_lang:get("LANG_SKILL_SHENBING"))
    skillTitle:createStroke(Colors.strokeBrown, 2)
    local panel = self:getPanelByName("Panel_skill")
    local height = MergeEquipment.initSkill(self._equipment:getInfo(),self._equipment.refining_level,panel,self:getImageViewByName("ImageView_skill"))
    return height
end

return TreasureInfo
