AgendaClanderPanel = AgendaClanderPanel or BaseClass(BasePanel)

function AgendaClanderPanel:__init(parent, Main)
    self.parent = parent
    self.main = Main
    self.name = "AgendaClanderPanel"

    self.resList = {
        {file = AssetConfig.agenda_clander, type = AssetType.Main}
    }

    self.itemList = {{},{},{},{},{},{},{}}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function AgendaClanderPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function AgendaClanderPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.agenda_clander))
    self.transform = self.gameObject.transform
    self.gameObject.name = "AgendaClanderPanel"
    self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3(1, 1, 1)
    self.parent:Find("TipsPanel"):SetAsLastSibling()
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.itemCon = self.transform:Find("ItemCon")
    self.baseItem = self.transform:Find("ItemCon/Button")

    self.currDay = self.transform:Find("Con/CurrDay")
    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    if currentWeek == 0 then
        currentWeek = 7
    end
    self.currDay.anchoredPosition = Vector2(-225.84+(currentWeek-1)*90, 2)
end 

function AgendaClanderPanel:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function AgendaClanderPanel:OnOpen()
    self:InitClander()
end

function AgendaClanderPanel:OnHide()

end

function AgendaClanderPanel:InitClander()
    for i=1,7 do
        local data = BaseUtils.copytab(DataAgenda.data_clander[i])
        self.transform:Find(string.format("Con/TText%s", tostring(i))):GetComponent(Text).text = data.time
        for ii = 1, 7 do
            local item = self.itemList[i][ii]
            if item == nil then
                local its = GameObject.Instantiate(self.baseItem.gameObject)
                its.transform:SetParent(self.itemCon)
                its.transform.localScale = Vector3.one
                its.transform.anchoredPosition = Vector2((ii-1)*90, -(i-1)*50)
                item = its.transform
                self.itemList[i][ii] = its.transform
            end

            if RoleManager.Instance.world_lev < 60 and ii == 3 and data.args[ii].id == 2019 then
                data.args[ii] = {id = 2010,desc = TI18N("勇士战场")}
            elseif RoleManager.Instance.RoleData.lev >= 70 and RoleManager.Instance.world_lev >= 70 and ii == 3 and data.args[ii].id == 2019 then
                data.args[ii] = {id = 2106,desc = TI18N("<color='#ffff00'>峡谷之巅</color>")}
            end

            if data.args[ii].id ~= 0 then
                if data.args[ii].id == 1008 and (RoleManager.Instance.connect_type ~= 1 or RoleManager.Instance.RoleData.lev < 70) then
                    item:Find("Text"):GetComponent(Text).text = TI18N("吃货巡游")
                else
                    item:Find("Text"):GetComponent(Text).text = data.args[ii].desc
                end
                item:GetComponent(Button).onClick:AddListener(function() self:OnClick(1, data.args[ii].id, ii) end)
            else
                item:Find("Text"):GetComponent(Text).text = "--"
            end
            item.gameObject:SetActive(true)
        end
    end
end

function AgendaClanderPanel:OnClick(type, id, week)
    local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
    if currentWeek == 0 then currentWeek = 7 end
    if id == 1008 and RoleManager.Instance.connect_type == 1 and RoleManager.Instance.RoleData.lev >= 70 then
        local currentNpcData = DataUnit.data_unit[20004]
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[20004])
        extra.base.buttons = {}
        extra.base.buttons[1] = {}
        extra.base.buttons[1].button_id = 997
        extra.base.buttons[1].button_desc = TI18N("武道大会")
        extra.base.buttons[1].button_args = function() self.main:ShowTips(type, DataAgenda.data_list[2028]) end
        extra.base.buttons[2] = {}
        extra.base.buttons[2].button_id = 997
        extra.base.buttons[2].button_desc = TI18N("吃货巡游")
        extra.base.buttons[2].button_args = function() self.main:ShowTips(type, DataAgenda.data_list[1008]) end
        local iscross = RoleManager.Instance:CanConnectCenter()
        local substr = TI18N("1.武道会需跨服参与，本服<color='#00ff00'>已连接</color>跨服")
        if not iscross then
            substr = TI18N("1.武道会需跨服参与，本服<color='#ffff00'>未连接</color>跨服")
        end
        extra.base.plot_talk = string.format(TI18N("<color='#ffff00'>70</color>级以后，<color='#ffff00'>每天</color>中午<color='#ffff00'>12:30-13:30</color> 将开启<color='#00ff00'>天下第一武道会</color>，奖励更丰厚喔\n注意：%s"), substr)
        MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)

    else
        self.main:ShowTips(type, DataAgenda.data_list[id])
    end
end
