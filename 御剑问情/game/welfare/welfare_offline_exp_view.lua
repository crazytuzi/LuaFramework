OfflineExpView = OfflineExpView or BaseClass(BaseRender)

function OfflineExpView:__init()
	--监听事件
	self.hour = self:FindVariable("Hour")
	self.minute = self:FindVariable("Minute")
	self.second = self:FindVariable("Second")

	self.item_cell_list = WelfareCtrl.CommonItemManager(self, OfflineExpCell.New)
	self.offline_cfg = WelfareData.Instance:GetOffLineExpCfg()
	local count = 1
	for k,v in pairs(self.item_cell_list) do
		v.mother_view = self
		v.cell_index = count
		v:SetCfg(self.offline_cfg[count])
		count = count + 1
	end

	self:Flush()
end

function OfflineExpView:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
end

function OfflineExpView:Flush()
	--时间
	local hour, min, sec = WelfareData.Instance:GetOffLineTime()
	self.hour:SetValue(hour)
	self.minute:SetValue(min)
	self.second:SetValue(sec)
	--经验
	local exp = WelfareData.Instance:GetOffLineExp()

	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local match_cfg = nil
	for k,v in pairs(self.offline_cfg) do
		if v.vip_level <= vip_level then
			match_cfg = v
		else
			break
		end
	end

	for k,v in pairs(self.item_cell_list) do
		local data = {}
		data.exp = exp
		data.match_cfg_type = match_cfg.type
		v:SetData(data)
	end
end

function OfflineExpView:SendGetOffLineExp(type)
	WelfareCtrl.Instance:SendGetOffLineExp(type)
end

--------------------------------------------------------------
--收益格子
OfflineExpCell = OfflineExpCell or BaseClass(BaseCell)

function OfflineExpCell:__init()
	self.exp = self:FindVariable("Exp")
	self.vip_tips = self:FindVariable("VipTips")
	self.vip_state = self:FindVariable("VIPState")
	self.can_get = self:FindVariable("CanGet")

	self:ListenEvent("UpgradeVIPClick", BindTool.Bind(self.UpgradeVipClick, self))
	self:ListenEvent("GetClick", BindTool.Bind(self.GetRewardClick, self))

	self.cfg = nil
end

function OfflineExpCell:__delete()

end

function OfflineExpCell:SetCfg(cfg)
	self.cfg = cfg
end

function OfflineExpCell:OnFlush()
	self.exp:SetValue(self.data.exp * self.cfg.factor)

	--玩家vip等级符合领取条件
	if self.data.match_cfg_type == self.cfg.type then
		self.vip_state:SetValue(1)
		self.can_get:SetValue((self.data.exp > 0))
	--玩家vip等级符高于领取条件
	elseif self.data.match_cfg_type > self.cfg.type then
		self.vip_state:SetValue(2)
	--玩家vip等级符低于领取条件
	else
		self.vip_state:SetValue(0)
		self.vip_tips:SetValue(ToColorStr(string.format(Language.Welfare.Vip, self.cfg.vip_level), TEXT_COLOR.RED))
	end
end

function OfflineExpCell:GetRewardClick()
	self.mother_view:SendGetOffLineExp(self.cell_index - 1)
end

function OfflineExpCell:UpgradeVipClick()
	ViewManager.Instance:Close(ViewName.Welfare)
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end