FaceGetEffectPanel = FaceGetEffectPanel or BaseClass(BasePanel)

function FaceGetEffectPanel:__init(model)

    self.model = model
    self.windowId = WindowConfig.WinID.face_get_effect
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.showListener = function(data) self:ApplyShow(data) end

    self.resList = {
        {file = AssetConfig.face_get_effect, type = AssetType.Main},
    }

    self.isEffectBtn = true
    self.timerId = nil
end

function FaceGetEffectPanel:__delete()
    self.OnHideEvent:Fire()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function FaceGetEffectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.face_get_effect))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    local canvas = self.gameObject:GetComponent(Canvas)
    canvas.overrideSorting = true
    canvas.sortingOrder = 30
    canvas.overrideSorting = false
    self.transform:GetComponent(RectTransform).localPosition = Vector3(0,0,-600)
    self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:ClickEffectPanel() end)
    --self.transform.gameObject:SetActive(false)
    self.OnOpenEvent:Fire()
end

function FaceGetEffectPanel:OnOpen()
    self:RemoveListeners()
    FaceManager.Instance.OnGetShowFace:AddListener(self.showListener)
    self:ShowEffectPanel()
end

function FaceGetEffectPanel:OnHide()
    self:RemoveListeners()
end

function FaceGetEffectPanel:RemoveListeners()
    FaceManager.Instance.OnGetShowFace:RemoveListener(self.showListener)
end

function FaceGetEffectPanel:ShowEffectPanel()
    self.transform.gameObject:SetActive(true)

    if self.effect_1 ~= nil then
        self.effect_1:SetActive(false)
    end
    if self.effect_2 ~= nil then
        self.effect_2:SetActive(false)
    end
    if self.effect_3 ~= nil then
        self.effect_3:SetActive(false)
    end

    if self.effect_2 == nil then
        local fun = function(effectView)
            if BaseUtils.isnull(self.gameObject) then
                return
            end

            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(self.transform:Find("Main"))
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.localPosition = Vector3(234, 117, -400)

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")

            self.effect_2 = effectView
        end
        self.effect_2 = BaseEffectView.New({effectId = 20017, callback = fun})
    else
        self.effect_2:SetActive(false)
        self.effect_2:SetActive(true)
    end

    self.effectTime = BaseUtils.BASE_TIME
end

function FaceGetEffectPanel:ClickEffectPanel()
    if BaseUtils.BASE_TIME - self.effectTime > 0 then
        if self.isEffectBtn == true then
            self.isEffectBtn = false
            print("1111111111111111")
            if self.effect_3 == nil then
                local fun = function(effectView)
                    if BaseUtils.isnull(self.gameObject) then
                        return
                    end

                    local effectObject = effectView.gameObject
                    effectObject.transform:SetParent(self.transform:Find("Main"))
                    effectObject.name = "Effect"
                    effectObject.transform.localScale = Vector3(1, 1, 1)
                    effectObject.transform.localPosition = Vector3(0, 0, -400)

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                    self.effect_3 = effectView
                    self.timerId = LuaTimer.Add(600, function() self:HideEffectPanel() end)
                    print("333333333333333333333333333333333333")
                end
                self.effect_3 = BaseEffectView.New({effectId = 20018, callback = fun})

            else
                self.effect_3:SetActive(false)
                self.effect_3:SetActive(true)

                self.timerId = LuaTimer.Add(1000, function() self:HideEffectPanel() end)
            end
        end
    end
end

function FaceGetEffectPanel:HideEffectPanel()
    self.transform.gameObject:SetActive(false)
    FaceManager.Instance:Send10431(3)
end

function FaceGetEffectPanel:ApplyShow(data)
    if self.giftShow == nil then
        self.giftShow = FaceSaveGetPanel.New(self)
    end
    local myData = {}
    myData.item_list = {}
    myData.item_list[1] = data
    myData.isAngel = true
    self.giftShow:Show(myData)
    self.isEffectBtn = true
end

function FaceGetEffectPanel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
    self.OnHideEvent:Fire()
    self:DeleteMe()
    self.model.effect = nil
end
