ApprenticeshipGrowPanel = ApprenticeshipGrowPanel or BaseClass(BasePanel)

function ApprenticeshipGrowPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = TeacherManager.Instance

    self.resList = {
        {file = AssetConfig.teacher_grow_panel, type = AssetType.Main}
    }

    self.itemList = {}
    self.sliderList = {}
    self.sliderTextList = {}
    self.giftObjList = {}
    self.hasGetObjList = {}
    self.unreachObjList = {}
    self.giftBtnList = {}
    self.hasGetRectList = {}
    self.hasGetImageList = {}
    self.descTextList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.onUpdateListener = function() self:ReloadItems() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ApprenticeshipGrowPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ApprenticeshipGrowPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_grow_panel))
    self.gameObject.name = "GrowPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.container = t:Find("ScrollLayer/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.cloner = t:Find("ScrollLayer/Cloner").gameObject
    self.cloner:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container, {cspacing = 5, axis = BoxLayoutAxis.Y, border = 5})
end

function ApprenticeshipGrowPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ApprenticeshipGrowPanel:OnOpen()
    local model = self.model
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.model.stuData = self.openArgs[1]
    end

    -- 师傅每次打开请求，没有数据也请求
    -- if model.myTeacherInfo.status == 3 or model.targetData[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)] == nil then
        self.mgr:send15806(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)
    -- end
    self:RemoveListeners()
    self.mgr.onUpdateTarget:AddListener(self.onUpdateListener)
end

function ApprenticeshipGrowPanel:OnHide()
    self:RemoveListeners()
end

function ApprenticeshipGrowPanel:RemoveListeners()
    self.mgr.onUpdateTarget:RemoveListener(self.onUpdateListener)
end

function ApprenticeshipGrowPanel:ReloadItems()
    local model = self.model
    local key = BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)
    local data = model.targetData[key]
    if data == nil then
        return
    end

    local lev = RoleManager.Instance.RoleData.lev
    local dataList = {}
    for i,v in ipairs(data.list) do
        if v ~= nil and v.finish ~= 3 and lev >= DataTeacher.data_get_target[v.id].lev then
            table.insert(dataList, v)
        end
    end

    local masterRewardList = self.model.masterRewardList
    if self.model.myTeacherInfo.status == 3 then
        table.sort(dataList, function(a, b)
            local fa = nil
            local fb = nil

            if masterRewardList[b.id] == 0 then fb = 2
            elseif masterRewardList[b.id] == 1 then fb = 0
            else fb = 1
            end

            if masterRewardList[a.id] == 0 then fa = 2
            elseif masterRewardList[a.id] == 1 then fa = 0
            else fa = 1
            end

            if fa ~= fb then return fa > fb
            else return a.id < b.id
            end
        end)
    else
        table.sort(dataList, function(a, b)
            local fa = (a.finish + 1) % 3
            local fb = (b.finish + 1) % 3
            if fa ~= fb then return fa > fb
            else return a.id < b.id
            end
        end)
    end

    for i,v in ipairs(dataList) do
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.itemList[i] = obj
            self:SetItem(obj, v, i)
        end
        self:UpdateItem(v, i)
        self.itemList[i]:SetActive(true)
    end

    for i=#dataList + 1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end

    if #dataList > 0 then
        local rect = self.layout.cellList[#dataList]:GetComponent(RectTransform)
        self.containerRect.sizeDelta = Vector2(0, rect.sizeDelta.y - rect.anchoredPosition.y + self.layout.border)
    end
end

function ApprenticeshipGrowPanel:SetItem(obj, data, index)
    local t = obj.transform
    t:Find("Arrow/Text"):GetComponent(Text).text = TI18N("目标")..BaseUtils.NumToChn(index)
    self.descTextList[index] = t:Find("Desc"):GetComponent(Text)
    self.sliderList[index] = t:Find("Slider"):GetComponent(Slider)
    self.sliderTextList[index] = t:Find("Slider/ProgressTxt"):GetComponent(Text)
    self.giftObjList[index] = t:Find("Gift").gameObject
    self.unreachObjList[index] = t:Find("Unreach").gameObject
    self.hasGetObjList[index] = t:Find("HasGet").gameObject
    self.giftBtnList[index] = t:Find("Gift"):GetComponent(Button)
    self.hasGetRectList[index] = self.hasGetObjList[index]:GetComponent(RectTransform)
    self.hasGetImageList[index] = self.hasGetObjList[index]:GetComponent(Image)
end

function ApprenticeshipGrowPanel:UpdateItem(data, index)
    local progress = data.progress[1]
    local roleData = RoleManager.Instance.RoleData
    self.sliderList[index].value = progress.value / progress.target_val
    self.descTextList[index].text = data.name
    local target_val = progress.target_val
    if target_val <= 0 then
        target_val = "--"
    else
        target_val = tostring(target_val)
    end
    self.sliderTextList[index].text = tostring(progress.value).."/"..target_val

    if BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id) == BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) then     -- 看自己
        self.hasGetObjList[index]:SetActive(data.finish == 1 or data.finish == 2)
        self.giftObjList[index]:SetActive(data.finish == 1)
        self.unreachObjList[index]:SetActive(data.finish == 0)

        if data.finish == 1 then
            self.hasGetRectList[index].anchoredPosition = Vector2(129, 0)
        elseif data.finish == 2 then
            self.hasGetRectList[index].anchoredPosition = Vector2(165, 0)
        end
    else    -- 看别人（我的徒弟）
        self.hasGetObjList[index]:SetActive(self.model.masterRewardList[data.id] == 1)
        self.giftObjList[index]:SetActive(self.model.masterRewardList[data.id] == 0)
        self.unreachObjList[index]:SetActive(self.model.masterRewardList[data.id] == nil)

        if self.model.masterRewardList[data.id] == 1 then -- 已领取
            self.hasGetRectList[index].anchoredPosition = Vector2(165, 0)
        elseif self.model.masterRewardList[data.id] == 0 then -- 未领取
            self.hasGetRectList[index].anchoredPosition = Vector2(129, 0)
        end
    end

    self.giftBtnList[index].onClick:RemoveAllListeners()
    self.giftBtnList[index].onClick:AddListener(function()
        self:OnClickReward(data)
    end)
end

function ApprenticeshipGrowPanel:OnClickReward(data)
    local id = data.id
    if self.model.myTeacherInfo.status == 3 then
        local roleData = RoleManager.Instance.RoleData

        -- 我作为师傅查看我之前的师门目标
        if BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id) == BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) then
            if data.finish == 1 then
                TeacherManager.Instance:send15809(1, id)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("你的目标还没有完成，无法领取奖励哦~"))
            end
            return
        end

        if self.model.masterRewardList[id] == 0 then
            TeacherManager.Instance:send15818(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id, id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你的目标还没有完成，无法领取奖励哦~"))
        end
    else
        if data.finish == 1 then
            TeacherManager.Instance:send15809(1, id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你的目标还没有完成，无法领取奖励哦~"))
        end
    end
end
