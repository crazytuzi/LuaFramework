SlotStrengthenView = SlotStrengthenView or BaseClass(SubView)

function SlotStrengthenView:__init()
	self.is_modal = true
	self.config_tab = {
		{"horoscope_ui_cfg", 4, {0}},
		{"horoscope_ui_cfg", 2, {0}},
		{"horoscope_ui_cfg", 7, {0}},
		 {"horoscope_ui_cfg", 1, {0}},
	}
	self.texture_path_list[1] = 'res/xui/bag.png'
	self.need_del_objs = {}
	--self.fight_power_view = nil
	--self.cell_list = {}
	self.select_cell = nil
	self.streng_data_list = {}
	self.progress = nil

	self.cur_select_num = 0
end

function SlotStrengthenView:__delete()
	self.cell_list = nil
	self.streng_data_list = nil
end

function SlotStrengthenView:LoadCallBack()
	self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99)
	self.need_del_objs[#self.need_del_objs + 1] = self.fight_power_view
	--self.node_t_list.img_title_1.node:SetString("槽位选择")
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnBtnClick, self))
	XUI.AddClickEventListener(self.node_t_list.btn_back.node, BindTool.Bind(self.OnBtnBack, self))
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind(self.OnBtnLeft, self))
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind(self.OnBtnRight, self))
	XUI.AddClickEventListener(self.node_t_list.btn_xh_ques.node, BindTool.Bind2(self.OpenTip, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagItemChangeCallBack, self))

	self:CreateSelectCell()
	self:CreateGridView()
	self:CreateBagView()
	self:CreateProg()

	EventProxy.New(HoroscopeData.Instance, self):AddEventListener(HoroscopeData.SLOT_STRENGTHEN_DATA_CHANGE, BindTool.Bind(self.FlushView, self))
end

function SlotStrengthenView:OpenTip()
	DescTip.Instance:SetContent(Language.DescTip.XinghunContent, Language.DescTip.XinghunTitle)
end

function SlotStrengthenView:FlushView(data)
	self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())
	self.use_level = data.new - data.old
	self:OnFlushProgresser()
end

function SlotStrengthenView:OnFlushProgresser( ... )
	if self.use_level < 0 then
		self:Flush()
		return 
	end
	self.use_level = self.use_level - 1
	self.progress:SetPercent(70, true)
	self.progress:SetTotalTime(0.2)
	if self.inner_eff_countdown_timer then
		GlobalTimerQuest:CancelQuest(self.inner_eff_countdown_timer)
		self.inner_eff_countdown_timer = nil
	end
	 self.inner_eff_countdown_timer = GlobalTimerQuest:AddDelayTimer(function ()
		 self.progress:SetPercent(100,true)
		  self:OnFlushProgresser()
	end, 0.2)
	 
end

function SlotStrengthenView:CreateGridView()
	local ph = self.ph_list.ph_list
	self.slot_grid = BaseGrid.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.slot_grid

	local grid_node = self.slot_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=12, col=4, row=1, itemRender = StrenthItemRender,
													direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item_render1})
	grid_node:setPosition(ph.x, ph.y)
	self.slot_grid:SetSelectCallBack(BindTool.Bind1(self.OnClickGrid, self))
	self.slot_grid:SelectCellByIndex(0)
	self.node_t_list.layout_list.node:addChild(grid_node, 100)
	self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())
end

function SlotStrengthenView:CreateBagView()
	local ph = self.ph_list.ph_bag
	self.bag_grid = BaseGrid.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.bag_grid
	local grid_node =  self.bag_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=110, col=4, row=3, itemRender = self.SelectItemRender,
													direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item})
	self.bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickRenderHandle, self))
	self.bag_grid:SetIsMultiSelect(true)

	self.node_t_list.layout_bag.node:addChild(grid_node, 100)

	local bag_constellation_list = BagData.Instance:GetBagConstellationAndStoneList()
	self.bag_grid:SetDataList(bag_constellation_list)
