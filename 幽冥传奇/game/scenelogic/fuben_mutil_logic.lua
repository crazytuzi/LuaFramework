FubenMutilLogic = FubenMutilLogic or BaseClass(BaseFbLogic)

function FubenMutilLogic:__init()
	self.fuben_id = 0
	self.stop_sub = false
end

function FubenMutilLogic:__delete()
	self:CancelTimer()
	self:UnBindEvent()
	if self.exit_alert then
		self.exit_alert:DeleteMe()
		self.exit_alert = nil
	end
end

function FubenMutilLogic:Enter(old_scene_type, new_scene_type)	
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseViewByDef(ViewDef.FubenMulti)
    FubenMutilCtrl.Instance:CloseMenListAlert()
	FubenMutilCtrl.Instance:CloseActivedAlert()
	FubenMutilData.Instance:SetCurKilledNum(0)
	FubenMutilCtrl.SendGetFubenEnterTimes(FubenMutilType.Team)

	self.cur_turn = 1 
    
	-- GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.RIGHT)
	self:StartCutdown()
	if self.fuben_id == FubenMutilId.Team then
		self.result_event = GlobalEventSystem:Bind(OtherEventType.FIRST_FLOOR_RESULT, BindTool.Bind(self.OnFirstFloorResult, self))
	end

	if self.fuben_id == FubenMutilId.Team_2 then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	end
end

function FubenMutilLogic:Out()
	BaseFbLogic.Out(self)

	FubenMutilData.Instance:SetCurKilledNum(0)

	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
	-- GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)

	self:CancelTimer()
	self:UnBindEvent()
end

function FubenMutilLogic:SetFubenId(fuben_id)
	self.fuben_id = fuben_id
end

function FubenMutilLogic:StartCutdown()
	local scene_id = Scene.Instance:GetSceneId()
	if self.fuben_id == FubenMutilId.Team and scene_id == FubenMutilSceneId.Team then
		self.turns_secs = FubenMutilData.GetTurnsRefreshTimes(FubenMutilType.Team, FubenMutilLayer[FubenMutilSceneId.Team])
	end
	self.total_secs = FubenMutilData.GetFloorRefreshTimes(FubenMutilType.Team, self.fuben_id)
	self.total_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnTotalTimerCallback, self), 1)
end

function FubenMutilLogic:CancelTimer()
	if self.total_timer then
		GlobalTimerQuest:CancelQuest(self.total_timer)
		self.total_timer = nil
	end
end

function FubenMutilLogic:UnBindEvent()
	if self.result_event then
		GlobalEventSystem:UnBind(self.result_event)
		self.result_event = nil
	end
end

function FubenMutilLogic:OnTotalTimerCallback()
	if not self.stop_sub then
		self.total_secs = self.total_secs - 1 < 0 and 0 or self.total_secs - 1
		if self.total_secs <= 0 then
			FubenMutilCtrl.SendExitFubenRequest(self.fuben_id)
		end
	end

	if self.turns_secs then
		self.turns_secs = self.turns_secs - 1 < 0 and 0 or self.turns_secs - 1
		if self.turns_secs == 0 then
			self.stop_sub = true
		end
	end

	self:UpdateTaskGuideData(FubenMutilType.Team, self.fuben_id)

	local max_kill_num = FubenMutilData.GetNeedKilledNum(FubenMutilType.Team, self.fuben_id)
	local cur_kill_num = FubenMutilData.Instance:GetCurKilledNum()
	local scene_id = Scene.Instance:GetSceneId()
	if cur_kill_num >= max_kill_num then
		if FubenMutilLayer[scene_id] then
			FubenMutilCtrl.Instance:OpenFubenActiveAlert(cur_kill_num, max_kill_num, 10)
		end
	end
end

function FubenMutilLogic:OnFirstFloorResult(result)
	if result == 1 then

	elseif result == 0 then
		if self.total_secs <= 0 then
			FubenMutilCtrl.SendExitFubenRequest(self.fuben_id)
		elseif self.fuben_id == FubenMutilId.Team then
			local scene_id = Scene.Instance:GetSceneId()
			if FubenMutilLayer[scene_id] then
				self.turns_secs = FubenMutilData.GetTurnsRefreshTimes(FubenMutilType.Team, FubenMutilLayer[scene_id])
				local total_secs = FubenMutilData.GetFloorRefreshTimes(FubenMutilType.Team, self.fuben_id)
				self.total_secs = total_secs - (self.cur_turn * self.turns_secs)
				self.cur_turn = self.cur_turn + 1
				self.stop_sub = false
				FubenMutilData.Instance:SetCurKilledNum(0)
				self:ShowFailedTips()
				FubenMutilCtrl.Instance:CloseActivedAlert()
			end
		end
	end
