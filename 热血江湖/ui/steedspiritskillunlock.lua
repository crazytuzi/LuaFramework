-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSpiritSkillUnlock = i3k_class("wnd_steedSpiritSkillUnlock", ui.wnd_base)

local WIDGET_ZQQZSJT = "ui/widgets/zqqzsjt"

function wnd_steedSpiritSkillUnlock:ctor()
	self._id = 0
	self._lvl = 0
	self._needItems = {}
	self._needRank = 0
end

function wnd_steedSpiritSkillUnlock:configure()
	local widgets = self._layout.vars
	self.skillIcon = widgets.skillIcon
	self.skillName = widgets.skillName
	self.skillLvl = widgets.skillLvl
	self.nextTitle = widgets.nextTitle
	self.needRankDesc = widgets.needRankDesc
	self.nextEffect = widgets.nextEffect
	self.itemScroll = widgets.itemScroll
	self.unlockBtn = widgets.unlockBtn
	widgets.unlockBtn:onClick(self, self.onUnlockBtn)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_steedSpiritSkillUnlock:refresh(id, lvl)
	self._id = id
	self._lvl = lvl
	local dbCfg = i3k_db_steed_fight_spirit_skill[id]
	local nextCfg = dbCfg[lvl + 1]
	self.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(dbCfg[lvl + 1].skillIconID))
	self.skillName:setText(dbCfg[lvl + 1].skillName)
	self.skillLvl:setText(i3k_get_string(1293))
	self._needRank = nextCfg.needRank
	self:loadNextLvlDesc(lvl+1)
	self:initNeedItems(dbCfg[lvl+1])
	self:loadItemScroll()
	self:loadBtnState()
end

function wnd_steedSpiritSkillUnlock:loadNextLvlDesc(lvl)
	local dbCfg = i3k_db_steed_fight_spirit_skill[self._id]
	local cfg = dbCfg[lvl]
	if cfg then
		local rankDesc = i3k_db_steed_fight_spirit_rank[cfg.needRank + 1].rankDesc
		self.nextTitle:setText(i3k_get_string(1292, lvl))
		self.needRankDesc:setText(i3k_get_string(1294, rankDesc))
		self.needRankDesc:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:getSteedSpiritRank() >= cfg.needRank))
		self.nextEffect:setText(cfg.skillDesc)
	end
end

function wnd_steedSpiritSkillUnlock:initNeedItems(data)
	self._needItems = {}
	for i, e in ipairs(data.needItems) do
		if e.itemID ~= 0 then
			table.insert(self._needItems, {itemID = e.itemID, itemCount = e.itemCount})
		end
	end
end

function wnd_steedSpiritSkillUnlock:loadItemScroll()
	self.itemScroll:removeAllChildren()
	for _, e in ipairs(self._needItems) do
		local widget = require(WIDGET_ZQQZSJT)()
		-- widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
			widget.vars.item_count:setText(e.itemCount)
		else
			widget.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
		end
		widget.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
		widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.vars.tip_btn:onClick(self, self.onItemTips, e.itemID)
		self.itemScroll:addItem(widget)
	end

end

function wnd_steedSpiritSkillUnlock:loadBtnState()
	if g_i3k_game_context:getSteedSpiritRank() < self._needRank then
		self.unlockBtn:disableWithChildren()
	else
		self.unlockBtn:enableWithChildren()
	end
end

function wnd_steedSpiritSkillUnlock:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_steedSpiritSkillUnlock:onUnlockBtn(sender)
	if g_i3k_game_context:getSteedSpiritRank() < self._needRank then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1295))
	end

	if not g_i3k_db.i3k_db_get_item_is_enough_up(self._needItems) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end

	i3k_sbean.horse_spirit_skill_lvlup_request(self._id, self._lvl + 1, self._needItems)
end

function wnd_create(layout)
	local wnd = wnd_steedSpiritSkillUnlock.new()
	wnd:create(layout)
	return wnd
end
