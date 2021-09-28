local EffectNode = require("app.common.effects.EffectNode")

local HeroSoulDropItemCell = class("HeroSoulDropItemCell", function()
	return CCSItemCellBase:create("ui_layout/herosoul_DropItemCell.json")
end)

function HeroSoulDropItemCell:ctor()
	self._tEffect = nil
end

function HeroSoulDropItemCell:updateItem(tDropInfo)
	if not tDropInfo then
		return
	end

	local tGoods = G_Goods.convert(tDropInfo.type, tDropInfo.value, tDropInfo.size)
	assert(tGoods)

	if tGoods then
		self:_updateIcon(tGoods)
	end
end

function HeroSoulDropItemCell:_updateIcon(tGoods)
	local imgQualityFrame = self:getImageViewByName("Image_QualityFrame")
	local nQuality = tGoods.quality
	local nType = tGoods.type
	local nValue = tGoods.value
	local szName = tGoods.name 
	local nItemNum = tGoods.size 
	local szIcon = tGoods.icon

	-- 物品品质框
	if imgQualityFrame then
		imgQualityFrame:loadTexture(G_Path.getEquipColorImage(nQuality, nType))
	end
	-- 物品图片
	local imgIcon = self:getImageViewByName("Image_Icon")
	if imgIcon then
		imgIcon:loadTexture(szIcon)
	end
	-- 物品数量
	local labelNum = self:getLabelByName("Label_Num")
	if labelNum then
		labelNum:setText("x" .. G_GlobalFunc.ConvertNumToCharacter2(nItemNum))
		labelNum:createStroke(Colors.strokeBrown, 1)
	end
	-- 是否必掉
	if nType == G_Goods.TYPE_HERO_SOUL then
		if G_Me.heroSoulData:isSoulNeeded(nValue) then
			self:showWidgetByName("Image_Mark", true)
			if G_Me.heroSoulData:isSoulBadlyNeeded(nValue) then
				self:getImageViewByName("Image_Mark"):loadTexture("ui/text/txt/jixu.png")
			else
				self:getImageViewByName("Image_Mark"):loadTexture("ui/text/txt/jzcb_xuyao.png")
			end
		else
			self:showWidgetByName("Image_Mark", false)
		end
	else
		self:showWidgetByName("Image_Mark", false)
	end
	

	-- 特效
--	self:_showEffect(nType == G_Goods.TYPE_HERO_SOUL_POINT, self:getImageViewByName("Image_QualityFrame"))

	self:registerWidgetClickEvent("Image_QualityFrame", function()
		if type(nType) == "number" and type(nValue) == "number" then
	    	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
		end
	end)
end

function HeroSoulDropItemCell:_showEffect(isNeed, tParent)
	assert(tParent)
	if isNeed then
		if not self._tEffect then
            self._tEffect = EffectNode.new("effect_around1")
            self._tEffect:setScale(1.7)
            self._tEffect:setPosition(ccp(4, -4))
            tParent:addNode(self._tEffect)
            self._tEffect:play()
		end
	else
		if self._tEffect then
			self._tEffect:removeFromParentAndCleanup(true)
			self._tEffect = nil
		end
	end
end

            


return HeroSoulDropItemCell