require("game/beauty/beauty_item")
BeautyHuanhuaView = BeautyHuanhuaView or BaseClass(BaseView)

local BEAUTY_HUANHUA_COUNT = 8
function BeautyHuanhuaView:__init()
	self.ui_config = {"uis/views/beauty","BeautyHuanHuaView"}
	self:SetMaskBg()
	self.play_audio = true
	self.activate_shenwu = false
	self.cur_seq = -1
	self.cur_select = 1
	self.all_num = 0
	self.all_data = {}
end

function BeautyHuanhuaView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickActivate", BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("OnClickShenwuBtn", BindTool.Bind(self.OnClickShenwu, self))
	self:ListenEvent("OnLeftBtn", BindTool.Bind(self.OnLeftBtn, self))
	self:ListenEvent("OnRightBtn", BindTool.Bind(self.OnRightBtn, self))

	self.left_arrow = self:FindObj("LeftArrow")
	self.right_arrow = self:FindObj("RightArrow")
	self.gongji = self:FindVariable("GongJi")
	self.fangyu = self:FindVariable("FangYu")
	self.shengming = self:FindVariable("ShengMing")
	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.name = self:FindVariable("ZuoQiName")

	self.fight_power = self:FindVariable("FightPower")
	self.activate_text = self:FindVariable("ActivateText")

	self.pro_num = self:FindVariable("ActivateProNum")
	self.need_num = self:FindVariable("ExchangeNeedNum")
	self.current_level = self:FindVariable("CurrentLevel")
	self.show_level = self:FindVariable("ShowCurrentLevel")
	self.battle_btn_gray = self:FindVariable("BattleBtnGray")
	self.heti_attr = self:FindVariable("HeTiAttr")
	self.name_image = self:FindVariable("NameImage")

	self.show_shenwu_red = self:FindVariable("ShowShenwuRemind")
	self.show_heti_red = self:FindVariable("ShowHeTiRemind")
	self.show_btn_red = self:FindVariable("ShowBtnRemind")
	self.show_heti_label = self:FindVariable("ShowHeTiLabel")
	self.select_btn_gray = self:FindVariable("SelectBtnGray")
	self.select_text = self:FindVariable("SelectText")
	self:ListenEvent("OnClickSelect", BindTool.Bind(self.OnClickSelect, self))

	self.show_level:SetValue(true)
	
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	self.icon_cell_list = {}
	self.all_num, self.all_data = BeautyData.Instance:GetShowSpecialInfo()
	self.icon_list = self:FindObj("ListView")
	local list_view_delegate = self.icon_list.list_simple_delegate
	--生成数量
	list_view_delegate.NumberOfCellsDel = function()
		return self.all_num or 0
	end
	--刷新函数
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshIconListView, self)
	self.cur_data = self.all_data[1]

	self.display = self:FindObj("Display")
	self:Flush()
end

function BeautyHuanhuaView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end

	if self.icon_cell_list then
		for k,v in pairs(self.icon_cell_list) do
			v:DeleteMe()
		end
		self.icon_cell_list = {}
	end
	
	if self.quest then
		GlobalTimerQuest:CancelQuest(self.quest)
		self.quest = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.cur_seq = -1
	self.cur_select = 1
	self.gongji = nil
	self.fangyu = nil
	self.shengming = nil
	self.mingzhong = nil
	self.shanbi = nil
	self.name = nil
	self.fight_power = nil
	self.activate_text = nil
	self.pro_num = nil
	self.need_num = nil
	self.icon_list = nil
	self.display = nil
	self.show_level = nil
	self.current_level = nil
	self.battle_btn_gray = nil
	self.heti_attr = nil
	self.name_image = nil
	self.left_arrow = nil
	self.right_arrow = nil

	self.show_shenwu_red = nil
	self.show_heti_red = nil
	self.show_btn_red = nil
	self.show_heti_label = nil
	self.select_btn_gray = nil
	self.select_text = nil
end

function BeautyHuanhuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function BeautyHuanhuaView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function BeautyHuanhuaView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id ~= nil and BeautyData.Instance:CheckIsHuanHuaItem(item_id) then
		local now_num = BeautyData.Instance:GetShowSpecialInfo()
		--if self.all_num ~= now_num then
		self:Flush("all", {need_flush = true, now_num = now_num})
		--end
		-- self:FlushRed()
		-- self:Flush()
	end
end

