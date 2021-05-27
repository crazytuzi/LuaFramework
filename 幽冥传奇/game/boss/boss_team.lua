-- BossTeamPage = BossTeamPage or BaseClass()


-- function BossTeamPage:__init()
	
-- end	

-- function BossTeamPage:__delete()

	
-- 	if self.fuben_team_list ~= nil then
-- 		self.fuben_team_list:DeleteMe()
-- 		self.fuben_team_list = nil
-- 	end
-- 	if self.team_list ~= nil then
-- 		self.team_list:DeleteMe()
-- 		self.team_list = nil
-- 	end

-- 	if self.my_team_list ~= nil then
-- 		self.my_team_list:DeleteMe()
-- 		self.my_team_list = nil
-- 	end
-- 	if self.reward_cell ~= nil then
-- 		for k,v in pairs(self.reward_cell) do
-- 			v:DeleteMe()
-- 		end
-- 		self.reward_cell = {}
-- 	end
-- 	self:RemoveEvent()
-- 	self.view = nil
-- end	

-- --初始化页面接口
-- function BossTeamPage:InitPage(view)
-- 	--绑定要操作的元素
-- 	self.view = view
-- 	self.cur_fuben_index = nil 
-- 	self.leader_id = 0
-- 	self.my_fuben_id = 0
-- 	self.my_team_id = 0
-- 	self.my_team = {}
-- 	self.team_list_t = {}
-- 	self:CreateFubenList()
-- 	self:CreateTeamList()
-- 	self:CreateMyTeamList()
-- 	self:CreateCells()
-- 	self:InitEvent()
	
-- end	

-- --初始化事件
-- function BossTeamPage:InitEvent()
	
-- 	RichTextUtil.ParseRichText(self.view.node_t_list.layout_team_boss.layout_not_team.rich_txt.node, Language.Boss.TeamInfo, 24)
-- 	XUI.RichTextSetCenter(self.view.node_t_list.layout_team_boss.layout_not_team.rich_txt.node)
-- 	XUI.AddClickEventListener(self.view.node_t_list.layout_team_boss.layout_not_team.btn_create_team.node, BindTool.Bind2(self.CreateTeam, self))
-- 	XUI.AddClickEventListener(self.view.node_t_list.layout_team_boss.layout_not_team.btn_quickly_enter.node, BindTool.Bind2(self.JoinTeam, self))
-- 	XUI.AddClickEventListener(self.view.node_t_list.layout_team_boss.layout_had_team.btn_open_fuben.node, BindTool.Bind2(self.OpenFuBen, self))
-- 	XUI.AddClickEventListener(self.view.node_t_list.layout_team_boss.layout_had_team.btn_exit_team.node, BindTool.Bind2(self.LevelTeam, self))
-- 	XUI.AddClickEventListener(self.view.node_t_list.layout_team_boss.layout_not_team.btn_team_boss_desc.node, BindTool.Bind2(self.DescTipsTeamBoss, self))

-- end

-- function BossTeamPage:CreateTeam()
-- 	if self.select_data ~= nil then
-- 		BossCtrl.Instance:CreateFubenTeam(self.select_data.fuben_id)
-- 	end
-- end
-- function BossTeamPage:JoinTeam()
-- 	if self.select_data ~= nil then
-- 		if #self.team_list_t == 0 then
-- 			BossCtrl.Instance:CreateFubenTeam(self.select_data.fuben_id)
-- 		else
-- 			BossCtrl.Instance:ReqJoinFubenTeam(2, self.select_data.fuben_id)
-- 		end
-- 	end
-- end

-- function BossTeamPage:OpenFuBen()
-- 	if self.leader_id == RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
-- 		BossCtrl.Instance:LeaderReqOpenFuben()
-- 	else
-- 		SysMsgCtrl.Instance:FloatingTopRightText(Language.Boss.FabBind)
-- 	end
-- end

