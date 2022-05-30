 --[[
 --
 -- @authors shan 
 -- @date    2014-08-07 13:21:04
 -- @version 
 --
 --]]

require("utility.richtext.richText")
local NoteItem = class("NoteItem", function ( ... )
    return CCTableViewCell:new()
end)



function NoteItem:getContentSize()
    if self._sz then

    else
        local proxy = CCBProxy:create()
        local rootnode = {}

        CCBuilderReaderLoad("ccbi/gamenote/noteItem.ccbi", proxy, rootnode)
        self._sz = rootnode["item_bg"]:getContentSize()
    end

    return self._sz
end



function NoteItem:create(param)
    dump(param)
    dump(param.viewSize.width)
    dump(param.viewSize.height)
	local proxy = CCBProxy:create()
    self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/gamenote/noteItem.ccbi", proxy, self._rootnode)
	self:addChild(node)


    dump(self._rootnode["item_bg"]:getContentSize().width)
    dump(self._rootnode["item_bg"]:getContentSize().height)

    self.titleLabel = ui.newTTFLabelWithOutline({
        text = param.itemData.title,
        font = FONTS_NAME.font_haibao,
        x = self._rootnode["item_title_bg"]:getContentSize().width/2,
        y = self._rootnode["item_title_bg"]:getContentSize().height/2,
        color = FONT_COLOR.NOTE_TITLE,
        outlineColor = FONT_COLOR.NOTE_TITLE_OUTLINE,
        size = 30,
        align = ui.TEXT_ALIGN_CENTER
        })
    self._rootnode["item_title_bg"]:addChild(self.titleLabel)

    local text = ""--"[活动时间]\n\n8月08日00:00-8月11日23:59\n\n[活动范围]\n\nxxx服:1-75区\n\n[活动内容]\n\n这里是活动的内容1这里是活动的内容2这里是活动的内容3这里是活动的内容4这里是活动的内容5这里是活动的内容6这里是活动的内容7这里是活动的内容8这里是活动的内容9这里是活动的内容10这里是活动的内容11这里是活动的内容12"
    -- local text_1 = "[活动时间]\n\n"
    -- local text_2 = "\n\n8月08日00:00-8月11日23:59\n\n"
    -- local text_3 = "\n\n[活动范围]"
    -- local text_4 = "\n\nxxx服:1-75区"
    -- local htmlText = "<font size=\"22\"  font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s</font><font size=\"22\" color=\"#7e0000\">%s</font><font size=\"22\"  font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s</font><font size=\"22\" color=\"#7e0000\">%s</font>"
    -- self.textLabel = getRichText(string.format(htmlText, text_1, text_2,text_3,text_4), self._rootnode["item_bg"]:getContentSize().width * 0.76)
    -- self.textLabel:setPosition(self._rootnode["item_bg"]:getContentSize().width*0.12, self._rootnode["item_bg"]:getContentSize().height*0.5)
    self.textLabel = ui.newTTFLabel({
        text = text,--param.itemData.content,
        font = FONTS_NAME.font_fzcy,
        x = self._rootnode["item_bg"]:getContentSize().width*0.12,
        y = self._rootnode["item_bg"]:getContentSize().height*0.6,
        color = FONT_COLOR.NOTE_TEXT,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        -- valign = ui.TEXT_VALIGN_BOTTOM,
        dimensions = param.viewSize
        })
    self._rootnode["item_bg"]:addChild(self.textLabel)
	
    self:refresh(param)
    return self
end


-- 更新活动item的背景
function NoteItem:refresh(param)
	if(param.itemData ~= nil ) then
        self.titleLabel:setString(param.itemData.title)
        -- self.textLabel:setString(param.itemData.content)
		-- local spriteName = "ui/ui_huodong/" .. param.itemData.icon .. ".png"

		-- local sprite = display.newSprite(spriteName)
		-- self._rootnode["item_bg"]:setDisplayFrame(sprite:getDisplayFrame())

	end
end



return NoteItem