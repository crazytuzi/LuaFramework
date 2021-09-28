--HeroListItem.lua

local HeroListItem = class ("HeroListItem", function (  )
	return CCSItemCellBase:create("ui_layout/knight_selectKnightItem.json")
end)


function HeroListItem:ctor(  )
	self._heroIndex = -1

	self:attachImageTextForBtn("Button_select", "ImageView_9032")
	self:registerBtnClickEvent("Button_select", function ( widget )
		--local knightId = G_Me.bagData.knightsData:getKnightByIndex(self._heroIndex)
		--
        self:setClickCell()
		self:selectedCell(self._heroIndex, 0)
	end)

	self:registerWidgetClickEvent("ImageView_hero_back", function ( widget )
		__Log("ImageView_hero_back: click hero index=%d", self._heroIndex or 0)
		if self._heroIndex < 1 then 
			return 
		end

		local heroDesc = require("app.scenes.hero.HeroDescLayer")
		local layer = heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), self._heroIndex, false)
	end)	

	--self:enableLabelStroke("Label_level", Colors.strokeBlack, 1 )
	--self:enableLabelStroke("Label_zizhi_value", Colors.strokeBlack, 1 )
	self:enableLabelStroke("Label_name", Colors.strokeBlack, 1 )
	self:enableLabelStroke("Label_jingjie", Colors.strokeBlack, 1 )
	self:enableLabelStroke("Label_ji_pan_count", Colors.strokeBlack, 1 )
	--local label = self:getLabelByName("Label_zizhi")
	--if label then
	--	label:createStroke(Colors.strokeBlack, 1)
	--end
	--label = self:getLabelByName("Label_level_title")
	--if label then
	--	label:createStroke(Colors.strokeBlack, 1)
	--end
end

function HeroListItem:updateHero( knightId, hejiIds, jipanCount )
	if knightId == nil  or self._heroIndex == knightId then
		return 
	end
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo == nil then
		__LogError("HeroListItem:updateHero: knightInfo is nil")
		return 
	end

	self._heroIndex = knightId
	hejiIds = hejiIds or {}
	jipanCount = jipanCount or 0

	local teamId = G_Me.formationData:getKnightTeamId(knightId)
	self:showWidgetByName("ImageView_wearon", teamId > 0 and true or false)
	self:enableWidgetByName("Button_select", (teamId == nil or teamId <= 0) and true or false)

	local baseId = knightInfo["base_id"] or 0
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	else
		__LogError("knightinfo is nil for baseId:%d", baseId)
	end

	local icon = self:getImageViewByName("ImageView_hero_head")
	if icon ~= nil then
		--icon:removeChildByTag(1000, true)
		local heroPath = G_Path.getKnightIcon(resId)
		--local heroSprite = CCSprite:create(heroPath)
    	--icon:addNode(heroSprite, 0, 1000)
    	--__Log("heroPath:%s", heroPath)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
	end

	local pingji = self:getImageViewByName("ImageView_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo.quality))  
    end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightBaseInfo.quality])
		name:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "Default Name")		
	end

	local jingjie = self:getLabelByName("Label_jingjie")
	if jingjie then 
		jingjie:setColor(Colors.qualityColors[knightBaseInfo.quality])
		jingjie:setText(knightBaseInfo.advanced_level > 0 and "+"..knightBaseInfo.advanced_level or "", true)
	end
	--self:showTextWithLabel("Label_level", ""..knightInfo["level"])
	self:showTextWithLabel("Label_level", G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue=knightInfo and knightInfo["level"] or 1}))

	-- GlobalFunc.loadStars(self, 
	-- 	{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5", "ImageView_star_6", },
	-- 	knightBaseInfo and knightBaseInfo.star or 0, 1, G_Path.getListStarIcon())

	local panel = self:getPanelByName("Panel_8564")
	if panel then 
		panel:requestDoLayout()
	end

	self:showWidgetByName("Label_heji_desc", (#hejiIds > 0) or (jipanCount > 0))
	if #hejiIds > 0 then 
		local knightNames = ""
		local knightIdArr = {}
		for key, value in pairs(hejiIds) do 
			local baseInfo = knight_info.get(value)
			if baseInfo and not knightIdArr[value] then 
				knightIdArr[value] = 1
				knightNames = knightNames..baseInfo.name
			end
		end
		self:showTextWithLabel("Label_heji_desc", G_lang:get("LANG_KNIGHT_HEJI_ACTIVATE_DESC", {knightName=knightNames}))
	elseif jipanCount > 0 then 
		self:showTextWithLabel("Label_heji_desc", G_lang:get("LANG_KNIGHT_JIPAN_ACTIVATE_DESC", {count=jipanCount}))
	end
	--self:showWidgetByName("Image_can_heji", hejiId > 0)
	--self:showWidgetByName("Image_can_jipan", (hejiId < 1) and (jipanCount > 0))
	--self:showTextWithLabel("Label_ji_pan_count", "+"..jipanCount)
end


return HeroListItem