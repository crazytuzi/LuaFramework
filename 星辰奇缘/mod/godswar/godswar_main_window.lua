-- ----------------------------
-- 诸神之战
-- ----------------------------
GodsWarMainWindow = GodsWarMainWindow or BaseClass(BaseWindow)

function GodsWarMainWindow:__init(model)
	self.model = model
    self.windowId = WindowConfig.WinID.godswar_main
	self.resList = {
		{file = AssetConfig.godswarmain, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
        {file = AssetConfig.rank_textures,type = AssetType.Dep}
	}


    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.cacheMode = CacheMode.Visible
    self.currIndex = 0
    self.listener = function() self:ProtoUpdate() end
    self.numberListener = function() self:SetNumber() end
end

function GodsWarMainWindow:__delete()
    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
	EventMgr.Instance:RemoveListener(event_name.godswar_team_update, self.listener)
	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
	end

	for i,v in pairs(self.panelList) do
		v:DeleteMe()
	end
	self.panelList = nil
end

function GodsWarMainWindow:OnShow()

    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
    GodsWarManager.Instance.OnUpdateTime:AddListener(self.numberListener)
    GodsWarManager.Instance:Send17933()
	self.args = self.openArgs
    if self.openArgs ~= nil then
            self.number = self.openArgs.number
            self.isChoose = self.openArgs.isChoose or false
    end

    local status = GodsWarManager.Instance.status
    if status == GodsWarEumn.Step.None and self.isChoose == false then
        self.tabGroup:ChangeTab(3)
    else
        if self.args == nil or self.args[1] == nil then
            if self.currIndex ~= 0 then
                self.tabGroup:ChangeTab(self.currIndex)
            else
                self.tabGroup:ChangeTab(1)
            end
        else
            self.tabGroup:ChangeTab(self.args[1])
        end
    end
	self:ProtoUpdate()
end

function GodsWarMainWindow:OnHide()
    if self.panelList[self.currIndex] ~= nil then
        self.panelList[self.currIndex]:Hiden()
    end
end

function GodsWarMainWindow:SetNumber()
    local number1 = nil
    local number2 = nil
    local isNumberDouble = false

    local myNumber = self.number or GodsWarManager.Instance.godTimeNumber
    --print(myNumber .. "fsdkjflksdjfklsdj")
    if tonumber(myNumber) >= 10 then

        local i,j,tag,val = string.find(tostring(myNumber),"(%d)(%d)")
       number1 = tostring(tag)
       number2 = tostring(val)
       isNumberDouble = true

    end


    if isNumberDouble == true then
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number1)
        self.number2 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number2)
    else
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. myNumber)
        self.number2 = nil
    end

    if self.number1 == nil then
        self.numberImg1.gameObject:SetActive(false)
    else
        self.numberImg1.gameObject:SetActive(true)
        self.numberImg1:SetNativeSize()
        self.numberImg1.sprite = self.number1
    end

    if self.number2 == nil then
        self.numberImg2.gameObject:SetActive(false)
    else
        self.numberImg2.gameObject:SetActive(true)
        self.numberImg2:SetNativeSize()
        self.numberImg2.sprite = self.number2
    end
end

function GodsWarMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarmain))
    self.gameObject.name = "GodsWarMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.mainTransform = self.transform:Find("Main")

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseMain() end)


    self.numberImg1 = self.transform:Find("Main/Title/Image1"):GetComponent(Image)
    self.numberImg2 = self.transform:Find("Main/Title/Image2"):GetComponent(Image)



    local tabGroupSetting = {
        notAutoSelect = true,
        isVertical = true,
        noCheckRepeat = true,
        -- cannotSelect = {false, true, true}
    }
    self.transform:Find("Main/TabButtonGroup").anchoredPosition = Vector2(742,-56)
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.panelList = {
    	GodsWarInfoPanel.New(self),
    	GodsWarTeamPanel.New(self),
    	GodsWarFightPanel.New(self),
        GodsWarHistoryPanel.New(self),
        GodsWarJiFenPanel.New(self),
        nil,
        GodsWarChallengePanel.New(self),
	}
	EventMgr.Instance:AddListener(event_name.godswar_team_update, self.listener)
	self:OnShow()
end

function GodsWarMainWindow:ChangeTab(index)
	self.tabGroup:ShowRed(index, false)
	if self.panelList[self.currIndex] ~= nil then
		self.panelList[self.currIndex]:Hiden()
	end
	self.currIndex = index
    --BaseUtils.dump(self.args,"self.args")

    if index == 6 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 2, group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)})
        self.tabGroup:ChangeTab(1)
    else
        if self.args ~= nil then
            table.remove(self.args,1)
            self.panelList[self.currIndex]:Show(self.args)
            -- if self.args.isChoose == nil then
            --     self.panelList[self.currIndex]:Show(self.args)
            -- else
            --     self.panelList[self.currIndex]:Show()
            -- end
            self.args = nil
        else
            self.panelList[self.currIndex]:Show()
        end
    end
    GodsWarManager.Instance.isHitstory = self.currIndex == 4
end

function GodsWarMainWindow:ProtoUpdate()
    local setting = {
        notAutoSelect = true,
        isVertical = true,
        noCheckRepeat = true,
        perWidth = 87,
        perHeight = 58,
        spacing = 10,
        offsetWidth = 8,
    }
    local lv1 = 1
    local lv2 = 1
    local lv3 = 1
    local lv4 = 999
    local lv5 = 1
    local lv6 = 1
    local lv7 = 1

	local status = GodsWarManager.Instance.status
    if status == GodsWarEumn.Step.None then
       lv1 = 999
       lv2 = 999
       lv3 = 1
	elseif status < GodsWarEumn.Step.Publicity then
    	  lv3 = 999
    end
    if GodsWarManager.Instance.season - #GodsWarManager.Instance.unShowList > 1 then
        lv4 = 1
    end
    local HasCeremary = GodsWarWorShipManager.Instance.isHasGorWarShip
    local ChallengeStatus = GodsWarWorShipManager.Instance.godsWarStatus

    if HasCeremary == 1 and ChallengeStatus ~= 0 then
        lv2 = 999
    else
        lv7 = 999
    end

    setting.openLevel = {lv1,lv2,lv3,lv4,lv5,lv6,lv7}
    self.tabGroup:UpdateSetting(setting)
    self.tabGroup:Layout()
	self.tabGroup:ShowRed(2, GodsWarManager.Instance.requestRed)
end
