-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_gem_bless = i3k_class("wnd_gem_bless",ui.wnd_base)

local bless_rankImg = {5139, 5140, 5141, 5142, 10856, 10857, 10858, 10859, 10860, 10861}

function wnd_gem_bless:ctor()
	self._pos = 0
	self._slotPos = 0
	self._gemId = 0
	self._blessLvl = nil  --祝福等级
	self._canBless = false --道具是否足够
end

function wnd_gem_bless:configure()
	local widgets = self._layout.vars
	
	self.gemName = widgets.gemName
	self.gemGrade = widgets.gemGrade
	self.gemIcon = widgets.gemIcon
	self.blessDesc = widgets.blessDesc
	self.consumeGrade = widgets.consumeGrade
	self.consumeIcon = widgets.consumeIcon
	self.consumeCount = widgets.consumeCount
	self.blessLable = widgets.blessLable
	self.consumeBtn = widgets.consumeBtn
	
	self.blessBtn = widgets.blessBtn
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.blessBtn:onClick(self, self.onBless)
end

function wnd_gem_bless:refresh(info)
	self._pos = info.pos
	self._slotPos = info.seq
	self._gemId = info.gemId
	self._blessLvl = info.blessLvl
	self._blessCfg = i3k_db_equip_part[info.pos].blessing
	self:loadBlessData(info)
end

function wnd_gem_bless:loadBlessData(info)
	self.blessLable:setVisible(info.blessLvl and info.blessLvl == #self._blessCfg.itemCount)
	self.blessBtn:setVisible(not info.blessLvl or info.blessLvl < #self._blessCfg.itemCount)
	self.gemName:setText(g_i3k_db.i3k_db_get_common_item_name(info.gemId))
	self.gemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(info.gemId)))
	self.gemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.gemId, g_i3k_game_context:IsFemaleRole()))
	self.gemGrade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.gemId))
	
	local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(info.gemId)
	local blessCfg = g_i3k_db.i3k_db_get_diamond_bless_cfg(gemCfg.type)
	local propName = g_i3k_db.i3k_db_get_property_name(gemCfg.effect_id)
	if not info.blessLvl then
		-- 祝福前效果
		--self._layout.vars.gemBefore:disableWithChildren()
		self._layout.vars.blessDescBefore:setText("尚未祝福") 
		
		-- 祝福后效果
		self.blessDesc:setText(string.format("%s +%s%%", propName, blessCfg[1] * 100))
		self._layout.vars.gemAfter:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[1]))
	else
		-- 祝福前效果
		self._layout.vars.gemBefore:enableWithChildren()
		self._layout.vars.gemBefore:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[info.blessLvl]))
		self._layout.vars.blessDescBefore:setText(string.format("%s +%s%%", propName, blessCfg[info.blessLvl] * 100))
		
		-- 祝福后效果
		if info.blessLvl < #self._blessCfg.itemCount then
			self.blessDesc:setText(string.format("%s +%s%%", propName, blessCfg[info.blessLvl + 1] * 100))
			self._layout.vars.gemAfter:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[info.blessLvl + 1]))
		else
			self._layout.vars.maxIcon:show()
			self._layout.vars.gemRoot:hide()
		end
	end
	
	self:loadConsumeItemInfo()
end

function wnd_gem_bless:loadConsumeItemInfo()
	local id = self._blessCfg.itemID
	local count = 0
	if not self._blessLvl then
		count = self._blessCfg.itemCount[1]
	elseif self._blessLvl < #self._blessCfg.itemCount then
		count = self._blessCfg.itemCount[self._blessLvl + 1]
	end
	self.consumeIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	self.consumeCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(id).."/"..count)
	self.consumeCount:setTextColor(g_i3k_get_cond_color(count <= g_i3k_game_context:GetCommonItemCanUseCount(id)))
	self._canBless = g_i3k_game_context:GetCommonItemCanUseCount(id) >= count
	self.consumeGrade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.consumeBtn:onClick(self, self.onItemTips, id)
end

function wnd_gem_bless:onBless(sender)
	if self._canBless then
		i3k_sbean.equip_gem_bless(self._pos, self._slotPos, self._gemId, self._blessLvl)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

function wnd_gem_bless:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_gem_bless.new()
	wnd:create(layout)
	return wnd
end
