require("game/exchange/exchange_content_view")
ExchangeView = ExchangeView or BaseClass(BaseView)

ExchangeView.SHOW_EXCHANGE_TAB =
{
	1,		 --MOJING
	2, 		--RONG_YU
	8,		--RONG_YAO
	14,      --XIANJING
}

local icon_img_path = {
	[1] = "ShengWang",
	[2] = "RongYu",
	[3] = "RongYao",
	[4] = "MiZang",
}

function ExchangeView:__init()
	self.ui_config = {"uis/views/exchangeview_prefab","NewExchangeView"}
	self.full_screen = true
	self.play_audio = true
	self.is_first = true
	self.cur_index = 1
end
function ExchangeView:__delete()

end

function ExchangeView:ReleaseCallBack()
	if self.exchange_content_view ~= nil then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Exchange)
	end
	self.cur_index = 1

	-- 清理变量和对象
	self.show_block = nil
	self.title_name = nil
	self.show_add_money = nil
	self.top_img_path = nil
	self.top_text_path = nil
	self.toggle_list = nil
	self.xian_shi_list = {}
	self.show_red_point_list = {}
	self.gold = nil
	self.bind_gold = nil
end

function ExchangeView:LoadCallBack()
	self:InitToggle()

	for i=1,4 do
		self:ListenEvent("toggle_" .. i ,BindTool.Bind2(self.OnToggleClick, self, i))
	end

	local content_view = self:FindObj("exchange_content_view")
	UtilU3d.PrefabLoad("uis/views/exchangeview_prefab", "Content",
	function(obj)
		obj.transform:SetParent(content_view.transform, false)
		obj = U3DObject(obj)
		self.exchange_content_view = ExchangeContentView.New(obj)
		--引导用
		self.cell_list = self.exchange_content_view:GetCellList()
	end)

	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent("add_money_click", BindTool.Bind(self.AddMoneyClick, self))
	self:ListenEvent("chongzhi",BindTool.Bind(self.ChongZhi, self))

	self.show_block = self:FindVariable("show_block")
	self.title_name = self:FindVariable("title_name")
	self.show_add_money = self:FindVariable("show_add_money")
	self.top_img_path = self:FindVariable("top_img_path")
	self.top_text_path = self:FindVariable("top_text_path")
	self.gold = self:FindVariable("coin_icon")
	self.bind_gold = self:FindVariable("bind_coin_text")

	self.xian_shi_list = {}
	self.show_red_point_list = {}
	for i=1,4 do
		self.xian_shi_list[i] = self:FindVariable("xianshi_" .. i)
		self.show_red_point_list[i] = self:FindVariable("show_red_point_" .. i)
	end
	self.top_text_path:SetValue(self:FormatMoney(ExchangeData.Instance:GetScoreList()[1]))  -- 给个默认值，显示第一个
	self.gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
	self.bind_gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
	self.show_add_money:SetValue(false)
	self.title_name:SetValue(Language.Exchange.Change)

	local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[self.cur_index])
	self.top_img_path:SetAsset(bundle, asset)

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Exchange, BindTool.Bind(self.GetUiCallBack, self))
end

function ExchangeView:GetExchangeContentView()
	return self.exchange_content_view
end

function ExchangeView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function ExchangeView:InitTabXianShi()
	self:DisAbleTabXianShi()
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	if not is_activity_open then
		return
	end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local data = ExchangeData.Instance
	for k, v in ipairs(ExchangeView.SHOW_EXCHANGE_TAB) do
		if self.xian_shi_list[k] then
			local itemid_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, v, prof)
			for _, v2 in ipairs(itemid_list) do
				if v2[2] == 1 then
					self.xian_shi_list[k]:SetValue(true)
					local is_click = ExchangeData.Instance:GetClickState(k)
					self.show_red_point_list[k]:SetValue(not is_click)
					break
				end
			end
		end
	end
end

function ExchangeView:FlushTab(index)
	local state = ExchangeData.Instance:GetClickState(index)
	if state then
		self.show_red_point_list[index]:SetValue(false)
	end
end

function ExchangeView:DisAbleTabXianShi()
	for i=1,4 do
		self.xian_shi_list[i]:SetValue(false)
		self.show_red_point_list[i]:SetValue(false)
	end
end

function ExchangeView:OpenCallBack()
	self.show_block:SetValue(true)
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(true)
	end
	self:InitTabXianShi()
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	self.activity_change_call_back = BindTool.Bind1(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_call_back)
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
end


function ExchangeView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" then
		self.gold:SetValue(GameVoManager.Instance:GetMainRoleVo().gold)
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(GameVoManager.Instance:GetMainRoleVo().bind_gold)
	end
end


function ExchangeView:CloseCallBack()
	if self.show_block then
		self.show_block:SetValue(false)
	end
	if self.exchange_content_view then
		self.exchange_content_view:SetIsOpen(false)
	end
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_call_back)
	self.activity_change_call_back = nil
end

