-- 家园 地图
-- ljh 160705
HomeMapArea = HomeMapArea or BaseClass(BaseView)

function HomeMapArea:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.homemaparea, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.name = "HomeMapArea"

    self.gameObject = nil
    self.transform = nil

    self.mapname_text = nil
    self.exp_text = nil
    self.level_name_text = nil
    self.icon_image = nil

    self.infoButton = nil
    self.editButton = nil
    self.exitButton = nil
    self.infoButton_redPoint = nil
    self.editButton_redPoint = nil
    self.exitButton_redPoint = nil

    self.buildUpdateListener = function() self:OnCheckGuide() end
    self.useUpdateListener = function() self:OnUseUpdate() end

    HomeManager.Instance.buildFirstInfo:RemoveListener(self.buildUpdateListener)
    HomeManager.Instance.buildFirstInfo:AddListener(self.buildUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.home_use_info_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.home_train_info_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_build_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.home_build_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.active_point_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.active_point_update, self.useUpdateListener)

    self:OnUseUpdate()
    self:OnCheckGuide()

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function HomeMapArea:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self.useUpdateListener)
        EventMgr.Instance:AddListener(event_name.home_use_info_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self.useUpdateListener)
        EventMgr.Instance:AddListener(event_name.home_train_info_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.home_build_update, self.useUpdateListener)
        EventMgr.Instance:AddListener(event_name.home_build_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.active_point_update, self.useUpdateListener)
        EventMgr.Instance:AddListener(event_name.active_point_update, self.useUpdateListener)

        AgendaManager.Instance:Require12004()
        BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = true
        end
        self:OnCheckGuide()
        self:OnUseUpdate()
    else
        EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.active_point_update, self.useUpdateListener)
        EventMgr.Instance:RemoveListener(event_name.home_build_update, self.useUpdateListener)
        BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = false
        end
    end
end

