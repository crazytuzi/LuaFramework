GloryRankPanel = GloryRankPanel or BaseClass(BasePanel)

function GloryRankPanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.name = "GloryRankPanel"
    self.gameObject = gameObject
    self.mgr = GloryManager.Instance

    self.assetWrapper = assetWrapper

    self.itemList = {}

    self.reloadListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function GloryRankPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end

    if self.rankLayout ~= nil then
        self.rankLayout:DeleteMe()
        self.rankLayout = nil
    end

    self.gameObject = nil
    self.assetWrapper = nil
end

function GloryRankPanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.rankCloner = t:Find("Panel/Cloner").gameObject
    self.rankClonerRect = self.rankCloner:GetComponent(RectTransform)
    self.rankCloner:SetActive(false)
    self.rankContainer = t:Find("Panel/Container")
    self.rankLayout = LuaBoxLayout.New(self.rankContainer.gameObject, {axis = BoxLayoutAxis.Y, rspacing = 0})
end

function GloryRankPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryRankPanel:OnOpen()
    self:Reload()
    self:RemoveListeners()
    self.mgr.onUpdateInfo:AddListener(self.reloadListener)
end

function GloryRankPanel:OnHide()
    self:RemoveListeners()

    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:SetActive(false)
        end
    end

    if self.model.rankItem ~= nil then
        self.model.rankItem:Select(false)
        self.model.rankItem = nil
    end
end

function GloryRankPanel:RemoveListeners()
    self.mgr.onUpdateInfo:RemoveListener(self.reloadListener)
end

function GloryRankPanel:Reload()
    local model = self.model
    local level_id = model.selectData.id

    local dataList = nil

    if self.model.rankItem ~= nil then
        self.model.rankItem:Select(false)
        self.model.rankItem = nil
    end

    if model.levelDataList[level_id] == nil then
        return
    end

    if self.type == GloryItemType.type.All then
        dataList = model.levelDataList[level_id].best_rank
    elseif self.type == GloryItemType.type.Recent then
        dataList = model.levelDataList[level_id].recent
    end

    if dataList == nil then dataList = {} end

    for i,v in ipairs(dataList) do
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.rankCloner)
            obj.name = tostring(i)
            self.rankLayout:AddCell(obj)
            self.itemList[i] = GloryRankItem.New(model, obj, self.assetWrapper)
        end
        self.itemList[i]:update_my_self(v, i, self.type)
    end

    self.rankLayout.panelRect.anchoredPosition = Vector2.zero
    self.rankLayout.panelRect.sizeDelta = Vector2(self.rankClonerRect.sizeDelta.x, self.rankClonerRect.sizeDelta.y * #dataList)

    for i=#dataList + 1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end

    if #dataList > 0 then
        self.itemList[1]:OnSelect()
    end
end