function ExchangeView:ShowIndexCallBack(index)
	if index == TabIndex.exchange_mojing then
		self.toggle_list[1].toggle_content.toggle.isOn = true
		ExchangeData.Instance:SetCurIndex(ExchangeView.SHOW_EXCHANGE_TAB[1])
	elseif index == TabIndex.exchange_shengwang then
		self.toggle_list[2].toggle_content.toggle.isOn = true
		ExchangeData.Instance:SetCurIndex(ExchangeView.SHOW_EXCHANGE_TAB[2])
	elseif index == TabIndex.exchange_rongyao then
		self.toggle_list[3].toggle_content.toggle.isOn = true
		ExchangeData.Instance:SetCurIndex(ExchangeView.SHOW_EXCHANGE_TAB[3])
	elseif index == TabIndex.exchange_mizang then
		self.toggle_list[4].toggle_content.toggle.isOn = true
		ExchangeData.Instance:SetCurIndex(ExchangeView.SHOW_EXCHANGE_TAB[4])
	else
		self:ShowIndex(TabIndex.exchange_mojing)
	end

end

function ExchangeView:OnCloseBtnClick()
	self:Close()
--	ViewManager.Instance:Close(ViewName.Exchange)
end

function ExchangeView:AddMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	if self.cur_index == 1 then
		ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
		PlayerCtrl.Instance.view:Flush("bag_recycle")
	elseif self.cur_index == 2 then
		ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_battle)
	elseif self.cur_index == 3 then
		ViewManager.Instance:Open(ViewName.Activity, TabIndex.activity_kuafu_battle)
	elseif self.cur_index == 4 then
		ViewManager.Instance:Open(ViewName.Boss,TabIndex.secret_boss)
	end
end

function ExchangeView:ChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ExchangeView:InitToggle()
	self.toggle_list = {}
	for i=1, 4 do
		self.toggle_list[i] = {}
		self.toggle_list[i].toggle_content = self:FindObj("toggle_content_" .. i)
		self.toggle_list[i].toggle_text = self:FindVariable("toggle_text_" .. i)
		local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, ExchangeView.SHOW_EXCHANGE_TAB[i],GameVoManager.Instance:GetMainRoleVo().prof)
		if #item_id_list == 0 or i > #ExchangeView.SHOW_EXCHANGE_TAB then
			self.toggle_list[i].toggle_content:SetActive(false)
		else
			if i == 1 then
				self.toggle_list[i].toggle_text:SetValue(Language.Common.MoJing)
			elseif i == 2 then
				self.toggle_list[i].toggle_text:SetValue(Language.Common.ShengWang)
			elseif i == 3 then
				self.toggle_list[i].toggle_text:SetValue(Language.Common.RongYao)
			elseif i == 4 then
				self.toggle_list[i].toggle_text:SetValue(Language.Common.MiZang)
			end
		end
	end
end

function ExchangeView:OnToggleClick(i,is_click)
	if is_click then
		local bundle, asset = ResPath.GetExchangeNewIcon(icon_img_path[i])
		if self.exchange_content_view then
			self.exchange_content_view:SetCurrentPriceType(ExchangeView.SHOW_EXCHANGE_TAB[i])
			self.exchange_content_view:OnFlushListView()
			self.exchange_content_view:FlushCoin()
		end
		self.top_img_path:SetAsset(bundle, asset)
		local score_type = i
		ExchangeData.Instance:SetClickState(i)

		RemindManager.Instance:Fire(RemindName.Echange)
		self:FlushTab(i)

		if i == 1 then
			self.show_index = TabIndex.exchange_mojing
		elseif i == 2 then
			self.show_index = TabIndex.exchange_shengwang
		elseif i == 3 then
			score_type = EXCHANGE_PRICE_TYPE.RONGYAO
			self.show_index = TabIndex.exchange_rongyao
		elseif score_type == 4 then
			score_type = EXCHANGE_PRICE_TYPE.BOSSSCORE
			self.show_index = TabIndex.exchange_mizang
		end
		self.top_text_path:SetValue(self:FormatMoney(ExchangeData.Instance:GetCurrentScore(score_type)))
		self.cur_index = i
	end
end

function ExchangeView:OnFlush(param_t)
	local score_type = self.cur_index
	if score_type == 3 then
		score_type = EXCHANGE_PRICE_TYPE.RONGYAO
	elseif score_type == 4 then
		score_type = EXCHANGE_PRICE_TYPE.BOSSSCORE
	end
	-- local type = self.cur_index == 3 and EXCHANGE_PRICE_TYPE.RONGYAO or self.cur_index
	self.top_text_path:SetValue(self:FormatMoney(ExchangeData.Instance:GetCurrentScore(score_type)))
	self.gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
	self.bind_gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
	for k, v in pairs(param_t) do
		if k == "flush_list_view" then
			if self.exchange_content_view then
				self.exchange_content_view:OnFlushListView()
			end
		elseif k == "xianshi_tab" then
			self:InitTabXianShi()
		end
	end
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

function ExchangeView:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE and status == ACTIVITY_STATUS.CLOSE then
		self:DisAbleTabXianShi()
		if self.exchange_content_view then
			self.exchange_content_view:OnFlushListView()
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