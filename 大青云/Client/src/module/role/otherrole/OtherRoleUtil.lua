--[[
OtherRoleUtil
zhangshuhui
2015年1月16日16:58:16
]]

_G.OtherRoleUtil = {};

OtherRoleUtil.size = 50
OtherRoleUtil.gap = 16
OtherRoleUtil.startX = 106
OtherRoleUtil.startY = 661
OtherRoleUtil.hunzhuNum = 5
OtherRoleUtil.wuhunOrderList = {}

--获取人物装备VO
function OtherRoleUtil:GetEquipUIVO(pos,isBig)
	-- WriteLog(LogType.Normal,true,'---------------------获取人物装备VO:',pos)

	local tid = self:GetRoleEquipIdByPos(pos)
	
	local item = ShowEquipSlotVO:new();
	item.pos = pos;
	item.bagType = BagConsts.BagType_Role;
	if tid then
		item.hasItem = true;
		item.tid = tid;
		item.strenLvl = OtherRoleModel:GetStrenLvl(tid);
		if OtherRoleModel:GetBingState(tid) == 0 then
			item.bindState = BagConsts.Bind_None;
		else
			item.bindState = BagConsts.Bind_Bind;
		end
		item.equipGroupId = OtherRoleModel:GetGroupId2(tid);
		if pos == BagConsts.Equip_WuQi then
			item.shenWuLevel = OtherRoleModel.otherhumanBSInfo.shenWuLevel
			item.shenWuStar = OtherRoleModel.otherhumanBSInfo.shenWuStar
		end
	end
	return item;
end

--获取人物翅膀VO
function OtherRoleUtil:GetBodyToolList()
	local list = {};

	for i,vo in pairs(OtherRoleModel.bodyToolList) do
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
--获取人物宠物VO
function OtherRoleUtil:GetBodyToolListPet()
	local list = {};

	for i,vo in pairs(OtherRoleModel.bodyToolListPet) do
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
function OtherRoleUtil:GetWingId()
	local id = 0;

	-- for i,vo in pairs(OtherRoleModel.bodyToolList) do
		-- id = t_item[vo.wingid].link_param;
		-- break;
	-- end
	
	return id;
end

--获取装备tip信息
function OtherRoleUtil:GetEquipTipVO(tid,pos)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	if not itemTipsVO then return; end
	local EquipInfo = OtherRoleModel.equipInfoList[tid];
	if EquipInfo then
		itemTipsVO.strenLvl = EquipInfo.strenLvl;
		itemTipsVO.extraLvl = EquipInfo.extraLvl;
		itemTipsVO.refinLvl = EquipInfo.refinLvl;
		
		if OtherRoleModel:GetBingState(tid) == 0 then
			itemTipsVO.bindState = BagConsts.Bind_None;
		else
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end
		itemTipsVO.gemList = {};
		itemTipsVO.gemList = OtherRoleModel:GetGemAtPos(pos);
		itemTipsVO.vipLvl  = VipController:GetVipLevelByFlag(OtherRoleModel.otherhumanBSInfo.eaVIPLevel);
		itemTipsVO.superVO = {superNum = 0};
		itemTipsVO.washList = EquipInfo.superVO.superList;
		itemTipsVO.newSuperList = EquipInfo.newSuperList;
		itemTipsVO.groupId = EquipInfo.groupId;
		itemTipsVO.groupId2 = EquipInfo.groupId2;
		itemTipsVO.groupId2Level = EquipInfo.groupId2Level;
		itemTipsVO.groupEList = self:GetEquipList();

		if pos == BagConsts.Equip_JieZhi1 then
			itemTipsVO.ring = OtherRoleModel.otherhumanBSInfo.ring
		end
		if pos >= 0 and pos <= 10 then
			local quality = itemTipsVO.cfg.quality
			if quality >= BagConsts.Quality_Green1 and quality <= BagConsts.Quality_Green3 then
				itemTipsVO.newGroupInfo = OtherRoleModel:GetNewEquipGroupInfo()
			end
		end
	else
		itemTipsVO.newGroupInfo = nil
	end
	itemTipsVO.shenWuLevel = OtherRoleModel.otherhumanBSInfo.shenWuLevel
	itemTipsVO.shenWuStar = OtherRoleModel.otherhumanBSInfo.shenWuStar
	itemTipsVO.shenWuSkills = OtherRoleModel.otherhumanBSInfo.shenWuSkills
	return itemTipsVO;
