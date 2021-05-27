-- 影翼合成界面

WingView = WingView or BaseClass(XuiBaseView)

function WingView:InitWingCompound()

	XUI.AddClickEventListener(self.node_t_list.btn_breakup.node, BindTool.Bind1(self.OnBreakWingUp, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compound.node, BindTool.Bind1(self.OnWingCompound, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_img_tip.node, BindTool.Bind1(self.OpenShowTipDesc, self), true)
	

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagDataChange, self))--监听背包变化
	self:InitCompound()

	self.btn_vis = false
	self.com_data = {}
end

function WingView:DeletCompound()
	if self.wing_bag_gird ~= nil then
		self.wing_bag_gird:DeleteMe()
		self.wing_bag_gird = nil
	end

	if nil ~= self.cl_cell then
		self.cl_cell:DeleteMe()
		self.cl_cell = nil
	end

	if nil ~= self.cl_cell2 then
		self.cl_cell2:DeleteMe()
		self.cl_cell2 = nil
	end

	if nil ~= self.hc_cell then
		self.hc_cell:DeleteMe()
		self.hc_cell = nil
	end
end

function WingView:OnBreakWingUp()
	self:ChangeToIndex(TabIndex.wing_wing)
end

function WingView:BagDataChange()
	self:ItemCompoundFlush()
end

function WingView:OpenShowTipDesc( ... )
	DescTip.Instance:SetContent(Language.DescTip.YingWingConent, Language.DescTip.YingWingTitle)
end

function WingView:OnWingCompound()
	if next(self.com_data) then
		local compose_index, cur_compose_cfg = WingData.Instance:GetHcData()
		local cur_award = cur_compose_cfg.award and cur_compose_cfg.award[1] or {}
		local next_id = cur_award.id or 0
		local cur_consume = cur_compose_cfg.consume or {}
		local consume_1 = cur_consume[1] or {}
		local consume_2 = cur_consume[2] or {}
		local need_num_1 = consume_1.count or 1
		local need_num_2 = consume_2.count or 1
		local item_num_1 = BagData.Instance:GetItemNumInBagById(consume_1.id)
		local item_num_2 = BagData.GetConsumesCount(consume_2.id, consume_2.type)

		local index = WingData.Instance:GetCompodunIndex(next_id)
		if item_num_1 >= need_num_1 then
			if item_num_2 >= need_num_2 then
				if index ~= 0 then 
					BagCtrl.SendComposeItem(1, index, compose_index, 1)
				end
			else
				if nil == consume_2.type or consume_2.type == tagAwardType.qatEquipment then
					TipCtrl.Instance:OpenGetStuffTip(consume_2.id)
				else
					TipCtrl.Instance:OpenGetStuffTip(493)
				end
			end
		else
			TipCtrl.Instance:OpenGetStuffTip(consume_1.id)
		end
	end
end

function WingView:FlushCompound(param_t)
	if not param_t then return end
	for k, v in pairs(param_t) do
		if k == "all" then
			self:ItemCompoundFlush()
		elseif k == "move_cell" then
			self.cl_cell:SetData(nil)
			self.cl_cell2:SetData(nil)
			self.cl_cell2:SetLockIconVisible(true)
			self.hc_cell:SetData(nil)
			self.node_t_list.txt_need_num.node:setString("")
			XUI.SetButtonEnabled(self.node_t_list.btn_compound.node, false)
		end
	end
end

function WingView:ItemCompoundFlush()
	if self.wing_bag_gird then
		self.wing_bag_gird:SetDataList(WingData.Instance:WingBagItem())
	end

	local _, cur_compose_cfg = WingData.Instance:GetHcData()
	local cur_award = cur_compose_cfg.award and cur_compose_cfg.award[1] or {}
	local next_id = cur_award.id or 0
	local cur_consume = cur_compose_cfg.consume or {}
	local consume_1 = cur_consume[1] or {}
	local consume_2 = cur_consume[2] or {}
	local need_num_1 = consume_1.count or 1
	local need_num_2 = consume_2.count or 1
	local item_num_1 = BagData.Instance:GetItemNumInBagById(consume_1.id)
	local item_num_2 = BagData.GetConsumesCount(consume_2.id, consume_2.type)
	self.btn_vis = item_num_1 >= need_num_1
	self.com_data = cur_consume

	local txt_num = item_num_1 == 0 and "" or (item_num_1 .. "/" .. need_num_1)
	local color = self.btn_vis and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list.txt_need_num.node:setString(txt_num)
	self.node_t_list.txt_need_num.node:setColor(color)
	
	self.node_t_list.text_need_num2.node:setString("")
	local text = ""
	if consume_2.type and consume_2.type ~= tagAwardType.qatEquipment then
		local color = item_num_2 >= need_num_2 and COLORSTR.GREEN or COLORSTR.RED
		local gold_icon = "{image;res/xui/common/bind_gold.png;31,23}"
		text = string.format("%s{color;%s;%d}/%d", gold_icon, color, item_num_2, need_num_2)

		self.cl_cell2:SetData(nil)
		self.cl_cell2:SetLockIconVisible(true)
	else
		if consume_2.id then
			self.cl_cell2:SetData({item_id = consume_2.id, num = 1, bind_type = 0})
			self.cl_cell2:SetLockIconVisible(false)
			local txt_num = item_num_2 .. "/" .. need_num_2
			local color = item_num_2 >= need_num_2 and COLOR3B.GREEN or COLOR3B.RED
			self.node_t_list.text_need_num2.node:setString(txt_num)
			self.node_t_list.text_need_num2.node:setColor(color)
		else
			self.cl_cell2:SetData(nil)
			self.cl_cell2:SetLockIconVisible(true)
		end
	end
	local rich = self.node_t_list["rich_money"].node
	RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	XUI.RichTextSetCenter(rich)
	rich:refreshView()
	
	if next(cur_consume) then
		self.cl_cell:SetData({item_id = consume_1.id, num = 1, is_bind = 0})
		self.hc_cell:SetData({item_id = next_id, num = 1, is_bind = 0})
	else
		self.cl_cell:SetData(nil)
		self.hc_cell:SetData(nil)
	end

	XUI.SetButtonEnabled(self.node_t_list.btn_compound.node, next(cur_consume) ~= nil)