-- function BossTeamPage:LevelTeam()
-- 	BossCtrl.Instance:ReqExitFubenTeam(self.my_team_id)
-- 	BossCtrl.Instance:ReqFubenData(self.my_fuben_id)
-- end


-- --移除事件
-- function BossTeamPage:RemoveEvent()

-- end

-- function BossTeamPage:DescTipsTeamBoss()
-- 	DescTip.Instance:SetContent(Language.Boss.TeamBossContent, Language.Boss.TeamBossTiTle)
-- end

-- function BossTeamPage:UpdateData(data)
	
-- 	local fuben_id, team_id, cur_data = BossData.Instance:GetMyData()
-- 	self.my_fuben_id = fuben_id 
-- 	self.my_team_id = team_id
-- 	self.view.node_t_list.layout_team_boss.layout_not_team.node:setVisible(team_id == 0)
-- 	self.view.node_t_list.layout_team_boss.layout_had_team.node:setVisible(team_id ~= 0)
-- 	self.fuben_team_list:SetDataList(cur_data)
-- 	if self.cur_fuben_index == nil then
-- 		if self.fuben_team_list ~= nil then
-- 			self.fuben_team_list:SelectIndex(1)
-- 		end
-- 	end

-- 	local list = BossData.Instance:GetCurAllFubenTeamList()
-- 	self.team_list_t = list
-- 	self.team_list:SetDataList(list)
	
-- 	self.leader_id, self.my_team = BossData.Instance:GetMyTeamListData()
-- 	XUI.SetButtonEnabled(self.view.node_t_list.layout_team_boss.layout_had_team.btn_open_fuben.node, false)
-- 	if self.leader_id == RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
-- 		XUI.SetButtonEnabled(self.view.node_t_list.layout_team_boss.layout_had_team.btn_open_fuben.node, true)
-- 	end
-- 	self.my_team_list:SetDataList(self.my_team)
-- end

-- function BossTeamPage:CreateFubenList()
-- 	if self.fuben_team_list == nil then
-- 		self.fuben_team_list = ListView.New()
-- 		local ph = self.view.ph_list.ph_btn_item_list
-- 		self.fuben_team_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TeamBossRender, nil, nil, self.view.ph_list.ph_btn_list_item)
-- 		self.view.node_t_list.layout_team_boss.node:addChild(self.fuben_team_list:GetView(), 100, 100)
-- 		self.fuben_team_list:GetView():setAnchorPoint(0,0)
-- 		self.fuben_team_list:SetItemsInterval(10)
-- 		self.fuben_team_list:SetMargin(5)
-- 		self.fuben_team_list:SetJumpDirection(ListView.Top)
-- 		self.fuben_team_list:SetSelectCallBack(BindTool.Bind(self.SelectTeamBossListCallback, self))
-- 	end
-- end

-- function BossTeamPage:CreateTeamList()
-- 	if self.team_list == nil then
-- 		self.team_list = ListView.New()
-- 		local ph = self.view.ph_list.ph_team_list
-- 		self.team_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TeamListRender, nil, nil, self.view.ph_list.ph_team_item)
-- 		self.view.node_t_list.layout_not_team.node:addChild(self.team_list:GetView(), 100, 100)
-- 		self.team_list:GetView():setAnchorPoint(0,0)
-- 		self.team_list:SetItemsInterval(10)
-- 		self.team_list:SetMargin(5)
-- 		self.team_list:SetJumpDirection(ListView.Top)
-- 		self.team_list:SetSelectCallBack(BindTool.Bind(self.SelectTeamListCallback, self))
-- 	end
-- end

-- function BossTeamPage:SelectTeamListCallback(item, index)
-- 	if item == nil or item:GetData() == nil then return end
-- end

