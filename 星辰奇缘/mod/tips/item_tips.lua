-- ------------------------------
-- 道具tips
-- hosr
-- ------------------------------
ItemTips = ItemTips or BaseClass(BaseTips)

function ItemTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_item, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.showStep = false
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:OnHide() self:RemoveTime() end)
end

function ItemTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.itemData = nil
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function ItemTips:RemoveTime()
    self.mgr.updateCall = nil
end

function ItemTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_item))
    self.gameObject.name = "ItemTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() EventMgr.Instance:Fire(event_name.tips_cancel_close) self.model:Closetips() end)

    self.labelObj = self.transform:Find("Label").gameObject
    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.otherTxt = head:Find("TimeLimit"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject
    self.specialIcon =  head:Find("SpecialIcon"):GetComponent(Image)

    local mid = self.transform:Find("MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)

    self.chanceButton = mid:Find("Desc/ChanceButton"):GetComponent(Button)
     self.chanceButton.onClick:AddListener(function() TipsManager.Instance.model:OpenChancewindow(self.chanceId) end)
    -- self.chanceButton.onClick:AddListener(function() TipsManager.Instance.model:OpenChancewindow(self.chanceId) end）
    self.descTxt.horizontalOverflow = HorizontalWrapMode.Overflow
    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.text1 = mid:Find("Text1"):GetComponent(Text)
    self.text2 = mid:Find("Text2"):GetComponent(Text)
    self.text3 = mid:Find("Text3"):GetComponent(Text)

    self.msg1 = MsgItemExt.New(self.text1, 250, 18, 21)
    self.msg2 = MsgItemExt.New(self.text2, 250, 18, 21)
    self.msg3 = MsgItemExt.New(self.text3, 250, 18, 21)

    self.trect1 = self.text1.gameObject:GetComponent(RectTransform)
    self.trect2 = self.text2.gameObject:GetComponent(RectTransform)
    self.trect3 = self.text3.gameObject:GetComponent(RectTransform)

    local bottom = self.transform:Find("ButtonList")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)
    local use = bottom:Find("UseButton").gameObject
    local drop = bottom:Find("DropButton").gameObject
    local sell = bottom:Find("SellButton").gameObject
    local cons = bottom:Find("ConsignmentButton").gameObject
    local simth = bottom:Find("SmithButton").gameObject
    local ware = bottom:Find("WareButton").gameObject
    local merge = bottom:Find("MergeButton").gameObject
    local pregem = bottom:Find("PetGemOffButton").gameObject
    local remove = bottom:Find("RemoveButton").gameObject
    local open = bottom:Find("OpenWindowButton").gameObject
    local discard = bottom:Find("DiscardButton").gameObject
    local inStore = bottom:Find("InStoreButton").gameObject
    local outStore = bottom:Find("OutStoreButton").gameObject
    local lianhua = bottom:Find("LianhuaButton").gameObject
    local xilian = bottom:Find("XilianButton").gameObject
    local place = bottom:Find("PlaceButton").gameObject
    local mark = bottom:Find("MarkButton").gameObject
    local useAll = bottom:Find("UseAllButton").gameObject
    local split = bottom:Find("SplitButton").gameObject
    local collect = bottom:Find("CollectButton").gameObject
    local convert = bottom:Find("ConvertButton").gameObject
    local smelting = bottom:Find("SmeltingButton").gameObject
    local loveCheck = bottom:Find("LoveCheckButton").gameObject
    local faceMerge = bottom:Find("FaceMergeButton").gameObject


    self.sellBtnIcon = sell.transform:Find("Image"):GetComponent(Image)
    self.sellBtnTxt = sell.transform:Find("Text"):GetComponent(Text)
    self.opentxt = open.transform:Find("Text"):GetComponent(Text)

    use:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData, self.extra) end)
    sell:GetComponent(CustomButton).onClick:AddListener(function() self.model:Sell(self.itemData) end)
    sell:GetComponent(CustomButton).onHold:AddListener(function()  self.model:Sell(self.itemData, true) end)
    sell:GetComponent(CustomButton).onDown:AddListener(function() self:OnDownSell() end)
    self.noticeBtn = sell.transform:Find("Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    sell:GetComponent(CustomButton).onUp:AddListener(function() self:OnUpSell() end)
    drop:GetComponent(Button).onClick:AddListener(function() self.model:Drop(self.itemData) end)
    cons:GetComponent(Button).onClick:AddListener(function() self.model:Consignment(self.itemData) end)
    simth:GetComponent(Button).onClick:AddListener(function() self.model:Smith(self.itemData) end)
    ware:GetComponent(Button).onClick:AddListener(function() self.model:Use(self.itemData) end)
    merge:GetComponent(Button).onClick:AddListener(function() self.model:Merge(self.itemData) end)
    pregem:GetComponent(Button).onClick:AddListener(function() self.model:Pet_gem_off(self.itemData) end)
    remove:GetComponent(Button).onClick:AddListener(function() self.model:Remove(self.itemData) end)
    open:GetComponent(Button).onClick:AddListener(function() self.model:Openwindow(self.openwindowid, self.openwindowargs) end)
    discard:GetComponent(Button).onClick:AddListener(function() self.model:Discard(self.itemData) end)
    inStore:GetComponent(Button).onClick:AddListener(function() self.model:InStore(self.itemData) end)
    outStore:GetComponent(Button).onClick:AddListener(function() self.model:OutStore(self.itemData) end)
    lianhua:GetComponent(Button).onClick:AddListener(function() self.model:Alchemy(self.itemData) end)
    xilian:GetComponent(Button).onClick:AddListener(function() self.model:TransForBackPackItem(self.itemData) end)
    place:GetComponent(Button).onClick:AddListener(function() self.model:Place(self.itemData) end)
    mark:GetComponent(Button).onClick:AddListener(function() self.model:Mark(self.itemData) end)
    useAll:GetComponent(Button).onClick:AddListener(function() self.model:UseAll(self.itemData) end)
    split:GetComponent(Button).onClick:AddListener(function() self.model:Split(self.itemData) end)
    collect:GetComponent(Button).onClick:AddListener(function() self.model:Collect(self.handbookId) end)
    convert:GetComponent(Button).onClick:AddListener(function() self.model:Convert(self.itemData) end)
    smelting:GetComponent(Button).onClick:AddListener(function() self.model:Smelting(self.itemData) end)
    loveCheck:GetComponent(Button).onClick:AddListener(function() self.model:LoveCheck(self.itemData) end)
    faceMerge:GetComponent(Button).onClick:AddListener(function() self.model:FaceMerge(self.itemData) end)


    self.buttons = {
        [TipsEumn.ButtonType.Use] = use
        ,[TipsEumn.ButtonType.Drop] = drop
        ,[TipsEumn.ButtonType.Sell] = sell
        ,[TipsEumn.ButtonType.Consigenment] = cons
        ,[TipsEumn.ButtonType.Smith] = simth
        ,[TipsEumn.ButtonType.Ware] = ware
        ,[TipsEumn.ButtonType.Merge] = merge
        ,[TipsEumn.ButtonType.Petgem_off] = pregem
        ,[TipsEumn.ButtonType.Remove] = remove
        ,[TipsEumn.ButtonType.Openwindow] = open
        ,[TipsEumn.ButtonType.Discard] = discard
        ,[TipsEumn.ButtonType.InStore] = inStore
        ,[TipsEumn.ButtonType.OutStore] = outStore
        ,[TipsEumn.ButtonType.AlchemyType] = lianhua
        ,[TipsEumn.ButtonType.Xilian] = xilian
        ,[TipsEumn.ButtonType.Place] = place
        ,[TipsEumn.ButtonType.Mark] = mark
        ,[TipsEumn.ButtonType.UseAll] = useAll
        ,[TipsEumn.ButtonType.Split] = split
        ,[TipsEumn.ButtonType.Collect] = collect
        ,[TipsEumn.ButtonType.Convert] = convert
        ,[TipsEumn.ButtonType.Smelting] = smelting
        ,[TipsEumn.ButtonType.LoveCheck] = loveCheck
    }

    for _,v in pairs(self.buttons) do
        if v ~= nil then
            v.transform.pivot = Vector2(0.5, 0.5)
        end
    end
end

function ItemTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function ItemTips:Default()
    -- print("----------3")
    self.height = 20
    self.nameTxt.text = ""
    self.otherTxt.text = ""
    self.bindObj:SetActive(false)
    self.descTxt.text = ""
    self.text1.text = ""
    self.text2.text = ""
    self.text3.text = ""

    for _,button in pairs(self.buttons) do
        button.gameObject:SetActive(false)
    end

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 道具数据
-- extra = 扩展参数
-- ---- inbag = 是否在背包
-- ---- nobutton = 是否不要任何按钮
-- ---- white_list = 自定义列表 {id,show}
-- ---- 注意，传人white_list就直接根据该列表处理，不做默认处理
-- ---- show_limit = 是否显示限购数
-- ------------------------------------
function ItemTips:UpdateInfo(info, extra)
    self.transform:SetAsLastSibling()
    self:Default()
    self.extra = extra
    self.itemData = info
    if info == nil then return end
    self.nameTxt.text = ColorHelper.color_item_name(info.quality, info.name)
    self.itemCell:SetAll(info, extra)
    self.itemCell:ShowNum(false)
    self.bindObj:SetActive(info.bind == 1)
    self.labelObj:SetActive(false)

    local ddesc = info.desc

    local myDataId = nil
    if info.base_id == 0 or info.base_id == nil then
        myDataId = info.id

    else
        myDataId = info.base_id

    end

    --BaseUtils.dump(info,"info")
    if DataItem.data_get[myDataId].isChance ~= nil and DataItem.data_get[myDataId].isChance ~= 0 then
        self.chanceId = DataItem.data_get[myDataId].isChance
        self.chanceButton.gameObject:SetActive(true)
    else
        self.chanceButton.gameObject:SetActive(false)
    end
    -- 处理品阶描述显示
    self.showStep = false
    if info.step ~= nil and info.step ~= 0 then
        self.showStep = true
        self.otherTxt.gameObject:SetActive(true)
        self.otherTxt.text = string.format(TI18N("品阶:%s"), info.step)
        local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", info.base_id, info.step)]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
        else
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
    else
        self.otherTxt.text = ""
        ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
    end

    if info.step ~= nil and info.step ~= 0 then
        self.showStep = true
        self.otherTxt.gameObject:SetActive(true)
        self.otherTxt.text = string.format(TI18N("品阶:%s"), info.step)
        local step_data = DataExperienceBottle.data_get_exp[info.step]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[exp_bottle1%]", step_data.lev_min)
            ddesc = string.gsub(ddesc, "%[exp_bottle2%]", step_data.lev_max)
            ddesc = string.gsub(ddesc, "%[exp_bottle3%]", step_data.exp)
        else
            ddesc = string.gsub(ddesc, "%[exp_bottle1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[exp_bottle2%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[exp_bottle3%]", TI18N("一定"))
        end
    else
        self.otherTxt.text = ""
        ddesc = string.gsub(ddesc, "%[exp_bottle1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[exp_bottle2%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[exp_bottle3%]", TI18N("一定"))
    end

    local model_id = nil
    if next(info.effect) ~= nil then
        local effectType = info.effect[1].effect_type
        if effectType == 77 then
            model_id = info.effect[1].val[1]
        end
    end
    if model_id ~= nil then
        local lev = RoleManager.Instance.RoleData.lev
        local num = DataItem.data_get_model[model_id.."_"..lev].num
        ddesc = string.gsub(ddesc, "%[coin_num%]", num)
    end

    --雕文
    if next(info.effect_client) ~= nil then
        local effectType = info.effect_client[1].effect_type_client
        if effectType == BackpackEumn.ItemUseClient.glyphs_effect then
            ddesc = BaseUtils.ReplaceGlyphsPattern(info)
        end
    end

    if info.type == 158 then
        self.showStep = false
        self.otherTxt.gameObject:SetActive(false)
        self.otherTxt.text = ""
    end

    if info.base_id == 23238 then
        local capname = "";
        local captimes = 0;
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.quest_offer_times then
                captimes = v.value
            elseif v.name == BackpackEumn.ExtraName.quest_offer_role_name then
                capname = v.str
            end
        end
        if captimes=="" or captimes==nil then
            captimes = 0
        end
        if capname ~= "" and capname ~= nil then
            if tonumber(captimes) > 0 then
                ddesc = ddesc..string.format(TI18N("\n;队长：<color='#31f2f9'>%s</color>\n你已经给Ta颁发<color='#31f2f9'>%s</color>枚奖章"),capname,captimes)
            else
                ddesc = ddesc..string.format(TI18N("\n;队长：<color='#31f2f9'>%s</color>\n你还未给Ta颁发过奖章哦，快表扬一下Ta吧"),capname)
            end
        end
    end
    local tempExtra = extra or {}
    if self.showStep == false or tempExtra.show_limit == true then
        self:ShowLimit(tempExtra.show_limit == true)
    end

    self.height = 105

    -- 处理描述显示
    local th = 0
    local descStr = ""

    -- 处理有效时间显示
    if info.expire_type == nil or info.expire_type == BackpackEumn.ExpireType.None then
        descStr = ""
    elseif info.expire_type == BackpackEumn.ExpireType.StartTime or info.expire_type == BackpackEumn.ExpireType.StartDate then
        if BaseUtils.BASE_TIME > info.expire_time then
            descStr = ""
        else
            local timeStr = string.format("%s %s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M", info.expire_time))
            descStr = string.format(TI18N("\n<color='#00ffff'>%s 可开启</color>"), timeStr)
        end
    else
        local timeStr = string.format("%s　%s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M:00", info.expire_time))
        descStr = string.format(TI18N("\n<color='#00ffff'>过期:%s</color>"), timeStr)
    end

    --处理75保底雷暴的精华值
    if info.base_id == 20185 then
        local BuildNum = 0
        for k,v in pairs(info.extra) do
            if v.name == BackpackEumn.ExtraName.aptitude_acc then
                BuildNum = v.value
                if BuildNum >= 300 then
                    BuildNum = 300
                end
            end
        end
        if descStr == "" then
            descStr = string.format(TI18N("\n<color='#00ffff'>星辰精华：%s/%s</color>"),BuildNum, 300)
        end
    end


    if descStr ~= "" then
        self.descRect.sizeDelta = Vector2(250, 60)
        th = -65
    else
        self.descRect.sizeDelta = Vector2(250, 40)
        th = -45
    end

    self.descTxt.text = string.format(TI18N("作用:%s"), info.func) .. descStr

    local strs = {}
    for s1, s2 in string.gmatch(ddesc, "(.+);(.+)") do
        strs = {s1, s2}
    end
    if #strs == 0 then
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(ddesc)
        self.text1.gameObject:SetActive(true)
        self.text2.text = ""
        self.text2.gameObject:SetActive(false)
        th = th - self.msg1.selfHeight - 5
    else
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(strs[1])
        self.text1.gameObject:SetActive(true)
        th = th - self.msg1.selfHeight - 5

        self.trect2.anchoredPosition = Vector2(0, th)
        self.msg2:SetData(strs[2])
        self.text2.gameObject:SetActive(true)
        th = th - self.msg2.selfHeight - 5
    end

    -- 处理价格显示
    local price = BackpackEumn.GetSellPrice(info)
    if price ~= 0 and info.bind ~= 1 then
        self.trect3.anchoredPosition = Vector2(0, th)
        self.msg3:SetData(string.format(TI18N("出售价格: {assets_1,90003,%s}"), price))
        self.text3.gameObject:SetActive(true)
        th = th - self.msg3.selfHeight - 5
    else
        self.text3.text = ""
        self.text3.gameObject:SetActive(false)
    end
    self.midRect.sizeDelta = Vector2(255, math.abs(th))
    self.height = self.height + math.abs(th) + 10

    self.bottomRect.anchoredPosition = Vector2(0, -self.height)

    -- 处理按钮
    self:ShowButton(info, extra)
    self:IsSetSpecial()

    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

