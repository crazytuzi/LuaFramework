-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_familyDonateRoles = i3k_class("wnd_familyDonateRoles", ui.wnd_base)

local SCOLLITEM = "ui/widgets/bangpaihuzhujzzt"

function wnd_familyDonateRoles:ctor()

end

function wnd_familyDonateRoles:configure()
	local weights = self._layout.vars
	weights.close:onClick(self, self.onCloseUI)	
end

function wnd_familyDonateRoles:onShow()
	
end

function wnd_familyDonateRoles:onHide()

end

function wnd_familyDonateRoles:refresh(roleInfo)	
	local weights = self._layout.vars
	local scoll = weights.scoll
	local sortTable = {}
	
	local fun = function(a, b)
		return a.id < b.id
	end
	
	for k, v in ipairs(roleInfo) do
		sortTable[k] = v.data.role
	end
	
	table.sort(sortTable, fun)
	scoll:addChildWithCount(SCOLLITEM, 4, #roleInfo, true)
	
	for k, v in ipairs(sortTable) do
		local node = scoll:getChildAtIndex(k)
		local weight = node.vars
		weight.iconType:setImage(g_i3k_get_head_bg_path(v.bwType, v.headBorder))
		weight.lvl:setText(v.level)
		weight.name:setText(v.name)
		weight.zhiyeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.type].classImg))
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(v.headIcon, g_i3k_db.eHeadShapeQuadrate)
		
		if hicon and hicon > 0 then
			weight.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_familyDonateRoles.new();
	wnd:create(layout, ...)

	return wnd
end
