-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaEquipBuildRebuild = EncyclopediaEquipBuildRebuild or BaseClass(BasePanel)


function EncyclopediaEquipBuildRebuild:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaEquipBuildRebuild"

    self.resList = {
        {file = AssetConfig.equipbuild_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaEquipBuildRebuild:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaEquipBuildRebuild:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equipbuild_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("BuildCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("ReBuildCon/MaskScroll/Desc"):GetComponent(Text)
    local descData = DataBrew.data_alldesc["buildrebuild"]
    self.TextEXT1 = MsgItemExt.New(self.leftDesc, 222, 17, 26)
    self.TextEXT2 = MsgItemExt.New(self.RightDesc, 222, 17, 26)
    if descData ~= nil then
        self.TextEXT1:SetData(descData.desc1)
        self.TextEXT2:SetData(descData.desc2)
        -- self.leftDesc.text = descData.desc1
        -- self.RightDesc.text = descData.desc2
    end
    self.leftDesc.transform.sizeDelta = Vector2(222, self.leftDesc.preferredHeight+46)
    self.RightDesc.transform.sizeDelta = Vector2(222, self.RightDesc.preferredHeight+46)
    self.leftDesc.transform:Find("Button").gameObject:SetActive(true)
    self.RightDesc.transform:Find("Button").gameObject:SetActive(true)
    self.leftDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        if RoleManager.Instance.RoleData.lev < 40 then
            NoticeManager.Instance:FloatTipsByString(TI18N("到达40级开启哦"))
            return
        end
        WindowManager:OpenWindowById(WindowConfig.WinID.eqmadvance, {1})
    end)
    self.RightDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        if RoleManager.Instance.RoleData.lev < 38 then
            NoticeManager.Instance:FloatTipsByString(TI18N("到达38级开启哦"))
            return
        end
        WindowManager:OpenWindowById(WindowConfig.WinID.eqmadvance, {2})
    end)
end

function EncyclopediaEquipBuildRebuild:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaEquipBuildRebuild:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaEquipBuildRebuild:OnHide()
    self:RemoveListeners()
end

function EncyclopediaEquipBuildRebuild:RemoveListeners()
end