
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/meridianPotential");
local Base = ui.wnd_meridianPotential
-------------------------------------------------------
wnd_queryMeridian = i3k_class("wnd_queryMeridian",Base)

function wnd_queryMeridian:ctor()
	Base.ctor(self)
	self.meridians = nil
	self.selectedMeridian = nil
	self.selectedMeridianId = 0
end

function wnd_queryMeridian:configure()
	Base.initWidgets(self)
	local widgets = self._layout.vars
	self.meridianScroll = widgets.meridianScroll
end

function wnd_queryMeridian:refresh(meridians)
	self.meridians = meridians
	local item_size
	for i,v in ipairs(i3k_db_meridians.meridians) do
		local node = require("ui/widgets/qiannenghyt2")()
		item_size = node.rootVar:getSize()
		self.meridianScroll:addItem(node)
		node = node.vars
		node.btn:onClick(self, self.onUpdateMeridian, i)
		node.name:setText(v.name)
		if not self.selectedMeridian then
			self.selectedMeridianId = i
			self.selectedMeridian = node.btn
			node.btn:stateToPressed(true)
		end
	end
	if item_size then
		local width = item_size.width* #i3k_db_meridians.meridians
		local scl_size = self.meridianScroll:getContentSize()
		if width < scl_size.width then
			self.meridianScroll:setContentSize(width, item_size.height)
			self.meridianScroll:update()
		end
	end
	self:updateUI()
end

function wnd_queryMeridian:updateUI()
	local tbl
	if not self.meridians[self.selectedMeridianId] then
		self.meridians[self.selectedMeridianId] = {}
		tbl = {}
		local meridiansCfg = i3k_db_meridians.meridians[self.selectedMeridianId]

		for k,v in ipairs(meridiansCfg.acupuncturePointIds) do
			tbl[v] = {energy = 0}
		end
		self.meridians[self.selectedMeridianId].holes = tbl
	end

	Base.refresh(self, self.selectedMeridianId, self.meridians[self.selectedMeridianId])
end

function wnd_queryMeridian:onUpdateMeridian(sender, merId)
	if self.selectedMeridian == sender then
		return
	end
	sender:stateToPressed(true)
	self.selectedMeridian:stateToNormal(true)
	self.selectedMeridian = sender
	self.selectedMeridianId = merId

	self:updateUI()
end

function wnd_queryMeridian:updateScroll()
	local rankIcon = i3k_db_meridians.common.rankIcon
	local potCfg = i3k_db_meridians.potentia
	local meridiansCfg = i3k_db_meridians.meridians[self.selectedMeridianId]

	local potential = self.meridians[self.selectedMeridianId] and self.meridians[self.selectedMeridianId].potentials or {}
	local power = 0
	self.scroll:removeAllChildren()
	for i , v in ipairs(meridiansCfg.potentialIds) do
		local node = require("ui/widgets/qiannenghyt")()
		local lvl = potential[v] or 0
		local cfg = potCfg[v][lvl]
		self.scroll:addItem(node)
		node = node.vars
		node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
		node.bg:setImage(g_i3k_db.i3k_db_get_icon_path(rankIcon[cfg.rank]))
		node.name:setText(cfg.name)
		node.lvl:setText(lvl)
		if cfg.combatValue > 0 or lvl == 0 then
			node.specialIcon:hide()
			node.power:setText(cfg.combatValue)
		else
			node.power:hide()
		end
		node.desc:setText(cfg.desc)--self:getAttrTxt(cfg.attr)
		power = power + cfg.combatValue
	end
	self.power:setText(power)
end

function wnd_create(layout, ...)
	local wnd = wnd_queryMeridian.new()
	wnd:create(layout, ...)
	return wnd;
end

