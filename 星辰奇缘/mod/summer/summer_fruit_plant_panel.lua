--2016/7/14
--zzl
SummerFruitPlantPanel = SummerFruitPlantPanel or BaseClass(BasePanel)

function SummerFruitPlantPanel:__init(model,parent)
    self.parent = parent
    self.model = SummerManager.Instance.model
    self.resList = {
        {file = AssetConfig.summer_fruit_plant_panel, type = AssetType.Main}
        ,{file = AssetConfig.summer_fruit_plant_bg1, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = AssetConfig.summer_fruit_plant_bg2, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20121), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20118), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20070), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20158), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20159), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file  =  AssetConfig.summer_res, type  =  AssetType.Dep}
    }
    self.has_init = false
    self.fruit_item_list = {}

    self.timer_id = 0

    self.cool_timer_id = 0

    self.downUpTimerId = 0

    self.previewComp_list = {}

    self.update_view = function()
        self:update_info(1)
    end

    self.on_item_update = function()
        self:update_info(2)
    end

    self.downFun = function(item)
        if self.has_init then
            if item.ImgBubbleRect.anchoredPosition.y == 34 then
                Tween.Instance:MoveLocalY(item.ImgBubbleGo, 38, 0.4, function() self.upFun(item) end, LeanTweenType.linear)
            end
        end
    end

    self.upFun = function(item)
        if self.has_init then
            if item.ImgBubbleRect.anchoredPosition.y == 38 then
                Tween.Instance:MoveLocalY(item.ImgBubbleGo, 34, 0.4, function() self.downFun(item) end, LeanTweenType.linear)
            end
        end
    end

    self.loaders = {}
    return self
end

