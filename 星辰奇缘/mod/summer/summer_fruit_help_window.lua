--2016/7/14
--zzl
SummerFruitPlantHelpWindow = SummerFruitPlantHelpWindow or BaseClass(BaseWindow)

function SummerFruitPlantHelpWindow:__init(model)
    self.mgr = ShippingManager.Instance
    self.model = model
    self.helper = nil
    self.last_selected_item = nil
    self.helper = nil
    self.resList = {
        {file = AssetConfig.summer_fruit_help_panel, type = AssetType.Main}
    }
    self.name = "ShipFriendHelpWindow"
    self.iconloader = {}
end

function SummerFruitPlantHelpWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
end

function SummerFruitPlantHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_fruit_help_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local trans = self.transform
    self.needitem = trans:Find("Main/ItemCon/Mask/needItem")
    self.needitmCon = trans:Find("Main/ItemCon/Mask/Con")
    self.noText = trans:Find("Main/ItemCon/Mask/noText")
    self.frienditem = trans:Find("Main/FriendCon/Mask/friendItem")
    self.friendcon = trans:Find("Main/FriendCon/Mask/Con")
    self.noFriendText = trans:Find("Main/FriendCon/Mask/noFriendText")
    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Button).onClick:AddListener(function ()
        self:SendHelp()
    end)

    self:LoadFruitMaps()
end


--加载可以求助的item
function SummerFruitPlantHelpWindow:LoadFruitMaps()
    local map_data_list = self.model.fruit_plant_data.list
    local data_list = {}
    for i=1, #map_data_list do
        if map_data_list[i].status == 0 then
            table.insert(data_list, map_data_list[i].id)
        end
    end

    for i=1,#data_list do
        local item = GameObject.Instantiate(self.needitem.gameObject)
        item.transform:SetParent(self.needitmCon)
        item.transform.localScale = Vector3.one
        item:SetActive(true)
        item.name = tostring(data_list[i])
        local cfg_data = DataCampFruit.data_fruit_base[data_list[i]]
        local base_data = DataItem.data_get[cfg_data.item_id]
        local img = item.transform:Find("Slot"):GetComponent(Image)
        local id = img.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(img.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, base_data.icon)
        item.transform:Find("name"):GetComponent(Text).text = base_data.name
        item.transform:Find("exptext"):GetComponent(Text).text = ""
        local color_str = "#2fc823"
        local has_num =BackpackManager.Instance:GetNotExpireItemCount(cfg_data.item_id)
        local need_num = cfg_data.num
        if has_num < need_num then
            color_str = "#df3435"
        end
        item.transform:Find("Text"):GetComponent(Text).text = string.format("<color='%s'>%s</color>/%s", color_str, tostring(has_num) ,tostring(need_num))
        item.transform:GetComponent(Button).onClick:AddListener(function ()
            if self.last_selected_item ~= nil then
                self.last_selected_item.transform:Find("select").gameObject:SetActive(false)
            end
            self.last_selected_item = item
            self.last_selected_item.transform:Find("select").gameObject:SetActive(true)
        end)
    end

    self.helper = {}
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        local frienditem = GameObject.Instantiate(self.frienditem.gameObject)
        frienditem.transform:SetParent(self.friendcon)
        frienditem.transform.localScale = Vector3.one
        frienditem:SetActive(true)
        local key = BaseUtils.Key(v.classes,v.sex)
        frienditem.transform:Find("Slot/icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, key)
        frienditem.transform:Find("Slot/icon").gameObject:SetActive(true)
        if v.sex > 0 then
            frienditem.transform:Find("male").gameObject:SetActive(true)
        else
            frienditem.transform:Find("male").gameObject:SetActive(false)
        end
        frienditem.transform:Find("classes"):GetComponent(Text).text = KvData.classes_name[v.classes]
        frienditem.transform:Find("name"):GetComponent(Text).text = v.name


        frienditem.transform:GetComponent(Button).onClick:AddListener(function ()
            self:SelectFriend(frienditem, v)
            if self.helper ~= nil and #self.helper > 0 and self.selectitemgoid ~= nil and self.selectitemgoid.data.id ~= nil then
                self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            else
                self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            end
        end)
    end
    if #FriendManager.Instance.online_friend_List < 1 then
        self.noFriendText.gameObject:SetActive(true)
    end

end


function SummerFruitPlantHelpWindow:SelectFriend(_go, _data)
    if _go.transform:Find("select").gameObject.activeSelf == false then
        if #self.helper>2 then
            self.helper[1].go.transform:Find("select").gameObject:SetActive(false)
            _go.transform:Find("select").gameObject:SetActive(true)
            table.remove( self.helper, 1)
            table.insert(self.helper, {go = _go, data = _data})
        else
            table.insert(self.helper, {go = _go, data = _data})
            _go.transform:Find("select").gameObject:SetActive(true)
        end
    else
        _go.transform:Find("select").gameObject:SetActive(false)
        for k,v in pairs(self.helper) do
            if v.go == _go then
                table.remove( self.helper, k)
            end
        end
    end
end


function SummerFruitPlantHelpWindow:SendHelp()
    if self.last_selected_item == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要求助的种子"))
        return
    end
    if self.helper == nil or #self.helper == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择好友进行求助"))
        return
    end
    local _table = {}

    for k,v in pairs(self.helper) do
        local _f = {g_id = v.data.id, g_platform = v.data.platform , g_zone_id = v.data.zone_id}
        table.insert(_table, _f)
    end
    local boxid = tonumber(self.last_selected_item.name)

    --BaseUtils.dump(_table)
    SummerManager.Instance:request14022(1, boxid, _table)

    -- for i=1,#_table do
    --     local _f = _table[i]
    --     FriendManager.Instance:SendMsg(id, platform, zone_id, msg)
    -- end

end