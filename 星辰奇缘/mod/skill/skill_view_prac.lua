-- ----------------------------------------------------------
-- UI - 冒险技能
-- ----------------------------------------------------------
SkillView_Prac = SkillView_Prac or BaseClass(BasePanel)

function SkillView_Prac:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "SkillView_Prac"
    self.resList = {
        {file = AssetConfig.skill_window_prac, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
	self.skillmatrix = nil
	self.skillinfo = nil

	self.iconlist = {}
	self.imagelist = {}
	self.namelist = {}
	self.levellist = {}
    self.labellist = {}
    self.enhanceLevlist = {}
    self.recommendlist = {}

	self.selectbtn = nil
	self.skilldata = nil
	self.select_skilldata = nil

	self.toggle = nil
	self.select_mark = nil
    self.last_skill_id = nil

    self.itemSolt = nil
    self.itemData = nil
    self.itemSolt_RedPoint = nil

    self.dropList = {}
    self.dropDataList = {
        {times = 1},
        {times = 20},
        {times = 50},
    }

    ------------------------------------------------
    self._updateSkillItem = function()
        self:updateSkillItem()
    end
    self._role_assets_change = function()
        self:role_assets_change()
    end
    self._update_item = function()
        self:update_item()
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.guide = function() self:CheckGuide() end
    self.oneTimeBtn = nil
    self.useItemBtn = nil
end

function SkillView_Prac:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_window_prac))
    self.gameObject.name = "SkillView_Prac"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
	self.skillmatrix = transform:FindChild("SkillList").gameObject
    self.skillinfo = transform:FindChild("SkillPracInfo").gameObject
    self.skillinfo.transform:FindChild("CostItem/NumText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)
    self.skillinfo.transform:FindChild("OwnItem/NumText"):GetComponent(Text).color = Color(232/255, 250/255, 255/255, 1)

    for i = 1, 6 do
        local icon = transform:FindChild("SkillList/SkillIcon"..i).gameObject
        self.iconlist[i] = icon
        self.imagelist[i] = icon.transform:FindChild("SkillImage").gameObject
        self.namelist[i] = icon.transform:FindChild("SkillName").gameObject:GetComponent(Text)
        self.levellist[i] = icon.transform:FindChild("SkillLevel").gameObject:GetComponent(Text)
        self.labellist[i] = icon.transform:FindChild("SkillLabel").gameObject
        self.enhanceLevlist[i] = icon.transform:FindChild("EnhanceLev").gameObject:GetComponent(Text)
        self.recommendlist[i] = icon.transform:FindChild("Recommend").gameObject

        local fun = function() self:onskillitemclick(icon) end
        icon:GetComponent(Button).onClick:AddListener(fun)
    end

    self.toggle = self.skillinfo.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener(function(on) self:ontogglechange(on) end)

    self.select_mark = self.skillmatrix.transform:FindChild("Select").gameObject

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.skillinfo.transform:FindChild("Item").gameObject, self.itemSolt.gameObject)

    local itembase = BackpackManager.Instance:GetItemBase(20025)
    self.itemData = ItemData.New()
    self.itemData:SetBase(itembase)
    self.itemSolt:SetAll(self.itemData)

    self.itemSolt_RedPoint = self.skillinfo.transform:FindChild("ItemRedPoint").gameObject

    self.dropArea = self.skillinfo.transform:Find("DropArea")
    for i=1,self.dropArea.childCount do
        local tab = {}
        tab.transform = self.dropArea:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.text = tab.transform:Find("Text"):GetComponent(Text)
        tab.text.text = string.format(TI18N("学习%s次"), self.dropDataList[i].times)
        tab.button = tab.gameObject:GetComponent(Button)
        local j = i
        tab.button.onClick:AddListener(function() self:DropClick(j) end)
        self.dropList[i] = tab
    end

    self.dropArrow = self.skillinfo.transform:FindChild("OneKeyButton/Arrow")
    self.dropArrow:GetComponent(Button).onClick:AddListener(function() self:ArrowClick() end)
    self.leftTimes = self.skillinfo.transform:Find("LearnTimes/NumText"):GetComponent(Text)
    self.noteTimes = self.skillinfo.transform:Find("NoteTimes/NumText"):GetComponent(Text)
    self.noteTimes.text = "0/0"

    -- 按钮功能绑定
    local btn
    btn = self.skillinfo.transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:okbuttonclick() end)
    self.oneTimeBtn = btn

    btn = self.skillinfo.transform:FindChild("OneKeyButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onekeybuttonclick() end)
    self.oneKeyButton = btn
    self.oneKeyButtonText = btn.transform:FindChild("Text"):GetComponent(Text)

    btn = self.skillinfo.transform:FindChild("UseItemButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:useitembuttonclick() end)
    self.useItemBtn = btn

    btn = self.skillinfo.transform:FindChild("DescButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:descbuttonclick() end)
    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()

    -- ---------------------------------------------------------------------
    -- ----------------------- 可以说非常强行了 ----------------------------
    -- ---------------------------------------------------------------------

    self:ShowDrop(false)

    self.oneTimeBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.oneTimeBtn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
    self.oneTimeBtn.gameObject:SetActive(true)
    self.oneTimeBtn.transform.anchoredPosition = Vector2(-14, -180)

    self.oneKeyButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.oneKeyButtonText.color = ColorHelper.DefaultButton1
    self.oneKeyButtonText.text = string.format(TI18N("学习%s次"), 20)
    self.oneKeyButtonText.transform.anchoredPosition = Vector2.zero
    self.oneKeyButton.transform.sizeDelta = Vector2(120, 48)
    self.oneKeyButton.transform.anchoredPosition = Vector2(-160, -180)
    self.dropArrow.gameObject:SetActive(false)

    self.useItemBtn.transform.anchoredPosition = Vector2(155, -180)
    self.itemSolt_RedPoint.transform.anchoredPosition = Vector2(211, -160)
    self.skillinfo.transform:Find("LearnTimes").gameObject:SetActive(false)
    self.skillinfo.transform:Find("NoteTimes").gameObject:SetActive(false)
end

function SkillView_Prac:OnShow()
    -- self:ShowDrop(false)
    self:addevents()
    self:updateSkillItem()
    self:update_item()

    self:CheckGuide()
end

function SkillView_Prac:OnHide()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
    self:removeevents()
    self.model:SavePracSelect()
end

function SkillView_Prac:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    self:OnHide()
    self:AssetClearAll()
end

function SkillView_Prac:addevents()
    SkillManager.Instance.OnUpdatePracSkill:Add(self._updateSkillItem)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._role_assets_change)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_item)
end

function SkillView_Prac:removeevents()
    SkillManager.Instance.OnUpdatePracSkill:Remove(self._updateSkillItem)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._role_assets_change)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_item)
