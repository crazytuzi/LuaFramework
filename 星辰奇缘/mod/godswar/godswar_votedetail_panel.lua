-- -------------------------------------
-- 诸神之战投票操作界面
-- hosr
-- -------------------------------------
GodsWarVoteDetailPanel = GodsWarVoteDetailPanel or BaseClass(BasePanel)

function GodsWarVoteDetailPanel:__init(model)
    self.model = model
	self.resList = {
		{file = AssetConfig.godswarvote, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}
    self.currItem = nil
    self.max = 377
    self.height = 21

    self.valAll = 0
    self.val1 = 0
    self.val2 = 0
    self.valList = {self.val1, self.val2}
end

function GodsWarVoteDetailPanel:__delete()
    self.voteImg.sprite = nil
end

function GodsWarVoteDetailPanel:OnShow()
    self.index = self.openArgs.index
    self.dataList = self.openArgs.data
    self.callback = self.openArgs.callback
	self:Update()
end

function GodsWarVoteDetailPanel:OnHide()
end

function GodsWarVoteDetailPanel:Close()
    self.callback = nil
    self.model:CloseVoteDetail()
end

function GodsWarVoteDetailPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarvote))
    self.gameObject.name = "GodsWarVoteDetailPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    table.insert(self.itemList, GodsWarVoteDetailItem.New(self.transform:Find("Main/Item1").gameObject, self))
    table.insert(self.itemList, GodsWarVoteDetailItem.New(self.transform:Find("Main/Item2").gameObject, self))

    self.transform:Find("Main/LookButton"):GetComponent(Button).onClick:AddListener(function() self:ClickLook() end)
    self.transform:Find("Main/VideoButton"):GetComponent(Button).onClick:AddListener(function() self:ClickVideo() end)

    local voteBtn = self.transform:Find("Main/VoteButton")
    voteBtn:GetComponent(Button).onClick:AddListener(function() self:ClickVote() end)
    self.voteImg = voteBtn:GetComponent(Image)
    self.voteTxt = voteBtn:Find("Text"):GetComponent(Text)

    self.buleVal = self.transform:Find("Main/Progress/Blue/Val"):GetComponent(Text)
    self.yellowVal = self.transform:Find("Main/Progress/Yellow/Val"):GetComponent(Text)
    self.buleRect = self.transform:Find("Main/Progress/Blue"):GetComponent(RectTransform)
    self.yellowRect = self.transform:Find("Main/Progress/Yellow"):GetComponent(RectTransform)

    self.buleRect.sizeDelta = Vector2(self.max / 2, self.height)
    self.yellowRect.sizeDelta = Vector2(self.max / 2, self.height)

    self:OnShow()
end

function GodsWarVoteDetailPanel:Select(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
end

function GodsWarVoteDetailPanel:ClickLook()
    if self.currItem ~= nil and self.currItem.data ~= nil then
        GodsWarManager.Instance.model:OpenTeam(self.currItem.data)
    end
end

function GodsWarVoteDetailPanel:ClickVideo()
    local group = 1
    local name = ""
    if self.currItem ~= nil then
        -- group = GodsWarEumn.Group(self.currItem.data.lev, self.currItem.data.break_times)
        group = self.currItem.data.lev
        name = self.currItem.data.name
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = group, name = name})
    self:Close()
end

function GodsWarVoteDetailPanel:ClickVote()
    if GodsWarManager.Instance.voted then
        return
    end

    if self.callback ~= nil then
        self.callback(self.index, self.currItem.data)
    end
    self:Close()
end

function GodsWarVoteDetailPanel:Update()
    self.valAll = 0
    for i,v in ipairs(self.itemList) do
        local data = self.dataList[i]
        self.itemList[i]:SetData(data)
        local key = string.format("%s_%s_%s", data.tid, data.platform, data.zone_id)
        self.valList[i] = GodsWarManager.Instance.voteCountDic[key] or 1
        self.valAll = self.valAll + self.valList[i]
    end
    self:UpdateProgress()

    if self.currItem == nil then
        self:Select(self.itemList[1])
    end

    if GodsWarManager.Instance.voted then
        self.voteImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.voteTxt.text = TI18N("已投票")
    else
        self.voteImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.voteTxt.text = TI18N("投票")
    end
end

function GodsWarVoteDetailPanel:UpdateProgress()
    if self.valAll > 100 then
        local precent = self.valList[1] / self.valAll
        self.buleRect.sizeDelta = Vector2(self.max * precent, self.height)
        self.buleVal.text = string.format("%s%%", math.ceil(precent * 100))
        self.yellowRect.sizeDelta = Vector2(self.max * (1 - precent), self.height)
        self.yellowVal.text = string.format("%s%%", 100 - math.ceil(precent * 100))
    end
end