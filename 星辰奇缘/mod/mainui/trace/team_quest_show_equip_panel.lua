-- 作者:jia
-- 5/18/2017 5:58:29 PM
-- 功能:新手任务奖励展示装备面板

TeamQuestShowEquipPanel = TeamQuestShowEquipPanel or BaseClass(BasePanel)
function TeamQuestShowEquipPanel:__init(model, questid)
    self.questid = questid
    self.model = model
    self.ShowData = DataQuest.data_show_reward[self.questid]
    self.myEquipId = self:GetMyEquipid(self.ShowData)
    self.resList = {
        { file = AssetConfig.teamquestshowequippanel, type = AssetType.Main }
        ,{ file = AssetConfig.teamquest, type = AssetType.Dep }
        ,{ file = string.format(AssetConfig.effect, 20209), type = AssetType.Main }
    }
    -- self.OnOpenEvent:Add(function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.PosTxt = { "武器", "衣服", "腰带", "裤子", "鞋子", "戒指", "项链", "手镯" }
    -- 装备的pos转换到当前界面的pos
    self.PosChange = { 1, 6, 7, 8, 2, 3, 4, 5 }

    self.hasInit = false
    self.ItemList = { }
    self.timerID = nil
    self.scaleID = nil
    self.tweenID = nil
    self.slot = nil
    self.tweenSlot = nil
    self.scaleSlot = nil
    self.staySlot = nil
    self.isEquip = false
    self.ErrorTimer = nil
    self.backpackPos = Vector3(370, -230, 0)
    self.flyTime = 0.3
end

function TeamQuestShowEquipPanel:__delete()
    if not self.isEquip then
        local itemData = BackpackManager.Instance:GetItemByBaseid(self.myEquipId)[1]
        if itemData ~= nil then
            BackpackManager.Instance:SpecialUseEuip(itemData.id, itemData.quantity, itemData.base_id)
            self.isEquip = true
        end
    end
    self:CancelRotate()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.timerID ~= nil then
        LuaTimer.Delete(self.timerID)
        self.timerID = nil
    end
    if self.ErrorTimer ~= nil then
        LuaTimer.Delete(self.ErrorTimer)
        self.ErrorTimer = nil
    end
    if self.tweenSlot ~= nil then
        Tween.Instance:Cancel(self.tweenSlot)
        self.tweenSlot = nil
    end
    if self.staySlot ~= nil then
        LuaTimer.Delete(self.staySlot)
        self.staySlot = nil
    end
    if self.scaleSlot ~= nil then
        Tween.Instance:Cancel(self.scaleSlot)
        self.scaleSlot = nil
    end
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    if self.tweenID ~= nil then
        Tween.Instance:Cancel(self.tweenID)
        self.tweenID = nil
    end
    if self.doOpenTimer ~= nil then
        LuaTimer.Delete(self.doOpenTimer)
        self.doOpenTimer = nil
    end
    if self.ItemList ~= nil then
        for _, item in pairs(self.ItemList) do
            item:DeleteMe()
            item = nil
        end
        self.ItemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TeamQuestShowEquipPanel:OnHide()

end

function TeamQuestShowEquipPanel:OnOpen()

end

function TeamQuestShowEquipPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamquestshowequippanel))
    self.gameObject.name = "TeamQuestShowEquipPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.Panel = self.transform:Find("Panel"):GetComponent(Button)
    self.Panel.onClick:AddListener(
    function()
        -- self:ClosePanel()
    end )
    self.Close = self.transform:Find("Content/Close"):GetComponent(Button)
    self.Close.onClick:AddListener(
    function()
        self:ClosePanel()
    end )
    self.Content = self.transform:Find("Content")
    self.Content.localScale = Vector3.zero
    self.Content.localPosition = self.backpackPos

    self.ShowCon = self.transform:Find("Content/ShowCon")
    self.ShowSlot = self.transform:Find("ShowSlot")
    self.ShowSlot.localPosition = Vector3.zero

    self.SlotCon = self.transform:Find("ShowSlot/SlotCon")
    self.ImgQuality = self.transform:Find("ShowSlot/ImgQuality"):GetComponent(Image)

    self.ShowSlot.gameObject:SetActive(false)
    self.ShowItem = self.transform:Find("Content/ShowCon/ShowItem").gameObject
    self.ShowItem:SetActive(false)

    self.rotationBg = self.transform:Find("rotationBg")
    self.rotationBg.gameObject:SetActive(false)
    self.rotationBg.localPosition = Vector3.zero
    for index = 1, 8 do
        local item = TeamQuestShowEquipItem.New(self.ShowItem, index);
        item.TxtPos.text = self.PosTxt[index]
        table.insert(self.ItemList, item)
    end
    self:InitEquip()
    -- 容错倒计时  防止位置情况导致界面卡住无法关闭 自动关闭界面
    if self.ErrorTimer ~= nil then
        LuaTimer.Delete(self.ErrorTimer)
        self.ErrorTimer = nil
    end
    self.ErrorTimer = LuaTimer.Add(5000,
    function()
        self.model:CloseShowEquipPanel()
    end )
