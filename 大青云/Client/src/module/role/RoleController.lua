--[[
角色面板控制
lizhuangzhuang
2014年7月23日19:47:16
]]

_G.RoleController = setmetatable({},{__index=IController})
RoleController.name = "RoleController"

function RoleController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_LevelUp,self,self.OnHandLvlUp);
	--MsgManager:RegisterCallBack(MsgType.SC_YaoDan,self,self.OnYaoDanUpData);   -- changer ：houxudong
	-- MsgManager:RegisterCallBack(MsgType.SC_YaoHun,self,self.OnYaoHunUpData);
	--MsgManager:RegisterCallBack(MsgType.SC_YaoHunExchange,self,self.OnYaoHunExchange);
	MsgManager:RegisterCallBack(MsgType.SC_YaoHunAttrResult,self,self.OnYaoHunAttrResult);
	
	--查看他人信息
	MsgManager:RegisterCallBack(MsgType.SC_OtherHumanInfoRet,self,self.OnOtherHumanInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_OtherHumanBSInfoRet,self,self.OnOtherHumanBSInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_OtherHumanXXInfoRet,self,self.OnOtherHumanXXInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_OtherMountInfoRet,self,self.OnOtherMountInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_OtherWuhunInfoRet,self,self.OnOtherWuhunInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_OtherEquipGem,self,self.OnOtherEquipGemResult);

	MsgManager:RegisterCallBack(MsgType.SC_OtherBodyTool,self,self.OnOtherBodyToolResult);

	MsgManager:RegisterCallBack(MsgType.SC_OhterMagicWeaponInfo,self,self.OnOtherShengbingInfo);
	MsgManager:RegisterCallBack(MsgType.SC_OhterMingYuInfo,self,self.OnOtherMingYuInfo);
	MsgManager:RegisterCallBack(MsgType.SC_OhterBaoJiaInfo,self,self.OnOtherArmorInfo);
	MsgManager:RegisterCallBack(MsgType.SC_OhterFabaoInfo,self,self.OnOtherLingQiInfo);
end

--人物加点
function RoleController:ChangePlayerPoint(pointList)
	local msg = ReqHumanModifyAttyMsg:new();
	msg.attrData = pointList;
	MsgManager:Send(msg);
end

--提醒加点
function RoleController:RemindAddPoint()
	if MainPlayerModel.humanDetailInfo.eaLeftPoint >= PlayerConsts.RemindAddPoint then
		RemindController:AddRemind( RemindConsts.Type_EaLeftPoint )
		return true;
	else
		RemindController:ClearRemind( RemindConsts.Type_EaLeftPoint )
		return false;
	end
end

--手动升级
function RoleController:HandLvlUp()
	local info = MainPlayerModel.humanDetailInfo;
	if not t_lvup[info.eaLevel] then return; end
	local lvlExp = t_lvup[info.eaLevel].exp;
	local currentExp = info.eaExp;
	if currentExp < lvlExp then 
		FloatManager:AddNormal( string.format(StrConfig['role14']) );
		return
	end
	-- 打开2次确认面板
	local content = string.format( StrConfig['role18'], currentExp, lvlExp )
	local confirmFunc = function() -- 升等级
		local playerInfo = MainPlayerModel.humanDetailInfo
		if playerInfo.eaLevel == PlayerConsts:GetMaxLevel() then
			FloatManager:AddNormal( string.format(StrConfig['role21']) );
			return
		end
		local msg = ReqLevelUpMsg:new();
		MsgManager:Send(msg);
	end
	-- local cancelFunc = function() -- 升境界
	-- 	FuncManager:OpenFunc( FuncConsts.Realm, true );
	-- end
	-- UIConfirm:Open( content, confirmFunc, cancelFunc, StrConfig['role19'], StrConfig['role20'], true )
end

--手动升级结果
function RoleController:OnHandLvlUp(msg)
	if msg.result == -1 then
		FloatManager:AddNormal( string.format( StrConfig['role1'], PlayerConsts:GetManulLevel() ) );
	elseif msg.result == -2 then
		FloatManager:AddNormal(StrConfig['role2']);
	end
end

--查看他人宝石信息
function RoleController:ViewOtherRoleGem(roldId)
	local msg = ReqOtherHumanInfoMsg:new();
	msg.roleID = roldId;
	msg.type = 4;
	MsgManager:Send(msg);
	
	-- print('============查看他人宝石信息')
	-- trace(msg)
end

--查看他人卓越孔信息
function RoleController:ViewOtherRoleSuperHole(roldId)
	local msg = ReqOtherHumanInfoMsg:new();
	msg.roleID = roldId;
	msg.type = 5;
	MsgManager:Send(msg);
	
	-- print('============查看他人卓越孔信息')
	-- trace(msg)
