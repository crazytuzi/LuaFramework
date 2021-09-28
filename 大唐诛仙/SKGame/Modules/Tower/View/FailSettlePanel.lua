FailSettlePanel =BaseClass(BaseView)

-- (Constructor) use FailSettlePanel.New(...)
function FailSettlePanel:__init( ... )
	self.URL = "ui://jf5x839xhovh11";

	self.ui = UIPackage.CreateObject("Tower","FailSettlePanel")
	
	self.bg = self.ui:GetChild("bg")
	self.QuiteBtn = self.ui:GetChild("QuiteBtn")
	self.bg1 = self.ui:GetChild("bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.FailShowLevel = self.ui:GetChild("FailShowLevel")
	self.NextBtn = self.ui:GetChild("NextBtn")

	self:InitEvent()

	self.renderStr = "VictorySettlePanel:CountDown"
end

function FailSettlePanel:InitEvent()
	self.closeCallback = function () end
	self.openCallback  = function () 
		local curLevel = TowerModel:GetInstance().curLevel
		self.FailShowLevel:GetChild("title").text = StringFormat("第{0}层",curLevel)
	end
	self.QuiteBtn.onClick:Add(self.OnClickQuiteBtn,self)
	self.NextBtn.onClick:Add(self.OnClickNextBtn, self)
end

function FailSettlePanel:Open()
	BaseView.Open(self)
	self.leftTime = 5
	RenderMgr.Add(function () self:CountDown() end, self.renderStr)
end

function FailSettlePanel:CountDown()
	self.NextBtn:GetChild("title").text = StringFormat("({0})回到第{1}层", math.ceil(self.leftTime), math.max(TowerModel:GetInstance().curLevel - 2, 1))
	self.leftTime = self.leftTime - Time.deltaTime
	if self.leftTime <= 0 then
		RenderMgr.Realse(self.renderStr)
		self:OnClickNextBtn()
	end
end

--退出大荒塔
function FailSettlePanel:OnClickQuiteBtn()
	TowerController:GetInstance():RequireQuiteTower()
end

--进入下一层
function FailSettlePanel:OnClickNextBtn()
	TowerController:GetInstance():RequireEnterTower()
end

-- Dispose use FailSettlePanel obj:Destroy()
function FailSettlePanel:__delete()
	RenderMgr.Realse(self.renderStr)
	self.bg = nil
	self.QuiteBtn = nil
	self.bg1 = nil
	self.bg2 = nil
	self.FailShowLevel = nil
	self.NextBtn = nil
	if self.ui then
		self.ui:Dispose()
	end
	self.ui = nil
end