-- -------------------------------------------
-- 子女天赋
-- hosr
-- -------------------------------------------
PetChildTelentView = PetChildTelentView or BaseClass(BasePanel)

function PetChildTelentView:__init(parent)
	self.parent = parent
    self.name = "PetView_ChildTelent"
    self.resList = {
        {file = AssetConfig.petwindow_childtelentpanel, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.childtelenticon, type = AssetType.Dep}
    }

    self.itemList = {}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.telentListener = function() self:Update() end
    self.infoListener = function() self:UpdateInfo() end

    self.isUp = false
    self.currIndex = 0
    self.currItem = nil
end

function PetChildTelentView:__delete()
    self:OnHide()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end

    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end

    if self.buyBtn ~= nil then
        self.buyBtn:DeleteMe()
        self.buyBtn = nil
    end

    if self.msg ~= nil then
        self.msg:DeleteMe()
        self.msg = nil
    end

    if self.skillIcon ~= nil then
        self.skillIcon.sprite = nil
    end
end

function PetChildTelentView:OnShow()
    self:RemoveListeners()
    self:AddListeners()
    self:Update()
end

function PetChildTelentView:OnHide()
    self:RemoveListeners()
end

function PetChildTelentView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petwindow_childtelentpanel))
    self.gameObject.name = "PetView_ChildTelent"
    self.gameObject.transform:SetParent(self.parent.panelContainer)
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject.transform.localPosition = Vector3.zero

    self.transform = self.gameObject.transform

    self.transform:Find("Tips"):GetComponent(Text).text = TI18N("PVP活动战斗中，子女登场时<color='#ffff9a'>随机一个</color>天赋技能获得<color='#ffff9a'>熟练度+1</color>")

    self.skillIcon = self.transform:Find("Info/SkillIcon"):GetComponent(Image)
    self.skillName = self.transform:Find("Info/SkillName"):GetComponent(Text)
    self.skillLev = self.transform:Find("Info/SkillLev"):GetComponent(Text)
    self.desc = self.transform:Find("Info/Desc"):GetComponent(Text)
    self.transform:Find("Info/Desc/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")
    self.transform:Find("Info/ChangeButton"):GetComponent(Button).onClick:AddListener(function() self:ClickChange() end)
    self.slider = self.transform:Find("Info/Normal/Slider"):GetComponent(Slider)
    self.sliderVal = self.transform:Find("Info/Normal/Slider/Val"):GetComponent(Text)
    -- self.transform:Find("Info/TrainButton"):GetComponent(Button).onClick:AddListener(function() self:ClickTrain() end)
    self.btnTxt = self.transform:Find("Info/Normal/TrainButton/Text"):GetComponent(Text)

    self.buyBtn = BuyButton.New(self.transform:Find("Info/Normal/TrainButton").gameObject, TI18N("训练"))
    self.buyBtn.key = "ChildTalent"
    self.buyBtn.protoId = 18625
    self.buyBtn:Show()

    self.itemName = self.transform:Find("Info/Normal/ItemName"):GetComponent(Text)
    self.itemNum = self.transform:Find("Info/Normal/ItemNum"):GetComponent(Text)
    self.itemNum.text = ""
    local rect = self.transform:Find("Info/Normal/ItemNum"):GetComponent(RectTransform)
    self.msg = MsgItemExt.New(self.itemNum, 120)

    self.transform:Find("Info/Normal/Preview"):GetComponent(Button).onClick:AddListener(function() self:ClickPreview() end)

    -- self.itemNum.gameObject:SetActive(true)
    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Info/Normal/Slot").gameObject, self.slot.gameObject)

    local container = self.transform:Find("SkillContainer")
    local len = container.childCount
    for i = 1, len do
        local item = PetChildTelnetItem.New(container:Find("Item" .. i).gameObject, self, i)
        table.insert(self.itemList, item)
    end

    self.normal = self.transform:Find("Info/Normal").gameObject
    self.full = self.transform:Find("Info/Full").gameObject
    self.fullDesc = self.transform:Find("Info/Full/Text"):GetComponent(Text)

    self:OnShow()
end

function PetChildTelentView:ClickChange(i)
    local index = nil
    local lev = 1
    if i == nil then
        index = self.currIndex
    else
        index = i
    end

    local telent = self.child.talent_skills[index]
    if telent ~= nil then
        lev = telent.lev
    end

    local info = {child = self.child, index = index, lev = lev}
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_change_telnet, info)
end

function PetChildTelentView:ClickTrain()
    -- if not self.isUp and BackpackManager.Instance:GetItemCount(self.item_id) == 0 then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("所需的技能书数量不足"))
    --     self.slot:SureClick()
    --     return
    -- end
    ChildrenManager.Instance:Require18625(self.child.child_id, self.child.platform, self.child.zone_id, self.item_id)