end

--查看人物信息
function RoleController:ViewRoleInfo(roldId, othertype)
	if not roldId then
		return;
	end
	if roldId == 0 then
		return;
	end
	
	local roletype = othertype;
	if not roletype then
		roletype = 0;
	end
	
	if roletype == 0 then
		local typebase = bit.band(255, OtherRoleConsts.OtherRole_Base);
		local typegem = bit.band(255, OtherRoleConsts.OtherRole_Gem);
		local typebodytool = bit.band(255, OtherRoleConsts.OtherRole_BodyTool);
		roletype = typebase + typegem + typebodytool;
	end
	
	local msg = ReqOtherHumanInfoMsg:new();
	msg.roleID = roldId;
	msg.type = roletype;
	MsgManager:Send(msg);
	
	-- print('============查看人物信息')
	-- trace(msg)
end

--返回妖丹列表
function RoleController:OnYaoDanUpData(msg)
	local list = msg.list;
	RoleBoegeyPillModel:OnUpDataYaoDanHandler(list);
end

--返回妖魂值
function RoleController:OnYaoHunUpData(msg)
	local yaohunVal = msg.val;
	RoleBoegeyPillModel:OnUpDataYaoHunHandler(yaohunVal);
end

--服务器返回妖魂兑换(是否成功与哪个类型)
function RoleController:OnYaoHunExchange(msg)
	local obj = {};
	obj.result = msg.result;
	obj.type = msg.type;
	RoleBoegeyPillModel:OnUpDataYaoHunExchangeHandler(msg);
end

--服务器返回妖魂兑换属性列表
function RoleController:OnYaoHunAttrResult(msg)
	local list = msg.list;
	RoleBoegeyPillModel:OnUpDataYaoHunAttrResultHandler(list);
end

-----------------------------妖魂发送-----------------------------
function RoleController:OnExChangeYaoHunHandler(index)
	-- local msg = ReqYaoHunExchangeMsg:new();
	-- msg.type = index ;
	-- MsgManager:Send(msg)
end

-----------------------------查看他人信息-----------------------------
function RoleController:OnOtherHumanInfoResult(msg)
	FloatManager:AddCenter(StrConfig["role15"]);
end

function RoleController:OnOtherHumanBSInfoResult(msg)
	-- print('==============查看他人基本信息')
	-- trace(msg)
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
	if msg.type == 2 then
		RankListController:DetaiedInfoDeal(1,msg)
		return;
	end
	
	--清空数据
	OtherRoleModel:ClearOtherRoleInfo();
	
	local otherhumanDetailInfo = {};
	otherhumanDetailInfo.serverType = msg.serverType;
	otherhumanDetailInfo.dwRoleID = msg.roleID;
	otherhumanDetailInfo.eaName = msg.roleName;
	otherhumanDetailInfo.prof = msg.prof;
	otherhumanDetailInfo.eaLevel = msg.level;
	otherhumanDetailInfo.eaHp = msg.hp;
	otherhumanDetailInfo.eaMaxHp = msg.maxHp;
	otherhumanDetailInfo.eaMp = msg.mp;
	otherhumanDetailInfo.eaMaxMp = msg.maxMp;
	otherhumanDetailInfo.eaFight = msg.fight;
	otherhumanDetailInfo.eaGuildName = msg.guildName;
	otherhumanDetailInfo.eaVIPLevel = msg.vipLevel;
	otherhumanDetailInfo.sex = msg.sex;
	otherhumanDetailInfo.dress = msg.dress;
	otherhumanDetailInfo.arms = msg.arms;
	otherhumanDetailInfo.fashionshead = msg.fashionshead;
	otherhumanDetailInfo.fashionsarms = msg.fashionsarms;
	otherhumanDetailInfo.fashionsdress = msg.fashionsdress;
	otherhumanDetailInfo.wing = msg.wing;
	otherhumanDetailInfo.wingStarLevel = msg.wingStarLevel;
	otherhumanDetailInfo.suitflag = msg.suitflag;
	otherhumanDetailInfo.mountState = msg.mountState;
	otherhumanDetailInfo.wuhunState = msg.wuhunState;
	otherhumanDetailInfo.wuhunId = msg.wuhunId;
	otherhumanDetailInfo.eaGongJi = msg.att;
	otherhumanDetailInfo.eaFangYu = msg.def;
	otherhumanDetailInfo.eaMingZhong = msg.hit;
	otherhumanDetailInfo.eaBaoJi = msg.cri;
	otherhumanDetailInfo.eaShanBi = msg.dodge;
	otherhumanDetailInfo.eaRenXing = msg.defcri;
	otherhumanDetailInfo.eaGongJiSpeed = msg.attspper;
	otherhumanDetailInfo.eaMoveSpeed = msg.moveper;
	
	--潜能属性
	otherhumanDetailInfo.eaHunLi = msg.hl;
	otherhumanDetailInfo.eaTiPo = msg.tp;
	otherhumanDetailInfo.eaShenFa = msg.sf;
	otherhumanDetailInfo.eaJingShen = msg.js;
	--神武属性
	otherhumanDetailInfo.shenWuLevel, otherhumanDetailInfo.shenWuStar = self:ParseShenWu(msg.shenwu)
	otherhumanDetailInfo.shenWuSkills = self:GetShenWuSkills(msg.shenwuSkills)
	--配偶
	otherhumanDetailInfo.loveName = msg.loveName;
	
	--设置基本信息
	OtherRoleModel:SetBSInfo(otherhumanDetailInfo);

	--戒指等级
	otherhumanDetailInfo.ring = msg.ringlv
	
	--装备属性
	for i,vo in ipairs(msg.list) do
		--卓越属性
		local superVO = {};
		superVO.superNum = vo.superNum;
		superVO.superList = {};
		
		for k, v in pairs(vo.superList) do
			if v.id > 0 then
				table.push(superVO.superList, v)
			end
		end

		OtherRoleModel:SetEquipInfo(vo.tid,vo.bind,vo.strenLvl,vo.strenVal,vo.refinLvl,vo.attrAddLvl,vo.groupId,superVO,vo.newSuperList,vo.groupId2,vo.group2Level);
	end