function SummerFruitPlantPanel:__delete()
    for k,v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil

    if self.fruit_item_list ~= nil then
        for k, v in pairs(self.fruit_item_list) do
            v.slot:DeleteMe()
        end
    end
    self.BottomSlot:DeleteMe()
    self.TopCon:Find("ImgBg1"):GetComponent(Image).sprite = nil
    self.TopCon:Find("ImgBg2"):GetComponent(Image).sprite = nil

    self.has_init = false
    if self.previewComp_list[1] ~= nil then
        self.previewComp_list[1]:DeleteMe()
    end

    if self.previewComp_list[2] ~= nil then
        self.previewComp_list[2]:DeleteMe()
    end

    if self.previewComp_list[3] ~= nil then
        self.previewComp_list[3]:DeleteMe()
    end

    if self.previewComp_list[4] ~= nil then
        self.previewComp_list[4]:DeleteMe()
    end

    if self.previewComp_list[5] ~= nil then
        self.previewComp_list[5]:DeleteMe()
    end

    if self.previewComp_list[6] ~= nil then
        self.previewComp_list[6]:DeleteMe()
    end

    self.previewComp_list = nil

    self:stop_timer()
    self:stop_cool_timer()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:RemoveListener(event_name.summer_fruit_plant_update, self.update_view)
    self.fruit_item_list = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function SummerFruitPlantPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_fruit_plant_panel))
    self.gameObject.name = "SummerFruitPlantPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    --self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.one

    self.TopCon = self.transform:Find("TopCon")
    self.TopImgClock = self.TopCon:Find("ImgClock")
    self.TopTimeClock = self.TopImgClock:Find("TxtTime"):GetComponent(Text)
    self.TopCon:Find("ImgBg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.summer_fruit_plant_bg1, "FruitPlantBg1")
    self.TopCon:Find("ImgBg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.summer_fruit_plant_bg2, "FruitPlantBg2")
    self.ImgRightGift = self.TopCon:Find("TitleCon/ImgGiftBox")

    self.noticeBtn = self.TopCon:Find("TitleCon/NoticeButton"):GetComponent(Button)
    local tipsText = {DataCampaign.data_list[self.campId].cond_desc}
    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = tipsText})
        end)


    local go = self.ImgRightGift.gameObject
    local imgLoader = SingleIconLoader.New(go)
    imgLoader:SetSprite(SingleIconType.Item, 22530)
    self.loaders[go:GetInstanceID()] = imgLoader

    self.BottomCon = self.transform:Find("BottomCon")
    self.ImgLeft = self.BottomCon:Find("ImgLeft")
    self.BottomTxtDesc = self.ImgLeft:Find("TxtDescBottom"):GetComponent(Text)
    self.BottomTxtDesc.gameObject:SetActive(false)
    self.BottomTxtDesc.text = ""
    self.Left_title_con = self.ImgLeft:Find("ImgTitle")
    self.Left_title_txt = self.Left_title_con:Find("TxtTitle"):GetComponent(Text)
    self.StatusCon1 = self.ImgLeft:Find("StatusCon1")

    self.StatusCon2 = self.ImgLeft:Find("StatusCon2")
    self.StatusClock =  self.StatusCon2:Find("ImgClock").gameObject
    self.StatusTxtTime = self.StatusCon2:Find("TxtTime"):GetComponent(Text)
    self.StatusTxtTips = self.StatusCon2:Find("TxtTips"):GetComponent(Text)

    self.SlotCon = self.StatusCon1:Find("SlotCon")
    self.BottomSlot = self:create_equip_slot(self.SlotCon)
    self.ExpCon = self.StatusCon1:Find("ExpCon")
    self.TxtVal = self.ExpCon:Find("TxtVal"):GetComponent(Text)

    self.TxtVal.text = ""

    self.HelpCon = self.StatusCon1:Find("HelpCon")
    self.HelpCon_panel = self.HelpCon:Find("Panel"):GetComponent(Button)
    self.GuildHelpBtn = self.HelpCon:Find("GuildBtn"):GetComponent(Button)
    self.FriendHelpBtn = self.HelpCon:Find("FriendBtn"):GetComponent(Button)

    self.BtnHelp = self.StatusCon1:Find("BtnHelp"):GetComponent(Button)
    self.BtnPlant = self.StatusCon1:Find("BtnPlant"):GetComponent(Button)

    self.plantBtnEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20121)))
    self.plantBtnEffect.transform:SetParent(self.BtnPlant.transform)
    self.plantBtnEffect.transform.localRotation = Quaternion.identity
    self.plantBtnEffect:SetActive(true)
    Utils.ChangeLayersRecursively(self.plantBtnEffect.transform, "UI")
    self.plantBtnEffect.transform.localScale = Vector3(1.3, 1.3, 1.3)
    self.plantBtnEffect.transform.localPosition = Vector3(0, 0, -100)


    self.GuildHelpBtn.onClick:AddListener(function()
        self.show_help = false
        self.HelpCon.gameObject:SetActive(self.show_help)

        SummerManager.Instance:request14022(2, self.last_item.data.id, {})
    end)
    self.FriendHelpBtn.onClick:AddListener(function()
        --检查下是否已经种了两块地

        self.show_help = false
        self.HelpCon.gameObject:SetActive(self.show_help)

        self.model:InitFruitHelpUI()
    end)

    self.show_help = false
    self.HelpCon_panel.onClick:AddListener(function()
        self.show_help = false
        self.HelpCon.gameObject:SetActive(self.show_help)
    end)
    self.BtnHelp.onClick:AddListener(function()
        local has_plant_num = 0

        for i=1, #self.model.fruit_plant_data.list do
            local plant_data = self.model.fruit_plant_data.list[i]
            if plant_data.status ~= 0 then
                has_plant_num = has_plant_num + 1
            end
        end
        if has_plant_num < 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("播种<color='#ffff00'>2块土地</color>，才可使用求助{face_1,22}"))
            return
        end


        self.show_help = not self.show_help
        self.HelpCon.gameObject:SetActive(self.show_help)
    end)
    self.BtnPlant.onClick:AddListener(function()
        --BaseUtils.dump(self.last_item,"self.last_item")
        local itemId = self.last_item.cfg_data.item_id
        local needNum = self.last_item.cfg_data.num
        local ownNum = BackpackManager.Instance:GetNotExpireItemCount(itemId)
        if ownNum < needNum then
            NoticeManager.Instance:FloatTipsByString(TI18N("种子不足，快去获取吧{face_1,3}"))
            TipsManager.Instance:ShowItem({gameObject = nil, itemData = DataItem.data_get[itemId]})
        else
            SummerManager.Instance:request14023(self.last_item.data.id)
        end
    end)

    self.ImgRight = self.BottomCon:Find("ImgRight")
    self.ImgRightTxt = self.ImgRight:Find("ExpCon/TxtVal"):GetComponent(Text)
    self.ImgRightBtn = self.ImgRight:GetComponent(Button)

    go = self.ImgRight:Find("ImgReward").gameObject
    local imgLoader1 = SingleIconLoader.New(go)
    imgLoader1:SetSprite(SingleIconType.Item, 23630)
    self.loaders[go:GetInstanceID()] = imgLoader1

    self.all_finish_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20118)))
    self.all_finish_effect.transform:SetParent(self.ImgRight)
    self.all_finish_effect.transform.localRotation = Quaternion.identity
    self.all_finish_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.all_finish_effect.transform, "UI")
    self.all_finish_effect.transform.localScale = Vector3(1.9, 2.1, 1)
    self.all_finish_effect.transform.localPosition = Vector3(-93, 56, -325)


    self.finish_reward_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20158)))
    self.finish_reward_effect.transform:SetParent(self.ImgRight:Find("ImgReward"))
    self.finish_reward_effect.transform.localRotation = Quaternion.identity
    self.finish_reward_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.finish_reward_effect.transform, "UI")
    self.finish_reward_effect.transform.localScale = Vector3(1, 1, 1)
    self.finish_reward_effect.transform.localPosition = Vector3(0, 0, -325)


    self.ImgRightBtn.onClick:AddListener(function()
        if self.model.fruit_plant_data ~= nil then
            if self.model.fruit_plant_data.end_time == 0 and self.all_map_has_finish then
                --可领奖
                SummerManager.Instance:request14026()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("收获所有土地可领取大丰收奖励"))

                local itemData = ItemData.New()
                itemData:SetBase(DataItem.data_get[23630])
                TipsManager.Instance:ShowItem({gameObject = self.ImgRightBtn.gameObject, itemData = itemData, extra = {nobutton = false, inbag = false}})
            end
        end
    end)

    self.has_init = true
    for i=1,6 do
        local go = self.TopCon:Find(string.format("FruitItem%s",i))
        local item = self:create_fruit_item(go, i)
        self.fruit_item_list[i] = item
    end

    SummerManager.Instance:request14021(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)

    EventMgr.Instance:AddListener(event_name.summer_fruit_plant_update, self.update_view)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
