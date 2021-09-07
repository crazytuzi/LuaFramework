 -- 远航商人主面板

ShippingWindow = ShippingWindow or BaseClass(BaseWindow)

function ShippingWindow:__init()
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model
    self.model.mainpanel = self
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.preview_loaded = function (texture, modelDataList)
        self:PreviewLoaded(texture, modelDataList)
    end
    self.openinpool = function (arg)
        self:OpenInPool(arg)
    end
    self.hidwidow = function (args)
        self:Hide_windows(args)
    end
    self.settitle = function (time)
        self:SetTitle(time)
    end
    -- self.backfrommarket = function (args)
    --     self:BackFromMarket(args)
    -- end
    self.loadinfo = function ()
        self:LoadInfo()
    end

    self.closeself = function()
        self.model:CloseMain()
    end

    self.updatecachemode = function()
        self:UpdateCacheMode()
    end

    self.setdestorymode = function () 
        self:SetDestoryMode() 
    end

    -- self.holdTime = 300

    self.talkid = nil
    self.itemtodata = {}
    self.selectdata = nil
    self.time = 36000
    self.SPtime = 3600
    self.selectBox = nil
    self.closeeffectPath = "prefabs/effect/20074.unity3d"
    self.sreeffectPath = "prefabs/effect/20075.unity3d"
    self.goeffectPath = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.shiptextures, type = AssetType.Dep}
        ,{file = "prefabs/effect/20074.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20075.unity3d", type = AssetType.Main}
        ,{file = self.goeffectPath, type = AssetType.Main}
        ,{file = AssetConfig.shippingwin, type = AssetType.Main}
    }
    self.name = "ShippingWindow"
    self.iconloader = {}
    self.slotlist = {}
end

function ShippingWindow:__delete()
    if self.slotlist ~= nil then
        for k,v in pairs(self.slotlist) do
            v:DeleteMe()
        end
        self.slotlist = nil
    end
    if self.helpSlot ~= nil then
        self.helpSlot:DeleteMe()
        self.helpSlot = nil
    end
    if self.iconloader ~= nil then
        for k,v in pairs(self.iconloader) do
            v:DeleteMe()
        end
        self.iconloader = nil
    end
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end
    EventMgr.Instance:RemoveListener(event_name.drop_findnpc, self.closeself)
    EventMgr.Instance:RemoveListener(event_name.tips_cancel_close, self.updatecachemode)
    if self.talktimer ~= nil then
        LuaTimer.Delete(self.talktimer)
        self.talktimer = nil
    end
    self.mgr.shipmainpanel = false
    self.transform = nil
    self:AssetClearAll()
end

function ShippingWindow:InitPanel()
    self.OnOpenEvent:AddListener(function() self:OpenInPool() end)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shippingwin))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    self.closeeffectClone = GameObject.Instantiate(self:GetPrefab(self.closeeffectPath))
    self.closeeffectClone.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.closeeffectClone.transform, "UI")
    self.closeeffectClone.gameObject:SetActive(false)

    self.sreeffectClone = GameObject.Instantiate(self:GetPrefab(self.sreeffectPath))
    self.sreeffectClone.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.sreeffectClone.transform, "UI")
    self.sreeffectClone.gameObject:SetActive(false)

    local trans = self.transform
    self.closebtn = trans:Find("Main/CloseButton")
    self.previewCon = trans:Find("Main/Left")
    -- self.preview = trans:Find("Main/Left/RawImage"):GetComponent(RawImage)
    self.npctalk = trans:Find("Main/Left/SceneTalkBubble/Content")
    self.timetext = trans:Find("Main/Top/TimeText"):GetComponent(Text)
    self.sptimetext = trans:Find("Main/Top/SPTimeText"):GetComponent(Text)
    self.spinfo = trans:Find("Main/Top/SPinfo")
    self.helpcon = trans:Find("Main/Bot/helpcon")
    self.startcon = trans:Find("Main/Bot/startcon")
    -- self.mgr.shipmainpanel = self

    self.goeffectClone = GameObject.Instantiate(self:GetPrefab(self.goeffectPath))
    self.goeffectClone.transform:SetParent(self.startcon:Find("Gobtn"))
    Utils.ChangeLayersRecursively(self.goeffectClone.transform, "UI")
    self.goeffectClone.transform.localScale = Vector3(1.5, 0.6, 1)
    self.goeffectClone.transform.localPosition = Vector3(-45, -16, -400)
    self.goeffectClone.gameObject:SetActive(false)

    if self.mgr.first then
        for i=1,8 do
            local go = self.transform:Find("Main/Mid"):GetChild(i-1).gameObject
            go:SetActive(false)
            -- utils.duang_scale(go, Vector3(1.3, 1.3, 1.3))
        end
        self.mgr.first = false
        self:OnceEffect()
    else
        for i=1,8 do
            local go = self.transform:Find("Main/Mid"):GetChild(i-1).gameObject
            go:SetActive(true)
            -- utils.duang_scale(go, Vector3(1.3, 1.3, 1.3))

        end
    end
    self.mgr:Req13708()
    self.closebtn:GetComponent(Button).onClick:AddListener(function () self.model:CloseMain()  end)
    self.startcon:Find("Gobtn"):GetComponent(Button).onClick:AddListener(function () self.mgr:Req13705()  end)
    self.helpcon:Find("Helpbtn"):GetComponent(Button).onClick:AddListener(function () self:OnclickHelp()  end)
    self.transform:Find("Main/Bot/reqhelp/Panel"):GetComponent(Button).onClick:AddListener(function () self.transform:Find("Main/Bot/reqhelp").gameObject:SetActive(false)  end)
    self.transform:Find("Main/Bot/reqhelp/Friendhelp"):GetComponent(Button).onClick:AddListener(function () self.transform:Find("Main/Bot/reqhelp").gameObject:SetActive(false) self.model:FriendHelp() end)
    -- self.transform:Find("Main/Bot/reqhelp/Friendhelp").gameObject:SetActive(false)
    self:SetTitle()
    self.OnHideEvent:AddListener(function() self:Hide_windows() end)
    EventMgr.Instance:AddListener(event_name.drop_findnpc, self.closeself)
    EventMgr.Instance:AddListener(event_name.tips_cancel_close, self.updatecachemode)
    -- LuaTimer.Add(function ()
    --     self:GoEffect()
    -- end, 5)
    self:LoadInfo()
