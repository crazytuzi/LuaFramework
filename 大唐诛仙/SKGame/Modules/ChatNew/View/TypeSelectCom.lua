TypeSelectCom = BaseClass(LuaUI)

function TypeSelectCom:__init(...)
	self.URL = "ui://m2d8gld1ea8v1i";
	self:__property(...)
	self:Config()
end

function TypeSelectCom:SetProperty(...)
	
end

function TypeSelectCom:Config()
	
end

function TypeSelectCom:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","TypeSelectCom");

	self.btnItemList = self.ui:GetChild("btnItemList")
	self.Bg1 = self.ui:GetChild("Bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.typeContent = self.ui:GetChild("typeContent")

	self.destoryList = {}

	self:ShowBtns()
end

function TypeSelectCom.Create(ui, ...)
	return TypeSelectCom.New(ui, "#", {...})
end

function TypeSelectCom:ShowBtns()
	local data = {{"表情", 0}, {"装备", 1}, {"输入历史", 2}}
	local w = 91
	local h = 91
	local x = 0
	local y = 40
	for i = 1, #data do
		local btn = SelectBtn.New()
		btn:SetData(data[i], x, y, self)
		if i == 1 then
			btn:Select()
		end
		x = x + w + 10
	end
end

function TypeSelectCom:Refresh(cType)
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
	elseif cType == 2 then --输入历史
		local w = 245
		local h = 83
		local x = 2
		local y = 0
		local data = ChatNewModel:GetInstance():GetHistoryInput()
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
		end
	end
end

function TypeSelectCom:OnEquipClick(target)
	local data = target.data
	local vo = {}
	vo.name = data.cfg.name
	vo.equipId = data.equipId
	vo.id = data.cfg.id
	vo.rare = data.cfg.rare
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.SelectEquip, vo)
end

function TypeSelectCom:OnFaceClick(context)
	local str = StringFormat("[:{0}]", context.sender.data)
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.SelectFace, str)
end

function TypeSelectCom:ClearContent()
	destroyUIList(self.destoryList)
	self.destoryList = {}
	while self.typeContent.numChildren > 0 do
		self.typeContent:RemoveChildAt(0)
	end
end

function TypeSelectCom:__delete()
	if self.destoryList then
		destroyUIList(self.destoryList)
	end
	self.destoryList = nil
end