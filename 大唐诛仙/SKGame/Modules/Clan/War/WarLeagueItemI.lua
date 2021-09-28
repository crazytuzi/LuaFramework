WarLeagueItemI = BaseClass(LuaUI)
function WarLeagueItemI:__init(data)
	self.data = data
	local ui = UIPackage.CreateObject("Duhufu","WarLeagueItemI")
	self.ui = ui
	self.btn = ui:GetChild("btn")
	self.title = ui:GetChild("title")
	self:Update(data)

	self.btn.onClick:Add(function ()
		if not self.data then return end
		ClanCtrl:GetInstance():C_ApplyUnion(self.data.unionId)
	end)
end
function WarLeagueItemI:Update( v )
	self.data = v
	-- v.unionId = 1;  // 联盟编号
	-- v.unionName = 2;  // 联盟名
	-- v.applyFlag = 3;   // 是否已申请  1：是
	if not v then return end
	self.title.text = v.unionName
end
function WarLeagueItemI:OnUnion(id)
	self.btn.enabled = true
	self.btn.visible = true
	if tostring(id) == "0" then
		if self.data.applyFlag == 1 then
			self.btn.enabled = false
			self.btn.title = "已申请"
		else
			if ClanModel:GetInstance().job < 2 then
				self.btn.enabled = false
			else
				self.btn.title = "申请加入"
			end
		end
	else
		self.btn.enabled = false
		if self.data.unionId == id then
			self.btn.title = "已加入"
		else
			self.btn.visible = false
		end
	end
end

function WarLeagueItemI:__delete()
end