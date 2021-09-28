GirlGuideView = GirlGuideView or BaseClass(BaseView)

local GirlResId = 4028001

function GirlGuideView:__init()
	self.ui_config = {"uis/views/guideview_prefab","GirlGuideView"}
	self.step_cfg = {}
	self.view_layer = UiLayer.Guide
end

function GirlGuideView:__delete()

end

function GirlGuideView:ReleaseCallBack()
	if self.girl_model then
		self.girl_model:DeleteMe()
		self.girl_model = nil
	end

	if self.audio_item then
		ScriptablePool.Instance:Free(self.audio_item)
		self.audio_item = nil
		self.audio_player = nil
	end

	self:RemoveTimerQuest()

	-- 清理变量和对象
	self.girl_des = nil
	self.girl_guide = nil
	self.display = nil
	self.girl_image = nil
	self.bg = nil
end

function GirlGuideView:LoadCallBack()
	--获取变量
	self.girl_des = self:FindVariable("GirlDes")

	--获取组件
	self.girl_guide = self:FindObj("GirlGuide")
	self.display = self:FindObj("Display")
	self.girl_image = self:FindVariable("GirlImage")					--美女图片

	self.bg = self:FindObj("Bg")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function GirlGuideView:SetClickCallBack(callback)
	self.click_call_back = callback
end

function GirlGuideView:SetIsNeedCloseOnClick(value)
	self.is_need_close = value
end

function GirlGuideView:CloseWindow()
	if self.is_need_close then
		if self.bg then
			self.bg.canvas_group.blocksRaycasts = false
		end
		self.girl_guide.canvas_group.blocksRaycasts = false
		self:Close()
		self.step_cfg = {}
	end
	FunctionGuide.Instance:StartNextStep()
end

function GirlGuideView:CreateModel()
	-- local bunble, asset = ResPath.GetGuideRes("GuideGirl")
	-- self.girl_image:SetAsset(bunble, asset)
end

function GirlGuideView:OpenCallBack()
	self.bg.canvas_group.blocksRaycasts = true
	self.girl_guide.canvas_group.blocksRaycasts = true
	self:CreateModel()
	local audio_id = self.step_cfg.offset_x
	if audio_id and audio_id ~= "" then
		local bundle, asset = ResPath.GetVoiceRes(audio_id)
		ScriptablePool.Instance:Load(AssetID(bundle, asset), function(audio_item)
			self:RemoveTimerQuest()
			if not self:IsOpen() then
				return
			end

			if nil == audio_item then
				return
			end
			self.audio_item = audio_item
			self.audio_player = AudioManager.Play(audio_item)
		 	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
				if not UtilU3d.AudioPlayerIsPlaying(self.audio_player) then
					self:RemoveTimerQuest()
					self:CloseWindow()
				end
			end, 0.1)
		end)
	end
end

function GirlGuideView:RemoveTimerQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GirlGuideView:CloseCallBack()
	if self.audio_item then
		ScriptablePool.Instance:Free(self.audio_item)
		self.audio_item = nil
		self.audio_player = nil
	end

	self:RemoveTimerQuest()
end

function GirlGuideView:OnFlush()
	self.girl_des:SetValue(self.step_cfg.arrow_tip)
end

function GirlGuideView:SetArrowDes(des)
	self.des = des
end

function GirlGuideView:SetStepCfg(cfg)
	self.step_cfg = cfg
end