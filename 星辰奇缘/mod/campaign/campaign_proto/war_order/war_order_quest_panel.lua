-- @author hze
-- @date #19/08/19#
-- @战令任务面板

WarOrderQuestPanel = WarOrderQuestPanel or BaseClass(BasePanel)

function WarOrderQuestPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.war_order_quest_panel, type = AssetType.Main}
        ,{file = AssetConfig.warordertextures, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
    }
    self.model = model
    self.parent = parent
    self.mgr = CampaignProtoManager.Instance


    self.itemList = {}
    self.loaders = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._update_quest_listener = function() self:ReloadQuestData() end
    self._update_weekBox_listener = function() self:SetWeekBoxData() end
end

function WarOrderQuestPanel:__delete()
    self.OnHideEvent:Fire()

    BaseUtils.ReleaseImage(self.rewardIconImg)

    if self.loaders then 
        for _ , v in pairs(self.loaders) do
            v:DeleteMe()
        end
    end

    if self.shakeTimer ~= nil then 
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end

    if self.effect ~= nil then 
        self.effect:DeleteMe()
    end

    if self.itemList ~= nil then 
        for _, v in ipairs(self.itemList) do
            if v.slotList ~= nil then 
                for __, vv in ipairs(v.slotList) do
                    if vv.slot then 
                        vv.slot:DeleteMe()
                    end
                    if vv.effect then 
                        vv.effect:DeleteMe()
                    end
                end
            end
        end
    end

    self:AssetClearAll()
end

function WarOrderQuestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_quest_panel))
    self.gameObject.name = "WarOrderQuestPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform

    local bottom = t:Find("Bottom")
    self.rewardIconImg = bottom:Find("IconBg/Icon"):GetComponent(Image)

    self.rewardBtn = bottom:Find("IconBg"):GetComponent(Button)
    self.rewardBtn.onClick:AddListener(function() self:OnRewardClick() end)

    self.descTxt = bottom:Find("DescText"):GetComponent(Text)
    self.statusTxt = bottom:Find("StatusText"):GetComponent(Text)

    self.buyBtn = bottom:Find("Button"):GetComponent(Button)
    self.buyBtn.onClick:AddListener(function() self:OnBuyClick() end)


    self.scroll = t:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function()
        self:DealExtraEffect()
        end)

    self.container = t:Find("ScrollRect/Container")
    self.tempItem = t:Find("ScrollRect/Tab").gameObject
    self.tempItem:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
end

function WarOrderQuestPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderQuestPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if not self.openArgs then
        return
    end
    self.campId = self.openArgs
    -- print(self.campId)

    -- self.mgr:Send10261()
    self:ReloadQuestData()
    self:SetWeekBoxData()

    -- self.container.anchoredPosition = Vector2(0,0)
    LuaTimer.Add(200, function() self:DealExtraEffect()  end)
end

function WarOrderQuestPanel:OnHide()
    self:RemoveListeners()
end

function WarOrderQuestPanel:AddListeners()
    self.mgr.updateWarOrderQuestEvent:AddListener(self._update_quest_listener)
    EventMgr.Instance:AddListener(event_name.quest_update, self._update_quest_listener)
    self.mgr.updateWarOrderEvent:AddListener(self._update_weekBox_listener)
end

function WarOrderQuestPanel:RemoveListeners()
    self.mgr.updateWarOrderQuestEvent:RemoveListener(self._update_quest_listener)
    EventMgr.Instance:RemoveListener(event_name.quest_update, self._update_quest_listener)
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_weekBox_listener)
end

