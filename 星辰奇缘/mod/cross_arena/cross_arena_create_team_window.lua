-- 跨服擂台创建房间窗口
-- ljh 20190329
CrossArenaCreateTeamWindow = CrossArenaCreateTeamWindow or BaseClass(BasePanel)

function CrossArenaCreateTeamWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.CrossArenaCreateTeamWindow

    self.resList = {
        {file = AssetConfig.crossarenacreateteamwindow, type = AssetType.Main},
        {file = string.format(AssetConfig.effect, 20486), type = AssetType.Main},
    }

    -----------------------------------------------------------
    self.windowType = 1
    self.roomType = 1
    -----------------------------------------------------------
    
    self.levelMin = 1
    self.levelMax = 1

    self.btnNameList = {}
    -----------------------------------------------------------

    self.updateListener = function() self:Update() end

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function CrossArenaCreateTeamWindow:__delete()
    self.OnHideEvent:Fire()

    if self.roomTypeTabButtonGroup ~= nil then
        self.roomTypeTabButtonGroup:DeleteMe()
        self.roomTypeTabButtonGroup = nil 
    end

    if self.battleTypeTabButtonGroup ~= nil then
        self.battleTypeTabButtonGroup:DeleteMe()
        self.battleTypeTabButtonGroup = nil 
    end

    if self.levelTabButtonGroup ~= nil then
        self.levelTabButtonGroup:DeleteMe()
        self.levelTabButtonGroup = nil 
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossArenaCreateTeamWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenacreateteamwindow))
    self.gameObject.name = "CrossArenaCreateTeamWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    	
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform = self.transform:FindChild("Main")
    self.mainTransform:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)
    self.mainTransform.localPosition = Vector3(0, 0, -600)

    self.nameInput = self.mainTransform.transform:FindChild("NameInput"):GetComponent(InputField)
    self.nameInput.textComponent = self.nameInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.nameInput.placeholder = self.nameInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.nameInput.characterLimit = 15
    self.nameButton = self.mainTransform.transform:FindChild("NameButton"):GetComponent(Button)
    self.nameButton.onClick:AddListener(function() self:OnClickNameButton() end)


    self.roomTypeTabButtonGroupObj = self.mainTransform:FindChild("RoomTypeTabButtonGroup").gameObject   
    self.roomTypeAttention1 = self.mainTransform:FindChild("RoomTypeAttention/Attention1").gameObject   
    self.roomTypeAttention1.transform:FindChild("Text"):GetComponent(Text).text = TI18N("                  以武会友，创建友谊赛房间")
    self.roomTypeAttention2 = self.mainTransform:FindChild("RoomTypeAttention/Attention2").gameObject   
    self.roomTypeAttention2_Ext = MsgItemExt.New(self.roomTypeAttention2.transform:FindChild("Text"):GetComponent(Text), 300, 18, 34)
    self.roomTypeAttention2_Ext:SetData(TI18N("跨服决斗，本模式战斗将消耗双方各{assets_1, 90002, 300}\n决斗将全服传闻，获胜者可赢得称号和奖励"))

    self.battleTypeTabButtonGroupObj = self.mainTransform:FindChild("BattleTypeTabButtonGroup").gameObject   

    self.levelTabButtonGroupObj = self.mainTransform:FindChild("LevelTabButtonGroup").gameObject   

    self.levelMinInput = self.mainTransform.transform:FindChild("LevelMinInput/Text"):GetComponent(Text)
    self.mainTransform.transform:FindChild("LevelMinInput"):GetComponent(Button).onClick:AddListener(function() self:OnClickLevelMinButton() end)
    self.levelMaxInput = self.mainTransform.transform:FindChild("LevelMaxInput/Text"):GetComponent(Text)
    self.mainTransform.transform:FindChild("LevelMaxInput"):GetComponent(Button).onClick:AddListener(function() self:OnClickLevelMaxButton() end)

    self.passWordLabel = self.mainTransform.transform:FindChild("PassWordLabel").gameObject
    self.passWordInput = self.mainTransform.transform:FindChild("PassWordInput"):GetComponent(InputField)
    self.passWordInput.textComponent = self.passWordInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.passWordInput.placeholder = self.passWordInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.passWordInput.characterLimit = 4

    self.letterLabel = self.mainTransform.transform:FindChild("LetterLabel").gameObject
    self.letterToggle = self.mainTransform.transform:FindChild("LetterToggle"):GetComponent(Toggle)
    self.letterToggle.isOn = false
    self.letterToggle.onValueChanged:AddListener(function(on) self:OnToggleChange(on) end)
    self.letterAttention = self.mainTransform.transform:FindChild("LetterAttention").gameObject

    self.okButton = self.mainTransform:FindChild("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnClickOkButton() end)
    self.okButton2 = self.mainTransform:FindChild("OkButton2"):GetComponent(Button)
    self.okButton2.onClick:AddListener(function() self:OnClickOkButton() end)

    self.roomTypeTabButtonGroup = TabGroup.New(self.roomTypeTabButtonGroupObj, function(index) self:OnRoomTypeTabButtonGroup_ChangeTab(index) end)
    self.battleTypeTabButtonGroup = TabGroup.New(self.battleTypeTabButtonGroupObj, function(index) self:OnBattleTypeTabButtonGroup_ChangeTab(index) end)
    self.levelTabButtonGroup = TabGroup.New(self.levelTabButtonGroupObj, function(index) self:OnLevelTabButtonGroup_ChangeTab(index) end)

    self.nameSelect = self.transform:Find("Select")
    self.nameSelect:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.nameSelect.gameObject:SetActive(false) end)
    self.nameSelectMain = self.nameSelect:Find("Main"):GetComponent(RectTransform)
    self.scroll = self.nameSelect:Find("Main/scroll") 
    self.scroll_content = self.nameSelect:Find("Main/scroll/scroll_content")
    self.cloneBtn = self.nameSelect:Find("Main/scroll/scroll_content/btn").gameObject
    self.cloneBtn:SetActive(false)
    self.layout = LuaBoxLayout.New(self.scroll_content, { axis = BoxLayoutAxis.Y, scrollRect = self.scroll, border = 2 })

    local effect = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20486)))
    local effectTransform = effect.transform
    effectTransform:SetParent(self.roomTypeTabButtonGroupObj.transform)
    effectTransform.localScale = Vector3.one
    effectTransform.localPosition = Vector3(260, 0, -300)
    effectTransform.localRotation = Quaternion.identity