end

function RoleController:ParseShenWu(shenwu)
	local level, star = 0, 0
	if shenwu then
		level = math.floor( shenwu / 10000 )
		star = shenwu % 10000
	end
	return level, star
end

function RoleController:GetShenWuSkills(swSkills)
	local skills = {}
	if swSkills then
		for _, vo in ipairs(swSkills) do
			table.push(skills, vo.skillId)
		end
	end
	return skills
end

function RoleController:OnOtherHumanXXInfoResult(msg)
	-- print('=============其他人详细信息')
	--trace(msg)
	-- debug.debug()
	--roleID判断
	if OtherRoleModel.otherhumanBSInfo.dwRoleID ~= msg.roleID then
		return;
	end
	
	-- local otherhumanXXInfo = {};
	-- otherhumanXXInfo.eaShanBi = msg.dodge;
	-- otherhumanXXInfo.eaRenXing = msg.defcri;
	-- otherhumanXXInfo.eaBaoJiHurt = msg.crivalue;
	-- otherhumanXXInfo.eaBaoJiDefense = msg.subcri;
	-- otherhumanXXInfo.eaChuanCiHurt = msg.absatt;
	-- otherhumanXXInfo.eaChuanTou = msg.defparry;
	-- otherhumanXXInfo.eaGeDang = msg.parryvalue;
	-- otherhumanXXInfo.eaHurtAdd = msg.adddamage;
	-- otherhumanXXInfo.eaHurtSub = msg.subdamage;
	
	-- otherhumanXXInfo.eaPKVal = msg.pkValue;
	-- otherhumanXXInfo.eaHonor = msg.pkHonor;
	-- otherhumanXXInfo.eaKillValue = msg.killValue;
	
	-- otherhumanXXInfo.eaSubdef = msg.subdef;
	-- otherhumanXXInfo.eaSuper = msg.super;
	-- otherhumanXXInfo.eaSuperValue = msg.supervalue;
	-- otherhumanXXInfo.eaShenwei = msg.shenWei;
		local attrList = msg.attrData
		local otherhumanXXInfo = {}
		-- UILog:print_table(attrList)
		
		for k, v in pairs(attrList) do
			otherhumanXXInfo[v.type] = v.value
			-- print('-------------------------v.type'..v.type)
			-- print('-------------------------v.value'..v.value)
		end
		-- UILog:print_table(otherhumanXXInfo)
	--设置详细信息
	OtherRoleModel:SetXXInfo(otherhumanXXInfo);
