require("game.Biwu.BiwuFuc")
require("game.Huodong.JumpToHelper")

local GameNote = class("GameNote", function (...)
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 100))
end)

local contentSizeHeight = 0

local Item = class("Item", function (param)
	local itemData = param.itemData
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/gamenote/noteItem.ccbi", proxy, rootnode)
	local textNode = rootnode.text_node
	local title_color = cc.c3b(checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 1, 2))), checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 3, 4))), checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 5, 6))))
	local content_color = cc.c3b(checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 1, 2))), checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 3, 4))), checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 5, 6))))
	local titleLabel
	if itemData.teffect == 1 then
		titleLabel = ui.newTTFLabelWithOutline({
		text = itemData.title,
		font = FONTS_NAME.font_haibao,
		color = title_color,
		outlineColor = FONT_COLOR.NOTE_TITLE_OUTLINE,
		size = checkint(itemData.tfont),
		align = ui.TEXT_ALIGN_CENTER
		})
	else
		titleLabel = ui.newTTFLabelWithOutline({
		text = itemData.title,
		font = FONTS_NAME.font_haibao,
		color = title_color,
		outlineColor = FONT_COLOR.BLACK,
		size = checkint(itemData.tfont),
		align = ui.TEXT_ALIGN_CENTER
		})
	end
	titleLabel:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	node:addChild(titleLabel)
	local viewSize = CCSizeMake(textNode:getContentSize().width, 0)
	dump(itemData.content)
	dump(itemData.content)
	local index1 = string.find(itemData.content, "<@")
	local index2 = string.find(itemData.content, "@>")
	local keys
	local txt = itemData.content
	if index2 and index1 then
		index2 = index2 + 1
		local key = string.sub(itemData.content, index1, index2)
		itemData.content = string.sub(itemData.content, 0, index1 - 1) .. string.sub(itemData.content, index2 + 1, string.len(itemData.content))
		txt = string.gsub(itemData.content, "\r\n", "\n")
		keys = string.split(string.sub(key, 3, string.len(key) - 2), "-")
	end
	local contentLabel = ui.newTTFLabel({
	text = txt,
	font = FONTS_NAME.font_fzcy,
	color = content_color,
	size = checkint(itemData.cfont),
	align = ui.TEXT_ALIGN_LEFT,
	valign = ui.TEXT_VALIGN_TOP,
	dimensions = viewSize
	})
	contentLabel:setAnchorPoint(0.5, 1)
	contentLabel:setPosition(node:getContentSize().width / 2, 0)
	node:addChild(contentLabel)
	contentSizeHeight = contentLabel:getContentSize().height
	if keys then
		do
			local btnData = {id = keys}
			local offset = 30
			local gotoBtn = display.newSprite("#btn_go.png")
			gotoBtn:setPosition(node:getContentSize().width * 0.5, contentLabel:getPositionY() - contentLabel:getContentSize().height - offset - 15)
			gotoBtn:setTouchSwallowEnabled(false)
			node:addChild(gotoBtn)
			addTouchListener(gotoBtn, function (sender, eventType)
				dump(eventType)
				if eventType == EventType.began then
					sender:setScale(0.9)
				elseif eventType == EventType.ended then
					sender:setScale(1)
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
					JumpTo(btnData)
				elseif eventType == EventType.cancel then
					sender:setScale(1)
				end
			end)
			contentSizeHeight = contentLabel:getContentSize().height + offset + gotoBtn:getContentSize().height
		end
	end
	return node
end)

function GameNote:ctor()
	self:setNodeEventEnabled(true)
	self:loadRes()
	--self:setNodeEventEnabled(true)
	--local bg = display.newColorLayer(cc.c4b(0, 0, 0, 100))
	--bg:setScale(display.height / bg:getContentSize().height)
	--self:addChild(bg)
	--bg:setTouchEnabled(true)
	local proxy = CCBProxy:create()
	local rootnode = rootnode or {}
	local ccb_mm_name = "ccbi/gamenote/gamenote.ccbi"
	local node = CCBuilderReaderLoad(ccb_mm_name, proxy, rootnode)
	--self.layer = node
	--node:setTouchEnabled(false)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.content_bg:setVisible(false)
	rootnode.note_bg_2:setVisible(true)
	rootnode.note_bg:setVisible(false)
	local btn_know = rootnode.btn_know
	btn_know:setVisible(false)
	local okBtn = rootnode.btn_ok
	okBtn:setVisible(true)
	okBtn:setZOrder(1000)
	
	okBtn:addHandleOfControlEvent(function (sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		sender:runAction(transition.sequence({
		CCScaleTo:create(0.08, 0.8),
		CCScaleTo:create(0.1, 1.2),
		CCScaleTo:create(0.02, 1),
		CCCallFunc:create(function ()
			self:removeSelf()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	local height = 0
	local contentViewSize = rootnode.contentView:getContentSize()
	dump("==============================")
	dump("==============================")
	dump("==============================")
	dump("==============================")
	dump("game.player.m_gamenote....." .. #game.player.m_gamenote)
	for i, v in ipairs(game.player.m_gamenote) do
		local item = Item.new({itemData = v})
		item:setPosition(contentViewSize.width / 2, -height)
		rootnode.contentView:addChild(item)
		height = height + item:getContentSize().height + contentSizeHeight + 10
	end
	local sz = cc.size(contentViewSize.width, contentViewSize.height + height)
	rootnode.descView:setContentSize(sz)
	rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	local scrollView = rootnode.scrollView
	--scrollView:setTouchSwallowEnabled(false)
	scrollView:updateInset()
	scrollView:setContentOffset(cc.p(0, -sz.height + scrollView:getViewSize().height), false)
end

function GameNote:onExit()
	self:releaseRes()
end

function GameNote:loadRes()
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
end

function GameNote:releaseRes()
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
end

return GameNote