function HomeMapArea:__delete()
    HomeManager.Instance.buildFirstInfo:RemoveListener(self.buildUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.home_build_update, self.useUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.active_point_update, self.useUpdateListener)
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HomeMapArea:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.homemaparea))
    self.gameObject.name = "HomeMapArea"
    self.gameObject.transform:SetParent(HomeManager.Instance.homeCanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

    self.gameObject.transform:SetAsFirstSibling()

    self.mainRect = self.transform:FindChild("Main"):GetComponent(RectTransform)
    -----------------------------
    self.transform:FindChild("Main/MapAreaButton"):GetComponent(Button).onClick:AddListener(function() self:worldmapiconclick() end)
    self.transform:FindChild("Main/CurMapButton"):GetComponent(Button).onClick:AddListener(function() self:curmapiconclick() end)

    self.mapname_text = self.transform:FindChild("Main/MapAreaButton/MapNameText"):GetComponent(Text)
    self.exp_text = self.transform:FindChild("Main/MapAreaButton/ExpText"):GetComponent(Text)
    self.level_name_text = self.transform:FindChild("Main/MapAreaButton/LevelNameText"):GetComponent(Text)
    self.icon_image = self.transform:FindChild("Main/MapAreaButton/Icon"):GetComponent(Image)

    self.exp_transform = self.transform:FindChild("Main/MapAreaButton/Exp")

    self.infoButton = self.transform:FindChild("Main/InfoButton"):GetComponent(Button)
    self.infoButton.onClick:AddListener(function() self:infobuttonclick() end)
    self.infoButton_redPoint = self.infoButton.transform:FindChild("RedPoint").gameObject

    self.useButton = self.transform:FindChild("Main/UseButton"):GetComponent(Button)
    self.useButton.onClick:AddListener(function() self:usebuttononclick() end)
    self.useButton_redPoint = self.useButton.transform:FindChild("RedPoint").gameObject

    self.editButton = self.transform:FindChild("Main/EditButton"):GetComponent(Button)
    self.editButton.onClick:AddListener(function() self:editbuttononclick() end)
    self.editButton_redPoint = self.editButton.transform:FindChild("RedPoint").gameObject

    self.exitButton = self.transform:FindChild("Main/ExitButton"):GetComponent(Button)
    self.exitButton.onClick:AddListener(function() self:exitbuttononclick() end)
    self.exitButton_redPoint = self.exitButton.transform:FindChild("RedPoint").gameObject

    self.infoText = self.transform:Find("Main/InfoText"):GetComponent(Text)

    -----------------------------
    self:update()
    EventMgr.Instance:AddListener(event_name.home_base_update, self._update)
    EventMgr.Instance:AddListener(event_name.home_base_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.home_use_info_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.home_train_info_update, self.useUpdateListener)
    EventMgr.Instance:AddListener(event_name.active_point_update, self.useUpdateListener)

    self:OnUseUpdate()

    self:ClearMainAsset()
end

function HomeMapArea:update()
    if self.gameObject == nil then return end

    self:update_mapname()
    self:update_exp()
    self:update_level()

    self:update_button()
end

function HomeMapArea:update_mapname()
    local roleData = RoleManager.Instance.RoleData
    local homeModel = HomeManager.Instance.model
    local home_data = DataFamily.data_home_data[homeModel.home_lev]
    if home_data == nil then return end
    if homeModel.fid == roleData.fid and homeModel.platform == roleData.family_platform and homeModel.zone_id == roleData.family_zone_id then
        self.mapname_text.text = string.format("%s%s", TI18N("我的"), home_data.name2)
    else
        self.mapname_text.text = string.format("%s%s%s", BaseUtils.string_cut(homeModel.master_name, 12, 9), TI18N("的"), home_data.name2)
    end
end

function HomeMapArea:update_exp()
    local home_data = DataFamily.data_home_data[HomeManager.Instance.model.home_lev]
    if home_data == nil then return end
	self.exp_text.text = string.format("%s/%s", HomeManager.Instance.model.env_val, home_data.max_env+1)

    local scale = HomeManager.Instance.model.env_val / home_data.max_env
    if scale > 1 then
        scale = 1
    end
    self.exp_transform.localScale = Vector3(scale, 1, 1)
end

function HomeMapArea:update_level()
    local home_data = DataFamily.data_home_data[HomeManager.Instance.model.home_lev]
    if home_data == nil then return end
    self.level_name_text.text = home_data.name

    self.icon_image.sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, string.format("home%s", HomeManager.Instance.model.home_lev))
end

function HomeMapArea:cleanText()
    if self.gameObject == nil then return end
    self.mapname_text.text = ""
	self.exp_text.text = ""
	self.level_name_text.text = ""
end

--隐藏四个按钮
function HomeMapArea:hide_all_button()
    if self.gameObject == nil then return end
    self.infoButton.gameObject:SetActive(false)
    self.useButton.gameObject:SetActive(false)
    self.editButton.gameObject:SetActive(false)
    self.exitButton.gameObject:SetActive(false)
end

function HomeMapArea:update_button()
	if self.gameObject == nil then return end

    local nextBtnX = 320

	local show = not HomeManager.Instance.model.editType and HomeManager.Instance.model:CanEditHome()
	self.infoButton.gameObject:SetActive(show)
    if show then
        nextBtnX = 390
    end
    local showUseBtn = false
    if HomeManager.Instance.model:CanEditHome() then
        self.useButton.transform.anchoredPosition = Vector3(nextBtnX, 9, 0)
        for k, v in pairs(HomeManager.Instance.model.build_list) do
            if v.lev > 0 then
                showUseBtn = true
                nextBtnX = nextBtnX + 70
                break
            end
        end
    end
    self.useButton.gameObject:SetActive(showUseBtn)

	self.editButton.gameObject:SetActive(show)
    self.exitButton.gameObject:SetActive(not HomeManager.Instance.model.editType)
    if HomeManager.Instance.model:CanEditHome() then
        --能够显示编辑按钮
        self.editButton.transform.anchoredPosition = Vector3(nextBtnX, 9, 0)
        nextBtnX = nextBtnX + 70
    end
    self.exitButton.transform.anchoredPosition = Vector3(nextBtnX, 9, 0)

    if HomeManager.Instance.model:GetHomeMaxLev() > HomeManager.Instance.model.home_lev then
        self.infoButton_redPoint:SetActive(true)
    else
        self.infoButton_redPoint:SetActive(false)
    end