end

function CrossArenaCreateTeamWindow:OnClickClose()
    self.model:CloseCrossArenaCreateTeamWindow()
end

function CrossArenaCreateTeamWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CrossArenaCreateTeamWindow:OnOpen()
    local roleData = RoleManager.Instance.RoleData
    for i,v in pairs(DataCrossArena.data_lev_limit) do
        if (roleData.lev >= v.lev_min and roleData.lev_break_times >= v.lev_min_break) and (roleData.lev <= v.lev_max and roleData.lev_break_times <= v.lev_max_break) then
            self.levelMinInput.text = tostring(v.lev_min_name)
            self.levelMaxInput.text = tostring(v.lev_max_name)

            self.levelMin = i
            self.levelMax = i
        end
    end

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.windowType = self.openArgs[1]

        local teamNumber = 1 
        if TeamManager.Instance:HasTeam() then
            teamNumber = TeamManager.Instance.teamNumber
        end
        local roomNameList = {}
        if self.windowType == 1 or self.windowType == 2 then 
            for i,v in pairs(DataCrossArena.data_room_name) do
                if v.num == teamNumber then
                    table.insert(roomNameList, v.name)
                end
            end
        else
            for i,v in pairs(DataCrossArena.data_letter_name) do
                if v.num == teamNumber then
                    table.insert(roomNameList, v.name)
                end
            end
        end
        if #roomNameList > 0 then
            self.nameInput.text = roomNameList[math.random(1, #roomNameList)]
        end

        if #self.openArgs > 1 then
            self.roomType = self.openArgs[2]
            self.roomTypeTabButtonGroup:ChangeTab(self.roomType)
            if #self.openArgs > 2 then
                self.room_id = self.openArgs[3]
            end
        end

        if self.windowType == 2 then
            self.nameInput.text = self.model.myRoomData.name
            self.passWordInput.text = self.model.myRoomData.password

            if self.model.myRoomData.provocation_type == 1 then
                self.roomTypeTabButtonGroup:ChangeTab(2)
            end
            if self.model.myRoomData.room_lev_min == 0 and self.model.myRoomData.min_lev_break == 0 and self.model.myRoomData.room_lev_max == 200 and self.model.myRoomData.max_lev_break == 1 then
                self.levelTabButtonGroup:ChangeTab(1)
            else
                self.levelTabButtonGroup:ChangeTab(2)
            end
        end
    end

    self:Update()

    -- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
    -- StarChallengeManager.Instance.OnUpdateList:AddListener(self.updateListener)
end

function CrossArenaCreateTeamWindow:OnHide()
    -- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
end

function CrossArenaCreateTeamWindow:Update()
    if self.windowType == 1 then
        self.mainTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("创建房间")
        if self.roomType == 1 then
            self.mainTransform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("确认创建")
        else
            self.mainTransform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("确认创建")
        end
    elseif self.windowType == 2 then
        self.mainTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("修改房间")
        self.mainTransform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("确认修改")
    elseif self.windowType == 3 or self.windowType == 4 then
        self.mainTransform:FindChild("Title/Text"):GetComponent(Text).text = TI18N("跨服战书")

        self.passWordLabel:SetActive(false)
        self.passWordInput.gameObject:SetActive(false)

        self.roomTypeTabButtonGroupObj:SetActive(false)
        self.mainTransform:FindChild("RoomTypeLabel").gameObject:SetActive(false)
        self.mainTransform:FindChild("RoomTypeAttention").gameObject:SetActive(false)

        self.mainTransform:FindChild("BattleTypeLabel").gameObject:SetActive(true)
        self.battleTypeTabButtonGroupObj:SetActive(true)

        self.letterLabel:SetActive(true)
        self.letterToggle.gameObject:SetActive(true)
        self.letterAttention:SetActive(true)

        self.mainTransform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("确认发布")

        if self.letterToggle.isOn then
            self.okButton.gameObject:SetActive(false)
            self.okButton2.gameObject:SetActive(true)
        else
            self.okButton.gameObject:SetActive(true)
            self.okButton2.gameObject:SetActive(false)
        end
    end

    if self.roomType == 1 then
        self.roomTypeAttention1:SetActive(true)
        self.roomTypeAttention2:SetActive(false)
    else
        self.roomTypeAttention1:SetActive(false)
        self.roomTypeAttention2:SetActive(true)
    end

    if self.windowType == 3 or self.windowType == 4 then -- 战书类型
        self.mainTransform:GetComponent(RectTransform).sizeDelta = Vector2(525, 400)
        self.nameSelectMain.localPosition = Vector3(64, 110, 0)
    else
        self.mainTransform:GetComponent(RectTransform).sizeDelta = Vector2(525, 430)
        -- self.nameSelectMain.localPosition = Vector3(64, -130, 0)
    end
end

function CrossArenaCreateTeamWindow:OnClickNameButton()
    self.nameSelect.gameObject:SetActive(true)
    self:InitNameList()
end

function CrossArenaCreateTeamWindow:OnRoomTypeTabButtonGroup_ChangeTab(index)
    self.roomType = index
    self:Update()
end

function CrossArenaCreateTeamWindow:OnBattleTypeTabButtonGroup_ChangeTab(index)
    self.battleType = index
end

function CrossArenaCreateTeamWindow:OnLevelTabButtonGroup_ChangeTab(index)
    self.levelLimitType = index
    if self.levelLimitType == 2 then

    end
end

function CrossArenaCreateTeamWindow:OnClickLevelMinButton()
    local btns = {}
    for i=1, self.levelMax do
        local index = i
        local lev_limit = DataCrossArena.data_lev_limit[index]
        table.insert(btns, {label = lev_limit.lev_min_button_name, callback = function() self:OnSelectLevelMin(index) end})
    end
    TipsManager.Instance:ShowButton({gameObject = self.mainTransform.transform:FindChild("LevelMinInput").gameObject, data = btns})
end

function CrossArenaCreateTeamWindow:OnClickLevelMaxButton()
    local btns = {}
    for i=self.levelMin, #DataCrossArena.data_lev_limit do
        local index = i
        local lev_limit = DataCrossArena.data_lev_limit[index]
        table.insert(btns, {label = lev_limit.lev_max_button_name, callback = function() self:OnSelectLevelMax(index) end})
    end
    TipsManager.Instance:ShowButton({gameObject = self.mainTransform.transform:FindChild("LevelMaxInput").gameObject, data = btns})
end

function CrossArenaCreateTeamWindow:OnSelectLevelMin(index)
    self.levelMin = index
    self.levelMinInput.text = DataCrossArena.data_lev_limit[index].lev_min_name

    self.levelTabButtonGroup:ChangeTab(2)
end

function CrossArenaCreateTeamWindow:OnSelectLevelMax(index)
    self.levelMax = index
    self.levelMaxInput.text = DataCrossArena.data_lev_limit[index].lev_max_name

    self.levelTabButtonGroup:ChangeTab(2)
end

function CrossArenaCreateTeamWindow:OnToggleChange(on)
    self:Update()
end

function CrossArenaCreateTeamWindow:InitNameList()
    local nameNum = 0
    if self.windowType == 1 or self.windowType == 2 then 
        nameNum = DataCrossArena.data_room_name_length
        for index = 1, nameNum do
            if  self.btnNameList[index] == nil then
                self.btnNameList[index] = GameObject.Instantiate(self.cloneBtn)
                self.btnNameList[index]:SetActive(true)
                self.btnNameList[index].name = tostring(index)
                self.layout:AddCell(self.btnNameList[index])
                local txt = self.btnNameList[index].transform:Find("Text").gameObject:GetComponent(Text)
                txt.text = DataCrossArena.data_room_name[index].name
                self.btnNameList[index]:GetComponent(Button).onClick:AddListener( function() self:NameButtonClick(index) end)
            end
        end
    else
        nameNum = DataCrossArena.data_letter_name_length
        for index = 1, nameNum do
            if  self.btnNameList[index] == nil then
                self.btnNameList[index] = GameObject.Instantiate(self.cloneBtn)
                self.btnNameList[index]:SetActive(true)
                self.btnNameList[index].name = tostring(index)
                self.layout:AddCell(self.btnNameList[index])
                local txt = self.btnNameList[index].transform:Find("Text").gameObject:GetComponent(Text)
                txt.text = DataCrossArena.data_letter_name[index].name
                self.btnNameList[index]:GetComponent(Button).onClick:AddListener( function() self:NameButtonClick(index) end)
            end
        end
    end
    
    local sizeDelta = self.nameSelectMain.sizeDelta
    local mheight = 26 + nameNum * 44
    self.nameSelectMain.sizeDelta = Vector2(sizeDelta.x, mheight)
end

function CrossArenaCreateTeamWindow:NameButtonClick(index)
    if self.windowType == 1 or self.windowType == 2 then 
        self.nameInput.text = DataCrossArena.data_room_name[index].name
    else
        self.nameInput.text = DataCrossArena.data_letter_name[index].name
    end
    self.nameSelect.gameObject:SetActive(false)
end

function CrossArenaCreateTeamWindow:OnClickOkButton()
    if self.windowType == 2 then
        if self.model.myRoomData ~= nil and self.model.myRoomData.horn_rid ~= 0 and self.model.myRoomData.target_rid ~= 0 then
            NoticeManager.Instance:FloatTipsByString("已发起<color='#ffff00'>决斗邀请函</color>，决斗结束前<color='#ffff00'>不能更改模式</color>哟{face_1,2}")
            return
        end
    end

    local room_name = self.nameInput.text
    local room_mode = self.battleType
    local room_lev_min = DataCrossArena.data_lev_limit[self.levelMin].lev_min
    local min_lev_break = DataCrossArena.data_lev_limit[self.levelMin].lev_min_break
    local room_lev_max = DataCrossArena.data_lev_limit[self.levelMax].lev_max
    local max_lev_break = DataCrossArena.data_lev_limit[self.levelMax].lev_max_break
    local room_password = self.passWordInput.text
    local letter_toggle = 0
    if self.letterToggle.isOn then
        letter_toggle = 1
    end
    if self.levelLimitType == 1 then
        room_lev_min = 0
        min_lev_break = 0
        room_lev_max = 200
        max_lev_break = 1
    end
    local provocation_type = self.roomType - 1

    if self.windowType == 1 then
        if not TeamManager.Instance:HasTeam() then
            TeamManager.Instance:Send11701()
        end
        CrossArenaManager.Instance:Send20703(room_name, room_mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, room_password, provocation_type)
    elseif self.windowType == 2 then
        CrossArenaManager.Instance:Send20706(self.model.myRoomData.id, room_name, room_mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, room_password, provocation_type)
    elseif self.windowType == 3 then
        CrossArenaManager.Instance:Send20726(room_name, room_mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, letter_toggle, provocation_type)
    elseif self.windowType == 4 then
        CrossArenaManager.Instance:Send20727(self.room_id, room_name, room_mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, letter_toggle, provocation_type)
    end
    self:OnClickClose()
end
