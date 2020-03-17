--[[
 灵兽战印
 wangshuai
]]
_G.WarPrintController = setmetatable({},{__Index = IController});
WarPrintController.name = "WarPrintController";

function WarPrintController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_RSpiritWarPrint,				self,self.OnWarPrintItem); -- 8334
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintAdd,			self,self.OnWarPrintItemAdd); -- 8335
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintUpdata,		self,self.OnWarPrintItemUpdata); -- 8336
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintRemove,		self,self.OnWarPrintItemRemove); -- 8337
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintSwapResult,	self,self.OnWarPrintItemSwapResult); -- 8338
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintDebrisResult,	self,self.OnWarPrintDebrisResult); -- 8340
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintBuy,		self,self.OnWarPrintShopResult); -- 8342
	MsgManager:RegisterCallBack(MsgType.SC_SpiritWarPrintBuyStore,		self,self.OnWarPrintStoreResult); -- 8348
	MsgManager:RegisterCallBack(MsgType.SC_DongTianLvInfo,		self,self.OnWarPrintDongTianLvResult); -- 8348
	WarPrintModel:InitInfo()
end;

-- item list
function WarPrintController:OnWarPrintItem(msg)

	WarPrintModel:OnSetBagInfo(msg.list)
	WarPrintModel:OnSpiritDebrisNum(msg.debris)
	--trace(msg)
	--print("总item。")
	--debug.debug();

end;

-- item add
function WarPrintController:OnWarPrintItemAdd(msgc)
	local msg = msgc;
	if msg.isChou == 1 then 
		TimerManager:RegisterTimer(function()
			WarPrintModel:OnSpiritAddItem(msg.tid,msg.value,msg.pos,msg.bagType)
		end, 1000, 1)
		return 
	end;
	WarPrintModel:OnSpiritAddItem(msg.tid,msg.value,msg.pos,msg.bagType)
end;

-- item remove
function WarPrintController:OnWarPrintItemRemove(msg)
	WarPrintModel:OnSpiritRemoveItem(msg.pos,msg.bagType)
	--trace(msg)
	--print("移除item。")
end

-- item updata
function WarPrintController:OnWarPrintItemUpdata(msg)
	 WarPrintModel:OnSpiritUpdataItem(msg.tid,msg.value,msg.pos,msg.bagType)
	 --trace(msg)
	--print("更新item。")
end;

-- swap result
function WarPrintController:OnWarPrintItemSwapResult(msg)
 	WarPrintModel:OnSpiritSwapItem(msg)
 	--trace(msg)
	--print("交换item。")
end;

-- debris result
function WarPrintController:OnWarPrintDebrisResult(msg)
	--trace(msg)
	--print("分解结果item。")
	WarPrintModel:OnSpiritDebrisResult(msg)
end;

-- shpo result 
function WarPrintController:OnWarPrintShopResult(msg)
	--print("购买结果")
	--trace(msg)
	WarPrintModel:OnSpiritShopintResult(msg)
	WarPrintModel:OnSpiritDebrisNum(msg.num, true)
	
	--print("购买结果item。")
end;

-- store shop resule
function WarPrintController:OnWarPrintStoreResult(msg)
	--trace(msg)
	if msg.result == 2 then 
		-- 碎片不足

	elseif msg.result == 1 then 
		WarPrintModel:OnSpiritDebrisNum(msg.num)
	end;
	--print("商店购买结果")
end;
--返回当前洞天等级
function WarPrintController:OnWarPrintDongTianLvResult(msg)
	WarPrintModel.dongTianLv = msg.lv;
	Notifier:sendNotification(NotifyConsts.SpiritWarPrintUpdateDongTianLv);
end


------------------------c to s 

-- swap
function WarPrintController:OnReqItemSwap(scrbag,scridx,dstbag,dstidx)
	local msg = ReqSpiritWarPrintSwapMsg:new()
	msg.src_bag = scrbag;
	msg.src_idx = scridx;
	msg.dst_bag = dstbag;
	msg.dst_idx = dstidx;
	MsgManager:Send(msg)
	--trace(msg)
	--print("请求交换物品")
