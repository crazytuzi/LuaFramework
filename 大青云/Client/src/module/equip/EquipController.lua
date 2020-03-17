--[[
装备熔炼相关
lizhuangzhuang
2014年11月13日16:18:17
]]

_G.EquipController = setmetatable({},{__index=IController});

EquipController.name = "EquipController";
--自动强化
EquipController.autoStrenId = nil;
EquipController.autoStrenAutoBuy = false;
EquipController.autoStrenKeepLvl = false;
EquipController.autoStrenitemLvUp = false;
EquipController.autoStrenToLvl = 0;
--强化掉级确定
EquipController.strenConfirm = true;
--强化前强化等级
EquipController.oldStrenLvl = 0;

function EquipController:Create()
	EquipUtil:Create();
	MsgManager:RegisterCallBack(MsgType.SC_EquipInfo,self,self.OnEquipInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_EquipSuper,self,self.OnEquipSuperList);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperLib,self,self.OnSuperLibList);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperHole,self,self.OnSuperHoleList);
	MsgManager:RegisterCallBack(MsgType.SC_EquipExtra,self,self.OnEquipExtraList);
	MsgManager:RegisterCallBack(MsgType.SC_EquipAdd,self,self.OnEquipInfoAdd);
	MsgManager:RegisterCallBack(MsgType.SC_EquipGem,self,self.OnEquipGemResult);
	-- MsgManager:RegisterCallBack(MsgType.SC_Stren,self,self.OnEquipStrenResult);
	MsgManager:RegisterCallBack(MsgType.SC_EquipPro,self,self.OnEquipProResult);
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGemUpLevelInfo,self,self.OnEquipGemUplevelInfo);  --宝石升级返回信息
	MsgManager:RegisterCallBack(MsgType.SC_EquipInherit ,self,self.OnEquipBackInherit);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperHoleUp,self,self.OnSuperHoleLvlUp);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperAttrDown,self,self.OnSuperAttrDown);
	MsgManager:RegisterCallBack(MsgType.SC_BuildAttrScroll,self,self.OnBuildAttrScroll);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperAttrUp,self,self.OnSuperAttrUp);
	-- MsgManager:RegisterCallBack(MsgType.SC_SuperLibRemove,self,self.OnSuperLibRemove);
	MsgManager:RegisterCallBack(MsgType.SC_EquipExtraInherit,self,self.OnExtraInherit);
	MsgManager:RegisterCallBack(MsgType.SC_ItemSuper,self,self.OnItemSuperList);
	MsgManager:RegisterCallBack(MsgType.SC_CreateSuperItem,self,self.OnCreateSuperItem);
	MsgManager:RegisterCallBack(MsgType.SC_UseItemSuper,self,self.OnUseItemSuper);
	MsgManager:RegisterCallBack(MsgType.SC_EquipNewSuper,self,self.OnEquipNewSuperList);
	-- 炼化
	MsgManager:RegisterCallBack(MsgType.SC_EquipRefiningList,				self,self.OnrefiningList);
	MsgManager:RegisterCallBack(MsgType.SC_EquipRefiningLvlUpResult,		self,self.OnRefiningLvlUpResult);
	MsgManager:RegisterCallBack(MsgType.SC_EquipRefiningAutoLvlUpResult,	self,self.OnRefiningAutoLvlUpResult);
	--
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroup,self,self.OnEquipGroup);
	--套装2
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroup2,self,self.OnEquipGroup2);
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupPeel,self,self.OnEquipGroupPeel);
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupLvlUp,self,self.OnEquipGroupLevelUp);
	--熔炼
	MsgManager:RegisterCallBack(MsgType.SC_EquipSmelt,self,self.OnEquipSmelt);
	--翅膀
	MsgManager:RegisterCallBack(MsgType.SC_WingInfo,self,self.OnWingInfo)
	-- MsgManager:RegisterCallBack(MsgType.SC_OpenSuperHole,self,self.OnOpenSuperHole);

	--卓越洗练
	MsgManager:RegisterCallBack(MsgType.SC_EquipNewSuperNewVal,self,self.SuperNewWashVal)
	MsgManager:RegisterCallBack(MsgType.SC_EquipNewSuperNewValSet,self,self.SaveSuperNewWashVal)

	--卓越精炼
	
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipSuperValWash,self,self.SuperValWash)
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipSuperValWashSave,self,self.SuperValWashSave)

	--套装养成
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupActiInfo,self,self.OnSetEquipGroupInfo)
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupOpenPos,self,self.OnSetEquipOpenPos)
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupOpenSet,self,self.OnSetEquipOpenSet)
	-- MsgManager:RegisterCallBack(MsgType.SC_EquipGroupUpLvl,self,self.OnSetEquipGroupLvl)

	-- 装备洗练
	MsgManager:RegisterCallBack(MsgType.SC_EquipWashInfo,self,self.SetEquipWashInfo)
	MsgManager:RegisterCallBack(MsgType.SC_EquipWashActivate,self,self.OnWashActiveResult)
	MsgManager:RegisterCallBack(MsgType.SC_EquipWashLevelUp,self,self.OnWashLvUpResult)
	MsgManager:RegisterCallBack(MsgType.SC_EquipWashRandom,self,self.OnWashChangeResult)

	-- 装备传承
	MsgManager:RegisterCallBack(MsgType.SC_EquipChuanCheng,self,self.OnRespResult)
end

------------处理换线，换场景，取消临时，自动data，or逻辑
function EquipController:BeforeLineChange()
	if UIEquipStren.isAutoLvlUp then
		UIEquipStren:CancelAutoStren();
	end
	if UIEquipSuperNewWash:IsShow() then 
		UIEquipSuperNewWash:ShowRight();
	end;
	if UIEquipSuperValWash:IsShow() then 
		UIEquipSuperValWash:ShowRight();
	end;
