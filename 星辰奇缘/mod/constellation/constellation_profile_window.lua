-- 作者:jia
-- 6/17/2017 3:00:45 PM
-- 功能:星座驾照界面

ConstellationProfileWindow = ConstellationProfileWindow or BaseClass(BaseWindow)
function ConstellationProfileWindow:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.constellationprofilewindow, type = AssetType.Main }
        ,{ file = AssetConfig.res_constellation, type = AssetType.Dep }
    }
    self.windowId = WindowConfig.WinID.constellation_profile_window
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)

    self.originHeight = 312
    self.maxWidth = 510
    self.originWidth = 40
    self.isShare = false
    self.hasInit = false
end

function ConstellationProfileWindow:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ConstellationProfileWindow:OnHide()

end

function ConstellationProfileWindow:OnOpen()
    if self.openArgs ~= nil then
        self:UpdateData(self.openArgs)
    end
end

function ConstellationProfileWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.constellationprofilewindow))
    self.gameObject.name = "ConstellationProfileWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.Panel = self.transform:Find("Panel")
    self.mainRect = self.transform:Find("Main")
    self.mainRect.sizeDelta = Vector2(self.originWidth, self.originHeight)

    self.ConHead = self.transform:Find("Main/Bg/Content/InfoCon/ConHead")
    self.headSlot = HeadSlot.New(nil,true)
    self.headSlot:SetRectParent(self.ConHead:Find("Head").gameObject)
    self.headSlot:HideSlotBg(true)
    self.TxtTitleLev = self.transform:Find("Main/Bg/Content/InfoCon/ConTitleLev/TxtTitleLev"):GetComponent(Text)

    self.TxtName = self.transform:Find("Main/Bg/Content/InfoCon/TxtName"):GetComponent(Text)

    self.TxtCanKill = self.transform:Find("Main/Bg/Content/InfoCon/TxtCanKill"):GetComponent(Text)

    self.TxtTeamKill = self.transform:Find("Main/Bg/Content/InfoCon/TxtTeamKill"):GetComponent(Text)

    self.BtnShare = self.transform:Find("Main/Bg/Content/InfoCon/BtnShare"):GetComponent(Button)

    self.BtnProfile = self.transform:Find("Main/Bg/Content/InfoCon/BtnProfile"):GetComponent(Button)

    self.ShareCon = self.transform:Find("Main/ShareCon")
    self.ShareCon.gameObject:SetActive(self.isShare)
    self.SharePanel = self.ShareCon:Find("ImgPanel"):GetComponent(Button)
    self.BtnShareChat = self.ShareCon:Find("BtnChat"):GetComponent(Button)
    self.BtnShareFriend = self.ShareCon:Find("BtnFriend"):GetComponent(Button)

    self.BtnShare.onClick:AddListener( function()
        self.isShare = not self.isShare
        self.ShareCon.gameObject:SetActive(self.isShare)
    end )

    self.SharePanel.onClick:AddListener( function()
        self.isShare = not self.isShare
        self.ShareCon.gameObject:SetActive(self.isShare)
    end )

    self.BtnShareChat.onClick:AddListener( function()
        self.isShare = not self.isShare
        self.ShareCon.gameObject:SetActive(self.isShare)
        self.model:OnShareFightScore()
    end )

    local setting = { title = TI18N("星座驾照分享"), type = 3 }
    self.quickpanel = ZoneQuickShareStr.New(setting)
    self.BtnShareFriend.onClick:AddListener( function()
        self.isShare = not self.isShare
        self.ShareCon.gameObject:SetActive(self.isShare)
        self.quickpanel:Show()
    end )

    self.BtnProfile.onClick:AddListener(
    function()
        self.model:OpenHonorWindow()
    end )
    self.closeBtn = self.transform:Find("Main/Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener( function() self:OnClose(true) end)
    self.closeBtn.gameObject:SetActive(false)
end

function ConstellationProfileWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ConstellationProfileWindow:UpdateData(profileDat)
    if profileDat ~= nil then
        self.profileData = profileDat


        local data = { };
        data.sex = self.profileData.Sex
        data.classes = self.profileData.Classes
        data.id = self.profileData.RoldID
        data.platform = self.profileData.Platform
        data.zone_id = self.profileData.ZoneID
        data.name = self.profileData.Name
       local  RoleData = RoleManager.Instance.RoleData
       local isSelf = RoleData.id == data.id and RoleData.zone_id == data.zone_id and RoleData.platform == data.platform
        self.BtnProfile.gameObject:SetActive(isSelf)
        self.headSlot:SetAll(data, {
            isSmall = false,
            clickCallback =
            function()
                TipsManager.Instance:ShowPlayer(
                { id = data.id, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name })
            end
        } )
        local CanLev = self.profileData.CanKill + 1
        CanLev = math.min(CanLev, 14);
        self.TxtName.text = string.format(TI18N("名称：%s"), self.profileData.Name)
        self.TxtCanKill.text = string.format(TI18N("级别：可挑战%s星"), CanLev)
        self.TxtTeamKill.text = string.format(TI18N("最高击杀：%s星"), self.profileData.MaxKill)
        self.TxtTitleLev.text = ConstellationEumn.TitleLev[self.profileData.CanKill]
        self:Release()
    else
        self:OnClose(false)
    end

end

-- 收起
function ConstellationProfileWindow:RollUp(delta, callback)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.counter = 0
    self.timerId = LuaTimer.Add(0, 10, function()
        self.counter = self.counter + 1
        local offsetX = self.maxWidth - self.counter * 20
        self.mainRect.sizeDelta = Vector2(offsetX, self.originHeight)
        if self.mainRect.sizeDelta.x <= self.originWidth - 20 then
            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
                if callback ~= nil then
                    callback()
                    -- LuaTimer.Add(200, callback)
                end
            end
        end
    end )
end

function ConstellationProfileWindow:OnClose(isEffect)
    self.closeBtn.gameObject:SetActive(false)
    if isEffect then
        self:RollUp(200, function() WindowManager.Instance:CloseWindowById(self.windowId, false) end)
    else
        WindowManager.Instance:CloseWindowById(self.windowId, false)
    end
end

-- 展开
function ConstellationProfileWindow:Release()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.currentPos = 0
    self.currentVel = 2
    self.timerId = LuaTimer.Add(0, 10,
    function()
        self.currentPos = self.currentPos + 1
        local totleVel = self.originWidth + self.currentPos * 20
        self.mainRect.sizeDelta = Vector2(totleVel, self.originHeight)
        if totleVel >= self.maxWidth then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
            self.closeBtn.gameObject:SetActive(true)
        end
    end
    )
end