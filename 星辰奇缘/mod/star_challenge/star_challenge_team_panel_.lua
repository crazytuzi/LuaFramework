-- 龙王
-- ljh 20170725
StarChallengeTeamPanel = StarChallengeTeamPanel or BaseClass(BasePanel)

function StarChallengeTeamPanel:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.StarChallengeTeamPanel

    self.resList = {
        {file = AssetConfig.starchallengeteampanel, type = AssetType.Main}
        ,{file = AssetConfig.starchallenge_textures, type = AssetType.Dep}
    }

    -----------------------------------------------------------

    self.itemList = {}
    self.headSlotList = {}

    -----------------------------------------------------------

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function StarChallengeTeamPanel:__delete()
    self.OnHideEvent:Fire()

    for i=1, #self.headSlotList do
		self.headSlotList[i]:DeleteMe()
		self.headSlotList[i] = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StarChallengeTeamPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallengeteampanel))
    self.gameObject.name = "StarChallengeTeamPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3(0, 0, -400)

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self.transform:FindChild("Main"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")

    self.titleText2 = self.mainTransform:Find("Title2/Text"):GetComponent(Text)

    self.itemList = {}
    for i=1, 5 do
    	table.insert(self.itemList, self.mainTransform:Find("Item"..i))
    end

	self.headSlotList = {}
    for i=1, 5 do
	    local headSlot = HeadSlot.New()
	    UIUtils.AddUIChild(self.itemList[i]:Find("LeaderHead").gameObject, headSlot.gameObject)
	    table.insert(self.headSlotList, headSlot)
	end

    self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButtonClick() end)
end

function StarChallengeTeamPanel:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:CloseStarChallengeTeamPanel()
end

function StarChallengeTeamPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StarChallengeTeamPanel:OnOpen()
	if self.openArgs ~= nil and #self.openArgs > 1 then
        self.index = self.openArgs[1]
		self.data = self.openArgs[2]
	end
    self:Update()
end

function StarChallengeTeamPanel:OnHide()
end

function StarChallengeTeamPanel:Update()
    if self.index == 1 then
        self.titleText2.text = TI18N("龙王试炼")
    else
        self.titleText2.text = TI18N("龙王资格")
    end

	if self.data ~= nil then
		for i=1, #self.data.team_mates do
			local data = self.data.team_mates[i]
			local transform = self.itemList[i]
			transform.gameObject:SetActive(true)

			transform:Find("NameText"):GetComponent(Text).text = data.name
			transform:Find("FcText"):GetComponent(Text).text = string.format(TI18N("战力：%s"), data.fc)
			transform:Find("Classes"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, string.format("ClassesIcon_%s", data.classes))

			local dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
     		self.headSlotList[i]:SetAll(dat, {isSmall = true})

            local button = transform.gameObject:AddComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function()
                    TipsManager.Instance:ShowPlayer({ id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name })
                end)
		end

		for i=#self.data.team_mates+1, 5 do
			self.itemList[i].gameObject:SetActive(false)
		end
	end
end

function StarChallengeTeamPanel:OnOkButtonClick()
	if self.data ~= nil then
		CombatManager.Instance:Send10753(self.data.type, self.data.rec_id, self.data.rec_platform, self.data.rec_zone_id)
		self:OnClickClose()
		-- self.model:CloseWindow()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.starchallengewindow)
	end
end