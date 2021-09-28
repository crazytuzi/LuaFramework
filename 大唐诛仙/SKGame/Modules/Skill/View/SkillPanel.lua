SkillPanel = BaseClass(LuaUI)

function SkillPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Skill","SkillPanel");

	self:Layout()
end

function SkillPanel:InitEvent()
	for index = 1 , #self.uiSkillItems do
		if self.uiSkillItems[index] then
			self.uiSkillItems[index].ui.onClick:Add(function() 
				self:OnSkillItemClick(index)
			end)
		end
	end

	self.btnGoto.onClick:Add(self.OnBtnGotoClick , self)
	self.btnUpgrade.onClick:Add(self.OnBtnUpgradeClick , self)
	self.btnAddMastery.onClick:Add(self.OnBtnAddMastery , self)

	self.handler0 = GlobalDispatcher:AddEventListener(EventName.SkillUpgrade, function (  )
		self:Update()
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.SyncSkillMastery , function ()
		self:HanldeSyncSkillMastery()
	end)
end

function SkillPanel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

-- 布局UI
function SkillPanel:Layout()
	-- 以下开始UI布局
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Dispose use SkillPanel obj:Destroy()
function SkillPanel:__delete()
	self:DisposeUISkillItems()
	self:DisposeUISkillEffects()
	self:DisposeBookUI()
	self:DisposeWinConfirm()
	self:CleanEvent()
	self:CleanData()
end

function SkillPanel:InitData()
	self.uiSkillItems = {} --用来保存5个技能槽对象
	self.uiSkillEffects = {} --用来保存技能效果Item对象，依次为当前效果、下一等级效果、最高等级效果

	self.model = SkillModel:GetInstance()
	self.skillData = {} --技能信息数据

	self.lastSelectIndex = -1
	self.defaultSelectIndex = 1

	self.curSelectSkillData = {}

end

function SkillPanel:SetSkillData()
	self.skillData = self.model:GetAllSkillList()
end

function SkillPanel:UpdateCurSelectedSkill()
	if not TableIsEmpty(self.curSelectSkillData) then
		for  idx , v in pairs(self.skillData) do
			if v.skillId == self.curSelectSkillData.skillId then
				self.curSelectSkillData.mastery = v.mastery
				break
			end
		end
	end
end

function SkillPanel:CleanData()
	self.skillData = {}
	self.curSelectSkillData = {}
	self.model:CleanSelectSkillData()
	self.lastSelectIndex = -1
end

function SkillPanel:InitUI()
	self:InitChildUI()
	self:InitUISkillItems()
	self:InitUISkillEffects()
	self:InitUISkillUpgrade()
	self:InitSkillBookUI()
end

function SkillPanel:InitChildUI()
	self.imgShuye3 = self.ui:GetChild("imgShuye3")
	self.btnGoto = self.ui:GetChild("btnGoto")
	self.labelGoto = self.ui:GetChild("labelGoto")
	self.imgBgSkillItems = self.ui:GetChild("imgBgSkillItems")
	self.skillItem1 = self.ui:GetChild("skillItem1")
	self.skillItem2 = self.ui:GetChild("skillItem2")
	self.skillItem3 = self.ui:GetChild("skillItem3")
	self.skillItem4 = self.ui:GetChild("skillItem4")
	self.skillItem5 = self.ui:GetChild("skillItem5")
	self.labelTips = self.ui:GetChild("labelTips")
	self.groupLeft = self.ui:GetChild("groupLeft")
	self.imgShuye0 = self.ui:GetChild("imgShuye0")
	self.imgShuye1 = self.ui:GetChild("imgShuye1")
	self.imgFenge0 = self.ui:GetChild("imgFenge0")
	self.imgFenge1 = self.ui:GetChild("imgFenge1")
	self.labelSkillName = self.ui:GetChild("labelSkillName")
	self.labelSkillDesc = self.ui:GetChild("labelSkillDesc")
	self.imgFenge = self.ui:GetChild("imgFenge")
	self.skillEffectCur = self.ui:GetChild("skillEffectCur")
	self.imgUpgradeArrow = self.ui:GetChild("imgUpgradeArrow")
	self.skillEffectNext = self.ui:GetChild("skillEffectNext")
	self.skillEffectMax = self.ui:GetChild("skillEffectMax")
	self.labelMasteryTitle = self.ui:GetChild("labelMasteryTitle")
	self.labelMasteryValue = self.ui:GetChild("labelMasteryValue")
	self.masteryProcess = self.ui:GetChild("masteryProcess")
	self.btnAddMastery = self.ui:GetChild("btnAddMastery")
	self.upgradeConsume = self.ui:GetChild("upgradeConsume")
	self.btnUpgrade = self.ui:GetChild("btnUpgrade")
	self.groupRight = self.ui:GetChild("groupRight")
	self.labelSkillLearnTips = self.ui:GetChild("labelSkillLearnTips")

