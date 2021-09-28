WarMemItem = BaseClass(LuaUI)
function WarMemItem:__init(data)
	local ui = UIPackage.CreateObject("Duhufu","WarMemItem")
	self.ui = ui
	self.tnum = ui:GetChild("tnum")
	self.tdff = ui:GetChild("tdff")
	self.tlm = ui:GetChild("tlm")
	self:Update(data)
end
function WarMemItem:Update( v )
	self.data = v
	-- v.guildName = 1 // 都护府名
	-- v.unionName = 2 // 联盟名
	-- v.createFlag = 3 // 是否盟主
	self.tdff.text = v.guildName
	if v.createFlag == 1 then
		self.tlm.text = StringFormat("{0} [color=#00ff00]（盟主）[/color]",v.unionName)
	else
		self.tlm.text = v.unionName
	end
end
function WarMemItem:SetNum( v )
	self.tnum.text = v
end

function WarMemItem:__delete()
end