

local EquipmentInfo = class("EquipmentInfo", UFCCSModelLayer)

local MergeEquipment = require("app.data.MergeEquipment")
local EquipmentConst = require("app.const.EquipmentConst")
local Colors = require("app.setting.Colors")
local EffectNode = require "app.common.effects.EffectNode"

require "app.cfg.equipment_suit_info"
require "app.cfg.equipment_info"

function EquipmentInfo:ctor( ... )
	self._equipment = nil
    self._slotInfo = nil 
	self.super.ctor(self, ...)

	self:adapterWithScreen()

	self:registerBtnClickEvent("Button_back", function ( widget )
		self:close()
	end)
	self:registerBtnClickEvent("Button_xiexia", function ( widget )
        G_HandlersManager.fightResourcesHandler:sendClearFightEquipment( self._slotInfo.teamId , self._slotInfo.pos, self._slotInfo.slot)

		
		self:close()
	end)
	self:registerBtnClickEvent("Button_strength", function ( widget )

        if require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.StrengthMode) then
            self:close()
        end
		
	end)
	self:registerBtnClickEvent("Button_jinglian", function ( widget )
      

        if require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.RefineMode)  then
            self:close()
        end

	end)

    self:registerBtnClickEvent("Button_shengxing", function ( widget )
      

        if require("app.scenes.equipment.EquipmentDevelopeScene").show(self._equipment, EquipmentConst.StarMode)  then
            self:close()
        end

    end)

    self:attachImageTextForBtn("Button_strength","Image_strtxt")
    self:attachImageTextForBtn("Button_jinglian","Image_reftxt")
    self:attachImageTextForBtn("Button_shengxing","Image_startxtt")
    
end

function EquipmentInfo:onLayerEnter( )
    self:registerKeypadEvent(true, false)
end

function EquipmentInfo:onBackKeyEvent( ... )
    self:close()
    return true
end

function EquipmentInfo:__prepareDataForGuide__( param )
    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    if scrollView then 
        scrollView:setScrollEnable(false)
    end
end

function EquipmentInfo:initEquipmentWithEquip( equipment, style, slotInfo )
	self._equipment = equipment


    if style == 1 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "", 0, 0)
       self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 10, 10)

        self:getPanelByName("Panel_btns1"):setVisible(false)
    elseif style== 2 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "Panel_btns1", 0, -25)

        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 85, 30)


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
        --self:showWidgetByName("Image_tip", slotInfo.flag)
    end

    self:registerBtnClickEvent("Button_genghuan", function ( widget )
        if slotInfo and slotInfo.teamId and slotInfo.pos and slotInfo.slot then
            local equiplist = G_Me.bagData:getEquipmentListByType( slotInfo.slot )
            local equipWearOn = G_Me.formationData:getFightEquipmentList(slotInfo.slot)
            local unWearEquip = 0
            for key, value in pairs(equiplist) do 
                if value and not equipWearOn[value["id"]] then
                    unWearEquip = unWearEquip + 1
                end
            end

            if unWearEquip == 0 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_NO_EQUIP"))
                return 
            else
                local equipSelectLayer = require("app.scenes.common.EquipSelectLayer")
                --local equiplist = G_Me.bagData:getEquipmentListByType( slotInfo.slot )
                local knightId, index = G_Me.formationData:getWearEquipmentKnightId(equipment.id)
                equipSelectLayer.showEquipSelectLayer(uf_notifyLayer:getModelNode(), index, slotInfo.slot, equiplist, function ( equipId )
                    G_HandlersManager.fightResourcesHandler:sendAddFightEquipment( slotInfo.teamId, slotInfo.pos, slotInfo.slot, equipId)
                end)
            end
        end
        self:close()
    end) 
    

    self:_updateCommonAttrs()
end



--style 取值
-- 1 显示强化 ,精炼
-- 2 显示强化,精炼, 卸下, 更换 , 此时slotInfo必须有值为: {teamId=, slot=, pos=}
function EquipmentInfo.showEquipmentInfo( equipment, style, slotInfo, flag)


	local equipDesc = require("app.scenes.equipment.EquipmentInfo").new("ui_layout/equipment_EquipmentInfo.json", Colors.modelColor)
	-- uf_notifyLayer:getModelNode():addChild(equipDesc)
    uf_sceneManager:getCurScene():addChild(equipDesc)
	equipDesc:initEquipmentWithEquip(equipment, style, slotInfo)


    
    
    return equipDesc
