CAttrCtrl = class("CAttrCtrl", CCtrlBase)

function CAttrCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetAll()
end

--所有属性都有默认值
function CAttrCtrl.ResetAll(self)
	self.m_LoginInit = false

	--人物属性
	self.pid = 0
	self.server_grade = 0
	self.days = 0
	self.org_status = 0
	--服务端属性
	self.grade = 1					--等级	
	self.name = ""					--名字
	self.title_info = {}			--称谓
	self.coin = 0		    		--金币	
	self.goldcoin = 0				--水晶
	self.silver= 0					--银币(暂时不需要)
	self.arenamedal = 0				--荣誉(比武场)
	self.medal = 0					--勋章(爬塔货币)
	self.skin = 0					--皮肤券
	self.exp = 0
	self.chubeiexp = 0
	self.max_hp = 0					--气血
	self.hp = 0						
	self.attack = 0					--攻击
	self.defense = 0				--防御
	self.speed = 0					--速度
	self.critical_ratio = 0			--暴击率
	self.res_critical_ratio = 0		--抗暴击率
	self.critical_damage = 0		--暴击伤害率
	self.cure_critical_ratio = 0	--治疗暴击率
	self.abnormal_attr_ratio = 0	--异常命中率
	self.res_abnormal_ratio = 0		--异常抵抗率
	self.power = 0					--战斗力
	self.model_info = {}			--造型信息
	self.school = 0					--职业
	self.school_branch = 0			--职业分支
	self.gold_over = 0
	self.silver_over = 0
	self.skill_point = 0			--技能点
	self.vip_level = 0				--Vip等级
	self.systemsetting = nil		--系统设置

	self.upvote_amount = 0			--点赞数量
    self.org_id = 0					--公会ID
    self.orgname = "无"				--公会名称
    self.org_pos = 0				--公会职位id
    self.org_offer = 0				--公会贡献
    self.is_org_wish = 0			--是否进行过碎片许愿
    self.is_equip_wish = 0			--是否进行过装备许愿
	--{
		--teamsetting = {},			--组队设置			
	--}			
	self.server_time = 0			--服务器时间
	self.sex = 0					--性别
	self.active = 0					--活跃度
	self.org_build_status  = 0		--帮派建设状态,0:无,1-3:建设类型,4:完成,5:领取奖励
	self.org_sign_reward = 0  		--帮派签到进度奖励
	self.org_build_time = 0			--帮派建设结束时间
	self.org_red_packet = 0			--当天是否领取过帮派红包,1:领取过
	self.give_org_wish = {}			--当天赠送碎片许愿列表
	self.give_org_equip = {}		--当天赠送装备许愿列表
	self.trapmine_point = 0			--暗雷探索点
	self.org_fuben_cnt = 0          --公会副本剩余次数
	self.travel_score = 0			--游历积分
	self.color_coin = 0				--彩晶
	self.org_leader = nil			--公会会长
	self.org_level = nil			--公会等级
	self.bcmd = {}					--战斗指令
	self.followers = {}
	self.open_day = 0				--开服天数，0-开始
	self.energy = 0					--体力，剧情副本用
	self.kp_sdk_info = {create_time=nil, upgrade_time=nil}--提供靠谱sdk信息
	self.m_SkinList = {}			--拥有的皮肤列表(GS2CShapeList)
	self.camp = 0					--阵容


	self.m_GetPlayerInfoTime = nil	--请求玩家信息时间
end

function CAttrCtrl.UpdateAttr(self, dict)
	local dPreAttr = {} --保存下修改前的数据方便
	local dChange = {}
	for k , v in pairs(dict) do
		if self[k] ~= v then
			dPreAttr[k] = self[k]
			self[k] = v
			dChange[k] = v
		end
	end
	local bUploadCreate = false
	if next(dChange) then
		if self.m_LoginInit then
			if dChange.name or dChange.model_info or self.title_info then
				g_MapCtrl:UpdateHero()
			end
			if dChange.school_branch then
				self:SchoolChange()
			end
			if dChange.grade then
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					oHero:ShowLevelUpEffect()
				end
				g_SdkCtrl:UploadData(enum.Sdk.UploadType.level_up)
			end
			if dChange.power  and dPreAttr.power then
				dChange.power = dChange.power + self:GetPartPower()
				dPreAttr.power = dPreAttr.power + self:GetPartPower()
			end	
			if self.exp ~= 0 and self:HasAttrChange(dPreAttr, dChange) and g_ItemCtrl:GetShowAttrChangeFlag() then
				g_ItemCtrl:SetShowAttrChangeFlag(false)
				g_ItemCtrl:ShowAttrChangeAttrTips(dPreAttr, dChange)
			end
			if dChange.name ~= "" and dPreAttr.name == "" then
				bUploadCreate = true
			end
			if dChange.goldcoin then
				local iCoin = dChange.goldcoin - dPreAttr.goldcoin
				if iCoin ~= 0 then
					if iCoin > 0 then
						g_SdkCtrl:GainGameCoin(iCoin)
					else
						g_SdkCtrl:ConsumeGameCoin(iCoin)
					end
				end
			end
			self:OnEvent(define.Attr.Event.Change, {dAttr = dChange, dPreAttr = dPreAttr})
		end
		if dChange.org_id then
			g_QQPluginCtrl:ResetQQGroupInfo()
		end
		if dChange.grade then
			g_GuideCtrl:TriggerCheck("grade")
			if dChange.grade >= data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade and not g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_Skill") then
				g_GuideCtrl:StartTipsGuide("Tips_Skill")
			end
			if dChange.grade >= data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade then				
				g_TaskCtrl:RefreshUI()
			end
		end
	end
	if bUploadCreate then
		g_SdkCtrl:UploadData(enum.Sdk.UploadType.create_role)
		g_SdkCtrl:UploadData(enum.Sdk.UploadType.start_game)
	end
	if dChange.followers then
		if next(dChange.followers) == nil then
			g_MapCtrl:DelAllFollowWalker()
		else
			g_MapCtrl:DelAllFollowWalker()
			for j,c in pairs(dChange.followers) do
				g_MapCtrl:AddFollowPartner(c)
			end
		end
	end
	self.m_LoginInit = true
