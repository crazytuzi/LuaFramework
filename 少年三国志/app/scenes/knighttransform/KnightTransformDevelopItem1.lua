

local KnightTransformConst = require("app.const.KnightTransformConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
local KnightTransformDevelopItem1 = class("KnightTransformDevelopItem1", UFCCSNormalLayer)

function KnightTransformDevelopItem1.create(nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
	local szJson = "ui_layout/KnightTransform_DevelopItem1.json"
	return KnightTransformDevelopItem1.new(szJson, nil, nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
end

function KnightTransformDevelopItem1:ctor(json, param, nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
	self.super.ctor(self, json, param, ...)

	self._nDevelopType = nDevelopType
	self._nSourceKnightId = nSourceKnightId
	self._nTargetKnightBaseId = nTargetKnightBaseId
	self._nKnightType = KnightTransformConst.KNIGHT_TYPE.SOURCE

	if self._nTargetKnightBaseId ~= nil then
		self._nKnightType = KnightTransformConst.KNIGHT_TYPE.TARGET
	end

	if self._nKnightType == KnightTransformConst.KNIGHT_TYPE.SOURCE then
		self:_initSourceKnightInfo()
	else
		self:_initTargetKnightInfo()
	end
end

function KnightTransformDevelopItem1:onLayerEnter()
	
end

function KnightTransformDevelopItem1:onLayerExit()
	
end

function KnightTransformDevelopItem1:_initSourceKnightInfo()
	CommonFunc._updateLabel(self, "Label_Title", {text=G_lang:get("LANG_KNIGHT_TRANSFORM_BEFORE"), stroke=Colors.strokeBrown})

	local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
	if not tSourceKnight then
		return
	end

	local nBaseId = tSourceKnight["base_id"]
	local tSourceKnightTmpl = knight_info.get(nBaseId)
	if not tSourceKnightTmpl then
		return
	end
	local nResId = tSourceKnightTmpl.res_id

	CommonFunc._updateImageView(self, "ImageView_hero_head", {texture=G_Path.getKnightIcon(nResId), texType=UI_TEX_TYPE_LOCAL})
	CommonFunc._updateImageView(self, "ImageView_pingji", {texture=G_Path.getAddtionKnightColorImage(tSourceKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	CommonFunc._updateLabel(self, "Label_KnightName", {text=tSourceKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tSourceKnightTmpl.quality]})

	local szDevelop = ""
	local szDevelopValue = ""
	local tAttrList = { 0, 0, 0, 0}
	local curKnightAttr = nil
	local showSkill = false
	local nLevel = tSourceKnight.level
	local isTypeVisible = true 
	if self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.LEVELUP then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_1")
		szDevelopValue = nLevel

	--	curKnightAttr = G_Me.bagData.knightsData:getKnightAttr1(self._nSourceKnightId)

		if tSourceKnightTmpl.damage_type == 1 then
			-- 武将是物攻类型
			tAttrList[1] = tSourceKnightTmpl.base_physical_attack + (nLevel-1) * tSourceKnightTmpl.develop_physical_attack
			tAttrList[2] = tSourceKnightTmpl.base_hp + (nLevel-1) * tSourceKnightTmpl.develop_hp
			tAttrList[3] = tSourceKnightTmpl.base_physical_defence + (nLevel-1) * tSourceKnightTmpl.develop_physical_defence
			tAttrList[4] = tSourceKnightTmpl.base_magical_defence + (nLevel-1) * tSourceKnightTmpl.develop_magical_defence
		else
			-- 武将是法攻类型
			tAttrList[1] = tSourceKnightTmpl.base_magical_attack + (nLevel-1) * tSourceKnightTmpl.develop_magical_attack
			tAttrList[2] = tSourceKnightTmpl.base_hp + (nLevel-1) * tSourceKnightTmpl.develop_hp
			tAttrList[3] = tSourceKnightTmpl.base_physical_defence + (nLevel-1) * tSourceKnightTmpl.develop_physical_defence
			tAttrList[4] = tSourceKnightTmpl.base_magical_defence + (nLevel-1) * tSourceKnightTmpl.develop_magical_defence
		end

		showSkill = false
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.BREAK then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_2")
		szDevelopValue = tSourceKnightTmpl.advanced_level
		if tSourceKnightTmpl.damage_type == 1 then
			-- 武将是物攻类型
			tAttrList[1] = tSourceKnightTmpl.base_physical_attack + (nLevel-1) * tSourceKnightTmpl.develop_physical_attack
			tAttrList[2] = tSourceKnightTmpl.base_hp + (nLevel-1) * tSourceKnightTmpl.develop_hp
			tAttrList[3] = tSourceKnightTmpl.base_physical_defence + (nLevel-1) * tSourceKnightTmpl.develop_physical_defence
			tAttrList[4] = tSourceKnightTmpl.base_magical_defence + (nLevel-1) * tSourceKnightTmpl.develop_magical_defence
		else
			-- 武将是法攻类型
			tAttrList[1] = tSourceKnightTmpl.base_magical_attack + (nLevel-1) * tSourceKnightTmpl.develop_magical_attack
			tAttrList[2] = tSourceKnightTmpl.base_hp + (nLevel-1) * tSourceKnightTmpl.develop_hp
			tAttrList[3] = tSourceKnightTmpl.base_physical_defence + (nLevel-1) * tSourceKnightTmpl.develop_physical_defence
			tAttrList[4] = tSourceKnightTmpl.base_magical_defence + (nLevel-1) * tSourceKnightTmpl.develop_magical_defence
		end
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.FOSTER then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_3")
		szDevelopValue = 110
		isTypeVisible = false


		local trainingData = tSourceKnight and tSourceKnight["training"] or nil
		local calcTrainingRange = G_Me.bagData.knightsData:calcTraingRange(nLevel, nBaseId)
		if not tSourceKnight or not trainingData or not calcTrainingRange then
			return 
		end
		local maxRange = calcTrainingRange["at_max"]
		tAttrList[1] = trainingData["at"].."/"..maxRange
		maxRange = calcTrainingRange["hp_max"]
		tAttrList[2] = trainingData["hp"].."/"..maxRange
		maxRange = calcTrainingRange["pd_max"]
		tAttrList[3] = trainingData["pd"].."/"..maxRange
		maxRange = calcTrainingRange["md_max"]
		tAttrList[4] = trainingData["md"].."/"..maxRange
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.DESTINY then
		local curHaloLevel = tSourceKnight and tSourceKnight.halo_level or 1
		local tHaloTmpl = knight_halo_info.get(curHaloLevel)
		if not tHaloTmpl then
			return
		end

		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_4")
		szDevelopValue = tHaloTmpl.level

		local function formatText(nAttr)
			nAttr = nAttr or 0
			return "+"..(nAttr/10).."%"
		end

		tAttrList[1] = formatText(tHaloTmpl.attack_add)
		tAttrList[2] = formatText(tHaloTmpl.health_add)
		tAttrList[3] = formatText(tHaloTmpl.phy_defence_add)
		tAttrList[4] = formatText(tHaloTmpl.magic_defence_add)

		-- 技能
		local tActiveSkillTmpl = skill_info.get(tSourceKnightTmpl.active_skill_id)
		local tUniteSkillTmpl = skill_info.get(tSourceKnightTmpl.unite_skill_id)
		if not tActiveSkillTmpl then
			return 
		end
		showSkill = true
		CommonFunc._updateLabel(self, "Label_Skill1", {text=tActiveSkillTmpl.name})
		CommonFunc._updateLabel(self, "Label_SkillValue1", {text=G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue=tHaloTmpl.level})})
		CommonFunc._updateLabel(self, "Label_Skill2", {text=tUniteSkillTmpl and tUniteSkillTmpl.name or ""})
		CommonFunc._updateLabel(self, "Label_SkillValue2", {text=G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue=tHaloTmpl.level})})
		self:showWidgetByName("Panel_Skill2", tSourceKnightTmpl.unite_skill_id ~= 0)

		for i=1, 2 do
			local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
		        self:getImageViewByName('Image_Skill'..i),
		        self:getLabelByName('Label_Skill'..i),
		        self:getLabelByName('Label_SkillValue'..i),
		    }, "L")
		    self:getImageViewByName('Image_Skill'..i):setPositionXY(alignFunc(1))
		    self:getLabelByName('Label_Skill'..i):setPositionXY(alignFunc(2))
		    self:getLabelByName('Label_SkillValue'..i):setPositionXY(alignFunc(3))
		end
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.GOD then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_6")
		local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(tSourceKnight.id)
		szDevelopValue = HeroGodCommon.getDisplyLevel(nowGodLevel)

		local attrInfos = G_Me.bagData.knightsData:getGodAttrs(tSourceKnight.id)

		tAttrList = attrInfos

		showSkill = false
	end


	CommonFunc._updateLabel(self, "Label_Develop", {text=szDevelop, visible=isTypeVisible})
	CommonFunc._updateLabel(self, "Label_DevelopValue", {text=szDevelopValue, visible=isTypeVisible})
	for i=1, 4 do
		CommonFunc._updateLabel(self, "Label_Attr"..i, {text=G_lang:get("LANG_KNIGHT_TRANSFORM_ATTR_TYPE_"..i)})
		CommonFunc._updateLabel(self, "Label_AttrValue"..i, {text=tAttrList[i]})
	end

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Develop'),
        self:getLabelByName('Label_DevelopValue'),
    }, "L")
    self:getLabelByName('Label_Develop'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_DevelopValue'):setPositionXY(alignFunc(2))

    for i=1, 4 do
	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, i*10), {
	        self:getLabelByName('Label_Attr'..i),
	        self:getLabelByName('Label_AttrValue'..i),
	    }, "L")
	    self:getLabelByName('Label_Attr'..i):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_AttrValue'..i):setPositionXY(alignFunc(2))
    end

    self:showWidgetByName("Panel_Skill", showSkill)
