

local DressInfo = class("DressInfo", UFCCSModelLayer)

require "app.cfg.dress_info"
require "app.cfg.dress_compose_info"
require "app.cfg.passive_skill_info"
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

function DressInfo:ctor( ... )
	self._equipment = nil
            self._slotInfo = nil 

	self.super.ctor(self, ...)

	self:adapterWithScreen()

	self:registerBtnClickEvent("Button_back", function ( widget )
		self:close()
	end)

	self:registerBtnClickEvent("Button_qianghua", function ( widget )
                        -- if G_SceneObserver:getSceneName() == "DressMainScene" then
                        --     self._container:check(3)
                        --     self:close()
                        --     return
                        -- end
                        local funLevelConst = require("app.const.FunctionLevelConst")
                        if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.DRESSSTRENGTH) then
                                    self:close()
                                    uf_sceneManager:replaceScene(require("app.scenes.dress.DressMainScene").new(3))
                        end
	end)

            self:attachImageTextForBtn("Button_qianghua","Image_reftxt")
    

        self:getLabelByName("Label_attr2noattr"):setVisible(false)
        self:getPanelByName("Panel_attr2attr"):setVisible(true)
end

function DressInfo:onLayerEnter( )
    self:registerKeypadEvent(true, false)
end

function DressInfo:onBackKeyEvent( ... )
    self:close()
    return true
end

function DressInfo:__prepareDataForGuide__( param )
    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    if scrollView then 
        scrollView:setScrollEnable(false)
    end
end

function DressInfo:initEquipmentWithEquip( equipment,container)
	self._equipment = equipment
    self._container = container  
    if self._equipment then
        self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id)
    end
    self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "", 0, 0)
   self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 10, 10)

    self:getPanelByName("Panel_btns1"):setVisible(false)
    
    self:_updateCommonAttrs()
end

function DressInfo:initEquipmentWithEquipInfo( equipmentinfo,container)      
    self._equipmentInfo = equipmentinfo
    self._container = container  
    self._equipment = G_Me.dressData:getDressByBaseId(equipmentinfo.id)  

    self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "", 0, 0)
   self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 10, 10)

    self:getPanelByName("Panel_btns1"):setVisible(false)
    
    self:_updateCommonAttrs()
end

function DressInfo.showEquipmentInfo( equipment,container )


	local equipDesc = require("app.scenes.dress.DressInfo").new("ui_layout/dress_DressInfo.json", Colors.modelColor)
	uf_notifyLayer:getModelNode():addChild(equipDesc)
	equipDesc:initEquipmentWithEquip(equipment,container)

    return equipDesc
end

function DressInfo.showInfo( equipmentinfo,container )


    local equipDesc = require("app.scenes.dress.DressInfo").new("ui_layout/dress_DressInfo.json", Colors.modelColor)
    uf_notifyLayer:getModelNode():addChild(equipDesc)
    equipDesc:initEquipmentWithEquipInfo(equipmentinfo,container)

    return equipDesc
end


