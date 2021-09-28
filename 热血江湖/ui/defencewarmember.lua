-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defencewarMember = i3k_class("wnd_defencewarMember", ui.wnd_base)

function wnd_defencewarMember:ctor()

end

function wnd_defencewarMember:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI) 
end

function wnd_defencewarMember:refresh(roles)
	local weights = self._layout.vars
	weights.scroll_schedule:removeAllChildren()
	local role = {}
	
	for _, v in pairs(roles) do
		if v ~= nil then
			table.insert(role, v)
		end
	end
	
	table.sort(role, function (a, b) return a.fightPower > b.fightPower end)
	
	for _, v in ipairs(role) do
		local node = require("ui/widgets/zdchengzhan2t")()
		local weight = node.vars
		weight.name:setText(v.name)
		weight.power:setText(v.fightPower)
		weights.scroll_schedule:addItem(node)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_defencewarMember.new()
	wnd:create(layout, ...)
	return wnd;
end
