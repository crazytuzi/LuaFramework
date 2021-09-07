WelfareBagsTohelpPanel = WelfareBagsTohelpPanel or BaseClass(BasePanel)

function WelfareBagsTohelpPanel:__init(model)
    self.mgr = CampaignManager.Instance
    self.model = model

    self.isguild = false
    self.helpdata = {}
    self.helpinfo = {}

    self.resList = {
        {file = AssetConfig.shiptohelpwin, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
    }
    self.name = "WelfareBagsTohelpPanel"

    self.update_item = function()
        self:UpdatePanel()
    end
    self.data = nil
    self.OnOpenEvent:AddListener(function()
        self.data = self.openArgs
        self:UpdatePanel()
    end)

    self.itemData = ItemData.New()

    self.OnHideEvent:AddListener(function()
        self:DeleteMe()
    end)
    self.iconloader = {}
end

function WelfareBagsTohelpPanel:OnInitCompleted()
    self.data = self.openArgs
    self:UpdatePanel()
end

function WelfareBagsTohelpPanel:__delete()
    -- body
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.update_item)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self:AssetClearAll()
    self.model.tohelp_bags_panel = nil
    self.model = nil
end
-- args {needid =1, rid = 1, platform = "dev", zone_id = zoenid, type = "求助类型"}
function WelfareBagsTohelpPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shiptohelpwin))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local trans = self.transform
    self.closebtn = trans:Find("Main/CloseButton")
    self.transform = trans

    trans:Find("Main/Title"):GetComponent(Text).text = TI18N("劳动最光荣")
    self.box = trans:Find("Main/ItemCon/box")
    self.nametext = trans:Find("Main/ItemCon/descText"):GetComponent(Text)
    self.helpbtn = trans:Find("Main/ItemCon/helpbtn")
    self.rewardnum = trans:Find("Main/ItemCon/rewcon/rewardText"):GetComponent(Text)
    trans:Find("Main/ItemCon/rewcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90010")
    self.rewconObj = trans:Find("Main/ItemCon/rewcon").gameObject
    self.rewconTitle = trans:Find("Main/ItemCon/rewcon/Text")
    self.rewconTxt = trans:Find("Main/ItemCon/rewcon/rewardText")
    self.rewconIcon = trans:Find("Main/ItemCon/rewcon/Image")
    self.rewconTxt .gameObject:SetActive(false)
    self.rewconIcon.gameObject:SetActive(false)
    self.rewconTitle:GetComponent(RectTransform).sizeDelta = Vector2(230, 24)
    self.rewconTitle.transform.localPosition = Vector2(-5,-2)
    self.rewconTitle:GetComponent(Text).text = TI18N("填充部分福袋有几率获得奖励")
    -- self.rewconObj:SetActive(false)

    self.helpbtn:GetComponent(Button).onClick:AddListener(function () self:GiveHelp()  end)
    self.closebtn:GetComponent(Button).onClick:AddListener(function () self:Hiden()  end)
    -- utils.add_down_up_scale(self.helpbtn.gameObject)
    -- utils.add_down_up_scale(self.closebtn)
    -- utils.duang_scale(self.box.gameObject, Vector3(1.3, 1.3, 1.3))
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.update_item)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.box:Find("itemImage").gameObject,self.slot.gameObject)
    -- self:LoadData()

    self:DoClickPanel()
end

function WelfareBagsTohelpPanel:DoClickPanel()
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

