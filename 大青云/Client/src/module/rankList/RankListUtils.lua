--[[
排行榜
wangshuai
]]
_G.RankListUtils = {};

RankListUtils.onePage = 10;
RankListUtils.onePage2 = 12; --第二页开始每页的个数
-- 得到当前页数下的itemlist
function RankListUtils:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	local eachPageCount = 0;
	if page <= 1 then
		eachPageCount = self.onePage;
	else
		eachPageCount = self.onePage2;
	end
	local startIndex = (eachPageCount * page) - eachPageCount + 1;
	local endIndex = (eachPageCount * page);
	if page > 1 then
		startIndex = startIndex - (self.onePage2 - self.onePage);
		endIndex = endIndex - (self.onePage2 - self.onePage);
	end

	for i = startIndex, endIndex do
		table.push(vo,list[i])
	end;
	return vo
end;

function RankListUtils:GetListLenght(list)
	local lenght = (#list - self.onePage) / self.onePage2;
	return math.ceil(lenght) + 1;
end;
function RankListUtils:GetList(type)
	if type == RankListConsts.LvlRank then 
		-- 等级排行list
		return RankListModel:GetRoleLvl();
	elseif type == RankListConsts.FigRank then 
		-- 战力
		return RankListModel:GetRolefig();
	elseif type == RankListConsts.ZuoRank then 
		-- 坐骑
		return RankListModel:GetMountList();
	elseif type == RankListConsts.jingJie then 
		-- 境界
		return RankListModel:GetJingjieList();
	elseif type == RankListConsts.Lingshou then 
		-- 灵兽
		return RankListModel:GetLingShoulist();
	-- elseif type == RankListConsts.LingZhen then 
	-- 	-- 灵阵
	-- 	return RankListModel:GetLingZhenlist();
	elseif type == RankListConsts.JixianBoss then 
		-- 极限挑战boss
		return RankListModel:GetjxtzBosslist();
	elseif type == RankListConsts.JixianMonster then 
		-- 极限挑战monster
		return RankListModel:GetjxtzMonsterlist();
	elseif type == RankListConsts.Shengbing then
	 	return RankListModel:GetShengBingList();
	elseif type == RankListConsts.MingYu then
		return RankListModel:GetMingYuList();
	elseif type == RankListConsts.LingQi then
		return RankListModel:GetLingQiList();
	elseif type == RankListConsts.Armor then
		return RankListModel:GetArmorList();
	end;

end;

function RankListUtils:FindDesc(list,desc)
	local rstList = {};
	for i,info in pairs(list) do
		local num = string.find(info.roleName,desc)
		if num then 
			table.push(rstList,info);
		end;
	end;
	return rstList
end;

function RankListUtils:FindMyDesc(list,desc)
	self:FindDesc(list,desc)
	for i,info in pairs(list) do
		if info.roleName == desc then 
			return info;
		end;
	end;
end;

--- 获取其他人物的list
function RankListUtils:GetRoleEquipItemList()
	local list = {};
	local roleInfo = RankListModel.roleDetaiedinfo;
	for i,info in ipairs(EquipConsts.EquipStrenType) do
		local item = ShowEquipSlotVO:new();
		local vo = self:GetEquipPos(info);
		item.pos = info;
		item.bagType = BagConsts.BagType_Role;
		if not vo then
			item.hasItem = false;
		else
			item.hasItem = true;
			item.tid = vo.tid;

			if vo.bind == 0 then 
				item.bindState = BagConsts.Bind_None;
			elseif vo.bind == 1 then 
				item.bindState = BagConsts.Bind_Bind;
			end;
			item.showBind = false;
			item.strenLvl = vo.strenLvl;
			item.attrAddLvl = vo.attrAddLvl;
			item.strenVal = vo.strenVal;
			item.superVO = vo.superVO;
			item.equipGroupId = vo.groupId2;
			if info == BagConsts.Equip_WuQi then
				item.shenWuLevel = roleInfo.shenWuLevel
				item.shenWuStar = roleInfo.shenWuStar
			end
		end
		table.push(list,item:GetUIData())
	end;
	return list
end


function RankListUtils:GetIsShowEquipGroup(vo)
	local groupId = vo.groupId2
	if groupId and groupId > 0 then 
		local cfg = t_equipgroup[groupId]
		if cfg  then 
			return ResUtil:GetNewEquipGrouNameIcon(cfg.nameicon,nil,true)
		end;
		return ""
	end;
	return ""
end;

function RankListUtils:GetEquipPos(pos)
	local servo = RankListModel.roleEqupeinfo;
	for i,vo in pairs(servo) do 
		local cfg = t_equip[vo.tid];
		if not cfg then return end;
		local cfgpos = t_equip[vo.tid].pos
		if  cfgpos == pos then 
			return vo
		end;
	end;
end;

--获取装备tip信息
function RankListUtils:GetEquipTipVO(tid,pos)
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	if not itemTipsVO then return; end
	local EquipInfo = RankListUtils:GetRoleRquipVo(tid)--RankListModel.roleEqupeinfo[e.item.tid];
	local roleInfo = RankListModel.roleDetaiedinfo;
	if EquipInfo then
		itemTipsVO.fight = EquipInfo.fight;
		itemTipsVO.strenLvl = EquipInfo.strenLvl;
		itemTipsVO.quality = EquipInfo.quality;
		itemTipsVO.refinLvl = EquipInfo.refinLvl;
		itemTipsVO.gemList = RankListModel:GetGemAtPos(pos)
		itemTipsVO.vipLvl = roleInfo.eaVIPLevel;
		if EquipInfo.bind == 0 then 
			itemTipsVO.bindState = BagConsts.Bind_None;
		else 
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end;
		itemTipsVO.superVO = {superNum = 0};
		itemTipsVO.washList = EquipInfo.superVO.superList;
		itemTipsVO.newSuperList = EquipInfo.newSuperList;
		itemTipsVO.extraLvl = EquipInfo.extraLvl
		itemTipsVO.groupId = EquipInfo.groupId;
		itemTipsVO.groupId2 = EquipInfo.groupId2;
		itemTipsVO.groupId2Level = EquipInfo.groupId2Level;
		itemTipsVO.groupEList = self:GetEquipList();
		if pos == BagConsts.Equip_JieZhi1 then
			itemTipsVO.ring = roleInfo.ring
		end
		if itemTipsVO.cfg.pos >= 0 and itemTipsVO.cfg.pos <= 10 then
			local quality = itemTipsVO.cfg.quality
			if quality >= BagConsts.Quality_Green1 and quality <= BagConsts.Quality_Green3 then
				itemTipsVO.newGroupInfo = RankListModel:GetNewEquipGroupInfo()
			end
		end
	else
		itemTipsVO.newGroupInfo = nil
	end
	local cfg = t_equip[tid];
	if cfg and cfg.pos == BagConsts.Equip_WuQi then 
		itemTipsVO.shenWuLevel = roleInfo.shenWuLevel
		itemTipsVO.shenWuStar = roleInfo.shenWuStar
		itemTipsVO.shenWuSkills = roleInfo.shenWuSkills
	end;
	
	return itemTipsVO;
end

--获取坐骑装备tip信息
function RankListUtils:GetMountEquipTipVO(tid)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	
	local vo = RankListModel:GetMountEquipVO(tid);
	if vo then
		if vo.bind == 0 then
			itemTipsVO.bindState = BagConsts.Bind_None;
		else
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end
		itemTipsVO.groupId = vo.groupId;
		itemTipsVO.groupEList = self:GetMountEquipList();
	end
	return itemTipsVO;
end

--获取灵兽装备tips
function RankListUtils:GetLingShouEquipTipVO(tid)
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	local vo = RankListModel:GetLingShouEquipVO(tid);
	if vo then
		if vo.bind == 0 then
			itemTipsVO.bindState = BagConsts.Bind_None;
		else
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end
		itemTipsVO.groupId = vo.groupId;
		itemTipsVO.groupEList = {};
		for i,equipInfo in ipairs(RankListModel.lingShouEquip) do
			local vo1 = {};
			vo1.id = equipInfo.id;
			vo1.groupId = equipInfo.groupId;
			table.push(itemTipsVO.groupEList,vo1);
		end
	end
	return itemTipsVO;
end

--获取翅膀tip信息
function RankListUtils:GetWingTipVO(tid,showBind)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	if showBind == 0 then
		itemTipsVO.bindState = BagConsts.Bind_None;
	else
		itemTipsVO.bindState = BagConsts.Bind_Bind;
	end
	local vo = RankListModel:GetBodyToolVO(tid);
	if RankListModel.roleDetaiedinfo.wingStarLevel and RankListModel.roleDetaiedinfo.wingStarLevel > 0 then
		itemTipsVO.wingStarLevel = RankListModel.roleDetaiedinfo.wingStarLevel;
		itemTipsVO.wingID = RankListModel.roleDetaiedinfo.wing;
	end
	if vo then
		itemTipsVO.wingTime = vo.val1;
		itemTipsVO.wingAttrFlag = vo.val2;
	end
	return itemTipsVO;
end

--获取人物翅膀VO
function RankListUtils:GetBodyToolList()
	local list = {};

	for i,vo in pairs(RankListModel.bodyToolList) do
		local item = ShowEquipSlotVO:new();
		item.pos = 1;
		item.bagType = BagConsts.BagType_RoleItem;
		item.hasItem = true;
		item.tid = vo.wingid;

		if vo.wingState == 0 then
			item.bindState = BagConsts.Bind_None;
		else
			item.bindState = BagConsts.Bind_Bind;
		end
		table.push(list,item);
	end
	
	if #list == 0 then
		local item = ShowEquipSlotVO:new();
		item.pos = 1;
		item.bagType = BagConsts.BagType_RoleItem;
		table.push(list,item);
	end
	
	return list;
end

--获取人物翅膀id
function RankListUtils:GetWingId()
	local id = 0;

	for i,vo in pairs(RankListModel.bodyToolList) do
		id = t_item[vo.wingid].link_param;
		break;
	end
	
	return id;
end

--获取装备列表 （用于tip套装显示）
function RankListUtils:GetEquipList()
	local list = {};
	for i,equipInfo in pairs(RankListModel.roleEqupeinfo) do
		local vo = {};
		vo.id = equipInfo.tid;
		vo.groupId = equipInfo.groupId;
		vo.groupId2 = equipInfo.groupId2;
		vo.groupId2Level = equipInfo.groupId2Level;
		table.push(list,vo);
	end
	return list;
end

--获取装备列表 （用于tip套装显示）
function RankListUtils:GetMountEquipList()
	local list = {};
	for i,equipInfo in ipairs(RankListModel.mountEquip) do
		local vo = {};
		vo.id = equipInfo.id;
		vo.groupId = equipInfo.groupId;
		table.push(list,vo);
	end
	return list;
end



--根据其他人物坐骑装备list
function RankListUtils:GetMountEquipItemList()
	local list = {};
	local servo = RankListModel.mountEquip;
	for i,vo in pairs(servo) do 

		local item = ShowEquipSlotVO:new();
		if vo ~= 0 then 
			item.hasItem = true;
			item.tid = vo;
		else 
			item.hasItem = false;
		end;
		table.push(list,item:GetUIData())
	end;
	return list;
end


--获取玩家坐骑模型Id
function RankListUtils:GetPlayerMountModelId(mountlevel,roleid)
	local listvo = RankListUtils:GetMountListVo(roleid)
	if not listvo then return end;
	return MountUtil:GetModelIdByLevel(mountlevel,listvo.role)
end

--获取坐骑
function RankListUtils:GetMountVO(mountid)
	local mountVO = MountVO:new();
	--特殊坐骑
	if mountid > MountConsts.SpecailDownid then
		local cfgskn = t_horseskn[mountid];
		if cfgskn then
			mountVO.mountId = mountid;
			mountVO.mountLevel = cfgskn.id;
			mountVO.nameIcon = cfgskn.nameIcon;
			mountVO.shuzi_nameIcon = cfgskn.shuzi_nameIcon;
		end
	else
		--普通坐骑
		local cfg = t_horse[mountid];
		if cfg then
			mountVO.mountId = mountid;
			mountVO.mountLevel = cfg.id;
			mountVO.nameIcon = cfg.nameIcon;
			mountVO.shuzi_nameIcon = cfg.shuzi_nameIcon;
		end
	end
	
	return mountVO;
end

--  根据roleid 得到 server lsit vo
function RankListUtils:GetMountListVo(roleid)
	local list = {};
	if UIRanklistSuit:IsShow() then 
		list = RankListModel.MountList;
	elseif UIAllTheServerRankView:IsShow() then 
		list = RankListModel.atServerMountList;
	end;
	for i,info in ipairs(list) do 
		if info.roleid == roleid then 
			return info;
		end;
	end;
end;

--得到坐骑nameIcon
function RankListUtils:GetMountinfo(mountId)
	--特殊坐骑
	if mountId > MountConsts.SpecailDownid then
		local mountInfo = t_horseskn[mountId]
		if mountInfo == nil then
			return
		end
		
		return mountInfo
	--普通坐骑
	else
		local mountInfo = t_horse[mountId]
		if mountInfo == nil then
			return
		end
		
		return mountInfo
	end
end

--得到坐骑名称图标
function RankListUtils:GetMountIconName(mountId, name, prof)
	local info = self:GetMountinfo(mountId)
	if info == nil then
		return "";
	end
	
	--特殊坐骑
	if mountId > MountConsts.SpecailDownid then
		return info[name..prof]
	--普通坐骑
	else
		return info[name..prof]
	end
end

--获取在某个组的技能id
function RankListUtils:GetMountSkillInGroup(groupId)
	for k,skillVO in pairs(RankListModel.mountSkill) do
		local cfg = skillVO:GetCfg();
		if cfg and cfg.group_id==groupId then
			return skillVO;
		end
	end
	return nil;
end

--创建技能列表
function RankListUtils:GetOtherMountSortSkill()
	local skilllist = {};
	for k,cfg in pairs(t_passiveskill) do
		if cfg.showtype==SkillConsts.ShowType_Horse and cfg.level==1 then
			local userSkillVO = self:GetMountSkillInGroup(cfg.group_id);
			local vo = {};
			if userSkillVO then
				vo.skillId = userSkillVO:GetID();
				vo.lvl = userSkillVO:GetLvl();
			else
				vo.skillId = cfg.id;
				vo.lvl = 0;
			end
			table.push(skilllist,vo);
		end
	end
	local list = {};
	for i,skillgp in pairs(t_horseskill) do
		if skillgp then
			for j,vo in pairs(skilllist) do
				if skillgp.skillGroup == t_passiveskill[vo.skillId].group_id then
					list[i] = vo;
					break;
				end
			end
		end
	end
	
	return list;
end

--获取坐骑技能列表VO
function RankListUtils:GetMountSkillListVO(skillId,lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl
		vo.needItem = cfg.needItem;
		vo.needSpecail = cfg.needSpecail
		vo.effectStr = cfg.effectStr
		vo.icon = cfg.icon;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon,"");
		vo.group_id = cfg.group_id;
		vo.maxLvl = 0
		if t_skillgroup[cfg.group_id] then
			vo.maxLvl = t_skillgroup[cfg.group_id].maxLvl;
		end
	end
	return vo;
end

function RankListUtils:GetRoleRquipVo(tid)
	local servo = RankListModel.roleEqupeinfo;
	for i,info in ipairs(servo) do 
		if info.tid == tid then 
			return info;
		end;
	end
end;

-------------------------全服
function RankListUtils:AtServerGetList(type)
	if type == RankListConsts.LvlRank then 
		-- 等级排行list
		return RankListModel.atServerlvlList;
	elseif type == RankListConsts.FigRank then 
		-- 战力
		return RankListModel.atServerfightlist;
	elseif type == RankListConsts.ZuoRank then 
		-- 坐骑
		return RankListModel.atServerMountList;
	elseif type == RankListConsts.jingJie then 
		-- 境界
		return RankListModel.atServerjingJieList;
	elseif type == RankListConsts.Lingshou then 
		-- 灵兽
		return RankListModel.atServerlingShouList;
	-- elseif type == RankListConsts.LingZhen then 
	-- 	-- 灵阵
	-- 	return RankListModel.atServerlingZhenList;
	elseif type == RankListConsts.JixianBoss then 
		-- 极限挑战boss
		return RankListModel.atServerjxtzBossList;
	elseif type == RankListConsts.JixianMonster then 
		-- 极限挑战monster
		return RankListModel.atServerjxtzMonsterList;
	-- elseif type == RankListConsts.Shengbing then 
	-- 	-- 神兵
	-- 	return RankListModel.atServerShengbingList;
	end;

end;

function RankListUtils:GetRoleItemUIdata(info,curItemindex, isSmall)
	if not info then return end;
	if not curItemindex then return end;
	local vo = {};
	vo.roleid = info.roleid;
	vo.prof = info.role;
	vo.roleName = info.roleName;
	vo.roleLvl = info.lvl;
	vo.vipLvl  = info.vipLvl;
	local vipStr = ResUtil:GetVIPIcon(info.vipLvl);
	if vipStr and vipStr ~= "" then 
		vipStr = "<img src='"..vipStr.."'/>";
		vo.roleName = vipStr .. vo.roleName;
	end;
	-- local vflagStr = ResUtil:GetVIcon(info.vflag);
	-- if vflagStr and vflagStr ~= "" then 
		-- vflagStr = "<img src='"..vflagStr.."'/>";
		-- vo.roleName = vflagStr..vo.roleName;
	-- end;
	vo.isFirst = false;
	if info.rank == 3 then 
		vo.rank = "c";
		vo.isFirst = true;
		vo.isShowRank = false;
	elseif info.rank == 2 then 
		vo.rank = "b";
		vo.isFirst = true;
		vo.isShowRank = false;
	elseif info.rank == 1 then 
		vo.rank = "a";
		vo.isFirst = true;
		vo.isShowRank = false;
	else 
		vo.rank = info.rank;
		vo.isFirst = false;
		vo.isShowRank = true;
	end;
	if isSmall then
		vo.rank = info.rank;
		vo.isShowRank = true;
	end
	vo.xy = RankListConsts.TabPage[curItemindex]
	if info.role <= 0 or info.role > 4 then 
		print("*******Error********：abot roleType is nil . No ShowList   AT  ranklistSuitview  '119' line")
		return 
	end;
	if curItemindex == RankListConsts.LvlRank then 
		vo.txt = vo.roleName.."!"..info.lvl.."!"..t_playerinfo[info.role].name
	elseif curItemindex == RankListConsts.FigRank then 
		vo.txt = vo.roleName.."!"..info.lvl.."!"..t_playerinfo[info.role].name.."!"..info.fight;
	elseif curItemindex == RankListConsts.ZuoRank then
		if info.mountid == 0 then 
			vo.txt = vo.roleName.."!".." ".."!"..info.mountId;
		end; 
		if not t_horse[info.mountId] then return end;
		local name = t_horse[info.mountId]["name"..info.role]
		if not name then return end;
		vo.txt = vo.roleName.."!"..name.."!"..info.mountId;
	elseif curItemindex == RankListConsts.jingJie then 
		vo.txt = vo.roleName.."!"..t_playerinfo[info.role].name..'!'..info.jingjieVlue;
	elseif curItemindex == RankListConsts.Lingshou then 
		vo.txt = vo.roleName.."!"..info.lingshouName..'!'..info.lingshouOrder;
	-- elseif curItemindex == RankListConsts.LingZhen then 
	-- 	vo.txt = vo.roleName.."!"..info.lingzhenName..'!'..info.lingzhenOrder;
	elseif curItemindex == RankListConsts.JixianBoss then 
		vo.txt = vo.roleName.."!"..t_playerinfo[info.role].name..'!'..info.killNum;
	elseif curItemindex == RankListConsts.JixianMonster then 
		vo.txt = vo.roleName.."!"..t_playerinfo[info.role].name..'!'..info.monsterNum;
	elseif curItemindex == RankListConsts.Shengbing then
	 	vo.txt = vo.roleName.."!"..info.sbName..'!'..info.sbValue;
	elseif curItemindex == RankListConsts.MingYu then
	 	vo.txt = vo.roleName.."!"..info.myName..'!'..info.myValue;
	elseif curItemindex == RankListConsts.LingQi then
		vo.txt = vo.roleName.."!"..info.lqName..'!'..info.lqValue;
	elseif curItemindex == RankListConsts.Armor then
		vo.txt = vo.roleName.."!"..info.armorName..'!'..info.armorValue;
	end
	return UIData.encode(vo)
end;

----------- get技能

function RankListUtils:GetPassiveSkill(showType,listvo)
	local cfg = t_passiveskill
	return self:GetSkillUIData(showType,cfg,listvo)
end;

function RankListUtils:GetSkilllist(showType,listvo)
	local cfg = t_skill;
	return self:GetSkillUIData(showType,cfg,listvo)
end;


function RankListUtils:GetSkillUIData(showType,cfgT,listvo)
	if not cfgT then return; end
	if not showType then return; end
	local list = {};
	for k,cfg in pairs(cfgT) do
		if cfg.showtype==showType and cfg.level==1 then
			local userSkillVO = self:GetSkillInGroup(listvo,cfg.group_id);
			local vo = {};
			if userSkillVO then
				vo.skillId = userSkillVO:GetID();
				vo.lvl = userSkillVO:GetLvl();
				vo.cfg = cfg;
			else
				vo.skillId = cfg.id;
				vo.lvl = 0;
				vo.cfg = cfg;
			end
			table.push(list,vo);
		end
	end
	table.sort(list,function(A,B)
		local groupA = t_skillgroup[A.cfg.group_id];
		local groupB = t_skillgroup[B.cfg.group_id];
		return groupA.index < groupB.index;
	end);
	return list;
end;

function RankListUtils:GetSkillInGroup(listvo,grouid)
	for k,skillVO in pairs(listvo) do
		local cfg = skillVO:GetCfg();
		if cfg and cfg.group_id==grouid then
			return skillVO;
		end
	end
	return nil
end;

--获取灵阵列表VO
function RankListUtils:GetSkillListVO(skillId, lvl)
	local vo = {};
	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if cfg then
		vo.name = cfg.name;
		vo.lvl = lvl;
		if lvl == 0 then
			vo.lvlStr = StrConfig['skill101'];
			vo.iconUrl = ImgUtil:GetGrayImgUrl(ResUtil:GetSkillIconUrl(cfg.icon))
		else
			local maxLvl = SkillUtil:GetSkillMaxLvl(skillId);
			vo.lvlStr = string.format( StrConfig['skill102'], lvl, maxLvl );
			local skillVO = SkillModel:GetSkill(skillId);
			vo.showLvlUp = false;
			vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
		end
	end
	return vo;
end

-- 获取极限挑战榜的信息
function RankListUtils:GetJxtzInfo(roleId,type)
	local list = nil
	local val = 0;
	if type == RankListConsts.JixianBoss then 
		-- 极限挑战boss
		list = RankListModel:GetjxtzBosslist();
	elseif type == RankListConsts.JixianMonster then 
		-- 极限挑战monster
		list = RankListModel:GetjxtzMonsterlist();
	end;
	if not list then return end;
	for i,info in pairs(list) do 
		local rid = info.roleid;
		if rid == roleId then
			val = info.rankl
			if type == RankListConsts.JixianBoss then 
				-- 极限挑战boss
				val = info.killNum
			elseif type == RankListConsts.JixianMonster then 
				-- 极限挑战monster
				val = info.monsterNum
			end;
		end;
	end;
	return val or 0
end;
function RankListUtils:IsOpen(id)

	local func=FuncManager:GetFunc(id)
    return func:GetFuncOpenState()
end
function RankListUtils:GetlvlSource(lvl)
	local lvlStr = ""
	lvl = tonumber(lvl)
	if lvl < 10 then 
		lvlStr = lvl;
	elseif lvl == 10 then 
		lvlStr = "a"
	elseif lvl == 11 then 
		lvlStr = "b" 
	elseif lvl == 12 then 
		lvlStr = "c" 
	elseif lvl == 13 then 
		lvlStr = "d" 
	elseif lvl == 14 then 
		lvlStr = "e" 
	elseif lvl == 15 then 
		lvlStr = "f" 
	elseif lvl == 16 then 
		lvlStr = "g" 
	elseif lvl == 17 then 
		lvlStr = "h" 
	elseif lvl == 18 then 
		lvlStr = "i" 
	elseif lvl == 19 then 
		lvlStr = "g" 
	elseif lvl == 20 then 
		lvlStr = "k" 
	end;
	return lvlStr;
end;