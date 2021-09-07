--作者:hzf
--02/23/2017 11:06:59
--功能:群组信息面板

FriendGroupInfoPanel = FriendGroupInfoPanel or BaseClass(BasePanel)
function FriendGroupInfoPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.groupinfopanel, type = AssetType.Main}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.groupMgr = FriendGroupManager.Instance
	self.friendMgr = FriendManager.Instance
	self.ItemList = {}
	self.updateListener = function()
		self:UpdatePanel()
	end
	self.friendUpdateListener = function()
		self:UpdateList()
	end
end

function FriendGroupInfoPanel:__delete()
	self.groupMgr.OnGroupDataUpdate:Remove(self.updateListener)
	EventMgr.Instance:RemoveListener(event_name.friend_update, self.friendUpdateListener)
	self.bluesprite = nil
	self.greensprite = nil
	self.addsprite = nil
	self.minorssprite = nil
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function FriendGroupInfoPanel:OnHide()

end

function FriendGroupInfoPanel:OnOpen()

end

function FriendGroupInfoPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.groupinfopanel))
	self.gameObject.name = "FriendGroupInfoPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:SetAsFirstSibling()

	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseInfoPanel()
	end)
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.Text = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
	self.NameText = self.transform:Find("MainCon/NameText"):GetComponent(Text)
	self.DescText = self.transform:Find("MainCon/DescText"):GetComponent(Text)

	self.NameInputField = self.transform:Find("MainCon/NameInputField"):GetComponent(InputField)
	local ipf = self.NameInputField
    local textcom = self.NameInputField.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.NameInputField.transform:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder
    self.NameInputField.onValueChange:AddListener(function (val) self:OnNameChange(val) end)


	self.DescInputField = self.transform:Find("MainCon/DescInputField"):GetComponent(InputField)
	local ipf = self.DescInputField
    local textcom = self.DescInputField.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.DescInputField.transform:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder
    self.DescInputField.onValueChange:AddListener(function (val) self:OnDescChange(val) end)

	self.NameButton = self.transform:Find("MainCon/NameButton"):GetComponent(Button)
	self.NameButton.onClick:AddListener(function()
		if self:IsSelfOwner() then
			if self.NameInputField.text ~= self.data.name then
				self.groupMgr:Require19006(self.NameInputField.text, self.data.group_id, self.data.group_platform, self.data.group_zone_id)
			else
				NoticeManager.Instance:FloatTipsByString(TI18N("你没有做出任何修改"))
			end
		else
			NoticeManager.Instance:FloatTipsByString(TI18N("非群主无法修改"))
		end
	end)
	self.NameButtonImage = self.transform:Find("MainCon/NameButton"):GetComponent(Image)
	self.NameButtonText = self.transform:Find("MainCon/NameButton/Text"):GetComponent(Text)

	self.DescButton = self.transform:Find("MainCon/DescButton"):GetComponent(Button)
	self.DescButton.onClick:AddListener(function()
		if self:IsSelfOwner() then
			if self.DescInputField.text ~= self.data.content then
				self.groupMgr:Require19007(self.DescInputField.text, self.data.group_id, self.data.group_platform, self.data.group_zone_id)
			else
				NoticeManager.Instance:FloatTipsByString(TI18N("你没有做出任何修改"))
			end
		else
			NoticeManager.Instance:FloatTipsByString(TI18N("非群主无法修改"))
		end
	end)
	self.Block1 = self.transform:Find("MainCon/Block1").gameObject
	self.Block2 = self.transform:Find("MainCon/Block2").gameObject
	self.transform:Find("MainCon/Block1"):GetComponent(Button).onClick:AddListener(function()
		NoticeManager.Instance:FloatTipsByString(TI18N("非群主无法修改"))
	end)
	self.transform:Find("MainCon/Block2"):GetComponent(Button).onClick:AddListener(function()
		NoticeManager.Instance:FloatTipsByString(TI18N("非群主无法修改"))
	end)
	self.DescButtonImage = self.transform:Find("MainCon/DescButton"):GetComponent(Image)
	self.DescButtonText = self.transform:Find("MainCon/DescButton/Text"):GetComponent(Text)

	self.CurrNumText = self.transform:Find("MainCon/CurrNumText"):GetComponent(Text)
	self.MaxNumText = self.transform:Find("MainCon/MaxNumText"):GetComponent(Text)

	self.Mask = self.transform:Find("MainCon/Mask/Scroll")
	self.List = self.transform:Find("MainCon/Mask/Scroll/List")

	local setting1 = {
        column = 2
        ,cspacing = 4
        ,rspacing = 6
        ,cellSizeX = 254.5
        ,cellSizeY = 74
    }
	self.Layout = LuaGridLayout.New(self.List, setting1)

	self.BaseItem = self.transform:Find("MainCon/Mask/Scroll/List/BaseItem").gameObject
	self.BaseItem:SetActive(false)
	self.transform:Find("MainCon/Mask/Scroll/List/BaseItem/Head").gameObject:SetActive(false)
	self.BaseItem.transform:Find("Button/Image").anchoredPosition = Vector2.zero

	self.ReleaseButton = self.transform:Find("MainCon/ReleaseButton"):GetComponent(Button)
	self.ReleaseButton.onClick:AddListener(function()
		local data = NoticeConfirmData.New()
	    data.type = ConfirmData.Style.Normal
	    if self.groupMgr.data19001.create == 1 then
	    	data.content = string.format(TI18N("你确定要解散<color='#ffff00'>%s</color>群组吗？解散后重新创建需要再次消耗{assets_1,90000, 2000000}"), self.data.name)
	    else
	    	data.content = string.format(TI18N("你确定要解散<color='#ffff00'>%s</color>群组吗？解散后重新创建需要再次消耗{assets_1,90002, 300}"), self.data.name)
	    end
	    data.sureLabel = TI18N("解散")
	    data.cancelLabel = TI18N("取消")
	    data.sureCallback = function()
	            	if self.data ~= nil then
	                	self.groupMgr:Require19005(self.data.group_id, self.data.group_platform, self.data.group_zone_id)
	                end
	        end
	    NoticeManager.Instance:ConfirmTips(data)
	end)
	-- self.Text = self.transform:Find("MainCon/ReleaseButton/Text"):GetComponent(Text)
	self.InviteButton = self.transform:Find("MainCon/InviteButton"):GetComponent(Button)
	self.InviteButton.onClick:AddListener(function()
		self.model:OpenInvitePanel(self.openArgs)
	end)
	self.Text = self.transform:Find("MainCon/InviteButton/Text"):GetComponent(Text)
	self.LeaveButton = self.transform:Find("MainCon/LeaveButton"):GetComponent(Button)
	self.LeaveButton.onClick:AddListener(function()
		local data = NoticeConfirmData.New()
	    data.type = ConfirmData.Style.Normal
	    data.content = string.format(TI18N("确定要离开<color='#ffff00'>%s</color>群组吗？"), self.data.name)
	    data.sureLabel = TI18N("离开")
	    data.cancelLabel = TI18N("取消")
	    data.sureCallback = function()
            	if self.data ~= nil then
                	self.groupMgr:Require19004(self.data.group_id, self.data.group_platform, self.data.group_zone_id)
                end
	        end
	    NoticeManager.Instance:ConfirmTips(data)
	end)
	-- self.Text = self.transform:Find("MainCon/LeaveButton/Text"):GetComponent(Text)
	self.CommentButton = self.transform:Find("MainCon/CommentButton"):GetComponent(Button)
	self.Toggle = self.transform:Find("MainCon/Toggle"):GetComponent(Toggle)
	self.Toggle.onValueChanged:AddListener(function(val)
		self:OnToggleChange(val)
	end)
	self.Background = self.transform:Find("MainCon/Toggle/Background")
	self.Checkmark = self.transform:Find("MainCon/Toggle/Background/Checkmark")
	self.Label = self.transform:Find("MainCon/Toggle/Label")

	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseInfoPanel()
	end)

	self.bluesprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
	self.greensprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton6")


	self.addsprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "InfoIcon16")
	self.minorssprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "InfoIcon8")



	-- self.data = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
	self:UpdatePanel()
	EventMgr.Instance:AddListener(event_name.friend_update, self.friendUpdateListener)
	self.groupMgr.OnGroupDataUpdate:Add(self.updateListener)
