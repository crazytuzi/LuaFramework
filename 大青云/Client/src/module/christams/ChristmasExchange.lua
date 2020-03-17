--[[
	2015年12月22日17:34:36
	wangyanwei
	圣诞兑换
]]

_G.UIChristmasExchange = BaseUI:new('UIChristmasExchange');

function UIChristmasExchange:Create()
	self:AddSWF('christmasExchange.swf',true);
end

function UIChristmasExchange:OnLoaded(objSwf)
	objSwf.exchangelist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.exchangelist.itemRollOut = function () TipsManager:Hide(); end
	
	local cfg = t_consts[177];
	if not cfg then return end
	local npcCfg = t_npc[cfg.val3];
	if not npcCfg then return end
	objSwf.btn_npc.htmlLabel = string.format(StrConfig['christmas150'],npcCfg.name);
	objSwf.btn_npc.click = function () self:NpcClick(); end
	objSwf.btn_goon.click = function () self:NpcClick(); end
end

function UIChristmasExchange:NpcClick()
	local cfg = t_consts[177];
	local posID = cfg.fval;
	QuestController:DoRunToNpc( QuestUtil:GetQuestPos(posID), cfg.val3 );
end

function UIChristmasExchange:OnShow()
	self:ShowReward();
end

function UIChristmasExchange:ShowReward()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local list = {};
	for i , v in pairs(t_shop) do
		if v.type == ShopConsts.T_XmasExchange then
			table.push(list,v);
		end
	end
	table.sort(list,function (A,B) return A.id < B.id end)
	
	local str = '';
	for i , v in ipairs(list) do
		str = str .. v.itemId .. ',' .. 0;
		str = i >= #list and str or str .. '#';
	end
	local exchangelist = RewardManager:Parse(str);
	objSwf.exchangelist.dataProvider:cleanUp();
	objSwf.exchangelist.dataProvider:push(unpack(exchangelist));
	objSwf.exchangelist:invalidateData();
end

function UIChristmasExchange:OnHide()
	
end