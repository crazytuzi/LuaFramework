--KnightInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.knight_info")
local knightPic = require("app.scenes.common.KnightPic")
local HeroGodAttrPreviewLargeLayer = require "app.scenes.herofoster.god.HeroGodAttrPreviewLargeLayer"
local KnightConst = require("app.const.KnightConst")

local KnightInfoPage = class("KnightInfoPage", KnightPageBase)

function KnightInfoPage.create(...)
	return KnightPageBase._create_(KnightInfoPage.new(...), "ui_layout/BaseInfo_KnightInfo.json", ...)
end

function KnightInfoPage.delayCreate( ... )
	local page = KnightPageBase._create_(KnightInfoPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_KnightInfo.json")
	return page
end

function KnightInfoPage:ctor( baseId, fragmentId, scenePack, ... )
	self._isPlayingVoice = false
	self._lastCommonVoice = false
	self.super.ctor(self, baseId, fragmentId, scenePack, ...)

	self._scenePack = scenePack
end

function KnightInfoPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_skill_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_association_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_skill_tianfu", Colors.strokeBrown, 2 )

	self:registerBtnClickEvent("Button_get", function ( ... )
		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, self._baseId, self._scenePack)
	end)

	local knightInfo = knight_info.get(self._baseId)
	if not knightInfo then 
		return
	end

	local function isGodPreviewShow()
		local isShow = knightInfo.potential >= KnightConst.KNIGHT_GOD_POTENTIAL and knightInfo.type ~= 1
		local FunctionLevelConst = require("app.const.FunctionLevelConst")
		require("app.cfg.function_level_info")
		if G_Me.userData.level < function_level_info.get(FunctionLevelConst.KNIGHT_GOD).level - 5 then
			isShow = false
		end
		return isShow
	end

	self:showWidgetByName("Button_God_Preview", isGodPreviewShow())
	self:registerBtnClickEvent("Button_God_Preview", handler(self, self._godPreviewOnclick))

	self:registerBtnClickEvent("Button_play_voice", function ( ... )
		if self._isPlayingVoice then 
			return 
		end

		local voiceName  = self._lastCommonVoice and knightInfo.skill_sound or knightInfo.common_sound
		self._lastCommonVoice = not self._lastCommonVoice
		if voiceName == "0" then 
			voiceName = knightInfo.common_sound
		end
		G_SoundManager:playSound(voiceName)
		if self._parentLayer and self._parentLayer.callAfterDelayTime then
			self._isPlayingVoice = true
			self._parentLayer:callAfterDelayTime(4.0, nil, function ( ... )
				self._isPlayingVoice = false
			end)
		end
	end)

	local heroPanel = self:getPanelByName("Panel_knightPic") 
    if heroPanel then
		knightPic.createKnightPic(knightInfo.res_id, heroPanel)
    end

    local label = self:getLabelByName("Label_name")
    if label then 
    	label:setColor(Colors.getColor(knightInfo and knightInfo.quality or 1))
    	label:setText(knightInfo.name)
    end

    local image = self:getImageViewByName("Image_hurt_type")
	if image then
		local groupPath, imgType = G_Path.getJobTipsIcon(knightInfo.character_tips)
		if groupPath then
			image:loadTexture(groupPath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

	image = self:getImageViewByName("Image_county")
	if image then
		local groupPath, imgType = G_Path.getKnightGroupIcon(knightInfo and knightInfo.group or -1)
		if groupPath then
			image:loadTexture(groupPath, imgType)
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end

	local scrollView = self:getScrollViewByName("ScrollView_detail")
	if scrollView then 
		local bottomY = 5
		local scrollSize = scrollView:getInnerContainerSize()

		bottomY = self:_loadTianfuInfo( knightInfo, bottomY )
		bottomY = self:_loadAssociationInfo(knightInfo, bottomY)
		bottomY = self:_loadSkillInfo(knightInfo, bottomY, scrollSize.height)

		if bottomY > scrollSize.height then
			scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
		end
	end
end

function KnightInfoPage:_godPreviewOnclick()

	local knightBaseInfo = knight_info.get(self._baseId)
	if not knightBaseInfo then 
		return
	end

	local baseInfo = knightBaseInfo
	if baseInfo.advanced_level < 8 then
		for i =1, 8 do
			if baseInfo.advanced_level == 8 then
				break
			end
			baseInfo = knight_info.get(baseInfo.advanced_id)
		end
	end

	if not baseInfo then
		return
	end

	for i = 1, 6 do
		if baseInfo.god_id and baseInfo.god_id == 0 then
			break
		end
		baseInfo = knight_info.get(baseInfo.god_id)
	end

	if not baseInfo then
		return
	end

	--主角
	if baseInfo.type == 1 then
		return
	end

	HeroGodAttrPreviewLargeLayer.show(nil, baseInfo, true, true)
end

function KnightInfoPage:_loadSkillInfo( knightInfo, bottomY, scrollHeight )
	local panel = self:getPanelByName("Panel_skill")
	if not panel or not knightInfo then 
		return bottomY
	end

	scrollHeight = scrollHeight or 0
	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 0

	local damageTxt = G_lang:get("LANG_DRESS_ATTACK_TYPE"..knightInfo.damage_type)

	local super_unite_skill_id = knightInfo.super_unite_skill_id
	if super_unite_skill_id > 0 then 
		local skillInfo = skill_info.get(super_unite_skill_id)
		if skillInfo then
			local heSkill = "["..skillInfo.name.." Lv.1]  "..G_GlobalFunc.formatText(skillInfo.directions, 
	 			{num1 = skillInfo.formula_value1_1,
	 			 num2 = skillInfo.formula_value1_2, 
	 			 damage_type = damageTxt,test = ""})

			local label = GlobalFunc.createGameLabel(heSkill, 22, Colors.inActiveSkill ,
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
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	if knightInfo.unite_skill_id > 0 then 
		local skillInfo = skill_info.get(knightInfo.unite_skill_id)
		if skillInfo then
			local heSkill = "["..skillInfo.name.." Lv.1]  "..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,
				 num2 = skillInfo.formula_value1_2, 
				 damage_type = damageTxt,test = ""})

			local label = GlobalFunc.createGameLabel(heSkill, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_he.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	if knightInfo.active_skill_id > 0 then 
		local skillInfo = skill_info.get(knightInfo.active_skill_id)
		if skillInfo then
			local jiSkill = "["..skillInfo.name.." Lv.1]  "..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,
				 num2 = skillInfo.formula_value1_2, 
				 damage_type = damageTxt,test = ""})

			local label = GlobalFunc.createGameLabel(jiSkill, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	if knightInfo.common_id > 0 then 
		local skillInfo = skill_info.get(knightInfo.common_id)
		if skillInfo then 
			local skillText = "["..skillInfo.name.."]  "..G_GlobalFunc.formatText(skillInfo.directions, 
				{num1 = skillInfo.formula_value1_1,damage_type = damageTxt,})

			local label = GlobalFunc.createGameLabel(skillText, 22, Colors.inActiveSkill,
		 		nil, CCSizeMake(size.width - 50, 0), true)
			local labelSize = label:getSize()
			local labelPosX = size.width - labelSize.width/2 - 5
			label:setPosition(ccp(labelPosX, startYpos + labelSize.height/2))
			panel:addChild(label)
			startYpos = startYpos + labelSize.height

			labelPosX = labelPosX - labelSize.width/2
			local img = ImageView:create()
			img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
			local imgSize = img:getSize()
			img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, startYpos - imgSize.height/2))
			panel:addChild(img)

			startYpos = startYpos + 5
		end
	end

	startYpos = startYpos + 5
	local title = self:getWidgetByName("Image_title_skill")
	if title then 
		local titleSize = title:getSize()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos))
	if startYpos + initYPos < scrollHeight then 
		panel:setPosition(ccp(0, scrollHeight - startYpos))
	else
		panel:setPosition(ccp(0, initYPos))
	end
	
	bottomY = bottomY + 10

	return bottomY
