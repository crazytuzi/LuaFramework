ActSpecialRebateView = ActSpecialRebateView or BaseClass(BaseView)

function ActSpecialRebateView:__init()
	self.ui_config = {"uis/views/actspecialrebate","ActSpecialRebateView"}
	self.play_audio = true
	self:SetMaskBg()
	self.cell_list = {}
	self.data_list = {}

	self.view_type = ACT_SPECIAL_REBATE_TYPE.FOOT
end

function ActSpecialRebateView:_delete()

end

function ActSpecialRebateView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo, self))
	self:ListenEvent("OnClickAct1", BindTool.Bind(self.OnClickAct, self, 1))
	self:ListenEvent("OnClickAct2", BindTool.Bind(self.OnClickAct, self, 2))
	self:ListenEvent("OnClickAct3", BindTool.Bind(self.OnClickAct, self, 3))

	self.title_res = self:FindVariable("TitleRes")
	self.tip_res = self:FindVariable("TipRes")
	self.show_through = self:FindVariable("ShowThrough")

	self.list_view = self:FindObj("List")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

end

function ActSpecialRebateView:ReleaseCallBack()
	if self.cell_list ~= nil then
		 for k,v in pairs(self.cell_list) do
		 	if v ~= nil then
		 		v:DeleteMe()
		 	end
		 end

		 self.cell_list = {}
	end

	if self.through_cell ~= nil then
		self.through_cell:DeleteMe()
		self.through_cell = nil
	end

	self.title_res = nil
	self.tip_res = nil
	self.show_through = nil
	self.list_view = nil
end

function ActSpecialRebateView:SetViewType(view_type)
	self.view_type = view_type or ACT_SPECIAL_REBATE_TYPE.FOOT
end

function ActSpecialRebateView:OpenCallBack()
	local act_id = ActSpecialRebateData.ACT_TYPE[self.view_type]
	if act_id then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(act_id, RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO)
	end
end

function ActSpecialRebateView:CloseCallBack()
	self.view_type = ACT_SPECIAL_REBATE_TYPE.FOOT
end

function ActSpecialRebateView:OnClickClose()
	self:Close()
end

function ActSpecialRebateView:OnClickGo()
	local view, tab
	if self.view_type == ACT_SPECIAL_REBATE_TYPE.FOOT then
		view = ViewName.Advance
		tab = TabIndex.shengong_jinjie
	else
		view = ViewName.DressUp
		if self.view_type == ACT_SPECIAL_REBATE_TYPE.HEAD then
			tab = TabIndex.headwear
		elseif self.view_type == ACT_SPECIAL_REBATE_TYPE.WAIST then
			tab = TabIndex.waist
		elseif self.view_type == ACT_SPECIAL_REBATE_TYPE.FACE then
			tab = TabIndex.mask
		elseif self.view_type == ACT_SPECIAL_REBATE_TYPE.ARM then
			tab = TabIndex.kirin_arm
		elseif self.view_type == ACT_SPECIAL_REBATE_TYPE.BEAD then
			tab = TabIndex.bead
		elseif self.view_type == ACT_SPECIAL_REBATE_TYPE.TREASURE then
			tab = TabIndex.fabao
		end
	end

	ViewManager.Instance:Open(view, tab)
end

function ActSpecialRebateView:OnClickAct(act_type)
	if act_type == nil then
		return
	end

	local tab = nil
	local is_can = false
	local view_name = nil
	if act_type == 1 then
		is_can = #KaiFuChargeData.Instance:GetDiscountOpenIndex() > 0
		tab = TabIndex.kaifu_discount
		view_name = ViewName.KaiFuChargeView
	elseif act_type == 2 then
		local data = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
		if data ~= nil and data.status ~= ACTIVITY_STATUS.CLOSE  then
			is_can = true
			view_name = ViewName.ZhuangZhuangLe
		end
	elseif act_type == 3 then
		is_can = next(KaiFuChargeData.Instance:GetFenQiCfg())
		tab = TabIndex.kaifu_rising_star
		view_name = ViewName.KaiFuChargeView
	end

	if not is_can then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	if view_name ~= nil then
		ViewManager.Instance:Open(view_name, tab)
	end
end

function ActSpecialRebateView:GetNumberOfCells()
	local num = 0
	for k,v in pairs(self.data_list) do
		num = num + 1
	end

	return num
end

function ActSpecialRebateView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = SpeRebateListRender.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	if self.data_list[data_index + 1] ~= nil then
		group_cell:SetData(self.data_list[data_index + 1])
	end