end

--获取坐骑装备tip信息
function OtherRoleUtil:GetMountEquipTipVO(tid)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	
	local vo = OtherRoleModel:GetMountEquipVO(tid);
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
function OtherRoleUtil:GetLingShouEquipTipVO(tid)
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	local vo = OtherRoleModel:GetLingShouEquipVO(tid);
	if vo then
		if vo.bind == 0 then
			itemTipsVO.bindState = BagConsts.Bind_None;
		else
			itemTipsVO.bindState = BagConsts.Bind_Bind;
		end
		itemTipsVO.groupId = vo.groupId;
		if itemTipsVO.groupId > 0 then
			itemTipsVO.groupEList = {};
			for i,equipInfo in ipairs(OtherRoleModel.lingShouEquiplist) do
				local vo1 = {};
				vo1.id = equipInfo.id;
				vo1.groupId = equipInfo.groupId;
				table.push(itemTipsVO.groupEList,vo1);
			end
		else
			itemTipsVO.groupEList = {};
		end
	end
	return itemTipsVO;
end

--获取翅膀tip信息
function OtherRoleUtil:GetWingTipVO(tid,showBind)
	--他人信息中个数是1  绑定状态为1
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid,1,1);
	if showBind == 0 then
		itemTipsVO.bindState = BagConsts.Bind_None;
	else
		itemTipsVO.bindState = BagConsts.Bind_Bind;
	end
	local vo = OtherRoleModel:GetBodyToolVO(tid);
	if OtherRoleModel.otherhumanBSInfo.wingStarLevel and OtherRoleModel.otherhumanBSInfo.wingStarLevel > 0 then
		itemTipsVO.wingStarLevel = OtherRoleModel.otherhumanBSInfo.wingStarLevel;
		itemTipsVO.wingID = OtherRoleModel.otherhumanBSInfo.wing;
	end
	if vo then
		itemTipsVO.wingTime = vo.val1;
		itemTipsVO.wingAttrFlag = vo.val2;
	end
	return itemTipsVO;
end

--获取装备列表 （用于tip套装显示）
function OtherRoleUtil:GetEquipList()
	local list = {};
	for i,equipInfo in pairs(OtherRoleModel.equipInfoList) do
		local vo = {};
		vo.id = equipInfo.id;
		vo.groupId = equipInfo.groupId;
		vo.groupId2 = equipInfo.groupId2;
		vo.groupId2Level = equipInfo.groupId2Level;
		table.push(list,vo);
	end
	return list;
end

--获取装备列表 （用于tip套装显示）
function OtherRoleUtil:GetMountEquipList()
	local list = {};
	for i,equipInfo in ipairs(OtherRoleModel.othermountequiplist) do
		local vo = {};
		vo.id = equipInfo.id;
		vo.groupId = equipInfo.groupId;
		table.push(list,vo);
	end
	return list;
end

--获取坐骑装备VO
function OtherRoleUtil:GetMountEquipUIList(list)
	local UIDatalist = {};
	for i,pos in ipairs(MountConsts.MountEquipType) do
		local tid, bind = self:GetMountEquipIdByPos(pos,list)
	
		local item = ShowEquipSlotVO:new();
		item.pos = pos - 20;
		item.bagType = BagConsts.BagType_Horse;
		if tid then
			item.hasItem = true;
			item.tid = tid;
			if bind == 0 then
				item.bindState = BagConsts.Bind_None;
			else
				item.bindState = BagConsts.Bind_Bind;
			end
		end
		
		table.push(UIDatalist,item:GetUIData());
	end
	
	return UIDatalist;
end

--获取灵兽装备VO
function OtherRoleUtil:GetLingShouEquipUIList(list)
	local uilist = {};
	for i,vo in ipairs(list) do
		local item = ShowEquipSlotVO:new();
		item.pos = i-1;
		item.bagType = BagConsts.BagType_LingShou;
		if vo.id > 0 then
			item.hasItem = true;
			item.tid = vo.id;
			if vo.bind == 0 then
				item.bindState = BagConsts.Bind_None;
			else
				item.bindState = BagConsts.Bind_Bind;
			end
		end
		table.push(uilist,item:GetUIData());
	end
	return uilist;
