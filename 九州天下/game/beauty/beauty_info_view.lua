require("game/beauty/beauty_item")
BeautyInfoView = BeautyInfoView or BaseClass(BaseRender)

local BEAUTY_MODEL_COUNT = 7
local BEAUTY_IDLE1 = 0 		--待机站立
local BEAUTY_IDLE2 = 2		--待机蹲下

local BEAUTY_INDEX2 = 2		-- 第二和第三个美人是蹲下的
local BEAUTY_INDEX3 = 3
function BeautyInfoView:__init(instance)
	self.cur_select = 1
	self.name_cell_list = {}
end

function BeautyInfoView:__delete()
	if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end

	if self.name_cell_list then	
		for k,v in pairs(self.name_cell_list) do
			v:DeleteMe()
		end
		self.name_cell_list = {}
	end

	if self.chuchang_quest then
		GlobalTimerQuest:CancelQuest(self.chuchang_quest)
		self.chuchang_quest = nil
	end
end

function BeautyInfoView:LoadCallBack(instance)
	self:ListenEvent("OnActivateBtn", BindTool.Bind(self.OnActivateHandle, self))
	self:ListenEvent("OnButtonHelp", BindTool.Bind(self.OnButtonHelpHandle, self))
	--self:ListenEvent("OnHeti", BindTool.Bind(self.OnHeti, self))
	self:ListenEvent("OnChanBtn", BindTool.Bind(self.OnChanBtn, self))
	self:ListenEvent("OnHetiAttr", BindTool.Bind(self.OnHetiAttr, self))
	self:ListenEvent("OnLeftBtn", BindTool.Bind(self.OnLeftBtn, self))
	self:ListenEvent("OnRightBtn", BindTool.Bind(self.OnRightBtn, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickOpenAttr", BindTool.Bind(self.OnClickOpenAttr, self))
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))
	self:ListenEvent("OnBattleBtn", BindTool.Bind(self.OnBattleHandle, self))

	self.btn_active = self:FindObj("BtnActive")
	--self.btn_fit = self:FindObj("BtnFit")
	self.left_arrow = self:FindObj("LeftArrow")
	self.right_arrow = self:FindObj("RightArrow")
	self.btn_text = self:FindVariable("BtnText")
	self.display = self:FindObj("DIsplay")
	self.show_activate_btn = self:FindVariable("ShowActivateBtn")
	self.activate_text = self:FindVariable("ActivateText")
	self.chan_text = self:FindVariable("ChanText")
	self.show_active_red = self:FindVariable("ActiveRed")
	self.show_chan_red = self:FindVariable("ChanMianRed")
	--self.show_heti_red = self:FindVariable("HeTiRed")
	self.show_huahua_red = self:FindVariable("ShowHuanHuaRed")
	self.str_get_way = self:FindVariable("StrGetWay")
	self.battle_btn_gray = self:FindVariable("BattleBtnGray")
	self.battle_btn_text = self:FindObj("BattleBtnText")

	self.image_name = self:FindVariable("ImageName")
	self.level = self:FindVariable("Level")

	self.list_data = BeautyData.Instance:GetBeautyInfo()
	self.name_list = self:FindObj("NameList")
	local name_view_delegate = self.name_list.list_simple_delegate
	--生成数量
	name_view_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	--刷新函数
	name_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNameListView, self)

	self:InitModel()
	self:FlushArrowState()
end

function BeautyInfoView:RefreshNameListView(cell, data_index, cell_index)
	data_index = data_index + 1
	local icon_cell = self.name_cell_list[cell]
	if icon_cell == nil then
		icon_cell = BeautyNameCell.New(cell.gameObject)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		icon_cell:SetToggleGroup(self.name_list.toggle_group, data_index == self.cur_select)
		self.name_cell_list[cell] = icon_cell
	end
	local data = self.list_data[data_index]
	icon_cell:SetIndex(data_index)
	icon_cell:SetRedFlag(BeautyData.Instance:GetIsCanActiveOrChan(data_index, nil, true))
	icon_cell:SetData(data)
end

