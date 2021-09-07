RareTreasureSelectView = RareTreasureSelectView or BaseClass(BaseView)
function RareTreasureSelectView:__init()
	self.ui_config = {"uis/views/serveractivity/raretreasure", "SelectView"}
	self:SetMaskBg()
	self.word_seq = 0
	self.pool_seq = 0
end

function RareTreasureSelectView:ReleaseCallBack()
	self.word_icon = nil
	self.totle_role = nil
	self.totle_gold = nil
	self.pool_status = nil
	self.btn_text = nil
end

function RareTreasureSelectView:LoadCallBack()
	self.word_icon = self:FindVariable("WordIcon")
	self.totle_role = self:FindVariable("TotleRole")
	self.totle_gold = self:FindVariable("TotleGold")
	self.pool_status = self:FindVariable("IsOpen")
	self.btn_text = self:FindVariable("BtnText")

	self:ListenEvent("ClickSelectWord", BindTool.Bind(self.ClickSelectWord, self))
	self:ListenEvent("CloseView", BindTool.Bind(self.Close, self))
end

function RareTreasureSelectView:SetSelectSeq(word_seq)
	self.word_seq = word_seq or 0
end

function RareTreasureSelectView:SetRewardPoolSeq(pool_seq)
	self.pool_seq = pool_seq or 0
end

function RareTreasureSelectView:OpenCallBack()
	self:FlushInfo()
end

function RareTreasureSelectView:OnFlush(param)
	self:FlushInfo()
end

function RareTreasureSelectView:FlushInfo()
	local bundle, asset = ResPath.GetRareTreasureImage("word_" .. self.word_seq)
	self.word_icon:SetAsset(bundle, asset)
	local role_count = RareTreasureData.Instance:GetGuessCountBySeq(self.pool_seq, self.word_seq)
	self.totle_role:SetValue(role_count)
	local lottery_cost = RareTreasureData.Instance:GetLotteryCost()
	local pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.pool_seq)
	if not pool_config then return end
	local pool_cost = lottery_cost * (pool_config.reward_rate or 0)

	local calc_num = role_count
	local my_word = RareTreasureData.Instance:GetMyWordBySeq(self.pool_seq)
	local is_same = true
	if my_word ~= self.word_seq then
		calc_num = calc_num + 1
		is_same = false
	end

	local get_cost = math.ceil(pool_cost / calc_num)
	self.totle_gold:SetValue(get_cost)

	local pool_is_open = RareTreasureData.Instance:GetTrueWordBySeq(self.pool_seq) ~= -1
	local btn_texts = Language.Rare.SelectMe
	if not pool_is_open then
		self.pool_status:SetValue(is_same)
		if is_same then
			-- 未开奖并且和当前选中一样
			btn_texts = Language.Rare.HasSelect
		end
	else
		btn_texts = Language.Rare.Open
		self.pool_status:SetValue(pool_is_open)
	end
	self.btn_text:SetValue(btn_texts)
end

function RareTreasureSelectView:ClickSelectWord()
	local pool_config = RareTreasureData.Instance:GetConfigByPoolSeq(self.pool_seq)
	if not pool_config then return end
	local recharge_num = RareTreasureData.Instance:GetTotleChongZhi()
	if recharge_num < pool_config.unlock_cost then
		TipsCtrl.Instance:ShowCommonTip(function ()
			ViewManager.Instance:Open(ViewName.RechargeView)
		end, nil, Language.Rare.NotEnough)
		return
	end

	local cur_select = RareTreasureData.Instance:GetMyWordBySeq(self.pool_seq)
	function click_callback()
		HappyBargainCtrl.Instance:SendCrossRandActivityRequest(ACTIVITY_TYPE.CROSS_MI_BAO_RANK,
			RARE_TREASURE.RA_ZHEN_YAN_REQ_TYPE_CHANGE_WORD, self.pool_seq, cur_select, self.word_seq)
		self:Close()
	end

	if cur_select == -1 then
		click_callback()
	else
		local cur_change_times = RareTreasureData.Instance:GetCurChangeNum()
		local next_cost = RareTreasureData.Instance:GetChangeWordNeedGold(cur_change_times)
		local show_str = string.format(Language.Rare.Description, next_cost)
		TipsCtrl.Instance:ShowCommonTip(click_callback, nil, show_str)
	end
end