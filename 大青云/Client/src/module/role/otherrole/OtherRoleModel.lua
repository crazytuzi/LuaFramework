--[[其他角色数据
zhangshuhui
2015年1月16日16:58:16
]]

_G.OtherRoleModel = Module:new();

OtherRoleModel.otherhumanBSInfo = {};--其他人物基本信息
OtherRoleModel.otherhumanXXInfo = {};--其他人物详细信息
OtherRoleModel.equipInfoList = {};--其他人物装备附加信息
OtherRoleModel.gemList = {};--装备宝石信息
OtherRoleModel.bodytoolList = {};--身上道具信息
OtherRoleModel.rideLevel = 0;
OtherRoleModel.rideStar = 0;
OtherRoleModel.rideSelect = 0;
OtherRoleModel.pillNum = 0;
OtherRoleModel.othermountequiplist = {};--其他人物坐骑装备信息
OtherRoleModel.othermountskilllist = {};--其他人物坐骑技能信息
OtherRoleModel.otherattrXlist = {};--其他人物属性百分比
OtherRoleModel.wuhunLevel = 0;
OtherRoleModel.selectedWuhunId = 0
OtherRoleModel.hunzhu = 0
OtherRoleModel.feedNum = 0
OtherRoleModel.wuhunState = 0
OtherRoleModel.lingShouEquiplist = {};
OtherRoleModel.lingShouattrXlist = {};
OtherRoleModel.petId = 0;

--清空个人信息
function OtherRoleModel:ClearOtherRoleInfo()
	self.otherhumanBSInfo = nil;
	self.otherhumanXXInfo = nil;
	
	for i,vo in pairs(self.equipInfoList) do
		self.equipInfoList[i] = nil;
	end
	
	self.rideLevel = 0;
	self.rideStar = 0;
	self.rideSelect = 0;
	self.pillNum = 0;
	self.othermountequiplist = {};
	
	self.gemList = {};
	self.bodytoolList = {};
	self.bodytoolListPet = {};
	
	for j,vo in pairs(self.othermountskilllist) do
		self.othermountskilllist[j] = nil;
	end
	
	self.otherattrXlist = {};
	self:ClearOtherMountInfo();
	self:ClearOtheWuHunInfo();
end

--清空坐骑信息
function OtherRoleModel:ClearOtherMountInfo()
	self.rideLevel = 0;
	self.rideStar = 0;
	self.rideSelect = 0;
	self.pillNum = 0;
	self.othermountequiplist = {};
	
	for j,vo in pairs(self.othermountskilllist) do
		self.othermountskilllist[j] = nil;
	end
	
	self.otherattrXlist = {};
end

--清空武魂信息
function OtherRoleModel:ClearOtheWuHunInfo()
	self.wuhunLevel = 0;
	self.selectedWuhunId = 0;
	self.hunzhu = 0;
	self.feedNum = 0;
	self.wuhunState = 0;
	self.lingShouEquiplist = {};
	self.otherattrXlist = {};
end

--设置基本信息
function OtherRoleModel:SetBSInfo(bsinfo)
	self.otherhumanBSInfo = bsinfo;
end

--创建VO
function OtherRoleModel:CreateEquipVO(id)
	if self.equipInfoList[id] then
		return;
	end
	local vo = {};
	vo.id = id;
	vo.strenLvl = 0;
	vo.strenVal = 0;
	vo.proVal = 0;
	vo.groupId = 0;
	self.equipInfoList[id] = vo;
	
	return vo;
end

--设置装备附加信息
function OtherRoleModel:SetEquipInfo(id,bing,strenLvl,strenVal,refinLvl,extraLvl,groupId,superVO,newSuperList,groupId2,groupId2Level)
	if id == 0 then 
		return 
	end;
	local vo = self:CreateEquipVO(id);
	vo.bing = bing;
	vo.strenLvl = strenLvl;
	vo.strenVal = strenVal;
	vo.refinLvl = refinLvl;
	vo.extraLvl = extraLvl;
	vo.groupId = groupId;
	vo.groupId2 = groupId2;
	vo.groupId2Level = groupId2Level;
	vo.superVO = superVO;
	vo.newSuperList = newSuperList;
	vo.gemList = {};
	self.equipInfoList[id] = vo;
end

--设置装备的宝石信息
function OtherRoleModel:SetGemInfo(pos, slot, id)
	if not t_gemgroup[id] then return end; 
	if not self.gemList[pos] then
		self.gemList[pos] = {};
	end

	local gem = {};
	gem.id = id;
	gem.used = true;
	local config = t_gemgroup[id];
	gem.pos = config.slot;
	gem.name = config.name;
	gem.level = config.level;
	gem.view = {}
	gem.view.id = gem.id;
	gem.view.pos = gem.pos;
	gem.view.iconUrl = ResUtil:GetEquipGemIconUrl(config.icon,config.level,'54');
	table.push(self.gemList[pos], gem)
end

function OtherRoleModel:ClearGemList()
	self.gemList = {};
end

--设置身上道具信息
function OtherRoleModel:SetBodyToolInfo(list)
	self.bodyToolList = list;
	-- WriteLog(LogType.Normal,true,'---------------------收到服务器消息',result)

