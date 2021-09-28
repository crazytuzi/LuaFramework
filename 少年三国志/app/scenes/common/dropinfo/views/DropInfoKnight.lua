
local DropInfoBaseView = require("app.scenes.common.dropinfo.DropInfoBaseView")


local DropInfoKnight = class("DropInfoTreasure", DropInfoBaseView)

function DropInfoKnight.create(...)
    return DropInfoKnight.new("ui_layout/dropinfo_DropInfoKnight.json", ...)
end

function DropInfoKnight:ctor( ... )
	self.super.ctor(self, ...)

	self:getLabelByName("Label_pu"):setFixedWidth(true)
	self:getLabelByName("Label_ji"):setFixedWidth(true)
	self:getLabelByName("Label_he"):setFixedWidth(true)

	self:getLabelByName("Label_tianfu_1"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_2"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_3"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_4"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_5"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_6"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_7"):setFixedWidth(true)
	self:getLabelByName("Label_tianfu_8"):setFixedWidth(true)

	self:getLabelByName("Label_jiban_1"):setFixedWidth(true)
	self:getLabelByName("Label_jiban_2"):setFixedWidth(true)
	self:getLabelByName("Label_jiban_3"):setFixedWidth(true)
	self:getLabelByName("Label_jiban_4"):setFixedWidth(true)
	self:getLabelByName("Label_jiban_5"):setFixedWidth(true)
	self:getLabelByName("Label_jiban_6"):setFixedWidth(true)
end

function DropInfoKnight:setData(type, value, isSubview)
    self:_addEvents()
     

	local knightBaseInfo = knight_info.get(value)
	if not knightBaseInfo then 
		return 
	end    

	--名字
    self:getLabelByName("Label_name"):setColor(Colors.qualityColors[knightBaseInfo.quality])
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_name"):setText(knightBaseInfo.name)

    self:getLabelByName("Label_title1"):createStroke(Colors.strokeBrown,1)
    
	self:getImageViewByName("ImageView_icon"):loadTexture( G_Path.getKnightPic(knightBaseInfo.res_id) )
	self:getImageViewByName("ImageView_knight_type"):loadTexture(G_Path.getKnightColorText(knightBaseInfo.quality))
	self:getImageViewByName("Image_zhengyin"):loadTexture(G_Path.getKnightGroupIcon(knightBaseInfo.group))

	local knightAttributes = G_Me.bagData.knightsData:getKnightAttributes(knightBaseInfo and knightBaseInfo.id, 1) or {}
	self:showTextWithLabel("Label_attr1_value", knightAttributes["at"] or 0)
	self:showTextWithLabel("Label_attr2_value", knightAttributes["hp"] or 0)
	self:showTextWithLabel("Label_attr3_value", knightAttributes["pd"] or 0)
	self:showTextWithLabel("Label_attr4_value", knightAttributes["md"] or 0)
	self:showTextWithLabel("Label_exp_value", knightBaseInfo.food_exp)

	self:showTextWithLabel("Label_desc", knightBaseInfo.directions)

	-- skill info
	local puSkill = ""
	if knightBaseInfo.common_id > 0 then 
		local skillInfo = skill_info.get(knightBaseInfo.common_id)
		if skillInfo then
			puSkill = "["..skillInfo.name.."]"..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1})
		end
	end
	self:showTextWithLabel("Label_pu", puSkill)
	self:showWidgetByName("Image_pu", knightBaseInfo.active_skill_id > 0)

	local jiSkill = ""
	if knightBaseInfo.active_skill_id > 0 then
		local skillInfo = skill_info.get(knightBaseInfo.active_skill_id)
		if skillInfo then
			jiSkill = "["..skillInfo.name.."]"..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,
				 num2 = skillInfo.formula_value1_2})
		end
	end
	self:showTextWithLabel("Label_ji", jiSkill)
	self:showWidgetByName("Image_ji", knightBaseInfo.active_skill_id > 0)

	local heSkill = ""
	if knightBaseInfo.unite_skill_id > 0 then
		local skillInfo = skill_info.get(knightBaseInfo.unite_skill_id)
		if skillInfo then
			heSkill = "["..skillInfo.name.."]"..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,
				 num2 = skillInfo.formula_value1_2})
		end
	end
	self:showTextWithLabel("Label_he", heSkill)
	self:showWidgetByName("Image_he", knightBaseInfo.unite_skill_id > 0)

	local curTianfuIndex = 1
	local addTianfuContent = function ( passiveId )
		require("app.cfg.passive_skill_info")
		local label = self:getLabelByName("Label_tianfu_"..curTianfuIndex)
		local passiveInfo = passive_skill_info.get(passiveId)
		if passiveInfo == nil then
			return 
		end
		
		if label then
			label:setText("["..passiveInfo.name.."] "..passiveInfo.directions)
		end
		curTianfuIndex = curTianfuIndex + 1
	end
	-- tianfu content
	addTianfuContent(knightBaseInfo.passive_skill_1)
	addTianfuContent(knightBaseInfo.passive_skill_2)
	addTianfuContent(knightBaseInfo.passive_skill_3)
	addTianfuContent(knightBaseInfo.passive_skill_4)
	addTianfuContent(knightBaseInfo.passive_skill_5)
	addTianfuContent(knightBaseInfo.passive_skill_6)
	addTianfuContent(knightBaseInfo.passive_skill_7)
	addTianfuContent(knightBaseInfo.passive_skill_8)
	addTianfuContent(knightBaseInfo.passive_skill_9)
	addTianfuContent(knightBaseInfo.passive_skill_10)
	addTianfuContent(knightBaseInfo.passive_skill_11)
	addTianfuContent(knightBaseInfo.passive_skill_12)
	addTianfuContent(knightBaseInfo.passive_skill_13)
	addTianfuContent(knightBaseInfo.passive_skill_14)
	addTianfuContent(knightBaseInfo.passive_skill_15)

	local index = 1
	for index = curTianfuIndex, 8, 1 do 
		self:showWidgetByName("Label_tianfu_"..index, false)
	end

	local curJipanIndex = 1
	local addJipanContent = function ( associationId )
		require("app.cfg.association_info")
		local associationInfo = association_info.get(associationId)
		local label = self:getLabelByName("Label_jiban_"..curJipanIndex)
		if label then
			label:setVisible(associationInfo ~= nil)
		end
		if associationInfo == nil then
			return 
		end
		
		if label then
			label:setText("["..associationInfo.name.."] "..associationInfo.directions)
		end
		curJipanIndex = curJipanIndex + 1
	end


	--jipan content
	addJipanContent(knightBaseInfo.association_1)
	addJipanContent(knightBaseInfo.association_2)
	addJipanContent(knightBaseInfo.association_3)
	addJipanContent(knightBaseInfo.association_4)
	addJipanContent(knightBaseInfo.association_5)
	addJipanContent(knightBaseInfo.association_6)
	addJipanContent(knightBaseInfo.association_7)
	addJipanContent(knightBaseInfo.association_8)
	index = 1
	for index = curJipanIndex, 8, 1 do 
		self:showWidgetByName("Label_jiban_"..index, false)
	end

	self:getLabelByName("Label_suite_txt_skill"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_suite_txt_jipan"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_suite_txt_tianfu"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_suite_txt_shuoming"):createStroke(Colors.strokeBrown,1)
end

function DropInfoKnight:_addEvents()
    self:registerBtnClickEvent("Button_close", function()
        self:_close()
    end)


end
return DropInfoKnight
