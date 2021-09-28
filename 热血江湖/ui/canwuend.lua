-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_canwuEnd = i3k_class("wnd_canwuEnd", ui.wnd_base)

function wnd_canwuEnd:ctor()
	--self.typeName = {"武道", "身法", "内力", "防御", "暴击", "韧性"}
	self.needItem ={}
end



function wnd_canwuEnd:configure(...)
	local widgets = self._layout.vars
	self._layout.vars.okBtn:onClick(self, self.onCloseUI)
	self.descLabel = widgets.descLabel
	self.percentLabel = widgets.percentLabel
end
function wnd_canwuEnd:onShow()
	
end

function wnd_canwuEnd:refresh(wudaoID, getExp)
	self:updateLayerData(wudaoID, getExp)
	self.percentLabel:hide()
end 

function wnd_canwuEnd:updateLayerData(wudaoID, getExp)
	local args = g_i3k_db.i3k_db_experience_args
	local typeName = {}
	for k,v in ipairs(i3k_db_experience_canwu) do
		typeName[k] = v[1].name
	end
	local str = string.format(i3k_get_string(475, getExp))
	self.descLabel:setText(str)
	g_i3k_game_context:AddCanWuExp(wudaoID, getExp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "canwuCountData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "setCanwuData")
end

--[[function wnd_canwuEnd:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_CanWuEnd)
end--]]


function wnd_create(layout, ...)
	local wnd = wnd_canwuEnd.new()
	wnd:create(layout, ...)
	return wnd
end
