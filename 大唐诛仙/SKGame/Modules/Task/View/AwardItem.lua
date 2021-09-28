AwardItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function AwardItem:__init( ... )
	self.URL = "ui://ioaemb0chudkh";
	self:__property(...)
	self:Config()
end

-- Set self property
function AwardItem:SetProperty( ... )
	
end

-- Logic Starting
function AwardItem:Config()
	self.icon.url = "Icon/Goods/1001"
end

-- Register UI classes to lua
function AwardItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Task","AwardItem");

	self.loader_quality = self.ui:GetChild("loader_quality")
	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
end

-- Combining existing UI generates a class
function AwardItem.Create( ui, ...)
	return AwardItem.New(ui, "#", {...})
end


function AwardItem:SetUI(itemInfo)

	if itemInfo ~= nil then				
		local itemId = itemInfo.itemId
		local itemCnt = itemInfo.itemCnt
		local isBinding = itemInfo.isBinding

		if itemInfo.itemType == TaskConst.RewardItemType.Item then
			
			local curItemCfg = GetCfgData("item"):Get(itemId)
			if curItemCfg ~= nil then
				
				self.loader_quality.url = "Icon/Common/grid_cell_"..curItemCfg.rare
				self.icon.url = StringFormat("Icon/Goods/{0}",curItemCfg.icon)
				self.title.text = itemCnt
			end

		elseif itemInfo.itemType == TaskConst.RewardItemType.Equipment then
			local curItemCfg = GetCfgData("equipment"):Get(itemId)
			if curItemCfg ~= nil then
				
				self.loader_quality.url = "Icon/Common/grid_cell_"..curItemCfg.rare
				self.icon.url = StringFormat("Icon/Goods/{0}",curItemCfg.icon)
				self.title.text = itemCnt
			end

		elseif itemInfo.itemType == TaskConst.RewardItemType.Diamond then

		elseif itemInfo.itemType == TaskConst.RewardItemType.Bind_Diamond then

		elseif itemInfo.itemType == TaskConst.RewardItemType.Contribution then

		elseif itemInfo.itemType == TaskConst.RewardItemType.Honor then

		elseif itemInfo.itemType ~= TaskConst.RewardItemType.Coin then
			self.loader_quality.url = ""
			self.icon.url = StringFormat("Icon/Goods/gold_big")
			self.title.text = itemCnt

		elseif itemInfo.itemType ~= TaskConst.RewardItemType.Experience then	
			self.loader_quality.url = ""
			self.icon.url = StringFormat("Icon/Goods/exp_big")
			self.title.text = itemCnt
		end
	
	end
end

-- Dispose use AwardItem obj:Destroy()
function AwardItem:__delete()
	
	self.loader_quality = nil 
	self.icon = nil 
	self.title = nil 
end