end

--更新田地
function SummerFruitPlantPanel:update_info(_type)
    if self.model.fruit_plant_data == nil then return end
    local map_data_list = self.model.fruit_plant_data.list
    --BaseUtils.dump(map_data_list,"map_data_list")
    table.sort(map_data_list, function(a, b) return a.id < b.id end)

    local open_timer = false
    self.all_map_has_finish = true --判断下所有土地是否已收获


    for i=1,#map_data_list do
        local map_data = map_data_list[i]
        local fruit_item = self.fruit_item_list[i]
        self:update_fruit_item_data(fruit_item, map_data, _type)

        if fruit_item.left_time > 0 then
            open_timer = true
        end

        if map_data.status ~= 2 then
            self.all_map_has_finish = false
        end
    end

    if open_timer then
        self:start_timer()
    else
        self:stop_timer()
    end

    self.all_finish_effect:SetActive(false)
    self.finish_reward_effect:SetActive(false)
    if self.all_map_has_finish and self.model.fruit_plant_data.end_time == 0 then
        self.all_finish_effect:SetActive(true)

        self.ImgRightTxt.text = TI18N("可领取")
    elseif self.model.fruit_plant_data.end_time > 0 then
        self.ImgRightTxt.text = TI18N("已领取")
    else
        local base_data = DataItem.data_get[23630]
        self.ImgRightTxt.text = ColorHelper.color_item_name(base_data.quality ,base_data.name)
    end

    if self.last_item ~= nil then
        self:update_bottom(self.last_item)
    else
        self:update_bottom(self.fruit_item_list[1])
    end
