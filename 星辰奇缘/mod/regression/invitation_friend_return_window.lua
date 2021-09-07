InvitationFriendReturnWindow = InvitationFriendReturnWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function InvitationFriendReturnWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.invitationfriendreturnwindow
    self.name = "InvitationFriendReturnWindow"
    self.resList = {
        {file = AssetConfig.invitationfriendreturnwindow, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.stongbg, type = AssetType.Dep}
    }

    -----------------------------------------
    self.headSlot = {}
    self.nameText = {}
    self.sexImg = {}
    self.addImg = {}
    self.buttonText = {}
    self.label = {}
    -----------------------------------------
    self.select_item = nil
    self.select_data = nil

    -----------------------------------------
    self._Update = function()
        self:Update()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function InvitationFriendReturnWindow:__delete()
    self:ClearDepAsset()
    RegressionManager.Instance.friendUpdate:Remove(self._Update)
end

function InvitationFriendReturnWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.invitationfriendreturnwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/Item1/StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.CloseButton = self.transform:Find("Main/Close")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.descText = self.transform:Find("Main/DescText1"):GetComponent(Text)

    local i = 1
	-- for i=1,3 do
		local item = self.transform:Find("Main/Item"..i)
	    local head = item:Find("Head")
	    local headSlot = HeadSlot.New()
	    headSlot:SetRectParent(head)
	    headSlot.transform:SetAsFirstSibling()
	    headSlot:HideSlotBg(true)
	    table.insert(self.headSlot, headSlot)


	    local index = i
	    item:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OnClickItem(index) end)

	    local nameText = item:Find("NameText"):GetComponent(Text)
	    table.insert(self.nameText, nameText)

	    local sexImg = item:Find("Sex")
		table.insert(self.sexImg, sexImg)

		local buttonText = item:Find("Button/Text"):GetComponent(Text)
		table.insert(self.buttonText, buttonText)

		local addImg = head:Find("AddImage").gameObject
		table.insert(self.addImg, addImg)
		addImg:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(index) end)

		local label = head:Find("Label").gameObject
		table.insert(self.label, label)
	-- end

    self:Update()
    RegressionManager.Instance.friendUpdate:Add(self._Update)
end

function InvitationFriendReturnWindow:Close()
    self.model:CloseInvitationFriendReturnWindow()
end

function InvitationFriendReturnWindow:Update()
	-- local color = "#00ff00"
	-- if self.model.friendTimes == 0 then
	-- 	color = "#ff0000"
	-- end
 --    self.descText.text = string.format(TI18N("你的招募ID为：%s  当前可招募（<color='%s'>%s</color>/3）名好友"), self.model.id, color, self.model.friendTimes)

	-- for i=1,3 do
	-- 	local data = self.model.friendList[i]
	-- 	local friend_data = nil
	-- 	local login = 0
	-- 	if data ~= nil then
	-- 		local uid = BaseUtils.Key(data.role_id, data.platform, data.zone_id)
	-- 		friend_data = FriendManager.Instance.friend_List[uid]
	-- 		login = data.login
	-- 	end
	-- 	self:SetItem(i, friend_data, login)
	-- end

	self.descText.text = string.format(TI18N("你的招募ID为：%s"), self.model.id)

	local i = 1
	local login = 1
	local uid = BaseUtils.Key(self.model.role_id_bind, self.model.platform_bind, self.model.zone_id_bind)
	local friend_data = FriendManager.Instance.friend_List[uid]
	self:SetItem(i, friend_data, login)
end

function InvitationFriendReturnWindow:SetItem(i, data, login)
	if data == nil then
	    self.nameText[i].text = TI18N("<color='#7eb9f7'>暂未招募</color>")
	    self.sexImg[i].gameObject:SetActive(false)

	    self.headSlot[i]:Default()
	    self.addImg[i]:SetActive(true)
	    self.buttonText[i].text = TI18N("招募")
	else
	    self.nameText[i].text = data.name
	    self.sexImg[i].gameObject:SetActive(true)
	    self.sexImg[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("IconSex%s", data.sex))

	    self.headSlot[i]:SetAll(data, { small = true })
	    self.addImg[i]:SetActive(false)
	    self.buttonText[i].text = TI18N("已招募")

	    if data.id == self.model.role_id_bind and data.platform == self.model.platform_bind and data.zone_id == self.model.zone_id_bind then
		    self.label[i]:SetActive(true)
		else
			self.label[i]:SetActive(false)
		end

		if login == 0 then
			self.headSlot[i]:SetGray(true)
		else
			self.headSlot[i]:SetGray(false)
		end
	end
end

function InvitationFriendReturnWindow:OnClickItem(index)
	-- if self.model.friendTimes == 0 then
	-- 	NoticeManager.Instance:FloatTipsByString(TI18N("招募好友名额重置时间为1个月哦~"))
	-- 	return
	-- end

	local customlist = {}
	local tempList = FriendManager.Instance:GetSortFriendList()
	local timeout = 8 * 24 * 3600
	for key, value in pairs(tempList) do
		if value.online_time ~= 0 and BaseUtils.BASE_TIME - value.online_time > timeout and value.lev >= 70 then
			local mark = true
			for i=1,#self.model.friendList do
				local data = self.model.friendList[i]
				if data ~= nil and data.role_id == value.id and  data.platform == value.platform and data.zone_id == value.zone_id then
					mark = false
				end
			end
			if mark then
				table.insert(customlist, value)
			end
		end
	end

	self.pos = index
	local setting = {
		list_type = 2,
	    ismulti = false,
	    customlist = customlist,
	    nofriendtext = TI18N("没有符合条件的好友"),
	    callback = function(list)
	    	for i,v in ipairs(list) do
		        RegressionManager.Instance:Send11878(v.id, v.platform, v.zone_id, self.pos)
		    end
		end
	}
    if self.friendPanel == nil then
	    self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
	end
	self.friendPanel:Show()
end
