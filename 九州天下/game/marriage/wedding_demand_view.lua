WeddingDemandView = WeddingDemandView or BaseClass(BaseView)

function WeddingDemandView:__init()
	self.ui_config = {"uis/views/marriageview","DemandWeddingView"}

	self:SetMaskBg()
end

function WeddingDemandView:ReleaseCallBack()
	self.my_image_res = nil
	self.other_image_res = nil
	self.my_image_state = nil
	self.other_image_state = nil
	self.role_name = nil
	self.lover_name = nil
	self.time_tips = nil
	self.show_invite = nil
	self.my_rawimage = nil
	self.other_rawimage = nil
end

function WeddingDemandView:LoadCallBack()
	self.my_image_res = self:FindVariable("MyImageRes")
	-- self.my_rawimage_res = self:FindVariable("MyRawImageRes")
	self.other_image_res = self:FindVariable("OtherImageRes")
	-- self.other_rawimage_res = self:FindVariable("OtherRawImageRes")
	self.my_image_state = self:FindVariable("MyImageState")				--是否显示自己的默认头像
	self.other_image_state = self:FindVariable("OtherImageState")		--是否显示别人的默认头像
	-- self.have_other_people = self:FindVariable("HaveOtherPeople")		--是否显示别人头像
	self.role_name = self:FindVariable("role_name")
	self.lover_name = self:FindVariable("lover_name")
	self.time_tips = self:FindVariable("time_tips")
	self.show_invite = self:FindVariable("show_invite")

	self.my_rawimage = self:FindObj("MyRawImage")
	self.other_rawimage = self:FindObj("OtherRawImage")

	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("GoWedding",BindTool.Bind(self.OnGoWedding, self))
	self:ListenEvent("DemandInvite",BindTool.Bind(self.OnDemandInvite, self))
	self:ListenEvent("InviteGuests",BindTool.Bind(self.OnInviteGuests, self))

	self:Flush()
end

function WeddingDemandView:ClickClose()
	self:Close()
end

function WeddingDemandView:OnGoWedding()
	MarriageCtrl.Instance:SendEnterWeeding()
end

function WeddingDemandView:OnDemandInvite()
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_APPLY)
end

function WeddingDemandView:OnInviteGuests()
	ViewManager.Instance:Open(ViewName.WeddingInviteView)
end

function WeddingDemandView:OnFlush()
	local wedding_info = MarriageData.Instance:GetCurWeddingInfo()
	local role_vo = wedding_info.marryuser_list
	local vo = GameVoManager.Instance:GetMainRoleVo()

	if role_vo == nil or next(role_vo) == nil then return end

	self.role_name:SetValue(role_vo[1].marry_name)
	self.lover_name:SetValue(role_vo[2].marry_name)
	self.show_invite:SetValue(role_vo[1].marry_uid == vo.role_id or role_vo[2].marry_uid == vo.role_id)

	local wedding_time_cfg = MarriageData.Instance:GetYuYueTime(wedding_info.seq)
	local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime()) 
	self.time_tips:SetValue(string.format(Language.Marriage.MarryDemand2, time_table.month, time_table.day, wedding_time_cfg.begin_time / 100))
	
	self:SetMyHead(role_vo[1])
	self:SetOtherHead(role_vo[2])
end

function WeddingDemandView:SetMyHead(role_vo)
	if role_vo == nil then return end

	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_vo.marry_uid)
	if AvatarManager.Instance:isDefaultImg(role_vo.marry_uid) == 0 or avatar_path_small == 0 then
		self.my_image_state:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(role_vo.prof, false, role_vo.sex)
		self.my_image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.my_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_vo.marry_uid, false)
			end
			self.my_rawimage.raw_image:LoadSprite(path, function ()
					
			end)
		end
		AvatarManager.Instance:GetAvatar(role_vo.marry_uid, false, callback)
	end
end

function WeddingDemandView:SetOtherHead(role_vo)
	if role_vo == nil then return end

	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_vo.marry_uid)
	if AvatarManager.Instance:isDefaultImg(role_vo.marry_uid) == 0 or avatar_path_small == 0 then
		self.other_image_state:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(role_vo.prof, false, role_vo.sex)
		self.other_image_res:SetAsset(bundle, asset)
	else
		local function lovercallback(path)
			if IsNil(self.other_rawimage.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_vo.marry_uid, false)
			end
			self.other_rawimage.raw_image:LoadSprite(path, function ()
					
			end)
		end
		AvatarManager.Instance:GetAvatar(role_vo.marry_uid, false, lovercallback)
	end
end