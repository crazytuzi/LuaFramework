MarryModel = MarryModel or BaseClass(BaseModel)

function MarryModel:__init()
    self.propose_window = nil
    self.bepropose_window = nil
	self.propose_answer_window = nil
	self.wedding_window = nil
	self.invite_window = nil
	self.beinvite_window = nil
	self.theinvitation_window = nil
	self.nowWedding_window = nil
	self.atmosptips = nil
	self.divorce_window = nil
	self.marriage_certificate_window = nil

	self.status = 0
	self.type = 0
	self.start_time = 0
	self.end_time = 0

	self.male_id = 0
	self.male_platform = 0
	self.male_zone_id = 0
	self.male_classes = 0
	self.male_sex = 0
	self.male_lev = 0
	self.male_face = 0
	self.male_name = ""

	self.female_id = 0
	self.female_platform = 0
	self.female_zone_id = 0
	self.female_classes = 0
	self.female_sex = 0
	self.female_lev = 0
	self.female_face = 0
	self.female_name = ""

	self.time = 0

	self.atmosp = 0
	self.act_logs = {}

	self.action_times_list = {}

	self.requestData = {}

	self.inside_List_Loading = false
	self.inside_List = {} -- 在典礼场景里面的人

	self.hidePet = false
	self.onWedding = false

	self.home_list = nil -- 结缘双方的家园信息

	self.wedding_package_list = nil
	self.marry_honor_id = nil
	self.marry_honor_list = {}


	EventMgr.Instance:AddListener(event_name.mainui_loaded, function() self:update() end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:update() end)
    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:update(event, old_event) end)
end

function MarryModel:__delete()

end

function MarryModel:OpenProposeWindow(args)
    if self.propose_window == nil then
        self.propose_window = Marry_ProposeView.New(self)
    end
    self.propose_window:Open(args)
end

function MarryModel:CloseProposeWindow()
    if self.propose_window ~= nil then
        self.propose_window:DeleteMe()
        self.propose_window = nil
    end
end

function MarryModel:OpenBeProposeWindow(args)
    if self.bepropose_window == nil then
        self.bepropose_window = Marry_BeProposeView.New(self)
    end
    self.bepropose_window:Open(args)
end

function MarryModel:CloseBeProposeWindow()
    if self.bepropose_window ~= nil then
        self.bepropose_window:DeleteMe()
        self.bepropose_window = nil
    end
end

function MarryModel:OpenProposeAnswerWindow(args)
    if self.propose_answer_window == nil then
        self.propose_answer_window = Marry_BeProposeAnswerView.New(self)
    end
    self.propose_answer_window:Open(args)
end

function MarryModel:CloseProposeAnswerWindow()
    if self.propose_answer_window ~= nil then
        self.propose_answer_window:DeleteMe()
        self.propose_answer_window = nil
    end
end

function MarryModel:OpenWeddingWindow(args)
    if self.wedding_window == nil then
        self.wedding_window = Marry_WeddingView.New(self)
    end
    self.wedding_window:Open(args)
end

function MarryModel:CloseWeddingWindow()
    if self.wedding_window ~= nil then
        self.wedding_window:DeleteMe()
        self.wedding_window = nil
    end
end

function MarryModel:OpenInviteWindow(args)
    if self.invite_window == nil then
        self.invite_window = Marry_InviteView.New(self)
    end
    self.invite_window:Open(args)
    MarryManager.Instance:Send15023()
end

function MarryModel:CloseInviteWindow()
    if self.invite_window ~= nil then
        self.invite_window:DeleteMe()
        self.invite_window = nil
    end
end

function MarryModel:OpenBeinviteWindow(args)
    if self.beinvite_window == nil then
        self.beinvite_window = Marry_BeinviteView.New(self)
    end
    self.beinvite_window:Open(args)
end

function MarryModel:CloseBeInviteWindow()
    if self.beinvite_window ~= nil then
        self.beinvite_window:DeleteMe()
        self.beinvite_window = nil
    end
end

function MarryModel:OpenTheinvitationWindow(args)
    if self.theinvitation_window == nil then
        self.theinvitation_window = Marry_TheinvitationView.New(self)
    end
    self.theinvitation_window:Open(args)
end

function MarryModel:CloseTheinvitationWindow()
    if self.theinvitation_window ~= nil then
        self.theinvitation_window:DeleteMe()
        self.theinvitation_window = nil
    end
end

function MarryModel:OpenRequestWindow(args)
    if self.request_window == nil then
        self.request_window = Marry_RequestView.New(self)
    end
    self.request_window:Open(args)
end

function MarryModel:CloseRequestWindow()
    if self.request_window ~= nil then
        self.request_window:DeleteMe()
        self.request_window = nil
    end
end

function MarryModel:OpenNowWeddingWindow(args)
    if self.nowWedding_window == nil then
        self.nowWedding_window = Marry_NowWeddingView.New(self)
    end
    self.nowWedding_window:Open(args)
end

function MarryModel:CloseNowWeddingWindow()
    if self.nowWedding_window ~= nil then
        self.nowWedding_window:DeleteMe()
        self.nowWedding_window = nil
    end
