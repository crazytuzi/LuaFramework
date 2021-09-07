GuildMemDeleteWindow  =  GuildMemDeleteWindow or BaseClass(BasePanel)

function GuildMemDeleteWindow:__init(model)
    self.name  =  "GuildMemDeleteWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_mem_delete_win, type  =  AssetType.Main}
    }

    self.is_open  =  false
    return self
end


function GuildMemDeleteWindow:__delete()
    self.is_open  =  false
    if self.titleMsg ~= nil then
        self.titleMsg:DeleteMe()
        self.titleMsg = nil
    end
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildMemDeleteWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_mem_delete_win))
    self.gameObject.name  =  "GuildMemDeleteWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseMemDeleteUI() end)


    self.MainCon = self.transform:FindChild("MainCon")

    local CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseButton.onClick:AddListener(function() self.model:CloseMemDeleteUI() end)

    self.TxtTitle = self.MainCon:FindChild("TxtTitle"):GetComponent(Text)

    self.titleMsg = MsgItemExt.New(self.TxtTitle, 290, 18, 20)

    self.BtnCancel = self.MainCon:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.MainCon:FindChild("BtnCreate"):GetComponent(Button)

    self.MaskCon = self.MainCon:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.ItemCon = self.ScrollCon:FindChild("ItemCon")
    self.Item = self.ItemCon:FindChild("Item").gameObject

    self.BtnCancel.onClick:AddListener(function() self.model:CloseMemDeleteUI() end)
    self.BtnCreate.onClick:AddListener(function()
        self.model.mem_delete_data.sureCallback()
        self.model:CloseMemDeleteUI()
    end)

    self:update_info()
end

--更新面板
function GuildMemDeleteWindow:update_info()
    self.titleMsg:SetData(self.model.mem_delete_data.msg_str)
    local index = 1
    for k, v in pairs(self.model.mem_delete_data.selected_list) do
        if v ~= nil then
            local item = self:create_item(self.Item)
            self:set_item_data(item, v)
            local newY = (index - 1)*-30
            local rect = item.transform:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(0, newY)
            index = index + 1
        end
    end

    local newH = 30*(index-1)
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end


--创建item
function GuildMemDeleteWindow:create_item(clone)
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
function GuildMemDeleteWindow:set_item_data(item,data)
    item.TxtName.text = data.Name
    item.TxtLev.text = string.format("%s%s", data.Lev, TI18N("级"))
    item.TxtClasses.text = KvData.classes_name[data.Classes]
end
