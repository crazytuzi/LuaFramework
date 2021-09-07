-- --------------------------
-- 角色，宠物加点
-- hosr
-- --------------------------
AddPoint = AddPoint or BaseClass(BaseWindow)

function AddPoint:__init(model)
    self.model = model
    self.name = "AddPoint"
    self.resList = {
        {file = AssetConfig.addpoint, AssetType.Main},
        {file = AssetConfig.childhead, AssetType.Dep},
        {file = AssetConfig.addpointTexture, AssetType.Dep},
    }

    self.attr = nil
    self.slider = nil
    self.set = nil
    self.tips = nil
    self.PointList = {}
    self.cur_select_option = 1 --当前选择的加点方案

    self.listener = function() self:AttrChange() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnInitCompletedEvent:Add(function() self:OnInitCompleted() end)
    self.isStartGuide = false
end

function AddPoint:OnShow()
    if RoleManager.Instance.RoleData:ExtraPoint() == 0  and RoleManager.Instance.RoleData.point ~= 0 then
        self.isStartGuide = true
    else
        self.isStartGuide = false
    end
    self.slider:CheckGuideAddPoint()
end

function AddPoint:OnInitCompleted()
    if self.openArgs[1] == AddPointEumn.Type.Role then
        if RoleManager.Instance.RoleData:ExtraPoint() == 0  and RoleManager.Instance.RoleData.point ~= 0 then
            self.isStartGuide = true
        else
            self.isStartGuide = false
        end
        self.slider:CheckGuideAddPoint()
    elseif self.openArgs[1] == AddPointEumn.Type.Pet then
        -- local data = DataQuest.data_get[41810]
        -- local quest = BaseUtils.copytab(QuestManager.Instance.questTab[data.id])

        -- if quest == nil then
        --     quest = {finish = 1, follow = 0}
        -- end

        -- local isGuidePetAddPoint = true
        -- if quest.progress ~= nil then

        -- else
        --     if data.find_break_lev > 0 then
        --         if RoleManager.Instance.RoleData.lev < data.lev or RoleManager.Instance.RoleData.lev_break_times < data.find_break_lev then
        --         else
        --             isGuidePetAddPoint = false
        --         end
        --     else
        --         if RoleManager.Instance.RoleData.lev < data.lev then
        --         else
        --             isGuidePetAddPoint = false
        --         end
        --     end
        -- end
        local isGuidePetAddPoint = false
        local data = DataQuest.data_get[41800]
        local questData = QuestManager.Instance:GetQuest(data.id)

        if questData ~= nil and questData.finish == 1 then
            isGuidePetAddPoint = true
        end

        if isGuidePetAddPoint == true then
            self.isStartGuide = true
        else
            self.isStartGuide = false
        end
        self.slider:CheckGuideAddPoint()
    end
