
DaFuHaoView = DaFuHaoView or BaseClass(BaseView)

function DaFuHaoView:__init()
	self.ui_config =  {"uis/views/dafuhaoview_prefab", "DaFuHaoView"}
	self.view_layer = UiLayer.MainUI
	self.play_audio = true
	self.active_close = false
end

function DaFuHaoView:__delete()

end

function DaFuHaoView:LoadCallBack()
	self.info_conntent = self:FindObj("InfoContent")
	self.shrink_button = self:FindObj("ShrinkButton")
	self.info_view = DaFuHaoInfoView.New(self.info_conntent)

	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self.shrink_button.toggle:AddValueChangedListener(BindTool.Bind(self.OnShrinkToggleChange, self))

	self.change_fight_state_toggle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.ChangeFightStateToggle, self))
	local boss_id = DaFuHaoData.Instance:GetDaFuHaoCfg().other[1].boss_id
	--print_error(boss_id)
	FuBenCtrl.Instance:SetMonsterInfo(boss_id, 1)
end

function DaFuHaoView:ReleaseCallBack()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.change_fight_state_toggle then
		GlobalEventSystem:UnBind(self.change_fight_state_toggle)
		self.change_fight_state_toggle = nil
	end

	-- 清理变量和对象
	self.info_conntent = nil
	self.shrink_button = nil
end

function DaFuHaoView:ChangeFightStateToggle(value)
	self.info_view:SetActive(not value)
end

function DaFuHaoView:CloseCallBack()
	if self.info_view then
		self.info_view:CloseCallBack()
	end
end

function DaFuHaoView:OpenCallBack()
	self:Flush()
	if self.info_view then
		self.info_view:OpenCallBack()
	end
end

function DaFuHaoView:OnClickClose()
	self:Close()
end

function DaFuHaoView:OnShrinkToggleChange(isOn)
	GlobalEventSystem:Fire(MainUIEventType.SHRINK_DAFUHAO_INFO, isOn)
end

function DaFuHaoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "boss" then
			self:SetBossInfo()
		else
			if self.info_view then
				self.info_view:Flush()
			end
			self:SetBossInfo()
		end
	end
end

function DaFuHaoView:SetBossInfo()
	local info = DaFuHaoData.Instance:GetBossFlushData()
	if nil == next(info) then return end

	local boss_flush_time = math.floor(info.next_millionaire_boss_refresh_time - TimeCtrl.Instance:GetServerTime())
	FuBenCtrl.Instance:SetMonsterDiffTime(boss_flush_time)

	FuBenCtrl.Instance:SetMonsterIconState(true)

	local str = Language.ShengXiao.ClickGoTo2
	-- str=string.gsub(str,'1 / 1','')--替换字符串

	FuBenCtrl.Instance:ShowMonsterHadFlush(boss_flush_time <= 0 , str)
end