end

function ActSpecialRebateView:FlushThrough(is_show, data)
	-- if is_show and self.through_cell == nil then
	-- 	self.through_cell = SpeRebateThroughRender.New(self:FindObj("Through"))
	-- end

	-- if self.through_cell ~= nil then
	-- 	self.through_cell:SetData(data)
	-- end

	-- if self.list_view ~= nil then
	-- 	local trans = self.list_view.transform
	-- 	local rect = trans:GetComponent(typeof(UnityEngine.RectTransform))
	-- 	rect.sizeDelta = Vector2(415, 470)
	-- end

	-- if self.show_through ~= nil then
	-- 	self.show_through:SetValue(true)
	-- end
end

function ActSpecialRebateView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "view_type" then
			self.view_type = v.view_type
		elseif k == "flush_view" then
			if v.view_type == nil or self.view_type ~= v.view_type then
				return
			end
		end
	end

	if self.title_res ~= nil then
		local boundl, asset = ResPath.GetSpecialRebate("img_act_title_" .. self.view_type)
		self.title_res:SetAsset(boundl, asset)
	end

	if self.tip_res ~= nil then
		local boundl, asset = ResPath.GetSpecialRebate("img_act_tip_" .. self.view_type)
		self.tip_res:SetAsset(boundl, asset)
	end

	local through_cfg
	self.data_list, through_cfg = ActSpecialRebateData.Instance:GetActCfgByViewType(self.view_type)

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end

	--self:FlushThrough(true, through_cfg)
end


---------------------------------------------------------------------------------
SpeRebateThroughRender = SpeRebateThroughRender or BaseClass(BaseCell)

function SpeRebateThroughRender:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))

	self.grade_str = self:FindVariable("Grade")
	self.btn_str = self:FindVariable("BtnStr")

	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
end

function SpeRebateThroughRender:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpeRebateThroughRender:OnClickBuy()
	if self.data == nil or next(self.data) == nil then
		return
	end

	ActSpecialRebateCtrl.Instance:SendUpgradeCardBuyReq(self.data.related_activity_s, self.data.item_id)
end

function SpeRebateThroughRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.item_cell ~= nil then
		self.item_cell:SetData({item_id = self.data.item_id})
	end

	if self.grade_str ~= nil then
		self.grade_str:SetValue(string.format(Language.ActSpecialRebate.GradeStr, self.data.show_grade or 0))
	end

	if self.btn_str ~= nil then
		self.btn_str:SetValue(string.format(Language.ActSpecialRebate.BtnBuyStr, self.data.is_buy or 0))
	end
end

---------------------------------------------------------------------------------
SpeRebateListRender = SpeRebateListRender or BaseClass(BaseCell)

function SpeRebateListRender:__init()
	self.title_res = self:FindVariable("Title")
	self.is_can_get = self:FindVariable("CanGet")
	self.is_get = self:FindVariable("IsGet")
	self.is_show_red = self:FindVariable("IsShowRed")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))

	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
end

function SpeRebateListRender:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpeRebateListRender:OnClickGet()
	if self.data == nil or next(self.data) == nil then
		return
	end

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.data.act_id, RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end

function SpeRebateListRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.item_cell ~= nil then
		self.item_cell:SetData(self.data.reward_item)
	end

	local str_tab = Language.ActSpecialRebate
	if self.title_res ~= nil then
		local need_grade = self.data.need_grade or 0
		--服务端默认一开始是1阶
		need_grade = need_grade + 10
		local grade = math.floor(need_grade / 10)
		local star =  math.floor(need_grade % 10)
		local str = ""
		if star > 0 then
			str = string.format(str_tab.TitleStarStr, str_tab.ActName[self.data.view_type or 1] or "", grade, star)
		else
			str = string.format(str_tab.TitleStr, str_tab.ActName[self.data.view_type or 1] or "", grade)
		end

		self.title_res:SetValue(str)
	end

	if self.is_can_get ~= nil and self.data.is_can then
		self.is_can_get:SetValue(self.data.is_can and self.data.is_can == 1)
	end

	if self.is_get ~= nil and self.data.is_get then
		self.is_get:SetValue(self.data.is_get and self.data.is_get == 1)
	end

	if self.is_show_red ~= nil then
		local is_can = self.data.is_can and self.data.is_can == 1
		local is_get = self.data.is_get and self.data.is_get == 0
		self.is_show_red:SetValue(is_can and is_get)
	end
end