end

function SkillPanel:InitUISkillItems()
	self.uiSkillItems[1] = SkillBigItem.Create(self.skillItem1)
	self.uiSkillItems[2] = SkillItem.Create(self.skillItem2)
	self.uiSkillItems[3] = SkillItem.Create(self.skillItem3)
	self.uiSkillItems[4] = SkillItem.Create(self.skillItem4)
	self.uiSkillItems[5] = SkillItem.Create(self.skillItem5)
end

function SkillPanel:DisposeUISkillItems()
	for index = 1 , #self.uiSkillItems do
		if self.uiSkillItems[index] then
			self.uiSkillItems[index]:Destroy()
		end
	end
	self.uiSkillItems = {}
end

function SkillPanel:InitUISkillEffects()
	self.uiSkillEffects[1] = SkillEffect.Create(self.skillEffectCur) -- 当前技能效果
	self.uiSkillEffects[2] = SkillEffect.Create(self.skillEffectNext) -- 下一等级技能效果
	self.uiSkillEffects[3] = SkillEffect.Create(self.skillEffectMax) -- 最大等级技能效果
	self.uiSkillEffects[1]:SetTitle("当前效果")
	self.uiSkillEffects[2]:SetTitle("下级效果")
	self.uiSkillEffects[3]:SetTitle("已达当前等级上限")
	self.uiSkillEffects[1]:SetEffectType(SkillConst.SkillEffectType.CurLev)
	self.uiSkillEffects[2]:SetEffectType(SkillConst.SkillEffectType.NextLev)
	self.uiSkillEffects[3]:SetEffectType(SkillConst.SkillEffectType.MaxLev)

	for index = 1 , 3 do
		self.uiSkillEffects[index]:SetVisible(false)
	end
end

function SkillPanel:DisposeUISkillEffects()
	for index = 1 , #self.uiSkillEffects do
		if self.uiSkillEffects[index] then
			self.uiSkillEffects[index]:Destroy()
		end
	end
	self.uiSkillEffects = {}
end

function SkillPanel:DisposeBookUI()
	if self.skillBookUI then
		self.skillBookUI:Destroy()
		self.skillBookUI = nil
	end
end

function SkillPanel:DisposeWinConfirm()
	if self.winConfirmBuySkilBook ~= nil then
		self.winConfirmBuySkilBook:Destroy()
		self.winConfirmBuySkilBook = nil
	end
end

function SkillPanel:InitUISkillUpgrade()
	self.upgradeConsume = SkillUpgradeConsume.Create(self.upgradeConsume)

end

function SkillPanel:InitSkillBookUI()
	if NewbieGuideModel:GetInstance():IsHasSkillUpgradeGuide() then
		if not self.skillBookUI then
			self.skillBookUI = SkillBook.New()
			self.skillBookUI:SetXY(self.btnAddMastery.x - self.skillBookUI.ui.width , (self.btnAddMastery.y - self.skillBookUI.ui.height))
			self.ui:AddChild(self.skillBookUI.ui)
			self.skillBookUI.ui.visible = false
		end
	end