function BeautyInfoView:OnBattleHandle()
	if BeautyData.Instance:GetCurBattleBeauty() == self.cur_select - 1 then return end
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_CALL, self.cur_select - 1)
end

function BeautyInfoView:OnClickGetWay()
	if self.cur_select == nil then
		return
	end

	local active_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_select - 1)
	local way_cfg = BeautyData.Instance:GetWayById(active_info.get_way)

	if way_cfg ~= nil and way_cfg.open_panel ~= nil then
		local tab = Split(way_cfg.open_panel, "#")
		if tab ~= nil and tab[1] ~= nil then
			if tab[1] == ViewName.VipView then
				VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
				ViewManager.Instance:Open(ViewName.VipView)				
			else
				if tab[1] == ViewName.SevenLoginGiftView or tab[1] == ViewName.QiTianChongZhiView then	
					if TimeCtrl.Instance:GetCurOpenServerDay() > 7 and SevenLoginGiftData.Instance:GetSevenLoginRemind() == 0 then	
						TipsCtrl.Instance:ShowSystemMsg(Language.Common.ActivityFinish)	
					else
						ViewManager.Instance:Open(tab[1], TabIndex[tab[2]] or 0)
					end
				else
					ViewManager.Instance:Open(tab[1], TabIndex[tab[2]] or 0)
				end			
			end
		end
	end
end

function BeautyInfoView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data or self.cur_select == cell.index then return end
	self.cur_select = cell.index
	self:FlushArrowState()
	self:Flush()
end

-- 初始化模型处理函数
function BeautyInfoView:InitModel()
	if nil == self.model_display then
		self.model_display = RoleModel.New("beauty_panel")
		self.model_display:SetDisplay(self.display.ui3d_display)
	end
end

function BeautyInfoView:UpModelState()
	local active_info = BeautyData.Instance:GetBeautyActiveInfo(self.cur_select - 1)
	local beaut_info = BeautyData.Instance:GetBeautyInfo()[self.cur_select]

	if self.str_get_way ~= nil then
		local way_cfg = BeautyData.Instance:GetWayById(active_info.get_way)
		if way_cfg.discription ~= nil then
			self.str_get_way:SetValue(string.format(Language.Beaut.GetWayLabel, way_cfg.discription))
		end
	end

	if self.model_display and self.list_data[self.cur_select] and beaut_info and active_info then
		local bundle, asset = ResPath.GetGoddessNotLModel(active_info.model)
		self.model_display:SetMainAsset(bundle, asset, function ()
			self.model_display:ShowAttachPoint(AttachPoint.Weapon, beaut_info.is_active_shenwu == 1)
			self.model_display:ShowAttachPoint(AttachPoint.Weapon2, beaut_info.is_active_shenwu == 1)
			self.model_display:SetLayer(4, 1.0)
			self.model_display:SetTrigger("chuchang", false)

		end)
		self.model_display:ResetRotation()
	end
end

function BeautyInfoView:ChuchangChangeTime()
	if self.model_display then
		self.model_display:ShowAttachPoint(AttachPoint.BuffMiddle, false)
		self.model_display:ShowAttachPoint(AttachPoint.BuffMiddle, true)
	end
end

function BeautyInfoView:FlushBtnRed()
	if self.cur_select == nil then
		return
	end

	if self.show_active_red ~= nil then
		self.show_active_red:SetValue(BeautyData.Instance:GetIsCanActiveOrChan(self.cur_select, true))
	end

	if self.show_chan_red ~= nil then
		self.show_chan_red:SetValue(BeautyData.Instance:GetIsCanActiveOrChan(self.cur_select, false))
	end

	-- if self.show_heti_red ~= nil then
	-- 	self.show_heti_red:SetValue(BeautyData.Instance:GetIsHeTi(self.cur_select))
	-- end

	if self.show_huahua_red ~= nil then
		self.show_huahua_red:SetValue(BeautyData.Instance:GetIsShowHuanHuaRed())
	end

	local all_info = BeautyData.Instance:GetBeautyInfo()
	if all_info == nil or next(all_info) == nil then
		return
	end

	local info = all_info[self.cur_select]
	if info == nil or next(info) == nil then
		return
	end
	
	local battle_flag = info.is_active == 1 and BeautyData.Instance:GetCurBattleBeauty() ~= self.cur_select - 1
	self.battle_btn_gray:SetValue(battle_flag)
	if self.battle_btn_text ~= nil then
		self.battle_btn_text.grayscale.GrayScale = battle_flag and 0 or 255
	end
	self.btn_text:SetValue(battle_flag and Language.Beaut.BeautBattle or Language.Beaut.BeautYichuzhan)
