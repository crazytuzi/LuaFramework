--道具仓库
-- @author zgs
ToolsStorePanel = ToolsStorePanel or BaseClass(BasePanel)

function ToolsStorePanel:__init(model,parent)
    self.model = model
    self.name = "ToolsStorePanel"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.toolstoreitems_panel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)

    self._UpdateWindow = function() self:UpdateWindow() end

    self._doubleClickFunc = function (item)
        self:DoubleClick(item)
    end

    self.toggleTab = {}
    self.itemPanel = BackpackItemPanel.New(self,BackpackEumn.StorageType.Backpack,true,self._doubleClickFunc) --右边背包界面
    self.gridPanel = BackpackGridPanel.New(self,nil,BackpackEumn.StorageType.Store,false,self._doubleClickFunc) --左边仓库格子
end

function ToolsStorePanel:DoubleClick(item)
    -- BaseUtils.dump(item,"DoubleClick")
    if item.extra.storageType ==  BackpackEumn.StorageType.Backpack then
        TipsManager.Instance.model:InStore(item.itemData)
    elseif item.extra.storageType ==  BackpackEumn.StorageType.Store then
        TipsManager.Instance.model:OutStore(item.itemData)
    end
end

function ToolsStorePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function ToolsStorePanel:__delete()
    if self.itemPanel ~= nil then
        self.itemPanel:DeleteMe()
    end
    if self.gridPanel ~= nil then
        self.gridPanel:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil

    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._UpdateWindow)
    EventMgr.Instance:RemoveListener(event_name.buff_update, self._UpdateWindow)
end

function ToolsStorePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.toolstoreitems_panel))
    self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent, self.gameObject)

    local toggleGroup = self.transform:Find("ToggleGroup")
    self.toggleTab[1] = toggleGroup:GetChild(0):GetComponent(Toggle)
    self.toggleTab[2] = toggleGroup:GetChild(1):GetComponent(Toggle)
    self.toggleTab[3] = toggleGroup:GetChild(2):GetComponent(Toggle)   
    self.toggleTab[4] = toggleGroup:GetChild(3):GetComponent(Toggle)   
    self.toggleTab[4].gameObject:SetActive(true)
    -- self.toggleTab[3].gameObject:SetActive(false)

    self.sortBtn = self.transform:Find("RestoreButton"):GetComponent(Button)
    self.sortBtn.onClick:AddListener(function() self:RestoreStore() end)

    self.itemPanel.parent = self.gameObject
    self.itemPanel:Show()
    self.gridPanel.parent = self.gameObject
    self.gridPanel:Show()
end
--整理仓库
function ToolsStorePanel:RestoreStore()
    SoundManager.Instance:Play(256)
    BackpackManager.Instance:Send10322({ package_type = 2 })
end

function ToolsStorePanel:OnChangePage(index)
    self.toggleTab[index].isOn = true
end


function ToolsStorePanel:UpdateWindow()
    self.model.storeType = BackpackEumn.StorageType.Store
end


function ToolsStorePanel:OnClickClose()
    self.model:CloseMain()
end


