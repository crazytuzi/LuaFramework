AwardList =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function AwardList:__init( ... )
	self.URL = "ui://ioaemb0chudki";
	self:__property(...)
	self:Config()
end

-- Set self property
function AwardList:SetProperty( ... )
	
end

-- Logic Starting
function AwardList:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

-- Register UI classes to lua
function AwardList:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Task","AwardList");
	self.list = self.ui:GetChild("list")
	self.awardItemURL = UIPackage.GetItemURL("Task" , "AwardItem")
end

-- Combining existing UI generates a class
function AwardList.Create( ui, ...)
	return AwardList.New(ui, "#", {...})
end

function AwardList:InitData()
	self.rewardList = {}
	self.UIRewardList = {}
end

function AwardList:InitUI()
end	

function AwardList:InitEvent()
end

function AwardList:SetUI(curTaskID)
	self:SetData(curTaskID)
	--self.list:RemoveChildrenToPool()
	self.list:RemoveChildren()

	for index = 1, #self.rewardList do
		local itemData = self.rewardList[index]
		if self:IsCanGet(itemData) then
			-- local item = self.list:AddItemFromPool(self.awardItemURL)
			-- local itemObj = AwardItem.Create(item)
			local oldItemObj = self:GetRewardItemByIndex(index)
			local curItemObj = {}
			if not TableIsEmpty(oldItemObj) then
				curItemObj = oldItemObj
				self.list:AddChild(curItemObj.ui)
			else
				curItemObj = PkgCell.New(self.list)
				table.insert(self.UIRewardList, curItemObj)
			end

			local itemCnt = itemData.itemCnt
			
			if TaskModel:GetInstance():IsCycleTask(curTaskID) then
				if itemData.itemType == GoodsVo.GoodType.exp then
					itemCnt = TaskModel:GetInstance():GetCycleTaskAwardExp(curTaskID , itemCnt)
				end

				if itemData.itemType == GoodsVo.GoodType.gold then
					itemCnt = TaskModel:GetInstance():GetCycleTaskAwardCoin(curTaskID , itemCnt)
				end
			end
			
			curItemObj:SetDataByCfg(itemData.itemType, itemData.itemId, itemCnt, itemData.isBinding)
			curItemObj:SetXY(0 + (index - 1) * 11, 0)
			curItemObj:OpenTips(true, false)

		end
	end
end

function AwardList:GetRewardItemByIndex(index)
	return self.UIRewardList[index] or {}
end

 function AwardList:IsCanGet(itemInfo)
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

 		if itemInfo.itemType == TaskConst.RewardItemType.Coin or itemInfo.itemType == TaskConst.RewardItemType.Experience then
 			rtnIsCanGet = true
 		end
 	end
 	--print("====== itemInfo", itemInfo.itemId, " IsCanGet = ", tostring(rtnIsCanGet))
 	return rtnIsCanGet
 end

function AwardList:SetData(curTaskID)
	if curTaskID ~= nil then
		local curTaskInfo = TaskModel:GetInstance():GetTaskDataByID(curTaskID)
		if curTaskInfo ~= nil and not TableIsEmpty(curTaskInfo) then
			self.rewardList = {}
			self.rewardList = curTaskInfo:GetRewardList()
		end
	end
end

function AwardList:DisposeUIAwardItemList()
	for index = 1, #self.UIRewardList do
		self.UIRewardList[index]:Destroy()
	end
end

function AwardList:CleanData()
	self.rewardList = {}
	self.awardItemURL = ""
	self.UIRewardList = {}
end

-- Dispose use AwardList obj:Destroy()
function AwardList:__delete()
	self:DisposeUIAwardItemList()
	self:CleanData()
	self.list = nil
end