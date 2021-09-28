local KnightTransformConst = require("app.const.KnightTransformConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local KnightTransformDevelopItem2 = class("KnightTransformDevelopItem2", UFCCSNormalLayer)

function KnightTransformDevelopItem2.create(nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
	return KnightTransformDevelopItem2.new("ui_layout/KnightTransform_DevelopItem2.json", nil, nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
end

function KnightTransformDevelopItem2:ctor(json, param, nDevelopType, nSourceKnightId, nTargetKnightBaseId, ...)
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

function KnightTransformDevelopItem2:onLayerEnter()
	
end

function KnightTransformDevelopItem2:onLayerExit()
	
end

function KnightTransformDevelopItem2:_initSourceKnightInfo()
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

	-- 觉醒星星
	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(tSourceKnight.id) or -1
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

    CommonFunc._updateLabel(self, "Label_AwakeStar", {text=G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(tSourceKnight.awaken_level / 10), level=tSourceKnight.awaken_level % 10}), visible=stars ~= -1})

    -- 觉醒道具
    local tKnightAwakenTmpl = knight_awaken_info.get(tSourceKnightTmpl.awaken_code, tSourceKnight.awaken_level)
    assert(tKnightAwakenTmpl, "Could not find the tKnightAwakenTmpl with awaken_code and awakenLevel: "..tSourceKnightTmpl.awaken_code..", "..tSourceKnight.awaken_level)
    
    self:_updateAwakenItem(tKnightAwakenTmpl, self._nSourceKnightId)

end

function KnightTransformDevelopItem2:_initTargetKnightInfo()
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

	-- 觉醒星星
	local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(tSourceKnight.id) or -1
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

    CommonFunc._updateLabel(self, "Label_AwakeStar", {text=G_lang:get("LANG_KNIGHT_AWAKEN_DESC", {star=math.floor(tSourceKnight.awaken_level / 10), level=tSourceKnight.awaken_level % 10}), visible=stars ~= -1})

    -- 觉醒道具
    local tKnightAwakenTmpl = knight_awaken_info.get(tTargetKnightTmpl.awaken_code, tSourceKnight.awaken_level)
    assert(tKnightAwakenTmpl, "Could not find the tKnightAwakenTmpl with awaken_code and awakenLevel: "..tTargetKnightTmpl.awaken_code..", "..tSourceKnight.awaken_level)
    
    self:_updateAwakenItem(tKnightAwakenTmpl, nil)

end


function KnightTransformDevelopItem2:_updateAwakenItem(tKnightAwakenTmpl, nKnightId)
	for i=1, 4 do
		local itemId = tKnightAwakenTmpl["item_id_"..i]
        
        -- 装备icon和背景
        CommonFunc._updateImageView(self, "Image_bg"..i, {visible=(itemId ~= 0)})
        CommonFunc._updateImageView(self, "Image_icon"..i, {visible=(itemId ~= 0)})
        CommonFunc._updateImageView(self, "Image_frame"..i, {visible=(itemId ~= 0)})
        
        -- 觉醒状态
        CommonFunc._updateImageView(self, "Image_Prop"..i, {visible=(itemId ~= 0)})
        
        if itemId ~= 0 then
            local itemInfo = item_awaken_info.get(itemId)
            assert(itemInfo, "Could not find the awaken item with id: "..itemId)

            CommonFunc._updateImageView(self, "Image_bg"..i, {texture=G_Path.getEquipIconBack(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
            CommonFunc._updateImageView(self, "Image_icon"..i, {texture=itemInfo.icon})
            CommonFunc._updateImageView(self, "Image_frame"..i, {texture=G_Path.getEquipColorImage(itemInfo.quality), texType=UI_TEX_TYPE_PLIST})
        
            if nKnightId ~= nil then
	        	local equipped = G_Me.bagData.knightsData:isEquippedAwakenItem(nKnightId, itemId, i)
	            self:getImageViewByName("Image_bg"..i):showAsGray(not equipped)
	            self:getImageViewByName("Image_icon"..i):showAsGray(not equipped)
	            self:getImageViewByName("Image_frame"..i):showAsGray(not equipped)
	        else 
	        	local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
				if not tSourceKnight then
					return
				end

				local nBaseId = tSourceKnight["base_id"]
				local tSourceKnightTmpl = knight_info.get(nBaseId)
				local tAwakenTmpl = knight_awaken_info.get(tSourceKnightTmpl.awaken_code, tSourceKnight.awaken_level)
				local nItemId = tAwakenTmpl["item_id_"..i]
				if nItemId ~= 0 then
					local equipped = G_Me.bagData.knightsData:isEquippedAwakenItem(self._nSourceKnightId, nItemId, i)
					self:getImageViewByName("Image_bg"..i):showAsGray(not equipped)
	            	self:getImageViewByName("Image_icon"..i):showAsGray(not equipped)
	            	self:getImageViewByName("Image_frame"..i):showAsGray(not equipped)
				end
	        end
        end


	end
end

return KnightTransformDevelopItem2