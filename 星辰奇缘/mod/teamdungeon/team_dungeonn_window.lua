-- ----------------------------------------------------------
-- UI - 组队副本窗口
-- ljh 20170205
-- ----------------------------------------------------------
TeamDungeonWindow = TeamDungeonWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TeamDungeonWindow:__init(model)
    self.model = model
    self.name = "TeamDungeonWindow"
    self.windowId = WindowConfig.WinID.teamdungeonwindow
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.teamdungeonwindow, type = AssetType.Main}
        , {file = AssetConfig.teamdungeon_textures, type = AssetType.Dep}
        , {file = AssetConfig.chat_window_res, type = AssetType.Dep}
        , {file = AssetConfig.teamres, type = AssetType.Dep}
        , {file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
	self.dungeonItemList = {}
    self.dungeonCloneItem = nil
    self.dungeonContainer = nil

    self.selectDungeonItem = nil

    self.teamItemList = {}
    self.teamCloneItem = nil
    self.teamContainer = nil

    self.memberItemList = {}
    self.bubbleList = {}

    self.teamList = nil
    self.memberList = nil

	self.teamHeadList = {}
	self.memberHeadList = {}

	self.dungeonItemSlotList = {}
	self.dungeonItemMsgItemExtList = {}

	self.teamPanelTitleText = nil

	self.teamToggle = nil
	self.teamToggleText = nil
	self.refreshButton = nil
	self.createTeamButton = nil
	self.quickJionButton = nil

	self.memberListDescText = nil
	self.memberListStateText = nil
	self.memberListTimeText = nil
	self.exitButton = nil
	self.startButton = nil

	self.tweenId = nil
	self.moveTweenId = nil
	------------------------------------------------
	self.dungeonTitleButtonTips = {
		TI18N("1、通关副本获得<color='#ffff00'>结算奖励</color>时需消耗1次挑战次数")
		, TI18N("2、每日<color='#ffff00'>5:00</color>重置副本次数")
		, TI18N("3、随<color='#ffff00'>人物等级</color>增长，可提升副本每日总次数")
	}

	self.currentIndex = 0

	self.timerId = nil

	self.autoRefreshTime = nil
	self.autoJoinTime = nil
	self.autoStartTime = nil
	self.recruitFreezeIndex = nil
	self.memberListStateTextIndex = 0
	self.quickJionTextIndex = 0

    ------------------------------------------------
    self._OnUpdate = function(args, args2) self:OnUpdate(args, args2) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.queue = BaseUtils.create_queue()
end

function TeamDungeonWindow:__delete()
    self:OnHide()

    for i,v in ipairs(self.dungeonItemSlotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.dungeonItemSlotList = nil

    for _, teamHead in pairs(self.teamHeadList) do
        teamHead:DeleteMe()
        teamHead = nil
    end

    for _, memberHead in pairs(self.memberHeadList) do
        memberHead:DeleteMe()
        memberHead = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function TeamDungeonWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamdungeonwindow))
    self.gameObject.name = "TeamDungeonWindow"
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)

    ----------------------------
    --特殊处理 如果仍然存在翻牌界面，把翻牌界面盖在本窗口上面
    ----------------------------
    if self.model.rewardWindow ~= nil and self.model.rewardWindow.transform ~= nil then
    	self.model.rewardWindow.transform:SetAsFirstSibling()
    end

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.transform:FindChild("ClosePanel").gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickMini() end)

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.miniBtn = self.mainTransform:FindChild("MiniButton"):GetComponent(Button)
    self.miniBtn.onClick:AddListener(function() self:OnClickMini() end)

    self.transform:Find("ShowButton"):GetComponent(Button).onClick:AddListener(function()
        self.transform:SetSiblingIndex(3)
        ChatManager.Instance.model:ShowChatWindow({2})
    end)

    self.dungeonTitleText = self.mainTransform:FindChild("DungeonPanel/Title/Text"):GetComponent(Text)
	self.mainTransform:FindChild("DungeonPanel/Title/DescButton"):GetComponent(Button).onClick:AddListener(function()
			TipsManager.Instance:ShowText({gameObject = self.mainTransform:FindChild("DungeonPanel/Title/DescButton").gameObject, itemData = self.dungeonTitleButtonTips})
		end)

    self.dungeonCloneItem = self.mainTransform:FindChild("DungeonPanel/DungeonList/Item").gameObject
    self.dungeonCloneItem:SetActive(false)
    self.dungeonContainer = self.mainTransform:FindChild("DungeonPanel/DungeonList/Container").gameObject
    self.dungeonContainerMaskHeight = self.mainTransform:FindChild("DungeonPanel/DungeonList"):GetComponent(RectTransform).sizeDelta.y
	self.dungeonCloneItemHeight = self.dungeonCloneItem.transform:GetComponent(RectTransform).sizeDelta.y

    self.dungeonItemPanelTitleText = self.mainTransform:FindChild("DungeonPanel/ItemPanel/TitleText"):GetComponent(Text)

    local dungeonPanelItemPanelContainerItem = self.mainTransform:FindChild("DungeonPanel/ItemPanel/Container/Item").gameObject
    dungeonPanelItemPanelContainerItem:SetActive(false)
    local dungeonPanelItemPanelContainer = self.mainTransform:FindChild("DungeonPanel/ItemPanel/Container").gameObject
    for i = 1, 4 do
    	local item = GameObject.Instantiate(dungeonPanelItemPanelContainerItem)
        item:SetActive(true)
        item.transform:SetParent(dungeonPanelItemPanelContainer.transform)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

	    local itemSlot = ItemSlot.New()
    	UIUtils.AddUIChild(item, itemSlot.gameObject)

    	table.insert(self.dungeonItemSlotList, itemSlot)
	end


	self.teamPanelTitleText = self.mainTransform:FindChild("TeamPanel/Title/Text"):GetComponent(Text)

	self.teamList = self.mainTransform:FindChild("TeamPanel/TeamList").gameObject
	self.noTeamTips = self.teamList.transform:FindChild("Mask/NoTeamTips").gameObject
	self.noTeamTipsButton = self.noTeamTips.transform:FindChild("Button").gameObject
	self.noTeamTipsButton:GetComponent(Button).onClick:AddListener(function() self:CreateTeam() end)
	-- self.teamCloneItem = self.teamList.transform:FindChild("Mask/TeamItem").gameObject
    -- self.teamContainer = self.teamList.transform:FindChild("Mask/Container").gameObject
	self.teamToggle = self.teamList.transform:FindChild("Toggle"):GetComponent(Toggle)
	self.teamToggle.onValueChanged:AddListener(function(on) self:OnToggleChange(on) end)
	self.teamToggleText = self.teamList.transform:FindChild("Toggle/Text"):GetComponent(Text)
	self.refreshButton = self.teamList.transform:FindChild("RefreshButton"):GetComponent(Button)
	self.refreshButton.onClick:AddListener(function() self:RefreshTeamList(true) end)
	self.createTeamButton = self.teamList.transform:FindChild("CreateTeamButton"):GetComponent(Button)
	self.createTeamButton.onClick:AddListener(function() self:CreateTeam() end)
	self.quickJionButton = self.teamList.transform:FindChild("QuickJionButton"):GetComponent(Button)
	self.quickJionButton.onClick:AddListener(function() self:QuickJion() end)
	self.quickJionButtonText = self.teamList.transform:FindChild("QuickJionButton/Text"):GetComponent(Text)

    self.teamContainer = self.teamList.transform:FindChild("Mask/Container")
    self.teamItem = self.teamContainer.transform:FindChild("1").gameObject
    self.tontainer_vScroll =  self.teamList.transform:FindChild("Mask"):GetComponent(ScrollRect)
    self.tontainer_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.team_list_data)
    end)

    self.teamContainer_item_list = {}
    for i=1, 7 do
        local go = self.teamContainer.transform:FindChild(tostring(i)).gameObject

        local item = DungeonTeamItem.New(go, self)
        table.insert(self.teamContainer_item_list, item)
    end

    -- local go = GameObject.Instantiate(self.teamContainer.transform:FindChild(tostring(1)).gameObject)
    -- go.transform:SetParent(self.teamContainer.transform)
    -- go:GetComponent(RectTransform).localPosition = Vector3(0, 0, 0)
    -- go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
    -- local item = DungeonTeamItem.New(go, self)
    -- table.insert(self.teamContainer_item_list, item)
    -- local go = GameObject.Instantiate(self.teamContainer.transform:FindChild(tostring(1)).gameObject)
    -- go.transform:SetParent(self.teamContainer.transform)
    -- go:GetComponent(RectTransform).localPosition = Vector3(0, 0, 0)
    -- go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
    -- local item = DungeonTeamItem.New(go, self)
    -- table.insert(self.teamContainer_item_list, item)

    self.single_item_height = self.teamItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.teamList.transform:FindChild("Mask"):GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.teamContainer:GetComponent(RectTransform).anchoredPosition.y

    self.team_list_data = {
       item_list = self.teamContainer_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.teamContainer  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

	self.memberList = self.mainTransform:FindChild("TeamPanel/MemberList").gameObject
	for i = 1, 5 do
		local memberItem = self.memberList.transform:FindChild("MemberItem"..i).gameObject
		self.memberItemList[i] = memberItem

		memberItem:GetComponent(Button).onClick:AddListener(function() self:OnMemberItemClick(i) end)
		memberItem.transform:Find("LeaderMark").gameObject:SetActive(i==1)

		local headSlot = HeadSlot.New()
		headSlot:SetRectParent(memberItem.transform:Find("Head"))
		self.memberHeadList[i] = headSlot
	end
	self.memberListDescText = self.memberList.transform:FindChild("DescText"):GetComponent(Text)
	self.memberListStateText = self.memberList.transform:FindChild("State/Text"):GetComponent(Text)
	self.memberListTimeText = self.memberList.transform:FindChild("TimeText"):GetComponent(Text)
	self.memberListTimeText2 = self.memberList.transform:FindChild("TimeText2"):GetComponent(Text)
	self.memberListTimeText2.text = ""

	for i = 1, 5 do
		self.bubbleList[i] = {}

		local bubbleItem = self.memberList.transform:FindChild("Bubble"..i)
		self.bubbleList[i].bubble = bubbleItem
		self.bubbleList[i].bubbleText = bubbleItem:Find("Text"):GetComponent(Text)
        self.bubbleList[i].Ext = MsgItemExt.New(self.bubbleList[i].bubbleText, 159.65, 19, 29)

        bubbleItem.gameObject:SetActive(false)
	end

	self.exitButton = self.memberList.transform:FindChild("ExitButton"):GetComponent(Button)
	self.exitButton.onClick:AddListener(function() self:ExitTeam() end)
	self.startButton = self.memberList.transform:FindChild("StartButton"):GetComponent(Button)
	self.startButton.onClick:AddListener(function() self:OnStartButtonClick() end)
	self.recruitButton = self.memberList.transform:FindChild("RecruitButton"):GetComponent(Button)
	self.recruitButton.onClick:AddListener(function() self:OnRecruitButtonClick() end)

	self.exitButtonText = self.memberList.transform:FindChild("ExitButton/Text"):GetComponent(Text)
    ----------------------------

 --    self.memberListTimeText2.gameObject:SetActive(false)
	-- self.recruitButton.gameObject:SetActive(false)
	-- self.miniBtn.gameObject:SetActive(false)
	-- self.transform:FindChild("ClosePanel").gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

	-- self.exitButton.gameObject.transform.localPosition = Vector3(-105, -221, 0)
	-- self.startButton.gameObject.transform.localPosition = Vector3(85, -221, 0)
	-- self.memberListTimeText.gameObject.transform.localPosition = Vector3(85, -261, 0)

    self:OnShow()
    self:ClearMainAsset()
end

function TeamDungeonWindow:OnClickClose()
	if self.model.dungeon_team ~= nil then
		local data = NoticeConfirmData.New()
		data.type = ConfirmData.Style.Normal
		if self.model.status == 1 then
			data.content = TI18N("是否<color='#00ff00'>带领队伍</color>，离开副本挑战？")
		else
			data.content = TI18N("是否<color='#00ff00'>退出队伍</color>，离开副本挑战？")
		end
		data.sureLabel = TI18N("退出")
		data.cancelLabel = TI18N("取消")
		data.sureCallback = function()
				if self.model.status == 1 then
					TeamDungeonManager.Instance:Send12133()
				else
					TeamDungeonManager.Instance:Send12137()
				end
				WindowManager.Instance:CloseWindow(self)
			end
		NoticeManager.Instance:ConfirmTips(data)
		return
	end

	-- if self.model.quickJionMark then
		TeamDungeonManager.Instance:Send12135()
	-- end

	-- WindowManager.Instance:CloseWindow(self)
	TeamDungeonManager.Instance.model:CloseTeamDungeonWindow()
end

function TeamDungeonWindow:OnClickMini()
    if self.tweenId == nil then
        self.tweenId = Tween.Instance:Scale(self.gameObject, Vector3(0.1, 0.1, 1), 0.2, function() self.miniMark = true self.gameObject:SetActive(false) self.tweenId = nil end, LeanTweenType.easeOutQuart).id
        self.moveTweenId = Tween.Instance:MoveY(self.gameObject, -0.6, 0.2, function() self.moveTweenId = nil end, LeanTweenType.easeOutQuart).id
    end
end

function TeamDungeonWindow:OnShow()
	self.model.dungeon_team = nil
    self.model.status = 0

	local selectIndex
    if self.openArgs ~= nil and #self.openArgs > 0 then
        selectIndex = self.openArgs[1]
    end
    if PlayerPrefs.GetInt("TeamDungeonWindowAuto") == 0 then -- 默认值为选中
    	self.teamToggle.isOn = true
		self:OnToggleChange(true)
	else
		self.teamToggle.isOn = false
		self:OnToggleChange(false)
	end

    self:Update()
    if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end
	self.timerId = LuaTimer.Add(0, 500, function() self:OnTimer() end)

	if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
		self:CreateTeam()
	end

	if selectIndex ~= nil then
		self:OnDungeonItemClick(selectIndex)
	end

	TeamDungeonManager.Instance.OnUpdate:Remove(self._OnUpdate)
	TeamDungeonManager.Instance.OnUpdate:Add(self._OnUpdate)
	TeamDungeonManager.Instance:Send12130()
	TeamDungeonManager.Instance:Send12150()

	if self.model.recruitFreezeIndexTime ~= nil and self.model.recruitFreezeIndexTime - BaseUtils.BASE_TIME > 0 then
		self.recruitFreezeIndex = math.floor((self.model.recruitFreezeIndexTime - BaseUtils.BASE_TIME) * 2)
	end

	if self.miniMark then
		self.miniMark = false
        self.gameObject:SetActive(true)
        self.transform.localPosition = Vector3.zero
        self.transform.localScale = Vector3.one
    end
end

function TeamDungeonWindow:OnHide()
	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end

	if self.joinButtonEffTimerId ~= nil then
        LuaTimer.Delete(self.joinButtonEffTimerId)
        self.joinButtonEffTimerId = nil
    end

	TeamDungeonManager.Instance.OnUpdate:Remove(self._OnUpdate)
end

function TeamDungeonWindow:OnUpdate(args, args2)
	if self.gameObject == nil then
		return
	end
	if args == nil then
		self:Update()
	elseif args == "UpdateMemberList" then
		-- self:UpdateMemberList()
		self:UpdateInfo()
	elseif args == "UpdateTeamList" then
		-- self:UpdateTeamList()
		self:UpdateInfo()
	elseif args == "UpdateSelectDungeon" then
		local index = 1
		for i, value in ipairs(self.model.DataTeamDungeon) do
			if value.id == self.model.dun_id then
				index = i
				break
			end
		end
		self:ChangeDungeon(index)
	elseif args == "UpdateBar" then
		if args2 ~= nil then
			self.currentIndex = args2
		end
		self:UpdateBar()
	elseif args == "UpdateTeamToggle" then
		self.teamToggle.gameObject:SetActive(not self.model.quickJionMark and self:CanShowToggle())
		self:JoinButtonEffect(not self.model.quickJionMark)
		if PlayerPrefs.GetInt("TeamDungeonWindowAuto") == 0 then -- 默认值为选中
	    	self.teamToggle.isOn = true
			self:OnToggleChange(true)
		else
			self.teamToggle.isOn = false
			self:OnToggleChange(false)
		end
	end
end

function TeamDungeonWindow:Update()
	self:UpdateBar()
	self:UpdateInfo()
end

function TeamDungeonWindow:UpdateBar()
	local noTimesMark = false
	local topIndex = 0 -- 目前能挑战的最高副本
	local topIndex_HaveTimes = 0 -- 目前能挑战且还有次数的最高副本
	local lev = RoleManager.Instance.RoleData.lev
    local lowerLev = self.model:GetTeamLev()

    local times = DataDungeon.data_team_dungeon_times[lev].limit
    local lessTimes = times - self.model.passTimes
	local color = "#009900"
	if times - self.model.passTimes <= 0 then
		color = "#ff0000"
		lessTimes = 0
	end
	self.dungeonTitleText.text = string.format(TI18N("副本总次数<color='%s'>（%s/%s）</color>"), color, lessTimes, times)

    for i=1, #self.model.DataTeamDungeon do
        local dungeonItem = self.dungeonItemList[i]
        local data = self.model.DataTeamDungeon[i]
        if dungeonItem == nil then
            dungeonItem = GameObject.Instantiate(self.dungeonCloneItem)
            dungeonItem:SetActive(true)
            dungeonItem.transform:SetParent(self.dungeonContainer.transform)
            dungeonItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            dungeonItem:GetComponent(Button).onClick:AddListener(function() self:OnDungeonItemClick(i) end)
            self.dungeonItemList[i] = dungeonItem

            local msgItemExt = MsgItemExt.New(dungeonItem.transform:FindChild("Reward/RewardText"):GetComponent(Text), 240, 16, 25)
            self.dungeonItemMsgItemExtList[i] = msgItemExt

            dungeonItem.transform:FindChild("Reward").gameObject:SetActive(false)
        end

        dungeonItem:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teamdungeon_textures, data.name_res)
        dungeonItem.transform:FindChild("Select/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teamdungeon_textures, data.name_res)

        local time = self.model.pass_list[data.id]
		if time == nil then
			time = 0
		end
		time = 3 - time
		if time < 0 then
			time = 0
		end
-- print(string.format("%s %s---", self.model.pass_list[data.id], time))
    	if data.lev_min > lev or data.lev_max <= lev then
    		-- dungeonItem:GetComponent(Image).color = Color.grey
    		-- dungeonItem:GetComponent(Image).color = Color(0.65, 0.65, 0.65)
    		-- dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = TI18N("剩余次数:  <color='%s'>-/-</color>")

    		self.dungeonItemMsgItemExtList[i]:SetData(TI18N("低级副本无法获得奖励"))

			-- dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = ""
    		if data.lev_max <= lev then
	    		dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = TI18N("<color='#da643f'>副本等级过低</color>")
	    	elseif data.lev_min > lev then
	    		dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = TI18N("<color='#da643f'>副本等级过高</color>")
	    	end
    	else
    		dungeonItem:GetComponent(Image).color = Color.white

    		if lessTimes == 0 then
    			dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = TI18N("次数已满")
    		else
	    		dungeonItem.transform:FindChild("TimesText"):GetComponent(Text).text = string.format(TI18N("剩余次数:  <color='%s'>%s/3</color>"), "#00ff00", time)
	    	end

    		local rewardString = TI18N("预计可得: ")
	        if self.model.rewards_list[data.id] ~= nil then
			    for _,value in ipairs(self.model.rewards_list[data.id].gains) do
			        rewardString = string.format("%s{assets_1,%s,%s}", rewardString, value.gid, value.value)
			    end
			end

			if rewardString == TI18N("预计可得: ") then
				rewardString = TI18N("低级副本无法获得奖励")
			elseif time == 0 or lessTimes == 0 then
				rewardString = TI18N("挑战次数不足，无法获得奖励")
			end
	    	self.dungeonItemMsgItemExtList[i]:SetData(rewardString)
    	end
-- print(string.format("lev    %s %s %s %s", lowerLev, data.lev_min, lowerLev, data.lev_max))
    	if data.lev_min <= lowerLev and data.lev_max > lowerLev then
    		if self.currentIndex == 0 and topIndex < i then
	   			topIndex = i
			end
			if time > 0 then
				if self.currentIndex == 0 and topIndex_HaveTimes < i then
		   			topIndex_HaveTimes = i
				end
			end
			-- print(string.format("%s %s+++", topIndex, topIndex_HaveTimes))
		end

		if self.model.status == 1 and data.id == self.model.dun_id then
			if time <= 0 then
				noTimesMark = true
			end
		end
    end
-- print(topIndex_HaveTimes)
-- print(topIndex)
-- print("-----")
-- print(debug.traceback())
    if topIndex_HaveTimes ~= 0 then
    	if noTimesMark and self.model.dun_id ~= topIndex_HaveTimes then
    		NoticeManager.Instance:FloatTipsByString("副本次数为0，自动切换挑战目标")
    	end

    	if self.model.status > 1 then
    		self:ChangeDungeon(topIndex_HaveTimes)
    	elseif lowerLev ~= lev then
    		TeamDungeonManager.Instance:Send12149(self.model.DataTeamDungeon[topIndex_HaveTimes].id)

    		self:ChangeDungeon(topIndex_HaveTimes)
			self:RefreshTeamList(true)

		    if self.teamToggle.isOn then
		    	self:OnToggleChange(true)
		    end
    	else
			self:OnDungeonItemClick(topIndex_HaveTimes)
		end
    elseif topIndex ~= 0 then
    	if noTimesMark and self.model.dun_id ~= topIndex_HaveTimes then
    		NoticeManager.Instance:FloatTipsByString("副本次数为0，自动切换挑战目标")
    	end

    	if self.model.status > 1 then
    		self:ChangeDungeon(topIndex)
    	elseif lowerLev ~= lev then
    		TeamDungeonManager.Instance:Send12149(self.model.DataTeamDungeon[topIndex].id)

    		self:ChangeDungeon(topIndex)
			self:RefreshTeamList(true)

		    if self.teamToggle.isOn then
		    	self:OnToggleChange(true)
		    end
    	else
			self:OnDungeonItemClick(topIndex)
		end
	end

	self.teamToggle.gameObject:SetActive(not self.model.quickJionMark and self:CanShowToggle())
end

function TeamDungeonWindow:UpdateInfo()
	if self.currentIndex ~= 0 then
		self.teamPanelTitleText.text = self.model.DataTeamDungeon[self.currentIndex].name
	end

	if self.model.dungeon_team == nil then
		self.teamList:SetActive(true)
    	self.memberList:SetActive(false)
		self:UpdateTeamList()
	else
		self.teamList:SetActive(false)
    	self.memberList:SetActive(true)
		self:UpdateMemberList()
	end
end

function TeamDungeonWindow:UpdateTeamList()
 --    for i=1, #self.model.dungeon_enlistment do
 --        local teamItem = self.teamItemList[i]
 --        local data = self.model.dungeon_enlistment[i]
 --        if teamItem == nil then
 --            teamItem = GameObject.Instantiate(self.teamCloneItem)
 --            teamItem.transform:SetParent(self.teamContainer.transform)
 --            teamItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
 --            self.teamItemList[i] = teamItem

 --   			local headSlot = HeadSlot.New()
	-- 		headSlot:SetRectParent(teamItem.transform:FindChild("LeaderHead"))
	-- 		self.teamHeadList[i] = headSlot

	-- 		teamItem.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OnJionButtonClick(i) end)
 --        end

 --        teamItem:SetActive(true)
 --        data.id = data.rid
 --        self.teamHeadList[i]:SetAll(data, {isSmall = true})
 --        teamItem.transform:FindChild("LeaderName"):GetComponent(Text).text = data.name

 --        for memberIndex = 1, 4 do
 --        	if memberIndex < data.member_num then
 --        		teamItem.transform:FindChild(string.format("Member%s/Image", memberIndex)).gameObject:SetActive(true)
 --        	else
 --        		teamItem.transform:FindChild(string.format("Member%s/Image", memberIndex)).gameObject:SetActive(false)
 --        	end
 --        end
 --    end

 --    if #self.model.dungeon_enlistment < #self.teamItemList then
	--     for i = #self.model.dungeon_enlistment + 1, #self.teamItemList do
	--     	local teamItem = self.teamItemList[i]
	--     	teamItem:SetActive(false)
	--     end
	-- end

	self.team_list_data.data_list = self.model.dungeon_enlistment
	BaseUtils.refresh_circular_list(self.team_list_data)

	self.autoRefreshTime = BaseUtils.BASE_TIME + 5

	if #self.model.dungeon_enlistment > 0 then
		self.noTeamTips:SetActive(false)
	else
		self.noTeamTips:SetActive(true)
	end
