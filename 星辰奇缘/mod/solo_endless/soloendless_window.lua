--作者:hzf
--12/08/self.maxPage16 self.maxPage:49:39
--功能:单人无尽

SoloEndlessWindow = SoloEndlessWindow or BaseClass(BaseWindow)
function SoloEndlessWindow:__init(model)
	self.model = model
	self.Mgr = SoloEndlessManager.Instance
	self.resList = {
		{file = AssetConfig.unlimitedsinglechallengepanel, type = AssetType.Main}
		,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.currindex = 0
	self.tweening = false
	self.maxPage = 1
 	self.rid = RoleManager.Instance.RoleData.id
    self.platform = RoleManager.Instance.RoleData.platform
    self.zone_id = RoleManager.Instance.RoleData.zone_id
    self.name = RoleManager.Instance.RoleData.name
end

function SoloEndlessWindow:__delete()
	if self.timestimer ~= nil then
		LuaTimer.Delete(self.timestimer)
		self.timestimer = nil
	end
	if self.txttimer ~= nil then
		LuaTimer.Delete(self.txttimer)
		self.txttimer = nil
	end
	if self.friendPanel ~= nil then
        self.friendPanel:DeleteMe()
    end
    self.friendPanel = nil
	if self.SlotList ~= nil then
		for k,v in pairs(self.SlotList) do
			v:DeleteMe()
		end
		self.SlotList = nil
	end
	if self.ItemList ~= nil then
		for k,v in pairs(self.ItemList) do
			v = {}
		end
	end
	self.ItemList = nil
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function SoloEndlessWindow:OnHide()

end

function SoloEndlessWindow:OnOpen()
	self:UpdateInfo()
end

function SoloEndlessWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimitedsinglechallengepanel))
	self.gameObject.name = "SoloEndlessWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseMainWindow()
	end)
	self.Icon = self.transform:Find("Main/Icon")
	self.RankText = self.transform:Find("Main/RankText/Text"):GetComponent(Text)

	self.SlotList = {}
	for i=1,4 do
		local parent = self.transform:Find("Main/Slot"..tostring(i))
		local ItemSlot = ItemSlot.New()
		UIUtils.AddUIChild(parent.gameObject, ItemSlot.gameObject)
		ItemSlot.transform.localPosition = Vector3(0, 0, 0)
		ItemSlot.transform.localScale = Vector3(1, 1, 1)
		self.SlotList[i] = ItemSlot
	end

	self.NextText = self.transform:Find("Main/NextText"):GetComponent(Text)
	self.RankButton = self.transform:Find("Main/RankButton"):GetComponent(Button)
	self.RankButton.onClick:AddListener(function() self:OnRank() end)

	self.MidList = self.transform:Find("Main/Con/MidList")
	self.List = self.transform:Find("Main/Con/MidList/List")

	self.ItemList = {}
	self.maxPage = math.ceil(#DataSoloendless.data_list/5)
	for i=1, 20 do
		local Item = self.List:GetChild(i-1)
		Item.gameObject:SetActive(i <= self.maxPage)
		tab = {}
		tab.CanvasGroup = Item:GetComponent(CanvasGroup)
		tab.LButton = Item:Find("LButton"):GetComponent(Button)
		tab.LButton.onClick:AddListener(function() self:TurnToChapter(i-1) end)
		tab.RButton = Item:Find("RButton"):GetComponent(Button)
		tab.RButton.onClick:AddListener(function() self:TurnToChapter(i+1) end)
		tab.Content = Item:Find("Content")
		tab.TitleText = Item:Find("Content/Text"):GetComponent(Text)
		tab.Slider = Item:Find("Content/SlideArea/Slider"):GetComponent(Slider)
		tab.Slider.interactable = false
		tab.num = {}
		tab.num[1] = Item:Find("Content/SlideArea/num1"):GetComponent(Text)
		tab.num[2] = Item:Find("Content/SlideArea/num2"):GetComponent(Text)
		tab.num[3] = Item:Find("Content/SlideArea/num3"):GetComponent(Text)
		tab.num[4] = Item:Find("Content/SlideArea/num4"):GetComponent(Text)
		tab.num[5] = Item:Find("Content/SlideArea/num5"):GetComponent(Text)
		Item:GetComponent(Button).onClick:AddListener(function()
			self:TurnToChapter(i)
		end)
		self.ItemList[i] = tab
	end

	self.recorderDesc = self.transform:Find("Main/Con/Bottom/Desc"):GetComponent(Text)
	self.FirstButton = self.transform:Find("Main/Con/Bottom/FirstButton"):GetComponent(Button)
	self.FirstButton.onClick:AddListener(function() self:OnFirstRec() end)
	self.FirstButtonText = self.transform:Find("Main/Con/Bottom/FirstButton/Text"):GetComponent(Text)
	self.CurrButton = self.transform:Find("Main/Con/Bottom/CurrButton"):GetComponent(Button)
	self.CurrButton.onClick:AddListener(function() self:OnCurrRec() end)
	self.CurrButtonText = self.transform:Find("Main/Con/Bottom/CurrButton/Text"):GetComponent(Text)

	self.HelpText = self.transform:Find("Main/Con/Bottom/HelpText"):GetComponent(Text)
	self.HelpButton = self.transform:Find("Main/Con/Bottom/HelpButton"):GetComponent(Button)
	self.HelpButton.onClick:AddListener(function() self.reqhelp.gameObject:SetActive(true) end)
	self.TimesText = self.transform:Find("Main/Con/Bottom/TimesText"):GetComponent(Text)
	self.StartButtonText = self.transform:Find("Main/Con/Bottom/StartButton/Text"):GetComponent(Text)
	self.StartButton = self.transform:Find("Main/Con/Bottom/StartButton"):GetComponent(Button)
	self.StartButton.onClick:AddListener(function() self:OnStart() end)
	self.InfoButton = self.transform:Find("Main/Con/Bottom/Button"):GetComponent(Button)
	self.InfoButton.onClick:AddListener(function() self:OnInfo() end)

	self.reqhelp = self.transform:Find("Main/reqhelp")
	self.reqhelp:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self.reqhelp.gameObject:SetActive(false)
	end)
	self.reqhelp:Find("Guildhelp"):GetComponent(Button).onClick:AddListener(function()
		self:OnHelp(MsgEumn.ChatChannel.Guild)
	end)
	self.reqhelp:Find("Friendhelp"):GetComponent(Button).onClick:AddListener(function()
		self:OnHelp(MsgEumn.ChatChannel.Private)
	end)

	self.TipsClose = self.transform:Find("TipsClose").gameObject
	self.Tips = self.transform:Find("Tips")
	self.TipsText = self.transform:Find("Tips/Text"):GetComponent(Text)
	-- self.TextEXT = MsgItemExt.New(self.TipsText, 230, 17, self.maxPage)
	self.transform:Find("TipsClose"):GetComponent(Button).onClick:AddListener(function()
		if self.txttimer ~= nil then
			LuaTimer.Delete(self.txttimer)
			self.txttimer = nil
		end
		self.TipsClose:SetActive(false)
		self.Tips.gameObject:SetActive(false)
	end)
	self:UpdateInfo()
	self:IninChapterList()
	self:TurnToChapter(1)
