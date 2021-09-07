OffLineExpView = OffLineExpView or BaseClass(BaseView)

function OffLineExpView:__init()
	self.ui_config = {"uis/views/welfare","OffLineExpView"}
	self.play_audio = true
	self:SetMaskBg(true)
	-- self.view_layer = UiLayer.Pop
end

function OffLineExpView:LoadCallBack()
	self.select_index = 1				--默认选择第一个档次

	self.off_time = self:FindVariable("OffTime")
	self.level = self:FindVariable("Level")
	self.role_exp = self:FindVariable("RoleExp")

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
end

function OffLineExpView:OnSelectChange(index, isOn)
	if isOn then
		self.select_index = index

		local off_line_exp = WelfareData.Instance:GetOffLineExp()
		off_line_exp = off_line_exp * index
		self.role_exp:SetValue(CommonDataManager.ConverMoney(off_line_exp))
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
	local find_type = select_cfg.type
	if select_cfg.can_use_bind_gold ~= 0 then
		local diff_value = main_vo.bind_gold - cost_gold
		if diff_value < 0 then
			if PlayerData.GetIsEnoughAllGold(cost_gold) then
				local function ok_func()
					WelfareCtrl.Instance:SendGetOffLineExp(find_type)
					self:Close()
				end
				local des = string.format(Language.Common.ToUseGold, math.abs(diff_value))
				TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		else
			WelfareCtrl.Instance:SendGetOffLineExp(find_type)
			self:Close()
		end
	else
		local diff_value = main_vo.gold - cost_gold
		if diff_value < 0 then
			TipsCtrl.Instance:ShowLackDiamondView()
		else
			WelfareCtrl.Instance:SendGetOffLineExp(find_type)
			self:Close()
		end
	end
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
	if not main_vo or not off_line_exp then return end

	off_line_exp = off_line_exp * self.select_index
	
	local lv, zhuan = PlayerData.GetLevelAndRebirth(main_vo.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.level:SetValue(level_des)

	self.role_exp:SetValue(CommonDataManager.ConverMoney(off_line_exp))

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
	if not off_line_cfg then return end
	for k, v in ipairs(self.gold_text_list) do
		local cost = off_line_cfg[k].diamond * multiple
		local cost_des = ""
		local role_gold = nil

		if off_line_cfg[k].can_use_bind_gold ~= 0 then
			role_gold = main_vo.bind_gold + main_vo.gold
		else
			role_gold = main_vo.gold
		end

		if role_gold < cost then
			cost_des = ToColorStr(tostring(cost), TEXT_COLOR.RED)
		else
			cost_des = ToColorStr(tostring(cost), TEXT_COLOR.GREEN)
		end
		v:SetValue(cost > 0 and cost_des or "")
		self.gold_icon[k]:SetActive(cost > 0)
	end
end