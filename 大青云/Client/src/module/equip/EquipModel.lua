--[[
装备Model,存在装备的附加信息
lizhuangzhuang
2014年11月13日18:13:04 
]]

_G.EquipModel = Module:new();

--装备附加信息
EquipModel.equipInfoList = {};
--装备宝石信息
EquipModel.gemList = {};
--卓越属性   key:id		VO:{id,superNum,superList:VO{uid,id,val1}}
EquipModel.superList = {};
--卓越属性库 key:index  VO:{uid,id,val1}
EquipModel.superLib = {};
--卓越孔信息 key:pos_index	level
EquipModel.superHoleList = {};
--追加属性	 key:id		level
EquipModel.extraList = {};
--道具卓越属性 key:id	VO:{id,val1}
EquipModel.itemSuperList = {};
--新卓越属性	key:id	VO:{id,newSuperList:VO{id}}
EquipModel.newSuperList = {};
--炼化信息
EquipModel.refinList = {};
--翅膀信息		key:id VO:{time,attrFlag}
EquipModel.wingList = {};
--神炉信息 
EquipModel.stoveList = {};
-- 洗练信息
EquipModel.washList = {}

--创建VO
function EquipModel:CreateEquipVO(id)
	if self.equipInfoList[id] then
		return;
	end
	local vo = {};
	vo.id = id;
	vo.strenLvl = 0;
	vo.strenVal = 0;
	vo.emptystarnum = 0;
	vo.groupId = 0;
	vo.groupId2 =0;
	vo.group2Level = 0;
	self.equipInfoList[id] = vo;
	return vo;
end

--设置装备附加信息
function EquipModel:SetEquipInfo(id,strenLvl,strenVal,groupId,groupId2,groupId2Bind,group2Level, emptystarnum)
	local vo = self.equipInfoList[id];
	if not vo then
		vo = self:CreateEquipVO(id);
	end
	vo.strenLvl = strenLvl;
	vo.strenVal = strenVal;
	vo.groupId = groupId;
	vo.emptystarnum = emptystarnum
	vo.groupId2 = groupId2
	vo.groupId2Bind = groupId2Bind
	vo.group2Level = group2Level or 0
	self.equipInfoList[id] = vo;
	self:sendNotification(NotifyConsts.EquipAttrChange,{id=id});
end

function EquipModel:AddEquipInfo(msg)
	local vo = self.equipInfoList[msg.id];
	if not vo then
		vo = self:CreateEquipVO(msg.id);
	end
	
	vo.strenLvl = msg.strenLvl;
	vo.strenVal = msg.strenVal;
	vo.emptystarnum = msg.emptystarnum;
	vo.groupId = msg.groupId;
	vo.groupId2 = msg.groupId2
	vo.groupId2Bind = msg.groupId2Bind
	vo.group2Level = msg.group2Level or 0
	self.equipInfoList[msg.id] = vo;
	self:sendNotification(NotifyConsts.EquipAttrChange,{id=msg.id});
	
end

--获取装备的附加信息
function EquipModel:GetEquipInfo(id)
	return self.equipInfoList[id];
end

