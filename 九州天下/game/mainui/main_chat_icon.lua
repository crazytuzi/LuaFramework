MainCHATIcon = MainCHATIcon or BaseClass(BaseRender)

function MainCHATIcon:__init()
	self.show_image = self:FindVariable("showImage")
	self.image_res = self:FindVariable("ImageRes")
	self.raw_image = self:FindObj("RawImage")
end

function MainCHATIcon:__delete()
	
end

function MainCHATIcon:SetData(role)
	if role == nil or next(role) == nil then
		return
	end
	local head_id = role.from_uid
	local avatar_key_small = AvatarManager.Instance:GetAvatarKey(head_id)
	if avatar_key_small == 0 then
		self.show_image:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(role.prof, false, role.sex)
		self.image_res:SetAsset(bundle, asset)
	else
	local function callback(path)
		if path == nil then
			path = AvatarManager.GetFilePath(head_id, false)
		end
		self.raw_image.raw_image:LoadSprite(path, function ()
		self.show_image:SetValue(false)
		end)
	end
	AvatarManager.Instance:GetAvatar(head_id, false, callback)
	end
end