function BeautyHuanhuaView:OnClickSelect()
	if self.all_data ~= nil and self.cur_select ~= nil and self.all_data[self.cur_select] ~= nil then
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_USE_HUANHUA, self.all_data[self.cur_select].seq)
	end
end

function BeautyHuanhuaView:FlushData()
	self:Flush("all", {need_flush = true})
end

function BeautyHuanhuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" and self:IsOpen() then
		self:FlushData()
	end
end

function BeautyHuanhuaView:OnLeftBtn()
	self.cur_select = self.cur_select - 1
	if self.cur_select <= 1 then
		self.cur_select = 1
	end
	self:Flush()
end

function BeautyHuanhuaView:OnRightBtn()
	self.cur_select = self.cur_select + 1
	if self.cur_select >= BEAUTY_HUANHUA_COUNT then
		self.cur_select = BEAUTY_HUANHUA_COUNT
	end
	self:Flush()
end

function BeautyHuanhuaView:FlushArrowState()
	self.left_arrow:SetActive(self.cur_select > 1)
	local max_num = self.all_num ~= 0 and self.all_num or BEAUTY_HUANHUA_COUNT 
	self.right_arrow:SetActive(self.cur_select < max_num)
	self.cur_data = self.all_data[self.cur_select]
	BeautyUpIconCell.SelectHuanhuaIndex = self.cur_select
	self.icon_list.scroller:RefreshActiveCellViews()
	self:UpData()
	self:FlushModel()
end

-- 初始化模型处理函数
function BeautyHuanhuaView:FlushModel()
	if nil == self.model_display then
		self.model_display = RoleModel.New("common_huanhua_panel", 1000)
		self.model_display:SetDisplay(self.display.ui3d_display)
	end

	if self.model_display and self.cur_data then
		if self.cur_seq == self.cur_data.seq then return end
		self.cur_seq = self.cur_data.seq
		local info = BeautyData.Instance:GetHuanhuaInfo(self.cur_data.seq)
		if info then
			self.activate_shenwu = info.is_active_shenwu == 1
		end
		local bundle, asset = ResPath.GetGoddessNotLModel(self.cur_data.model)
		self.model_display:SetMainAsset(bundle, asset, function ()
			self.model_display:ShowAttachPoint(AttachPoint.Weapon, self.activate_shenwu)
			self.model_display:ShowAttachPoint(AttachPoint.Weapon2, self.activate_shenwu)
			self.model_display:SetLayer(4, 1.0)
			self.model_display:SetTrigger("chuchang", false)
		end)
		self.model_display:SetTrigger(SceneObjAnimator.Atk1)

		local bundle, asset = ResPath.GetBeautyNameRes("huan_name_" .. self.cur_seq)
		self.name_image:SetAsset(bundle, asset)
	end
	if self.quest then
		GlobalTimerQuest:CancelQuest(self.quest)
		self.quest = nil
	end
	self.quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeTime, self), 15)
end

function BeautyHuanhuaView:ChangeTime()
	local animator_list = {"attack1", "attack2"}
	local index = GameMath.Rand(1, 2)
	if self.model_display then
		self.model_display:SetTrigger(animator_list[index])
	end
end

function BeautyHuanhuaView:RefreshIconListView(cell, data_index, cell_index)
	local huanhua_info = BeautyData.Instance:GetBeautyHuanhuaCfg(data_index)
	data_index = data_index + 1
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = BeautyUpIconCell.New(cell.gameObject)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		icon_cell:SetToggleGroup(self.icon_list.toggle_group)
		self.icon_cell_list[data_index] = icon_cell
	end
	local data = self.all_data[data_index]
	icon_cell:SetIndex(data_index)
	icon_cell:SetRedFlag(BeautyData.Instance:GetHuanHuaIsCanActiveOrChan(data.seq + 1) or BeautyData.Instance:GetIsCanActiveShenWu(data_index, true))
	icon_cell:SetData(data)
end

function BeautyHuanhuaView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_select = cell.index
	self:Flush()
end

function BeautyHuanhuaView:OnClickClose()
	self:Close()
end

function BeautyHuanhuaView:OnClickActivate()
	if nil ~= self.cur_data and nil ~= self.cur_data.seq then
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_HUANHUA, self.cur_data.seq)
	end		
end

function BeautyHuanhuaView:OnClickShenwu()
	ViewManager.Instance:Open(ViewName.BeautyShenwu, nil, "beauty_huanhua", {seq = self.cur_data.seq})
end