--获取装备的强化等级
function EquipModel:GetStrenLvl(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.strenLvl;
	end
	return 0;
end

--获取装备的强化进度
function EquipModel:GetStrenVal(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.strenVal;
	end
	return 0;
end

function EquipModel:GetAllStrenLvl()
	local nLev = 0;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if bagVO then
		for i,pos in ipairs(EquipConsts.EquipStrenType) do
			local item = bagVO:GetItemByPos(pos);
			if item then
				nLev = nLev + EquipModel:GetStrenLvl(item:GetId())
			end
		end
	end
	return nLev
end

--获取当前的强化连锁id
function EquipModel:GetStrenLinkId()
	return EquipUtil:GetStrenLinkId(self:GetAllStrenLvl());
end

--设置强化信息
function EquipModel:SetStrenInfo(id,strenLvl,strenVal)
	local vo = self.equipInfoList[id];
	if not vo then
		vo = self:CreateEquipVO(id);
	end
	vo.strenLvl = strenLvl;
	vo.strenVal = strenVal;
end

--删除装备附加信息
function EquipModel:RemoveEquipInfo(id)
	if self.equipInfoList[id] then
		self.equipInfoList[id] = nil;
	end
end

--设置装备的宝石信息
function EquipModel:SetGemInfo(id,lvl,bo)
	if not t_gemgroup[id] then return end; 
	if not self.gemList[id] then
		self.gemList[id] = {};
	end
	local curpos = nil;
	local atbname = nil;
	local atbval = nil;
	for i,ca  in pairs(t_gemgroup) do
		if i == id then 
			curpos = ca.pos;
			atbname = AttrParseUtil.AttMap[ca.atr];
			atbval = ca["atr"..lvl]
			break;
		end;
	end;
	local vo = self.gemList[id];
	vo.id = id;  	
	vo.lvl = lvl;
	vo.pos = curpos;
	vo.atbname = atbname;
	vo.atbval = atbval;
	local vipAdd = VipController:GetBaoshishuxingUp() / 100;
	local ratioNum = vipAdd * vo.atbval;
	vo.atbval = vo.atbval + ratioNum;
	local a,b = math.floor(vo.atbval)
	vo.atbval = a;
	if bo == true then 
		self:sendNotification(NotifyConsts.EquipGemUpdata,true);
	else
		self:sendNotification(NotifyConsts.EquipGemUpdata,false);
	end;
end
function EquipModel:GetGemLinkId()
	return EquipUtil:GetGemLinkId(self.gemList)
end;
-- 得到所有宝石
function EquipModel:GetGemList()
	return self.gemList;
end;
--获取某个装备位的宝石信息
function EquipModel:GetGemAtPos(pos)
	local list = {};
	for i,vo in pairs(self.gemList) do
		if vo.pos == pos then
			table.push(list,vo);
		end
	end
	return list;
end
-- 获取某个宝石信息
function EquipModel:GetGemServerinfo(gameid)
	for i,vo in pairs(self.gemList) do
		if  i == gameid then 
			return vo
		end;
	end;
end;
-- 得到当前宝石总属性加成
function EquipModel:GetCurGemAtbAll()
	local list = {};
	for i,vo in  pairs(self.gemList) do 
		print(vo.atbname)
		if not list[vo.atbname] then 
			list[vo.atbname] = 0;
			list[vo.atbname] = list[vo.atbname] + vo.atbval;
		else
			list[vo.atbname] = list[vo.atbname] + vo.atbval;
		end;
	end;
	return list;
end;

--获取装备的升品信息
function EquipModel:GetProVal(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.proVal;
	end
	return 0;
end

--设置装备升品信息
function EquipModel:SetProVal(id,proVal,result)
	local vo = self.equipInfoList[id];
	if not vo then
		vo = self:CreateEquipVO(id);
	end
	vo.proVal = proVal;
	self:sendNotification(NotifyConsts.EquipProductUpdata,result);
end

--获取装备的套装id
function EquipModel:GetGroupId(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.groupId;
	end
	return 0;
end

--设置旧装备的套装id
function EquipModel:SetGroupId(id,groupId)
	local vo = self.equipInfoList[id];
	if not vo then
		vo = self:CreateEquipVO(id);
	end
	vo.groupId = groupId;
end


--设置新装备的套装id
function EquipModel:SetGroupId2(id,groupId2,groupId2Bind)
	local vo = self.equipInfoList[id];
	if not vo then
		vo = self:CreateEquipVO(id);
	end
	vo.groupId2 = groupId2;
	vo.groupId2Bind = groupId2Bind;
end

--得到新装备的套装
function EquipModel:GetGroupId2(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.groupId2,vo.groupId2Bind;
	end
	return 0,0;
end;

function EquipModel:SetEquipGroupLevel( equipId, level )
	local vo = self.equipInfoList[equipId]
	if not vo then
		vo = self:CreateEquipVO(equipId)
	end
	vo.group2Level = level
	if level > 0 then
		vo.groupId2Bind = 1
	end
	self:sendNotification( NotifyConsts.EquipGroupLevel, { id = equipId } )
end

function EquipModel:GetEquipGroupLevel( equipId )
	local vo = self.equipInfoList[equipId];
	return vo and vo.group2Level or 0
end


--------------------------------------装备卓越--------------------------------
--设置装备的卓越属性
function EquipModel:SetSuperVO(id,vo)
	self.superList[id] = vo;
end

--获取装备的卓越属性
function EquipModel:GetSuperVO(id)
	return self.superList[id];
end

--检查一个装备是否卓越
function EquipModel:CheckSuper(id)
	if not self.superList[id] then
		return false;
	end
	if self.superList[id].superNum > 0 then
		for i=1,self.superList[id].superNum do
			local vo = self.superList[id].superList[i];
			if vo.id > 0 then
				return true;
			end
		end
	end
	return false;
end

--检查一个装备是否有卓越孔
function EquipModel:CheckSuperHole(id)
	if not self.superList[id] then
		return false;
	end
	if self.superList[id].superNum > 0 then
		return true;
	else
		return false;
	end
end

--设置指定索引的卓越属性
function EquipModel:SetSuperAtIndex(id,index,vo)
	if not self.superList[id] then
		print("Error:设置装备卓越属性错误.");
		return;
	end
	local superVo = self.superList[id];
	superVo.superList[index] = vo;
	self:sendNotification(NotifyConsts.EquipSuperChange,{id=id});
end

--获取指定索引的卓越属性
function EquipModel:GetSuperAtIndex(id,index)
	if not self.superList[id] then
		return nil;
	end
	local vo = self.superList[id].superList[index];
	if not vo then return nil; end
	if vo.id == 0 then return nil; end
	return vo;
end

--删除指定索引的卓越属性
function EquipModel:RemoveSuperAtIndex(id,index)
	if not self.superList[id] then return nil; end
	local vo = self.superList[id];
	local removeVO = vo.superList[index];
	vo.superList[index] = {uid="",id=0,val1=0};
	self:sendNotification(NotifyConsts.EquipSuperChange,{id=id});
	return removeVO;
end

--改卓越孔数
function EquipModel:SetSuperHoleNum(id,num)
	if not self.superList[id] then return nil; end
	local vo = self.superList[id];
	vo.superNum = num;
	self:sendNotification(NotifyConsts.EquipSuperChange,{id=id});
end

--添加到卓越属性库
function EquipModel:SuperLibAdd(vo)
	if self:GetSuperLibVO(vo.uid) then
		print("Error:库中已存在该卓越属性");
		return;
	end
	table.push(self.superLib,vo);
	table.sort(self.superLib,function(A,B)
		return A.id > B.id;
	end);
	self:sendNotification(NotifyConsts.SuperLibRefresh);
end

--从卓越属性库获取
function EquipModel:GetSuperLibVO(uid)
	for i,vo in ipairs(self.superLib) do
		if vo.uid == uid then
			return vo;
		end
	end
	return nil;
end

--从卓越属性库删除
function EquipModel:SuperLibRemove(uid)
	for i=#self.superLib,1,-1 do
		local vo = self.superLib[i];
		if vo.uid == uid then
			local removeVO = table.remove(self.superLib,i,1);
			self:sendNotification(NotifyConsts.SuperLibRemove,{id=removeVO.uid})
			self:sendNotification(NotifyConsts.SuperLibRefresh);
			return removeVO;
		end
	end
end

--设置指定卓越孔的等级
function EquipModel:SetSuperHoleAtIndex(pos,index,level)
	local key = pos .."_"..index;
	self.superHoleList[key] = level;
	self:sendNotification(NotifyConsts.SuperHoleLvlUp,{pos=pos,index=index});
end

--获取指定卓越孔的等级
function EquipModel:GetSuperHoleAtIndex(pos,index)
	local key = pos .."_".. index;
	if self.superHoleList[key] then
		return self.superHoleList[key];
	end
	return 0;
end

--设置装备追加属性
function EquipModel:SetExtra(id,level)
	self.extraList[id] = level;
end

--获取装备追加属性等级
function EquipModel:GetExtraLvl(id)
	if self.extraList[id] then
		return self.extraList[id];
	end
	return 0;
end

---------------------------------------道具卓越属性---------------------------------
--设置道具的卓越属性
function EquipModel:SetItemSuperVO(id,vo)
	self.itemSuperList[id] = vo;
end

--获取道具的卓越属性
function EquipModel:GetItemSuperVO(id)
	return self.itemSuperList[id];
end

----------------------------------------新卓越属性-------------------------------------
--设置装备的卓越属性
function EquipModel:SetNewSuperVO(id,vo)
	self.newSuperList[id] = vo;
end

function EquipModel:SetNewSuperAtIndex(id,index,vo)
	if not self.newSuperList[id] then
		print("Error:设置装备新卓越属性错误.");
		return;
	end
	local superVo = self.newSuperList[id];

	superVo.newSuperList[index] = vo;
	self:sendNotification(NotifyConsts.EquipNewSuperChange,{id=id});
end

--获取装备的卓越属性
function EquipModel:GetNewSuperVO(id)
	return self.newSuperList[id];
end

--检查一个装备是否新卓越
function EquipModel:CheckNewSuper(id)
	if not self.newSuperList[id] then
		return false;
	end
	for i,vo in ipairs(self.newSuperList[id].newSuperList) do
		if vo.id > 0 then
			return true;
		end
	end
	return false;
end

--获取人身上所有的新卓越属性数量
function EquipModel:GetRoleTotalNewSuper()
	local num = 0;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return num; end
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		local item = bagVO:GetItemByPos(pos);
		if item and self.newSuperList[item:GetId()] then
			local newSuperVO = self.newSuperList[item:GetId()];
			for i,vo in ipairs(newSuperVO.newSuperList) do
				if vo.id > 0 then
					num = num + 1;
				end
			end
		end
	end
	return num;
end

--获取当前的新卓越连锁id
--全身卓越数量
function EquipModel:GetNewSuperLinkId()
	local num = self:GetRoleTotalNewSuper();
	if num == 0 then return 0; end
	return EquipUtil:GetNewSuperLinkId(num);
end

--------卓越洗练，
EquipModel.washTemporaryData = {};
function EquipModel:SetWashValTemporaryData(cid,id,wash,idx)
	self.washTemporaryData.cid = cid;
	self.washTemporaryData.id = id;
	self.washTemporaryData.wash = wash;
	self.washTemporaryData.idx = idx;
	if UIEquipSuperNewWash:IsShow() then 
		UIEquipSuperNewWash:SetWashTemporary()
	end;
end;

--------------------------------------炼化
function EquipModel:SetRefinInfo(id,pos)
	if 1 then return end
	local vo = {};
	vo.id = id;
	vo.pos = pos;
	vo.lvl = id - (pos * 10000)
	self.refinList[pos] = vo;
end;

function EquipModel:GetRefinInfo(pos)
	if not self.refinList[pos] then 
		return 
	end;
	return self.refinList[pos]
end;

function EquipModel:GetRefinList()
	return self.refinList;
end;

function EquipModel:GetRefinLvlByPos(pos)
	if self.refinList[pos] then
		return self.refinList[pos].lvl;
	end
	return 0;
end

function EquipModel:GetRefinLinkId()
	return EquipUtil:GetRefinLinkId(self.refinList)
end;

-------------------------------熔炼-----------------------------------
EquipModel.smeltLevel = 0;
EquipModel.smeltExp = 0;
EquipModel.smeltFlags = 0;
function EquipModel:UpDataSmelting(level,exp,flags)
	self.smeltLevel = level;
	self.smeltExp = exp;
	self.smeltFlags = flags;
end

function EquipModel:GetSmeltLevel()
	return self.smeltLevel;
end

function EquipModel:GetSmeltExp()
	return self.smeltExp;
end

function EquipModel:GetSmeltFlags()
	return self.smeltFlags;
end

function EquipModel:GetAutoSmelt()
	local flags = self:GetSmeltFlags();
	return bit.band(flags,math.pow(2,4)) == math.pow(2,4);
end

------------------------------翅膀信息----------------------------------
function EquipModel:SetWingInfo(id,time,attrFlag)
	if not self.wingList[id] then
		self.wingList[id] = {};
	end
	self.wingList[id].time = time;
	self.wingList[id].attrFlag = attrFlag;
end

function EquipModel:RemoveWingInfo(id)
	if self.wingList[id] then
		self.wingList[id] = nil;
	end
end

--翅膀是否有特殊属性
function EquipModel:GetWingAttrFlag(id)
	if not self.wingList[id] then
		return false;
	end
	return self.wingList[id].attrFlag==1;
end

-- 翅膀到期时间
function EquipModel:GetWingTime(id)
	if not self.wingList[id] then return -1; end
	return self.wingList[id].time;
end

--翅膀到期剩余时间
function EquipModel:GetWingLastTime(id)
	if not self.wingList[id] then return -1; end
	local time = self.wingList[id].time;
	if time < 0 then return -1; end
	if time == 0 then return 0; end
	local now = GetServerTime();
	if now >= time then return 0; end
	return time-now;
end

----------------------------------卓越精炼

EquipModel.washJinglian = {};
function EquipModel:SetWashJInglian(cid,id,wash,idx)
	self.washJinglian.cid = cid;
	self.washJinglian.id = id;
	self.washJinglian.wash = wash;
	self.washJinglian.idx = idx;
	if UIEquipSuperValWash:IsShow() then 
		UIEquipSuperValWash:SetWashTemporary()
	end;
end;


------------------------------------套装养成

EquipModel.Grouplist = {};

function EquipModel:SetEquipGroupInfo(pos,index,lvl)
	index = index + 1
	local vo = {};
	vo.pos = pos;
	vo.index = index;
	vo.lvl = lvl;
	self.Grouplist[pos..index] = vo;
	--trace(self.Grouplist)
end;

--得到当前装备位下，套装位置，是否有东西，是否开启
-- 找不到 -2 未开孔，
-- 找到 -1 开孔未镶嵌
-- 找到 0 镶嵌，未升级
-- 找到等级，已生效
function EquipModel:GetCuePosIsHaveGroup(pos,index)
	if not pos or not index then 
		print(pos,index,debug.traceback())
	end;
	local str = pos .. index;
	if self.Grouplist[str] then
		return self.Grouplist[str].lvl;
	end;
	return -2;--未开孔
end;

--得到当前装备位置下，开孔次数
function EquipModel:GetcurPosKongNum(pos)
	local num = 0;
	for i,info in pairs(self.Grouplist) do 
		if toint(info.pos) == pos then 
			num = num + 1;
		end;
	end;
	return num
end;

--得到当前pos下有几个套装
function EquipModel:GetCurPosGroupNum(pos)
	local num = 0;
	for i,info in pairs(self.Grouplist) do 
		if toint(info.pos) == pos then 
			if info.lvl >= 0 then 
				num = num + 1;
			end;
		end;
	end;
	return num
end;

--得到当前pos下有几个套装
function EquipModel:GetCurPosGroupPosNum(pos)
	local num = 0;
	for i,info in pairs(self.Grouplist) do 
		if toint(info.pos) == pos then 
			if info.lvl >= -1 then 
				num = num + 1;
			end;
		end;
	end;
	return num
end;

function EquipModel:SetStoveInfo(tid, level, progress, star)
	-- 先查找是否有这个系列的
	local targetStoveInfo = t_stoveplay[tid];
	
	if not targetStoveInfo then return end
	
	-- 查找是不是已经有了
	local hasStoveInfo = self.stoveList[targetStoveInfo.type];
	-- 如果没有创建，则创建一个
	if not hasStoveInfo then
		hasStoveInfo = {};
		self.stoveList[targetStoveInfo.type] = hasStoveInfo;
	end
	-- 更新数据
	hasStoveInfo.id = tid;
	hasStoveInfo.type = targetStoveInfo.type;
	hasStoveInfo.currentLevel = level;
	hasStoveInfo.currentProgress = progress;
	hasStoveInfo.currentStar = star;
end

function EquipModel:GetStoveInfoVOByType(type)
	return self.stoveList[type];
end

--------------------------------------------------------------装备洗练------------------------------------------------------------
function EquipModel:setWashInfo(id, num, list)
	self.washList[id] = list
	for k, v in pairs(self.washList[id]) do
		if v.id == 0 then
			self.washList[id][k] = nil
		end
	end
end

function EquipModel:getWashInfo(id)
	return self.washList[id] or {}
end

function EquipModel:GetWashLvByID(id)
	local nLv = 0
	for k, v in pairs(self:getWashInfo(id)) do
		nLv = nLv + t_extraatt[v.id].lv
	end
	return nLv
end

function EquipModel:GetWashLinkID()
	local linkID = 0
	local AllLv = self:GetWashAllLv()
	for k, v in pairs(t_extrachain) do
		if v.lv <= AllLv and v.id > linkID then
			linkID = v.id
		end
	end
	return linkID
end

function EquipModel:GetWashAllLv()
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip)
	local nLv = 0
	for k1, v1 in pairs(equips) do
		nLv = nLv + self:GetWashLvByID(v1:GetId())
	end
	return nLv
end

function EquipModel:GetMaxWashLinkNeed()
	local lv = 0
	for k, v in pairs(t_extrachain) do
		if v.lv > lv then
			lv = v.lv
		end
	end
	return lv
end