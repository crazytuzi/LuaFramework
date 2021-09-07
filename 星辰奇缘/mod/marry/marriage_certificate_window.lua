-- 结缘证界面
-- ljh 20160827
MarriageCertificateWindow = MarriageCertificateWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function MarriageCertificateWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marriage_certificate_window
    self.name = "MarriageCertificateWindow"
    self.resList = {
        {file = AssetConfig.marriage_certificate_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
        , {file = AssetConfig.zone_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.skillList = {}

    self.male_data = nil
	self.female_data = nil
	self.intimacy = nil
	self.time = nil
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
    self._Send15029 = function() self:Send15029() end
    self._Update_RedPoint = function() self:Update_RedPoint() end
end

function MarriageCertificateWindow:__delete()
    self:OnHide()

    if self.imgLoader ~= nil then
	    self.imgLoader:DeleteMe()
	    self.imgLoader = nil
	end

    self:ClearDepAsset()
end

function MarriageCertificateWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marriage_certificate_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.mainTransform = self.transform:Find("Main")

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.shareButton = self.transform:FindChild("Main/ShareButton").gameObject
    self.shareButton:GetComponent(Button).onClick:AddListener(function() self:shareButtonClick() end)

    self.mainTransform:Find("Panel/MaleHead/Head").gameObject:SetActive(false)
	self.mainTransform:Find("Panel/FemaleHead/Head").gameObject:SetActive(false)

	if self.imgLoader == nil then
	    local go = self.okButton.transform:FindChild("Image").gameObject
	    self.imgLoader = SingleIconLoader.New(go)
	end
	self.imgLoader:SetSprite(SingleIconType.Item, 22505)

    self:OnShow()
end

function MarriageCertificateWindow:Close()
    self.model.newTalent = {}
    self:OnHide()

    WindowManager.Instance:CloseWindow(self)
    -- self.model:CloseMarriageCertificateWindow()

    if self.model.windowId ~= nil then
        WindowManager.Instance:OpenWindowById(self.model.windowId)
        self.model.windowId = nil
    end
end

function MarriageCertificateWindow:OnShow()
	if self.openArgs ~= nil and #self.openArgs > 0 then
		local data = self.openArgs[1]
        self.male_data = { name = data.male_name, sex = data.male_sex, classes = data.male_classes, id = data.male_id, platform = data.male_platform, zone_id = data.male_zone_id, face_index = data.male_face_index, face_time = data.male_face_time }
		self.female_data = { name = data.female_name, sex = data.female_sex, classes = data.female_classes, id = data.female_id, platform = data.female_platform, zone_id = data.female_zone_id, face_index = data.female_face_index, face_time = data.female_face_time }
		self.intimacy = data.intimacy
		self.time = data.time
		self:Update()

		MarryManager.Instance:Send15025()
		EventMgr.Instance:AddListener(event_name.lover_data, self._Update_RedPoint)
		EventMgr.Instance:RemoveListener(event_name.lover_data, self._Send15029)
    else
		if MarryManager.Instance.loverData == nil then
			-- EventMgr.Instance:AddListener(event_name.lover_data, self._Update)
			EventMgr.Instance:AddListener(event_name.lover_data, self._Send15029)
			MarryManager.Instance:Send15014()
		else
			-- self:Update()
			self:Send15029()
		end
	end
end

function MarriageCertificateWindow:Send15029()
	local data = self.model:GetMarriageCertificateData()
	MarryManager.Instance:Send15029(data.male_data.id, data.male_data.platform, data.male_data.zone_id)
end

function MarriageCertificateWindow:OnHide()
	-- EventMgr.Instance:RemoveListener(event_name.lover_data, self._Update)
	EventMgr.Instance:RemoveListener(event_name.lover_data, self._Send15029)
	EventMgr.Instance:RemoveListener(event_name.lover_data, self._Update_RedPoint)
end

function MarriageCertificateWindow:Update()
	if self.male_data == nil then
		local data = self.model:GetMarriageCertificateData()
		self.male_data = data.male_data
		self.female_data = data.female_data
		self.intimacy = data.intimacy
		self.time = data.time

        if self.time == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("已解除结缘"))
            LuaTimer.AddListener(500, function() WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marriage_certificate_window) end)
            return
        end
	else
		local data = self.model:GetMarriageCertificateData()
		if data == nil or (data.male_data.id ~= self.male_data.id or data.male_data.platform ~= self.male_data.platform or data.male_data.zone_id ~= self.male_data.zone_id) then
			self.okButton.gameObject:SetActive(false)
			self.shareButton.gameObject:SetActive(false)

			self.mainTransform.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(528, 340)
			self.mainTransform:FindChild("bg"):GetComponent(RectTransform).sizeDelta = Vector2(492, 300)
			self.mainTransform:FindChild("Panel").localPosition = Vector3(0, -30, 0)
		end
	end

	local male_data = self.male_data
	local female_data = self.female_data
	local intimacy = self.intimacy
	local time = self.time

	self.mainTransform:Find("Panel/MaleText"):GetComponent(Text).text = male_data.name
	self.mainTransform:Find("Panel/FemaleText"):GetComponent(Text).text = female_data.name
	self.mainTransform:Find("Panel/LoveValueText"):GetComponent(Text).text = string.format(TI18N("亲密度：<color='#ffff9a'>%s</color>"), intimacy)

	local day = tostring(math.floor((BaseUtils.BASE_TIME-time)/3600/24))
	local hour = math.modf((BaseUtils.BASE_TIME-time) % 86400 / 3600)
	local timeStr = string.format(TI18N("%s天%s小时"), day, hour)
	local timeName = ""
	for i,value in ipairs(DataWedding.data_weddingday) do
		if tonumber(day) >= value.day then
			timeName = value.name
		end
	end
	self.mainTransform:Find("Panel/TimeText"):GetComponent(Text).text = string.format(TI18N("携手岁月：<color='#3166ad'>%s(他们已结缘%s)</color>"), timeName, timeStr)

	local marry_year = os.date("%y", time)
	local marry_month = os.date("%m", time)
	local marry_day = os.date("%d", time)
	local marry_hour = os.date("%H", time)
	self.mainTransform:Find("Panel/DayText"):GetComponent(Text).text = string.format(TI18N("永恒纪念：<color='#3166ad'>20%s年%s月%s日%s点</color>"), marry_year, marry_month, marry_day, marry_hour)

	self:UpdateImage(male_data, female_data)
end

function MarriageCertificateWindow:UpdateImage(male_data, female_data)
	self.mainTransform:Find("Panel/MaleHead/Head").gameObject:SetActive(true)
	self.mainTransform:Find("Panel/FemaleHead/Head").gameObject:SetActive(true)

	self.mainTransform:Find("Panel/MaleHead/Head"):GetComponent(Image).sprite
		= self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", male_data.classes, male_data.sex))
	self.mainTransform:Find("Panel/FemaleHead/Head"):GetComponent(Image).sprite
		= self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", female_data.classes, female_data.sex))

    local photo = ZoneManager.Instance.model:LoadLocalPhoto(male_data.id, male_data.platform, male_data.zone_id, male_data.face_index, male_dataface_time)
    if BaseUtils.is_null(photo) then
        ZoneManager.Instance:RequirePhotoQueue(male_data.id, male_data.platform, male_data.zone_id, function(photoList) self:PhotoBack(photoList, 1) end)
    else
        self:toPhoto(photo, 1)
    end

    photo = ZoneManager.Instance.model:LoadLocalPhoto(female_data.id, female_data.platform, female_data.zone_id, female_data.face_index, female_dataface_time)
    if BaseUtils.is_null(photo) then
        ZoneManager.Instance:RequirePhotoQueue(female_data.id, female_data.platform, female_data.zone_id, function(photoList) self:PhotoBack(photoList, 2) end)
    else
        self:toPhoto(photo, 2)
    end
end

function MarriageCertificateWindow:PhotoBack(photoList, index)
	BaseUtils.dump(photoList)
	if #photoList > 0 then
		self:toPhoto(photoList[1], index)
	end
end

function MarriageCertificateWindow:toPhoto(photo, index)
	if BaseUtils.is_null(self.gameObject) then -- 如果界面销魂了就不处理了
		return
	end
	local tex2d = Texture2D(130, 130, TextureFormat.RGB24, false)

	local result = tex2d:LoadImage(photo.photo_bin)
	if result then
		if index == 1 then
			self.mainTransform:Find("Panel/MaleHead/Head"):GetComponent(Image).sprite = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
		else
			self.mainTransform:Find("Panel/FemaleHead/Head"):GetComponent(Image).sprite = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
		end
	end
end

function MarriageCertificateWindow:okButtonClick()
	-- self:Close()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.weddingday_window)
