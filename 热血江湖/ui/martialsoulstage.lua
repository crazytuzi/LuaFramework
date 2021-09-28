-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_martialSoulStage = i3k_class("wnd_martialSoulStage", ui.wnd_base)
local PROP = "ui/widgets/wuhunsjt1"
local ITEM = "ui/widgets/wuhunsjt2"
function wnd_martialSoulStage:ctor()
	
end

function wnd_martialSoulStage:configure()
	local widgets = self._layout.vars;
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.up_state = widgets.up_state;
	self.now_stage = widgets.now_stage
	self.next_stage = widgets.next_stage; 
	self.needLvl	= widgets.needLvl;
	self.needTotalLvl	= widgets.needTotalLvl;
	self.effectScroll	= widgets.effectScroll;
	self.itemScroll = widgets.itemScroll;
	self.promptDesc = widgets.promptDesc;
end

function wnd_martialSoulStage:refresh()
	self:UpdateText()
	self:AffectScroll();
	self:ItemScroll();
end

function wnd_martialSoulStage:UpdateText()
	local Grade =  g_i3k_game_context:GetWeaponSoulGrade();
	local soul =  i3k_db_martial_soul_rank[Grade];
	local nextRank = i3k_db_martial_soul_rank[Grade + 1]
	local AverageLvl, TotalLvl = g_i3k_game_context:IsCanGrade();
	if AverageLvl then
		self.needLvl:setTextColor(g_i3k_get_green_color());
	else
		self.needLvl:setTextColor(g_i3k_get_red_color());
	end
	if TotalLvl then
		self.needTotalLvl:setTextColor(g_i3k_get_green_color());
	else
		self.needTotalLvl:setTextColor(g_i3k_get_red_color());
	end
	if soul then
		self.now_stage:setText(soul.rankName);
		self.promptDesc:setText(soul.promptDesc);
	end
	if nextRank then
		self.needLvl:setText(i3k_get_string(1062, nextRank.needAverageLvl));
		self.needTotalLvl:setText(i3k_get_string(1063, nextRank.needTotalLvl, g_i3k_game_context:GetWeaponSoulTotalLvl())); 
		self.next_stage:setText(nextRank.rankName);
	end 
end

function wnd_martialSoulStage:AffectScroll()
	local Grade =  g_i3k_game_context:GetWeaponSoulGrade();
	local propTb =  i3k_db_martial_soul_rank[Grade].propTb;
	local propNextTb =  i3k_db_martial_soul_rank[Grade + 1].propTb;
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_MARTIAL_ID)
	self.effectScroll:removeAllChildren()
	if propNextTb then
		for i, e in ipairs(propNextTb) do
			if e.propID ~= 0 then
				local node = require(PROP)()
				local widget = node.vars
				local icon = g_i3k_db.i3k_db_get_property_icon(e.propID)
				node.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
				node.vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(e.propID))
				if propTb then
					local nowProp =  propTb[i];
					if nowProp and nowProp.propID == e.propID then
						if nowProp.propValue ~= 0 then
							node.vars.propertyValue:setText(i3k_get_prop_show(e.propID, math.modf(nowProp.propValue * (1 + ratio))));
							node.vars.nextValue:setText("+"..i3k_get_prop_show(e.propID, math.modf((e.propValue - nowProp.propValue) * (1 + ratio))))
						end
					else
						node.vars.propertyValue:setText("0");
						node.vars.nextValue:setText("+"..i3k_get_prop_show(e.propID, math.modf(e.propValue * (1 + ratio))));
					end
					self.effectScroll:addItem(node)
				end
			end
		end
	end
end

function wnd_martialSoulStage:ItemScroll()
	local Grade =  g_i3k_game_context:GetWeaponSoulGrade();
	local needItems =  i3k_db_martial_soul_rank[Grade + 1].needItems;
	local Items = {};
	if needItems then
		for k,v in ipairs(needItems) do
			if v.itemID > 0 then
				table.insert(Items, v)
			end
		end
	end
	self.up_state:onClick(self, self.onUpState, Items)
	self.itemScroll:removeAllChildren()
	for _, e in ipairs(Items) do
		local node = require(ITEM)()
		local widget = node.vars
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemID))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID,i3k_game_context:IsFemaleRole()))
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		if e.itemID == g_BASE_ITEM_DIAMOND or e.itemID == g_BASE_ITEM_COIN then
			widget.item_count:setText(needItemCount)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) .."/".. e.itemCount)
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) >= e.itemCount))
		widget.bt:onClick(self, self.onItemTips, e.itemID);
		self.itemScroll:addItem(node)
	end
end

function wnd_martialSoulStage:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_martialSoulStage:onUpState(sender, Items)
	local AverageLvl, TotalLvl = g_i3k_game_context:IsCanGrade();
	if AverageLvl and TotalLvl then
		if g_i3k_game_context:WeaponSoulGradeItemCount() then
			local Grade =  g_i3k_game_context:GetWeaponSoulGrade() + 1;
			i3k_sbean.weaponSoulGradeUp(Grade, Items)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1065))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1064))
	end
end

function wnd_create(layout)
	local wnd = wnd_martialSoulStage.new();
		wnd:create(layout);
	return wnd;
end