end

function SlotStrengthenView:CreateSelectCell()
	self.select_cell = BaseCell.New()
	self.need_del_objs[#self.need_del_objs + 1]= self.select_cell
	local ph = self.ph_list.ph_cell_select
	self.select_cell:SetPosition(ph.x, ph.y)
	self.node_t_list.layout_slot_strengthen.node:addChild(self.select_cell:GetView(), 100)
end

function SlotStrengthenView:CreateProg()
	self.progress = ProgressBar.New()
	self.need_del_objs[#self.need_del_objs + 1]= self.progress
	self.progress:SetView(self.node_t_list.prog9_val.node)
	self.progress:SetTotalTime(0.2)
	self.progress:SetPercent(0)
end

function SlotStrengthenView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}
end

function SlotStrengthenView:ShowIndexCallBack()
	self:Flush()
end


function SlotStrengthenView:OnFlush()
	local slot_info = HoroscopeData.Instance:GetSlotInfoDataList(self.select_index) or {}
	self.node_t_list.lbl_cur_level.node:setString(slot_info.level or 0)

	local item_list = self.bag_grid:GetAllCell()
	local old_exp = slot_info.exp or 0
	local exp = slot_info.exp or 0
	self.streng_data_list = {}
	for _, v in pairs(item_list) do
		local cell_data = v:GetData()
		if cell_data and 1 == cell_data.is_put_in then
			local consume_conf = HoroscopeData.GetConsumeConf(cell_data.item_id)
			exp = exp + cell_data.num / consume_conf.count * consume_conf.exp
			self.streng_data_list[#self.streng_data_list + 1] = {
				count = cell_data.num,
				series = cell_data.series,}
		end
	end
	
	local slot_info_conf = HoroscopeData.GetSlotInfoConfBySlot(self.select_index)

	local next_level = slot_info.level or 0
	local change_exp = exp
	for i = (slot_info.level or 0) + 1, #slot_info_conf do
		if change_exp < slot_info_conf[i].exp then
			next_level = i - 1
			break
		else
			next_level = i
			change_exp = change_exp - slot_info_conf[i].exp
		end
	end

	
	if next_level == (slot_info.level or 0)  and (slot_info.level or 0)  < #slot_info_conf then
		next_level = (slot_info.level or 0)  + 1
	end
	self.node_t_list.lbl_next_level.node:setString(next_level)
	self:OnFlushAttr((slot_info.level or 0) , next_level)

	local next_data = slot_info_conf[(slot_info.level or 0)  + 1] or {exp = 0}
	if not next_data or exp > next_data.exp then
		self.progress:SetPercent(100)
	else
		self.progress:SetPercent(exp / next_data.exp * 100)
	end
	local text = exp .. "/"..(next_data.exp)
	self.node_t_list.lbl_fire_prog.node:setString(text)

	local text = string.format("本次强化增加{wordcolor;00ff00;%d}经验", exp - old_exp)
	if slot_info.level ==  #slot_info_conf then
		text = "已达到最大强化等级" 
		self.node_t_list["btn_1"].node:setEnabled(false)
	else
		self.node_t_list["btn_1"].node:setEnabled(true)
	end
	RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, text)
	XUI.RichTextSetCenter(self.node_t_list.text_desc.node)
	self:FlushPower()
end

function SlotStrengthenView:FlushPower( ... )
	local data = HoroscopeData.Instance:GetAllConstellationData()
	local attr = {}
	for k, v in pairs(data) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		local strength_data =  HoroscopeData.Instance:GetSlotInfoDataList(config.stype)
		local strength_cfg = HoroscopeData.GetSlotAttrCfg(config.stype)
		local attrs = strength_data and strength_cfg[strength_data.level] and strength_cfg[strength_data.level].attrs or {}
		local attr1 = CommonDataManager.AddAttr(attrs, config.staitcAttrs)
		attr = CommonDataManager.AddAttr(attr, attr1) 
	end

	local suit_level = HoroscopeData.Instance:GetSuitId()
	local suit_config = SuitPlusConfig[8].list[suit_level]
	if suit_config then
		attr = CommonDataManager.AddAttr(attr, suit_config.attrs)
	end

	local power_value = CommonDataManager.GetAttrSetScore(attr)
	self.fight_power_view:SetNumber(power_value)