end

function TeamDungeonWindow:UpdateMemberList()
	for i=1, #self.memberItemList do
		local memberItem = self.memberItemList[i].transform
		local data = self.model.dungeon_team.dungeon_mate[i]

		if data ~= nil then
			data.id = data.rid
			self.memberHeadList[i]:SetAll(data, {isSmall = true})
			memberItem:Find("Name").gameObject:SetActive(true)
			memberItem:Find("Name"):GetComponent(Text).text = data.name
			memberItem:Find("ClassesIcon").gameObject:SetActive(true)
			memberItem:Find("ClassesIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_"..data.classes)

			memberItem:Find("Waitting").gameObject:SetActive(false)
			memberItem:Find("AddImage").gameObject:SetActive(false)
		else
			self.memberHeadList[i]:Default()
			memberItem:Find("Name").gameObject:SetActive(false)
			memberItem:Find("ClassesIcon").gameObject:SetActive(false)

			memberItem:Find("Waitting").gameObject:SetActive(true)
			memberItem:Find("AddImage").gameObject:SetActive(true)
		end
	end

	if #self.model.dungeon_team.dungeon_mate >= 5 then
		self.memberListStateText.text = TI18N("即将开始挑战")
		self.memberListTimeText.text = TI18N("30s后自动开始")

		self.autoStartTime = 60
	else
		self.memberListStateText.text = TI18N("正在等待队员")
		self.memberListTimeText.text = ""

		self.memberListStateTextIndex = 0
	end

	if self.model.status == 1 then
		self.memberListTimeText2.gameObject:SetActive(true)
		self.recruitButton.gameObject:SetActive(true)
		self.exitButton.gameObject.transform.localPosition = Vector3(-10, -221, 0)
		self.startButton.gameObject.transform.localPosition = Vector3(145, -221, 0)
		self.memberListTimeText.gameObject.transform.localPosition = Vector3(145, -261, 0)

		if TeamManager.Instance:MemberCount() > 1 then
			self.exitButtonText.text = TI18N("退出副本")
		else
			self.exitButtonText.text = TI18N("返回大厅")
		end
	else
		self.memberListTimeText2.gameObject:SetActive(false)
		self.recruitButton.gameObject:SetActive(false)
		self.exitButton.gameObject.transform.localPosition = Vector3(-105, -221, 0)
		self.startButton.gameObject.transform.localPosition = Vector3(85, -221, 0)
		self.memberListTimeText.gameObject.transform.localPosition = Vector3(85, -261, 0)

		self.exitButtonText.text = TI18N("返回大厅")
	end
