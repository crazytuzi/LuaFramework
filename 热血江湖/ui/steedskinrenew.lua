-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_steed_skin_renew = i3k_class("wnd_steed_skin_renew",ui.wnd_base)

function wnd_steed_skin_renew:ctor()
	self._effectiveTime = 0
	self._cfg = 0
end

function wnd_steed_skin_renew:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)

	self.skin_icon = widgets.skin_icon
	self.skin_bg = widgets.skin_bg
	self.skin_name = widgets.skin_name
	self.left_time = widgets.left_time
	self.item_desc = widgets.item_desc
	self.consumeBg = widgets.consumeBg
	self.consumeIcon = widgets.consumeIcon
	self.consumeCount = widgets.consumeCount
	self.consumeBtn = widgets.consumeBtn
	self.use_label = widgets.use_label
	widgets.use_btn:onClick(self, self.onUseBtn)
end

function wnd_steed_skin_renew:refresh(cfg)
	self._cfg = cfg
	self:setData(cfg)
end

function wnd_steed_skin_renew:setData(cfg)
	cfg = cfg or self._cfg
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	local itemName = g_i3k_db.i3k_db_get_common_item_name(cfg.actNeedId)
	self._effectiveTime = steedShowIDs[cfg.id]
	self.skin_name:setText(cfg.name)
	self.skin_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.steedRankIconId))
	self.item_desc:setText(i3k_get_string(15535, itemName, math.modf(cfg.effectiveTime / 3600 /24)))
	self.consumeBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.actNeedId))
	self.consumeIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.actNeedId, g_i3k_game_context:IsFemaleRole()))
	local desc = string.format("%s/%s", g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId), cfg.needCount)
	self.consumeCount:setText(desc)
	self.consumeCount:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId) >= cfg.needCount))
	self.consumeBtn:onClick(self, self.onItmeTips, cfg.actNeedId)
end

function wnd_steed_skin_renew:onUseBtn(sender)
	if g_i3k_game_context:GetCommonItemCanUseCount(self._cfg.actNeedId) >= self._cfg.needCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15533))
		i3k_sbean.act_steed_skin(0, self._cfg.id) --激活追加皮肤hid传参0
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15532))
	end
end

function wnd_steed_skin_renew:getTimeStr(timeNum)
	local leftDay = math.modf(timeNum/(3600*24))
	local leftHour = math.modf((timeNum-3600*24*leftDay)/3600)
	local leftMin = math.modf((timeNum-3600*24*leftDay-3600*leftHour)/60)
	return string.format("时效：%s天%s小时%s分", leftDay, leftHour, leftMin)
end

function wnd_steed_skin_renew:onUpdate(dTime)
	if self._effectiveTime then
		self.left_time:show()
		if self._effectiveTime - i3k_game_get_time() > 0 then
			self.left_time:setText(self:getTimeStr(self._effectiveTime - i3k_game_get_time()))
		else
			self.left_time:setText("时效：未拥有")
		end
	else
		self.left_time:hide()
	end
end

function wnd_steed_skin_renew:onItmeTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_steed_skin_renew.new()
	wnd:create(layout)
	return wnd
end
