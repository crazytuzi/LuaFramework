-- 师徒，选择师父的面板
-- @author zgs
SelectTeacherPanel = SelectTeacherPanel or BaseClass(BasePanel)

function SelectTeacherPanel:__init(model)
    self.model = model
    self.name = "SelectTeacherPanel"

    self.resList = {
        {file = AssetConfig.select_teacher_panel, type = AssetType.Main},
        {file = AssetConfig.heads, type = AssetType.Dep},
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdatePanel()
    end)

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePanel()
    end)
end


function SelectTeacherPanel:RemovePanel()
    self:DeleteMe()
end

function SelectTeacherPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
end

function SelectTeacherPanel:__delete()
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.stp = nil
    self.model = nil
end

function SelectTeacherPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.select_teacher_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("Main/Con")

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.descText = self.MainCon:FindChild("DescText"):GetComponent(Text)

    self.teacher_1 = self.MainCon:FindChild("Item_1")
    self.image_1 = self.teacher_1:Find("THead/HeadImage"):GetComponent(Image)
    self.teacher_1:Find("THead/BgImage").gameObject:SetActive(false)
    self.sexIcon_1 = self.teacher_1:Find("THead/SexIcon"):GetComponent(Image)
    -- self.classIcon_1 = self.teacher_1:Find("THead/ClassIcon"):GetComponent(Image)
    self.nameText_1 = self.teacher_1:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_1 = self.teacher_1:FindChild("THead/ClassText"):GetComponent(Text)
    -- self.levText_1 = self.teacher_1:FindChild("THead/LevText"):GetComponent(Text)
    self.connectBtn_1 = self.teacher_1:Find("OpposeButton"):GetComponent(Button)
    self.connectBtn_1.onClick:AddListener( function() self:onClickConnectBtn(1) end)

    self.teacher_2 = self.MainCon:FindChild("Item_2")
    self.image_2 = self.teacher_2:Find("THead/HeadImage"):GetComponent(Image)
    self.teacher_2:Find("THead/BgImage").gameObject:SetActive(false)
    self.sexIcon_2 = self.teacher_2:Find("THead/SexIcon"):GetComponent(Image)
    -- self.classIcon_2 = self.teacher_2:Find("THead/ClassIcon"):GetComponent(Image)
    self.nameText_2 = self.teacher_2:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_2 = self.teacher_2:FindChild("THead/ClassText"):GetComponent(Text)
    -- self.levText_2 = self.teacher_2:FindChild("THead/LevText"):GetComponent(Text)
    self.connectBtn_2 = self.teacher_2:Find("OpposeButton"):GetComponent(Button)
    self.connectBtn_2.onClick:AddListener( function() self:onClickConnectBtn(2) end)

    self.teacher_3 = self.MainCon:FindChild("Item_3")
    self.image_3 = self.teacher_3:Find("THead/HeadImage"):GetComponent(Image)
    self.teacher_3:Find("THead/BgImage").gameObject:SetActive(false)
    self.sexIcon_3 = self.teacher_3:Find("THead/SexIcon"):GetComponent(Image)
    -- self.classIcon_3 = self.teacher_3:Find("THead/ClassIcon"):GetComponent(Image)
    self.nameText_3 = self.teacher_3:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_3 = self.teacher_3:FindChild("THead/ClassText"):GetComponent(Text)
    -- self.levText_3 = self.teacher_3:FindChild("THead/LevText"):GetComponent(Text)
    self.connectBtn_3 = self.teacher_3:Find("OpposeButton"):GetComponent(Button)
    self.connectBtn_3.onClick:AddListener( function() self:onClickConnectBtn(3) end)

    self:DoClickPanel()
end

function SelectTeacherPanel:OnClickClose()
    self:Hiden()
end

function SelectTeacherPanel:onClickConnectBtn(index)
    local data = self.model.selectteacherList[index]
    data.online = 1
    data.id = data.rid
    TeacherManager.Instance:send15819(data.id, data.platform, data.zone_id)
    FriendManager.Instance:TalkToUnknowMan(data, 1)
end

function SelectTeacherPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end


function SelectTeacherPanel:UpdatePanel()
    self.teacher_1.gameObject:SetActive(true)
    self.teacher_2.gameObject:SetActive(true)
    self.teacher_3.gameObject:SetActive(true)
    local data_1 = self.model.selectteacherList[1]
    self.image_1.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
    self.sexIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
    -- self.classIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
    self.nameText_1.text = data_1.name
    self.classText_1.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
    data_1 = self.model.selectteacherList[2]
    if data_1 ~= nil then
        self.image_2.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
        self.sexIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
        -- self.classIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
        self.nameText_2.text = data_1.name
        self.classText_2.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
    else
        self.teacher_2.gameObject:SetActive(false)
    end
    data_1 = self.model.selectteacherList[3]
    if data_1 ~= nil then
        self.image_3.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
        self.sexIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
        -- self.classIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
        self.nameText_3.text = data_1.name
        self.classText_3.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
    else
        self.teacher_3.gameObject:SetActive(false)
    end
end
