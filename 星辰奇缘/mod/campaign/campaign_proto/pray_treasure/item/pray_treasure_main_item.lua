-- @author hze
-- @date #2019/09/19#
-- 祈愿宝阁mainItem

PrayTreasureMainItem = PrayTreasureMainItem or BaseClass()

function PrayTreasureMainItem:__init(model, gameObject)
    self.model = model

    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.__active = self.gameObject.activeSelf

    self:InitPanel()
end

function PrayTreasureMainItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end

    if self.effect then 
        self.effect:DeleteMe()
    end

    if self.endEffect ~= nil then
        self.endEffect:DeleteMe()
    end

end

function PrayTreasureMainItem:InitPanel()
    self.slot = ItemSlot.New()
    self:Default()
    self.slotTrans = self.transform:Find("Slot")
    UIUtils.AddUIChild(self.slotTrans.gameObject, self.slot.gameObject)
    self.btn = self.slotTrans:GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function PrayTreasureMainItem:SetData(dat, index)
    -- BaseUtils.dump(self.data)
    if dat then
        self.data = DataCampPray.data_reward[dat.id]
        local itemVo = ItemData.New()
        itemVo:SetBase(DataItem.data_get[self.data.item_id])
        self.slot:SetAll(itemVo, {nobutton = true})
        self.slot:SetNum(self.data.count)
        self.slot:ShowAddBtn(false)
        self.slot:ShowEffect(self.data.is_eff == 1, 20138)
    else
        self:Default()
    end
end

function PrayTreasureMainItem:Default()
    if self.slot then
        self.slot:ShowAddBtn(true)
        self.slot:SetNotips()
        self.slot:SetAddCallback(nil)
        self.slot:ShowEffect(false)
    end
    self.data = nil
end

function PrayTreasureMainItem:OnClick()
    if self.data then 
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[self.data.item_id])
        TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = itemData, extra = {nobutton = true}})
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.praytreasurewindow, {campId = self.model.prayTreasure_campId, index = 3})
    end
end

function PrayTreasureMainItem:SetActive(bool)
    if bool ~= self._active then
        self.gameObject:SetActive(bool)
        self._active = bool
    end
end

function PrayTreasureMainItem:ShowEffect(bool)
    if bool then
        if self.effect == nil then
            self.effect = BaseUtils.ShowEffect(20527, self.slotTrans, Vector3.one, Vector3(0,0,-55))
        end
        self.effect:SetActive(true)
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function PrayTreasureMainItem:ShowEndEffect(bool)
    if bool then
        if self.endEffect == nil then
            self.endEffect = BaseUtils.ShowEffect(20528, self.slotTrans, Vector3.one, Vector3(0,0,-55))
        end
        self.endEffect:SetActive(false)
        self.endEffect:SetActive(true)
    else
        if self.endEffect ~= nil then
            self.endEffect:SetActive(false)
        end
    end
end




