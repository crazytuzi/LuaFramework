--------------------------------------------------------------------------
-- MoLongInfoView 魔龙信息面板
--------------------------------------------------------------------------
MoLongInfoView = MoLongInfoView or BaseClass(BaseRender)

function MoLongInfoView:__init()
	MoLongInfoView.Instance = self

	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self:InitView()
end

function MoLongInfoView:__delete()
	MoLongInfoView.Instance = nil

	if self.left_info_view ~= nil then
		self.left_info_view:DeleteMe()
		self.left_info_view = nil
	end

	for i=1,3 do
		if self.item_list[i] ~= nil then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end

	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.MolongModel then
		self.MolongModel:DeleteMe()
		self.MolongModel = nil
	end
end

function MoLongInfoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	MoLongInfoView.Instance:FlushInfoView()
end

function MoLongInfoView:InitView()
	for i = 1, 5 do
		self["spirite_" .. i] = self:FindObj("spirite_" .. i)
	end

	self.juhun_bt = self:FindObj("juhun_bt")
	self.tips_text = self:FindObj("tips_text")
	self.label_juhun = self:FindObj("label_juhun")
	self.center_display = self:FindObj("CenterDisplay")

	self:ListenEvent("juhun_click", BindTool.Bind(self.JuHunBtnOnClick, self))
	self:ListenEvent("help_click", BindTool.Bind(self.HelpBtnOnClick, self))

	self.left_info_view = MoLongInfoLeftView.New(self:FindObj("molong_icon_content"), self)

	self.atk = self:FindVariable("atk")
	self.add_atk = self:FindVariable("add_atk")

	self.def = self:FindVariable("def")
	self.add_def = self:FindVariable("add_def")

	self.hp = self:FindVariable("hp")
	self.add_hp = self:FindVariable("add_hp")

	self.hit = self:FindVariable("hit")
	self.add_hit = self:FindVariable("add_hit")

	self.flash = self:FindVariable("flash")
	self.add_flash = self:FindVariable("add_flash")

	self.fight = self:FindVariable("fight")
	self.add_fight = self:FindVariable("add_fight")

	self.juhun_text = self:FindVariable("juhun_text")
	self.is_maxlevel = self:FindVariable("is_maxlevel")

	self.ball_level_1 = self:FindVariable("ball_level_01")
	self.ball_level_2 = self:FindVariable("ball_level_02")
	self.ball_level_3 = self:FindVariable("ball_level_03")
	self.ball_level_4 = self:FindVariable("ball_level_04")
	self.ball_level_5 = self:FindVariable("ball_level_05")

	self.set_next_visible = self:FindVariable("SetNextVisible")
	self.all_level = self:FindVariable("all_level")
	self.is_balltips = self:FindVariable("is_balltips")

	self.ball_redpoint_list = {}
	for i=1,5 do
		self.ball_redpoint_list[i] = self:FindVariable("ball_redpoint_0"..i)
	end

	for i=1,5 do
		self:ListenEvent("ball0"..i.."_click", BindTool.Bind2(self.BallClick, self, i))
	end

	self.ball_seq = 1
	self.select_yuhun_index = 1

	-- 初始化道具
	self.item_list = {}
	for i=1,3 do
		local data = {}
		local item_cell = NeedGridItem.New(self:FindObj("item_" .. i))
		item_cell:SetData(data)
		table.insert(self.item_list, item_cell)
	end

	self:InitMolongModel()
	self:FlushMolongModel()
end

function MoLongInfoView:FlushRedPoint()
	local is_show = false
	for j=1,5 do
		local level = MoLongData.Instance:GetLevelByIndex(j)
		local level_sprite_list = MoLongData.Instance:GetSpiritLevelListByindex(j)
		for i=1,5 do
			if MoLongData.Instance:IsCanUpLevelSprite(j,i) and level >= level_sprite_list[i] then
				if level > 5 then
					break
				end
				is_show = true
				MoLongView.Instance:MoLongShowRedPoint(is_show)
				return
			end
		end
	end

	MoLongView.Instance:MoLongShowRedPoint(is_show)
end

function MoLongInfoView:FlushMolongModel()
	local res_id = MoLongData.Instance:GetMolongModelBySeq(self.select_yuhun_index - 1)
	local bubble, asset = ResPath.GetNpcModel(res_id)
	self.MolongModel:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.NPC], tonumber(asset))
	self.MolongModel:SetMainAsset(bubble, asset)
