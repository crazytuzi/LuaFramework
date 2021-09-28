-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_red_envelope_send = i3k_class("wnd_red_envelop_send", ui.wnd_base)

function wnd_red_envelope_send:ctor()
	self.diamond = 0
	self.number = 0
	self.leftDiamond = 0
end

function wnd_red_envelope_send:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onClose)
	widgets.helpBtn:onClick(self, self.onHelp)
	self.desc = widgets.desc
	self.leftTimes = widgets.leftTimes
	self.send = widgets.send
	self.desc:setMaxLength(i3k_db_common.factionRedEnvelope.maxText)
	self.desc:addEventListener(function(eventType)
		if eventType == "ended" then
			if self.desc:getText() == "" then
				self.desc:setText(i3k_get_string(17533))
			end
		end
	end)
end

function wnd_red_envelope_send:refresh()
	self.leftDiamond = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].redEnvelopeDiamond - g_i3k_game_context:getRedEnvelopeSend()
	self.leftTimes:hide()
	self.send:onClick(self, self.onSend)
	self.desc:setText(i3k_get_string(17533))
	self:setData()
end

function wnd_red_envelope_send:setData()
	local widgets = self._layout.vars
	for k = 1, 3 do
		widgets["diamondLabel"..k]:setText(i3k_db_common.factionRedEnvelope.diamondNum[k])
		widgets["diamondBtn"..k]:onClick(self, self.onDiamond, k)
		widgets["packetLabel"..k]:setText(i3k_db_common.factionRedEnvelope.packetNum[k])
		widgets["packetBtn"..k]:onClick(self, self.onPacket, k)
	end
end

function wnd_red_envelope_send:onDiamond(sender, index)
	self.diamond = i3k_db_common.factionRedEnvelope.diamondNum[index]
	self:updataDiamond(index)
end

function wnd_red_envelope_send:updataDiamond(index)
	local widgets = self._layout.vars
	for k = 1, 3 do
		if k == index then
			widgets["diamondBtn"..k]:stateToPressed(true)
		else
			widgets["diamondBtn"..k]:stateToNormal(true)
		end
	end
end

function wnd_red_envelope_send:onPacket(sender, index)
	self.number = i3k_db_common.factionRedEnvelope.packetNum[index]
	self:updataPacket(index)
end

function wnd_red_envelope_send:updataPacket(index)
	local widgets = self._layout.vars
	for k = 1, 3 do
		if k == index then
			widgets["packetBtn"..k]:stateToPressed(true)
		else
			widgets["packetBtn"..k]:stateToNormal(true)
		end
	end
end

function wnd_red_envelope_send:onSend(sender)
	local limitVip = 1
	for k, v in ipairs(i3k_db_kungfu_vip) do
		if v.redEnvelopeDiamond > 0 then
			limitVip = k
			break
		end
	end
	if g_i3k_game_context:getSectFactionLevel() < i3k_db_common.factionRedEnvelope.factionLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16700, i3k_db_common.factionRedEnvelope.factionLvl))
	elseif i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_common.factionRedEnvelope.joinTimeLimit * 3600 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16701, i3k_db_common.factionRedEnvelope.joinTimeLimit))
	elseif g_i3k_game_context:GetVipLevel() < limitVip then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16703, limitVip))
	elseif g_i3k_game_context:GetDiamondCanUse(true) < self.diamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15072))
	elseif g_i3k_game_context:GetFactionCurrentMemberCount() < i3k_db_common.factionRedEnvelope.packetNum[1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16718, i3k_db_common.factionRedEnvelope.packetNum[1]))
	elseif self.leftDiamond < self.diamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16707))
	elseif self.diamond == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16723))
	elseif self.number == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16722))
	elseif g_i3k_game_context:GetLevel() < i3k_db_common.factionRedEnvelope.sendLvlLimit then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16706, i3k_db_common.factionRedEnvelope.sendLvlLimit))
	else
		i3k_sbean.sect_red_pack_send({diamond = self.diamond, num = self.number, msg = self.desc:getText()})
	end
end

function wnd_red_envelope_send:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelopeSend)
end

function wnd_red_envelope_send:onHelp(sender)
	local info = i3k_db_common.factionRedEnvelope
	local vipLvl = g_i3k_game_context:GetVipLevel()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16721, info.rate/10000,i3k_db_kungfu_vip[vipLvl].redEnvelopeDiamond, info.rewardActivity, info.rewardTimes))--参数
end

function wnd_create(layout, ...)
	local wnd = wnd_red_envelope_send.new();
		wnd:create(layout, ...);
	return wnd;
end
