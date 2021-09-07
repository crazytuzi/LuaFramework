FriendHelpPanel = FriendHelpPanel or BaseClass(BasePanel)

function FriendHelpPanel:__init()
    self.mgr = CampaignManager.Instance
    self.model = CampaignManager.Instance.labourModel
    -- self.model.help_panel = self
    self.selectitemgoid = nil
    self.helper = nil
    self.resList = {
        {file = AssetConfig.shiphelpwin, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
    }
    self.name = "FriendHelpPanel"
    self.iconloader = {}
    self.OnHideEvent:AddListener(function()
        self:DeleteMe()
    end)
end

function FriendHelpPanel:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    -- self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self:AssetClearAll()
    self.model.help_bags_panel = nil
    self.model = nil
end

function FriendHelpPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shiphelpwin))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local trans = self.transform
    self.needitem = trans:Find("Main/ItemCon/Mask/needItem")
    self.needitmCon = trans:Find("Main/ItemCon/Mask/Con")
    self.noText = trans:Find("Main/ItemCon/Mask/noText"):GetComponent(Text)
    self.noText.text = TI18N("没有福袋需要求助 ")
    self.frienditem = trans:Find("Main/FriendCon/Mask/friendItem")
    self.friendcon = trans:Find("Main/FriendCon/Mask/Con")
    self.noFriendText = trans:Find("Main/FriendCon/Mask/noFriendText")
    self:LoadList()
    self.transform:Find("Main/FriendCon/Sendbtn"):GetComponent(Button).onClick:AddListener(function () self:SendHelp() end)
    trans:Find("Main/ItemCon/Text"):GetComponent(Text).text = ""

    self:DoClickPanel()
end

function FriendHelpPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function FriendHelpPanel:LoadList()
    local data = {}
    for i,v in ipairs(self.mgr.campaign_bags.collected) do
        local dataTpl = DataCampaignBags.data_getBags[v.id]

        if v.num < dataTpl.need then
            --未填满的福袋
            table.insert(data,v)
        end
    end
    for i=1,self.needitmCon.childCount do
        local go = self.needitmCon:GetChild(0).gameObject
        GameObject.DestroyImmediate(go)
    end
    local neednum = 0
    local item_scrollrect = self.needitmCon.parent:GetComponent(ScrollRect)
    for i=1,#data do
        neednum = neednum + 1
        local item = GameObject.Instantiate(self.needitem.gameObject)
        item.transform:SetParent(self.needitmCon)
        item.transform.localScale = Vector3.one
        item:SetActive(true)
        local img = item.transform:Find("Slot"):GetComponent(Image)
        local id = img.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(img.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[data[i].id].icon)
        item.transform:Find("name"):GetComponent(Text).text = DataItem.data_get[data[i].id].name
        item.transform:Find("exptext"):GetComponent(Text).text = tostring(CampaignManager.Instance.campaign_bags.bagRewardsKeyValue[data[i].id].rewards[1].base_num) --经验值
        local expIcon = item.transform:Find("textbg/Image"):GetComponent(Image)
        expIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90010")
        local sizeData = expIcon.transform.sizeDelta
        sizeData.x = 27
        sizeData.y = 27
        expIcon.transform.sizeDelta = sizeData
        item.transform:Find("Text"):GetComponent(Text).text = string.format("%s/%s", tostring(BackpackManager.Instance:GetItemCount(data[i].id)), tostring(DataCampaignBags.data_getBags[data[i].id].need))
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
        if i == 1 then
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

function FriendHelpPanel:SelectFriend(_go, _data)
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

function FriendHelpPanel:SendHelp()
    if self.selectitemgoid == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要求助的福袋"))
        return
    end
    local boxid = self.selectitemgoid.data.id
    local _table = {}
    for k,v in pairs(self.helper) do
        -- local _f = {role_id = v.data.id, platform = v.data.platform , zone_id = v.data.zone_id}
        -- table.insert(_table, _f)
        self.mgr:Send14012(v.data.id,v.data.platform,v.data.zone_id,boxid)
    end
    -- self.mgr:Req13707(_table, boxid)
    self:Hiden()
end
