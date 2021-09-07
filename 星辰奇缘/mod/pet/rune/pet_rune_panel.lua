-- @author hze
-- @date #2019/05/09#
-- @宠物内丹界面

PetRunePanel = PetRunePanel or BaseClass(BasePanel)

function PetRunePanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.name = "PetRunePanel"
    self.assetWrapper = assetWrapper

    self.runeItemList = {}

    self.runeTips = {
        TI18N("1.宠物内丹分为高级内丹、普通内丹。<color='#ffff00'>每只宠物只能拥有1个高级内丹</color>，普通内丹的携带数量与宠物参战等级相关。")
        ,TI18N("2.宠物突破后可<color='#ffff00'>额外开启1个普通内丹</color>")
        ,TI18N("3.宠物学习内丹后可以在战斗过程中<color='#ffff00'>领悟</color>，也可以消耗一定银币或者成长丹快速领悟，领悟后可以提升内丹等级，最高<color='#ffff00'>可提升至5级</color>。")
        ,TI18N("4.高级内丹<color='#ffff00'>达到5级</color>后可以与普通内丹产生<color='#ffff00'>共鸣</color>，如果共鸣效果与已学习普通内丹一致，并且普通内丹等级达到5级，则该普通内丹自动<color='#ffff00'>提升到6级</color>")
        ,TI18N("5.已学习的内丹可以被遗忘，遗忘按照当前等级可<color='#ffff00'>返还</color>一定的道具，遗忘后可重新学习内丹。")
        
    }

    self.listener = function(arg) self:Update() end
    self.effectListener = function(data) self:SetEffect(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function PetRunePanel:__delete()
    self.OnHideEvent:Fire()

    for _,v in ipairs(self.runeItemList) do
        if v.iconloader ~= nil then 
            v.iconloader:DeleteMe()
        end

        if v.effect ~= nil then 
            v.effect:DeleteMe()
        end
        
        if v.effect2 ~= nil then 
            v.effect2:DeleteMe()
        end
    end

    if self.smartItem.iconloader ~= nil then 
        self.smartItem.iconloader:DeleteMe()
    end

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end

    BaseUtils.ReleaseImage(self.transform:Find("Bg"):GetComponent(Image))
end

function PetRunePanel:InitPanel()
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petrunepanel_bg, "PetRunePanelBg")

    self.normol = self.transform:Find("Normal")
    self.smart = self.transform:Find("Smart")

    --普通内丹
    for i = 1 ,5 do
        self.runeItemList[i] = self:CreateItem(self.normol:Find(string.format("Item%s",i)))
    end

    --高级内丹
    self.smartItem = self:CreateItem(self.smart:Find("Item"))

    --Tips
    local tipsBtn = self.transform:Find("Tips"):GetComponent(Button)
    tipsBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = tipsBtn.gameObject, itemData = self.runeTips}) end)

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BaseUtils.ShowEffect(20049, self.transform, Vector3.one, Vector3(0, 0, -1000))
    self.effect:SetActive(false)
    -- self:Update()
end

function PetRunePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PetRunePanel:OnOpen()
    self:RemoveListeners()
    PetManager.Instance.OnPetUpdate:Add(self.listener)
    PetManager.Instance.OnPetRuneStudyUpgrade:Add(self.effectListener)
    self:Update()
end

function PetRunePanel:OnHide()
    self:RemoveListeners()
end

function PetRunePanel:RemoveListeners()
    PetManager.Instance.OnPetUpdate:Remove(self.listener)
    PetManager.Instance.OnPetRuneStudyUpgrade:Remove(self.effectListener)
end

