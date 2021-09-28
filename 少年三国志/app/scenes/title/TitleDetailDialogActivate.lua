-- TitleDetailDialogActivate.lua 可激活称号弹框

require("app.cfg.title_info")
require("app.cfg.item_info")

local TitleDetailDialogActivate = class("TitleDetailDialogActivate", UFCCSModelLayer)

function TitleDetailDialogActivate.create(... )
	return TitleDetailDialogActivate.new("ui_layout/title_dialog_activate.json", Colors.modelColor, ...)
end

function TitleDetailDialogActivate:ctor(json, color, index, itemId, ... )
	self.super.ctor(self, ...)

	self._index = index
	self._itemId = itemId

	if not itemId then
		for i = 1, item_info.getLength() do
			local item = item_info.indexOf(i)
			if item.item_type == 24 and item.item_value == index then
				self._itemId = item.id
			end
		end
	end

	-- local currentTitleInfo = title_info.indexOf(self._index)
	local currentTitleInfo = title_info.get(self._index)

	self:showAtCenter(true)

	-- 该称号对应的背景图片
	local titleNameBg = self:getImageViewByName("Image_Title_Name_Bg")
	local uiResName = currentTitleInfo.picture
	titleNameBg:loadTexture(uiResName, UI_TEX_TYPE_LOCAL)

	-- 称号名
	local titleName = currentTitleInfo.name
	local titleNameLabel = self:getLabelByName("Label_Title_Name")
	local quality = currentTitleInfo.quality
	titleNameLabel:setColor(Colors.getColor(quality))
	titleNameLabel:setText(titleName)
	titleNameLabel:createStroke(Colors.strokeBrown, 3)

	-- 激活说明中的称号名
	local titleNameLabelInDesription = self:getLabelByName("Label_Title_In_Description")
	titleNameLabelInDesription:setColor(Colors.getColor(quality))
	titleNameLabelInDesription:setText(titleName)
	titleNameLabelInDesription:createStroke(Colors.strokeBrown, 1)
	-- 称号有效时限
	local effectTime = currentTitleInfo.effect_time	/ (60 * 60 * 24)
	if effectTime < 1 then
		effectTime = string.format("%.2f", effectTime) 
	end
	local effectTimeLabel = self:getLabelByName("Label_Effect_Time")
	effectTimeLabel:setText(G_lang:get("LANG_TITLE_DAYS", {dayValue = effectTime}))
	effectTimeLabel:createStroke(Colors.strokeBrown, 1)

	-- 称号名前后文本加描边
	self:getLabelByName("Label_Title_Pre"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_Title_Post1"):createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_Title_Post2"):createStroke(Colors.strokeBrown, 1)

	-- 激活道具名
	local activatePropNameLabel = self:getLabelByName("Label_Prop_Name")
	activatePropNameLabel:createStroke(Colors.strokeBrown, 1)
	local activateItem = self:_getActivateItemInfo()	
	activatePropNameLabel:setText(activateItem.name)
	-- 道具名前的文字加描边
	self:getLabelByName("Label_Prop_Cost"):createStroke(Colors.strokeBrown, 1)
	-- 道具图标及其背景
	self:getImageViewByName("Image_Prop_Icon"):loadTexture(G_Path.getItemIcon(activateItem.res_id), UI_TEX_TYPE_LOCAL)
    self:getImageViewByName("Image_Prop_Border"):loadTexture(G_Path.getEquipColorImage(activateItem.quality, G_Goods.TYPE_ITEM))
    self:getImageViewByName("Image_Prop_Bg"):loadTexture(G_Path.getEquipIconBack(activateItem.quality))

	self:registerBtnClickEvent("Button_Activate", function ( ... )
		self:_activate()
	end)

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

end

-- 获取该称号所对应的激活道具信息
function TitleDetailDialogActivate:_getActivateItemInfo( ... )
	local itemInfo = {}
	for i= 1, item_info.getLength() do
		local itemInfoTemp = item_info.indexOf(i)
		if itemInfoTemp.item_type == 24 then
			if itemInfoTemp.item_value == self._index then
				__Log("itemInfoTemp: ")
				itemInfo = itemInfoTemp
				break				
			end
		end
	end
	return itemInfo
end

function TitleDetailDialogActivate:_activate( ... )
	__Log("TitleDetailDialogActivate:_activate itemId = %d", self._itemId)
	G_HandlersManager.bagHandler:sendUseItemInfo(self._itemId)
	self:animationToClose()
end

function TitleDetailDialogActivate:onLayerEnter( ... )
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	self:closeAtReturn(true)
end

return TitleDetailDialogActivate