--更新界面数据
function WarOrderQuestPanel:ReloadQuestData()
    local idList = {}
    for id, _ in pairs(self.model.warOrderQuestData) do
        table.insert(idList, id)
    end
    -- BaseUtils.dump(self.model.warOrderQuestData, "ssddsd")
    table.sort(idList, function(a, b)
        local a_vo = self.model.warOrderQuestData[a]
        local b_vo = self.model.warOrderQuestData[b]

        if a_vo and b_vo then
            if a_vo.sort ~= b_vo.sort then
                return a_vo.sort < b_vo.sort
            end
        end
        return a < b 
    end)

    self.layout:ReSet()
    for i, quest_id in ipairs(idList) do
        local item = self.itemList[i] or {}
        if self.itemList[i] == nil then 
           item.gameObject = GameObject.Instantiate(self.tempItem)
           item.transform = item.gameObject.transform
           item.headIcon = item.transform:Find("QuestIcon"):GetComponent(Image)
           item.nameTxt = item.transform:Find("Name"):GetComponent(Text)
           item.sliderValTrans = item.transform:Find("Slider/SliderVal")
           item.slidervalTxt = item.transform:Find("Slider/ValText"):GetComponent(Text)
           item.slotList = {}
           for j = 1, 2 do
                item.slotList[j] = {}
                item.slotList[j].gameObject = item.transform:Find("Item" .. j)
           end
           item.btn = item.transform:Find("Button"):GetComponent(Button)
           item.btnImg = item.transform:Find("Button"):GetComponent(Image)
           item.btnTxt = item.transform:Find("Button/Text"):GetComponent(Text)
           item.btnEffect = BaseUtils.ShowEffect(20053, item.btn.transform, Vector3(1.9, 0.75, 1), Vector3(-60, -16, -350))
           item.btnEffect:SetActive(false)
           self.layout:AddCell(item.gameObject)
        end
        local vo = self.model.warOrderQuestData[quest_id]
        self:GetHeadIconSprite(item.headIcon, vo.cfg.icon)
        item.nameTxt.text = vo.name

        -- BaseUtils.dump(vo,"sdgsdgsgds")

        local target = 0
        local target_val = ((vo.progress or {})[1] or {}).target_val or 1

        if target_val == 0 then 
            target_val = 1
        end
        
        if vo.finish == 1 and vo.progress_ser and vo.progress_ser[1] then 
            target = vo.progress_ser[1].value
        elseif vo.finish == 2 then 
            target = target_val
        elseif vo.finish == 3 then 
            target = target_val
        end

        item.sliderValTrans.sizeDelta = Vector2((target / target_val) *248, 16)
        item.slidervalTxt.text = string.format( "%s/%s", target, target_val)

        --Item奖励内容
        local count = 0
        local total = #vo.cfg.rewards
        for j, vv in ipairs(vo.cfg.rewards) do
            local slot = item.slotList[j].slot
            if slot == nil then 
                slot = ItemSlot.New()
                item.slotList[j].slot = slot
            end
            local info = ItemData.New()
            info:SetBase(DataItem.data_get[vv[1]])
            slot:SetAll(info, {inbag = false, nobutton = true})
            slot:SetNum(vv[3])
            NumberpadPanel.AddUIChild(item.slotList[j].gameObject, slot.gameObject)
            count = count + 1
            item.slotList[j].effectFlag = (vv[4] == 1)
            if vv[4] == 1 then 
                if item.slotList[j].effect == nil then 
                    item.slotList[j].effect = BaseUtils.ShowEffect(20223, slot.transform, Vector3.one, Vector3(0, 0, -250))
                end
                item.slotList[j].effect:SetActive(true)
            else
                if item.slotList[j].effect ~= nil then 
                    item.slotList[j].effect:SetActive(false)
                end
            end
        end
        for j = count + 1, total do
            if item.slotList[j] ~= nil then 
                item.slotList[j].gameObject:SetActive(false)
            end
        end

        --按钮状态
        item.btn.onClick:RemoveAllListeners()
        item.btn.onClick:AddListener(function() 
                local questData = QuestManager.Instance:GetQuest(quest_id)
                if questData == nil then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你已经完成了"))
                else
                    if vo.finish == 1 then 
                        WindowManager.Instance:CloseWindowById()
                    end
                    QuestManager.Instance:DoQuest(questData)
                end
            end)
        
        if vo.finish == 1 then 
            item.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            item.btnTxt.text = string.format(ColorHelper.DefaultButton3Str, TI18N("前往"))
            item.btnEffect:SetActive(false)
        elseif vo.finish == 2 then 
            item.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            item.btnTxt.text = string.format(ColorHelper.DefaultButton3Str, TI18N("领取"))
            item.btnEffect:SetActive(true)
        elseif vo.finish == 3 then 
            item.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            item.btnTxt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("已完成"))
            item.btnEffect:SetActive(false)
        end
        self.itemList[i] = item
    end
end