end

function KnightInfoPage:_loadAssociationInfo( knightInfo, bottomY )
	local panel = self:getPanelByName("Panel_association")
	if not panel or not knightInfo then 
		return bottomY
	end

	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 0
	require("app.cfg.association_info")
	local addJipanContent = function ( associationId, isActive )
		local associationInfo = association_info.get(associationId)
		if associationInfo == nil then
			return 
		end
		
		local desc = string.format("[%s] %s", associationInfo.name, associationInfo.directions)
		local label = GlobalFunc.createGameLabel(desc, 22, Colors.inActiveSkill,
		 nil, CCSizeMake(size.width - 15, 0), true)

		local labelSize = label:getSize()

		label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
		panel:addChild(label)
		startYpos = startYpos + labelSize.height
	end

	addJipanContent(knightInfo.association_8)
	addJipanContent(knightInfo.association_7)
	addJipanContent(knightInfo.association_6)
	addJipanContent(knightInfo.association_5)
	addJipanContent(knightInfo.association_4)
	addJipanContent(knightInfo.association_3)
	addJipanContent(knightInfo.association_2)
	addJipanContent(knightInfo.association_1)

	if startYpos == 0 then
		panel:setVisible(false) 
		return bottomY
	end

	startYpos = startYpos + 5
	local title = self:getWidgetByName("Image_title_association")
	if title then 
		local titleSize = title:getSize()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

