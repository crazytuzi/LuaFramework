ReportView = ReportView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject



function ReportView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.ReportView
    self.name = "ReportView"
    self.friendMgr = self.model.friendMgr
    self.resList = {
        {file = AssetConfig.reportwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.Layout = nil
    self.CopyItem = nil
    self.noFriend = nil
    self.input_field = nil
    self.toggleList = {}

    self.data = nil
    self.dataList = {}
    self.itemList = {}
    -----------------------------------------

    self.selectList = BaseUtils.create_queue()
end

function ReportView:__delete()
    self:ClearDepAsset()
end

function ReportView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reportwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CopyItem = self.transform:Find("Main/CopyItem").gameObject

    self.descTxt = self.transform:Find("Main"):GetChild(10):GetComponent(Text)
    self.titleTxt = self.transform:Find("Main/NameText"):GetComponent(Text)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/Con")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("Main/Con/Layout"), setting)

    self.noFriend = self.transform:Find("Main/Con/NoFriend").gameObject

    self.toggleList = {}
    for i=1, 6 do
    	local toggle = self.transform:Find("Main/TogglePanel/Toggle"..i):GetComponent(Toggle)
    	table.insert(self.toggleList, toggle)
    end

	self.input_field = self.transform:FindChild("Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
	self.input_field.textComponent = self.transform:FindChild("Main/InputCon/InputField/Text"):GetComponent(Text)
	self.input_field.placeholder = self.transform:FindChild("Main/InputCon/InputField/Placeholder"):GetComponent(Text)
	self.input_field.placeholder.text = TI18N("点击这里输入原因，最多100字")
	self.input_field.characterLimit = 100

    self.okButton = self.transform:Find("Main/OkButton")
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)

    self.descButton = self.transform:Find("Main/DescButton")
    self.descButton:GetComponent(Button).onClick:AddListener(function()
    	 	TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject
            	, itemData = {TI18N("1.系统<color='#ffff00'>不会</color>以任何形式透露举报人信息。")
								, TI18N("2.举报属实，给予<color='#ffff00'>首名</color>举报人奖励。")
								, TI18N("3.根据情节轻重，给予被举报人相应<color='#ffff00'>惩罚</color>。")}})
    	end)

    -- self.transform:Find("Main/DescText"):GetComponent(Text).text = ""

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
    end

    --//默认为聊天or留言板举报、类型2为公会公告宗旨举报、类型3为公会邮件举报
    self.type = self.openArgs[2]


    local txtList = {TI18N("发布广告"), TI18N("反动政治"), TI18N("其它")}
    if self.type == 2 or self.type == 3 then 
        for i=1, 6 do
            if i <= 3 then 
                self.toggleList[i].transform:Find("Label"):GetComponent(Text).text = txtList[i]
            else
                self.toggleList[i].transform.gameObject:SetActive(false)
            end
        end
        self.transform:Find("Main"):GetChild(3).anchoredPosition = Vector2(0,168)
        self.transform:Find("Main"):GetChild(4).anchoredPosition = Vector2(0,168)
        self.transform:Find("Main"):GetChild(5).anchoredPosition = Vector2(-197,108)
        self.transform:Find("Main"):GetChild(6).anchoredPosition = Vector2(-25,113)
        self.transform:Find("Main"):GetChild(7).anchoredPosition = Vector2(42,54)
        self.transform:Find("Main"):GetChild(8).anchoredPosition = Vector2(-197,54)
    end

    self:Update()
end

function ReportView:Close()
    self.model:CloseWindow()
end

function ReportView:Update()
	if self.data == nil then return end
	
    BaseUtils.clearqueue(self.selectList)

    local titleStr = TI18N("被举报玩家：")
    local descStr = TI18N("勾选发言记录作为证据")
    if self.type == 2 then 
        self:UpdateGuildBoradList()
        titleStr = TI18N("被举报公会：")
        descStr = TI18N("勾选公会公告内容作为证据")
    elseif self.type == 3 then 
        self:UpdateGuildMailList()
        titleStr = TI18N("被举报公会：")
        descStr = TI18N("勾选公会邮件内容作为证据")
    else
        self:UpdateChatList()
    end
    self:UpdateItem()
    self.titleTxt.text = string.format(TI18N("%s<color='#ffff00'>%s</color>"), titleStr, self.data.name)
    self.descTxt.text = descStr
end

function ReportView:UpdateItem()
    self.itemList = {}
    local tab 
    for k,v in ipairs(self.dataList) do
        local item = GameObject.Instantiate(self.CopyItem)
        self:SetItem(item, v, k)
        self.Layout:AddCell(item.gameObject)
        table.insert(self.itemList, item:GetComponent(Toggle))
    end

    self.Layout:ReSize()
end

