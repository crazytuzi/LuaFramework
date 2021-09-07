-- -----------------------------
-- 诸神之战 冠军查看面板
-- ljh
-- -----------------------------
GodsWarSettlementPanel = GodsWarSettlementPanel or BaseClass(BasePanel)

function GodsWarSettlementPanel:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.godswarsettlementpanel, type = AssetType.Main },
        { file = AssetConfig.godswarres, type = AssetType.Dep },
        { file = AssetConfig.bigatlas_godswarbg0, type = AssetType.Dep },
        { file = AssetConfig.classcardgroup_textures, type = AssetType.Dep },
    }

    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.itemList = { }
    self.isFull = false

    -- self.list_name_title = { TI18N("半神组(80-89级)"), TI18N("真神组(90-突破99)"), TI18N("主神组(突破100+)") }
    -- self.list_name = { TI18N("半神组(80-89级)"), TI18N("真神组(90-突破99)"), TI18N("主神组(突破100以上)") }
    -- self.list_zone = { 1, 3, 4 } -- 服务器端的数据改了， 删除了组别2，故对应组别为 1.半神组(80-89级), 2.真神组(90-突破99), 3.主神组(突破100以上)

    self.groupType = 1
    
    self.listenerMatch = function()
        self:Update()
    end
end

function GodsWarSettlementPanel:__delete()
    -- self.buttonImg.sprite = nil

    for i, v in ipairs(self.itemList) do
        v:DeleteMe()
    end
    self.itemList = nil
end

function GodsWarSettlementPanel:OnShow()
    EventMgr.Instance:AddListener(event_name.godswar_match_update, self.listenerMatch)

    local roleData = RoleManager.Instance.RoleData

    -- if roleData.lev_break_times == 0 and roleData.lev < 80 then
    --     self:SelectTransformationList(1)
    -- elseif roleData.lev_break_times == 0 or (roleData.lev_break_times == 1 and roleData.lev <100) then
    --     self:SelectTransformationList(2)
    -- else
    --     self:SelectTransformationList(3)
    -- end
    local index = GodsWarEumn.Group(roleData.lev, roleData.lev_break_times)
    self:SelectTransformationList(index)
end

function GodsWarSettlementPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listenerMatch)
end

function GodsWarSettlementPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarsettlementpanel))
    self.gameObject.name = "GodsWarSettlementPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener( function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self:Close() end)

    local container = self.transform:Find("Main/Scroll/Container")
    local len = container.childCount
    for i = 1, len do
        local item = GodsWarOtherTeamItem.New(container:GetChild(i - 1).gameObject, self)
        table.insert(self.itemList, item)
    end

    self.fightObj = self.transform:Find("Main/Fight").gameObject
    self.fight = self.transform:Find("Main/Fight/Val"):GetComponent(Text)
    self.button = self.transform:Find("Main/Button").gameObject
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)
    self.button:GetComponent(Button).onClick:AddListener( function() self:ClickButton() end)

    self.serveName = self.transform:Find("Main/ServerName"):GetComponent(Text)
    self.teamName = self.transform:Find("Main/TeamName"):GetComponent(Text)

    self.switchButtonList = self.transform:FindChild("Main/SwitchButton/List").gameObject
    self.switchButtonTypeText = self.transform:FindChild("Main/SwitchButton/TypeText"):GetComponent(Text)

    local btn
    btn = self.transform:FindChild("Main/SwitchButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OpenList() end)

    btn = self.transform:FindChild("Main/SwitchButton/List/Close"):GetComponent(Button)
    btn.onClick:AddListener(function() self:CloseList() end)

    local con = self.transform:FindChild("Main/SwitchButton/List")
    local buttonCloner = self.transform:FindChild("Main/SwitchButton/List/Button").gameObject
    buttonCloner:SetActive(false)
    local groupNum = GodsWarEumn.GroupNum()
    for i = 1, groupNum do
        local button = GameObject.Instantiate(buttonCloner)
        button:SetActive(true)
        button.transform:SetParent(con)
        button.transform.localPosition = Vector2(0, -28 - 36 * (i-1))
        button.transform.localScale = Vector2.one

        btn = button:GetComponent(Button)
        btn.onClick:AddListener(function() self:SelectTransformationList(i) end)

        -- btn.transform:FindChild("I18NText"):GetComponent(Text).text = self.list_name[i]
        btn.transform:FindChild("I18NText"):GetComponent(Text).text = GodsWarEumn.GroupName(i)
    end

    local rectTransform = self.transform:FindChild("Main/SwitchButton/List"):GetComponent(RectTransform)
    local sizeDelta = rectTransform.sizeDelta
    rectTransform.sizeDelta = Vector2(sizeDelta.x, 22 + 36 * groupNum)

    self.titleImage = self.transform:FindChild("Main/TitleImage")

    self:OnShow()
end

function GodsWarSettlementPanel:Close()
    self.model:CloseSettlement()
end

function GodsWarSettlementPanel:Update()
    local settlementData = GodsWarManager.Instance.settlementData
    if settlementData ~= nil then 
        self.data = settlementData[self.zone]
        if self.data ~= nil then 
            self:UpdateInfo()
        end
    end


    -- local elimintionTab = GodsWarManager.Instance.elimintionTab[self.zone]
    -- if elimintionTab == nil then
    --     -- GodsWarManager.Instance:Send17925(self.zone)
    -- else
    --     -- BaseUtils.dump(elimintionTab, "GodsWarSettlementPanel:Update()")
    --     for key, value in pairs(elimintionTab) do
    --         if value.qualification == GodsWarEumn.Quality.Champion then
    --             self.data = value
    --             self:UpdateInfo()
    --             break
    --         end
    --     end
    -- end
end

-- {uint32, tid, "战队ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "战队名字"}
-- ,{uint8, lev, "战队等级"}
-- ,{uint8, member_num, "战队人数"}
function GodsWarSettlementPanel:UpdateInfo()
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    self.serveName.text = BaseUtils.GetServerNameMerge(self.data.platform, self.data.zone_id)
    self.teamName.text = self.data.name

    if self.data.win_times == nil or self.data.loss_times == nil then
        self.fight.text = ""
        self.fightObj:SetActive(false)
    else
        self.fightObj:SetActive(true)
        self.fight.text = string.format(TI18N("战绩:%s胜%s负"), self.data.win_times, self.data.loss_times)
    end
    local normalIndex = 1

    table.sort(self.data.members, function(a, b)
        if a.position ~= b.position then
            return a.position < b.position
        else
            return a.fight_capacity > b.fight_capacity
        end
    end )

    for i, v in ipairs(self.data.members) do
        local item = self.itemList[normalIndex]
        item:SetData(v)
        normalIndex = normalIndex + 1
    end

    for i = normalIndex, #self.itemList do
        self.itemList[i]:Reset()
    end

    -- self.buttonTxt.text = TI18N("录 像")
    -- self.button:SetActive(true)
end

function GodsWarSettlementPanel:ClickButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = self.groupType,name = self.data.name})
end

function GodsWarSettlementPanel:OpenList()
    self.switchButtonList:SetActive(true)
end

function GodsWarSettlementPanel:CloseList()
    self.switchButtonList:SetActive(false)
end

function GodsWarSettlementPanel:SelectTransformationList(type)
    self.groupType = type
    self:CloseList()

    -- self.switchButtonTypeText.text = self.list_name_title[self.groupType]
    self.switchButtonTypeText.text = GodsWarEumn.GroupName(self.groupType)
    -- self.zone = self.list_zone[self.groupType]
    self.zone = self.groupType -- 服务器端的数据改了， 删除了组别2，故对应组别为 1.半神组(80-89级), 2.真神组(90-突破99), 3.主神组(突破100以上)

    self:Update()
end
