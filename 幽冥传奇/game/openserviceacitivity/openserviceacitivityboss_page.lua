-- 开服BOSs
OpenServiceAcitivityBossPage = OpenServiceAcitivityBossPage or BaseClass()

function OpenServiceAcitivityBossPage:__init()
	
	
end	

function OpenServiceAcitivityBossPage:__delete()
	self:RemoveEvent()
	if self.boss_grid ~= nil then
		self.boss_grid:DeleteMe()
		self.boss_grid = nil 
	end
	if self.reward_cell ~= nil then 
		for i, v in ipairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end

	if self.remind_eff then
		self.remind_eff:removeFromParent()
		self.remind_eff = nil
	end
end	

--初始化页面接口
function OpenServiceAcitivityBossPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.reward_cell = {}
	self.cur_index = 1
	self:CreateGrid()
	self:CreateCells()
	self:InitEvent()
end	

function OpenServiceAcitivityBossPage:CreateGrid()
	if self.boss_grid == nil then
		local num = OpenServiceAcitivityData.Instance:GetMonsterNum()
		self.boss_grid = BaseGrid.New() 
		local ph_grid = self.view.ph_list.ph_imonster_grid
		local grid_node = self.boss_grid:CreateCells({w = ph_grid.w + 20, h = ph_grid.h, itemRender = BossItemRender, direction = ScrollDir.Horizontal,cell_count = num, col = 4, row = 1, ui_config = self.view.ph_list.ph_item})
		grid_node:setPosition(ph_grid.x, ph_grid.y)
		grid_node:setAnchorPoint(0.5, 0.5)
		self.view.node_t_list["layout_boss"].node:addChild(grid_node, 999)
		self.cur_index = self.boss_grid:GetCurPageIndex()
		self.boss_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	end
	self.remind_eff = RenderUnit.CreateEffect(11, self.view.node_t_list.btn_transmit_failed.node, zorder, frame_interval, COMMON_CONSTS.MAX_LOOPS, x, y)

end

function OpenServiceAcitivityBossPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	self:FlushData()
	self:FlushRewardData()
	self:FlushBtn()
end

--初始化事件
function OpenServiceAcitivityBossPage:InitEvent()
	self.view.node_t_list.btn_left_move.node:addClickEventListener(BindTool.Bind(self.OnClickMoveLeftHandler, self))
	self.view.node_t_list.btn_right_move.node:addClickEventListener(BindTool.Bind(self.OnClickMoveRightHandler, self))
	self.view.node_t_list.btn_transmit_failed.node:addClickEventListener(BindTool.Bind(self.OnTransmit, self))
end

function OpenServiceAcitivityBossPage:OnClickMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.boss_grid:ChangeToPage(self.cur_index)
	end
end

function OpenServiceAcitivityBossPage:OnClickMoveRightHandler()
	if self.cur_index < 4 then
		self.cur_index = self.cur_index + 1
		self.boss_grid:ChangeToPage(self.cur_index)
	end
end

function OpenServiceAcitivityBossPage:OnTransmit()
	local bool_show = OpenServiceAcitivityData.Instance:GetBoolGetReward(self.cur_index)
	if bool_show == 1 then
		OpenServiceAcitivityCtrl.Instance:SendGetBossRewardReq(self.cur_index)
	else
		for k, v in pairs(OpenServerCfg.Boss) do
			if k == self.cur_index then
				if v.fun then
					local boss_panel = v.fun[1]
					-- print(boss_panel)
					ViewManager.Instance:Open(boss_panel, v.fun[2])	
					ViewManager.Instance:Close(ViewName.OpenServiceAcitivity)
				else
					Scene.Instance:CommonSwitchTransmitSceneReq(v.teleId)
					ViewManager.Instance:Close(ViewName.OpenServiceAcitivity)
				end
			end
		end
	end
end

--移除事件
function OpenServiceAcitivityBossPage:RemoveEvent()
	
end

function OpenServiceAcitivityBossPage:CreateCells()
	self.reward_cell = {}
	for i = 1, 5 do
		local ph = self.view.ph_list["ph_award_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		self.view.node_t_list["layout_boss"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

--更新视图界面
function OpenServiceAcitivityBossPage:UpdateData(data)
	self:FlushData()
	self:FlushRewardData()
	self:FlushBtn()
end

function OpenServiceAcitivityBossPage:FlushData()
	local data = OpenServiceAcitivityData.Instance:GetBossInfo()
	local cur_data = data or {}
	local monster_data = {}
	local key = 0
	for i, v in ipairs(cur_data) do
		for i1,v1 in ipairs(v) do
			monster_data[key] = v1
			key = key + 1
		end
	end
	self.boss_grid:SetDataList(monster_data)
	local scene_name = ""
	local scene_id = OpenServerCfg.Boss[self.cur_index] and OpenServerCfg.Boss[self.cur_index].sceneId
	if scene_id then
		local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
		scene_name = scene_config and scene_config.name or ""
	end
	self.view.node_t_list.txt_boss_scene_name.node:setString(scene_name)
end

function OpenServiceAcitivityBossPage:FlushBtn()
	self.view.node_t_list.btn_left_move.node:setVisible(self.cur_index ~= 1)
	self.view.node_t_list.btn_right_move.node:setVisible(self.cur_index ~= 4)
	local bool_show = OpenServiceAcitivityData.Instance:GetBoolGetReward(self.cur_index)
	local txt = (bool_show == 1) and Language.OpenServiceAcitivity.BossBtnTitle_2 or Language.OpenServiceAcitivity.BossBtnTitle_1
	self.view.node_t_list.btn_transmit_failed.node:setTitleText(txt)
	if bool_show == 2 then
		XUI.SetButtonEnabled(self.view.node_t_list.btn_transmit_failed.node, false)
		self.remind_eff:setVisible(false)
	else
		XUI.SetButtonEnabled(self.view.node_t_list.btn_transmit_failed.node, true)
		self.remind_eff:setVisible(true)
	end
end

function OpenServiceAcitivityBossPage:FlushRewardData()
	local data = OpenServiceAcitivityData.Instance:GetBossReawradData(self.cur_index)
	local cur_data = {}
	for i, v in ipairs(data) do
		if v.item_id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.num, is_bind = v.is_bind}
			end
		else
			cur_data[i] = v
		end
	end
	for i,v in ipairs(cur_data) do
		self.reward_cell[i]:SetData(v)
	end
end

BossItemRender = BossItemRender or BaseClass(BaseRender)
function BossItemRender:__init()
end

function BossItemRender:__delete()	
end

function BossItemRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossItemRender:OnFlush()
	if self.data == nil then return end
	local monster_cfg = BossData.GetMosterCfg(self.data.monster_id)
	if monster_cfg == nil then
		return 
	end
	local id = 10000
	if monster_cfg.icon > 0 then
		id = monster_cfg.icon
	end
	self.node_tree.img_bg.node:loadTexture(ResPath.GetBossHead("boss_icon_"..id))
	local name = DelNumByString(monster_cfg.name)
	self.node_tree.txt_monster_name.node:setString(name)
	self.node_tree.txt_kill_time.node:setString(self.data.is_kill.."/".."1")
	if self.data.is_kill == 1 then
		self.node_tree.img_bg.node:setGrey(true)
		self.node_tree.img_bg_2.node:setVisible(true)
	else
		self.node_tree.img_bg.node:setGrey(false)
		self.node_tree.img_bg_2.node:setVisible(false)
	end
end

function BossItemRender:CreateSelectEffect()
	
end