function KnightInfoPage:_loadTianfuInfo( knightInfo, bottomY )
	local panel = self:getPanelByName("Panel_tianfu")
	if not panel or not knightInfo then 
		return bottomY
	end

	local size = panel:getSize()
	local initYPos = bottomY
	local startYpos = 0
	require("app.cfg.passive_skill_info")
	local addTianfuContent = function ( passiveId )
		local passiveInfo = passive_skill_info.get(passiveId)
		if not passiveInfo then
			return 
		end

		local desc = string.format("[%s] %s", passiveInfo.name, passiveInfo.directions)
		local label = GlobalFunc.createGameLabel(desc, 22, Colors.inActiveSkill,
		 nil, CCSizeMake(size.width - 15, 0), true)

		local labelSize = label:getSize()

		label:setPosition(ccp(size.width/2, startYpos + labelSize.height/2))
		panel:addChild(label)
		startYpos = startYpos + labelSize.height
	end

	addTianfuContent(knightInfo.passive_skill_15)
	addTianfuContent(knightInfo.passive_skill_14)
	addTianfuContent(knightInfo.passive_skill_13)
	addTianfuContent(knightInfo.passive_skill_12)
	addTianfuContent(knightInfo.passive_skill_11)
	addTianfuContent(knightInfo.passive_skill_10)
	addTianfuContent(knightInfo.passive_skill_9)
	addTianfuContent(knightInfo.passive_skill_8)
	addTianfuContent(knightInfo.passive_skill_7)
	addTianfuContent(knightInfo.passive_skill_6)
	addTianfuContent(knightInfo.passive_skill_5)
	addTianfuContent(knightInfo.passive_skill_4)
	addTianfuContent(knightInfo.passive_skill_3)
	addTianfuContent(knightInfo.passive_skill_2)
	addTianfuContent(knightInfo.passive_skill_1)

	if startYpos == 0 then 
		panel:setVisible(false)
		return bottomY
	end
	startYpos = startYpos + 5
	local title = self:getWidgetByName("Image_title_tianfu")
	if title then 
		local titleSize = title:getSize()
		title:setPosition(ccp(size.width/2, startYpos + titleSize.height/2))
		startYpos = startYpos + titleSize.height
	end

	bottomY = startYpos + bottomY
	panel:setSize(CCSizeMake(size.width, bottomY - initYPos))
	panel:setPosition(ccp(0, initYPos))
	bottomY = bottomY + 10

	return bottomY
end

return KnightInfoPage