end

function MoLongInfoView:InitMolongModel()
	if not self.MolongModel then
		self.MolongModel = RoleModel.New()
		self.MolongModel:SetDisplay(self.center_display.ui3d_display)
	end
end

-- 按顺时针刷新到下一个可以聚魂的球上
function MoLongInfoView:GotoNextMoHun()
	local level = MoLongData.Instance:GetLevelByIndex(self.select_yuhun_index)
	local level_sprite_list = MoLongData.Instance:GetSpiritLevelListByindex(self.select_yuhun_index)
	for i=1,5 do
		if MoLongData.Instance:IsCanUpLevelSprite(self.select_yuhun_index,i) and level >= level_sprite_list[i] then
			self.ball_seq = i
			break
		end
	end

	self:FlushSpiritView()
end

function MoLongInfoView:HelpBtnOnClick()
	local tips_id = 80  -- 魔龙信息
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MoLongInfoView:BallClick(i)
	if i == self.ball_seq then
		return
	end

	self.ball_seq = i
	self:FlushInfo()
end

function MoLongInfoView:SetShowRedPoint(i,is_show)
	self.ball_redpoint_list[i]:SetValue(is_show)
end

function MoLongInfoView:JuHunBtnOnClick()
	if self.select_yuhun_index == 0 or self.ball_seq == 0 then
		return
	end
	MoLongCtrl.Instance:SendMitamaOperaReq(MITAMA_REQ_TYPE.MITAMA_REQ_TYPE_UPGRADE, self.select_yuhun_index - 1, self.ball_seq - 1)
end

function MoLongInfoView:GetYuHunIndex()
	return self.select_yuhun_index
end

function MoLongInfoView:SetYuHunIndex(index)
	self.select_yuhun_index = index
	self.ball_seq = 1
end

function MoLongInfoView:FlushInfo()
	local yuhun_index = self.select_yuhun_index
	local ball_index = self.ball_seq
	if yuhun_index == 0 or ball_index == 0 then
		return
	end

	local attr_list = MoLongData.Instance:GetYuHunAttrByIndex(yuhun_index)
	self.atk:SetValue(attr_list.gong_ji)
	self.def:SetValue(attr_list.fang_yu)
	self.hp:SetValue(attr_list.max_hp)
	self.hit:SetValue(attr_list.ming_zhong)
	self.flash:SetValue(attr_list.shan_bi)

	local fight = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight:SetValue(fight)

	local star_level = MoLongData.Instance:GetStarLevelByIndex(yuhun_index, ball_index)

	local level = MoLongData.Instance:GetLevelByIndex(self.select_yuhun_index)
	if level < 6 then
		self.is_maxlevel:SetValue(false)
		self.juhun_bt.button.interactable = true
		self.juhun_text:SetValue(Language.YuHun.ButtonText[0])

		self.is_balltips:SetValue(false)
		self.tips_text:SetActive(true)
		self.set_next_visible:SetValue(true)

		if star_level > level then
			self.is_balltips:SetValue(true)
			self.juhun_bt.button.interactable = false
			self.juhun_text:SetValue(Language.YuHun.ButtonText[1])
			self.set_next_visible:SetValue(false)
		end
	else
		self.juhun_bt.button.interactable = false
		self.juhun_text:SetValue(Language.YuHun.ButtonText[1])
		self.label_juhun:SetActive(false)

		self.tips_text:SetActive(false)
		self.is_maxlevel:SetValue(true)

		self.set_next_visible:SetValue(false)
		for i = 1, 3 do
			if self.item_list[i] then
				self.item_list[i]:SetData({})
			end
		end
		return
	end

	local str = (level + 1) .. Language.Common.Ji
	self.all_level:SetValue(string.format("%s",ToColorStr(str, TEXT_COLOR.GREEN)))

	local add_attr_list = MoLongData.Instance:GetAddYuHunAttr(yuhun_index, star_level)
	self.add_atk:SetValue(add_attr_list.gong_ji)
	self.add_def:SetValue(add_attr_list.fang_yu)
	self.add_hp:SetValue(add_attr_list.max_hp)
	self.add_hit:SetValue(add_attr_list.ming_zhong)
	self.add_flash:SetValue(add_attr_list.shan_bi)

	local add_fight = CommonDataManager.GetCapabilityCalculation(add_attr_list,true)
	self.add_fight:SetValue(add_fight)

	local item_list = MoLongData.Instance:GetLevelUpItemList(yuhun_index, star_level)

	local item_num = 1
	for k, v in pairs(item_list) do
		self.item_list[item_num]:SetData(v)
		item_num = item_num + 1
	end
	for i = item_num, #self.item_list do
		if self.item_list[i] then
			self.item_list[i]:SetData({})
		end
	end
