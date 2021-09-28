--PetInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.knight_info")
require("app.cfg.equipment_suit_info")

local knightPic = require("app.scenes.common.KnightPic")
local MergeEquipment = require("app.data.MergeEquipment")
local EffectNode = require "app.common.effects.EffectNode"

local PetInfoPage = class("PetInfoPage", KnightPageBase)

function PetInfoPage.create(...)
	return KnightPageBase._create_(PetInfoPage.new(...), "ui_layout/BaseInfo_PetInfo.json", ...)
end

function PetInfoPage.delayCreate( ... )
	local page = KnightPageBase._create_(PetInfoPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_PetInfo.json")
	return page
end

function PetInfoPage:ctor( baseId, fragmentId, scenePack, ... )
    self._scenePack = scenePack

	self.super.ctor(self, baseId, fragmentId, scenePack, ...)
    __Log("-- baseId = %s, fragmentId = %s", tostring(baseId), tostring(fragmentId))
end

function PetInfoPage:afterLayerLoad( ... )
    if not self._jsonFile then
        return
    end

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_base_title", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_skill_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_addition_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_taozhuang", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_desc", Colors.strokeBrown, 2 )

	self:enableLabelStroke("Label_attr_6", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attr_5", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_attr_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_attr_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_attr_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_attr_1", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_get", function ( ... )
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_PET, self._baseId, self._scenePack)
	end)
    self:registerWidgetTouchEvent("Label_CheckSkill", function (widget, eventType)
        if eventType == TOUCH_EVENT_ENDED then
            __Log("查看所有技能")
            if not self._tPetTmpl then
                return
            end
            local tTmplList = {}
            for i=1, pet_info.getLength() do
                local tPetTmpl = pet_info.indexOf(i)
                if tPetTmpl and tPetTmpl.advanced_id == self._tPetTmpl.advanced_id then
                    table.insert(tTmplList, #tTmplList + 1, tPetTmpl)
                end
            end

            local tContentList = {}
            for i=1, #tTmplList do
                local tPetTmpl = tTmplList[i]
                __Log("-- tPetTmpl.active_skill_id = %s", tostring(tPetTmpl.active_skill_id))
                local tSkillTmpl = skill_info.get(tPetTmpl.active_skill_id)

                local tContent = {}
                tContent["color"] = Colors.lightColors.DESCRIPTION
                tContent["content"] = tSkillTmpl.directions
                table.insert(tContentList, #tContentList + 1, tContent)
            end

            require("app.scenes.common.CommonAttrLayer").show(tContentList, nil, "ui/text/txt/zhanchongjineng.png")
        end
    end)

    self:_initView()
end

function PetInfoPage:_initView()
    self._tPetTmpl = pet_info.get(self._baseId)
    if not self._tPetTmpl then
        return
    end

    -- 战宠形象
    local eff = G_Path.getPetReadyEffect(self._tPetTmpl.ready_id)
    if not self._tEffectPic then
        self._tEffectPic = EffectNode.new(eff)
        assert(self._tEffectPic)
        local tParent = self:getPanelByName("Panel_PetEffect")
        if tParent then
            tParent:setScale(0.6)
            tParent:addNode(self._tEffectPic)
            self._tEffectPic:play()
        end
    end

    -- 战宠名字
    local lable = self:getLabelByName("Label_name")
    if lable then
        lable:setColor(Colors.getColor(self._tPetTmpl.quality))
        lable:setText(self._tPetTmpl.name)
    end

    -- 基础属性
    local nAttack, nHp, nPhyDef, nMagDef = G_Me.bagData.petData:getBaseAttr(1, self._tPetTmpl.id,0)
    __Log("-- nAttack = %d, nHp = %d, nPhyDef = %d, nMagDef = %d", nAttack, nHp, nPhyDef, nMagDef)
    -- 攻击
    lable = self:getLabelByName("Label_attack_value")
    local szAttr = ""..nAttack
    if lable then
        lable:setText(szAttr)
    end
    -- 生命
    lable = self:getLabelByName("Label_hp_value")
    szAttr = ""..nHp
    if lable then
        lable:setText(szAttr)
    end
    -- 物防
    lable = self:getLabelByName("Label_phydef_value")
    szAttr = ""..nPhyDef
    if lable then
        lable:setText(szAttr)
    end
    -- 法防
    lable = self:getLabelByName("Label_magdef_value")
    szAttr = ""..nMagDef
    if lable then
        lable:setText(szAttr)
    end
    -- 注
    lable = self:getLabelByName("Label_Tips")
    if lable then
        lable:setText(G_lang:get("LANG_PET_STRENGTH_TIPS"))
    end

    -- 技能
    -- 普通技能
    local tCommomSkillTmpl = skill_info.get(self._tPetTmpl.common_id)
    local tActiveSkillTmpl = skill_info.get(self._tPetTmpl.active_skill_id)
    local szCommonSkillDesc = ""
    local szActiveSkillDesc = ""
    if tCommomSkillTmpl then
       szCommonSkillDesc = "["..tCommomSkillTmpl.name.."] " .. tCommomSkillTmpl.directions
    end
    if tActiveSkillTmpl then
       szActiveSkillDesc = "["..tActiveSkillTmpl.name.."] " .. tActiveSkillTmpl.directions
    end
    lable = self:getLabelByName("Label_Pu")
    if lable then
        lable:setText(szCommonSkillDesc)
    end
    lable = self:getLabelByName("Label_Ji")
    if lable then
        lable:setText(szActiveSkillDesc)
    end

    -- 神炼
    local nAdditionLevel = 0
    local tAdditionTmpl = pet_addition_info.get(self._tPetTmpl.addition_id, nAdditionLevel)
    lable = self:getLabelByName("Label_Spirit_Level")
    if lable then
        lable:setText(nAdditionLevel)
    end
    lable = self:getLabelByName("Label_Spirit_Desc")
    if lable then
        lable:setText(G_lang:get("LANG_PET_ADDITION_DESC"))
    end
    
    local szSpiritDescList = {}
    for i=1, 6 do
        local pos = i
        local type = tAdditionTmpl["type_"..i]
        local value = tAdditionTmpl["value_"..i]
        self:enableLabelStroke("Label_Pos_"..i, Colors.strokeBrown, 1)
        if type == 0 then
            self:showWidgetByName("Image_Pos_Light_"..i, false)
        else
            self:showWidgetByName("Image_Pos_Light_"..i, true)
            local _, _, attrType, attrValue = MergeEquipment.convertPassiveSkillTypeAndValue(type, value)
            local szDesc = G_lang:get("LANG_PET_SHOOT_POSITION", {num=i}).." "..attrType.."：+"..attrValue
            table.insert(szSpiritDescList, #szSpiritDescList + 1, szDesc)
        end
    end
    local nCount = 0
    for i=1, 6 do
        local szDesc = szSpiritDescList[i]
        lable = self:getLabelByName("Label_Spirit_Attr_"..i)
        if szDesc then
            lable:setText(szDesc)
            nCount = nCount + 1
        else
            lable:setText("")
        end
    end
    
    local panelSpirit = self:getPanelByName("Panel_spirit")
    local tSize = panelSpirit:getSize()
    panelSpirit:setSize(CCSizeMake(tSize.width, 150 + nCount * 24))
  
    -- 描述
    lable = self:getLabelByName("Label_equip_desc")
    if lable then
        lable:setText(self._tPetTmpl.directions)
    end

    self:setSkillInfo()    

    self:adapterInfo()
end


function PetInfoPage:setSkillInfo()
    -- 普通技能
    local tCommomSkillTmpl = skill_info.get(self._tPetTmpl.common_id)
    local tActiveSkillTmpl = skill_info.get(self._tPetTmpl.active_skill_id)
    local szCommonSkillDesc = ""
    local szActiveSkillDesc = ""
    if tCommomSkillTmpl then
       szCommonSkillDesc = "["..tCommomSkillTmpl.name.."] " .. tCommomSkillTmpl.directions
    end
    if tActiveSkillTmpl then
       szActiveSkillDesc = "["..tActiveSkillTmpl.name.."] " .. tActiveSkillTmpl.directions
    end

    local tPanel = self:getPanelByName("Panel_skill")
    local tSize = tPanel:getSize()

    local nBottomY = 5
    local labelCheck = self:getLabelByName("Label_CheckSkill")
    local labelLine = self:getLabelByName("Label_Line")
    if labelCheck then
        labelCheck:setPositionXY(tSize.width - 100, nBottomY + labelCheck:getSize().height/2)
        labelLine:setPositionXY(tSize.width - 100, nBottomY + labelCheck:getSize().height/2)
        nBottomY = labelCheck:getSize().height + 25
    end

    -- 技能
    if tActiveSkillTmpl then
        local label = GlobalFunc.createGameLabel(szActiveSkillDesc, 22, Colors.inActiveSkill, nil, CCSizeMake(tSize.width - 50, 0), true)
        local labelSize = label:getSize()
        local labelPosX = tSize.width - labelSize.width/2 - 5
        label:setPosition(ccp(labelPosX, nBottomY + labelSize.height/2))
        tPanel:addChild(label, 1, 100)

        labelPosX = labelPosX - labelSize.width/2
        local img = ImageView:create()
        img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
        local imgSize = img:getSize()
        img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, nBottomY + labelSize.height - imgSize.height/2))
        tPanel:addChild(img)

        nBottomY = nBottomY + labelSize.height + 5
    end

    -- 普通攻击
    if tCommomSkillTmpl then
        local label = GlobalFunc.createGameLabel(szCommonSkillDesc, 22, Colors.inActiveSkill, nil, CCSizeMake(tSize.width - 50, 0), true)
        local labelSize = label:getSize()
        local labelPosX = tSize.width - labelSize.width/2 - 5
        label:setPosition(ccp(labelPosX, nBottomY + labelSize.height/2))
        tPanel:addChild(label, 1, 100)

        labelPosX = labelPosX - labelSize.width/2
        local img = ImageView:create()
        img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
        local imgSize = img:getSize()
        img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, nBottomY + labelSize.height - imgSize.height/2))
        tPanel:addChild(img)

        nBottomY = nBottomY + labelSize.height + 8
    end

    -- title 
    local imgTitle = self:getImageViewByName("Image_title_skill")
    if imgTitle then
        local x, y = imgTitle:getPosition()
        local size = imgTitle:getSize()
        imgTitle:setPosition(ccp(x, nBottomY + size.height/2))
        nBottomY = nBottomY + size.height + 5
    end

    tPanel:setSize(CCSizeMake(tSize.width, nBottomY))
end


function PetInfoPage:adapterInfo()
    local height = 0
    local scrollView = self:getScrollViewByName("ScrollView_detail")
    if not scrollView then
        return
    end
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height

    panel = self:getPanelByName("Panel_spirit")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height

    panel = self:getPanelByName("Panel_skill")
    panel:setVisible(true)
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height

    panel = self:getPanelByName("Panel_base")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height

    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, height))
    -- self:getPanelByName("Panel_scrollContent"):setContentSize(CCSizeMake(scrollSize.width,height))
end

function PetInfoPage:setSkill( )
    local skillTitle = self:getLabelByName("Label_skill_title")
    if skillTitle then
        skillTitle:setText(G_lang:get("LANG_SKILL_SHENBING"))
        skillTitle:createStroke(Colors.strokeBrown, 2)
    end
    local panel = self:getPanelByName("Panel_skill")
    local height = 0
    if panel then
        height = MergeEquipment.initSkill(pet_info.get(self._baseId),1,panel,self:getImageViewByName("Image_title_skill"),35,20)
    end
    return height
end


return PetInfoPage