end

function CAttrCtrl.SchoolChange(self)

end

function CAttrCtrl.GetUpgradeExp(self, iGrade)
	if not iGrade then
		iGrade = self.grade
	end
	local expinfo = data.upgradedata.DATA[iGrade + 1]
	if expinfo then
		return expinfo.player_exp
	else
		return 0
	end
end

function CAttrCtrl.GetCurGradeExp(self, iGrade, iCurExp)
	if not iGrade then
		iGrade = self.grade
	end
	if not iCurExp then
		iCurExp = self.exp
	end
	local expinfo = data.upgradedata.DATA[iGrade]
	local iSumExp = 0
	if expinfo then
		iSumExp =  expinfo.sum_player_exp or 0
	end
	return iCurExp - iSumExp

end

function CAttrCtrl.C2GSChangeSchool(self )
	--TODO
	local branch = self.school_branch
	if branch == 1 then
		branch = 2
	else
		branch = 1
	end
	netplayer.C2GSChangeSchool(branch)
end

--判断某个属性是否是人物属性
--key(hp, speed 等)
function CAttrCtrl.IsAttrKey(self, key)
	local b = false
	for _, k in pairs(define.Attr.AttrKey) do
		if key == k then
			b = true
			break
		end
	end
	return b
end

--获取流派名称
--school 门派
--branch 流派分支
function CAttrCtrl.GetSchoolBranchStr(self, school, branch)
	local s = "未知流派"
	local d = data.roletypedata.BRANCH_TYPE
	if d then
		for k, v in pairs(d) do
			if v.school == school and v.branch == branch then
				s = v.name
				break
			end
		end
	end
	return s
end

--获取流派名称
--school 门派
--branch 流派分支
function CAttrCtrl.GetSchoolStr(self, school)
	local s = "门派"
	local d = data.roletypedata.BRANCH_TYPE
	if d then
		for k, v in pairs(d) do
			if v.school == school then
				s = v.school_name
				break
			end
		end
	end
	return s
end

--获取综合战力
function CAttrCtrl.GetTotalPower(self)
	return (self.power + self:GetPartPower())
end

function CAttrCtrl.GetPartPower(self)
	local partnerPower = 0
	local t = {}
	local list = g_PartnerCtrl:GetPartnerList()
	if list and next(list) then
		for i, dPartner in ipairs(list) do
			table.insert(t, dPartner:GetValue("power"))
		end
	end
	table.sort(t, function(a, b)
		return a > b
	end)

	for i = 1, 4 do
		if t[i] then
			partnerPower = partnerPower + t[i]
		end
	end
	return partnerPower
end

--获取当前使用的武器类型
function CAttrCtrl.GetMyFitWeaponType(self)
	local weaponType = 0
	local d = data.itemdata.SCHOOL_WEAPON 
	for i = 1, #d do
		if d[i].school == self.school and d[i].branch == self.school_branch then
			weaponType = d[i].weapon
		end
	end
	return weaponType
end

--获取当前  门派(大职业) 的武器类型
function CAttrCtrl.GetMyFitSchoolWeaponType(self)
	local weaponType = {}
	local d = data.itemdata.SCHOOL_WEAPON 
	for i = 1, #d do
		if d[i].school == self.school then
			table.insert(weaponType, d[i].weapon)
		end
	end
	return weaponType
end

function CAttrCtrl.UpdateDay(self)
	self:OnEvent(define.Attr.Event.UpdateDay)
end

function CAttrCtrl.LoginInit(self)
	--第一次进入组队初始化设置
	g_TeamCtrl:InitTeamSetting()
end

--是否有属性变化
function CAttrCtrl.HasAttrChange(self, oAttr, nAttr)
	if not next(oAttr) or not next(nAttr) then
		return false
	end

	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(oAttr) do
			if _v == k then
				return true
			end				
		end
	end
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(nAttr) do
			if _v == k then
				return true
			end				
		end
	end
	return false