function WarOrderQuestPanel:SetWeekBoxData()
    local week_box_data = DataCampWarOrder.data_week_box[1]
    -- self.rewardIconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.warordertextures, week_box_data.icon or "gift1")
    self.rewardIconImg.sprite = self.assetWrapper:GetSprite(AssetConfig.warordertextures,"gift2")
    -- self.rewardIconImg:SetNativeSize()
    
    if self.model.warOrderData.week_box == 0 then 
        if not self.model:GetHighLevelWarStatus() then 
            self.statusTxt.text = string.format("<color='#906014'>%s</color>", TI18N("未领取"))
            if self.effect ~= nil then
                self.effect:SetActive(false)
            end
            self:Shake(false)
        else
            self.statusTxt.text = TI18N("可领取")
            if self.effect == nil then
                self.effect = BaseUtils.ShowEffect(20121, self.rewardBtn.transform, Vector3.one * 1.5, Vector3(0, 0, -250)) --转圈特效
            end
            self.effect:SetActive(true)
            self:Shake(true)
        end
    elseif self.model.warOrderData.week_box == 1 then 
        self.statusTxt.text = TI18N("已领取")
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
        self:Shake(false)
    end
    self.descTxt.text = week_box_data.desc
end

--跳转至等级购买界面
function WarOrderQuestPanel:OnBuyClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderwindow, {index = 4, campId = self.campId})
end

--经验宝箱点击
function WarOrderQuestPanel:OnRewardClick()
    if self.model:GetHighLevelWarStatus() then 
        self.mgr:Send20487()
    else
        local cdata = NoticeConfirmData.New()
        cdata.type = ConfirmData.Style.Normal
        cdata.content = string.format(TI18N("当前未激活%s,是否前往激活？"), WarOrderConfigHelper.GetOrder(2).name)
        cdata.sureLabel = TI18N("前往激活")
        cdata.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderbuywindow) end
        NoticeManager.Instance:ConfirmTips(cdata)
    end
end

--处理特效
function WarOrderQuestPanel:DealExtraEffect()
    local scrollRect = self.scroll
    local container = scrollRect.content

    local item_list = self.itemList
    local delta1 = -12
    local delta2 = -12

    local a_side = -container.anchoredPosition.y
    local b_side = a_side - scrollRect.transform.sizeDelta.y

    local a_xy, s_xy = 0, 0
    for k, v in pairs(item_list) do
        a_xy = v.gameObject.transform.anchoredPosition.y + delta1
        s_xy = v.gameObject.transform.sizeDelta.y + delta1 + delta2

        if v.slotList ~= nil then
            for __, vv in pairs(v.slotList) do
                if vv.effect ~= nil then 
                    vv.effect:SetActive((a_xy < a_side) and (a_xy - s_xy > b_side) and vv.effectFlag )
                end 
            end
        end
    end
end


function WarOrderQuestPanel:GetHeadIconSprite(img, iconid)
    local sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(iconid))
    if sprite == nil then 
        self.loaders[iconid] = SingleIconLoader.New(img.gameObject)
        self.loaders[iconid]:SetSprite(SingleIconType.Item, tonumber(iconid))
        return
    else
        -- img.sprite = self.assetWrapper:GetSprite(AssetConfig.warordertextures, "pic1")
        img.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(iconid))
        -- img:SetNativeSize()
    end
end

--左右晃动效果
function WarOrderQuestPanel:Shake(bool)
    if self.shakeTimer ~= nil then 
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
    -- Quaternion.Euler
    if bool then 
        self.x = 0
        self.shakeTimer = LuaTimer.Add(0, 1, function()
            self.x = self.x + 36
            self.x = (self.x - 36) % 360 + 36
            local z = math.sin( self.x / 360 * math.pi)
            self.rewardBtn.transform.localRotation = Quaternion.Euler(0, 0, z*3)
        end)
    end
end

--重写show，hiden方法,创建太多item，优化卡顿
function WarOrderQuestPanel:Show(arge)
    if self.loading then
        return
    end
    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self.gameObject.transform.localScale = Vector3(1, 1, 1)
        -- self.gameObject:SetActive(true)
        if self.scroll ~= nil then
            self.scroll.enabled = true
        end
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function WarOrderQuestPanel:Hiden()
    if self.gameObject ~= nil then
        if self.scroll ~= nil then
            self.scroll.enabled = false
        end
        self.gameObject.transform.localScale = Vector3(0, 0, 0)
        -- self.gameObject:SetActive(false)
        self.OnHideEvent:Fire()
    end
end





