-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_end = i3k_class("wnd_chess_task_end", ui.wnd_base)

local ITEM = "ui/widgets/zhenlongqijujst"

function wnd_chess_task_end:ctor()
	
end

function wnd_chess_task_end:configure()
	
end

function wnd_chess_task_end:refresh(state)
	self._layout.vars.endBtn:onClick(self, self.onEndBtn)
	local chessTask = g_i3k_game_context:getChessTask()
	if state == 0 then
		self._layout.vars.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(6501))
		self._layout.vars.desc:setText(i3k_get_string(17278))
		self._layout.vars.endText:setText("就到这里")
	else
		self._layout.vars.desc:setText(i3k_get_string(17277))
		self._layout.vars.endText:setText("完美通关")
		self._layout.vars.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(6500))
	end
	self._layout.vars.scroll:removeAllChildren()
	for k, v in pairs(chessTask.loopRewards) do
		local node = require(ITEM)()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k))
		node.vars.suo:setVisible(k > 0)
		node.vars.count:setText("x"..v)
		node.vars.itemBtn:onClick(self, self.onItemInfo, k)
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_chess_task_end:onEndBtn(sender)
	i3k_sbean.chess_game_cancel()
	self:onCloseUI()
end

function wnd_chess_task_end:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_chess_task_end.new()
	wnd:create(layout)
	return wnd
end
