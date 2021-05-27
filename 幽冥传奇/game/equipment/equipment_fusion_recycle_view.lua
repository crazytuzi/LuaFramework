------------------------------------------------------------------
-- 锻造-融合-分解  配置:EquipForgingDecomCfg 请求接口:7, 58
------------------------------------------------------------------

EquipmentFusionRecycleView = EquipmentFusionRecycleView or BaseClass(BaseView)

EquipmentFusionRecycleView.quantity_limit = 0 -- 数量限制

function EquipmentFusionRecycleView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"equipment_ui_cfg", 5, {0}},
	}
end

function EquipmentFusionRecycleView:__delete()
end

--释放回调
function EquipmentFusionRecycleView:ReleaseCallBack()
	EquipmentFusionRecycleView.quantity_limit = 0
	self.item_id_list = {}
end

--加载回调
function EquipmentFusionRecycleView:LoadCallBack(index, loaded_times)
	local content_size = self.root_node:getContentSize()
	local x = content_size.width / 2
	local y = content_size.height - 45
	self:CreateTopTitle(ResPath.GetWord("word_equipment_fusion_recycle"), x, y)

	XUI.RichTextSetCenter(self.node_t_list["rich_consume"].node)

	self:CreateEquipList()
	self:CreateAwardList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

end

function EquipmentFusionRecycleView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function EquipmentFusionRecycleView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	EquipmentFusionRecycleView.quantity_limit = 0
	self.item_id_list = {}
end

--显示指数回调
function EquipmentFusionRecycleView:ShowIndexCallBack(index)
	self:FlushEquipList()

	self:Flush()
end

function EquipmentFusionRecycleView:OnFlush(param_list)
	self:FlushAwardListAndConsume()
end

----------视图函数----------

function EquipmentFusionRecycleView:CreateEquipList()
	local ph = self.ph_list["ph_equip_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_equip_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_fusion_recycle"].node
	local item_render = self.EquipItem
	local line_dis = ph_item.h + 2
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.FlushAwardListAndConsume, self))
	self.equip_list = grid_scroll
	self:AddObj("equip_list")
end

