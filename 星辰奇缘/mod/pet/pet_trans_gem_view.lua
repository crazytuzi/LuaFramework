-- region *.lua
-- Date
-- jia  2017-7-16
-- 宠物幻化选择幻化石界面
-- endregion

PetTransGemView = PetTransGemView or BaseClass(BasePanel)

function PetTransGemView:__init(model, parent)
    self.model = model
    self.parent = parent;
    self.name = "PetTransGemView"

    self.resList = {
        { file = AssetConfig.pet_trans_gen_panel, type = AssetType.Main }
        ,{ file = AssetConfig.pet_textures, type = AssetType.Dep }
    }
    self.selectitem = nil
    self.geniconlist = { }
    self.itemList = { }
    self.itemSlotlist = { }
    self.open_pet_trans = function()
        self:OpenPetTrans()
    end
    self.OnOpenEvent:Add( function() self:OnShow() end)
end

function PetTransGemView:__delete()
    for k, v in pairs(self.itemSlotlist) do
        v:DeleteMe()
        v = nil
    end

    for k, v in pairs(self.geniconlist) do
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

function PetTransGemView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_trans_gen_panel))
    self.gameObject.name = "PetTransGemView"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener( function() self:OnClickClose() end)
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener( function() self:OnClickClose() end)

    self.itemcontainer = self.transform:FindChild("Main/mask/ItemContainer").gameObject
    self.noitemtips = self.transform:FindChild("Main/mask/NoItemTips").gameObject
    self.noitemtips:SetActive(false);
    self.noitemtips.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener( function() self:open_pet_trans() end)
    self.noitemtips.transform:FindChild("Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetMainUiIconSprite("347")

    self.noitemtips.transform:FindChild("I18N_Text_Title"):GetComponent(Text).text = TI18N("当前宠物可幻化")

    self.noitemtips.transform:FindChild("I18N_Text_Desc"):GetComponent(Text).text = TI18N("您背包中没有宠物幻化道具可以通过龙王试炼活动获得")

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener( function() self:button_click() end)
    self.okButton:SetActive(false)
    self.transform:FindChild("Main/OkButton/Text"):GetComponent(Text).text = TI18N("宠物幻化");
    self.descText = self.transform:FindChild("Main/DescText"):GetComponent(Text)

    self:OnShow()
    self:ClearMainAsset()
end

function PetTransGemView:OnClickClose()
    self.model:CloseTransGemView()
end

function PetTransGemView:OnShow()
    self.descText.text = ""
    self.okButton:SetActive(false)
    self:update()
end

function PetTransGemView:OnHide()
    self.selectitem = nil
    self.selectitemdata = nil
end

function PetTransGemView:update()
    if self.model.cur_petdata == nil then return end

    for k, v in pairs(self.itemList) do
        GameObject.Destroy(v)
    end
    self.itemList = { }
    local transgem_list = BackpackManager.Instance:GetItemByType(BackpackEumn.ItemType.pettrans)
    local itempanel = self.itemcontainer
    local itemobject = itempanel.transform:FindChild("Item").gameObject
    local index = 0;
    if #transgem_list > 0 then
        itempanel:SetActive(true)
        for _, itemdata in pairs(transgem_list) do
            if itemdata.expire_time - BaseUtils.BASE_TIME > 0 then
                index = index + 1;
                local item = self.itemList[index]
                if item == nil then
                    item = GameObject.Instantiate(itemobject)
                    UIUtils.AddUIChild(itempanel, item)
                    self.itemList[index] = item
                    local fun = function()
                        self:item_click(item, itemdata)
                    end
                    item:GetComponent(Button).onClick:AddListener(fun)
                end
                local slot = self.itemSlotlist[index];
                if slot == nil then
                    slot = ItemSlot.New()
                    UIUtils.AddUIChild(item.transform:FindChild("Item").gameObject, slot.gameObject)
                    self.itemSlotlist[index] = slot
                end
                slot:SetAll(itemdata)
                item.transform:FindChild("Name"):GetComponent(Text).text = itemdata.name
                self:setitemattr(item, itemdata.base_id)
            end
        end
    end
    if index == 0 then
        itempanel:SetActive(false)
        self.noitemtips:SetActive(true);
        local iconpanel = self.transform:FindChild("Main/mask/NoItemTips/IconPanel").gameObject
        local iconobject = iconpanel.transform:FindChild("Icon").gameObject
        local data_pet_gem = DataPet.data_pet_trans;
        local i = 0;
        for _, item in pairs(data_pet_gem) do
            i = i + 1;
            local genicon = self.geniconlist[i]
            if genicon == nil then
                local object = GameObject.Instantiate(iconobject)
                UIUtils.AddUIChild(iconpanel, object)
                local slot = ItemSlot.New()
                UIUtils.AddUIChild(object, slot.gameObject)
                slot.name = "Slot"
                genicon = { object = object, slot = slot }
                table.insert(self.geniconlist, genicon)
            end
            local base_id = item.item_id
            local base_data = ItemData.New()
            base_data:SetBase(BackpackManager.Instance:GetItemBase(base_id))
            if base_data ~= nil then
                genicon.slot:SetAll(base_data)

                genicon.object.transform:FindChild("Text"):GetComponent(Text).text = ColorHelper.color_item_name(base_data.quality, BaseUtils.string_cut(base_data.name, 15, 12))
            end
            genicon.object:SetActive(true)
        end
    end
end

function PetTransGemView:setitemattr(item, base_id)
    local skill_str = ""
    local tmp = DataPet.data_pet_trans[base_id];
    if tmp ~= nil then
        for k, v in pairs(tmp.skills) do
            skill_str = skill_str .. string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v[1])].name)
        end
        item.transform:FindChild("Desc"):GetComponent(Text).text = TI18N("技能:")
        item.transform:FindChild("Skill"):GetComponent(Text).text = skill_str
    end
end

function PetTransGemView:item_click(item, itemdata)
    if self.selectitem ~= nil then
        self.selectitem.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.selectitem = item
    self.selectitemdata = itemdata
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self.okButton:SetActive(true)
    if DataPet.data_pet_trans_black[self.model.cur_petdata.base_id] ~= nil then
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = string.format(TI18N("不可幻化"), self.model.transLev);
    else
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("穿戴")
    end
    local skill_str = ""
    local tmp = DataPet.data_pet_trans[itemdata.base_id];
    if tmp ~= nil then
        for k, v in pairs(tmp.skills) do
            skill_str = skill_str .. string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v[1])].name)
        end
    end
    self.descText.text = string.format(TI18N("附带技能: %s"), skill_str)
end

function PetTransGemView:button_click()
    if self.selectitemdata ~= nil then
        if DataPet.data_pet_trans_black[self.model.cur_petdata.base_id] ~= nil then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("宠物出战等级不足，需要<color='#00ff00'>%s级</color>才能装备"), self.model.transLev))
        else
            if #self.model.cur_petdata.unreal == 0 then
                PetManager.Instance:Send10508(self.model.cur_petdata.id, self.selectitemdata.id)
                self:OnClickClose()
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.cancelLabel = TI18N("取消")
                data.sureCallback =
                function()
                    PetManager.Instance:Send10508(self.model.cur_petdata.id, self.selectitemdata.id)
                    self:OnClickClose()
                end
                data.content = TI18N("您的宠物已经穿戴幻化道具，是否更换幻化道具？")
                data.sureLabel = TI18N("更换")
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

function PetTransGemView:OpenPetTrans()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain)
end