--星辰乐园南瓜
--2017/03/01
--zzl


StarParkPumpkinPanel = StarParkPumpkinPanel or BaseClass(BasePanel)

function StarParkPumpkinPanel:__init(parent, bgPath)
    self.parent = parent
    self.model = parent.model
    self.bgPath = bgPath
    self.resList = {
        {file = AssetConfig.starpark_pumpkin_panel, type = AssetType.Main}
        ,{file = self.bgPath, type = AssetType.Main}
    }
    self.has_init = false
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function()end)

    self.bottomSlotList = nil
    return self
end

function StarParkPumpkinPanel:__delete()
    if self.bottomSlotList ~= nil then
        for k, v in pairs(self.bottomSlotList) do
            v:DeleteMe()
        end
    end

    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function StarParkPumpkinPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starpark_pumpkin_panel))
    self.gameObject.name = "StarParkPumpkinPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.RightCon, self.gameObject)

    self.ImgBg = self.transform:FindChild("ImgBg")
    UIUtils.AddBigbg(self.ImgBg, GameObject.Instantiate(self:GetPrefab(self.bgPath)))
    self.ImgBg.gameObject:SetActive(true)

    self.TopCon = self.transform:FindChild("TopCon")
    self.TxtDesc = self.TopCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.ImgShopBtn = self.TopCon.transform:FindChild("ImgShopBtn"):GetComponent(Button)

    self.BottomCon = self.transform:FindChild("BottomCon")
    self.MaskCon = self.BottomCon:FindChild("MaskCon")
    self.ScollLayer = self.MaskCon:FindChild("ScollLayer")
    self.Container = self.ScollLayer:FindChild("Container")
    self.SlotCon = self.Container:FindChild("SlotCon")

    self.BtnJoin = self.BottomCon:FindChild("BtnJoin"):GetComponent(Button)
    self.BtnJoinText = self.BottomCon:FindChild("BtnJoin/Text"):GetComponent(Text)
    self.TxtNum = self.BottomCon:FindChild("TxtNum"):GetComponent(Text)
    self.TipsButton = self.BottomCon:FindChild("TipsButton"):GetComponent(Button)

    self.ImgShopBtn.onClick:AddListener(function()
        self:OpenShop()
    end)

    self.BtnJoin.onClick:AddListener(function()
        self:Join()
    end)

    self.TipsButton.onClick:AddListener(function()
        self:ShowTips()
    end)

    self.TxtNum.text = ""

    self:OnOpen()
end

function StarParkPumpkinPanel:OnOpen()
    self.starParkData = self.model.leftBtnList[self.parent.lastSelectedId]
    if self.starParkData == nil then
        return
    end

    self:Update()
end

function StarParkPumpkinPanel:Update()
    local agendaData = DataAgenda.data_list[self.starParkData.agendaId]

    local text1 = string.format(TI18N("等级需求：%s级"), agendaData.open_leve)
    local text2 = TI18N("开启时间：<color='#ffff00'>")

    -- print("dskjfksdjfklsdjfkljslk1")
    for i=1, #agendaData.args do
        if i > 1 then
            if agendaData.args[i] == 7 then
                text2 = string.format(TI18N("%s、周%s"), text2, "日")
            else
                text2 = string.format(TI18N("%s、周%s"), text2, BaseUtils.NumToChn(agendaData.args[i]))
            end
        else
            if agendaData.args[i] == 7 then
                text2 = string.format(TI18N("%s周%s"), text2, "日")
            else
                text2 = string.format(TI18N("%s周%s"), text2, BaseUtils.NumToChn(agendaData.args[i]))
            end
        end
    end
    self.TxtDesc.text = string.format("%s\n%s\n                   %s</color>", text1, text2, agendaData.time)

    local agenda_list = AgendaManager.Instance.agenda_list
    local agenda_data = nil
    for i=1, #agenda_list do
        if agenda_list[i].id == self.starParkData.agendaId then
            agenda_data = agenda_list[i]
            break
        end
    end
    if agenda_data == nil then
        self.TxtNum.text = ""
    elseif agenda_data.max_try == agenda_data.engaged then
        -- self.TxtNum.text = string.format("剩余：<color='#ff0000'>%s</color>/%s", 0, agenda_data.max_try)
        self.TxtNum.text = string.format("剩余：<color='#ff0000'>%s</color>/%s", 0, agenda_data.max_try)
    else
        self.TxtNum.text = string.format("剩余：<color='#00ff00'>%s</color>/%s", agenda_data.max_try - agenda_data.engaged, agenda_data.max_try)
    end
    self.agenda_data = agenda_data

    self:ShowJoinButton()
    self:UpdateReward()
end

function StarParkPumpkinPanel:UpdateReward()
    local dataList = DataAgenda.data_list[self.starParkData.agendaId].reward
    local newWidth = #dataList*80
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(newWidth, 70)

    if #dataList > 0 then
        if self.bottomSlotList == nil then
            self.bottomSlotList = {}
        end
        for i = 1, #dataList do
            local baseId = dataList[i].key
            local num = dataList[i].val
            local slot = self.bottomSlotList[i]
            if slot == nil then
                slot = self:CreateSlot(i)
                table.insert(self.bottomSlotList, slot)
            end
            self:SetSlotData(slot, baseId, num)
        end
    end