function WelfareBagsTohelpPanel:UpdatePanel()
    -- BaseUtils.dump(self.data,"WelfareBagsTohelpPanel:UpdatePanel()")
    -- if self.data.extraData.helpId == 4 then  -- 公会求助
        -- self.isguild = true
        local itemIdTemp = 0
        local itemCntTemp = 0
        local rewardCntTemp = 0
        for i,v in ipairs(self.data.extraData.digit_array) do
            if v.digit_key == 2 then
                itemIdTemp = v.digit_val
            elseif v.digit_key == 3 then
                itemCntTemp = v.digit_val
            elseif v.digit_key == 4 then
                rewardCntTemp = v.digit_val
            end
        end
        local hasCnt = BackpackManager.Instance:GetItemCount(itemIdTemp)
        if hasCnt >= itemCntTemp then
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#00ff44'>%s</color>/%s", tostring(hasCnt), tostring(itemCntTemp))
        else
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#ff4400'>%s</color>/%s", tostring(hasCnt), tostring(itemCntTemp))
        end
        -- if self.helpdata.shipping_cell[1].type == 2 then
        --     self.box:Find("boximg/nr1").gameObject:SetActive(false)
        --     self.box:Find("boximg/sr1").gameObject:SetActive(true)
        -- end
        local iconid = DataItem.data_get[itemIdTemp].icon
        local id = self.box:Find("itemImage").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(self.box:Find("itemImage").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, iconid)
        -- if self.helpdata.shipping_cell[1].rewards[1] ~= nil then
        --     self.rewardnum.text = tostring(self.helpdata.shipping_cell[1].rewards[1].val)
        -- else
        --     self.rewardnum.text = "啊～我坏掉了"
        -- end
        self.rewardnum.text = tostring(rewardCntTemp)
        self.nametext.text = string.format(TI18N("<color='#00ff22'>%s</color>需要你的帮助："), tostring(self.data.msgData.elements[1].content))

        self.itemData:SetBase(DataItem.data_get[itemIdTemp])
        self.slot:SetAll(self.itemData, {inbag = false, nobutton = true})
        -- self.model:CreatSlot(self.helpdata.shipping_cell[1].item_base_id, self.box:Find("itemImage"))

    -- else
    --     self.isguild = false
    --     self.helpinfo = self.mgr.friendhelp_info
    --     local targetuid = BaseUtils.Key( self.helpdata.shipping_cell[1].role_id, self.helpdata.shipping_cell[1].platform, self.helpdata.shipping_cell[1].zone_id)
    --     print(targetuid)
    --     BaseUtils.dump(self.helpdata)
    --     local frienddata = self.mgr.guildhelp_info
    --     self.helpinfo = self.mgr.guildhelp_info
    --     local has = BackpackManager.Instance:GetItemCount(self.helpdata.shipping_cell[1].item_base_id)
    --     if has >= self.helpdata.shipping_cell[1].need_num then
    --         self.box:Find("num"):GetComponent(Text).text = string.format("<color='#00ff44'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
    --     else
    --         self.box:Find("num"):GetComponent(Text).text = string.format("<color='#ff4400'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
    --     end
    --     if self.helpdata.shipping_cell[1].type == 2 then
    --         self.box:Find("boximg/nr1").gameObject:SetActive(false)
    --         self.box:Find("boximg/sr1").gameObject:SetActive(true)
    --     end

    --     local iconid = DataItem.data_get[self.helpdata.shipping_cell[1].item_base_id].icon
    --     -- utils.SetSprite("textures/itemicon.unity3d", iconid, self.box:Find("itemImage"):GetComponent(Image))
    --     self.rewardnum.text = tostring(self.helpdata.shipping_cell[1].rewards[1].val)
    --     self.nametext.text = string.format("<color='#00ff22'>%s</color>需要你的帮助：", tostring(frienddata.name))

    --     -- local slotData=  DataItem.data_get[self.helpdata.shipping_cell[1].item_base_id]
    --     -- local is_eq = mod_item.is_equip(slotData.type)
    --     -- local info = {trans = self.box.gameObject.transform, data = nil, is_equip = is_eq, num_need = 0, show_num = true, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = true, drop_only = false}
    --     -- info.data = {}
    --     -- info.data.base = slotData
    --     self.model:CreatSlot(self.helpdata.shipping_cell[1].item_base_id, self.box:Find("itemImage"))

    --     -- event_manager:GetUIEvent(self.box.gameObject).OnClick:RemoveAllListeners()
    --     -- event_manager:GetUIEvent(self.box.gameObject).OnClick:AddListener(function () mod_tips.item_tips(info)  end)
    -- end
end

function WelfareBagsTohelpPanel:GiveHelp()
    SosManager.Instance:Send16003(self.data.extraData.id)
    self:Hiden()
end