end

function TeamDungeonWindow:UpdateReWard()
	if self.currentIndex ~= 0 then
		self.dungeonItemPanelTitleText.text = string.format(TI18N("%s几率掉落"), self.model.DataTeamDungeon[self.currentIndex].name)
		local reward = self.model.DataTeamDungeon[self.currentIndex].base_gain
		for i=1, #reward do
			local itembase = BackpackManager.Instance:GetItemBase(reward[i].item_id)
	        local itemData = ItemData.New()
	        itemData:SetBase(itembase)
	        itemData.quantity = reward[i].item_val
			self.dungeonItemSlotList[i]:SetAll(itemData, { nobutton = true })
		end
	end
end

function TeamDungeonWindow:OnDungeonItemClick(index)
	local data = self.model.DataTeamDungeon[index]
	local lev = RoleManager.Instance.RoleData.lev
	local lowerLev, name = self.model:GetTeamLev()

	if self.model.status > 1 then
		NoticeManager.Instance:FloatTipsByString(TI18N("队员无法选择副本"))
		return
	end
	if data.lev_min > lowerLev then
		if lev == lowerLev then
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s副本将在<color='#ffff00'>%s级</color>开放"), data.name, data.lev_min))
		else
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#00ff00'>%s</color>等级不足<color='#ffff00'>%s级</color>，不能挑战<color='#00ff00'>%s</color>"), name, data.lev_min, data.name))
		end
		return
	end
	if lowerLev >= data.lev_max then
		NoticeManager.Instance:FloatTipsByString(TI18N("低级副本无法获得奖励，请选择高级副本"))
		return
	end
	if self.model.status == 1 then
		TeamDungeonManager.Instance:Send12149(self.model.DataTeamDungeon[index].id)
		if self.currentIndex == index then
			return
		end
	end
	if self.model.quickJionMark and self.model.DataTeamDungeon[index].id ~= self.model.dun_id then
		local data = NoticeConfirmData.New()
		data.type = ConfirmData.Style.Normal
		data.content = TI18N("是否<color='#ffff00'>取消匹配</color>并切换副本目标？")
		data.sureLabel = TI18N("退出")
		data.cancelLabel = TI18N("取消")
		data.sureCallback = function()
				self:ChangeDungeon(index)
				self:RefreshTeamList(true)
				TeamDungeonManager.Instance:Send12135()

			    if self.teamToggle.isOn then
			    	self:OnToggleChange(true)
			    end
			end
		NoticeManager.Instance:ConfirmTips(data)
	else
		self:ChangeDungeon(index)
		self:RefreshTeamList(true)

	    if self.teamToggle.isOn then
	    	self:OnToggleChange(true)
	    end
	end
