MarrySkillWindow = MarrySkillWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function MarrySkillWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marryskillwindow
    self.name = "MarrySkillWindow"
    self.resList = {
        {file = AssetConfig.marryskillwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.skillList = {}

    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._UpdateList = function() self:UpdateList() end
end


function MarrySkillWindow:__delete()
    self:OnHide()
    for i, v in ipairs(self.skillList) do
        v.loader:DeleteMe()
        v.loader = nil
    end
    self.skillList = {}
    self:ClearDepAsset()
end

function MarrySkillWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marryskillwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = self.transform:FindChild("Main/Mask/SoltPanel").gameObject
    self.skillItem = self.transform:FindChild("Main/SkillItem").gameObject

    self.okButton = self.transform:FindChild("Main/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.descButton = self.transform:FindChild("Main/DescButton").gameObject
    self.descButton:GetComponent(Button).onClick:AddListener(function() self:descButtonClick() end)

    self:OnShow()
end

function MarrySkillWindow:Close()
    self.model.newTalent = {}
    self:OnHide()

    WindowManager.Instance:CloseWindow(self)
    -- self.model:CloseMarrySkillWindow()
end

function MarrySkillWindow:OnShow()
    SkillManager.Instance.OnUpdateMarrySkill:Add(self._UpdateList)
    self:UpdateList()
    SkillManager.Instance:Send10822()
end

function MarrySkillWindow:OnHide()
    SkillManager.Instance.OnUpdateMarrySkill:Remove(self._UpdateList)
end

function MarrySkillWindow:UpdateList()
    local list = { self.model:getmarryskilldata(83000, 1), self.model:getmarryskilldata(83001, 1), self.model:getmarryskilldata(83002, 1) }
    for i,v in ipairs(list) do
        local skillItem = self.skillList[i]
        if skillItem == nil then
            local icon = GameObject.Instantiate(self.skillItem)
            UIUtils.AddUIChild(self.soltPanel, icon)
            local loader = SingleIconLoader.New(icon.transform:FindChild("Icon/Image").gameObject)
            skillItem = { icon = icon, loader = loader }
            table.insert(self.skillList, skillItem)
        end
        local icon = skillItem.icon
        self:SetItem(icon, v, i)

        if i == 3 and self.selectItem == nil and self.selectItemData == nil then
            self:ClickItem(icon, v)
        end
    end

    if self.selectItem ~= nil and self.selectItemData ~= nil then
        self:updateButton(self.selectItem, self.selectItemData)
    end
end

function MarrySkillWindow:SetItem(item, data, index)
    local skill_data = nil
    for k,v in pairs(self.model.marry_skill) do
        if data.id == v.id then
            skill_data = v
            break
        end
    end

    if skill_data == nil then
        self.model:On10822({ skill_data = {} })
        self:SetItem(item, data, index)
        return
    end

    -- item.transform:FindChild("Icon/Image"):GetComponent(Image).sprite
    --                     = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(data.icon))
    if self.skillList[index] ~= nil then
        self.skillList[index].loader:SetSprite(SingleIconType.SkillIcon, tostring(data.icon))
    end
    item.transform:FindChild("NameText"):GetComponent(Text).text = data.name
    if skill_data.lev == 0 then
        local skill_data_lev1 = self.model:getmarryskilldata(skill_data.id, 1)
        local roleData = RoleManager.Instance.RoleData
        if skill_data_lev1.intimacy <= FriendManager.Instance:GetIntimacy(roleData.lover_id, roleData.lover_platform, roleData.lover_zone_id) then
            item.transform:FindChild("StateText"):GetComponent(Text).text = TI18N("<color='#ffff00'>[可激活]</color>")
        else
            item.transform:FindChild("StateText"):GetComponent(Text).text = string.format(TI18N("<color='#ff0000'>亲密度:%s</color>"), skill_data_lev1.intimacy)
        end
    else
        item.transform:FindChild("StateText"):GetComponent(Text).text = TI18N("<color='#00ff00'>[已激活]</color>")
    end


    local btn = item:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:ClickItem(item, data) end)

    local skillTipsData = data
    local btn2 = item.transform:FindChild("Icon"):GetComponent(Button)
    btn2.onClick:RemoveAllListeners()
    btn2.onClick:AddListener(function() self:ClickItem(item, data) TipsManager.Instance:ShowSkill({gameObject = item, type = Skilltype.marryskill, skillData = skillTipsData}) end)

    if self.selectItem == nil and self.selectItemData == nil then
        if skill_data.lev == 0 then
            self:ClickItem(item, data)
        end
    end
end

function MarrySkillWindow:ClickItem(item, data)
    if self.selectItem ~= nil then
        self.selectItem.transform:FindChild("Select").gameObject:SetActive(false)
    end
    self.selectItem = item
    self.selectItemData = data

    self.selectItem.transform:FindChild("Select").gameObject:SetActive(true)

    self:updateButton(item, data)
end

function MarrySkillWindow:updateButton(item, data)
    local skill_data = nil
    for k,v in pairs(self.model.marry_skill) do
        if self.selectItemData.id == v.id then
            skill_data = v
            break
        end
    end

    if skill_data == nil then
        self.model:On10822({ skill_data = {} })
        self:updateButton(item, data)
        return
    end

    if skill_data.lev == 0 then
        local data = self.model:getmarryskilldata(skill_data.id, 1)
        if data.love_var == 0 then
            self.okButton.transform:FindChild("FreeText").gameObject:SetActive(true)
            self.okButton.transform:FindChild("FreeText"):GetComponent(Text).text = TI18N("免费激活")
            self.okButton.transform:FindChild("Text").gameObject:SetActive(false)
            self.okButton.transform:FindChild("Image").gameObject:SetActive(false)
        else
            self.okButton.transform:FindChild("FreeText").gameObject:SetActive(false)
            self.okButton.transform:FindChild("Text"):GetComponent(Text).text = string.format(TI18N("%s     激活"), data.love_var)
            self.okButton.transform:FindChild("Text").gameObject:SetActive(true)
            self.okButton.transform:FindChild("Image").gameObject:SetActive(true)
        end
    else
        self.okButton.transform:FindChild("FreeText").gameObject:SetActive(true)
        self.okButton.transform:FindChild("FreeText"):GetComponent(Text).text = TI18N("已激活")
        self.okButton.transform:FindChild("Text").gameObject:SetActive(false)
        self.okButton.transform:FindChild("Image").gameObject:SetActive(false)
    end
end

function MarrySkillWindow:okButtonClick()
    if self.selectItemData ~= nil then
        local skill_data = nil
        for k,v in pairs(self.model.marry_skill) do
            if self.selectItemData.id == v.id then
                skill_data = v
                break
            end
        end
        if skill_data == nil then
            self.model:On10822({ skill_data = {} })
            self:okButtonClick()
            return
        end
        if skill_data.lev == 0 then
            SkillManager.Instance:Send10821(skill_data.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已激活，无需重新激活"))
        end
    end

    -- SkillManager.Instance.model:OpenNewMarrySkillWindow({83000, 10})
end

function MarrySkillWindow:descButtonClick()
    TipsManager.Instance:ShowText({gameObject = self.descButton, itemData = {
            TI18N("1.伴侣技能只能对自己的<color='#ffff00'>伴侣</color>使用")
            , TI18N("2.伴侣激活需要双方亲密度达到<color='#ffff00'>激活条件</color>并消耗一定<color='#ffff00'>恩爱值</color>")
            , TI18N("3.解除结缘后伴侣技能将消失，复婚再婚后需要<color='#ffff00'>重新激活</color>")
            , TI18N("4.<color='#ffff00'>伴侣技能效果</color>随伴侣双方亲密度增加而提升")
        }})
end