end
function RoleController:OnOtherMountInfoResult(msg)
	-- print('=============其他人坐骑')
	-- trace(msg)

	if msg.type == 2 then
		RankListController:DetaiedInfoDeal(2,msg)
		return;
	end
	--roleID判断
	if OtherRoleModel.otherhumanBSInfo.dwRoleID ~= msg.roleID then
		return;
	end
	
	--清空坐骑数据
	OtherRoleModel:ClearOtherMountInfo();
	
	OtherRoleModel.rideLevel = msg.rideLevel;
	OtherRoleModel.rideStar = OtherRoleUtil:GetStarByProgress(msg.rideLevel, msg.starProgress);
	OtherRoleModel.rideSelect = msg.rideSelect;
	OtherRoleModel.pillNum = msg.pillNum;
	
	--坐骑装备
	for i,vo in pairs(msg.equiplist) do
		OtherRoleModel:AddMountEquip(vo.id, vo.bind, vo.groupId);
	end
	
	--坐骑技能
	for i,vo in pairs(msg.skilllist) do
		if vo.skillid > 0 then
			local skillVO = SkillVO:new(vo.skillid);
			OtherRoleModel:AddMountSkill(skillVO);
		end
	end
	
	--属性百分比皮肤
	for i,vo in ipairs(msg.attrlist) do
		local vox = {};
		vox.type = vo.type;
		vox.val = vo.valX;
		OtherRoleModel:AddAttrX(vox);
	end
	
	UIOtherMountBasic:Show();
end
function RoleController:OnOtherWuhunInfoResult(msg)
	-- print('=============查看他人武魂信息')
	-- trace(msg)

	-- 排行榜信息
	if msg.type == 2 then
		RankListModel:SetOtherRoleLingShouinfo(msg.roleID,msg.wuhunId,msg.serverType,msg.equiplist)
		return;
	end

	--roleID判断
	if OtherRoleModel.otherhumanBSInfo.dwRoleID ~= msg.roleID then
		return;
	end
	
	--清空武魂数据
	OtherRoleModel:ClearOtheWuHunInfo();
	
	OtherRoleModel:SetWuhunInfo(msg.wuhunId,msg.wuhunselectId,msg.hunzhu,msg.feedNum,msg.wuhunState);
	
	for i,vo in ipairs(msg.equiplist) do
		OtherRoleModel:AddLingShouEquip(vo.id, vo.bind, vo.groupId);
	end
	
	--属性百分比皮肤
	for i,vo in pairs(msg.attrlist) do
		local vox = {};
		vox.type = vo.type;
		vox.val = vo.valX;
		OtherRoleModel:AddAttrX(vox);
	end
	
	UIOtherSpirits:Show();
end

--装备宝石信息
function RoleController:OnOtherEquipGemResult(msg)
	-- print('=============装备宝石信息')
	-- trace(msg)
	
	if msg.type == 2 then
		RankListModel:ClearGemList();
		for i,vo in pairs(msg.list) do
			RankListModel:SetGemInfo(vo.pos, vo.slot, vo.tid);
		end
		return;
	end
	
	OtherRoleModel:ClearGemList();
	
	for i,vo in pairs(msg.list) do
		OtherRoleModel:SetGemInfo(vo.pos, vo.slot, vo.tid);
	end
end

--身上道具信息
function RoleController:OnOtherBodyToolResult(msg)
	-- print('=============身上道具信息')
	-- trace(msg)
	if msg.petID>0 then
		OtherRoleModel:SetPetVO(msg.petID);
	end
	local list = {};
	for i,vo in pairs(msg.list) do
		local toolvo = {};
		toolvo.wingid = vo.wing;
		toolvo.bingstate = vo.wingState;
		toolvo.val1 = vo.val1;
		toolvo.val2 = vo.val2;
		list[vo.wing] = toolvo;
	end
	
	if msg.type == 2 then
		RankListModel:SetBodyToolInfo(list);
		return;
	end
	
	OtherRoleModel:SetBodyToolInfo(list);
	
	--显示菜单
	UIOtherRole:Show();
end

--神兵协议
function RoleController:OnOtherShengbingInfo(msg)
	if msg.type == 2 then --排行榜协议
		RankListModel:SetOtherRoleShengBing(msg.roleID,msg.level,msg.skills,msg.serverType, msg.equiplist);
		return
	end;
end;


--玉佩协议
function RoleController:OnOtherMingYuInfo(msg)
	if msg.type == 2 then --排行榜协议
		RankListModel:SetOtherRoleMingYu(msg.roleID,msg.level,msg.skills,msg.serverType, msg.equiplist);
		return
	end;
end;


--宝甲协议
function RoleController:OnOtherArmorInfo(msg)
	if msg.type == 2 then --排行榜协议
	RankListModel:SetOtherRoleArmor(msg.roleID,msg.level,msg.skills,msg.serverType, msg.equiplist);
	return
	end;
end;

--灵器协议
function RoleController:OnOtherLingQiInfo(msg)
	if msg.type == 2 then --排行榜协议
	RankListModel:SetOtherRoleLingQi(msg.roleID,msg.level,msg.skills,msg.serverType, msg.equiplist);
	return
	end;
end;