-- 三国无双精英boss总览icon

local WushBossIconItem = class("WushBossIconItem", function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/wush_BossIconItem.json")
end)

require("app.cfg.dead_battle_boss_info")
local EffectNode = require "app.common.effects.EffectNode"

function WushBossIconItem:ctor( id, ... )

	self._bossInfo = dead_battle_boss_info.get(id)
	if self._bossInfo == nil then
		return
	end

	self._activeId = G_Me.wushData:getBossActiveId()
	self._firstId = G_Me.wushData:getBossFirstId()

	self._unlockLabel = UIHelper:seekWidgetByName(self, "Label_Unlock_Level")
	self._unlockLabel = tolua.cast(self._unlockLabel, "Label")
	self._unlockImage = UIHelper:seekWidgetByName(self, "Image_Lock")
	self._unlockImage = tolua.cast(self._unlockImage, "ImageView")
	self._selectedBg = UIHelper:seekWidgetByName(self, "Image_Select_Bg")
	self._selectedBg = tolua.cast(self._selectedBg, "ImageView")

	local nameLabel = UIHelper:seekWidgetByName(self, "Label_Boss_Name")
	nameLabel = tolua.cast(nameLabel, "Label")
	nameLabel:setText(self._bossInfo.monster_name)
	nameLabel:createStroke(Colors.strokeBrown, 1)

	local bossImage = UIHelper:seekWidgetByName(self, "Image_Boss")
	bossImage = tolua.cast(bossImage, "ImageView")
	bossImage:loadTexture(G_Path.getKnightIcon(self._bossInfo.monster_image), UI_TEX_TYPE_LOCAL)

	local unlockTextLabel =  UIHelper:seekWidgetByName(self, "Label_Unlock_Text")
	unlockTextLabel = tolua.cast(unlockTextLabel, "Label")

	if id > (self._firstId + 1) then
		-- 该boss前面尚有未战胜的boss
		local preBoss = dead_battle_boss_info.get(id-1)
		if preBoss then
			self._unlockLabel:setText(G_lang:get("LANG_WUSH_BOSS_OPEN_AFTER_MONSTER_2", {name = preBoss.monster_name}))
			self._unlockImage:setVisible(false)
			nameLabel:setVisible(true)
			bossImage:showAsGray(true)
		end

		if id > self._activeId then
			-- 该boss尚未激活
			self._unlockLabel:setText(G_lang:get("LANG_WUSH_BOSS_OPEN_LEVEL", {num = self._bossInfo.front_floor}))
			self._unlockImage:setVisible(true)
			nameLabel:setVisible(true)
		end
	elseif id == (self._firstId + 1) and self._firstId == self._activeId then
		-- 该boss尚未激活
		self._unlockLabel:setText(G_lang:get("LANG_WUSH_BOSS_OPEN_LEVEL", {num = self._bossInfo.front_floor}))
		self._unlockImage:setVisible(true)
		nameLabel:setVisible(true)
		bossImage:showAsGray(false)
	else
		self._unlockLabel:setVisible(false)
		unlockTextLabel:setVisible(false)
		self._unlockImage:setVisible(false)
		bossImage:showAsGray(false)
	end

	self._btnName = "Button_Boss_Icon_" .. id
	local btn = UIHelper:seekWidgetByName(self, "Button_Boss_Icon")
	btn = tolua.cast(btn, "Button")
	btn:setName(self._btnName)


end


function WushBossIconItem:updateSelectedBg( isVisible )
	self._selectedBg:setVisible(isVisible)
end

function WushBossIconItem:setGrayBossImage( isGray )
	local bossImage = UIHelper:seekWidgetByName(self, "Image_Boss")
	bossImage = tolua.cast(bossImage, "ImageView")
	if bossImage then
		bossImage:showAsGray(isGray)
	end
end

function WushBossIconItem:playUnlockEffect(  )
	if not self._unlockImage:isVisible() then

		-- local bossImage = UIHelper:seekWidgetByName(self, "Image_Boss")
		-- bossImage = tolua.cast(bossImage, "ImageView")


		local btn = UIHelper:seekWidgetByName(self, self._btnName)
		btn = tolua.cast(btn, "Button")

		-- 添加特效
		local effectLight = EffectNode.new("effect_lp_jl", function ( event, frameIndex )
												if event == "finish" then
													self:setGrayBossImage(false)
												end
											end)
		btn:addNode(effectLight, -1)
		effectLight:setPosition(ccp(14, -22))
		effectLight:setScale(1.5)
		effectLight:play()

	end
end






function WushBossIconItem:getBtnName(  )
	return self._btnName
end


return WushBossIconItem