--[[
新装备提醒
lizhuangzhuang
2014年10月29日14:20:10
]]

_G.EquipNewTipsManager = {};

EquipNewTipsManager.list = {};
EquipNewTipsManager.currId = nil;--当前id

--背包获得新装备
function EquipNewTipsManager:GetEquip(id)
	--打开炼化炉时不提示
	if UIEquip:IsShow() then
		return;
	end
	--打造里只有卓越不提醒
	if UIEquipSuperUp:IsShow() then
		return;
	end
	if UIEquipSuperDown:IsShow() then
		return;
	end
	
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local newItem = bagVO:GetItemById(id);
	if not newItem then return; end
	if BagUtil:GetItemShowType(newItem:GetTid()) ~= BagConsts.ShowType_Equip then
		return;
	end
	--判断等级职业
	if not newItem:LevelAccord() then
		return true;
	end
	if newItem:GetCfg().vocation>0 and newItem:GetCfg().vocation~=MainPlayerModel.humanDetailInfo.eaProf then
		return;
	end
	--对比人身上
	if not BagUtil:CheckBetterEquip(newItem:GetBagType(),newItem:GetPos()) then
		return;
	end
	--对比队列中的
	for i=#self.list,1,-1 do
		local itemId = self.list[i];
		local item = bagVO:GetItemById(itemId);
		if item then
			if BagUtil:GetEquipType(item:GetTid()) == BagUtil:GetEquipType(newItem:GetTid()) then
				if newItem:GetFight() > item:GetFight() then
					table.remove(self.list,i,1);
					if itemId == self.currId then
						self.currId = nil;
						UIMainEquipNewTips:Hide();
					end
					break;
				else
					return;
				end
			end
		end
	end
	table.push(self.list,id);
	if not self.currId then
		if #self.list > 0 then
			UIMainEquipNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--背包失去新装备
function EquipNewTipsManager:LoseEquip(id)
	for i=#self.list,1,-1 do
		local itemId = self.list[i];
		if itemId == id then
			table.remove(self.list,i,1);
			if id == self.currId then
				self.currId = nil;
				UIMainEquipNewTips:Hide();
			end
			break;
		end
	end
	if not self.currId then
		if #self.list > 0 then
			UIMainEquipNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--显示完一个
function EquipNewTipsManager:OnShowOneOver()
	if not self.currId then return; end
	if self.currId ~= self.list[1] then
		return;
	end
	table.remove(self.list,1,1);
	self.currId = nil;
	if #self.list > 0 then
		UIMainEquipNewTips:Open(self.list[1]);
		self.currId = self.list[1];
	end
end

--关闭所有提示(打开炼化炉时)
function EquipNewTipsManager:CloseAll()
	if self.currId then
		self.currId = nil;
	end
	if #self.list > 0 then
		self.list = {};
	end
	if UIMainEquipNewTips:IsShow() then
		UIMainEquipNewTips:Hide();
	end
end