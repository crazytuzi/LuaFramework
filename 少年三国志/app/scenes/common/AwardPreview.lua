local AwardPreview = class("AwardPreview", UFCCSModelLayer)

function AwardPreview.create(tAwardList, ...)
	return AwardPreview.new("ui_layout/common_AwardPreview1.json", Colors.modelColor, tAwardList, ...)
end

function AwardPreview:ctor(json, param, tAwardList, ...)
	self._tAwardList = tAwardList

	self.super.ctor(self, json, param, ...)
end

function AwardPreview:onLayerLoad()

end

function AwardPreview:onLayerEnter()
	self:showAtCenter(true)
	self:setClickClose(true)
	self:closeAtReturn(true)

	self:_initWidgets()

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_Bg"), "smoving_bounce")
end

function AwardPreview:onLayerExit()
	
end

function AwardPreview:onLayerUnload()
	
end


function AwardPreview:_initWidgets()
	for i=1, 4 do
        local imgBg = self:getImageViewByName(string.format("Image_Bg%d", i))
        assert(imgBg)

        local tAward = self._tAwardList[i]
        if tAward then
      		local tGoods = G_Goods.convert(tAward["type"], tAward["value"], tAward["size"])
      		if tGoods then
      			imgBg:setVisible(true)
      			self:_initGoods(i, tGoods)
      		else
      			imgBg:setVisible(false)
      		end
        else
            imgBg:setVisible(false)
        end
	end
end

function AwardPreview:_initGoods(nIndex, tGoods)
	local imgQualityFrame = self:getImageViewByName("Image_QualityFrame" .. nIndex)
	local nQuality = tGoods.quality
	local nType = tGoods.type
	local nValue = tGoods.value
	local szName = tGoods.name 
	local nItemNum = tGoods.size 
	local szIcon = tGoods.icon

	-- 物品品质框
	imgQualityFrame:loadTexture(G_Path.getEquipColorImage(nQuality, nType))
	-- 物品图片
	local imgIcon = self:getImageViewByName("Image_Icon" .. nIndex)
	imgIcon:loadTexture(szIcon)
	-- 物品数量
	local labelNum = self:getLabelByName("Label_Num" .. nIndex)
	labelNum:setText("x" .. G_GlobalFunc.ConvertNumToCharacter2(nItemNum))
	labelNum:createStroke(Colors.strokeBrown, 1)

	-- self:registerWidgetClickEvent("Image_QualityFrame"..nIndex, function()
	-- 	if type(nType) == "number" and type(nValue) == "number" then
	--     	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
	-- 	end
	-- end)
end


return AwardPreview