end

function SkillPanel:Update()
	self:UpdateData()
	self:UpdateUI()
end

function SkillPanel:HanldeSyncSkillMastery()
	self:UpdateData()
	--self:UpdateCurSelectedSkill()
	self:SetCurSelectSkillData()
	self:SetSKillItemsUI()
	self:SetMasteryProcessUI()
	self:SetUpgradeBtnUI()
	self:SetSkillLearnTips()
	self.model:SetSelectSkillData(self.curSelectSkillData)
end

function SkillPanel:UpdateData()
	self:SetSkillData()
end

function SkillPanel:UpdateUI()
	self:SetSKillItemsUI()
	if self.lastSelectIndex == -1  then
		self:SetDefaultSelectSkillUI()
	else
		self:SetCurSelectSkillData()
		self:SetSkillDescUI()
		self:SetSkillEffectUI()
		self:SetMasteryProcessUI()
		self:SetUpgradeBtnUI()
		self:SetSkillLearnTips()
		self.model:SetSelectSkillData(self.curSelectSkillData)
	end
end

function SkillPanel:SetDefaultSelectSkillUI()
	self:OnSkillItemClick(self.defaultSelectIndex)
end

function SkillPanel:OnSkillItemClick(targetIndex)
	for index = 1, #self.uiSkillItems do
		if targetIndex and self.uiSkillItems[targetIndex] and index == targetIndex then
			self.uiSkillItems[index]:SetSelectUI(true)
		else
			self.uiSkillItems[index]:SetSelectUI(false)
		end
	end

	if self.lastSelectIndex ~= targetIndex  then
		self.lastSelectIndex = targetIndex
		self:SetCurSelectSkillData()
		self:SetSkillDescUI()
		self:SetSkillEffectUI()
		self:SetMasteryProcessUI()
		self:SetUpgradeBtnUI()
		self:SetSkillLearnTips()
		self.model:SetSelectSkillData(self.curSelectSkillData)
	end

	if self.lastSelectIndex == 2 then
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function SkillPanel:OnBtnGotoClick()
	GodFightRuneController:GetInstance():OpenGodFightRunePanel()
end

function SkillPanel:OnBtnUpgradeClick()
	if not TableIsEmpty(self.curSelectSkillData) then
		if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
			UIMgr.Win_FloatTip("该技能已升到最高级！")
			return
		end

		if self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and  self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false then
			SkillController:GetInstance():C_CreatePlayerSkill(self.curSelectSkillData.skillId)
			return
		end

		if self.model:IsEnoughLevelToUpgrade(self.curSelectSkillData.skillId) == true then
			self.model:SetPreviousLevSkillId(self.curSelectSkillData.skillId)
			local skillId = self.model:GetSkillIdById(self.curSelectSkillData.skillId) --铭文技能、非铭文技能，都是发送对应的技能
			SkillController:GetInstance():C_UpgradePlayerSkill(skillId)
		else
			if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == false then
				UIMgr.Win_FloatTip("等级不足")
			end
		end

		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function SkillPanel:OnBtnAddMastery()
	if not TableIsEmpty(self.curSelectSkillData) and self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
		UIMgr.Win_FloatTip("该技能已升到最高级！")
		return
	end

	if self.model:IsEmptySkillBook() then
		self.winConfirmBuySkilBook =  UIMgr.Win_Confirm("温馨提示", "技能书不足，是否前往购买？", "确定", "取消", function()--确定
			MallController:GetInstance():OpenMallPanel(nil, 0, 2) 
			self.winConfirmBuySkilBook = nil
		end,
		function()	--取消
			self.winConfirmBuySkilBook = nil
		end)
	else
		if NewbieGuideModel:GetInstance():IsHasSkillUpgradeGuide() == true then
			if self.skillBookUI then
				self.skillBookUI.ui.visible = not self.skillBookUI.ui.visible
			end			
		else
			SkillController:GetInstance():OpenSkillBookUI()
		end
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end

