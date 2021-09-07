GodsWarWorShipIcon = GodsWarWorShipIcon or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function GodsWarWorShipIcon:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.godswarworshipicon, type = AssetType.Main}
        ,{file = AssetConfig.godswarworshiptexture, type = AssetType.Dep}
        -- , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }

    self.name = "GodsWarWorShipIcon"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._update = function()
        self:update()
    end

    self._updatestatus = function()
        self:UpdateStatus()
    end

    self:LoadAssetBundleBatch()
end

function GodsWarWorShipIcon:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    self:AssetClearAll()
end

function GodsWarWorShipIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarworshipicon))
    self.gameObject.name = "GodsWarWorShipIcon"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

    -----------------------------
    local transform = self.transform

    self.button = transform:FindChild("Button").gameObject
    -- self.button.transform.anchoredPosition = Vector2(0,self.button.transform.anchoredPosition.y)
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.buttonImage = self.button.gameObject:GetComponent(Image)

    self.button2 = transform:FindChild("Button2").gameObject
     -- self.button2.gameObject:SetActive(false)
    self.button2:GetComponent(Button).onClick:AddListener(function() self:button_click2() end)

    self.button3 = transform:FindChild("Button3").gameObject
     -- self.button2.gameObject:SetActive(false)
    self.button3:GetComponent(Button).onClick:AddListener(function() self:button_click3() end)
    self.button3:SetActive(false)

    self.timeObj = transform:Find("Time").gameObject
    self.timeText = transform:Find("Time/Text"):GetComponent(Text)

    if self.effect == nil then
        local fun = function(effectView)
            if BaseUtils.is_null(self.gameObject) then
                GameObject.Destroy(effectView.gameObject)
                return
            end
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.button.transform)
            effectObject.transform.localScale = Vector3(1.2, 1.2, 1.2)
            effectObject.transform.localPosition = Vector3(-2, 5, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect = BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
    else
        self.effect:SetActive(true)
    end

    if self.effect2 == nil then
        local fun = function(effectView)
            if BaseUtils.is_null(self.gameObject) then
                GameObject.Destroy(effectView.gameObject)
                return
            end
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.button2.transform)
            effectObject.transform.localScale = Vector3(1.2, 1.2, 1.2)
            effectObject.transform.localPosition = Vector3(-2, 5, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect2 = BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
    else
        self.effect2:SetActive(true)
    end

    if self.effect3 == nil then
        local fun = function(effectView)
            if BaseUtils.is_null(self.gameObject) then
                GameObject.Destroy(effectView.gameObject)
                return
            end
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.button3.transform)
            effectObject.transform.localScale = Vector3(1.2, 1.2, 1.2)
            effectObject.transform.localPosition = Vector3(-2, 5, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect3 = BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
    else
        self.effect3:SetActive(true)
    end
    -----------------------------

    self:Show()
    GodsWarWorShipManager.Instance:Send17938()
    -- self:ClearMainAsset()
end

function GodsWarWorShipIcon:Show()
    -- print(debug.traceback())
    EventMgr.Instance:AddListener(event_name.end_fight, self._update)
    EventMgr.Instance:AddListener(event_name.begin_fight, self._update)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipStatus:AddListener(self._updatestatus)

    self:update()
end

function GodsWarWorShipIcon:Hide()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self._update)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self._update)
    GodsWarWorShipManager.Instance.OnUpdateGodsWarWorShipStatus:RemoveListener(self._updatestatus)
end

function GodsWarWorShipIcon:update()
    LuaTimer.Add(1500,function()
        if not BaseUtils.is_null(self.gameObject) then
            local IsFight = CombatManager.Instance.isFighting
            if IsFight then
                self.gameObject:SetActive(false)
            else
                self.gameObject:SetActive(true)
            end
        end
    end)


    -- local ChallengeStatus = GodsWarWorShipManager.Instance.godsChallengeStatus
    -- if ChallengeStatus ~= 0 then
    --     if self.button3 ~= nil then
    --         self.button3:SetActive(true)
    --     end
    -- end
end

function GodsWarWorShipIcon:button_click()
    if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Away then
       NoticeManager.Instance:FloatTipsByString(TI18N("你正在队伍中，不能进行此操作"))
       return
    end
    local isHasNpc = false
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for k,v in pairs(units) do
        if v.baseid == 43088 then
           SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
           isHasNpc = true
           break
        end
    end
    if isHasNpc == false then
        NoticeManager.Instance:FloatTipsByString("暂未可以膜拜")
    end
end

function GodsWarWorShipIcon:button_click2()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1})
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswarworship_video, {type = 1})
end

function GodsWarWorShipIcon:button_click3()
    if GodsWarWorShipManager.Instance.godsWarStatus ~= 0 then
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.GodsWarWorShip then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {7, 1, isChoose = true})
        end
    end
end

function GodsWarWorShipIcon:UpdateStatus()
    local status = GodsWarWorShipManager.Instance.godsWarStatus
    local bossStatus = GodsWarWorShipManager.Instance.BossStatus
    if (status == 3 and bossStatus == 0) or status == 2 then
        if self.button ~= nil then
            self.button:SetActive(true)
        end
        if self.button2 ~= nil then
            self.button2:SetActive(true)
        end
        if self.button3 ~= nil then
            self.button3:SetActive(false)
        end
    elseif status == 5 or status == 6 or status == 8 or status == 7 or (status == 3 and bossStatus ~= 0) then
        if self.button ~= nil then
            self.button:SetActive(true)
        end
        if self.button2 ~= nil then
            self.button2:SetActive(false)
        end
        if self.button3 ~= nil then
            self.button3:SetActive(true)
        end
    end
end