end

function StarParkPumpkinPanel:CreateSlot(index)
    local slot_con = GameObject.Instantiate(self.SlotCon)
    slot_con:SetParent(self.SlotCon.transform.parent)
    slot_con.localScale = Vector3.one
    local newX = (index - 1)*70
    slot_con:GetComponent(RectTransform).anchoredPosition = Vector2(newX, 0)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function StarParkPumpkinPanel:SetSlotData(slot, base_id, num)
    local cell = ItemData.New()
    local itemData = DataItem.data_get[base_id] --设置数据
    cell:SetBase(itemData)
    cell.quantity = num
    slot:SetAll(cell, nil)
    -- slot:SetNotips(true)
end

function StarParkPumpkinPanel:OpenShop()
    self.model:OpenShop()
end

function StarParkPumpkinPanel:Join()
    if self.agenda_data ~= nil and self.agenda_data.max_try == self.agenda_data.engaged then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s参与次数超过%s次，无法参与活动"), RoleManager.Instance.RoleData.name, self.agenda_data.max_try))
    else
        if self.starParkData.agendaId == 2101 then
            if MatchManager.Instance.statusList[1000] == nil or MatchManager.Instance.statusList[1000] == 0 then
                NoticeManager.Instance:FloatTipsByString("活动尚未开启，敬请期待！{face_1, 3}")
            else
                StarParkManager.Instance.model:CloseStarParkMainUI()
                MatchManager.Instance:Require18301(1000)
            end
        elseif self.starParkData.agendaId == 2102 then
            if HalloweenManager.Instance.model.status == 0 then
                NoticeManager.Instance:FloatTipsByString("活动尚未开启，敬请期待！{face_1, 3}")
            elseif RoleManager.Instance.RoleData.lev < 50 then
                NoticeManager.Instance:FloatTipsByString("50级才能参加该活动,努力升级吧{face_1,18}{face_1,18}{face_1,18}")
            else
                StarParkManager.Instance.model:CloseStarParkMainUI()
                HalloweenManager.Instance.model:GoCheckIn()
            end
        elseif self.starParkData.agendaId == 2104 then
            if AnimalChessManager.Instance.status == AnimalChessEumn.Status.Close then
                NoticeManager.Instance:FloatTipsByString("活动尚未开启，敬请期待！{face_1, 3}")
            else
                StarParkManager.Instance.model:CloseStarParkMainUI()
                QuestManager.Instance.model:FindNpc("34_1")
            end
        elseif self.starParkData.agendaId == 2105 then
            if DragonPhoenixChessManager.Instance.status == DragonChessEumn.Status.Close then
                NoticeManager.Instance:FloatTipsByString("活动尚未开启，敬请期待！{face_1, 3}")
            else
                StarParkManager.Instance.model:CloseStarParkMainUI()
                QuestManager.Instance.model:FindNpc("3_1")
            end
        end
    end
end

function StarParkPumpkinPanel:ShowTips()
    TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = self.starParkData.tips})
end

function StarParkPumpkinPanel:ShowJoinButton()
    if self.agenda_data == nil or self.agenda_data.max_try == self.agenda_data.engaged then
    else
        -- if self.starParkData.agendaId == 2101 then
        --     if MatchManager.Instance.statusList[1000] == 0 then
        --         self.BtnJoinText.text = TI18N("未开启")
        --         self.BtnJoinText.color = ColorHelper.DefaultButton4
        --         self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        --         self.TxtNum.gameObject:SetActive(false)
        --     else
        --         self.BtnJoinText.text = TI18N("参 加")
        --         self.BtnJoinText.color = ColorHelper.DefaultButton3
        --         self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        --         self.TxtNum.gameObject:SetActive()
        --     end
        -- elseif self.starParkData.agendaId == 2102 then
        --     if HalloweenManager.Instance.model.status == 0 then
        --         self.BtnJoinText.text = TI18N("未开启")
        --         self.BtnJoinText.color = ColorHelper.DefaultButton4
        --         self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        --         self.TxtNum.gameObject:SetActive(false)
        --     else
        --         self.BtnJoinText.text = TI18N("参 加")
        --         self.BtnJoinText.color = ColorHelper.DefaultButton3
        --         self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        --         self.TxtNum.gameObject:SetActive(true)
        --     end
        -- end
        if self.model:GetActivityState(self.starParkData.agendaId) then
            self.BtnJoinText.text = TI18N("参 加")
            self.BtnJoinText.color = ColorHelper.DefaultButton3
            self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.TxtNum.gameObject:SetActive(true)
        else
            self.BtnJoinText.text = TI18N("未开启")
            self.BtnJoinText.color = ColorHelper.DefaultButton4
            self.BtnJoin.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.TxtNum.gameObject:SetActive(false)
        end
    end
end
