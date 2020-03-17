--[[
排行榜model
wangshuai
]]

_G.RankListModel = Module:new();


RankListModel.fristList = {}; --本服所有第一

RankListModel.fightlist = {};
RankListModel.lvlList = {};
RankListModel.MountList = {};
RankListModel.jingJieList = {};
RankListModel.lingShouList = {};
RankListModel.jxtzBossList = {};
RankListModel.jxtzMonsterList = {};
RankListModel.ShengbingList = {};
RankListModel.MingYuList = {};
RankListModel.LingQiList = {};
RankListModel.ArmorList = {};
RankListModel.NewTianshen = {};

RankListModel.atServerfightlist = {};
RankListModel.atServerlvlList = {};
RankListModel.atServerMountList = {};
RankListModel.atServerjingJieList = {};
RankListModel.atServerlingShouList = {};
RankListModel.atServerjxtzBossList = {};
RankListModel.atServerjxtzMonsterList = {};
-- RankListModel.atServerShengbingList = {};


-- 坐骑，人物，详细信息 右侧面板
RankListModel.roleDetaiedinfo = {};
RankListModel.roleEqupeinfo = {};
RankListModel.mountDetaied = {};
RankListModel.gemList = {};
RankListModel.bodyToolList = {};
RankListModel.lingshouinfo = {};
RankListModel.shengbingInfo = {};
RankListModel.lingQiInfo = {};
RankListModel.armorInfo = {};
RankListModel.mingYuInfo = {};
RankListModel.newtianshenInfo = {};

RankListModel.mountSkill = {};
RankListModel.mountEquip = {};

RankListModel.UpdataList = {}; -- 本服，更新list

RankListModel.UpdatalistAtServer = {}; -- 全服更新list


function RankListModel:SetUpdatalistInit()
	local index = RankListConsts.AllRankNum;
	for i=0,index do
		self.UpdataList[i] = {};
		self.UpdataList[i].IsUpdate = true;
		self.UpdatalistAtServer[i] = {};
		self.UpdatalistAtServer[i].IsUpdate = true;
	end;
end;

function RankListModel:GetCurListboo(type)
	if not self.UpdataList[type] then return end;
	return self.UpdataList[type].IsUpdate;
end;

function RankListModel:SetCurListboo(type,bo)
	if not self.UpdataList[type] then
		-- print(debug.traceback(),"server back type : "..type)
	end;
	if self.UpdataList[type] then
		self.UpdataList[type].IsUpdate = bo;
	end;
end;
-- 人物详细信息；
function RankListModel:SetRoleDetaiedInfo(msg)
	self.roleDetaiedinfo = {};
	self.roleEqupeinfo = {};
	local vo = {};--;
	vo.dwRoleID = msg.roleID;
	vo.eaName = msg.roleName;
	vo.prof = msg.prof;
	vo.eaLevel = msg.level;
	vo.eaHp = msg.hp;
	vo.eaMaxHp = msg.maxHp;
	vo.eaMp = msg.mp;
	vo.eaMaxMp = msg.maxMp;
	vo.eaFight = msg.fight;
	vo.eaGuildName = msg.guildName;
	vo.eaVIPLevel = msg.vipLevel;
	vo.sex = msg.sex;
	vo.dress = msg.dress;
	vo.arms = msg.arms;
	vo.fashionsHead = msg.fashionshead;
	vo.fashionsArms = msg.fashionsarms;
	vo.fashionsDress = msg.fashionsdress;
	--vo.wing = msg.wing;
	vo.wingStarLevel = msg.wingStarLevel;
	vo.wuhunId = msg.wuhunId;
	vo.suitflag = msg.suitflag
	vo.eaGongJi = msg.att;
	vo.eaFangYu = msg.def;
	vo.eaMingZhong = msg.hit;
	vo.eaBaoJi = msg.cri;
	vo.eaGongJiSpeed = msg.attspper;
	vo.eaMoveSpeed = msg.moveper;

	--潜能属性
	vo.eaHunLi = msg.hl;
	vo.eaTiPo = msg.tp;
	vo.eaShenFa = msg.sf;
	vo.eaJingShen = msg.js;

	--神武属性
	vo.shenWuLevel, vo.shenWuStar = RoleController:ParseShenWu(msg.shenwu)
	vo.shenWuSkills = RoleController:GetShenWuSkills(msg.shenwuSkills)


	vo.ring = msg.ringlv
	self.roleDetaiedinfo = vo;

	for i,info in ipairs(msg.list) do
		local voc = {};
		voc.tid = info.tid;
		voc.strenLvl = info.strenLvl;
		voc.strenVal = info.strenVal;
		voc.refinLvl = info.refinLvl;
		voc.proVal   = info.proVal;
		voc.extraLvl = info.attrAddLvl;
		voc.groupId = info.groupId;
		voc.groupId2 = info.groupId2;
		voc.groupId2Level = info.group2Level;
		voc.bind = info.bind;
		voc.superVO = {};
		voc.superVO.superNum = info.superNum;
		voc.superVO.superList = {}
		for k, v in pairs(info.superList) do
			if v.id > 0 then
				table.push(voc.superVO.superList, v)
			end
		end
		-- trace(voc.superVO.superList)
		voc.newSuperList = info.newSuperList;
		table.push(self.roleEqupeinfo,voc)
	end;
	self:sendNotification(NotifyConsts.RanklistRoleDetaiedInfo);
