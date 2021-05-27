--转生打宝
HuntBossTreasurePage = HuntBossTreasurePage or BaseClass()


function HuntBossTreasurePage:__init()
	self.boss_baotu_map_list = nil 
	self.boss_baotu_info_list = nil
	self.select_idx = 1
end	

function HuntBossTreasurePage:__delete()
	self:RemoveEvent()
	self.select_idx = 1
	
	self.view = nil
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end	

--初始化页面接口
function HuntBossTreasurePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.select_index = 1
	self:InitEvent()
end	

--初始化事件
function HuntBossTreasurePage:InitEvent()
	self:CreateBossBaotuMapList()
	self:CreateBossBaotuInfoList()
	self:CreateRewardCell()

	XUI.AddClickEventListener(self.view.node_t_list.btn_on_boss_baotu.node, BindTool.Bind2(self.OnBossBaotuJoinBtn, self))
end

--移除事件
function HuntBossTreasurePage:RemoveEvent()
	if self.boss_baotu_map_list then
		self.boss_baotu_map_list:DeleteMe()
		self.boss_baotu_map_list = nil
	end

	if self.boss_baotu_info_list then
		self.boss_baotu_info_list:DeleteMe()
		self.boss_baotu_info_list = nil
	end
end

function HuntBossTreasurePage:CreateBossBaotuMapList()
	if nil == self.boss_baotu_map_list then
		local ph = self.view.ph_list.ph_boss_baotu_map_list
		self.boss_baotu_map_list = ListView.New()
		self.boss_baotu_map_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossBaotuMapRender, nil, nil, self.view.ph_list.ph_boss_baotu_map_item)
		self.boss_baotu_map_list:GetView():setAnchorPoint(0, 0)
		self.boss_baotu_map_list:SetMargin(2)
		self.boss_baotu_map_list:SetItemsInterval(5)
		self.boss_baotu_map_list:SetJumpDirection(ListView.Top)
		self.boss_baotu_map_list:SetSelectCallBack(BindTool.Bind(self.OnBossSclectCallBack, self))
		self.view.node_t_list.page13.node:addChild(self.boss_baotu_map_list:GetView(), 100)
	end	
end

function HuntBossTreasurePage:OnBossSclectCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_index = item:GetIndex()
	self:FlushView(index)
end

function HuntBossTreasurePage:CreateBossBaotuInfoList()
	if nil == self.boss_baotu_info_list then
		local ph = self.view.ph_list.ph_boss_baotu_list
		self.boss_baotu_info_list = ListView.New()
		self.boss_baotu_info_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossBaotuInfoRender, nil, nil, self.view.ph_list.ph_boss_baotu_item)
		self.boss_baotu_info_list:GetView():setAnchorPoint(0, 0)
		self.boss_baotu_info_list:SetMargin(2)
		self.boss_baotu_info_list:SetItemsInterval(5)
		self.boss_baotu_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page13.node:addChild(self.boss_baotu_info_list:GetView(), 100)
	end	
end

--更新视图界面
function HuntBossTreasurePage:UpdateData(data)
	local data = BossData.Instance:GetBossBaotuData()
	self.boss_baotu_map_list:SetDataList(data)
	self.boss_baotu_map_list:SelectIndex(1)
end	

function HuntBossTreasurePage:FlushView()
	local data = BossData.Instance:GetBossBaotuData()
	local config = ItemData.Instance:GetItemConfig(data[self.select_index].consume.id)
	if config == nil then return end
	self.view.node_t_list.page13.txt_consume.node:setString(config.name .. " X " .. data[self.select_index].consume.count)
	self.boss_baotu_info_list:SetDataList(HuntBossTreasureCfg[self.select_index].boss)
	local reward_data = BossDropShowConfig[HuntBossTreasureCfg[self.select_index].boss[#HuntBossTreasureCfg[self.select_index].boss]] or {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for k,v in pairs(self.cell_list) do
		v:GetView():setVisible(false)
	end
	local cur_data = {}
	for k,v in pairs(reward_data) do
		if v.job == prof then
			table.insert(cur_data, v)
		end
	end
	for i, v in ipairs(cur_data) do
		if self.cell_list[i] ~= nil then
			self.cell_list[i]:GetView():setVisible(true)
			if v.id == 0 then
				local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
				if virtual_item_id then
					self.cell_list[i]:SetData{["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
				end
			else
				self.cell_list[i]:SetData{item_id = v.id, num = v.count, is_bind = 0}
			end
		end	
	end
	-- local vis = false
	-- for i1, v1 in ipairs(cur_data) do
	-- 	for i1 = 1, 8 do
	-- 		vis = cur_data[i1] and true or false
	-- 		self.cell_list[i1]:GetView():setVisible(vis)
	-- 	end
	-- 	self.cell_list[i1]:SetData(v1)
	-- end
end

function HuntBossTreasurePage:CreateRewardCell()
	self.cell_list = {}
	for i = 1, 8 do
		local cell = BaseCell.New()
		local ph = self.view.ph_list["ph_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.view.node_t_list.layout_baotu_boss_reward_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_list, cell)
	end
end
function HuntBossTreasurePage:OnBossBaotuJoinBtn()
	BossCtrl.Instance:SendEnterHuntBossTreasureReq(self.select_index)
end

-- boss地图
BossBaotuMapRender = BossBaotuMapRender or BaseClass(BaseRender)
function BossBaotuMapRender:__init()
end

function BossBaotuMapRender:__delete()	
end

function BossBaotuMapRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossBaotuMapRender:OnFlush()
	local index = select_index or 1
	if self.data.level_min[1] == 0 then
		self.node_tree.txt_baotu_limit_lev.node:setString(string.format(Language.Boss.ConsumeLevel, self.data.level_min[2]))
	else
		self.node_tree.txt_baotu_limit_lev.node:setString(string.format(Language.Boss.BossLimitCircle, self.data.level_min[1]))
	end
	self.node_tree.img_baotu_map_name.node:loadTexture(ResPath.GetBoss("HuntBossTreasure_".. self.index))
	self.node_tree.img_boss_baotu_bg.node:loadTexture(ResPath.GetBigPainting("bg_boss_home_".. self.index, true))
	self.node_tree.txt_baotu_desc.node:setString(Language.Boss.HuntBossTreasureDesc[self.index])
	
end

-- 地图boss信息
BossBaotuInfoRender = BossBaotuInfoRender or BaseClass(BaseRender)
function BossBaotuInfoRender:__init()
end

function BossBaotuInfoRender:__delete()	
end

function BossBaotuInfoRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossBaotuInfoRender:OnFlush()
	if not self.data then return end
	local boss_data = ConfigManager.Instance:GetMonsterConfig(self.data)
	self.node_tree.txt_boss_baotu_name.node:setString(boss_data.name)
	self.node_tree.txt_boss_baotu_lev.node:setString(boss_data.level)
	local is_can_kill = BossData.Instance:GetCanKillBoss()
	local txt = Language.Boss.BossIsKill[1]
	self.node_tree.txt_state.node:setColor(COLOR3B.RED)
	for k, v in pairs(is_can_kill) do
		if v.boss_id == self.data then
			txt = Language.Boss.BossIsKill[2]
			self.node_tree.txt_state.node:setColor(COLOR3B.GREEN)
		end
	end
	self.node_tree.txt_state.node:setString(txt)
end