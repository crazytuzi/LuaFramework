ClanSQItem = BaseClass(LuaUI)
function ClanSQItem:__init( data )
	self.ui = UIPackage.CreateObject("Duhufu","SQItem")
	self.t1 = self.ui:GetChild("t1")
	self.t2 = self.ui:GetChild("t2")
	self.t3 = self.ui:GetChild("t3")
	self.t4 = self.ui:GetChild("t4")
	self.t5 = self.ui:GetChild("t5")
	self.ui.onClick:Add(function ()
		if self.func then
			self.func(self.ui, self.data)
		end
	end)
	self:Update( data )
end
function ClanSQItem:Selected()
	if self.func then
		self.func(self.ui, self.data)
	end
end
function ClanSQItem:Update( data )
	self.data = data or self.data
	data = self.data
	self.t1.text = data.guildName
	self.t2.text = data.headerName
	self.t3.text = data.level
	self.t4.text = data.memberNum
	self.t5.text = data.applyFlag == 1 and "已申请" or "可申请"

	-- data.applyFlag --是否已申请  1：是
	-- data.autoJoin = 0 --是否勾选自动加入 1：是
	-- data.autoMinLv = 0 --最小设定等级
	-- data.autoMaxLv = 0 --最大设定等级
end
function ClanSQItem:SetClickCallback( func )
	self.func = func
end

function ClanSQItem:__delete()
end