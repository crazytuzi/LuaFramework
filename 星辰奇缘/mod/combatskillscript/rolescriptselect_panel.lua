-- 战斗出招表方案选择
-- @author huangzefeng
-- @date 20160616
RoleScriptSelectPanel = RoleScriptSelectPanel or BaseClass(BasePanel)


function RoleScriptSelectPanel:__init(model)
    self.model = model
    self.name = "RoleScriptSelectPanel"

    self.resList = {
        {file = AssetConfig.setroleskillpanel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.updatefunc = function()
        self:Update()
    end
    self.end_fight_callback = function()
        self.model:CloseRolePanel()
    end
    self.notSendFlag = false
end

function RoleScriptSelectPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.end_fight_callback)
    SkillScriptManager.Instance.OnRoleScriptChange:Remove(self.updatefunc)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function RoleScriptSelectPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.setroleskillpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    -- UIUtils.AddUIChild(AutoFarmManager.Instance.model.mainwin.gameObject, self.gameObject)
    self.gameObject.name = "RoleScriptSelectPanel"
    self.transform = self.gameObject.transform
    if self.openArgs then
        self.transform:Find("Main").anchoredPosition = Vector2(65, 40)
        EventMgr.Instance:AddListener(event_name.end_fight, self.end_fight_callback)
    end
    self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:CloseRolePanel() end)
    self.item = {}
    self.item2 = self.transform:Find("Main"):GetChild(1)
    self.item3 = self.transform:Find("Main"):GetChild(2)
    for i=1,4 do
        local item = self.transform:Find("Main"):GetChild(i-1)
        local toggle = item:Find("Toggle"):GetComponent(Toggle)
        local name = item:Find("Toggle/Label"):GetComponent(Text)
        local btn = item:Find("Button"):GetComponent(Button)
        self.item[i] = {item = item, toggle = toggle, btn = btn, name = name}
        self.item[i].name.text = self.model.mgr:GetGroupName(i)
        if self.model.mgr.roleCurrIndex ~= 0 then
            self.item[i].toggle.isOn = self.model.mgr.roleCurrIndex == i
        elseif self.model.mgr.roleCurrIndex == 0 then
            self.item[i].toggle.isOn = i == 4
        end
    end
    for i=1,4 do
        local toggle = self.item[i].toggle
        local btn = self.item[i].btn
        toggle.onValueChanged:RemoveAllListeners()
        toggle.onValueChanged:AddListener(function(status) self:OnCheck(i, status) end)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() self:OpenEditWindow(i) end)
    end
    SkillScriptManager.Instance.OnRoleScriptChange:Add(self.updatefunc)
end

function RoleScriptSelectPanel:OnCheck(index, status)
    if status == true and self.notSendFlag == false then
        if index == 4 then
            self.model.mgr:Send10766(0)
        else
            self.model.mgr:Send10766(index)
        end
        self.model:CloseRolePanel()
    end
end

function RoleScriptSelectPanel:OpenEditWindow(index)
    self.model:OpenEditWindow(index)
    self.model:CloseRolePanel()
end

function RoleScriptSelectPanel:Update()
    self.notSendFlag = true
    for i=1,4 do
        self.item[i].name.text = self.model.mgr:GetGroupName(i)
        if self.model.mgr.roleCurrIndex ~= 0 then
            self.item[i].toggle.isOn = self.model.mgr.roleCurrIndex == i
        elseif self.model.mgr.roleCurrIndex == 0 then
            self.item[i].toggle.isOn = i == 4
        end
    end
    self.notSendFlag = false
end