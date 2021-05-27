-- 行会红包
local GuildRedEnvelopeView = GuildRedEnvelopeView or BaseClass(SubView)

function GuildRedEnvelopeView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 16, {0}},
	}
end

function GuildRedEnvelopeView:LoadCallBack()
	self.send_total_gold_num = GuildData.GetGuildCfg().global.MinRedPacketMoney
	self.send_num = GuildData.GetGuildCfg().global.MinRedPacketCount

	self.layout_miss_envelope = self.node_t_list.layout_miss_envelope.node
	self.btn_rob_red_envelope = self.node_t_list.btn_rob_red_envelope.node
	self.layout_miss_envelope:setVisible(false)
	self.btn_rob_red_envelope:setVisible(false)

	self:CreateEnvelopeRecordList()

	self.gold_num_keypad = NumKeypad.New()
	self.gold_num_keypad:SetOkCallBack(BindTool.Bind1(self.OnGoldNumCallBack, self))
	self.envelope_num_keypad = NumKeypad.New()
	self.envelope_num_keypad:SetOkCallBack(BindTool.Bind1(self.OnEnvelopeNumCallBack, self))

	self.node_t_list.layout_miss_envelope.img_miss_bg.node:setColor(COLOR3B.BROWN)

	XUI.AddClickEventListener(self.node_t_list.btn_send_red_envelope.node, BindTool.Bind1(self.OnClickSendRedEnvelope, self))
	XUI.AddClickEventListener(self.node_t_list.img9_send_num.node, BindTool.Bind1(self.OpenKeypadByGoldNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.img9_send_total_gold.node, BindTool.Bind1(self.OpenKeypadByNum, self), false)
	XUI.AddClickEventListener(self.btn_rob_red_envelope, BindTool.Bind1(self.OnClickRobRedEnvelope, self))
	XUI.AddClickEventListener(self.node_t_list.btn_red_envelope_tip.node, BindTool.Bind1(self.OnClickRedEnvelopeTips, self))

	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.RedEnvelopeChange, BindTool.Bind(self.OnFlushRobRedEnvelopeView, self))
end

function GuildRedEnvelopeView:ReleaseCallBack()
	if self.envelope_record_list then
		self.envelope_record_list:DeleteMe()
		self.envelope_record_list = nil
	end

	if self.gold_num_keypad then
		self.gold_num_keypad:DeleteMe()
		self.gold_num_keypad = nil
	end

	if self.envelope_num_keypad then
		self.envelope_num_keypad:DeleteMe()
		self.envelope_num_keypad = nil
	end

	self:DeleteRedEnvelopeTimer()
end

function GuildRedEnvelopeView:ShowIndexCallBack()
	self:OnFlushRobRedEnvelopeView()
end

function GuildRedEnvelopeView:OnFlushRobRedEnvelopeView()
	local info = GuildData.Instance:GetRedEnvelopeInfo()

	self.node_t_list.lbl_sender_name.node:setString(info.sender_name)
	local left_envelope_num = info.left_hb_num
	self.node_t_list.lbl_left_num.node:setString(left_envelope_num)
	self.node_t_list.lbl_left_num.node:setColor(left_envelope_num > 0 and COLOR3B.DEEP_ORANGE or COLOR3B.RED)
	self:FlushSentEnvelopeInfo()
	self:UpdateRedEnvelopeTime(0)
	self:FlushEnvelopeRecordList()
end

function GuildRedEnvelopeView:OnClickSendRedEnvelope()
	GuildCtrl.SentRedEnvelope(self.send_total_gold_num, self.send_num)
end

function GuildRedEnvelopeView:OnClickRobRedEnvelope()
	GuildCtrl.RobRedEnvelope()
end

function GuildRedEnvelopeView:OnClickRedEnvelopeTips()
	DescTip.Instance:SetContent(Language.Guild.EnvelopeTipsContent, Language.Guild.EnvelopeTipsTitle)
end

