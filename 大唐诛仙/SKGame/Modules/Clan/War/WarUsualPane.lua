WarUsualPane = BaseClass(LuaUI)
function WarUsualPane:__init()
	local ui = UIPackage.CreateObject("Duhufu","WarUsualPane")
	self.ui = ui
	self.t1 = ui:GetChild("t1")
	self.t2 = ui:GetChild("t2")
	self.t3 = ui:GetChild("t3")
	self.b4 = ui:GetChild("b4")
	self.close = ui:GetChild("close")
	self:Layout()
	self:InitEvent()
end
function WarUsualPane:Layout()
	local model = ClanModel:GetInstance()
	local msg = model.cityWar
	self.t1.text = msg.defendName
	self.t2.text = msg.attackName
	self.t3.text = ClanConst.warUsualTimeContent
end
function WarUsualPane:InitEvent()
	self.close.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)
	self.b4.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
		UIMgr.ShowCenterPopup(WarJieshaoPane.New(),function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(WarUsualPane.New(), nil, true)
			end, 0.1)
		end, true)
	end)
end

function WarUsualPane:__delete()

end