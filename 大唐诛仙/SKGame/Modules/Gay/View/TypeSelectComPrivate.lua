TypeSelectComPrivate = BaseClass(LuaUI)

function TypeSelectComPrivate:__init(...)
	self.URL = "ui://jn83skxkeykg1o";
	self:__property(...)
	self:Config()
end

function TypeSelectComPrivate:SetProperty(...)
	
end

function TypeSelectComPrivate:Config()
	
end

function TypeSelectComPrivate:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Gay","TypeSelectComPrivate");

	self.btnItemList = self.ui:GetChild("btnItemList")
	self.bg1 = self.ui:GetChild("bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.typeContent = self.ui:GetChild("typeContent")

	self.destoryList = {}

	self:ShowBtns()
end

function TypeSelectComPrivate.Create(ui, ...)
	return TypeSelectComPrivate.New(ui, "#", {...})
end

function TypeSelectComPrivate:ShowBtns()
	local data = {{"表情", 0}, {"装备", 1}}
	local w = 91
	local h = 91
	local x = 35
	local y = 50
	for i = 1, #data do
		local btn = SelectBtn.New()
		btn:SetData(data[i], x, y, self)
		if i == 1 then
			btn:Select()
		end
		x = x + w + 50
	end
end

function TypeSelectComPrivate:Refresh(cType)
	self:ClearContent()
	if cType == 0 then --表情
		local w = 60
		local h = 60
		local x = -6
		local y = 0
		for i = 1, #ChatNewConst.TAGS do
			local item = UIPackage.CreateObject("ChatNew", "Face")
			item.icon = UIPackage.GetItemURL("ChatNew" , ChatNewConst.TAGS[i])
			item.data = ChatNewConst.TAGS[i]
			item.onClick:Add(self.OnFaceClick, self) 
			item.x = x
			item.y = y
			x = x + w + 18
			if i % 10 == 0 then
				y = y + h + 20
				x = -6
			end
			self.typeContent:AddChild(item)
			table.insert(self.destoryList, item)
		end
	elseif cType == 1 then --装备
		local w = 123
		local h = 123
		local x = 30
		local y = 0
		local data = PkgModel:GetInstance():GetAllEquipInfos2()
		for i = 1, #data do
			local icon = PkgCell.New(self.typeContent)
			icon:SetData(data[i])
			icon:SetXY(x, y)	
			icon:SetSelectCallback( function(data) self:OnEquipClick(data) end )
			icon:SetupPressShowTips(true, 0.3)
			x = x + w + 5
			if i % 6 == 0 then
				y = y + h + 5
				x = 30
			end
			table.insert(self.destoryList, icon)
		end
	--[[elseif cType == 2 then --输入历史
		local w = 245
		local h = 83
		local x = 2
		local y = 0
		local data = FriendModel:GetInstance():GetHistoryInput()
		for i = 1, #data do
			local item = HistorySay.New()
			item:SetData(data[i])
			item:SetXY(x, y)
			x = x + w + 20
			if i % 3 == 0 then
				y = y + h + 20
				x = 2
			end
			self.typeContent:AddChild(item.ui)
			table.insert(self.destoryList, item)
		end]]--
	end
end

function TypeSelectComPrivate:OnEquipClick(target)
	local data = target.data
	local vo = {}
	vo.name = data.cfg.name
	vo.equipId = data.equipId
	vo.id = data.cfg.id
	vo.rare = data.cfg.rare
	FriendModel:GetInstance():DispatchEvent(FriendConst.SelectEquip, vo)
end

function TypeSelectComPrivate:OnFaceClick(context)
	local str = StringFormat("[:{0}]", context.sender.data)
	FriendModel:GetInstance():DispatchEvent(FriendConst.SelectFace, str)
end

function TypeSelectComPrivate:ClearContent()
	destroyUIList(self.destoryList)
	self.destoryList = {}
	while self.typeContent.numChildren > 0 do
		self.typeContent:RemoveChildAt(0)
	end
end

function TypeSelectComPrivate:__delete()
	destroyUIList(self.destoryList)
	self.destoryList = nil
end