end

--获取物品图标
function OtherRoleUtil:GetItemIcon(id,big)
	local size = "";
	if big then
		size = "54";
	end
	local defaultIcon = "img://resfile/itemicon/default.png";
	local equipConfig = t_equip[id];
	if not equipConfig then return defaultIcon; end
	return ResUtil:GetItemIconUrl(equipConfig.icon,size);
end

function OtherRoleUtil:GetRoleEquipIdByPos(pos)
	--是否是同一个装备位
	for k,cfg in pairs(OtherRoleModel.equipInfoList) do
		local equipvo = t_equip[k];
		if equipvo then
			if pos == equipvo.pos then
				return k;
			end
		end
	end
	
	return nil;
end

function OtherRoleUtil:GetMountEquipIdByPos(pos,list)
	--是否是同一个装备位
	for k,cfg in pairs(list) do
		local equipvo = t_equip[cfg.id];
		if equipvo then
			if pos == equipvo.pos then
				return cfg.id, cfg.bind;
			end
		end
	end
	
	return nil;
end

--获取坐骑
function OtherRoleUtil:GetMountVO(mountid)
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

--获取玩家坐骑模型Id
function OtherRoleUtil:GetPlayerMountModelId(mountlevel)
	return MountUtil:GetModelIdByLevel(mountlevel,OtherRoleModel.otherhumanBSInfo.prof)
end

--坐骑技能排序
function OtherRoleUtil:GetOtherMountSortSkill()
	local skilllist = {};
	for k,cfg in pairs(t_passiveskill) do
		if cfg.showtype==SkillConsts.ShowType_Horse and cfg.level==1 then
			local userSkillVO = OtherRoleModel:GetSkillInGroup(cfg.group_id);
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

--获取列表VO
function OtherRoleUtil:GetSkillListVO(skillId,lvl)
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

--坐骑其他属性
function OtherRoleUtil:GetMountOtherAttribute(mountlevel,star)
	local horselist = {};
	local horseattrlist = {};

	local keyMap = {"att","def","hp","cri","defcri","dodge","hit","movespeed"};
	
	--坐骑等阶属性
	local horseCfg = t_horse[mountlevel];
	if horseCfg then
		local vo = {};
		vo.type = AttrParseUtil.AttMap["movespeed"];
		vo.val = horseCfg["speed"];
		table.push(horselist,vo);
	end
	--坐骑属性
	for i,k in pairs(OtherRoleModel.otherattrXlist) do
		local vo = {};
		vo.type = i;
		vo.val = toint(k);
		table.push(horseattrlist,vo);
	end
	
	local list = {};
	list = self:AddUpAttrIsNil(horselist,horseattrlist);
	
	--战斗力计算
	local equipAddFight = {};
	local vo = {};
	vo.type = enAttrType.eaFight;
	vo.val = EquipUtil:GetFight(list);
	table.push(equipAddFight,vo);
	return self:AddUpAttrIsNil(list,equipAddFight);
end

function OtherRoleUtil:AddUpAttrIsNil(list1,list2)
	if list1 == nil then
		return list2;
	end
	
	if list2 == nil then
		return list1;
	end
	
	return EquipUtil:AddUpAttr(list1,list2);
end

--坐骑总属性
function OtherRoleUtil:GetMountAttribute(mountlevel,star)
	local otherattrlist = self:GetMountOtherAttribute(mountlevel,star)
	return otherattrlist;
end

-- 武魂列表显示
--{node.wuhunId,
-- node.iconUrl,
-- node.isFushen,
-- node.levelUrl,
-- node.nameUrl
-- node.selected
-- }
function OtherRoleUtil:GetWuhunList(selectedIndex)
	self.wuhunOrderList = {};
	
	for index, wuhunVO in pairs(OtherRoleModel.wuhunList) do
		if selectedIndex and index == selectedIndex then
			-- FPrint('选中了'..index)
			table.push(self.wuhunOrderList, self:GetWuhunListVo(wuhunVO.wuhunId, 1))
		else	
			-- FPrint('没选中'..index)
			table.push(self.wuhunOrderList, self:GetWuhunListVo(wuhunVO.wuhunId, 0))
		end
	end
	
	if #self.wuhunOrderList > 0 then
		table.sort(self.wuhunOrderList,function(A,B)
					if A.wuhunId < B.wuhunId then
						return true
					else
						return false
					end
				end)
	end

	return self.wuhunOrderList;
