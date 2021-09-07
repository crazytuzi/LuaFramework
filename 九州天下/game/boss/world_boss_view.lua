WorldBossView = WorldBossView or BaseClass(BaseRender)

-- 福利Boss
function WorldBossView:__init()
	self.select_boss_id = 0
end

function WorldBossView:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	
	if self.item_cell and next(self.item_cell) then
		for i = 1, 8 do
			self.item_cell[i]:DeleteMe()
		end
		self.item_cell = {}
	end

	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end
end

function WorldBossView:LoadCallBack()
	self.item_cell = {}
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end
	self.iskill = self:FindVariable("IsKill")
	self.killer_info = self:FindVariable("KillerInfo")
	self.show_Red_Point = self:FindVariable("showRedPoint")
	
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("fuli_boss_view")
	self.model_view:SetDisplay(self.model_display.ui3d_display)

	self:ListenEvent("QuestionClick", BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("ToActtack", BindTool.Bind(self.ToActtack, self))
	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))

	self.select_boss_id = BossData.Instance:GetBossCfg()[0].bossID
end

function WorldBossView:RoleInfoCallBack(role_id, protocol)
	local killer = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	if killer and killer.last_kill_uid == role_id then
		local str = Language.Common.CampNameAbbr[protocol.camp_id] .. protocol.role_name
		self.killer_info:SetValue(str)
	end
end

function WorldBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local min_level = BossData.Instance:GetBossCfgById(self.select_boss_id).min_lv
	if my_level >= min_level then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
		ViewManager.Instance:CloseAll()
		BossCtrl.Instance:SendEnterBossWorld(BossData.WORLD_BOSS_ENTER_TYPE.WORLD_BOSS_ENTER, self.select_boss_id)
	else
		local limit_text = string.format(Language.Common.ZhuanShneng, min_level)
		limit_text = string.format(Language.Common.CanNotEnter, limit_text)
		TipsCtrl.Instance:ShowSystemMsg(limit_text)
	end
end

function WorldBossView:QuestionClick()
	local tips_id = 140 -- 世界boss
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WorldBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.model_display.gameObject.activeInHierarchy then
		local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(boss_data.resid))
		self.model_view:SetTrigger("rest1")
	end
end

function WorldBossView:FlushItemList()
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	local item_list = boss_data.item_list
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			v:SetData({item_id = item_list[k]})
		else
			v:SetData(nil)
		end
	end
end

function WorldBossView:FlushInfoList()
	if self.select_boss_id ~= 0 then
		local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
		self:FlushItemList(boss_data.item_list)
		self:FlushModel()
	end
end

function WorldBossView:OnFlush()
	self:FlushBossView()
end

function WorldBossView:FlushBossView()
	self:FlushInfoList()
	local killer = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	self.iskill:SetValue(killer.status == 0)
	self.show_Red_Point:SetValue(killer.status == 1)
	if killer then
		if killer.last_kill_uid == 0 then
			self.killer_info:SetValue(Language.Boss.BossKiller)
		else
			if killer.last_kill_uid ~= nil then
				CheckCtrl.Instance:SendQueryRoleInfoReq(killer.last_kill_uid)
			end
		end
	end
	
end