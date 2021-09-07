-- @author xjlong
-- @date 2016年8月17日
-- @坐骑升级与幻化

EncyclopediaRideTrans = EncyclopediaRideTrans or BaseClass(BasePanel)

function EncyclopediaRideTrans:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaRideTrans"

    self.resList = {
        {file = AssetConfig.ridetrans_peida, type = AssetType.Main},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
    }

    self.leftDesc = nil
    self.RightDesc = nil
    self.TextEXT1 = nil
    self.TextEXT2 = nil
    
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaRideTrans:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaRideTrans:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridetrans_peida))
    self.gameObject.name = self.name

    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.leftDesc = t:Find("LvupCon/MaskScroll/Desc"):GetComponent(Text)
    self.RightDesc = t:Find("TransCon/MaskScroll/Desc"):GetComponent(Text)
    self.TextEXT1 = MsgItemExt.New(self.leftDesc, 222, 17, 26)
    self.TextEXT2 = MsgItemExt.New(self.RightDesc, 222, 17, 26)
    local descData = DataBrew.data_alldesc["ridetrans"]
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

function EncyclopediaRideTrans:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaRideTrans:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaRideTrans:OnHide()
    self:RemoveListeners()
end

function EncyclopediaRideTrans:RemoveListeners()
end

