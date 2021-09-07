MainuiMarryPanel = MainuiMarryPanel or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiMarryPanel:__init(main)
    self.main = main
    self.isInit = true

    self.levelText = nil
    self.marryNameText = nil
    self.atmospText = nil
    self.Point = nil
    self.LevMask = nil
    self.itemText = nil
    self.container = nil
    self.toggle = nil

    self.itemList = {}
    self.act_logs_length = 0

    self.timer_id = nil

    self._Update = function() self:Update() end

    self.resList = {
        {file = AssetConfig.marry_content, type = AssetType.Main}
    }

    self._SettingUpdate = function(key, value) self:SettingUpdate(key, value) end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiMarryPanel:__delete()
    self.OnHideEvent:Fire()
end

function MainuiMarryPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0,-45, 0)

	self.levelText = self.transform:FindChild("Level/Text"):GetComponent(Text)
	self.marryNameText = self.transform:FindChild("Container/taskItem/Text"):GetComponent(Text)
	self.atmospText = self.transform:FindChild("Container/taskItem4/ValueText"):GetComponent(Text)

	self.Point = self.transform:FindChild("Container/taskItem3/point")
	self.LevMask = self.transform:FindChild("Container/taskItem3/Mask")

	self.itemText = self.transform:FindChild("Container/taskItem5/Mask/Text").gameObject
	self.container = self.transform:FindChild("Container/taskItem5/Mask/Container").gameObject

    self.toggle = self.transform:FindChild("Container/taskItem6"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener(function(on) self:ontogglechange(on) end)
    self.toggle.isOn = false
    self:ontogglechange(false)

	self.itemList = {}
	for i = 1, 3 do
		local item = GameObject.Instantiate(self.itemText)
	    UIUtils.AddUIChild(self.container, item)
	    item:GetComponent(Text).text = ""
	    table.insert(self.itemList, item)
	end

    self.exitbtn = self.transform:Find("GiveUP/Button")
    self.exitbtn:GetComponent(Button).onClick:AddListener(function() self:ClickGiveUPBtn() end)
    self.invitebtn = self.transform:Find("Invite/Button")
    self.invitebtn:GetComponent(Button).onClick:AddListener(function() self:ClickInviteBtn() end)
   	self.transform:FindChild("Container/taskItem4/DescButton"):GetComponent(Button).onClick:AddListener(function() self:descButtonClick() end)
end

function MainuiMarryPanel:OnShow()
    self:Update()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.marry_data_update, self._Update)
    EventMgr.Instance:AddListener(event_name.setting_change, self._SettingUpdate)

    self.timer_id = LuaTimer.Add(1000, 1000, function() self:Update_Time() end)
end

function MainuiMarryPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiMarryPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.marry_data_update, self._Update)
    EventMgr.Instance:RemoveListener(event_name.setting_change, self._SettingUpdate)
end

function MainuiMarryPanel:OnHide()
    self:RemoveListeners()
    if self.timer_id ~= nil then LuaTimer.Delete(self.timer_id) self.timer_id = nil end
end

function MainuiMarryPanel:Update()
	local marryModel = MarryManager.Instance.model
	if marryModel.type == 1 then
		self.levelText.text = TI18N("挚爱典礼")
	else
		self.levelText.text = TI18N("豪华典礼")
	end

	self.marryNameText.text = string.format(TI18N("<color='#00ffff'>%s</color>与<color='#00ffff'>%s</color>"), marryModel.male_name, marryModel.female_name)
	self.atmospText.text = tostring(marryModel.atmosp)

	local levPointX = {
        [0] = -90,
        [1] = -35,
        [2] = 20,
        [3] = 90,
    }
    local barW =
    {
        [0] = 40,
        [1] = 95,
        [2] = 152,
        [3] = 222
    }

	local currfigure = 0
	local figure_score = marryModel.atmosp

    if figure_score >= 999 then
        currfigure = 3
        figure_score = 0
    elseif figure_score > 699 then
        currfigure = 2
        figure_score = figure_score - 699
    elseif figure_score > 399 then
        currfigure = 1
        figure_score = figure_score - 399
    end

    local sizex = 222
    if currfigure == 3 then
        sizex = 222
    elseif currfigure == 2 then
        sizex = barW[currfigure]+ (figure_score /600)*(barW[currfigure+1]-barW[currfigure])
    elseif currfigure == 1 then
        sizex = barW[currfigure]+ (figure_score /300)*(barW[currfigure+1]-barW[currfigure])
    elseif currfigure == 0 then
        sizex = barW[currfigure]+ (figure_score /399)*(barW[currfigure+1]-barW[currfigure])
    else
        sizex = 222
    end
    self.Point.localPosition = Vector3(-90+sizex-35, 0, 0)
    self.LevMask.sizeDelta = Vector2(sizex, 29)

 --    if self.act_logs_length ~= #marryModel.act_logs then -- 长度有改变时才更新
	--     self.act_logs_length = #marryModel.act_logs
	--     local index = self.act_logs_length
	--     for i = 1, 3 do
	--     	local act_logs_data = marryModel.act_logs[index]
	-- 		if act_logs_data ~= nil then
	-- 			self.itemList[i]:GetComponent(Text).text = MessageParser.GetMsgData(act_logs_data.msg).showString
	-- 		end
	-- 		index = index - 1
	-- 	end
	-- end

    local roleData = RoleManager.Instance.RoleData
    if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
        self.invitebtn.gameObject:SetActive(true)
        self.exitbtn.transform.localPosition = Vector2(0, 0, 0)
    else
        self.invitebtn.gameObject:SetActive(false)
        self.exitbtn.transform.localPosition = Vector2(-67, 0, 0)
    end

    local length = 0
    for key, value in pairs(MarryManager.Instance.model.requestData) do
        length = length + 1
    end
    if length > 0 then
        self.invitebtn.transform:Find("RedPoint").gameObject:SetActive(true)
    else
        self.invitebtn.transform:Find("RedPoint").gameObject:SetActive(false)
    end