-- 处理tips按钮
function ItemTips:ShowButton(info, extra)
    extra = extra or {}
    local options = info.tips_type
    local showList = {}
    if not extra.nobutton then
        for i, data in ipairs(options) do
            if data.tips == TipsEumn.ButtonType.Drop then
                if not extra.inbag then
                    table.insert(showList, data.tips)
                end
            elseif data.tips == TipsEumn.ButtonType.Openwindow then
                local items = StringHelper.MatchBetweenSymbols(data.val, "{", "}")
                if #items > 0 then
                    local args = BaseUtils.split(items[1], ";")
                    if #args > 0 then
                        self.opentxt.text = args[1]
                    end
                    if #args > 1 then
                        local args2 = BaseUtils.split(args[2], "|")
                        self.openwindowid = args2[1]
                        self.openwindowargs = {}
                        if #args2 > 1 then
                            for args_index=2, #args2 do
                                table.insert(self.openwindowargs, args2[args_index])
                            end
                        end
                    end
                end

                if extra.showopenwindow or extra.inbag then
                    if tonumber(self.openwindowid) == WindowConfig.WinID.giftwindow then
                        if info.bind == BackpackEumn.BindType.unbind then
                            table.insert(showList, data.tips)
                        end
                    else
                        table.insert(showList, data.tips)
                    end
                end
            elseif data.tips == TipsEumn.ButtonType.AlchemyType then
                if extra.inbag then
                    table.insert(showList, data.tips)
                end
            elseif data.tips == TipsEumn.ButtonType.Xilian then
                if extra.inbag then
                    table.insert(showList, data.tips)
                end
            elseif data.tips == TipsEumn.ButtonType.Place then
                table.insert(showList, data.tips)
            elseif data.tips == TipsEumn.ButtonType.Mark then
                table.insert(showList, data.tips)
            else
                if extra.inbag then
                    if data.tips == TipsEumn.ButtonType.Sell then
                        --绑定物品无法出售，寄售,不显示
                        if info.bind == BackpackEumn.BindType.unbind then
                          --  has_sell = true
                            table.insert(showList, data.tips)
                        end
                        --处理是否显示产出图标
                        local btn = self.buttons[data.tips]
                        if data.val ~= nil and data.val ~= "[]" then
                            local icon = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                            if icon == "1" then
                                --显示金币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90003")
                                self.sellBtnIcon.gameObject:SetActive(true)
                                self.sellBtnTxt.text = TI18N("出售")
                                self.noticeBtn.gameObject:SetActive(true)
                            elseif icon == "2" then
                                --显示银币
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90000")
                                self.sellBtnTxt.text = TI18N("上架")
                                self.sellBtnIcon.gameObject:SetActive(true)
                                self.noticeBtn.gameObject:SetActive(false)
                            elseif icon == "3" then
                                --显示钻石
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90002")
                                self.sellBtnTxt.text = TI18N("上架")
                                self.sellBtnIcon.gameObject:SetActive(true)
                                self.noticeBtn.gameObject:SetActive(false)
                            elseif icon == "4" then
                                -- 家园
                                self.sellBtnTxt.text = TI18N("出售")
                                self.noticeBtn.gameObject:SetActive(false)
                                self.sellBtnIcon.gameObject:SetActive(false)
                            elseif icon == "5" then
                                --显示金币，但是卖到银币市场
                                self.sellBtnIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "Assets90003")
                                self.sellBtnTxt.text = TI18N("上架")
                                self.sellBtnIcon.gameObject:SetActive(true)
                                self.noticeBtn.gameObject:SetActive(false)
                            end
                        else
                            self.sellBtnIcon.gameObject:SetActive(false)
                        end
                    elseif data.tips == TipsEumn.ButtonType.Consigenment then
                        --绑定物品无法出售，寄售,不显示
                        if info.bind == BackpackEumn.BindType.unbind then
                            table.insert(showList, data.tips)
                        end
                    elseif data.tips == TipsEumn.ButtonType.UseAll then
                        if info.quantity >= 5 then
                            table.insert(showList, data.tips)
                        end
                    elseif data.tips == TipsEumn.ButtonType.Collect then
                        if data.val ~= "" and data.val ~= "[]" then
                            local id = StringHelper.MatchBetweenSymbols(data.val, "%[", "%]")[1]
                            self.handbookId = tonumber(id)
                            table.insert(showList, data.tips)
                        end
                    else
                        if self.buttons[data.tips] ~= nil then
                            table.insert(showList, data.tips)
                        end
                    end
                end
            end
        end
    end

    if extra.white_list == nil then
       for i,v in ipairs(showList) do
            if self.buttons[v] ~= nil then
                self.buttons[v]:SetActive(true)
            end
        end
    else
        --不根据配置的额外处理部分
        showList = {}
        for i, data in ipairs(extra.white_list) do
            if data.show then
                table.insert(showList, data.id)
            end
            self.buttons[data.id]:SetActive(data.show)
        end
    end

    local count = 0
    local temp  = {}
    local temp1 = {}
    table.sort(showList, function(a,b) return a < b end)

    local hasSell = false
    for i,id in ipairs(showList) do
        if id == TipsEumn.ButtonType.Sell then
            hasSell = true
            table.insert(temp, 1, id)
        elseif id == TipsEumn.ButtonType.Mark then
            if hasSell then
                table.insert(temp, 2, id)
            else
                table.insert(temp, 1, id)
            end
        elseif id == TipsEumn.ButtonType.UseAll then
            if hasSell then
                table.insert(temp, 2, id)
            else
                table.insert(temp, 1, id)
            end
        elseif id == TipsEumn.ButtonType.Split or id == TipsEumn.ButtonType.Collect then
            table.insert(temp1, id)
        else
            table.insert(temp, id)
        end
    end

    table.sort(temp1, function(a,b) return a > b end)
    for _,id in ipairs(temp1) do
        table.insert(temp, id)
    end

    showList = temp
    temp = nil
    if #showList == 1 then
        count = count + 1
        local rect = self.buttons[showList[1]]:GetComponent(RectTransform)
        if showList[1] == TipsEumn.ButtonType.Drop then
            rect.anchoredPosition = Vector2(115, -24)
            rect.sizeDelta = Vector2(230, 48)
        else
            rect.anchoredPosition = Vector2(115, -24)
            rect.sizeDelta = Vector2(110, 48)
        end
    else
        for _,id in ipairs(showList) do
            count = count + 1
            local rect = self.buttons[showList[count]]:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(120*((count-1)%2) + 55, -58*(math.ceil(count/2)-1) - 24)
            rect.sizeDelta = Vector2(110, 48)
        end
    end
    self.height = self.height + 58 * math.ceil(count / 2) + 5