-- function BossTeamPage:SelectTeamBossListCallback(item, index)
-- 	if item == nil or item:GetData() == nil then return end
-- 	if self.my_team_id == 0 then
-- 		self.select_data = item:GetData()
-- 		self.cur_fuben_index = item:GetIndex()
-- 		self:FlushReward()
-- 		BossCtrl.Instance:ReqFubenData(self.select_data.fuben_id)
-- 	else
-- 		local data = item:GetData()
-- 		local index = item:GetIndex()
-- 		if self.team_id  ~= 0 then
-- 			if self.my_fuben_id ~= data and data.fuben_id then
-- 				self.fuben_team_list:CancelSelect()

-- 			end
-- 		end
-- 	end
-- end

-- function BossTeamPage:CreateMyTeamList()
-- 	if self.my_team_list == nil then
-- 		self.my_team_list = ListView.New()
-- 		local ph = self.view.ph_list.ph_item_list_1
-- 		self.my_team_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MyTeamListRender, nil, nil, self.view.ph_list.ph_list_team_1)
-- 		self.view.node_t_list.layout_team_boss.layout_had_team.node:addChild(self.my_team_list:GetView(), 100, 100)
-- 		self.my_team_list:GetView():setAnchorPoint(0,0)
-- 		self.my_team_list:SetItemsInterval(10)
-- 		self.my_team_list:SetMargin(5)
-- 		self.my_team_list:SetJumpDirection(ListView.Top)
-- 		self.my_team_list:SetSelectCallBack(BindTool.Bind(self.SelectMyTeamListCallback, self))
-- 	end
-- end

-- function BossTeamPage:SelectMyTeamListCallback()
	
-- end

-- function BossTeamPage:CreateCells()
-- 	self.reward_cell = {}
-- 	for i = 1, 5 do
-- 		local ph = self.view.ph_list["ph_cell_"..i]
-- 		local cell = BaseCell.New()
-- 		cell:SetPosition(ph.x, ph.y)
-- 		cell:GetView():setAnchorPoint(0, 0)
-- 		self.view.node_t_list.layout_not_team.node:addChild(cell:GetView(), 100)
-- 		table.insert(self.reward_cell, cell)
-- 	end
-- end

-- function BossTeamPage:FlushReward()
-- 	self.select_data = self.select_data or {}
-- 	local reward = self.select_data.show_reward or {}
-- 	for k,v in pairs(self.reward_cell) do
-- 		v:GetView():setVisible(false)
-- 	end

-- 	for k,v in pairs(reward) do
-- 		if self.reward_cell[k] ~= nil then
-- 			self.reward_cell[k]:GetView():setVisible(true)
-- 			local id = nil
-- 			if v.type > 0 then
-- 				id = ItemData.Instance:GetVirtualItemId(v.type)
-- 			else
-- 				id = v.id
-- 			end
-- 			self.reward_cell[k]:SetData({item_id = id, num = v.count, is_bind = v.bind})
-- 		end
-- 	end
-- end



-- TeamBossRender = TeamBossRender or BaseClass(BaseRender)
-- function TeamBossRender:__init()

-- end

-- function TeamBossRender:__delete()	
-- end

-- function TeamBossRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	self.node_tree.img_bg.node:loadTexture(ResPath.GetBigPainting("fuben_team"..(self.index+1), true))
-- end

-- function TeamBossRender:OnFlush()
-- 	if self.data == nil then return end
-- 	self.node_tree.txt_remain_time.node:setString(self.data.remain_num .. "/" .. self.data.maxnum)
-- 	self.node_tree.txt_fuben_name.node:setString(self.data.fubenName)
-- 	local txt = ""
-- 	if self.data.limit[1] == 0 then
-- 		txt = string.format(Language.Boss.ConsumeLevel, self.data.limit[2] or 0)
-- 	else
-- 		txt = string.format(Language.Boss.ConsumeCircle, self.data.limit[1] or 0, self.data.limit[2] or 0)
-- 	end
-- 	self.node_tree.txt_monster_level.node:setString(txt)
-- 	self.node_tree.txt_tuijian.node:setString(string.format(Language.Boss.TuiJianZhanli, self.data.need_zhanli))
-- 	if self.cache_select and self.is_select then
-- 		self.cache_select = false
-- 		self:CreateSelectEffect()
-- 	end	
-- end

