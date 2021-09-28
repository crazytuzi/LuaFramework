ShenJingPanel =BaseClass(BaseView)
function ShenJingPanel:__init( ... )
	self.URL = "ui://ny6nt56pez9z3"
	self.ui = UIPackage.CreateObject("ShenJing","ShenJingPanel")
	self.bg = self.ui:GetChild("bg")
	self.returnBtn = self.ui:GetChild("returnBtn")
	self.btn1 = self.ui:GetChild("btn1")
	self.btn2 = self.ui:GetChild("btn2")
	self.btn3 = self.ui:GetChild("btn3")
	self.btn4 = self.ui:GetChild("btn4")
	self.btn5 = self.ui:GetChild("btn5")

	self:InitEvent()
	for i=1,5 do
		self["btn"..i] = InLetBtn.Create(self["btn"..i],i)
	end
end

function ShenJingPanel:InitEvent()
	self.returnBtn.onClick:Add(self.OnClickCloseBtn,self)
end

--关闭界面
function ShenJingPanel:OnClickCloseBtn()
	self:Close()
end

function ShenJingPanel:__delete()
	self.bg = nil
	for i=1,5 do
		if self["btn"..i] then 
			self["btn"..i]:Destroy()
			self["btn"..i]=nil
		end
	end
end