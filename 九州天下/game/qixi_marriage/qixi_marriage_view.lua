QiXiMarriageView = QiXiMarriageView or BaseClass(BaseView)

function QiXiMarriageView:__init()
	self.ui_config = {"uis/views/qiximarriageview","QiXiMarriageView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.full_screen = true
	self:SetMaskBg()
end

function QiXiMarriageView:__delete()

end

function QiXiMarriageView:LoadCallBack()

	self.have_wedding = self:FindVariable("have_wedding")
	self.is_my_wedding = self:FindVariable("is_my_wedding")
	self.wedding_countdown_str = self:FindVariable("wedding_countdown_str")
	self.wedding_countdown = self:FindVariable("wedding_countdown")
	self.duration = self:FindVariable("duration")
	self.activity_countdown = self:FindVariable("activity_countdown")
	self.left_image_res = self:FindVariable("left_image_res")
	self.right_image_res = self:FindVariable("right_image_res")
	self.left_image_state = self:FindVariable("left_image_state")			
	self.right_image_state = self:FindVariable("right_image_state")		
	self.left_name = self:FindVariable("left_name")
	self.right_name = self:FindVariable("right_name")
	self.duration = self:FindVariable("duration")
	self.price = self:FindVariable("price")

	self.left_rawimage = self:FindObj("LeftRawImage")
	self.right_rawimage = self:FindObj("RightRawImage")

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickDemand", BindTool.Bind(self.OnClickDemand, self))
	self:ListenEvent("ClickInvite", BindTool.Bind(self.OnClickInvite, self))
	self:ListenEvent("ClickReservation", BindTool.Bind(self.OnClickReservation, self))
end

function QiXiMarriageView:ReleaseCallBack()
	self.have_wedding = nil
	self.is_my_wedding = nil
	self.wedding_countdown_str = nil
	self.wedding_countdown = nil
	self.duration = nil
	self.activity_countdown = nil
	self.left_image_res = nil
	self.right_image_res = nil
	self.left_image_state = nil			
	self.right_image_state = nil	
	self.left_name = nil
	self.right_name = nil
	self.duration = nil
	self.price = nil

	self.left_rawimage = nil
	self.right_rawimage = nil
end

function QiXiMarriageView:OpenCallBack()
	self.price:SetValue(QiXiMarriageData.Instance:GetLuxuryPrice())
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_MARRIAGE)
	self:Flush()
	self:FlushAllTime()
	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushAllTime, self), 1)
	end
end

function QiXiMarriageView:FlushAllTime()
	local activity_countdown = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_MARRIAGE) --2192
	local activity_countdown_t = TimeUtil.Format2TableDHMS(activity_countdown)
	if activity_countdown_t.day > 0 then
		self.activity_countdown:SetValue(TimeUtil.FormatSecond2DHMS(activity_countdown, 1))
	else
		self.activity_countdown:SetValue(TimeUtil.FormatSecond2HMS(activity_countdown))
	end

	local wedding_countdown = QiXiMarriageData.Instance:GetBeginTime() - TimeCtrl.Instance:GetServerTime()
	if wedding_countdown < 0 then
		local remaining_countdown = QiXiMarriageData.Instance:GetEndTime() - TimeCtrl.Instance:GetServerTime()
		if remaining_countdown < 0 then
			self.have_wedding:SetValue(false)
			self.wedding_countdown_str:SetValue(Language.Marriage.NoWedding)
		else
			self.have_wedding:SetValue(true)
			self.wedding_countdown_str:SetValue(Language.Marriage.WeddingCountDown2)
			self.wedding_countdown:SetValue(TimeUtil.FormatSecond(remaining_countdown, 4))
		end
	else
		self.have_wedding:SetValue(true)
		self.wedding_countdown_str:SetValue(Language.Marriage.WeddingCountDown1)
		self.wedding_countdown:SetValue(TimeUtil.FormatSecond(wedding_countdown, 1))
	end
end

function QiXiMarriageView:OnClickClose()
	self:Close()
end

function QiXiMarriageView:CloseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function QiXiMarriageView:OnFlush()
	local role_vo = QiXiMarriageData.Instance:GetCpInfo()
	local self_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == role_vo or nil == next(role_vo) then return end

	if 0 == role_vo[1].uid or 0 == role_vo[2].uid then 
		self.have_wedding:SetValue(false)
	else
		self.have_wedding:SetValue(true)
		self.is_my_wedding:SetValue(role_vo[1].uid == self_vo.role_id or role_vo[2].uid == self_vo.role_id)
		self.left_name:SetValue(role_vo[1].name)
		self.right_name:SetValue(role_vo[2].name)
	
		local begin_time_t = os.date("*t", QiXiMarriageData.Instance:GetBeginTime()) 
		local end_time_t = os.date("*t", QiXiMarriageData.Instance:GetEndTime())
		local time_str = string.format("%02d:%02d - %02d:%02d", begin_time_t.hour, begin_time_t.min, end_time_t.hour, end_time_t.min)
		self.duration:SetValue(time_str)
		
		self:SetLeftPortrait(role_vo[1])
		self:SetRightPortrait(role_vo[2])
	end
end

function QiXiMarriageView:SetLeftPortrait(role_vo)
	if role_vo == nil then return end

	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_vo.uid)
	if AvatarManager.Instance:isDefaultImg(role_vo.uid) == 0 or avatar_path_small == 0 then
		self.left_image_state:SetValue(false)
		local bundle, asset = AvatarManager.GetDefAvatar(role_vo.prof, false, role_vo.sex)
		self.left_image_res:SetAsset(bundle, asset)
	else
		self.left_image_state:SetValue(true)
		local function callback(path)
			if IsNil(self.left_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_vo.uid, false)
			end
			self.left_rawimage.raw_image:LoadSprite(path, function ()
					
			end)
		end
		AvatarManager.Instance:GetAvatar(role_vo.uid, false, callback)
	end
end

function QiXiMarriageView:SetRightPortrait(role_vo)
	if role_vo == nil then return end

	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_vo.uid)
	if AvatarManager.Instance:isDefaultImg(role_vo.uid) == 0 or avatar_path_small == 0 then
		self.right_image_state:SetValue(false)
		local bundle, asset = AvatarManager.GetDefAvatar(role_vo.prof, false, role_vo.sex)
		self.right_image_res:SetAsset(bundle, asset)
	else
		self.right_image_state:SetValue(true)
		local function lovercallback(path)
			if IsNil(self.right_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_vo.uid, false)
			end
			self.right_rawimage.raw_image:LoadSprite(path, function ()
					
			end)
		end
		AvatarManager.Instance:GetAvatar(role_vo.uid, false, lovercallback)
	end
end

function QiXiMarriageView:OnClickDemand()
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_APPLY)
end

function QiXiMarriageView:OnClickInvite()
	ViewManager.Instance:Open(ViewName.WeddingInviteView)
end

function QiXiMarriageView:OnClickReservation()
	if MarriageData.Instance:CheckIsMarry() then 
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_weeding)
	else
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
	end
end