end

-- 更新技能列表 Mark
function SkillView_Prac:updateSkillItem()
	local skilllist = self.model.prac_skill
    local skillitem
    local data

    for i = 1, #skilllist do
        data = skilllist[i]

        local skilldata = DataSkillPrac.data_skill[data.id]

        if self.iconlist[i] ~= nil then
	        self.imagelist[i]:SetActive(true)
	        self.namelist[i].text = skilldata.name
            self.labellist[i]:SetActive(self.model.prac_skill_learning == data.id)
            local enhancelevel = self.model:getpracskillenhancelevel(data)
            if enhancelevel > 0 then
                self.levellist[i].text = string.format("%s+%s/%s", data.lev, enhancelevel
                    , self.model:getpracskill_top_lev(data.id, RoleManager.Instance.RoleData.lev))
            else
                self.levellist[i].text = string.format("%s/%s", data.lev
                    , self.model:getpracskill_top_lev(data.id, RoleManager.Instance.RoleData.lev))
            end
	        self.iconlist[i].name = tostring(data.id)

            local data_skill_level = DataSkillPrac.data_skill_level[string.format("%s_%s", data.id, data.lev + 4)]
            if data_skill_level ~= nil then
                self.recommendlist[i]:SetActive(data_skill_level.role_lev < (RoleManager.Instance.world_lev + 8))
            else
                self.recommendlist[i]:SetActive(false)
            end

            if self.selectbtn == nil and self.model.prac_skill_learning == data.id then
                self.selectbtn = self.iconlist[i]
            end
	    end
    end

    if #skilllist > 0 then
        if self.selectbtn == nil then
            self:onskillitemclick(self.transform:FindChild("SkillList/"..self.iconlist[1].name).gameObject)
        else
            self:onskillitemclick(self.selectbtn)
        end
    end