end

--------------------------------fruitItem逻辑
--创建fruitItem表结构
function SummerFruitPlantPanel:create_fruit_item(gameObject, index)
    local item = {}
    item.gameObject = gameObject
    item.transform = gameObject.transform

    item.index = index
    item.left_time = 0
    item.transform:GetComponent(Button).onClick:AddListener(function()
        if item.data ~= nil then
            if item.data.status == 1 and item.left_time <= 0 then
                item.BubbleCon.gameObject:SetActive(false)
                 item.ImgBubbleGo:SetActive(false)
                --领取
                item.bubble_effect:SetActive(false)
                item.bubble_effect:SetActive(true)
                item.tree_moel_effect:SetActive(false)
                item.tree_moel_effect:SetActive(true)
                item.composite.tpose.transform:GetComponent(Animator):Play("Idle1")
                LuaTimer.Add(1200, function()
                    item.bubble_effect:SetActive(false)
                    item.tree_moel_effect:SetActive(false)
                    SummerManager.Instance:request14025(item.data.id)
                end)
            end
            self:update_bottom(item, 1)
        end

    end)

    item.ImgBg = item.transform:Find("ImgBg"):GetComponent(Image)
    item.ImgFruitPlantSelect = item.transform:Find("ImgFruitPlantSelect").gameObject
    item.SlotCon = item.transform:Find("SlotCon")
    item.Con = item.SlotCon:Find("Con")
    item.slot = self:create_equip_slot(item.Con)
    item.ImgArrow = item.SlotCon:Find("ImgArrow")

    item.ImgTxtBg = item.SlotCon:Find("ImgTxtBg")
    item.ImgTxtBgTxt = item.ImgTxtBg:Find("TxtSlotName"):GetComponent(Text)

    item.Preview = item.transform:Find("Preview")
    item.TimeCon = item.transform:Find("TimeCon")
    item.TxtTime = item.TimeCon:Find("TxtTime"):GetComponent(Text)

    item.ImgArrow.gameObject:SetActive(false)
    item.SlotCon.gameObject:SetActive(false)
    item.Preview.gameObject:SetActive(false)
    item.TimeCon.gameObject:SetActive(false)

    item.ImgBubble = item.transform:Find("ImgBubble")
    item.ImgTxtState = item.transform:Find("ImgTxtState"):GetComponent(Image)
    item.ImgBubbleRect = item.transform:Find("ImgBubble"):GetComponent(RectTransform)
    item.ImgBubbleForward = 1 --代表向下
    item.ImgBubbleGo = item.ImgBubble.gameObject
    item.ImgBubble.gameObject:SetActive(false)
    item.BubbleCon = item.ImgBubble:Find("BubbleCon")
    item.BubbleSlotCon = item.BubbleCon:Find("BubbleSlotCon"):GetComponent(Image)

    Tween.Instance:MoveLocalY(item.ImgBubbleGo, 34, 0.4, function() self.downFun(item) end, LeanTweenType.linear)

    --气泡特效
    item.bubble_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20070)))
    item.bubble_effect.transform:SetParent(item.ImgBubble)
    item.bubble_effect.transform.localRotation = Quaternion.identity
    item.bubble_effect:SetActive(false)

    --植物模型idle特效，20159
    item.tree_moel_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20159)))
    item.tree_moel_effect.transform:SetParent(item.transform)
    item.tree_moel_effect.transform.localRotation = Quaternion.identity
    item.tree_moel_effect:SetActive(false)

    Utils.ChangeLayersRecursively(item.bubble_effect.transform, "UI")
    item.bubble_effect.transform.localScale = Vector3(1, 1, 1)
    item.bubble_effect.transform.localPosition = Vector3(0, 0, -100)


    Utils.ChangeLayersRecursively(item.tree_moel_effect.transform, "UI")
    item.tree_moel_effect.transform.localScale = Vector3(1, 1, 1)
    item.tree_moel_effect.transform.localPosition = Vector3(0, 0, -100)

    return item
