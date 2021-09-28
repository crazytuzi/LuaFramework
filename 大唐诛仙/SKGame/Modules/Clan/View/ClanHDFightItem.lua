ClanHDFightItem = BaseClass(LuaUI)
function ClanHDFightItem:__init( v )
	self.ui = UIPackage.CreateObject("Duhufu","HDFightItem")
	self.txtName = self.ui:GetChild("txtName")
	self.txtLv = self.ui:GetChild("txtLv")
	self.txtStatus = self.ui:GetChild("txtStatus")
	self.txtTime = self.ui:GetChild("txtTime")

	self.lessTime = 0
	self.ui.onClick:Add(function ()
		self.func(self.ui, self.data)
	end)
	self:Update(v)
end

function ClanHDFightItem:SetClickCallback( func )
	self.func = func
end

function ClanHDFightItem:Update(v)
	self.data = v
	self.txtName.text = v.guildName
	self.txtLv.text = v.level
	self.txtStatus.text = v.battleValue
	local t = v.endWarTime - TimeTool.GetCurTime()
	self.lessTime = math.floor(t*0.001)
	self:SetTime()
end
function ClanHDFightItem:UpdateTime()
	if self.lessTime ~= 0 then
		self.lessTime = self.lessTime - 1
		self:SetTime()
	end
	
end
function ClanHDFightItem:SetTime()
	self.lessTime = math.max(self.lessTime, 0)
	local t = self.lessTime
	if t == 0 then
		self.txtTime.text = TimeTool.GetTimeFormat(t)
	else
		self.txtTime.text = TimeTool.GetTimeFormat(t)
	end
end

function ClanHDFightItem:__delete()
	self.lessTime = 0
	self.data = nil
end