end

function MarryModel:OpenAtmospTipsWindow(args)
    if self.atmosptips == nil then
        self.atmosptips = Marry_AtmospTipsView.New(self)
    end
    self.atmosptips:Show(args)
end

function MarryModel:CloseAtmospTipsWindow()
    if self.atmosptips ~= nil then
        self.atmosptips:DeleteMe()
        self.atmosptips = nil
    end
end

function MarryModel:OpenDivorceWindow(args)
    if self.divorce_window == nil then
        self.divorce_window = Marry_DivorceView.New(self)
    end
    self.divorce_window:Open(args)
end

function MarryModel:CloseDivorceWindow()
    if self.divorce_window ~= nil then
        self.divorce_window:DeleteMe()
        self.divorce_window = nil
    end
end

function MarryModel:OpenMarriageCertificateWindow(args)
    if self.marriage_certificate_window == nil then
        self.marriage_certificate_window = MarriageCertificateWindow.New(self)
    end
    self.marriage_certificate_window:Open(args)
end

function MarryModel:CloseMarriageCertificateWindow()
    if self.marriage_certificate_window ~= nil then
        self.marriage_certificate_window:DeleteMe()
        self.marriage_certificate_window = nil
    end
end

function MarryModel:OpenWeddingDayWindow(args)
    if self.weddingday_window == nil then
        self.weddingday_window = WeddingDayWindow.New(self)
    end
    self.weddingday_window:Open(args)
end

function MarryModel:CloseWeddingDayWindow()
    if self.weddingday_window ~= nil then
        self.weddingday_window:DeleteMe()
        self.weddingday_window = nil
    end
end

function MarryModel:OpenMarryHonorWindow(args)
    if self.marryhonor_window == nil then
        self.marryhonor_window = MarryHonorWindow.New(self)
    end
    self.marryhonor_window:Open(args)
end

function MarryModel:CloseMarryHonorWindow()
    if self.marryhonor_window ~= nil then
        self.marryhonor_window:DeleteMe()
        self.marryhonor_window = nil
    end
end

------------------------------------------
function MarryModel:On15003(data)
	if self.status ~= 3 and data.status == 3 then
		for key, value in pairs(SceneManager.Instance.sceneElementsModel.RoleView_List) do
			value:StopMoveTo()
		end
	end
	self.status = data.status
	self.type = data.type
	self.start_time = data.start_time
	self.end_time = data.end_time

	self.male_id = data.male_id
	self.male_platform = data.male_platform
	self.male_zone_id = data.male_zone_id
	self.male_classes = data.male_classes
	self.male_sex = data.male_sex
	self.male_lev = data.male_lev
	self.male_face = data.male_face
	self.male_name = data.male_name

	self.female_id = data.female_id
	self.female_platform = data.female_platform
	self.female_zone_id = data.female_zone_id
	self.female_classes = data.female_classes
	self.female_sex = data.female_sex
	self.female_lev = data.female_lev
	self.female_face = data.female_face
	self.female_name = data.female_name
	
	self.time = data.time + BaseUtils.BASE_TIME

	local roleData = RoleManager.Instance.RoleData
	if roleData.event == RoleEumn.Event.Marry_cere or roleData.event == RoleEumn.Event.Marry_guest_cere then
		SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
	end

	-- if data.status == 0 then
	-- 	MainUIManager.Instance:DelAtiveIcon(110)
	-- else
	-- 	MainUIManager.Instance:DelAtiveIcon(110)

  --       local cfg_data = DataSystem.data_daily_icon[110]
  --       local iconData = AtiveIconData.New()
  --       iconData.id = cfg_data.id
  --       iconData.iconPath = cfg_data.res_name
  --       iconData.clickCallBack = function()
  --       	local male_uniqueid = BaseUtils.get_unique_roleid(self.male_id, self.male_zone_id, self.male_platform)
  --       	local female_uniqueid = BaseUtils.get_unique_roleid(self.female_id, self.female_zone_id, self.female_platform)
  --       	if SceneManager.Instance.sceneElementsModel.self_unique == male_uniqueid or SceneManager.Instance.sceneElementsModel.self_unique == female_uniqueid then
  --       		-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_invite_window)
  --       		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_now_wedding_window)
  --       	else
  --       		-- local confirmData = NoticeConfirmData.New()
	 --         --    confirmData.type = ConfirmData.Style.Normal
	 --         --    confirmData.content = string.format("%s与%s正在举办典礼", self.male_name, self.female_name)
	 --         --    confirmData.sureLabel = "参加典礼"
	 --         --    confirmData.cancelLabel = "取消"
	 --         --    confirmData.sureCallback = function() MarryManager.Instance:Send15009() end
	 --         --    NoticeManager.Instance:ConfirmTips(confirmData)

	 --            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_now_wedding_window)
  --       	end
  --       end
  --       iconData.sort = cfg_data.sort
  --       iconData.lev = cfg_data.lev
		-- iconData.createCallBack = function(gameObject)
		--     local fun = function(effectView)
		--         if BaseUtils.is_null(gameObject) then
		--             effectView:DeleteMe()
		--             return
		--         end
		--         local effectObject = effectView.gameObject

		--         effectObject.transform:SetParent(gameObject.transform)
		--         effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
		--         effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
		--         effectObject.transform.localRotation = Quaternion.identity

		--         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
		--     end
		--     BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
		-- end
		-- iconData.text = "<color='#00ea00'>典礼举办中</color>"
  --       MainUIManager.Instance:AddAtiveIcon(iconData)
	-- end