end

function BeautyInfoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "beauty_index" and v.item_id and v.item_id > 0 then
			local seq = BeautyData.Instance:GetBeautyactiveCfg(v.item_id)
			self.cur_select = seq + 1
			self:FlushArrowState()
		end
	end
	self:UpActivateInfo()
	self:FlushBtnRed()

	if self.name_list ~= nil then
		self.name_list.scroller:ReloadData(0)
	end
end

function BeautyInfoView:OnActivateHandle()
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_ACTIVE, self.cur_select - 1)
end

function BeautyInfoView:UpActivateInfo()
	local info = BeautyData.Instance:GetBeautyInfo()
	if info[self.cur_select] then
		local bundle, asset = ResPath.GetBeautyNameRes(self.cur_select)
		self.image_name:SetAsset(bundle, asset)
		self.level:SetValue("LV." .. info[self.cur_select].grade)
		self.show_activate_btn:SetValue(info[self.cur_select].is_active == 1)
		self:ItemDataChangeCallback()
	end
end

function BeautyInfoView:ItemDataChangeCallback()
	local activate_cfg = BeautyData.Instance:GetBeautyActiveInfo(self.cur_select - 1)
	if activate_cfg and activate_cfg.active_item_id > 0 then
		local has_stuff = ItemData.Instance:GetItemNumInBagById(activate_cfg.active_item_id)
		self.activate_text:SetValue(BeautyData.Instance:GetNameStuffNumStr(ItemData.Instance:GetItemName(activate_cfg.active_item_id), has_stuff, 1))
		self.chan_text:SetValue(BeautyData.Instance:GetNameStuffNumStr(ItemData.Instance:GetItemName(activate_cfg.active_item_id), has_stuff, 1))
	
		if self.name_list ~= nil then
			self.name_list.scroller:ReloadData(0)
		end

		self:FlushBtnRed()
	end
end

function BeautyInfoView:OnButtonHelpHandle()
	TipsCtrl.Instance:ShowHelpTipView(195)
end

function BeautyInfoView:OnHetiAttr()
	BeautyCtrl.Instance:HetiAttrView()
end

function BeautyInfoView:OnLeftBtn()
	self.cur_select = self.cur_select - 1
	if self.cur_select <= 1 then
		self.cur_select = 1
	end
	self:FlushArrowState()
end

function BeautyInfoView:OnRightBtn()
	self.cur_select = self.cur_select + 1
	if self.cur_select >= BEAUTY_MODEL_COUNT then
		self.cur_select = BEAUTY_MODEL_COUNT
	end
	self:FlushArrowState()
end

function BeautyInfoView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.BeautyHuanhua)
end

function BeautyInfoView:OnClickOpenAttr()
	--BeautyCtrl.Instance:OpenAttrView()
	local attr_data = BeautyData.Instance:GetBeautyAllCapAttr()
	TipsCtrl.Instance:OpenGeneralView(attr_data)
end

function BeautyInfoView:FlushArrowState()
	self.left_arrow:SetActive(self.cur_select > 1)
	self.right_arrow:SetActive(self.cur_select < BEAUTY_MODEL_COUNT)

	for k,v in pairs(self.name_cell_list) do
		v:SetToggleOn(self.cur_select)
	end
	self:UpModelState()
	self:UpActivateInfo()
end

function BeautyInfoView:OnChanBtn()
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_EXCHANGE_ITEM, self.cur_select - 1)
end

function BeautyInfoView:GetBtnActive()
	return self.btn_active
end

-- function BeautyInfoView:GetBtnFit()
-- 	return self.btn_fit
-- end