-- function TeamBossRender:CreateSelectEffect()
-- 	if nil == self.node_tree.img_bg then
-- 		self.cache_select = true
-- 		return
-- 	end
-- 	local size = self.node_tree.img_bg.node:getContentSize()
-- 	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width+10,size.height+10,ResPath.GetCommon("btn_effect_116"), true , cc.rect(37,19,73,22))
-- 	if nil == self.select_effect then
-- 		ErrorLog("BaseRender:CreateSelectEffect fail")
-- 		return
-- 	end
-- 	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
-- end

-- TeamListRender = TeamListRender or BaseClass(BaseRender)
-- function TeamListRender:__init()

-- end

-- function TeamListRender:__delete()	
-- end

-- function TeamListRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	XUI.AddClickEventListener(self.node_tree.txt_enter_team.node, BindTool.Bind2(self.EnterTeam, self))
-- end

-- function TeamListRender:OnFlush()
-- 	if self.data == nil then return end
-- 	self.node_tree.txt_leader_name.node:setString(self.data.leader_name)
-- 	self.node_tree.txt_leader_level.node:setString(self.data.leader_level)
-- 	self.node_tree.txt_zhanli.node:setString(self.data.team_zhanli)
-- 	self.node_tree.txt_team_num.node:setString(self.data.tean_num)
-- 	self.node_tree.team_leader_prof.node:loadTexture(ResPath.GetCommon("team_" .. self.data.leader_prof))
-- 	self.node_tree.txt_prof.node:setString(Language.Common.ProfName[self.data.leader_prof])
-- end

-- function TeamListRender:EnterTeam()
-- 	BossCtrl.Instance:ReqJoinFubenTeam(1, self.data.team_id)
-- end

-- MyTeamListRender = MyTeamListRender or BaseClass(BaseRender)
-- function MyTeamListRender:__init()

-- end

-- function MyTeamListRender:__delete()	
-- end

-- function MyTeamListRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	XUI.AddClickEventListener(self.node_tree.btn_shotoff_team.node, BindTool.Bind2(self.ShotOffTeam, self))
-- end

-- function MyTeamListRender:OnFlush()
-- 	if self.data == nil then return end
-- 	self.node_tree.txt_member_prof.node:setString(Language.Common.ProfName[self.data.member_prof])
-- 	self.node_tree.img_prof.node:loadTexture(ResPath.GetCommon("team_" .. self.data.member_prof))
-- 	self.node_tree.txt_name.node:setString(self.data.member_name)
-- 	self.node_tree.txt_level.node:setString(self.data.member_level)
-- 	self.node_tree.txt_zhanli.node:setString(self.data.member_zhanli)
-- 	self.node_tree.txt_guild_name.node:setString(self.data.guild_name)
-- 	self.node_tree.btn_shotoff_team.node:setVisible(false)
-- 	self.node_tree.layout_bg.node:setVisible(self.data.is_leader == 1)
-- 	local leader_id = BossData.Instance:GetMyTeamListData()
-- 	if leader_id == RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
-- 		if self.data.is_leader ~= 1 then
-- 			self.node_tree.btn_shotoff_team.node:setVisible(true)
-- 		end
-- 	end
-- end

-- function MyTeamListRender:ShotOffTeam()
-- 	local leader_id = BossData.Instance:GetMyTeamListData()
-- 	if leader_id == RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
-- 		BossCtrl.Instance:ReqLeaderExitMemberSigleFubenTeam(self.data.member_id)
-- 	else
-- 		SysMsgCtrl.Instance:FloatingTopRightText(Language.Boss.FabBind)
-- 	end
-- end