end

function EquipController:BeforeEnterCross()
	if UIEquipStren.isAutoLvlUp then
		UIEquipStren:CancelAutoStren();
	end
	if UIEquipSuperNewWash:IsShow() then 
		UIEquipSuperNewWash:ShowRight();
	end;
	if UIEquipSuperValWash:IsShow() then 
		UIEquipSuperValWash:ShowRight();
	end;
end

-------------------------------装备信息同步----------------------------------------
--装备附件信息
function EquipController:OnEquipInfoResult(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:AddEquipInfo(vo);
	end
end

--装备卓越信息
function EquipController:OnEquipSuperList(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:SetSuperVO(vo.id,vo);
	end
end

--道具新卓越属性信息
function EquipController:OnEquipNewSuperList(msg)
	 --新卓越属性，特殊处理
    for i,ao in ipairs(msg.list) do 
        for p,vo in  ipairs(ao.newSuperList) do 
            if vo.id > 0  and vo.wash == 0 then 
                local cfg = t_zhuoyueshuxing[vo.id];
                vo.wash = cfg and cfg.val or 0;
            end;    
        end;
    end;
    --
	for i,vo in ipairs(msg.list) do
		EquipModel:SetNewSuperVO(vo.id,vo);
	end
end

--道具卓越信息
function EquipController:OnItemSuperList(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:SetItemSuperVO(vo.itemId,vo);
	end
end

--装备卓越属性库
function EquipController:OnSuperLibList(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:SuperLibAdd(vo);
	end
end

--装备卓越孔信息
function EquipController:OnSuperHoleList(msg)
	for i,posVO in ipairs(msg.list) do
		for j,holeVO in ipairs(posVO.holeList) do
			EquipModel:SetSuperHoleAtIndex(posVO.pos,holeVO.index,holeVO.level);
		end
	end
end

--装备追加信息
function EquipController:OnEquipExtraList(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:SetExtra(vo.id,vo.level);
	end
end

--添加装备信息
function EquipController:OnEquipInfoAdd(msg)

	 --新卓越属性，特殊处理
    for p,vo in  ipairs(msg.newSuperList) do 
        if vo.id > 0  and vo.wash == 0 then 
            local cfg = t_zhuoyueshuxing[vo.id];
            vo.wash = cfg and cfg.val or 0;
        end;    
    end;
    --

	EquipModel:SetEquipInfo(msg.id,msg.strenLvl,msg.strenVal,msg.groupId,msg.groupId2,msg.groupId2Bind,msg.group2Level, msg.emptystarnum);
	EquipModel:SetExtra(msg.id,msg.attrAddLvl);
	-- local superVO = {};
	-- superVO.id = msg.id;
	-- superVO.superNum = msg.superNum;
	-- superVO.superList = msg.superList;
	-- EquipModel:SetSuperVO(msg.id,superVO);
	EquipModel:setWashInfo(msg.id, msg.superNum, msg.superList)
	local newSuperVO = {};
	newSuperVO.id = msg.id;
	newSuperVO.newSuperList = msg.newSuperList;
	EquipModel:SetNewSuperVO(msg.id,newSuperVO);
end

--装备宝石信息
function EquipController:OnEquipGemResult(msg)
	for i,vo in pairs(msg.list) do
		EquipModel:SetGemInfo(vo.id,vo.lvl);
	end
end

--------------------------------装备强化-------------------------------------------
--请求装备强化
--@return 可以强化返回true,反之false
function EquipController:StrenEquip(id,autoBuy,keepLvl,itemLvlUp)
	local strenLvl = EquipModel:GetStrenLvl(id);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	--强化升星符打造
	if itemLvlUp then
		local itemLvlUpId = 0;
		if strenLvl+1 > EquipConsts.StrenMaxStar then
			itemLvlUpId = EquipConsts.itemJZLvlUpId;
		else
			itemLvlUpId = EquipConsts.itemLvlUpId;
		end
		--强化升星符数量
		local needItemCurrNum = BagModel:GetItemNumInBag(itemLvlUpId);
		if needItemCurrNum < 1 then
			FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
			return false;
		end
		self:DoSendStrenMsg(id,autoBuy,keepLvl,itemLvlUp);
		return true;
	end
	--金币
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		FloatManager:AddNormal(StrConfig["equip505"]);--银两不足
		return;
	end
	--强化道具数量
	local needItemCurrNum = BagModel:GetItemNumInBag(cfg.itemId);
	if needItemCurrNum < cfg.itemNum then
		if autoBuy then
			local canBuyNum = MallUtils:GetMoneyShopMaxNum(cfg.itemId);
			if needItemCurrNum + canBuyNum < cfg.itemNum then
				FloatManager:AddNormal(StrConfig["equip506"]);--元宝不足，无法购买
				if UIEquipStren:IsShow() then
					-- UIShopQuickBuy:Open(cfg.itemId, UIEquip,UIEquip:GetShopContainer(), cfg.itemNum-needItemCurrNum);
				end
				return;
			end
		else
			FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
			if UIEquipStren:IsShow() then
				-- UIShopQuickBuy:Open( cfg.itemId, UIEquip,UIEquip:GetShopContainer(), cfg.itemNum-needItemCurrNum);
			end
			return;
		end
	end
	--防掉级道具
	if cfg.keepItem > 0 then
		--不再提示
		if not self.strenConfirm then
			self:DoSendStrenMsg(id,autoBuy,keepLvl);
			return true;
		end
		if keepLvl then
			if BagModel:GetItemNumInBag(cfg.keepItem) >= cfg.keepNum then
				self:DoSendStrenMsg(id,autoBuy,keepLvl);
				return true;
			else
				local canBuyNum = MallUtils:GetMoneyShopMaxNum(cfg.keepItem);
				if BagModel:GetItemNumInBag(cfg.keepItem)+canBuyNum < cfg.keepNum then
					FloatManager:AddNormal(StrConfig["equip122"],UIEquipStren:GetStrenBtn());--防掉级道具不足
					return false;
				else
					self:DoSendStrenMsg(id,autoBuy,keepLvl);
					return true;
				end
			end
		else
			--提示可能掉级
			UIConfirmWithNoTip:Open(StrConfig['equip121'],function(noTip)
				self.strenConfirm = not noTip;
				self:DoSendStrenMsg(id,autoBuy,keepLvl);
			end,function()
				if UIEquipStren.isAutoLvlUp then
					UIEquipStren:CancelAutoStren();
				end
			end);
			return true;
		end
	else
		self:DoSendStrenMsg(id,autoBuy,keepLvl,itemLvlUp);
		return true;
	end
end

function EquipController:DoSendStrenMsg(id,autoBuy,keepLvl,itemLvlUp)
	local strenLvl = EquipModel:GetStrenLvl(id);
	self.oldStrenLvl = strenLvl;
	local msg = ReqStrenMsg:new();
	msg.id = id;
	msg.autoBuy = autoBuy and 1 or 0;
	msg.keepLv = keepLvl and 1 or 0;
	msg.itemLvUp = itemLvlUp and 1 or 0;
	MsgManager:Send(msg);
end

--自动强化
function EquipController:AutoStrenEquip(id,autoBuy,keepLvl,toLvl,itemLvlUp)
	self.autoStrenId = id;
	self.autoStrenAutoBuy = autoBuy;
	self.autoStrenKeepLvl = keepLvl;
	self.autoStrenToLvl = toLvl;
	self.autoStrenitemLvUp = itemLvlUp;
	local strenLvl = EquipModel:GetStrenLvl(id);
	if strenLvl >= toLvl then return; end
	if not self:StrenEquip(id,autoBuy,keepLvl,itemLvlUp) then
		UIEquipStren:CancelAutoStren();
	end
end

--返回装备强化
function EquipController:OnEquipStrenResult(msg)
	local oldStrenVal = EquipModel:GetStrenVal(msg.id);
	EquipModel:SetStrenInfo(msg.id,msg.strenLvl,msg.strenVal);
	if msg.result == -1 then--条件不足导致的失败
		if UIEquipStren.isAutoLvlUp then
			UIEquipStren:CancelAutoStren();
		end
	end
	if UIEquipStren.isAutoLvlUp then
		if msg.strenLvl < self.autoStrenToLvl then
			TimerManager:RegisterTimer(function()
				if not UIEquipStren.isAutoLvlUp then return; end
				if not self:StrenEquip(self.autoStrenId,self.autoStrenAutoBuy,self.autoStrenKeepLvl,self.autoStrenitemLvUp) then
					UIEquipStren:CancelAutoStren();
				end
			end,500,1);
		else
			UIEquipStren:CancelAutoStren();
		end
	end
	if UIEquipStren:IsShow() then
		UIEquipStren:OnStrenResult(msg.id,msg.result,msg.strenLvl,msg.strenVal,self.oldStrenLvl,oldStrenVal);
	end
end

------------------------------------------------------------------------------------
--------------------------------------装备升品--------------------------------------
--请求升品
function EquipController:EquipPro(id,equiplist)
	local msg = ReqEquipProMsg:new();
	msg.id = id;
	msg.list = equiplist;
	MsgManager:Send(msg);
end

--返回升品
function EquipController:OnEquipProResult(msg)
	if msg.result < 0 then
		return;
	end
	if msg.result == 0 or msg.result == 1 then
		SoundManager:PlaySfx(2007);
		EquipModel:SetProVal(msg.id,msg.proVal,msg.result)
		--trace(msg)
		return;
	end
	
end
-------------------------------宝石------------------------------------
--  宝石升品结果
function EquipController:OnEquipGemUplevelInfo(msg)
	if msg.result < 0 then 
		FloatManager:AddNormal(StrConfig["equip313"]);
		local cfg = t_equipgem[msg.pos]
		if not cfg then return end
		local item = split(cfg.celerityshop, "#")
		UIQuickBuyConfirm:Open(self,toint(item[msg.slot]))
		return;
	end;
	if msg.result == 0 then 
		EquipModel:SetGemInfo(msg.id,msg.gemlvl,true)
		SoundManager:PlaySfx(2008);
	end
end;

--  宝石升级请求
function EquipController:OnGemGoUpLevel(id,autobuy)
	-- 条件检测
	local cofg = EquipModel:GetGemServerinfo(id);-- 获取某个宝石信息
	local cfg = nil;
	if cofg then  
		local lvl = cofg.lvl + 1;
		if lvl >= 10 then 
			lvl = 10;
		 end;
		cfg = t_gemcost[lvl] --根据宝石等级，获得宝石信息
	else
		cfg = t_gemcost[1]
	end;
	-- 银两：绑定金币+非绑定金币
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.money then  
		FloatManager:AddSysNotice(2007001);--银两不足，无法强化
	return 
	end;

	if cfg.direct_item > 0 then 
		local NbItemNum = BagModel:GetItemNumInBag(cfg.direct_item);
		if NbItemNum >= cfg.direct_num then 
			--有优先使用道具,改道具不可自动购买
			autobuy = false;
			if autobuy == true then 
				autobuy = 0;
			elseif autobuy == false then 
				autobuy = -1;
			end;
			local msg = ReqEquipGemUpLevelMsg:new();
			msg.id = id;
			msg.autoBuy = autobuy;
			MsgManager:Send(msg);
			return 
		end;
	end;

	-- 道具数量
	local itemNum = BagModel:GetItemNumInBag(cfg.item) 
	if itemNum < cfg.num then 
		if autobuy then 
			local canbuy = MallUtils:GetMoneyShopMaxNum(cfg.item);
			if  not canbuy then 
				canbuy = 0
			 end; 
			if itemNum + canbuy < cfg.num then 
				FloatManager:AddSysNotice(2007003);--元宝不足，无法购买
				if UIEquipGem:IsShow() then
					-- UIShopQuickBuy:Open( cfg.item, UIEquip,UIEquip:GetShopContainer(), cfg.num-itemNum);
				end
				return;
			end;
		else
		-- 材料不足
			FloatManager:AddNormal(StrConfig["equip313"]);
			--FloatManager:AddSysNotice(2013001);--材料不足 
			if UIEquipGem:IsShow() then
				-- UIShopQuickBuy:Open( cfg.item, UIEquip,UIEquip:GetShopContainer(), cfg.num-itemNum);
			end
			return;
		end;
	end;

	if autobuy == true then 
		autobuy = 0;
	elseif autobuy == false then 
		autobuy = -1;
	end;
	local msg = ReqEquipGemUpLevelMsg:new();
	msg.id = id;
	msg.autoBuy = autobuy;
	MsgManager:Send(msg);
end;

-----------------------------------------------------------------------------------
-----------------------------------装备传承----------------------------------------
--装备传承
function EquipController:OnEquipInherit(srcid,tarid,autoBuy)
	local msg = ReqEquipInheritMsg:new();
	msg.srcid = srcid;
	msg.tarid = tarid;
	if autoBuy then msg.autoBuy = 1; else msg.autoBuy = 0; end
	MsgManager:Send(msg);
end
--返回装备传承
function EquipController:OnEquipBackInherit(msg)
	if msg.result == 0 then
		FloatManager:AddCenter(StrConfig["equip262"]);
	end
	UIEquipInherit:OnStrenInheirtResult(msg.result,msg.srcid,msg.tarid);
	Debug(msg.srcid,msg.tarid,msg.result)
	SoundManager:PlaySfx(2017);
end

---------------------------------装备卓越-----------------------------------------
--卓越孔升级
function EquipController:SuperHoleLevelUp(pos,index,autoBuy)
	local level = EquipModel:GetSuperHoleAtIndex(pos,index);
	if level >= EquipConsts.SuperHoleMaxLvl then
		FloatManager:AddNormal(StrConfig["equip504"]);
		return;
	end
	local cfg = t_superHoleUp[level+1];
	--金币
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		FloatManager:AddNormal(StrConfig["equip505"]);
		return;
	end
	--道具
	local itemNum = BagModel:GetItemNumInBag(cfg.itemId) 
	if itemNum < cfg.itemNum then 
		if autoBuy then 
			local canbuy = MallUtils:GetMoneyShopMaxNum(cfg.itemId);
			if itemNum + canbuy < cfg.itemNum then 
				FloatManager:AddNormal(StrConfig["equip506"]);
				return;
			end;
		else
			FloatManager:AddNormal(StrConfig["equip507"]); 
			return;
		end;
	end;
	local msg = ReqSuperHoleUpMsg:new();
	msg.pos = pos;
	msg.index = index;
	msg.autoBuy = autoBuy and 0 or 1;
	MsgManager:Send(msg);
end

--返回卓越孔升级
function EquipController:OnSuperHoleLvlUp(msg)
	EquipModel:SetSuperHoleAtIndex(msg.pos,msg.index,msg.level);
end

--请求卸载卓越属性
function EquipController:SuperAttrDown(bag,pos,index)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return; end
	local item	= bagVO:GetItemByPos(pos);
	if not item then return; end
	local vo = EquipModel:GetSuperAtIndex(item:GetId(),index);
	if not vo then 
		FloatManager:AddNormal(StrConfig["equip610"]);
		return; 
	end
	if vo.id == 0 then 
		FloatManager:AddNormal(StrConfig["equip610"]);
		return; 
	end
	if vo.lock == 1 then
		FloatManager:AddNormal(StrConfig["equip620"]);
		return;
	end
	--
	if #EquipModel.superLib >= EquipConsts:SuperLibMaxNum() then
		FloatManager:AddNormal(StrConfig["equip611"]);
		return;
	end
	local cfg = t_fujiafix[item:GetCfg().level*10+item:GetCfg().quality];
	--金币
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.downGold then
		FloatManager:AddNormal(StrConfig["equip505"]);
		return;
	end
	local msg = ReqSuperAttrDownMsg:new();
	msg.eid = item:GetId();
	msg.index = index;
	MsgManager:Send(msg);
end

--返回卸载卓越属性
function EquipController:OnSuperAttrDown(msg)
	if msg.result == 0 then
		local removeVO = EquipModel:RemoveSuperAtIndex(msg.eid,msg.index);
		if not removeVO then return; end
		local vo = {};
		vo.uid = removeVO.uid;
		vo.id = removeVO.id;
		vo.val1 = removeVO.val1;
		EquipModel:SuperLibAdd(vo);
		UIEquipSuperDown:OnSuperAttrDown(msg.eid,msg.index);
	elseif msg.result == 1 then
		FloatManager:AddCenter(StrConfig["equip611"]);
	else
		print('Error装备卓越剥离失败,未处理的错误.',msg.result);
	end
end

EquipController.waitBuildScrolllist = nil
function EquipController:ReqBuildAttrScroll(list)
	QuestController:TestTrace("请求生成附加属性")
	QuestController:TestTrace(list)
	self.waitBuildScrolllist = list
	local msg = ReqBuildAttrScrollMsg:new()
	msg.list = list
	MsgManager:Send(msg);
end

-- 生成附加属性结果
function EquipController:OnBuildAttrScroll(msg)
	QuestController:TestTrace("生成附加属性结果")
	QuestController:TestTrace(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["equip635"]);
		local list = self.waitBuildScrolllist
		if list and #list > 0 then
			for _, vo in pairs(list) do
				EquipModel:SuperLibRemove(vo.uid)
			end
		end
	end
	self.waitBuildScrolllist = nil
end

--请求安装卓越属性
function EquipController:SuperAttrUp(uid,bag,pos,index,autoBuy)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	--判断库
	local libVO = EquipModel:GetSuperLibVO(uid);
	if not libVO then
		FloatManager:AddNormal(StrConfig["equip612"]);
		return;
	end	
	--金币
	local cfg = t_fujiafix[item:GetCfg().level*10+item:GetCfg().quality];
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		FloatManager:AddNormal(StrConfig["equip505"]);
		return;
	end
	--道具
	local itemNum = BagModel:GetItemNumInBag(cfg.itemId) 
	if itemNum < cfg.itemNum then 
		if autoBuy then 
			local canbuy = MallUtils:GetMoneyShopMaxNum(cfg.itemId);
			if itemNum + canbuy < cfg.itemNum then 
				FloatManager:AddNormal(StrConfig["equip506"]);
				return;
			end;
		else
			FloatManager:AddNormal(StrConfig["equip507"]); 
			return;
		end;
	end;
	local func = function()
		local msg = ReqSuperAttrUpMsg:new();
		msg.uid = uid;
		msg.eid = item:GetId();
		msg.index = index;
		msg.autoBuy = autoBuy and 0 or 1;
		MsgManager:Send(msg);
	end
	--判断目标
	local targetVO = EquipModel:GetSuperAtIndex(item:GetId(),index);
	if targetVO then
		UIConfirm:Open(StrConfig['equip618'],function()
			func();
		end);
	else
		func();
	end
end

--返回安装卓越属性
function EquipController:OnSuperAttrUp(msg)
	if msg.result == 0 then
		local removeVO = EquipModel:SuperLibRemove(msg.uid);
		if not removeVO then return; end
		local vo = {};
		vo.uid = removeVO.uid;
		vo.id = removeVO.id;
		vo.val1 = removeVO.val1;
		EquipModel:SetSuperAtIndex(msg.eid,msg.index,vo);
		UIEquipSuperUp:OnSuperAttrUp(msg.eid,msg.index);
		SoundManager:PlaySfx(2052);
	elseif msg.result == 1 then
		FloatManager:AddCenter(StrConfig["equip614"]);
	else
		print('Error装备卓越铭刻失败,未处理的错误.',msg.result);
	end
end

--请求从卓越属性库删除
function EquipController:SuperLibRemove(list)
	-- local vo = EquipModel:GetSuperLibVO(uid);
	-- if not vo then 
	-- 	FloatManager:AddNormal(StrConfig["equip612"]);
	-- 	return; 
	-- end
	local msg = ReqSuperLibRemoveMsg:new();
	msg.list = list;
	MsgManager:Send(msg);
end

--返回从卓越属性库删除
function EquipController:OnSuperLibRemove(msg)
	local sta = 0;
	for i,info in ipairs(msg.list) do 
		if info.result then 
			EquipModel:SuperLibRemove(info.uid);
			if sta == 0 then 
				sta = 1;
				FloatManager:AddNormal(StrConfig["equip625"]);
			end;
		end;
	end;
	-- if msg.result == 0 then
	-- 	EquipModel:SuperLibRemove(msg.uid);
	-- else
	-- 	print('Error.卓越属性库删除,未处理的错误.',msg.result);
	-- end
end

--请求创建卓越卷轴
function EquipController:CreateSuperItem(uid)
	local vo = EquipModel:GetSuperLibVO(uid);
	if not vo then 
		FloatManager:AddNormal(StrConfig["equip612"]);
		return; 
	end
	local msg = ReqCreateSuperItemMsg:new();
	msg.uid = uid;
	MsgManager:Send(msg);
end

--返回创建卓越卷轴
function EquipController:OnCreateSuperItem(msg)
	if msg.result == 0 then
		EquipModel:SuperLibRemove(msg.libUid);
		UIEquipSuperItemGet:Open(msg.itemUid);
	else
		print('Error.创建卓越道具失败,未处理的错误.',msg.result);
	end
end

--返回道具生成卓越属性
function EquipController:OnUseItemSuper(msg)
	if msg.result ~= 0 then return; end
	UIEquipSuperAttrGet:Open(msg.id,msg.val1);
end
----------------------------------------------------------------------------------

--------------------------------装备追加------------------------------------------
--请求追加属性传承
function EquipController:ExtraInherit(srcId,tarId,state)
	local msg = ReqEquipExtraInheritMsg:new();
	msg.srcId = srcId;
	msg.tarId = tarId;
	if state then
		msg.state = 1;
	else
		msg.state = 0;
	end
	MsgManager:Send(msg);
end

--返回追加属性传承
function EquipController:OnExtraInherit(msg)
	if msg.result == 0 then
		FloatManager:AddCenter(StrConfig["equip261"]);
		local srcLvl = EquipModel:GetExtraLvl(msg.srcId);
		local tarLvl = EquipModel:GetExtraLvl(msg.tarId);
		EquipModel:SetExtra(msg.srcId,tarLvl);
		EquipModel:SetExtra(msg.tarId,srcLvl);
		Notifier:sendNotification( NotifyConsts.EquipInherEffect );
	else
		print("追加传承失败",msg.result);
	end
end
---------------------------------------------------------------------------------


---------------------------------------炼化--------------------------------
function EquipController:OnrefiningList(msg)
	for i,vo in pairs(msg.Refining) do
		EquipModel:SetRefinInfo(vo.id,vo.pos);
	end
	Notifier:sendNotification(NotifyConsts.EquipRefinUpdata);
end;

function EquipController:OnRefiningLvlUpResult(msg)
	if msg.result == 0 then 
		VipModel:SetIsChange(VipConsts.TYPE_QIANGHUA,true);
		-- 成功
		FloatManager:AddNormal(StrConfig["equip905"])
	else
		FloatManager:AddNormal(StrConfig["equip908"])
	end;
end;

function EquipController:OnRefiningAutoLvlUpResult(msg)
	if msg.result == 0 then 
		VipModel:SetIsChange(VipConsts.TYPE_QIANGHUA,true);
		-- 成功
		FloatManager:AddNormal(StrConfig["equip906"])
		if UIRefinView:IsShow() == true then 
			UIRefinView:OnResultShowFpx(msg.itemlist)
		end;
		SoundManager:PlaySfx(2034);
	elseif msg.result == 1 then 
		--UILingLiGet:Show();
		SoundManager:PlaySfx(2056);
		FloatManager:AddNormal(StrConfig["equip904"])
	elseif msg.result == 2 then 
		SoundManager:PlaySfx(2056);
		FloatManager:AddNormal(StrConfig["equip910"])
	elseif msg.result == 3 then 
		SoundManager:PlaySfx(2056);
		FloatManager:AddNormal(StrConfig["equip911"])
	elseif msg.result == 4 then 
		SoundManager:PlaySfx(2056);
		FloatManager:AddNormal(StrConfig["equip00000001"])
	else
		FloatManager:AddNormal(StrConfig["equip908"])
	end;
end;

function EquipController:ReqRefinLvlUp(pos)
	local msg = ReqEquipRefininglvlUpMsg:new();
	msg.pos = pos;
	MsgManager:Send(msg)
end;

function EquipController:ReqrefinAutoLvlUp()
	local msg = ReqEquipRefiningAutolvlUpMsg:new();
	MsgManager:Send(msg)
end;


--请求剥离套装
function EquipController:OnRepEquipGroupPeel(equipId)
	local msg = ReqEquipGroupPeelMsg:new();
	msg.equipId = equipId;
	MsgManager:Send(msg);
	-- trace(msg)
	-- print("请求剥离")
end;	

--返回剥离装备套装
function EquipController:OnEquipGroupPeel(msg)
	-- trace(msg)
	-- print("返回剥离")
	if msg.result == 0 then 
		EquipModel:SetGroupId2(msg.equipId,0);
		EquipModel:SetEquipGroupLevel(msg.equipId,0);
		FloatManager:AddNormal(StrConfig['equipgroup007']);
		if UIEquipGroupPeel:IsShow() then 
			UIEquipGroupPeel:UpdataUI()
		end;
	elseif msg.result == 1 then 
		FloatManager:AddNormal(StrConfig['equipgroup001']);
	elseif msg.result == 2 then 
		FloatManager:AddNormal(StrConfig['equipgroup008']);
	end;
end;

--请求更改新套装
function EquipController:ChangeEquipGroup2(equipId,groupId,isBind)
	local msg = ReqEquipGroup2Msg:new();
	msg.equipId = equipId;
	msg.groupId = groupId;
	msg.isBind = isBind;
	MsgManager:Send(msg)
	-- trace(msg)
	-- print("请求更改新套装")
end;

--新套装结果
function EquipController:OnEquipGroup2(msg)

	-- trace(msg)
	-- print("新套装，更改结果")
	if msg.result == 0 then
		-- trace(msg)
		EquipModel:SetGroupId2(msg.equipId,msg.groupId,msg.groupIdBind);
		if UIEquipGroupChange:IsShow() then 
			UIEquipGroupChange:PlayCompleteFpx()
		end;
		FloatManager:AddNormal(StrConfig['equipgroup005']);
	elseif msg.result == 1 then
		--装备不存在
		FloatManager:AddNormal(StrConfig['equipgroup001']);
	elseif msg.result == 2 then
		--道具不足
		FloatManager:AddNormal(StrConfig['equipgroup002']);
	elseif msg.result == 3 then
		--道具无法使用
		FloatManager:AddNormal(StrConfig['equipgroup003']);
	elseif msg.result == 4 then 
		--已有套装
		FloatManager:AddNormal(StrConfig['equipgroup004']);
	else
		print("Error:设置装备套装,未处理的错误",msg.result);
	end
end;

--请求更改装备套装
function EquipController:ChangEquipGroup(equipId,itemId)
	local msg = ReqEquipGroupMsg:new();
	msg.equipId = equipId;
	msg.itemId = itemId;
	MsgManager:Send(msg);
end

--返回更改装备套装
function EquipController:OnEquipGroup(msg)
	if msg.result == 0 then
		local cfg = t_item[msg.itemTid];
		if cfg then
			EquipModel:SetGroupId(msg.equipId,cfg.use_param_1);
		end
		local groupCfg = t_equipgroup[cfg.use_param_1];
		if groupCfg then
			FloatManager:AddNormal(string.format(StrConfig['equip1002'],groupCfg.name));
		end
		if UIEquipGroup:IsShow() then
			UIEquipGroup:Hide();
		end
	elseif msg.result == 1 then
		print('error1');
	elseif msg.result == 2 then
		print('error2');
	elseif msg.result == 3 then
		print('error3');
	else
		print("Error:设置装备套装,未处理的错误",msg.result);
	end
end

-----------------------------------------升级---------------------------------------
---[[
-- 客户端请求：套装升级
function EquipController:ReqEquipGroupLevelUp(equipId, isBind)
	local msg = ReqEquipGroupLvlUpMsg:new()
	msg.equipId = equipId
	msg.isBind = isBind
	MsgManager:Send(msg)
	QuestController:TestTrace("客户端请求:套装升级")
end

-- 服务器返回:套装升级
function EquipController:OnEquipGroupLevelUp(msg)
	QuestController:TestTrace("服务器返回:套装升级")
	QuestController:TestTrace(msg)
	local result = msg.result
	if result == 0 then -- 成功
		EquipModel:SetEquipGroupLevel( msg.equipId, msg.equipLevel )
		if UIEquipGroupLvlUp:IsShow() then 
			UIEquipGroupLvlUp:PlayCompleteFpx()
		end;
	end
end
--]]

-----------------------------------------熔炼----------------------------------------
function EquipController:OnEquipSmelt(msg)
	EquipModel:UpDataSmelting(msg.id,msg.exp,msg.flags)
	Notifier:sendNotification( NotifyConsts.EquipSmeltingData );
end

function EquipController:OnSendEquipSmelting(smeltlist,flags)
	local msg = ReqEquipSmeltMsg:new();
	msg.smeltlist = smeltlist;
	msg.flags = flags;
	MsgManager:Send(msg);
end


--//自动熔炼
function EquipController:OnAotuSmelting(item)
	local equipCfg = t_equip[item:GetTid()];
	if not equipCfg then return end
	local quality = equipCfg.quality;
	local flags = EquipModel:GetSmeltFlags();
	for i = 1 , 3 do
		if bit.band(flags,math.pow(2,i)) == math.pow(2,i) then
			if EquipConsts.QualityConsts[i] == quality then
				local list ={};
				local vo = {};
				vo.guid = item:GetId();
				table.push(list,vo);
				self:OnSendEquipSmelting(list,flags)
			end
		end
	end
end

--翅膀信息
function EquipController:OnWingInfo(msg)
	for i,vo in ipairs(msg.list) do
		EquipModel:SetWingInfo(vo.itemId,vo.time,vo.attrFlag);
	end
end

--开卓越孔
function EquipController:OpenSuperHole(eId)
	local msg = ReqOpenSuperHoleMsg:new();
	msg.eId = eId;
	msg.itemTid = EquipConsts:GetSuperHoleItem();
	MsgManager:Send(msg);
end

function EquipController:OnOpenSuperHole(msg)
	if msg.result == 0 then
		EquipModel:SetSuperHoleNum(msg.eId,msg.superNum);
	else
		FloatManager:AddNormal(StrConfig['equip1203']);
	end
end


--卓越洗练

function EquipController:SuperNewWashVal(msg)
	--trace(msg)
	--print("返回临时数据")
	if msg.result == 0 then 
		EquipModel:SetWashValTemporaryData(msg.cid,msg.id,msg.wash,msg.idx)
	elseif msg.result == -1 then 
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	end;
end;

function EquipController:SaveSuperNewWashVal(msg)
	--trace(msg)
	--print("返回保存数据")
	if msg.result == 0 then 
		local vo = {};
		vo.id = msg.id;
		vo.wash = msg.wash;
		EquipModel:SetNewSuperAtIndex(msg.cid,msg.idx,vo)
		
		if UIEquipSuperNewWash:IsShow() then 
			UIEquipSuperNewWash:ShowRight();
		end;
		
		FloatManager:AddNormal(StrConfig["equipWash003"]);
	end;
end;

function EquipController:UpSuperNewWash(cid,idx)
	local msg = ReqEquipNewSuperNewValMsg:new()
	msg.cid = cid;
	msg.idx = idx;
	MsgManager:Send(msg)
	-- trace(msg)
	-- print("请求临时")
end;

function EquipController:SaveSuperNewWash(cid,idx)
	local msg = ReqEquipNewSuperNewValSetMsg:new()
	msg.cid = cid;
	msg.idx = idx;
	MsgManager:Send(msg)
	-- trace(msg)
	-- print("请求保存")

end;

---卓越洗练
--临时
function EquipController:SuperValWash(msg)
	-- trace(msg)
	-- print("进啊哈哈就啊哈哈啊")
	local _type = msg.type ;
	if _type == 2 then
		if msg.result == 5 then
			FloatManager:AddNormal(StrConfig["equip1002"]);--最大值
			return
		end
		Notifier:sendNotification(NotifyConsts.EquipSeniorJinglianLose);
		return
	end
	if msg.result == 0 then 
		EquipModel:SetWashJInglian(msg.cid,msg.id,msg.wash,msg.idx)
	elseif msg.result == -1 then 
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	elseif msg.result == -4 then 
		FloatManager:AddNormal(StrConfig["equip633"]);--道具不足
	end;
end;

--保存
function EquipController:SuperValWashSave(msg)
	local _type = msg.type;
	if _type == 2 then
		local vo = {};
		vo.id = msg.id;
		vo.wash = msg.wash;
		EquipModel:SetNewSuperAtIndex(msg.cid,msg.idx,vo)
		Notifier:sendNotification(NotifyConsts.EquipSeniorJinglian,{idx = msg.idx});
		return
	end
	if msg.result == 0 then 
		local vo = {};
		vo.id = msg.id;
		vo.wash = msg.wash;
		EquipModel:SetNewSuperAtIndex(msg.cid,msg.idx,vo)
		
		if UIEquipSuperValWash:IsShow() then 
			UIEquipSuperValWash:ShowRight();
		end;
		
		FloatManager:AddNormal(StrConfig["equipWash003"]);
	end;
end;

function EquipController:UpSuperNewJinglian(cid,idx,washType)
	local msg = ReqEquipSuperValWashMsg:new()
	msg.cid = cid;
	msg.idx = idx;
	msg.washType = washType;
	MsgManager:Send(msg)
end;

function EquipController:SaveSuperNewJinglian(cid,idx)
	local msg = ReqEquipSuperValWashSaveMsg:new()
	msg.cid = cid;
	msg.idx = idx;
	MsgManager:Send(msg)
end;

-----------------------------------套装养成
--设置套装养成属性
function EquipController:OnSetEquipGroupInfo(msg)
	--print('------------收到套装养成协议')
	for i,info in ipairs(msg.list) do 
		EquipModel:SetEquipGroupInfo(info.pos,info.index,info.lvl)
	end;
end;

--设置套装装备位置
function EquipController:OnSetEquipOpenPos(msg)
	--trace(msg)
	--print('设置套装装备位置')
	if msg.result == 0 then 
		EquipModel:SetEquipGroupInfo(msg.pos,msg.index,-1) --开孔
		Notifier:sendNotification( NotifyConsts.EquipGroupActivation );
		UIEquipGroupActivation:UpdataFpxShow(1,msg.index)
	elseif msg.result == -1 then 
		--道具不足
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	elseif msg.result == -2 then 
		--不可开启
		FloatManager:AddNormal(StrConfig["equip2002"]);--道具不足
	elseif msg.result == -3 then 
		--已达可开启上线
		FloatManager:AddNormal(StrConfig["equip2003"]);--道具不足
	end;
end;

--设置套装装备位套装
function EquipController:OnSetEquipOpenSet(msg)
	--trace(msg)
	--print('设置套装装备位套装')
	if msg.result == 0 then 
		EquipModel:SetEquipGroupInfo(msg.pos,msg.index,0) --镶嵌
		Notifier:sendNotification( NotifyConsts.EquipGroupActivation );
		UIEquipGroupActivation:UpdataFpxShow(2,msg.index)
	elseif msg.result == -1 then 
		--道具不足，
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	elseif msg.result == -2 then 
		--2不可开启
	end;
end;

--设置套装等级
function EquipController:OnSetEquipGroupLvl(msg)
	--trace(msg)
	--print('设置套装等级')
	if msg.result == 0 then 
		EquipModel:SetEquipGroupInfo(msg.pos,msg.index,msg.lvl) --升级
		Notifier:sendNotification( NotifyConsts.EquipGroupActivation );
		UIEquipGroupActivation:UpdataFpxShow(3,msg.index)
	elseif msg.result == -1 then 
		--道具不足，
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	elseif msg.result == -2 then 
		--2不可开启
	end;
end;


function EquipController:ReqOpenPos(pos,index)
	index = index - 1;
	local msg = ReqEquipGroupOpenPosMsg:new()
	msg.pos = pos;
	msg.index = index;
	MsgManager:Send(msg)
end;

function EquipController:ReqSetPosData(pos,index)
	index = index - 1;
	local msg = ReqEquipGroupOpenSetMsg:new()
	msg.pos = pos;
	msg.index = index;
	MsgManager:Send(msg)
end;

function EquipController:ReqLvlUpGroup(pos,index) 
	index = index - 1;
	local msg = ReqEquipGroupUpLvlMsg:new();
	msg.pos = pos;
	msg.index = index;
	MsgManager:Send(msg)
end;




----------------------------------------------------------------------装备洗练-------------------------------------------------------------------------
function EquipController:SetEquipWashInfo(msg)
	for k, v in pairs(msg.list) do
		EquipModel:setWashInfo(v.id, v.superNum, v.superList)
	end
end

function EquipController:OnWashActiveResult(msg)
	if msg.result == 0 then
		-- 激活成功
		Notifier:sendNotification(NotifyConsts.WashActive)
	end
end

function EquipController:OnWashLvUpResult(msg)
	if msg.result == 0 then
		-- 升级成功
		Notifier:sendNotification(NotifyConsts.WashUpdate, {msg.id, msg.uid})
	else
		FloatManager:AddNormal("洗炼失败")
	end
end

function EquipController:OnWashChangeResult(msg)
	if msg.result == 0 then
		-- 洗练成功
		Notifier:sendNotification(NotifyConsts.WashChange, {msg.id, msg.uid})
	end
end

function EquipController:ReqWashActive(id) 
	local msg = ReqEquipWashActivateMsg:new();
	msg.id = id
	MsgManager:Send(msg)
end

function EquipController:ReqWashLvUp(id)
	local msg = ReqEquipWashLevelUpMsg:new();
	msg.id = id
	MsgManager:Send(msg)
end

function EquipController:ReqWashChangeAtt(id, uid)
	local msg = ReqEquipWashRandomMsg:new();
	msg.id = id
	msg.uid = uid
	MsgManager:Send(msg)
end


----------------------------------------------装备传承--------------------------------------------------------------
function EquipController:OnRespResult(msg)
	if msg.result == 0 then
		-- 传承成功
		-- msg.srccid   msg.destcid
		Notifier:sendNotification(NotifyConsts.RespSuccess)
	end
end

-- type  1 升星  2 洗练    3  升星 洗练
function EquipController:ReqEquipResp(srccid, destcid, type)
	local msg = ReqEquipChuanChengMsg:new();
	msg.srccid = srccid
	msg.destcid = destcid
	msg.operation = type
	MsgManager:Send(msg)
end