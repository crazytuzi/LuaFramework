ReLifePanel = BaseClass(LuaUI)
function ReLifePanel:__init()
	local ui = UIPackage.CreateObject("Main","ReLifePanel")
	self.ui = ui
	self.btn1 = ui:GetChild("btn1")
	self.btn2 = ui:GetChild("btn2")
	self.btn3 = ui:GetChild("btn3")
	self.desc = ui:GetChild("desc")
	self.reliftBtn = ui:GetChild("reliftBtn")
	self.reliftPanel = ui:GetChild("reliftPanel")

	self.reliftBtn:GetChild("title").text = "点击复活"
	self.reliftBtn.visible = false
	self.costId = 23001
	self.costNum = 1
	self:UpateCountInfo()
	self.btn1.onClick:Add(function()
		if self.reLiftBtnType == 1 then
			MallController:GetInstance():QuickBuy(3010, function()
				local reLifePanel = ReLifePanel.New()
				UIMgr.ShowCenterPopup(reLifePanel, function()  end)
			end)
		else
			SceneController:GetInstance():RequireRevive(2) -- 玩家复活
			UIMgr.HidePopup()
		end
	end, self)
	self.btn2.onClick:Add(function()
		self.reliftPanel.visible = false
		self.reliftBtn.visible = true
	end, self)
	self.btn3.onClick:Add(function()
		FBController:GetInstance():RequireQuitInstance()
		UIMgr.HidePopup()
	end, self)
	self.reliftBtn.onClick:Add(function()
		self.reliftPanel.visible = true
		self.reliftBtn.visible = false
	end, self)
	self.handler5 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function () self:UpateCountInfo() end)
end

function ReLifePanel:UpateCountInfo()
	local color = ""
	local v = PkgModel:GetInstance():GetTotalByBid(self.costId)
	if v >= self.costNum then
		color = "#04ce5e"
		self.reLiftBtnType = 2 --复活
	else
		color = "#ff0000"
		self.reLiftBtnType = 1 --购买
	end
	self.desc.text = StringFormat("复活消耗还魂丹({0}/[color={1}]{2}[/color])个", self.costNum, color, v)
end


function ReLifePanel:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler5)
end