end

function MoLongInfoView:FlushSpiritView()
	if self.select_yuhun_index == 0 or self.ball_seq == 0 then
		return
	end

	self["spirite_" .. self.ball_seq].toggle.isOn = true

	local level = MoLongData.Instance:GetLevelByIndex(self.select_yuhun_index)
	local spirit_level_list = MoLongData.Instance:GetSpiritLevelListByindex(self.select_yuhun_index)
	if level < 6 then
		for k, v in ipairs(spirit_level_list) do
			if self["ball_level_" .. k] then
				self["ball_level_" .. k]:SetValue(v)
			end
		end
	else
		for k, v in ipairs(spirit_level_list) do
			if self["ball_level_" .. k] then
				self["ball_level_" .. k]:SetValue("MAX")
			end
		end
	end
end

function MoLongInfoView:FlushInfoView()
	self.left_info_view:FlushView()
	self.left_info_view:FlushRedPoint()
	self:FlushRedPoint()
	self:GotoNextMoHun()
	self:FlushInfo()
end

--------------------------------------------------------------------------
-- 左面板
--------------------------------------------------------------------------
MoLongInfoLeftView = MoLongInfoLeftView or BaseClass(BaseRender)
function MoLongInfoLeftView:__init(instance, info_view)
	self.info_view = info_view
	self.up_btn = self:FindObj("up_btn")
	self.down_btn = self:FindObj("down_btn")

	self:ListenEvent("up_btn", BindTool.Bind(self.UpBtnOnClick, self))
	self:ListenEvent("down_btn", BindTool.Bind(self.DownBtnOnClick, self))

	self.icon_cell_list = {}
	self.current_icon_index = 0
	self.is_select = false
	self:InitListView()

	self.current_icon_cell = nil
	self.index_list = {}
	self.up_btn:SetActive(true)

	self.yuhun_data = {}
end

function MoLongInfoLeftView:__delete()
	for k, v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = {}
end

function MoLongInfoLeftView:UpBtnOnClick()
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	self:BagJumpPage(0)
end

function MoLongInfoLeftView:DownBtnOnClick()
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	self:BagJumpPage(index + 2)
end

function MoLongInfoLeftView:BagJumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller_list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function MoLongInfoLeftView:SetBtnActive()
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index  = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	if index > 0 then
		self.up_btn:SetActive(true)
	else
		self.up_btn:SetActive(false)
	end
	if index < 1 then
		self.down_btn:SetActive(true)
	else
		self.down_btn:SetActive(false)
	end
end

--ListView逻辑
function MoLongInfoLeftView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	self.scroller_list_view.scroller.scrollerScrollingChanged = function ()
		self:SetBtnActive()
	end
	local list_delegate = self.scroller_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function MoLongInfoLeftView:GetNumberOfCells()
	return #self.yuhun_data or 0
end

function MoLongInfoLeftView:RefreshCell(cell, data_index)
	self:SetBtnActive()
	data_index = data_index + 1
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = MoLongIconCell.New(cell.gameObject, self)
		icon_cell.root_node.toggle.group = self.scroller_list_view.toggle_group
		self.icon_cell_list[cell] = icon_cell
	end
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(self.yuhun_data[data_index])
end

function MoLongInfoLeftView:GetYuHunIndex()
	return self.info_view:GetYuHunIndex()
end

function MoLongInfoLeftView:SetYuHunIndex(index)
	self.info_view:SetYuHunIndex(index)
end

function MoLongInfoLeftView:FlushMolongModel()
	self.info_view:FlushMolongModel()
end

function MoLongInfoLeftView:FlushSpiritView()
	self.info_view:FlushSpiritView()
end

function MoLongInfoLeftView:FlushInfo()
	self.info_view:FlushInfo()
end

function MoLongInfoLeftView:GotoNextMoHun()
	self.info_view:GotoNextMoHun()
end

