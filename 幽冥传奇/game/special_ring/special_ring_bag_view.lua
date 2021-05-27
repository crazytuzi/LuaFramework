--------------------------------------------------------
-- 特戒-背包  配置
--------------------------------------------------------

SpecialRingBagView = SpecialRingBagView or BaseClass(BaseView)

function SpecialRingBagView:__init()
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"special_ring_ui_cfg", 3, {0}},
	}

	self.bag_action_time = 0.3 -- 背包滑出的时间
	self.bag_width = 0 -- 背包宽度
end

function SpecialRingBagView:__delete()
end

--释放回调
function SpecialRingBagView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function SpecialRingBagView:LoadCallBack(index, loaded_times)
	self:InitSpecialRingBag()
	self:CreateBagList()

	self.node_t_list["scroll_bag"].node:addScrollEventListener(BindTool.Bind(self.BagScrollEvent, self))
	self.node_t_list["scroll_bag"].node:setTouchEnabled(false)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_bag"].node, BindTool.Bind(self.OnCloseHandler, self))
end

function SpecialRingBagView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingBagView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function SpecialRingBagView:ShowIndexCallBack(index)
	self:Flush()
end

function SpecialRingBagView:OnFlush()
	self:FlushBagList()
	local scroll_bag = self.node_t_list["scroll_bag"].node
	scroll_bag:setScorllDirection(ScrollDir.Horizontal)
	scroll_bag:scrollToTopRight(self.bag_action_time, false)
end

----------视图函数----------

function SpecialRingBagView:InitSpecialRingBag()
	local parent = self.node_t_list["scroll_bag"].node:getInnerContainer()
	local size = parent:getContentSize()
	self.bag_width = size.width - 44 -- 背包宽度
	parent:setContentWH(size.width + self.bag_width, size.height)

	self.bag_layout = XUI.CreateLayout(size.width, 0, self.bag_width, size.height)
	self.bag_layout:setAnchorPoint(0, 0)
	parent:addChild(self.bag_layout, 0)

	local img_bg = XUI.CreateImageViewScale9(0, 0, self.bag_width, size.height, ResPath.GetCommon("img9_284"), XUI.IS_PLIST, cc.rect(8, 8, 8, 7))
	img_bg:setAnchorPoint(0, 0)
	self.bag_layout:addChild(img_bg, 1)

	local img_bar = XUI.CreateImageView(self.bag_width / 2, size.height - 2, ResPath.GetCommon("bg_301"), XUI.IS_PLIST)
	img_bar:setAnchorPoint(0.5, 1)
	self.bag_layout:addChild(img_bar, 2)

	local text = XUI.CreateText(self.bag_width / 2, size.height - 10, 150, 30, cc.TEXT_ALIGNMENT_CENTER, "特戒背包")
	text:setColor(Str2C3b("e5d69c"))
	text:setAnchorPoint(0.5, 1)
	self.bag_layout:addChild(text, 3)

	local bar_size = img_bar:getContentSize()
	self.bag_y = size.height - bar_size.height - 4 -- bag_list的y坐标


	local bag_btn_layout = XUI.CreateLayout(size.width, 300, 0, 0) -- 高度是layout_bag_btn的中心点
	parent:addChild(bag_btn_layout, 0)

	local btn_bg = XUI.CreateImageView(0, 0, ResPath.GetSpecialRing("img_special_ring_16"), XUI.IS_PLIST)
	btn_bg:setAnchorPoint(1, 0.5)
	bag_btn_layout:addChild(btn_bg, 2)

	local btn_right = XUI.CreateImageView(-6, 0, ResPath.GetCommon("btn_right"), XUI.IS_PLIST)
	btn_right:setAnchorPoint(1, 0.5)
	bag_btn_layout:addChild(btn_right, 2)
end

function SpecialRingBagView:CreateBagList()
	local x, y = self.node_t_list["scroll_bag"].node:getPosition()
	local size = self.node_t_list["scroll_bag"].node:getContentSize()
	local w, h = size.width - 44, self.bag_y - 2

	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.bag_layout
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(0, self.bag_y, w, h, 4, ph_item.w, self.CellItem, ScrollDir.Vertical, false, ph_item)
	grid_scroll:GetView():setAnchorPoint(0, 1)
	parent:addChild(grid_scroll:GetView(), 99)
	self.bag_list = grid_scroll
	self:AddObj("bag_list")
end

