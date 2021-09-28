--活动任务接受任务界面 
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_festivalTaskAcceptBase = i3k_class("wnd_festivalTaskAcceptBase", ui.wnd_base)


function wnd_festivalTaskAcceptBase:ctor()

    self.Item_Widget = "ui/widgets/jierirwt"
end

function wnd_festivalTaskAcceptBase:localScroll(rewards, scroll)
	for k, v in ipairs(rewards) do
		local node = require(self.Item_Widget)()
		local itemID = v.itemID
		node.vars.count:setText("x"..v.itemCount)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		node.vars.suo:setVisible(itemID > 0)
		node.vars.btn:onClick(self, self.onItemTip, itemID)
		scroll:addItem(node)
	end
end

function wnd_festivalTaskAcceptBase:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_festivalTaskAcceptBase:onGiveUpBtn(sender)
	self:onCloseUI()
	-- local message = "确定放弃任务吗？"
	-- local callback = function(ok)
	-- 	if ok then
	-- 		i3k_sbean.quitPowerReqTask(self._npcID)
	-- 	end
	-- end
	-- g_i3k_ui_mgr:ShowMessageBox2(message, callback)
end
function wnd_festivalTaskAcceptBase:SetTaskName(taskName)
	self._layout.vars.taskName:setText(taskName)
end

function wnd_festivalTaskAcceptBase:SetTaskDesc(taskString)
	self._layout.vars.taskDesc:setText(taskString)
end
function wnd_festivalTaskAcceptBase:SetTaskKillDesc(taskString)
	self._layout.vars.taskKill:setText(taskString)
end

function wnd_create(layout, ...)
	local wnd = wnd_festivalTaskAcceptBase.new()
	wnd:create(layout, ...)
	return wnd;
end
