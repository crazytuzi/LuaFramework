ActtackModeView = ActtackModeView or BaseClass(BaseView)

function ActtackModeView:__init()
	self.view_layer = UiLayer.MainUIHigh
	self.ui_config = {"uis/views/main_prefab", "AttackModeView"}
end

function ActtackModeView:__delete()

end

function ActtackModeView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("SwitchPeaceMode",
		BindTool.Bind(self.SwitchPeaceMode, self))
	self:ListenEvent("SwitchTeamMode",
		BindTool.Bind(self.SwitchTeamMode, self))
	self:ListenEvent("SwitchGuildMode",
		BindTool.Bind(self.SwitchGuildMode, self))
	self:ListenEvent("SwitchAllMode",
		BindTool.Bind(self.SwitchAllMode, self))
	self:ListenEvent("SwitchColorMode",
		BindTool.Bind(self.SwitchColorMode, self))
	self:ListenEvent("CloseMode",
		BindTool.Bind(self.CloseMode, self))

end

function ActtackModeView:CloseMode()
	self:Close()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end

--攻击模式改变
function ActtackModeView:SwitchPeaceMode()
	self:Close()
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

function ActtackModeView:SwitchGuildMode()
	self:Close()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, true, true)
end


function ActtackModeView:SwitchAllMode()
	self:Close()
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