end

--创建slot
function SummerFruitPlantPanel:create_equip_slot(slot_con)
    local _slot = ItemSlot.New()
    _slot.gameObject.transform:SetParent(slot_con)
    _slot.gameObject.transform.localScale = Vector3.one
    _slot.gameObject.transform.localPosition = Vector3.zero
    _slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = _slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return _slot
end

--对slot设置数据
function SummerFruitPlantPanel:set_slot_data(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end

--设置fruitImte的数据
function SummerFruitPlantPanel:update_fruit_item_data(item,_data, _type)
    item.data = _data

    item.cfg_data = DataCampFruit.data_fruit_base[_data.id]

    if self.model.fruit_plant_data.end_time > 0 then
        item.SlotCon.gameObject:SetActive(false)
        item.Preview.gameObject:SetActive(false)
        item.TimeCon.gameObject:SetActive(false)
        item.BubbleCon.gameObject:SetActive(false)
        item.ImgBubbleGo:SetActive(false)

        --换成烂地皮
        item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantBreakBg")
        item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NHasFinish")
        item.ImgTxtState.gameObject:SetActive(true)
    else

        if _type == 2 and _data.status == 0 then
            --换成正常地皮
            item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantbg")
            --道具更新
            --初始状态
            local base_data = DataItem.data_get[item.cfg_data.item_id]
            self:set_slot_data(item.slot, base_data, false)
            item.slot:SetQualityInBag(base_data.quality)
            item.slot:SetNotips(true)

            item.Preview.gameObject:SetActive(false)
            item.TimeCon.gameObject:SetActive(false)
            item.BubbleCon.gameObject:SetActive(false)
            item.ImgBubbleGo:SetActive(false)
            item.SlotCon.gameObject:SetActive(true)


            item.ImgArrow.gameObject:SetActive(true)
            item.ImgTxtBgTxt.text = ColorHelper.color_item_name(base_data.quality ,base_data.name)

            local has_num = BackpackManager.Instance:GetNotExpireItemCount(item.cfg_data.item_id)
            item.slot:SetNum(has_num, item.cfg_data.num)

            if has_num >= item.cfg_data.num then
                item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NCanPlant")
                item.ImgTxtState.gameObject:SetActive(true)
                item.ImgTxtBg.gameObject:SetActive(false)
            else
                item.ImgTxtState.gameObject:SetActive(false)
                item.ImgTxtBg.gameObject:SetActive(true)
            end
        elseif _type == 1 then
            if _data.status == 0 then
                --换成正常地皮
                item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantbg")
                --初始状态
                local base_data = DataItem.data_get[item.cfg_data.item_id]
                self:set_slot_data(item.slot, base_data, false)
                item.slot:SetQualityInBag(base_data.quality)
                item.slot:SetNotips(true)

                item.Preview.gameObject:SetActive(false)
                item.TimeCon.gameObject:SetActive(false)
                item.BubbleCon.gameObject:SetActive(false)
                 item.ImgBubbleGo:SetActive(false)
                item.SlotCon.gameObject:SetActive(true)

                item.ImgArrow.gameObject:SetActive(true)
                item.ImgTxtBgTxt.text = ColorHelper.color_item_name(base_data.quality ,base_data.name)

                local has_num = BackpackManager.Instance:GetNotExpireItemCount(item.cfg_data.item_id)
                item.slot:SetNum(has_num, item.cfg_data.num)

                if has_num >= item.cfg_data.num then
                    item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NCanPlant")
                    item.ImgTxtState.gameObject:SetActive(true)
                    item.ImgTxtBg.gameObject:SetActive(false)
                else
                    item.ImgTxtState.gameObject:SetActive(false)
                    item.ImgTxtBg.gameObject:SetActive(true)
                end
            elseif _data.status == 1 then
                --换成正常地皮
                item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantbg")
                --种植状态
                local left_time = _data.start_time + item.cfg_data.cd - BaseUtils.BASE_TIME
                item.left_time = left_time


                item.Preview.gameObject:SetActive(true)
                item.TimeCon.gameObject:SetActive(true)
                item.SlotCon.gameObject:SetActive(false)

                if item.left_time > 0 then
                    --还在种植生长
                    item.BubbleCon.gameObject:SetActive(false)
                     item.ImgBubbleGo:SetActive(false)
                    self:update_model(_data, item.cfg_data.plant_model_id, 1, item) --设置模型
                    item.ImgTxtState.gameObject:SetActive(false)
                else
                    --可收获
                    item.TxtTime.text = string.format("<color='#2fc823'>%s</color>", TI18N("可收获"))
                    self:update_model(_data, item.cfg_data.finish_model_id, 2, item) --设置模型
                    item.BubbleCon.gameObject:SetActive(true)
                     item.ImgBubbleGo:SetActive(true)

                    local go = item.BubbleSlotCon.gameObject
                    local id = go:GetInstanceID()
                    local imgLoader = self.loaders[id]
                    if imgLoader == nil then
                        imgLoader = SingleIconLoader.New(go)
                        self.loaders[id] = imgLoader
                    end
                    imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[item.cfg_data.product_id].icon)

                    item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NCanGet")
                    item.ImgTxtState.gameObject:SetActive(true)
                end
            elseif _data.status == 2 then
                --已收获
                --换成烂地皮
                item.Preview.gameObject:SetActive(false)
                item.TimeCon.gameObject:SetActive(false)
                item.BubbleCon.gameObject:SetActive(false)
                 item.ImgBubbleGo:SetActive(false)
                item.SlotCon.gameObject:SetActive(false)
                item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "FruitPlantBreakBg")

                item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NHasFinish")
                item.ImgTxtState.gameObject:SetActive(true)
            end
        end

    end
