-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianPotentialUp = i3k_class("wnd_meridianPotentialUp",ui.wnd_base)

function wnd_meridianPotentialUp:ctor()
	self.meridianId = 0
	self.potentialId = 0
	self.currLvl = 0
	self.energy = 0
end

function wnd_meridianPotentialUp:configure(...)
	local widgets = self._layout.vars
	widgets.up_btn:onClick(self,self.OnUpLvl)
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.currLvlDesc = widgets.currLvlDesc
	self.nextLvlDesc = widgets.nextLvlDesc
	self.btn_label = widgets.btn_label
	self.name = widgets.name
end

function wnd_meridianPotentialUp:refresh(meridianId, potentialId, energy)
	self.meridianId = meridianId
	self.potentialId = potentialId
	self.energy = energy
	self:updateUI()
end

function wnd_meridianPotentialUp:OnUpLvl(sender)
	i3k_sbean.meridianPotentialUp(self.meridianId, self.potentialId, self.currLvl + 1)
end

function wnd_meridianPotentialUp:getAttrTxt(attr)
	local str = {}
	for i,v in ipairs(attr) do
		if v.id > 0 then
			table.insert(str,i3k_db_prop_id[v.id].desc.."+"..i3k_get_prop_show(v.id, v.value))
		end
	end
	if #str == 0 then
		return "无属性提升"
	else
		return table.concat(str,",")
	end
end

function wnd_meridianPotentialUp:updateUI()
	local widgets = self._layout.vars
	self.currLvl = g_i3k_game_context:getMeridianPotentialLvl(self.potentialId)
	local currcfg = i3k_db_meridians.potentia[self.potentialId][self.currLvl]
	local nextcfg = i3k_db_meridians.potentia[self.potentialId][self.currLvl + 1]

	if not nextcfg then
		self:onCloseUI()
		return g_i3k_ui_mgr:PopupTipMessage("您已经达到最高级")
	end

	if self.currLvl == 0 then
		self.btn_label:setText("激活")
	else
		self.btn_label:setText("升级")
	end
	self.name:setText(currcfg.name)

	widgets.tips:setText(string.format("%s气海达到:%s/%s",i3k_db_meridians.meridians[self.meridianId].name, self.energy, nextcfg.gasSea))
	local energyEnough = self.energy >= nextcfg.gasSea
	widgets.tips:setTextColor(g_i3k_get_cond_color(energyEnough))

	self.currLvlDesc:setText(currcfg.desc)--self:getAttrTxt(currcfg.attr)
	self.nextLvlDesc:setText(nextcfg.desc)--self:getAttrTxt(nextcfg.attr)

	widgets.scroll:removeAllChildren()
	local itemEnough = true
	for k,v in ipairs(nextcfg.needItem) do
		if v.id ~= 0 then
			local node = require("ui/widgets/qiannengsjt")()
			widgets.scroll:addItem(node)
			node = node.vars
			node.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
			node.bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
			if v.id == g_BASE_ITEM_COIN then
				node.count:setText(v.count)
			else
				node.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id).."/"..v.count)
			end
			local notenough = v.count > g_i3k_game_context:GetCommonItemCanUseCount(v.id)
			if notenough then
				itemEnough = false
			end
			node.count:setTextColor(g_i3k_get_cond_color(not notenough))
			node.btn:onClick(self, self.itemTips, v.id)
		end
	end
	if energyEnough and itemEnough then
		widgets.up_btn:enable()
	else
		widgets.up_btn:disable()
	end
end

function wnd_meridianPotentialUp:itemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_meridianPotentialUp.new()
	wnd:create(layout)
	return wnd
end
