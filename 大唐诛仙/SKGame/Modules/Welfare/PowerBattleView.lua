PowerBattleView = BaseClass(LuaUI)
function PowerBattleView:__init( ... )
	self.URL = "ui://ic8go605psjw7";
	self:__property(...)
	self:Config()
end
-- Set self property
function PowerBattleView:SetProperty( ... )
end
-- start
function PowerBattleView:Config()
	self.model = PowerModel:GetInstance()
	self:InitData()
	self:AddImproveItem()
	self:RegistBtn()
end
-- wrap UI to lua
function PowerBattleView:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PowerLevelingActivitiesUI","ImproveBattleContent");

	self.list = self.ui:GetChild("list")
	self.imgSplit = self.ui:GetChild("imgSplit")
	self.daojishi = self.ui:GetChild("daojishi")
	self.daoJiTime = self.ui:GetChild("daoJiTime")
end
-- Combining existing UI generates a class
function PowerBattleView.Create( ui, ...)
	return PowerBattleView.New(ui, "#", {...})
end

function PowerBattleView:InitData()
	self.onBattleRewardTimeKey = "onBattleRewardTimeKey"
	self.daoJiTime.text =TimeTool.GetTimeDHM(self.model:GetHuoDongTime())	
	self:RefershTimeUI()
	self.ImproveData = {}
	self.ImproveItemURL = UIPackage.GetItemURL("PowerLevelingActivitiesUI", "ImproveItem")
	self.rewardImproveItemList = {}

end

function PowerBattleView:AddImproveItem()
	self:SetImproveData()
	self:CleanListEvent()
	self.list:RemoveChildrenToPool()
	self.rewardImproveItemList = {}

	for k,v in pairs(self.ImproveData) do
		local curItemData = self.ImproveData[k]
		local item = self.list:AddItemFromPool(self.ImproveItemURL)
		local rewardItem = PowerBattleItem.Create(item, curItemData)
		rewardItem:SetData(curItemData)
		rewardItem:SetStartUi()
		table.insert(self.rewardImproveItemList, rewardItem)	
	end

end

function PowerBattleView:RegistBtn()
	if self.rewardImproveItemList then
		for k,v in pairs(self.rewardImproveItemList) do
			local data = PowerModel:GetInstance():GetImproveBattleData()[k]
			self.rewardImproveItemList[k]:SetData(data)
			self.rewardImproveItemList[k]:RegistBtn()
		end
	end
end

function PowerBattleView:SetImproveData()
	self.ImproveData = PowerModel:GetInstance():GetImproveBattleData()
end

function PowerBattleView:__delete()

	RenderMgr.Realse(self.onBattleRewardTimeKey)
	self.ImproveData = {}
	self.ImproveItemURL = ""
	for i = 1, #self.rewardImproveItemList do
		if self.rewardImproveItemList[i] then
			self.rewardImproveItemList[i]:Destroy()
		end
	end
end

function PowerBattleView:RefershTimeUI()
	RenderMgr.CreateCoTimer(function() 
		self:SetTimeUI()
		--WelfareController:GetInstance():C_GetBVAwardData()
	end,20,-1,self.onBattleRewardTimeKey)
end

function PowerBattleView:SetTimeUI()
	
	--活动剩余时间
	local shengYuTime = self.model:GetHuoDongTime() 
	
	self.daoJiTime.text =shengYuTime > 0 and StringFormat("{0}",TimeTool.GetTimeDHM(shengYuTime)) or "活动已结束！"
end

function PowerBattleView:CleanListEvent()
  if self.rewardImproveItemList then
	for i= 1, #self.rewardImproveItemList do
		if self.rewardImproveItemList[i] then
			self.rewardImproveItemList[i]:CleanBtnEvent()
		end
	end
  end
end