end

function FubenMutilLogic:ShowFailedTips()
	local screen_width, screen_height = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	local bg = XUI.CreateImageView(screen_width / 2, screen_height / 2 + 200, ResPath.GetScene("fb_bg_101"))
	local size = bg:getContentSize()
	local img_failed = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetScene("fb_fail_word_4"))
	img_failed:setGrey(true)
	bg:addChild(img_failed)
	HandleRenderUnit:AddUi(bg, 100)

	local fade_out = cc.FadeOut:create(5)
	local call_back = cc.CallFunc:create(function()
		bg:removeFromParent()
	end)

	bg:runAction(cc.Sequence:create(fade_out, call_back))
end

function FubenMutilLogic:UpdateTaskGuideData(fuben_type, fuben_id)
	-- local btns = {
	-- 	["tips"] = {
	-- 		path = ResPath.GetCommon("part_100"),
	-- 		x = MainuiTask.Size.width - 30,
	-- 		y = MainuiTask.Size.height - 90,
	-- 		event = function()
	-- 			local max_times = FubenMutilData.GetFubenMaxEnterTimes(fuben_type)
	-- 			local used_times = FubenMutilData.Instance:GetFubenUsedTimes(fuben_type)
	-- 			local left_times = max_times - used_times
	-- 			local desc = string.format(Language.FubenMutil.Desc, left_times <= 0 and "ff0000" or "00ff00", left_times, max_times)
	-- 			DescTip.Instance:SetContent(desc, Language.FubenMutil.TipTitle)
	-- 		end,
	-- 	}
	-- }
	
	-- local opt_btns = nil
	-- local max_kill_num = FubenMutilData.GetNeedKilledNum(fuben_type, fuben_id)
	-- local cur_kill_num = FubenMutilData.Instance:GetCurKilledNum()
	-- if cur_kill_num > max_kill_num then
	-- 	cur_kill_num = max_kill_num
	-- end
	-- opt_btns = {
	-- 	["out"] = {
	-- 		title = Language.Fuben.ExitFuben,
	-- 		event = function()
	-- 			if FubenMutilData.Instance:GetCurKilledNum() < FubenMutilData.GetNeedKilledNum(fuben_type, fuben_id) then
	-- 				self.exit_alert = self.exit_alert or Alert.New()
	-- 				self.exit_alert:SetLableString(Language.Fuben.ExitFubenAlert)
	-- 				self.exit_alert:SetOkFunc(function()
	-- 					FubenMutilCtrl.SendExitFubenRequest(fuben_id)
	-- 				end)
	-- 				self.exit_alert:SetCancelString(Language.Common.Cancel)
	-- 				self.exit_alert:SetOkString(Language.Common.Confirm)
	-- 				self.exit_alert:SetShowCheckBox(false)
	-- 				self.exit_alert:Open()
	-- 			else
	-- 				FubenMutilCtrl.SendExitFubenRequest(fuben_id)
	-- 			end
	-- 		end
	-- 	},
	-- }
	
	-- local award_items = FubenMutilData.GetFubenAwardList(fuben_type, fuben_id)
    -- local team_info = FubenMutilData.Instance:GetMyTeamInfo(fuben_type, FubenMutilId.Team)
	-- local fuben_name = FubenMutilData.GetFubenName(fuben_type, fuben_id)

	-- local data = {
	-- 	[OTHER_TASK_GUIDE.RIGHT] = {
	-- 		guide_name  = MainuiTask.GUIDE_NAME.FB_MUTILPLAYER,
	-- 		btn_path    = "task_btn_fuben",
	-- 		render      = FubenMutilRender,
	-- 		render_data = {
	-- 			btns           = btns, 
	-- 			items          = award_items, 
	-- 			team_info      = team_info, 
	-- 			fuben_name     = fuben_name, 
	-- 			max_kill_num   = max_kill_num, 
	-- 			cur_kill_num   = cur_kill_num,
	-- 			turns_time     = self.turns_secs,
	-- 			total_time     = self.total_secs,
	-- 			fuben_id	   = fuben_id,
	-- 		},
	-- 	},
	-- 	[OTHER_TASK_GUIDE.BOTTOM] = {
	-- 		guide_name = MainuiTask.GUIDE_NAME.FB_MUTILPLAYER,
	-- 		render_data = {btns = opt_btns, parent_panel = OTHER_TASK_GUIDE.RIGHT},
	-- 	},
	-- }
	
	-- GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, data)
end