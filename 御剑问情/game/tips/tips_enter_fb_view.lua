TipsEnterFbView = TipsEnterFbView or BaseClass(BaseView)
local TIME = 15
function TipsEnterFbView:__init()
	self.ui_config = {"uis/views/tips/enterfbtips_prefab", "EnterFbTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsEnterFbView:__delete()

end

function TipsEnterFbView:LoadCallBack()
	self:ListenEvent("OnClose",
		BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickYes",
		BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo",
		BindTool.Bind(self.OnClickNo, self))
	self.head_list = {}
	for i = 1, 3 do
		self.head_list[i] = TipsEnterFbHeadCell.New(self:FindObj("Head" .. i))
	end
	self.value = self:FindVariable("Value")
	self.fb_name = self:FindVariable("FbName")
	self.slider = self:FindObj("Slider").slider
	self.agreed = self:FindVariable("agreed")
end

function TipsEnterFbView:ReleaseCallBack()
	for k,v in pairs(self.head_list) do
		v:DeleteMe()
	end
	self.head_list = {}
	self:RemoveCountDown()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end
	self.slider = nil
	self.fb_name = nil
	self.value = nil
	self.agreed = nil
end

function TipsEnterFbView:OpenCallBack()
	self:Flush()
	self:StartCountDown()
	self.agreed:SetValue(false)
end

function TipsEnterFbView:CloseCallBack()
	self:RemoveCountDown()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end
end

function TipsEnterFbView:OnClose()
	self:OnClickNo()
end

function TipsEnterFbView:StartCountDown()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(
		TIME, 1, BindTool.Bind(self.CountDown, self))
	self.value:SetValue(TIME)
	self.slider.value = 0
	self.tweener = self.slider:DOValue(1, TIME, false)
	self.tweener:SetEase(DG.Tweening.Ease.Linear)
end

function TipsEnterFbView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsEnterFbView:CountDown(elapse_time, total_time)
	self.value:SetValue(math.ceil(total_time - elapse_time))
	if total_time - elapse_time <= 0 then
		self:OnClickYes()
		self:Close()
	end
end

function TipsEnterFbView:OnClickYes()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.ENTER_AFFIRM, TeamMemberState.AGREE_STATE)
	self.agreed:SetValue(true)
end

function TipsEnterFbView:OnClickNo()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.ENTER_AFFIRM, TeamMemberState.REJECT_STATE)
	self:Close()
end

function TipsEnterFbView:OnFlush()
	local fb_info = FuBenData.Instance:GetTeamFbRoomEnterAffirm()
	local fb_name = ""
	if fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		fb_name = Language.FuBen.ExpFuBen
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
		local config = FuBenData.Instance:GetShowConfigByLayer(fb_info.layer)
		if config then
			fb_name = config.name or ""
		end
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
		fb_name = Language.FuBen.TeamFbName[1]
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		fb_name = Language.FuBen.TeamFbName[2]
	elseif fb_info.team_type == FuBenTeamType.TEAM_TYPE_YAOSHOUJITANG then
		fb_name = Language.FuBen.TeamFbName[3]
	end
	self.fb_name:SetValue(fb_name)

	if ScoietyData.Instance:GetTeamState() then
		local info = ScoietyData.Instance:GetTeamInfo()
		if info and next(info) then
			for i = 1, 3 do
				local head = self.head_list[i]
				if head then
					local data = info.team_member_list[i]
					head:SetData(data)
					if data then
						-- 有人拒绝
						if data.fbroom_read == TeamMemberState.REJECT_STATE then
							SysMsgCtrl.Instance:ErrorRemind(string.format(Language.FuBen.Refuse, data.name))
							self:Close()
							return
						end
					end
				end
			end
		end
	else
		for k,v in pairs(self.head_list) do
			v:SetActive(false)
		end
	end
end

-------------------------------------------------玩家信息------------------------------------------------

TipsEnterFbHeadCell = TipsEnterFbHeadCell or BaseClass(BaseCell)

function TipsEnterFbHeadCell:__init()
	self.name = self:FindVariable("Name")
	self.head = self:FindVariable("Head")
	self.is_prepare = self:FindVariable("IsPrepare")
	self.portrait = self:FindObj("portrait")
	self.portrait_raw = self:FindObj("portrait_raw")
end

function TipsEnterFbHeadCell:__delete()

end

function TipsEnterFbHeadCell:OnFlush()
	if self.data then
		self:SetActive(true)
		CommonDataManager.SetAvatar(self.data.role_id, self.portrait_raw, self.portrait, self.head, self.data.sex, self.data.prof, false)
		self.name:SetValue(self.data.name)
		self.is_prepare:SetValue(self.data.fbroom_read == TeamMemberState.AGREE_STATE)
	else
		self:SetActive(false)
	end
end