end;

--设置装备的宝石信息
function RankListModel:SetGemInfo(pos, slot, id)
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

--- claer
function RankListModel:ClearGemList()
	self.gemList = {};
end;
--获取某个装备位的宝石信息
function RankListModel:GetGemAtPos(pos)
	return self.gemList[pos] or {};
end

--设置身上道具信息
function RankListModel:SetBodyToolInfo(list)
	self.bodyToolList = list;

	self:sendNotification(NotifyConsts.RanklistRoleDetaiedInfo);
end

function RankListModel:GetBodyToolVO(id)
	for i,vo in ipairs(self.bodyToolList) do
		if vo.wingid == id then
			return vo;
		end
	end
end

-- 坐骑详细信息
function RankListModel:SetMountInfo(msg)
	self.mountDetaied = {};
	self.mountSkill = {};
	self.mountEquip = {};
	local vo = {};
	vo.rideLevel = msg.rideLevel;
	vo.mountStar = msg.mountStar;
	vo.pillNum = msg.pillNum;
	vo.roleID = msg.roleID;
	self.mountDetaied = vo;

	for i,vo in pairs(msg.equiplist) do
		--OtherRoleModel:AddMountEquip(vo.id);
		local voc = {};
		voc.id = vo.id;
		voc.bind = vo.bind;
		voc.groupId = vo.groupId;
		table.insert(self.mountEquip,voc)
	end
		--坐骑技能
	for i,vo in pairs(msg.skilllist) do
		if vo.skillid > 0 then
			local skvo = SkillVO:new(vo.skillid);
			self.mountSkill[skvo:GetID()] = skvo
		end;
	end
	self:sendNotification(NotifyConsts.RanklistMountDetaiedInfo);
end;

--获取坐骑装备的信息
function RankListModel:GetMountEquipVO(id)
	for i,vo in ipairs(self.mountEquip) do
		if vo.id == id then
			return vo;
		end
	end
	return nil;
end

-- 设置灵兽他人信息
function RankListModel:SetOtherRoleLingShouinfo(roleID,wuhunid,serverType,equiplist)
	self.lingshouinfo.roleID = roleID;
	self.lingshouinfo.wuhunId = wuhunid

	self.lingshouinfo.skillList = {};
	local cfg = t_wuhun[wuhunid]
	local skillCfg = split(cfg.gift_skill,"#");
	for i,info in ipairs(skillCfg) do
		local skvo = SkillVO:new(tonumber(info));
		self.lingshouinfo.skillList[skvo:GetID()] = skvo
	end;

	self.lingShouEquip = {};
	for i,vo in pairs(equiplist) do
		local voc = {};
		voc.id = vo.id;
		voc.bind = vo.bind;
		voc.groupId = vo.groupId;
		table.insert(self.lingShouEquip,voc)
	end
	self:sendNotification(NotifyConsts.RanklistLingshouDetaiedInfo);
end;

function RankListModel:GetLingShouEquipVO(id)
	for i,vo in ipairs(self.lingShouEquip) do
		if vo.id == id then
			return vo;
		end
	end
	return nil;
end

