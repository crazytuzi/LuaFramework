OffLineExpView = OffLineExpView or BaseClass(BaseView)

function OffLineExpView:__init()
	self.ui_config = {"uis/views/welfare_prefab","OffLineExpView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function OffLineExpView:LoadCallBack()
	self.select_index = 1				--默认选择第一个档次

	self.off_time = self:FindVariable("OffTime")
	self.level = self:FindVariable("Level")
	self.role_exp = self:FindVariable("RoleExp")
	self.mojing = self:FindVariable("MoJing")
	self.gold_text_list = {}
	self.gold_icon = {}
	for i = 1, 3 do
		-- local select_text = self:FindVariable("SelectText" .. i)
		local gold_text = self:FindVariable("Gold" .. i)
		table.insert(self.gold_text_list, gold_text)

		

		local tab = self:FindObj("Tab" .. i)
		tab.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectChange, self, i))
		self.gold_icon[i] = self:FindObj("GoldIcon" .. i)
	end

	self:ListenEvent("ClickGet", BindTool.Bind(self.ClickGet, self))
	self:ListenEvent("ClickAfter", BindTool.Bind(self.ClickAfter, self))
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function OffLineExpView:ReleaseCallBack()
	self.off_time = nil
	self.level = nil
	self.role_exp = nil
	self.gold_text_list = nil
	self.gold_icon = nil
	self.mojing = nil
end

function OffLineExpView:OnSelectChange(index, isOn)
	if isOn then
		self.select_index = index

		local off_line_exp = WelfareData.Instance:GetOffLineExp()
		local off_line_mojing = WelfareData.Instance:GetOffLineMojing()
		off_line_exp = off_line_exp * index
		off_line_mojing = off_line_mojing * index
		self.role_exp:SetValue(CommonDataManager.ConverMoney(off_line_exp))
		self.mojing:SetValue(off_line_mojing)
	end
end

function OffLineExpView:CloseCallBack()

end

function OffLineExpView:OpenCallBack()
	self:Flush()
end

function OffLineExpView:ClickGet()
	local off_line_cfg = WelfareData.Instance:GetOffLineExpCfg()
	local select_cfg = off_line_cfg[self.select_index]

	local hour, min, sec  = WelfareData.Instance:GetOffLineTime()
	--计算倍数
	local multiple = 1
	if hour > 0 then
		if min > 0 or sec > 0 then
			multiple = hour + 1
		else
			multiple = hour
		end
	end

	local cost_gold = select_cfg.diamond * multiple
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local diff_value = main_vo.bind_gold - cost_gold
	if diff_value < 0 then
		if PlayerData.GetIsEnoughAllGold(cost_gold) then
			local find_type = select_cfg.type
			WelfareCtrl.Instance:SendGetOffLineExp(find_type)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	else
		local find_type = select_cfg.type
		WelfareCtrl.Instance:SendGetOffLineExp(find_type)
	end
	self:Close()
end

function OffLineExpView:ClickAfter()
	self:Close()
end

function OffLineExpView:CloseWindow()
	self:Close()
end

function OffLineExpView:OnFlush()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local off_line_exp = WelfareData.Instance:GetOffLineExp()
	local off_line_mojing = WelfareData.Instance:GetOffLineMojing()
	off_line_exp = off_line_exp * self.select_index
	off_line_mojing = off_line_mojing * self.select_index
	local level_des = PlayerData.GetLevelString(main_vo.level)
	self.level:SetValue(level_des)

	self.role_exp:SetValue(CommonDataManager.ConverMoney(off_line_exp))
	self.mojing:SetValue(off_line_mojing)
	local hour, min, sec  = WelfareData.Instance:GetOffLineTime()
	local off_time_des = ""
	if hour > 0 then
		off_time_des = off_time_des .. string.format(Language.OpenServer.TimeHour, hour)
	end
	if min > 0 then
		off_time_des = off_time_des .. string.format(Language.OpenServer.TimeMin, min)
	end
	if sec > 0 then
		off_time_des = off_time_des .. string.format(Language.Role.XXMiao, sec)
	end
	self.off_time:SetValue(off_time_des)

	--计算倍数
	local multiple = 1
	if hour > 0 then
		if min > 0 or sec > 0 then
			multiple = hour + 1
		else
			multiple = hour
		end
	end

	local off_line_cfg = WelfareData.Instance:GetOffLineExpCfg()
	for k, v in ipairs(self.gold_text_list) do
		local cost = off_line_cfg[k].diamond * multiple
		local cost_des = ""
		v:SetValue(cost > 0 and tostring(cost) or "")
		self.gold_icon[k]:SetActive(cost > 0)
	end
end