local do_not_fusion = {} -- 不可投入的特戒 item_id,  用于投入副戒时的排序和灰化判断
function SpecialRingBagView:FlushBagList()
	local data_list = SpecialRingData.Instance:GetSpecialRingBag()

	local in_put_list = SpecialRingData.Instance:GetInPutList()
	local in_put_series_list = {}
	for i,v in pairs(in_put_list) do
		in_put_series_list[v.series] = 1
	end

	local list = {}
	for i,v in pairs(data_list) do
		if nil == in_put_series_list[v.series] then
			list[#list + 1] = v
		end
	end

	local in_put_type = SpecialRingData.Instance:GetInPutType()
	if in_put_type == 2 then
		-- 投入副戒时,设置 do_not_fusion 并排序
		do_not_fusion = {}

		-- 根据 "主戒的特戒类型" 和 "已融合的特戒类型" 从配置中获取不可融合的 item_id
		local item_id_index = SpecialRingHandleCfg and SpecialRingHandleCfg.ItemIdIndxs or {}
		local main_ring = in_put_list[1] or {}
		local item_cfg = ItemData.Instance:GetItemConfig(main_ring.item_id)
		local _type = item_cfg.useType or 0 -- 主戒的特戒类型
		local item_id_list = item_id_index[_type] and item_id_index[_type].ids or {}
		for i, item_id in ipairs(item_id_list) do
			do_not_fusion[item_id] = true
		end

		for i,v in ipairs(main_ring.special_ring or {}) do
			local _type = v.type or 0 -- 已融合的特戒类型
			local item_id_list2 = item_id_index[_type] and item_id_index[_type].ids or {}
			for i, item_id in ipairs(item_id_list2) do
				do_not_fusion[item_id] = true
			end
		end

		-- 排序需求：不可融合的特戒排后面
		table.sort(list, function(a, b)
			-- 同为"不可融合"或"可融合"时,item_id大的排前面
			if do_not_fusion[a.item_id] == do_not_fusion[b.item_id] then
				return a.item_id > b.item_id

			-- 特戒b 不可融合时, 特戒a 排前面 否则不变
			elseif do_not_fusion[b.item_id] then
				return true
			end
		end)
	else
		-- 背包排序
		table.sort(list, function(a, b)
			return a.item_id > b.item_id
		end)
	end

	-- 最少显示24个格子
	if #list < 24 then
		for i = 1, (24 - #list) do
			table.insert(list, {})
		end
	end

	self.bag_list:SetDataList(list)
	self.bag_list:JumpToTop()
end

function SpecialRingBagView:BagScrollEvent(scroll, event_type, x, y)
	self.event_type = event_type
	if event_type == 5 then
		local x, y = scroll:getInnerContainer():getPosition()
		self.node_t_list["scroll_bag"].node:setScorllDirection(ScrollDir.Vertical)
		if x == 0 then
			SpecialRingBagView.super.Close(self)
		end
	end
end

-- 重写 BaseView 的 Close
function SpecialRingBagView:Close()
	local scroll_bag = self.node_t_list["scroll_bag"]
	if scroll_bag then
		local size = scroll_bag.node:getContentSize()
		scroll_bag.node:setScorllDirection(ScrollDir.Horizontal)
		scroll_bag.node:scrollToTopLeft(self.bag_action_time, false)
	else
		SpecialRingBagView.super.Close(self)
	end
end

-- 重写 BaseView 的 OnCloseHandler
function SpecialRingBagView:OnCloseHandler()
	-- 背包正在滑出时,屏蔽点空白关闭背包,避免连点
	if self.event_type == 4 then return end
	self:Close()
end

----------end----------

----------------------------------------
-- 项目渲染命名
----------------------------------------
SpecialRingBagView.CellItem = BaseClass(BaseRender)
local CellItem = SpecialRingBagView.CellItem
function CellItem:__init()
	self.item_cell = nil
end

function CellItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function CellItem:CreateChild()
	BaseRender.CreateChild(self)

	local cell = BaseCell.New()
	cell:SetItemTipFrom(EquipTip.FROM_SPECIAL_RING_BAG)
	cell:SetCfgEffVis(false)
	self.view:addChild(cell:GetView(), 1)
	self.item_cell = cell
end

function CellItem:OnFlush()
	if nil == self.data then return end
	self.item_cell:SetData(self.data)

	-- 投入副戒时,不可投入的特戒灰化
	local in_put_type = SpecialRingData.Instance:GetInPutType()
	if in_put_type == 2 then
		local item_id = self.data.item_id or 0
		local bool = do_not_fusion[self.data.item_id]
		self.item_cell:MakeGray(bool)
	else
		self.item_cell:MakeGray(false)
	end
end

function CellItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

--------------------
