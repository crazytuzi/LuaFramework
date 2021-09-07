NoticeFlyPanel = NoticeFlyPanel or BaseClass(BasePanel)

function NoticeFlyPanel:__init(model)
    self.model = model
    self.name = "NoticeFlyPanel"

    self.resList = {
        {file = AssetConfig.fly_item_panel, type = AssetType.Main},
    }

    self.moveSpeed = 50          -- 单位：像素每秒

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NoticeFlyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fly_item_panel))

    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.model.noticeCanvas.gameObject, self.gameObject)
    self.transform.anchoredPosition = Vector2(0, 0)

    self.gameObject:SetActive(false)

    self.item = t:Find("ItemBg")
    self.iconImage = self.item:Find("Icon"):GetComponent(Image)

    self.item:GetComponent(Image).enabled = false
end

function NoticeFlyPanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end


-- 以左上角为原点
-- data = {
--     item = {
--         base_id,
--     },
--     begin_pos = Vector2(),
--     end_pos = Vector2(),
--     appear_time = 0.5,
--     stop_time = 0.5
--     moving_time = 0.5,
--     diappear_time = 0.5,
-- }
function NoticeFlyPanel:SetData(data)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if data.item == nil or data.item.base_id == nil then
        Log.Error("请传入正确的物品base_id")
    end
    if GlobalEumn.CostTypeIconName[data.item.base_id] == nil then
        if self.imgLoader == nil then
            local go = self.iconImage.gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[data.item.base_id].icon)
    else
        self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.item.base_id])
    end

    self.data = data
    self.gameObject:SetActive(true)

    self:AppearGrow()
end

function NoticeFlyPanel:OnOpen()
end

function NoticeFlyPanel:OnHide()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end

function NoticeFlyPanel:AppearGrow()
    self.item.localScale = Vector3(0.6, 0.6, 1)
    self.item.transform.anchoredPosition = self.data.begin_pos

    self.tweenId = Tween.Instance:Scale(self.item.gameObject, Vector3(1.3, 1.3, 1), (self.data.appear_time or 0.5) / 2, function() self:AppearNarrow() self.tweenId = nil end, LeanTweenType.linear).id
end

function NoticeFlyPanel:AppearNarrow()
    self.item.localScale = Vector3(1.3, 1.3, 1)
    self.tweenId = Tween.Instance:Scale(self.item.gameObject, Vector3.one, (self.data.appear_time or 0.5) / 2, function() self:Stop() self.tweenId = nil end, LeanTweenType.easeInCubic).id
end

function NoticeFlyPanel:Moving()
    self.item.localScale = Vector3.one
    self.tweenId = Tween.Instance:Move(self.item, self.data.end_pos, self.data.moving_time or 0.5, function() self:Disappear() self.tweenId = nil end, LeanTweenType.linear).id
end

function NoticeFlyPanel:Disappear()
    self.item.anchoredPosition = self.data.end_pos

    -- self.tweenId = Tween.Instance:Scale(self.item.gameObject, Vector3.zero, self.data.disappear_time or 0.5, function() self.gameObject:SetActive(false) self.tweenId = nil end, LeanTweenType.linear).id

    self.gameObject:SetActive(false)
end

function NoticeFlyPanel:Stop()
    local pos = Vector3(self.item.anchoredPosition.x, self.item.anchoredPosition.y, 0)
    self.tweenId = Tween.Instance:Move(self.item, pos, self.data.stop_time or 0.5, function() self:Moving() self.tweenId = nil end, LeanTweenType.linear).id
end
