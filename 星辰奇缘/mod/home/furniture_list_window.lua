-- ----------------------------------------------------------
-- UI - 家园家具列表窗口
-- ljh 20160809
-- ----------------------------------------------------------
FurnitureListWindow = FurnitureListWindow or BaseClass(BaseWindow)

function FurnitureListWindow:__init(model)
    self.model = model
    self.name = "FurnitureListWindow"
    self.windowId = WindowConfig.WinID.furniturelistwindow

    self.resList = {
        {file = AssetConfig.furniturelistwindow, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.container_item_list = {}
    ------------------------------------------------
    self.tipsText = {
        TI18N("1.每个等级的家园放置某类家具达到数量<color='#ffff00'>上限</color>时，继续放置该类家具将<color='#ffff00'>不再获得繁华值</color>")
        , TI18N("2.家园<color='#ffff00'>等级越高</color>，每种家具可放置的数目<color='#ffff00'>上限越高</color>")
    }
    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FurnitureListWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function FurnitureListWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.furniturelistwindow))
    self.gameObject.name = "FurnitureListWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.descBtn = self.mainTransform:FindChild("DescButton"):GetComponent(Button)
    self.descBtn.onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.descBtn.gameObject, itemData = self.tipsText})
        end)

    self.panel = self.mainTransform:Find("Panel").gameObject
    self.container = self.panel.transform:FindChild("Panel/Container")

    -- for i=1, 11 do
    --     local go = self.container.transform:FindChild(tostring(i)).gameObject
    --     table.insert(self.container_item_list, go)
    -- end
    self.cloneItem = self.container.transform:FindChild("Item").gameObject
    self.cloneItem:SetActive(false)

    ----------------------------

    self:OnShow()
end

function FurnitureListWindow:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function FurnitureListWindow:OnShow()
    self:update()
end

function FurnitureListWindow:OnHide()
end

function FurnitureListWindow:update()
    self.transform:FindChild("Main/PointText"):GetComponent(Text).text = tostring(self.model.env_val)

    local dataList = {}
    for i = 1, 16 do
        local list = self.model:getFurnitureListByType(i)
        -- 按照繁华度排序
        local function sortfun(a,b)
            return a.base.inv_val > b.base.inv_val
        end
        table.sort(list, sortfun)
        dataList[i] = list
    end

    for i, furniture_type_data in ipairs(self.model.furniture_type_list) do
        local item = GameObject.Instantiate(self.cloneItem)
        -- item.transform:SetParent(self.container.transform)
        UIUtils.AddUIChild(self.container, item)
        if i % 2 == 0 then
            item:GetComponent(Image).color = Color(154/255,  198/255, 241/255)
        end

        local num = 0
        local num_max = 0
        local inv_val = 0
        local color = "#00ff00"
        for _, value in ipairs(furniture_type_data.type) do
            local limit_data = DataFamily.data_limit[string.format("%s_%s", self.model.home_lev, value)]
            if limit_data ~= nil then
                num = num + #dataList[value]
                num_max  = num_max + limit_data.count
                local length = limit_data.count
                if length > #dataList[value] then
                    length = #dataList[value]
                end

                for index = 1, length do
                    inv_val = inv_val + dataList[value][index].base.inv_val
                end
            end
        end
        if num >= num_max then
            num = num_max
            color = "#ffff00"
        end

        item.transform:FindChild("Name"):GetComponent(Text).text = furniture_type_data.name
        item.transform:FindChild("Num"):GetComponent(Text).text = string.format("<color='%s'>%s/%s</color>", color, num, num_max)
        item.transform:FindChild("EvnVal"):GetComponent(Text).text = inv_val
    end
end
