FuBenFailFinishView = FuBenFailFinishView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.SpiritView, ViewName.Goddess, ViewName.BaoJu
}

local VIEW_TABLE_INDEX = {
	TabIndex.forge_strengthen, TabIndex.mount_jinjie, TabIndex.spirit_spirit, TabIndex.goddess_info, TabIndex.baoju_zhibao_active,
}

function FuBenFailFinishView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "FailFinishView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].ShiBai) or 0
	end
	-- self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,
	-- 	BindTool.Bind(self.OnChangeScene, self))
	-- self.is_do_close = false
end

function FuBenFailFinishView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickButton1",
		BindTool.Bind(self.OnClickButton, self, 1))
	self:ListenEvent("OnClickButton2",
		BindTool.Bind(self.OnClickButton, self, 2))
	self:ListenEvent("OnClickButton3",
		BindTool.Bind(self.OnClickButton, self, 3))
	self:ListenEvent("OnClickButton4",
		BindTool.Bind(self.OnClickButton, self, 4))
	self:ListenEvent("OnClickButton5",
		BindTool.Bind(self.OnClickButton, self, 5))

	-- self.scroll_rect = self:FindObj("ScrollRect").scroll_rect
	-- self.show_left_arrow = self:FindVariable("ShowLeftArrow")
	-- self.show_right_arrow = self:FindVariable("ShowRightArrow")
	self.ok_fun = nil
	self:Flush()
end

function FuBenFailFinishView:ReleaseCallBack()
	if self.close_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
	self.ok_fun = nil
	-- if self.close_view ~= nil then
	-- 	GlobalEventSystem:UnBind(self.close_view)
	-- 	self.close_view = nil
	-- end
end

function FuBenFailFinishView:OpenCallBack()
	-- self.is_do_close = false
	-- if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		self:AddTimerQuest()
	-- end
end

function FuBenFailFinishView:CloseCallBack()
	if self.close_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
	FuBenCtrl.Instance:SendExitFBReq()
end

function FuBenFailFinishView:OnClickClose()
	if self.ok_fun then
		self.ok_fun()
	end

	self:Close()
end

function FuBenFailFinishView:SetOKCallback(fun)
	self.ok_fun = fun
end

-- function FuBenFailFinishView:OnChangeScene()
-- 	if self:IsOpen() then
-- 		self:Flush()
-- 	end
-- end

function FuBenFailFinishView:OnClickButton(index)
	ViewManager.Instance:Open(ViewNameList[index], VIEW_TABLE_INDEX[index])
	self:Close()
end

function FuBenFailFinishView:CloseView()
	self:Close()
end

function FuBenFailFinishView:AddTimerQuest()
	if self.close_timer_quest == nil then
		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 8)
	end
end

-- function FuBenFailFinishView:OnFlush(param_t)
-- 	if Scene.Instance:GetSceneType() == SceneType.Common then
-- 		if self.close_timer_quest == nil then
-- 			self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 7)
-- 		end
-- 	end
-- end