-- 更新通用的属性, 名字啊, star啥的
function DressInfo:_updateCommonAttrs()
    local info = self._equipmentInfo
    -- if self._equipment then
    --     info = G_Me.dressData:getDressInfo(self._equipment.base_id)
    -- end
    
    ---------------顶部部分
    --名字
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_name"):setText(info.name)
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 2)
    
    --颜色图片
    self:getImageViewByName("Image_color"):loadTexture(G_Path.getEquipmentColorImage(info.quality))

    --资质
    self:getLabelByName("Label_zizhi"):setColor(Colors.qualityColors[info.quality])
    self:getLabelByName("Label_zizhi"):setText( G_lang:get("LANG_ZIZHI_VALUE", {zizhi=info.potentiality}) )
    self:getLabelByName("Label_zizhi"):createStroke(Colors.strokeBrown, 1)

    --大图
    local resid = G_Me.dressData:getCurDressedResidWithDress(info.id)
    local panel = self:getPanelByName("Panel_dressKnight")
    panel:removeAllChildrenWithCleanup(true)
    self._knight =KnightPic.createKnightPic( resid, panel, "knightImg",true )
    -- panel:setScale(0.7)
    -- self:getImageViewByName("ImageView_pic"):loadTexture(resid)

    --类型文字图片    
    self:getImageViewByName("ImageView_type"):loadTexture("ui/text/txt/zb_shizhuang.png" )
    
    ------------------属性部分
    ----基础
    self:getLabelByName("Label_attr1_title"):setText( G_lang:get("LANG_JICHU_SHUXING")  )
    self:getLabelByName("Label_attr1_title"):createStroke(Colors.strokeBrown, 2)
    for i = 1 ,2 do 
        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(info["basic_type_"..i], info["basic_value_"..i])
        self:getLabelByName("Label_attr1_slot"..i.."_title"):setText(strtype)
        self:getLabelByName("Label_attr1_slot"..i.."_value"):setText(strvalue)
    end
    
    local level = self._equipment and self._equipment.level or 1
    --强化
    self:getLabelByName("Label_attr2_title"):setText( G_lang:get("LANG_QIANGHUA_SHUXING")  )
    self:getLabelByName("Label_attr2_slot5_title"):setText( G_lang:get("LANG_QIANGHUA_DENGJI")..  G_lang:get("LANG_MAOHAO") )
    self:getLabelByName("Label_attr2_slot5_value"):setText( level .. "/" .. G_Me.dressData:getMaxLevel() )
    self:getLabelByName("Label_attr2_title"):createStroke(Colors.strokeBrown, 2)

    for i = 1 ,4 do 
        local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(info["strength_type_"..i], info["strength_value_"..i]*(level-1))
        self:getLabelByName("Label_attr2_slot"..i.."_title"):setText(strtype)
        self:getLabelByName("Label_attr2_slot"..i.."_value"):setText(strvalue)
    end

    local hasEquip = G_Me.dressData:getDressByBaseId(info.id)
    if hasEquip then
        self:getButtonByName("Button_qianghua"):setTouchEnabled(true)
    else
        self:getButtonByName("Button_qianghua"):setTouchEnabled(false)
    end

    ----------------描述部分
    self:getLabelByName("Label_desc_txt"):setText( G_lang:get("LANG_MIAOSU") )
    self:getLabelByName("Label_desc_txt"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_desc_content"):setText( info.directions )
    
    -----------------套装

    self:setSuitPanel(info,self._equipment)

    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    local scrollSize = scrollView:getInnerContainerSize()
    local scrollContent = self:getPanelByName("Panel_scrollContent")
    local bottomY = 5
    local mainKnightInfo = G_Me.bagData.knightsData:getMainKightInfo()
    local guanghuan = mainKnightInfo.halo_level

    local descPanel = self:getPanelByName("Panel_desc")
    descPanel:setPosition(ccp(0,bottomY))
    bottomY = bottomY + descPanel:getSize().height + 5
    local suitPanel = self:getPanelByName("Panel_suite")
    suitPanel:setPosition(ccp(0,bottomY))
    bottomY = bottomY + suitPanel:getSize().height + 5

    if G_Me.dressData:getDressCanStrength() then
        bottomY = self:initTianFu( bottomY) + 5 + 5
        self:getPanelByName("Panel_tianfu"):setVisible(true)
    else
        self:getPanelByName("Panel_tianfu"):setVisible(false)
    end
    bottomY = self:_loadSkillInfo(info,guanghuan, bottomY, scrollSize.height) + 5

    if G_Me.dressData:getDressCanStrength() then
        local attrPanel2 = self:getPanelByName("Panel_attr2")
        attrPanel2:setVisible(true)
        attrPanel2:setPosition(ccp(0,bottomY))
        bottomY = bottomY + attrPanel2:getSize().height + 5
    else
        local attrPanel2 = self:getPanelByName("Panel_attr2")
        attrPanel2:setVisible(false)
    end

    local attrPanel1 = self:getPanelByName("Panel_attr1")
    attrPanel1:setPosition(ccp(0,bottomY))
    bottomY = bottomY + attrPanel1:getSize().height + 5

    bottomY = bottomY - 5
    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
    scrollContent:setSize(CCSizeMake(scrollSize.width, bottomY))
end

--设置套装小面板的显示
function DressInfo:setSuitPanel(info,equipment)

    self:getLabelByName("Label_suite_txt"):setText( G_lang:get("LANG_ZUHE") )
    self:getLabelByName("Label_suite_txt"):createStroke(Colors.strokeBrown,2)

    --todo: 是否所有装备都是套装?
    if info.compose_id ~= nil and info.compose_id ~= 0 then
        
        self:getPanelByName("Panel_suite"):setVisible(true)

        local suiteInfo = dress_compose_info.get(info.compose_id)
        self:getLabelByName("Label_suite_name"):setColor(Colors.qualityColors[info.quality] )
        self:getLabelByName("Label_suite_name"):setText(suiteInfo.name )
        self:getLabelByName("Label_suite_name"):createStroke(Colors.strokeBrown, 2)

        local suitMax = 0
        for i = 1 , 3 do 
            if suiteInfo["dress_"..i] > 0 then
                suitMax = suitMax + 1
            end
        end

        -- 设置 图标
        self:getPanelByName("Panel_icons2"):setVisible(suitMax == 2)
        self:getPanelByName("Panel_icons3"):setVisible(suitMax == 3)
        local suitEnough = true

        for i=1,suitMax do
            local equipment_key = "dress_" .. i
            local equipment_id = suiteInfo[equipment_key]
            local equipmentInfo = dress_info.get(equipment_id)

            self:getLabelByName("Label_suite"..suitMax.."_icon" .. i .. "_name"):setColor(Colors.qualityColors[equipmentInfo.quality])
            self:getLabelByName("Label_suite"..suitMax.."_icon" .. i .. "_name"):setText(equipmentInfo.name )
            self:getImageViewByName("ImageView_suite"..suitMax.."_icon" .. i ):loadTexture(G_Path.getDressIconById(equipmentInfo.id),UI_TEX_TYPE_LOCAL)
            self:getImageViewByName("ImageView_suite"..suitMax.."_icon" .. i  .. "_border"):loadTexture(G_Path.getEquipColorImage(equipmentInfo.quality,G_Goods.TYPE_EQUIPMENT))
            self:getLabelByName("Label_suite"..suitMax.."_icon" .. i .. "_name"):createStroke(Colors.strokeBrown, 1)
            
            local ball = self:getImageViewByName("ImageView_suite"..suitMax.."_icon" .. i .. "_ball" )
            if ball then 
                ball:loadTexture(G_Path.getEquipIconBack(equipmentInfo.quality))
            end
            local has = G_Me.dressData:hasDressId(equipment_id)
            suitEnough = suitEnough and has
            if has then 
                local effect= EffectNode.new("effect_around1", 
                    function(event, frameIndex)
                        if event == "finish" then
                     
                        end
                    end
                )
                effect:setPosition(ccp(4,-4))
                effect:setScale(1.6);
                effect:play()
                self:getImageViewByName("ImageView_suite"..suitMax.."_icon" .. i .. "_border" ):addNode(effect)
            end
        end
        local titleTxt = self:getLabelByName("Label_suite_attr1_title")
        if suitEnough then 
            titleTxt:setColor(Colors.lightColors.TIPS_01)
        else
            titleTxt:setColor(Colors.lightColors.DESCRIPTION)
        end
        titleTxt:setText( G_lang:get("LANG_JIHUOXIAOGUO") )

        for i=1,3 do
            local _type = suiteInfo["attribute_type_"..i]
            local _value = suiteInfo["attribute_value_"..i]

            if _type > 0 then

                local type,value,typeString, valueString = MergeEquipment.convertAttrTypeAndValue(_type, _value)

                local attrTxt = self:getLabelByName("Label_suite_attr1_" .. i)
                attrTxt:setVisible(true)
                if suitEnough then 
                    attrTxt:setColor(Colors.lightColors.TIPS_01)
                else
                    attrTxt:setColor(Colors.lightColors.DESCRIPTION)
                end
                attrTxt:setText( typeString   .. "  +" ..    valueString  )
            else
                local attrTxt = self:getLabelByName("Label_suite_attr1_" .. i)
                attrTxt:setVisible(false)
            end
            
        end

    else
        self:getLabelByName("Panel_suite"):setVisible(false)
    end
    
end

function DressInfo:_loadSkillInfo( knightInfo,guanhuan, bottomY, scrollHeight )
    local panel = self:getPanelByName("Panel_skill")
    if not panel or not knightInfo then 
        return bottomY
    end

    local title = self:getWidgetByName("ImageView_title_bg")
    if title then 
        title:retain()
    end

    self:getLabelByName("Label_skill_title"):setText(G_lang:get("LANG_JINENG"))
    self:getLabelByName("Label_skill_title"):createStroke(Colors.strokeBrown,2)

    local level = self._equipment and self._equipment.level or 1
    local guanhuanLevel = guanhuan or 1
    panel:removeAllChildren()
    scrollHeight = scrollHeight or 0
    local size = panel:getSize()
    local initYPos = bottomY
    local startYpos = 5

    if knightInfo.super_unite_skill_id > 0 and ( G_Me.dressData:getDressCanStrength() or level >= knightInfo.super_unite_clear_level ) then 
        local skillInfo = skill_info.get(knightInfo.super_unite_skill_id)
        if skillInfo then
            local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(knightInfo.sp_unite_des, 
                {num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10*(guanhuanLevel - 1)),
                 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1),
                 damage_type = G_Me.dressData:getAttackTypeTxt(),
                 test = (guanhuanLevel == 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))})})
            if level < knightInfo.super_unite_clear_level then
                heSkill = heSkill.."   "..G_lang:get("LANG_DRESS_LEVELLIMIT",{level=knightInfo.super_unite_clear_level})
            end
            local label = GlobalFunc.createGameLabel(heSkill, 22, 
                level >= knightInfo.super_unite_clear_level and Colors.activeSkill or Colors.inActiveSkill,
                nil, CCSizeMake(size.width - 50, 0), true)
            local labelSize = label:getSize()
            local labelPosX = size.width - labelSize.width/2 - 5
            label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
            panel:addChild(label, 1, 100)
            startYpos = startYpos + labelSize.height

            labelPosX = labelPosX - labelSize.width/2
            local img = ImageView:create()
            img:loadTexture("ui/text/txt/icon_skill_chao.png", UI_TEX_TYPE_LOCAL)
            local imgSize = img:getSize()
            img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
            panel:addChild(img,2)

            startYpos = startYpos + 5
        end
    end

    if knightInfo.unite_skill_id > 0 and ( G_Me.dressData:getDressCanStrength() or level >= knightInfo.unite_clear_level ) then 
        local skillInfo = skill_info.get(knightInfo.unite_skill_id)
        if skillInfo then
            local heSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
                {num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10*(guanhuanLevel - 1)),
                 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1),
                 damage_type = G_Me.dressData:getAttackTypeTxt(),
                 test = (guanhuanLevel == 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))})})
            if level < knightInfo.unite_clear_level then
                heSkill = heSkill.."   "..G_lang:get("LANG_DRESS_LEVELLIMIT",{level=knightInfo.unite_clear_level})
            end
            local label = GlobalFunc.createGameLabel(heSkill, 22, 
                level >= knightInfo.unite_clear_level and Colors.activeSkill or Colors.inActiveSkill,
                nil, CCSizeMake(size.width - 50, 0), true)
            local labelSize = label:getSize()
            local labelPosX = size.width - labelSize.width/2 - 5
            label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
            panel:addChild(label, 1, 100)
            startYpos = startYpos + labelSize.height

            labelPosX = labelPosX - labelSize.width/2
            local img = ImageView:create()
            img:loadTexture("ui/text/txt/icon_skill_he.png", UI_TEX_TYPE_LOCAL)
            local imgSize = img:getSize()
            img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
            panel:addChild(img,2)

            startYpos = startYpos + 5
        end
    end

    if knightInfo.active_skill_id_1 > 0 then 
        local skillInfo = skill_info.get(knightInfo.active_skill_id_1)
        if skillInfo then
            local jiSkill = "["..skillInfo.name.." Lv."..guanhuanLevel.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
                {num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
                 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1),
                 damage_type = G_Me.dressData:getAttackTypeTxt(),
                 test = (guanhuanLevel == 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))})})
            if level < knightInfo.active_clear_level_1 then
                jiSkill = jiSkill.."   "..G_lang:get("LANG_DRESS_LEVELLIMIT",{level=knightInfo.unite_clear_level})
            end
            local label = GlobalFunc.createGameLabel(jiSkill, 22, 
                level >= knightInfo.active_clear_level_1 and Colors.activeSkill or Colors.inActiveSkill,
                nil, CCSizeMake(size.width - 50, 0), true)
            local labelSize = label:getSize()
            local labelPosX = size.width - labelSize.width/2 - 5
            label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
            panel:addChild(label, 1, 100)
            startYpos = startYpos + labelSize.height

            labelPosX = labelPosX - labelSize.width/2
            local img = ImageView:create()
            img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
            local imgSize = img:getSize()
            img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
            panel:addChild(img,2)

            startYpos = startYpos + 5
        end
    end

    if knightInfo.common_skill_id > 0 then 
        local skillInfo = skill_info.get(knightInfo.common_skill_id)
        if skillInfo then 
            local skillText = "["..skillInfo.name.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
                {num1 = skillInfo.formula_value1_1,
                num2 = skillInfo.formula_value1_2,
                damage_type = G_Me.dressData:getAttackTypeTxt(),})
            if level < knightInfo.common_clear_level then
                skillText = skillText.."   "..G_lang:get("LANG_DRESS_LEVELLIMIT",{level=knightInfo.unite_clear_level})
            end
            local label = GlobalFunc.createGameLabel(skillText, 22, 
                level >= knightInfo.common_clear_level and Colors.activeSkill or Colors.inActiveSkill,
                nil, CCSizeMake(size.width - 50, 0), true)
            local labelSize = label:getSize()
            local labelPosX = size.width - labelSize.width/2 - 5
            label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
            panel:addChild(label, 1, 100)
            startYpos = startYpos + labelSize.height

            labelPosX = labelPosX - labelSize.width/2
            local img = ImageView:create()
            img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
            local imgSize = img:getSize()
            img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
            panel:addChild(img,2)

            startYpos = startYpos + 5
        end
    end

    startYpos = startYpos + 5
    if title then 
        local titleSize = title:getSize()
        panel:addChild(title)
        title:release()
        title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
        startYpos = startYpos + titleSize.height
    end


    bottomY = startYpos + bottomY
    panel:setSize(CCSizeMake(size.width, bottomY - initYPos + 5))
    panel:setPosition(ccp(0, initYPos))

    bottomY = bottomY + 5

    return bottomY
