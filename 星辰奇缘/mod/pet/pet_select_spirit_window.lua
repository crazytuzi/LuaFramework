PetSelecttSpirtWindow = PetSelecttSpirtWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function PetSelecttSpirtWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.petselect
    self.name = "PetSelecttSpirtWindow"
    self.resList = {
        {file = AssetConfig.petspiritselectpanel, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.Layout = nil
    self.CopyItem = nil

    self.buttonType = 1
    self.headLoaderList = {}

    -----------------------------------------
    self.select_item = nil
    self.select_data = nil
end

function PetSelecttSpirtWindow:__delete()
    if self.headLoaderList ~= nil then
     for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self:ClearDepAsset()
end

function PetSelecttSpirtWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petspiritselectpanel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform.localPosition = Vector3(0, 0, -400)

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CopyItem = self.transform:Find("Main/mask/Item").gameObject
    self.CopyItem:SetActive(false)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = nil
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/mask")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("Main/mask/ItemContainer"), setting)

    self.transform:Find("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OkButtonClick() end)

    self.tipsText = self.transform:Find("Main/TipsText"):GetComponent(Text)

    self.transform:Find("Main/DescText").gameObject:SetActive(false)

    self.transform:Find("Main/mask").gameObject:SetActive(true)

    self:UpdateList()
end

function PetSelecttSpirtWindow:Close()
    self.model:ClosePetSelecttSpirtWindow()
end

function PetSelecttSpirtWindow:UpdateList()
    local temp = BaseUtils.copytab(self.model:GetMasterPetList())

    local list = {}
    for k,v in ipairs(temp) do
        if v.id ~= self.model.cur_petdata.id and #v.attach_pet_ids == 0  and v.status ~= 1 and self.model:GetPetSpirtScoreBySkillLevel(v.base_id, 0) ~= nil then
            table.insert(list, v)
        end
    end

    local function sortfun(a,b)
        local a_spirtdata = self.model:CheckPetSpirtUp(a, self.model.cur_petdata)
        local b_spirtdata = self.model:CheckPetSpirtUp(b, self.model.cur_petdata)

        return (a_spirtdata == nil and b_spirtdata ~= nil)
                or ((a_spirtdata ~= nil and b_spirtdata ~= nil) and a.talent > b.talent)
                or ((a_spirtdata == nil and b_spirtdata == nil) and a.talent > b.talent)
    end
    table.sort(list, sortfun)

    if self.model.battle_petdata ~= nil and self.model:GetPetSpirtScoreBySkillLevel(self.model.battle_petdata.base_id, 0) ~= nil then
        local mainPetData = self.model.cur_petdata
        local petData = self.model.battle_petdata

        if ((mainPetData.genre == 2 or mainPetData.genre == 4) and (petData.genre ~= 2 and petData.genre ~= 4))
            or (petData.lev < petData.base.manual_level + 5)
            or (petData.talent < 3600)
            or (petData.base.manual_level < mainPetData.base.manual_level -5 and (petData.genre ~= 2 and petData.genre ~= 4))
            or (#petData.attach_pet_ids > 0) then

        else
            table.insert(list, 1, BaseUtils.copytab(self.model.battle_petdata))
        end
    end

    for index, value in ipairs(self.model.cur_petdata.attach_pet_ids) do
        local attachPetData = self.model:getpet_byid(value)
        table.insert(list, 1, attachPetData)
    end


    for k,v in ipairs(list) do
        local item = GameObject.Instantiate(self.CopyItem)
        self:SetItem(item, v)
        self.Layout:AddCell(item.gameObject)
    end

    self.Layout:ReSize()

    if #list == 0 then
        self.tipsText.gameObject:SetActive(true)
    else
        self.tipsText.gameObject:SetActive(false)
    end
end

function PetSelecttSpirtWindow:SetItem(item, data)
    local its = item.transform
    local headId = tostring(data.base.head_id)
    local headImage = its.transform:FindChild("Head_78/Head"):GetComponent(Image)

    local loaderId = headImage.gameObject:GetInstanceID()
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
    -- headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
    -- headImage:SetNativeSize()
    headImage.rectTransform.sizeDelta = Vector2(54, 54)
    -- headImage.gameObject:SetActive(true)

    local headbg = self.model:get_petheadbg(data)
    its.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
        = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

    its:Find("LVText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("NameText"):GetComponent(Text).text = data.name

    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(item, data) end)


    if data.talent < 3600 then
        its:Find("PointText"):GetComponent(Text).text = string.format("<color='#ff0000'>%s(%s)</color>", self.model:gettalentclass(data.talent), data.talent)
    else
        its:Find("PointText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(data.talent), data.talent)
    end

    if data.master_pet_id ~= 0 then
        its:Find("StateText"):GetComponent(Text).text = TI18N("<color='#3267ae'>附灵中</color>")
    elseif data.status == 1 then
        its:Find("StateText"):GetComponent(Text).text = TI18N("<color='#ffff66'>出战中</color>")
    else
        local destString = self.model:CheckPetSpirtUp(data, self.model.cur_petdata)
        if destString == nil then
            its:Find("StateText"):GetComponent(Text).text = TI18N("<color='#229900'>可附灵</color>")
             its:Find("PointText"):GetComponent(Text).text = string.format("%s(%s)", self.model:gettalentclass(data.talent), data.talent)
        else
            its:Find("StateText"):GetComponent(Text).text = TI18N("<color='#898989'>不可附灵</color>")
            its:Find("PointText"):GetComponent(Text).text = string.format("<color='#ff0000'>%s(%s)</color>", self.model:gettalentclass(data.talent), data.talent)
        end
    end

    local skillSlot = SkillSlot.New()
    UIUtils.AddUIChild(its:FindChild("SkillIcon").gameObject, skillSlot.gameObject)

    local data_pet_spirt_score = self.model:GetPetSpirtScoreByTalent(data.base_id, data.talent)
    if data_pet_spirt_score == nil or #data_pet_spirt_score.skills == 0 then
        data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(data.base_id, 0)
    end
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_pet_spirt_score.skills[1][1], data_pet_spirt_score.skills[1][2])]
    skillSlot:SetAll(Skilltype.petskill, skillData)

    if self.select_item == nil and self.select_data == nil then
        self:OnClickItem(item, data)
    end
end

function PetSelecttSpirtWindow:OnClickItem(item, data)
    if self.select_item ~= nil then
        self.select_item.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.select_item = item
    self.select_data = data
    self.select_item.transform:FindChild("Select").gameObject:SetActive(true)

    self:UpdateButton()
end

function PetSelecttSpirtWindow:UpdateButton()
    if self.select_data.master_pet_id == 0 then
        self.buttonType = 1

        local destString = self.model:CheckPetSpirtUp(self.select_data, self.model.cur_petdata)
        if destString == nil then
            self.transform:Find("Main/OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton3Str, TI18N("附  灵"))
            self.transform:Find("Main/OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.transform:Find("Main/OkButton").gameObject:SetActive(true)
            self.transform:Find("Main/DescText").gameObject:SetActive(false)
        else
            self.transform:Find("Main/OkButton").gameObject:SetActive(false)
            self.transform:Find("Main/DescText").gameObject:SetActive(true)
            self.transform:Find("Main/DescText"):GetComponent(Text).text = destString
        end
    else
        self.buttonType = 2
        self.transform:Find("Main/OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton2Str, TI18N("卸  下"))
        self.transform:Find("Main/OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.transform:Find("Main/OkButton").gameObject:SetActive(true)
        self.transform:Find("Main/DescText").gameObject:SetActive(false)
    end
end

function PetSelecttSpirtWindow:OkButtonClick()
    if self.select_data == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择附灵宠"))
    else
        if self.buttonType == 1 then
            self:Close()

            -- local data = NoticeConfirmData.New()
            -- data.type = ConfirmData.Style.Normal
            -- data.content = string.format(TI18N("确定将[%s]附灵到[%s]吗？"), self.select_data.name, self.model.cur_petdata.name)
            -- data.sureLabel = TI18N("确认")
            -- data.cancelLabel = TI18N("取消")
            -- data.sureCallback = function()
            --         PetManager.Instance:Send10561(self.model.cur_petdata.id, self.select_data.id)
            --     end
            -- NoticeManager.Instance:ConfirmTips(data)

            self.model.tempSpirtMainPetData = BaseUtils.copytab(self.model.cur_petdata)
            self.model.tempSpirtSubPetData = BaseUtils.copytab(self.select_data)
            PetManager.Instance:Send10561(self.model.cur_petdata.id, self.select_data.id)
        elseif self.buttonType == 2 then
            self:Close()
            PetManager.Instance:Send10562(self.select_data.id)
        end
    end
end