end

--更新底部
function SummerFruitPlantPanel:update_bottom(item, _type)
    if self.last_item ~= nil then
        self.last_item.ImgFruitPlantSelect:SetActive(false)
    end
    self.last_item = item

    self.TopImgClock.gameObject:SetActive(false)
    self.last_item.ImgFruitPlantSelect:SetActive(true)

    self.BottomTxtDesc.text = ""
    self.BottomTxtDesc.gameObject:SetActive(false)
    if self.model.fruit_plant_data.end_time > 0 then
        self.Left_title_txt.text = TI18N("种植状态")
        --所有都已经完成，显示播种冷却
        self.StatusCon1.gameObject:SetActive(false)
        self.StatusCon2.gameObject:SetActive(true)
        self.TopImgClock.gameObject:SetActive(true)
        self.timer_pre_str = TI18N(" 播种冷却")
        self.StatusTxtTips.text = TI18N("所有田地收获后进入冷却，冷却完毕可<color='#ffff00'>再次种植</color>")
        if _type ~= 1 then
            self.timer_cool_left_time = self.model.fruit_plant_data.end_time - BaseUtils.BASE_TIME
            self:start_cool_timer(1)
        end
    elseif  self.last_item.data.status == 2 then
        self.Left_title_txt.text = TI18N("种植状态")
        --已收获
        self.StatusCon1.gameObject:SetActive(false)
        self.StatusCon2.gameObject:SetActive(false)
        self.BottomTxtDesc.text = TI18N("该土地<color='#ffff00'>已完成</color>种植，请完成其他土地的种植")
        self.BottomTxtDesc.gameObject:SetActive(true)
        self.StatusTxtTips.text = TI18N("所有田地收获后进入冷却，冷却完毕可<color='#ffff00'>再次种植</color>")
        self:stop_cool_timer()
    elseif self.last_item.left_time > 0 and self.last_item.data.status == 1 then
        self.Left_title_txt.text = TI18N("种植状态")
        --等待成熟
        self.StatusCon1.gameObject:SetActive(false)
        self.StatusCon2.gameObject:SetActive(true)
        self.timer_pre_str = TI18N(" 等待成熟")
        self.StatusTxtTips.text = TI18N("倒计时结束后即可<color='#ffff00'>收获果实</color>")
        self.timer_cool_left_time = self.last_item.left_time
        self:start_cool_timer(2)

    elseif self.last_item.left_time <= 0 and self.last_item.data.status == 1 then
        self.Left_title_txt.text = TI18N("种植状态")
        --可收获
        self.StatusCon1.gameObject:SetActive(false)
        self.StatusCon2.gameObject:SetActive(true)
        self.StatusTxtTime.text = ""
        self.StatusClock:SetActive(false)
        self:stop_cool_timer()
    else
        self.Left_title_txt.text = TI18N("种植所需")

        --当前选中的可以播种
        self.StatusCon2.gameObject:SetActive(false)
        self.StatusCon1.gameObject:SetActive(true)
        self:stop_cool_timer()
    end



    local base_data = DataItem.data_get[item.cfg_data.item_id]
    self:set_slot_data(self.BottomSlot, base_data)
    --local has_num = BackpackManager.Instance:GetItemCount(item.cfg_data.item_id)
    local has_num = BackpackManager.Instance:GetNotExpireItemCount(item.cfg_data.item_id)
    self.BottomSlot:SetNum(has_num, item.cfg_data.num)

    self.TxtVal.text =  ColorHelper.color_item_name(base_data.quality ,base_data.name) -- tostring(item.cfg_data.plant_exp_mode)

    self.BottomSlot:SetQualityInBag(base_data.quality)

    if has_num >= item.cfg_data.num then
        self.plantBtnEffect:SetActive(true)
    else
        self.plantBtnEffect:SetActive(false)
    end