function RankListModel:GetOtherRoleLingshow()
	return self.lingshouinfo;
end;


--设置神兵他人信息
function RankListModel:SetOtherRoleShengBing(roleID,level,skills,serverType, equips)
	self.shengbingInfo = {};
	self.shengbingInfo.roleID = roleID;
	self.shengbingInfo.level = level;
	self.shengbingInfo.skillList = {}
	self.shengbingInfo.equipList = {}
	for i,info in pairs(skills) do
		local skvo = SkillVO:new(info.skillId);
		self.shengbingInfo.skillList[skvo:GetID()] = skvo;
	end;
	for k, v in pairs(equips) do
		local vo = ShowEquipSlotVO:new();
		if v.id > 0 then
			vo.bagType = BagConsts.BagType_MagicWeapon
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = true;
			vo.tid = v.id;
			vo.bindState = v.bind
		else
			vo.bagType = BagConsts.BagType_MagicWeapon
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = false;
		end
		table.push(self.shengbingInfo.equipList, vo)
	end
	self:sendNotification(NotifyConsts.RanklistShengbingDetaiedInfo)
end;

function RankListModel:GetOtherRoleShengBing()
	return self.shengbingInfo
end;


--设置灵器他人信息
function RankListModel:SetOtherRoleLingQi(roleID,level,skills,serverType,equips)
	self.lingQiInfo = {};
	self.lingQiInfo.roleID = roleID;
	self.lingQiInfo.level = level;
	self.lingQiInfo.skillList = {}
	self.lingQiInfo.equipList = {}
	for i,info in pairs(skills) do
		local skvo = SkillVO:new(info.skillId);
		self.lingQiInfo.skillList[skvo:GetID()] = skvo;
	end;
	for k, v in pairs(equips) do
		local vo = ShowEquipSlotVO:new();
		if v.id > 0 then
			vo.bagType = BagConsts.BagType_LingQi
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = true;
			vo.tid = v.id;
			vo.bindState = v.bind
		else
			vo.bagType = BagConsts.BagType_LingQi
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = false;
		end
		table.push(self.lingQiInfo.equipList, vo)
	end
	self:sendNotification(NotifyConsts.RanklistLingQiDetaiedInfo)
end;

function RankListModel:GetOtherRoleLingQi()
	return self.lingQiInfo
end;

--设置玉佩他人信息
function RankListModel:SetOtherRoleMingYu(roleID,level,skills,serverType,equips)
	self.mingYuInfo = {};
	self.mingYuInfo.roleID = roleID;
	self.mingYuInfo.level = level;
	self.mingYuInfo.skillList = {}
	self.mingYuInfo.equipList = {}
	for i,info in pairs(skills) do
		local skvo = SkillVO:new(info.skillId);
		self.mingYuInfo.skillList[skvo:GetID()] = skvo;
	end;
	for k, v in pairs(equips) do
		local vo = ShowEquipSlotVO:new();
		if v.id > 0 then
			vo.bagType = BagConsts.BagType_MingYu
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = true;
			vo.tid = v.id;
			vo.bindState = v.bind
		else
			vo.bagType = BagConsts.BagType_MingYu
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = false;
		end
		table.push(self.mingYuInfo.equipList, vo)
	end
	self:sendNotification(NotifyConsts.RanklistMingYuDetaiedInfo)
end;

function RankListModel:GetOtherRoleMingYu()
	return self.mingYuInfo
end;

--设置宝甲他人信息
function RankListModel:SetOtherRoleArmor(roleID,level,skills,serverType,equips)
	self.armorInfo = {};
	self.armorInfo.roleID = roleID;
	self.armorInfo.level = level;
	self.armorInfo.skillList = {}
	self.armorInfo.equipList = {}
	for i,info in pairs(skills) do
		local skvo = SkillVO:new(info.skillId);
		self.armorInfo.skillList[skvo:GetID()] = skvo;
	end;
	for k, v in pairs(equips) do
		local vo = ShowEquipSlotVO:new();
		if v.id > 0 then
			vo.bagType = BagConsts.BagType_Armor
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = true;
			vo.tid = v.id;
			vo.bindState = v.bind
		else
			vo.bagType = BagConsts.BagType_Armor
			vo.uiPos = k;
			vo.pos = k - 1;
			vo.opened = true;
			vo.hasItem = false;
		end
		table.push(self.armorInfo.equipList, vo)
	end
	self:sendNotification(NotifyConsts.RanklistArmorDetaiedInfo)
