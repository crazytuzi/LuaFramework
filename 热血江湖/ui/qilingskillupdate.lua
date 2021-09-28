module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingSkillUpdate = i3k_class("wnd_qilingSkillUpdate", ui.wnd_base)

local WIDGETITEM = "ui/widgets/qljht1"

function wnd_qilingSkillUpdate:ctor()
	self.level = 1
end

function wnd_qilingSkillUpdate:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
end

function wnd_qilingSkillUpdate:refresh(id)
	self.id = id
	self:updateSkill()
end

function wnd_qilingSkillUpdate:updateSkill()
	local canUp = true
	local widgets = self._layout.vars
	widgets.scroll3:removeAllChildren()
	local data = g_i3k_game_context:getQilingData()
	local rank = data[self.id].rank
	self.level = data[self.id].skillLevel
	widgets.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(4581))
	widgets.now_effect:setText(i3k_get_string(15355))
	widgets.now_label:setText(i3k_get_string(1096))
	widgets.level_value:setText(self.level)
	widgets.desc1:setText(i3k_db_qiling_skill[self.id][self.level].desc)
	widgets.up_btn:hide()
	widgets.up_state:hide()
	widgets.auto_up:hide()
	if self.level < #i3k_db_qiling_skill[self.id] then
		widgets.next_label:setText(i3k_get_string(1096))
		widgets.next_level:setText(self.level + 1)
		widgets.next_effect:setText(i3k_get_string(1097))
		local text = i3k_db_qiling_skill[self.id][self.level + 1].desc
		local needRank = g_i3k_game_context:getUpNeedRank(self.id, self.level)
		if rank >= needRank then
			widgets.desc2:setText(text..i3k_get_string(1078))
		else
			widgets.desc2:setText(text..i3k_get_string(1076, i3k_db_qiling_type[self.id].name, needRank))
		end
		local item = i3k_db_qiling_skill[self.id][self.level + 1].consume
		if next(item) then
			for k, v in ipairs(item) do
				local _layer = require(WIDGETITEM)()
				widgets.scroll3:addItem(_layer)
				_layer.vars.bt:onClick(self, self.onConsumeItem, v.id)
				_layer.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
				_layer.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
				_layer.vars.suo:setVisible(v.id > 0)
				local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
				local text = math.abs(v.id) == g_BASE_ITEM_COIN and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
				_layer.vars.item_count:setText(text)
				_layer.vars.item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= v.count))
				if canUseCount < v.count then
					canUp = false
				end
			end
		end
	else
		widgets.next_label:setText("")
		widgets.next_level:setText("")
	end
	widgets.upSkill:show()
	widgets.upSkill:onClick(self, self.upSkill, canUp)
end

function wnd_qilingSkillUpdate:onConsumeItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_qilingSkillUpdate:upSkill(sender, canUp)
	local data = g_i3k_game_context:getQilingData()
	local rank = data[self.id].rank
	if self.level >= #i3k_db_qiling_skill[self.id] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1098))
	elseif i3k_db_qiling_trans[self.id][rank].skillUpLevel <= self.level then
		local needRank = g_i3k_game_context:getUpNeedRank(self.id, self.level)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1077, i3k_db_qiling_type[self.id].name, needRank))
	elseif canUp then
		i3k_sbean.qilingSkillLevelUp(self.id, self.level + 1)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function wnd_qilingSkillUpdate:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_QilingSkillUpdate)
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingSkillUpdate.new();
		wnd:create(layout, ...);
	return wnd;
end