function MoLongInfoLeftView:FlushRedPoint()
	if self.yuhun_data[self:GetYuHunIndex()].level >= 6 then
		for i=1,5 do
			self.info_view:SetShowRedPoint(i,false)
		end
		return
	end

	local level_sprite_list = MoLongData.Instance:GetSpiritLevelListByindex(self:GetYuHunIndex())
	for i=1,5 do
		if MoLongData.Instance:IsCanUpLevelSprite(self:GetYuHunIndex(),i) and self.yuhun_data[self:GetYuHunIndex()].level >= level_sprite_list[i] then
			self.info_view:SetShowRedPoint(i,true)
		else
			self.info_view:SetShowRedPoint(i,false)
		end
	end
end

function MoLongInfoLeftView:FlushView()
	local yuhun_data = MoLongData.Instance:GetMitamaInfo()
	self.yuhun_data = yuhun_data
	if self.scroller_list_view then
		self.scroller_list_view.scroller:RefreshActiveCellViews()
	end
end

--------------------------------------------------------------------------
--MoLongIconCell 	格子
--------------------------------------------------------------------------
MoLongIconCell = MoLongIconCell or BaseClass(BaseCell)

function MoLongIconCell:__init(instance, left_view)
	self.left_view = left_view

	self:IconInit()
	for i = 1, 6 do
		self["star" .. i] = self:FindObj("star" .. i)
	end
end

function MoLongIconCell:__delete()
	MoLongIconCell.Instance = nil
end

function MoLongIconCell:GetMoLongLevel()
	return self.data.level
end

function MoLongIconCell:IconInit()
	self.icon_sprite = self:FindObj("icon_sprite")
	self.icon_select = self:FindObj("icon_select")
	self.show_red_point = self:FindVariable("show_red_point")
	self.name = self:FindVariable("name")

	self:ListenEvent("icon_btn_click",BindTool.Bind(self.IconOnClick, self))
	-- self:ListenEvent("grey_image_click",BindTool.Bind(self.GreyImageOnClick, self))
	self.set_grey_image = self:FindObj("set_grey_image")
	self.lock = self:FindObj("lock")
end

function MoLongIconCell:IconOnClick()
	self.root_node.toggle.isOn = true
	local select_index = self.left_view:GetYuHunIndex()
	if select_index == self.index then
		return
	end
	self.left_view:SetYuHunIndex(self.index)
	self.left_view:FlushMolongModel()
	self.left_view:FlushRedPoint()
	self.left_view:GotoNextMoHun()
	self.left_view:FlushInfo()
end

function MoLongIconCell:ShowRedPoint(is_show)
	self.show_red_point:SetValue(is_show)
end

function MoLongIconCell:OnFlush()
	if not next(self.data) then return end
	local level = self.data.level

	if level > 0 then
		self.lock:SetActive(false)
	else
		self.lock:SetActive(true)
	end

	for i = 1, 6 do
		if i > level then
			self["star" .. i]:SetActive(false)
		else
			self["star" .. i]:SetActive(true)
		end
	end

	local is_show = false
	for i=1,5 do
		if MoLongData.Instance:IsCanUpLevelSprite(self.index,i) then
			is_show = true
		end
	end

	local info = MoLongData.Instance:GetMolongDataBySeq(self.index - 1)
	self.name:SetValue(info.name)
	if is_show and self.data.level < 6 then
		self:ShowRedPoint(true)
	else
		self:ShowRedPoint(false)
	end

	-- 刷新选中特效
	local select_index = self.left_view:GetYuHunIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

---------------------------------------------------------------------------- 消耗道具类
NeedGridItem = NeedGridItem or BaseClass(BaseRender)

function NeedGridItem:__init()
	self.item_num_text = self:FindVariable("number")
	self.item_cell = ItemCell.New(self:FindObj("ItemCell"))
end

function NeedGridItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function NeedGridItem:SetData(data)
	self.data = data
	if not next(self.data) then
		self:SetActive(false)
		return
	end
	self:SetActive(true)
	self.item_cell:ShowHighLight(false)

	local item_data = {}
	item_data.item_id = self.data.item_id
	item_data.num = 1
	item_data.is_bind = 0
	self.item_cell:SetData(item_data)

	local have_num = ItemData.Instance:GetItemNumInBagById(self.data.item_id)
	local item_num = self.data.num

	if have_num < item_num then
		self.item_num_text:SetValue(string.format("%s/%s", ToColorStr(have_num, TEXT_COLOR.RED), item_num))
	else
		self.item_num_text:SetValue(string.format("%s/%s", have_num, item_num))
	end
end