-- 星魂boss

local XhBossView = BaseClass(SubView)

function XhBossView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"new_boss_ui_cfg", 12, {0}},
	}

	require("scripts/game/newly_boss/nrare_boss/rexue_boss_rank").New(ViewDef.ReXueBossRank, self)
end

function XhBossView:__delete()
end

function XhBossView:LoadCallBack(index, loaded_times)
	self:CreateAwardCells()
	self:CreateMonsterAnimation()
	self.select_index = 1

	XUI.AddClickEventListener(self.node_t_list.layout_rexue_boss.btn_challenge.node, BindTool.Bind(self.OnClickChallengeHandler, self))
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.NEWLY_BOSS_REMIND, BindTool.Bind(self.Flush, self))

	RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, Language.DescTip.ReXueBossContent, 18)
	
	self.node_t_list.lbl_lv_need.node:setString(ModBossConfig[7][1].circle .. "转" .. ModBossConfig[7][1].level .. "级")
end

function XhBossView:ShowIndexCallBack()
	self:Flush()
end

function XhBossView:ReleaseCallBack()
	if self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil 
	end

	if self.award_cell_list  then
		for k,v in pairs(self.award_cell_list ) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end
	GlobalEventSystem:UnBind(self.scene_change)

	self:DeleteResumeTimer()
end

function XhBossView:CreateMonsterAnimation()
	if nil == self.monster_display then
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_rexue_boss.node, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(300,200)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(2)
	end

	self.monster_display:Show(BossData.GetMosterCfg(ReXueBaZheBossCfg.boss.bossid).modelid)
end

function XhBossView:CreateAwardCells()
	if nil ~= self.award_cell_list then
		return
	end

	self.award_cell_list = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_award_cell_" .. i]
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_rexue_boss.node:addChild(cell:GetView(), 20)
		table.insert(self.award_cell_list, cell)
	end

	local drop_list = {}
	for k,v in pairs(ModBossConfig[7][1].drops) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	for k, v in pairs(self.award_cell_list) do
		v:SetData(drop_list[k])
	end
end


function XhBossView:OnFlush(param_t)
	self:FlushResumeTimer()
end

function XhBossView:TimerFunc()
	local time = NewlyBossData.Instance:GetReXueBossResumeTime()
	if time <= 0 then
		self:DeleteResumeTimer()
	else
		self.node_t_list.lbl_flush_time.node:setString(TimeUtil.FormatSecond2Str(time))
	end
end

function XhBossView:FlushResumeTimer()
	if nil == self.resume_timer and not NewlyBossData.Instance:ReXueBossIsFlush() then
		self.resume_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:TimerFunc()
		end, 1)
		self:TimerFunc()
	else
		self.node_t_list.lbl_flush_time.node:setString("已刷新")
	end
end

function XhBossView:DeleteResumeTimer()
	if self.resume_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.resume_timer)
		self.resume_timer = nil
	end
end

function XhBossView:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE then 
			self:Flush()
	end
end

function XhBossView:OnBossStateChange()
	self:Flush()
end

function XhBossView:FlushAwardList(data_list)
	for k,v in pairs(ModBossConfig[7][1].boss_drop) do
		drop_list[#drop_list + 1] = {item_id = v.id, num = 1, is_bind = v.bind}
	end
	for k, v in pairs(self.award_cell_list) do
		v:SetData(drop_list[k])
	end
end


function XhBossView:OnClickChallengeHandler()
	BossCtrl.CSChuanSongBossScene(7, ReXueBaZheBossCfg.boss.bossid)
end

function XhBossView:SceneChange()
	local fuben_type = Scene.Instance:GetSceneLogic():GetFubenType()
	if fuben_type == FubenType.PersonalBoss then 
		ViewManager.Instance:CloseViewByDef(ViewDef.Boss)
	end
end

return XhBossView