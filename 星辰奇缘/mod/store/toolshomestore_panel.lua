--家园仓库
-- @author ljh 20160721
-- copy by ToolsHomeStorePanel
ToolsHomeStorePanel = ToolsHomeStorePanel or BaseClass(BasePanel)

function ToolsHomeStorePanel:__init(model,parent)
    self.model = model
    self.name = "ToolsHomeStorePanel"
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
    self.gridPanel = BackpackGridPanel.New(self,nil,BackpackEumn.StorageType.HomeStore,false,self._doubleClickFunc) --左边仓库格子
end

function ToolsHomeStorePanel:DoubleClick(item)
    -- BaseUtils.dump(item,"DoubleClick")
    if item.extra.storageType ==  BackpackEumn.StorageType.Backpack then
        TipsManager.Instance.model:InStore(item.itemData)
    elseif item.extra.storageType ==  BackpackEumn.StorageType.HomeStore then
        TipsManager.Instance.model:OutStore(item.itemData)
    end
end

function ToolsHomeStorePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function ToolsHomeStorePanel:__delete()
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

function ToolsHomeStorePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.toolstoreitems_panel))
    self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent, self.gameObject)

    local toggleGroup = self.transform:Find("ToggleGroup")
    self.toggleTab[1] = toggleGroup:GetChild(0):GetComponent(Toggle)
    self.toggleTab[2] = toggleGroup:GetChild(1):GetComponent(Toggle)
    self.toggleTab[3] = toggleGroup:GetChild(2):GetComponent(Toggle)
    self.toggleTab[4] = toggleGroup:GetChild(3):GetComponent(Toggle)
    self.toggleTab[5] = toggleGroup:GetChild(4):GetComponent(Toggle)
    self.toggleTab[4].gameObject:SetActive(true)
    self.toggleTab[5].gameObject:SetActive(true)

    self.sortBtn = self.transform:Find("RestoreButton"):GetComponent(Button)
    self.sortBtn.onClick:AddListener(function() self:RestoreStore() end)

    self.itemPanel.parent = self.gameObject
    self.itemPanel:Show()
    self.gridPanel.parent = self.gameObject
    self.gridPanel:Show()
end
--整理仓库
function ToolsHomeStorePanel:RestoreStore()
    BackpackManager.Instance:Send10322({ package_type = 4 })
end

function ToolsHomeStorePanel:OnChangePage(index)
    self.toggleTab[index].isOn = true
end


function ToolsHomeStorePanel:UpdateWindow()
    self.model.storeType = BackpackEumn.StorageType.HomeStore
end


function ToolsHomeStorePanel:OnClickClose()
    self.model:CloseMain()
end


