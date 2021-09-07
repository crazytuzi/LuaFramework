-- ----------------------------------------------------------
-- UI - 子女符石窗口
-- ----------------------------------------------------------
PetChildGemView = PetChildGemView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetChildGemView:__init(model)
    self.model = model
    self.name = "PetChildGemView"
    self.windowId = WindowConfig.WinID.petchildgemwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.pet_gen_window, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
	self.selectitem = nil
	self.geniconlist = {}
	self.itemList = {}

	self.itemcontainer =  nil
	self.noitemtips =  nil
	self.okButton =  nil
	self.descText  = nil
    self.rrecommendSkillButton = nil
    self.buyButton = nil

    self.itemSlotlist = {}
	------------------------------------------------
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.needLev = 0
end

function PetChildGemView:__delete()
    for k,v in pairs(self.itemSlotlist) do
        v:DeleteMe()
        v = nil
    end

    for k,v in pairs(self.geniconlist) do
        v.slot:DeleteMe()
        v.slot = nil
    end

    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetChildGemView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_gen_window))
    self.gameObject.name = "PetChildGemView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.transform:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("子女装备")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.itemcontainer = self.transform:FindChild("Main/mask/ItemContainer").gameObject

    self.noitemtips = self.transform:FindChild("Main/mask/NoItemTips").gameObject
    local no = self.transform:Find("Main/mask/NoItemTips")
    no:GetChild(0):GetComponent(Text).text = TI18N("<color='#ffff9a'>当前子女品阶可穿戴</color>")
    no:GetChild(3):GetComponent(Text).text = TI18N("您背包中没有子女装备\n可以到<color='#ffff9a'>神秘商店</color>中购买")
    self.noitemtips.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:open_gold_market() end)
    self.noitemtips.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetMainUiIconSprite("I18NShopButtonIcon")

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.okButton:SetActive(false)

    self.descText = self.transform:FindChild("Main/DescText"):GetComponent(Text)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetChildGemView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PetChildGemView:OnShow()
    self.hole_id = self.openArgs.hold_id
    self.replace = self.openArgs.replace
    self.child = PetManager.Instance.model.currChild
	self.descText.text = ""
	self.okButton:SetActive(false)
	self:update()

    if PetManager.Instance.model:CheckChildCanFollow() then
        local child = PetManager.Instance.model.currChild
        ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
    end
end

function PetChildGemView:OnHide()
	self.selectitem = nil
    self.selectitemdata = nil
end

function PetChildGemView:update()
    if self.child == nil then return end

    for k,v in pairs(self.itemList) do
        GameObject.Destroy(v)
    end
    self.itemList = {}

    local baseData = DataChild.data_equip_gem[string.format("%s_%s_%s", self.child.base_id, self.child.grade, self.hole_id)]
    if baseData == nil then
        return
    end
    self.needLev = baseData.need_lev

    local data_pet_gem = baseData.allow_stone
    local canList = {}
    for i,v in ipairs(data_pet_gem) do
        local list = BackpackManager.Instance:GetItemByBaseid(v)
        for i,item in ipairs(list) do
            table.insert(canList, item)
        end
    end

    local itempanel = self.itemcontainer
    local itemobject =  itempanel.transform:FindChild("Item").gameObject

    if #canList > 0 then
        itempanel:SetActive(true)
        self.noitemtips:SetActive(false)

        for i=1,#canList do
            local itemdata = canList[i]
            local item = GameObject.Instantiate(itemobject)
            UIUtils.AddUIChild(itempanel, item)
            table.insert(self.itemList, item)
            local fun = function()
                self:item_click(item, itemdata)
            end
            item:GetComponent(Button).onClick:AddListener(fun)

            local slot = ItemSlot.New()
            UIUtils.AddUIChild(item.transform:FindChild("Item").gameObject, slot.gameObject)
            slot:SetAll(itemdata)
            table.insert(self.itemSlotlist, slot)

            item.transform:FindChild("Name"):GetComponent(Text).text = itemdata.name
            self:setitemattr(item, itemdata.attr)
        end
    else
        itempanel:SetActive(false)
        self.noitemtips:SetActive(true)

        local iconpanel = self.transform:FindChild("Main/mask/NoItemTips/IconPanel").gameObject
        local iconobject =  iconpanel.transform:FindChild("Icon").gameObject
        for i=1,#data_pet_gem do
            local genicon = self.geniconlist[i]
            if genicon == nil then
                local object = GameObject.Instantiate(iconobject)
                UIUtils.AddUIChild(iconpanel, object)

                local slot = ItemSlot.New()
                UIUtils.AddUIChild(object, slot.gameObject)
                slot.name = "Slot"

                genicon = {object = object, slot = slot}
                table.insert(self.geniconlist, genicon)
            end
            local base_id = data_pet_gem[i]
            local base_data = ItemData.New()
            base_data:SetBase(BackpackManager.Instance:GetItemBase(base_id))
            if base_data ~= nil then
                genicon.slot:SetAll(base_data)

                genicon.object.transform:FindChild("Text"):GetComponent(Text).text = ColorHelper.color_item_name(base_data.quality, BaseUtils.string_cut(base_data.name, 15, 12))
            end

            genicon.object:SetActive(true)
        end

        for i=#data_pet_gem+1, #self.geniconlist do
            self.geniconlist[i].object:SetActive(false)
        end
    end
