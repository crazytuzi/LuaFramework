-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_set_level = i3k_class("wnd_gm_set_level", ui.wnd_base)

function wnd_gm_set_level:ctor()
	
end

function wnd_gm_set_level:configure()
	local widget = self._layout.vars
	self.inputBox = widget.inputBox
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_set_level:refresh(gmType, args)
	self.args = args
	local widget = self._layout.vars
	self.inputBox:setText("")
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_set_level:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSetLevel)
end

function wnd_gm_set_level:onSend(sender, gmType)
	local text = ""
	local args = self.inputBox:getText()
	if args == "" then
		g_i3k_ui_mgr:PopupTipMessage("请输入信息")
		return
	end
	if gmType == g_GM_CREATE_TEST then --创建测试entity播放动作
		local world = i3k_game_get_world()
		if world then
			world:CreateCommonEntity(tonumber(args))
			world:PlayTestEntityAct(tonumber(args))
		end
		g_i3k_ui_mgr:CloseUI(eUIID_GmSetLevel)
		return
	end

	if gmType == g_GM_HIDE_TITLE_INFO then --隐藏entity头顶相关
		local world = i3k_game_get_world()
		if world then
			local vis = tonumber(args) == 1 or false
			world:visTitleAndName(vis)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_GmSetLevel)
		return
	end


	--text = string.format(g_GM_COMMAND[gmType], args)
	--i3k_sbean.world_msg_send_req(text)
	if self.args and self.args.commond then
		self:onSendImpl(string.format("%s %s", self.args.commond, args))
	else
		self:onSendImpl(args)
	end
	self:onSendImpl()
	g_i3k_ui_mgr:CloseUI(eUIID_GmSetLevel)
end

function wnd_gm_set_level:onSendImpl(str)
	local req = i3k_sbean.msg_send_req.new()
	req.type = global_world
	req.id = 0
	req.msg = str
	req.gsName = ""
	i3k_game_send_str_cmd(req, "msg_send_res")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_set_level.new()
	wnd:create(layout, ...);
	return wnd
end
