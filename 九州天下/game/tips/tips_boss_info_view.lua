TipsBossInfoView = TipsBossInfoView or BaseClass(BaseView)

function TipsBossInfoView:__init()
	self.ui_config = {"uis/views/tips/bossinfotips", "BossInfoTipView"}
	self.boss_id = 0
	self.boss_info = {}
	self.play_audio = true
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.view_layer = UiLayer.Pop
end

function TipsBossInfoView:__delete()
	self.boss_id = nil
	self.boss_info = {}
end

function TipsBossInfoView:ReleaseCallBack()
	-- 清理变量和对象
	self.last_kill = nil
	self.scene_name = nil
	self.flush_time = nil
	self.fight_power = nil
	self.boss_name = nil
end

function TipsBossInfoView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickMoveTo", BindTool.Bind(self.OnClickMoveTo, self))

	self.last_kill = self:FindVariable("Lastkill")
	self.scene_name = self:FindVariable("SceneNane")
	self.flush_time = self:FindVariable("FlushTime")
	self.fight_power = self:FindVariable("FightPower")
	self.boss_name = self:FindVariable("BossName")
end

function TipsBossInfoView:OpenCallBack()
	if not self.scene_load_enter then
		self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
			BindTool.Bind(self.OnChangeScene, self))
	end
	self:Flush()
end

function TipsBossInfoView:CloseCallBack()
	self.boss_id = 0
	self.boss_info = {}
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function TipsBossInfoView:OnClose()
	self:Close()
end

function TipsBossInfoView:OnClickMoveTo()
	if self.boss_info.boss_type > 0 then
		local free_vip_level, cost_gold = BossData.Instance:GetBossVipLismit(self.boss_info.scene_id)
		local vo_vip = GameVoManager.Instance:GetMainRoleVo().vip_level

		local ok_fun = function()
			BossData.Instance:SetCurInfo(self.boss_info.scene_id, self.boss_id)
			BossCtrl.SendEnterBossFamily(self.boss_info.boss_type, self.boss_info.scene_id)
		end

		if vo_vip < free_vip_level then
			local str = string.format(Language.Boss.BossFamilyLimitStr, cost_gold)
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, str)
			return
		end
		ok_fun()
	else
		GuajiCtrl.Instance:FlyToScenePos(self.boss_info.scene_id, self.boss_info.born_x, self.boss_info.born_y, true)
		-- GuajiCtrl.Instance:MoveToPos(self.boss_info.scene_id, self.boss_info.born_x, self.boss_info.born_y, 4, 2)
	end
end

function TipsBossInfoView:OnChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end

function TipsBossInfoView:SetBossId(boss_id)
	self.boss_id = boss_id or 0
end

function TipsBossInfoView:OnFlush()
	local boss_info = KaifuActivityData.Instance:GetBossInfoById(self.boss_id)--BossData.Instance:GetWorldBossInfoById(self.boss_id) --

	if not boss_info then
		return
	end
	self.boss_info = boss_info
	-- self.last_kill:SetValue(boss_info.last_kill_name ~= "" and boss_info.last_kill_name or "暂无")
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	self.scene_name:SetValue(scene_config.name)

	-- local refresh_time_str = os.date("%H:00", BossData.Instance:GetBossNextReFreshTime())
	-- if BossData.Boss_State.ready == boss_info.status then
	-- 	refresh_time_str = "存活"
	-- end
	-- self.flush_time:SetValue(refresh_time_str)

	local zhan_li_text = ""
	if GameVoManager.Instance:GetMainRoleVo().capability >= boss_info.boss_capability then
		zhan_li_text = ToColorStr(boss_info.boss_capability, TEXT_COLOR.GREEN)
	else
		zhan_li_text = ToColorStr(boss_info.boss_capability, TEXT_COLOR.RED)
	end
	self.fight_power:SetValue(zhan_li_text)

	if self.monster_cfg[self.boss_id] then
		self.boss_name:SetValue(self.monster_cfg[self.boss_id].name)
	end
end