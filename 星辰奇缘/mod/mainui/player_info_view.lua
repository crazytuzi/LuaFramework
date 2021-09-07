-- 主界面 选中玩家头像
PlayerInfoView = PlayerInfoView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function PlayerInfoView:__init(parent)
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.playerselect, type = AssetType.Main}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    self.name = "PlayerInfoView"

    self.gameObject = nil
    self.transform = nil
    self.isshow = true

    self.adaptListener = function() self:AdaptIPhoneX() end

    self:LoadAssetBundleBatch()
end

function PlayerInfoView:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PlayerInfoView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playerselect))
    self.gameObject.name = "PlayerInfoView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(212, 142, 1)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)
    self.Frame = self.gameObject.transform:Find("Frame"):GetComponent(Image)
    -- self.gameObject.transform:SetAsFirstSibling()

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform
    self.headicon = self.transform:Find("Head"):GetComponent(Image)
    self.levTxt = self.transform:Find("Text"):GetComponent(Text)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:Onclick() end)

    self.headSlot = HeadSlot.New()
    self.headicon.transform.anchoredPosition = Vector2(0.55, 0)
    self.headicon.transform.sizeDelta = Vector2(56, 56)
    self.headSlot:SetRectParent(self.headicon.gameObject)
    self:ClearMainAsset()

    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    self:AdaptIPhoneX()
    self.gameObject:SetActive(false)
end

function PlayerInfoView:SetData(data)
    self.data = data
    self:update_head()
    self.gameObject:SetActive(true)
    UnitStateManager.Instance.model:Layout(true, self.gameObject.transform.anchoredPosition)
end

function PlayerInfoView:update_head()

    -- self.headicon.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.classes, self.data.sex))
    -- BaseUtils.dump(self.data)
    self.headicon.enabled = false
    local dat = {id = self.data.roleid, platform = self.data.platform, zone_id = self.data.zoneid, classes = self.data.classes, sex = self.data.sex}
    self.headSlot:HideSlotBg(true, -0.01)
    self.headSlot:SetAll(dat, {isSmall = true, clickCallback = function() self:Onclick() end})
    self.levTxt.text = tostring(self.data.lev)
    local frameid = nil
    for k,v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_role_frame then
            frameid = v.looks_val
            break
        end
    end
    if frameid ~= nil then
        self.Frame.sprite = PreloadManager.Instance:GetSprite(AssetConfig.rolelev_frame, tostring(frameid))
        self.Frame.gameObject:SetActive(true)
    else
        self.Frame.gameObject:SetActive(false)
    end
    -- self.roleHeadImage:SetNativeSize()
    self:TraceSwitch(self.isshow)
end

function PlayerInfoView:SetLev()
    self.levTxt.text = tostring(self.data.lev)
end

function PlayerInfoView:hide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
        UnitStateManager.Instance.model:Layout(false, self.gameObject.transform.anchoredPosition)
    end
end

function PlayerInfoView:Onclick()
    TipsManager.Instance:ShowPlayer(self.data)
end

function PlayerInfoView:TraceSwitch(isshow)
    if BaseUtils.isnull(self.gameObject) then return end
    
    if isshow then
        Tween.Instance:MoveX(self.transform, self.containerOriginX, 0.2, function()end)
    else
        Tween.Instance:MoveX(self.transform, self.containerOriginX + 190, 0.2, function()end)
    end
    self.isshow = isshow
end

function PlayerInfoView:AdaptIPhoneX()
    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            self.containerOriginX = -300
        else
            self.containerOriginX = -288
        end
    else
        self.containerOriginX = -270
    end

    self:TraceSwitch(self.isshow == true)
end