end




-- 更新通用的属性, 名字啊, star啥的
function EquipmentInfo:_updateCommonAttrs()
    local info = self._equipment:getInfo()
    
    ---------------顶部部分
    --名字
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 2)
    
    --颜色图片
    self:getImageViewByName("Image_color"):loadTexture(G_Path.getEquipmentColorImage(info.quality))

    --资质
    --self:getLabelBMFontByName("LabelBMFont_zizhi"):setText( info.potentiality )
    self:getLabelByName("Label_zizhi"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_zizhi"):setText( G_lang:get("LANG_ZIZHI_VALUE", {zizhi=info.potentiality}) )
    self:getLabelByName("Label_zizhi"):createStroke(Colors.strokeBrown, 1)

    --大图
    self:getImageViewByName("ImageView_pic"):loadTexture(self._equipment:getPic())

    --类型文字图片    
    self:getImageViewByName("ImageView_type"):loadTexture(self._equipment:getTypeImagePath() )
    
    ------------------属性部分
    ----强化
    self:getLabelByName("Label_attr1_title"):setText( G_lang:get("LANG_QIANGHUA_SHUXING")  )
    self:getLabelByName("Label_attr1_slot1_title"):setText( G_lang:get("LANG_QIANGHUA_DENGJI")..  G_lang:get("LANG_MAOHAO") )
    self:getLabelByName("Label_attr1_slot1_value"):setText( self._equipment.level .. "/" .. self._equipment:getMaxStrengthLevel() )
    self:getLabelByName("Label_attr1_title"):createStroke(Colors.strokeBrown, 2)
    -- self:getLabelByName("Label_attr1_slot1_title"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_attr1_slot1_value"):createStroke(Colors.strokeBrown, 1)

    local attrs = self._equipment:getStrengthAttrs(self._equipment.level)
    EquipmentInfo.setAttrLabels(self, attrs,{"Label_attr1_slot2_title", "Label_attr1_slot2_value", "Label_attr1_slot3_title", "Label_attr1_slot3_value"})

    --精炼
    self:getLabelByName("Label_attr2_title"):setText( G_lang:get("LANG_JINGLIAN_SHUXING")  )
    self:getLabelByName("Label_attr2_slot1_title"):setText( G_lang:get("LANG_JINGLIAN_JIESHU")..  G_lang:get("LANG_MAOHAO") )
    self:getLabelByName("Label_attr2_slot1_value"):setText( self._equipment.refining_level .. "/" .. self._equipment:getMaxRefineLevel() )
    self:getLabelByName("Label_attr2_title"):createStroke(Colors.strokeBrown, 2)
    -- self:getLabelByName("Label_attr2_slot1_title"):createStroke(Colors.strokeBrown, 1)
    -- self:getLabelByName("Label_attr2_slot1_value"):createStroke(Colors.strokeBrown, 1)

    --升星
    self:getLabelByName("Label_attr_star_title"):setText( G_lang:get("LANG_STAR_SHUXING")  )
    self:getLabelByName("Label_attr_star_title"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_attr_star_slot1_title"):setText( G_lang:get("LANG_STAR_JIESHU")..  G_lang:get("LANG_MAOHAO") )

    local maxLevel = self._equipment:getMaxStarLevel()
    for i = 1, EquipmentConst.Star_MAX_LEVEL do
        self:getImageViewByName("Image_start_" .. i):setVisible(i <= maxLevel)
    end

    local EquipmentConst = require("app.const.EquipmentConst")
    local starLevel = self._equipment.star
    if starLevel then
        for i = 1, EquipmentConst.Star_MAX_LEVEL do
            self:getImageViewByName(string.format("Image_start_%d_full", i)):setVisible(i <= starLevel)
        end
    end

    local attrsStar = self._equipment:getStarAttrs()
    EquipmentInfo.setAttrLabels(self, attrsStar, {"Label_attr_star_slot2_title", "Label_attr_star_slot2_value"})

    local attrsRefine = self._equipment:getRefineAttrs(self._equipment.refining_level)
    EquipmentInfo.setAttrLabels(self, attrsRefine, {"Label_attr2_slot2_title", "Label_attr2_slot2_value", "Label_attr2_slot3_title", "Label_attr2_slot3_value"})

    if info.potentiality < EquipmentConst.Star_Potentiality_Min_Value then
        self:getButtonByName("Button_shengxing"):setTouchEnabled(false)
    end
    -- local funLevelConst = require("app.const.FunctionLevelConst")
    -- local StrUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_STRENGTH)
    -- local RefUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING)

    -- self:enableWidgetByName("Button_strength", StrUnlock and self._equipment:getMaxStrengthLevel() > self._equipment.level)
    -- self:enableWidgetByName("Button_jinglian", RefUnlock and self._equipment:getMaxRefineLevel() > self._equipment.refining_level)

    ----------------描述部分
    self:getLabelByName("Label_desc_txt"):setText( G_lang:get("LANG_MIAOSU") )
    self:getLabelByName("Label_desc_txt"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_desc_content"):setText( info.directions )
    
    -- self:getLabelByName("Label_desc_content"):createStroke(Colors.strokeBrown, 1)
    

    -----------------套装

    EquipmentInfo.setSuitPanel(self, info,self._equipment)

    self._skillHeight = self:setSkill()
    self:adapterInfo()

    -- 紫装及以下隐藏掉升星属性
    local baseInfo = self._equipment:getInfo()
    local EquipmentConst = require("app.const.EquipmentConst")
    if baseInfo.potentiality < EquipmentConst.Star_Potentiality_Min_Value then

        -- 隐藏升星属性UI
        local attrStarPanel = self:getPanelByName("Panel_attr_star")
        attrStarPanel:setVisible(false)
        local height = attrStarPanel:getContentSize().height

        -- 其他属性下移
        local attrsPanel = self:getPanelByName("Panel_attr")
        local Y = attrsPanel:getPositionY()
        attrsPanel:setPositionY(Y - height)

        -- 面板所有信息上移
        local scrollView = self:getScrollViewByName("ScrollView_scroll")
        local scrollSize = scrollView:getInnerContainerSize()
        scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, scrollSize.height - height))
    end