end

function TeamDungeonWindow:ChangeDungeon(index)
	if self.selectDungeonItem ~= nil then
        self.selectDungeonItem.transform:FindChild("Select").gameObject:SetActive(false)
        self.selectDungeonItem.transform:FindChild("Reward").gameObject:SetActive(false)
    end
    self.currentIndex = index
    self.model.dun_id = self.model.DataTeamDungeon[self.currentIndex].id
    self.selectDungeonItem = self.dungeonItemList[index]
    self.selectDungeonItem.transform:FindChild("Select").gameObject:SetActive(true)
    self.selectDungeonItem.transform:FindChild("Reward").gameObject:SetActive(true)

    self:UpdateInfo()
    self:UpdateReWard()

    if index == 4 then
		self.dungeonContainer.transform.localPosition = Vector3(-20, 200, 0)
	end

	-- local height = (self.dungeonContainerMaskHeight / 2) + (index - 1) * self.dungeonCloneItemHeight
	-- self.dungeonContainer.transform.localPosition = Vector3(-20, height, 0)

	self:JoinButtonEffect(true)
	self.teamToggle.gameObject:SetActive(not self.model.quickJionMark and self:CanShowToggle())
end

function TeamDungeonWindow:RefreshTeamList(updateToggle)
	if updateToggle and self.teamToggle.isOn then
    	self:OnToggleChange(true)
    end
    if self.currentIndex ~= 0 then
		TeamDungeonManager.Instance:Send12131(self.model.DataTeamDungeon[self.currentIndex].id)
	end
