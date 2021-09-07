ZoneStylePanel = ZoneStylePanel or BaseClass()


function ZoneStylePanel:__init(main, id)
    self.main = main
    self.id = id
    self.gameObject = self.main.StylePanel.gameObject
    self.transform = self.main.StylePanel
    self.baseItem = self.transform:Find("Image").gameObject
    self.data = self:GetBaseData(id)
    self.assetWrapper_List = {}
    self.assetWrapper = AssetBatchWrapper.New()

    self.idtoindex ={
        [10001] = 1,
        [10002] = 1,
        [10003] = 2,
        [10004] = 3,
        [10005] = 3,
    }
    self.itemList = {}
    self.CycleitemList = {}
    -- self.main.currStyle = id
    self.gameObject:SetActive(true)
    self.data.path = "textures/zonestyle/style1.unity3d"
    if self.data ~= nil and id ~= 0 and self.data.path ~= "" then
        self.assetWrapper_List[self.data.path] = self.assetWrapper
        self.resList = {
            {file = self.data.path, type = AssetType.Dep}
            -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
        }
        self.assetWrapper:LoadAssetBundle(self.resList, function () self:InitPanel() end)
    end
end

function ZoneStylePanel:OnInitCompleted()

end

function ZoneStylePanel:__delete()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    for k,v in pairs(self.assetWrapper_List) do
        v:DeleteMe()
    end
    self.assetWrapper_List = nil
end

function ZoneStylePanel:InitPanel(historyWrapper)
    local Wrapper = historyWrapper~= nil and historyWrapper or self.assetWrapper
    -- BaseUtils.dump(Wrapper.resList,"?????????")
    local Findex = self.idtoindex[self.id]
    for i,v in ipairs(self.data.location) do
        local name = string.format("%d_%d", Findex, v[1])
        local x = v[2]--[+3.3]
        local y = v[3]
        local item = self:GetItem()
        local sprite = Wrapper:GetSprite(self.data.path, name)
        table.insert(self.itemList, item)
        local img = item.transform:GetComponent(Image)
        img.sprite = sprite
        img:SetNativeSize()
        item.transform.anchoredPosition = Vector2(x,y)
        item:SetActive(true)
    end
end

function ZoneStylePanel:Reload(id)
    if self.id == id then
        return
    end
    self.id = id
    -- print("重载id："..tostring(self.id))
    -- self.main.currStyle = id
    for i,v in ipairs(self.itemList) do
        v:SetActive(false)
        table.insert(self.CycleitemList, v)
    end
    self.itemList = {}
    -- if self.assetWrapper ~= nil then
    --     self.assetWrapper:DeleteMe()
    --     self.assetWrapper = nil
    -- end
    self.data = self:GetBaseData(id)
    self.data.path = "textures/zonestyle/style1.unity3d"
    if self.data ~= nil and id ~= 0 and self.data.path ~= "" then
        if self.assetWrapper_List[self.data.path] == nil then
            self.assetWrapper = AssetBatchWrapper.New()
            self.resList = {
                {file = self.data.path, type = AssetType.Dep}
                -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
            }
            self.assetWrapper:LoadAssetBundle(self.resList, function () self:InitPanel() end)
        else
            self:InitPanel(self.assetWrapper_List[self.data.path])
        end
    end
end

function ZoneStylePanel:GetItem()
    if #self.CycleitemList > 0 then
        local item = self.CycleitemList[#self.CycleitemList]
        item.transform:SetParent(self.transform)
        item.transform.localScale = Vector3.one
        table.remove(self.CycleitemList)
        return item
    else
        local item = GameObject.Instantiate(self.baseItem)
        item.transform:SetParent(self.transform)
        item.transform.localScale = Vector3.one
        return item
    end
end

function ZoneStylePanel:GetBaseData(id)
    if id == nil then
        id = 0
    end
    for i,v in ipairs(DataFriendZone.data_style) do
        if v.id == id then
            return v
        end
    end
end

