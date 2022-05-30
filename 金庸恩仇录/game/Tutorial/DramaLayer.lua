local data_drama_drama = require("data.data_drama_drama")
local CUR_IMAGE = 1
local FUR_IMAGE = 2

--剧情对话
local DramaLayer = class("DramaLayer", function (data)
	return require("utility.ShadeLayer").new()
end)

function DramaLayer:ctor(id, endFunc, skipFunc)
	display.addSpriteFramesWithFile("ui/ui_tutorial.plist", "ui/ui_tutorial.png")
	ResMgr.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	self:initPos()
	local dramaData = data_drama_drama[id]
	local dramaType = dramaData.drama_type
	local dramaSkip = dramaData.isSkip
	local opacity = dramaData.opacity
	if opacity ~= nil then
		self:setOpacity(opacity)
	end
	self.isTouch = false
	if dramaSkip == 1 then
		self:setTouchFunc(function ()
			self.isTouch = true
			endFunc()
			self:removeSelf()
		end)
	end
	if dramaType == 1 then
		local animName = dramaData.anim
		local dramaAnim = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = animName,
		finishFunc = function ()
			if self.isTouch ~= true then
				endFunc()
				self:removeSelf()
			end
		end,
		isRetain = false
		})
		dramaAnim:setPosition(display.cx, display.cy)
		self:addChild(dramaAnim)
	else
		local chatStr = dramaData.intro
		local cur_large = dramaData.cur_large
		local cur_posId = dramaData.cur_pos or 1
		local cur_offsetX = dramaData.cur_offsetX or 0
		local cur_offsetY = dramaData.cur_offsetY or 0
		local cur_over = dramaData.cur_over
		local cur_scale = dramaData.cur_scale or 1000
		local cur_opacity = dramaData.cur_opacity or 100
		local fur_large = dramaData.fur_large
		local fur_posId = dramaData.fur_pos
		local fur_offsetX = dramaData.fur_offsetX or 0
		local fur_offsetY = dramaData.fur_offsetY or 0
		local fur_over = dramaData.fur_over
		local fur_scale = dramaData.fur_scale or 1000
		local fur_opacity = dramaData.fur_opacity or 100
		local speakerName = dramaData.cur_name or common:getLanguageString("@wumingshi")
		if speakerName == 1 then
			speakerName = game.player.m_name
		end
		self.chatBox = display.newScale9Sprite("#chat_box.png", 0, 0, CCSize(display.width, 208))
		self:addChild(self.chatBox, 100)
		self.chatBox:setPosition(display.cx, display.height * 0.3)
		self:addHeroImage(cur_large, cur_posId, cur_over, cur_offsetX, cur_offsetY, cur_scale, cur_opacity, CUR_IMAGE)
		self:addHeroImage(fur_large, fur_posId, fur_over, fur_offsetX, fur_offsetY, fur_scale, fur_opacity, FUR_IMAGE)
		local dim = CCSize(display.width - 30, self.chatBox:getContentSize().height - 30)
		if chatStr ~= nil then
			local dramaTTF = ui.newTTFLabel({
			text = chatStr,
			size = 32,
			font = FONTS_NAME.font_fzcy,
			dimensions = dim,
			align = ui.TEXT_ALIGN_LEFT,
			valign = ui.TEXT_VALIGN_TOP,
			color = cc.c3b(54, 4, 5),
			})
			dramaTTF:setPosition(self.chatBox:getPositionX(), self.chatBox:getPositionY() - 20)
			self:addChild(dramaTTF, 105)
		end
		local nameBg = display.newSprite("#chat_name.png")
		nameBg:setPosition(self.imageX[cur_posId], self.chatBox:getPositionY() - 7 + self.chatBox:getContentSize().height / 2 + nameBg:getContentSize().height / 2)
		self:addChild(nameBg, 95)
		if speakerName ~= nil then
			local charName = ui.newTTFLabel({
			text = speakerName,
			size = 32,
			font = FONTS_NAME.font_haibao,
			align = ui.TEXT_ALIGN_CENTER,
			color = cc.c3b(254, 205, 102),
			outlineColor = cc.c3b(255, 204, 106),
			})
			charName:setPosition(nameBg:getContentSize().width / 2, nameBg:getContentSize().height * 0.4)
			nameBg:addChild(charName)
		end
		--设置触摸按键
		self:setTouchFunc(function (event)
			if event.name == "ended" then
				endFunc()
				self:removeSelf()
			end
		end)
		
		--跳过剧情
		local btnSprite = display.newScale9Sprite("#jump_drama_btn.png")
		self.skipDramaBtn = CCControlButton:create("", FONTS_NAME.font_fzcy, 30)
		self.skipDramaBtn:setBackgroundSpriteForState(btnSprite, CCControlStateNormal)
		self.skipDramaBtn:setPreferredSize(cc.size(144, 50))
		self.skipDramaBtn:addHandleOfControlEvent(function ()
			DramaMgr.isSkipBattleDrama = true
			DramaMgr.isSkipBattleBefWorld = true
			DramaMgr.isSkipBattleBefSub = true
			DramaMgr.isSkipBattleBefNpc = true
			if skipFunc then
				skipFunc()
			end
			DramaMgr.isSkipBattleBefWorld = false
			DramaMgr.isSkipBattleBefSub = false
			DramaMgr.isSkipBattleBefNpc = false
			self:removeSelf()
		end,
		CCControlEventTouchUpInside)
		
		self.skipDramaBtn:align(display.RIGHT_BOTTOM, display.width - 22, 60)
		self:addChild(self.skipDramaBtn, 10000000)
		
		if game.runningScene and game.runningScene.fubenType and game.runningScene.fubenType == DRAMA_FUBEN then
			self.skipDramaBtn:setVisible(false)
		end
	end
end

function DramaLayer:addHeroImage(large, pos, over, offsetX, offsetY, scale, opacity, isCur)
	local data_card_card = require("data.data_card_card")
	local speakerImage = large
	local imageOffsetX = display.width * offsetX / 100000
	local imageOffsetY = display.height * offsetY / 100000
	if speakerImage == 1 then
		local cls = game.player.m_class or 0
		local fashionId = game.player:getFashionId()
		local data_item_item = require("data.data_item_item")
		if fashionId > 0 and data_item_item[fashionId] then
			speakerImage = data_item_item[fashionId].body[game.player.m_gender]
		elseif game.player.m_gender == 1 then
			speakerImage = data_card_card[1].arr_body[cls + 1]
		else
			speakerImage = data_card_card[2].arr_body[cls + 1]
		end
	end
	local isFlip = false
	if over == 1 then
		isFlip = true
	end
	if speakerImage ~= nil and speakerImage ~= "" then
		local imagePath = "hero/large/" .. speakerImage .. ".png"
		local heroImage = display.newSprite(imagePath)
		if isCur ~= 1 then
			heroImage:setOpacity(0)
		end
		heroImage:setScale(scale / 1000)
		heroImage:setFlipX(isFlip)
		heroImage:setPosition(self.imageX[pos] + imageOffsetX, imageOffsetY + self.chatBox:getPositionY() + self.chatBox:getContentSize().height / 2 + 40)
		heroImage:setAnchorPoint(cc.p(0.5, 0.33))
		self:addChild(heroImage, 90)
	end
end

function DramaLayer:onExit()
	ResMgr.removeSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
end

function DramaLayer:initPos()
	local displayWidth = display.width
	self.imageX = {
	0.2 * displayWidth,
	0.5 * displayWidth,
	0.8 * displayWidth
	}
end

return DramaLayer