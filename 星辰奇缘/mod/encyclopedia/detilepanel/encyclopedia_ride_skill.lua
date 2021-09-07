-- @author xjlong
-- @date 2016年8月17日
-- @坐骑技能与契约

EncyclopediaRideSkill = EncyclopediaRideSkill or BaseClass(BasePanel)


function EncyclopediaRideSkill:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaRideSkill"

    self.resList = {
        {file = AssetConfig.rideskill_peida, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.leftDesc = nil
    self.RightDesc = nil
    self.TextEXT1 = nil
    self.TextEXT2 = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaRideSkill:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaRideSkill:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rideskill_peida))
    self.gameObject.name = self.name

    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("SkillCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("DeedCon/MaskScroll/Desc"):GetComponent(Text)
    self.TextEXT1 = MsgItemExt.New(self.leftDesc, 222, 17, 26)
    self.TextEXT2 = MsgItemExt.New(self.RightDesc, 222, 17, 26)
    local descData = DataBrew.data_alldesc["rideskill"]
    if descData ~= nil then
        self.TextEXT1:SetData(descData.desc1)
        self.TextEXT2:SetData(descData.desc2)
    end
    self.leftDesc.transform.sizeDelta = Vector2(222, self.leftDesc.preferredHeight+46)
    self.RightDesc.transform.sizeDelta = Vector2(222, self.RightDesc.preferredHeight+46)

    --[[self.leftDesc.transform:Find("Button").gameObject:SetActive(true)
    self.RightDesc.transform:Find("Button").gameObject:SetActive(true)
    self.leftDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        if RoleManager.Instance.RoleData.lev < 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("到达2级开启哦"))
            return
        end
        WindowManager:OpenWindowById(WindowConfig.WinID.ridewindow, {1,1})
    end)
    self.RightDesc.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        -- if RoleManager.Instance.RoleData.lev < 0 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("到达12级开启哦"))
        --     return
        -- end
        WindowManager:OpenWindowById(WindowConfig.WinID.ridewindow, {1,1})
    end)]]
end

function EncyclopediaRideSkill:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaRideSkill:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaRideSkill:OnHide()
    self:RemoveListeners()
end

function EncyclopediaRideSkill:RemoveListeners()
end