end

function PetChildTelentView:CliekOne(index)
    if self.currItem ~= nil then
        self.currItem:Select(false)
    end
    self.currIndex = index
    self.currItem = self.itemList[self.currIndex]
    self.currItem:Select(true)
    self:UpdateInfo()
end

-- 更新格子状态
function PetChildTelentView:UpdateGrids()
    local grade = self.child.grade + 1
    for i,item in ipairs(self.itemList) do
        if i > grade then
            item:Default()
            item:Lock(true)
        else
            item:Lock(false)
            local telent = self.child.talent_skills[i]
            item:SetData(telent)
        end
    end
end

function PetChildTelentView:Update()
    self.isUp = false
    self.child = PetManager.Instance.model.currChild
    if self.child == nil then
        return
    end

    self:UpdateGrids()

    if self.currIndex == 0 then
        self.itemList[1]:ClickSelf()
    else
        if self.itemList[self.currIndex].data ~= nil then
            self.itemList[self.currIndex]:ClickSelf()
        else
            self.itemList[1]:ClickSelf()
        end
    end
end

function PetChildTelentView:UpdateInfo()
    if self.currItem == nil or self.currItem.skillData == nil then
        return
    end

    local skillData = self.currItem.skillData
    local data = self.currItem.data
    self.skillIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.childtelenticon, skillData.icon)
    self.skillName.text = skillData.name
    self.skillLev.text = data.lev .. TI18N("级")
    self.desc.text = skillData.desc
    self.slider.value = data.exp / skillData.max_exp
    self.sliderVal.text = string.format("%s/%s", data.exp, skillData.max_exp)

    local id = skillData.loss[1][1]
    local num = skillData.loss[1][2]
    local has = BackpackManager.Instance:GetItemCount(id)
    local itemdata = DataItem.data_get[id]
    self.slot:SetAll(itemdata)
    self.slot:SetNum(has, num)
    self.itemName.text = itemdata.name
    self.itemNum.text = string.format("%s/%s", num, has)
    self.item_id = id

    local role = RoleManager.Instance.RoleData

    local bool = false
    local isbreak = false
    local lev = 0
    self.itemNum.text = ""
    local items = {[self.item_id] = {need = 1}}
    if role.lev_break_times > skillData.need_lev_break then
        bool = true
    elseif role.lev_break_times < skillData.need_lev_break then
        bool = false
        isbreak = true
        lev = skillData.need_lev
    else
        if role.lev >= skillData.need_lev then
            bool = true
        else
            bool = false
            lev = skillData.need_lev
        end
    end

    if bool then
        if data.exp == skillData.max_exp then
            self.buyBtn.content = TI18N("升级")
            self.isUp = true
            items = {}
        else
            self.buyBtn.content = TI18N("训练")
            self.isUp = false
        end
    else
        if data.exp >= skillData.max_exp then
            self.isUp = true
            items = {}
            if isbreak then
                self.buyBtn.content = string.format(TI18N("突破%s级"), lev)
            else
                self.buyBtn.content = string.format(TI18N("需要%s级"), lev)
            end
        else
            self.isUp = false
            self.buyBtn.content = TI18N("训练")
        end
    end

    self.buyBtn:ReleaseFrozon()
    self.buyBtn:Layout(items, function() self:ClickTrain() end, function(data) self:PriceBack(data) end)

    if self.currItem.isFull then
        self.normal:SetActive(false)
        self.full:SetActive(true)
        self.fullDesc.text = string.format(TI18N("<color='#ffff9a'>%s</color>已达到最高等级"), skillData.name)
    else
        self.normal:SetActive(true)
        self.full:SetActive(false)
        self.fullDesc.text = ""
    end
end

function PetChildTelentView:PriceBack(data)
    local data = data[self.item_id]
    if data == nil then
        self.itemNum.text = ""
        self.msg:SetData("")
        return
    end

    local price = ""
    if data.allprice == 0 then
        price = ""
    elseif data.allprice > 0 then
        price = string.format("<color='#ffff9a'>%s</color>{assets_2,%s}", data.allprice, data.assets)
    elseif data.allprice < 0 then
        price = string.format("<color='#df3435'>%s</color>{assets_2,%s}", math.abs(data.allprice), data.assets)
    end

    self.itemNum.text = ""
    self.msg:SetData(price)
end

function PetChildTelentView:ClickPreview()
    local info = {skillid = self.currItem.skillData.id, skilllev = self.currItem.skillData.lev}
    PetManager.Instance.model:OpenChildTelentPreview(info)
end

function PetChildTelentView:AddListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.infoListener)
    ChildrenManager.Instance.OnChildTelentUpdate:Add(self.telentListener)
end

function PetChildTelentView:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.infoListener)
    ChildrenManager.Instance.OnChildTelentUpdate:Remove(self.telentListener)
end

