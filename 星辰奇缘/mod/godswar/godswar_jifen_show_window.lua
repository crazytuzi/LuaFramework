-- ----------------------------------------------------------
-- UI - 诸神徽章分享
-- @zyh
-- ----------------------------------------------------------
GodsWarsJiFenShowWindow = GodsWarsJiFenShowWindow or BaseClass(BaseWindow)

function GodsWarsJiFenShowWindow:__init(model)
    self.model = model
    self.name = "GodsWarsJiFenShowWindow"
    self.windowId = WindowConfig.WinID.godswarshowwin

    self.resList = {
        {file = AssetConfig.godswarsshowpanel, type = AssetType.Main},
        {file = AssetConfig.godswartexture, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1001, type = AssetType.Dep},
            {file = AssetConfig.godswarjifenlight, type = AssetType.Dep},
         {file = AssetConfig.godswarjifenCircleBg, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1002, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1000, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1003, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1004, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1005, type = AssetType.Dep},
        {file = AssetConfig.godswarjifenBadge1006, type = AssetType.Dep},


    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.startLeftObjList = {}
    self.startRightObjList = {}

    self.roleOtherListener = function() self:UpdateRoleOtherStatus() end
    self.roleListener = function() self:UpdateRoleStatus() end

end

function GodsWarsJiFenShowWindow:AddAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarOtherData:AddListener(self.roleOtherListener)
    GodsWarManager.Instance.OnUpdateGodsWarData:AddListener(self.roleListener)
end

function GodsWarsJiFenShowWindow:RemoveAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarOtherData:RemoveListener(self.roleOtherListener)
    GodsWarManager.Instance.OnUpdateGodsWarData:RemoveListener(self.roleListener)
end

function GodsWarsJiFenShowWindow:OnHide()
    self:RemoveAllListeners()

end

function GodsWarsJiFenShowWindow:__delete()
    self:OnHide()

    if self.rotateId ~= nil then
        Tween.Instance:Cancel(self.rotateId)
       self.rotateId = nil
    end
   if self.leftCircleBg ~= nil and self.leftCircleBg.sprite ~= nil then
        self.leftCircleBg.sprite = nil
    end

    if self.leftLightBg ~= nil and self.leftLightBg.sprite ~= nil then
        self.leftLightBg.sprite = nil
    end

    if self.rightCircleBg ~= nil and self.rightCircleBg.sprite ~= nil then
        self.rightCircleBg.sprite = nil
    end

    if self.rightLightBg ~= nil and self.rightLightBg.sprite ~= nil then
        self.rightLightBg.sprite = nil
    end

    if self.rightBadgeImage ~= nil and self.rightBadgeImage.sprite ~= nil then
        self.rightBadgeImage.sprite = nil
    end

    if self.leftBadgeImage ~= nil and self.leftBadgeImage.sprite ~= nil then
        self.leftBadgeImage.sprite = nil
    end
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function GodsWarsJiFenShowWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarsshowpanel))
    self.gameObject.name = "GodsWarsJiFenShowWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.leftBadgeImage = self.transform:Find("Panel/LeftBadge/Badge"):GetComponent(Image)
    self.rightBadgeImage = self.transform:Find("Panel/RightBadge/Badge"):GetComponent(Image)

    self.leftTitle = self.transform:Find("Panel/LeftBadge/TitleBg/Text"):GetComponent(Text)
    self.rightTitle = self.transform:Find("Panel/RightBadge/TitleBg/Text"):GetComponent(Text)

    self.rightBadgePanel = self.transform:Find("Panel/RightBadge")
    self.startleftContaner = self.transform:Find("Panel/LeftBadge/Levels")
    self.leftJiFenText = self.transform:Find("Panel/LeftBadge/JifenText"):GetComponent(Text)
    self.rightJiFenText = self.transform:Find("Panel/RightBadge/JifenText"):GetComponent(Text)


    self.leftCircleBg = self.transform:Find("Panel/LeftBadge/Bg"):GetComponent(Image)
    self.leftLightBg = self.transform:Find("Panel/LeftBadge/Light"):GetComponent(Image)

    self.leftCircleBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenCircleBg,"GodsWarCircleBg")
    self.leftLightBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenlight,"GodsWarLightBg")

    self.rightCircleBg = self.transform:Find("Panel/RightBadge/Bg"):GetComponent(Image)
    self.rightLightBg = self.transform:Find("Panel/RightBadge/Light"):GetComponent(Image)

    self.rightCircleBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenCircleBg,"GodsWarCircleBg")
    self.rightLightBg.sprite = self.assetWrapper:GetSprite(AssetConfig.godswarjifenlight,"GodsWarLightBg")

    self.leftLightBg.gameObject:SetActive(true)
    self.rightLightBg.gameObject:SetActive(true)

    self.leftCircleBg.gameObject:SetActive(true)
    self.rightCircleBg.gameObject:SetActive(true)

    for i = 1,3 do
        local go = self.startleftContaner:GetChild(i - 1).gameObject
        table.insert(self.startLeftObjList,go)
    end

    self.startRightContaner = self.transform:Find("Panel/RightBadge/Levels")
    self.startleftContaner.transform.anchoredPosition = Vector2(0,167)
    self.startRightContaner.transform.anchoredPosition = Vector2(0,167)
    for i = 1,3 do
        local go = self.startRightContaner:GetChild(i - 1).gameObject
        table.insert(self.startRightObjList,go)
    end

    self.shareChat = self.transform:Find("Panel/LeftBadge/ShareButton"):GetComponent(Button)
    self.shareChat.onClick:AddListener(function()
        WorldChampionManager.Instance.model:OnShareGodsWar()
    end)
    self.OnOpenEvent:Fire()
    -- self.transform:SetAsLastSibling()

    -- LuaTimer.Add(100, function() self.transform:SetAsLastSibling() end)
