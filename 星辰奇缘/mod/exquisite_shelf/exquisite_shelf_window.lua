-- @author 黄耀聪
-- @date 2017年8月21日, 星期一

ExquisiteShelfWindow = ExquisiteShelfWindow or BaseClass(BaseWindow)

function ExquisiteShelfWindow:__init(model)
    self.model = model
    self.name = "ExquisiteShelfWindow"
    self.windowId = WindowConfig.WinID.exquisite_shelf

    self.resList = {
        {file = AssetConfig.exquisite_shelf_window, type = AssetType.Main},
        {file = AssetConfig.exquisite_shelf_textures, type = AssetType.Dep},
        {file = AssetConfig.exquisite_select, type = AssetType.Main},
    }

    self.assetBgList = {
        AssetConfig.exquisite_bg1,
        AssetConfig.exquisite_bg2,
        AssetConfig.exquisite_bg3
    }

    self.rewardList = {}
    self.levelList = {}
    self.clickCallback = function(index) self:OnClick(index) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExquisiteShelfWindow:__delete()
    self.OnHideEvent:Fire()
    if self.levelList ~= nil then
        for _,v in pairs(self.levelList) do
            v:DeleteMe()
        end
        self.levelList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.resExt ~= nil then
        self.resExt:DeleteMe()
        self.resExt = nil
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    self:AssetClearAll()
end

function ExquisiteShelfWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisite_shelf_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.container = main:Find("Scroll/Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
    self.rewardContainer = main:Find("Reward/Container")
    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
    self.teamBtn = main:Find("Team"):GetComponent(Button)
    self.challengeBtn = main:Find("Challenge"):GetComponent(Button)
    self.resExt = MsgItemExt.New(main:Find("Text"):GetComponent(Text), 400, 19, 21.59)

    self.teamBtn.onClick:AddListener(function() self:OnTeam() end)
    self.challengeBtn.onClick:AddListener(function() self:OnChallenge() end)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function ExquisiteShelfWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExquisiteShelfWindow:OnOpen()
    self:RemoveListeners()

    self:Reload()
    self:OnClick(ExquisiteShelfManager.Instance:GetCurrentShelfLev())
end

function ExquisiteShelfWindow:OnHide()
    self:RemoveListeners()
end

function ExquisiteShelfWindow:RemoveListeners()
end

function ExquisiteShelfWindow:Reload()
    self.datalist = {}
    for _,v in pairs(DataExquisiteShelf.data_group) do
        table.insert(self.datalist, v)
    end
    table.sort(self.datalist, function(a,b) return a.shelf_lev < b.shelf_lev end)
    local length = 0
    for i,data in ipairs(self.datalist) do
        if i <= self.container.childCount then
            local item = self.levelList[i] or ExquisiteShelfItem.New(self.model, self.container:GetChild(i - 1).gameObject, self.assetWrapper)
            self.levelList[i] = item
            item.clickCallback = self.clickCallback
            item:SetData(data, i)
            length = length + 1
        end
    end
    for i=length+1,#self.levelList do
        self.levelList[i].gameObject:SetActive(false)
    end

    if TeamManager.Instance:MemberCount() < 3 then
        if self.effect == nil then
            self.effect = BaseUtils.ShowEffect(20053, self.teamBtn.transform, Vector3(1.7,0.6,1), Vector3(-53,-13,-400))
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function ExquisiteShelfWindow:OnClick(index)
    local lev = RoleManager.Instance.RoleData.lev
    if self.datalist[index].max_lev < lev then
        NoticeManager.Instance:FloatTipsByString(TI18N("副本等级过低，无法进入"))
        return
    end
    if self.lastIndex ~= nil then
        self.levelList[self.lastIndex]:Select(false)
    end
    self.levelList[index]:Select(true)
    self.lastIndex = index

    self:ReloadReward(self.levelList[index].data.reward)

    local lev = RoleManager.Instance.RoleData.lev
    if self.datalist[index].min_lev <= lev and lev <= self.datalist[index].max_lev then
        self.teamBtn.gameObject:SetActive(true)
        self.challengeBtn.gameObject:SetActive(true)
        self.resExt:SetData("")
    else
        self.teamBtn.gameObject:SetActive(false)
        self.challengeBtn.gameObject:SetActive(false)
        self.resExt:SetData(string.format(TI18N("达到<color='#ffff00'>%s级</color>可进入{face_1,3}"), self.datalist[index].min_lev))

        local size = self.resExt.contentTrans.sizeDelta
        self.resExt.contentTrans.anchoredPosition = Vector2(-size.x - 35, size.y / 2 - 195.9)
    end
end

function ExquisiteShelfWindow:ReloadReward(list)
    list = CampaignManager.ItemFilter(list)
    self.rewardLayout:ReSet()
    for i,data in ipairs(list) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.data = ItemData.New()
            tab.slot = ItemSlot.New()
            self.rewardList[i] = tab
        end
        if tab.data.base_id ~= data.base_id then
            tab.data:SetBase(DataItem.data_get[data[1]])
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        end
        tab.slot:SetNum(data[2])
        self.rewardLayout:AddCell(tab.slot.gameObject)
    end
    for i=#list+1,#self.rewardList do
        self.rewardList[i].slot.gameObject:SetActive(false)
    end
end

function ExquisiteShelfWindow:ReloadButton()
end

function ExquisiteShelfWindow:OnTeam()
    ExquisiteShelfManager.Instance:OnTeam()
end

function ExquisiteShelfWindow:OnChallenge()
    ExquisiteShelfManager.Instance:send20303()
    WindowManager.Instance:CloseWindow(self)
end