end

function TeamDungeonWindow:CreateTeam()
	if self.currentIndex ~= 0 then
		TeamDungeonManager.Instance:Send12132(self.model.DataTeamDungeon[self.currentIndex].id)
	end
end

function TeamDungeonWindow:QuickJion()
	if self.currentIndex ~= 0 then
		if self.model.quickJionMark then
			TeamDungeonManager.Instance:Send12135()
			if PlayerPrefs.GetInt("TeamDungeonWindowAuto") == 0 then -- 默认值为选中
				self:OnToggleChange(true)
			end
		else
			TeamDungeonManager.Instance:Send12134(self.model.DataTeamDungeon[self.currentIndex].id)
		end
	end
end

function TeamDungeonWindow:ExitTeam()
	if self.model.status == 1 and TeamManager.Instance:MemberCount() > 1 then
		self:OnClickClose()
	else
		local data = NoticeConfirmData.New()
		data.type = ConfirmData.Style.Normal
		if self.model.status == 1 then
			data.content = TI18N("是否<color='#00ff00'>解散队伍</color>回到副本大厅？")
		else
			data.content = TI18N("是否<color='#00ff00'>退出队伍</color>回到副本大厅？")
		end
		data.sureLabel = TI18N("退出")
		data.cancelLabel = TI18N("取消")
		data.sureCallback = function()
				TeamDungeonManager.Instance:Send12137()
			end
		NoticeManager.Instance:ConfirmTips(data)
	end
