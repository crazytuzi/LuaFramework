-- 许愿池页面
CarnivalPoolPage = CarnivalPoolPage or BaseClass()

function CarnivalPoolPage:__init()
	self.view = nil
end

function CarnivalPoolPage:__delete()
	self:RemoveEvent()
	if self.gift_info_list then
		self.gift_info_list:DeleteMe()
		self.gift_info_list = nil
	end
	if self.reward_cell then
		for k, v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	self.view = nil
end

function CarnivalPoolPage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:CreateRewardCell()
	self:OnSignInDataChange()
end

function CarnivalPoolPage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_list_super_group_purchase
	self.grid_list = BaseGrid.New()
	local bag_cells = 30
	local data = CarnivalData.Instance:getCarnivalPool()
	if data then
		bag_cells= #data.Items
	end
	local grid_node = self.grid_list:CreateCells({w = ph.w, h = ph.h, cell_count = bag_cells, col = 6, row = 2, itemRender = CarnivalGoldPoolItem, direction = ScrollDir.Horizontal, ui_config = self.view.ph_list.ph_super_group_buy_item})
	grid_node:setPosition(ph.x, ph.y)
	grid_node:setAnchorPoint(0.5, 0.5)
	self.view.node_t_list.page8.node:addChild(grid_node, 999)
	self.cur_index = self.grid_list:GetCurPageIndex()
	self.max_page_idx = self.grid_list:GetPageCount()
	self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
end

function CarnivalPoolPage:OnClickMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function CarnivalPoolPage:FlushBtn()
	local page = math.ceil(self.ItemNum/12)
	if self.ItemNum>12 then
		self.view.node_t_list.btn_super_group_left.node:setVisible(self.cur_index ~= 1)
		self.view.node_t_list.btn_super_group_right.node:setVisible((self.cur_index ~= page) or (math.ceil(self.ItemNum/12)>self.cur_index))
	else
		self.view.node_t_list.btn_super_group_left.node:setVisible(false)
		self.view.node_t_list.btn_super_group_right.node:setVisible(false)
	end
end

function CarnivalPoolPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	if self.ItemNum <= 12 then
		self.grid_list:ChangeToPage(1)
	end
	if 	math.ceil(self.ItemNum/12)<page_index then
		self.grid_list:ChangeToPage(page_index-1)
		self.cur_index = page_index -1
	else
		self.cur_index = page_index		
	end
	self:FlushBtn()
end

function CarnivalPoolPage:OnClickMoveRightHandler()
	if self.cur_index < self.max_page_idx then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function CarnivalPoolPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_left.node, BindTool.Bind(self.OnClickMoveLeftHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_right.node, BindTool.Bind(self.OnClickMoveRightHandler, self), true)
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)
	-- self.sign_in_data_event = GlobalEventSystem:Bind(WelfareEventType.SIGN_IN_DATA_CHANGE, BindTool.Bind(self.OnSignInDataChange, self))
end

function CarnivalPoolPage:RemoveEvent()
	if self.item_list_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		self.item_list_event = nil
	end
end

function CarnivalPoolPage:ItemDataListChangeCallback()
	self:UpdateData()
end

function CarnivalPoolPage:CreateRewardCell()
	self.reward_cell = {}
	local pos_x, pos_y = self.view.node_t_list.img_exp.node:getPosition()
	self.view.node_t_list.img_exp.node:setVisible(false)
	for i = 1, 3 do
		local cell = BaseCell.New()
		cell:SetPosition(pos_x+(i-1)*85, pos_y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		self.view.node_t_list.page8.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

--更新视图界面
function CarnivalPoolPage:UpdateData(data)
	if self.grid_list then
		local data = CarnivalData.Instance:getCarnivalPool()
		if data then
			local TempData = {}
			self.ItemNum = 0
			local had_num
			for i,v in ipairs(data.Items) do
				had_num = ItemData.Instance:GetItemNumInBagById(v.id,nil)
				if had_num>0 then
					TempData[self.ItemNum] ={item_id = v.id,num= had_num,is_bind = 0,index = i}
					self.ItemNum = self.ItemNum+1
				end
			end
			self.grid_list:SetDataList(TempData)
			local open_days =  OtherData.Instance:GetOpenServerDays()
			if data and data.startDay and data.endDay then
				local time_util = TimeUtil.CONST_3600*TimeUtil.CONST_24
				local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
				local ta_server = os.date("*t", server_time)
				server_time = server_time-(ta_server.hour*TimeUtil.CONST_3600+ta_server.min*TimeUtil.CONST_60+ta_server.sec)
				server_time = server_time-time_util*open_days
				server_time = server_time+time_util*data.startDay
				local format_time_begin = os.date("*t", server_time)

				if data.endDay > data.startDay then
					local left = data.endDay-data.startDay
					server_time= server_time+time_util*left
				end
				local format_time_end = os.date("*t", server_time)
				self.view.node_t_list.txt_time_common_pool.node:setString(format_time_begin.year.."/"..format_time_begin.month.."/"..format_time_begin.day.."-"..format_time_end.year.."/"..format_time_end.month.."/"..format_time_end.day)
			end
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_activity_common_pool.node,data.actDesc,20,cc.c3b(0xff, 0xff, 0xff))
			self:FlushBtn()
		end
	end
	if self.reward_cell then
		local data =  CarnivalData.Instance:getPoolData()
		if data then
			for i,v in ipairs(data) do
				if self.reward_cell[i] then
					self.reward_cell[i]:SetData({item_id = v.id, num = v.count, is_bind = 0})
				end
			end
		end
	end
end	

function CarnivalPoolPage:SelectItemCallBack(item)
	-- if item == nil or item:GetData() == nil then return end
	-- local data = item:GetData()
	-- local today_sign_state = WelfareData.Instance:GetTodaySignState()
	-- for k, v in pairs(self.grid_scroll:GetItems()) do
	-- end
end

function CarnivalPoolPage:OnSigninClicked()
	
end

function CarnivalPoolPage:OnSignInDataChange()

end

-- 狂欢许愿池活动选中出售Render
CarnivalGoldPoolItem = CarnivalGoldPoolItem or BaseClass(BaseRender)
function CarnivalGoldPoolItem:__init()

end

function CarnivalGoldPoolItem:__delete()
	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end
end

function CarnivalGoldPoolItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_group_buy.node, BindTool.Bind(self.BuyItem, self), true)
	self.node_tree.btn_group_buy.node:setVisible(false)
	local ph = self.ph_list.ph_chosen_item_cell
	self.chosen_item_cell = BaseCell.New()
	self.chosen_item_cell:SetPosition(ph.x, ph.y)
	self.chosen_item_cell:GetView():setVisible(false)
	self.chosen_item_cell:GetView():setAnchorPoint(0, 0)
	self.view:addChild(self.chosen_item_cell:GetView(), 100)

end

function CarnivalGoldPoolItem:OnFlush()
	if nil == self.data then return end
	if self.chosen_item_cell and self.data.item_id then
		self.chosen_item_cell:SetData({item_id= self.data.item_id,num =self.data.num,is_bind=self.data.is_bind})
		self.node_tree.btn_group_buy.node:setVisible(self.data and self.data.item_id and true or false)
		self.chosen_item_cell:GetView():setVisible(self.data and self.data.item_id and true or false)
	end
end

function CarnivalGoldPoolItem:CreateSelectEffect()

end

function CarnivalGoldPoolItem:BuyItem()
	if not self.data then return end
	if self.data and self.data.index then
		CarnivarCtrl.Instance:SendCarnivalPool(self.data.index)
	end
end