end

function EquipmentInfo:adapterInfo()
    local height = 5
    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5
    panel = self:getPanelByName("Panel_suite")
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
    panel = self:getPanelByName("Panel_attr")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5

    height = height - 5
    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, height))
    self:getPanelByName("Panel_scrollContent"):setContentSize(CCSizeMake(scrollSize.width,height))
end

--设置套装小面板的显示, 因为在其他地方也要设置,写一个统一函数设置
function EquipmentInfo.setSuitPanel(self, info,equipment)
    self:getLabelByName("Label_suite_txt"):setText( G_lang:get("LANG_TAOZHUANG") )
    self:getLabelByName("Label_suite_txt"):createStroke(Colors.strokeBrown,2)
    --todo: 是否所有装备都是套装?
    if info.suit_id ~= nil and info.suit_id ~= 0 then
        
        self:getPanelByName("Panel_suite"):setVisible(true)

        local suiteInfo = equipment_suit_info.get(info.suit_id)
        self:getLabelByName("Label_suite_name"):setColor(Colors.qualityColors[equipment_info.get(suiteInfo["equipment_id_1"]).quality] )
        self:getLabelByName("Label_suite_name"):setText(suiteInfo.name )
        self:getLabelByName("Label_suite_name"):createStroke(Colors.strokeBrown, 2)

        local suitData = EquipmentInfo.getSuitNum(equipment)
        local suitNum = 0

        -- 设置 4个图标

        for i=1,4 do
            --ImageView_suite_icon1
            --Label_suite_icon1_name
            --ImageView_suite_icon1_border
            local equipment_key = "equipment_id_" .. i
            local equipment_id = suiteInfo[equipment_key]
            local equipmentInfo = equipment_info.get(equipment_id)

            self:getLabelByName("Label_suite_icon" .. i .. "_name"):setColor(Colors.qualityColors[equipmentInfo.quality])
            self:getLabelByName("Label_suite_icon" .. i .. "_name"):setText(equipmentInfo.name )
            self:getImageViewByName("ImageView_suite_icon" .. i ):loadTexture(G_Path.getEquipmentIcon(equipmentInfo.res_id),UI_TEX_TYPE_LOCAL)
            self:getImageViewByName("ImageView_suite_icon" .. i  .. "_border"):loadTexture(G_Path.getEquipColorImage(equipmentInfo.quality,G_Goods.TYPE_EQUIPMENT))
            self:getLabelByName("Label_suite_icon" .. i .. "_name"):createStroke(Colors.strokeBrown, 1)
            
            local ball = self:getImageViewByName("ImageView_suite_icon" .. i .. "_ball" )
            if ball then 
                ball:loadTexture(G_Path.getEquipIconBack(equipmentInfo.quality))
            end
            self:getImageViewByName("ImageView_suite_icon" .. i ):setTouchEnabled(true)
            self:registerWidgetTouchEvent("ImageView_suite_icon" .. i, function (widget,_type)
                if  _type == TOUCH_EVENT_ENDED then
                    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
                    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_EQUIPMENT,equipment_id)
                end
            end)
            if suitData[i] == 0 then 
                -- self:getLabelByName("Label_suite_icon" .. i .. "_name"):setColor(Colors.uiColors.GRAY)
                -- self:getImageViewByName("ImageView_suite_icon" .. i ):showAsGray(true)
                -- self:getImageViewByName("ImageView_suite_icon" .. i  .. "_border"):showAsGray(true)
                -- if ball then 
                --     ball:showAsGray(true)
                -- end
            else
                local effect= EffectNode.new("effect_around1", 
                    function(event, frameIndex)
                        if event == "finish" then
                     
                        end
                    end
                )
                effect:setPosition(ccp(4,-4))
                effect:setScale(1.6);
                effect:play()
                self:getImageViewByName("ImageView_suite_icon" .. i .. "_border" ):addNode(effect)
                suitNum = suitNum + 1
            end

        end
        
        --2条, 3条, 4条属性
        for i=1,3 do
          -- Label_suite_attr1_title
          -- Label_suite_attr1_1
          -- Label_suite_attr1_2

         
            local type1
            local value1 
            local type2 
            local value2 
            if i == 1 then
                self:getLabelByName("Label_suite_attr" .. i .. "_title"):setText( G_lang:get("LANG_SUIT_ATTR1") )
                type1 = suiteInfo.two_suit_type_1
                value1 = suiteInfo.two_suit_value_1 
                type2 = suiteInfo.two_suit_type_2
                value2 = suiteInfo.two_suit_value_2 
            elseif i==2 then
                self:getLabelByName("Label_suite_attr" .. i .. "_title"):setText( G_lang:get("LANG_SUIT_ATTR2") )
                type1 = suiteInfo.three_suit_type_1
                value1 = suiteInfo.three_suit_value_1 
                type2 = suiteInfo.three_suit_type_2
                value2 = suiteInfo.three_suit_value_2 
            elseif i ==3 then
                self:getLabelByName("Label_suite_attr" .. i .. "_title"):setText( G_lang:get("LANG_SUIT_ATTR3") )
                type1 = suiteInfo.four_suit_type_1
                value1 = suiteInfo.four_suit_value_1 
                type2 = suiteInfo.four_suit_type_2
                value2 = suiteInfo.four_suit_value_2 
            end

            local type,value,typeString, valueString = MergeEquipment.convertAttrTypeAndValue(type1, value1)
            


            self:getLabelByName("Label_suite_attr" .. i .. "_1"):setText( typeString   .. "+" ..    valueString  )
            -- self:getLabelByName("Label_suite_attr" .. i .. "_title"):createStroke(Colors.strokeBrown, 1)
            -- self:getLabelByName("Label_suite_attr" .. i .. "_1"):createStroke(Colors.strokeBrown, 1)

            if type2 ~= 0 then

                local type,value,typeString, valueString = MergeEquipment.convertAttrTypeAndValue(type2, value2)

                self:getLabelByName("Label_suite_attr" ..i .. "_2"):setText( typeString   .. "+" ..    valueString )
                self:getLabelByName("Label_suite_attr" .. i .. "_2"):setVisible(true)
                -- self:getLabelByName("Label_suite_attr" .. i .. "_2"):createStroke(Colors.strokeBrown, 1)
            else
                self:getLabelByName("Label_suite_attr" .. i .. "_2"):setVisible(false)
            end

            if suitNum > i then 
                self:getLabelByName("Label_suite_attr" .. i .. "_title"):setColor(Colors.lightColors.TIPS_01)
                self:getLabelByName("Label_suite_attr" .. i .. "_1"):setColor(Colors.lightColors.TIPS_01)
                self:getLabelByName("Label_suite_attr" ..i .. "_2"):setColor(Colors.lightColors.TIPS_01)
            else
                self:getLabelByName("Label_suite_attr" .. i .. "_title"):setColor(Colors.lightColors.DESCRIPTION)
                self:getLabelByName("Label_suite_attr" .. i .. "_1"):setColor(Colors.lightColors.DESCRIPTION)
                self:getLabelByName("Label_suite_attr" ..i .. "_2"):setColor(Colors.lightColors.DESCRIPTION)
            end
            
        end

    else
        self:getLabelByName("Panel_suite"):setVisible(false)
    end
    
   
