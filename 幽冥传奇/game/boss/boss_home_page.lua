BossHomePage = BossHomePage or BaseClass()


function BossHomePage:__init()
	self.boss_map_list = nil 
	self.boss_info_list = nil
	self.select_idx = 1
end	

function BossHomePage:__delete()
	self:RemoveEvent()
	self.select_idx = 1
	
	self.view = nil
	if self.cell_gift_list ~= nil then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = {}
	end
end	

--初始化页面接口
function BossHomePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.select_index = 1
	self:InitEvent()
end	

--初始化事件
function BossHomePage:InitEvent()
	self:CreateBossMapList()
	self:CreateBossInfoList()
	self:CreateRewardCell()

	XUI.AddClickEventListener(self.view.node_t_list.btn_on_boss.node, BindTool.Bind2(self.OnBossHomeJoinBtn, self))
end

--移除事件
function BossHomePage:RemoveEvent()
	if self.boss_map_list then
		self.boss_map_list:DeleteMe()
		self.boss_map_list = nil
	end

	if self.boss_info_list then
		self.boss_info_list:DeleteMe()
		self.boss_info_list = nil
	end
end

function BossHomePage:CreateBossMapList()
	if nil == self.boss_map_list then
		local ph = self.view.ph_list.ph_boss_home_list
		self.boss_map_list = ListView.New()
		self.boss_map_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossMapRender, nil, nil, self.view.ph_list.ph_boss_home_item)
		self.boss_map_list:GetView():setAnchorPoint(0, 0)
		self.boss_map_list:SetMargin(2)
		self.boss_map_list:SetItemsInterval(5)
		self.boss_map_list:SetJumpDirection(ListView.Top)
		self.boss_map_list:SetSelectCallBack(BindTool.Bind(self.OnBossSclectCallBack, self))
		self.view.node_t_list.page11.node:addChild(self.boss_map_list:GetView(), 100)
	end	
end

function BossHomePage:OnBossSclectCallBack(item, index)
	if nil == item or nil == item:GetData() then return end
	self.select_idx = index

	self:FlushView()
end

function BossHomePage:CreateBossInfoList()
	if nil == self.boss_info_list then
		local ph = self.view.ph_list.ph_boss_list
		self.boss_info_list = ListView.New()
		self.boss_info_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossInfoRender, nil, nil, self.view.ph_list.ph_boss_item)
		self.boss_info_list:GetView():setAnchorPoint(0, 0)
		self.boss_info_list:SetMargin(2)
		self.boss_info_list:SetItemsInterval(5)
		self.boss_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page11.node:addChild(self.boss_info_list:GetView(), 100)
	end	
end

--更新视图界面
function BossHomePage:UpdateData(data)
	local data = BossData.Instance:GetBossHomeData()
	self.boss_map_list:SetDataList(data)
	self.boss_map_list:SelectIndex(1)
end	

function BossHomePage:FlushView()
	local data = BossData.Instance:GetBossHomeData()

	local boss_cfg = BossData.Instance:GetBossInfoData(data[self.select_idx].child)
	self.boss_info_list:SetDataList(boss_cfg)

	local limit_data = data[self.select_idx].vipLimit
	local open_days =  OtherData.Instance:GetOpenServerDays()
	local txt_limit = ""
	if limit_data[1] ~= 0 then
		if open_days >= limit_data[1] then
			txt = ""
		else
			txt = string.format(Language.Boss.VipLimitNeed, limit_data[2])
		end
	else
		txt = string.format(Language.Boss.VipLimitNeed, limit_data[2])
	end
	self.view.node_t_list.txt_limit_enter.node:setString(txt)

	-- local rew_data = data[self.select_idx].consume[1]
	-- local config = ItemData.Instance:GetItemConfig(rew_data.id)
	-- if config == nil then return end
	-- self.view.node_t_list.txt_on_term.node:setString(config.name .. " * " .. rew_data.count)
	self:BossHomeShowReward(data[self.select_idx].child)
end

function BossHomePage:OnBossHomeJoinBtn()
	Scene.Instance:CommonSwitchTransmitSceneReq(201)
	-- Scene.Instance:GetMainRole():LeaveFor(5, 83, 67, MoveEndType.NpcTask, 134)
	ViewManager.Instance:Close(ViewName.Boss)
end

function BossHomePage:BossHomeShowReward(data)
	local reward_data = BossDropShowConfig[data[#data]]--BossData.Instance:GetRewardByBossId(data[#data])
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(self.cell_gift_list) do
		v:GetView():setVisible(false)
	end
	local cur_data = {}
	for k,v in pairs(reward_data) do
		if v.job == prof then
			table.insert(cur_data, v)
		end
	end
	for i, v in ipairs(cur_data) do
		if self.cell_gift_list[i] ~= nil then
			self.cell_gift_list[i]:GetView():setVisible(true)
			if v.id == 0 then
				local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
				if virtual_item_id then
					self.cell_gift_list[i]:SetData{["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
				end
			else
				self.cell_gift_list[i]:SetData{item_id = v.id, num = v.count, is_bind = 0}
			end
		end
	end
	-- local vis = false
	-- for i1, v1 in ipairs(cur_data) do
	-- 	for i1 = 1, 8 do
	-- 		vis = cur_data[i1] and true or false
	-- 		self.cell_gift_list[i1]:GetView():setVisible(vis)
	-- 	end
	-- 	self.cell_gift_list[i1]:SetData(v1)
	-- end

end

function BossHomePage:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 8 do
		local cell = BaseCell.New()
		local ph = self.view.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.view.node_t_list.layout_boss_reward_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
end

-- boss地图
BossMapRender = BossMapRender or BaseClass(BaseRender)
function BossMapRender:__init()
end

function BossMapRender:__delete()	
end

function BossMapRender:CreateChild()
	BaseRender.CreateChild(self)
	
end

function BossMapRender:OnFlush()
	if self.data.limit_lev[1] == 0 then
		self.node_tree.txt_limit_lev.node:setString(string.format(Language.Boss.ConsumeLevel, self.data.limit_lev[2]))
	else
		self.node_tree.txt_limit_lev.node:setString(string.format(Language.Boss.BossLimitCircle, self.data.limit_lev[1]))
	end
	self.node_tree.img_map_name.node:loadTexture(ResPath.GetBoss("boos_home_".. self.index))
	self.node_tree.img_boss_bg.node:loadTexture(ResPath.GetBigPainting("bg_boss_home_".. self.index, true))
	self.node_tree.txt_desc.node:setString(Language.Boss.BossHomeDesc[self.index])
	
end

-- 地图boss信息
BossInfoRender = BossInfoRender or BaseClass(BaseRender)
function BossInfoRender:__init()
end

function BossInfoRender:__delete()	
end

function BossInfoRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossInfoRender:OnFlush()
	if not self.data then return end
	self.node_tree.txt_boss_name.node:setString(self.data.name)
	self.node_tree.txt_boss_lev.node:setString(self.data.level)
	local txt = Language.Boss.BossIsKill[self.data.state]
	if self.data.state == 1 then
		self.node_tree.txt_profession.node:setColor(COLOR3B.RED)
	else	
		self.node_tree.txt_profession.node:setColor(COLOR3B.GREEN)
	end	
	self.node_tree.txt_profession.node:setString(txt)
end