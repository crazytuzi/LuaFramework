--[[
新翅膀提醒
lizhuangzhuang
2014年10月29日14:20:10
]]

_G.RelicNewTipsManager = {};

RelicNewTipsManager.list = {};
RelicNewTipsManager.currId = nil;--当前id

--背包获得新装备
function RelicNewTipsManager:GetRelic(id)
	
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then 
		return;
	end
	local newItem = bagVO:GetItemById(id);
	if not newItem then 
		return; 
	end

	if not BagUtil:IsRelic(newItem:GetTid()) then
		return;
	end
	
	table.push(self.list,id);
	if not self.currId then
		if #self.list > 0 then
			UIMainRelicNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--背包失去新装备
function RelicNewTipsManager:LoseRelic(id)
	for i=#self.list,1,-1 do
		local itemId = self.list[i];
		if itemId == id then
			table.remove(self.list,i,1);
			if id == self.currId then
				self.currId = nil;
				UIMainRelicNewTips:Hide();
			end
			break;
		end
	end
	if not self.currId then
		if #self.list > 0 then
			UIMainRelicNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--显示完一个
function RelicNewTipsManager:OnShowOneOver()
	if not self.currId then return; end
	if self.currId ~= self.list[1] then
		return;
	end
	table.remove(self.list,1,1);
	self.currId = nil;
	if #self.list > 0 then
		UIMainRelicNewTips:Open(self.list[1]);
		self.currId = self.list[1];
	end
end

--关闭所有提示(打开炼化炉时)
function RelicNewTipsManager:CloseAll()
	if self.currId then
		self.currId = nil;
	end
	if #self.list > 0 then
		self.list = {};
	end
	if UIMainRelicNewTips:IsShow() then
		UIMainRelicNewTips:Hide();
	end
end