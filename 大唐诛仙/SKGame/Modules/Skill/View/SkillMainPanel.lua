SkillMainPanel = BaseClass(CommonBackGround)

function SkillMainPanel:__init()
	self.ctrl = SkillController:GetInstance()
	self:InitEvent()
	self:Config()
end

function SkillMainPanel:Config()

	self.id = "SkillMainPanel"
	self.useFade = false
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = { 1 , 2}
	self.tabBar = {
		{label="", res0="jn01", res1="jn00", id="0", red=false },
		{label="", res0="zl01", res1="zl00", id="1", red=false }
	}

	self.defaultTabIndex = 0
	self.selectPanel = nil
	local update = true
	self.tabBarSelectCallback = function(idx, id)
		
		local cur = nil
		if id == "0" then
			self:SetTitle("技能")
			if not self.skillPanel then
				self.skillPanel = SkillPanel.New()
				self.skillPanel:SetXY(134, 106)
				self.container:AddChild(self.skillPanel.ui)
			end
			cur = self.skillPanel
		elseif id == "1" then
			self:SetTitle("注  灵")
			if not self.wakanPanel then
				self.wakanPanel = WakanController:GetInstance():GetWakanPanel()
				self.wakanPanel:SetXY(123, 104)
				--self.wakanPanel:DefaultSet()
				self.container:AddChild(self.wakanPanel.ui)
			end
			cur = self.wakanPanel
			update = false
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end

		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
				if self.isFinishLayout and update then -- 在布局完成才调用（不要让打开回调与这里一起回调）
					cur:Update() -- 更新当前面板数据（每个面板切换时更新）
				end
			end
		end
		self:SetTabarTips(id, false)
		self:CheckRedTips()
	end
end

function SkillMainPanel:InitEvent()
	self.openCallback = function ()
		if self.selectPanel then
			self.selectPanel:Update()
		end
	end

	self.closeCallback = function ()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		SkillController:GetInstance():CloseSkillBookUI()
	end

	self.handler0 = GlobalDispatcher:AddEventListener(EventName.MAINUI_RED_TIPS , function(data) self:HandleRedTips(data) end )
end

function SkillMainPanel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function SkillMainPanel:Layout()

end

function SkillMainPanel:Open(tabIdx)
	if tabIdx then
		CommonBackGround.Open(self)
		self:SetSelectTabbar(tabIdx)
	else
		self:SetSelectTabbar(SkillConst.TabType.Skill)
		CommonBackGround.Open(self)
	end
end

function SkillMainPanel:OnSkillItemClickById(skillId)
	if self.skillPanel ~=nil and skillId ~= nil then
		self.skillPanel:OnSkillItemClickById(skillId)
	end
end

function SkillMainPanel:HandleRedTips(data)
	if data then
		--data {moduleId = FunctionConst.FunEnum.skill , state = isShow})
		if data.moduleId == FunctionConst.FunEnum.skill then
			self:SetTabarTips( "0" ,  data.state)
		end
	end
end

function SkillMainPanel:CheckRedTips()
	SkillModel:GetInstance():ShowSkillRedTips()
end

function SkillMainPanel:__delete()
	if self.skillPanel then
		self.skillPanel:Destroy()
		self.skillPanel = nil
	end
	WakanController:GetInstance():DestroyWakanPanel()
end