NewbieGuidePanel = BaseClass(LuaUI)
function NewbieGuidePanel:__init( ... )
	self.ui = UIPackage.CreateObject("NewbieGuide","NewbieGuidePanel")
	self.topGraph = self.ui:GetChild("topGraph")
	self.leftGraph = self.ui:GetChild("leftGraph")
	self.rightGraph = self.ui:GetChild("rightGraph")
	self.bottomGraph = self.ui:GetChild("bottomGraph")
	self.circleGraph = self.ui:GetChild("circleGraph")
	self.circleEffectRoot = self.ui:GetChild("circleEffectRoot")
	self.arrowEffectRoot = self.ui:GetChild("arrowEffectRoot")
	self:Config()
end

-- start
function NewbieGuidePanel:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function NewbieGuidePanel:__delete()
	self:CleanEvent()
	self:CleanUI()
end

function NewbieGuidePanel:InitData()
	self.circleMaskEffectObj = nil
	self.arrowEffectObj = nil
	self.model = NewbieGuideModel:GetInstance()
	self:SetGuideData()
	self.onUIClickCnt = 0
	self.delayKey = "NewbieGuidePanel.SkipCurGuideStep"
end

function NewbieGuidePanel:SetGuideData()
	self.curGuideData = self.model:GetCurGuideData()
	local param = self.model:GetCurGuideStepParam()
	self.curGuideUIPos = Vector3.New(param[1] or 0 , param[2] or 0 , 0)
	self.curClickRange = param[3] or 0 --当前可点击范围（正方形，最大边长110）

end

function NewbieGuidePanel:SetGuideArrow()
	self:LoadArrowEffect()
	if self.curClickRange then
		self.circleGraph:SetXY(self.curGuideUIPos.x - 0.5 * self.curClickRange , (self.curGuideUIPos.y + 0.5 * self.curClickRange) * -1)
	end
end

function NewbieGuidePanel:CleanData()
	self.circleMaskEffectObj = nil
	self.arrowEffectObj = nil
	self.model = nil
	self.curGuideData = nil
end

function NewbieGuidePanel:InitUI()
	self.circleGraph.visible = NewbieGuideConst.ShowClickRange
	self:SetClickRange()
	self:SetGuideArrow()
end

function NewbieGuidePanel:CleanUI()

end

function NewbieGuidePanel:InitEvent()
	self.ui.onClick:Add(self.OnUIClick , self)
	self.ui.onTouchBegin:Add(self.onUITouchBeginCallback , self)
	self.ui.onTouchEnd:Add(self.onUITouchEndCallback , self)
	self.handler0 = self.model:AddEventListener(NewbieGuideConst.RefershEvent , function ()
		self:RefershGuide()
	end)
end

function NewbieGuidePanel:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
end

function NewbieGuidePanel:RefershGuide()
	self:SetGuideData()
	self:SetGuideArrow()
	self:SetClickRange()
end

function NewbieGuidePanel:OnUIClick(e)
	self:LoadCircleEffect()
end

function NewbieGuidePanel:onUITouchBeginCallback()
	RenderMgr.Realse(self.delayKey)
	self.onUIClickCnt = self.onUIClickCnt + 1
	if self.onUIClickCnt > 4 then
		self.onUIClickCnt = 0
		self:SkipCurGuideStep()
	end
end

function NewbieGuidePanel:onUITouchEndCallback()
	DelayCallWithKey(function()  self.onUIClickCnt = 0 end , 0.5 , self.delayKey)
end

--加载黑幕圆圈引导特效
function NewbieGuidePanel:LoadCircleEffect()
	local function loadCallBack(effect)
		if effect then
			if self.circleMaskEffectObj ~= nil then
				destroyImmediate(self.circleMaskEffectObj)
				self.circleMaskEffectObj = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			local tf = effectObj.transform
			tf.localPosition = self.curGuideUIPos or Vector3.New(0 , 0 , 0)
			tf.localScale = Vector3.New(1 , 1 , 1)
			tf.localRotation =  Quaternion.Euler(0, 0, 0)
			self.circleEffectRoot:SetNativeObject(GoWrapper.New(effectObj))
			self.circleMaskEffectObj = effectObj
		end
	end
	LoadEffect("ui_xinshouzhiyin_dc_heimu" , loadCallBack)
end

--加载箭头引导特效
function NewbieGuidePanel:LoadArrowEffect()
	local function loadCallBack(effect)
		if effect then
			if self.arrowEffectObj ~= nil then
				destroyImmediate(self.arrowEffectObj)
				self.arrowEffectObj = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			local tf = effectObj.transform
			tf.localPosition = self.curGuideUIPos or Vector3.New(0 , 0 , 0)
			tf.localScale =	Vector3.New(1 , 1 , 1)
			tf.localRotation = Quaternion.New(0 , 0 , 0)
			self.arrowEffectRoot:SetNativeObject(GoWrapper.New(effectObj))
			self.arrowEffectObj = effectObj
		end
	end
	LoadEffect("ui_xinshouzhiyin_dc" , loadCallBack)
end


--自动化点击范围
function NewbieGuidePanel:SetClickRange()
	if self.curClickRange then
		self.circleGraph:SetSize(self.curClickRange, self.curClickRange)
	end
end

--避免由于未考虑到的意外情况而导致引导卡死。提供连续点击5次，直接跳过当前引导的机制
function NewbieGuidePanel:SkipCurGuideStep()
	NewbieGuideController:GetInstance():EndCurNewbieGuide()
end
