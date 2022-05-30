local fightRes = {
normal = "#fuchou_n.png",
pressed = "#fuchou_p.png",
disabled = "#fuchou_p.png"
}
local levelRes = {
{
frame = "#arena_itemBg_1.png",
arrowBng = "#arena_lv_bg_1.png",
titleBng = "#arena_name_bg_1.png",
contentBng = "#arena_itemInner_bg_1.png",
rank = "#wj_extra_mark_2.png"
},
{
frame = "#arena_itemBg_2.png",
arrowBng = "#arena_lv_bg_2.png",
titleBng = "#arena_name_bg_2.png",
contentBng = "#arena_itemInner_bg_2.png",
rank = "#wj_extra_mark_3.png"
},
{
frame = "#arena_itemBg_3.png",
arrowBng = "#arena_lv_bg_3.png",
titleBng = "#arena_name_bg_3.png",
contentBng = "#arena_itemInner_bg_3.png",
rank = "#wj_extra_mark_4.png"
}
}
local defaut = {
frame = "#arena_itemBg_5.png",
arrowBng = "#arena_lv_bg_4.png",
titleBng = "#arena_name_bg_5.png",
contentBng = "#arena_itemInner_bg_1.png"
}
local BiwuTianbangItem = class("BiwuTianbangItem", function()
	return CCTableViewCell:new()
end)

function BiwuTianbangItem:create(param)
	self:setUpView(param)
	return self
end

function BiwuTianbangItem:setUpView(param)
	local padding = {
	left = 20,
	right = 20,
	top = 20,
	down = 20
	}
	self:refresh(param)
end

function BiwuTianbangItem:refresh(param)
	self:removeAllChildren()
	local data = param.data
	local padding = {
	left = 20,
	right = 20,
	top = 20,
	down = 20
	}
	--dump(data)
	self.viewSize = param.viewSize
	self:setContentSize(self.viewSize)
	self.bng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].frame or defaut.frame, 0, 0, cc.size(self.viewSize.width, self.viewSize.height))
	self.bng:setAnchorPoint(cc.p(0, 0))
	self:addChild(self.bng)
	self.titleBng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].titleBng or defaut.titleBng, 0, 0, cc.size(self.viewSize.width - padding.left - padding.right, self.viewSize.height * 0.15))
	self.titleBng:setAnchorPoint(cc.p(0, 0))
	self.titleBng:setPosition(cc.p(self.viewSize.width * 0.02, self.viewSize.height * 0.75))
	self.bng:addChild(self.titleBng)
	local nameDis = ui.newTTFLabel({
	text = data.name,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(92, 38, 1)
	})
	nameDis:setAnchorPoint(cc.p(0, 0.5))
	nameDis:setPosition(self.titleBng:getContentSize().width * 0.23, self.titleBng:getContentSize().height * 0.5)
	self.titleBng:addChild(nameDis)
	local fightDis = ui.newTTFLabel({
	text = "【" .. data.faction .. "】",
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(147, 5, 5)
	})
	fightDis:setAnchorPoint(cc.p(1, 0.5))
	fightDis:setPosition(self.titleBng:getContentSize().width * 0.95, self.titleBng:getContentSize().height * 0.5)
	self.titleBng:addChild(fightDis)
	if data.faction == "" then
		fightDis:setVisible(false)
	end
	self.arrowBng = display.newSprite(data.rank <= 3 and levelRes[data.rank].arrowBng or defaut.arrowBng)
	self.arrowBng:setAnchorPoint(cc.p(0, 0))
	self.titleBng:addChild(self.arrowBng)
	if data.rank <= 3 then
		display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
		self.rankTag = display.newSprite(levelRes[data.rank].rank)
		self.rankTag:setAnchorPoint(cc.p(0, 0))
		self.rankTag:setPositionY(self.viewSize.height - 70)
		self.rankTag:setPositionX(10)
		self.bng:addChild(self.rankTag, 20)
	end
	local levelDis = ui.newTTFLabel({
	text = "LV:" .. data.level,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = FONT_COLOR.WHITE,
	})
	levelDis:setAnchorPoint(cc.p(0, 0.5))
	levelDis:setPosition(self.arrowBng:getContentSize().width * 0.2 + 20, self.arrowBng:getContentSize().height * 0.5)
	self.arrowBng:addChild(levelDis)
	self.heroBng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].contentBng or defaut.contentBng, 0, 0, cc.size(self.viewSize.width * 0.7, self.viewSize.height * 0.55))
	self.heroBng:setAnchorPoint(cc.p(0, 0))
	self.heroBng:setPosition(cc.p(self.viewSize.width * 0.01, self.viewSize.height * 0.2))
	self.bng:addChild(self.heroBng)
	for i = 1, #data.cards do
		local head = self:createHeroView(i, self.heroBng, data.cards, data)
	end
	ui.newTTFLabel({
	text = common:getLanguageString("@Ranking", data.rank),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(4, 90, 106)
	})
	:pos(self.viewSize.width * 0.85, self.viewSize.height * 0.6):addTo(self.bng)
	
	
	local fightBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#arena_challenge_btn.png",
	handle = function()
		if param.rank < data.rank then
			show_tip_label(common:getLanguageString("@NotDareScoreLow"))
			return
		end
		if param.roleid == data.role_id then
			show_tip_label(common:getLanguageString("@NotDareSelf"))
			return
		end
		if param.times == 0 then
			show_tip_label(common:getLanguageString("@NotDareNumber"))
			return
		end
		BiwuController.sendFightData(BiwuConst.TIAOZHAN, data.role_id, TabIndex.TIANBANG, data.name)
	end
	})
	fightBtn:align(display.CENTER, self.viewSize.width * 0.85, self.viewSize.height * 0.3)
	self.bng:addChild(fightBtn)
	
	local show = param.rank < 20 and param.rank ~= 0 and data.role_id ~= game.player.m_playerID
	fightBtn:setVisible(show)
	fightBtn:setTouchEnabled(show)
	
	display.newSprite("#friend_zhandouli.png"):pos(self.viewSize.width * 0.1, self.viewSize.height * 0.15):addTo(self.bng)
	ui.newTTFLabel({
	text = data.attack,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(216, 30, 0)
	})
	:pos(self.viewSize.width * 0.22, self.viewSize.height * 0.15):addTo(self.bng)
	ui.newTTFLabel({
	text = common:getLanguageString("@Score"),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(147, 5, 5)
	})
	:pos(self.viewSize.width * 0.5, self.viewSize.height * 0.15):addTo(self.bng)
	
	ui.newTTFLabel({
	text = data.score,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(216, 30, 0)
	}):pos(self.viewSize.width * 0.6, self.viewSize.height * 0.15):addTo(self.bng)
end

function BiwuTianbangItem:createHeroView(index, node, data, dataall)
	local i = index
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon = ResMgr.refreshIcon({
	id = data[i].resId,
	resType = ResMgr.HERO,
	cls = data[i].cls
	})
	dump(dataall)
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(node:getContentSize().width / 5 * i - 20 + 10 * (i - 1), node:getContentSize().height / 2)
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	node:addChild(icon)
	self.data = dataall
	return icon
end

function BiwuTianbangItem:tableCellTouched(x, y)
	if x < display.cx + 100 then
		if self.data .faction ~= "" then
			guidName = " 【" .. self.data .faction .. "】"
		end
		local layer = require("game.form.EnemyFormLayer").new(1, self.data .acc, nil, guidName)
		layer:setPosition(0, 0)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000000)
	end
end

function BiwuTianbangItem:refreshHeroIcons()
end

return BiwuTianbangItem