function GuildRedEnvelopeView:OpenKeypadByGoldNum()
	if nil ~= self.gold_num_keypad then
		self.gold_num_keypad:Open()
		self.gold_num_keypad:SetText(self.send_total_gold_num)
		local max_val = math.floor(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
		self.gold_num_keypad:SetMaxValue(max_val)
	end
end

function GuildRedEnvelopeView:OpenKeypadByNum()
	if nil ~= self.envelope_num_keypad then
		self.envelope_num_keypad:Open()
		self.envelope_num_keypad:SetText(self.send_num)
		local max_val = GuildData.GetGuildCfg().global.MaxRedPacketCount
		self.envelope_num_keypad:SetMaxValue(max_val)
	end
end

function GuildRedEnvelopeView:OnGoldNumCallBack(num)
	self.send_total_gold_num = num > 1 and num or GuildData.GetGuildCfg().global.MinRedPacketMoney
	self:FlushSentEnvelopeInfo()
end

function GuildRedEnvelopeView:OnEnvelopeNumCallBack(num)
	self.send_num = num > 1 and num or GuildData.GetGuildCfg().global.MinRedPacketCount
	self:FlushSentEnvelopeInfo()
end

function GuildRedEnvelopeView:FlushSentEnvelopeInfo()
	self.node_t_list.lbl_send_total_gold.node:setString(self.send_total_gold_num)
	self.node_t_list.lbl_send_num.node:setString(self.send_num)
end

function GuildRedEnvelopeView:CreateEnvelopeRecordList()
	if self.envelope_record_list ~= nil then return end

	local ph = self.ph_list.ph_red_envelope_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, nil, EnvelopeRecordListItem, nil, nil, self.ph_list.ph_red_envelope_list_item)
	self.node_t_list.layout_rob_red_envelope.node:addChild(list:GetView(), 100)
	list:SetItemsInterval(1)
	list:SetAutoSupply(true)
	list:SetMargin(1)
	list:SetJumpDirection(ListView.Top)

	self.envelope_record_list = list
end

function GuildRedEnvelopeView:FlushEnvelopeRecordList()
	local record_list = GuildData.Instance:GetGuildHbRecordList()
	-- table.sort(record_list, SortTools.KeyUpperSorter('time'))
	self.envelope_record_list:SetDataList(record_list)
end

function GuildRedEnvelopeView:UpdateRedEnvelopeTime(change_num)
	local hb_left_time = GuildData.Instance:GetRedEnvelopeLeftTime()
	local info = GuildData.Instance:GetRedEnvelopeInfo()
	local has_hb = 0 < info.left_hb_num and 0 < hb_left_time 

	local left_time = 0
	if true == has_hb then
		self:CreateRedEnvelopeTimer()
		left_time = hb_left_time
	else
		self.node_t_list.lbl_sender_name.node:setString("")
		self:DeleteRedEnvelopeTimer()
	end

	self.layout_miss_envelope:setVisible(not has_hb)
	self.btn_rob_red_envelope:setVisible(has_hb)
	self.node_t_list.lbl_end_time.node:setString(TimeUtil.FormatSecond(left_time, 3))
end

function GuildRedEnvelopeView:CreateRedEnvelopeTimer()
	if self.red_envelope_timer == nil then
		self.red_envelope_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.UpdateRedEnvelopeTime, self, -1), 1)
	end
end

function GuildRedEnvelopeView:DeleteRedEnvelopeTimer()
	if self.red_envelope_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.red_envelope_timer)
		self.red_envelope_timer = nil
	end
end


----------------------------------------------------
-- EnvelopeRecordListItem
----------------------------------------------------
EnvelopeRecordListItem = EnvelopeRecordListItem or BaseClass(BaseRender)

function EnvelopeRecordListItem:__init()
end

function EnvelopeRecordListItem:__delete()
end

function EnvelopeRecordListItem:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_text = self.node_tree.rich_text.node
end

function EnvelopeRecordListItem:OnFlush()
	-- self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if self.data == nil then
		RichTextUtil.ParseRichText(self.rich_text, "", 17, color)
		return
	end

	local content = ""
	local color = COLOR3B.LIGHT_BROWN
	if self.data.sent_hb_gold > 0 then
		content = string.format(Language.Guild.SentHbRecord, self.data.role_name, self.data.sent_hb_gold)
	else
		content = string.format(Language.Guild.RecHbRecord, self.data.role_name, self.data.rec_hb_gold)
	end
	RichTextUtil.ParseRichText(self.rich_text, content, 17, color)
end

function EnvelopeRecordListItem:CreateSelectEffect()
end

return GuildRedEnvelopeView