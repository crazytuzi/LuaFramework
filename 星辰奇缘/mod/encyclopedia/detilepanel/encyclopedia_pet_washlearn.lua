-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaPetWashLearn = EncyclopediaPetWashLearn or BaseClass(BasePanel)


function EncyclopediaPetWashLearn:__init(parent)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaPetWashLearn"

    self.resList = {
        {file = AssetConfig.washalearn_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaPetWashLearn:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaPetWashLearn:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.washalearn_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("WashCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("LearnCon/MaskScroll/Desc"):GetComponent(Text)
    self.TextEXT1 = MsgItemExt.New(self.leftDesc, 222, 17, 26)
    self.TextEXT2 = MsgItemExt.New(self.RightDesc, 222, 17, 26)
    local descData = DataBrew.data_alldesc["washlearn"]
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
        if RoleManager.Instance.RoleData.lev < 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("到达2级开启哦"))
            return
        end
        WindowManager:OpenWindowById(WindowConfig.WinID.pet, {2})
    end)
    self.RightDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        -- if RoleManager.Instance.RoleData.lev < 0 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("到达12级开启哦"))
        --     return
        -- end
        WindowManager:OpenWindowById(WindowConfig.WinID.pet, {1,2})
    end)
end

function EncyclopediaPetWashLearn:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaPetWashLearn:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaPetWashLearn:OnHide()
    self:RemoveListeners()
end

function EncyclopediaPetWashLearn:RemoveListeners()
end