end

-- 选中技能 Mark
function SkillView_Prac:onskillitemclick(item)
    self.select_skilldata = self.model:getpracskill(item.name)
    if self.select_skilldata == nil then return end

    self.skilldata = self.model:getpracskilldata(item.name, self.select_skilldata.lev)

    self:updateSkill()

    self.selectbtn = item
    self.select_mark.transform:SetParent(self.selectbtn.transform)
    self.select_mark.transform.localPosition = Vector3.zero
    self.select_mark.transform.localScale = Vector3.one
end

-- 更新技能信息 Mark
function SkillView_Prac:updateSkill()
    if nil == self.skilldata or nil == self.select_skilldata then return end
    local enhancelevel = self.model:getpracskillenhancelevel(self.select_skilldata)

    if enhancelevel == 0 then
        self.skillinfo.transform:FindChild("NameText"):GetComponent(Text).text
            = string.format("%s LV.%s", DataSkillPrac.data_skill[self.skilldata.id].name, self.skilldata.skill_lev)
        self.skillinfo.transform:FindChild("DescButton").gameObject:SetActive(false)
    else
        self.skillinfo.transform:FindChild("NameText"):GetComponent(Text).text
            = string.format("%s LV.%s <color='#c3692c'>+%s</color>"
                , DataSkillPrac.data_skill[self.skilldata.id].name, self.skilldata.skill_lev, enhancelevel)
        self.skillinfo.transform:FindChild("DescButton").gameObject:SetActive(true)
    end

    self.skillinfo.transform:FindChild("DescText"):GetComponent(Text).text = self.skilldata.desc

    self.skillinfo.transform:FindChild("DescText2"):GetComponent(Text).text = self.model:getpracskilldata(self.skilldata.id, self.select_skilldata.lev + enhancelevel).desc1

    if self.model.prac_skill_learning == self.skilldata.id then
        self.toggle.isOn = true
    else
        self.toggle.isOn = false
    end

    self.skillinfo.transform:FindChild("CostItem/NumText"):GetComponent(Text).text = "20000"
    self.skillinfo.transform:FindChild("OwnItem/NumText"):GetComponent(Text).text = tostring(RoleManager.Instance.RoleData.coin)

    self.skillinfo.transform:FindChild("ExpText"):GetComponent(Text).text = string.format("%s/%s", self.select_skilldata.exp, self.skilldata.exp)
    -- skillinfo.transform:FindChild("ExpSlider"):GetComponent(Slider).value = select_skilldata.exp / skilldata.exp
    local expslider = self.skillinfo.transform:FindChild("ExpSlider"):GetComponent(Slider)

    -- if mod_skill.prac_skill_upgrade_id ~= nil then
    --     tween:DoSlider(expslider, 1, 0.5, "ui_skill_prac.expslider_end")
    -- else
    --     tween:DoSlider(expslider, select_skilldata.exp / skilldata.exp, 0.5)
    -- end

    if self.model.prac_skill_upgrade_id ~= nil then
        -- SoundManager.Instance:Play(241)
        if self.skilldata.exp ~= 0 then
            local fun = function() BaseUtils.tweenDoSlider(expslider, 0, self.select_skilldata.exp / self.skilldata.exp, 0.5) end
            BaseUtils.tweenDoSlider(expslider, expslider.value, 1, 0.5, fun)
        else
            self.skillinfo.transform:FindChild("ExpText"):GetComponent(Text).text = TI18N("已满级")
            expslider.value = 1
        end
    elseif self.last_skill_id == self.skilldata.id then
        if self.skilldata.exp ~= 0 then
            BaseUtils.tweenDoSlider(expslider, expslider.value, self.select_skilldata.exp / self.skilldata.exp, 0.5)
        else
            self.skillinfo.transform:FindChild("ExpText"):GetComponent(Text).text = TI18N("已满级")
            expslider.value = 1 
        end
    else
        if self.skilldata.exp ~= 0 then
            expslider.value = self.select_skilldata.exp / self.skilldata.exp
        else
            self.skillinfo.transform:FindChild("ExpText"):GetComponent(Text).text = TI18N("已满级")
            expslider.value = 1
        end
    end

    -- self.oneKeyButtonText.text = string.format(TI18N("学习%s次"), self.dropDataList[self.model.skillpracIndex or 1].times)

    -- local leftNum = DataSkillPrac.data_skill[self.skilldata.id].day_max_times - self.model:getpracskill(self.skilldata.id).times
    -- if leftNum == 0 then
    --     self.leftTimes.text = string.format("<color='#c23934'>%s</color>/%s", leftNum, DataSkillPrac.data_skill[self.skilldata.id].day_max_times)
    -- else
    --     self.leftTimes.text = string.format("%s/%s", leftNum, DataSkillPrac.data_skill[self.skilldata.id].day_max_times)
    -- end

    -- local max_use_time = 15
    -- if PrivilegeManager.Instance.lev >= 70 then
    --     max_use_time = max_use_time + 5
    -- end
    -- leftNum = max_use_time - self.model.note_times
    -- if leftNum == 0 then
    --     self.noteTimes.text = string.format("<color='#c23934'>%s</color>/%s", leftNum, max_use_time)
    -- else
    --     self.noteTimes.text = string.format("%s/%s", leftNum, max_use_time)
    -- end
    -- self.last_skill_id = self.skilldata.id
