GuildTotemWindow  =  GuildTotemWindow or BaseClass(BaseWindow)

function GuildTotemWindow:__init(model)
    self.name  =  "GuildTotemWindow"
    self.model  =  model

    self.resList  =  {
        {file = AssetConfig.guild_totem_win, type = AssetType.Main}
        ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
    }

    return self
end

function GuildTotemWindow:__delete()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v.Img.sprite = nil
        end
    end
    self.img_ToTem.sprite = nil
    self.is_open  =  false
    self.item_list = nil
    self.last_item = nil
    self.current_selected_id = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildTotemWindow:InitPanel()
    self.is_open = true

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_totem_win))
    self.gameObject.name = "GuildTotemWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.CloseButton = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseTotemUI() end)

    local con_mid = self.MainCon.transform:FindChild("ConMid").gameObject
    self.img_ToTem = con_mid.transform:FindChild("TopCon"):FindChild("ImgCon"):FindChild("Img"):GetComponent(Image)
    self.ConItems = con_mid.transform:FindChild("ConItems").gameObject
    self.Content = self.ConItems.transform:FindChild("Content").gameObject
    self.Item = self.Content.transform:FindChild("Item").gameObject

    self.TxtLeftChangeTime = self.MainCon.transform:FindChild("TxtLeftChangeTime"):GetComponent(Text)
    self.BtnPlus = self.MainCon.transform:FindChild("BtnPlus"):GetComponent(Button)
    self.BtnSelected = self.MainCon.transform:FindChild("BtnSelected"):GetComponent(Button)

    self.BtnPlus.onClick:AddListener(function() self:on_click_plus_btn() end)

    self.BtnSelected.onClick:AddListener(function() self:on_click_selected_btn() end) --BtnRest

    self:update_view()

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

----------------各种监听事件
function GuildTotemWindow:on_click_selected_btn(g)
    if self.current_selected_id ~= 0 then
        GuildManager.Instance:request11144(self.current_selected_id)
    end
end

function GuildTotemWindow:on_click_plus_btn(g)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("增加公会图腾修改次数需要消耗<color='#4dd52b'>30万</color>公会资金")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        GuildManager.Instance:request11145()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

------------------------更新逻辑
function GuildTotemWindow:update_view()
    self:update_change_time()
    self.img_ToTem.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon, tostring(self.model.my_guild_data.ToTem))
    self:init_ToTem_girds()
end

function GuildTotemWindow:update_change_time()
    self.TxtLeftChangeTime.text = string.format("%s<color='#8DE92A'>%s</color>", TI18N("剩余修改次数："), tostring(self.model.my_guild_data.ToTemChangeable))
end


-- 初始化道具网格
function GuildTotemWindow:init_ToTem_girds()
    self.item_list = {}
    local ToTemList = {101, 102, 103, 104, 105}
    local selected_item = nil
    for i=1, #ToTemList do
      local itemData = ToTemList[i]
      local item = self:create_ToTem_item(self.Item, itemData)
      item.go.name = tostring(i)
      table.insert(self.item_list, item)
      item.go:GetComponent(Button).onClick:AddListener(function() self:ToTem_click(item) end)

      if self.model.my_guild_data.ToTem == ToTemList[i] then
        selected_item = item
      end
    end
    if selected_item ~= nil then
        self:ToTem_click(selected_item)
    end
end

--创建图腾item
function GuildTotemWindow:create_ToTem_item(originItem, data)
    local item = {}
    item.go = GameObject.Instantiate(originItem)
    UIUtils.AddUIChild(originItem.transform.parent.gameObject,item.go)

    item.go:SetActive(true)

    item.Img = item.go.transform:FindChild("Img"):GetComponent(Image)
    item.ImgSelect = item.go.transform:FindChild("ImgSelect").gameObject
    item.ImgSelect:SetActive(false)

    item.data = data
    item.Img.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon, tostring(item.data))

    return item
end

function GuildTotemWindow:ToTem_click(item)
    if self.last_item ~= nil then
        self.last_item.ImgSelect:SetActive(false)
    end
    item.ImgSelect:SetActive(true)
    self.current_selected_id = item.data
    self.last_item = item
end
