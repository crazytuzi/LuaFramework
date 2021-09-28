--TreasureInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.knight_info")
require("app.cfg.treasure_info")

local MergeEquipment = require("app.data.MergeEquipment")

local TreasureInfoPage = class("TreasureInfoPage", KnightPageBase)

function TreasureInfoPage.create(...)
	return KnightPageBase._create_(TreasureInfoPage.new(...), "ui_layout/BaseInfo_TreasureInfo.json", ...)
end

function TreasureInfoPage.delayCreate( ... )
	local page = KnightPageBase._create_(TreasureInfoPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_TreasureInfo.json")
	return page
end

function TreasureInfoPage:ctor( baseId, fragmentId, scenePack, ... )
	self.super.ctor(self, baseId, fragmentId, scenePack, ...)
	self._scenePack = scenePack
end

function TreasureInfoPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_base_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_addition_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_desc", Colors.strokeBrown, 1 )

	self:registerBtnClickEvent("Button_get", function ( ... )
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_TREASURE, self._baseId, self._scenePack)
	end)

	local equipInfo = treasure_info.get(self._baseId)
	if not equipInfo then 
		return
	end

	local equipIcon = self:getImageViewByName("Image_equip_icon") 
    if equipIcon then 
		equipIcon:loadTexture(G_Path.getTreasurePic(equipInfo.res_id))
    end

    local label = self:getLabelByName("Label_name")
    if label then 
    	label:setColor(Colors.getColor(equipInfo.quality or 1))
    	label:setText(equipInfo.name)
    end

    local image = self:getImageViewByName("Image_equip_type")
	if image then
		image:loadTexture(G_Path.getTreasureTypeImage(equipInfo.type))
	end

    local  typeString = G_lang.getGrowthTypeName(equipInfo.strength_type_1)
    self:showTextWithLabel("Label_att_name_1", typeString)
    self:showTextWithLabel("Label_att_name_add_1", typeString)
    self:showTextWithLabel("Label_att_value_1", "+"..G_lang.getGrowthValue(equipInfo.strength_type_1, equipInfo.strength_value_1))
    self:showTextWithLabel("Label_att_value_add_1", "+"..G_lang.getGrowthValue(equipInfo.strength_type_1, equipInfo.strength_growth_1))

    typeString = G_lang.getGrowthTypeName(equipInfo.strength_type_2)
    self:showTextWithLabel("Label_att_name_2", typeString)
    self:showTextWithLabel("Label_att_name_add_2", typeString)
    self:showTextWithLabel("Label_att_value_2", "+"..G_lang.getGrowthValue(equipInfo.strength_type_2, equipInfo.strength_value_2))
    self:showTextWithLabel("Label_att_value_add_2", "+"..G_lang.getGrowthValue(equipInfo.strength_type_2, equipInfo.strength_growth_2))

    self:showTextWithLabel("Label_equip_desc", equipInfo.directions)

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


function TreasureInfoPage:adapterInfo()
    local height = 0
    local scrollView = self:getScrollViewByName("ScrollView_detail")
    if not scrollView then
        return
    end
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
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

function TreasureInfoPage:setSkill( )
    local skillTitle = self:getLabelByName("Label_skill_title")
    if skillTitle then
        skillTitle:setText(G_lang:get("LANG_SKILL_SHENBING"))
        skillTitle:createStroke(Colors.strokeBrown, 2)
    end
    local panel = self:getPanelByName("Panel_skill")
    local height = 0
    if panel then
        height = MergeEquipment.initSkill(treasure_info.get(self._baseId),1,panel,self:getImageViewByName("Image_title_skill"),35,20)
    end
    return height
end

return TreasureInfoPage