function ReportView:UpdateChatList()
    local channelIndexList = { 1, 2, 3, 4, 8}
	self.dataList = {}
	local chatWindow = ChatManager.Instance.model.chatWindow
	if chatWindow ~= nil then
		for channelIndex=1, #channelIndexList do
			if chatWindow.channelContainerTab[channelIndexList[channelIndex]] ~= nil then
				for key, value in pairs(chatWindow.channelContainerTab[channelIndexList[channelIndex]].elementTab) do
					if value.data.name == self.data.name then
						table.insert(self.dataList, value.data)
					end
				end
			end
		end
	end

    local historyTab = ChatManager.Instance.model.historyTab
	for channelIndex=1, #channelIndexList do
		for key, value in pairs(historyTab[channelIndexList[channelIndex]]) do
			if value.name == self.data.name then
				table.insert(self.dataList, value)
			end
		end
	end

	for key, value in pairs(FriendManager.Instance.chatData) do
		for key2, value2 in pairs(value) do
			if value2.name == self.data.name then
				table.insert(self.dataList, value2)
			end
		end
	end
    local danmakuhistory = CombatManager.Instance.danmakuHistory
    for key, value in pairs(danmakuhistory) do
        if value.name == self.data.name then
            table.insert(self.dataList, value)
        end
    end
    -- BaseUtils.dump(self.dataList, "dataList")
end

function ReportView:UpdateGuildBoradList()
    if self.openArgs[1].borad then 
        self.dataList = self.openArgs[1].borad
    end
end

function ReportView:UpdateGuildMailList()
    if self.openArgs[1].mail then 
        self.dataList = self.openArgs[1].mail
    end
end

function ReportView:SetItem(item, data, k)
    local its = item.transform
    item:GetComponent(Toggle).onValueChanged:AddListener(function(on) 
        if on then 
            if self.selectList.len == 3 then    --//上限为3个(最多选择3个操作)
                self.itemList[BaseUtils.dequeue(self.selectList)]:GetComponent(Toggle).isOn = false
            end
            BaseUtils.enqueue(self.selectList, k)
        else
            local len = self.selectList.len
            local temp = {}
            for i = 1, len do
                local tmp = BaseUtils.dequeue(self.selectList)
                if k ~= tmp then 
                    table.insert( temp, tmp)
                end
            end
            BaseUtils.clearqueue(self.selectList)
            for _,vv in ipairs(temp) do
                BaseUtils.enqueue(self.selectList, vv)
            end
        end
    end)
    local label = its:Find("Label"):GetComponent(Text)
    local str = ""
    if self.type == 2 then 
        str = string.format("<color='#3cf6fd'>[%s]%s：%s</color>", TI18N("公会公告"), data.publish_name, data.content)
        label.text = str
    elseif self.type == 3 then 
        str = string.format("<color='#3cf6fd'>[%s]%s：%s</color>", TI18N("公会邮件"), data.publish_name, data.content)
        label.text = str
    else
        str = data.msgData.showString
        str = string.gsub(str, "{.-}", "##")
        label.text = string.format("<color='%s'>[%s]%s：%s</color>", MsgEumn.ChannelColor[data.channel], MsgEumn.ChatChannelName[data.channel], self.data.name, str)
    end
    its.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(360, label.preferredHeight + 2)
end

function ReportView:OnOkButton()
	if self.data == nil then return end
    local reason = self.input_field.text
    local rid = self.data.roleid
    local platform = self.data.platform
    local zone_id = self.data.zone_id
    local msg = {}
    local new = ""
    local type = 0
    local flag
    for k,v in pairs(self.toggleList) do
    	if v.isOn then
    		type = k
    		break
    	end
    end

    local dat
    local title = ""
    local content = ""
    local chat_time = 0
    -- BaseUtils.dump(self.dataList)
    for k,v in pairs(self.itemList) do
        dat = self.dataList[k]
        
        if v.isOn then
            if self.type == 2 then 
                rid = dat.rid
                platform = dat.platform
                zone_id = dat.zone_id

                title = TI18N("公会公告")
                content = string.format( "%s[%s]",dat.content, self.data.name)
                chat_time = 0

                flag = 2
            elseif self.type == 3 then 
                rid = dat.rid
                platform = dat.platform
                zone_id = dat.zone_id

                title = TI18N("公会邮件")
                content = string.format( "%s[%s]",dat.content, self.data.name)
                chat_time = 0
                flag = 2
            else
                title = MsgEumn.ChatChannelName[dat.channel]
                content = dat.msgData.showString
                chat_time = dat.recvTime or 0
            end
            table.insert(msg, {title = title, content = content, chat_time = chat_time})
    	end
    end

    if type == 0 then
    	NoticeManager.Instance:FloatTipsByString(TI18N("请选择举报类型"))
    	return
    end
    if type == 6 and reason == "" then
    	NoticeManager.Instance:FloatTipsByString(TI18N("请输入举报原因"))
    	return
    end
    if type ~= 1 and type ~= 6 and #msg == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请勾选违规发言以供审核"))
        return
    end

    ReportManager.Instance:Send14702(rid, platform, zone_id, reason, msg, type, flag)
    
    self:Close()
end