ShipToHelpWindow = ShipToHelpWindow or BaseClass(BasePanel)

function ShipToHelpWindow:__init()
print("ShippingWindow "..debug.traceback())
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model

    self.isguild = false
    self.helpdata = {}
    self.helpinfo = {}

    self.resList = {
        {file = AssetConfig.shiptohelpwin, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
    }
    self.name = "ShippingWindow"

    self.update_item = function()
        self:LoadData()
    end
    self.iconloader = {}
    self.slotlist = {}

    self.OnOpenEvent:AddListener(function() self:Open() end)
end

function ShipToHelpWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.update_item)
end
-- args {needid =1, rid = 1, platform = "dev", zone_id = zoenid, type = "求助类型"}
function ShipToHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shiptohelpwin))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local trans = self.transform
    self.closebtn = trans:Find("Main/CloseButton")
    self.transform = trans

    self.box = trans:Find("Main/ItemCon/box")
    self.nametext = trans:Find("Main/ItemCon/descText"):GetComponent(Text)
    self.helpbtn = trans:Find("Main/ItemCon/helpbtn")
    self.rewardnum = trans:Find("Main/ItemCon/rewcon/rewardText"):GetComponent(Text)

    self.helpbtn:GetComponent(Button).onClick:AddListener(function () self:GiveHelp()  end)
    self.closebtn:GetComponent(Button).onClick:AddListener(function () self.model:CloseToHelpWin()  end)
    -- utils.add_down_up_scale(self.helpbtn.gameObject)
    -- utils.add_down_up_scale(self.closebtn)
    -- utils.duang_scale(self.box.gameObject, Vector3(1.3, 1.3, 1.3))
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.update_item)
    self:LoadData()
end

function ShipToHelpWindow:Open()
    self.transform:SetAsLastSibling()
    self:LoadData()
end

function ShipToHelpWindow:LoadData()
    self.helpdata = self.mgr.friendhelp_data
    -- utils.dump(self.helpdata, "^^^^^^^^^^^^^^^^^^^^^")
    if self.helpdata.op_code == 0 then
        print("获取求助数据失败，数据有问题？")
    end
    self.isguild = self.helpdata.isguild
    -- if self.helpdata.shipping_cell[1].help_type == 1 or self.helpdata.shipping_cell[1].help_type == 3 then  -- 公会求助
    if self.mgr.currHelpType == 1 then  -- 公会求助
        self.isguild = true
        local frienddata = self.mgr.guildhelp_info
        self.helpinfo = self.mgr.guildhelp_info
        local has = BackpackManager.Instance:GetItemCount(self.helpdata.shipping_cell[1].item_base_id)
        if has >= self.helpdata.shipping_cell[1].need_num then
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#00ff44'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
        else
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#ff4400'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
        end
        if self.helpdata.shipping_cell[1].type == 2 then
            self.box:Find("boximg/nr1").gameObject:SetActive(false)
            self.box:Find("boximg/sr1").gameObject:SetActive(true)
        end
        local iconid = DataItem.data_get[self.helpdata.shipping_cell[1].item_base_id].icon
        local id = self.box:Find("itemImage").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(self.box:Find("itemImage").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, iconid)
        if self.helpdata.shipping_cell[1].rewards[1] ~= nil then
            self.rewardnum.text = tostring(self.helpdata.shipping_cell[1].rewards[1].val)
        else
            self.rewardnum.text = TI18N("啊～我坏掉了")
        end
        self.nametext.text = string.format(TI18N("<color='#00ff22'>%s</color>需要你的帮助："), tostring(frienddata.name))

        local slot = self.model:CreatSlot(self.helpdata.shipping_cell[1].item_base_id, self.box:Find("itemImage"))
        table.insert(self.slotlist, slot)

    else
        self.isguild = false
        self.helpinfo = self.mgr.friendhelp_info
        local targetuid = BaseUtils.Key( self.helpdata.shipping_cell[1].role_id, self.helpdata.shipping_cell[1].platform, self.helpdata.shipping_cell[1].zone_id)
        print(targetuid)
        BaseUtils.dump(self.helpdata)
        local frienddata = self.mgr.guildhelp_info
        self.helpinfo = self.mgr.guildhelp_info
        local has = BackpackManager.Instance:GetItemCount(self.helpdata.shipping_cell[1].item_base_id)
        if has >= self.helpdata.shipping_cell[1].need_num then
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#00ff44'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
        else
            self.box:Find("num"):GetComponent(Text).text = string.format("<color='#ff4400'>%s</color>/%s", tostring(has), tostring(self.helpdata.shipping_cell[1].need_num))
        end
        if self.helpdata.shipping_cell[1].type == 2 then
            self.box:Find("boximg/nr1").gameObject:SetActive(false)
            self.box:Find("boximg/sr1").gameObject:SetActive(true)
        end

        local iconid = DataItem.data_get[self.helpdata.shipping_cell[1].item_base_id].icon
        local id = self.box:Find("itemImage").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(self.box:Find("itemImage").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, iconid)
        self.rewardnum.text = tostring(self.helpdata.shipping_cell[1].rewards[1].val)
        self.nametext.text = string.format(TI18N("<color='#00ff22'>%s</color>需要你的帮助："), tostring(frienddata.name))

        -- local slotData=  DataItem.data_get[self.helpdata.shipping_cell[1].item_base_id]
        -- local is_eq = mod_item.is_equip(slotData.type)
        -- local info = {trans = self.box.gameObject.transform, data = nil, is_equip = is_eq, num_need = 0, show_num = true, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = true, drop_only = false}
        -- info.data = {}
        -- info.data.base = slotData
        local slot = self.model:CreatSlot(self.helpdata.shipping_cell[1].item_base_id, self.box:Find("itemImage"))
        table.insert(self.slotlist, slot)

        -- event_manager:GetUIEvent(self.box.gameObject).OnClick:RemoveAllListeners()
        -- event_manager:GetUIEvent(self.box.gameObject).OnClick:AddListener(function () mod_tips.item_tips(info)  end)
    end
end

function ShipToHelpWindow:GiveHelp()
    if self.isguild then
        self.mgr:Req13704(1, self.helpinfo.role_id, self.helpinfo.platform, self.helpinfo.zone_id, self.helpinfo.cell_id)
        self.model:CloseToHelpWin()
    else
        self.mgr:Req13704(2, self.helpinfo.role_id, self.helpinfo.platform, self.helpinfo.zone_id, self.helpinfo.cell_id)
        self.model:CloseToHelpWin()
    end
end

