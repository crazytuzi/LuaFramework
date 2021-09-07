-- region *.lua
-- Date jia 2017-5-16
-- 此文件由[BabeLua]插件自动生成
-- 亲密度排行榜奖励item
-- endregion
IntiMacyRewardItem = IntiMacyRewardItem or BaseClass()
function IntiMacyRewardItem:__init(origin_item, _index, isRnak)
    self.index = _index
    self.isRank = isRnak
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.TxtCondition = self.transform:Find("TxtCondition"):GetComponent(Text)
    self.ConRewards = self.transform:Find("ConRewards")
    self.TxtDesc = self.transform:Find("TxtDesc"):GetComponent(Text)

    self.SliderTra = self.transform:Find("Slider")
    self.TxtSld = self.transform:Find("Slider/TxtSld"):GetComponent(Text)
    self.Slider = self.transform:Find("Slider/Slider"):GetComponent(Slider)
    self.BtnReward = self.transform:Find("BtnReward"):GetComponent(Button)
    self.BtnReward.onClick:AddListener(
    function()
        if self.tmpData == nil then
            return
        end
        IntimacyManager.Instance:Send17861(self.tmpData.num)
    end )

    self.Result = self.transform:Find("Result")
    self.setting = {
        column = 3
        ,
        cspacing = 10
        ,
        rspacing = 10
        ,
        cellSizeX = 60
        ,
        cellSizeY = 60,
    }
    local newY = -(self.index - 1) * 85
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)

    self.hasInit = false
    self.itemslots = { }
    self.tmpData = nil
    self.signRewardEffect = nil

    self.TxtDesc.gameObject:SetActive(self.isRank)
    self.SliderTra.gameObject:SetActive(not self.isRank)

end

function IntiMacyRewardItem:__delete()


    if self.signRewardEffect ~= nil then
      self.signRewardEffect:DeleteMe()
      self.signRewardEffect = nil
    end
    if self.itemslots ~= nil then
        for _, slot in pairs(self.itemslots) do
            slot:DeleteMe()
            slot = nil
        end
        self.itemslots = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function IntiMacyRewardItem:SetData(data)
    self.tmpData = data
    if self.tmpData == nil then
        return
    end
    if self.isRank then
        self.TxtCondition.text = self.tmpData.reward_title

    else
        self.TxtCondition.text = string.format(TI18N("<color=#ffff00''>%s</color>亲密可领"), self.tmpData.num)
    end

    local rewards = self.tmpData.item_list
    local index = 0;
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
    end
    self.setting.column = #rewards
    self.Layout = LuaGridLayout.New(self.ConRewards, self.setting)
    for _, reward in pairs(rewards) do
        index = index + 1
        local slot = self.itemslots[index];
        if slot == nil then
            slot = ItemSlot.New()
        end
        local item = BackpackManager.Instance:GetItemBase(reward[1])
        item.quantity = reward[3]
        item.isbind = reward[2] == 1
        item.show_num = true
        local extra = { inbag = false, noqualitybg = false, nobutton = true }
        slot:SetAll(item, extra)
        self.itemslots[index] = slot
        self.Layout:AddCell(slot.gameObject)
    end
    self:UpdatePersonalData()
end
---
function IntiMacyRewardItem:UpdatePersonalData()
    if self.isRank or self.tmpData == nil then
        return
    end
    local myIntimacy = IntimacyManager.Instance:GetMyIntimacy();
    local curTmpValue = self.tmpData.num;
    local scale = myIntimacy / curTmpValue
    self.SliderTra.gameObject:SetActive(scale < 1)
    self.Slider.value = scale
    self.TxtSld.text = string.format("%s/%s", myIntimacy, curTmpValue)
    local isGet = IntimacyManager.Instance:CheckIsGetReward(curTmpValue);
    self.BtnReward.gameObject:SetActive(false)
    self.Result.gameObject:SetActive(false)
    if scale >= 1 then
        if not isGet then
            self.BtnReward.gameObject:SetActive(true)
            if self.signRewardEffect == nil then
                self.signRewardEffect = BibleRewardPanel.ShowEffect(20053,self.BtnReward.transform,Vector3(1.4, 0.6, 1),Vector3(-46, -12.1, -400))
            end
            self.signRewardEffect:SetActive(true)

        else
            if self.signRewardEffect ~= nil then
                self.signRewardEffect:SetActive(false)
            end
            self.Result.gameObject:SetActive(true)
        end
    end
end
