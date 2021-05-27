JingqingSYView = JingqingSYView or BaseClass(ActBaseView)

function JingqingSYView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function JingqingSYView:__delete()
	-- if self.act_53_reward_t then
	-- 	for k,v in pairs(self.act_53_reward_t) do
	-- 		v:DeleteMe()
	-- 	end
	-- 	self.act_53_reward_t = {}
	-- end
	if self.reward_list then
		self.reward_list:DeleteMe() 
		self.reward_list = nil 
	end
	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end
end

function JingqingSYView:InitView()
	self.node_t_list.btn_go_53.node:addClickEventListener(BindTool.Bind(self.OnClickGoFtHandler, self))
	self:CreateJingqingSYRewards()
	self.node_t_list.layout_jingqing_sy_53.node:setPosition(400,219)


end

function JingqingSYView:RefreshView(param_list)
end

function JingqingSYView:CreateJingqingSYRewards()
	-- self.act_53_reward_t = {}
	-- for i = 1, 5 do
	-- 	local cell = ActBaseCell.New()
	-- 	local ph = self.ph_list["ph_53_cell_"..i]
	-- 	cell:SetPosition(ph.x, ph.y)
	-- 	cell:SetIndex(i)
	-- 	cell:SetAnchorPoint(0.5, 0.5)
	-- 	self.node_t_list.layout_jingqing_sy_53.node:addChild(cell:GetView(), 300)
	-- 	table.insert(self.act_53_reward_t, cell)
	-- end
	-- local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQSY)
	-- if act_cfg then
	-- 	for i,v in ipairs(self.act_53_reward_t) do
	-- 		if act_cfg.config.award[i] then
	-- 			local data =   act_cfg.config.award[i]
	-- 			if data.type == tagAwardType.qatEquipment then
	-- 				v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
	-- 			else
	-- 				local virtual_item_id = ItemData.GetVirtualItemId(data.type)
	-- 				if virtual_item_id then
	-- 					v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0, effectId = data.effectId})
	-- 				end
	-- 			end
	-- 		end
	-- 		v:SetVisible( act_cfg.config.award[i] ~= nil)
	-- 	end
	-- end

	if nil == self.reward_list  then
		local ph = self.ph_list.ph_list
		self.reward_list  = ListView.New()
		local grid_node = self.reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ShowItemRender, nil, nil, self.ph_list.ph_53_cell_1)
		self.node_t_list.layout_jingqing_sy_53.node:addChild(self.reward_list:GetView(), 100)
		self.reward_list:GetView():setAnchorPoint(0, 0)
		self.reward_list:SetMargin(2)
		self.reward_list:SetItemsInterval(2)
		self.reward_list:SetJumpDirection(ListView.Top)
	end

	 local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQSY)
	if act_cfg then
		local cfg = act_cfg.config.awards
		self.reward_list:SetDataList(cfg)
		local ph = self.ph_list.ph_list
		local x = ph.x
		local y = ph.y
		if #cfg < 5 then
			x = ph.x + (5 - #cfg) * 35  - 18 + (5- #cfg)*2
		end
		self.reward_list:GetView():setPosition(x,y)

		
		if nil == self.monster_display then
			local ph = self.ph_list.ph_boss_pos
			self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_jingqing_sy_53.node, GameMath.MDirDown)
			self.monster_display:SetAnimPosition(ph.x,ph.y)
			self.monster_display:SetFrameInterval(FrameTime.RoleStand)
			self.monster_display:SetZOrder(100)
		end

		local boss_cfg = BossData.GetMosterCfg(act_cfg.config.show_monster_id)
		self.monster_display:Show(boss_cfg.modelid)
		local model_cfg = BossData.GetMosterModelCfg(boss_cfg.modelid)
		self.monster_display:SetScale(model_cfg.modelScale)
	end
end

function JingqingSYView:OnClickGoFtHandler()
	-- local act_id = ACT_ID.JQSY
	-- ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 1)

	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
	BossCtrl.CSChuanSongBossScene(7, ReXueBaZheBossCfg.boss.bossid)
end

ShowItemRender = ShowItemRender or BaseClass(BaseRender)
function ShowItemRender:__init( ... )
	-- body
end

function ShowItemRender:__delete( ... )
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end
end

function ShowItemRender:CreateChild( ... )
	BaseRender.CreateChild(self)
	if self.cell == nil then
		self.cell = ActBaseCell.New()
		local ph = self.ph_list["ph_item_render"]
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 300)
	end
end

function ShowItemRender:OnFlush()
	if self.data == nil then
		return 
	end
	self.cell:SetData({item_id = self.data.id, num = self.data.count, is_bind = self.data.bind or 0})
end
