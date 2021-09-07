-- ----------------------------------------------------------
-- UI - 装备洗练指定特效窗口
-- ----------------------------------------------------------
AppointEffectWindow = AppointEffectWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function AppointEffectWindow:__init(model)
    self.model = model
    self.name = "AppointEffectWindow"
    self.windowId = WindowConfig.WinID.eqmtappointeffectwinrans
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.appoint_effect_window, type = AssetType.Main}
    }


    self.effectItemList = {}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

end

function AppointEffectWindow:__delete()
    self:OnHide()
end

function AppointEffectWindow:OnHide()

end

function AppointEffectWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.appoint_effect_window))
    self.gameObject.name = "AppointEffectWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClick() end)

    self.itemcontainer = self.transform:FindChild("Main/mask/ItemContainer").gameObject
    self.effect_Item = self.itemcontainer.transform:Find("Item")

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end


function AppointEffectWindow:OnShow()
    self.model.selected_effect = nil 
    self.model.selected_effect_flag = false
    self.cur_selected_data = self.openArgs

    --//当前装备特效name,val
    local __name 
    local __val
    local effect_attr = {}
    for k,attr_v in pairs(self.cur_selected_data.attr) do
        if attr_v.type == GlobalEumn.ItemAttrType.effect then
            table.insert(effect_attr, attr_v)
        end
    end

    for i,v in ipairs(effect_attr) do
        __name = v.name
        __val = v.val
    end
    
    ---可出现特效
    local effectData = DataEqm.data_effect[string.format("%s_%s", self.cur_selected_data.type, self.cur_selected_data.lev)]
    local list = {}
    if effectData ~= nil then
        for i,v in ipairs(effectData) do
            if v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes then
                for i,v1 in ipairs(v.effect) do
                    table.insert(list, v1)
                end
            end
        end
    end
    
    local effectList = {}
    for i,v in ipairs(list) do
        local skillData = nil
        if v.effect_type == 100 then
            if v.val >= 80000 then
                skillData = DataSkill.data_skill_effect[v.val]
            end
        elseif v.effect_type == 150 then
            -- 易强化
            skillData = DataSkill.data_skill_effect[81019]
        elseif v.effect_type == 151 then
            -- 易成长
            skillData = DataSkill.data_skill_effect[81020]
        end
        if skillData ~= nil then
            skillData.val = v.val
            skillData.effect_type = v.effect_type
            if not (skillData.effect_type == __name and  skillData.val == __val) then 
                table.insert(effectList, skillData)
            end
        end
    end

    for i,v in ipairs(list) do
        local talent_skillData_tmp = nil
        local talent_skillData = {}
        if v.effect_type == 100 then
            talent_skillData_tmp = DataSkillTalent.data_skill_talent[v.val]
            if talent_skillData_tmp ~= nil then
                talent_skillData.id = talent_skillData_tmp.id
                talent_skillData.name = talent_skillData_tmp.talent3_name
                talent_skillData.desc = talent_skillData_tmp.talent3_desc3
                talent_skillData.effect_type = v.effect_type
                talent_skillData.val = v.val
                if not (talent_skillData.effect_type == __name and  talent_skillData.val == __val) then 
                    table.insert(effectList, talent_skillData)
                end
            end
        end
    end

    table.sort(effectList, function(a,b) return a.id < b.id end)



    for i,v in ipairs(effectList) do
        local tab = {}
        if self.effectItemList[i] == nil then 
            tab.obj = GameObject.Instantiate(self.effect_Item.gameObject)
            UIUtils.AddUIChild(self.itemcontainer, tab.obj)
            tab.name = tab.obj.transform:Find("Name"):GetComponent(Text)
            tab.btn = tab.obj.transform:GetComponent(Button)
            tab.desc = tab.obj.transform:Find("Desc"):GetComponent(Text)
        end

        tab.name.text = string.format("<color='#d781f2'>%s</color>",v.name)
        -- tab.desc.text = string.format("<color='#33CCFF'>%s</color>",v.desc)
        tab.desc.text = v.desc
        tab.data = {}
        tab.data.name = string.format("<color='#fff000'>%s</color>",v.name)
        tab.data.effect_type = v.effect_type
        tab.data.val = v.val
        tab.btn.onClick:RemoveAllListeners()
        tab.btn.onClick:AddListener(function() self.model.selected_effect_flag = true self.model.selected_effect = tab.data  self:OnClick() end)

        self.effectItemList[i] = tab
    end

    for i = #effectList + 1, #self.effectItemList do
        if self.effectItemList[i] ~= nil then 
            self.effectItemList[i].obj:SetActive(false)
        end
    end

    self.effect_Item_txt = self.effect_Item:Find("Name"):GetComponent(Text)
    self.effect_Item_txt.text = TI18N("取消选择")
    self.effect_Item_txt.transform.anchoredPosition = Vector2(0,0)
    self.effect_Item_txt.fontSize = 20
    self.effect_Item:Find("Select").gameObject:SetActive(true)
    self.effect_Item:GetComponent(Button).onClick:RemoveAllListeners()
    self.effect_Item:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    
end

function AppointEffectWindow:OnClick()
    WindowManager.Instance:CloseWindow(self) 
    EquipStrengthManager.Instance.onAppointEffect:Fire()
end