end

function MarryModel:On15005(data)
	if data.type == 0 then
		self.requestData = {}
		for key, value in pairs(data.list) do
			self.requestData[BaseUtils.Key(value.id, value.platform, value.zone_id)] = value
		end
	elseif data.type == 1 then
		for key, value in pairs(data.list) do
			self.requestData[BaseUtils.Key(value.id, value.platform, value.zone_id)] = value
		end
	elseif data.type == 2 then
		for key, value in pairs(data.list) do
			self.requestData[BaseUtils.Key(value.id, value.platform, value.zone_id)] = nil
		end
	end

	EventMgr.Instance:Fire(event_name.marry_data_update)
end

function MarryModel:update(event, old_event)
	local roleData = RoleManager.Instance.RoleData
	if roleData.event == RoleEumn.Event.Marry_cere or roleData.event == RoleEumn.Event.Marry_guest_cere then
	    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
	elseif roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_guest then
	    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
	end

	if BaseUtils.is_null(ctx.sceneManager.Map) then return end
	if SceneManager.Instance:CurrentMapId() == 30002 then
		if MainUIManager.Instance.mainuitracepanel then MainUIManager.Instance.mainuitracepanel:TweenShow() end
		if not self.onWedding then
			SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
		end
		self.onWedding = true
		MainUIManager.Instance:OpenMarryBarView()
		self.is_wedding = true
		
		if roleData.event == RoleEumn.Event.Marry_cere or roleData.event == RoleEumn.Event.Marry_guest_cere then
			SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
		end

		local marryModel = MarryManager.Instance.model
        local role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.male_id, marryModel.male_zone_id, marryModel.male_platform))
        if role then 
            role.is_virtual = true
        end
        role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.female_id, marryModel.female_zone_id, marryModel.female_platform))
        if role then 
            role.is_virtual = true
        end

		if MainUIManager.Instance.MainUIIconView then MainUIManager.Instance.MainUIIconView:Set_ShowTop(false) end
		SceneManager.Instance.sceneElementsModel.removeOutView = false
	elseif self.onWedding then
		self.onWedding = false
		MainUIManager.Instance:CloseMarryBarView()
		SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
		if self.is_wedding then
			SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)
			for _, value in pairs(SceneManager.Instance.sceneElementsModel:GetSceneData_Role()) do
				-- value.exclude_outofview = false
				value.is_virtual = false
			end
			self.is_wedding = false
		end
		if MainUIManager.Instance.MainUIIconView then MainUIManager.Instance.MainUIIconView:Set_ShowTop(true) end
		SceneManager.Instance.sceneElementsModel.removeOutView = true
	end
end

function MarryModel:update_virtual()
	if SceneManager.Instance:CurrentMapId() == 30002 then
		local marryModel = MarryManager.Instance.model
        local role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.male_id, marryModel.male_zone_id, marryModel.male_platform))
        if role then 
            role.is_virtual = true
        end
        role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.female_id, marryModel.female_zone_id, marryModel.female_platform))
        if role then 
            role.is_virtual = true
        end
    end
end

function MarryModel:GetMarriageCertificateData()
	local male_data = {}
	local female_data = {}
	local roleData = RoleManager.Instance.RoleData
	local loverData = MarryManager.Instance.loverData

	if loverData == nil then
		return 
	end
	
	if roleData.sex == 1 then
		male_data.name = roleData.name
		male_data.sex = roleData.sex
		male_data.classes = roleData.classes
		male_data.id = roleData.id
		male_data.platform = roleData.platform
		male_data.zone_id = roleData.zone_id

		female_data.name = loverData.name
		female_data.sex = loverData.sex
		female_data.classes = loverData.classes
		female_data.id = loverData.id
		female_data.platform = loverData.platform
		female_data.zone_id = loverData.zone_id
	else
		female_data.name = roleData.name
		female_data.sex = roleData.sex
		female_data.classes = roleData.classes
		female_data.id = roleData.id
		female_data.platform = roleData.platform
		female_data.zone_id = roleData.zone_id

		male_data.name = loverData.name
		male_data.sex = loverData.sex
		male_data.classes = loverData.classes
		male_data.id = loverData.id
		male_data.platform = loverData.platform
		male_data.zone_id = loverData.zone_id
	end

	local data = {}
	data.male_data = male_data
	data.female_data = female_data
	data.intimacy = FriendManager.Instance:GetIntimacy(loverData.id, loverData.platform, loverData.zone_id)
	data.time = MarryManager.Instance.loverData.time

	return data
end

function MarryModel:isMarryHonorActivate(honor_id)
	for i=1,#self.marry_honor_list do
        if self.marry_honor_list[i].honor_id == honor_id then
            return true
        end
    end
    return false
end