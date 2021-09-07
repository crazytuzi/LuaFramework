-- ---------------------------
-- 组队阵法提升界面
-- hosr
-- ---------------------------
FormationLearnPanel = FormationLearnPanel or BaseClass(BasePanel)

function FormationLearnPanel:__init(mainPanel)
    self.mainPanel = mainPanel

    self.resList = {
        {file = AssetConfig.formationlearn, type = AssetType.Main}
    }

    self.slotTab = {}
    self.upgradeitem_list = {}
    self.listener = function(data) self:Update(data) end

    self.OnOpenEvent:Add(function() self:MyShow() end)
end

function FormationLearnPanel:__delete()
    for k,v in pairs(self.slotTab) do
        v["imgLoader"]:DeleteMe()
    end
    self.slotTab = nil
    EventMgr.Instance:RemoveListener(event_name.formation_levelup, self.listener)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FormationLearnPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.formationlearn))
    self.gameObject.name = "FormationLearnPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.mainPanel.gameObject, self.gameObject)

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.itemIcon = self.transform:Find("Main/item"):GetComponent(Image)
    self.itemIcon.gameObject:SetActive(true)
    self.name_txt = self.transform:Find("Main/name"):GetComponent(Text)
    self.lev_txt = self.transform:Find("Main/lev"):GetComponent(Text)
    self.exp_txt = self.transform:Find("Main/Exp"):GetComponent(Text)
    self.slot_container = self.transform:Find("Main/SlotCon").gameObject
    self.nothing = self.transform:Find("Main/noCon").gameObject
    self.nothingTxt = self.transform:Find("Main/noCon/Text"):GetComponent(Text)
    self.nothingbtn = self.nothing.transform:Find("btn"):GetComponent(Button)
    self.use_btn = self.transform:Find("Main/Usebtn"):GetComponent(Button)
    self.use_btn.onClick:AddListener(function() self:UseItem() end)
    self.tips_btn = self.transform:Find("Main/tipsbtn").gameObject
    self.slider = self.transform:Find("Main/Expbar"):GetComponent(Slider)
    self.slider2 = self.transform:Find("Main/Expbar/Fill Area"):GetComponent(Slider)
    self.bottomTxt = self.transform:Find("Main/Text"):GetComponent(Text)
    local panel = self.transform:Find("Panel").gameObject

    for i=1,10 do
        local slot = self.slot_container.transform:Find(string.format("ItemSlot%s", i)).gameObject
        local tab = {}
        tab["gameObject"] = slot
        tab["button"] = slot:GetComponent(Button)
        tab["imgLoader"] = SingleIconLoader.New(slot.transform:Find("ItemImg").gameObject)
        tab["num"] = slot.transform:Find("Num"):GetComponent(Text)
        tab["select"] = slot.transform:Find("Select").gameObject
        self.slotTab[i] = tab
    end

    self.nothingbtn.onClick:AddListener(function() self:Hiden() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 6}) end)

    EventMgr.Instance:AddListener(event_name.formation_levelup, self.listener)

    self:MyShow()
end

function FormationLearnPanel:Update(backdata)
    local fdata = DataFormation.data_list[string.format("%s_%s", self.currselect_forid, backdata.lev2)]
    local data = BaseUtils.copytab(fdata)
    data.lev = backdata.lev2
    data.exp = backdata.exp2
    self:Change(data)
end

function FormationLearnPanel:Hiden()
    self.upgradeitem_list = {}
    self.gameObject:SetActive(false)
end

function FormationLearnPanel:MyShow()
    local fdata = self.openArgs
    local data = BaseUtils.copytab(fdata)
    local id = data.id
    self.currselect_forid = id
    data.exp = 0
    for k,v in ipairs(FormationManager.Instance.formationList) do
        if v.id == id then
            data.exp = v.exp
        end
    end
    self:Change(data)
end

