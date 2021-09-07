RankMarryTip = RankMarryTip or BaseClass(BaseView)
function RankMarryTip:__init()
	self.ui_config = {"uis/views/rank","RankMarryTip"}
	self.full_screen = false
end

function RankMarryTip:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("Clickman", BindTool.Bind(self.ClickMan, self))
	self:ListenEvent("Clickwoman", BindTool.Bind(self.Clickwoman, self))

	self.man_image_res = self:FindVariable("ManImageRes")
	self.woman_image_res = self:FindVariable("WomanImageRes")
	self.man_name = self:FindVariable("Man_Name")
	self.woman_name = self:FindVariable("Woman_Name")

	self.man_image_obj = self:FindObj("man_image_obj")
	self.women_image_obj = self:FindObj("women_image_obj")
end

function RankMarryTip:__delete()
	
end

function RankMarryTip:ReleaseCallBack()
	self.man_image_res = nil
	self.woman_image_res = nil
	self.man_name = nil
	self.woman_name = nil
	self.man_image_obj = nil
	self.women_image_obj = nil
end

function RankMarryTip:CloseView()
	self:Close()
end

function RankMarryTip:SetHeadData(head_data)
	self.head_data = head_data
	self:Flush()
end

function RankMarryTip:OnFlush()
	if nil == self.head_data or nil == next(self.head_data) then return end
	self:SetRoleHead(self.man_image_res, self.man_image_obj, self.head_data.uid_1, self.head_data.prof_1, self.head_data.sex_1, self.head_data.avatar_key_small_1, self.head_data.avatar_key_big_1)
	self:SetRoleHead(self.woman_image_res, self.women_image_obj, self.head_data.uid_2, self.head_data.prof_2, self.head_data.sex_2, self.head_data.avatar_key_small_2, self.head_data.avatar_key_big_2)
end


function RankMarryTip:SetRoleHead(image_res, rawimage_obj, uid, prof, sex, avatar_key_small, avatar_key_big)
	image_res:SetAsset(nil,nil)
	AvatarManager.Instance:SetAvatarKey(uid, avatar_key_big, avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(uid)
	if AvatarManager.Instance:isDefaultImg(uid) == 0 or avatar_path_small == 0 then
		rawimage_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(prof, false, sex)
		image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(rawimage_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(uid, false)
			end
			rawimage_obj.raw_image:LoadSprite(path, function ()
				rawimage_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(uid, false, callback)
	end
	self.man_name:SetValue(self.head_data.name_1)
	self.woman_name:SetValue(self.head_data.name_2)
end

function RankMarryTip:ClickMan()
	if self.head_data.uid_1 ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.head_data.name_1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end

function RankMarryTip:Clickwoman()
	if self.head_data.uid_2 ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.head_data.name_2)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end