end

-- 初始化
function WingView:InitCompound()
	-- 影翼预览
	local ph_txt = self.ph_list.ph_yl_txt
	self.txt_wing_pre = RichTextUtil.CreateLinkText("影翼预览", 20, COLOR3B.GREEN)
	self.txt_wing_pre:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.txt_wing_pre, BindTool.Bind(self.OnOpenPreview, self), true)
	self.node_t_list.layout_compound.node:addChild(self.txt_wing_pre, 100)

	-- 获取材料
	local ph_map = self.ph_list.ph_go_map
	self.txt_wing_map = RichTextUtil.CreateLinkText("前 往", 20, COLOR3B.GREEN)
	self.txt_wing_map:setPosition(ph_map.x, ph_map.y)
	XUI.AddClickEventListener(self.txt_wing_map, BindTool.Bind(self.OnOpenNpc, self), true)
	self.node_t_list.layout_compound.node:addChild(self.txt_wing_map, 100)

	-- 神翼背包
	self.wing_bag_gird = BaseGrid.New()
	self.wing_bag_gird:SetGridName(GRID_TYPE_BAG) 		--来自重铸背包
	
	local ph_bag = self.ph_list.ph_wing_bag
	local grid_node = self.wing_bag_gird:CreateCells({w=ph_bag.w, h=ph_bag.h, cell_count=96, col=4, row=4})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_compound.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_bag.x, ph_bag.y)
	self.wing_bag_gird:SetSelectCallBack(BindTool.Bind2(self.SelectCellCallBack, self, EquipTip.FROM_WING_BAG))

	local ph_eff = self.ph_list.ph_hc_cell
	RenderUnit.CreateEffect(1078, self.node_t_list.layout_compound.node, 10, nil, nil, ph_eff.x, ph_eff.y)

	-- 材料显示
	if nil == self.cl_cell then
		local ph = self.ph_list.ph_cl_cell
		self.cl_cell = BaseCell.New()
		self.cl_cell:SetPosition(ph.x, ph.y)
		self.cl_cell:SetCellBgVis(false)
		self.cl_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_compound.node:addChild(self.cl_cell:GetView(), 103)
		
		self.cl_cell:SetItemTipFrom(EquipTip.FROM_WING_CL_SHOW)
		-- self.cl_cell:SetName(GRID_TYPE_BAG)
	end

	if nil == self.cl_cell2 then
		local ph = self.ph_list.ph_cl_cell2
		self.cl_cell2 = BaseCell.New()
		self.cl_cell2:SetPosition(ph.x, ph.y)
		self.cl_cell2:SetCellBgVis(false)
		self.cl_cell2:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_compound.node:addChild(self.cl_cell2:GetView(), 103)
		
		self.cl_cell2:SetItemTipFrom(EquipTip.FROM_WING_CL_SHOW)
		-- self.cl_cell:SetName(GRID_TYPE_BAG)
	end	

	-- 合成物品显示
	if nil == self.hc_cell then
		local ph = self.ph_list.ph_hc_cell
		self.hc_cell = BaseCell.New()
		self.hc_cell:SetPosition(ph.x, ph.y)
		self.hc_cell:SetCellBgVis(false)
		self.hc_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_compound.node:addChild(self.hc_cell:GetView(), 103)
		
		-- self.hc_cell:SetItemTipFrom(EquipTip.FROM_WING_CL_SHOW)
		-- self.hc_cell:SetName(GRID_TYPE_BAG)
	end	
end

function WingView:SelectCellCallBack(form_view, cell)
	if cell == nil then
		return
	end

	local cell_data = cell:GetData()
	if cell_data and next(cell_data) then
		TipCtrl.Instance:OpenItem(cell_data, form_view)				--打开tip,提示使用
	end
end

function WingView:OnOpenPreview()
	self:ChangeToIndex(TabIndex.wing_preview)
end

-- 点击跳转 激战BOSS-稀有-神威秘境
function WingView:OnOpenNpc()
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Rare.ShenWei)
	ViewManager.Instance:CloseViewByDef(ViewDef.Wing)
end