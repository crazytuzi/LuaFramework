TotalRechargeView = BaseClass()

function TotalRechargeView:__init()
	self:InitData()
	self:LoadUIRes()
end

function TotalRechargeView:__delete()
	self:CleanData()
end


function TotalRechargeView:InitData()
	self.isInited = false
end

function TotalRechargeView:CleanData()
	self.isInited = false
end

function TotalRechargeView:LoadUIRes()
	if self.isInited then return end
	resMgr:AddUIAB("TotalRechargeUI")
	self.isInited = true
end