end

function TeamQuestShowEquipPanel:ClosePanel()
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    if self.tweenID ~= nil then
        Tween.Instance:Cancel(self.tweenID)
        self.tweenID = nil
    end
    self.tweenID = Tween.Instance:MoveLocal(self.Content.gameObject, self.backpackPos, self.flyTime + 0.2,
    function()
        if self.tweenID ~= nil then
            Tween.Instance:Cancel(self.tweenID)
            self.tweenID = nil
        end
        self.model:CloseShowEquipPanel()
    end , LeanTweenType.linear).id
    self.scaleID = Tween.Instance:Scale(self.Content.gameObject, Vector3.zero, self.flyTime + 0.2,
    function()
        if self.scaleID ~= nil then
            Tween.Instance:Cancel(self.scaleID)
            self.scaleID = nil
        end
    end , LeanTweenType.linear).id
end

function TeamQuestShowEquipPanel:InitEquip()
    local myEquip = BackpackManager.Instance.equipDic
    for _, equip in pairs(myEquip) do
        if equip.base_id ~= self.myEquipId then
            local curPos = self.PosChange[equip.pos];
            local item = self.ItemList[curPos]
            if item ~= nil then
                if self.myEquipId ~= equip.base_id and self:CheckIsMatch(curPos, equip.base_id) then
                    item:SetData(equip)
                else
                    item:SetData(nil)
                end
            end
        end
    end
    self:InitFlyItem();
    self:StartRotate()
    if self.doOpenTimer ~= nil then
        LuaTimer.Delete(self.doOpenTimer)
        self.doOpenTimer = nil
    end
    self.doOpenTimer = LuaTimer.Add(1000,
    function()
        self:DoOpenPanel()
        if self.doOpenTimer ~= nil then
            LuaTimer.Delete(self.doOpenTimer)
            self.doOpenTimer = nil
        end
    end )
end

function TeamQuestShowEquipPanel:DoOpenPanel()
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    if self.tweenID ~= nil then
        Tween.Instance:Cancel(self.tweenID)
        self.tweenID = nil
    end

--    self.Content.localPosition = Vector3(-15, -130, 0)
--    self.Content.localScale = Vector3.one

        self.tweenID = Tween.Instance:MoveLocal(self.Content.gameObject, Vector3(-15, -130, 0), self.flyTime,
        function()
            if self.tweenID ~= nil then
                Tween.Instance:Cancel(self.tweenID)
                self.tweenID = nil
            end
        end , LeanTweenType.linear).id
        self.scaleID = Tween.Instance:Scale(self.Content.gameObject, Vector3.one, self.flyTime,
        function()
            if self.scaleID ~= nil then
                Tween.Instance:Cancel(self.scaleID)
                self.scaleID = nil
            end

        end , LeanTweenType.linear).id
end

function TeamQuestShowEquipPanel:CheckIsMatch(pos, baseid)
    local showDatas = DataQuest.data_show_reward;
    local showData = nil;
    if showDatas ~= nil then
        for _, data in pairs(showDatas) do
            if data.pos == pos then
                showData = data
                break
            end
        end
        if showData ~= nil then
            if self:GetMyEquipid(showData) == baseid then
                return true
            end
        end
    end
    return false
end