end

function OtherRoleModel:ClearBodyToolList()
	self.bodyToolList = {};
end

function OtherRoleModel:GetBodyToolVO(id)
	for i,vo in ipairs(self.bodyToolList) do
		if vo.wingid == id then
			return vo;
		end
	end
end

function OtherRoleModel:SetPetVO(id)
	self.petId = id;
end

--获取某个装备位的宝石信息
function OtherRoleModel:GetGemAtPos(pos)
	return self.gemList[pos] or {}
end

--获取装备的强化等级
function OtherRoleModel:GetStrenLvl(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.strenLvl;
	end
	return 0;
end

--获取新套装id
function OtherRoleModel:GetGroupId2(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.groupId2;
	end
	return 0;
end

--获取新套装id
function OtherRoleModel:GetGroupId2Level(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.groupId2Level;
	end
	return 0;
end

--获取装备的绑定状态
function OtherRoleModel:GetBingState(id)
	local vo = self.equipInfoList[id];
	if vo then
		return vo.bing;
	end
	return 0;
end

--获取坐骑装备的信息
function OtherRoleModel:GetMountEquipVO(id)
	for i,vo in ipairs(self.othermountequiplist) do
		if vo.id == id then
			return vo;
		end
	end
	return nil;
end

--设置详细信息
function OtherRoleModel:SetXXInfo(xxinfo)
	self.otherhumanXXInfo = xxinfo;
	-- debug.debug()
	self:sendNotification(NotifyConsts.OtherRoleXXInfo);
end

--设置武魂
function OtherRoleModel:SetWuhunInfo(wuhunId,wuhunselectId,hunzhu,feedNum,wuhunState)
	self.wuhunLevel = wuhunId;
	self.selectedWuhunId = wuhunselectId;
	self.hunzhu = hunzhu;
	self.feedNum = feedNum;
	self.wuhunState = wuhunState;
end
function OtherRoleModel:GetWuhunId()
	return self.wuhunLevel;
end
function OtherRoleModel:SelectedWuhunId()
	return self.selectedWuhunId;
end
function OtherRoleModel:GetHunzhu()
	return self.hunzhu;
end
function OtherRoleModel:GetFeedNum()
	return self.feedNum;
end
function OtherRoleModel:GetWuhunState()
	return self.wuhunState;
end

-- 添加灵兽装备
function OtherRoleModel:AddLingShouEquip(id, bind, groupId)
	local vo = {};
	vo.id = id;
	vo.bind = bind;
	vo.groupId = groupId;
	table.insert(self.lingShouEquiplist ,vo);
end

function OtherRoleModel:GetLingShouEquipVO(id)
	for i,vo in ipairs(self.lingShouEquiplist) do
		if vo.id == id then
			return vo;
		end
	end
	return nil;
end

-- 添加坐骑装备
function OtherRoleModel:AddMountEquip(id, bind, groupId)
	local vo = {};
	vo.id = id;
	vo.bind = bind;
	vo.groupId = groupId;
	table.insert(self.othermountequiplist ,vo);
end

-- 添加坐骑技能
function OtherRoleModel:AddMountSkill(skillVO)
	self.othermountskilllist[skillVO:GetID()] = skillVO;
end

--获取在某个组的技能id
function OtherRoleModel:GetSkillInGroup(groupId)
	for k,skillVO in pairs(self.othermountskilllist) do
		local cfg = skillVO:GetCfg();
		if cfg and cfg.group_id==groupId then
			return skillVO;
		end
	end
	return nil;
end

-- 添加属性百分比
function OtherRoleModel:AddAttrX(vo)
	self.otherattrXlist[vo.type] = vo.val;
end

--检查一个装备是否新卓越
function OtherRoleModel:CheckNewSuper(id)
	if not self.equipInfoList[id] then
		return false;
	end
	if not self.equipInfoList[id].newSuperList then
		return false;
	end
	for i,vo in ipairs(self.equipInfoList[id].newSuperList) do
		if vo.id > 0 then
			return true;
		end
	end
	return false;
end

--- 获取其他人套装效果
function OtherRoleModel:GetNewEquipGroupInfo()
	local equipList = {}
	local count = 0
	local attr = {}
	for k, v in pairs(self.equipInfoList) do
		local cfg = t_equip[k]
		if cfg.quality >= BagConsts.Quality_Green1 and cfg.quality <= BagConsts.Quality_Green3 then
			equipList[cfg.pos] = 1
			count = count + 1
			attr = PublicUtil:GetFightListPlus(attr, AttrParseUtil:Parse(cfg.baseAttr))
		end
	end
	
	local valueInfo = t_consts[324]
	local per = 0
	if count >= 6 and count < 9 then
		per = valueInfo.val1
	elseif count >= 9 and count < 11 then
		per = valueInfo.val2
	elseif count == 11 then
		per = valueInfo.val3
	else
		attr = {}
	end
	for k, v in pairs(attr) do
		attr[k].val = math.ceil(attr[k].val * per/100)
	end
	return {count, equipList, attr}
end