end;
function RankListModel:GetOtherRoleArmor()
	return self.armorInfo
end;
--设置天神他人信息
function RankListModel:SetOtherRoleNewTianShen(roleID,level,skills,serverType)
	self.newtianshenInfo = {};
	self.newtianshenInfo.roleID = roleID;
	self.newtianshenInfo.level = level;
	self.newtianshenInfo.skillList = {}
	for i,info in pairs(skills) do
		local skvo = SkillVO:new(info.skillId);
		self.newtianshenInfo.skillList[skvo:GetID()] = skvo;
	end;
	self:sendNotification(NotifyConsts.RanklistNewTianShenDetaiedInfo)
end;
function RankListModel:GetOtherRoleNewTianShen()
	return self.newtianshenInfo
end;

-- 设置排行榜首名
function RankListModel:SetRankFrist(list)
	self.fristList = {};
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.role = info.ranktype;
		vo.roleName = info.roleName;
		vo.fight = info.fight;
		vo.prof = info.prof;
		vo.dress = info.dress;
		vo.arms = info.arms;
		vo.shoulder = info.shoulder;
		vo.fashionsHead = info.fashionshead;
		vo.fashionsArms = info.fashionsarms;
		vo.fashionsDress = info.fashionsdress;
		vo.wuhunId = info.wuhunId;
		--vo.wing = info.wing;
		vo.suitflag = info.suitflag;
		table.push(self.fristList,vo)
	end;
	self:sendNotification(NotifyConsts.RanklistAllRoleInfo);
end;
function RankListModel:GetRankFrist()
	return self.fristList;
end;
-- 设置战斗力数据
function RankListModel:SetRoleFight(list)
	--trace(list)
	--print("战斗力排行")
	self.fightlist = {};
	self:AboutFightlist(list,self.fightlist)
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;
function RankListModel:GetRolefig()
	return self.fightlist;
end;

-- 设置等级排行数据
function RankListModel:SetRoleLvl(list)
	self.lvlList = {};
	self:Aboutlvllist(list,self.lvlList)
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;
function RankListModel:GetRoleLvl()
	return self.lvlList;
end;

-- 设置坐骑排行数据
function RankListModel:SetMountRank(list)
	self.MountList = {};
	self:AboutMountlist(list,self.MountList)
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;
function RankListModel:GetMountList()
	return self.MountList;
end;

-- 本服境界
function RankListModel:GetJingjieList()
	return self.jingJieList;
end;