end

-- 从缓存打开的初始化
function ShippingWindow:OpenInPool(arg)
    
    if BaseUtils.IsIPhonePlayer() then
        self.cacheMode = CacheMode.Destroy
    else
        self.cacheMode = CacheMode.Visible
    end

    if self.mgr.first then
        self.mgr.first = false
        self:OnceEffect()
    end
    -- self:LoadPreview()
    self.selectdata = nil
    self.mgr:Req13708()
    self:UpdataHelpCon()
end

function ShippingWindow:Hide_windows(args)
    -- self.preview.gameObject:SetActive(false)
    -- ModelPreview.Instance:Release()
    -- ModelPreview.Instance:SetSize(512 , 512)
end

-- 协议信息返回更新信息
function ShippingWindow:LoadInfo()
    self:LoadPreview()
    if self.transform == nil then
        return
    end
    if self.mgr.shippingmaindata[1].shipping_type == 1 then
        self.sptimetext.gameObject:SetActive(false)
        self.transform:Find("Main/Top/SPinfo").gameObject:SetActive(false)
    elseif self.mgr.shippingmaindata[1].shipping_type == 2 then
        -- event_manager:GetUIEvent(self.transform:Find("Main/Top/SPinfo").gameObject).OnClick:RemoveAllListeners()
        self.transform:Find("Main/Top/SPinfo"):GetComponent(Button).onClick:AddListener(function () TipsManager.Instance:ShowText({gameObject = self.transform:Find("Main/Top/SPinfo").gameObject, itemData = {TI18N("1小时内起航，可以获得额外奖励。")}})  end)

    elseif self.mgr.shippingmaindata[1].shipping_type == 3 then
        -- event_manager:GetUIEvent(self.transform:Find("Main/Top/SPinfo").gameObject).OnClick:RemoveAllListeners()
        self.transform:Find("Main/Top/SPinfo"):GetComponent(Button).onClick:AddListener(function () TipsManager.Instance:ShowText({gameObject = self.transform:Find("Main/Top/SPinfo").gameObject, itemData = {TI18N("双倍的货物需求，双倍的奖励！")}}) end)
    end
    self.time = math.ceil(36000 - (BaseUtils.BASE_TIME - self.mgr.shippingmaindata[1].start_time))
    self.SPtime = math.ceil(3600 - (BaseUtils.BASE_TIME - self.mgr.shippingmaindata[1].start_time))
    -- self.helpcon:Find("Helpbtn/HelpTimes"):GetComponent(Text).text = string.format("%s/2", tostring(self.mgr.shippingmaindata[1].help_num))
    local data = self.mgr.shippingmaindata[1]
    self.itemtodata = {}
    for i,v in ipairs(data.shipping_cell) do
        self:SetBox(i,v)
    end
    -- if self.selectdata == nil then
    --     self:SetHelpCon(nil)
    -- end
    self:UpdataHelpCon()
    self:SetGoReward(20025)
end

