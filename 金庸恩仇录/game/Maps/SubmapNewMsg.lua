local SubmapNewMsg = class("SubmapNewMsg", function()
	return display.newNode()
end)

function SubmapNewMsg:ctor(title, levelName)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("fuben/sub_map_open.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode["title_lbl"]:setString(title)
	-- 关卡名称
	local titleLbl = ui.newTTFLabelWithOutline({
	text = levelName,
	size = 40,
	color = cc.c3b(101, 1, 1),
	outlineColor = cc.c3b(225, 225, 134),
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	--名称居中对齐
	ResMgr.replaceKeyLableEx(titleLbl, rootnode, "level_name", 0, titleLbl:getContentSize().height/2)
	titleLbl:align(display.CENTER)
	self:runAction(transition.sequence{
	CCDelayTime:create(1.5),
	CCFadeOut:create(1.0),
	CCCallFunc:create(function()
		self:removeSelf()
	end)
	})
end

return SubmapNewMsg