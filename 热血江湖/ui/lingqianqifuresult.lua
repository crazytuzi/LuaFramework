------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_ling_qian_result = i3k_class("wnd_ling_qian_result",ui.wnd_base)

local ITEM = "ui/widgets/qifu3jgt"
local ITEM2 = "ui/widgets/qifu3jgt2"
local AUTO_CLOSE_TIME = 2
function wnd_ling_qian_result:configure()
	self._timer = 0
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.OnCloseUI)
	widgets.okBtn:onClick(self, self.onCloseUI)
end

function wnd_ling_qian_result:onUpdate(dTime)
	if self._timer < 0 then
		self._layout.vars.buffTip:hide()
		self._timer = 0
	elseif self._timer > 0 then
		self._timer = self._timer - dTime
	end
end

function wnd_ling_qian_result:refresh(dropID)
	local widgets = self._layout.vars
	local cfg = i3k_db_ling_qian_award[dropID]
	local level = g_i3k_game_context:GetLevel()
	widgets.expCount:setText(cfg.expRate * i3k_db_exp[level].lingqianExp)
	widgets.des:setText(cfg.desc)
	widgets.scroll:removeAllChildren()
	widgets.title_scroll:setBounceEnabled(false)
	widgets.title_scroll:removeAllChildren()
	for i, v in ipairs(cfg.iconID) do
		local UI = require(ITEM2)()
		UI.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v))
		widgets.title_scroll:addItem(UI)
	end
	local buffID = cfg.buffID
	local buffCfg = i3k_db_buff[buffID]
	widgets.buffIcon:setImage(g_i3k_db.i3k_db_get_icon_path(buffCfg.buffDrugIcon))
	widgets.buffName:setText(buffCfg.note)
	widgets.buffName2:setText(buffCfg.note)
	widgets.buffBtn:onClick(self, function(sender)
			self._timer = AUTO_CLOSE_TIME
			widgets.buffTip:setVisible(not widgets.buffTip:isVisible())
		end)
	for i, v in ipairs(cfg.award) do
		if v.id ~= g_BASE_ITEM_COIN then
			local UI = require(ITEM)()
			UI.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
			UI.vars.img:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			UI.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			UI.vars.count:setText("x"..v.count)
			UI.vars.btn:onClick(self, function()
					g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
				end)
			widgets.scroll:addItem(UI)
		else
			widgets.coinCount:setText(v.count)
		end
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_ling_qian_result.new()
	wnd:create(layout,...)
	return wnd
end