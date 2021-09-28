local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")


local KnightTransformTargetItem = class("KnightTransformTargetItem", function()
	return CCSItemCellBase:create("ui_layout/KnightTransform_TargetItem.json")
end)

function KnightTransformTargetItem:ctor(nSourceKnightId, selectedCallback)
	self._nSourceKnightId = nSourceKnightId
	self._selectedCallback = selectedCallback

	self._tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
	assert(self._tSourceKnight)
end

function KnightTransformTargetItem:updateItem(tTransformTmpl)
	if not tTransformTmpl then
		return
	end
	if not self._tSourceKnight then
		return
	end

	local nSourceKinghtBaseId = self._tSourceKnight["base_id"]
	local tSourceKnightTmpl = knight_info.get(nSourceKinghtBaseId)
	if not tSourceKnightTmpl then
		return
	end

	local nAdvancedLevel = tSourceKnightTmpl.advanced_level
	local nGodLevel = tSourceKnightTmpl.god_level

	local nAdvanceCode = tTransformTmpl.advanced_code
	local tKnightTmpl = nil
	for i=1, knight_info.getLength() do
		local tKnightBaseInfo = knight_info.indexOf(i)
		if tKnightBaseInfo and tKnightBaseInfo.advance_code == nAdvanceCode and tKnightBaseInfo.advanced_level == nAdvancedLevel 
		and tKnightBaseInfo.god_level == nGodLevel then
			tKnightTmpl = tKnightBaseInfo
		end
	end

	if not tKnightTmpl then
		return
	end

	-- 是不是稀有
	self:showWidgetByName("Image_Rare", tTransformTmpl.cost ~= 0)

	-- icon
	CommonFunc._updateImageView(self, "ImageView_hero_head", {texture=G_Path.getKnightIcon(tKnightTmpl.res_id), texType=UI_TEX_TYPE_LOCAL})
	-- quality frame 
	CommonFunc._updateImageView(self, "ImageView_pingji", {texture=G_Path.getAddtionKnightColorImage(tKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	-- name color
	local szName = tKnightTmpl.name
	if nAdvancedLevel > 0 then
		szName = tKnightTmpl.name .." +"..nAdvancedLevel
	end
	CommonFunc._updateLabel(self, "Label_name", {text=szName, color=Colors.qualityColors[tKnightTmpl.quality], stroke=Colors.strokeBrown})
	-- tips
	CommonFunc._updateLabel(self, "Label_knight_type", {text=G_lang.getKnightTypeStr(tKnightTmpl and tKnightTmpl.character_tips or 1)})

	-- 以下数据来自源武将
	-- 等级
	CommonFunc._updateLabel(self, "Label_level", {text=self._tSourceKnight.level})
	-- 天命
	CommonFunc._updateLabel(self, "Label_jingjie", {text=self._tSourceKnight.halo_level})
	-- 觉醒
	CommonFunc._updateLabel(self, "Label_juexing_value", {text=G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(self._tSourceKnight.awaken_level / 10), level=self._tSourceKnight.awaken_level % 10})})
	-- 觉醒星星
	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(self._tSourceKnight.id) or -1
	self:showWidgetByName("Image_star_1", stars >= 0)
    self:showWidgetByName("Image_star_2", stars >= 0)
    self:showWidgetByName("Image_star_3", stars >= 0)
    self:showWidgetByName("Image_star_4", stars >= 0)
    self:showWidgetByName("Image_star_5", stars >= 0)
    if stars >= 0 then 
        self:showWidgetByName("Image_star_1_full", stars >= 1)
        self:showWidgetByName("Image_star_2_full", stars >= 2)
        self:showWidgetByName("Image_star_3_full", stars >= 3)
        self:showWidgetByName("Image_star_4_full", stars >= 4)
        self:showWidgetByName("Image_star_5_full", stars >= 5)
    end
    
    local unlock = stars ~= -1
    self:showWidgetByName("Label_juexing_title", unlock)
    self:showWidgetByName("Label_juexing_value", unlock)

    self:getButtonByName("Button_Confirm"):setTag(tKnightTmpl.id)
    self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirm))

    local nCost = G_GlobalFunc.getKnightTransformCost(self._nSourceKnightId, tKnightTmpl.id)
    -- 变身花费
	CommonFunc._updateLabel(self, "Label_Cost", {text=nCost, color=G_Me.userData.gold >= nCost and Colors.lightColors.TITLE_01 or Colors.lightColors.TIPS_01, stroke=Colors.strokeBrown})

	-- 化神
    local godTitleLabel = self:getLabelByName("Label_God_Level")
    local godImage = self:getImageViewByName("Image_God_Level")
    if tKnightTmpl.god_level == 0 and self._tSourceKnight.pulse_level == 0 then
        godTitleLabel:setVisible(false)
        godImage:setVisible(false)
    else
        local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
        godTitleLabel:setVisible(true)
        godImage:setVisible(true)
        local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(self._tSourceKnight.id)
        godTitleLabel:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, tKnightTmpl.quality))
        godImage:loadTexture(G_Path.getGodQualityShuiYin(tKnightTmpl.quality))
    end
end

function KnightTransformTargetItem:_onConfirm(sender)
	local nBaseId = sender:getTag() or 0
	if nBaseId ~= 0 then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_SELECT_TARGET_KINGHT_SUCC, nil, false, nBaseId)
	end
	if self._selectedCallback then
		self._selectedCallback()
	end
end

return KnightTransformTargetItem