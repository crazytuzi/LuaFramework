ListNPCTaskReward =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ListNPCTaskReward:__init( ... )
	self.URL = "ui://y1al0f5qtjjee";
	self:__property(...)
	self:Config()
end

-- Set self property
function ListNPCTaskReward:SetProperty( ... )
	
end

-- Logic Starting
function ListNPCTaskReward:Config()
	self:InitData()
	self:InitEvent()
end

-- Register UI classes to lua
function ListNPCTaskReward:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("NPCDialog","ListNPCTaskReward");

	self.list = self.ui:GetChild("list")
	self.button_next_page = self.ui:GetChild("button_next_page")
	self.button_prev_page = self.ui:GetChild("button_prev_page")
	
end

-- Combining existing UI generates a class
function ListNPCTaskReward.Create( ui, ...)
	return ListNPCTaskReward.New(ui, "#", {...})
end

function ListNPCTaskReward:InitData()
	self.uiRewardList = {}
	self.maxItemCnt = 3
end

function ListNPCTaskReward:InitEvent()
	self.button_prev_page.onClick:Add(self.OnButtonPrevPageClick, self)
	self.button_next_page.onClick:Add(self.OnButtonNextPageClick, self)
end

function ListNPCTaskReward:SetUI(rewardList)
	self.list:RemoveChildren()

	for index = 1, #rewardList do
		local curItemInfo = rewardList[index]
		if curItemInfo.itemType ~= TaskConst.RewardItemType.Coin and curItemInfo.itemType ~= TaskConst.RewardItemType.Experience then
			if self:IsCanGet(curItemInfo) then
				local oldRewardItem = self.uiRewardList[index]
				local curRewardItem = {}
				if not TableIsEmpty(oldRewardItem) then
					curRewardItem = self.uiRewardList[index]
					self.list:AddChild(curRewardItem.ui)
				else
					curRewardItem = PkgCell.New(self.list)
					table.insert(self.uiRewardList, curRewardItem)
				end

				curRewardItem:SetDataByCfg(curItemInfo.itemType, curItemInfo.itemId, curItemInfo.itemCnt, curItemInfo.isBinding)
				curRewardItem:SetXY(36 + (index - 1) * 6, 0)
				curRewardItem:OpenTips(true, false)

				
				
			end
		end
	end

	self:SetPrevNextBtnVisible()
end

function ListNPCTaskReward:GetRewardItemByIndex(index)
	return self.uiRewardList[index] or {}
end
	
 function ListNPCTaskReward:IsCanGet(itemInfo)
 	local rtnIsCanGet = false
 	local mainPlayerData = SceneModel:GetInstance():GetMainPlayer()

 	if itemInfo then
 		if itemInfo.itemType == TaskConst.RewardItemType.Equipment then
 			local equipmentCfg = GetCfgData("Equipment"):Get(itemInfo.itemId)
 			if equipmentCfg then
 				if (mainPlayerData and mainPlayerData.career == equipmentCfg.needJob) or equipmentCfg.needJob == 0 then
 					rtnIsCanGet = true
 				end
 			end
 		end

 		if itemInfo.itemType == TaskConst.RewardItemType.Item then
 			local itemCfg = GetCfgData("Item"):Get(itemInfo.itemId)
 			if itemCfg then
 				if (mainPlayerData and mainPlayerData.career == itemCfg.needJob) or itemCfg.needJob == 0 then
 					rtnIsCanGet = true
 				end
 			end
 		end
 	end
 	--print("====== itemInfo", itemInfo.itemId, " IsCanGet = ", tostring(rtnIsCanGet))
 	return rtnIsCanGet
 end

function ListNPCTaskReward:DisposeRewardItemList()
	for index = 1, #self.uiRewardList do
		self.uiRewardList[index]:Destroy()
		self.uiRewardList[index] = nil
	end
end

function ListNPCTaskReward:CleanData()
	self.uiRewardList = {}
	self.beginIndex = -1
	self.endIndex = -1
end

function ListNPCTaskReward:SetPrevNextBtnVisible()
	local needShow = false
	if self.list.numChildren > self.maxItemCnt then
		needShow = true
		self.beginIndex = 0
		self.endIndex = 2
	end

	self.button_prev_page.visible = needShow
	self.button_next_page.visible = needShow
end

function ListNPCTaskReward:OnButtonNextPageClick()
	self.endIndex = self.endIndex + 1
	self.beginIndex = self.beginIndex + 1
	
	if 0 <= self.endIndex  and self.endIndex < self.list.numChildren then
		self.list:ScrollToView(self.endIndex)
	else
		self.endIndex = self.list.numChildren - 1
		self.beginIndex = self.endIndex - 2
	end
end

function ListNPCTaskReward:OnButtonPrevPageClick()
	self.endIndex = self.endIndex - 1
	self.beginIndex = self.beginIndex - 1

	if 0 <= self.beginIndex and self.beginIndex < self.list.numChildren then
		self.list:ScrollToView(self.beginIndex)
	else
		self.beginIndex = 0
		self.endIndex = self.beginIndex + 2
	end
end


-- Dispose use ListNPCTaskReward obj:Destroy()
function ListNPCTaskReward:__delete()
	self:DisposeRewardItemList()
	self:CleanData()
	self.list = nil
	self.button_next_page = nil
	self.button_prev_page = nil
end