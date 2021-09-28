local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")


local KnightTransformSourceItem = class("KnightTransformSourceItem", function()
	return CCSItemCellBase:create("ui_layout/KnightTransform_SourceItem.json")
end)

function KnightTransformSourceItem:ctor(selectedCallback)
	self._selectedCallback = selectedCallback
end

function KnightTransformSourceItem:updateItem(tKnight)
	if not tKnight then
		return
	end


	local nBaseId = tKnight["base_id"]
	local tKnightTmpl = knight_info.get(nBaseId)
	if not tKnightTmpl then
		return
	end

	-- icon
	CommonFunc._updateImageView(self, "ImageView_hero_head", {texture=G_Path.getKnightIcon(tKnightTmpl.res_id), texType=UI_TEX_TYPE_LOCAL})
	-- quality frame 
	CommonFunc._updateImageView(self, "ImageView_pingji", {texture=G_Path.getAddtionKnightColorImage(tKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	-- name color
	local szName = tKnightTmpl.name
	if tKnightTmpl.advanced_level > 0 then
		szName = tKnightTmpl.name .." +"..tKnightTmpl.advanced_level
	end
	CommonFunc._updateLabel(self, "Label_name", {text=szName, color=Colors.qualityColors[tKnightTmpl.quality], stroke=Colors.strokeBrown})
	-- tips
	CommonFunc._updateLabel(self, "Label_knight_type", {text=G_lang.getKnightTypeStr(tKnightTmpl and tKnightTmpl.character_tips or 1)})
	-- 等级
	CommonFunc._updateLabel(self, "Label_level", {text=tKnight.level})
	-- 天命
	CommonFunc._updateLabel(self, "Label_jingjie", {text=tKnight.halo_level})
	-- 觉醒
	CommonFunc._updateLabel(self, "Label_juexing_value", {text=G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(tKnight.awaken_level / 10), level=tKnight.awaken_level % 10})})
	-- 觉醒星星
	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(tKnight.id) or -1
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

    self:getButtonByName("Button_Confirm"):setTag(tKnight.id)
    self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirm))

    -- 化神
    local godTitleLabel = self:getLabelByName("Label_God_Level")
    local godImage = self:getImageViewByName("Image_God_Level")
    if tKnightTmpl.god_level == 0 and tKnight.pulse_level == 0 then
        godTitleLabel:setVisible(false)
        godImage:setVisible(false)
    else
        local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
        godTitleLabel:setVisible(true)
        godImage:setVisible(true)
        local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(tKnight.id)
        godTitleLabel:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, tKnightTmpl.quality))
        godImage:loadTexture(G_Path.getGodQualityShuiYin(tKnightTmpl.quality))
    end


end

function KnightTransformSourceItem:_onConfirm(sender)
	local nKinghtId = sender:getTag() or 0
	if nKinghtId ~= 0 then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_SELECT_SOURCE_KINGHT_SUCC, nil, false, nKinghtId)
	end
	if self._selectedCallback then
		self._selectedCallback()
	end
end

return KnightTransformSourceItem