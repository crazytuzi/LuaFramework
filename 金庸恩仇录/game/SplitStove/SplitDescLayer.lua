local data_message_message = require("data.data_message_message")

local SplitDescLayer = class("SplitDescLayer", function()
	return require("utility.ShadeLayer").new()
end)

function SplitDescLayer:ctor(viewType, text, title)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("lianhualu/lianhualu_desc.ccbi", proxy, rootnode)
	self:addChild(node)
	node:setPosition(display.cx, display.cy)
	
	local descLabel = ui.newTTFLabel({
	text = "",
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	valign = ui.TEXT_VALIGN_TOP,
	size = 20,
	dimensions = cc.size(rootnode.label_view:getContentSize().width * 0.72, 0),
	color = cc.c3b(130, 13, 0)
	})
	rootnode.descLabel = descLabel
	descLabel:align(display.LEFT_BOTTOM)
	rootnode.label_view:addChild(descLabel)
	rootnode.label_view:setDirection(kCCScrollViewDirectionVertical)
	dump(viewType)
	if text then
		rootnode.titleLabel:setString(title or common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(text)
	elseif viewType == 1 then
		rootnode.titleLabel:setString(common:getLanguageString("@lianhuasm"))
		rootnode.descLabel:setString(data_message_message[11].text)
	elseif viewType == 2 then
		rootnode.titleLabel:setString(common:getLanguageString("@chongshengsm"))
		rootnode.descLabel:setString(data_message_message[12].text)
	elseif viewType == 3 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[21].text)
	elseif viewType == 4 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[23].text)
	elseif viewType == 5 then
		rootnode.titleLabel:setString(common:getLanguageString("@yabiaosm"))
		rootnode.descLabel:setString(require("data.data_ui_ui")[9].content)
	elseif viewType == 6 then
		rootnode.titleLabel:setString(common:getLanguageString("@cuiliansm"))
		rootnode.descLabel:setString(data_message_message[25].text)
	elseif viewType == 7 then
		rootnode.titleLabel:setString(common:getLanguageString("@changxiaotg"))
		rootnode.descLabel:setString(data_message_message[26].text)
	elseif viewType == 8 then
		rootnode.titleLabel:setString(common:getLanguageString("@haohuatg"))
		rootnode.descLabel:setString(data_message_message[27].text)
	elseif viewType == 9 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[31].text)
	elseif viewType == 11 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[32].text)
	elseif viewType == 12 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[35].text)
	elseif viewType == 13 then
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(data_message_message[36].text)
	elseif viewType == 41 then
		rootnode.titleLabel:setString(common:getLanguageString("@ChuangDangDesc"))
		rootnode.descLabel:setString(data_message_message[41].text)
	else
		rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
		rootnode.descLabel:setString(tostring(data_message_message[viewType].text))
	end
	local contentSize = rootnode.descLabel:getContentSize()
	rootnode.label_view:setContentSize(contentSize)
	rootnode.label_view:setContentOffset(cc.p(0, -contentSize.height + rootnode.label_view:getViewSize().height), false)
	
	rootnode.tag_close:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
end

return SplitDescLayer