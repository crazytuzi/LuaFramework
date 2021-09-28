------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_homeland_guard_treeBlood = i3k_class("wnd_homeland_guard_treeBlood",ui.wnd_base)


local BUFF_ITEM = "ui/widgets/hudxlzmtem"

function wnd_homeland_guard_treeBlood:ctor()
	self.treeItems = {}
end

function wnd_homeland_guard_treeBlood:configure()
	self.widgets = self._layout.vars
end

function wnd_homeland_guard_treeBlood:refresh(goldenTreeInfos)
	self.widgets.totalText:setText(i3k_get_string(5545))
	local bloodTable = {}
	
	for k,v in pairs(goldenTreeInfos) do
		v.id = k
		table.insert(bloodTable, v)
	end

	table.sort(bloodTable, function(a,b) return a.id < b.id end)

	for _,info in ipairs(bloodTable) do
		if not self.treeItems[info.id] then
			local item = require(BUFF_ITEM)()
			item.vars.target:hide()
			item.vars.name:setText(i3k_db_monsters[112130].name)
			local percent = info.curHp / info.maxHp * 100
			item.vars.current:setPercent(percent)
			item.vars.value:setText(math.floor(percent).."%")
			self.widgets.scroll:addItem(item)
			self.treeItems[info.id] = item
		end
	end
end

function wnd_homeland_guard_treeBlood:UpdateTreeBlood(info)
	local percent = info.curHp / info.maxHp * 100
	self.treeItems[info.id].vars.current:setPercent(percent)
	self.treeItems[info.id].vars.value:setText(math.floor(percent).."%")
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_homeland_guard_treeBlood.new()
	wnd:create(layout,...)
	return wnd
end