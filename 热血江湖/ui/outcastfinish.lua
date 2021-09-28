-------------------------------------------------------
-- eUIID_OutCastFinish
------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_outCastFinish = i3k_class("wnd_outCastFinish", ui.wnd_base)

function wnd_outCastFinish:ctor()
	
end

function wnd_outCastFinish:configure()
	local widgets = self._layout.vars
	self._widgets = widgets
	widgets.ok:onClick(self, function()
		i3k_sbean.mapcopy_leave()
	end)
end

function wnd_outCastFinish:refresh(info)
	local id = info.lastUnlockID
	local cfg = i3k_db_out_cast[id]
	local taskCfg = i3k_db_out_cast_task[g_i3k_game_context:getOutCastLastTask(id)]
	if not taskCfg or not cfg then  
		i3k_sbean.mapcopy_leave()
	end
	self._widgets.desc:setText(cfg.finishDesc)
	g_i3k_ui_mgr:refreshScrollItems(self._widgets.scrollview, taskCfg.awards, "ui/widgets/rchwztgt")
end


function wnd_create(layout)
	local wnd = wnd_outCastFinish.new()
	wnd:create(layout)
	return wnd
end