end


----------------模型逻辑
--更新守护模型
function SummerFruitPlantPanel:update_model(_data, _u_id, _type, item)
    local previewComp = self.previewComp_list[item.index]
    local callback = function(composite)
        self:on_model_build_completed(composite, _data, item)
    end
    local setting = nil
    local _scale = 1
    if _type == 2 then
        --已完成
        _scale = 4.8
        setting = {
            name = "PlantNpc"
            ,orthographicSize = 1
            ,width = 120
            ,height = 120
            ,offsetY = -0.4
            ,noDrag = true
        }
    elseif _type == 1 then
        --成长中
        _scale = 6
        setting = {
            name = "PlantNpc"
            ,orthographicSize = 1
            ,width =  100
            ,height = 100
            ,offsetY = -0.4
            ,noDrag = true
        }
    end

    local cfg_data = DataUnit.data_unit[_u_id]
    local modelData = {type = PreViewType.Npc, skinId = cfg_data.skin, modelId = cfg_data.res, animationId = cfg_data.animation_id, scale = _scale}
    if previewComp == nil then
        previewComp = PreviewComposite.New(callback, setting, modelData)
        self.previewComp_list[item.index] = previewComp
        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() previewComp:Hide() end)
        self.OnOpenEvent:AddListener(function() previewComp:Show() end)
    else
        previewComp:Reload(modelData, callback)
    end
end