end
function AddPoint:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_attr_change, self.listener)
    PetManager.Instance.OnPetUpdate:Remove(self.listener)
    PetManager.Instance.OnUpdatePetList:Remove(self.listener)
    ChildrenManager.Instance.OnChildPointUpdate:Remove(self.listener)

    if self.attr ~= nil then
        self.attr:DeleteMe()
        self.attr = nil
    end
    if self.slider ~= nil then
        self.slider:DeleteMe()
        self.slider = nil
    end
    if self.set ~= nil then
        self.set:DeleteMe()
        self.set = nil
    end
    if self.tips ~= nil then
        self.tips:DeleteMe()
        self.tips = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AddPoint:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.addpoint))
    self.gameObject.name = "AddPoint"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Window/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.attr = AddPointAttr.New(self.transform:Find("Window/Attribute").gameObject, self)
    self.slider = AddPointSlider.New(self.transform:Find("Window/PointSlider").gameObject, self,self.openArgs[1])
    self.set = AddPointSet.New(self.transform:Find("SettingPanel").gameObject, self)
    self.pointRes = self.transform:Find("PointResPanel")
    self.pointRes.gameObject:SetActive(false)
    self.pointResBtn = self.pointRes:GetComponent(Button)
    self.pointResBtn.onClick:AddListener(function() self.pointRes.gameObject:SetActive(false) end)
    for i=1, 5 do
        if self.PointList[i] == nil then
            local point = {}
            point.trans = self.pointRes:Find("Main/Option"):GetChild(i-1)
            point.num = point.trans:Find("Value"):GetComponent(Text)
            point.img = point.trans:Find("Image"):GetComponent(Image)
            self.PointList[i] = point
        end
    end

    self.transform:Find("Window/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self:AttrChange()

    local addPointType = self.openArgs[1]
    if addPointType == AddPointEumn.Type.Role then
        EventMgr.Instance:AddListener(event_name.role_attr_change, self.listener)
        AddPointManager.Instance:Send10026()
    elseif addPointType == AddPointEumn.Type.Pet then
        local petData = self.openArgs[2]
        PetManager.Instance.OnPetUpdate:Add(self.listener)
        PetManager.Instance.OnUpdatePetList:Add(self.listener)
        PetManager.Instance:Send10567(petData.id)
    elseif addPointType == AddPointEumn.Type.Child then
        ChildrenManager.Instance.OnChildPointUpdate:Add(self.listener)

        if PetManager.Instance.model:CheckChildCanFollow() then
            local child = PetManager.Instance.model.currChild
            ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
        end
    end
end

function AddPoint:Close()
    self.model:Close()
end

--确定加点
function AddPoint:SureAddPoint(info)
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    if addPointType == AddPointEumn.Type.Role then
        RoleManager.Instance:send10005(info)
    elseif addPointType == AddPointEumn.Type.Pet then
        local petData = self.openArgs[2]
        PetManager.Instance:Send10513(petData.id, info)
    elseif addPointType == AddPointEumn.Type.Child then
        local childData = self.openArgs[2]
        local data = {}
        data.id = childData.child_id
        data.platform = childData.platform
        data.zone_id = childData.zone_id
        data.info = info
        ChildrenManager.Instance:Require18611(data)
    end
end

--确定点数设置
function AddPoint:SureSetting(info)
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    if addPointType == AddPointEumn.Type.Role then
        RoleManager.Instance:send10006(info)
    elseif addPointType == AddPointEumn.Type.Pet then
        local petData = self.openArgs[2]
        PetManager.Instance:Send10520(petData.id, info)
    elseif addPointType == AddPointEumn.Type.Child then
    end
end

-- 洗点
function AddPoint:Wash()
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    if addPointType == AddPointEumn.Type.Role then
        RoleManager.Instance:send10009()
    elseif addPointType == AddPointEumn.Type.Pet then
        PetManager.Instance:Send10534(self.openArgs[2].id)
    elseif addPointType == AddPointEumn.Type.Child then
        local childData = self.openArgs[2]
        local data = {}
        data.id = childData.child_id
        data.platform = childData.platform
        data.zone_id = childData.zone_id
        data.info = {0,0,0,0,0}
        ChildrenManager.Instance:Require18611(data)
    end
end

--打开设置
function AddPoint:OpenSet()
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    self.set:Show(addPointType)
end

-- 变动更新
-- info = {_dis, _cor, _for, _bra, _agi, __end}
function AddPoint:PointChange(info)
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    self.attr:UpdateUpInfo(addPointType, info)
end

function AddPoint:AttrChange()
    if self.openArgs == nil then
        return
    end
    local addPointType = self.openArgs[1]
    self.attr:UpdateInfo(addPointType)
    self.slider:Show(addPointType)
end

function AddPoint:ShowTips()
    if self.tips == nil then
        self.tips = AddPointTips.New(self)
    end
    self.tips:Show()
end

function AddPoint:OpenRoleHelpTips()
    local role = RoleManager.Instance.RoleData
    --role.honorPoint, role.itemPoint ,role.handbookPoint, role.levbreakPoint, role.levbreakExchangePoint
    for i, v in ipairs(self.PointList) do
        self.PointList[i].img.sprite = self.assetWrapper:GetSprite(AssetConfig.addpointTexture, tostring(i))
    end
    self.PointList[1].num.text = string.format(TI18N("爵位挑战：<color='#ffff00'>%s</color>"), role.honorPoint)
    self.PointList[2].num.text = string.format(TI18N("特殊道具：<color='#ffff00'>%s</color>"), role.itemPoint)
    self.PointList[3].num.text = string.format(TI18N("特殊图鉴：<color='#ffff00'>%s</color>"), role.handbookPoint)
    self.PointList[4].num.text = string.format(TI18N("等级突破：<color='#ffff00'>%s</color>"), role.levbreakPoint)
    self.PointList[5].num.text = string.format(TI18N("兑换点数：<color='#ffff00'>%s</color>"), role.levbreakExchangePoint)

    self.pointRes.gameObject:SetActive(true)
end