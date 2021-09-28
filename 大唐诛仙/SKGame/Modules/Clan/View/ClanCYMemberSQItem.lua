ClanCYMemberSQItem = BaseClass(LuaUI)
function ClanCYMemberSQItem:__init( data )
	self.ui = UIPackage.CreateObject("Duhufu","CYMemberSQItem")
	self.txt1 = self.ui:GetChild("txt1")
	self.txt2 = self.ui:GetChild("txt2")
	self.txt3 = self.ui:GetChild("txt3")
	self.txt4 = self.ui:GetChild("txt4")
	self.btnApply = self.ui:GetChild("btnApply")
	self.btnRefuse = self.ui:GetChild("btnRefuse")
	self.btnApply.visible=true
	self.btnRefuse.enabled=true
	self.btnApply.onClick:Add(function ()
		-- self.applyFunc(self.data)
		self.btnApply.title = "已同意"
		self.btnRefuse.visible=false
		self.btnApply.enabled=false
		ClanCtrl:GetInstance():C_AgreeApply(self.data.playerId)
	end)
	self.btnRefuse.onClick:Add(function ()
		-- self.refuseFunc(self.data)
		self.btnRefuse.title = "已拒绝"
		self.btnApply.visible=false
		self.btnRefuse.enabled=false
		ClanCtrl:GetInstance():C_RefuseApply(self.data.playerId)
	end)
	self:Update(data)
end

function ClanCYMemberSQItem:Update(data)
	self.data = data
	self.txt1.text = GetCfgData("newroleDefaultvalue"):Get(data.career).careerName
	self.txt2.text = data.playerName
	self.txt3.text = data.level
	self.txt4.text = data.battleValue
	-- data.exitTime
	
	if ClanModel:GetInstance().job<2 then
		self.btnRefuse.enabled=false
		self.btnApply.enabled=false
	end
end

function ClanCYMemberSQItem:__delete()
end