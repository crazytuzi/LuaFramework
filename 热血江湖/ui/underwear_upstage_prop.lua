-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_underwear_upStage_prop = i3k_class("wnd_underwear_upStage_prop", ui.wnd_base)

local DESCWIDGET = "ui/widgets/njqst"

function wnd_underwear_upStage_prop:ctor()
	
end

function wnd_underwear_upStage_prop:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_underwear_upStage_prop:refresh(id, stage)
	self:updateScroll(id, stage)
end

function wnd_underwear_upStage_prop:updateScroll(id, stage)
	for k, v in ipairs(i3k_db_under_wear_upStage[id]) do
		if k >= stage then
			local descNode = require(DESCWIDGET)()
			local stageName = i3k_db_under_wear_upStage[id][k].stageName
			local name = string.split(stageName, "·")
			descNode.vars.title:setText(name[2])
			descNode.vars.desc:setText(i3k_db_under_wear_upStage[id][k].desc)
			self._layout.vars.scroll:addItem(descNode)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_underwear_upStage_prop.new();
	wnd:create(layout);
	return wnd;
end