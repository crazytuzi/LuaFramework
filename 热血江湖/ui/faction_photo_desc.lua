-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_photo_desc = i3k_class("wnd_faction_photo_desc", ui.wnd_base)

local ROLE_DESC = "ui/widgets/bpgzt"

function wnd_faction_photo_desc:ctor()
	
end

function wnd_faction_photo_desc:configure(...)
	local widgets = self._layout.vars
	widgets.nextBtn:onClick(self, self.onNext)
	widgets.close_btn2:onClick(self, self.onCloseUI)
end


function wnd_faction_photo_desc:refresh()
	local widgets = self._layout.vars
	local node = require(ROLE_DESC)()
	node.vars.ruleDesc:setText(i3k_get_string(1775))
	widgets.scroll:addItem(node)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local textUI = node.vars.ruleDesc
		local size = node.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		i3k_log(width, height)
		node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
	end, 1)
end

function wnd_faction_photo_desc:onNext()
	if g_i3k_game_handler.CheckStoragePermission then
		local res = g_i3k_game_handler:CheckStoragePermission()
		if res == 0 then
			-- ��Ҫ����洢Ȩ�޲ſ��Խ�����һ��
			g_i3k_ui_mgr:PopupTipMessage("��Ҫ�洢Ȩ�޲���ʹ�ð��ɺ���")
			return
		end
	end
	if not g_i3k_game_context:ishaveFactionFightGroupPower(g_FACTION_GROUP_PHOTO) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1784))
	else
		local data = i3k_sbean.sect_members_req.new()
		data.callBack = function()
			g_i3k_ui_mgr:OpenUI(eUIID_FactionPhotoList)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionPhotoList)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionPhotoTips)
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
	end
	
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_photo_desc.new();
		wnd:create(layout, ...);
	return wnd;
end
