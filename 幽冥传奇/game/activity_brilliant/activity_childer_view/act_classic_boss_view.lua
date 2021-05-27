ClassicBossView = ClassicBossView or BaseClass(ActBaseView)

function ClassicBossView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ClassicBossView:__delete()
  
	if self.boss_grid then
		self.boss_grid:DeleteMe()
		self.boss_grid = nil
	end
	if self.awakeboss_list then
		self.awakeboss_list:DeleteMe()
		self.awakeboss_list = nil
	end

	if self.spare_88_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_88_time)
		self.spare_88_time = nil
	end
end

function ClassicBossView:InitView()
	self:CreateBossGridScroll()
	self:CreateSpareFFTimer()
end

function ClassicBossView:CloseCallBack()
   
end

function ClassicBossView:RefreshView(param_list)
	-- self.node_t_list.btn_getawake.node:setVisible(false)
	self.node_t_list.stamp_1.node:setVisible(false)
	self.boss_list_data = {}
	local temp_list = {}
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JDBS).config.monster
	local kill_list = ActivityBrilliantData.Instance:GetBossKillList()
	for i,v in ipairs(cfg) do
		temp_list[i] = v
		temp_list[i].awake_sign = kill_list[i].awake_sign
		temp_list[i].boss_num = kill_list[i].boss_num
		for k,v in ipairs(cfg[i]) do
			temp_list[i][k].sign = kill_list[i][k]
		end
	end
	for i = 0, #temp_list - 1 do
		self.boss_list_data[i] = temp_list[i + 1]
	end

	XUI.AddClickEventListener(self.node_t_list.btn_left.node,BindTool.Bind(self.OnClickLeftBackHandler,self),false)
	XUI.AddClickEventListener(self.node_t_list.btn_right.node,BindTool.Bind(self.OnClickRightBackHandler,self),false)
	self:UpdateBtnState()
	self.boss_grid:SetDataList(self.boss_list_data)
end

function ClassicBossView:OnClickAwakeBtn(index)
	ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.JDBS,index)
end

function ClassicBossView:CreateBossGridScroll()
	local ph_shouhun = self.ph_list.ph_boss_grild
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JDBS).config.monster
	local cell_num = #cfg
	if nil == self.boss_grid  then
		self.boss_grid = BaseGrid.New() 
		self.boss_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.boss_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = BossListItemRender, ui_config = self.ph_list.ph_boss_list_item, cell_count = cell_num, col = 1, row = 1})
		self.node_t_list.layout_classics_boss.node:addChild(grid_node, 300)
		self.boss_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
	end
end

function ClassicBossView:OnPageChangeCallBack()
	self:UpdateBtnState()
end

function ClassicBossView:OnClickRightBackHandler()
	local index = self.boss_grid:GetCurPageIndex() or 0
	if index < self.boss_grid:GetPageCount() then
		self.boss_grid:ChangeToPage(index + 1)
	end
	-- self:UpdateBtnState()
end

function ClassicBossView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JDBS)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_classboss_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ClassicBossView:CreateSpareFFTimer()
	self.spare_88_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end


function ClassicBossView:OnClickLeftBackHandler()
	local index = self.boss_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.boss_grid:ChangeToPage(index - 1)
	end
	-- self:UpdateBtnState()
end