function BeautyHuanhuaView:OnFlush(param_t)
	local old_num = self.all_num
	self.all_num, self.all_data = BeautyData.Instance:GetShowSpecialInfo()
	local is_flush = true
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.item_id then
				self.cur_data = BeautyData.Instance:GetHuanhuaCurSeq(v.item_id)
				if self.cur_data then
					self.cur_select = self.cur_data.show_order
				end
			end
		end

		if v.need_flush then
			if self.all_data ~= nil and self.cur_select ~= nil and self.all_data[self.cur_select] == nil then
				self.cur_select = 1
				self.cur_data = self.all_data[self.cur_select]
			end
			self.icon_list.scroller:ReloadData(0)
			is_flush = false
		else
			is_flush = false
			self.icon_list.scroller:RefreshActiveCellViews()
		end
	end
	self:FlushArrowState()

	if self.all_data == nil or self.cur_select == nil or self.all_data[self.cur_select] == nil then
		return
	end

	if is_flush or old_num ~= self.all_num then
		self.icon_list.scroller:ReloadData(0)
	end

	if self.show_heti_label ~= nil and self.all_data[self.cur_select] ~= nil then
		local info_data = BeautyData.Instance:GetHuanhuaInfo(self.all_data[self.cur_select].seq)
		self.show_heti_label:SetValue(info_data ~= nil and info_data.is_active == 1)
	end

	local mainr_role = GameVoManager.Instance:GetMainRoleVo()
	local select_seq = BeautyData.Instance:GetHuanHuaSeq()
	--local is_select = mainr_role.beauty_used_huanhua_seq >= 0 and self.all_data[self.cur_select].seq == mainr_role.beauty_used_huanhua_seq
	local is_select = select_seq == self.all_data[self.cur_select].seq
	self.select_btn_gray:SetValue(true)
	self.select_text:SetValue(is_select and Language.Beaut.CancleHuanHua or Language.Beaut.BeautHuanhua)
end

function BeautyHuanhuaView:UpData()
	if self.cur_data == nil then
		return
	end
	
	local info = BeautyData.Instance:GetHuanhuaInfo(self.cur_data.seq)
	if nil == info then return end
	local is_max_level = false
	local max_level_cfg = BeautyData.Instance:GetHuanhuaMaxLevel(info.seq)
	if max_level_cfg then
		is_max_level = info.level >= max_level_cfg.level
	end
	local attr_cfg = BeautyData.Instance:GetCurHuanhuaAttrCfg(info.seq, info.level > 0 and info.level or 1)
	if self.cur_data and attr_cfg then
		self.gongji:SetValue(attr_cfg.gongji)
		self.fangyu:SetValue(attr_cfg.fangyu)
		self.shengming:SetValue(attr_cfg.maxhp)
		-- self.mingzhong:SetValue(attr_cfg.ming_zhong)
		-- self.shanbi:SetValue(attr_cfg.shan_bi)
		self.heti_attr:SetValue(BeautyData.Instance:GetHeTiAttr(info.seq + 100))
		self.item_cell:SetData({item_id = self.cur_data.need_item})
		self.name:SetValue(self.cur_data.name)

		local add_item_num = 1
		local has_stuff = ItemData.Instance:GetItemNumInBagById(self.cur_data.need_item)
		local stuff_color = has_stuff < add_item_num and "ff0000" or "00931f"
		self.pro_num:SetValue(string.format("<color=#%s>%d</color>", stuff_color, has_stuff))
		self.need_num:SetValue(add_item_num)
		local power = CommonDataManager.GetCapabilityCalculation(attr_cfg)
		self.fight_power:SetValue(power)
	end
	self.battle_btn_gray:SetValue(not is_max_level)
	self.current_level:SetValue(info.level)
	self.activate_text:SetValue(is_max_level and Language.Common.MaxLv or (info.level >= 1 and Language.Common.Up or Language.Common.Activate))

	self:FlushRed()
end

function BeautyHuanhuaView:FlushRed()
	if self.cur_data == nil or self.cur_data.seq == nil then
		return
	end

	if self.show_shenwu_red ~= nil then
		self.show_shenwu_red:SetValue(BeautyData.Instance:GetIsCanActiveShenWu(self.cur_data.seq + 1, true))
	end

	if self.show_heti_red ~= nil then
		self.show_heti_red:SetValue(BeautyData.Instance:CanHuanHuaHeTi(self.cur_data.seq + 1))
	end

	if self.show_btn_red ~= nil then
		self.show_btn_red:SetValue(BeautyData.Instance:GetHuanHuaIsCanActiveOrChan(self.cur_data.seq + 1))
	end
end