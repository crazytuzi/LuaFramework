-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_pigeon_post = i3k_class("wnd_pigeon_post", ui.wnd_base)

function wnd_pigeon_post:ctor()
	self._timeCounter = 0
	self._pigeonPost = {}
end

function wnd_pigeon_post:configure()
	self._layout.vars.close:onClick(self, self.onCloseBtn)
end

function wnd_pigeon_post:refresh()
	local pigeonPost = g_i3k_game_context:getPigeonPost()
	self._pigeonPost = pigeonPost
	self._layout.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_pigeon_post.itemInfo[pigeonPost.kiteId].bgIcon))
	self._layout.vars.close:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_pigeon_post.itemInfo[pigeonPost.kiteId].closeIcon))
	self._layout.vars.scroll:removeAllChildren()
	if pigeonPost and pigeonPost.time then
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local textNode = require("ui/widgets/ggt1")()
			local showText = self:transformMessage(pigeonPost.msg)
			if i3k_game_get_server_name(i3k_game_get_login_server_id()) == pigeonPost.gsName then
				text = string.format("%s：\n%s", pigeonPost.roleName, showText)
			else
				text = string.format("%s-%s：\n%s", pigeonPost.gsName, pigeonPost.roleName, showText)
			end
			textNode.vars.text:setText(text)
			textNode.vars.text:setTextColor(i3k_db_pigeon_post.itemInfo[self._pigeonPost.kiteId].textColor)
			ui._layout.vars.scroll:addItem(textNode)
			g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
				local textUI = textNode.vars.text
				local size = textNode.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
			end, 1)
		end, 1)
	else
		self:onCloseBtn()
	end
end

function wnd_pigeon_post:transformMessage(message)
	local showText = message
	local isBq = string.match(message, "#%d")
	if isBq then
		showText = string.gsub(message, "#%d+", function(str)
			local id = string.sub(str, 2, -1)
			local intId = tonumber(id)
			if intId > 0 and intId <= #i3k_db_emoji then
				local repStr = g_i3k_db.i3k_db_get_icon_path(i3k_db_emoji[intId].iconId)
				return "<e=".. repStr .. "/>"
			end
		end)
	end
	return showText
end

function wnd_pigeon_post:onCloseBtn(sender)
	g_i3k_game_context:updatePigeonPost()
	g_i3k_ui_mgr:CloseUI(eUIID_PigeonPost)
end

function wnd_pigeon_post:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter >= 1 then
		self._timeCounter = 0
		if i3k_game_get_time() - self._pigeonPost.time > i3k_db_pigeon_post.itemInfo[self._pigeonPost.kiteId].lastTime then
			self:onCloseBtn()
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_pigeon_post.new();
		wnd:create(layout, ...);
	return wnd;
end