end;

-- duoci tunshi
function WarPrintController:OnReqItemTunshi(pos)
	local msg = ReqSpiritWarPrintAutoDevourMsg:new()
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_Bag,pos)
	if not item then return end;
	local cfg = WarPrintUtils:OnGetItemCfg(item.tid)
	if not cfg then 
		--玩家选中后，可能再次对选中状态进行操作；
		return;
	end;
	if cfg.lvl >= WarPrintModel.warprintmaxlvl then 
		FloatManager:AddNormal(StrConfig["warprint005"])
		return 
	end;
	msg.pos = pos;
	MsgManager:Send(msg);
	--trace(msg)
	--print("发送多次吞噬2")
end;

-- danci tunshi
function WarPrintController:OnReqItemDuociTunshi(scrbag,scridx,dstbag,dstidx)
	local msg = ReqSpiritWarPrintDevourMsg:new()
	local item = WarPrintUtils:OnGetItem(dstbag,dstidx)
	if not item then return end;
	local cfg = WarPrintUtils:OnGetItemCfg(item.tid)
	if not cfg then 
		--玩家选中后，可能再次对选中状态进行操作；
		return;
	end;
	if cfg.lvl >= WarPrintModel.warprintmaxlvl then 
		FloatManager:AddNormal(StrConfig["warprint005"])
		return 
	end;
	msg.bagType = dstbag;
	msg.pos = dstidx;
	msg.BebagType = scrbag;
	msg.Bepos = scridx;
	MsgManager:Send(msg)
	--trace(msg)
	--print(" 发送单次吞噬")
end;

-- fenjie 
function WarPrintController:OnReqItemDebris(list)
	local msg = ReqSpiritWarPrintDebrisMsg:new()
	msg.list = list;
	MsgManager:Send(msg)
	--trace(msg)
	--print("发送分解 list")
end;

WarPrintController.lastSendTime = 0;
-- bug item
function WarPrintController:OnReqBuyItem(moneyType,Type)
	if GetCurTime() - self.lastSendTime < 200 then
		return false;
	end
	self.lastSendTime = GetCurTime();

	local lastNum = WarPrintModel:GetBagLastNum()
	if lastNum <= 0 then 
		FloatManager:AddNormal(StrConfig["warprintstore009"])
		UIWarPrintShop:StopGoldDuoClick();
		return false;
	end;
	local goldCost = t_zhanyinachieve[WarPrintModel.dongTianLv].money;
	local moneyCost = t_zhanyincost[2].cost;
	if moneyType == 1 then -- 银两
		local gold = ShopUtils:GetMoneyByType(enAttrType.eaBindGold);
		if goldCost > gold then
			FloatManager:AddNormal(StrConfig["equip505"])
			UIWarPrintShop:StopGoldDuoClick();
			return false;
		end;
	elseif moneyType == 2 then  -- 元宝
		local money = ShopUtils:GetMoneyByType(enAttrType.eaUnBindMoney);
		if moneyCost > money then
			FloatManager:AddNormal(StrConfig["equip506"])
			UIWarPrintShop:StopGoldDuoClick();
			return false;
		end;
	end;

	local msg = ReqSpiritWarPrintBuyMsg:new();
	msg.type  = moneyType;
	msg.type2 = Type;
	MsgManager:Send(msg)
	return true;
end;
-- store shoping 
function WarPrintController:OnReqStoreItem(id,num)
	local cfg = t_zhanyinexchange[id]
	if not cfg then return end;
	local numc = WarPrintModel:GetDebrisNum()
	if cfg.num > numc then 
		FloatManager:AddNormal(StrConfig["warprintstore003"])
		return 
	end;
	local msg = ReqSpiritWarPrintBuyStoreMsg:new();
	msg.tid = id;
	msg.num = num;
	MsgManager:Send(msg)
end;


