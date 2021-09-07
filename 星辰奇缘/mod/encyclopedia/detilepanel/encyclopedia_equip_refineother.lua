-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaEquipRefineOther = EncyclopediaEquipRefineOther or BaseClass(BasePanel)


function EncyclopediaEquipRefineOther:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaEquipRefineOther"

    self.resList = {
        {file = AssetConfig.equiprefine_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaEquipRefineOther:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaEquipRefineOther:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equiprefine_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("StondCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("StrengthCon/MaskScroll/Desc"):GetComponent(Text)
    self.TextEXT1 = MsgItemExt.New(self.leftDesc, 222, 17, 26)
    self.TextEXT2 = MsgItemExt.New(self.RightDesc, 222, 17, 26)
    local descData = DataBrew.data_alldesc["refineother"]
    if descData ~= nil then
        self.TextEXT1:SetData(descData.desc1)
        self.TextEXT2:SetData(descData.desc2)
        -- self.leftDesc.text = descData.desc1
        -- self.RightDesc.text = descData.desc2
    end
    self.leftDesc.transform.sizeDelta = Vector2(222, self.leftDesc.preferredHeight+46)
    self.leftDesc.transform:Find("Button").gameObject:SetActive(true)
    self.leftDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        if RoleManager.Instance.RoleData.lev < 80 then
            NoticeManager.Instance:FloatTipsByString(TI18N("到达80级开启哦"))
            return
        end
        WindowManager:OpenWindowById(WindowConfig.WinID.eqmadvance, {5})
    end)
end

function EncyclopediaEquipRefineOther:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaEquipRefineOther:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaEquipRefineOther:OnHide()
    self:RemoveListeners()
end

function EncyclopediaEquipRefineOther:RemoveListeners()
end