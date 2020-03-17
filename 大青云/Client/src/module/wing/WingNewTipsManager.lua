--[[
新翅膀提醒
lizhuangzhuang
2014年10月29日14:20:10
]]

_G.WingNewTipsManager = {};

WingNewTipsManager.list = {};
WingNewTipsManager.currId = nil;--当前id

--背包获得新装备
function WingNewTipsManager:GetWing(id)
	-- print('================WingNewTipsManager',id)
	
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then 
		-- print('===================not bagVO')
		return;
	end
	local newItem = bagVO:GetItemById(id);
	if not newItem then 
		-- print('===================not newItem')
		return; 
	end
		-- print('======================newItem:GetTid()',newItem:GetTid())
	if not BagUtil:IsWing(newItem:GetTid()) then
		return;
	end
	--判断等级职业
	if not newItem:LevelAccord() then
		-- print('===================判断等级职业')
		return true;
	end
	--是否为当前职业使用
	if newItem:GetCfg().vocation>0 and newItem:GetCfg().vocation~=MainPlayerModel.humanDetailInfo.eaProf then
		-- print('===================1111111111111111111')
		return;
	end
	--对比人身上
	if not BagUtil:CheckBetterWing(newItem:GetBagType(),newItem:GetPos(),newItem:GetTid()) then
		-- print('===================对比人身上')
		return;
	end
	--对比队列中的
	-- UILog:print_table(self.list)
	for i=#self.list,1,-1 do
		local itemId = self.list[i];
		local item = bagVO:GetItemById(itemId);
		if item then
			-- if WingStarUtil:GetInWingCfgFight(item:GetTid())>0 and WingStarUtil:GetInWingCfgFight(newItem:GetTid())>0 then--若为翅膀
			if WingStarUtil:GetInWingCfgFight(newItem:GetTid()) >= WingStarUtil:GetInWingCfgFight(item:GetTid()) then
				table.remove(self.list,i,1);
				if itemId == self.currId then
					self.currId = nil;
					-- print('==============背包获得新翅膀 Hide')
					UIMainWingNewTips:Hide();
				end
				break;
			else
				-- print('==============2222222222222222222')
				return;
			end
			-- end
		end
	end
	table.push(self.list,id);
	if not self.currId then
		if #self.list > 0 then
			UIMainWingNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--背包失去新装备
function WingNewTipsManager:LoseWing(id)
	-- print('===========================背包失去新装备',id)
	for i=#self.list,1,-1 do
		local itemId = self.list[i];
		if itemId == id then
			table.remove(self.list,i,1);
			if id == self.currId then
				self.currId = nil;
				-- print('===================背包失去新装备 Hide')
				UIMainWingNewTips:Hide();
			end
			break;
		end
	end
	if not self.currId then
		if #self.list > 0 then
			UIMainWingNewTips:Open(self.list[1]);
			self.currId = self.list[1];
		end
	end
end

--显示完一个
function WingNewTipsManager:OnShowOneOver()
	if not self.currId then return; end
	if self.currId ~= self.list[1] then
		return;
	end
	table.remove(self.list,1,1);
	self.currId = nil;
	if #self.list > 0 then
		UIMainWingNewTips:Open(self.list[1]);
		self.currId = self.list[1];
	end
end

--关闭所有提示(打开炼化炉时)
function WingNewTipsManager:CloseAll()
	if self.currId then
		self.currId = nil;
	end
	if #self.list > 0 then
		self.list = {};
	end
	if UIMainWingNewTips:IsShow() then
		UIMainWingNewTips:Hide();
	end
end