end

function DressInfo:initTianFu(bottomY)
    local baseInfo = self._equipmentInfo
    local panel = self:getPanelByName("Panel_tianfu")
    if not panel or not baseInfo then 
        return bottomY
    end

    self:getLabelByName("Label_tianfu_title"):setText(G_lang:get("LANG_DRESS_TIANFU"))
    self:getLabelByName("Label_tianfu_title"):createStroke(Colors.strokeBrown,2)

    local title = self:getWidgetByName("ImageView_tianfu_bg")
    if title then 
        title:retain()
    end
    panel:removeAllChildren()
    local height = 5
    local size = panel:getSize()
    local level = self._equipment and self._equipment.level or 1

    for i = 7, 1,-1 do 
            local skillId = baseInfo["passive_skill_"..i]
            if skillId > 0 then
                local info = passive_skill_info.get(skillId)
                local str = "["..info.name.."]  "..info.directions
                local label = GlobalFunc.createGameLabel(str,22,
                    level >= baseInfo["strength_level_"..i] and Colors.activeSkill or Colors.inActiveSkill,
                    nil,CCSizeMake(size.width - 15, 0), true)
                local labelSize = label:getSize()

                label:setPosition(ccp(size.width/2, height + labelSize.height/2))
                panel:addChild(label)
                height = height + labelSize.height
            end
    end

    height = height + 5
    if title then 
        local titleSize = title:getSize()
        panel:addChild(title)
        title:release()
        title:setPosition(ccp(size.width/2, height + titleSize.height/2))
        height = height + titleSize.height
    end
    panel:setSize(CCSizeMake(size.width, height+5))
    panel:setPosition(ccp(0, bottomY))
    return height + bottomY
end

return DressInfo
