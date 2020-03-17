--物品

_G.BagItem = {}

--Flag标记位
BagItem.Flag_Bind = 1;--第一位,0未绑定/1绑定
BagItem.Flag_Lock = 2;--第二位,0未锁定/1交易锁定

--
--@param id		唯一id
--@param tid	表里的物品id
--@param count	物品数量
--@param bagType背包类型
--@param pos	格子位置
--@param useCnt 当前使用次数
--@param todayUse 当天使用次数
--@param param1 --多用参数  针对圣物为圣物等级或天神资质
--@param param2 --多用参数  暂时针对天神卡为产出地图
--@param param4 --多用参数  暂时针对 圣物 天神激活卡 为生成时间
--@param flags	
function BagItem:new(id,tid,count,bagType,pos,useCnt,todayUse,flags, param1, param2, param4)
	local obj = {}
	for k,v in pairs(BagItem) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.id = id;
	obj.tid = tid;
	obj.count = count;
	obj.bagType = bagType;
	obj.pos = pos;
	obj.useCnt = useCnt;
	obj.todayUse = todayUse;
	obj.flags = toint32(flags);
	obj.param1 = param1
	obj.param2 = param2
	obj.param4 = param4
	return obj
end

--唯一id
function BagItem:GetId()
	return self.id;
end

-- 获取道具特殊参数
function BagItem:GetParam()
	return self.param1
end

-- 设置参数
function BagItem:SetParam(param1)
	self.param1 = param1
end

--获取参数2
function BagItem:GetParam2()
	return self.param2
end

--设置参数2
function BagItem:SetParam2(param2)
	self.param2 = param2
end

function BagItem:GetParam4()
	return self.param4
end

function BagItem:GetReuseDay()
	if not self.param4 or self.param4 == 0 then
		return -1
	end
	local nTime1 = GetServerTime() + 8*3600
	local nTime2 = self.param4 + 8*3600
	return (nTime1 - nTime1%ONE_DAY - (nTime2 - nTime2%ONE_DAY))/ONE_DAY + 1
--	return (GetServerTime() - GetServerTime()%ONE_DAY - (self.param4 - self.param4%ONE_DAY))/ONE_DAY + 1
	-- return CTimeFormat:diffDayNum(GetServerTime(), self.param4) + 1;
end

function BagItem:SetParam4(param4)
	self.param4 = param4
end

--物品id
function BagItem:SetTid(tid)
	self.tid = tid;
end

function BagItem:GetTid()
	return self.tid;
end

--数量
function BagItem:SetCount(count)
	self.count = count;
end

function BagItem:GetCount()
	return self.count;
end

--背包类型
function BagItem:SetBagType(type)
	self.bagType = type;
end

function BagItem:GetBagType()
	return self.bagType;
end

--位置
function BagItem:SetPos(pos)
	self.pos = pos;
end

function BagItem:GetPos()
	return self.pos;
end

--战斗力
function BagItem:SetFight(fight)
	self.fight = fight;
end

--当前使用次数
function BagItem:SetUseCnt(useCnt)
	self.useCnt = useCnt;
end

function BagItem:GetUseCnt()
	return self.useCnt;
end

--当天使用次数
function BagItem:SetTodayUse(todayUse)
	self.todayUse = todayUse;
end

function BagItem:GetTodayUse()
	return self.todayUse;
end

--战斗力客户端计算
function BagItem:GetFight()
	local tipsVO = ItemTipsVO:new();
	ItemTipsUtil:CopyItemDataToTipsVO(self,tipsVO);
	return tipsVO:GetFight();
end

--标志
function BagItem:SetFlags(flags)
	self.flags = toint32(flags);
end

--获取绑定类型
--1已绑定,0不绑定,2使用后绑定
function BagItem:GetBindState()
	if bit.band(self.flags,BagItem.Flag_Bind) == BagItem.Flag_Bind then
		return BagConsts.Bind_Bind;
	else
		local cfg = self:GetCfg();
		if cfg then
			return cfg.bind;
		end
	end
	return BagConsts.Bind_None;
end

--获取物品是否被锁定
function BagItem:GetItemLocked()
	if bit.band(self.flags,BagItem.Flag_Lock) == BagItem.Flag_Lock then
		return true;
	else
		return false;
	end
end

--获取显示分类
function BagItem:GetShowType()
	return BagUtil:GetItemShowType(self.tid);
end

--配置表
function BagItem:GetCfg()
	if self:GetShowType() == BagConsts.ShowType_Equip then
		return t_equip[self.tid];
	else
		return t_item[self.tid];
	end
end

--使用的最低等级
function BagItem:GetNeedLevel()
	return BagUtil:GetNeedLevel(self:GetTid());
end

---
function BagItem:GetNeedAttrOne()
	return BagUtil:GetNeedAttrOne(self:GetTid());
end

function BagItem:GetNeedAttr()
	return BagUtil:GetNeedAttr(self:GetTid());
end

--等级是否足够
function BagItem:LevelAccord()
	return BagUtil:GetLevelAccord(self:GetTid());
end

--使用的职业
function BagItem:GetProf()
	local cfg = self:GetCfg();
	if not cfg then
		return 0;
	end
	return cfg.vocation;
end

--职业是否符合
function BagItem:ProfAccord()
	local playerInfo = MainPlayerModel.humanDetailInfo;
	if self:GetProf()==0 then
		return true;
	end
	return playerInfo.eaProf==self:GetProf();
end

--当物品是装备时,获取物品是否是贵重的
function BagItem:IsValuable()
	if EquipModel:GetStrenLvl(self.id) > 0 then
		return true;
	end
	if EquipModel:CheckSuper(self.id) then
		return true;
	end
	if EquipModel:CheckNewSuper(self.id) then
		return true;
	end
	return false;
end
