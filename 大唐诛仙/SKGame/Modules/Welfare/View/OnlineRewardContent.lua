OnlineRewardContent = BaseClass(LuaUI)
function OnlineRewardContent:__init(...)
	self.URL = "ui://g35bobp2l1qp9";
	self:__property(...)
	self:Config()
end

function OnlineRewardContent:SetProperty(...)
	
end

function OnlineRewardContent:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function OnlineRewardContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","OnlineRewardContent");

	self.loaderBG = self.ui:GetChild("loaderBG")
	self.titleTime = self.ui:GetChild("titleTime")
	self.imgSplit = self.ui:GetChild("imgSplit")
	self.imgList = self.ui:GetChild("imgList")
	self.list = self.ui:GetChild("list")
end

function OnlineRewardContent.Create(ui, ...)
	return OnlineRewardContent.New(ui, "#", {...})
end

function OnlineRewardContent:__delete()
	self:CleanData()
	self:DisposeRewardItemUIList()
	self:RemoveTimer()
	self.onlineTime = 0
end

function OnlineRewardContent:RemoveTimer()
	RenderMgr.Remove(self.onlineRewardTimeKey)
end

function OnlineRewardContent:InitEvent()
	self.list.onClickItem:Add( self.OnOnlineRewardItemClick, self)
end

function OnlineRewardContent:InitUI()
	self.titleTime.text = ""
	self.list:RemoveChildrenToPool()

end

function OnlineRewardContent:InitData()
	self.onlineRewardData = {}
	self.onlineRewardItemURL = UIPackage.GetItemURL("Welfare", "OnlineRewardItem")
	self.rewardItemUIList = {}
	self.onlineRewardTimeKey = "onlineRewardTimeKey"
	self.onlineTime = 0
	self.lastSelectedIndex = -1
end

function OnlineRewardContent:SetUI()
	
end

function OnlineRewardContent:RefershData()
	WelfareController:GetInstance():C_GetRewardList()
end

function OnlineRewardContent:RefershUI()
	self:SetData()
	self.list:RemoveChildrenToPool()
	self:CleanAllEvent()
	self.rewardItemUIList = {}

	for k , v in pairs(self.onlineRewardData) do

		local curItemData = self.onlineRewardData[k]
		local item = self.list:AddItemFromPool(self.onlineRewardItemURL)
		local rewardItem = OnlineRewardItem.Create(item, curItemData)
		rewardItem:SetData(curItemData)
		rewardItem:SetUI()
		table.insert(self.rewardItemUIList, rewardItem)	
	end
	self:RefershTimeUI()
end

function OnlineRewardContent:SetData()
	self.onlineRewardData = WelfareModel:GetInstance():GetOnlineRewardData()
	self.onlineTime = WelfareModel:GetInstance():GetOnlineTime()
end

function OnlineRewardContent:RefershTimeUI()
	RenderMgr.Add(function() 
		self:SetTimeUI()
		local welfarePanel = WelfareController:GetInstance():GetWelfarePanel()
		if welfarePanel then
			welfarePanel:ShowOnlineRewardRedTips()
		end
	end, self.onlineRewardTimeKey)
end

function OnlineRewardContent:SetTimeUI()
	self.onlineTime = self.onlineTime  + Time.deltaTime
	
	local strFormatStr = GetTimeStr(math.floor(self.onlineTime))
	
	self.titleTime.text = StringFormat("今日累积在线：{0}", strFormatStr)

	self:RefershStateUIByTime()
end

function OnlineRewardContent:DisposeRewardItemUIList()
	for index = 1, #self.rewardItemUIList do
		if self.rewardItemUIList[index] then
			self.rewardItemUIList[index]:Destroy()
		end
	end
end

function OnlineRewardContent:CleanData()
	self.onlineRewardData = {}
	self.onlineRewardItemURL = ""

end

function OnlineRewardContent:CleanAllEvent()
	for index = 1, #self.rewardItemUIList do
		if self.rewardItemUIList[index] then
			self.rewardItemUIList[index]:CleanEvent()
		end
	end
end

function OnlineRewardContent:OnOnlineRewardItemClick(e)
	
	if self.lastSelectedIndex ~= self.list.selectedIndex then
		self.lastSelectedIndex = self.list.selectedIndex
		
	end
end

function OnlineRewardContent:RefershStateUI(rewardId)
	if rewardId then
		local idx = WelfareModel:GetInstance():GetIndexByRewardId(rewardId)
		if idx ~= 0 and self.onlineRewardData[idx] then
			local newItemData = WelfareModel:GetInstance():GetOnlineRewardDataById(rewardId)
			if not TableIsEmpty(newItemData) then
				if  self.onlineRewardData[idx].state ~= newItemData.state then
					self.onlineRewardData[idx].state = newItemData.state
				end
			end
		end

		local itemObj = self:GetOnlineRewardItem(rewardId)
		local itemData = self.onlineRewardData[idx]
		if (not TableIsEmpty(itemObj)) and (not TableIsEmpty(itemData)) then
			itemObj:SetData(itemData)
			itemObj:SetStateUI()
		end
	end
end

function OnlineRewardContent:RefershStateUIByTime()
	local onlineRewardData = WelfareModel:GetInstance():GetOnlineRewardData()
	for index = 1, #onlineRewardData do
		local curRewardData = onlineRewardData[index]
		if curRewardData.state == WelfareConst.OnlineRewardState.CannotGet then
			local rewardCfg = WelfareModel:GetInstance():GetOnlineRewradCfgById(curRewardData.id)
			if not TableIsEmpty(rewardCfg) then
				if rewardCfg.condition < (self.onlineTime / 60) then
					
					curRewardData.state = WelfareConst.OnlineRewardState.CanGet
					local itemObj = self:GetOnlineRewardItem(curRewardData.id)
					if (not TableIsEmpty(itemObj)) then
						itemObj:SetData(curRewardData)
						itemObj:SetStateUI()
					end
				end
			end
		end
	end
end

function OnlineRewardContent:GetOnlineRewardItem(id)
	local rewardItemObj = {}
	if id then
		for index = 1, #self.rewardItemUIList do
			local curItemObj = self.rewardItemUIList[index]
			if curItemObj then
				local curItemData = curItemObj:GetData()
				if not TableIsEmpty(curItemData) and curItemData.id == id then
					rewardItemObj =  curItemObj
					break
				end
			end
		end
	end
	return rewardItemObj
end