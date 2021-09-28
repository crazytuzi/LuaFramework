--KnightInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")

local KnightSkillPage = class("KnightSkillPage", KnightPageBase)

function KnightSkillPage.create(...)
	return KnightPageBase._create_(KnightSkillPage.new(...), "ui_layout/BaseInfo_KnightSkill.json", ...)
end

function KnightSkillPage.delayCreate(...)
	local page = KnightPageBase._create_(KnightSkillPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_KnightSkill.json")
	return page
end

function KnightSkillPage:ctor( baseId, fragmentId, scenePack,... )
	self.super.ctor(self, baseId, fragmentId, scenePack,...)

	self._scenePack = scenePack
end

function KnightSkillPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_title_skill", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_title_knights", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_name_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name_3", Colors.strokeBrown, 1 )

	local knightInfo = knight_info.get(self._baseId)
	if not knightInfo then 
		return
	end
	local skillInfo = skill_info.get(knightInfo.unite_skill_id)
	if skillInfo then
		local heSkill = "["..skillInfo.name.." Lv.1]  "..G_GlobalFunc.formatText(skillInfo.directions, 
			{num1 = skillInfo.formula_value1_1,
			 num2 = skillInfo.formula_value1_2, test = ""})
		self:showTextWithLabel("Label_skill_desc", heSkill)

		self:_doLoadKnight(self._baseId, 1)
		self:_doLoadKnight(knightInfo.release_knight_1, 2)
		self:_doLoadKnight(knightInfo.release_knight_2, 3)

		
	else
		self:showWidgetByName("Panel_content", false)
		self:showWidgetByName("Label_tip", false)
	end
end

function KnightSkillPage:_doLoadKnight( baseId, index )
	if type(baseId) ~= "number" or type(index) ~= "number" then 
		return 
	end

	local knightInfo = knight_info.get(baseId)
	if not knightInfo then 
		self:showWidgetByName("Image_"..index, false)
		self:showWidgetByName("Image_add_"..index, false)
		return 
	end

	local icon = self:getImageViewByName("Image_icon_"..index)
	if icon ~= nil then
		local heroPath = G_Path.getKnightIcon(knightInfo.res_id)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
	end

	local pingji = self:getImageViewByName("Image_pingji_"..index)
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))  
    end

	local name = self:getLabelByName("Label_name_"..index)
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightInfo.quality])
		name:setText(knightInfo.name or "Default Name")		
	end

	self:registerBtnClickEvent("Image_icon_"..index, function ( ... )
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, baseId, self._scenePack)
		end)
end

return KnightSkillPage