end


function SlotStrengthenView:BagItemChangeCallBack()
	local bag_constellation_list = BagData.Instance:GetBagConstellationAndStoneList()
	self.bag_grid:SetDataList(bag_constellation_list)

	self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())

	--强化消耗物品刷新界面
	self:OnFlush()
end
-- 刷新槽位属性视图
function SlotStrengthenView:OnFlushAttr(cur_level, next_level)
		local cur_attrs_data = HoroscopeData.GetAttrTypeValueFormat(self.select_index, cur_level)
		local next_attrs_data = HoroscopeData.GetAttrTypeValueFormat(self.select_index, next_level)

		-- 获取槽位属性,0级,显示"无"
		local text1 = ""
		if cur_level ~= 0 then
			local attr1 = {}
			for k, v in ipairs(cur_attrs_data) do
				attr1[#attr1 + 1] = v
			end
			local color = {
				type_str_color = "9c9181",
				value_str_color = "cdced0",
			}
			text1 = RoleData.Instance.FormatAttrContent(attr1, color)
		else
			text1 = Language.Common.No
		end

		-- 获取下一级的属性,满级时,显示"已是最高级了"
		local text2 = ""
	if next_level ~= 0 then
		if  next_level <= #(HoroscopeData.GetSlotAttrCfg(self.select_index)) then
			local attr2 = {}
			for k, v in ipairs(next_attrs_data) do
				attr2[#attr2 + 1] = v
			end
			local color = {
				type_str_color = "9c9181",
				value_str_color = "1ec449",
			}
			text2 = RoleData.Instance.FormatAttrContent(attr2,color)
		else
			text2 = Language.Common.AlreadyTopLv
			--self.node_t_list.rich_next_bonus.node:setPosition(580, 232)
			--self.node_t_list.layout_btn_1.node:setVisible(false)
		end
	else
		text2 = Language.Common.No
	end


		RichTextUtil.ParseRichText(self.node_t_list.rich_attr1.node, text1, 18, COLOR3B.DULL_GOLD)
		RichTextUtil.ParseRichText(self.node_t_list.rich_attr2.node, text2, 18, COLOR3B.DULL_GOLD)
		--self.node_t_list.rich_attr1.node:setVerticalSpace(-2) --设置垂直间隔
		--self.node_t_list.rich_attr2.node:setVerticalSpace(-2)
end

function SlotStrengthenView:OnBtnClick()
	if #self.streng_data_list <= 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Role.XinghunTip)
	else
		HoroscopeCtrl.StrengthenSlot(self.select_index, self.streng_data_list)

		-- 取消选中
		self.bag_grid:CancleSelectCurCell()
		local all_cell = self.bag_grid:GetAllCell()
		for k, cell in pairs(all_cell) do
			if cell:IsSelect() then
				cell:SetSelect(false)
			end

			local data = cell:GetData()
			if data then
				data.is_put_in = 0
			end
		end

		self.cur_select_num = 0
	end
end

function SlotStrengthenView:OnBtnBack()
	--ViewManager.Instance:CloseViewByDef(ViewDef.Role.Horoscope.SlotStrengthen)
	ViewManager.Instance:OpenViewByDef(ViewDef.Horoscope.HoroscopeView)

end

function SlotStrengthenView:OnClickGrid(cell)
	if nil == cell then
		return
	end
	self.select_index = cell.index
	local cell_data = cell:GetData()
	self.select_cell:SetData(cell_data)
	local bg_ta1 = ResPath.Horoscope("constellatory_bg_" .. self.select_index + 1) 
	if cell_data ~= nil then
		bg_ta1 = nil
	end
	local ui_config = { bg = ResPath.Horoscope("cell_bg"),
						bg_ta = bg_ta1}
	self.select_cell:SetSkinStyle(ui_config)

	self:Flush()
end

function SlotStrengthenView:OnClickRenderHandle(cell)
	if nil == cell then
		return
	end
	
	local cell_data = cell:GetData()
	if cell_data then
		if cell_data.is_put_in and cell_data.is_put_in == 1 then
			cell_data.is_put_in = 0
			self.cur_select_num = self.cur_select_num - 1
		else
			cell_data.is_put_in = 1
			self.cur_select_num = self.cur_select_num + 1
			if self.cur_select_num > 20 then
				cell:SetSelect(false)
				cell_data.is_put_in = 0
				self.cur_select_num = 20
				SysMsgCtrl.Instance:FloatingTopRightText("一次最多选中20个")
			end
		end

		cell:SetData(cell_data)
		cell:Flush()
		self:Flush()
	end
end

function SlotStrengthenView:OnBtnLeft()
	local idx = self.slot_grid:GetCurPageIndex()
	local count = self.slot_grid:GetPageCount()
	 idx = idx - 1
	if idx <= count then

		self.slot_grid:ChangeToPage(idx)
	end
end

function SlotStrengthenView:OnBtnRight()
	local idx = self.slot_grid:GetCurPageIndex()
	idx = idx + 1
	if idx > 0 then
		self.slot_grid:ChangeToPage(idx)
	end
end

StrenthItemRender = StrenthItemRender or BaseClass(BaseRender)
function StrenthItemRender:__init()
end

function StrenthItemRender:__delete()
end

function StrenthItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self:AddClickEventListener(self.click_callback)
end

function StrenthItemRender:OnFlush()
	self:Clear()
	if nil == self.data then
		return
	end

	self.node_tree.img_bg11.node:setVisible(false)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon = ResPath.GetItem(item_cfg.icon)
	self.node_tree.img_icon1.node:setVisible(true)
	self.node_tree.img_icon1.node:loadTexture(icon)
end

function StrenthItemRender:Clear()
	self.node_tree.text_strength_level1.node:setString("")
	self.node_tree.img_icon1.node:setVisible(false)
	self.node_tree.img_bg11.node:setVisible(true)
	self.node_tree.img_bg11.node:loadTexture(ResPath.Horoscope("constellatory_bg_" .. self.index + 1))

	local strenth_data =  HoroscopeData.Instance:GetSlotInfoDataList(self.index)
	local text = strenth_data and strenth_data.level > 0 and "+"..strenth_data.level or ""
	self.node_tree.text_strength_level1.node:setString(text)

	local showVis = HoroscopeData.Instance:GetSingleIsCanStrenth(strenth_data and strenth_data.level or 0, self.index)
	self.node_tree.img_red1.node:setVisible(showVis)
end


function StrenthItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2 - 1, size.height / 2 - 1,  ResPath.GetRole("img_select1"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
SlotStrengthenView.SelectItemRender = BaseClass(BaseRender)
local SelectItemRender = SlotStrengthenView.SelectItemRender
function SelectItemRender:__init()
	self.cell = nil
end

function SelectItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function SelectItemRender:CreateChild()
	BaseRender.CreateChild(self)

	local parent = self.view
	local ph = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local cell = BaseCell.New()
	cell:SetIsShowTips(false)
	cell:GetView():setTouchEnabled(false)
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell = cell

	self:AddClickEventListener(self.click_callback)
end

function SelectItemRender:OnFlush()
	self.cell:SetData(self.data)
end

function SelectItemRender:OnSelectChange(is_select)
	self.cell:MakeGray(is_select)
end

function SelectItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("img_gou"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

return SlotStrengthenView