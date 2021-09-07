FuBenFailFinishView = FuBenFailFinishView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.Beauty, ViewName.BaoJu, ViewName.FamousGeneralView
}

local VIEW_TABLE_INDEX = {
	TabIndex.forge_strengthen, TabIndex.AdvanceMountUp, TabIndex.beauty_info, TabIndex.baoju_zhibao, TabIndex.ming_jiang,
}

function FuBenFailFinishView:__init()
	self.ui_config = {"uis/views/fubenview", "FailFinishView"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].ShiBai) or 0
	end
	-- self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,
	-- 	BindTool.Bind(self.OnChangeScene, self))
	self.is_do_close = false
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

	self.show_button_panel = self:FindVariable("ShowButtonPanel")
	self.reward_item_list = {}
	for i = 0, 5 do
		self.reward_item_list[i] = {}
		self.reward_item_list[i].obj = self:FindObj("Item"..i)
		self.reward_item_list[i].cell = ItemCell.New()
		self.reward_item_list[i].cell:SetInstanceParent(self.reward_item_list[i].obj)
		self.reward_item_list[i].obj:SetActive(false)
	end
	-- self.scroll_rect = self:FindObj("ScrollRect").scroll_rect
	-- self.show_left_arrow = self:FindVariable("ShowLeftArrow")
	-- self.show_right_arrow = self:FindVariable("ShowRightArrow")

	-- self:Flush()

	self.is_show_tip = self:FindVariable("ShowText")
	self.tip_str = self:FindVariable("TextStr")
end

function FuBenFailFinishView:ReleaseCallBack()
	for k,v in pairs(self.reward_item_list) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.reward_item_list = {}

	if self.close_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
	if self.close_view ~= nil then
		GlobalEventSystem:UnBind(self.close_view)
		self.close_view = nil
	end

	self.show_button_panel = nil
	self.is_show_tip = nil
	self.tip_str = nil
end

function FuBenFailFinishView:OpenCallBack()
	self.is_do_close = false
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		self:AddTimerQuest()
	end
end

function FuBenFailFinishView:CloseCallBack()
	if self.close_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
end

function FuBenFailFinishView:OnClickClose()
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		if not self.is_do_close then
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		self.is_do_close = true
	else
		FuBenCtrl.Instance:SendExitFBReq()
	end
	self:Close()
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
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		if not self.is_do_close then
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		self.is_do_close = true
	else
		FuBenCtrl.Instance:SendExitFBReq()
	end
	self:Close()
end

function FuBenFailFinishView:AddTimerQuest()
	if self.close_timer_quest == nil then
		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 5)
	end
end

function FuBenFailFinishView:OnFlush(param_t)
	-- if Scene.Instance:GetSceneType() == SceneType.Common then
	-- 	if self.close_timer_quest == nil then
	-- 		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CloseView, self), 7)
	-- 	end
	-- end
	for k, v in pairs(param_t) do
		if k == "item_finish" then
			self.show_button_panel:SetValue(false)
			if v.data ~= nil then
				for i, j in pairs(self.reward_item_list) do
					if v.data[i] then
						j.cell:SetData(v.data[i])
						j.obj:SetActive(true)
					else
						j.obj:SetActive(false)
					end
				end
			end

			if self.is_show_tip ~= nil then
				self.is_show_tip:SetValue(v.tip_str ~= nil)
			end
		elseif k == "fail_tip" then
			if self.is_show_tip ~= nil then
				self.is_show_tip:SetValue(v.tip_str ~= nil)
			end
			
			if v.tip_str ~= nil then
				if self.tip_str ~= nil then
					self.tip_str:SetValue(v.tip_str)
				end
			end			
		end
	end
end