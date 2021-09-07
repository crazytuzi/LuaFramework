MainBeAtkIcon = MainBeAtkIcon or BaseClass(BaseRender)

function MainBeAtkIcon:__init()
	self.be_atked_icon = self.root_node

	self.show_image = self:FindVariable("ShowImage")
	self.image_res = self:FindVariable("ImageRes")
	self.atk_text = self:FindVariable("AtkText")

	self.raw_image = self:FindObj("RawImage")
	self.atk_icon_show_time = 0
	self.role_vo = nil

	self:ListenEvent("ClickBeAtk",
		BindTool.Bind(self.ClickBeAtk, self))

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.get_ui_callback)
end

function MainBeAtkIcon:__delete()
	if nil ~= self.be_attakced_update_t then
		GlobalTimerQuest:CancelQuest(self.be_attakced_update_t)
		self.be_attakced_update_t = nil
	end
	if nil ~= self.atta_kced then
		GlobalTimerQuest:CancelQuest(self.atta_kced)
		self.atta_kced = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.get_ui_callback)
	end
end

function MainBeAtkIcon:SetData(role_vo)
	if self.atk_icon_show_time > Status.NowTime then
		return
	end
	self.role_vo = role_vo
	local avatar_key_small = AvatarManager.Instance:GetAvatarKey(role_vo.role_id)
	-- local sex_color_cfg = SEX_COLOR[role_vo.sex] or SEX_COLOR[1]
	-- local name = role_vo.name
	-- local str = string.format(Language.Fight.BeHit, sex_color_cfg, name)
	-- self.atk_text:SetValue(str)
	if avatar_key_small == 0 then
		self.show_image:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(role_vo.prof, false, role_vo.sex)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if path == nil then
				path = AvatarManager.GetFilePath(role_vo.role_id, false)
			end
			self.raw_image.raw_image:LoadSprite(path, function ()
				self.show_image:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_vo.role_id, false, callback)
	end
	self:SetBeAtkIconState(role_vo)
end

function MainBeAtkIcon:SetBeAtkIconState(role_vo)
	self.atk_icon_show_time = Status.NowTime + 4
	self:SetActive(true)

	if nil ~= self.be_attakced_update_t then
		GlobalTimerQuest:CancelQuest(self.be_attakced_update_t)
		self.be_attakced_update_t = nil
	end
	self.be_attakced_update_t = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateAtkIconTime, self), 1)
end

function MainBeAtkIcon:UpdateAtkIconTime()
	if self.atk_icon_show_time <= Status.NowTime then
		if nil ~= self.be_attakced_update_t then
			GlobalTimerQuest:CancelQuest(self.be_attakced_update_t)
			self.be_attakced_update_t = nil
			self:SetActive(false)
		end
	end
end

function MainBeAtkIcon:ClickBeAtk()
	self:SetActive(false)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Common or scene_type == SceneType.ShuiJing then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end

	if nil ~= self.atta_kced then
		GlobalTimerQuest:CancelQuest(self.atta_kced)
		self.atta_kced = nil
	end
	self.atta_kced = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AttaKced, self), 0.5)
end

function MainBeAtkIcon:AttaKced()
	if self.role_vo ~= nil then
		local target_obj = Scene.Instance:GetObjectByObjId(self.role_vo.obj_id)
		if target_obj then
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "scene")
		end
	end
	if nil ~= self.atta_kced then
		GlobalTimerQuest:CancelQuest(self.atta_kced)
		self.atta_kced = nil
	end
end

function MainBeAtkIcon:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end