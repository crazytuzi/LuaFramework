-- @author hze
-- @date #2019/05/23#
-- @宠物内丹共鸣界面

PetResonancesRunePanel = PetResonancesRunePanel or BaseClass(BasePanel)

function PetResonancesRunePanel:__init(model)
    self.resList = {
        {file = AssetConfig.petresonancesrunepanel, type = AssetType.Main},
        {file = AssetConfig.petresonancesrunepanel_bg , type = AssetType.Dep},
    }

    self.model = model
    self.name = "PetResonancesRunePanel"

    self.runeItemList = {}

    self.flag = 0       --可激活位置/默认为可重置

    self.btnColdFlag = true

    self.runeTips = {
        TI18N("1.高级内丹达到5级后可以消耗一个相同的高级内丹激活一条共鸣")
        ,TI18N("2.激活共鸣的普通内丹是随机出现的，如果该普通内丹已学习且升级到5级，将增加1级效果（即6级效果）")
        ,TI18N("3.可以选择不满意的共鸣重置")
        ,TI18N("4.每个高级内丹最多可激活5条共鸣")
    }

    self.on_item_update = function() self:OnUpdateItem() end
    self.on_update = function() self:Update() end
    self.effectListener = function(data) 
        self.btnColdFlag = true
        self:SetEffect(data) 
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PetResonancesRunePanel:__delete()
    self.OnHideEvent:Fire()

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end

    if self.resonanceBtn ~= nil then 
        self.resonanceBtn:DeleteMe()
    end


    for _,v in ipairs(self.runeItemList) do
        if v.iconloader ~= nil then
            v.iconloader:DeleteMe()
        end
    end

    if self.itemCell ~= nil then 
        self.itemCell:DeleteMe()
    end
end

function PetResonancesRunePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petresonancesrunepanel))
    if self.model.window ~= nil and not BaseUtils.isnull(self.model.window.gameObject) then
        UIUtils.AddUIChild(self.model.window.gameObject, self.gameObject)
    else
        UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    end

    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0,0,-500)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetResonanceRunePanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetResonanceRunePanel() end)

    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petresonancesrunepanel_bg, "PetResonancesRunePanelBg")

    self.descTxt = self.transform:Find("Main/DescText"):GetComponent(Text)

    self.normol = self.transform:Find("Main/Normal")
    self.smart = self.transform:Find("Main/Smart")

    --共鸣内丹
    for i = 1 ,5 do
        self.runeItemList[i] = self:CreateItem(self.normol:Find(string.format("Item%s",i)))
    end

    --高级内丹
    self.smartItem = self:CreateItem(self.smart:Find("Item"))

    self.itemCell = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Main/ItemSlot"), self.itemCell.gameObject)
    -- self.itemCell:SetNotips()

    self.costMoney = self.transform:Find("Main/Cost")
    self.costMoneyIcon = self.costMoney:Find("GoldIcon")
    self.costMoneyTxt = self.costMoney:Find("Num"):GetComponent(Text)

    self.resonanceBtn = BuyButton.New(self.transform:Find("Main/ResonanceButton"), TI18N("共 鸣"), false)
    self.resonanceBtn:Set_btn_img("DefaultButton3")
    self.resonanceBtn.key = "PetRuneResonanceButton"
    self.resonanceBtn.protoId = 10578
    self.resonanceBtn:Show()

    self.clickCall = function() 
        if self.btnColdFlag then 
            self.btnColdFlag = false
            if self.curr_resonance_index == nil then 
                NoticeManager.Instance:FloatTipsByString(TI18N("请选择想要共鸣的内丹"))
            else
                PetManager.Instance:Send10578(self.curr_pet_id, self.curr_resonance_index) 
            end
        end
    end

    self.priceCall = function(prices) 
        -- BaseUtils.dump(prices, "prices")

        local data = nil
        for _, value in pairs(prices) do
            data = value
        end
        if data == nil then
            self.costMoney.gameObject:SetActive(false)
            return
        end
    
        local allprice = data.allprice
        local price_str = ""
        if allprice >= 0 then
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], allprice)
        else
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], - allprice)
        end
        if self.costMoneyTxt ~= nil then 
            self.costMoneyTxt.text = price_str
        end
        self.costMoneyIcon:GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets])
    
        self.costMoney.gameObject:SetActive(true)
    end

    --Tips
    local tipsBtn = self.transform:Find("Main/Tips"):GetComponent(Button)
    tipsBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = tipsBtn.gameObject, itemData = self.runeTips}) end)

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BaseUtils.ShowEffect(20049, self.transform, Vector3.one, Vector3(0, 0, -1000))
    self.effect:SetActive(false)
