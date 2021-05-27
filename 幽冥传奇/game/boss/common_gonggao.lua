GongGaoView = GongGaoView or BaseClass(XuiBaseView)

function GongGaoView:__init()
	self.zorder = 100
	self.config_tab = {
		{"common_gonggao_ui_cfg", 1, {0}},
	}
	self:SetModal(false)
	self.can_penetrate = true
end

function GongGaoView:__delete()
end

function GongGaoView:ReleaseCallBack()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	if self.time_limited_consume_event then
		GlobalEventSystem:UnBind(self.time_limited_consume_event)
		self.time_limited_consume_event = nil
	end
end

function GongGaoView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.time_limited_consume_event = GlobalEventSystem:Bind(OtherEventType.TIME_CHANGE_COMMON_GONGGAO, BindTool.Bind(self.UpdateTime, self))
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
	end
end


function GongGaoView:CloseCallBack()
	
end

function GongGaoView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GongGaoView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			local type_gg = BossData.Instance:GetGongGaotype()
			if type_gg ~= 3 then
				local content = BossData.Instance:GetContentData()
				RichTextUtil.ParseRichText(self.node_t_list.txt_content_desc.node, content, 22)
				XUI.RichTextSetCenter(self.node_t_list.txt_content_desc.node)
				if self.timer ~= nil then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
			else
				-- self.remain_time = BossData.Instance:GetRemianTime()
				self:FlushTime(0)
			end
		elseif k == "recycle" then
			if v.exp ~= nil and v.shield ~= nil and v.yuanbao ~= nil then
				local txt_1 = ""
				local txt_2 = ""
				if v.yuanbao ~= 0 then
					txt_2 = string.format(Language.Bag.RewardData_2, v.yuanbao)
				end
				if v.shield ~= 0 then
					txt_1 = string.format(Language.Bag.RewardData_1, v.shield, txt_2)
				end
				local pri_data = PrivilegeData.Instance:GetCurPrivilege()
				local count = PrivilegeData:GetPrivilegeAddCntByType(pri_data, PrivilegeData.AddCntTypeT.ExpAddPercent)
				local exp = v.exp*(1 + count/100)
				local txt = string.format(Language.Bag.RewardData, exp, txt_1)
				RichTextUtil.ParseRichText(self.node_t_list.txt_content_desc.node, txt, 22)
				XUI.RichTextSetCenter(self.node_t_list.txt_content_desc.node)
			end
			if self.timer ~= nil then
				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
			end
			break
		end
	end
	
end

function GongGaoView:UpdateTime()
	self:FlushTime(0)
end

function GongGaoView:FlushTime(num)
	BossData.Instance:SetTime(num or -1)
	local time = BossData.Instance:GetRemianTime() 
	if time and time < 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self:Close()
	end
 	local content = BossData.Instance:GetContentData()
	local time_dao = TimeUtil.FormatSecond2Str(time)
	local txt = string.format(content, time_dao)
	if self.node_t_list.txt_content_desc == nil then return end
 	RichTextUtil.ParseRichText(self.node_t_list.txt_content_desc.node, txt, 22)
 	XUI.RichTextSetCenter(self.node_t_list.txt_content_desc.node)
end