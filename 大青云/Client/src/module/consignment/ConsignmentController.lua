--[[
寄售行
wangshuai
]]
_G.ConsignmentController = setmetatable({},{__index=IController})
ConsignmentController.name = "ConsignmentController";

function ConsignmentController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_ConsignmentItemInfo,self,		self.BuyItemInfo); -- 7142	
	MsgManager:RegisterCallBack(MsgType.WC_ConsignmentItemBuy,self,			self.BuyItemResult); -- 7143	
	MsgManager:RegisterCallBack(MsgType.WC_ConsignmentItemOutShelves,self,	self.OutShelvesItemInfo); -- 7144z	
	MsgManager:RegisterCallBack(MsgType.WC_ConsignmentItemInShelves,self,	self.InShelvesItemInfo); -- 8383	
	MsgManager:RegisterCallBack(MsgType.WC_MyConsignmentEarnInfo,self,		self.MyConsignmentEarn); -- 8383	
end;

function ConsignmentController:OnEnterGame()

end;

function ConsignmentController:BuyItemInfo(msg)
	-- trace(msg)
	-- print("寄售行，物品信息")
	--新卓越属性，特殊处理
	for i,ao in ipairs(msg.consignlist) do 
		-- trace(ao.newSuperList)
		for p,vo in  ipairs(ao.newSuperList) do 
			if vo.id > 0  and vo.wash == 0 then 
				local cfg = t_zhuoyueshuxing[vo.id];
				vo.wash = cfg and cfg.val or 0;
			end;	
		end;
	end;
	--
	if msg.type == 0 then 
		-- 寄售行信息
		if #msg.consignlist == 0 then 
			--FloatManager:AddNormal( StrConfig['consignment020']);
		end;
		ConsignmentModel:SetBuyItemInfo(msg.consignlist)
		ConsignmentModel:SetBuyItemPageInfo(msg.curPage,msg.tatlPage)
		-- 浏览item
		Notifier:sendNotification(NotifyConsts.ConsignmentBuyItemInfo);
	elseif msg.type == 1 then 
		-- 我的寄售行信息
		ConsignmentModel:SetSellItemInfo(msg.consignlist)
		ConsignmentModel:SetUpItemSellNum()
		Notifier:sendNotification(NotifyConsts.ConsignmentMyUpItemInfo);
	end;
end;

function ConsignmentController:BuyItemResult(msg)
	-- --trace(msg)
	-- --print("购买结果")
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['consignment009']);
		UIConsignmentBuy:OnOkSearchItem()
	elseif msg.result == 1 then 
		FloatManager:AddNormal( StrConfig['consignment010']);
	elseif msg.result == 2 then 
		FloatManager:AddNormal( StrConfig['consignment011']);
	elseif msg.result == 3 then 
		FloatManager:AddNormal( StrConfig['consignment011']);
	elseif msg.result == 4 then 
		FloatManager:AddNormal( StrConfig['consignment025']);
	elseif msg.result == 5 then 
		FloatManager:AddNormal( StrConfig['consignment028']);
	elseif msg.result == 6 then 
		FloatManager:AddNormal( StrConfig['consignment029']);
	elseif msg.result == 7 then 
		FloatManager:AddNormal( StrConfig['consignment030']);
	end;
end;

function ConsignmentController:OutShelvesItemInfo(msg)
	-- --trace(msg)
	-- --print('物品下架结果')
	if msg.result == 0 then
		if msg.isall == 0 then 
			FloatManager:AddNormal( StrConfig['consignment013']);
		else
			FloatManager:AddNormal( StrConfig['consignment012']);
		end
	elseif msg.result == 2 then 
		FloatManager:AddNormal( StrConfig['consignment026']);
	elseif msg.result == 3 then 
		FloatManager:AddNormal( StrConfig['consignment029']);
	end;
end;

function ConsignmentController:InShelvesItemInfo(msg)
	-- --trace(msg)
	-- --print("上架结果")
	if msg.result == 0 then 
		FloatManager:AddNormal(StrConfig['consignment014'])
	elseif msg.result == 1 then 
		FloatManager:AddNormal(StrConfig['consignment008'])
	end;
	ConsignmentModel:SetUpItemSellNum()
	if msg.result == 3 then 
		Notifier:sendNotification(NotifyConsts.ConsignmentMyUpItemNum);
	end;
end;

function ConsignmentController:MyConsignmentEarn(msg)
	ConsignmentModel:SetEarninfoData(msg.earnlist);
	ConsignmentModel:SetEarnMoney(msg.yuanbao,msg.gold)
	Notifier:sendNotification(NotifyConsts.ConsignmentMyProfitInfo);
	-- trace(msg)
	-- print("寄售行盈利信息")
end;

----------------------resq

-- 请求物品信息
function ConsignmentController:ResqIteminfo(page,equipPos,roleType,equipType,miniLvl,maxLvl,quality,superAtb,canWith)
	local msg = ReqConsignmentItemInfoMsg:new();
	msg.page = page;
	msg.equipPos = equipPos;
	msg.equipRole = roleType;
	msg.equipType = equipType;
	msg.miniLvl = miniLvl;
	msg.maxLvl = maxLvl;
	msg.quality = quality;
	msg.superAtb = superAtb;
	msg.canWith = canWith;
	-- print('--------------------------- ConsignmentController:ResqIteminfo',page,equipPos)
	MsgManager:Send(msg)
	-- trace(msg)
	-- print('请求寄售信息')
end;

-- 购买物品
function ConsignmentController:ResqBuyItem(uid,num)

	local msg = ReqConsignmentItemBuyMsg:new();
	msg.uid = uid;
	msg.num = num;
	--trace(msg)
	MsgManager:Send(msg);
	--print("请求购买物品",uid,num)
end;

-- 物品下架
function ConsignmentController:ResqItemOutShelves(uid,isall)
	local msg = ReqConsignmentItemOutShelvesMsg:new();
	msg.uid = uid;
	msg.isall = isall;
	MsgManager:Send(msg)
	--print("请求物品下架",uid,isall)
end;

-- 请求我的寄售行信息
function ConsignmentController:ResqMyItemInfo()
	local msg = ReqMyConsignmentItemInfoMsg:new();
	MsgManager:Send(msg)
	--print("请求我的寄售行信息")
end;

-- 物品上架
function ConsignmentController:ResqItemInShelves(uid,num,money,timerLimit)

	local upitemnum = ConsignmentModel:GetUpItemSellNum()
	if upitemnum <= 0 then 
		FloatManager:AddNormal( StrConfig['consignment008']); 
		return
	end;
	
	local msg = ReqConsignmentItemInShelvesMsg:new();
	msg.uid = uid;
	msg.num = num;
	--msg.moneyType = 11;
	msg.money = money;
	msg.timerLimit = timerLimit;
	MsgManager:Send(msg)
	--print("物品上架",uid,num,moneyType,money,timerLimit)
end;

-- 请求寄售行盈利信息
function ConsignmentController:ResqMyProfitInfo()
	local msg = ReqMyConsignmentEarnInfoMsg:new();
	MsgManager:Send(msg)
	--print("请求盈利信息")
end;







---------------------bag click
function ConsignmentController:SetUpItemBagClick(item)
	ConsignmentModel:SetUpItemBagClick(item);
	Notifier:sendNotification(NotifyConsts.ConsignmentBagIteminfo);
end