end

function SkillPanel:SetCurSelectSkillData()
	if self.lastSelectIndex ~= -1 and self.skillData[self.lastSelectIndex] ~= nil then
		self.curSelectSkillData = self.skillData[self.lastSelectIndex]
	end
end

--设置左侧技能按钮UI表现
function SkillPanel:SetSKillItemsUI()
	for uiIndex = 1 , #self.uiSkillItems do
		for dataIndex = 1 , #self.skillData do
			local curSkillData = self.skillData[dataIndex]
			if not TableIsEmpty(curSkillData) and curSkillData.skillIndex == uiIndex then
				local curUISkillItem = self.uiSkillItems[uiIndex]
				curUISkillItem:SetData(curSkillData)
				curUISkillItem:SetUI()
				curUISkillItem:SetEffect()
				break
			end
		end
	end
end

--设置技能基本描述信息表现UI
function SkillPanel:SetSkillDescUI( )
	if not TableIsEmpty(self.curSelectSkillData) then
		self.labelSkillName.text = self.curSelectSkillData.name
		self.labelSkillDesc.text = self.curSelectSkillData.des

		if (self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false) or 
			(self.model:IsHasSkill(self.curSelectSkillData.skillId) == false) then
	
			self.upgradeConsume:SetUI("gold" , self.model:GetNeedMoney(self.curSelectSkillData.skillId))
		else

			self.upgradeConsume:SetUI("gold" , self.curSelectSkillData.needMoney)
		end

		if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
			self.upgradeConsume:SetVisible(false)
		else
			self.upgradeConsume:SetVisible(true)
		end
	end
end

--设置技能升级效果表现UI
function SkillPanel:SetSkillEffectUI()
	if not TableIsEmpty(self.curSelectSkillData) then
		--当前技能是否学习、或者没有激活
		if (self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false) or
			(self.model:IsHasSkill(self.curSelectSkillData.skillId) == false) then
			local isLearn = true
			self.uiSkillEffects[3]:SetVisible(false)
			self.uiSkillEffects[1]:SetData(self.curSelectSkillData , isLearn)
			self.uiSkillEffects[1]:SetUI()
			self.uiSkillEffects[2]:SetData(self.curSelectSkillData)
			self.uiSkillEffects[2]:SetUI()
			self.uiSkillEffects[1]:SetVisible(true)
			self.uiSkillEffects[2]:SetVisible(true)
			self:SetUpgradeEffectArrow(true)
			return
		end

		--当前技能是否已达最大等级
		local isMaxLev = self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) --该技能是否满级
		if isMaxLev then
			self.uiSkillEffects[1]:SetVisible(false)
			self.uiSkillEffects[2]:SetVisible(false)
			self.uiSkillEffects[3]:SetVisible(true)
			self.uiSkillEffects[3]:SetData(self.curSelectSkillData , nil)
			self.uiSkillEffects[3]:SetUI()
			self:SetUpgradeEffectArrow(false)
		else
			local nextLevSkillData = self.model:GetNextLevSkillData(self.curSelectSkillData.skillId)
			if not TableIsEmpty(nextLevSkillData) then
				self.uiSkillEffects[1]:SetData(self.curSelectSkillData , nil)
				self.uiSkillEffects[1]:SetUI()
				self.uiSkillEffects[1]:SetVisible(true)
				self.uiSkillEffects[2]:SetData(nextLevSkillData , nil)
				self.uiSkillEffects[2]:SetUI()
				self.uiSkillEffects[2]:SetVisible(true)
				self.uiSkillEffects[3]:SetVisible(false)
				self:SetUpgradeEffectArrow(true)
			end	
		end

	end
end

