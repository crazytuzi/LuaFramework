CrazyMoneyTreeData = CrazyMoneyTreeData or BaseClass(XuiBaseView)

function CrazyMoneyTreeData:__init()
	if CrazyMoneyTreeData.Instance then
		ErrorLog("[CrazyMoneyTreeData] Attemp to create a singleton twice !")
	end

	CrazyMoneyTreeData.Instance = self

	self.total_chongzhi_gold = 0
	self.chongzhi_gold = 0

	RemindManager.Instance:Register(RemindName.CrazyTree, BindTool.Bind(self.RemindChangeCallBack, self))
end

function CrazyMoneyTreeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.CrazyTree, BindTool.Bind(self.RemindChangeCallBack, self))
	CrazyMoneyTreeData.Instance = nil
end

function CrazyMoneyTreeData:SetRAShakeMoneyInfo(protocol)
	self.total_chongzhi_gold = protocol.total_chongzhi_gold
	self.chongzhi_gold = protocol.chongzhi_gold
end

function CrazyMoneyTreeData:GetTotalGold()
	 return self.total_chongzhi_gold
end

--已领取元宝
function CrazyMoneyTreeData:GetMoney()
	 return self.chongzhi_gold
end

function CrazyMoneyTreeData:GetShankeCfgByServerDay()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local shake_money_cfg = config.shake_money or {}
	local max_open_day = shake_money_cfg[#shake_money_cfg] and shake_money_cfg[#shake_money_cfg].section_start or 0
	local return_seq = 0
	if max_open_day ~= 0 and server_day >= max_open_day then
		return_seq = #shake_money_cfg 
		return return_seq 
	end

	for k,v in pairs(shake_money_cfg) do
		if server_day >= v.section_start and server_day <= v.section_end then
			return_seq = k
			break
		end
	end

	return return_seq
end

function CrazyMoneyTreeData:GetMaxChongZhiNum()
	local seq = self:GetShankeCfgByServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local shake_money_cfg = {}
	if config then
		shake_money_cfg = config.shake_money
	end
	local return_max = shake_money_cfg[seq] and shake_money_cfg[seq].return_max or 0
	return return_max
end

function CrazyMoneyTreeData:GetReturnChongzhi()
	local seq = self:GetShankeCfgByServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local shake_money_cfg = {}
	if config then
		shake_money_cfg = config.shake_money or {}
	end
	local return_chongzhi = shake_money_cfg[seq] and shake_money_cfg[seq].chongzhi_return or 0
	return return_chongzhi
end

--获取红点提醒
function CrazyMoneyTreeData:GetCanCrazy()
	local max_chongzhi_num = self:GetMaxChongZhiNum()
	local gold_num = self.total_chongzhi_gold - self.chongzhi_gold
	local cangetgold =  max_chongzhi_num - self.chongzhi_gold
	local has_recive_gold = self:GetReturnChongzhi()
	if gold_num > 0 and cangetgold > 0 then
		if self.chongzhi_gold ==  math.floor(self.total_chongzhi_gold * has_recive_gold / 100) then
			return false
		else
			return true
		end
	end
	return false
end

function CrazyMoneyTreeData:RemindChangeCallBack()
	local show_redpoint = self:GetCanCrazy()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY, show_redpoint)
end