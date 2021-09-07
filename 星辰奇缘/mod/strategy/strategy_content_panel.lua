-- @author 黄耀聪
-- @date 2016年7月7日

StrategyContentPanel = StrategyContentPanel or BaseClass(BasePanel)

function StrategyContentPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyContentPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_read_panel, type = AssetType.Main},
        {file = AssetConfig.strategy_textures, type = AssetType.Dep},
    }

    self.updateListener = function(id) self:Update(id) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.type = 0
end

function StrategyContentPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.contentExt ~= nil then
        self.contentExt:DeleteMe()
        self.contentExt = nil
    end
    if self.titleExt ~= nil then
        self.titleExt:DeleteMe()
        self.titleExt = nil
    end
    if self.btnLayout ~= nil then
        self.btnLayout:DeleteMe()
        self.btnLayout = nil
    end
    if self.titleLayout ~= nil then
        self.titleLayout:DeleteMe()
        self.titleLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StrategyContentPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_read_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.container = t:Find("ContentLayer/Container")
    self.titleObj = t:Find("ContentLayer/Container/Title").gameObject
    self.contentObj = t:Find("ContentLayer/Container/Content").gameObject
    self.contentRect = self.contentObj:GetComponent(RectTransform)
    self.titleContainer = self.titleObj.transform
    self.titleText = self.titleContainer:Find("Text"):GetComponent(Text)
    self.titleInfoText = self.titleContainer:Find("Info"):GetComponent(Text)
    self.titleInfoText.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(562, 30)
    self.titleRect = self.titleText.gameObject:GetComponent(RectTransform)
    self.contentText = t:Find("ContentLayer/Container/Content/Text"):GetComponent(Text)
    self.contentText.color = Color(12/255,82/255,176/255)

    self.btnContainer = t:Find("Reward/Container")
    self.collectBtn = self.btnContainer:Find("Collect"):GetComponent(Button)
    self.collectImage = self.btnContainer:Find("Collect"):GetComponent(Image)
    self.collectInsideImage = self.btnContainer:Find("Collect/Panel"):GetComponent(Image)
    self.transmitBtn = self.btnContainer:Find("Transmit"):GetComponent(Button)
    self.questionBtn = self.btnContainer:Find("Question"):GetComponent(Button)
    self.questionBtnText = self.btnContainer:Find("Question/Text"):GetComponent(Text)
    self.reEditBtn = self.btnContainer:Find("ReEdit"):GetComponent(Button)
    self.descText = t:Find("Reward/I18N"):GetComponent(Text)

    self.collectBtn.onClick:AddListener(function() self:OnCollect() end)
    self.questionBtn.onClick:AddListener(function() self:OnQuestion() end)
    self.transmitBtn.onClick:AddListener(function() self:OnShare() end)
    self.reEditBtn.onClick:AddListener(function() self:OnReEdit() end)
    self.questionBtn.gameObject:SetActive(false)
    self.collectBtn.gameObject.transform.anchoredPosition = Vector2(-70, -2)
    self.transmitBtn.gameObject.transform.anchoredPosition = Vector2(-36, -2)
    self.backBtn = t:Find("ContentLayer/Back"):GetComponent(Button)

    t:Find("ContentLayer"):GetComponent(ScrollRect).onValueChanged:AddListener(function(data) self:OnScroll(data) end)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    self.btnLayout = LuaBoxLayout.New(self.btnContainer, {axis = BoxLayoutAxis.X, cspacing = 10, border = 10})
    self.titleLayout = LuaBoxLayout.New(self.titleContainer, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 0})

    self.descText.text = ""
    self.reEditBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("再次编辑")
    self.backBtn.onClick:AddListener(function() self:OnBack() end)
    -- self.backBtn.gameObject:SetActive(self.model.lastKey ~= nil)
    -- self.contentText.lineSpacing = 1.5

    self.contentExt = MsgItemExt.New(self.contentText, 522, 16, 28)
    -- self.titleExt = MsgItemExt.New(self.titleText, 562, 20, 24)
end

function StrategyContentPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyContentPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateContent:AddListener(self.updateListener)

    self.openArgs = self.openArgs or {}

    if self.openArgs[3] == nil then     -- 列表打开
        self.data = self.extra
    else                                -- 直接转跳打开
        self.data = {id = self.openArgs[3], gm = 0}
    end

    if self.data.isDraft then
    else
        self.type = 0
        -- if self.data.gm ~= nil or (self.data.state ~= nil and self.data.state == 1) then
        if self.data.gm ~= nil then
            if self.model.type == 1 then
                self.type = 1
            end
        end
        if self.model.strategyTab[self.type][self.data.id] == nil then
            self.mgr:send16604(self.data.id, self.type)
        end
    end
    self.collectImage.color = Color(1, 1, 1)
    self.collectInsideImage.color = Color(1, 1, 1)
    self:Update(self.data.id)

    self.layout.panelRect.anchoredPosition = Vector2(0, 0)
    -- self.backBtn.gameObject:SetActive(self.model.lastKey ~= nil)
end

function StrategyContentPanel:OnHide()
    self:RemoveListeners()
end

function StrategyContentPanel:RemoveListeners()
    self.mgr.onUpdateContent:RemoveListener(self.updateListener)
end