end

function SoloEndlessWindow:IninChapterList()
	for i=1,self.maxPage do
		self.ItemList[i].TitleText.text = string.format(TI18N("第%s章 %s <color='#ffff00'>(%s-%s)</color>"), BaseUtils.NumToChn(i), DataSoloendless.data_list[i*5-4].chapter_name, tostring(i*5-4), tostring(i*5))
		self.ItemList[i].num[1].text = tostring(i*5-4)
		for ii = 0, 4 do
			if DataSoloendless.data_list[i*5- ii] ~= nil then
				self.ItemList[i].num[5-ii].text = tostring(i*5-ii)
			else
				self.ItemList[i].num[5-ii].text = ""
			end
		end
	end
end

function SoloEndlessWindow:TurnToChapter(index)
	if index == self.currindex or self.tweening then
		return
	end
	local directly = math.abs(index - self.currindex) > 1 or self.currindex == 0
	local Left = index < self.currindex
	if index <= self.maxPage and index > 0 then
		if directly then
			if self.ItemList[self.currindex] ~= nil then
				self.ItemList[self.currindex].LButton.gameObject:SetActive(false)
				self.ItemList[self.currindex].RButton.gameObject:SetActive(false)
			end
			self.ItemList[index].LButton.gameObject:SetActive(index ~= 1)
			self.ItemList[index].RButton.gameObject:SetActive(index ~= self.maxPage)
			local target = -41-(index-2)*268 - 359
			print(self.List.localPosition)
			print(self.List.anchoredPosition)
			self.List.localPosition = Vector3(target, 0, 0)
			local Item = self.ItemList[index]
			Item.CanvasGroup.alpha = 1
			Item.Content.localScale = Vector3.one
			if index-1 > 0 then
				local Item = self.ItemList[index-1]
				Item.CanvasGroup.alpha = 0.5
				Item.Content.localScale = Vector3.one*0.6
			end
			if index+1 <= self.maxPage then
				local Item = self.ItemList[index+1]
				Item.CanvasGroup.alpha = 0.5
				Item.Content.localScale = Vector3.one*0.6
			end
		else
			self.tweening = true
			if self.ItemList[self.currindex] ~= nil then
				self.ItemList[self.currindex].LButton.gameObject:SetActive(false)
				self.ItemList[self.currindex].RButton.gameObject:SetActive(false)
			end
			local target = -41-(index-2)*268 - 359
			Tween.Instance:MoveLocalX(self.List.gameObject, target, 0.3, function() end, LeanTweenType.linear)
			local change = function(val)
				if self.ItemList == nil or self.ItemList[index] == nil then
					return
				end
				if Left then
					self.ItemList[index].CanvasGroup.alpha = 0.5+val*0.5
					self.ItemList[index].Content.localScale = Vector3.one*(0.6+val*0.4)
				else
					self.ItemList[index].CanvasGroup.alpha = 0.5+val*0.5
					self.ItemList[index].Content.localScale = Vector3.one*(0.6+val*0.4)
				end
				if index-1 > 0 then
					if Left then
						self.ItemList[index-1].CanvasGroup.alpha = 1-val*0.5
						self.ItemList[index-1].Content.localScale = Vector3.one*(1-val*0.4)
					else
						self.ItemList[index-1].CanvasGroup.alpha = 1-val*0.5
						self.ItemList[index-1].Content.localScale = Vector3.one*(1-val*0.4)
					end
				end
				if index-2 > 0 then
					if Left then
						-- self.ItemList[index-2].CanvasGroup.alpha = 0.5-val*0.5
						-- self.ItemList[index-2].Content.localScale = Vector3.one*(0.6-val*0.6)
					else
						self.ItemList[index-2].CanvasGroup.alpha = 0.5-val*0.5
						self.ItemList[index-2].Content.localScale = Vector3.one*(0.6-val*0.6)
					end
				end
				if index+1 <= self.maxPage then
					if Left then
						self.ItemList[index+1].CanvasGroup.alpha = 1-val*0.5
						self.ItemList[index+1].Content.localScale = Vector3.one*(1-val*0.4)
					else
						self.ItemList[index+1].CanvasGroup.alpha = val*0.5
						self.ItemList[index+1].Content.localScale = Vector3.one*(val*0.6)
					end
				end
				if index+2 <= self.maxPage then
					if Left then
						-- self.ItemList[index+2].CanvasGroup.alpha = val*0.5
						self.ItemList[index+2].CanvasGroup.alpha = 0.5-val*0.5
						self.ItemList[index+2].Content.localScale = Vector3.one*(0.6-val*0.6)
					else
						self.ItemList[index+2].CanvasGroup.alpha = 0
						self.ItemList[index+2].Content.localScale = Vector3.one*0
					end
				end
			end
			local onEnd = function()
				self.tweening = false
				self.ItemList[self.currindex].LButton.gameObject:SetActive(self.currindex ~= 1)
				self.ItemList[self.currindex].RButton.gameObject:SetActive(self.currindex ~= self.maxPage)
			end
			Tween.Instance:ValueChange(0, 1, 0.3, onEnd, LeanTweenType.easeInCubic, change)
		end
	end

	self.currindex = index
	self:SetRecData()
