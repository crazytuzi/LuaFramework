require("game/exchange/exchange_content_view")
ExchangeView = ExchangeView or BaseClass(BaseView)

local SHOW_EXCHANGE_TAB =
{
	--1,		 --MOJING
	--2, 		--RONG_YU
	--8,		--RONG_YAO
	
	9,		 	--气运
	10, 		--积分
	11,			--跨服
	12,			--金锭
}

function ExchangeView:__init()
	self.ui_config = {"uis/views/exchangeview","NewExchangeView"}
	self:SetMaskBg()                
	self.full_screen = false
	self.play_audio = true
	self.is_first = true
	self.cur_index = 1
	self.toggle_index = 8   -- 积分用
end
function ExchangeView:__delete()

end

function ExchangeView:ReleaseCallBack()
	if self.exchange_content_view ~= nil then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end

	if self.money_bar ~= nil then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Exchange)
	end
	self.cur_index = nil

	-- 清理变量和对象
	self.top_img_path = nil
	self.top_text_path = nil
	self.toggle_list = nil
end

function ExchangeView:LoadCallBack()
	local content_view = self:FindObj("exchange_content_view")
	content_view.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_content_view = ExchangeContentView.New(obj)
		--引导用
		self.cell_list = self.exchange_content_view:GetCellList()
	end)

	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent("add_money_click", BindTool.Bind(self.AddMoneyClick, self))

	for i = 1, 4 do
		self:ListenEvent("toggle_" .. i ,BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.top_img_path = self:FindVariable("top_img_path")
	self.top_text_path = self:FindVariable("top_text_path")

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	
	self:InitToggle()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Exchange, BindTool.Bind(self.GetUiCallBack, self))
end

function ExchangeView:GetExchangeContentView()
	return self.exchange_content_view
end

function ExchangeView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function ExchangeView:OpenCallBack()
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(true)
	end

	self:ShowOrHideTab()
end

function ExchangeView:ShowOrHideTab()
	local open_fun_data = OpenFunData.Instance
	self.toggle_list[3].toggle_content:SetActive(open_fun_data:CheckIsHide("kf_battle"))
	self.toggle_list[4].toggle_content:SetActive(open_fun_data:CheckIsHide("kf_battle"))
end

function ExchangeView:CloseCallBack()
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(false)
	end
end

function ExchangeView:ShowIndexCallBack(index)
	if index == TabIndex.exchange_mojing then
		self.toggle_list[1].toggle_content.toggle.isOn = true
	elseif index == TabIndex.exchange_shengwang then
		self.toggle_list[2].toggle_content.toggle.isOn = true
	elseif index == TabIndex.exchange_rongyao then
		self.toggle_list[3].toggle_content.toggle.isOn = true
	elseif index == TabIndex.exchange_goldingot then
		self.toggle_list[4].toggle_content.toggle.isOn = true
	end
end

function ExchangeView:OnCloseBtnClick()
	ViewManager.Instance:Close(ViewName.Exchange)
end

function ExchangeView:AddMoneyClick()
	if self.cur_index == EXCHANGE_PRICE_TYPE.FATE then
		ViewManager.Instance:Open(ViewName.Camp, TabIndex.camp_fate)
	elseif self.cur_index == EXCHANGE_PRICE_TYPE.DAILYSCORE then
		ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_daily)
	elseif self.cur_index == EXCHANGE_PRICE_TYPE.LIUJIESCORE then
		ViewManager.Instance:Open(ViewName.KuaFuBattle, KuafuGuildBattleView.TabIndex.liujie)
	elseif self.cur_index == EXCHANGE_PRICE_TYPE.GOLD_INGOT then
		ViewManager.Instance:Open(ViewName.KuaFuBattle)
	end
	self:OnCloseBtnClick()
end

function ExchangeView:InitToggle()
	self.toggle_list = {}
	local temp = 0
	for i = 1, 4 do
		self.toggle_list[i] = {}
		self.toggle_list[i].toggle_content = self:FindObj("toggle_content_" .. i)
		self.toggle_list[i].toggle_text = self:FindVariable("toggle_text_" .. i)
		local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, SHOW_EXCHANGE_TAB[i], GameVoManager.Instance:GetMainRoleVo().prof)
		-- if #item_id_list == 0 or i > #SHOW_EXCHANGE_TAB then
		-- 	self.toggle_list[i].toggle_content:SetActive(false)
		-- else
			temp = temp + 1
			if temp == 1 then
				self.toggle_list[i].toggle_text:SetValue(Language.Exchange.QiYun)
			elseif temp == 2 then
				self.toggle_list[i].toggle_text:SetValue(Language.Exchange.JiFen)
			elseif temp == 3 then
				self.toggle_list[i].toggle_text:SetValue(Language.Exchange.KuaFu)
			elseif temp == 4 then
				self.toggle_list[i].toggle_text:SetValue(Language.Exchange.JinDing)
			end
		-- end
	end
	self.toggle_list[1].toggle_content.toggle.isOn = true
end

function ExchangeView:OnToggleClick(i, is_click)
	if is_click then
		self.cur_index = SHOW_EXCHANGE_TAB[i] - 1 
		self.toggle_index = SHOW_EXCHANGE_TAB[i] - 1
		if self.exchange_content_view then
			self.exchange_content_view:SetCurrentPriceType(SHOW_EXCHANGE_TAB[i])
			self.exchange_content_view:OnFlushListView()
		end
		local bundle, asset = ResPath.GetExchangeNewIcon(ExchangeData.Instance:GetExchangeRes(SHOW_EXCHANGE_TAB[i]))
		self.top_img_path:SetAsset(bundle, asset)
		local type = SHOW_EXCHANGE_TAB[i] - 1
		self.top_text_path:SetValue(self:FormatMoney(ExchangeData.Instance:GetCurrentScore(type)))
	end
end

function ExchangeView:OnFlush()
	self.top_text_path:SetValue(self:FormatMoney(ExchangeData.Instance:GetCurrentScore(self.toggle_index)))
end

function ExchangeView:GetToggleIndex()
	return self.toggle_index
end

function ExchangeView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.exchange_mojing then
		self.toggle_list[1].toggle_content.toggle.isOn = true
	end
end

function ExchangeView:SelectFirstItem()
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	for k, v in pairs(self.cell_list) do
		local index = v:GetIndex()
		if index == 1 then
			local first_cell = v:GetFirstCell()
			if first_cell then
				first_cell:SelectToggle()
			end
		end
	end
end

function ExchangeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.exchange_mojing then
			local toggle_mojing = self.toggle_list[1].toggle_content
			if toggle_mojing.gameObject.activeInHierarchy then
				if toggle_mojing.toggle.isOn then
					return NextGuideStepFlag
				else
					local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.exchange_mojing)
					return toggle_mojing, callback
				end
			end
		end
	elseif ui_name == GuideUIName.ExchangeMoJingFirstItem then
		if self.cell_list and next(self.cell_list) then
			for k, v in pairs(self.cell_list) do
				local index = v:GetIndex()
				if index == 1 then
					local first_cell = v:GetFirstCell()
					if first_cell then
						local callback = BindTool.Bind(self.SelectFirstItem, self)
						return first_cell.root_node, callback
					end
				end
			end
		end
	end
end