--设置技能熟练度进度条值
function SkillPanel:SetMasteryProcessUI()
	if not TableIsEmpty(self.curSelectSkillData) then
		local needMastery = 0
		if (self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false) or 
			(self.model:IsHasSkill(self.curSelectSkillData.skillId) == false) then
			
			needMastery = self.model:GetNeedMastery(self.curSelectSkillData.skillId)
		else
			
			needMastery = self.curSelectSkillData.needMastery
		end


		local masteryRate = (self.curSelectSkillData.mastery / needMastery) * 100
		self.masteryProcess.value = masteryRate
		
		self.labelMasteryValue.text = StringFormat("{0}/{1}" , self.curSelectSkillData.mastery , needMastery)

		-- if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
		-- 	self.masteryProcess.value = 100
		-- 	self:SetMasteryTitleVisible(false)
		-- else
		-- 	self:SetMasteryTitleVisible(true)
		-- end

		if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
			self.labelMasteryValue.text = StringFormat("{0}/{1}" , self.curSelectSkillData.mastery , '--')
		end
	end
end

function SkillPanel:SetMasteryTitleVisible(bl)
	if bl ~= nil then
		self.labelMasteryValue.visible = bl
		self.labelMasteryTitle.visible = bl
	end
end

--设置升级效果箭头显示
function SkillPanel:SetUpgradeEffectArrow(isVisible)
	self.imgUpgradeArrow.visible = isVisible
end


--默认选中某个SkillId
function SkillPanel:OnSkillItemClickById(skillId)
	if skillId then
		local skillIndex = self.model:GetAllSkillListIndexById(skillId)
		if skillIndex ~= -1 and skillIndex <= #self.uiSkillItems then
			self:OnSkillItemClick(skillIndex)
		end
	end
end

--设置升级按钮UI
function SkillPanel:SetUpgradeBtnUI()
	if (self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false) or 
			(self.model:IsHasSkill(self.curSelectSkillData.skillId) == false) then
			self.btnUpgrade.title = StringFormat("{0}" , "学习")
			self.btnUpgrade.enabled = true
	else
		local masteryRate = (self.curSelectSkillData.mastery / self.curSelectSkillData.needMastery) * 100
		local strTitle = ""
		local enabled = true
		-- 等级和熟练度都没达到：显示*等级可升级
		-- 等级达到，熟练度不够：显示熟练度不足
		-- 等级没达到，熟练度达到：显示*等级可升级
		-- 都达到：升级
		local levelEnough = self.model:IsEnoughLevelToUpgrade(self.curSelectSkillData.skillId)
		local masteryEnough = (masteryRate >= 100)
		if levelEnough == false and masteryEnough == false then
			enabled = false
			strTitle = StringFormat("{0}{1}" , self.curSelectSkillData.needLevel , "级可升级")
		end

		if levelEnough == true and masteryEnough == false then
			enabled = false
			strTitle = StringFormat("{0}" , "熟练度不足")
		end

		if levelEnough == false and masteryEnough == true then
			enabled = false
			strTitle = StringFormat("{0}{1}" , self.curSelectSkillData.needLevel , "级可升级")
		end

		if levelEnough == true and masteryEnough == true then 
			enabled = true
			strTitle = StringFormat("{0}" , "升级")
		end

		self.btnUpgrade.enabled = enabled
		self.btnUpgrade.title = strTitle

		if self.model:IsMaxSkillLev(self.curSelectSkillData.skillId) == true then
			self.btnUpgrade.title = StringFormat("{0}" , "已满级")
		end
	end
end

function SkillPanel:SetSkillLearnTips()
	if (self.curSelectSkillData.skillId == self.model:GetCurLearnSkillId() and self.model:IsSkillIndexActive(self.curSelectSkillData.skillId) == false) or 
			(self.model:IsHasSkill(self.curSelectSkillData.skillId) == false) then
			local skillIndex = self.model:GetSkillIndexById(self.curSelectSkillData.skillId)
			if skillIndex ~= -1 then
				self.labelSkillLearnTips.text = SkillConst.SkillLearnTips[skillIndex] or ""
			end
	else
		self.labelSkillLearnTips.text = ""
	end
end