end

function KnightTransformDevelopItem1:_initTargetKnightInfo()
	CommonFunc._updateLabel(self, "Label_Title", {text=G_lang:get("LANG_KNIGHT_TRANSFORM_AFTER"), stroke=Colors.strokeBrown})

	local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
	if not tSourceKnight then
		return
	end

	local nBaseId = self._nTargetKnightBaseId
	local tTargetKnightTmpl = knight_info.get(nBaseId)
	if not tTargetKnightTmpl then
		return
	end
	local nResId = tTargetKnightTmpl.res_id

	CommonFunc._updateImageView(self, "ImageView_hero_head", {texture=G_Path.getKnightIcon(nResId), texType=UI_TEX_TYPE_LOCAL})
	CommonFunc._updateImageView(self, "ImageView_pingji", {texture=G_Path.getAddtionKnightColorImage(tTargetKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	CommonFunc._updateLabel(self, "Label_KnightName", {text=tTargetKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tTargetKnightTmpl.quality]})

	local szDevelop = ""
	local szDevelopValue = ""
	local tAttrList = { 0, 0, 0, 0}
	local curKnightAttr = nil
	local showSkill = false
	local nLevel = tSourceKnight.level or 0
	local isTypeVisible = true 
	if self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.LEVELUP then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_1")
		szDevelopValue = nLevel

	--	curKnightAttr = G_Me.bagData.knightsData:getKnightAttr1(self._nSourceKnightId)

		if tTargetKnightTmpl.damage_type == 1 then
			-- 武将是物攻类型
			tAttrList[1] = tTargetKnightTmpl.base_physical_attack + (nLevel-1) * tTargetKnightTmpl.develop_physical_attack
			tAttrList[2] = tTargetKnightTmpl.base_hp + (nLevel-1) * tTargetKnightTmpl.develop_hp
			tAttrList[3] = tTargetKnightTmpl.base_physical_defence + (nLevel-1) * tTargetKnightTmpl.develop_physical_defence
			tAttrList[4] = tTargetKnightTmpl.base_magical_defence + (nLevel-1) * tTargetKnightTmpl.develop_magical_defence
		else
			-- 武将是法攻类型
			tAttrList[1] = tTargetKnightTmpl.base_magical_attack + (nLevel-1) * tTargetKnightTmpl.develop_magical_attack
			tAttrList[2] = tTargetKnightTmpl.base_hp + (nLevel-1) * tTargetKnightTmpl.develop_hp
			tAttrList[3] = tTargetKnightTmpl.base_physical_defence + (nLevel-1) * tTargetKnightTmpl.develop_physical_defence
			tAttrList[4] = tTargetKnightTmpl.base_magical_defence + (nLevel-1) * tTargetKnightTmpl.develop_magical_defence
		end

		showSkill = false
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.BREAK then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_2")
		szDevelopValue = tTargetKnightTmpl.advanced_level
		if tTargetKnightTmpl.damage_type == 1 then
			-- 武将是物攻类型
			tAttrList[1] = tTargetKnightTmpl.base_physical_attack + (nLevel-1) * tTargetKnightTmpl.develop_physical_attack
			tAttrList[2] = tTargetKnightTmpl.base_hp + (nLevel-1) * tTargetKnightTmpl.develop_hp
			tAttrList[3] = tTargetKnightTmpl.base_physical_defence + (nLevel-1) * tTargetKnightTmpl.develop_physical_defence
			tAttrList[4] = tTargetKnightTmpl.base_magical_defence + (nLevel-1) * tTargetKnightTmpl.develop_magical_defence
		else
			-- 武将是法攻类型
			tAttrList[1] = tTargetKnightTmpl.base_magical_attack + (nLevel-1) * tTargetKnightTmpl.develop_magical_attack
			tAttrList[2] = tTargetKnightTmpl.base_hp + (nLevel-1) * tTargetKnightTmpl.develop_hp
			tAttrList[3] = tTargetKnightTmpl.base_physical_defence + (nLevel-1) * tTargetKnightTmpl.develop_physical_defence
			tAttrList[4] = tTargetKnightTmpl.base_magical_defence + (nLevel-1) * tTargetKnightTmpl.develop_magical_defence
		end
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.FOSTER then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_3")
		szDevelopValue = 110
		isTypeVisible = false

		local trainingData = tSourceKnight and tSourceKnight["training"] or nil
		local calcTrainingRange = G_Me.bagData.knightsData:calcTraingRange(nLevel, nBaseId)
		if not tSourceKnight or not trainingData or not calcTrainingRange then
			return 
		end
		local maxRange = calcTrainingRange["at_max"]
		tAttrList[1] = math.min(trainingData["at"], maxRange).."/"..maxRange
		maxRange = calcTrainingRange["hp_max"]
		tAttrList[2] = math.min(trainingData["hp"], maxRange).."/"..maxRange
		maxRange = calcTrainingRange["pd_max"]
		tAttrList[3] = math.min(trainingData["pd"], maxRange).."/"..maxRange
		maxRange = calcTrainingRange["md_max"]
		tAttrList[4] = math.min(trainingData["md"], maxRange).."/"..maxRange
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.DESTINY then
		local curHaloLevel = tSourceKnight and tSourceKnight.halo_level or 1
		local tHaloTmpl = knight_halo_info.get(curHaloLevel)
		if not tHaloTmpl then
			return
		end

		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_4")
		szDevelopValue = tHaloTmpl.level

		local function formatText(nAttr)
			nAttr = nAttr or 0
			return "+"..(nAttr/10).."%"
		end

		tAttrList[1] = formatText(tHaloTmpl.attack_add)
		tAttrList[2] = formatText(tHaloTmpl.health_add)
		tAttrList[3] = formatText(tHaloTmpl.phy_defence_add)
		tAttrList[4] = formatText(tHaloTmpl.magic_defence_add)

		-- 技能
		local tActiveSkillTmpl = skill_info.get(tTargetKnightTmpl.active_skill_id)
		local tUniteSkillTmpl = skill_info.get(tTargetKnightTmpl.unite_skill_id)
		if not tActiveSkillTmpl then
			return 
		end
		showSkill = true
		CommonFunc._updateLabel(self, "Label_Skill1", {text=tActiveSkillTmpl.name})
		CommonFunc._updateLabel(self, "Label_SkillValue1", {text=G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue=tHaloTmpl.level})})
		CommonFunc._updateLabel(self, "Label_Skill2", {text=tUniteSkillTmpl and tUniteSkillTmpl.name or ""})
		CommonFunc._updateLabel(self, "Label_SkillValue2", {text=G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue=tHaloTmpl.level})})
		self:showWidgetByName("Panel_Skill2", tTargetKnightTmpl.unite_skill_id ~= 0)

		for i=1, 2 do
			local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
		        self:getImageViewByName('Image_Skill'..i),
		        self:getLabelByName('Label_Skill'..i),
		        self:getLabelByName('Label_SkillValue'..i),
		    }, "L")
		    self:getImageViewByName('Image_Skill'..i):setPositionXY(alignFunc(1))
		    self:getLabelByName('Label_Skill'..i):setPositionXY(alignFunc(2))
		    self:getLabelByName('Label_SkillValue'..i):setPositionXY(alignFunc(3))
		end
	elseif self._nDevelopType == KnightTransformConst.DEVELOP_TYPE.GOD then
		szDevelop = G_lang:get("LANG_KNIGHT_TRANSFORM_DEVELOP_TYPE_6")
		local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(tSourceKnight.id)
		szDevelopValue = HeroGodCommon.getDisplyLevel(nowGodLevel)

		local attrInfos = G_Me.bagData.knightsData:getGodAttrsTablesInfo(tTargetKnightTmpl, tSourceKnight.level, tSourceKnight.pulse_level)

		tAttrList = attrInfos

		showSkill = false
	end

	CommonFunc._updateLabel(self, "Label_Develop", {text=szDevelop, visible=isTypeVisible})
	CommonFunc._updateLabel(self, "Label_DevelopValue", {text=szDevelopValue, visible=isTypeVisible})
	for i=1, 4 do
		CommonFunc._updateLabel(self, "Label_Attr"..i, {text=G_lang:get("LANG_KNIGHT_TRANSFORM_ATTR_TYPE_"..i)})
		CommonFunc._updateLabel(self, "Label_AttrValue"..i, {text=tAttrList[i]})
	end

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Develop'),
        self:getLabelByName('Label_DevelopValue'),
    }, "L")
    self:getLabelByName('Label_Develop'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_DevelopValue'):setPositionXY(alignFunc(2))

    for i=1, 4 do
	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, i*10), {
	        self:getLabelByName('Label_Attr'..i),
	        self:getLabelByName('Label_AttrValue'..i),
	    }, "L")
	    self:getLabelByName('Label_Attr'..i):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_AttrValue'..i):setPositionXY(alignFunc(2))
    end

    self:showWidgetByName("Panel_Skill", showSkill)

end

return KnightTransformDevelopItem1