end

--获取战斗指令
--~table.print(g_AttrCtrl.bcmd)
function CAttrCtrl.GetBattleCmd(self, bAlly)
	local lCommand = {}
	local bcmd = g_AttrCtrl.bcmd
	table.sort(bcmd, function (a, b)
		return a.idx < b.idx
	end)
	for i,v in ipairs(bcmd) do
		if bAlly then
			if math.floor(v.idx / 100) == 1 then --我方
				table.insert(lCommand, v)
			end
		else
			if math.floor(v.idx / 100) == 2 then --敌方
				table.insert(lCommand, v)
			end
		end
	end
	return lCommand
end

function CAttrCtrl.IsBanChat(self)
	return g_AttrCtrl.chatself
end

function CAttrCtrl.UpdateGameShare(self, lGameShare)
	local dict = {gameshare = 0}
	for _, dGameShare in ipairs(lGameShare) do
		if dGameShare.value == 1 then
			dict["gameshare"] = 1
			break
		end
	end
	self:UpdateAttr(dict)
end

function CAttrCtrl.IsHasGameShare(self)
	return self.gameshare == 1
end

function CAttrCtrl.SetSkinList(self, shapes)
	local lExcept = {110,120,130,140,150,160} --原模型的不用红点
	local redDot = {}
	self.m_SkinList = shapes
	for i,v in ipairs(self.m_SkinList) do
		local key = "roleskin".."_"..v
		local roleData = IOTools.GetRoleData(key)
		if not roleData and v ~= self.model_info.shape and not table.index(lExcept, v) then
			table.insert(redDot, v)
		end
	end
	if #redDot > 0 then
		self:SetSkinRedDot(redDot)
	end
end

function CAttrCtrl.SetSkinRedDot(self, redDot)
	self.m_SkinRedDot = redDot
	self:OnEvent(define.Attr.Event.UpdateSkin)
end

function CAttrCtrl.GetSkinRedDot(self)
	return self.m_SkinRedDot
end

function CAttrCtrl.GetSkinList(self)
	return self.m_SkinList
end

function CAttrCtrl.GetMyShape(self)
	local shape = self.model_info.shape
	local d = data.roletypedata.DATA
	for i, v in ipairs(d) do
		if v.school == self.school and v.sex == self.sex	then
			shape = v.shape
		end
	end
	return shape
end

function CAttrCtrl.GetHeroOneSkillId(self)
	local modeId = 0
	local skillId = 0
	if self.model_info.shape == 110 or self.model_info.shape == 120 then
		if g_AttrCtrl.school_branch == 2 then 
			modeId = 31
		else
			modeId = 30
		end		
	elseif self.model_info.shape == 130 or self.model_info.shape == 140 then
		if self.school_branch == 2 then 
			modeId = 33
		else
			modeId = 32
		end
	elseif self.model_info.shape == 150 or self.model_info.shape == 160 then
		if self.school_branch == 2 then 
			modeId = 35
		else
			modeId = 34
		end
	end
	if modeId ~= 0 then
		skillId = tonumber(string.format("%d0%d", modeId, 1))
	end
	return skillId
end

function CAttrCtrl.GetMaxEnergy(self)
	local max_energy = data.globaldata.GLOBAL.max_energy.value
	if g_WelfareCtrl:HasYueKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].yk
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].zsk
	end
	return max_energy
end

function CAttrCtrl.GetServerGradeData(self, grade)
	grade = grade or self.grade
	local iGrade = grade - self.server_grade
	local oData
	for k,v in pairs(data.servergradedata.ExpLimit) do
		if iGrade >= v.grade.min and iGrade <= v.grade.max then
			oData = v
			break
		end
	end
	if g_AttrCtrl.server_grade < tonumber(data.globaldata.GLOBAL.open_expadd_grade.value) and oData.id == 1 then
		oData = data.servergradedata.ExpLimit[2]
	end
	return oData
end

function CAttrCtrl.GetServerGradeWarDesc(self, grade)
	local oData = self:GetServerGradeData(grade)
	if g_AttrCtrl.grade <= tonumber(data.globaldata.GLOBAL.ignore_expadd_grade.value) then
		return ""
	elseif grade >= tonumber(data.globaldata.GLOBAL.player_gradelimit.value) then
		return "[ff0000]已达到人物最大等级"
	else
		return oData.war_desc
	end
end

function CAttrCtrl.GetPlayerInfo(self, pid, style, bTips)
	bTips = bTips or true
	local time = g_TimeCtrl:GetTimeS()
	if self.m_GetPlayerInfoTime == nil or time - self.m_GetPlayerInfoTime > 1 then
		self.m_GetPlayerInfoTime = time
		netplayer.C2GSGetPlayerInfo(pid, style)
	else
		if bTips then
			g_NotifyCtrl:FloatMsg("操作频繁，请稍后再试")
		end
	end
end

return CAttrCtrl