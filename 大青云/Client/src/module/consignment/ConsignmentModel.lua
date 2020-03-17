--[[
寄售行
wangshuai
]]

_G.ConsignmentModel = Module:new();

ConsignmentModel.BuyItemlist = {} -- 购买浏览list
ConsignmentModel.BuyitempageInfo= {} -- ↑页数配置
ConsignmentModel.SellItemList = {}; -- 我的上架物品list
ConsignmentModel.MyInfo = {}; --  myinfo
ConsignmentModel.EarnInfoList = {}; -- 我的收益记录list

-- 设置预览物品的信息
function ConsignmentModel:SetBuyItemInfo(list)
	self.BuyItemlist = {};
	for i,info in ipairs(list) do
		local vo = {};
		vo.uid  = info.uid;
		vo.id = info.cid;
		vo.num = info.num;
		vo.lastTime = info.lastTime;
		vo.roleName = info.roleName;
		vo.price = info.price;
	--	vo.moneyType = info.monryType;
		vo.strenLvl = info.strenLvl
		vo.refinLvl = info.refinLvl;
		vo.attrAddLvl =	info.attrAddLvl;
		vo.groupId = info.groupId;
		vo.groupId2 = info.groupId2;
		vo.groupId2Level = info.group2Level;
		vo.superNum = info.superNum;
		vo.superList= info.superList;
		vo.newSuperList = info.newSuperList;
		table.push(self.BuyItemlist,vo)
	end;
end;

-- 得到全部预览物品
function ConsignmentModel:GetBuyItenInfo()
	return self.BuyItemlist;
end;

-- 得到某一个预览物品的信息
function ConsignmentModel:getCertainBuitemInfo(uid)
	for i,info in ipairs(self.BuyItemlist) do 
		if info.uid == uid  then 
			return info
		end;	
	end;
end;

-- 设置我的寄售行物品的信息
function ConsignmentModel:SetSellItemInfo(list)
	self.SellItemList = {};
	for i,info in ipairs(list) do
		local vo = {};
		vo.uid  = info.uid;
		vo.id = info.cid;
		vo.num = info.num;
		vo.lastTime = info.lastTime;
		vo.roleName = info.roleName;
		vo.price = info.price;
	--	vo.moneyType = info.monryType;
		vo.strenLvl = info.strenLvl
		vo.refinLvl = info.refinLvl;
		vo.attrAddLvl =	info.attrAddLvl;
		vo.groupId = info.groupId;
		vo.groupId2 = info.groupId2;
		vo.groupId2Level = info.group2Level;
		vo.superNum = info.superNum;
		vo.superList= info.superList;
		vo.newSuperList = info.newSuperList;
		table.push(self.SellItemList,vo)
	end;
end;

function ConsignmentModel:GetMySellItemAllInfo()
	return self.SellItemList
end;

function ConsignmentModel:GetMySellItemInfo(uid)
	for i,info in ipairs(self.SellItemList) do 
		if info.uid == uid  then 
			return info
		end;
	end;
end;

--设置预览页数
function ConsignmentModel:SetBuyItemPageInfo(curpage,tatlpage)
	self.BuyitempageInfo.curpage = curpage;
	self.BuyitempageInfo.tatlpage = tatlpage;
end;

-- get page
function ConsignmentModel:GetBuItemPageInfo()
	if not self.BuyitempageInfo.curpage then 
		self.BuyitempageInfo.curpage = 1;
	end;
	if not self.BuyitempageInfo.tatlpage then 
		self.BuyitempageInfo.tatlpage = 1
	end;
	return self.BuyitempageInfo;
end;

-- 设置上架剩余次数
function ConsignmentModel:SetUpItemSellNum()
	local numc = 0
	for i,info in pairs(self.SellItemList) do 
		numc = numc + 1;
	end;
	self.MyInfo.CanSellNum = 10 - numc;
end;

function ConsignmentModel:GetUpItemSellNum()
	if self.MyInfo.CanSellNum then 
		return self.MyInfo.CanSellNum
	end;
	return 0;
end;

--  设置收益list
function ConsignmentModel:SetEarninfoData(list)
	self.EarnInfoList = {};
	for i,info in ipairs(list) do 
		self.EarnInfoList[i] = info;
		self.EarnInfoList[i].id = info.cid;
	end;
end;

function ConsignmentModel:GetEarnInfoData()
	return self.EarnInfoList;
end;

-- 设置我的收益数量
function ConsignmentModel:SetEarnMoney(yuan,gold)
	self.MyInfo.EarnYuanBao = yuan;
	self.MyInfo.EarnGold = gold;
end;

function ConsignmentModel:GetEarnMoney()
	if self.MyInfo.EarnYuanBao and self.MyInfo.EarnGold then 
		return self.MyInfo.EarnYuanBao,self.MyInfo.EarnGold;
	end;
	return 0,0
end;




------------------------------  背包click数据
ConsignmentModel.BagItemInfo = nil;
function ConsignmentModel:SetUpItemBagClick(item)
	self.BagItemInfo = item;
end;

function ConsignmentModel:GetUpItemBagInfo()
	return self.BagItemInfo;
end;
