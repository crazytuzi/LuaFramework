--[[
物品逻辑控制
lizhuangzhang
2014年7月31日15:43:11 
]]
_G.BagController = setmetatable({},{__index=IController})

BagController.name = "BagController";

BagController.autoExpandBag = false;--是否在自动扩展背包

function BagController:Create()
	--注册消息
	MsgManager:RegisterCallBack(MsgType.SC_ItemAdd,self,self.OnItemAdd);
	MsgManager:RegisterCallBack(MsgType.SC_ItemDel,self,self.OnItemDel);
	MsgManager:RegisterCallBack(MsgType.SC_ItemUpdate,self,self.OnItemUpdate);
	MsgManager:RegisterCallBack(MsgType.SC_QueryItemResult,self,self.OnQueryItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_DiscardItemResult,self,self.OnDiscardItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_SwapItemResult,self,self.OnSwapItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_UseItemResult,self,self.OnUseItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_SellItemResult,self,self.OnSellItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_PackItemResult,self,self.OnPackItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_ExpandBagResult,self,self.OnExpandBagResult);
	MsgManager:RegisterCallBack(MsgType.SC_ExpandBagTips,self,self.OnExpandBagTips);
	MsgManager:RegisterCallBack(MsgType.SC_SplitItemResult,self,self.OnSplitItemResult);
	MsgManager:RegisterCallBack(MsgType.SC_OpenGift,self,self.OnOpenGiftResult);
	MsgManager:RegisterCallBack(MsgType.SC_ItemTips,self,self.OnItemTips);
	MsgManager:RegisterCallBack(MsgType.SC_ExpTips,self,self.OnExpTips);
	MsgManager:RegisterCallBack(MsgType.SC_ItemUseNum,self,self.OnItemUseNum);   --一键使用妖丹
	MsgManager:RegisterCallBack(MsgType.SC_ItemCDList,self,self.OnItemCDList);
	MsgManager:RegisterCallBack(MsgType.WC_ExtendGuild,self,self.OnExtendGuild);
	BagModel:CreateCompoundMap();
end

function BagController:Update(dwInterval)
	BagModel:UpdateItemGroupCD(dwInterval);
end

function BagController:OnChangeSceneMap()
	if UIBag:IsShow() then
		-- UIBag:SetQuickSell(false);
		UIBag:ShowList(true);
	end
	if UIRewardGetPanel:IsShow() then
		UIRewardGetPanel:Hide();
	end
end

--使用物品
function BagController:UseItem(bagType,pos,count)
	if count <= 0 then return;end
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	--判断是否可使用
	local canuse = BagUtil:GetItemCanUse(item:GetTid());
	if canuse < 0 then
		FloatManager:AddCenter(BagConsts:GetErrorTips(canuse));
		return;
	end
	--判断是否有脚本
	local cfg = t_item[item:GetTid()];
	if cfg and cfg.clientScript~="" then
		ItemScriptManager:DoScript(bagType,pos,cfg.clientScript,cfg.clientParam);
		return;
	end
	local canUseNum,rst = BagModel:GetItemCanUseNum(item:GetTid());
	if canUseNum == 0 then
		if rst == -1 then
			FloatManager:AddNormal(StrConfig['bag53']);
		else
			FloatManager:AddNormal(StrConfig['bag54']);
		end
		return;
	end
	if canUseNum>0 and count>canUseNum then
		count = canUseNum;
	end
	if cfg and cfg.payConfirm then 
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaUnBindMoney >= cfg.use_param_2 then--元宝足够开礼包
			local okfun = function()  
				--使用
				local msg = ReqUseItemMsg:new();
				msg.item_bag = bagType;
				msg.item_idx = pos;
				msg.item_count = count;
				MsgManager:Send(msg);
			end;
			local color = TipsConsts:GetItemQualityColor(cfg.quality)
			UIConfirm:Open(string.format(StrConfig["bag61"],color,cfg.name,cfg.use_param_2), okfun, nil, nil, nil, nil, nil,true)		
		else
			local okfun = function()  
				--进入充值页面
				Version:Charge()
			end;
			local color = TipsConsts:GetItemQualityColor(cfg.quality)
			local needYuanbao = cfg.use_param_2 - playerinfo.eaUnBindMoney
			UIConfirm:Open(string.format(StrConfig["bag611"],needYuanbao), okfun, nil, nil, nil, nil, nil,true)	
		end
		return;
	end;
	--使用
	if bagType == BagConsts.BagType_Tianshen then
		if NewTianshenModel:GetAllCount() >= NewTianshenConsts.tianshenCount then
			FloatManager:AddNormal(StrConfig['newtianshen109'])
			return
		end
		FuncManager:OpenFunc(FuncConsts.NewTianshen, nil, true)
	end
	local msg = ReqUseItemMsg:new();
	msg.item_bag = bagType;
	msg.item_idx = pos;
	msg.item_count = count;
	MsgManager:Send(msg);
