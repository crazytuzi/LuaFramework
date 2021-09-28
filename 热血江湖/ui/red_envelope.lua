-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_red_envelope = i3k_class("wnd_red_envelope", ui.wnd_base)

local REDENVELOPE = "ui/widgets/bpqhbt"
local NUMBER = 5 -- 每行添加多少个控件

function wnd_red_envelope:ctor()
	self.redEnvelope = {}
	self.empty = 0
end

function wnd_red_envelope:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onClose)
	widgets.toSendBtn:onClick(self, self.toSend)
	widgets.refresh_btn:onClick(self, self.clearOpened)
	self.scroll = widgets.scroll
end

function wnd_red_envelope:refresh(redEnvelopeList)
	self.redEnvelope = {}
	self:sortEnvelope(redEnvelopeList)
	self:updataList()
end

function wnd_red_envelope:sortEnvelope(redEnvelopeList)
	for k, v in pairs(redEnvelopeList) do
		local sortid = 0
		if v.packRoleStatus == 0 then
			if v.leftDiamond > 0 then
				sortid = 4
			else
				sortid = 3
			end
		elseif v.packRoleStatus == 1 then
			sortid = 2
		elseif v.packRoleStatus == 2 then
			sortid = 1
		end
		table.insert(self.redEnvelope, {packRoleStatus = v.packRoleStatus, id = v.id, name = v.sendRoleName, maxDiamond = v.maxDiamond, msg = v.sendRoleMsg, takeNum = v.takeNum, sortid = sortid})
		
	end
	table.sort(self.redEnvelope, function(a, b)
		return a.sortid > b.sortid
	end)
	--最后补全空的控件用来接收点击事件
	self.empty = 0
	if #self.redEnvelope <= NUMBER * 2 then
		self.empty = NUMBER * 2 - #self.redEnvelope
	else
		local x, r = math.modf(#self.redEnvelope/NUMBER)
		x = r > 0 and x + 1 or x
		self.empty = x * NUMBER - #self.redEnvelope
	end
	for k = 1, self.empty do
		table.insert(self.redEnvelope, {packRoleStatus = 3})
	end
end

function wnd_red_envelope:updataList()
	self.scroll:removeAllChildren()
	local children = self.scroll:addItemAndChild(REDENVELOPE, NUMBER, table.nums(self.redEnvelope))
	for k, v in pairs(self.redEnvelope) do
		local _widget = children[k]
		self:isShowRoot(_widget, v.packRoleStatus)
		if v.packRoleStatus == 0 then
			_widget.vars.name1:setText(v.name)
			_widget.vars.message:setText(v.msg)
			_widget.vars.diamond1:setText(v.maxDiamond)
			_widget.vars.qiang:onClick(self, self.onRewardBtn, {id = v.id, index = k})
		elseif v.packRoleStatus == 1 then
			_widget.vars.name2:setText(v.name)
			_widget.vars.diamond2:setText(v.takeNum)
			_widget.vars.detailBtn1:onClick(self, self.onDetail, v.id)
		elseif v.packRoleStatus == 2 then
			_widget.vars.detailBtn2:onClick(self, self.onDetail, v.id)
		else
			_widget.vars.emptyBtn:onClick(self, self.onClose)
		end
	end
end

function wnd_red_envelope:isShowRoot(_widget, status)
	_widget.vars.qiangRoot:setVisible(status == 0)
	_widget.vars.getRoot:setVisible(status == 1)
	_widget.vars.notGetRoot:setVisible(status == 2)
end

function wnd_red_envelope:onRewardBtn(sender, envelope)
	local scheduleInfo = g_i3k_game_context:GetScheduleInfo()
	if i3k_db_common.factionRedEnvelope.rewardTimes - g_i3k_game_context:getRedEnvelopeReward() <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16708))
	elseif scheduleInfo.activity < i3k_db_common.factionRedEnvelope.rewardActivity then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16705, i3k_db_common.factionRedEnvelope.rewardActivity))
	elseif g_i3k_game_context:GetLevel() < i3k_db_common.factionRedEnvelope.rewardLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16704, i3k_db_common.factionRedEnvelope.rewardLvl))
	elseif i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_common.factionRedEnvelope.rewardJoinLimit * 3600 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16702, i3k_db_common.factionRedEnvelope.rewardJoinLimit))
	else
		i3k_sbean.sect_red_pack_take(envelope.id, envelope.index)
	end
end

function wnd_red_envelope:replaceWidget(index, diamond)
	self.redEnvelope[index].packRoleStatus = diamond > 0 and 1 or 2
	self.redEnvelope[index].takeNum = diamond
	self:updataList()
end

function wnd_red_envelope:clearOpened(sender)
	i3k_sbean.sect_red_pack_sync()
end

function wnd_red_envelope:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelope)
end

function wnd_red_envelope:toSend(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RedEnvelopeSend)
	g_i3k_ui_mgr:RefreshUI(eUIID_RedEnvelopeSend)
	g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelope)
end

function wnd_red_envelope:onDetail(sender, packId)
	i3k_sbean.sect_red_pack_history(packId)
end

function wnd_red_envelope:deleteOverdue(id)
	local index = 1
	for k, v in pairs(self.redEnvelope) do
		if id == v.id then
			break
		else
			index = index + 1
		end
	end
	table.remove(self.redEnvelope, index)
	table.insert(self.redEnvelope, {packRoleStatus = 3})
	self.empty = self.empty + 1
	self:updataList()
end

function wnd_create(layout, ...)
	local wnd = wnd_red_envelope.new();
		wnd:create(layout, ...);
	return wnd;
end
