
RedPacketTip = RedPacketTip or BaseClass(BaseView)

function RedPacketTip:__init()
	if RedPacketTip.Instance then
		ErrorLog("[RedPacketTip] Attemp to create a singleton twice !")
	end
	RedPacketTip.Instance = self
	
	self.config_tab = {
		{"itemtip_ui_cfg", 22, {0}},
	}

	self:SetIsAnyClickClose(false)
	self:SetModal(true)
end

function RedPacketTip:__delete()
	RedPacketTip.Instance = nil
end

function RedPacketTip:ReleaseCallBack()
	if self.packet_record_list then
		self.packet_record_list:DeleteMe()
		self.packet_record_list = nil
	end
end

function RedPacketTip:ShowIndexCallBack()
	self:Flush()
end

function RedPacketTip:CloseCallBack()
	self:DeleteCutDownTimer()
end

function RedPacketTip:LoadCallBack()
	self:CreatePacketRecord()
	XUI.AddClickEventListener(self.node_t_list.img_packet_head.node, BindTool.Bind(self.OnClickSenderInfo, self), false)
	XUI.RichTextSetCenter(self.node_t_list.rich_next_send_time.node)	
end

function RedPacketTip:CreatePacketRecord()
	if nil == self.packet_record_list then
		local ph = self.ph_list.ph_item_list
		self.packet_record_list = ListView.New()
		self.packet_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RedPacketRecordRender, nil, nil, nil)
		self.packet_record_list:GetView():setAnchorPoint(0.5, 0.5)
		self.packet_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_red_package.node:addChild(self.packet_record_list:GetView(), 100)
	end		
end

function RedPacketTip:SetData(data)
	self.role_info = data
	self.record = data.packet_record
end

function RedPacketTip:OnFlush()
	self.node_t_list.lbl_packet_gold.node:setString(self.role_info.rob_gold)
	self.node_t_list.img_packet_head.node:loadTexture(ResPath.GetRoleHead("big_" .. self.role_info.role_prof .. "_" .. self.role_info.role_sex))
	local record_list = self:GetRedPacketRecord()
	self.packet_record_list:SetDataList(record_list)
	self.node_t_list.lbl_name_first.node:setString(self.role_info.role_name)

	self:FlushCutDownTimer()
end

function RedPacketTip:GetCutDownTime()	
	return ActivityBrilliantData.Instance.cooling_endtime - TimeCtrl.Instance:GetServerTime()
end

function RedPacketTip:CutDownTimerFunc()		
	local time = self:GetCutDownTime()
	-- self.node_t_list.rich_next_send_time.node:setVisible(time > 0)
	if time <= 0 then
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_send_time.node, "可再抢红包", 20, COLOR3B.GREEN)
		self:DeleteCutDownTimer()
	else
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_send_time.node, TimeUtil.FormatSecond(time) .. "秒后可再抢", 20, COLOR3B.RED)
	end
end

function RedPacketTip:FlushCutDownTimer()
	if nil == self.cutdown_timer and self:GetCutDownTime() > 0 then
		self.cutdown_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:CutDownTimerFunc()
		end, 1)
	end
	self:CutDownTimerFunc()
end

function RedPacketTip:DeleteCutDownTimer()
	if self.cutdown_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.cutdown_timer)
		self.cutdown_timer = nil
	end
end

function RedPacketTip:GetRedPacketRecord()
	if nil == self.record and "" == self.record then 
		return {}
	end
	local list = {}
	local tag_t = Split(self.record, ";")
	if nil == tag_t then return end
	for i= #tag_t, 1, -1 do
		local str =  Split(tag_t[i], "#")
		local vo = {}
		vo.name = str[1]
		vo.gold = str[2]
		vo.flag = tonumber(str[3])
		table.insert(list, vo)
		if 20 < #list then
			break
		end
	end
	return list
end


function RedPacketTip:OnClickSenderInfo()
	local menu_list = {
			{menu_index = 0},
			{menu_index = 3},
			{menu_index = 4},
			{menu_index = 5},
			{menu_index = 6},
	}
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername ~= self.role_info.role_name then
		UiInstanceMgr.Instance:OpenCustomMenu(menu_list, self.role_info)
	end
end