end

--直接使用物品接口  警告 ： 不允许调用！！！！
function BagController:QuickUseItem(bagType,pos,count)
	local msg = ReqUseItemMsg:new();
	msg.item_bag = bagType;
	msg.item_idx = pos;
	msg.item_count = count;
	MsgManager:Send(msg);
end

--脚本使用
function BagController:SplitUseItem(bagType,pos,count)
	if count <= 0 then print('1111')return;end
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then print('2222')return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then print('3333')return; end
	--判断是否可使用
	local canuse = BagUtil:GetItemCanUse(item:GetTid());
	if canuse < 0 then
		FloatManager:AddCenter(BagConsts:GetErrorTips(canuse));
		return;
	end
	--判断是否有脚本
	local cfg = t_item[item:GetTid()];
	if cfg and cfg.clientScript=="" then
		return;
	end
	local canUseNum,rst = BagModel:GetItemCanUseNum(item:GetTid());
	local canVIPUseNum = BagModel:GetDailyExtraNum(item:GetTid());
	if canUseNum == 0 and canVIPUseNum == 0 then return end	--无使用次数
	if canUseNum>0 and count>canUseNum then
		count = canUseNum;
	end
	--使用
	local msg = ReqUseItemMsg:new();
	msg.item_bag = bagType;
	msg.item_idx = pos;
	msg.item_count = count;
	MsgManager:Send(msg);
end

