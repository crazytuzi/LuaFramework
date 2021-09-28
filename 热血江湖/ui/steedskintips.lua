-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_steed_skin_tips = i3k_class("wnd_steed_skin_tips",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local USE_STATE = 1
local ACTIVATE_STATE = 2
local BUY_STATE	= 3

function wnd_steed_skin_tips:ctor()
	self._cfg = {}
	self._state = 0  -- 1 使用 2 激活 3 购买
	self._effectiveTime = 0
end

function wnd_steed_skin_tips:configure()
	local widgets = self._layout.vars
	widgets.globel_btn:onClick(self, self.onCloseUI)
	
	self.skin_icon = widgets.skin_icon
	self.skin_name = widgets.skin_name
	self.is_mul_label = widgets.is_mul_label
	self.power_value = widgets.power_value
	self.effective_time = widgets.effective_time
	self.scroll = widgets.scroll
	self.get_label = widgets.get_label
	self.renew_label = widgets.renew_label
	self.use_label = widgets.use_label
	self.use_btn = widgets.use_btn
	self.renew_btn = widgets.renew_btn
	self.fight_btn = widgets.fight_btn
	self.fight_label = widgets.fight_label
	widgets.renew_btn:onClick(self, self.onRenewBtn)
end

function wnd_steed_skin_tips:refresh(cfg)
	self._cfg = cfg
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	local fightData = g_i3k_game_context:getSteedFightShowIDs()
	self._effectiveTime = steedShowIDs[cfg.id]
	self.use_label:setText(self:getUseLabelDesc(cfg))
	self.use_btn:setVisible(cfg.id ~= g_i3k_game_context:getSteedCurShowID() and self._state ~= 0)
	if cfg.skinType == g_HS_ADDITIONAL and self._state == BUY_STATE then
		local tmp = g_i3k_db.i3k_db_get_isShow_btn(cfg.actNeedId)
		if not(tmp and tmp.showBuyBtn == 1 and g_i3k_game_context:GetLevel() >= tmp.showLevel) then
			self.use_btn:setVisible(false)
		end
	end
	self.renew_btn:setVisible(cfg.skinType ~= g_HS_TRADITIONAL and steedShowIDs[cfg.id] and steedShowIDs[cfg.id] > i3k_game_get_time())
	self.fight_label:setText(fightData[cfg.id] and "可骑战" or "启动骑战")
	local isShow = g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl and cfg.fightSkinType == g_HS_SKIN_FIGHT and steedShowIDs[cfg.id] ~= nil
	local isHave = steedShowIDs[cfg.id] and (steedShowIDs[cfg.id] > i3k_game_get_time() or steedShowIDs[cfg.id] < 0) or false
	self.fight_btn:setVisible(isShow and not fightData[cfg.id] and isHave)
	self.fight_btn:onClick(self, self.onFightBtn, {cfg = cfg, isActivateFight = fightData[cfg.id]})
	self.use_btn:onClick(self, self.onUseBtn, fightData[cfg.id])
	self.skin_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.steedRankIconId))
	self.skin_name:setText(cfg.name)
	self.is_mul_label:setText(cfg.rideNum > 1 and i3k_get_string(15537) or i3k_get_string(15536))
	self.get_label:setText(cfg.getMethod)
	self.power_value:setText(g_i3k_game_context:getSteedSkinPower(cfg))
	self:loadScroll(cfg)
end

function wnd_steed_skin_tips:getUseLabelDesc(cfg)
	local str = ""
	local steedShowIDs = g_i3k_game_context:getSteedShowIDs()
	if steedShowIDs[cfg.id] and (steedShowIDs[cfg.id] == -1 or steedShowIDs[cfg.id] > i3k_game_get_time()) then
		str = "使用"
		self._state = USE_STATE
	elseif g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId) >= cfg.needCount then
		str = "启动"
		self._state = ACTIVATE_STATE
	elseif (not steedShowIDs[cfg.id] or steedShowIDs[cfg.id] < i3k_game_get_time()) and g_i3k_game_context:GetCommonItemCanUseCount(cfg.actNeedId) < cfg.needCount then
		str = "购买"
		self._state = BUY_STATE
	end
	return str
end

function wnd_steed_skin_tips:getTimeStr(timeNum)
	local leftDay = math.modf(timeNum/(3600*24))
	local leftHour = math.modf((timeNum-3600*24*leftDay)/3600)
	local leftMin = math.modf((timeNum-3600*24*leftDay-3600*leftHour)/60)
	return string.format("时效：%s天%s小时%s分", leftDay, leftHour, leftMin)
end

function wnd_steed_skin_tips:onUpdate(dTime)
	if self._effectiveTime then
		if self._effectiveTime == -1 then
			self.effective_time:setText("时效：永久")
		else
			if self._effectiveTime - i3k_game_get_time() > 0 then
				self.effective_time:setText(self:getTimeStr(self._effectiveTime - i3k_game_get_time()))
			else
				self.effective_time:setText("时效：未拥有")
			end
		end
	else
		self.effective_time:setText("时效：未拥有")
	end
end

function wnd_steed_skin_tips:loadScroll(cfg)
	self.scroll:removeAllChildren()	
	if table.nums(g_i3k_game_context:getSteedSkinProperty(cfg.attrTb)) > 0 then
		local des = require(LAYER_ZBTIPST3)()
		des.vars.desc:setText(string.format("基础属性"))
		self.scroll:addItem(des)
		for i, e in ipairs(cfg.attrTb) do
			if e.id ~= 0 then
				local des = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[e.id]
				local _desc = _t.desc
				_desc = _desc.." :"
				des.vars.desc:setText(_desc)
				des.vars.value:setText(i3k_get_prop_show(e.id, e.count))
				self.scroll:addItem(des)
			end
		end
	end
end

function wnd_steed_skin_tips:onRenewBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedSkinRenew)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkinRenew, self._cfg)
	self:onCloseUI()
end

function wnd_steed_skin_tips:onUseBtn(sender, isActivateFight)
	if self._state == USE_STATE then
		local showID = self._cfg.id
		local func = function()
			local hero = i3k_game_get_player_hero()
			if hero:IsOnRide() then
				local callback = function ()
					i3k_sbean.change_steed_show(showID, nil, 1)
				end
				hero:SetRide(false, nil, callback)--正在骑乘，先下马然后换皮,再上马
			else
				i3k_sbean.change_steed_show(showID, nil, 0)
			end
		end
		local isNeedLvl = g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl
		if self._cfg.fightSkinType == g_HS_SKIN_FIGHT and not isActivateFight and isNeedLvl then
			local fun = (function(ok)
				if ok then
					func()
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("使用", "取消", i3k_get_string(1262), fun)
		else
			func()
		end
	elseif self._state == ACTIVATE_STATE then
		i3k_sbean.act_steed_skin(0, self._cfg.id) --激活追加皮肤hid传参0
	elseif self._state == BUY_STATE then
		local tmp = g_i3k_db.i3k_db_get_isShow_btn(self._cfg.actNeedId)
		if tmp and tmp.showBuyBtn == 1 and g_i3k_game_context:GetLevel() >= tmp.showLevel then
			g_i3k_logic:OpenVipStoreUI(tmp.showType, tmp.isBound, tmp.id)
		else
			g_i3k_logic:OpenVipStoreUI(3)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinTips)
	end
end

function wnd_steed_skin_tips:onFightBtn(sender, data)
	if not data.isActivateFight then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedFightUnlock)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedFightUnlock, data.cfg.id)
	end
end

function wnd_create(layout)
	local wnd = wnd_steed_skin_tips.new()
	wnd:create(layout)
	return wnd
end
