ClanChangeJobPane = BaseClass(LuaUI)
function ClanChangeJobPane:__init( data )
	self.ui = UIPackage.CreateObject("Duhufu","ChangeJobPane")
	self.title = self.ui:GetChild("title")
	self.btn1 = self.ui:GetChild("btnClan")
	self.btn2 = self.ui:GetChild("btnClan2")
	self.btn3 = self.ui:GetChild("btnNormal")
	self.btn4 = self.ui:GetChild("btnKick")
	self.btnCancel = self.ui:GetChild("btnCancel")
	self:InitEvent()

	self:SetData( data )
end
function ClanChangeJobPane:SetData( data )
	self.data = data
	self:Update()
end
function ClanChangeJobPane:InitEvent()
	local function exit()
		UIMgr.HidePopup(self.ui)
		self:Destroy()
	end

	self.btn1.onClick:Add(function ()
		ClanCtrl:GetInstance():C_ChangeGuildRole(self.data.playerId, 3)
		exit()
	end)
	self.btn2.onClick:Add(function ()
		ClanCtrl:GetInstance():C_ChangeGuildRole(self.data.playerId, 2)
		exit()
	end)
	self.btn3.onClick:Add(function ()
		ClanCtrl:GetInstance():C_ChangeGuildRole(self.data.playerId, 1)
		exit()
	end)
	self.btn4.onClick:Add(function ()
		ClanCtrl:GetInstance():C_KickGuild(self.data.playerId)
		exit()
	end)


	self.btnCancel.onClick:Add(exit)
end
function ClanChangeJobPane:Update()
	if ClanModel:GetInstance().job == 2 then
		self.btn1.visible = false
		self.btn2.visible = false
		self.btn3:SetXY(self.btn1.x, self.btn1.y)
		self.btn4:SetXY(self.btn2.x, self.btn2.y)
	-- elseif ClanModel:GetInstance().job == 3 then
	-- 	self.btn1.visible = false
	-- 	self.btn4:SetXY(self.btn3.x, self.btn3.y)
	-- 	self.btn3:SetXY(self.btn2.x, self.btn2.y)
	-- 	self.btn2:SetXY(self.btn1.x, self.btn1.y)
	end
	if SceneModel:GetInstance():GetMainPlayer().eid == self.data.playerId then
		self.btn4.visible = false
	end
end
function ClanChangeJobPane:__delete()
	self.data=nil
end