end

function TeamDungeonWindow:OnStartButtonClick()
	TeamDungeonManager.Instance:Send12139()
end

function TeamDungeonWindow:OnRecruitButtonClick()
	if self.recruitFreezeIndex == nil then
		if self.currentIndex ~= 0 then
			local teamDungeonData = self.model.DataTeamDungeon[self.currentIndex]

			local matchData = nil
			for Key, value in pairs(DataTeam.data_match) do
				if value.type == 28 and value.open_lev == teamDungeonData.lev_min then
					matchData = value
				end
			end

			-- BaseUtils.dump(matchData, "matchData")
			if matchData ~= nil then
				-- ChatManager.Instance:Send10419(matchData.id, matchData.lev_recruit[1].flag)
				-- TeamManager.Instance:Send11711(matchData.id, matchData.lev_recruit[1].flag)
				TeamManager.Instance.TypeOptions = {}
		    	TeamManager.Instance.TypeOptions[matchData.tab_id] = matchData.id
		    	TeamManager.Instance.LevelOption = matchData.lev_recruit[1].flag
	    		TeamManager.Instance:AutoFind()

				self.recruitFreezeIndex = 120
				self.model.recruitFreezeIndexTime = BaseUtils.BASE_TIME + 60
			end
		end
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("冷却中"))
	end
