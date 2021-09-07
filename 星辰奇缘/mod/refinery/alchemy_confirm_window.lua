AlchemyConfirmWindow  =  AlchemyConfirmWindow or BaseClass(BasePanel)

function AlchemyConfirmWindow:__init(model)
    self.name  =  "AlchemyConfirmWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.alchemy_confirm_win, type  =  AssetType.Main}
    }

    self.is_open  =  false
    return self
end


function AlchemyConfirmWindow:__delete()
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function AlchemyConfirmWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.alchemy_confirm_win))
    self.gameObject.name  =  "AlchemyConfirmWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0, 0, -310)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseLianhuaConfirmUI() end)


    self.MainCon = self.transform:FindChild("MainCon")

    local CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseButton.onClick:AddListener(function() self.model:CloseLianhuaConfirmUI() end)

    self.TxtTitle = self.MainCon:FindChild("TxtTitle"):GetComponent(Text)

    self.titleMsg = MsgItemExt.New(self.TxtTitle, 290, 18, 20)

    self.BtnCancel = self.MainCon:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.MainCon:FindChild("BtnCreate"):GetComponent(Button)

    self.MaskCon = self.MainCon:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.ItemCon = self.ScrollCon:FindChild("ItemCon")
    self.Item = self.ItemCon:FindChild("Item").gameObject

    self.BtnCancel.onClick:AddListener(function() self.model:CloseLianhuaConfirmUI() end)
    self.BtnCreate.onClick:AddListener(function()
        self.model.confirm_data.sureCallback()
        self.model:CloseLianhuaConfirmUI()
    end)

    self:update_info()
end

--更新面板
function AlchemyConfirmWindow:update_info()
    local index = 1
    local alchemy_num = 0
    for k, v in pairs(self.model.confirm_data.selected_list) do
        if v ~= nil then
            local base_data = DataItem.data_get[v.id]
            alchemy_num = alchemy_num + self:count_item_aclhemy_val(v.itemData , v.num)-- v.num*base_data.alchemy
            local item = self:create_item(self.Item)
            self:set_item_data(item, v)
            local newY = (index - 1)*-30
            local rect = item.transform:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(0, newY)
            index = index + 1
        end
    end

    local msg_str = string.format("%s{assets_2, 90017}<color='#ffff00'>%s</color>", TI18N("炼化以下道具将获得"), alchemy_num)
    self.titleMsg:SetData(msg_str)

    local size = self.titleMsg.contentRect.sizeDelta
    self.titleMsg.contentRect.anchoredPosition = Vector2(-size.x / 2, 123)

    local newH = 30*(index-1)
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end


--创建item
function AlchemyConfirmWindow:create_item(clone)
    local item = {}
    item.gameObject = GameObject.Instantiate(clone)
    item.transform = item.gameObject.transform
    item.gameObject:SetActive(true)

    item.transform:SetParent(clone.transform.parent)
    item.transform.localPosition = Vector3(0, 0, 0)
    item.transform.localScale = Vector3(1, 1, 1)

    item.TxtName = item.transform:FindChild("TxtName"):GetComponent(Text)
    item.TxtLev = item.transform:FindChild("TxtLev"):GetComponent(Text)
    item.TxtClasses = item.transform:FindChild("TxtClasses"):GetComponent(Text)

    return item
end

--设置item数据
function AlchemyConfirmWindow:set_item_data(item,data)
    local base_data = DataItem.data_get[data.id]
    item.TxtName.text = ColorHelper.color_item_name(base_data.quality , string.format("%sx%s", base_data.name, data.num))
    item.TxtLev.text = self:count_item_aclhemy_val(data.itemData, data.num)
    --tostring(data.num*base_data.alchemy)
    -- item.TxtClasses.text = KvData.classes_name[data.Classes]
end

--计算传入的道具的可炼化值
function AlchemyConfirmWindow:count_item_aclhemy_val(info, num)
    local alchemy_num = 0
    if info.type == BackpackEumn.ItemType.limit_fruit then
        local currTime = 0
        local maxTime = DataItem.data_fruit[tonumber(info.base_id)].num
        -- 限量果实显示使用次数
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_time then
                currTime = v.value
            end
        end
        if currTime == 0 then
            currTime = maxTime
        end
        currTime = math.max(currTime, 1)
        alchemy_num = math.ceil(num*info.alchemy*(currTime/maxTime))
    else
        alchemy_num = num*info.alchemy
    end
    return alchemy_num
end
