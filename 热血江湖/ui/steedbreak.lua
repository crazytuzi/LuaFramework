module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_steedBreak = i3k_class("wnd_steedBreak", ui.wnd_base)

function wnd_steedBreak:ctor()
	
end

function wnd_steedBreak:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_steedBreak:refresh(id)
	self._id = id
	local info = g_i3k_game_context:getSteedInfoBySteedId(id)
	local starLvl = info.star
	local nowAttr = {}
	local nextAttr = {}
	local breakLevel = g_i3k_game_context:GetSteedBreakInfo(id)
	if breakLevel > 0 then
		local breakCfgNow = i3k_db_steed_breakCfg[id][breakLevel]
		nowAttr = {
			[1] = {attrId = breakCfgNow.attrId1, attrValue = breakCfgNow.attrValue1},
			[2] = {attrId = breakCfgNow.attrId2, attrValue = breakCfgNow.attrValue2},
			[3] = {attrId = breakCfgNow.attrId3, attrValue = breakCfgNow.attrValue3},
			[4] = {attrId = breakCfgNow.attrId4, attrValue = breakCfgNow.attrValue4},
			[5] = {attrId = breakCfgNow.attrId5, attrValue = breakCfgNow.attrValue5},
			[6] = {attrId = breakCfgNow.attrId6, attrValue = breakCfgNow.attrValue6},
			[7] = {attrId = breakCfgNow.attrId7, attrValue = breakCfgNow.attrValue7},
			[8] = {attrId = breakCfgNow.attrId8, attrValue = breakCfgNow.attrValue8},
			[9] = {attrId = breakCfgNow.attrId9, attrValue = breakCfgNow.attrValue9},
		}
	end
	
	local breakCfgNext = i3k_db_steed_breakCfg[id][breakLevel + 1]
	nextAttr = {
			[1] = {attrId = breakCfgNext.attrId1, attrValue = breakCfgNext.attrValue1},
			[2] = {attrId = breakCfgNext.attrId2, attrValue = breakCfgNext.attrValue2},
			[3] = {attrId = breakCfgNext.attrId3, attrValue = breakCfgNext.attrValue3},
			[4] = {attrId = breakCfgNext.attrId4, attrValue = breakCfgNext.attrValue4},
			[5] = {attrId = breakCfgNext.attrId5, attrValue = breakCfgNext.attrValue5},
			[6] = {attrId = breakCfgNext.attrId6, attrValue = breakCfgNext.attrValue6},
			[7] = {attrId = breakCfgNext.attrId7, attrValue = breakCfgNext.attrValue7},
			[8] = {attrId = breakCfgNext.attrId8, attrValue = breakCfgNext.attrValue8},
			[9] = {attrId = breakCfgNext.attrId9, attrValue = breakCfgNext.attrValue9},
		}
		
	self._layout.vars.scroll:removeAllChildren()
	for i,v in ipairs(nextAttr) do
		if v.attrId ~= 0 then
			local node = require("ui/widgets/zqsxt")()
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.attrId))
			node.vars.nameLabel:setText(i3k_db_prop_id[v.attrId].desc.."：")
			local value = v.attrValue - (nowAttr[i] and nowAttr[i].attrValue or 0)
			node.vars.valueLabel:setText("+"..i3k_get_prop_show(v.attrId, value))
			node.vars.backImg1:setVisible(i%2==0)
			node.vars.backImg2:setVisible(not node.vars.backImg1:isVisible())
			self._layout.vars.scroll:addItem(node)
		end
	end
	self:showItems()
	self._layout.vars.breakBtn:onClick(self, self.OnBreak, id)
end

function wnd_steedBreak:showItems()
	local breakLevel = g_i3k_game_context:GetSteedBreakInfo(self._id)
	local cfg = i3k_db_steed_breakCfg[self._id][breakLevel + 1]
	local needId1 = cfg.itemId1
	local needCount1 = cfg.itemCount1
	local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needId1)
	local needId2 = cfg.itemId2
	local needCount2 = cfg.itemCount2
	local itemCount2 = g_i3k_game_context:GetCommonItemCanUseCount(needId2)
	
	self._layout.vars.itemNameLabel1:setText(g_i3k_db.i3k_db_get_common_item_name(needId1))
	local rank = g_i3k_db.i3k_db_get_common_item_rank(needId1)
	self._layout.vars.itemNameLabel1:setTextColor(g_i3k_get_color_by_rank(rank))
	self._layout.vars.itemGradeIcon1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId1))
	self._layout.vars.itemIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId1,i3k_game_context:IsFemaleRole()))
	self._layout.vars.itemLock1:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needId1))
	if math.abs(needId1) == g_BASE_ITEM_COIN then
		self._layout.vars.itemCountLabel1:setText(needCount1)
	else
		self._layout.vars.itemCountLabel1:setText(itemCount1.."/"..needCount1)
	end
	self._layout.vars.itemCountLabel1:setTextColor(g_i3k_get_cond_color(needCount1<=itemCount1))
	self._layout.vars.itemBtn1:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needId1)
	end)
	
	self._layout.vars.itemNameLabel2:setText(g_i3k_db.i3k_db_get_common_item_name(needId2))
	local rank2 = g_i3k_db.i3k_db_get_common_item_rank(needId2)
	self._layout.vars.itemNameLabel2:setTextColor(g_i3k_get_color_by_rank(rank2))
	self._layout.vars.itemGradeIcon2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId2))
	self._layout.vars.itemIcon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId2,i3k_game_context:IsFemaleRole()))
	self._layout.vars.itemLock2:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needId2))
	if math.abs(needId2) == g_BASE_ITEM_COIN then
		self._layout.vars.itemCountLabel2:setText(needCount2)
	else
		self._layout.vars.itemCountLabel2:setText(itemCount2.."/"..needCount2)
	end
	self._layout.vars.itemCountLabel2:setTextColor(g_i3k_get_cond_color(needCount2<=itemCount2))
	self._layout.vars.itemBtn2:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needId2)
	end)
end

function wnd_steedBreak:OnBreak(sender, id)
	local breakLevel = g_i3k_game_context:GetSteedBreakInfo(id)
	local nextBreakLevel = breakLevel + 1
	local cfg = i3k_db_steed_breakCfg[id][breakLevel + 1]
	local needId1 = cfg.itemId1
	local needCount1 = cfg.itemCount1
	local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needId1)
	local needId2 = cfg.itemId2
	local needCount2 = cfg.itemCount2
	local itemCount2 = g_i3k_game_context:GetCommonItemCanUseCount(needId2)
	if needCount1 > itemCount1 or needCount2 > itemCount2 then
		g_i3k_ui_mgr:PopupTipMessage("所需物品不足")
	else
		i3k_sbean.horse_breakthrough(id, nextBreakLevel)
	end
end

function wnd_create(layout)
	local wnd = wnd_steedBreak.new();
		wnd:create(layout);
	return wnd;
end