end

function PetResonancesRunePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PetResonancesRunePanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
    PetManager.Instance.OnPetUpdate:Add(self.on_update)
    PetManager.Instance.OnPetRuneResonances:Add(self.effectListener)


    if self.model.cur_petdata == nil then return end
    self:Update()

    

    --默认选中第一个
    local first_data
    for k, v in ipairs(self.data.resonances) do
        if v.resonance_index == 1 then 
            first_data = v
        end
    end

    self:ClickRuneBtn(self.runeItemList[1], first_data, true)
end

function PetResonancesRunePanel:OnHide()
    self:RemoveListeners()
end

function PetResonancesRunePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    PetManager.Instance.OnPetUpdate:Remove(self.on_update)
    PetManager.Instance.OnPetRuneResonances:Remove(self.effectListener)
end

function PetResonancesRunePanel:Update()
    --获取当前宠物高级内丹数据
    self.curr_pet_id = self.model.cur_petdata.id
    for k,v in ipairs(self.model.cur_petdata.pet_rune) do
        if v.rune_type == 2  then 
            self.data = v
        end
    end
    -- BaseUtils.dump(self.data,"共鸣数据")

    self.descTxt.text = string.format( "%s最多可激活%s条共鸣 ", self.model.cur_petdata.name, #self.data.resonances)

    --可激活位置/默认为可重置
    for k, v in ipairs(self.data.resonances) do
        if v.resonance_id == 0 then 
            self.flag = v.resonance_index
            break
        end
    end

    ----是否重置
    -- if self.flag == 0 then 
    --     self.resonanceBtn:Set_btn_txt(TI18N("重 置"))
    -- end

    --高级内丹
    self:SetItemData(self.smartItem, self.data)
    --共鸣内丹
    for _, v in ipairs(self.data.resonances) do
        self:SetItemData(self.runeItemList[v.resonance_index], v)
    end

    --刷新消耗物品信息
    self:OnUpdateItem()
end

function PetResonancesRunePanel:CreateItem(transform)
    local item = {}
    item["trans"] = transform
    item["btn"] = transform:Find("BgImg"):GetComponent(Button)
    item["iconImg"] = transform:Find("BgImg/IconImg")
    item["iconloader"] = SingleIconLoader.New(item.iconImg.gameObject)
    item["abledImg"] = transform:Find("BgImg/AbledImg")
    item["lockImg"] = transform:Find("BgImg/LockImg")
    item["select"] = transform:Find("BgImg/Select").gameObject
    item["txt"] = transform:Find("TxtBg/Text"):GetComponent(Text)
    item["textBg"] = transform:Find("TextBg")
    item["studytxt"] = transform:Find("TextBg/StudyText"):GetComponent(Text)
    return item
end 


function PetResonancesRunePanel:SetItemData(item,data)
    local key 
    local iconImgStatus = 1  --1：显示图标, 2:显示可激活, 3:锁
    local selectStatus = false  --true:选中, false:不选中
    local showTips = false 
    if data.rune_type == 2 then 
        key = BaseUtils.Key(data.rune_id, data.rune_lev)
        iconImgStatus = 1
        showTips = true
    else
        key = BaseUtils.Key(data.resonance_id, "1")
        if data.resonance_id ~= 0 then 
            iconImgStatus = 1
            selectStatus = true
            showTips = true
        elseif self.flag == data.resonance_index then
            iconImgStatus = 2 
            selectStatus = true
        else
            iconImgStatus = 3
        end
    end
    
    local runedata = DataRune.data_rune[key]
    
    if runedata ~= nil then 
        if data.resonance_id ~= 0 and runedata.quality == 1 then 
            item.textBg.gameObject:SetActive(true)
            local str2 = ""
            if data.rune_index == 0 then 
                if PetManager.Instance.model:JudgeStudyStatus(data.resonance_id) then
                    str2 = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("已学习"))
                else
                    str2 = string.format("<color='%s'>%s</color>", ColorHelper.color[6], TI18N("未学习"))
                end   
            else
                str2 = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("已共鸣"))
            end
            item.studytxt.text = str2
        else
            item.textBg.gameObject:SetActive(false)
        end
    end
    
    --激活判断
    local str = TI18N("未激活")
    if runedata ~= nil then 
        if data.resonance_id ~= 0 and runedata.quality == 1 then 
            str = runedata.name
        elseif runedata.quality == 2 then 
            str = string.format("%s(%s%s)", runedata.name, runedata.lev, TI18N("级"))
        end
    end
    item.txt.text = str

    item.iconImg.gameObject:SetActive(iconImgStatus == 1)
    item.abledImg.gameObject:SetActive(iconImgStatus == 2)
    item.lockImg.gameObject:SetActive(iconImgStatus == 3)

    if iconImgStatus == 1 then 
        item.iconloader:SetSprite(SingleIconType.SkillIcon, DataSkill.data_petSkill[BaseUtils.Key(runedata.skill_id, "1")].icon)
    end

    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function() 
        if selectStatus then self:ClickRuneBtn(item, data) end
        if showTips then 
            local itemdata = ItemData.New()
            itemdata:SetBase(BackpackManager.Instance:GetItemBase(data.rune_id or data.resonance_id))
            TipsManager.Instance:ShowItem({["gameObject"] = item.trans.gameObject, ["itemData"] = itemdata, extra = { nobutton = true } })
        end
    end)
