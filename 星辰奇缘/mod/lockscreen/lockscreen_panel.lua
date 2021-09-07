-- 锁屏
-- @author zgs
LockScreenPanel = LockScreenPanel or BaseClass(BasePanel)

function LockScreenPanel:__init(model)
    self.name = "LockScreenPanel"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.lockscreen_panel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.lockscreenicon, type  =  AssetType.Dep}
        , {file = AssetConfig.normalbufficon, type = AssetType.Dep}
    }
    self.scrollValue = 0
    self.isInit = false
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.checkScrollbarFun = function ()
        if self.isInit == true then
            self:checkScrollbar()
        end
    end

    self.updateRoleAsset = function()
        if self.isInit == true then
            self:update_buff()
        end
    end
    EventMgr.Instance:AddListener(event_name.buff_update, self.updateRoleAsset)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateRoleAsset)
end

function LockScreenPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function LockScreenPanel:__delete()
    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    Log.Error("LockScreenPanel:__delete()"..debug.traceback())
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateRoleAsset)
    EventMgr.Instance:RemoveListener(event_name.buff_update, self.updateRoleAsset)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function LockScreenPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lockscreen_panel))
	UIUtils.AddUIChild(NoticeManager.Instance.model.noticeCanvas, self.gameObject)
    self.transform = self.gameObject.transform

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2(-100, -100)
    rect.offsetMax = Vector2(100, 100)


    self.textObj = self.transform:Find("Text").gameObject
    self.Scrollbar = self.transform:Find("Scrollbar"):GetComponent(Scrollbar)
    self.petImg = self.transform:Find("Scrollbar/Sliding Area/Handle/Image"):GetComponent(Image)
    self.Scrollbar.onValueChanged:AddListener(function(value) self:OnValueChanged(value) end)

    self.sImage = self.transform:Find("BgImage/SImage"):GetComponent(Image)
    self.sText = self.transform:Find("BgImage/SImage/Text"):GetComponent(Text)
    self.dImage = self.transform:Find("BgImage/DImage"):GetComponent(Image)
    self.dText = self.transform:Find("BgImage/DImage/Text"):GetComponent(Text)
    self.isInit = true
end

function LockScreenPanel:checkScrollbar()
    if self.Scrollbar.value == 1 then
        self:Hiden()
        -- self:DeleteMe()
    else
        -- local nowVal = self.Scrollbar.value
        -- self.tweenDesc = Tween.Instance:ValueChange(nowVal, 0, time,
        --     function()
        --         self:ActionOver()
        --     end,
        --     nil,
        --     function(val)
        --         self:UpdateVal(val)
        --     end)
        self.Scrollbar.value = 0
        self.textObj:SetActive(true)
    end
end

function LockScreenPanel:OnValueChanged(value)
    self.textObj:SetActive(false)

    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(300, self.checkScrollbarFun)
end

function LockScreenPanel:UpdateWindow()
    if PetManager.Instance.model.battle_petdata ~= nil then
        local headId = tostring(PetManager.Instance.model.battle_petdata.base.head_id)
        self.petImg.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(62, 62)
        -- self.petImg.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)

        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petImg.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,headId)
    else
        self.petImg.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(48, 44)
         if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petImg.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,10099)
        -- self.petImg.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(10099), 10099)
    end
    self.Scrollbar.value = 0
    self.textObj:SetActive(true)

    self:update_buff()
end

function LockScreenPanel:update_buff()
    if SatiationManager:IsHunger() then
        self.sImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hunger")
    else
        self.sImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hungernot")
    end
    self.sText.text = string.format(TI18N("饱食度：%d/200"),RoleManager.Instance.RoleData.satiety)
    -- print("LockScreenPanel:event_name.role_asset_change()"..RoleManager.Instance.RoleData.satiety)
    if AgendaManager.Instance.double_point == 0 then
        self.dImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
    else
        self.dImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
    end
    self.dText.text = TI18N("双倍点数：")..AgendaManager.Instance.double_point
end