--蛋疼的是升级后没有00协议，职业06协议，我也是醉了
function FormationLearnPanel:Change(data)
    if data.lev >= 3 then
        self.bottomTxt.text = TI18N("使用<color='#ffff00'>上品阵图</color>增加经验")
        self.nothingTxt.text = TI18N("当前阵法已经<color='#ffff00'>达到3级</color>，需要消耗<color='#ffff00'>上品阵图</color>才能继续提升，可在<color='#ffff00'>金币市场</color>或<color='#ffff00'>神秘商店</color>获得")
    else
        self.bottomTxt.text = TI18N("使用<color='#ffff00'>阵法残卷/相应阵法书</color>增加经验")
        self.nothingTxt.text = TI18N("当前包裹没有可提升该阵法经验值的道具哦～去市场购买<color='#ffff00'>阵法书</color>吧！")
    end
    self.itemIcon.sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(data.id))
    self.name_txt.text = data.name
    self.lev_txt.text = string.format(TI18N("%s级"), tostring(data.lev))

    if data.next_exp == 0 then
        -- 不能升级了
        self.exp_txt.text = TI18N("满级")
        self.slider.value = 0
        self.slider2.value = 1
    else
        self.exp_txt.text = string.format("%s/%s", tostring(data.exp + self:Caculateexp(data)), tostring(data.next_exp))
        self.slider.value = (data.exp) / data.next_exp
        self.slider2.value = (data.exp + self:Caculateexp(data)) / data.next_exp
    end
    local currindex = 1

    for i,v in ipairs(data.need_item) do
        local num = BackpackManager.Instance:GetItemCount(v.item_id)
        if num > 0 then
            local slot = self.slotTab[currindex]
            local baseid = v.item_id
            local iconid = DataItem.data_get[baseid].icon
            slot["imgLoader"]:SetSprite(SingleIconType.Item, iconid)
            slot["imgLoader"].gameObject:SetActive(true)
            slot["num"].text = tostring(num)
            slot["num"].gameObject:SetActive(true)
            slot["select"]:SetActive(false)

            local click = function (eventdata)
                if slot["select"].activeSelf == true then
                    for k,_v in pairs(self.upgradeitem_list) do
                        if _v.id == v.item_id then
                            self.upgradeitem_list[k] = nil
                        end
                    end
                    slot["select"]:SetActive(false)
                else
                    table.insert( self.upgradeitem_list, {id = v.item_id, num = num})
                    slot["select"]:SetActive(true)
                end
                if data.next_exp == 0 then
                    -- 不能升级了
                    self.exp_txt.text = TI18N("满级")
                    self.slider.value = 0
                    self.slider2.value = 1
                else
                    self.slider.value = (data.exp) / data.next_exp
                    self.slider2.value = (data.exp + self:Caculateexp(data)) / data.next_exp
                    self.exp_txt.text = string.format("%s/%s", tostring(data.exp + self:Caculateexp(data)), tostring(data.next_exp))
                end
            end

            slot["button"].onClick:RemoveAllListeners()
            slot["button"].onClick:AddListener(click)

            if currindex == 1 then
                -- 选中第一个
                click()
            end
            currindex = currindex + 1
        end
    end
    for i = currindex, 10 do
        local slot = self.slotTab[i]
        slot["select"]:SetActive(false)
        slot["num"].gameObject:SetActive(false)
        slot["button"].onClick:RemoveAllListeners()
    end
    if currindex == 1 then
        -- 没有道具可用
        self.slot_container:SetActive(false)
        self.use_btn.gameObject:SetActive(false)
        self.nothing:SetActive(true)
    else
        self.slot_container:SetActive(true)
        self.use_btn.gameObject:SetActive(true)
        self.nothing:SetActive(false)
    end
end

-- 计算选择的道具能加多少经验
function FormationLearnPanel:Caculateexp(data)
    local id = data.id
    local lev = data.lev + 1
    local max = data.next_exp
    if data.lev < 3 then
        max = 0
        for i = data.lev, 2 do
            max = max + DataFormation.data_list[string.format("%s_%s", data.id, data.lev + i - 1)].next_exp
        end
    end
    max = max - data.exp

    local exp = 0
    if next(self.upgradeitem_list) ~= nil then
        for k,v in pairs(self.upgradeitem_list) do
            local list = BackpackManager.Instance:GetItemByBaseid(v.id)
            local num = BackpackManager.Instance:GetItemCount(v.id)
            local val = 0
            for _i,_v in ipairs(data.need_item) do
                if _v.item_id == v.id then
                    val = _v.item_val
                end
            end
            local need = math.ceil((max - exp) / val)
            if num > need then
                exp = exp + need * val
                v.num = need
                return exp
            else
                exp = exp + num * val
                v.num = num
            end
        end
    end
    return exp
end

-- 使用物品
function FormationLearnPanel:UseItem()
    if next(self.upgradeitem_list) ~= nil then
        for k,v in pairs(self.upgradeitem_list) do
            FormationManager.Instance:Send12907(self.currselect_forid, v.id, v.num)
        end
    end
    self.upgradeitem_list = {}
end