end

function ItemTips:ShowLimit(isshow)
    self.labelObj:SetActive(isshow)
    self.otherTxt.gameObject:SetActive(isshow)
    local marketGoldData = DataMarketGold.data_market_gold_item[self.itemData.base_id]
    local model = MarketManager.Instance.model
    if marketGoldData ~= nil and model.levelOpenItemLimit[self.itemData.base_id] ~= nil then
        local limit_count = 0
        local lev = RoleManager.Instance.RoleData.lev
        for i,v in ipairs(model.levelOpenItemLimit[self.itemData.base_id]) do
            if lev >= v[1] then
                limit_count = v[2]
            else
                break
            end
        end
        if model.limit_data[self.itemData.base_id] == nil or model.limit_data[self.itemData.base_id] == 0 then
            self.otherTxt.text = string.format(TI18N("本周限购 %s/%s个"), tostring(limit_count), tostring(limit_count))
        elseif model.limit_data[self.itemData.base_id] == limit_count then
            self.otherTxt.text = string.format(TI18N("本周限购 <color=#FF0000>0/%s</color>个"), tostring(limit_count))
        else
            self.otherTxt.text = string.format(TI18N("本周限购 %s/%s个"), tostring(limit_count - model.limit_data[self.itemData.base_id]), tostring(limit_count))
        end
    end
end


function ItemTips:OnDownSell()
    self.isUp = false
    LuaTimer.Add(100, function()
        if self.isUp then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.buttons[TipsEumn.ButtonType.Sell].transform, Vector3(1, 1, 1), Vector3(0, 40, -400))
        else
            self.arrowEffect:SetActive(false)
            self.arrowEffect:SetActive(true)
        end
    end)
end

function ItemTips:OnUpSell()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

function ItemTips:OnHide()
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

function ItemTips:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.buttons[TipsEumn.ButtonType.Sell].gameObject, itemData = {TI18N("长按可<color='#ffff00'>批量出售</color>")}, special = true})
end

function ItemTips:IsSetSpecial()
    local data = nil
    if self.itemData.base_id ~= nil then
        data = DataItem.data_get[self.itemData.base_id]
    else
        data = DataItem.data_get[self.itemData.id]
    end

    if data ~= nil then
        local id  = data.special_quality
        if id == 1 then
            self:ShowSpecial(true)
        else
            self:ShowSpecial(false)
        end
    end
end
function ItemTips:ShowSpecial(t)
    if t == true then
        self.specialIcon.gameObject:SetActive(true)
    else
        self.specialIcon.gameObject:SetActive(false)
    end
end
