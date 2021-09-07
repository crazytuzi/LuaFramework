ActtackModeView = ActtackModeView or BaseClass(BaseView)

function ActtackModeView:__init()
	self.view_layer = UiLayer.MainUIHigh
	self.ui_config = {"uis/views/main", "AttackModeView"}
end

function ActtackModeView:__delete()

end

function ActtackModeView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("SwitchPeaceMode", BindTool.Bind(self.SwitchPeaceMode, self))
	self:ListenEvent("SwitchTeamMode", BindTool.Bind(self.SwitchTeamMode, self))
	self:ListenEvent("SwitchGuildMode", BindTool.Bind(self.SwitchGuildMode, self))
	self:ListenEvent("SwitchAllMode", BindTool.Bind(self.SwitchAllMode, self))
	self:ListenEvent("SwitchColorMode", BindTool.Bind(self.SwitchColorMode, self))
	self:ListenEvent("SwitchCampMode", BindTool.Bind(self.SwitchCampMode, self))
	self:ListenEvent("SwitchAllianceMode", BindTool.Bind(self.SwitchAllianceMode, self))
	self:ListenEvent("CloseMode", BindTool.Bind(self.CloseMode, self))
end

function ActtackModeView:CloseMode()
	self:Close()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

--攻击模式改变	--和平
function ActtackModeView:SwitchPeaceMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsFamilyBossScene(scene_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit1)
		return
	end
	if scene_id == 4501 or scene_id == 2303 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit1)
		return
	end
	if KuafuGuildBattleData.Instance:IsLiuJieScene(scene_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CantOpenInCross)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

function ActtackModeView:SwitchTeamMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_TEAM)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

--家族
function ActtackModeView:SwitchGuildMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 4501 or scene_id == 2303 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit3)
		return
	end
	if KuafuGuildBattleData.Instance:IsLiuJieScene(scene_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CantOpenInCross)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

function ActtackModeView:SwitchAllMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 4501 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit4)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

function ActtackModeView:SwitchColorMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_NAMECOLOR)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

--国家
function ActtackModeView:SwitchCampMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

--同盟
function ActtackModeView:SwitchAllianceMode()
	self:Close()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == 1002 or scene_id == 1003 or scene_id == 3001 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SceneLimit6)
		return
	end
	if KuafuGuildBattleData.Instance:IsLiuJieScene(scene_id) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CantOpenInCross)
		return
	end
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALLIANCE)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end