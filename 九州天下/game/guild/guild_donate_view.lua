GuildDonateView = GuildDonateView or BaseClass(BaseRender)

function GuildDonateView:__init(instance)
	if instance == nil then
		return
	end

	self.record_num = 3
	self.record_list = {}
	self.variables = {}
	for i = 1, self.record_num do
		self.record_list[i] = self:FindObj("Record" .. i)

		self.variables[i] = {}
		self.variables[i].time = self.record_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("time")
		self.variables[i].name = self.record_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("name")
		self.variables[i].type = self.record_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("type")
		self.variables[i].donate_num = self.record_list[i]:GetComponent(typeof(UIVariableTable)):FindVariable("donate_num")
	end

	self.coin_text = self:FindVariable("coin_text")
	self.gold_text = self:FindVariable("gold_text")
	self.coin_change_text = self:FindVariable("coin_change_text")
	self.gold_change_text = self:FindVariable("gold_change_text")
	self.coin_btn = self:FindVariable("BtnCoinEnable")
	self.gold_btn = self:FindVariable("BtnGoldEnable")
	self.tongbi_shangxiang = self:FindVariable("TongBiShangXiang")
	self.yuanbao_shangxiang = self:FindVariable("YuanBaoShangXiang")
	self.tongbi_rongyu = self:FindVariable("TongBiRongYu")
	self.yuanbao_rongyu = self:FindVariable("YuanBaoRongYu")
	self.show_jilu = self:FindVariable("ShowJiLu")
	self.shangxiang_btn = self:FindVariable("shangxiang_btn")
	self.show_coin_red_point = self:FindVariable("ShowCoinRedPoint")

	self:ListenEvent("OnClickCoinDonate", BindTool.Bind(self.OnClickCoinDonate, self))
	self:ListenEvent("OnClickGoldDonate", BindTool.Bind(self.OnClickGoldDonate, self))
	self:ListenEvent("BtnCheckDonate", BindTool.Bind(self.BtnCheckDonate, self))
	self:ListenEvent("BtnHelp", BindTool.Bind(self.BtnHelp, self))
end

function GuildDonateView:OnFlush()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local coin_cfg = GuildData.Instance:GetShangXiangCfgByType(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_COIN)
	local gold_cfg = GuildData.Instance:GetShangXiangCfgByType(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD)
	local type_coin, type_gold = GuildData.Instance:GetGuildExpType()
	if coin_cfg then
		self.coin_text:SetValue(coin_cfg.cost)
	end
	if gold_cfg then
		self.gold_text:SetValue(gold_cfg.cost)
	end
	if role_vo and coin_cfg then
		self.show_coin_red_point:SetValue(role_vo.coin >= coin_cfg.cost and type_coin == 0)
	end

	local event_list = GuildData.Instance:GetGuildEventList()
	local event_num = #event_list
	if event_num then
		self.show_jilu:SetValue(event_num == 0)
	end

	for i = 1, self.record_num do
		self.record_list[i]:SetActive(i <= event_num)

		if i <= event_num then
			self.variables[i].name:SetValue(event_list[i].event_owner)
			self.variables[i].type:SetValue(Language.Guild.DonateType[event_list[i].param0])
			self.variables[i].donate_num:SetValue(event_list[i].param1)

	        local t_time = TimeUtil.Timediff(TimeCtrl.Instance:GetServerTime(), event_list[i].event_time)
	        local donate_time = self:LastDonateTime(t_time)
			self.variables[i].time:SetValue(donate_time)
		end
	end

	local shangxiang_cfg = GuildData.Instance:GetGuildShangXiangCfg()
	self.tongbi_shangxiang:SetValue(string.format(Language.Guild.ShangXiangTongBi,shangxiang_cfg[2].cost))
	self.yuanbao_shangxiang:SetValue(string.format(Language.Guild.ShangXiangYuanBao,shangxiang_cfg[1].cost))
	self.tongbi_rongyu:SetValue(string.format(Language.Guild.ShangXiangRongYu,shangxiang_cfg[2].add_gongxian))
	self.yuanbao_rongyu:SetValue(string.format(Language.Guild.ShangXiangRongYu,shangxiang_cfg[1].add_gongxian))

	if type_coin ~= 0 then
		self.coin_text:SetValue(true)
		self.coin_btn:SetValue(true)
		self.coin_change_text:SetValue(Language.Guild.HadShangxiang)
	else
		self.coin_text:SetValue(false)
		self.coin_btn:SetValue(false)		
		self.coin_change_text:SetValue(Language.Guild.CoinShangXiang)
	end

	if type_gold ~= 0 then
		self.gold_text:SetValue(true)
		self.gold_btn:SetValue(true)
		self.gold_change_text:SetValue(Language.Guild.HadShangxiang)
		self.shangxiang_btn:SetAsset(ResPath.GetImages("btn_1013"))
	else
		self.gold_text:SetValue(false)
		self.gold_btn:SetValue(false)
		self.gold_change_text:SetValue(Language.Guild.GoldShangXiang)
		self.shangxiang_btn:SetAsset(ResPath.GetImages("btn_1008"))
	end

end

-- 通过相差的时间，返回合适的时间
function GuildDonateView:LastDonateTime(t_time)
    local last_time = ""
    if t_time.year > 0 then
        last_time = string.format(Language.Common.BeforeXXYear, t_time.year)
        return last_time
    elseif t_time.year < 0 then
        last_time = Language.Common.JustMoment
        return last_time
    end
    if t_time.month ~= 0 then
        string.format(Language.Common.BeforeXXMonth, t_time.month)
        return last_time
    end
    if t_time.day ~= 0 then
        last_time = string.format(Language.Common.BeforeXXDay, t_time.day)
        return last_time
    end
    if t_time.hour ~= 0 then
        last_time = string.format(Language.Common.BeforeXXHour, t_time.hour)
        return last_time
    end
    if t_time.min ~= 0 then
        last_time = string.format(Language.Common.BeforeXXMinute, t_time.min)
        return last_time
    end
    if t_time.sec ~= 0 then
	    last_time = string.format(Language.Common.BeforeXXSecond, t_time.sec)
    else
    	last_time = Language.Common.JustMoment
    end
    return last_time
end

function GuildDonateView:OnClickCoinDonate()
	local coin_cfg = GuildData.Instance:GetShangXiangCfgByType(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_COIN)
	
	if nil == coin_cfg then return end
	local ok_fun = function ()
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_COIN, coin_cfg.cost, 0, {})
	end

	local coin_desc = string.format(Language.Guild.CostCoinDesc, coin_cfg.cost)
    TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, coin_desc)
end

function GuildDonateView:OnClickGoldDonate()
	local gold_cfg = GuildData.Instance:GetShangXiangCfgByType(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD)
	if nil == gold_cfg then return end
    local ok_fun = function ()
		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD, gold_cfg.cost, 0, {})
	end

	local gold_desc = string.format(Language.Guild.CostGoldDesc, gold_cfg.cost)
	
    TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, gold_desc)
end

function GuildDonateView:BtnCheckDonate()
	GuildCtrl.Instance:GuildCheckDonateViewOpen()
end

function GuildDonateView:BtnHelp()
	TipsCtrl.Instance:ShowHelpTipView(191)
end
