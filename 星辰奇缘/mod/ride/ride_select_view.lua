RideSelectView  =  RideSelectView or BaseClass(BasePanel)

function RideSelectView:__init(model)
    self.name  =  "RideSelectView"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.rideselectwindow, type  =  AssetType.Main}
        , {file = AssetConfig.headride, type = AssetType.Dep}
    }

    self.is_open  =  false

    self.item_list = nil

    return self
end


function RideSelectView:__delete()

    self.is_open  =  false

    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            item:Release()
        end
    end

    self.item_list = nil
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function RideSelectView:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.rideselectwindow))
    self.gameObject.name  =  "RideSelectView"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRideSelectUI() end)



    self.Main = self.transform:FindChild("Main")
    self.CloseButton = self.Main:FindChild("CloseButton"):GetComponent("Button")

    self.mask = self.Main:FindChild("mask")
    self.ItemContainer = self.mask:FindChild("ItemContainer")
    self.Item = self.ItemContainer:FindChild("Item").gameObject


    self.OkButton = self.Main:FindChild("OkButton"):GetComponent("Button")

    self.CloseButton.onClick:AddListener(function() self.model:CloseRideSelectUI()  end)
    self.OkButton.onClick:AddListener(function() self.sureCallBack(self.selectData) self.model:CloseRideSelectUI() end)


    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.clickCallBack = self.openArgs[1] -- 点击回调
        if #self.openArgs > 1 then
            self.sureCallBack = self.openArgs[2] -- 确定回调
        end
    end
    ---更新坐骑列表
    self:update_ride_list()
end


function RideSelectView:update_ride_list()

    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            item.gameObject:SetActive(false)
        end
    else
        self.item_list = {}
    end

    local index = 1
    for key,val in pairs(self.model.ridelist) do
        if val.live_status == 3 then
            --只显示已经激活的
            local item = self.item_list[index]
            if item == nil then
                item = RideSelectItem.New(self, self.Item, index)
            end
            item:set_item_data(val, self.clickCallBack)
            item.gameObject:SetActive(true)
            index = index + 1
        end
    end

    local len = index - 1
    local newH = 80*len
    local rect = self.ItemContainer:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(357, newH)
end

function RideSelectView:item_click(data)
    self.selectData = data
end