ShopRechargeReturnPanel = ShopRechargeReturnPanel or BaseClass(BasePanel)

function ShopRechargeReturnPanel:__init(model,parent,main,sub)
    self.model = model
    self.parent = parent
    self.mgr = ShopManager.Instance
    self.main = main
    self.sub = sub

    self.resList = {
        {file = AssetConfig.shop_recharge_return_panel, type = AssetType.Main}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
    }

    self.setting = {
        axis = BoxLayoutAxis.Y
        , cspacing = 3
        , border = 4
    }

    self.rtList = {}
    -- for i=1,DataPrivilege.data_section_length do
    for _,v in pairs(DataPrivilege.data_section) do
        table.insert(self.rtList, v)
    end
    table.sort(self.rtList, function(a,b) return a.lev < b.lev end)
    self.rtObjList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateRTListener = function() self:ReloadRTList() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ShopRechargeReturnPanel:__delete()
    self.OnHideEvent:Fire()

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.rtObjList ~= nil then
        for k,v in pairs(self.rtObjList) do
            if v ~= nil then
                v:DeleteMe()
                self.rtObjList[k] = nil
                v = nil
            end
        end
        self.rtObjList = nil
    end
    self.rtList = nil

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShopRechargeReturnPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shop_recharge_return_panel))
    self.gameObject.name = "RechargeReturnPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.container = t:Find("ItemParent/ItemGrid")
    self.cloner = self.container:Find("Item").gameObject
    self.scrollRect = self.container:GetComponent(RectTransform)
    self.containerRect = t:Find("ItemParent"):GetComponent(RectTransform)

    -- self.setting.scrollRect = self.scrollRect
    self.layout = LuaBoxLayout.New(self.container, self.setting)

    self.cloner:SetActive(false)

    self.OnOpenEvent:Fire()
end

function ShopRechargeReturnPanel:OnOpen()
    self:ReloadRTList()
    self:RemoveListeners()

    self.mgr.onUpdateRT:AddListener(self.updateRTListener)

    self.mgr.redPoint[self.main][self.sub] = false
    self.mgr.onUpdateRedPoint:Fire()
end

function ShopRechargeReturnPanel:OnHide()
    self:RemoveListeners()
end

function ShopRechargeReturnPanel:RemoveListeners()
    self.mgr.onUpdateRT:RemoveListener(self.updateRTListener)
end

function ShopRechargeReturnPanel:ReloadRTList()
    local obj = nil

    for i,v in ipairs(self.rtList) do
        v.state = PrivilegeManager.Instance:GetPrivilegeState(v.lev)
    end

    local firstReceivable = 1
    for i,v in ipairs(self.rtList) do
        if v.state == 2 or v.state == 1 then
            firstReceivable = i
            break
        end
    end

    for i,v in ipairs(self.rtList) do
        if self.rtObjList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.rtObjList[i] = ShopRechargeReturnItem.New(self.model, obj, self.assetWrapper)
        end
        self.rtObjList[i]:SetData(v, i, firstReceivable == i)
    end

    for i=#self.rtList + 1, #self.rtObjList do
        self.rtObjList[i]:SetActive(false)
    end


    local y = 0 - self.rtObjList[firstReceivable].rect.anchoredPosition.y
    if self.scrollRect.sizeDelta.y - y < self.containerRect.sizeDelta.y then
        y = self.scrollRect.sizeDelta.y - self.containerRect.sizeDelta.y
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(self.scrollRect.anchoredPosition.y, y, 0.6, function() self.tweenId = nil end, LeanTweenType.easeOutQuad, function(value) self.scrollRect.anchoredPosition = Vector2(0, value) end).id
    -- self.scrollRect.anchoredPosition = Vector2(0, y)
end