end

function PetChildGemView:setitemattr(item, attr)
    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s+%s", KvData.attr_name[v.name], v.val)
            else
                local data = DataSkill.data_child_skill[v.val]
                if data ~= nil then
                    skill_str = skill_str..string.format("[%s]", data.name)
                end
            end
        end
    end
    if attr_str == "" then
        item.transform:FindChild("Desc"):GetComponent(Text).text = TI18N("技能:")
        item.transform:FindChild("Skill"):GetComponent(Text).text = skill_str
    else
        item.transform:FindChild("Desc"):GetComponent(Text).text = attr_str
    end
end

function PetChildGemView:open_gold_market()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, {1, 3, 9})
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1,3})
end

function PetChildGemView:item_click(item, itemdata)
    if self.selectitem ~= nil then
        self.selectitem.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.selectitem = item
    self.selectitemdata = itemdata
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self.okButton:SetActive(true)
    if self.child.lev < self.needLev then
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = string.format(TI18N("%s级可用"), self.needLev)
    else
        if self.replace then
            self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("覆盖")
        else
            self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("穿戴")
        end
    end


    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(itemdata.attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s: <color='#00ff00'>+%s</color>", KvData.attr_name[v.name], v.val)
            else
                -- print(v.val)
                skill_str = skill_str..string.format("<color='#00ff00'>[%s]</color>", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
            end
        end
    end
    if attr_str == "" then
        self.descText.text = string.format(TI18N("附带技能: %s"), skill_str)
    else
        self.descText.text = string.format(TI18N("增加子女%s"), attr_str)
    end
end

function PetChildGemView:button_click()
    if self.selectitemdata ~= nil then
        if self.needLev > self.child.lev then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("孩子等级不足，需要<color='#00ff00'>%s级</color>才能装备"), self.needLev))
        else
            if self.child.grade <= 1 then
                ChildrenManager.Instance:Require18616(self.child.child_id, self.child.platform, self.child.zone_id, self.selectitemdata.id, self.hole_id)
                self:OnClickClose()
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                        ChildrenManager.Instance:Require18616(self.child.child_id, self.child.platform, self.child.zone_id, self.selectitemdata.id, self.hole_id)
                        self:OnClickClose()
                    end
                if self.child.grade == 2 then
                    if self.replace then
                        data.content = TI18N("您的孩子已进到最高阶，穿戴新装备将<color='#ffff00'>覆盖原有装备</color>，是否确定穿戴？")
                        data.sureLabel = TI18N("覆盖")
                    else
                        data.content = TI18N("您的孩子已进到最高阶，此阶段装备项链或装备将<color='#ffff00'>无法再卸下</color>（但可被其它项链或装备覆盖），是否确定穿戴？")
                        data.sureLabel = TI18N("穿戴")
                    end
                elseif self.child.grade == 3 then
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end