end

-- 得到武魂在列表中第一个
function OtherRoleUtil:GetWuhunFirst()
	if #self.wuhunOrderList > 0 then
		return self.wuhunOrderList[1].wuhunId;
	end
	
	return -1
end

function OtherRoleUtil:GetWuhunListVo(wuhunId, isSelected)
	local wuhunVO = OtherRoleModel:getWuhuVO(wuhunId, isSelected)

	local node = {}
		-- Debug("--------------------------"..type(wuhunVO.wuhunId)..wuhunVO.wuhunId)
	local cfg = t_wuhun[wuhunVO.wuhunId]
	-- trace(cfg)
	node.wuhunId = wuhunVO.wuhunId
	-- Debug("--------------------------"..cfg.face_icon)
	-- 图标
	--self:Print('是否选中'..isSelected..'//'..wuhunId)
	node.isKejihuo = 0 
	if wuhunVO.wuhunState == 0 then
		node.iconUrl = ResUtil:GetWuhunIcon(cfg.face_icon..'_d')
		if OtherRoleModel:IsActive(wuhunVO.wuhunId) then
			node.isKejihuo = 1 
		end
	elseif isSelected == 1 then
		node.iconUrl = ResUtil:GetWuhunIcon(cfg.face_icon..'_p')
	else
		node.iconUrl = ResUtil:GetWuhunIcon(cfg.face_icon)
	end
	
	node.selected = isSelected
	
	-- 附身图标
	if wuhunVO.wuhunState == 2 then
		node.isFushen = 1
	else
		node.isFushen = 0
	end
	
	-- 未激活等级图标
	-- Debug("------------------------"..wuhunVO.wuhunState)
	node.canActiveUrl = ''
	if wuhunVO.wuhunState == 0 then
		node.levelUrl = ResUtil:GetWuhunNoGetIcon()
	else
		node.levelUrl = ResUtil:GetWuhunLevelIcon(cfg.order)
	end
	
	-- 名字图标		
	node.nameUrl = ResUtil:GetWuhunIcon(cfg.name_icon .. "_1")
	
	return node
end

-- 当前选中的魂珠
function OtherRoleUtil:GetSelectedWuhunPos(wuhunId)
	local index = OtherRoleModel:GetWuhunIndex(wuhunId)
	-- self:Print(index)
	local x = self.startX + index * (self.size + self.gap)
	return x, self.startY, index
end

-- 武魂状态
function OtherRoleUtil:GetWuHunState(wuhunId)
	for index, wuhunVO in pairs(OtherRoleModel.wuhunList) do
		if wuhunVO then
			if wuhunVO.wuhunId == wuhunId then
				return wuhunVO.wuhunState;
			end
		end
	end
	
	return 0;
end

--是否有激活的武魂
function OtherRoleUtil:GetIsHaveActiveSpirite()
	for index, wuhunVO in pairs(OtherRoleModel.wuhunList) do
		if wuhunVO then
			if wuhunVO.wuhunState > 0 then
				return true;
			end
		end
	end
	
	return false;
end

--根据进度得到当前星
function OtherRoleUtil:GetStarByProgress(order, progress)
	local info = t_horse[order];
	if info == nil then
		return 0;
	end
	
	local star = progress / (info.wish_max / MountConsts.MountStarMax);
	star = math.modf(star);
	return star;
end

--得到武魂被动技能
function OtherRoleUtil:GetWuHunBeiDongSkill()
	local skillList = {};
	local cfg = t_wuhun[OtherRoleModel:GetWuhunId()]
	local skillCfg = split(cfg.gift_skill,"#");
	for i,info in ipairs(skillCfg) do 
		local skvo = SkillVO:new(tonumber(info));
		skillList[skvo:GetID()] = skvo
	end
	
	return skillList;
end