end 

function PetResonancesRunePanel:ClickRuneBtn(item, data, showTips)
    if self.lastSelectedItem ~= nil then 
        self.lastSelectedItem.select:SetActive(false)
    end
    item.select:SetActive(true)
    self.lastSelectedItem = item
    
    self.curr_resonance_index = data.resonance_index

    self.resonanceBtn.beforeContent = nil
    if data.resonance_id == 0 then 
        self.resonanceBtn:Set_btn_txt(TI18N("共 鸣"))
    else
        self.resonanceBtn:Set_btn_txt(TI18N("重 置"))
        if PetManager.Instance.model:JudgeStudyStatus(data.resonance_id) then
            self.resonanceBtn.beforeContent = string.format(TI18N("<color='#fff000'>%s</color>已经学习，是否继续重置该共鸣"), DataRune.data_rune[BaseUtils.Key(data.resonance_id,"1")].name)
        end
    end
    self.currdata = data

    self:OnUpdateItem()
end

function PetResonancesRunePanel:OnUpdateItem()
    if self.currdata == nil then return end
    local resonate_data = DataRune.data_resonate[self.currdata.resonance_index]
    if resonate_data == nil then return end

    local needNum = 1
    if self.flag ~= 0 then 
        needNum = resonate_data.open_cost
    else
        needNum = resonate_data.reset_cost
    end

    local itemdata = ItemData.New()
    itemdata:SetBase(DataItem.data_get[self.data.rune_id])
    self.itemCell:SetAll(itemdata,{nobutton = true})
    self.itemCell:SetNum(BackpackManager.Instance:GetItemCount(self.data.rune_id), needNum)

    
    local buylist = {[self.data.rune_id] = {need = needNum}}
    if self.resonanceBtn ~= nil then 
        self.resonanceBtn:Layout(buylist, self.clickCall, self.priceCall, {antofreeze = false})
    end
end


function PetResonancesRunePanel:SetEffect(index)
    local pos = self.runeItemList[index].trans.position
    self.effect.transform.position = pos

    self.effect:SetActive(false)
    self.effect:SetActive(true)
end 