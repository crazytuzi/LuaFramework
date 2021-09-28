ClanSQPanel = BaseClass(LuaUI)
function ClanSQPanel:__init( root )
	self.ui = UIPackage.CreateObject("Duhufu","SQPanel")
	self.btnTalk = self.ui:GetChild("btnTalk")
	self.btnOneKeySQ = self.ui:GetChild("btnOneKeySQ")
	self.btnSQ = self.ui:GetChild("btnSQ")
	self.txtNotice = self.ui:GetChild("txtNotice")
	self.inputFind = self.ui:GetChild("inputFind")
	self.btnFind = self.ui:GetChild("btn")
	self.listConn = self.ui:GetChild("listConn")

	self.parent = root
	self.items={}
	self.dataList ={}
	self.model = ClanModel:GetInstance()
	self:Layout()

	self.btnTalk.onClick:Add(function ()
		if not self.selectedData then return end
		print("联系都护")
		-- local chatVo = {}
		-- chatVo.sendPlayerLevel = self.selectedData.playerLevel
		-- chatVo.sendPlayerCareer = self.selectedData.career
		-- chatVo.sendPlayerId = self.selectedData.headerId
		-- chatVo.online = 1
		-- chatVo.sendPlayerName = self.selectedData.headerName
		-- chatVo.familyName = self.selectedData.familyName
		-- chatVo.guildName = self.selectedData.guildName
		-- FriendController:GetInstance():IsFriendChat(chatVo)
	end)
	self.btnOneKeySQ.onClick:Add(function ()
		ClanCtrl:GetInstance():C_QuickApply()
	end)
	self.btnSQ.onClick:Add(function ()
		if self.selectedData then
			if self.selectedData.applyFlag == 1 then return end
			ClanCtrl:GetInstance():C_ApplyGuild(self.selectedData.guildId)
		else
			UIMgr.Win_FloatTip("您还没有选择所要加入的都护府！")
		end
	end)
	self.btnFind.onClick:Add(function ()
		if self.items then
			local s = string.trim(self.inputFind.text)
			if string.trim(s) == "" then return end
			local item
			for i=1,#self.items do
				item = self.items[i]
				if item.data and item.data.guildName then
					if item.data.guildName==s then
						self.listConn.scrollPane:ScrollToView(item.ui)
						item:Selected()
						break
					end
				end
			end
		end
	end)

	self.sqGuildItems = self.model:AddEventListener(ClanConst.sqGuildItems, function (dataList)
		self.dataList = dataList
		self:Update()
	end)
	self.sqResultList = self.model:AddEventListener(ClanConst.sqResultList, function (guildIds)
		if self.items and #guildIds ~=0 then
			local item
			for i=1,#self.items do
				item = self.items[i]
				for j=1,#guildIds do
					if item.data.guildId == guildIds[j] then
						item.data.applyFlag = 1
						item:Update()
						break
					end
				end
			end
		end
	end)
end

function ClanSQPanel:Layout()
	self:AddTo(self.parent)
	self:SetXY(161, 132)
end
function ClanSQPanel:Update()
	if not self.ui or self.ui.visible == false then return end
	local model = self.model
	local num = #self.dataList
	local item
	for i=1,num do
		local data = self.dataList[i]
		item = self.items[i]
		if item then
			item:Update(data)
		else
			item = ClanSQItem.New(data)
			item:SetClickCallback(function (target, cellData)
				if self.selected then
					self.selected.selected=false
				end
				target.selected=true
				self.selectedData = cellData
				self.selected = target
			end)
			item:AddTo(self.listConn)
		end
		item:SetXY(0, (i-1)*64)
		self.items[i] = item
	end
	local more = #self.items - num
	if more > 0 then
		for i=more,1,-1 do
			item = self.items[num+i]
			item:Destroy()
			item = nil
			self.items[num+i]=nil
		end
	end
	
end
function ClanSQPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		ClanCtrl:GetInstance():C_GetGuildList()
	end
end

function ClanSQPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.sqGuildItems)
		self.model:RemoveEventListener(self.sqResultList)
	end
	self.items = nil
	self.model = nil
end