end

function SoloEndlessWindow:UpdateInfo()
	local rankval = 38
	local currChapter = 3
	local remainTimes = 1
	local maxTimes = 5
	local recoverTime = BaseUtils.BASE_TIME+3600*9
	local currwave = 22
	self.RankText.text = tostring(rankval)
	local rankLev = {}
	for k,v in pairs(DataSoloendless.data_rank_reward) do
		table.insert(rankLev, k)
	end
	table.sort(rankLev, function(a, b) return a<b end)
	local nextRank = rankLev[1]
	local currRank = rankLev[1]
	for i,v in ipairs(rankLev) do
		if rankval > v and (rankLev[i+1] ~= nil or rankval < rankLev[i+1]) then
			nextRank = v
			currRank = rankLev[i+1]
		end
	end
	for i = 1, 4 do
		local reward = DataSoloendless.data_rank_reward[currRank]
		if reward ~= nil then
			reward = reward.reward[i]
		else
			reward = {}
		end
		if reward ~= nil then
			local base = DataItem.data_get[reward[1]]
			local info = ItemData.New()
            info:SetBase(base)
            info.quantity = reward[2]
            local extra = {inbag = false, nobutton = true}
            self.SlotList[i]:SetAll(info, extra)
        else
        	self.SlotList[i]:Default()
		end
	end
	self.NextText.text = string.format(TI18N("达到<color='#00ff00'>%s名</color>可提升\n排名奖励"), tostring(nextRank))
	self.HelpText.text = TI18N("每周可以求助<color='#13fc60'>2次</color>")
	if self.timestimer ~= nil then
		LuaTimer.Delete(self.timestimer)
		self.timestimer = nil
	end
	if remainTimes == maxTimes then
		self.TimesText.text = string.format(TI18N("挑战次数：<color='#13fc60'>%s/%s</color>"), remainTimes, maxTimes)
	else
		self.timestimer = LuaTimer.Add(0, 1000, function()
			local timestr = BaseUtils.formate_time_gap(recoverTime - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.HOUR)
			self.TimesText.text = string.format(TI18N("挑战次数：<color='#13fc60'>%s/%s</color>\n<color='#23f0f7'>%s</color>"), remainTimes, maxTimes, timestr)
		end)
	end
	self.StartButtonText.text = string.format(TI18N("开始第%s波"), currwave)
