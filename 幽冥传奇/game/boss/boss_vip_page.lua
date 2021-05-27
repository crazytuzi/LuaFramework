--VIP - BOSS

BossVipView = BossVipView or BaseClass()


function BossVipView:__init()
	self.select_index = 1
end	

function BossVipView:__delete()
	self:RemoveEvent()
	
	
	self.view = nil
	self.select_index = 1
end	

--初始化页面接口
function BossVipView:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:VipFubenInfoList()
	self.view.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind1(self.OnMoveLeftHandler, self))
	self.view.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind1(self.OnMoveRightHandler, self))
	self.view.node_t_list.btn_left.node:setVisible(false)
end	

--初始化事件
function BossVipView:InitEvent()
	
end

function BossVipView:VipFubenInfoList()
	if self.grid_list == nil then
		local num = VipBossData.Instance:GetVipBossData()
		self.grid_list = BaseGrid.New() 
		local ph_grid = self.view.ph_list.ph_list_boss
		local grid_node = self.grid_list:CreateCells({w = ph_grid.w + 20, h = ph_grid.h, itemRender = BossVipItem, direction = ScrollDir.Horizontal,cell_count = #num, col = 3, row = 1, ui_config = self.view.ph_list.ph_boss_item})
		grid_node:setPosition(ph_grid.x, ph_grid.y)
		-- grid_node:setAnchorPoint(0.5, 0.5)
		self.view.node_t_list.layout_vip_boss.node:addChild(grid_node, 999)
		self.cur_index = self.grid_list:GetCurPageIndex()
		self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	end

	if self.pri_grid_list == nil then
		local num = VipBossData.Instance:GetVipBossData()
		self.pri_grid_list = BaseGrid.New() 
		local ph_grid = self.view.ph_list.ph_list_boss
		local grid_node = self.pri_grid_list:CreateCells({w = ph_grid.w + 20, h = ph_grid.h, itemRender = BossVipItem, direction = ScrollDir.Horizontal,cell_count = 3, col = 3, row = 1, ui_config = self.view.ph_list.ph_boss_item})
		grid_node:setPosition(ph_grid.x, ph_grid.y)
		self.view.node_t_list.layout_vip_boss.node:addChild(grid_node, 999)
	end

	if self.tabbar == nil then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.view.node_t_list.layout_vip_boss.node, 15, 549,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.ChellengeKBoss.TabGrop, false, ResPath.GetCommon("toggle_104_normal"))
		self.tabbar:SetSpaceInterval(5)
		self.tabbar:SelectIndex(1)
		self.select_index = 1
	end
end

function BossVipView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index

	self:FlushBtn()
end

--移除事件
function BossVipView:RemoveEvent()
	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end
	if self.pri_grid_list then
		self.pri_grid_list:DeleteMe()
		self.pri_grid_list = nil 
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
end

--更新视图界面
function BossVipView:UpdateData(data)
	local boss =  BossData.Instance:getPriviBossData()
	local cur_data = {}
	for i,v in ipairs(boss) do
		cur_data[i-1] = v
	end
	self.pri_grid_list:SetDataList(cur_data)
	self.pri_grid_list:GetView():setVisible(self.select_index == 1)
	local data = VipBossData.Instance:GetVipBossData()
	local cfg_data = {}
	local index = 0
	for k, v in pairs(data) do
		cfg_data[index] = v
		index = index + 1
	end
	self.grid_list:SetDataList(cfg_data)
	self.grid_list:GetView():setVisible(self.select_index == 2)
	self.view.node_t_list.btn_left.node:setVisible(self.select_index == 2 and self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.select_index == 2 and  self.cur_index == 1)
	for i = 1, #Language.ChellengeKBoss.TabGrop do
		if i == 1 then
			local flag = BossData.Instance:getPriviBossRemind()
			self.tabbar:SetRemindByIndex(i, flag> 0)
		elseif i == 2 then
			local flag = VipBossData.Instance:GetVipBossRemind()
			self.tabbar:SetRemindByIndex(i, flag >0)
		end
	end
end	

function BossVipView:changeeBar()
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
end 

function BossVipView:SelectTabCallback(index)
	self.select_index = index
	self:UpdateData()
end

function BossVipView:FlushView(data)
end

function BossVipView:OnMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
	self.view.node_t_list.btn_left.node:setVisible(self.select_index == 2 and self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.select_index == 2 and  self.cur_index == 1)
end

function BossVipView:OnMoveRightHandler()
	local num = VipBossData.Instance:GetVipBossData()
	local page = math.ceil(#num/3)
	if self.cur_index < page then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
	self.view.node_t_list.btn_left.node:setVisible(self.select_index == 2 and self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.select_index == 2 and  self.cur_index == 1)
end

function BossVipView:FlushBtn()
	local num = GuildData.Instance:SetGuildDataList()
	local page = math.ceil(#num/3)
	self.view.node_t_list.btn_left.node:setVisible(self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.cur_index ~= page)
	self.view.node_t_list.btn_left.node:setVisible(self.select_index == 2 and self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.select_index == 2 and  self.cur_index == 1)
end

-- vip boss rend
BossVipItem = BossVipItem or BaseClass(BaseRender)
function BossVipItem:__init()

end

function BossVipItem:__delete()
	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end

	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function BossVipItem:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateRewardCell()
	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind(self.EnterFuben, self), true)
	
end

function BossVipItem:OnFlush()
	if nil == self.data then return end
	self:ClearReward()
	if  self.data.ispri then
		self.node_tree.img_boss_name.node:setVisible(false)
		local monster_data = ConfigManager.Instance:GetMonsterConfig(self.data.monsters.monsterId)
		self.node_tree.txt_boss_name.node:setString(monster_data.name)
		self.node_tree.txt_limit_lev.node:setString(self.data.name)
		self:PriReward()
		if self.data.index == 1 then
			self.node_tree.img_boss.node:loadTexture(ResPath.GetBigPainting("vip_boss_" .. 2))
		elseif self.data.index == 2 then
			self.node_tree.img_boss.node:loadTexture(ResPath.GetBigPainting("vip_boss_" .. 4))
		elseif self.data.index == 3 then
			self.node_tree.img_boss.node:loadTexture(ResPath.GetBigPainting("vip_boss_" .. 5))
		end
		self.node_tree.btn_enter.node:setEnabled(self.data.fitNum>0)
		self.node_tree.txt_remaind_time.node:setString(string.format(Language.Vip.FubenTime, self.data.fitNum))
	else
		self.node_tree.img_boss.node:loadTexture(ResPath.GetBigPainting("vip_boss_" .. self.index+1))
		self.node_tree.img_boss_name.node:loadTexture(ResPath.GetVipResPath("vip_boss_txt_" .. self.index+1))
		self.node_tree.img_boss_name.node:setVisible(true)
		self.node_tree.txt_boss_name.node:setString("")
		local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
		local txt = string.format(Language.Vip.BossLimitText, self.data.vip_lev)
		self.node_tree.txt_limit_lev.node:setString(txt)

		if level >= self.data.vip_lev then
			if self.data.inter_time == 0 then
				self.node_tree.btn_enter.node:setEnabled(true)
				self.node_tree.txt_remaind_time.node:setString(string.format(Language.Vip.FubenTime, 1))
			else
				self.node_tree.btn_enter.node:setEnabled(false)
				self.node_tree.txt_remaind_time.node:setString(string.format(Language.Vip.FubenTime, 0))
			end
		else
			self.node_tree.btn_enter.node:setEnabled(false)
			self.node_tree.txt_remaind_time.node:setString(txt)
		end
		self:BossShowReward()
	end
end

function BossVipItem:CreateSelectEffect()

end

function BossVipItem:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 4 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:GetView():setScale(0.8)
		self.node_tree.layout_gift_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.view.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
	for k,v in pairs(self.cell_gift_list) do
		v:GetView():setVisible(false)
	end
end

function BossVipItem:BossShowReward()
	if nil == self.cell_gift_list then return end

	local data = VipData.Instance:GetBossReward(self.data.vip_lev)
	-- local vis = false
	-- for i1 = 1, 8 do
	-- 	vis = data[i1] and true or false
	-- 	self.cell_gift_list[i1]:GetView():setVisible(vis)
	-- end
	for i1, v1 in ipairs(data) do
		self.cell_gift_list[i1]:GetView():setVisible(true)
		self.cell_gift_list[i1]:SetData(v1)
	end
end

function BossVipItem:ClearReward()
	for k,v in pairs(self.cell_gift_list) do
		v:GetView():setVisible(false)
	end
end

function BossVipItem:PriReward()
	for i1, v1 in ipairs(self.data.draw) do
		self.cell_gift_list[i1]:GetView():setVisible(true)
		self.cell_gift_list[i1]:SetData({item_id = v1.id, is_bind = 0})
	end
end

function BossVipItem:EnterFuben()
	if  self.data.ispri then 
		BossCtrl.Instance:CSFitPriBoss(self.data.index)
	else
		VipBossCtrl:SendOnVipBossFubenReq(self.data.vip_lev)
	end
end