end

function TeamDungeonWindow:OnJionButtonClick(index)
	if self.currentIndex ~= 0 then
		local teamData = self.model.dungeon_enlistment[index]
		TeamDungeonManager.Instance:Send12136(teamData.team_id, teamData.team_platform, teamData.team_zone_id, self.model.DataTeamDungeon[self.currentIndex].id)
	end
end

function TeamDungeonWindow:OnMemberItemClick(index)
	local member = self.model.dungeon_team.dungeon_mate[index]
	if member ~= nil then
		local btns
		if index == 1 or self.model.status > 1 then
			btns = {{label = TI18N("查看信息"), callback = function() TipsManager.Instance:ShowPlayer({rid = member.rid, platform = member.platform, zone_id = member.zone_id, lev = member.lev}) end}
                    }
		else
			btns = {{label = TI18N("查看信息"), callback = function() TipsManager.Instance:ShowPlayer({rid = member.rid, platform = member.platform, zone_id = member.zone_id, lev = member.lev}) end}
                    , {label = TI18N("踢出队伍"), callback = function() TeamDungeonManager.Instance:Send12138(member.rid, member.platform, member.zone_id) end}}
		end

        TipsManager.Instance:ShowButton({gameObject = self.memberItemList[index], data = btns})
	else
		local btns = {{label = TI18N("邀请好友"), callback = function() self:InvitationFriend() end}
                    , {label = TI18N("公会招募"), callback = function() self:GuildRecruit() end}}
        TipsManager.Instance:ShowButton({gameObject = self.memberItemList[index], data = btns})
	end
end

function TeamDungeonWindow:InvitationFriend()
	-- local callBack = function(_, friendData)
	-- 	if friendData.lev >= self.model.DataTeamDungeon[self.currentIndex].lev_min then
	-- 		-- BaseUtils.dump(friendData, "InvitationFriend")
	-- 		TeamDungeonManager.Instance:Send12143(friendData.id, friendData.platform, friendData.zone_id)
	-- 		-- NoticeManager.Instance:FloatTipsByString(TI18N("邀请已发出"))
	-- 		FriendManager.Instance.model:CloseFriendSelect()
	-- 	else
	-- 		NoticeManager.Instance:FloatTipsByString(TI18N("好友等级过低，无法挑战XXXXX"))
	-- 	end
	-- end
	local callBack = function(selectDataList)
		for _,friendData in pairs(selectDataList) do
			TeamDungeonManager.Instance:Send12143(friendData.id, friendData.platform, friendData.zone_id)
		end
		FriendManager.Instance.model:CloseFriendSelect()
	end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 3 })
end

function TeamDungeonWindow:GuildRecruit()
	SosManager.Instance:Send16000(24)
end

function TeamDungeonWindow:OnToggleChange(on)
    if on then
    	self.autoJoinTime = 30
    	self.teamToggleText.text = string.format(TI18N("<color='#ffff00'>%ss</color>后自动匹配队伍"), math.floor(self.autoJoinTime/2))
    	PlayerPrefs.SetInt("TeamDungeonWindowAuto", 0)
    else
    	self.autoJoinTime = nil
    	self.teamToggleText.text = TI18N("<color='#ffff00'>15s</color>后自动匹配队伍")
    	PlayerPrefs.SetInt("TeamDungeonWindowAuto", 1)
    end
end