--守护模型加载完成
function SummerFruitPlantPanel:on_model_build_completed(composite, _data, item)
    local rawImage = composite.rawImage
    local preview = item.Preview
    rawImage.transform:SetParent(preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform:Rotate(Vector3(320, 0, 0))
    composite.tpose.transform:GetComponent(Animator):Play("Stand1")
    item.composite = composite
    --SceneConstData.UnitFaceTo.RightForward
end




----------------计时器逻辑
--启动计时器
function SummerFruitPlantPanel:start_timer()
    self:stop_timer()
    --开一个计时器，每秒遍历三个
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

--关闭计时器
function SummerFruitPlantPanel:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

--计时器逻辑
function SummerFruitPlantPanel:timer_tick()
    local all_zero = true
    for i=1,#self.fruit_item_list do
        local item = self.fruit_item_list[i]
        if item.left_time > 0 then
            item.left_time = item.left_time - 1
            if item.left_time >= 0 then
                all_zero = false
                if item.left_time == 0 then
                    item.TxtTime.text = string.format("<color='#2fc823'>%s</color>", TI18N("已完成"))

                    item.ImgTxtState.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, "I18NCanGet")
                    item.ImgTxtState.gameObject:SetActive(true)

                    item.BubbleCon.gameObject:SetActive(true)
                    item.ImgBubbleGo:SetActive(true)

                    local go = item.BubbleSlotCon.gameObject
                    local id = go:GetInstanceID()
                    local imgLoader = self.loaders[id]
                    if imgLoader == nil then
                        imgLoader = SingleIconLoader.New(go)
                        self.loaders[id] = imgLoader
                    end
                    imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[item.cfg_data.product_id].icon)

                    self:update_model(self.fruit_item_list[i].data, item.cfg_data.finish_model_id, 2, item) --设置模型
                else
                    local _, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(item.left_time)
                    my_minute = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
                    my_second = my_second >= 10 and my_second or string.format("0%s", my_second)
                    if my_hour > 0 then
                        my_hour = my_hour >= 10 and my_hour or string.format("0%s", my_hour)
                        item.TimeCon:GetComponent(RectTransform).anchoredPosition = Vector2(5.4, 36)
                        item.TimeCon:GetComponent(RectTransform).sizeDelta = Vector2(109, 20)
                        item.TxtTime.transform:GetComponent(RectTransform).sizeDelta = Vector2(81, 21)
                        item.TxtTime.text = string.format("%s:%s:%s", my_hour,my_minute, my_second)
                    else
                        item.TimeCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, 36)
                        item.TimeCon:GetComponent(RectTransform).sizeDelta = Vector2(83, 20)
                        item.TxtTime.transform:GetComponent(RectTransform).sizeDelta = Vector2(58, 21)
                        item.TxtTime.text = string.format("%s:%s", my_minute, my_second)
                    end
                end
            end
        end
    end

    if all_zero then
        --全部都倒计时完
        self:stop_timer()
    end
end


--------播种冷却或等待成熟的计时器
function SummerFruitPlantPanel:start_cool_timer(_type)
    self.StatusClock:SetActive(true)
    self.cool_time_type = _type
    self:stop_cool_timer()
    self.cool_timer_id = LuaTimer.Add(0, 1000, function() self:cool_timer_tick() end)
end

function SummerFruitPlantPanel:stop_cool_timer()
    if self.cool_timer_id ~= 0 then
        LuaTimer.Delete(self.cool_timer_id)
        self.cool_timer_id = 0
    end
end

function SummerFruitPlantPanel:cool_timer_tick()
    local cool_time = 0
    self.timer_cool_left_time = self.timer_cool_left_time - 1
    cool_time = self.timer_cool_left_time
    if cool_time >= 0 then
        local _, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(cool_time)
        my_minute = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
        my_second = my_second >= 10 and my_second or string.format("0%s", my_second)
        if my_hour > 0 then
            my_hour = my_hour >= 10 and my_hour or string.format("0%s", my_hour)
            self.StatusTxtTime.text = string.format("%s:%s%s%s%s", self.timer_pre_str, my_hour, TI18N("时"), my_minute, TI18N("分"))
            self.TopTimeClock.text = string.format("%s:%s:%s", my_hour, my_minute, my_second)
        else
            self.StatusTxtTime.text = string.format("%s: %s:%s", self.timer_pre_str, my_minute, my_second)
            self.TopTimeClock.text = string.format("%s:%s", my_minute, my_second)
        end
    else
        if self.cool_time_type == 2 then
            if cool_time <= 0 and self.last_item.data.status == 1 then
                self.StatusTxtTime.text = TI18N("可收获")
                self.StatusClock:SetActive(false)
                self.StatusTxtTips.text = TI18N("所有田地收获后进入冷却，冷却完毕可<color='#ffff00'>再次种植</color>")
            end
        elseif self.cool_time_type == 1 then
             SummerManager.Instance:request14021(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
        end
        self:stop_cool_timer()
    end
end