end

function SkillView_Prac:role_assets_change()
    self.skillinfo.transform:FindChild("OwnItem/NumText"):GetComponent(Text).text = tostring(RoleManager.Instance.RoleData.coin)
end

function SkillView_Prac:update_item() -- 20025
    local num = BackpackManager.Instance:GetItemCount(20025)
    self.itemSolt:SetNum(num, 1)
    -- self.itemSolt:SetAll(self.itemData)

    self.itemSolt_RedPoint:SetActive(self.model.skill_prac_redpoint and num > 0)
end

function SkillView_Prac:okbuttonclick()
    if self.select_skilldata == nil then return end
    if 20000 > RoleManager.Instance.RoleData.coin then
        NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
        ExchangeManager.Instance.model:OpenPanel(2)
        return
    end
    SkillManager.Instance:Send10807(self.select_skilldata.id, 1)
end

function SkillView_Prac:onekeybuttonclick()
    if self.select_skilldata == nil or self.skilldata == nil then return end

    -- local times = self.dropDataList[self.model.skillpracIndex or 1].times
    local learn_times = self.model:getpracskill(self.skilldata.id).times
    -- if DataSkillPrac.data_skill[self.skilldata.id].day_max_times - learn_times < times then
    --     times = DataSkillPrac.data_skill[self.skilldata.id].day_max_times - learn_times
    -- end
    -- if times > 0 then
    --     if 20000 * times > RoleManager.Instance.RoleData.coin then
    --         NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
    --         ExchangeManager.Instance.model:OpenPanel(2)
    --         return
    --     end
    --     SkillManager.Instance:Send10807(self.select_skilldata.id, times)
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("今天学习次数已用完"))
    -- end

    local max_times = DataSkillPrac.data_max[BaseUtils.Key(self.select_skilldata.id, self.select_skilldata.lev)].max_times
    local times = max_times - learn_times
    if times > 20 or max_times == 0 then
        times = 20
    end
    if max_times == 0 or times > 0 then
        if 20000 * times > RoleManager.Instance.RoleData.coin then
            NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
            ExchangeManager.Instance.model:OpenPanel(2)
            return
        else
            SkillManager.Instance:Send10807(self.select_skilldata.id, times)
        end
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>今日银币学习已达到上限"), DataSkillPrac.data_skill[self.select_skilldata.id].name))
    end