end

function MarriageCertificateWindow:shareButtonClick()
	local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(data) end}
	            , {label = TI18N("世界频道"), callback = function() self:ShareToWorld(data) end}
	            , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(data) end}}
	TipsManager.Instance:ShowButton({gameObject = self.shareButton.gameObject, data = btns})
end

function MarriageCertificateWindow:ShareToFriend()
	local setting = {
		list_type = 2,
	    ismulti = true,
	    callback = function(list)
	    	for i,v in ipairs(list) do
		        -- FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
		        self:ShareAchievement(MsgEumn.ExtPanelType.Friend, v)
		    end
		end
	}
	if self.friendPanel == nil then
	    self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
	end
	self.friendPanel:Show()

    -- local callBack = function(_, friendData) self:ShareAchievement(MsgEumn.ExtPanelType.Friend, friendData, data.id) NoticeManager.Instance:FloatTipsByString("分享成功") end
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack })
end

function MarriageCertificateWindow:ShareToWorld()
    self:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.World)
end

function MarriageCertificateWindow:ShareToGuild()
    if GuildManager.Instance.model:check_has_join_guild() then
        self:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.Guild)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
end

function MarriageCertificateWindow:ShareAchievement(panelType, channel)
	local roleData = RoleManager.Instance.RoleData
	local loverData = MarryManager.Instance.loverData
	local data = {}

	-- local sendData = string.format("{marriagecertificate_1, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s}"
	-- 	, male_data.name, male_data.sex, male_data.classes, male_data.id, male_data.platform, male_data.zone_id
	-- 	, female_data.name, female_data.sex, female_data.classes, female_data.id, female_data.platform, female_data.zone_id
	-- 	, roleData.love, loverData.time)
	local sendData = string.format(TI18N("{marriagecertificate_1, %s和%s的结缘证, %s, %s, %s}"), roleData.name, loverData.name, self.male_data.id, self.male_data.platform, self.male_data.zone_id)

	if panelType == MsgEumn.ExtPanelType.Friend then
	    FriendManager.Instance:SendMsg(channel.id, channel.platform, channel.zone_id, sendData)
	elseif panelType == MsgEumn.ExtPanelType.Chat then
	    ChatManager.Instance:SendMsg(channel, sendData)
	end

	NoticeManager.Instance:FloatTipsByString(TI18N("分享成功"))
end

function MarriageCertificateWindow:Update_RedPoint()
	local loverData = MarryManager.Instance.loverData
	if loverData == nil then return end

	local day = math.floor((BaseUtils.BASE_TIME-loverData.time)/3600/24)

	local package_data = nil
	local package_times = 0
	for _,value in pairs(self.model.wedding_package_list) do
		if package_data == nil and (value.times == 0 or DataWedding.data_wedding_package[value.id].day == 365) then
			package_data = DataWedding.data_wedding_package[value.id]
            package_times = value.times
		end
	end

	if package_data == nil then
        Log.Error("礼包数据出错")
        return
    end

	if package_data.day * (package_times+1) > day then
		self.okButton.transform:FindChild("RedPoint").gameObject:SetActive(false)
    else
    	self.okButton.transform:FindChild("RedPoint").gameObject:SetActive(true)
    end
end