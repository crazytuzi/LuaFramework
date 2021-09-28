TotalRechargeUI = BaseClass(LuaUI)

function TotalRechargeUI:__init( ... )
	self.URL = "ui://c76fl6zbkzve9";
	self:__property(...)
	self:Config()
end

-- Set self property
function TotalRechargeUI:SetProperty( ... )
end

-- start
function TotalRechargeUI:Config()
	self:InitData()
	self:InitEvent()
	self:InitUI()
end

-- wrap UI to lua
function TotalRechargeUI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("TotalRechargeUI","TotalRechargeUI");

	self.bgSplit = self.ui:GetChild("bgSplit")
	self.bg = self.ui:GetChild("bg")
	self.list = self.ui:GetChild("list")
	self.labelTitle = self.ui:GetChild("labelTitle")
	self.labelTotalRecharge = self.ui:GetChild("labelTotalRecharge")
	self.btnGet = self.ui:GetChild("btnGet")
	self.labelHasGet = self.ui:GetChild("labelHasGet")
	self.pkgCellRoot = self.ui:GetChild("pkgCellRoot")
	self.imgArrow = self.ui:GetChild("imgArrow")
	self.btnNext = self.ui:GetChild("btnNext")

	self.scrollPanel = self.list.scrollPane	
end

-- Combining existing UI generates a class
function TotalRechargeUI.Create( ui, ...)
	return TotalRechargeUI.New(ui, "#", {...})
end

function TotalRechargeUI:__delete()
	self:CleanEvent()
	self:CleanData()
	self:DisposeUIItemList()
	self:DisposePkgCellList()
end

function TotalRechargeUI:InitEvent()
	self.btnGet.onClick:Add(self.OnBtnGetClick , self)
	self.list.onClickItem:Add(self.OnRewardItemClick ,self)
	self.hasGetRewardHandler = self.model:AddEventListener(TotalRechargeConst.RefershTotalRechargeState ,function() 
		self:RefershTotalRechargeState()
	end)
	self.scrollPanel.onScroll:Add(self.OnPanelScroll , self)
	self.btnNext.onClick:Add(self.OnBtnNextClick , self)
end

function TotalRechargeUI:OnBtnNextClick()
	-- local firstChildIdx = self.list:GetFirstChildInView()
	-- if firstChildIdx == 0 then
	-- 	self.list:ScrollToView(4)
	-- else 
	-- 	self.list:ScrollToView(6)
	-- end

	self.scrollPanel.posX = self.scrollPanel.posX + 100
end


function TotalRechargeUI:CleanEvent()
	self.btnGet.onClick:Clear()
	self.list.onClickItem:Clear()
	self.model:RemoveEventListener(self.hasGetRewardHandler)
	self.hasGetRewardHandler = nil
end

function TotalRechargeUI:InitData()
	self.model = TotalRechargeModel:GetInstance()
	self:InitLastSelectedIndex()
	self:SetRewardData()
	self:SetTotalReCharge()
	self:SetRewardUIData()
	self:SetPkgCellData()
end


function TotalRechargeUI:SetRewardData()
	self.rewardData = self.model:GetRewardData()
end

function TotalRechargeUI:SetTotalReCharge()
	self.totalRecharge = self.model:GetTotalRechargeData()
end

function TotalRechargeUI:SetRewardUIData()
	self.rewardItemList = {}
end

function TotalRechargeUI:SetPkgCellData()
	self.pkgCellList = {}
end

function TotalRechargeUI:InitLastSelectedIndex()
	self.lastSelectedIndex = -1
end

function TotalRechargeUI:CleanData()
	self.rewardData = nil
	self.totalRecharge = nil
	self.model = nil
	self.lastSelectedIndex = -1
end

function TotalRechargeUI:InitUI()
	self:InitRewardUI()
	self:InitCurRechargeRewardStateUI()
end

function TotalRechargeUI:InitRewardUI()
	self:DisposeUIItemList()
	for index = 1 , #self.rewardData do
		local curRewardData = self.rewardData[index]
		if curRewardData then
			local rewardItemUI = TotalRechargeItem.New()
			rewardItemUI:SetData(curRewardData)
			rewardItemUI:SetUI()
			rewardItemUI:SetEffect()
			self.list:AddChild(rewardItemUI.ui)
			table.insert(self.rewardItemList , rewardItemUI)
		end
	end

	if #self.rewardItemList >= TotalRechargeConst.TotalRechargeItemCfg.index then

		self:SetRewardItemY(TotalRechargeConst.TotalRechargeItemCfg.index , TotalRechargeConst.TotalRechargeItemCfg.YPos)
	end

	self:InitChargeItemEffectUI()
end

function TotalRechargeUI:DisposeUIItemList()
	for index = 1, #self.rewardItemList do
		self.rewardItemList[index]:Destroy()
		self.rewardItemList[index] = nil
	end
	self.rewardItemList = {}
end

function TotalRechargeUI:InitCurRechargeRewardStateUI()
	if self.lastSelectedIndex == -1 then
		self.list.selectedIndex = 0
		self.lastSelectedIndex = 0
		self:SetPkgCellList()
		self:SetCurRechargeRewardStateUI()
	end
end

