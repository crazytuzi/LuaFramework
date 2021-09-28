--EquipInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.equipment_suit_info")

local knightPic = require("app.scenes.common.KnightPic")
local MergeEquipment = require("app.data.MergeEquipment")

local EquipInfoPage = class("EquipInfoPage", KnightPageBase)

function EquipInfoPage.create(...)
	return KnightPageBase._create_(EquipInfoPage.new(...), "ui_layout/BaseInfo_EquipInfo.json", ...)
end

function EquipInfoPage.delayCreate( ... )
	local page = KnightPageBase._create_(EquipInfoPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_EquipInfo.json")
	return page
end

function EquipInfoPage:ctor( baseId, fragmentId, scenePack, ... )
    self._scenePack = scenePack

	self.super.ctor(self, baseId, fragmentId, scenePack, ...)
  
end

function EquipInfoPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_base_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_addition_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_taozhuang", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_desc", Colors.strokeBrown, 2 )

	self:enableLabelStroke("Label_taozhuang_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_name_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
	self:registerBtnClickEvent("Button_get", function ( ... )


		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_EQUIPMENT, self._baseId, self._scenePack)
	end)

	local equipInfo = equipment_info.get(self._baseId)
	if not equipInfo then 
		return
	end

	local equipIcon = self:getImageViewByName("Image_equip_icon") 
    if equipIcon then 
		equipIcon:loadTexture(G_Path.getEquipmentPic(equipInfo.res_id))
    end

    local label = self:getLabelByName("Label_name")
    if label then 
    	label:setColor(Colors.getColor(equipInfo.quality or 1))
    	label:setText(equipInfo.name)
    end

    local image = self:getImageViewByName("Image_equip_type")
	if image then
		image:loadTexture(G_Path.getEquipmentTypeImage(equipInfo.type))
	end

    local  typeString = G_lang.getGrowthTypeName(equipInfo.strength_type)

    self:showTextWithLabel("Label_att_name", typeString)
    self:showTextWithLabel("Label_att_name_add", typeString)
    self:showTextWithLabel("Label_att_value", "+"..G_lang.getGrowthValue(equipInfo.strength_type, equipInfo.strength_value))
    self:showTextWithLabel("Label_att_value_add", "+"..G_lang.getGrowthValue(equipInfo.strength_type, equipInfo.strength_growth))
    self:showTextWithLabel("Label_equip_desc", equipInfo.directions)

    local suiteInfo = equipment_suit_info.get(equipInfo.suit_id)
    local label = self:getLabelByName("Label_taozhuang_name")
    if label then 
    	label:setColor(Colors.getColor(equipInfo.quality or 1))
    	label:setText(suiteInfo and suiteInfo.name or "")
    end

    local taoZhuangIds = {}
    if suiteInfo then 
    	taoZhuangIds[1] = suiteInfo.equipment_id_1
    	taoZhuangIds[2] = suiteInfo.equipment_id_2
    	taoZhuangIds[3] = suiteInfo.equipment_id_3
    	taoZhuangIds[4] = suiteInfo.equipment_id_4
    end

    for loopi = 1, 4 do 
    	local equipPart = equipment_info.get(taoZhuangIds[loopi] or 0)
    	if equipPart then 
    		local icon = self:getImageViewByName("Image_icon_"..loopi)
			if icon ~= nil then
				local heroPath = G_Path.getEquipmentIcon(equipPart.res_id)
    			icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
			end

			local pingji = self:getImageViewByName("Image_pingji_"..loopi)
			if pingji then
    			pingji:loadTexture(G_Path.getAddtionKnightColorImage(equipPart.quality))  
    		end

			local name = self:getLabelByName("Label_name_"..loopi)
			if name ~= nil then
				name:setColor(Colors.qualityColors[equipPart.quality])
				name:setText(equipPart.name or "Default Name")		
			end

			icon = self:getImageViewByName("Image_frag_back_"..loopi)
			if icon then
				icon:loadTexture(G_Path.getEquipIconBack(equipPart.quality))
			end
    	else
    		self:showWidgetByName("Image_"..loopi, false)
    	end
    end

    local generateSuitAttri = function ( type1, value1, type2, value2 )
    	type1 = type1 or 0
    	value1 = value1 or 0
    	type2 = type2 or 0
    	value2 = value2 or 0

    	local text = ""
    	if type1 > 0 then 
    		text = G_lang.getGrowthTypeName(type1)
    		text = text.."+"..(G_lang.getGrowthValue(type1, value1)).."  "
    	end

    	if type2 > 0 then 
    		text = text..(G_lang.getGrowthTypeName(type2))
    		text = text.."+"..(G_lang.getGrowthValue(type2, value2))
    	end

    	return text
    end
    if suiteInfo then 
    	self:showTextWithLabel("Label_effect_2", generateSuitAttri(
    		suiteInfo.two_suit_type_1, suiteInfo.two_suit_value_1, 
    		suiteInfo.two_suit_type_2, suiteInfo.two_suit_value_2))
    	self:showTextWithLabel("Label_effect_3", generateSuitAttri(
    		suiteInfo.three_suit_type_1, suiteInfo.three_suit_value_1, 
    		suiteInfo.three_suit_type_2, suiteInfo.three_suit_value_2))
    	self:showTextWithLabel("Label_effect_4", generateSuitAttri(
    		suiteInfo.four_suit_type_1, suiteInfo.four_suit_value_1, 
    		suiteInfo.four_suit_type_2, suiteInfo.four_suit_value_2))
    end

	-- local scrollView = self:getScrollViewByName("ScrollView_detail")
	-- if scrollView then 
	-- 	local bottomY = 5
	-- 	bottomY = self:_loadTianfuInfo( knightInfo, bottomY )
	-- 	bottomY = self:_loadAssociationInfo(knightInfo, bottomY)
	-- 	bottomY = self:_loadSkillInfo(knightInfo, bottomY)

	-- 	local scrollSize = scrollView:getInnerContainerSize()
	-- 	scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
	-- end

    self._skillHeight = self:setSkill()
    self:adapterInfo()
end

function EquipInfoPage:adapterInfo()
    local height = 0
    local scrollView = self:getScrollViewByName("ScrollView_detail")
    if not scrollView then
        return
    end
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height
    panel = self:getPanelByName("Panel_taozhuang")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height
    if self._skillHeight > 0 then
        panel = self:getPanelByName("Panel_skill")
        panel:setVisible(true)
        panel:setPosition(ccp(0,height))
        height = height + panel:getSize().height
    else
        panel = self:getPanelByName("Panel_skill")
        panel:setVisible(false)
    end
    panel = self:getPanelByName("Panel_addition")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height
    panel = self:getPanelByName("Panel_base")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height

    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, height))
    -- self:getPanelByName("Panel_scrollContent"):setContentSize(CCSizeMake(scrollSize.width,height))
end

function EquipInfoPage:setSkill( )
    local skillTitle = self:getLabelByName("Label_skill_title")
    if skillTitle then
        skillTitle:setText(G_lang:get("LANG_SKILL_SHENBING"))
        skillTitle:createStroke(Colors.strokeBrown, 2)
    end
    local panel = self:getPanelByName("Panel_skill")
    local height = 0
    if panel then
        height = MergeEquipment.initSkill(equipment_info.get(self._baseId),1,panel,self:getImageViewByName("Image_title_skill"),35,20)
    end
    return height
end


return EquipInfoPage
