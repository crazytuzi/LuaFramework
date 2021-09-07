BrothelView = BrothelView or BaseClass(BaseView)

ENTERTAINMENT_NUM = 3

function BrothelView:__init()
	self.ui_config = {"uis/views/brothel","BrothelContent"}
	self:SetMaskBg(true)
	self.play_audio = true
	
	self.cell_list = {}
	self.toggle_list = {}
end

function BrothelView:__delete()

end

function BrothelView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	for i=1,ENTERTAINMENT_NUM do
		self:ListenEvent("ClickBuy"..i, BindTool.Bind(self.ClickBuy, self, i))
	end

	self.belle_desc_t = {}
	self.duration_min_t = {}
	self.gold_cost_t = {}
	for i=1,ENTERTAINMENT_NUM do
		self.belle_desc_t[i] = self:FindVariable("belle_desc_"..i)
		self.duration_min_t[i] = self:FindVariable("duration_min_"..i)
		self.gold_cost_t[i] = self:FindVariable("gold_cost_"..i)
	end
	self.des = self:FindVariable("des")
	self.gold_text = self:FindVariable("gold_text")
end

function BrothelView:ReleaseCallBack()
	self.belle_desc_t = nil
	self.duration_min_t = nil
	self.gold_cost_t =nil
	self.des = nil
	self.gold_text = nil
end

function BrothelView:OpenCallBack()
	self:Flush()
end

function BrothelView:CloseView()
	self:Close()
end

function BrothelView:OnFlush()
	local des_str = ""
	local time_str = ""
	local enhancement = 10
	local value = 0
	local time = 30
	local cost = 50
	local singer_num = BrothelData.Instance.GetSingerNum()
	local total_enhancement = singer_num * enhancement
	for i=1,ENTERTAINMENT_NUM do
		enhancement = BrothelData:GetEnhancement(i - 1)
		value = BrothelData:GetValue(i - 1)
		value = value + value * (total_enhancement / 100)
		des_str = string.format(Language.Brothel.BelleDesc[i], value)
		self.belle_desc_t[i]:SetValue(des_str)
		time = BrothelData:GetDuration(i - 1)
		time_str = string.format(Language.Brothel.DurationMin, time)
		self.duration_min_t[i]:SetValue(time_str)
		cost = BrothelData:GetConsume(i - 1)
		self.gold_cost_t[i]:SetValue(cost)
	end
	local gold_text = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.GOLD_INGOT)
	local gold_str = CommonDataManager.ConverMoney(gold_text)
	self.gold_text:SetValue(gold_str)
	local ps_text = string.format(Language.Brothel.Ps, singer_num, total_enhancement).."%。"
	self.des:SetValue(ps_text)
end

function BrothelView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(248)
end

function BrothelView:ClickBuy(index)
	BrothelCtrl.Instance:SendBuyBuffReq(index - 1)
end