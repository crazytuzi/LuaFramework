ShipHelpWindow = ShipHelpWindow or BaseClass(BaseWindow)

function ShipHelpWindow:__init()
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model
    self.model.help_panel = self
    self.selectitemgoid = nil
    self.helper = nil
    self.resList = {
        {file = AssetConfig.shiphelpwin, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
    }
    self.name = "ShipFriendHelpWindow"
    self.iconloader = {}
end

function ShipHelpWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
end

function ShipHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shiphelpwin))
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
    self:LoadList()
    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Button).onClick:AddListener(function () self:SendHelp() end)
end

function ShipHelpWindow:LoadList()
    local data = self.mgr.shippingmaindata[1].shipping_cell
    local neednum = 0
    for i=1,self.needitmCon.childCount do
        local go = self.needitmCon:GetChild(0).gameObject
        GameObject.DestroyImmediate(go)
    end
    local item_scrollrect = self.needitmCon.parent:GetComponent(ScrollRect)
    for i=1,#data do
        if data[i].status ~= 2 and data[i].item_base_id ~= 29180 and data[i].item_base_id ~= 29181 and data[i].item_base_id ~= 29182 then
            neednum = neednum + 1
            local item = GameObject.Instantiate(self.needitem.gameObject)
            item.transform:SetParent(self.needitmCon)
            item.transform.localScale = Vector3.one
            item:SetActive(true)
            -- local img = item.transform:Find("Slot/icon"):GetComponent(Image)
            local img = item.transform:Find("Slot"):GetComponent(Image)
            -- self.mgr:SetItemIcon(data[i].item_base_id, img)
            local id = img.gameObject:GetInstanceID()
            if self.iconloader[id] == nil then
                self.iconloader[id] = SingleIconLoader.New(img.gameObject)
            end
            self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[data[i].item_base_id].icon)
            item.transform:Find("name"):GetComponent(Text).text = DataItem.data_get[data[i].item_base_id].name
            item.transform:Find("exptext"):GetComponent(Text).text = tostring(data[i].rewards[1].val)
            item.transform:Find("Text"):GetComponent(Text).text = string.format("%s/%s", tostring(BackpackManager.Instance:GetItemCount(data[i].item_base_id)), tostring(data[i].need_num))
            item.transform:GetComponent(Button).onClick:AddListener(function ()
                if self.selectitemgoid then
                    self.selectitemgoid.go.transform:Find("select").gameObject:SetActive(false)
                    item.transform:Find("select").gameObject:SetActive(true)
                    self.selectitemgoid = {go = item, data = data[i]}
                else
                    item.transform:Find("select").gameObject:SetActive(true)
                    self.selectitemgoid = {go = item, data = data[i]}
                end
                if self.helper ~= nil and #self.helper > 0 and self.selectitemgoid ~= nil and self.selectitemgoid.data.id ~= nil then
                    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                else
                    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                end
                  end)
        end
    end
    if neednum == 0 then
        self.noText.gameObject:SetActive(true)
    end
    self.helper = {}
    for i=1,self.friendcon.childCount do
        local go = self.friendcon:GetChild(0).gameObject
        GameObject.DestroyImmediate(go)
    end
    local friend_scrollRect = self.friendcon.parent:GetComponent(ScrollRect)
    for i,v in ipairs(FriendManager.Instance.online_friend_List) do
        local frienditem = GameObject.Instantiate(self.frienditem.gameObject)
        frienditem.transform:SetParent(self.friendcon)
        frienditem.transform.localScale = Vector3.one
        frienditem:SetActive(true)
        local key = BaseUtils.Key(v.classes,v.sex)
        frienditem.transform:Find("Slot/icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, key)
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
        -- frienditem.OnDownCall:AddListener(function (data) friend_scrollRect:OnInitializePotentialDrag(data) friend_scrollRect:OnBeginDrag(data)    end)
        -- frienditem.OnDragCall:AddListener(function (data) friend_scrollRect:OnDrag(data)    end)
        -- frienditem.OnDragEndCall:AddListener(function (data) friend_scrollRect:OnEndDrag(data)    end)
    end
    if #FriendManager.Instance.online_friend_List < 1 then
        self.noFriendText.gameObject:SetActive(true)
    end
end

function ShipHelpWindow:SelectFriend(_go, _data)
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

function ShipHelpWindow:SendHelp()
    if self.selectitemgoid == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要求助的道具"))
        return
    end
    local _table = {}
    for k,v in pairs(self.helper) do
        local _f = {role_id = v.data.id, platform = v.data.platform , zone_id = v.data.zone_id}
        table.insert(_table, _f)
    end
    local boxid = self.selectitemgoid.data.id
    self.mgr:Req13707(_table, boxid)
end