function TeamDungeonWindow:JoinButtonEffect(show)
	if self.joinButtonEffTimerId ~= nil then
        LuaTimer.Delete(self.joinButtonEffTimerId)
        self.joinButtonEffTimerId = nil
    end

    if self.currentIndex == 0 then
    	return
    end
	local lev = RoleManager.Instance.RoleData.lev
	local times = DataDungeon.data_team_dungeon_times[lev].limit
	local time = self.model.pass_list[self.model.DataTeamDungeon[self.currentIndex].id]
	if time == nil then
		time = 0
	end
    local mark = (times - self.model.passTimes > 0) and (3 - time > 0)
    if show and mark then
		self.joinButtonEffTimerId = LuaTimer.Add(1000, 3000, function()
		    self.quickJionButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
		    Tween.Instance:Scale(self.quickJionButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
		end)
	else
		self.quickJionButton.gameObject.transform.localScale = Vector3.one
	end
end

function TeamDungeonWindow:ShowMsg(rid, platform, zone_id, text, BubbleID)
    if self.loading then
        BaseUtils.enqueue(self.queue, function() self:ShowMsg(rid, platform, zone_id, text, BubbleID) end)
        return
    end

    if self.bubbleList == nil then
        return
    end
    if self.model.dungeon_team == nil or self.model.dungeon_team.dungeon_mate == nil then
    	return
    end
    for i,member in ipairs(self.model.dungeon_team.dungeon_mate) do
    	BaseUtils.dump(member)
        if member.rid == rid and member.platform == platform and member.zone_id == zone_id then
            self.bubbleList[i].Ext:SetData(text)
            self.bubbleList[i].bubble.gameObject:SetActive(true)
            local size = self.bubbleList[i].bubbleText.transform.sizeDelta
            self.bubbleList[i].bubble.sizeDelta = Vector2(size.x+33, size.y+16)
            local ID = Time.time
            self.bubbleList[i].bubbleID = ID
            LuaTimer.Add(3500, function()
                if self.bubbleList ~= nil and BaseUtils.isnull(self.bubbleList[i].bubble) == false and self.bubbleList[i].bubbleID == ID then
                    self.bubbleList[i].bubble.gameObject:SetActive(false)
                end
            end)
            break
        end
    end
end

function TeamDungeonWindow:CanShowToggle()
	if self.currentIndex == 0 then
		return false
	end
	local lev = RoleManager.Instance.RoleData.lev
    local times = DataDungeon.data_team_dungeon_times[lev].limit
    local lessTimes = times - self.model.passTimes
	if lessTimes < 0 then
		lessTimes = 0
	end

	local data = self.model.DataTeamDungeon[self.currentIndex]
	local time = self.model.pass_list[data.id]
	if time == nil then
		time = 0
	end
	time = 3 - time
	if time < 0 then
		time = 0
	end

	return lessTimes ~= 0 and time ~= 0
end

function TeamDungeonWindow:OnTimer()
	if self.model.dungeon_team == nil then
		-- print(string.format("self.model.quickJionMark %s", self.model.quickJionMark))
		if self.autoJoinTime ~= nil then
			if self.autoJoinTime >= 0 then
				self.teamToggleText.text = string.format(TI18N("<color='#ffff00'>%ss</color>后自动匹配队伍"), math.floor(self.autoJoinTime/2))
				self.autoJoinTime = self.autoJoinTime - 1
			else
				if self.currentIndex ~= 0 and self:CanShowToggle() then
					TeamDungeonManager.Instance:Send12134(self.model.DataTeamDungeon[self.currentIndex].id)
				end
				self.autoJoinTime = nil
			end
		end

		if self.autoRefreshTime ~= nil then
			if self.autoRefreshTime - BaseUtils.BASE_TIME <= 0 then
				self.autoRefreshTime = nil
				self:RefreshTeamList()
			end
		end

		if self.model.quickJionMark then
			if self.quickJionTextIndex == 0 then
				self.quickJionButtonText.text = TI18N("匹配中")
			elseif self.quickJionTextIndex == 1 then
				self.quickJionButtonText.text = TI18N("匹配中.")
			elseif self.quickJionTextIndex == 2 then
				self.quickJionButtonText.text = TI18N("匹配中..")
			elseif self.quickJionTextIndex == 3 then
				self.quickJionButtonText.text = TI18N("匹配中...")
			end
			self.quickJionTextIndex = self.quickJionTextIndex + 1

			if self.quickJionTextIndex > 3 then
				self.quickJionTextIndex = 0
			end
		else
			self.quickJionButtonText.text = TI18N("快速加入")
		end
	else
		if #self.model.dungeon_team.dungeon_mate >= 5 then
			if self.autoStartTime ~= nil then
				self.memberListTimeText.text = string.format(TI18N("%ss后自动开始"), math.floor(self.autoStartTime/2))
				self.autoStartTime = self.autoStartTime - 1
				if self.autoStartTime <= 0 then
					self.autoStartTime = nil
					if self.model.status == 1 then
						TeamDungeonManager.Instance:Send12139()
					end
				end
			end
		else
			if self.memberListStateTextIndex == 0 then
				self.memberListStateText.text = TI18N("正在等待队员")
			elseif self.memberListStateTextIndex == 1 then
				self.memberListStateText.text = TI18N("正在等待队员.")
			elseif self.memberListStateTextIndex == 2 then
				self.memberListStateText.text = TI18N("正在等待队员..")
			elseif self.memberListStateTextIndex == 3 then
				self.memberListStateText.text = TI18N("正在等待队员...")
			end
			self.memberListStateTextIndex = self.memberListStateTextIndex + 1

			if self.memberListStateTextIndex > 3 then
				self.memberListStateTextIndex = 0
			end

			self.memberListTimeText.text = ""
		end
	end

	if self.recruitFreezeIndex ~= nil then
		if self.recruitFreezeIndex >= 0 then
			self.memberListTimeText2.text = string.format(TI18N("<color='#ffff00'>%ss</color>后可用"), math.floor(self.recruitFreezeIndex/2))
			self.recruitButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
			self.recruitFreezeIndex = self.recruitFreezeIndex - 1
		else
			self.memberListTimeText2.text = ""
			self.recruitButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
			self.recruitFreezeIndex = nil
			self.recruitFreezeIndexTime = nil
		end
	end
end

function TeamDungeonWindow:OnInitCompleted()
    while self.queue.len ~= 0 do
        local func = BaseUtils.dequeue(self.queue)
        if func == nil then
            break
        else
            func()
        end
    end
    BaseUtils.clearqueue(self.queue)
end