function StrategyContentPanel:Update(id)
    self.titleRect.sizeDelta = Vector2(400, 30)
    local model = self.model
    local data = nil
    if self.data.isDraft then
        data = model.draftTab[id]
    elseif id ~= self.data.id or model.strategyTab[self.type][id] == nil then
        self.titleText.text = ""
        -- self.contentText.text = ""
        self.titleInfoText.text = ""
        -- self.titleExt:SetData("", true)
        self.contentExt:SetData("")
        return
    else
        data = model.strategyTab[self.type][id]
    end

    self.titleText.text = data.name
    -- self.contentText.text = data.content
    -- self.titleExt:SetData(data.name, true)
    self.contentExt:SetData(data.content)
    local role_name = self.data.role_name

    self.btnLayout:ReSet()
    self.questionBtn.gameObject:SetActive(false)
    self.collectBtn.gameObject:SetActive(false)
    self.transmitBtn.gameObject:SetActive(false)
    self.reEditBtn.gameObject:SetActive(false)

    if self.data.gm == nil then -- 我的攻略
        if self.data.state == 2 then    -- 未通过
            self.btnLayout:AddCell(self.reEditBtn.gameObject)
            self.descText.text = TI18N("攻略未通过审核，可再次编辑")
        elseif self.data.state == 0 then
            self.descText.text = TI18N("你的攻略正在审核中")
        else
            self.btnLayout:AddCell(self.collectBtn.gameObject)
            self.btnLayout:AddCell(self.transmitBtn.gameObject)
            self.descText.text = TI18N("作者发布该攻略获得了丰厚奖励")
        end
    else
        self.btnLayout:AddCell(self.collectBtn.gameObject)
        self.btnLayout:AddCell(self.transmitBtn.gameObject)
        if self.data.gm == 1 and RoleManager.Instance.RoleData.lev < 50 and ((data ~= nil and data.answer == 1) or self.data.answer == 1) then
            self.btnLayout:AddCell(self.questionBtn.gameObject)
        end

        if self.data.gm == 1 then
            self.descText.text = TI18N("本攻略由官方发布")
            role_name = TI18N("管理员")
        else
            self.descText.text = TI18N("作者发布该攻略获得了丰厚奖励")
        end
    end

    self.titleInfoText.text = string.format(TI18N("%s 作者:%s"),
            tostring(os.date("%Y/%m/%d", self.data.time)),
            tostring(role_name)
            )

    if data.reward == 1 then
        self.questionBtnText.text = TI18N("<color='#00FF00'>已领取</color>")
    else
        self.questionBtnText.text = TI18N("答题有奖")
    end

    if data.like == 1 then
        self.collectInsideImage.sprite = self.assetWrapper:GetSprite(AssetConfig.strategy_textures, "Heart")
    else
        self.collectInsideImage.sprite = self.assetWrapper:GetSprite(AssetConfig.strategy_textures, "Heard")
    end

    self.titleRect.sizeDelta = Vector2(400, self.titleText.preferredHeight + 10)
    self.contentRect.sizeDelta = Vector2(562, self.contentText.preferredHeight + 20)

    self.titleLayout:ReSet()
    self.titleLayout:AddCell(self.titleText.gameObject)
    self.titleLayout:AddCell(self.titleInfoText.gameObject)

    self.layout:ReSet()
    self.layout:AddCell(self.titleObj)
    self.layout:AddCell(self.contentObj)

    if self.data.gm == 1 then
    elseif self.data.gm == 0 then
    else
    end

    self.hasScrolled = (self.layout.panelRect.sizeDelta.y < 380)
end

function StrategyContentPanel:OnCollect()
    if self.data ~= nil and self.data.id ~= nil then
        self.mgr:send16605(self.data.id)
    end
end

function StrategyContentPanel:OnQuestion()
    if self.data.id ~= nil then
    --     self.model:OpenQuestionPanel(self.data)
        if self.reward == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("已领取过该奖励{face_1,2}"))
        elseif self.hasScrolled then
            self.model:AskQuestion(self.data.id)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请仔细阅读攻略吧{face_1,3}"))
        end
    end
end

function StrategyContentPanel:OnShare()
    local model = self.model
    local data = model.strategyTab[self.type][self.data.id]

    local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(self.data) end}
                , {label = TI18N("队伍频道"), callback = function() self:ShareToTeam(self.data) end}
                , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(self.data) end}}
    TipsManager.Instance:ShowButton({gameObject = self.transmitBtn.gameObject, data = btns})
end

function StrategyContentPanel:OnReEdit()
    local extra = {
        name = self.titleText.text,
        content = self.contentText.text,
        title_id = self.data.id,
    }
    BaseUtils.dump(extra, "extra")
    self.mgr.onChangeTab:Fire(100, extra)
end

function StrategyContentPanel:ShareToFriend(data)
    local callBack = function(_, friendData) self.model:ShareStrategy(MsgEumn.ExtPanelType.Friend, friendData, data.id, data.name) NoticeManager.Instance:FloatTipsByString(TI18N("分享成功")) end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack })
end

function StrategyContentPanel:ShareToGuild(data)
    if GuildManager.Instance.model:check_has_join_guild() then
        self.model:ShareStrategy(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.Guild, data.id, data.name)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
end

function StrategyContentPanel:ShareToTeam(data)
    if TeamManager.Instance:HasTeam() then
        self.model:ShareStrategy(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.Team, data.id, data.name)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有队伍"))
    end
end

function StrategyContentPanel:OnBack()
    local model = self.model
    if model.lastKey ~= nil then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, model.lastKey})
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 0})
    end
end

function StrategyContentPanel:OnScroll(data)
    self.lastPosition = self.lastPosition or 1
    if self.lastPosition >= 0.9 and data[2] < 0.9 then
        self.hasScrolled = true
    end
end