function PetRunePanel:Update()
    if self.model.cur_petdata == nil then return end
    self.runedata = BaseUtils.copytab(self.model.cur_petdata.pet_rune)

    for index, item in ipairs(self.runeItemList) do
        self:SetDefaultItem(item, index)
    end
    self:SetDefaultItem(self.smartItem)

    -- BaseUtils.dump(self.runedata,"内丹大界面数据")

    self.noticeString = string.format(TI18N("<color='#ffff00'>%s</color>最多开启<color='#ffff00'>%s</color>个普通内丹"), self.model.cur_petdata.name, #self.runedata - 1)
    if DataPet.data_pet[self.model.cur_petdata.base.id].has_break_skill == 1 and self.model.cur_petdata.break_times == 0 then
        self.noticeString = string.format(TI18N("%s突破后可开启"), self.model.cur_petdata.name)
    end
    
    for _, v in ipairs(self.runedata) do
        if v.rune_type == 1 then 
            -- print(v.rune_index)
            self:SetItemData(self.runeItemList[v.rune_index],v)
        elseif v.rune_type == 2 then 
            self:SetItemData(self.smartItem,v)
        end
    end
end

function PetRunePanel:CreateItem(transform)
    local item = {}
    item["trans"] = transform 
    item["btn"] = transform:Find("BgImg"):GetComponent(Button)
    item["iconImg"] = transform:Find("BgImg/IconImg")
    item["iconloader"] = SingleIconLoader.New(item.iconImg.gameObject)
    item["abledImg"] = transform:Find("BgImg/AbledImg")
    item["lockImg"] = transform:Find("BgImg/LockImg")
    item["txt"] = transform:Find("TxtBg/Text"):GetComponent(Text)
    item["upgrade"] = transform:Find("BgImg/Upgrade").gameObject

    item["effect"] = BaseUtils.ShowEffect(20522, item.iconImg, Vector3.one, Vector3(0, 0, -500))
    item.effect:SetActive(false)

    item["effect2"] = BaseUtils.ShowEffect(20523, item.iconImg:Find("Effect"), Vector3.one, Vector3(0, 0, -500))
    item.effect2:SetActive(false)

    item.lockImg.gameObject:SetActive(true)
    item.abledImg.gameObject:SetActive(false)
    item.iconImg.gameObject:SetActive(false)
    item.upgrade:SetActive(false)
    
    item.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(self.noticeString) end)
    return item
end 

function PetRunePanel:SetDefaultItem(item, index)
    item.lockImg.gameObject:SetActive(true)
    item.abledImg.gameObject:SetActive(false)
    item.iconImg.gameObject:SetActive(false)
    item.upgrade:SetActive(false)
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(self.noticeString) end)
    item.txt.text = TI18N("未开启")
    item.effect:SetActive(false)
    item.effect2:SetActive(false)
end 


function PetRunePanel:SetItemData(item,data)
    item.lockImg.gameObject:SetActive(data.rune_status == 0)
    item.abledImg.gameObject:SetActive(data.rune_status == 1)
    

    local txtString = ""
    local fun
    -- local name = rune_id.name
    if data.rune_status == 0 then 
        txtString = TI18N("可学习")
        item.lockImg.gameObject:SetActive(false)
        item.abledImg.gameObject:SetActive(true)
        item.iconImg.gameObject:SetActive(false)
        fun = function() self.model:OpenPetRuneStudyPanel({type = data.rune_type, rune_index = data.rune_index}) end
    elseif data.rune_status == 1 or data.rune_status == 2 or data.rune_status == 3 then 
        local key = BaseUtils.Key(data.rune_id, data.rune_lev)
        local rune_data = DataRune.data_rune[key]
        txtString = string.format("%s·%s", rune_data.name, rune_data.lev)
        item.lockImg.gameObject:SetActive(false)
        item.abledImg.gameObject:SetActive(false)
        item.iconImg.gameObject:SetActive(true)
        item.iconloader:SetSprite(SingleIconType.SkillIcon, DataSkill.data_petSkill[BaseUtils.Key(rune_data.skill_id, "1")].icon)
        -- item.iconloader:SetSprite(SingleIconType.Item, DataItem.data_get[data.rune_id].icon)
        data.pet_id = self.model.cur_petdata.id
        fun =  function(id) TipsManager.Instance:ShowRuneTips({itemData = data, gameObject = item.trans.gameObject}) end
    else
        item.lockImg.gameObject:SetActive(true)
        item.abledImg.gameObject:SetActive(false)
        item.iconImg.gameObject:SetActive(false)
    end
    item.txt.text = txtString

    item.upgrade:SetActive(data.rune_status == 2)

    item.effect:SetActive(data.is_resonance == 1)
    item.effect2:SetActive(data.is_resonance == 1)

    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(fun)
end 


function PetRunePanel:SetEffect(data)
    local rune_id = data.rune_id
    local rune_index = data.rune_index
    local runedata = DataRune.data_rune[BaseUtils.Key(rune_id,"1")]

    local pos
    if runedata.quality == 2 then 
        pos = self.smartItem.trans.position
    else
        pos = self.runeItemList[rune_index].trans.position
    end

    self.effect.transform.position = pos

    self.effect:SetActive(false)
    self.effect:SetActive(true)
    self.effect:SetActive(false)
end 
