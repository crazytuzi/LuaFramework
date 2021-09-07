-- ------------------------------------
-- 英雄擂台主界面
-- hosr
-- ------------------------------------
PlayerkillWindow = PlayerkillWindow or BaseClass(BasePanel)

function PlayerkillWindow:__init(model)
    self.name = "PlayerkillWindow"
    self.model = model
	self.resList = {
		{file = AssetConfig.playerkillmain, type = AssetType.Main},
        {file = AssetConfig.playerkilltexture, type = AssetType.Dep},
	}

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

	self.childTab = {}
	self.currIndex = 0
	self.minimize = false
end

function PlayerkillWindow:__delete()
    MainUIManager.Instance:ShowMainUICanvas(true)
    self.ishow = false
    -- for k,v in pairs(self.childTab) do
    --     v:Hiden()
    -- end
    if self.miniTweenId ~= nil then
        Tween.Instance:Cancel(self.miniTweenId)
        self.miniTweenId = nil
    end
    if self.maxiTweenId ~= nil then
        Tween.Instance:Cancel(self.maxiTweenId)
        self.maxiTweenId = nil
    end


	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end


	for i,v in ipairs(self.childTab) do
		v:DeleteMe()
	end
	self.childTab = nil
    PlayerkillManager.Instance:Send19300()
end

function PlayerkillWindow:Close()
    local status = PlayerkillManager.Instance.matchStatus
    if status == PlayerkillEumn.MatchStatus.Matching then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("关闭界面将<color='#ffff00'>退出匹配</color>，是否退出？")
        data.sureLabel = TI18N("退出")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self.model:CloseMainWindow()
            -- WindowManager.Instance:CloseWindowById(self.windowId)
        end

        NoticeManager.Instance:ConfirmTips(data)
    else
        self.model:CloseMainWindow()
	   -- WindowManager.Instance:CloseWindowById(self.windowId)
    end
end

function PlayerkillWindow:OnInitCompleted()
    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
end

function PlayerkillWindow:OnShow()
    self.ishow = true
	self.args = self.openArgs
	if self.args == nil or self.args[1] == nil then
		if self.currIndex == 0 then
			self.tabGroup:ChangeTab(1)
		else
			self.tabGroup:ChangeTab(self.currIndex)
		end
	else
		self.tabGroup:ChangeTab(self.args[1])
	end
end

function PlayerkillWindow:OnHide()
    self.ishow = false
    for k,v in pairs(self.childTab) do
        v:Hiden()
    end
end

function PlayerkillWindow:InitPanel()
    MainUIManager.Instance:ShowMainUICanvas(false)
    self.ishow = true
    -- self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playerkillmain))
    -- self.gameObject.name = "PlayerkillWindow"
    -- UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playerkillmain))
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject, true)
    self.gameObject.name = "PlayerkillWindow"
    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(3)

    self.transform = self.gameObject.transform
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.main = self.transform:Find("Main")

    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, self.setting)

    self.childTab[1] = PlayerkillFightPanel.New(self)
    self.childTab[2] = PlayerkillRankPanel.New(self)

    self.minimizeButton = self.transform:Find("Main/MiniButton"):GetComponent(Button)
    self.minimizeButton.gameObject:SetActive(true)
    self.minimizeButton.onClick:AddListener(function()
        self.miniTweenId = Tween.Instance:Scale(self.gameObject, Vector3(0.1, 0.1, 1), 0.2, function() self:TweenCallback() end, LeanTweenType.easeOutQuad).id
    end)

    self.transform:Find("ShowButton"):GetComponent(Button).onClick:AddListener(function()
        self.transform:SetSiblingIndex(3)
        ChatManager.Instance.model:ShowChatWindow({1})
    end)

    self:OnShow()
end

function PlayerkillWindow:ChangeTab(index)
	if self.currIndex ~= 0 and self.currIndex ~= index then
		self.childTab[self.currIndex]:Hiden()
	end

	self.currIndex = index
	if self.args == nil then
		self.childTab[self.currIndex]:Show()
	else
		self.childTab[self.currIndex]:Show(self.args[2])
	end
end

function PlayerkillWindow:TweenCallback()
    local status = PlayerkillManager.Instance.matchStatus
    if status == PlayerkillEumn.MatchStatus.Matching then
        self.minimize = true
        self.gameObject:SetActive(false)
        self.model:OpenMinimizePanel()
        MainUIManager.Instance:ShowMainUICanvas(true)
    else
        self:Close()
    end
end

function PlayerkillWindow:MaximizeMainWindow()
    self.minimize = false
    self.gameObject:SetActive(true)
    self.maxiTweenId = Tween.Instance:Scale(self.gameObject, Vector3.one, 0.2, nil, LeanTweenType.easeOutQuad).id
end