end

function SoloEndlessWindow:SetRecData()
	self.recorderDesc.text = string.format(TI18N("第%s章 %s<color='#ffff00'>(%s-%s)</color>挑战记录"), BaseUtils.NumToChn(self.currindex), DataSoloendless.data_list[self.currindex*5-4].chapter_name, tostring(self.currindex*5-4), tostring(self.currindex*5))
	local currdata = {}
	local firstname = "没惹啊啊啊"
	local currname = "没惹啊啊啊"
	if has then
		self.CurrButton.gameObject:SetActive(true)
		self.FirstButtonText.text = string.format(TI18N("首次通关玩家<color='#23f0f7'>%s</color>"), firstname)
		self.CurrButtonText.text = string.format(TI18N("最近通关玩家<color='#23f0f7'>%s</color>"), currname)
	else
		self.FirstButtonText.text = TI18N("尚未有人通关，快快夺取首通荣耀！")
		self.CurrButton.gameObject:SetActive(false)
	end
end

function SoloEndlessWindow:OnRank()
	SoloEndlessManager.Instance:Require18108()
end

function SoloEndlessWindow:OnFirstRec()
	-- body
end

function SoloEndlessWindow:OnCurrRec()
	-- body
end

function SoloEndlessWindow:OnHelp(channel)
	local str = string.format("{endless_1,%s,%s,%s,%s,%s}", self.rid, self.platform, self.zone_id, self.name, BaseUtils.BASE_TIME)
    if channel == MsgEumn.ChatChannel.Private then
        local setting = {
            ismulti = true,
            maxnum = 5,
            callback = function(list) self:SeleteFriend(list, str) NoticeManager.Instance:FloatTipsByString(TI18N("已成功起求助")) end
        }
        if self.friendPanel == nil then
            self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
        end
        self.friendPanel:Show()
    else
    	self.Mgr:Require18104()
        -- local res = ChatManager.Instance:SendMsg(channel, str)
        -- if res then
        --     NoticeManager.Instance:FloatTipsByString(string.format(TI18N("求助信息已发送到%s频道{face_1,18}"), MsgEumn.ChatChannelName[channel]))
        -- end
    end
    self.reqhelp.gameObject:SetActive(false)
end

function SoloEndlessWindow:SeleteFriend(list, str)
	for i,v in ipairs(list) do
		self.Mgr:Require18103(v.id, v.platform, v.zone_id)
        -- FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
    end
end

function SoloEndlessWindow:OnStart()
	self.Mgr:Require18102()
end

function SoloEndlessWindow:OnInfo()
	if true then
		local timegap = BaseUtils.BASE_TIME+3600*7
		local call = function()
			local timestr = BaseUtils.formate_time_gap(timegap - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.HOUR)
			self.TipsText.text = string.format(TI18N("当前挑战次数：<color='#ffff00'>%s/%s</color>\n  %s 后增加<color='#ffff00'>1</color>次\n.发起挑战时消耗次数\n.每<color='#ffff00'>12小时</color>增加<color='#ffff00'>1</color>次挑战次数\n.每周一<color='#00ff00'>5:00</color>重置次数为<color='#ffff00'>3</color>"), 0, 5, timestr)
			self.TipsText.gameObject.transform.sizeDelta = Vector2(self.TipsText.preferredWidth, self.TipsText.preferredHeight)
			self.Tips.sizeDelta = Vector2(self.TipsText.preferredWidth+40, self.TipsText.preferredHeight+40)
		end
		self.txttimer = LuaTimer.Add(0, 1000, call)
		call()
	else
		self.TipsText.text = TI18N("当前挑战次数：%s/%s\n  %s 后增加1次\n.发起挑战时消耗次数\n.每12小时增加1次挑战次数\n.每周一5:00重置次数为3")
	end
	self.TipsText.gameObject.transform.sizeDelta = Vector2(self.TipsText.preferredWidth, self.TipsText.preferredHeight)
	self.Tips.sizeDelta = Vector2(self.TipsText.preferredWidth+40, self.TipsText.preferredHeight+40)
	self.TipsClose:SetActive(true)
	self.Tips.gameObject:SetActive(true)
end
