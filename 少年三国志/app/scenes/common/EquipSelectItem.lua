--EquipSelectItem.lua

local EquipmentConst = require("app.const.EquipmentConst")
local MergeEquipment = require("app.data.MergeEquipment")

local EquipSelectItem = class ("EquipSelectItem", function (  )
	return CCSItemCellBase:create("ui_layout/knight_equipItem.json")
end)

function EquipSelectItem:ctor(  )
	self._equipId = -1
	self._iconImage = nil

	self:registerBtnClickEvent("Button_choose", function ( widget )
		self:setClickCell()
		self:selectedCell(self._equipId, 0)
	end)

	self:attachImageTextForBtn("Button_choose", "ImageView_3560")

	--self:enableLabelStroke("Label_level", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_qianli_value", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_Attri_1", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_Attri_1_value", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_Attri_2", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_Attri_2_value", Colors.strokeBlack, 1 )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_equip_type_name", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_ji_pan_count", Colors.strokeBrown,1)
	--self:enableLabelStroke("Label_jingjie", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_knightName", Colors.strokeBlack, 1 )
	--local label = self:getLabelByName("Label_qianli")
	--if label then
	--	label:createStroke(Colors.strokeBlack, 1)
	--end
end

function EquipSelectItem:updateInfo( equipInfo, wearKnightId, jipanCount )
	if equipInfo == nil then 
		return 
	end

	self._equipId = equipInfo.id
	jipanCount = jipanCount or 0

	self:showWidgetByName("Label_wearon", wearKnightId and wearKnightId > 0)
	self:showWidgetByName("Label_knightName", wearKnightId and wearKnightId > 0)
	self:enableWidgetByName("Button_choose", not wearKnightId or wearKnightId == 0)

	if wearKnightId and wearKnightId > 0 then
		require("app.cfg.knight_info")
		local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(wearKnightId)
		local baseKnightInfo = knight_info.get(baseId)
		if baseKnightInfo then
			self:showTextWithLabel("Label_knightName", baseKnightInfo.name)
		end
	end

	local baseInfo = equipInfo:getInfo()

	if baseInfo == nil then
		__LogError("Error in updateinfo")
		return 
	end

	local imgPath = equipInfo:getIcon()
	local iconBack = self:getImageViewByName("ImageView_hero_head")
	if imgPath and iconBack then
		--__Log("imgPath:%s", imgPath)
		iconBack:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
	end

	local pingji = self:getImageViewByName("ImageView_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(baseInfo.quality))  
    end

    local iconBack = self:getImageViewByName("Image_item_back")
	if iconBack then
    	iconBack:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))  
    end

	local iconPiece = self:getImageViewByName("ImageView_color_piece")
	if iconPiece then
		iconPiece:loadTexture(G_Path.getAddtionKnightColorPieceImage(baseInfo.quality))
	end

	--self:showTextWithLabel("Label_qianli_value", ""..baseInfo.potentiality)
	self:showTextWithLabel("Label_level", G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue=equipInfo["level"]}))

	local label = self:getLabelByName("Label_equip_type_name")
	if label then 
		label:setColor(Colors.getColor(baseInfo.quality))
		label:setText("【"..equipInfo:getTypeName().."】", true)
	end
	--self:showTextWithLabel("Label_name", baseInfo.name)

	local equipName = self:getLabelByName("Label_name")
	if equipName then
		equipName:setColor(Colors.getColor(baseInfo.quality))
		equipName:setText(baseInfo.name)
	end
	local jinglianLevel = equipInfo["refining_level"]
	--self:showWidgetByName("ImageView_3557", jinglianLevel > 0)
	--self:showTextWithLabel("Label_jinglian", G_lang.getJinglianValue(jinglianLevel))

	local strengthAttrs = equipInfo:getStrengthAttrs()
    local refineAttrs = equipInfo:getRefineAttrs()
    local starAttrs = equipInfo:getStarAttrs()

    local strengthAttri = MergeEquipment.getAllAttrs(strengthAttrs, refineAttrs, starAttrs)
	local index = 1
	for key, value in pairs(strengthAttri) do
		if type(value) == "table" then
			self:showTextWithLabel("Label_Attri_"..index.."_value", value.valueString)
			self:showTextWithLabel("Label_Attri_"..index, value.typeString)
		end
		index = index + 1
	end

	self:showWidgetByName("Image_jinglian", equipInfo and equipInfo.refining_level > 0)
	if equipInfo and equipInfo.refining_level > 0  then
		self:showTextWithLabel("Label_jinglian_text", G_lang:get("LANG_JING_LIAN", {level=equipInfo.refining_level}))
	end

	self:getLabelByName("Label_Attri_2"):setVisible(#strengthAttri > 1)
	self:getLabelByName("Label_Attri_2_value"):setVisible(#strengthAttri > 1)

	self:registerWidgetClickEvent("ImageView_hero_back", function ( ... )
		if equipInfo then 
			if equipInfo:isEquipment() then
          		require("app.scenes.equipment.EquipmentInfo").showEquipmentInfo(equipInfo, 1)
        	else
          		require("app.scenes.treasure.TreasureInfo").showTreasureInfo(equipInfo, 1)
        	end
    	end
	end)

	self:showWidgetByName("Label_jipan_desc", jipanCount > 0)
	--self:showTextWithLabel("Label_ji_pan_count", "+"..jipanCount)
	--GlobalFunc.loadStars(self, 
		--{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5", "ImageView_star_6", },
		--baseInfo and baseInfo.star or 0, 1, G_Path.getListStarIcon())

	    -- 升星等级
    local starLevel = equipInfo.star
    if starLevel and starLevel > 0 then
        self:showWidgetByName("Panel_stars_equip",true)
        for i = 1, EquipmentConst.Star_MAX_LEVEL do
            self:showWidgetByName(string.format("Image_start_%d_full", i), i <= starLevel)

        end

        local start_pos = {x = -47, y = -60}
        self:getPanelByName("Panel_stars_equip"):setPositionXY(start_pos.x + 9 * (EquipmentConst.Star_MAX_LEVEL - starLevel), start_pos.y)

    else
        self:showWidgetByName("Panel_stars_equip",false)
    end
end


return EquipSelectItem