-- 更新箱子
function ShippingWindow:SetBox(_index, _data)
    local index = 0
    if _index ~= nil then
        index = _index
    end
    local data = _data
    local Updata_mark = false
    if _index == nil then
        Updata_mark = true
        for i,v in ipairs(self.itemtodata) do
            if v.data.id == data.id then
                index = v.index
            end
        end
    end

    local boxParent = self.transform:Find("Main/Mid")
    if index < 1 or index > boxParent.childCount then
        Log.info("找不到远航箱子，跳过")
        return
    end
    local box = boxParent:GetChild(index-1)
    if data.type == 2 then  --金箱子
        if box:Find("boximg/sreffect") == nil then
            local effect = GameObject.Instantiate(self.sreeffectClone)
            effect.transform:SetParent(box:Find("boximg"))
            effect.transform.localPosition = Vector3(0, 37.2, -50)
            effect.transform.localScale = Vector3.one
            effect.name = "sreffect"
        end
        box:Find("boximg/sreffect").gameObject:SetActive(true)
        box:Find("boximg/sr1").gameObject:SetActive(true)
        box:Find("boximg/nr1").gameObject:SetActive(false)
        if data.status == 2 then
            local gaizi = box:Find("boximg/sr2").gameObject
            local starvec = Vector2(0, 140)
            local endvec = Vector2(0, 33.82)
            box:Find("boximg/sr2").anchoredPosition = starvec
            if box:Find("boximg/closeeffect") == nil then
                local effect = GameObject.Instantiate(self.closeeffectClone)
                effect.transform:SetParent(box:Find("boximg"))
                effect.transform.localPosition = Vector3(0, 37.2, -50)
                effect.transform.localScale = Vector3.one
                effect.name = "closeeffect"
            end
            box:Find("boximg/closeeffect").gameObject:SetActive(false)
            box:Find("boximg/closeeffect").gameObject:SetActive(true)
            -- tween:DoPosition(box:Find("boximg/sr2").gameObject, starvec, endvec, 0.5, "", "easeoutbounce", 1)
            Tween.Instance:MoveLocalY(box:Find("boximg/sr2").gameObject, endvec.y, 0.5, function()end, LeanTweenType.easeoutbounce)
            -- LuaTimer.Add(function ()
            -- end,0.1)
            gaizi:SetActive(true)
            box:Find("commiticon").gameObject:SetActive(false)
            box:Find("finishicon").gameObject:SetActive(true)
            box:Find("inhelp").gameObject:SetActive(false)
        else
            box:Find("inhelp").gameObject:SetActive(data.help_type ~= 0)
        end
    elseif data.type == 1 then  --普通箱子
        if box:Find("boximg/sreffect") ~= nil then
            box:Find("boximg/sreffect").gameObject:SetActive(false)
        end
        box:Find("boximg/sr1").gameObject:SetActive(false)
        box:Find("boximg/nr1").gameObject:SetActive(true)
        if data.status == 2 then
            local gaizi = box:Find("boximg/nr2").gameObject
            local starvec = Vector2(0, 140)
            local endvec = Vector2(0, 28)
            box:Find("boximg/nr2").anchoredPosition = starvec
            if box:Find("boximg/closeeffect") == nil then
                local effect = GameObject.Instantiate(self.closeeffectClone)
                effect.transform:SetParent(box:Find("boximg"))
                effect.transform.localPosition = Vector3(0, 37.2, -50)
                effect.transform.localScale = Vector3.one
                effect.name = "closeeffect"
            end
            box:Find("boximg/closeeffect").gameObject:SetActive(false)
            box:Find("boximg/closeeffect").gameObject:SetActive(true)
            -- tween:DoPosition(box:Find("boximg/nr2").gameObject, starvec, endvec, 0.5, "", "easeoutbounce", 1)
            Tween.Instance:MoveLocalY(box:Find("boximg/nr2").gameObject, endvec.y, 0.5, function()end, LeanTweenType.easeoutbounce)
            -- LuaTimer.Add(function ()
            -- end,0.1)
            gaizi:SetActive(true)
            box:Find("commiticon").gameObject:SetActive(false)
            box:Find("finishicon").gameObject:SetActive(true)
            box:Find("inhelp").gameObject:SetActive(false)
        else
            box:Find("inhelp").gameObject:SetActive(data.help_type ~= 0)
        end
    elseif data.type == 3 or data.type == 4 or data.type == 5 then  --任务箱子
        box:Find("boximg").gameObject:SetActive(false)
        box:Find("itemImage").gameObject:SetActive(false)
        box:Find("questbg").gameObject:SetActive(true)
        box:Find("questimg").gameObject:SetActive(true)
        box:Find("questimg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.shiptextures, data.type-2)
        if data.status == 2 then
            box:Find("commiticon").gameObject:SetActive(false)
            box:Find("finishicon").gameObject:SetActive(true)
        elseif data.status == 4 then
            box:Find("finishicon").gameObject:SetActive(false)
            box:Find("commiticon").gameObject:SetActive(true)
        else
            box:Find("finishicon").gameObject:SetActive(false)
            box:Find("commiticon").gameObject:SetActive(false)
        end
        if data.type ~= 3 then
            box:Find("Image").gameObject:SetActive(false)
            box:Find("num").gameObject:SetActive(false)
        end
    end
    box:Find("num"):GetComponent(Text).text = tostring(_data.need_num>0 and _data.need_num or "?" )
    local img = box:Find("itemImage"):GetComponent(Image)
    local has = 0
    if (data.type ~= 3 and data.type ~= 4 and data.type ~= 5) or (data.type == 3 and DataItem.data_get[data.item_base_id] ~= nil) then
        if DataItem.data_get[data.item_base_id] == nil then
            Log.Error(string.format("<color='#ff0000'>%s</color>改ID物品找不到！", tostring(data.item_base_id)))
        end
        local iconid = DataItem.data_get[data.item_base_id].icon
        self:SetItemIcon(iconid, img)
        has = BackpackManager.Instance:GetItemCount(data.item_base_id)
        if data.type ~= 3 and data.need_num <= has and data.status ~= 2 or data.status == 4 then
            box:Find("commiticon").gameObject:SetActive(true)
        else
            box:Find("commiticon").gameObject:SetActive(false)
        end
    end
    if Updata_mark then
        self.itemtodata[index].index = index
        self.itemtodata[index].data = data
        self.itemtodata[index].boxgo = box
    else
        table.insert( self.itemtodata, {index = index, data = data, boxgo = box} )
    end
    box:GetComponent(Button).onClick:RemoveAllListeners()

    if data.status ~= 2 then
        -- utils.add_down_up_scale(box.gameObject, nil, nil, Vector3(0.9, 0.9, 0.9))
        box:GetComponent(Button).onClick:AddListener(function ()
            if data.type ~= 3 and data.type ~= 4 and data.type ~= 5 and data.need_num <= has and data.status == 1 then
                local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog3
                local index = math.ceil(Random.Range(1, #list))
                self:NpcTalk(list[index].key)
                self:SetTitle()
            elseif data.type == 2 then
                local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog2
                local index = math.ceil(Random.Range(1, #list))
                self:NpcTalk(list[index].key)
                self.sptimetext.gameObject:SetActive(true)
                local itemname = ColorHelper.color_item_name(DataItem.data_get[data.item_base_id].quality, DataItem.data_get[data.item_base_id].name)
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("提交<color='#ffff00'>金箱子</color>[%s]，可获得{assets_1, 90013,%s}（其中额外奖励{assets_1, 90013,%s}）"), itemname, tostring(data.rewards[1].val), tostring(math.floor(data.rewards[1].val/2))))
                self:SetTitle()
            elseif data.type == 1 then
                self:SetTitle()
            elseif (data.type == 3  or data.type == 4 or data.type == 5) and data.status ~= 4 then
                self.model:OpenQuestPanel(data)
            end
            if (data.type ~= 3 or (data.type == 3 and DataItem.data_get[data.item_base_id] ~= nil))  then
                if self.selectBox == nil then
                    if data.type > 2 then
                        box:Find("questSelect").gameObject:SetActive(true)
                        self.selectBox = box:Find("questSelect")
                    else
                        box:Find("Select").gameObject:SetActive(true)
                        self.selectBox = box:Find("Select")
                    end
                else
                    self.selectBox.gameObject:SetActive(false)
                    if data.type > 2 then
                        box:Find("questSelect").gameObject:SetActive(true)
                        self.selectBox = box:Find("questSelect")
                    else
                        box:Find("Select").gameObject:SetActive(true)
                        self.selectBox = box:Find("Select")
                    end
                end
                self:SetHelpCon(data)
            end
            end)
    end
end

-- 更新帮助框
function ShippingWindow:SetHelpCon(data, item)
    self.selectBoxData = data
    if item ~= nil then
        if self.selectBox == nil then
            if data.type > 2 then
                item:Find("questSelect").gameObject:SetActive(true)
                self.selectBox = item:Find("questSelect")
            else
                item:Find("Select").gameObject:SetActive(true)
                self.selectBox = item:Find("Select")
            end
        else
            self.selectBox.gameObject:SetActive(false)
            if data.type > 2 then
                item:Find("questSelect").gameObject:SetActive(true)
                self.selectBox = item:Find("questSelect")
            else
                item:Find("Select").gameObject:SetActive(true)
                self.selectBox = item:Find("Select")
            end
        end
    end
    if data ~= nil then
        if data.status == 2 then return end
        -- local imgicon = self.helpcon:Find("slot/itemimg"):GetComponent(Image)
        local itemnum = self.helpcon:Find("itemnum"):GetComponent(Text)
        local rewardnum = self.helpcon:Find("rewcon/Text"):GetComponent(Text)
        -- local helpnum = self.helpcon:Find("Helpbtn/HelpTimes"):GetComponent(Text)
        -- local iconid = DataItem.data_get[data.item_base_id].icon
        -- self:SetItemIcon(iconid, imgicon)
        -- if self.helpcon:Find("slot/ItemSlot") ~= nil then
        --     GameObject.DestroyImmediate(self.helpcon:Find("slot/ItemSlot").gameObject)
        -- end
        self.helpSlot = self.helpSlot or self.model:CreatSlot(data.item_base_id, self.helpcon:Find("slot"))
        self.helpSlot:SetAll(DataItem.data_get[data.item_base_id], {inbag = false})
        -- table.insert(self.slotlist, self.helpSlot)

        local has = BackpackManager.Instance:GetItemCount(data.item_base_id)
        if has>= data.need_num and data.need_num ~= 0 then
            itemnum.text = string.format("<color='#00ee33'>%s</color>/%s", tostring(has), tostring(data.need_num))
        elseif data.type ~= 3 and data.type ~= 4 and data.type ~= 5 then
            itemnum.text = string.format("<color='#ee3900'>%s</color>/%s", tostring(has), tostring(data.need_num))
        elseif (data.type == 3 or data.type ~= 4 or data.type ~= 5 )and data.need_num ~= 0 then
            itemnum.text = string.format("<color='#00ee33'>%s</color>", tostring(data.need_num))
        else
            itemnum.text = "??"
        end
        if data.rewards[1] == nil and data.type ~= 3 and  data.type == 4 and data.type == 5 then
            self.helpcon:Find("rewcon/Text"):GetComponent(Text).text = "?????"
        elseif data.rewards[1] == nil and (data.type == 3 or data.type == 4 or data.type == 5) then
            self.helpcon:Find("rewcon/Text"):GetComponent(Text).text = "?????"
        else
            self.helpcon:Find("rewcon/Text"):GetComponent(Text).text = tostring(data.rewards[1].val)
        end
        self.helpcon:Find("Loadbtn"):GetComponent(Button).onClick:RemoveAllListeners()
        self.helpcon:Find("Loadbtn"):GetComponent(Button).onClick:AddListener(function ()
            if (data.type ~= 3 and data.type ~= 4 and data.type ~= 5 and has>= data.need_num) or (data.status == 4) then
                self.model:SelfCommit(data.id)
            elseif data.type ~= 3 and data.type ~= 4 and data.type ~= 5 then
                -- NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))
                local cell = DataItem.data_get[data.item_base_id]

                local itemdata = ItemData.New()
                itemdata:SetBase(cell)
                if BackpackManager.Instance:IsEquip(cell.type) then
                    TipsManager.Instance:ShowEquip({["gameObject"] = self.helpcon:Find("Loadbtn").gameObject, ["itemData"] = itemdata})
                else
                    self:SetDestoryMode()
                    TipsManager.Instance:ShowItem({["gameObject"] = self.helpcon:Find("Loadbtn").gameObject, ["itemData"] = itemdata})
                end
            else
                self.model:OpenQuestPanel(data)
            end
        end)
 --self:SetDestoryMode() 
        self.transform:Find("Main/Bot/reqhelp/Guildhelp"):GetComponent(Button).onClick:RemoveAllListeners()
        self.transform:Find("Main/Bot/reqhelp/Guildhelp"):GetComponent(Button).onClick:AddListener(function ()  self.model:GuildHelp(data.id) self.transform:Find("Main/Bot/reqhelp").gameObject:SetActive(false) end)
        self.helpcon:Find("slot"):GetComponent(Button).onClick:RemoveAllListeners()
        self.helpcon:Find("slot"):GetComponent(Button).onClick:AddListener(function () self.helpSlot:ClickSelf() end)
        self.helpcon:Find("slot/ItemSlot"):GetComponent(Button).onClick:RemoveListener(self.setdestorymode)
        self.helpcon:Find("slot/ItemSlot"):GetComponent(Button).onClick:AddListener(self.setdestorymode)
        
        self.helpcon:Find("AllText").gameObject:SetActive(false)
        self.helpcon:Find("slot").gameObject:SetActive(true)
        self.helpcon:Find("Text").gameObject:SetActive(true)
        self.helpcon:Find("rewcon").gameObject:SetActive(true)
        self.helpcon:Find("Helpbtn").gameObject:SetActive(true)
        self.helpcon:Find("Loadbtn").gameObject:SetActive(true)
        self.helpcon:Find("numbg").gameObject:SetActive(true)
        self.helpcon:Find("itemnum").gameObject:SetActive(true)
    else
        self.helpcon:Find("slot").gameObject:SetActive(false)
        self.helpcon:Find("Text").gameObject:SetActive(false)
        self.helpcon:Find("rewcon").gameObject:SetActive(false)
        self.helpcon:Find("Helpbtn").gameObject:SetActive(false)
        self.helpcon:Find("Loadbtn").gameObject:SetActive(false)
        self.helpcon:Find("numbg").gameObject:SetActive(false)
        self.helpcon:Find("itemnum").gameObject:SetActive(false)
        self.helpcon:Find("AllText").gameObject:SetActive(true)
        local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog4
        local index = math.ceil(Random.Range(1, #list))
        self:NpcTalk(list[index].key)
        self.startcon:Find("Gobtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        if self.goeffectClone ~= nil then
            self.goeffectClone.gameObject:SetActive(true)
        end
    end
    local unfinished = 0
    if self.mgr.shippingmaindata ~= nil then
        for i=1,#self.mgr.shippingmaindata[1].shipping_cell do
            if self.mgr.shippingmaindata[1].shipping_cell[i].status == 2 then
                unfinished = unfinished + 1
            end
        end
        if data ~= nil then
            self.helpcon:Find("Helpbtn/NoImg").gameObject:SetActive(unfinished<5 or data.type == 3)
        end
    end
end


function ShippingWindow:LoadPreview()
    local baseid = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type]
    local unit_data = DataUnit.data_unit[70008]
    if baseid ~= nil then
        unit_data = DataUnit.data_unit[baseid.id]
    end
    if unit_data == nil then
        print("单位ID错误？？ShippingWindow:LoadPreview()中断")
        return
    end
    local setting = {
        name = "Shipping"
        ,orthographicSize = 0.4
        ,width = 336
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(self.preview_loaded, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, self.preview_loaded)
    end

end

function ShippingWindow:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.previewCon)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        -- self.preview.texture = rawImage.texture
    end
    if self.transform == nil then
        return
    end
    self.transform:Find("Main/Left/SceneTalkBubble").gameObject:SetActive(false)
    self.transform:Find("Main/Left").gameObject:SetActive(true)
    -- self.preview.gameObject:SetActive(true)
    local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog1
    local index = math.ceil(Random.Range(1, #list))
    if list[index] == nil then
        print("没有说话数据")
    else
        self:NpcTalk(list[index].key, 8)
    end
    self.previewCon:GetComponent(Button).onClick:RemoveAllListeners()
    self.previewCon:GetComponent(Button).onClick:AddListener(function ()
        if self.mgr:IsCanGoShip() then
            local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog4
            local index = math.ceil(Random.Range(1, #list))
            if list[index].key == self.npctalk:GetComponent(Text).text then
                index = (index+1)%#list ~= 0 and (index+1)%#list or #list
            end
            self:NpcTalk(list[index].key)
        else
            local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog1
            local index = math.ceil(Random.Range(1, #list))
            if list[index].key == self.npctalk:GetComponent(Text).text then
                index = (index+1)%#list ~= 0 and (index+1)%#list or #list
            end

            self:NpcTalk(list[index].key)
        end
    end)
end

function ShippingWindow:NpcTalk(talkinfo, time)
    if self.mgr.shippingmaindata == nil or self.mgr.shippingmaindata[1] == nil then
        if self.talktimer ~= nil then
            LuaTimer.Delete(self.talktimer)
        end
        return
    end
    local currtalkid = os.time()
    self.talkid = currtalkid
    self.npctalk:GetComponent(Text).text = TI18N(talkinfo)
    self.transform:Find("Main/Left/SceneTalkBubble").gameObject:SetActive(true)
    if time then
        if self.talktimer ~= nil then
            LuaTimer.Delete(self.talktimer)
        end
        self.talktimer = LuaTimer.Add(0,time*1000, function ()
            if self.transform and not self.mgr:IsCanGoShip() then
                self.transform:Find("Main/Left/SceneTalkBubble").gameObject:SetActive(false)
                if self.mgr.shippingmaindata ~= nil then
                    local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog1
                    local index = math.ceil(Random.Range(1, #list))
                    if list[index].key == self.npctalk:GetComponent(Text).text then
                        index = (index+1)%#list ~= 0 and (index+1)%#list or #list
                    end
                    self:NpcTalk(list[index].key)
                end
            elseif self.transform and self.mgr:IsCanGoShip() then
                self.transform:Find("Main/Left/SceneTalkBubble").gameObject:SetActive(false)
                if self.mgr.shippingmaindata ~= nil then
                    local list = DataShipping.data_npctalk[self.mgr.shippingmaindata[1].shipping_type].dialog4
                    local index = math.ceil(Random.Range(1, #list))
                    if list[index].key == self.npctalk:GetComponent(Text).text then
                        index = (index+1)%#list ~= 0 and (index+1)%#list or #list
                    end
                    self:NpcTalk(list[index].key)
                end
            end
        end)
    -- else
    --     LuaTimer.Add(function ()
    --         if self.transform and currtalkid == self.talkid then
    --             self.transform:Find("Main/Left/SceneTalkBubble").gameObject:SetActive(false)
    --         end
    --     end, 8)
    end
end

-- 初次打开效果
function ShippingWindow:OnceEffect()
    for i=1,8 do
        local go = self.transform:Find("Main/Mid"):GetChild(i-1).gameObject
        if go.transform:Find("boximg/sr1").gameObject.activeSelf == true then
            go:SetActive(false)
            local boximg = go.transform:Find("boximg").gameObject
            local dy = i%4 == 0 and 3 or i%4-1
            local starvec = Vector2(68+dy*140.6,-68-(math.ceil(i/4)-1)*136+120)
            -- print(dy)
            local endvec = Vector2(68+dy*140.6,-68-(math.ceil(i/4)-1)*136)
            local startrota = Vector3(0, 0, 20)
            local endrota = Vector3(0, 0, -1)
            boximg.transform.rotation.eulerAngles = startrota
            LuaTimer.Add(function ()
                -- tween:DoPosition(go, starvec, endvec, 0.3, "", "linear", 1)
                Tween.Instance:MoveLocalY(go.gameObject, endvec.y, 0.1, function()end, LeanTweenType.linear)
                go:SetActive(true)
                -- tween:DoRotation(boximg, startrota, endrota, 0.8, "", "easeoutbounce", 1)
                Tween.Instance:Rotate(self.iconSwitcher:GetComponent(RectTransform), -1, 5, function()end, LeanTweenType.linear)
            end,i*0.15)
        else
            go:SetActive(true)
        end
        -- tween:DoRotation(go, endrota, startrota, 3)
        -- tween:DoRotation(self.light.gameObject, startrota, endrota, 0.2)
    end
end


function ShippingWindow:OnclickHelp()
    local unfinished = 0
    for i=1,#self.mgr.shippingmaindata[1].shipping_cell do
        if self.mgr.shippingmaindata[1].shipping_cell[i].status == 2 and self.mgr.shippingmaindata[1].shipping_cell[i].type ~= 3 then
            unfinished = unfinished + 1
        end
    end
    -- print(self.selectBoxData.type)
    if self.selectBoxData.type == 3 or self.selectBoxData.type == 4 or self.selectBoxData.type == 5 and self.selectBoxData.status ~= 4 then
        self.model:OpenQuestPanel(self.selectBoxData)
        NoticeManager.Instance:FloatTipsByString(TI18N("建议<color='#ffff00'>创建队伍</color>邀请他人协助完成{face_1,9}"))
        return
    elseif self.selectBoxData.status == 4 then
        self.model:SelfCommit(self.selectBoxData.id)
        return
    elseif unfinished<5 then
        -- print("自己提交少于5个不能求")
        NoticeManager.Instance:FloatTipsByString(TI18N("完成5次提交，才能使用求助"))
        return
    end
    self.transform:Find("Main/Bot/reqhelp").gameObject:SetActive(true)
    -- self.model:Help()
end

function ShippingWindow:SetTitle()
    if self.transform == nil or self.mgr.shippingmaindata == nil then
        return
    end
    if self.mgr.shippingmaindata[1].shipping_type == 1 then
        self.sptimetext.gameObject:SetActive(false)
        self.transform:Find("Main/Top/SPinfo").gameObject:SetActive(false)
    else
        self.sptimetext.gameObject:SetActive(true)
        self.transform:Find("Main/Top/SPinfo").gameObject:SetActive(true)
    end
    self.time = self.time-3
    self.SPtime = self.SPtime-3
    local h = math.floor(self.time/3600)>9 and math.floor(self.time/3600) or string.format("0%s", tostring(math.floor(self.time/3600)))
    local m = math.floor(self.time%3600/60)>9 and math.floor(self.time%3600/60) or string.format("0%s", tostring(math.floor(self.time%3600/60)))
    local sh = math.floor(self.SPtime/3600)>9 and math.floor(self.SPtime/3600) or string.format("0%s", tostring(math.floor(self.SPtime/3600)))
    local sm = math.floor(self.SPtime%3600/60)>9 and math.floor(self.SPtime%3600/60) or string.format("0%s", tostring(math.floor(self.SPtime%3600/60)))
    self.transform:Find("Main/Top/TimeText"):GetComponent(Text).text = string.format(TI18N("%s小时%s分钟"), tostring(h), tostring(m))

    if self.sptimetext.gameObject.activeSelf == true and self.mgr.shippingmaindata[1].shipping_type == 2 then
        if self.SPtime >1 then
            self.sptimetext.text = string.format(TI18N("遭遇事件-紧急供应：%s小时%s分钟"), tostring(sh), tostring(sm))
            self.sptimetext.gameObject:SetActive(true)
        else
            -- self.sptimetext:GetComponent(Text).text = "遭遇事件-紧急供应<color='#ff5500'>(已超时)</color>"
            self.mgr:Req13712()
            self.sptimetext.gameObject:SetActive(false)
        end
    elseif self.sptimetext.gameObject.activeSelf == true and self.mgr.shippingmaindata[1].shipping_type == 3 then
        self.sptimetext.text = TI18N("遭遇事件-大号订单")
    end
    -- LuaTimer.Add(self.settitle, 1)
    LuaTimer.Add(3000, function() self.settitle() end)
end


function ShippingWindow:GoEffect()
    if self.talktimer ~= nil then
        LuaTimer.Delete(self.talktimer)
    end
    LuaTimer.Add(500, function () self.model:DestoryMain() end)
    -- LuaTimer.Add(1500, function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shipwindow) end)
end

function ShippingWindow:UpdataHelpCon()
    self.selectdata = nil
    local item
    for i=1,#self.itemtodata do
        if self.selectdata == nil and self.itemtodata[i].data.status ~= 2 then
            self.selectdata = self.itemtodata[i].data
            item = self.itemtodata[i].boxgo
        elseif self.selectdata ~= nil and self.itemtodata[i].data.status ~= 2  then
            local currhas = BackpackManager.Instance:GetItemCount(self.selectdata.item_base_id)
            local has = BackpackManager.Instance:GetItemCount(self.itemtodata[i].data.item_base_id)
            if (currhas < self.selectdata.need_num and has >= self.itemtodata[i].data.need_num and (self.itemtodata[i].data.type ~= 3 and self.itemtodata[i].data.type ~= 4 and self.itemtodata[i].data.type ~= 5)) or self.itemtodata[i].data.status == 4 then
                self.selectdata = self.itemtodata[i].data
                item = self.itemtodata[i].boxgo
            end
        end
    end
    self:SetHelpCon(self.selectdata, item)
    -- local data = self.mgr.shippingmaindata[1]
    -- for i,v in ipairs(data.shipping_cell) do
    --     self:SetBox(i,v)
    -- end
end
function ShippingWindow:SetGoReward(id)
    if self.startcon:Find("slot/ItemSlot") == nil then
        local slot = self.model:CreatSlot(id, self.startcon:Find("slot"), true)
        table.insert(self.slotlist, slot)
    end
    self.startcon:Find("slot/ItemSlot/NumBg").gameObject:SetActive(true)
    self.startcon:Find("slot/ItemSlot/Num").gameObject:SetActive(true)
    if self.mgr.shippingmaindata[1].shipping_type == 1 then
        self.startcon:Find("slot/ItemSlot/Num"):GetComponent(Text).text = "2"
    elseif self.mgr.shippingmaindata[1].shipping_type == 2 then
        self.startcon:Find("slot/ItemSlot/Num"):GetComponent(Text).text = "3"
    elseif self.mgr.shippingmaindata[1].shipping_type == 3 then
        self.startcon:Find("slot/ItemSlot/Num"):GetComponent(Text).text = "2"
    else
        self.startcon:Find("slot/ItemSlot/Num"):GetComponent(Text).text = "2"
    end
        self.startcon:Find("slot/ItemSlot/Num").anchoredPosition = Vector2(-1.5, 3)

end


function ShippingWindow:SetItemIcon(iconid, img)
    local id = img.gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(img.gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, iconid)
end

function ShippingWindow:DeleteTimer()
    if self.talktimer ~= nil then
        LuaTimer.Delete(self.talktimer)
    end
    self.talktimer = nil
end

function ShippingWindow:UpdateCacheMode()
    --print(debug.traceback())
    if BaseUtils.IsIPhonePlayer() then
        self.cacheMode = CacheMode.Destroy
    else
        self.cacheMode = CacheMode.Visible
    end
end

function ShippingWindow:SetDestoryMode()
    self.cacheMode = CacheMode.Visible
end