function ClassicBossView:UpdateBtnState()
	local show = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JDBS).config.awards[self.boss_grid:GetCurPageIndex()]
	local sign_num = 0
	local temp_list = {}
	local data_list = {}
	if nil ~= self.awakeboss_list then
		self.awakeboss_list:DeleteMe()
		self.awakeboss_list = nil
	end
	for i = 1, #(ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JDBS).config.monster[self.boss_grid:GetCurPageIndex()]) do
		if self.boss_list_data[self.boss_grid:GetCurPageIndex() - 1][i].sign == 1 then
			sign_num = sign_num + 1
		end
	end
	-- if sign_num ==  #(self.boss_list_data[self.boss_grid:GetCurPageIndex() - 1]) then
	--    self.node_t_list.btn_getawake.node:setVisible(true)
	-- else
	--     self.node_t_list.btn_getawake.node:setVisible(false)
	-- end
	for k, v in pairs(show) do
		 if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end

	local index = self.boss_grid:GetCurPageIndex() - 1
	local cur_data = self.boss_list_data[index] or {awake_sign = 0}

	if cur_data.awake_sign == 1 then
		self.node_t_list.stamp_1.node:setVisible(true)
		self.node_t_list.btn_getawake.node:setEnabled(false)
	elseif cur_data.awake_sign == 0 then
		self.node_t_list.stamp_1.node:setVisible(false)

		local can_receive = true
		for i = 1, 2 do
			if cur_data[i] then
				can_receive = can_receive and cur_data[i].sign == 1
			else
				can_receive = false
			end
		end
		self.node_t_list.btn_getawake.node:setEnabled(can_receive)
	end

	local ph = self.ph_list["ph_boss_awake"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list.layout_classics_boss.node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w+5, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.awakeboss_list = grid_scroll
	self.awakeboss_list:SetDataList(data_list)

	self.node_t_list.btn_left.node:setVisible(not (self.boss_grid:GetCurPageIndex() == 1))
	self.node_t_list.btn_right.node:setVisible(not (self.boss_grid:GetCurPageIndex() == self.boss_grid:GetPageCount()))
	XUI.AddClickEventListener(self.node_t_list.btn_getawake.node,BindTool.Bind(self.OnClickAwakeBtn,self,self.boss_grid:GetCurPageIndex()), false)
end

BossListItemRender = BossListItemRender or BaseClass(BaseRender)
function BossListItemRender:__init()	
end

function BossListItemRender:__delete()	
	if self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil
	end
end

function BossListItemRender:CreateChild()
	BaseRender.CreateChild(self)
end

function BossListItemRender:BossList()
	local ph = self.ph_list.ph_boss_list
	local cell_num = #(self.data)
	local temp_list = {}
	for i = 0, cell_num - 1 do
		temp_list[i] = self.data[i + 1]
	end
	if nil == self.boss_list then
		self.boss_list = BaseGrid.New()
		local list_node = self.boss_list:CreateCells({w = ph.w, h = ph.h, itemRender = BossIconItemRender, ui_config = self.ph_list.ph_boss_item, cell_count = cell_num, col = cell_num, row = 1})
		self.view:addChild(list_node,300)
		self.boss_list:GetView():setPosition(ph.x, ph.y)
		self.boss_list:SetDataList(temp_list)
	end
end

function BossListItemRender:OnFlush()
	if self.data == nil then return end
	self:BossList()
end

BossIconItemRender = BossIconItemRender or BaseClass(BaseRender)
function BossIconItemRender:__init()
	self.boss_display = nil
	self.stamp = nil
end

function BossIconItemRender:__delete()
	if self.boss_display then
		self.boss_display:DeleteMe()
		self.boss_display = nil 
	end

	self.stamp = nil
end
function BossIconItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self:CreateMonsterAnimation()

	XUI.AddClickEventListener(self.node_tree.btn_fight_go.node, BindTool.Bind(self.OnClickFigthBtn, self), false)
end

function BossIconItemRender:CreateMonsterAnimation()
	if nil == self.boss_display then
		local ph = self.ph_list.ph_boss_dis
		self.boss_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view, GameMath.MDirDown)
		self.boss_display:SetAnimPosition(ph.x, ph.y-20)
		self.boss_display:SetFrameInterval(FrameTime.RoleStand)
		self.boss_display:SetZOrder(1)
	end
end

function BossIconItemRender:OnFlush()
	-- self.node_tree.img_boss_head.node:loadTexture(ResPath.GetOpenServerActivities(self.data.headid))
	if nil == self.data then return end
	self.node_tree.lbl_boss_name.node:setString(self.data.name)
	self.node_tree.lbl_scene_name.node:setString(self.data.sceneName)

	local boss_cfg = BossData.GetMosterCfg(self.data.id)
	if boss_cfg == nil then return end
	self.boss_display:Show(boss_cfg.modelid)
	
	local vis = self.data.sign == 1
	if vis and self.stamp == nil then
		local path = ResPath.GetCommon("stamp_11")
		local x, y = 150, 160
		self.stamp = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
		self.view:addChild(self.stamp, 20)
	end
	if self.stamp then
		self.stamp:setVisible(vis)
	end

	self.node_tree.btn_fight_go.node:setVisible(not vis)
end

function BossIconItemRender:OnClickFigthBtn()
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Wild)
	ActivityBrilliantCtrl.Instance:CloseView(ACT_ID.JDBS)
end




