--------------------------------------------------------------------------
--TimeLimitBigGiftView 	限时豪礼面板
--------------------------------------------------------------------------

TimeLimitBigGiftView = TimeLimitBigGiftView or BaseClass(BaseView)

function TimeLimitBigGiftView:__init()
	self.ui_config = {"uis/views/timelimitbiggift_prefab", "TimeLimitBigGiftView"}
	self.play_audio = true
	
end

function TimeLimitBigGiftView:__delete()
	-- body
end

--打开回调函数
function TimeLimitBigGiftView:OpenCallBack()
	TimeLimitBigGiftCtrl.Instance:SendBuyOrInfo()

	self:Flush()
	
	self.begin_timestamp = TimeLimitBigGiftData.Instance:GetTimeLimitGiftInfo().begin_timestamp or 0
	self.EndTime = self.begin_timestamp + (self.limit_time or 0)
	local rest_time = self.EndTime - TimeCtrl.Instance:GetServerTime()
	self:SetTime(rest_time)
    if rest_time >= 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
				self:SetTime(rest_time)
		end)
	end
end

--关闭回调函数
function TimeLimitBigGiftView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function TimeLimitBigGiftView:LoadCallBack()
	self.res_time = self:FindVariable("res_time")
	self.cost_text = self:FindVariable("CostText")
	self.value_text = self:FindVariable("ValueText")
	self.show_buy_text = self:FindVariable("show_buy_text")
	self.buy_btn = self:FindObj("buy_btn")

	self.show_cell_list = {}
	for i = 1, 4 do
		self.show_cell_list[i] = self:FindVariable("show_cell"..i)
	end

	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_cell"..i))
	end

	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))

	TimeLimitBigGiftCtrl.Instance:SendBuyOrInfo()

	local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()
	if cfg then
		self.limit_time	= cfg.limit_time or 0
		self.EndTime = 0
	end

end

--释放回调
function TimeLimitBigGiftView:ReleaseCallBack()
	if self.item_list then
		for i = 1, 4 do
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
		self.item_list = nil
	end

	if self.show_cell_list then
		for i = 1, 4 do
			self.show_cell_list[i] = nil
		end
		self.show_cell_list = nil
	end

	self.res_time = nil
	self.cost_text = nil
	self.value_text = nil
	self.buy_btn = nil
	self.show_buy_text = nil
end

function TimeLimitBigGiftView:OnFlush()
	local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()
	
	if cfg and cfg.reward_item and cfg.limit_time and cfg.seq and cfg.need_gold and cfg.gift_value then
		self.show_info_list = cfg.reward_item
		self.show_info_list_seq = cfg.seq
		self.limit_time	= cfg.limit_time
		self.cost_text:SetValue(cfg.need_gold)
		self.value_text:SetValue(cfg.gift_value)

		local num = 0
		for k, v in pairs(cfg.reward_item) do 
			num = num + 1
		end
		if self.show_cell_list and self.item_list and num > 0 then
			for i = 1, 4 do
				if self.show_cell_list[i] and self.item_list[i] then
					self.show_cell_list[i]:SetValue(i <= num)
					self.item_list[i]:SetData(cfg.reward_item[i - 1])
				end	
			end
		end
	end

	self:FlushBuyButton()
end


function TimeLimitBigGiftView:FlushBuyButton()
	self.is_already_buy = TimeLimitBigGiftData.Instance:GetTimeLimitGiftInfo().is_already_buy or 0
	self.buy_btn.grayscale.GrayScale = (self.is_already_buy > 0) and 255 or 0
	self.show_buy_text:SetValue(self.is_already_buy <= 0)
end

--设置时间
function TimeLimitBigGiftView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = string.format(Language.TimeLimitGift.ResTime, time_tab.hour, time_tab.min, time_tab.s)
	self.res_time:SetValue(str)
end

function TimeLimitBigGiftView:ClickBuy()
	if self.is_already_buy and self.is_already_buy <= 0 then
		local gold_num = PlayerData.Instance.role_vo["gold"] or 0
		local cfg = TimeLimitBigGiftData.Instance:GetLimitGiftCfg()

		if not cfg or not cfg.need_gold  then
			return 
		end

		if gold_num >= cfg.need_gold then
			local yes_func = function()
				TimeLimitBigGiftCtrl.Instance:SendBuyOrInfo(self.show_info_list_seq or 0)
			end
			
			local describe = string.format(Language.TimeLimitBigGift.BuyTips, cfg.need_gold) or ""

			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		else
			ViewManager.Instance:Open(ViewName.TipsLackDiamondView)
		end
	end
end

--关闭页面
function TimeLimitBigGiftView:CloseView()
	self:Close()
end