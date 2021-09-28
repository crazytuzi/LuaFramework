TipsEneterCommonSceneView = TipsEneterCommonSceneView or BaseClass(BaseView)

function TipsEneterCommonSceneView:__init()
	self.ui_config = {"uis/views/tips/entercommonscenetip_prefab", "EnterCommonSceneView"}
	self.play_audio = true
	local config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").enterscene_view
	self.enter_cfg = ListToMap(config, "scene_id")
	self.view_layer = UiLayer.MainUIHigh
end

function TipsEneterCommonSceneView:__delete()
end

function TipsEneterCommonSceneView:ReleaseCallBack()
	-- 清理变量和对象
	self.name_iamge = nil
	self.text = nil
	self:RemoveDelay()
end

function TipsEneterCommonSceneView:LoadCallBack()
	self.name_iamge = self:FindVariable("NameImage")
	self.text = self:FindVariable("text")
	self.animator:ListenEvent("exit", function ()
		self:Close()
	end)
	self:RemoveDelay()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function ()
		self:Close()
	end, 5)
end

function TipsEneterCommonSceneView:OpenCallBack()
	self:Flush()
end

function TipsEneterCommonSceneView:CloseCallBack()

end

function TipsEneterCommonSceneView:SetSceneId(scene_id)
	self.scene_id = scene_id or 0

	local cfg = self.enter_cfg[scene_id]
	if nil == cfg then
		return
	end
	self:Open()
end

function TipsEneterCommonSceneView:OnFlush()
	local cfg = self.enter_cfg[self.scene_id]
	if nil == cfg then
		return
	end
	self.name_iamge:SetAsset(ResPath.GetRawImage("image_" .. cfg.show_ui .. ".png"))
	self.text:SetValue(cfg.show_ui)
	self:RemoveDelay()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function ()
		self:Close()
	end, 5)
end

function TipsEneterCommonSceneView:RemoveDelay()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end