end

function SkillView_Prac:ontogglechange(on)
    if on then
        if self.model.prac_skill_learning ~= self.select_skilldata.id then
            SkillManager.Instance:Send10806(self.select_skilldata.id)
        end
    elseif self.model.prac_skill_learning == self.select_skilldata.id then
        self.toggle.isOn = true
    end
end

function SkillView_Prac:useitembuttonclick()
    -- print(BackpackManager.Instance:GetItemCount(20025))
    if nil == self.select_skilldata then return end

    if BackpackManager.Instance:GetItemCount(20025) < 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))

        -- local tipsData = { itemData = self.itemData, gameObject = self.skillinfo.transform:FindChild("UseItemButton").gameObject}
        -- TipsManager.Instance:ShowItem(tipsData)
        BuyManager.Instance:ShowQuickBuy({[20025] = {need = 1}})
        return
    end
    SkillManager.Instance:Send10817(self.select_skilldata.id)
end

function SkillView_Prac:descbuttonclick()
    if nil == self.select_skilldata or self.select_skilldata.enhance == nil then return end

    local tips_text = {}
    local list = {}
    for i=1, #self.select_skilldata.enhance do
        if self.select_skilldata.enhance[i].lev > 0 then
            table.insert(list, self.select_skilldata.enhance[i])
        end
    end

    for i=1, #list do
        table.insert(tips_text, string.format(TI18N("<color='#ffff00'>%s</color>加成，等级+%s"), self.model:getpracskillenhancesource(list[i].source), list[i].lev))
    end

    TipsManager.Instance:ShowText({gameObject = self.skillinfo.transform:FindChild("DescButton").gameObject
            , itemData = tips_text})
end

-- ----------------------------------
-- 特殊指引
-- hosr
-- ----------------------------------
function SkillView_Prac:CheckGuide()
    if RoleManager.Instance.RoleData.lev >= 30 and RoleManager.Instance.RoleData.lev < 50 and BackpackManager.Instance:GetItemCount(20025) > 0 then
        local questData = QuestManager.Instance.questTab[41250]
        if questData ~= nil and questData.finish ~= QuestEumn.TaskStatus.Finish then
            if self.guideScript == nil then
                self.guideScript = GuideSkillPrac.New(self)
                self.guideScript:Show()
            end
        end
    end
end

-- 上拉列表
function SkillView_Prac:ShowDrop(bool)
    self.isShowDrop = (bool == true)
    self.dropArea.gameObject:SetActive(self.isShowDrop)
    if self.isShowDrop then
        self.dropArrow.localScale = -Vector3.one
    else
        self.dropArrow.localScale = Vector3.one
    end
end

function SkillView_Prac:DropClick(index)
    self.model.skillpracIndex = index
    -- self:onekeybuttonclick()
    self:ShowDrop(false)
    NoticeManager.Instance:FloatTipsByString(TI18N("切换成功"))
    self.oneKeyButtonText.text = string.format(TI18N("学习%s次"), self.dropDataList[index].times)
end

function SkillView_Prac:ArrowClick()
    self:ShowDrop(self.isShowDrop ~= true)
end
