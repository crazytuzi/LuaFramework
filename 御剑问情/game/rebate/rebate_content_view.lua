RebateContentView = RebateContentView or BaseClass(BaseRender)

function RebateContentView:__init(instance)
	RebateContentView.Instance = self
	self.invest_btn = self:FindObj("invest_btn")
	self:ListenEvent("go_click", BindTool.Bind(self.OnGoClick, self))
	self.item_list = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	local item_info_list = RebateData.Instance:GetGiftInfoList()
	for i=1,3 do
		-- local handler = function()
		-- 	local close_call_back = function()
		-- 		self:CancelHighLight()
		-- 	end
		-- 	self.item_list[i]:ShowHighLight(true)
		-- 	TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		-- end
		self.item_list[i] = ItemCell.New(self:FindObj("item_" .. i))
		-- self.item_list[i]:ListenClick(handler)
		self.item_list[i]:SetData(item_info_list[i])

		self.item_name_list[i] = self:FindVariable("item_name_" .. i)
		self.item_name_list[i]:SetValue(Language.Rebate.ItemName[i])
		self.item_desc_list[i] = self:FindVariable("item_dec_" .. i)
		self.item_desc_list[i]:SetValue(Language.Rebate.ItemDesc[i])
	end

	self.invest_btn.button.interactable = RebateCtrl.Instance.is_buy
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("rebate_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	local data = RebateData.Instance:GetBaiBeiItemCfg()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local res_id = RebateData.Instance:GetFashionResId(main_role_vo.prof .. main_role_vo.sex, data.index, SHIZHUANG_TYPE.BODY)
	local weapon_res_id = RebateData.Instance:GetFashionResId(main_role_vo.prof .. main_role_vo.sex, data.index, SHIZHUANG_TYPE.WUQI)

	if main_role_vo.prof == GameEnum.ROLE_PROF_3 then
		local weapon_param_t = Split(weapon_res_id, ",")
		self.model:SetWeaponResid(weapon_param_t[1])
		self.model:SetWeapon2Resid(weapon_param_t[2])
	else
		self.model:SetWeaponResid(weapon_res_id)
	end

	self.model:SetMainAsset(ResPath.GetRoleModel(res_id))
end

function RebateContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.item_name_list = {}
	self.item_desc_list = {}
end

function RebateContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function RebateContentView:OnGoClick()
	local price = RebateData.Instance:GetBaiBeiItemCfg().baibeifanli_price
	local level_limit = RebateData.Instance:GetBaiBeiItemCfg().baibeifanli_level_limit
	local role_money = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	local func = function ()
		if role_money >= price then
			if role_level >= level_limit then
				if bags_grid_num >= 4 then
					RebateCtrl.Instance:SendBaiBeiFanLiBuy()
					self.invest_btn.button.interactable = false
					RebateCtrl.Instance.is_buy = false
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
				end
			else
				TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.BuyNeedLevle, level_limit))
			end
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.RebateTips, price))
end

function RebateContentView:SetModelState()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.prof == GameEnum.ROLE_PROF_2 and main_role_vo.sex == 0 then
		self.model:ResetRotation()
		return
	end
	local state_name = "fight"
	if main_role_vo.prof == GameEnum.ROLE_PROF_1 then
		state_name = "status"
	end
	-- self.model:SetBool(state_name, true)
	self.model:ResetRotation()
end