function TotalRechargeUI:SetCurRechargeRewardStateUI()
	local curRewardData = self.rewardData[self.lastSelectedIndex + 1] or nil
	if curRewardData then
		self.labelTotalRecharge.text = StringFormat("({0}/{1})" , self.totalRecharge , curRewardData.condition)

		self.labelHasGet.visible = false
		self.btnGet.visible = true
		if curRewardData.state == TotalRechargeConst.RewardState.CanGet then
			-- self.btnGet.touchable = true
			-- self.btnGet.alpha = 1
			self.btnGet.enabled = true
		elseif curRewardData.state == TotalRechargeConst.RewardState.HasGet then
			self.labelHasGet.visible = true
			self.btnGet.visible = false
		elseif curRewardData.state == TotalRechargeConst.RewardState.CannotGet then
			-- self.btnGet.touchable = false
			-- self.btnGet.alpha = 0.5
			self.btnGet.enabled = false
		elseif curRewardData.state == TotalRechargeConst.RewardState.None then
			-- self.btnGet.touchable = false
			-- self.btnGet.alpha = 0.5
			self.btnGet.enabled = false
		end
	end
end

function TotalRechargeUI:SetTotalReChargeItemEffect()
	for index = 1, #self.rewardItemList do
		self.rewardItemList[index]:SetEffect()
	end					
end

function TotalRechargeUI:InitChargeItemEffectUI()
	for index = 1, #self.rewardItemList do
		if index > 4 then
			self.rewardItemList[index]:SetEffectVisible(false)
		else
			self.rewardItemList[index]:SetEffectVisible(true)
		end
	end	
end

function TotalRechargeUI:SetPkgCellList()
	self:DisposePkgCellList()
	local curRewardData = self.rewardData[self.lastSelectedIndex + 1] or nil
	if curRewardData then
		local rewardItems = self.model:GetRewardItemsData(curRewardData.id or 0)
		if #rewardItems > 0 then
			for itemIndex = 1 , #rewardItems do
				local pkgCell = PkgCell.New(self.pkgCellRoot)
				pkgCell:SetDataByCfg(rewardItems[itemIndex][1] or 0 , rewardItems[itemIndex][2] or 0, rewardItems[itemIndex][3] or 0, rewardItems[itemIndex][4] or 0)
				pkgCell:OpenTips(true , false)
				table.insert(self.pkgCellList , pkgCell)
			end
		end
	end
end

function TotalRechargeUI:DisposePkgCellList()
	for index = 1, #self.pkgCellList do
		self.pkgCellList[index]:Destroy()
		self.pkgCellList[index] = nil
	end
	self.pkgCellList = {}
end

function TotalRechargeUI:OnBtnGetClick()
	local curRewardData = self.rewardData[self.lastSelectedIndex + 1] or nil
	if curRewardData then
		TotalRechargeController:GetInstance():C_GetTotalRrechargeReward(curRewardData.id)
	end
end

function TotalRechargeUI:OnRewardItemClick(e)
	if self.lastSelectedIndex ~= self.list.selectedIndex then
		self.lastSelectedIndex = self.list.selectedIndex
	end
	self:SetPkgCellList()
	self:SetCurRechargeRewardStateUI()
end

function TotalRechargeUI:RefershTotalRechargeState()
	self:SetRewardData()
	self:SetTotalReCharge()
	self:SetCurRechargeRewardStateUI()
	self:SetTotalReChargeItemEffect()
end

function TotalRechargeUI:SetRewardItemY(index , y)
	if self.rewardItemList[index] then
		self.rewardItemList[index]:SetY(y)
	end
end

function TotalRechargeUI:OnPanelScroll()
	if self.rewardItemList[1] then
		if  self.scrollPanel.scrollingPosX > 28 then
			self.rewardItemList[1]:SetEffectVisible(false)
		else
			self.rewardItemList[1]:SetEffectVisible(true)
		end
	end

	if self.rewardItemList[2] then
		if self.scrollPanel.scrollingPosX > 288 then
			self.rewardItemList[2]:SetEffectVisible(false)
		else
			self.rewardItemList[2]:SetEffectVisible(true)
		end
	end

	if self.rewardItemList[3] then
		if self.scrollPanel.scrollingPosX > 503 then
			self.rewardItemList[3]:SetEffectVisible(false)
		else
			self.rewardItemList[3]:SetEffectVisible(true)
		end
	end

	if self.rewardItemList[4] then
		if self.scrollPanel.scrollingPosX >= 0 then
			self.rewardItemList[4]:SetEffectVisible(true)
		elseif self.scrollPanel.scrollingPosX >= 688 then 
			self.rewardItemList[4]:SetEffectVisible(false)
		end
	end
	if self.rewardItemList[5] then
		if self.scrollPanel.scrollingPosX >= 245 then
			self.rewardItemList[5]:SetEffectVisible(true)
		else
			self.rewardItemList[5]:SetEffectVisible(false)
		end
	end

	if self.rewardItemList[6] then
		if self.scrollPanel.scrollingPosX >= 463 then
			self.rewardItemList[6]:SetEffectVisible(true)
		else
			self.rewardItemList[6]:SetEffectVisible(false)
		end
	end

	if self.rewardItemList[#self.rewardItemList] then
		if self.scrollPanel.scrollingPosX < 660 then
			self.rewardItemList[#self.rewardItemList]:SetEffectVisible(false)
		else
			self.rewardItemList[#self.rewardItemList]:SetEffectVisible(true)
		end
	end


end