--一键使用物品
function BagController:UseAllItem(bagType,list)
	local msg = ReqUseAllItemMsg:new();
	msg.item_bag = bagType;
	msg.itemlist = list;
	--[[
	print("可以使用妖丹的数量:",#list)
	for i,v in pairs(list) do
		print("第"..i.."物品id："..v.item_tid)
		print("第"..i.."物品数量："..v.item_count)
	end
	--]]
	MsgManager:Send(msg);                              
end

--根据tid从背包中检索物品，检索到使用
function BagController:UseItemByTid(bagType,tid,count)
	if count <= 0 then return; end
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return; end
	for k,itemVO in pairs(bagVO.itemlist) do
		if itemVO:GetTid() == tid then
			if count > itemVO:GetCount() then
				count = itemVO:GetCount();
			end
			self:UseItem(bagType,itemVO:GetPos(),count);
			break;
		end
	end
end

--交换物品
function BagController:SwapItem(srcBag,srcPos,dstBag,dstPos)
	local pos = 0
	if dstBag == BagConsts.BagType_Storage and srcBag == BagConsts.BagType_Bag then
		pos = srcPos
	elseif srcBag == BagConsts.BagType_Storage and dstBag == BagConsts.BagType_Bag then
		pos = dstPos
	end
	if pos ~= 0 then
		local bag = BagModel:GetBag(BagConsts.BagType_Bag);
		local item = bag:GetItemByPos(pos)
		if item then
			local cfg = t_equip[item:GetTid()]
			if cfg and not cfg.depot then
				FloatManager:AddNormal("当前物品无法放入仓库")
				return
			end
		end
	end
	local msg = ReqSwapItemMsg:new();
	msg.src_bag = srcBag;
	msg.dst_bag = dstBag;
	msg.src_idx = srcPos;
	msg.dst_idx = dstPos;
	MsgManager:Send(msg);
end

--丢弃物品
function BagController:DiscardItem(bag,pos)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	if not BagOperUtil:CheckHasOperRights(BagConsts.Oper_Destroy,item) then
		FloatManager:AddCenter(StrConfig["bag5"]);
		return;
	end
	local confirmFunc = function()
		self.discardKey = nil;
		local msg = ReqDiscardItemMsg:new();
		msg.item_bag = bag;
		msg.item_idx = pos;
		MsgManager:Send(msg);
	end
	self.discardKey = UIConfirm:Open(StrConfig["bag6"],confirmFunc,nil,nil,nil,nil,nil,true);
end

--清除丢弃确认
function BagController:ClearDiscardConfirm()
	UIConfirm:Close(self.discardKey);
	self.discardKey = nil;
end

--出售物品
function BagController:SellItem(bag,pos)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	--判断是否可出售
	if not BagOperUtil:CheckHasOperRights(BagConsts.Oper_Sell,item) then
		FloatManager:AddCenter(StrConfig["bagerror20"]);
		return;
	end
	--
	local confirmFunc = function()
		-- 发送出售协议前将物品信息缓存，如果出售成功则加到回购商店中
		ShopModel:AddSellCache(bag, pos);
		-- 出售
		local msg = ReqSellItemMsg:new();
		msg.item_bag = bag;
		msg.item_idx = pos;
		MsgManager:Send(msg);
	end
	UIBagSellConfirm:Open(bag,pos,confirmFunc);
end

--拆分物品
function BagController:SplitItem(bag,pos,count)
	local msg = ReqSplitItemMsg:new();
	msg.item_bag = bag;
	msg.item_idx = pos;
	msg.split_count = count;
	MsgManager:Send(msg);
end

--整理背包
function BagController:PackItem(bag)
	local msg = ReqPackItemMsg:new();
	msg.item_bag = bag;
	MsgManager:Send(msg);
end

--穿戴装备(人物或坐骑)
function BagController:EquipItem(fromBag,fromPos)
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end;
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end;
	--判断是否可穿戴
	local canuse = BagUtil:GetEquipCanUse(item:GetTid());
	if canuse < 0 then
		FloatManager:AddNormal(BagConsts:GetErrorTips(canuse));
		return;
	end
	--穿戴
	local toBag,toPos = BagUtil:GetEquipPutBagPos(item:GetTid());
	if toBag<0 or toPos<0 then
		return;
	end
	if item:GetBindState()==BagConsts.Bind_UseBind and item:IsValuable() then
		UIBagEquipConfirm:Open(fromBag,fromPos,item:GetId(),function()
			self:SwapItem(fromBag,fromPos,toBag,toPos);
		end)
	else
		self:SwapItem(fromBag,fromPos,toBag,toPos);
	end
end

--穿戴翅膀
function BagController:EquipWing(fromBag,fromPos)
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end;
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end; 
	local canuse = BagUtil:GetItemCanUse(item:GetTid());
	if canuse < 0 then
		FloatManager:AddCenter(BagConsts:GetErrorTips(canuse));
		return;
	end
	if item:GetBindState()==BagConsts.Bind_UseBind then
		UIConfirm:Open(StrConfig["bag48"],function()
			self:SwapItem(fromBag,fromPos,BagConsts.BagType_RoleItem,0);
		end);
	else
		self:SwapItem(fromBag,fromPos,BagConsts.BagType_RoleItem,0);
	end
end

-- 穿戴圣物
function BagController:EquipRelic(fromBag, fromPos)
	local bagVO = BagModel:GetBag(fromBag)
	if not bagVO then return end
	local item = bagVO:GetItemByPos(fromPos)
	if not item then return end
	local canuse = BagUtil:GetItemCanUse(item:GetTid())
	if canuse < 0 then
		FloatManager:AddCenter(BagConsts.GetErrorTips(canuse))
		return
	end
	local pos = BagUtil:GetRelicPos(item:GetTid()) - BagConsts.Equip_Relic_0
	if item:GetBindState() == BagConsts.Bind_UseBind then
		UIConfirm:Open(StrConfig["bag48"],function()
			self:SwapItem(fromBag,fromPos,BagConsts.BagType_RELIC,pos);
		end)
	else
		self:SwapItem(fromBag,fromPos,BagConsts.BagType_RELIC,pos);
	end
end

--卸载装备(到背包)
 function BagController:UnEquipItem(fromBag,fromPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	self:SwapItem(fromBag,fromPos,BagConsts.BagType_Bag,-1);
end

--移到仓库
function BagController:MoveToStorage(fromBag,fromPos)
	local storageBagVO = BagModel:GetBag(BagConsts.BagType_Storage);
	if not storageBagVO then return; end
	-- if fromBag == BagConsts.BagType_Bag then
	-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	-- 	local item = bag:GetItemByPos(fromPos)
	-- 	local cfg = t_equip[item:GetTid()]
	-- 	if cfg and not cfg.depot then
	-- 		FloatManager:AddNormal("当前物品无法放入仓库")
	-- 		return
	-- 	end
	-- end
	self:SwapItem(fromBag,fromPos,BagConsts.BagType_Storage,-1)
end
--移动到背包
function BagController:MoveToBag(fromBag,fromPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	self:SwapItem(fromBag,fromPos,BagConsts.BagType_Bag,-1)
end
--移动到交易栏
function BagController:MoveToDealShelves( bagItem )
	DealController:PutOnShelves( bagItem )
end

---------------------------以下为服务器消息处理----------------------------
--请求物品返回
function BagController:OnQueryItemResult(msg)
	local bagVO = BagModel:GetBag(msg.item_bag);
	if not bagVO then
		Debug("error:获取物品列表,错误的背包类型.BagType:"..msg.item_bag);
		return;
	end
	bagVO:RemoveAllItem();
	bagVO:SetSize(msg.bag_size);
	bagVO:SetItemList(msg.items);
	bagVO:SetOpenNextTime(msg.openLastTime);
end

--增加物品
function BagController:OnItemAdd(msg)
	-- print('=========================增加物品')
	local itemData = msg;
	local bagVO = BagModel:GetBag(itemData.bag);
	if not bagVO then
		Error("add item failed BagType:"..itemData.bag);
		-- print('=========================not bagVO')
		return;
	end
	local item = BagItem:new(itemData.id, itemData.tid, itemData.count, itemData.bag, itemData.pos,itemData.useCnt,itemData.todayUse,itemData.flags,itemData.param1, itemData.param2, itemData.param4);
	bagVO:AddItem(item);
	if itemData.bag == BagConsts.BagType_Bag then
		RemindFuncController:ExecRemindOnNewItemInBag(itemData.tid);
		RemindFuncTipsController:ExecRemindOnNewItemInBag(itemData.tid);
		EquipNewTipsManager:GetEquip(itemData.id);
		RelicNewTipsManager:GetRelic(itemData.id)
		WingNewTipsManager:GetWing(itemData.id);
		BagController:OnItemNumChange(itemData.bag,itemData.pos,itemData.tid);
		BagController:SendItemSplitWhenHang();
	end
	if itemData.bag == BagConsts.BagType_Tianshen then
		UINewTianshenCardGet:Open(itemData.id)
		if itemData.tid ~= 152201000 then
			RemindFuncController:ExecRemindOnNewItemInBag(itemData.tid);
			RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_NewTianShenUsed, itemData.id)
		end
	end
end

--移除物品
function BagController:OnItemDel(msg)
	-- print('=========================移除物品')
	local bagVO = BagModel:GetBag(msg.item_bag);
	if not bagVO then
		return;
	end
	local removeItem = bagVO:RemoveItem(msg.item_idx);
	if not removeItem then return; end
	print("item position in Bag：",msg.item_idx)
	if msg.item_bag == BagConsts.BagType_Bag then
		EquipNewTipsManager:LoseEquip(removeItem:GetId());
		WingNewTipsManager:LoseWing(removeItem:GetId());
		RelicNewTipsManager:LoseRelic(removeItem:GetId())
	end
	--删除装备附加信息
	EquipModel:RemoveEquipInfo(removeItem:GetId());
	EquipModel:RemoveWingInfo(removeItem:GetId());

	--执行检测已经打开右下角弹窗是否还符合条件
	RemindFuncController:RemoveFailPreshow(removeItem.tid);
end

--更新物品
function BagController:OnItemUpdate(msg)
	local itemData = msg;
	local bagVO = BagModel:GetBag(itemData.bag);
	if not bagVO then
		return;
	end
	local oldCount = bagVO:UpdateItem(itemData.id,itemData.tid,itemData.count,itemData.pos,itemData.useCnt,itemData.todayUse,itemData.flags,itemData.param1, itemData.param2, itemData.param4);
	if itemData.bag == BagConsts.BagType_Bag then
		if itemData.count > oldCount then
			BagController:OnItemNumChange(itemData.bag,itemData.pos,itemData.tid);
		end
	end
	RemindFuncController:ExecRemindOnNewItemInBag(itemData.tid);
	RemindFuncTipsController:ExecRemindOnNewItemInBag(itemData.tid);
end

--丢弃物品结果
function BagController:OnDiscardItemResult(msg)
	if msg.result == 0 then
		FloatManager:AddCenter(StrConfig["bag45"]);
		return;
	end
	FloatManager:AddCenter("丢弃物品,未处理的错误类型"..msg.result);
end

--交换物品结果
function BagController:OnSwapItemResult(msg)
	if msg.result ~= 0 then
		FloatManager:AddCenter("交换物品,未处理的错误类型"..msg.result);
		return;
	end
	local srcBagVO = BagModel:GetBag(msg.src_bag);
	if not srcBagVO then return; end
	local dstBagVO = BagModel:GetBag(msg.dst_bag);
	if not dstBagVO then return; end
	--
	local srcItem = srcBagVO:RemoveItem(msg.src_idx);
	local dstItem = dstBagVO:RemoveItem(msg.dst_idx);
	if srcItem then
		srcItem:SetBagType(msg.dst_bag);
		srcItem:SetPos(msg.dst_idx);
		dstBagVO:AddItem(srcItem);
	end
	if dstItem then
		dstItem:SetBagType(msg.src_bag);
		dstItem:SetPos(msg.src_idx);
		srcBagVO:AddItem(dstItem);
	end
	if msg.src_bag==BagConsts.BagType_Bag and msg.dst_bag~=BagConsts.BagType_Bag then
		-- print('=======================交换物品结果111')
		if srcItem then 
			EquipNewTipsManager:LoseEquip(srcItem:GetId());	
			WingNewTipsManager:LoseWing(srcItem:GetId());	
			RelicNewTipsManager:LoseRelic(srcItem:GetId())
		end
		if dstItem then 
			EquipNewTipsManager:GetEquip(dstItem:GetId());
			WingNewTipsManager:GetWing(dstItem:GetId());
			-- RelicNewTipsManager:GetRelic(dstItem:GetId())
		end
		
	end
	if msg.dst_bag==BagConsts.BagType_Bag and msg.src_bag~=BagConsts.BagType_Bag then
		print('=======================交换物品结果222')
		if dstItem then 
			EquipNewTipsManager:LoseEquip(dstItem:GetId());
			WingNewTipsManager:LoseWing(dstItem:GetId());
			RelicNewTipsManager:LoseRelic(dstItem:GetId())
		end
		if srcItem then 
			EquipNewTipsManager:GetEquip(srcItem:GetId()); 
			WingNewTipsManager:GetWing(srcItem:GetId());
			-- RelicNewTipsManager:GetRelic(srcItem:GetId())
		end
	end
	if msg.dst_bag==BagConsts.BagType_Role or msg.dst_bag==BagConsts.BagType_RoleItem then
		SoundManager:PlaySfx(2031);
	end
	if srcItem and dstItem then
		if msg.dst_bag == BagConsts.BagType_Role then
			RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_SmithingResp, srcItem:GetId(), dstItem:GetId())
		elseif msg.src_bag == BagConsts.BagType_Role then
			RemindFuncController:ExecRemindFunc(RemindFuncConsts.RFC_SmithingResp, dstItem:GetId(), srcItem:GetId())
		end
	end
end

--使用物品结果
function BagController:OnUseItemResult(msg)
	if msg.result == 0 then
		local itemCfg = t_item[msg.item_tid];
		if not itemCfg then return; end
		if itemCfg.groupcd and itemCfg.groupcd>0 then
			BagModel:SetItemGroupCD(itemCfg.groupcd,itemCfg.cd);
		end
--		if itemCfg.sub == BagConsts.SubT_Recover then
--			SoundManager:PlaySfx(2027);
--		end
		SoundManager:PlaySfx(2056);
		return;
	end
	FloatManager:AddCenter("使用物品,未处理的错误类型"..msg.result);
end

--出售物品结果
function BagController:OnSellItemResult(msg)
	--判断是否加到回购列表
	ShopController:OnItemSale( msg );
	if msg.result == 0 then
		FloatManager:AddCenter(StrConfig['bag46']);
		return;
	end
	FloatManager:AddCenter("出售物品,未处理的错误类型"..msg.result);
end

--整理物品结果
function BagController:OnPackItemResult(msg)
	if msg.result == 0 then
		return;
	end
end

--扩展背包
function BagController:ExpandBag(bag,size,moneyType)
	local msg = ReqExpandBagMsg:new();
	msg.item_bag = bag;
	msg.inc_size = size;
	msg.moneyType = moneyType;
	MsgManager:Send(msg);
end

--背包可扩充
function BagController:OnExpandBagTips(msg)
	--不弹提示,自动扩展
	self.autoExpandBag = true;
	BagController:ExpandBag(msg.item_bag,1,0);
end

--扩充背包结果
function BagController:OnExpandBagResult(msg)
	if msg.result ~= 0 then
		self.autoExpandBag = false;
		Debug('扩充背包失败');
		return;
	end
	local bagVO = BagModel:GetBag(msg.item_bag);
	if not bagVO then return; end
	local cfgT = nil;
	if msg.item_bag == BagConsts.BagType_Bag then
		cfgT = t_packetcost;
	elseif msg.item_bag == BagConsts.BagType_Storage then
		cfgT = t_storagecost;
	end
	if not cfgT then return; end
	if self.autoExpandBag then
		FloatManager:AddCenter(StrConfig["bag58"]);
		self.autoExpandBag = false;
	end
	bagVO:SetSize(msg.new_size);
	--重置下个格子倒计时
	local cfg = cfgT[bagVO:GetSize()-bagVO:GetDefaultSize()+1];
	if not cfg then return; end
	bagVO:SetOpenNextTime(cfg.autoTime*60);
end

--拆分物品结果 
function BagController:OnSplitItemResult(msg)
	if msg.result == 0 then
		return;
	end
	FloatManager:AddCenter("拆分物品,未处理的错误类型"..msg.result);
end
--开礼包结果
function BagController:OnOpenGiftResult(msg)
	local rewardStr = "";
	for i,giftItemVO in ipairs(msg.items) do
		rewardStr = rewardStr .. giftItemVO.itemId..","..giftItemVO.itemCount..","..giftItemVO.bind;
		if i < #msg.items then
			rewardStr = rewardStr .. "#";
		end
	end
	if msg.id == GiftsConsts.GiftsBoxID then
		-- trace(msg)
		Notifier:sendNotification(NotifyConsts.UpgradeStoneResult,{rewardStr = rewardStr});
		return
	end
	UIBagOpenGift:Open(msg.id,rewardStr, msg.count);
end

--物品获得失去提示
function BagController:OnItemTips(msg)
	for i,vo in ipairs(msg.itemTipsList) do
		FloatManager:OnPlayerItemAddReduce(vo.type,vo.tid,vo.count);
	end
end

--消耗经验提示
function BagController:OnExpTips(msg)
	FloatManager:OnExpReduce(msg.exp);
end

--返回物品使用数量
function BagController:OnItemUseNum(msg)
	BagModel:SetItemUseNum(msg.list);
end

--物品数量变化触发脚本
function BagController:OnItemNumChange(bagType,pos,tid)
	local itemCfg = t_item[tid];
	if not itemCfg then 
		itemCfg = t_equip[tid];
		if not itemCfg then return end;
	end
	if itemCfg.cChangeScript == "" then return; end
	local params = split(itemCfg.cChangeScript,",");
	local script = ItemNumCScriptCfg[params[1]];
	if not script then return; end
	table.remove(params,1);
	script.execute(bagType,pos,tid,params);
end

--同步物品cd
function BagController:OnItemCDList(msg)
	for i,vo in ipairs(msg.list) do
		BagModel:SetItemGroupCD(vo.groupId,vo.cdTime)
	end
end

--帮派扩展道具返回协议
function BagController:OnExtendGuild(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["bag300"]);
	elseif msg.result == 1 then
		FloatManager:AddNormal(StrConfig["bag301"]);
	elseif msg.result == 2 then
		FloatManager:AddNormal(StrConfig["bag302"]);
	elseif msg.result == 3 then
		FloatManager:AddNormal(StrConfig["bag303"]);
	end
end

function BagController:SendItemSplitWhenHang()
	if not AutoBattleController:GetAutoHang() then
		return;
	end
	
	if VipController:GetPower(10218) then
		local bag = BagModel:GetBag(BagConsts.BagType_Bag);
		if bag:GetFreeSize() <= 5 then
			AutoBattleController:SendHangState(2);
		end
	end
end