PowerLevelView = BaseClass(LuaUI)
function PowerLevelView:__init( ... )
	self.URL = "ui://ic8go605psjw9";
	self:__property(...)
	self:Config()
end
-- Set self property
function PowerLevelView:SetProperty( ... )
end
-- start
function PowerLevelView:Config()
	self.model = PowerModel:GetInstance()
	self:InitData()
	self:AddLevelItem()
	self:RegistBtn()
end
-- wrap UI to lua
function PowerLevelView:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PowerLevelingActivitiesUI","LevelingMadmanContent");

	self.backGround = self.ui:GetChild("backGround")
	self.list = self.ui:GetChild("list")
	self.imgSplit = self.ui:GetChild("imgSplit")
	self.daojishi = self.ui:GetChild("daojishi")
	self.daoJiTime = self.ui:GetChild("daoJiTime")
end
-- Combining existing UI generates a class
function PowerLevelView.Create( ui, ...)
	return PowerLevelView.New(ui, "#", {...})
end

function PowerLevelView:InitData()
	self.onLevelRewardTimeKey = "onLevelRewardTimeKey"
	self.daoJiTime.text =TimeTool.GetTimeDHM(self.model:GetHuoDongTime())
	self:RefershTimeUI()
	self.leveingMadmanData = {}
	self.levelRewardItemURL = UIPackage.GetItemURL("PowerLevelingActivitiesUI", "LevelingMadmanItem")
	self.rewardLevelItemList = {}

end

function PowerLevelView:AddLevelItem()
	self:SetLevelData()
	self:CleanListEvent()
	self.list:RemoveChildrenToPool()
	self.rewardLevelItemList = {}

	for k,v in pairs(self.leveingMadmanData) do
		local curItemData = self.leveingMadmanData[k]
		local item = self.list:AddItemFromPool(self.levelRewardItemURL)
		local rewardItem = PowerLevelItem.Create(item, curItemData)
		rewardItem:SetData(curItemData)
		rewardItem:SetStartUi()
		table.insert(self.rewardLevelItemList, rewardItem)	
	end

end

function PowerLevelView:RegistBtn()
	if self.rewardLevelItemList then
		for k,v in pairs(self.rewardLevelItemList) do
			local data = PowerModel:GetInstance():GetleveingMadmanData()[k]
			self.rewardLevelItemList[k]:SetData(data)
			self.rewardLevelItemList[k]:RegistBtn()
		end
	end
end

function PowerLevelView:SetLevelData()
	self.leveingMadmanData = PowerModel:GetInstance():GetleveingMadmanData()
end

function PowerLevelView:__delete()
	RenderMgr.Realse(self.onLevelRewardTimeKey)
	self.leveingMadmanData = {}
	self.levelRewardItemURL = ""
	for i = 1, #self.rewardLevelItemList do
		if self.rewardLevelItemList[i] then
			self.rewardLevelItemList[i]:Destroy()
		end
	end

end

function PowerLevelView:RefershTimeUI()
	RenderMgr.CreateCoTimer(function() 
		self:SetTimeUI()		
	end,20,-1,self.onLevelRewardTimeKey)
end

function PowerLevelView:SetTimeUI()

	--活动剩余时间
	local shengYuTime = self.model:GetHuoDongTime() 
	
	self.daoJiTime.text =shengYuTime > 0 and StringFormat("{0}",TimeTool.GetTimeDHM(shengYuTime)) or "活动已结束！"
end

function PowerLevelView:CleanListEvent()
  if self.rewardLevelItemList then
	for i= 1, #self.rewardLevelItemList do
		if self.rewardLevelItemList[i] then
			self.rewardLevelItemList[i]:CleanBtnEvent()
		end
	end
  end
end