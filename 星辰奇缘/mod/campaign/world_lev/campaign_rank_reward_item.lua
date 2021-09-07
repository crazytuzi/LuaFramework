-- region *.lua
-- Date jia 2017-5-16
-- 此文件由[BabeLua]插件自动生成
-- 活动排行榜奖励item
-- endregion
CampaignRankRewardItem = CampaignRankRewardItem or BaseClass()
function CampaignRankRewardItem:__init(origin_item, _index, isRnak, rankType)
    self.index = _index
    self.isRank = isRnak
    self.rankType = rankType
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
        WorldLevManager.Instance:Send17861(self.rankType, self.tmpData.num)
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
    self.CampaignData = nil
    self.effect = nil

    self.TxtDesc.gameObject:SetActive(self.isRank)
    self.SliderTra.gameObject:SetActive(not self.isRank)
    self.isShowEffect = false


end

function CampaignRankRewardItem:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
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

function CampaignRankRewardItem:SetData(data)
    self.tmpData = data
    if self.tmpData == nil then
        return
    end
    self:SetPosAndOther()
    if self.isRank then
        self.TxtCondition.text = self.tmpData.reward_title
    else
        self.TxtCondition.text = self:GetTitleDesc(self.tmpData.num)
    end

    local tmprewards = self.tmpData.item_list
    local rewards = { }
    for _, item in pairs(tmprewards) do
        if self:CheckItemsByCondition(item) then
            table.insert(rewards, item)
        end
    end
    local index = 0;
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
    end
    self.setting.column = #rewards
    self.Layout = LuaGridLayout.New(self.ConRewards, self.setting)
    local tbItem = nil
    if self.CampaignData ~= nil then
        local tbStr = self.CampaignData.cond_desc

        if tbStr ~= nil and tbStr ~= "" then
            local tb = BaseUtils.unserialize(tbStr)
            tbItem = { }
            for kx, vx in pairs(tb) do
                tbItem[vx] = kx
            end
        end
    end
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
        if (tbItem ~= nil and tbItem[reward[1]] ~= nil) or (reward[4] == 1) then
            slot:ShowEffect(true, 20223)
        end
        self.itemslots[index] = slot
        self.Layout:AddCell(slot.gameObject)
    end
    self:UpdatePersonalData()
end

function CampaignRankRewardItem:UpdatePersonalData()
    if self.isRank or self.tmpData == nil then
        return
    end
    local myIntimacy = WorldLevManager.Instance:GetMyValueByType(self.rankType)
    if self.tmpData ~= nil then
        local curTmpValue = self.tmpData.num;
        local scale = myIntimacy / curTmpValue
        self.SliderTra.gameObject:SetActive(scale < 1)
        self.Slider.value = scale
        self.TxtSld.text = string.format("%s/%s", myIntimacy, curTmpValue)
        local isGet = WorldLevManager.Instance:CheckIsGetRewardByType(self.rankType, curTmpValue);
        self.BtnReward.gameObject:SetActive(false)
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
        self.Result.gameObject:SetActive(false)
        self.isShowEffect = false
        if scale >= 1 then
            if not isGet then
                self.BtnReward.gameObject:SetActive(true)
                if self.effect == nil then
                    self.effect = BibleRewardPanel.ShowEffect(20118,self.BtnReward.transform, Vector3(0.75, 0.75, 1), Vector3(-38, 20, -400))

                else
                    self.effect:SetActive(true)
                end
                self.isShowEffect = true
            else

                self.Result.gameObject:SetActive(true)
            end
        end
    end
end

function CampaignRankRewardItem:SetPosAndOther()
    if self.rankType == CampaignEumn.CampaignRankType.ConSume then
        self.TxtCondition.transform.anchoredPosition = Vector2(200,12)
        self.TxtDesc.transform.anchoredPosition = Vector2(200,-12)
        self.ConRewards.transform.anchoredPosition = Vector2(123,-44)
        self.TxtCondition.gameObject:SetActive(self.isRank)
    else
        self.TxtCondition.transform.anchoredPosition = Vector2(-197.5,0)
        self.TxtDesc.transform.anchoredPosition = Vector2(200,0)
        self.ConRewards.transform.anchoredPosition = Vector2(295,-44)
    end
end

function CampaignRankRewardItem:GetTitleDesc(num)
    local str = nil
    if self.rankType == CampaignEumn.CampaignRankType.Constellation then
        str = string.format(TI18N("<color=#ffff00''>%s</color>积分可领"), num)
    elseif self.rankType == CampaignEumn.CampaignRankType.Intimacy then
        str = string.format(TI18N("<color=#ffff00''>%s</color>亲密度可领"), num)
    elseif self.rankType == CampaignEumn.CampaignRankType.Pet then
        str = string.format(TI18N("<color=#ffff00''>%s</color>评分可领"), num)
    elseif self.rankType == CampaignEumn.CampaignRankType.PlayerKill then
        str = string.format(TI18N("达到<color=#ffff00''>%s</color>可领"), DataRencounter.data_info[num].title)
    elseif self.rankType == CampaignEumn.CampaignRankType.Weapon then
        str = string.format(TI18N("<color=#ffff00''>%s</color>评分可领"), num)
    elseif self.rankType == CampaignEumn.CampaignRankType.WorldChampion then
        str = string.format(TI18N("达到%s可领"), DataTournament.data_list[num].name)
    elseif self.rankType == CampaignEumn.CampaignRankType.Wing then
        str = string.format(TI18N("<color=#ffff00''>%s</color>翅膀评分可领"), num)
    elseif self.rankType == CampaignEumn.CampaignRankType.ConSume then
        str = string.format(TI18N("<color=#ffff00''>%s</color>消费额可领"), num)
    else
        str = string.format(TI18N("<color=#ffff00''>%s</color>分数可领"), num)
    end
    return str
end

function CampaignRankRewardItem:ShowEffect(isShow)
    for _, slot in ipairs(self.itemslots) do
        if slot.effect ~= nil then
            slot.effect:SetActive(isShow)
        end
    end

    if self.effect ~= nil then
        if isShow == true and self.isShowEffect == true then
         self.effect:SetActive(isShow)
        elseif isShow == false then
            self.effect:SetActive(isShow)
        end
    end
end

function CampaignRankRewardItem:CheckItemsByCondition(tmpdata)
    local roleData = RoleManager.Instance.RoleData
    if --(tmpdata[] == roleData.classes or tmpdata[4] == 0 or tmpdata[4] == nil)
        --        and(tmpdata.sex == roleData.sex or tmpdata.sex == 2)
               (tmpdata[5] == nil or tmpdata[5] <= roleData.lev)
               and(tmpdata[6] == nil or tmpdata[6] >= roleData.lev)
        --        and(tmpdata.min_lev_break <= roleData.lev_break_times or tmpdata.min_lev_break == 0)
        --        and(tmpdata.max_lev_break >= roleData.lev_break_times or tmpdata.max_lev_break == 0)
    then
        return true
    end
    return false
end