end

function HomeMapArea:worldmapiconclick()
    WorldMapManager.Instance.model:OpenWindow({2})
end

function HomeMapArea:curmapiconclick()
    WorldMapManager.Instance.model:OpenWindow({2})
    -- WorldMapManager.Instance.model:OpenWindow({1})
end

function HomeMapArea:infobuttonclick()
    local mark = false
    for i,v in ipairs(HomeManager.Instance.model.build_list) do
        if v.lev ~= 0 then
            mark = true
            break
        end
    end
    if mark then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1,1})
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {2,1})
    end
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end

function HomeMapArea:editbuttononclick()
	HomeManager.Instance.model:ShowEditPanel()
end

function HomeMapArea:usebuttononclick()
    HomeManager.Instance.model:ShowUsePanel()
end

function HomeMapArea:exitbuttononclick()
    HomeManager.Instance:ExitHome()
end

function HomeMapArea:TweenHide()
    Tween.Instance:MoveY(self.mainRect, 100, 0.2)
end

function HomeMapArea:TweenShow()
    Tween.Instance:MoveY(self.mainRect, 0, 0.2)
end

function HomeMapArea:OnCheckGuide()
    local homeModel = HomeManager.Instance.model
    local hasBuild = homeModel.is_upgrade_bdg == nil or #homeModel.is_upgrade_bdg ~= 0

    if homeModel.isGuidePlay == false and (not hasBuild) and homeModel:CanEditHome() then
        homeModel.isGuidePlay = true
        DramaManager.Instance.model:JustPlayPlot(21000, function()
            if BaseUtils.is_null(self.gameObject) then
                return
            end
            if self.guideScript == nil then
                self.guideScript = GuideNewFurniture.New()
                self.guideScript:Show(self.infoButton.gameObject)
            end
        end)
    end
end

function HomeMapArea:OnUseUpdate()
    -- 宠物室的空位

    if not self.model:CanEditHome() then
        if self.infoText ~= nil then
            self.infoText.text = nil
        end
        if self.useButton_redPoint ~= nil then
            self.useButton_redPoint:SetActive(false)
        end

        return
    end

    local red = false

    local c = 0
    local build = self.model:getbuild(2)
    local petStr = nil

    if build ~= nil then
        local length = self.model:getbuilddataeffecttype(2, build.lev, 11)
        local left_time = length - self.model:getbuildeffecttypevalue(53)
        -- if build.lev == 0 then  -- 如果当前等级为0，则打开1个宠物栏
        --     -- length = 1
        --     length = 0
        -- end

        red = red and (AgendaManager.Instance:GetActivitypoint() >= 100)

        if left_time ~= 0 then
            petStr = string.format(TI18N("<color='#ffff00'>宠物室:</color><color='#00ff00'>%s</color><color='#ffff00'>/%s</color>"), tostring(left_time), tostring(length))
        end
    end

    -- 卧室的使用
    local all_times = self.model:geteffecttypevalue(12)
    local used_times = self.model:getbuildeffecttypevalue(55)
    red = red or (all_times - used_times > 0)

    local bedStr = nil
    if used_times ~= all_times then
        bedStr = string.format(TI18N("<color='#ffff00'>卧室:</color><color='#00ff00'>%s</color><color='#ffff00'>/%s</color>"), tostring(all_times - used_times), tostring(all_times))
    end

    if self.infoText ~= nil then
        if bedStr == nil then
            self.infoText.text = petStr
        elseif petStr == nil then
            self.infoText.text = bedStr
        else
            self.infoText.text = string.format("%s\n%s", bedStr,petStr)
        end
    end

    if self.useButton_redPoint ~= nil then
        self.useButton_redPoint:SetActive(red)
    end
end