end

function FriendGroupInfoPanel:UpdatePanel()
	self.data = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
	self.Block1:SetActive(not self:IsSelfOwner())
	self.Block2:SetActive(not self:IsSelfOwner())
	if self.data ~= nil then
		self.NameInputField.text = self.data.name
		self.DescInputField.text = self.data.content
		self:OnNameChange()
		self:OnDescChange()
		local onlinenum = self:GetOnlineNum()
		self.CurrNumText.text = string.format(TI18N("群组成员 %s/%s"), onlinenum, #self.data.members)
		self.MaxNumText.text = TI18N("群组成员上限:15")
		self.Toggle.isOn = self:IsSelfNotice()
		if self:IsSelfOwner() then
			self.NameInputField.enabled = true
			self.DescInputField.enabled = true
			self.ReleaseButton.gameObject:SetActive(true)
			self.InviteButton.gameObject:SetActive(true)
			self.LeaveButton.gameObject:SetActive(false)
			self.CommentButton.gameObject:SetActive(false)
		else
			self.NameInputField.enabled = false
			self.DescInputField.enabled = false
			self.ReleaseButton.gameObject:SetActive(false)
			self.InviteButton.gameObject:SetActive(true)
			self.LeaveButton.gameObject:SetActive(true)
			self.CommentButton.gameObject:SetActive(false)
		end
	end
	self:UpdateList()
end

function FriendGroupInfoPanel:OnNameChange(val)
	if self.data ~= nil then
		if self.NameInputField.text ~= self.data.name then
			self.NameButtonImage.sprite = self.greensprite
			self.NameButtonText.color = ColorHelper.DefaultButton6
			self.NameButtonText.text = TI18N("保存")
		else
			self.NameButtonImage.sprite = self.bluesprite
			self.NameButtonText.color = ColorHelper.DefaultButton5
			self.NameButtonText.text = TI18N("修改")
		end
	end
end

function FriendGroupInfoPanel:OnDescChange(val)
	if self.data ~= nil then
		if self.DescInputField.text ~= self.data.content then
			self.DescButtonImage.sprite = self.greensprite
			self.DescButtonText.color = ColorHelper.DefaultButton6
			self.DescButtonText.text = TI18N("保存")
		else
			self.DescButtonImage.sprite = self.bluesprite
			self.DescButtonText.color = ColorHelper.DefaultButton5
			self.DescButtonText.text = TI18N("修改")
		end
	end
end

function FriendGroupInfoPanel:GetOnlineNum(val)
	if self.data ~= nil then
		local num = 0
		for k,v in pairs(self.data.members) do
			if v.online == 1 then
				num = num + 1
			end
		end
		return num
	end
	return 0
end

function FriendGroupInfoPanel:IsSelfOwner()
	if self.data ~= nil then
		local roleData = RoleManager.Instance.RoleData
		for k,v in pairs(self.data.members) do
			if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
				return v.post == 1
			end
		end
		return false
	end
	return false
end

function FriendGroupInfoPanel:IsSelfNotice()
	if self.data ~= nil then
		local roleData = RoleManager.Instance.RoleData
		for k,v in pairs(self.data.members) do
			if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
				return v.notice == 1
			end
		end
		return false
	end
	return 0
end

function FriendGroupInfoPanel:OnToggleChange(val)
	if self.data ~= nil then
		if self:IsSelfNotice() ~= val then
			if val then
				print("接收")
				self.groupMgr:Require19011(self.data.group_id, self.data.group_platform, self.data.group_zone_id, 1)
			else
				print("不接收")
				self.groupMgr:Require19011(self.data.group_id, self.data.group_platform, self.data.group_zone_id, 0)
			end
		end
	end
end

function FriendGroupInfoPanel:UpdateList()
	if self.data == nil then
		return
	end
	self.Layout:ReSet()
	for i = #self.data.members, 1, -1 do
		self:CreatPlayerItem(self.data.members[i])
	end
	-- for i,v in ipairs(self.data.members) do
	-- 	self:CreatPlayerItem(v)
	-- end
end

function FriendGroupInfoPanel:CreatPlayerItem(data)
	if data.role_sex == nil then data.role_sex = 0 end
	local parentcon = self.List
	local key = data.role_name..tostring(data.role_rid)
    local item =  parentcon:Find(key) or GameObject.Instantiate(self.BaseItem)
    -- UIUtils.AddUIChild(parentcon.gameObject, item.gameObject)
    self.Layout:AddCell(item.gameObject)
    item.gameObject.name = key
    local itemtrans = item.transform
    if self.ItemList[key] == nil then
    	self.ItemList[key] = {item = item.gameObject}
    	local headSlot = HeadSlot.New()
    	self.ItemList[key].headSlot = headSlot
	    itemtrans:Find("Headbg"):GetComponent(Image).enabled = false
	    headSlot:SetRectParent(itemtrans:Find("Headbg"))
    end

    local dat = {id = data.role_rid, platform = data.role_platform, zone_id = data.role_zone_id,classes = data.role_classes, sex = data.role_sex}
    self.ItemList[key].headSlot:SetAll(dat, {isSmall = true})

	if data.online ~= 0 then
        itemtrans:Find("Head"):GetComponent(Image).color = Color(1,1,1)
        -- BaseUtils.SetGrey(itemtrans:Find("Head"):GetComponent(Image), false)
        itemtrans:Find("name"):GetComponent(Text).color = Color(49/255, 102/255, 173/255)
    else
        -- BaseUtils.SetGrey(itemtrans:Find("Head"):GetComponent(Image), true)
        itemtrans:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
        itemtrans:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    end
    self.ItemList[key].headSlot:SetGray(data.online == 0)
	itemtrans:Find("LevText"):GetComponent(Text).text = data.role_lev
	itemtrans:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.role_classes))
	itemtrans:Find("name"):GetComponent(Text).text = data.role_name
	itemtrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
	itemtrans:Find("Button"):GetComponent(Button).onClick:AddListener(function()
		if self:IsSelfOwner() then
			local Noticedata = NoticeConfirmData.New()
		    Noticedata.type = ConfirmData.Style.Normal
		    Noticedata.content = string.format(TI18N("你确定要将<color='#00ff00'>%s</color>踢出群组吗？"), data.role_name)
		    Noticedata.sureLabel = TI18N("踢出")
		    Noticedata.cancelLabel = TI18N("取消")
		    Noticedata.sureCallback = function()
	            	if self.data ~= nil then
						self.groupMgr:Require19008(self.data.group_id, self.data.group_platform, self.data.group_zone_id, data.role_rid, data.role_platform, data.role_zone_id)
	                end
		        end
		    NoticeManager.Instance:ConfirmTips(Noticedata)
		else
			self.friendMgr:AddFriend(data.role_rid, data.role_platform, data.role_zone_id)
			itemtrans:Find("Button").gameObject:SetActive(false)
		end
	end)
	if self:IsSelfOwner() then
		itemtrans:Find("Button/Image"):GetComponent(Image).sprite = self.minorssprite
		itemtrans:Find("Button/Image").sizeDelta = Vector2(32, 16)
		itemtrans:Find("Button").gameObject:SetActive(true)
	else
		if not self.friendMgr:IsFriend(data.role_rid, data.role_platform, data.role_zone_id) and BaseUtils.IsTheSamePlatform(data.role_platform, data.role_zone_id) then
			itemtrans:Find("Button/Image").sizeDelta = Vector2(32, 32)
			itemtrans:Find("Button/Image"):GetComponent(Image).sprite = self.addsprite
		else
			itemtrans:Find("Button").gameObject:SetActive(false)
		end
	end
	local roleData = RoleManager.Instance.RoleData
	local isself = false
	if data.role_rid == roleData.id and data.role_platform == roleData.platform and data.role_zone_id == roleData.zone_id then
		isself = true
	end
	itemtrans:Find("label").gameObject:SetActive(data.post == 1)
	itemtrans:Find("Button").gameObject:SetActive((self:IsSelfOwner() or not self.friendMgr:IsFriend(data.role_rid, data.role_platform, data.role_zone_id))and not isself)
end