end

function MainuiMarryPanel:Update_Time()
    local marryModel = MarryManager.Instance.model
    local time = marryModel.time - BaseUtils.BASE_TIME
    if time < 0 then time =0 end
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(time)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    -- marryModel.time = marryModel.time - 1
    if marryModel.status == 0 or marryModel.status == 1 then
        local roleData = RoleManager.Instance.RoleData
        if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
            self.itemList[1]:GetComponent(Text).text = string.format(TI18N("典礼仪式将在<color='#00ff00'>%s:%s</color>后开始，快邀请好友们前来观礼吧！"), my_minute, my_second)
        else
            self.itemList[1]:GetComponent(Text).text = string.format(TI18N("典礼仪式将在<color='#00ff00'>%s:%s</color>后开始，请祝福一对新人吧！"), my_minute, my_second)
        end
    elseif marryModel.status == 2 then
        self.itemList[1]:GetComponent(Text).text = TI18N("<color='#ffff00'>典礼仪式</color>进行中，请祝福新人吧！")
    elseif marryModel.status == 3 then
        if marryModel.type == 1 then
            self.itemList[1]:GetComponent(Text).text = TI18N("典礼仪式已圆满结束，宾客们可自行离开")
        else
            self.itemList[1]:GetComponent(Text).text = string.format(TI18N("礼毕，结缘宝箱将在<color='#ffff00'>%s:%s</color>后刷出"), my_minute, my_second)
        end
    elseif marryModel.status == 4 then
        self.itemList[1]:GetComponent(Text).text = TI18N("典礼仪式已圆满结束，宾客们可自行离开")
    end
end

function MainuiMarryPanel:descButtonClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_atmosp_tips)
	-- TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("Container/taskItem4/DescButton").gameObject
 --            , itemData = {"浪漫值达到<color='#ffff00'>399、699、999</color>，男方和女方可分别获得一份神秘大礼哦！"
 --                        , "男方女方燃放礼包、投放糖果可增加浪漫值"
 --                        , "宾客发红包、敬酒、撒花可增加浪漫值"}})
end

function MainuiMarryPanel:ontogglechange(on)
    if on then
        -- local marryModel = MarryManager.Instance.model
        -- local role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.male_id, marryModel.male_zone_id, marryModel.male_platform))
        -- if role then
        --     role.is_virtual = true
        -- end
        -- role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.female_id, marryModel.female_zone_id, marryModel.female_platform))
        -- if role then
        --     role.is_virtual = true
        -- end
        -- SceneManager.Instance.sceneElementsModel:Show_Self(false)
        -- SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(true)
    else
        -- local marryModel = MarryManager.Instance.model
        -- local role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.male_id, marryModel.male_zone_id, marryModel.male_platform))
        -- if role then
        --     role.is_virtual = false
        -- end
        -- role = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(BaseUtils.get_unique_roleid(marryModel.female_id, marryModel.female_zone_id, marryModel.female_platform))
        -- if role then
        --     role.is_virtual = false
        -- end
        -- SceneManager.Instance.sceneElementsModel:Show_Self(true)
        -- SceneManager.Instance.sceneElementsModel:Show_OtherRole(true)
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(false)
    end
end

function MainuiMarryPanel:ClickInviteBtn()
    local length = 0
    for key, value in pairs(MarryManager.Instance.model.requestData) do
        length = length + 1
    end
    if length == 0 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_invite_window, {1})
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_invite_window, {2})
    end
end

function MainuiMarryPanel:ClickGiveUPBtn()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = TI18N("是否要退出典礼殿堂？")
    confirmData.sureLabel = TI18N("确定")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function()
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
            SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
            MarryManager.Instance:Send15010()
        end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MainuiMarryPanel:SettingUpdate(key, value)
    if key == SettingManager.Instance.THidePerson then
        if self.toggle ~= nil then
            self.toggle.isOn = value
        end
    end
end