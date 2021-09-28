WarReadyPane = BaseClass(LuaUI)
function WarReadyPane:__init()
	local ui=UIPackage.CreateObject("Duhufu","WarReadyPane")
	self.ui = ui
	self.t1 = ui:GetChild("t1")
	self.t2 = ui:GetChild("t2")
	self.t3 = ui:GetChild("t3")
	self.b1 = ui:GetChild("b1")
	self.b2 = ui:GetChild("b2")
	self.b3 = ui:GetChild("b3")
	self.b4 = ui:GetChild("b4")
	self.close=ui:GetChild("close")
	self:Layout()
	self:InitEvent()
end
function WarReadyPane:Layout()
	local model = ClanModel:GetInstance()
	local msg = model.cityWar
	self.t1.text = msg.defendName
	self.t2.text = msg.attackName
	self.t3.text = ClanConst.warReadyTimeContent
end
function WarReadyPane:InitEvent()
	self.close.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)
	self.b4.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
		UIMgr.ShowCenterPopup(WarJieshaoPane.New(),function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(WarReadyPane.New(), nil, true)
			end, 0.1)
		end, true)
	end)
	self.b2.onClick:Add(function () --成员列表
		ClanCtrl:GetInstance():C_GetGuildFights()
	end)
	self.b3.onClick:Add(function () --联盟
		ClanCtrl:GetInstance():C_GetUnions()
	end)
	self.b1.onClick:Add(function () --进入战场
		ClanCtrl:GetInstance():C_EnterGuildFight()
	end)
end

function WarReadyPane:__delete()
end