end

function GodsWarsJiFenShowWindow:OnShow()
    self:RemoveAllListeners()
    self:AddAllListeners()
    self.isMySelf = true
    if self.openArgs ~= nil then
        if self.openArgs.rid == RoleManager.Instance.RoleData.id and self.openArgs.zone_id == RoleManager.Instance.RoleData.zone_id and self.openArgs.platform == RoleManager.Instance.RoleData.platform then
            GodsWarManager.Instance:Send17936()
        else
            GodsWarManager.Instance:Send17936(true,self.openArgs.rid,self.openArgs.platform,self.openArgs.zone_id)
            self.isMySelf = false
        end
    end
end

function GodsWarsJiFenShowWindow:UpdateRoleStatus()


        self.leftBadgeImage.gameObject:SetActive(true)
        if self.isMySelf == true then
            if self.rotateId ~= nil then
                Tween.Instance:Cancel(self.rotateId)
                self.rotateId = nil
            end
            self.rotateId = Tween.Instance:RotateZ(self.leftLightBg.gameObject, -720, 30, function() end):setLoopClamp().id
            self.rightBadgePanel.gameObject:SetActive(false)
        end
        for k,v in pairs(GodsWarManager.Instance.godsWarJiFenAllData.rank_info) do
                if v.rank == GodsWarManager.Instance.godsWarJiFenData.rank_lev then
                    self.myData = v
                    break
                end
        end
        self.leftBadgeImage.sprite = self.assetWrapper:GetSprite(AssetConfig[string.format("godswarjifenBadge%s",self.myData.badge_id)],"GodsWarBadge" .. self.myData.badge_id)
        self.leftBadgeImage:SetNativeSize()
         for i=1,self.myData.star do
                self.startLeftObjList[i].gameObject:SetActive(true)
        end

        if #self.startLeftObjList > self.myData.star then
            for i2=self.myData.star + 1,#self.startLeftObjList do
                self.startLeftObjList[i2].gameObject:SetActive(false)
            end
        end

        if self.myData.star == 1 then
            self.startLeftObjList[1].transform.anchoredPosition = Vector2(-4.2,-66.7)
        end

        if self.myData.star == 2 then
            self.startLeftObjList[1].transform.anchoredPosition = Vector2(-27,-74)
            self.startLeftObjList[2].transform.anchoredPosition = Vector2(27,-74)
        end

        if self.myData.star == 3 then
            self.startLeftObjList[1].transform.anchoredPosition = Vector2(-50,-81.2)
            self.startLeftObjList[2].transform.anchoredPosition = Vector2(-4.2,-66.7)
            self.startLeftObjList[3].transform.anchoredPosition = Vector2(42.3,-79.5)
        end


        self.leftTitle.text = string.format("%s",self.myData.name)

    self.leftJiFenText.text = string.format("诸神积分:%s",GodsWarManager.Instance.godsWarJiFenData.gods_duel_score)
