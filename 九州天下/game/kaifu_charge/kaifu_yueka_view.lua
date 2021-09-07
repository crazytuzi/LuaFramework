KaiFuYueKaView = KaiFuYueKaView or BaseClass(BaseRender)

function KaiFuYueKaView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","YueKaContent"}
	
end


function KaiFuYueKaView:__delete()
	if self.item_cell then
		for k, v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
	end
	self.panel_animator = nil

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function KaiFuYueKaView:LoadCallBack()
	self.day_gold = self:FindVariable("Day_Gold")
	self.btn_text = self:FindVariable("Btn_Text")
	self.month_charge = self:FindVariable("Month_Charge")
	self.remnant_Day = self:FindVariable("Remnant_Day")
	self.show_redpoint = self:FindVariable("show_redpoint")
	self.show_red_point =  self:FindVariable("show_red_point")
	self.PayNum = self:FindVariable("PayNum")
	self.GotRewordYueKa = self:FindVariable("GotRewordYueKa")
	self.btnMonthNumReward = self:FindObj("BtnMonthNumReward")
	self.imgMonthNumRewarded = self:FindObj("ImgMonthNumRewarded")

	self.content1 = self:FindObj("Content1")
	self.content2 = self:FindObj("Content2")
	self.content3 = self:FindObj("Content3")
	self.btnBuy = self:FindObj("BtnBuy")
	self.yueKaDayReWard = self:FindObj("YueKaDayReWard")

	self.item_cell = {}
	for i=1,5 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	self:ListenEvent("ClickBuy",
		BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("ClickMonthNumReward", 
		BindTool.Bind(self.OnClickMonthNumReward, self))
	self:ListenEvent("ClickMonthDayReward", 
		BindTool.Bind(self.OnClickMonthDayReward, self))

	self.panel_animator = self.btnMonthNumReward:GetComponent(typeof(UnityEngine.Animator))
	self:SetData()
	self:Flush()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFuYueKa)
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFuYueKaGold)
end



function KaiFuYueKaView:OnClickBuy()
	RechargeCtrl.Instance:Recharge(KaiFuChargeData.Instance:YueKaNeedPrice())
end

-- 月卡第一次奖励
function KaiFuYueKaView:OnClickMonthNumReward()
	KaiFuChargeCtrl.Instance:SendMonthReward(MONTH_CARD_REWARD_TYPE.MONTH_CARD_REWARD_TYPE_FIRST)
end

-- 月每日奖励
function KaiFuYueKaView:OnClickMonthDayReward()
	KaiFuChargeCtrl.Instance:SendMonthReward(MONTH_CARD_REWARD_TYPE.MONTH_CARD_REWARD_TYPE_DAILY)
end

-- 红点回调
function KaiFuYueKaView:RemindChangeCallBack(remind_name, num)
	if RemindName.KaiFuYueKa == remind_name then
		self.show_redpoint:SetValue(num > 0)
	elseif RemindName.KaiFuYueKaGold == remind_name then
		self.show_red_point:SetValue(num > 0)
	end
end


function KaiFuYueKaView:OnFlush(param_t)
	local touzi_cfg = KaiFuChargeData.Instance:TouZiCfg()
	local yueka_info = KaiFuChargeData.Instance:GetMonthCardInfo()
	local other_cfg = KaiFuChargeData.Instance:TouZiOtherCfg()
	local yueka_cfg = KaiFuChargeData.Instance:ChongzhirewardCfg()
	if yueka_cfg then
		self.day_gold:SetValue(yueka_cfg.month_card_daily_gold_reward)
		self.month_charge:SetValue(yueka_cfg.month_card_gold_price)
		local pay_num = yueka_cfg.month_card_gold_price / 10
		self.PayNum:SetValue(pay_num)
	end
	if yueka_info.is_active then				--是否激活
		if yueka_info.is_active >= 1 then  
			self.btn_text:SetValue(Language.Common.AlreadyPurchase)
			if yueka_info.monthcard_first_reward_fetch_flag and  yueka_info.monthcard_first_reward_fetch_flag == 0 then   			--能够拿取的元宝数
				self.btnMonthNumReward:SetActive(true)
				self.imgMonthNumRewarded:SetActive(false)
				-- self.show_redpoint:SetValue(true)
				if self.panel_animator and not IsNil(self.panel_animator.gameObject) then
					self.panel_animator:SetBool("shake", true)
				end
				
			else
				self.btnMonthNumReward:SetActive(false)
				self.imgMonthNumRewarded:SetActive(true)
				if self.panel_animator and not IsNil(self.panel_animator.gameObject) then
					self.panel_animator:SetBool("stop", true)
				end
				
			end
			self:ShowContent(3)
			self.btnBuy:SetActive(false)
			
			if yueka_info.reward_gold == 0 then
				self.yueKaDayReWard.grayscale.GrayScale = 180
				self.GotRewordYueKa:SetValue(true)
			else
				self.yueKaDayReWard.grayscale.GrayScale = 0
				self.GotRewordYueKa:SetValue(false)
			end

		else							   
			--self.btn_text:SetValue(Language.KaiFuCharge.MountBuy)
			self.btnBuy:SetActive(true)
			if yueka_info.buy_times then   												--月卡购买次数
				if yueka_info.buy_times == 0 then
					self:ShowContent(1)
				else
					self:ShowContent(2)
				end
			end
			self.yueKaDayReWard.grayscale.GrayScale = 180
		end
	end
	local buytime = yueka_info.active_timestamp
	--self.remnant_Day:SetValue((os.time({day=os.date("%d",buytime), month=os.date("%m",buytime)+1, year=os.date("%Y",buytime)})-buytime)/86400)
	self.remnant_Day:SetValue((buytime+30*86400-TimeCtrl.Instance:GetServerTime())/86400)
	self:SetData()

end
function KaiFuYueKaView:ShowContent(index)
	local contentTable = {self.content1,self.content2,self.content3}
	for i = 1,#contentTable do
		if(index==i) then
			contentTable[i]:SetActive(true)
		else
			contentTable[i]:SetActive(false)
		end
	end
end


function KaiFuYueKaView:SetData()
	local other_cfg = KaiFuChargeData.Instance:ChongzhirewardCfg()
	local giftItemList = ItemData.Instance:GetGiftItemList(other_cfg.first_buy_month_card_reward.item_id)

	for i=1,#giftItemList do
		self.item_cell[i]:SetData({item_id = giftItemList[i].item_id,num = giftItemList[i].num})
		-- self.item_cell[i]:SetData(other_cfg.reward_item[i - 1])
		self.item_cell[i]:ShowGetEffect(true)
	end
end