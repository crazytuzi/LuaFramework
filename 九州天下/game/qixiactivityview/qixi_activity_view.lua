QiXiActivityView = QiXiActivityView or BaseClass(BaseView)

function QiXiActivityView:__init()
	self.ui_config = {"uis/views/qixiactivityview", "QiXiActivityView"}
	self.play_audio = true
	self.cell_list = {}
	self.end_time = 0
	self.data = {}
	self.reward_id = 0
	self:SetMaskBg()
end

function QiXiActivityView:LoadCallBack()
	 KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:ListenEvent("OnBtnTips", BindTool.Bind(self.OnBtnTipsHandler, self))
	self.num = self:FindVariable("Num")
	self.mate_score = self:FindVariable("mate_score")
	self.total_score = self:FindVariable("total_score")
	self.remain_score = self:FindVariable("remain_score")

	self:InitScroller()
end

function QiXiActivityView:OnBtnTipsHandler()
	TipsCtrl.Instance:ShowHelpTipView(245)
end

function QiXiActivityView:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function QiXiActivityView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	self.scroller = nil
	self.act_time = nil
	self.num = nil
	self.mate_score = nil
	self.total_score = nil
	self.remain_score = nil
end

function QiXiActivityView:InitScroller()
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	self.data = QiXiActivityData.Instance:GetJuHuaSuanData()
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = QiXiActivityCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.data[data_index])
	end
end

function QiXiActivityView:OpenCallBack()
	self:Flush()
end

function QiXiActivityView:OnFlush(param_t)
	self.data = QiXiActivityData.Instance:GetJuHuaSuanData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end

	self.num:SetValue(QiXiActivityData.Instance.yuehui_my_score)
	self.mate_score:SetValue(QiXiActivityData.Instance.yuehui_mate_score)
	self.total_score:SetValue(QiXiActivityData.Instance.yuehui_total_score)
	self.remain_score:SetValue(QiXiActivityData.Instance.yuehui_remain_score)
end

---------------------------------------------------------------
--滚动条格子

QiXiActivityCell = QiXiActivityCell or BaseClass(BaseCell)

function QiXiActivityCell:__init()
	self.recharge_txt = self:FindVariable("RechargeTxt")
	self.btn_enble = self:FindVariable("BtnEnble")
	self.btn_txt = self:FindVariable("BtnTxt")
	self.show_red = self:FindVariable("ShowRed")
	self.reward_list = {}
	for i = 1, 3 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("ItemList"))
	end
	self:ListenEvent("ClickBuy",
		BindTool.Bind(self.ClickBuy, self))
end

function QiXiActivityCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
end

function QiXiActivityCell:OnFlush()
	if nil == self.data then return end
	local item_list = ItemData.Instance:GetGiftItemList(self.data.rewarditem.item_id)
	for k,v in pairs(self.reward_list) do
		if item_list[k] then
			v:SetData(item_list[k])
		end
		v.root_node:SetActive(item_list[k] ~= nil)
	end
	self.recharge_txt:SetValue(self.data.score)

	local str = self.data.task_achieve_count == 0 and Language.QiXiActivity.BtnText1 or Language.QiXiActivity.BtnText2
	self.btn_txt:SetValue(str)
	self.btn_enble:SetValue(self.data.task_achieve_count == 0)
	self.show_red:SetValue(self.data.fetch_reward_flag == 0)
end

function QiXiActivityCell:ClickBuy()
	if self.data == nil then return end
	if self.data.fetch_reward_flag == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.QiXiActivity.tipsText)
		return
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN, RA_CONSUME_AIM_OPERA_TYPE.RA_CONSUME_AIM_OPERA_TYPE_FETCH_REWARD
	 , self.data.seq)
end