function RankListModel:SetJingJinglist(list)
	self.jingJieList = {};
	self:AboutJingjielist(list,self.jingJieList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

-- 本服灵兽
function RankListModel:SetLingShouList(list)
	self.lingShouList = {};
	-- trace(list)
	-- print(list)
	self:AboutLingShou(list,self.lingShouList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetLingShoulist()
	return self.lingShouList;
end;

-- 本服灵阵
function RankListModel:SetLingZhenList(list)
	self.lingZhenList = {};
	self:AboutLingZhen(list,self.lingZhenList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetLingZhenlist()
	return self.lingZhenList;
end;


-- 本服极限挑战boss
function RankListModel:SetjxtzBossList(list)
	self.jxtzBossList = {};
	self:AboutjixiantiaozhanBoss(list,self.jxtzBossList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetjxtzBosslist()
	return self.jxtzBossList;
end;

-- 本服极限挑战monster
function RankListModel:SetjxtzMonsterList(list)
	self.jxtzMonsterList = {};
	self:AboutjixiantiaozhanMonster(list,self.jxtzMonsterList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetjxtzMonsterlist()
	return self.jxtzMonsterList;
end;

 -- 神兵
function RankListModel:SetShengBingList(list)
	self.ShengbingList = {};
	self:AboutShengbing(list,self.ShengbingList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;
 -- 天神
function RankListModel:SetNewTianShenList(list)
	self.NewTianshen = {};
	self:AboutNewTianshen(list,self.NewTianshen);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;
function RankListModel:GetShengBingList()
	return self.ShengbingList;
end;

--玉佩
function RankListModel:SetMingYuList(list)
	self.MingYuList = {};
	self:AboutMingYu(list,self.MingYuList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetMingYuList()
	return self.MingYuList;
end;

--灵器
function RankListModel:SetLingQiList(list)
	self.LingQiList = {};
	self:AboutLingQi(list,self.LingQiList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetLingQiList()
	return self.LingQiList;
end;


--宝甲
function RankListModel:SetArmorList(list)
	self.ArmorList = {};
	self:AboutArmor(list,self.ArmorList);
	self:sendNotification(NotifyConsts.RanklistRoleInfo);
end;

function RankListModel:GetArmorList()
	return self.ArmorList;
end;











































--------------------------------全服--------------------
function RankListModel:AtServerGetCurListboo(type)
	if not self.UpdatalistAtServer[type] then return end;
	return self.UpdatalistAtServer[type].IsUpdate;
end;

function RankListModel:AtServerSetCurListboo(type,bo)
     print("---------wrqewqrqwre--------------")
	if not self.UpdatalistAtServer[type] then
		print(debug.traceback(),"server back type : "..type)
	end;
	if self.UpdatalistAtServer[type] then
		self.UpdatalistAtServer[type].IsUpdate = bo;
	end;
end;

function RankListModel:AtServerFightList(list)
	self.atServerfightlist = {};
	self:AboutFightlist(list,self.atServerfightlist)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;

function RankListModel:AtserverLvlList(list)
	self.atServerlvlList = {};
	self:Aboutlvllist(list,self.atServerlvlList);
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;

function RankListModel:AtserverMountList(list)
	self.atServerMountList = {};
	self:AboutMountlist(list,self.atServerMountList)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;

function RankListModel:AtserverJingjieList(list)
	self.atServerjingJieList = {};
	self:AboutJingjielist(list,self.atServerjingJieList)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;

function RankListModel:AtserverlingShouList(list)
	self.atServerlingShouList = {};
	self:AboutLingShou(list,self.atServerlingShouList)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;


function RankListModel:AtserverjxtzBossList(list)
	self.atServerjxtzBossList = {};
	self:AboutjixiantiaozhanBoss(list,self.atServerjxtzBossList)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;

function RankListModel:AtserverjxtzMonsterList(list)
	self.atServerjxtzMonsterList = {};
	self:AboutjixiantiaozhanMonster(list,self.atServerjxtzMonsterList)
	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
end;


-- function RankListModel:AtserverShengbList(list)
-- 	self.atServerShengbingList = {};
-- 	self:AboutShengbing(list,self.atServerShengbingList)
-- 	self:sendNotification(NotifyConsts.AllTheServerListUpdata);
-- end;

------------------------公用数据解析
-- 等级
function RankListModel:Aboutlvllist(list,listvo)
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.rankvlue;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.vflag = info.vflag;
		table.push(listvo,vo)
	end;
end;

-- 战力
function RankListModel:AboutFightlist(list,listvo)
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank
		vo.roleName = info.roleName;
		vo.lvl = info.lvl;
		vo.role = info.roletype;
		vo.fight = info.rankvlue;
		vo.vipLvl = info.vipLvl;
		vo.vflag = info.vflag;
		table.push(listvo,vo);
	end;
end;
-- 坐骑
function RankListModel:AboutMountlist(list,listvo)
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.mountId = info.mountId;
		vo.role = info.roletype;
		vo.lvl = info.lvl;
		vo.vipLvl = info.vipLvl;
		vo.vflag = info.vflag;
		table.push(listvo,vo)
	end;
end;
-- 境界
function RankListModel:AboutJingjielist(list,listvo)
	for i,info in ipairs(list) do 
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.lvl;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.jingjieVlue = info.rankvlue;
		vo.vflag = info.vflag;
		table.push(listvo,vo);
	end;
end;

-- 灵兽
function RankListModel:AboutLingShou(list,listvo)
	for i,info in ipairs(list) do
		local cfg = t_wuhun[info.rankvlue];
		if cfg then
			local vo = {};
			vo.roleid = info.roleID;
			vo.rank = info.rank;
			vo.roleName = info.roleName;
			vo.lvl = info.lvl;
			vo.role = info.roletype;
			vo.vipLvl = info.vipLvl;
			vo.lingshouName = cfg.name;
			vo.lingshouOrder = cfg.order;
			vo.vflag = info.vflag;
			table.push(listvo,vo);
		end;
	end;
end;

--   极限挑战 boss
function RankListModel:AboutjixiantiaozhanBoss(list,listvo)
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.lvl;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.killNum = info.rankvlue;
		vo.vflag = info.vflag;
		table.push(listvo,vo);
	end;
end;

-- 极限挑战 小怪
function RankListModel:AboutjixiantiaozhanMonster(list,listvo)
	for i,info in ipairs(list) do
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.lvl;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.monsterNum = info.rankvlue;
		vo.vflag = info.vflag;
		table.push(listvo,vo);
	end;
end;


-- 神兵
function RankListModel:AboutShengbing(list,listvo)
	for i,info in ipairs(list) do
	local cfg = t_shenbing[info.rankvlue]
	if cfg then
	local vo = {};
	vo.roleid = info.roleID;
	vo.rank = info.rank;
	vo.roleName = info.roleName;
	vo.lvl = info.lvl;
	vo.role = info.roletype;
	vo.vipLvl = info.vipLvl;
	vo.sbValue = info.rankvlue;
	vo.sbName = cfg.name;
	vo.vflag = info.vflag;
	table.push(listvo,vo);
		end;
	end;
end;
function RankListModel:AboutNewTianshen(list,listvo)
	for i,info in ipairs(list) do
	local cfg = t_newtianshen[info.rankvlue]
	    if cfg then
		local vo = {};
		vo.roleid = info.roleID;
		vo.rank = info.rank;
		vo.roleName = info.roleName;
		vo.lvl = info.lvl;
		vo.role = info.roletype;
		vo.vipLvl = info.vipLvl;
		vo.sbValue = info.rankvlue;
		vo.sbName = cfg.name;
		vo.vflag = info.vflag;
		table.push(listvo,vo);
		end;
	end;
end
-- 玉佩
function RankListModel:AboutMingYu(list,listvo)
 	for i,info in ipairs(list) do
 		local cfg = t_mingyu[info.rankvlue]
 		if cfg then
 			local vo = {};
 			vo.roleid = info.roleID;
 			vo.rank = info.rank;
 			vo.roleName = info.roleName;
 			vo.lvl = info.lvl;
 			vo.role = info.roletype;
 			vo.vipLvl = info.vipLvl;
 			vo.myValue = info.rankvlue;
 			vo.myName = cfg.name;
 			vo.vflag = info.vflag;
 			table.push(listvo,vo);
 		end;
 	end;
end;
-- 灵器
function RankListModel:AboutLingQi(list,listvo)
	for i,info in ipairs(list) do
		local cfg = t_lingqi[info.rankvlue]
		if cfg then
			local vo = {};
			vo.roleid = info.roleID;
			vo.rank = info.rank;
			vo.roleName = info.roleName;
			vo.lvl = info.lvl;
			vo.role = info.roletype;
			vo.vipLvl = info.vipLvl;
			vo.lqValue = info.rankvlue;
			vo.lqName = cfg.name;
			vo.vflag = info.vflag;
			table.push(listvo,vo);
		end;
	end;
end;
-- 灵器
function RankListModel:AboutArmor(list,listvo)
	for i,info in ipairs(list) do
		local cfg = t_newbaojia[info.rankvlue]
		if cfg then
			local vo = {};
			vo.roleid = info.roleID;
			vo.rank = info.rank;
			vo.roleName = info.roleName;
			vo.lvl = info.lvl;
			vo.role = info.roletype;
			vo.vipLvl = info.vipLvl;
			vo.armorValue = info.rankvlue;
			vo.armorName = cfg.name;
			vo.vflag = info.vflag;
			table.push(listvo,vo);
		end;
	end;
end;
function RankListModel:GetNewEquipGroupInfo()
	local equipList = {}
	local count = 0
	local attr = {}
	for k, v in pairs(self.roleEqupeinfo) do
		local cfg = t_equip[v.tid]
		if cfg then
			if cfg.quality >= BagConsts.Quality_Green1 and cfg.quality <= BagConsts.Quality_Green3 then
				equipList[cfg.pos] = 1
				count = count + 1
				attr = PublicUtil:GetFightListPlus(attr, AttrParseUtil:Parse(cfg.baseAttr))
			end
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