function TeamQuestShowEquipPanel:InitFlyItem()
    self.ShowSlot.gameObject:SetActive(true)
    if self.slot == nil then
        self.slot = ItemSlot.New()
    end
    local showEquip = BackpackManager.Instance:GetItemBase(self.myEquipId);
    local extra = { nobutton = true };
    self.slot:SetAll(showEquip, extra)
    self.slot.itemImgRect.sizeDelta = Vector2.one * 53
    UIUtils.AddUIChild(self.SlotCon.gameObject, self.slot.gameObject)
    self.slot.localScale = Vector3.one
    self.slot.localPosition = Vector3.zero
    self.ShowSlot.localScale = Vector3.zero
    if showEquip.quality > 2 then
        self.ImgQuality.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item%s", showEquip.quality + 1))
    end
    if self.scaleSlot ~= nil then
        Tween.Instance:Cancel(self.scaleSlot)
    end
    self.scaleSlot = Tween.Instance:Scale(self.ShowSlot.gameObject, Vector3.one, self.flyTime,
    function()
        if self.scaleSlot ~= nil then
            Tween.Instance:Cancel(self.scaleSlot)
            self.scaleSlot = nil
        end
        if self.staySlot ~= nil then
            LuaTimer.Delete(self.staySlot)
        end
        self.staySlot = LuaTimer.Add(1300,
        function()
            if self.staySlot ~= nil then
                LuaTimer.Delete(self.staySlot)
                self.staySlot = nil
            end
            self:DoFlySlot()
        end )
    end , LeanTweenType.linear).id
end

function TeamQuestShowEquipPanel:StartRotate()
    self.rotationBg.gameObject:SetActive(true)
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
    end
    self.rotationTweenId = Tween.Instance:ValueChange(0, 360, 4,
    function()
        if self.rotationTweenId ~= nil then
            Tween.Instance:Cancel(self.rotationTweenId)
            self.rotationTweenId = nil
        end
        self:RotationShowBg()
    end , LeanTweenType.Linear,
    function(value)
        self.rotationBg.localRotation = Quaternion.Euler(0, 0, value)
    end ).id
end

function TeamQuestShowEquipPanel:CancelRotate()
    self.rotationBg.gameObject:SetActive(false)
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
    end
end

function TeamQuestShowEquipPanel:DoFlySlot()
    self:CancelRotate()
    local showItem = self.ItemList[self.ShowData.pos];
    if showItem ~= nil then
        self.ShowSlot.gameObject:SetActive(true)
        local index = self.ShowData.pos
        if self.tweenSlot ~= nil then
            Tween.Instance:Cancel(self.tweenSlot)
        end
        self.tweenSlot = Tween.Instance:MoveLocal(self.ShowSlot.gameObject, Vector3((index - 1) * 55 - 208, -135, 0), 0.5,
        function()
            if self.tweenSlot ~= nil then
                Tween.Instance:Cancel(self.tweenSlot)
                self.tweenSlot = nil
            end
            if self.effect20209 == nil then
                self.effect20209 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20209)))
                self.effect20209.transform:SetParent(self.ShowSlot)
                self.effect20209.transform.localRotation = Quaternion.identity
                Utils.ChangeLayersRecursively(self.effect20209.transform, "UI")
                self.effect20209.transform.localScale = Vector3(1, 1, 1)
            end
            self.effect20209.transform.localPosition = Vector3(0, 0, -400)
            local itemData = BackpackManager.Instance:GetItemByBaseid(self.myEquipId)[1]
            if itemData ~= nil then
                BackpackManager.Instance:SpecialUseEuip(itemData.id, itemData.quantity, itemData.base_id)
                self.isEquip = true
            end
            self:InitCloseTimer()
        end , LeanTweenType.linear).id
    end
end

function TeamQuestShowEquipPanel:InitCloseTimer()
    if self.timerID ~= nil then
        LuaTimer.Delete(self.timerID)
    end
    self.timerID = LuaTimer.Add(1000,
    function()
        local showItem = self.ItemList[self.ShowData.pos];
        local itemData = BackpackManager.Instance:GetItemBase(self.myEquipId)
        showItem:SetData(itemData)
        self.ShowSlot.gameObject:SetActive(false)
        self:ClosePanel()
    end )
end

function TeamQuestShowEquipPanel:GetMyEquipid(showData)
    local roleData = RoleManager.Instance.RoleData
    for _, item in pairs(showData.reward) do
        if (item[2] == roleData.sex or item[2] == 2) and(item[1] == roleData.classes or item[1] == 0) then
            return item[3]
        end
    end
    return 0
end