end


function GodsWarsJiFenShowWindow:UpdateRoleOtherStatus()


        for k,v in pairs(GodsWarManager.Instance.godsWarJiFenAllData.rank_info) do
                if v.rank == GodsWarManager.Instance.godsWarJiFenOtherData.rank_lev then
                    self.otherData = v
                    break
                end
        end
        if self.isMySelf == true then
            self.rightBadgePanel.gameObject:SetActive(false)
        else
            if self.rotateId ~= nil then
                Tween.Instance:Cancel(self.rotateId)
                self.rotateId = nil
            end
            if GodsWarManager.Instance.godsWarJiFenData.gods_duel_score >= GodsWarManager.Instance.godsWarJiFenOtherData.gods_duel_score then
                self.rotateId = Tween.Instance:RotateZ(self.leftLightBg.gameObject, -720, 30, function() end):setLoopClamp().id
            else
                self.rotateId = Tween.Instance:RotateZ(self.rightLightBg.gameObject, -720, 30, function() end):setLoopClamp().id
            end

            self.rightBadgePanel.gameObject:SetActive(true)
            -- self.rightBadgeImage.sprite = self.assetWrapper:GetSprite(AssetConfig[string.format("godswarjifenBadge%s",self.nextData.badge_id)],string.format("GodsWarBadge%s",self.otherData.badge_id))
            self.rightBadgeImage.sprite = self.assetWrapper:GetSprite(AssetConfig[string.format("godswarjifenBadge%s",self.otherData.badge_id)],"GodsWarBadge" .. self.otherData.badge_id)
            self.rightBadgeImage:SetNativeSize()
            self.rightBadgeImage.gameObject:SetActive(true)

        end

         for i=1,self.otherData.star do
                self.startRightObjList[i].gameObject:SetActive(true)
        end

        if #self.startRightObjList > self.otherData.star then
            for i2=self.otherData.star + 1,#self.startRightObjList do
                self.startRightObjList[i2].gameObject:SetActive(false)
            end
        end

        if self.otherData.star == 1 then
            self.startRightObjList[1].transform.anchoredPosition = Vector2(-4.2,-66.7)
        end

        if self.otherData.star == 2 then
            self.startRightObjList[1].transform.anchoredPosition = Vector2(-27,-74)
            self.startRightObjList[2].transform.anchoredPosition = Vector2(27,-74)
        end

        if self.otherData.star == 3 then
            self.startRightObjList[1].transform.anchoredPosition = Vector2(-50,-81.2)
            self.startRightObjList[2].transform.anchoredPosition = Vector2(-4.2,-66.7)
            self.startRightObjList[3].transform.anchoredPosition = Vector2(42.3,-79.5)
        end

        self.rightTitle.text = string.format("%s",self.otherData.name)

    self.rightJiFenText.text = string.format("诸神积分:%s",GodsWarManager.Instance.godsWarJiFenOtherData.gods_duel_score)

end