end

-- 判断一下套装有哪几件
function EquipmentInfo.getSuitNum(equipment)

    local res = {0,0,0,0}
    if not equipment or not equipment:isWearing() then 
        return res
    end
    
    local knightId = equipment:getWearingKnightId()
    local team,slot = G_Me.formationData:getTeamSlotByKnightId(knightId)
    for i=1,4 do 
        local fightEquipment = G_Me.formationData:getFightEquipmentBySlot(team, slot, i)
        if fightEquipment ~= nil and fightEquipment ~= 0 then
            local equipmentfight = G_Me.bagData.equipmentList:getItemByKey(fightEquipment)
            if equipmentfight:getInfo().suit_id == equipment:getInfo().suit_id then 
                res[i] = 1
            end
        end
    end
    return res

end

--给所有的属性label赋值, 还要设置隐藏和显示.
--labels 包含 4个元素, 第一个属性名字,第一个属性值, 第2个属性名字,第2个属性值
function EquipmentInfo.setAttrLabels(container, attrs, labels)

    container:showWidgetByName(labels[1], false)
    container:showWidgetByName(labels[2], false)
    if #labels >= 4 then
        container:showWidgetByName(labels[3], false)
        container:showWidgetByName(labels[4], false)
    end
    

    if #attrs >= 2 then
        container:showWidgetByName(labels[3], true)
        container:showWidgetByName(labels[4], true)
        container:getLabelByName(labels[3]):setText(attrs[2].typeString)
        container:getLabelByName(labels[4]):setText("+" ..attrs[2].valueString)
        -- container:getLabelByName(labels[3]):createStroke(Colors.strokeBrown, 1)
        -- container:getLabelByName(labels[4]):createStroke(Colors.strokeBrown, 1)
    end


    if #attrs >= 1 then
        container:showWidgetByName(labels[1], true)
        container:showWidgetByName(labels[2], true)
        container:getLabelByName(labels[1]):setText(attrs[1].typeString)
        container:getLabelByName(labels[2]):setText("+" .. attrs[1].valueString)
        -- container:getLabelByName(labels[1]):createStroke(Colors.strokeBrown, 1)
        -- container:getLabelByName(labels[2]):createStroke(Colors.strokeBrown, 1)

    end
end

function EquipmentInfo:setSkill( )
    local skillTitle = self:getLabelByName("Label_skill_txt")
    skillTitle:setText(G_lang:get("LANG_SKILL_SHENBING"))
    skillTitle:createStroke(Colors.strokeBrown, 2)
    local panel = self:getPanelByName("Panel_skill")
    local height = MergeEquipment.initSkill(self._equipment:getInfo(),self._equipment.refining_level,panel,self:getImageViewByName("ImageView_skillTitle"))
    return height
end

return EquipmentInfo