function EquipmentFusionRecycleView:CreateAwardList()
	local ph = self.ph_list["ph_award_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = {x = 0, y = 0, w = 80, h = 80,}
	local parent = self.node_t_list["layout_fusion_recycle"].node
	local item_render = BaseCell
	local line_dis = ph_item.w
	local direction = ScrollDir.Horizontal -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll.OnItemClickCallback = function()end -- 屏蔽 GridScroll 点击回调,避免点击物品打开tips时,出现选框
	self.award_list = grid_scroll
	self:AddObj("award_list")
end

function EquipmentFusionRecycleView:FlushEquipList()
	-- 获取背包中已融合的装备
	local bag_list = BagData.Instance:GetDataListSeries()
	local list = {}
	for series, item in pairs(bag_list) do
		if item.fusion_lv > 0 then
			table.insert(list, item)
		end
	end
	table.sort(list, function(a, b)
		local type_1 = EquipmentFusionData.GetEquipType(a.item_id)
		local type_2 = EquipmentFusionData.GetEquipType(b.item_id)
		if type_1 == type_2 then
			return a.fusion_lv > b.fusion_lv
		elseif a.fusion_lv > b.fusion_lv then
			return type_1 < type_2
		end
	end)

	-- 默认显示8个位置
	local count = 8 - #list
	for i = 1, count do
		table.insert(list, {})
	end
	self.equip_list:SetDataList(list)
	self.equip_list:JumpToTop()

	self:CancelEquipHook()
end

-- 刷新奖励列表和消耗
function EquipmentFusionRecycleView:FlushAwardListAndConsume()
	local list = {}
	local consumes_list = {}
	local virtual_consumes_list = {}

	local cfg = EquipForgingDecomCfg or {}
	local decom_cfg = cfg.DecomCfg or {}

	local items = self.equip_list:GetItems()
	for i, item in ipairs(items) do
		if item.hook then
			local equip_data = item:GetData()
			local item_id = equip_data.item_id
			local fusion_lv = equip_data.fusion_lv
			local award = {item_id = item_id, num = 1, is_bind = equip_data.is_bind, fusion_lv = fusion_lv - 1}
			table.insert(list, award)
			table.insert(list, award)

			-- 数量记录
			local cur_consumes = EquipmentFusionData.GetFusionRecycleCousumes(item_id, fusion_lv)
			BagData.ContinueRecordConsumesCount(cur_consumes, consumes_list, virtual_consumes_list)
		end
	end

	local text = ""
	if next(virtual_consumes_list) then
		local _type, count = next(virtual_consumes_list)
		local path = RoleData.GetMoneyTypeIconByAwardType(_type)
		local consume_count = BagData.GetConsumesCount(0, _type)
		local color = consume_count > count and COLORSTR.GREEN or COLORSTR.RED
		text = string.format("{image;%s}{color;%s;%s}/%s", path, color, CommonDataManager.ConverMoney(consume_count), CommonDataManager.ConverMoney(count))
	end
	local rich = self.node_t_list["rich_consume"].node
	RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()

	self.award_list:SetDataList(list)
	self.award_list:SetCenter()
end

----------视图函数end----------

function EquipmentFusionRecycleView:OnBtn()
	local series_list = {}
	local items = self.equip_list:GetItems()
	for i, item in ipairs(items) do
		if item.hook then
			local data = item:GetData() or {}
			local series = data.series
			if series then
				table.insert(series_list, series)
				if #series_list >= 20 then -- 服务端最多处理20个
					break
				end
			end
		end
	end

	if #series_list > 0 then
		EquipmentFusionCtrl.SendEquipmentFusionRecycleReq(series_list)
	end
end

-- 取消装备的勾选
function EquipmentFusionRecycleView:CancelEquipHook()
	local items = self.equip_list:GetItems()
	for i, item in ipairs(items) do
		item:CancelHook()
	end

	EquipmentFusionRecycleView.quantity_limit = 0
end

function EquipmentFusionRecycleView:OnBagItemChange(event)
	if self:IsOpen() then
		local need_flush = false
		for i, v in ipairs(event.GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST then
				need_flush = true
			else
				-- 监听融合属性大于0的装备
				local item_data = v.data or {}
				if item_data.fusion_lv > 0 then
					need_flush = true
				end
			end

			if need_flush then
				self:FlushEquipList()
				self:Flush()
				break
			end
		end

	end
end

--------------------

----------------------------------------
-- 装备选择渲染
----------------------------------------

EquipmentFusionRecycleView.EquipItem = BaseClass(BaseRender)
local EquipItem = EquipmentFusionRecycleView.EquipItem
function EquipItem:__init()
	self.cell = nil
	self.hook = false
end

function EquipItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function EquipItem:CreateChild()
	BaseRender.CreateChild(self)
	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell = cell

	self.node_tree["layout_select"]["img_hook"].node:setVisible(false)
end

function EquipItem:OnFlush()
	if nil == self.data then return end
	self.cell:SetData(self.data)
	self.node_tree["layout_select"]["img_hook"].node:setVisible(self.hook)
end

function EquipItem:CreateSelectEffect()
	return
end

function EquipItem:OnClick()
	if nil == self.data or nil == next(self.data) then return end
	
	if self.hook == false then
		-- 勾选时, 判断数量不得大于等于20
		if EquipmentFusionRecycleView.quantity_limit >= 20 then
			local str = "最多选中20个"
			SysMsgCtrl.Instance:FloatingTopRightText(str)
			return
		else
			EquipmentFusionRecycleView.quantity_limit = EquipmentFusionRecycleView.quantity_limit + 1
		end
	else
		EquipmentFusionRecycleView.quantity_limit = EquipmentFusionRecycleView.quantity_limit - 1
	end


	self.hook = not self.hook
	self.node_tree["layout_select"]["img_hook"].node:setVisible(self.hook)

	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

-- 取消勾选
function EquipItem:CancelHook()
	self.hook = false

	if self.node_tree and self.node_tree["layout_select"] and self.node_tree["layout_select"]["img_hook"] then
		self.node_tree["layout_select"]["img_hook"].node:setVisible(self.hook)
	end
end
