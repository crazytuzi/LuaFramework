-- 军徽的数据接口
require "luascript/script/game/gamemodel/emblem/emblemTroopVoApi"
emblemVoApi={
	init = nil,
	rtime = nil,
	lastGetTs = {},--上一次获取装备的时间
	getTimes = {},--已获取装备的次数集合{2,3}--其中2是钻石当天的获取次数  3是稀土当天的获取次数
	-- 当前玩家拥有的军徽table，里面都是vo
	equipList={},
	-- 存储当前已经选择的装备id，index=1：白装，index=2：绿装，以此类推
	tempList={},
	guideFlag=nil,--是否已经执行过新手引导
	guideTs = nil,--引导判断时间戳

	tmpEquip = nil, -- 临时存储equip

	battleEquipList = {}, -- 所有已出征的装备
	expeditionDeadEquip = {}, -- 远征军已死亡的装备，不可再用

	attackEquip = nil, -- 出征界面当前选中的装备
	storyEquip = nil, -- 关卡
	defenseEquip = nil, -- 基地防守
	arenaEquip = nil, -- 军事演习
	-- expeditionEquip = nil, -- 远征军
	allianceEquip = nil, -- 旧版军团战
	allianceWar2Equip = nil, --新军团战英雄
	allianceWar2CurEquip = nil, --新军团战当前英雄
	localWarEquip = nil, -- 区域战预设
	localWarCurEquip = nil, -- 区域战当前
	bossbattleEquip = nil,-- 世界boss
	serverWarPersonalEquip = {}, -- 个人跨服战
	serverWarTeamEquip = nil, -- 军团跨服战预设军徽
	serverWarTeamCurEquip = nil, -- 军团跨服战当前军徽
	dimensionalWarEquip = nil, -- 异元战场
	worldWarEquip = {}, -- 世界争霸
	swAttackEquip = nil, -- 超级武器攻击
    swDefenceEquip = nil, -- 超级武器防守
    serverWarLocalEquip = {},  --群雄争霸预设军徽
    serverWarLocalCurEquip = {},  --群雄争霸当前军徽
    platWarEquip = {}, --平台战军徽一
    permitLevel = nil, -- 军徽开放等级，后端传，后端不传取配置
    newYearBossEquip = nil, --除夕活动攻击年兽boss军徽
    championshipWarPersonalCurEquip=nil, --军团锦标赛个人战军徽或军徽部队
    championshipWarCurEquip=nil, --军团锦标赛军团战军徽或军徽部队
}

-- 清理
function emblemVoApi:clear()
	base:removeFromNeedRefresh(self)
	self.battleEquipList = {}
	self.expeditionDeadEquip = {}

	self.tmpEquip = nil

	self.attackEquip = nil
	self.storyEquip = nil
	self.defenseEquip = nil
	self.arenaEquip = nil
	-- self.expeditionEquip = nil
	self.allianceEquip = nil
	self.allianceWar2Equip = nil
	self.allianceWar2CurEquip = nil --新军团战当前英雄
	self.localWarEquip = nil
	self.localWarCurEquip = nil
	self.bossbattleEquip = nil
	self.serverWarPersonalEquip = {}
	self.serverWarTeamEquip = nil
	self.serverWarTeamCurEquip = nil
	self.dimensionalWarEquip = nil
	self.worldWarEquip = {}
	self.swAttackEquip = nil
    self.swDefenceEquip = nil
    self.serverWarLocalEquip = {}
    self.serverWarLocalCurEquip = {}
    self.platWarEquip = {}
    self.newYearBossEquip = nil

	self.init = nil
	self.rtime = nil
	self.lastGetTs={}
	self.getTimes={}
	self.guideFlag = nil
	self.guideTs = nil
	self.equipList = {}
	self.tempList = {}

	self.permitLevel = nil 
	self.championshipWarPersonalCurEquip=nil
    self.championshipWarCurEquip=nil
end

function emblemVoApi:tick()
	if emblemVoApi:getRefreshTime()==base.serverTime then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
		end
		socketHelper:refreshGemsMail(onRequestEnd)
	end
end

-- 初始化数据
function emblemVoApi:initData(seData)
	-- 只有第一次才执行
	if self.init==nil then
		require "luascript/script/game/gamemodel/emblem/emblemVo"
		require "luascript/script/config/gameconfig/emblemListCfg"
		require "luascript/script/config/gameconfig/emblemCfg"
		local flag=false
		for k,v in pairs(base.allNeedRefreshDialogs) do
			if(v==self)then
				flag=true
				break
			end
		end
		if(flag==false)then
			base:addNeedRefresh(self)
		end
	end
	self.init=true	
	if seData then
		if seData.sequip then
			self.equipList = {}
			for k,v in pairs(seData.sequip) do
				local cfg = self:getEquipCfgById(k)
				local vo = emblemVo:new(cfg)
				vo:initWithData(k,v[1])
				table.insert(self.equipList,vo)
			end
			local function sortFunc(a,b)
				if(a.cfg.color==b.cfg.color)then
					if(a.cfg.lv==b.cfg.lv)then
						return a.cfg.qiangdu>b.cfg.qiangdu
					else
						return a.cfg.lv>b.cfg.lv
					end
				else
					return a.cfg.color>b.cfg.color
				end
			end
			table.sort(self.equipList,sortFunc)
		end
		
		if seData.info then
			if seData.info.gold then
				self.lastGetTs[1] = seData.info.gold[1]
				self.getTimes[1] = seData.info.gold[2]
			end
			if seData.info.r5 then
				self.lastGetTs[2] = seData.info.r5[1]
				self.getTimes[2] = seData.info.r5[2]
			end
			if seData.info.gems then
				self:setRefreshTime(G_getWeeTs(base.serverTime+86400))
			end
			if seData.info.olvl then
				self.permitLevel = tonumber(seData.info.olvl)
			end
			print("初始化装备获取数据：",self.getTimes[1],self.getTimes[2],self.lastGetTs[1],self.lastGetTs[2])
		end
		if seData.stats then
			self:syncStats(seData.stats)
		end
		if seData.smaster then --军徽部队数据
			emblemTroopVoApi:updateTroopData(seData.smaster)
		end
		if seData.xtimes then --军徽部队训练数据
	        emblemTroopVoApi:updateWashData(seData.xtimes)			
		end
		if seData.sshop then --军徽部队购买和洗练道具购买数据
			emblemTroopVoApi:updateShopData(seData.sshop)
		end
	end
end

--~~~~~~~~~~~~~~~~~~~~~~~~下面是装备抽取的代码~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--获取装备获取数量的配置
function emblemVoApi:getEquipNumCfg()
	require "luascript/script/config/gameconfig/emblemCfg"
	return emblemCfg.equipGetNumCfg
end
--获取装备需要消耗的钻石或稀土(getType 获取消耗方式 1 钻石  2 稀土；index 第几个连抽)
function emblemVoApi:getEquipCost(getType,index)
	local num=self:getEquipNumCfg()[getType][index]
	if(self.getTimes==nil)then
		self.getTimes={}
	end 
	if self.lastGetTs and self.lastGetTs[getType] and self.lastGetTs[getType] > 0 and G_getWeeTs(base.serverTime) > G_getWeeTs(self.lastGetTs[getType]) then
		self.getTimes[getType] = 0--当前的领取次数重置
	end
	local cfg
	if getType == 1 then
		cfg = emblemCfg.goldCost --钻石的抽取消耗
	elseif getType == 2 then
		cfg = emblemCfg.r5cost --稀土的抽取消耗
	end
	local maxTimesCfg = SizeOfTable(cfg)
	local times=self.getTimes[getType] or 0
	if(getType==1 and index==2 and times==0)then
		times=1
	end
	local cost = 0
	local addCost= 0
	for i=1,num do
		if (times+i) > maxTimesCfg then
			addCost = cfg[maxTimesCfg]
		else
			addCost = cfg[times+i]
		end	
		cost = cost + addCost
	end
	return cost
end

function emblemVoApi:checkIfHadFreeCost()
	if self:getEquipCost(1,1) == 0 or self:getEquipCost(2,1) == 0 then
		return true
	end
	return false
end

--设置上一次抽取军徽的数据，包括抽取的时间戳和已抽取次数（用于军徽是否显示免费抽奖提示的功能）
function emblemVoApi:setLastGetData(seData)
	if seData and seData.info then
		if seData.info.gold then
			self.lastGetTs[1]=seData.info.gold[1]
			self.getTimes[1]=seData.info.gold[2]
		end
		if seData.info.r5 then
			self.lastGetTs[2]=seData.info.r5[1]
			self.getTimes[2]=seData.info.r5[2]
		end
	end
end

--获取装备后刷新对应的数据(getType 获取消耗方式 1 钻石  2 稀土；index 第几个连抽)
function emblemVoApi:afterGetEquip(getData,getType,index)
	local num = self:getEquipNumCfg()[getType][index]
	if getData ~= nil and (getType == 1 or getType == 2) and num > 0 then
		self.lastGetTs[getType] = base.serverTime
		if(self.getTimes[getType])then
			self.getTimes[getType] = self.getTimes[getType] + num
		else
			self.getTimes[getType]=num
		end
		local refreshTb={}
		for k,v in pairs(getData) do
			if v.type == "se" then
				local eVo
				for km,vm in pairs(self.equipList) do
					if vm and vm.id == v.key then
						vm:addNum(v.num)--添加数量
						eVo=vm
					end
				end
				local equipCfg = self:getEquipCfgById(v.key)
				if eVo==nil then					
					eVo=emblemVo:new(equipCfg)
					eVo:initWithData(v.key,v.num,0)
					table.insert(self.equipList,eVo)
				end
				table.insert(refreshTb,eVo)
				if(eVo and eVo.cfg.color>=4)then
					-- local paramTab={}
					-- paramTab.functionStr="emblem"
					-- paramTab.addStr="i_also_want"
					-- local emblemName=emblemVoApi:getEquipName(eVo.id)
					-- local message={key="emblem_get_chat",param={playerVoApi:getPlayerName(),emblemName}}
					-- chatVoApi:sendSystemMessage(message,paramTab)
					-- local params = {key="emblem_get_chat",param={{playerVoApi:getPlayerName(),1},{emblemName,3}}}
					-- chatVoApi:sendUpdateMessage(41,params)
				end
			end
		end
		local function sortFunc(a,b)
			if(a.cfg.color==b.cfg.color)then
				if(a.cfg.lv==b.cfg.lv)then
					return a.cfg.qiangdu>b.cfg.qiangdu
				else
					return a.cfg.lv>b.cfg.lv
				end
			else
				return a.cfg.color>b.cfg.color
			end
		end
		table.sort(self.equipList,sortFunc)
		eventDispatcher:dispatchEvent("emblem.data.refresh",refreshTb)
	end
end

--~~~~~~~~~~~~~~~~~~~~~~~~下面是装备分类获取的代码~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--通过技能id 获取技能配置
function emblemVoApi:getEquipSkillCfgById(kId)
	return emblemListCfg.skillCfg[kId]
end

--通过技能id 获取技能配置
function emblemVoApi:getEquipSkillValueByLv(kId,kLv)
	return emblemListCfg.skillCfg[kId]["value"..kLv]
end

function emblemVoApi:getEquipSkillNameById(kId,kLv)
	local cfg = self:getEquipSkillCfgById(kId)
	return getlocal("emblem_skillName_s"..cfg.stype)..G_LV()..kLv
end

function emblemVoApi:getEquipSkillDesById(kId,kLv,useRich)
	local valueTb = {}
	local skillCfg = emblemListCfg.skillCfg[kId]
	if skillCfg then
		if skillCfg.stype == 3 or skillCfg.stype == 4 then
			local skillTb=skillCfg["value"..kLv]
			if skillTb and skillTb[1] and skillTb[2] then
				local skillId,skillLv=skillTb[1],skillTb[2]
				if abilityCfg and abilityCfg[skillId] and abilityCfg[skillId][skillLv] then
					local ablitySkillCfg=abilityCfg[skillId][skillLv]
					if skillCfg.stype == 3 then
						valueTb={ablitySkillCfg.value1*100,ablitySkillCfg.turn}
					elseif skillCfg.stype == 4 then
						valueTb={ablitySkillCfg.value1*100}
					end 
				end
			end
		elseif skillCfg.stype == 5 then
			local skillTb=skillCfg["value"..kLv]
			if skillTb and skillTb[1] and skillTb[2] then
				local skillId,skillLv=skillTb[1],skillTb[2]
				if abilityCfg and abilityCfg[skillId] and abilityCfg[skillId][skillLv] then
					local ablitySkillCfg=abilityCfg[skillId][skillLv]
					valueTb = {ablitySkillCfg.value1*100,ablitySkillCfg.value2*100,ablitySkillCfg.value3*100}
				end
			end
		elseif skillCfg.stype == 305 or skillCfg.stype == 2 then
			valueTb = skillCfg["value"..kLv]
		else
			for k,v in pairs(skillCfg["value"..kLv]) do
				valueTb[k]=v * 100
			end
		end
	end
	local desc=""
	if self:isEmblem_e104UseNewSkill()==true and skillCfg.stype==4 then
		desc = getlocal("emblem_skillDes_new_s"..skillCfg.stype,valueTb)
	else
		desc = getlocal("emblem_skillDes_s"..skillCfg.stype,valueTb)
	end
	if useRich==true then
	else
		desc=string.gsub(desc,"<rayimg>","")
	end
	return desc
end

--eId 配件id
function emblemVoApi:getEquipCfgById(eId)
	local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(eId)
	if isTroop==true then
		if data then
			eId=data[1]
		else
			local troopVo=emblemTroopVoApi:getEmblemTroopData(eId)
			eId=troopVo.type
		end
	end
	local cfg = emblemListCfg.equipListCfg[eId]
	if cfg then
		cfg.id = eId
	end
	return cfg
end

--展示用的装备属性列表，按照一定的顺序显示
function emblemVoApi:getEquipAttUpForShow(attupCfg)
	local showAtt = {}
	if attupCfg.troopsAdd and tonumber(attupCfg.troopsAdd)>0 then
		table.insert(showAtt,{"troopsAdd",attupCfg.troopsAdd})
	end
	if attupCfg.first and tonumber(attupCfg.first)>0 then
		table.insert(showAtt,{"first",attupCfg.first})
	end
	if attupCfg.dmg and tonumber(attupCfg.dmg)>0 then
		table.insert(showAtt,{"dmg",attupCfg.dmg})
	end

	if attupCfg.hp and tonumber(attupCfg.hp)>0 then
		table.insert(showAtt,{"hp",attupCfg.hp})
	end
	
	if attupCfg.accuracy and tonumber(attupCfg.accuracy)>0 then
		table.insert(showAtt,{"accuracy",attupCfg.accuracy})
	end
	if attupCfg.evade and tonumber(attupCfg.evade)>0 then
		table.insert(showAtt,{"evade",attupCfg.evade})
	end
	
	if attupCfg.crit and tonumber(attupCfg.crit)>0 then
		table.insert(showAtt,{"crit",attupCfg.crit})
	end

	if attupCfg.anticrit and tonumber(attupCfg.anticrit)>0 then
		table.insert(showAtt,{"anticrit",attupCfg.anticrit})
	end
	if attupCfg.arp and tonumber(attupCfg.arp)>0 then
		table.insert(showAtt,{"arp",attupCfg.arp})
	end
	if attupCfg.armor and tonumber(attupCfg.armor)>0 then
		table.insert(showAtt,{"armor",attupCfg.armor})
	end
	return showAtt
end

-- 获取当前拥有的所有军徽
function emblemVoApi:getEquipList()
	return self.equipList
end

function emblemVoApi:getEquipListForBattle(bType)
	local equipList={}
	if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
		local troopList=emblemTroopVoApi:getEmblemTroopList()
	    if troopList then
	        for k,v in pairs(troopList) do
	            if v and self:checkEquipCanUse(bType,v.id)==true then
	                table.insert(equipList,G_clone(v))
	            end
	        end
        	local function sortFunc(a,b)
		        if a and b then
		            local as=a:getTroopStrength() or 0
		            local bs=b:getTroopStrength() or 0
		            return as>bs
		        end
		    end
		    table.sort(equipList,sortFunc)
	    end
	end
	for k,v in pairs(self.equipList) do
        table.insert(equipList,G_clone(v))		
	end
	return equipList
end

--装备的总个数（军徽数量）
function emblemVoApi:getEquipTotalNum()
	if(self.equipList)then
		return #(self.equipList)
	else
		return 0
	end
end

--是否有军徽或军徽部队(派兵出战时用)
function emblemVoApi:checkIfHadEquip()
	local permitLevel=self:getPermitLevel()
    if base.emblemSwitch==1 and playerVoApi:getPlayerLevel()>=permitLevel then
        if self.equipList then
      		if self:getEquipTotalNum()>0 then
      			return true
      		end
        end
        if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
        	local troopList=emblemTroopVoApi:getEmblemTroopList()
            if troopList and SizeOfTable(troopList)>0 then
                return true
            end
        end
    end
    return false
end

--根据color（1白装 2绿装 3蓝色 4紫色 5橙色）装备类型获取相应的装备集合
function emblemVoApi:getEquipListByColor(color)
	local tb={}
	for k,v in pairs(self.equipList) do
		if(v.cfg.color==color)then
			table.insert(tb,v)
		end
	end
	return tb
end

function emblemVoApi:clearTempEquip(color)
	self.tempList[color] = {}
end

-- 选择一件装备后，添加id到已选择列表内（装备进阶）
function emblemVoApi:addTempEquip(color,id)
	if SizeOfTable(self.tempList[color])<6 then
		table.insert(self.tempList[color],id)
	end
end

-- 取消选择一件装备后，从已选择列表内移除id（装备进阶）
function emblemVoApi:deleteTempEquip(color,id)
	for k,v in pairs(self.tempList[color]) do
		if v==id then
			table.remove(self.tempList[color],k)
			do return end
		end
	end
end

-- 获取军徽的临时表 里面存储的是id
function emblemVoApi:getTempList(color)
	return self.tempList[color]
end

-- 整理军徽列表，格式为 elist={ "e1"=2, "e2"=10, } (用于进阶)
function emblemVoApi:formatEquipList(tb)
	local elist = {}
	for k,v in pairs(tb) do
		if elist[v]==nil then
			elist[v] = 1
		else
			elist[v] = elist[v] + 1
		end
	end
	return elist
end

-- 获取color品级临时表里的元素个数
function emblemVoApi:getSelectNum(color)
	return SizeOfTable(self.tempList[color])
end

-- 获取当前可选择的装备列表
function emblemVoApi:getTempSelectList(color)
	local retTb = G_clone(self.equipList[color])
	local temp = self:getTempList(color)
	local equipCfg
	-- 有已经被选择的装备，需要移除
	if self:getSelectNum(color)>0 then
		for k,v in pairs(retTb) do
			equipCfg = self:getEquipCfgById(v.id)
			if equipCfg.lv<1 then
				for i,j in pairs(temp) do
					if j==v.id then
						retTb[k].num = retTb[k].num - 1
					end
				end
			else
				retTb[k].num = 0
			end
		end
	else
		for k,v in pairs(retTb) do
			equipCfg = self:getEquipCfgById(v.id)
			if equipCfg.lv>0 then
				retTb[k].num = 0
			end
		end
	end
	return retTb
end

-- 自动选择6件装备的的算法，根据数量及技能提取
function emblemVoApi:autoSelectEquip(color)
	
	local selectNum = self:getSelectNum(color) -- 已经选择装备的数量
	local haveEquip -- 当前可选择的装备
	if selectNum>0 then
		haveEquip = self:getTempSelectList(color) -- 移除掉已经选择的装备的所有装备
	else
		haveEquip = G_clone(self.equipList[color]) -- 当前品阶可选择的所有装备
	end
	local haveNum = SizeOfTable(haveEquip) -- 当前可选择的装备种数
	local retTb = {} -- 已经选择的装备id存储在这个table
	local sum = 6 - selectNum -- 需要选择的总数
	if sum==0 then
		return retTb
	end
	local equipCfg -- 配置
	local canUseNum = 0 -- 符合要求的装备种数（等级为0的）
	local oneEquipNum = 0 -- 符合要求的数量不足2（<=1）的装备种数
	for k,v in pairs(haveEquip) do
		equipCfg = self:getEquipCfgById(v.id)
		if v.num>1 and equipCfg.lv==0 then
			for i=1,v.num-1 do
				table.insert(retTb,v.id)
				haveEquip[k].num = haveEquip[k].num - 1
				sum = sum - 1
				if sum==0 then
					return retTb
				end
			end
			canUseNum = canUseNum + 1
			if haveEquip[k].num<=1 then
				oneEquipNum = oneEquipNum + 1
			end
		end
	end
	-- 如果符合要求的装备各自的数量都不足2,都是1或0了,没办法了,只能杀鸡取卵了
	if oneEquipNum<=canUseNum then
		for k,v in pairs(haveEquip) do
			equipCfg = self:getEquipCfgById(v.id)
			if v.num>0 and equipCfg.lv==0 then
				table.insert(retTb,v.id)
				haveEquip[k].num = haveEquip[k].num - 1
				sum = sum - 1
				if sum==0 then
					return retTb
				end
			end
		end
	end
	return retTb
end

-- 一键进阶
function emblemVoApi:getOneKeyEquip(color)
	local haveEquip = G_clone(self.equipList[color]) -- 当前品阶可选择的所有装备
	local haveNum = 0 -- 当前可选择的装备数
	local equipCfg
	for k,v in pairs(haveEquip) do
		equipCfg = self:getEquipCfgById(v.id)
		if equipCfg.lv==0 then
			haveNum = haveNum + v.num
		end
	end
	local findNum = haveNum - (haveNum%6) -- 需要找到多少装备
	local retTb = {} -- 已经选择的装备id存储在这个table
	if findNum<6 then
		return retTb
	end
	local sum = 0 -- 需要选择的总数
	for k,v in pairs(haveEquip) do
		equipCfg = self:getEquipCfgById(v.id)
		if equipCfg.lv==0 then
			for i=1,v.num do
				table.insert(retTb,v.id)
				haveEquip[k].num = haveEquip[k].num - 1
				sum = sum + 1
				if sum==findNum then
					return retTb
				end
			end
		end
	end
	return retTb
end

-- 获取装备名字
function emblemVoApi:getEquipName(id)
	local nameStr=""
	if id~=nil then
		local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(id)
		if isTroop==true then
			if data then
				id=data[1]
			else
				local troopVo=emblemTroopVoApi:getEmblemTroopData(id)
				if troopVo then
					id=troopVo.type
				end
			end
			nameStr=getlocal("emblem_name_"..id)
		else
			local iconID = id
			local equipCfg = self:getEquipCfgById(id)
			if equipCfg and equipCfg.lv>0 then
				local start = string.find(iconID,"_")
				if start and start>1 then
					iconID = string.sub(id,1,start-1)
					print("iconID",iconID,start)
				end
			end
			-- 装备名称
			nameStr = getlocal("emblem_name_"..iconID)
			if equipCfg and equipCfg.lv and equipCfg.lv>0 then
				nameStr = nameStr.."+"..equipCfg.lv
			end
		end
	end
	return nameStr
end

--获取装备对应的Vo
function emblemVoApi:getEquipVoByID(eId)
	local list = self:getEquipList()
	for k,v in pairs(list) do
		if v and v.id == eId then
			return v
		end
	end
	return nil
end

--获取装备对应的等级最大的Vo
function emblemVoApi:getEquipVoMaxLvByIdAndColor(eId,color)
	local eCfg = self:getEquipCfgById(eId)
	if color == nil then
		color = eCfg.color
	end
	local list = self:getEquipListByColor(color)
	if eCfg.etype == 1 then--武器有等级，取等级最大的
		local selectVo
		local selectLv = 0
		
		local firstEid = eId
		local start = string.find(eId,"_")
		if start and start>1 then
			firstEid = string.sub(firstEid,1,start-1)
		end
		
		local tEid,tStart
		for k,v in pairs(list) do
			tEid = v.id
			tStart = string.find(tEid,"_")
			if tStart and tStart>1 then
				tEid = string.sub(tEid,1,tStart-1)
			end
			if v and tEid == firstEid then
				local cfg = self:getEquipCfgById(v.id)
				if selectVo == nil or cfg.lv > selectLv then
					selectVo = v
					selectLv = cfg.lv
				end
			end
		end
		return selectVo
	else--装置没有等级
		for k,v in pairs(list) do
			if v and v.id == eId then
				return v
			end
		end
	end
	return nil
end

-- 获取装备icon
-- id：装备id
-- callback：回调方法
-- bgTag:背景的tag
-- num 装备的数量（nil 不显示数量）
-- strong 装备的强度（nil 不显示强度）
function emblemVoApi:getEquipIcon(id,callback,bgTag,num,strong,color,iconBgName,emTroopVo)
	-- 装备配置
	-- print("getEquipIcon: ", id)
	local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(id)
	if isTroop==true then
		local iconBg=emblemTroopVoApi:getTroopIconById(id,callback,nil,nil,emTroopVo)
		if bgTag and iconBg then
			iconBg:setTag(bgTag)
		end
		do return iconBg end
	end
	local addPosX = 130
	local addPosX2 = 10
	local nameFontSize = 17
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        addPosX =0
        addPosX2 = 0
        nameFontSize = 20
    end
	local equipCfg = self:getEquipCfgById(id)
	local function clickCallBack(object,fn,tag)
		if callback ~= nil then
		   callback(tag)
		end
	end
	local bgName
	if equipCfg then
		bgName = "emblemBg"..equipCfg.color..".png"
	else
		bgName = "emblemBg1.png"
	end
	if iconBgName then
		bgName = iconBgName
	end
	local iconBg = LuaCCSprite:createWithSpriteFrameName(bgName,clickCallBack) --LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",CCRect(50, 50, 10, 10),clickCallBack)
	-- iconBg:setContentSize(CCSizeMake(150,150))
	iconBg:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2))
	if bgTag then
		iconBg:setTag(bgTag)
	end

	-- id是真实id，iconID是等级为0时的id，用于查找icon和name，因为升级之后icon和name不改变
	local iconID = id
	if equipCfg and equipCfg.lv>0 then
		local start = string.find(iconID,"_")
		if start and start>1 then
			iconID = string.sub(iconID,1,start-1)
		end
	end
	local iconName = iconID==nil and "emblemUnknown.png" or "emblemIcon_"..iconID..".png"
	-- 装备的icon
	local icon = CCSprite:create("public/emblem/icon/"..iconName)
	if icon == nil then
		icon =  CCSprite:createWithSpriteFrameName("emblemUnknown.png")
	end
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+20))
	icon:setTag(10901)
	iconBg:addChild(icon)
	-- 装备数量
	if num then
		local ownStr = getlocal("emblem_infoOwn",{num})
		local ownLb = GetTTFLabel(ownStr,nameFontSize)
		ownLb:setAnchorPoint(ccp(0,1))
		ownLb:setPosition(ccp(10, iconBg:getContentSize().height - 5))
		ownLb:setTag(10902)
		iconBg:addChild(ownLb)
	end

	-- 装备强度
	local strongLb
	if strong then
		strongLb = GetTTFLabel(getlocal("alliance_boss_degree",{strong}),nameFontSize)
		strongLb:setAnchorPoint(ccp(0.5,0))
		strongLb:setPosition(ccp(iconBg:getContentSize().width/2, 10))
		strongLb:setTag(10903)
		iconBg:addChild(strongLb)
		-- strongLb:setColor(G_ColorRed)
	end
	
	-- 装备名称
	local nameStr = "??????"
	if equipCfg and equipCfg.lv then
		----todo 勿删  等图片出来以后使用
		nameStr = getlocal("emblem_name_"..iconID)
		if equipCfg.lv>0 then
			nameStr = nameStr.."+"..equipCfg.lv
		end
	end
	-- 装备名称
	local equipNameLb = GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
	local equipNameY
	if strongLb then
		equipNameY = 15 + strongLb:getContentSize().height + equipNameLb:getContentSize().height/2
	else
		equipNameY = 10 + equipNameLb:getContentSize().height/2
	end
	equipNameLb:setAnchorPoint(ccp(0.5,0.5))
	equipNameLb:setPosition(ccp(iconBg:getContentSize().width/2,equipNameY))
	equipNameLb:setTag(10904)
	iconBg:addChild(equipNameLb,2)
	
	local typeIcon
	if equipCfg and equipCfg.etype then
		typeIcon = CCSprite:createWithSpriteFrameName("emblemType"..equipCfg.etype..".png")
	else
		typeIcon = CCSprite:createWithSpriteFrameName("emblemType1.png")  
		typeIcon:setVisible(false)  
	end
	typeIcon:setAnchorPoint(ccp(0,0.5))
	typeIcon:setPosition(ccp(5, 80+addPosX2))
	iconBg:addChild(typeIcon)
	typeIcon:setTag(5)
	-- 装备品阶星级
	local colorNum = color
	if equipCfg then
		colorNum = equipCfg.color
	end
	if colorNum and colorNum>0 then
		-- 变色
		if colorNum == 1 then
			typeIcon:setColor(ccc3(212,212,212))
		elseif colorNum==2 then
			typeIcon:setColor(ccc3(54,242,112))
			equipNameLb:setColor(G_ColorGreen)
		elseif colorNum==3 then
			typeIcon:setColor(ccc3(69,187,255))
			equipNameLb:setColor(G_ColorBlue)
		elseif colorNum==4 then
			typeIcon:setColor(ccc3(255,138,229))
			equipNameLb:setColor(G_ColorPurple)
		elseif colorNum==5 then
			typeIcon:setColor(ccc3(255,187,69))
			equipNameLb:setColor(G_ColorOrange)
		end
		local px = iconBg:getContentSize().width
		if addPosX >0 then
			px =0
		end
		local py = 75
		for i=1,colorNum do
			local starSize = 20 -- 星星大小
			local starSpace = 20 
			local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
			starSp:setScale(starSize/starSp:getContentSize().width)
			-- px= px - starSize
			if addPosX >0 then
				px = px + starSize
			else
				px =px -starSize
			end
			-- local px = iconBg:getContentSize().width/2-starSpace/2*(colorNum-1)+starSpace*(i-1) -- 
			-- local py = 5 + equipNameY + starSize/2 + equipNameLb:getContentSize().height/2
			starSp:setPosition(ccp(px,py+addPosX))
			starSp:setTag(10990+i)
			iconBg:addChild(starSp)
		end
	end 
	return iconBg
end

-- 获取装备icon
-- id：装备id
--jiange:星星坐标
function emblemVoApi:getEquipIconNoBg(id, nameFontSize,starY,callback,nameY,emTroopVo)
	if starY == nil then
		starY = 10
	end
	if nameY == nil then
		nameY = starY - 10
	end
	local nameFontSizeOutSide
	if(nameFontSize)then
		nameFontSizeOutSide = nameFontSize-1
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
	        nameFontSizeOutSide =nameFontSize
	    end
	end
	-- 装备配置
	local equipCfg = self:getEquipCfgById(id)
	local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(id)
	if isTroop==true then
		local iconBg=emblemTroopVoApi:getTroopIconById(id,callback,false,nil,emTroopVo)
		do return iconBg end
	end
	
	-- id是真实id，iconID是等级为0时的id，用于查找icon和name，因为升级之后icon和name不改变
	local iconID = id
	if equipCfg and equipCfg.lv>0 then
		local start = string.find(iconID,"_")
		if start and start>1 then
			iconID = string.sub(id,1,start-1)
		end
	end
	local iconName = "emblemIcon_"..iconID..".png"
	local icon
	local function clickCallBack(object,fn,tag)
		if callback ~= nil then
		   callback(tag)
		end
	end
	-- 装备的icon
	icon = LuaCCSprite:createWithFileName("public/emblem/icon/"..iconName,clickCallBack)
	if icon == nil then
		icon =  LuaCCSprite:createWithFileName("public/emblem/icon/emblemIcon_e2.png",clickCallBack)
	end

	-- 装备名称
	local nameStr = getlocal("emblem_name_"..iconID)
	if equipCfg and equipCfg.lv and equipCfg.lv>0 then
		nameStr = nameStr.."+"..equipCfg.lv
	end
	-- 装备名称
	local equipNameLb
	if(nameFontSizeOutSide)then
		equipNameLb = GetTTFLabelWrap(nameStr,nameFontSizeOutSide,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
		equipNameLb:setAnchorPoint(ccp(0.5,1))
		equipNameLb:setPosition(ccp(icon:getContentSize().width/2,nameY))
		equipNameLb:setTag(1)
		icon:addChild(equipNameLb)
	end
	
	-- 装备品阶星级
	local colorNum = color
	if equipCfg then
		colorNum = equipCfg.color
	end
	if colorNum and colorNum>0 then
		-- 变色
		if(equipNameLb)then
			if colorNum==2 then
				equipNameLb:setColor(G_ColorGreen)
			elseif colorNum==3 then
				equipNameLb:setColor(G_ColorBlue)
			elseif colorNum==4 then
				equipNameLb:setColor(G_ColorPurple)
			elseif colorNum==5 then
				equipNameLb:setColor(G_ColorOrange)
			end
		end
		local px = icon:getContentSize().width
		for i=1,colorNum do
			local starSize = 20 -- 星星大小
			local starSpace = 20 
			local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
			starSp:setScale(starSize/starSp:getContentSize().width)
			px = icon:getContentSize().width/2-starSpace/2*(colorNum-1)+starSpace*(i-1)		  
			starSp:setPosition(ccp(px,starY))
			starSp:setTag(10+i)
			icon:addChild(starSp)
		end
	end 
	return icon
end

function emblemVoApi:getEquipIconNull()
	local iconBg = CCSprite:createWithSpriteFrameName("emblemBg1.png")
	local nullIcon = CCSprite:createWithSpriteFrameName("emblemUnknown.png")
	nullIcon:setAnchorPoint(ccp(0.5,0.5))
	nullIcon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+20))
	iconBg:addChild(nullIcon)
	return iconBg
end

function emblemVoApi:showMainDialog(layerNum,callBack,operatType,troopId)
	require "luascript/script/game/scene/gamedialog/emblem/emblemDialog"
	local td=emblemDialog:new(callBack,operatType,troopId)
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("emblem_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
-- 批量分解的面板
function emblemVoApi:showBulkSaleDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/emblem/emblemBulkSaleDialog"
	local smallDialog=emblemBulkSaleDialog:new()
	smallDialog:init(layerNum)
	return smallDialog
end

function emblemVoApi:showInfoDialog(emblemVo,layerNum,desVisible,doType,operatCallBack,parent)
	require "luascript/script/game/scene/gamedialog/emblem/emblemInfoDialog"
	local smallDialog=emblemInfoDialog:new(emblemVo)
	smallDialog:init(layerNum,desVisible,doType,operatCallBack,parent)
end

function emblemVoApi:showGetDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/emblem/emblemGetDialog"
	local td=emblemGetDialog:new()
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("emblem_btn_get"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function emblemVoApi:showAdvanceDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/emblem/emblemAdvanceDialog"
	local td = emblemAdvanceDialog:new(self.selectedTabIndex)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("emblem_btn_advance"),false,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function emblemVoApi:showSellRewardDialog(eVoTb,layerNum,callback,bulkFlag)
	require "luascript/script/game/scene/gamedialog/emblem/emblemSellRewardSmallDialog"
	local sd=emblemSellRewardSmallDialog:new(eVoTb,callback,bulkFlag)
	sd:init(layerNum)
end

-- dtype：35 领土争夺战新加
function emblemVoApi:showSelectEmblemDialog(quality,dialogType,layerNum,callback,usedList,dtype,cid)
	require "luascript/script/game/scene/gamedialog/emblem/emblemSelectDialog"
	local sd=emblemSelectDialog:new(quality,dialogType,usedList,callback,dtype,cid)
	sd:init(layerNum)
end

function emblemVoApi:showUpgradeDialog(eVo,layerNum)
	require "luascript/script/game/scene/gamedialog/emblem/emblemUpgradeDialog"
	local td = emblemUpgradeDialog:new(eVo)
	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("emblem_infoBtn1"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~获取属性加成~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--获得该装备提升的属性加成值
--param eId: 装备id
--return {100,100,2000,2000}
function emblemVoApi:getTankAttAdd(eId)
	local result={0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	return result
end

--skillType技能类型（1 提升科技研发速度 2提升部队生产速度 3 提高部队改造速度 4提高建筑建造速度 5 6增加仓库容量和仓库保护量）
--useDirectly 是否可以直接使用skillType
--return 属性值
function emblemVoApi:getSkillValue(skillType,useDirectly)
	local valueType
	if useDirectly == true then
		valueType = skillType
	else
		valueType = skillType + 300
	end
	local value = 0
	local eid
	local equipCfg,skillCfg
	for k,v in pairs(self.equipList) do
		if v and v.id then
			equipCfg = self:getEquipCfgById(v.id)
			if equipCfg.skill then
				skillCfg = self:getEquipSkillCfgById(equipCfg.skill[1])
				if skillCfg and valueType == skillCfg.stype then
					local skillValueTb = skillCfg["value"..equipCfg.skill[2]]
					local skillValue = skillValueTb[1]
					if skillValue > value then
						value = skillValue
						eid=v.id
					end
				end
			end
		end
	end
	return value,eid
end

-- 通过eid获取到分解所得配置
function emblemVoApi:getEquipDecomposeByIdAndNum(eId,num)
	-- 装备分解配置
	local dCfg = G_clone(emblemListCfg.equipListCfg[eId]["deCompose"])
	local awardCfg={}
	-- 多件数量计算
	for k,v in pairs(dCfg) do
		dCfg[k] = dCfg[k]*num
		local pType = string.sub(k,1,1)
		if(awardCfg[pType]==nil)then
			awardCfg[pType]={}
		end
		awardCfg[pType][k]=dCfg[k]
	end
	local award=FormatItem(awardCfg)
	return award
end

-- 批量分解获得道具
function emblemVoApi:getEquipDecomposeByElist(emblemTb)
	-- 分解获得的所有道具
	local totalProp = {}
	-- 循环分解装备
	for k,eVo in pairs(emblemTb) do
		local usableNum=eVo:getUsableNum()
		if(usableNum>0)then
			local sellCfg=eVo.cfg.deCompose
			for pid,pNum in pairs(sellCfg) do
				local pType = string.sub(pid,1,1)
				if(totalProp[pType]==nil)then
					totalProp[pType]={}
				end
				if(totalProp[pType][pid]==nil)then
					totalProp[pType][pid]=pNum*usableNum
				else
					totalProp[pType][pid]=totalProp[pType][pid] + pNum*usableNum
				end
			end
		end
	end
	totalProp=FormatItem(totalProp,false,true)
	return totalProp
end

-- 获取强度最大的装备id
function emblemVoApi:getMaxStrongEquip(bType)
	local maxStrongEquipId = nil
	local cfg1
	local cfg2
	local maxStrong=0
	for k,v in pairs(self.equipList) do
		cfg1 = v.cfg
		-- 判断是否有剩余装备
		if cfg1.etype==1 and self:checkEquipCanUse(bType,v.id)==true then
			if maxStrongEquipId==nil then
				maxStrongEquipId = v.id
				maxStrong=cfg1.qiangdu
			else
				cfg2 = self:getEquipCfgById(maxStrongEquipId)
				if cfg1.qiangdu>cfg2.qiangdu then
					maxStrongEquipId = v.id
					maxStrong=cfg1.qiangdu
				end
			end
		end
	end
    if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
    	local troopList=emblemTroopVoApi:getEmblemTroopList()
        for k,v in pairs(troopList) do
            if v and self:checkEquipCanUse(bType,v.id)==true then--未出征
                local tStrong=emblemTroopVoApi:getTroopStrengthById(v.id)
                if maxStrongEquipId==nil then
                    maxStrongEquipId=v.id
                    maxStrong=tStrong
                else
                    if tStrong>maxStrong then
                        maxStrongEquipId=v.id
                        maxStrong=tStrong
                    end
                end
            end
        end
    end
	return maxStrongEquipId
end

-- 通过装备id获取带兵量增加数量
function emblemVoApi:getTroopsAddById(equipId,emTroopVo)
	local troopsAdd = 0
	local color = 1
	if base.emblemSwitch==1 then
		local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
		if isTroop==true then
			if data then
				troopsAdd=emblemTroopVoApi:getTroopAttUpByJointId(equipId,"troopsAdd")
			else
				local troopVo=emTroopVo or emblemTroopVoApi:getEmblemTroopData(equipId)
				if troopVo then
					troopsAdd=troopVo:getAttValueByType("troopsAdd")
				end
			end
		else
			local equipCfg = self:getEquipCfgById(equipId)
			if equipCfg and equipCfg.attUp and equipCfg.attUp.troopsAdd then
				troopsAdd = equipCfg.attUp.troopsAdd
				color = equipCfg.color
			end
		end
	end
	return troopsAdd,color
end

-- 设置临时的军徽
function emblemVoApi:setTmpEquip(equipId,bType)
	if base.emblemSwitch==0 then
		do return end
	end
	if equipId and equipId==0 then
		equipId = nil
	end
	if bType==18 or bType==31 then
		do return end
	end
	if bType==nil then
		self.tmpEquip = equipId
	else
		if bType==7 or bType==8 or bType==9 or bType==13 or bType==14 or bType==15 or bType==21 or bType==22 or bType==23 or bType==24 or bType==25 or bType==26 or bType==27 or bType==28 or bType==29 then
			local isEmblemTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
			if isEmblemTroop==true and equipArr==nil then
				equipId=emblemVoApi:getEquipIdStr(equipId)
			end
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		-- elseif bType==13 or bType==14 or bType==15 then
		-- 	local isEmblemTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
		-- 	if isEmblemTroop==true and equipArr==nil then
		-- 		equipId=emblemVoApi:getEquipIdStr(equipId)
		-- 	end
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		-- elseif bType==21 or bType==22 or bType==23 then
		-- 	local isEmblemTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
		-- 	if isEmblemTroop==true and equipArr==nil then
		-- 		equipId=emblemVoApi:getEquipIdStr(equipId)
		-- 	end
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		-- elseif bType==24 or bType==25 or bType==26 then
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		-- elseif bType==27 or bType==28 or bType==29 then
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		-- elseif bType==35 or bType==36 then -- 领土争夺战
		-- 	local isEmblemTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
		-- 	if isEmblemTroop==true and equipArr==nil then
		-- 		equipId=emblemVoApi:getEquipIdStr(equipId)
		-- 	end
		-- 	if self.tmpEquip==nil or type(self.tmpEquip)=="string" then -- (目前先点击本地的保存部队，在点击现在的部队报错)
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		else
			self.tmpEquip = equipId
		end
	end 
end

-- 获取临时的军徽
function emblemVoApi:getTmpEquip(bType)
	if base.emblemSwitch~=1 then
		do return nil end
	end
	if bType==nil then
		return self.tmpEquip
	else
		if bType==7 or bType==8 or bType==9 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			return self.tmpEquip[bType]
		elseif bType==13 or bType==14 or bType==15 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			return self.tmpEquip[bType]
		elseif bType==21 or bType==22 or bType==23 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			return self.tmpEquip[bType]
		elseif bType==24 or bType==25 or bType==26 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			return self.tmpEquip[bType]
		elseif bType==27 or bType==28 or bType==29 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			return self.tmpEquip[bType]
		elseif bType==18 or bType==31 then
			return self:getBattleEquip(bType)
		-- elseif bType==35 or bType==36 then
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	return self.tmpEquip[bType]
		else
			return self.tmpEquip
		end
	end
end

-- 设置战斗的军徽
-- bType：战斗类型
-- equipId：装备id
function emblemVoApi:setBattleEquip(bType,equipId)
	if base.emblemSwitch==0 then
		do return end
	end
	if equipId==0 then
		equipId = nil
	end
	if bType==1 then
		self.defenseEquip = equipId
	elseif bType==2 then
		self.attackEquip = equipId
	elseif bType==3 then
		self.storyEquip = equipId
	elseif bType==4 then
		self.allianceWarEquip = equipId
	elseif bType==5 then
		self.arenaEquip = equipId
	elseif bType==7 then
		self.serverWarPersonalEquip[bType] = equipId
	elseif bType==8 then
		self.serverWarPersonalEquip[bType] = equipId
	elseif bType==9 then
		self.serverWarPersonalEquip[bType] = equipId
	elseif bType==10 then
		self.serverWarTeamEquip = equipId
	-- elseif bType==11 then
	--	 self.expeditionEquip = equipId
	elseif bType==12 then
		self.bossbattleEquip = equipId
	elseif bType==13 then
		self.worldWarEquip[bType] = equipId
	elseif bType==14 then
		self.worldWarEquip[bType] = equipId
	elseif bType==15 then
		self.worldWarEquip[bType] = equipId
	elseif bType==17 then
		self.localWarEquip = equipId
	elseif bType==18 then
		self.localWarCurEquip = equipId
	elseif bType==19 then
		self.swAttackEquip = equipId
	elseif bType==20 then
		self.swDefenceEquip = equipId
	elseif bType==21 or bType==22 or bType==23 then
		self.platWarEquip[bType] = equipId
	elseif bType==24 or bType==25 or bType==26 then
		self.serverWarLocalEquip[bType] = equipId
	elseif bType==27 or bType==28 or bType==29 then
		self.serverWarLocalCurEquip[bType] = equipId
	elseif bType==30 then
		self.newYearBossEquip = equipId
	elseif bType==31 then
		self.allianceWar2CurEquip = equipId	
	elseif bType==32 then
		self.allianceWar2Equip = equipId
	elseif bType==33 then
		self.dimensionalWarEquip = equipId
	elseif bType==34 then
		self.serverWarTeamCurEquip = equipId
	elseif bType==38 then --军团锦标赛个人战军徽或军徽部队
		self.championshipWarPersonalCurEquip=equipId
	elseif bType==39 then --军团锦标赛军团战军徽或军徽部队
		self.championshipWarCurEquip=equipId
	end
end

-- 获取战斗的军徽
-- bType：战斗类型
function emblemVoApi:getBattleEquip(bType,cid)
	if base.emblemSwitch~=1 then
		return nil
	end
	local equipId
	-- 是否需要检查已派出，镜像不需要
	local flag = false
	if bType==1 then
		equipId = self.defenseEquip
		flag = true
	elseif bType==2 then
		equipId = self.attackEquip
		flag = true
	elseif bType==3 then
		equipId = self.storyEquip
		flag = true
	elseif bType==4 then
		equipId = self.allianceWarEquip
	elseif bType==5 then
		equipId = self.arenaEquip
	elseif bType==7 then
		equipId = self.serverWarPersonalEquip[bType]
	elseif bType==8 then
		equipId = self.serverWarPersonalEquip[bType]
	elseif bType==9 then
		equipId = self.serverWarPersonalEquip[bType]
	elseif bType==10 or bType==34 then
		equipId = self.serverWarTeamEquip
	elseif bType==11 then
		equipId = self.expeditionEquip
	elseif bType==12 then
		equipId = self.bossbattleEquip
	elseif bType==13 then
		equipId = self.worldWarEquip[bType]
	elseif bType==14 then
		equipId = self.worldWarEquip[bType]
	elseif bType==15 then
		equipId = self.worldWarEquip[bType]
	elseif bType==17 then
		equipId = self.localWarEquip
	elseif bType==18 then
		equipId = self.localWarCurEquip
	elseif bType==19 then
		equipId = self.swAttackEquip
	elseif bType==20 then
		equipId = self.swDefenceEquip
	elseif bType==21 or bType==22 or bType==23 then
		equipId = self.platWarEquip[bType]
	elseif bType==24 or bType==25 or bType==26 then
		equipId = self.serverWarLocalEquip[bType]
	elseif bType==27 or bType==28 or bType==29 then
		equipId = self.serverWarLocalCurEquip[bType]
	elseif bType==30 then
		equipId = self.newYearBossEquip
	elseif bType==31 then
		equipId = self.allianceWar2CurEquip
	elseif bType==32 then
		equipId = self.allianceWar2Equip
	elseif bType==33 then
		equipId = self.dimensionalWarEquip
	elseif bType==34 then
		equipId = self.serverWarTeamCurEquip
	elseif bType==35 or bType==36 then -- 领土争夺战
		equipId = ltzdzFightApi:getDefenceEmblem(bType,cid)
	elseif bType==38 then --军团锦标赛个人战军徽或军徽部队
		equipId=self.championshipWarPersonalCurEquip
	elseif bType==39 then --军团锦标赛军团战军徽或军徽部队
		equipId=self.championshipWarCurEquip
	end
	-- 需要检查
	if flag==true then
		if equipId and self:checkEquipCanUse(bType,equipId)==true then
			return equipId
		else
			do return nil end
		end
	else
		return equipId
	end
end

-- 通过id获取已出征的数量
function emblemVoApi:getBattleNumById(equipId)
	if self.battleEquipList==nil then
		return 0
	else
		return (self.battleEquipList[equipId] or 0)
	end
end

-- 往出征队列中加equip
function emblemVoApi:addBattleEquipNum(equipId)
	if self.battleEquipList==nil then
		self.battleEquipList = {}
	end
	if self.battleEquipList[equipId]==nil then
		self.battleEquipList[equipId] = 1
	else
		self.battleEquipList[equipId] = self.battleEquipList[equipId] + 1
	end
end

-- 清空出征队列
function emblemVoApi:clearBattleEquipList()
	self.battleEquipList = nil
end

-- 清空不可重复使用的军徽
function emblemVoApi:clearEquipCanNotUse(bType)
	if bType==11 then
		self.expeditionDeadEquip = {}
	else
		do return end
	end
end

--根据传入的id，来获取已经上阵的军徽列表
function emblemVoApi:getEquipUsedByEquipId(equipId)
	local equipIdTb={}
	if equipId then
		local equipArr=Split(equipId,"-")
		if equipArr and SizeOfTable(equipArr)>1 then --如果是军徽部队的话，需要看部队中装配的军徽
			local troopId=equipArr[12]
			table.insert(equipIdTb,troopId)
			local troopList=emblemTroopVoApi:getEmblemTroopList()
       		local ownTroopVo=troopList[troopId] --镜像对应的玩家身上军徽部队当前数据（不是镜像）
    		local hasEmblemTb={}
    		if ownTroopVo and ownTroopVo.posTb then --记录当前军徽部队携带军徽
    			for kidx,posEquipId in pairs(ownTroopVo.posTb) do
    				if posEquipId and posEquipId~="0" then
						table.insert(equipIdTb,posEquipId)
        				hasEmblemTb[posEquipId]=(hasEmblemTb[posEquipId] or 0)+1
					end
    			end
    		end
			for j=1,3 do
				local posEquipId=equipArr[j+1]
				if posEquipId and posEquipId~="0" and hasEmblemTb[posEquipId]==nil then --玩家当前军徽部队上没有该军徽，但对应镜像上有则记录，否则不记录
					table.insert(equipIdTb,posEquipId)
				end
			end
		else
			table.insert(equipIdTb,equipId)
		end
	end
	return equipIdTb
end

-- 获取不可重复使用的军徽
function emblemVoApi:getEquipCanNotUse(bType)
	if bType==11 then
		return self.expeditionDeadEquip
	elseif bType==7 or bType==8 or bType==9 then
		local retTb = G_clone(self.serverWarPersonalEquip)
		retTb[bType] = nil 
		-- local retTb={}
		-- for i=7,9 do
		-- 	if i~=bType then
  --               local equipId=self.serverWarPersonalEquip[i]
  --               local equipIdTb=self:getEquipUsedByEquipId(equipId)
  --               for k,v in pairs(equipIdTb) do
  --               	table.insert(retTb,v)
  --               end
		-- 	end
		-- end
		return retTb
	elseif bType==13 or bType==14 or bType==15 then
		local retTb = G_clone(self.worldWarEquip)
		retTb[bType] = nil 
		-- local retTb={}
		-- for i=13,15 do
		-- 	if i~=bType then
  --               local equipId=self.worldWarEquip[i]
  --               local equipIdTb=self:getEquipUsedByEquipId(equipId)
  --               for k,v in pairs(equipIdTb) do
  --               	table.insert(retTb,v)
  --               end
		-- 	end
		-- end
		return retTb
	elseif bType==21 or bType==22 or bType==23 then
		local retTb = G_clone(self.platWarEquip)
		retTb[bType] = nil 
		-- local retTb={}
		-- for i=21,23 do
		-- 	if i~=bType then
  --               local equipId=self.platWarEquip[i]
  --               local equipIdTb=self:getEquipUsedByEquipId(equipId)
  --               for k,v in pairs(equipIdTb) do
  --               	table.insert(retTb,v)
  --               end
		-- 	end
		-- end
		return retTb
	elseif bType==24 or bType==25 or bType==26 then
		local retTb = G_clone(self.serverWarLocalEquip)
		retTb[bType] = nil 
		-- local retTb={}
		-- for i=24,26 do
		-- 	if i~=bType then
  --               local equipId=self.serverWarLocalEquip[i]
  --               local equipIdTb=self:getEquipUsedByEquipId(equipId)
  --               for k,v in pairs(equipIdTb) do
  --               	table.insert(retTb,v)
  --               end
		-- 	end
		-- end
		return retTb
	elseif bType==35 or bType==36 then -- 领土争夺战
		return nil
	else
		do return end
	end
end

-- 设置不可重复使用的军徽
function emblemVoApi:setEquipCanNotUse(bType,equipId,num)
    if bType==11 then
        -- table.insert(self.expeditionDeadEquip,equipId)
        self.expeditionDeadEquip[equipId] = num
    else
        do return end
    end
end


-- 判断此id的装备数量是否还有剩余的可以上阵
-- bType:战斗类型
-- equipId:装备id
function emblemVoApi:checkEquipCanUse(bType,equipId)
    if emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)==true and emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
        local troopVo=emblemTroopVoApi:getEmblemTroopData(equipId)
        if troopVo and troopVo:checkIfBattled()==false then
            -- 不可用的装备
        	local equipNumTb={}    
            local noEquipId=self:getEquipCanNotUse(bType)
			local troopList=G_clone(emblemTroopVoApi:getEmblemTroopList())	--当前玩家军徽部队列表
            -- 只有多个的时候才会涉及重复问题
            if noEquipId and type(noEquipId)=="table" then
                for k,v in pairs(noEquipId) do
                    if bType==11 then
                        if k==equipId then
                            return false
                        end
                    else
        	           	local isTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(v)
                    	if isTroop==true and equipArr and SizeOfTable(equipArr)>1 then --如果是军徽部队镜像的话，把部队中装配的军徽记录
                    		local troopId=equipArr[12]
                    		if troopId==equipId then
                    			return false
                    		end
                    		local ownTroopVo=troopList[troopId] --镜像对应的玩家身上军徽部队当前数据（不是镜像）
                    		local hasEmblemTb={}
                    		if ownTroopVo and ownTroopVo.posTb then --当前军徽部队携带军徽记录
                    			for kidx,posEquipId in pairs(ownTroopVo.posTb) do
                    				if posEquipId and posEquipId~="0" then
	                    				equipNumTb[posEquipId]=(equipNumTb[posEquipId] or 0)+1
	                    				hasEmblemTb[posEquipId]=(hasEmblemTb[posEquipId] or 0)+1
									end
                    			end
                    		end
                    		for j=1,3 do
                				local posEquipId=equipArr[j+1]
								if posEquipId and posEquipId~="0" and hasEmblemTb[posEquipId]==nil then --如果玩家当前军徽部队上没有该军徽并且对应镜像上有该军徽则记录，否则不记录（避免重复记录）
                    				equipNumTb[posEquipId]=(equipNumTb[posEquipId] or 0)+1
								end
                    		end
                    	elseif isTroop==false then --如果是军徽的话直接加1
        					equipNumTb[v]=(equipNumTb[v] or 0)+1
                    	end
                    end
                end
            end
            local equipVo
            for k,v in pairs(troopVo.posTb) do
				equipVo=self:getEquipVoByID(v)
            	if equipVo then --如果该部队上装配了该军徽，那需要判断该军徽当前的个数是否满足可出战的情况
					local equipedNum=equipVo:getEquipBattleNum() --已经派出去的该军徽个数
					if equipVo.num<=(equipedNum+(equipNumTb[v] or 0)) then --如果个数不够则携带该军徽的军徽部队不可参与布阵
						return false
					end
            	end
            end
            return true,1
        end
        return false
    end
   	local equipCfg=self:getEquipCfgById(equipId)
    if equipCfg==nil then
        return false
    end
	local equipVo=self:getEquipVoByID(equipId)
	if equipVo==nil then
		return false
	end
	-- 不可用的装备
	local noEquipId=self:getEquipCanNotUse(bType)
	-- 不可用的装备数量
	local noEquipNum=equipVo:getEquipBattleNum()
	-- 只有多个的时候才会涉及重复问题
	local troopList={}
	if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then
		troopList=G_clone(emblemTroopVoApi:getEmblemTroopList())	--当前玩家军徽部队列表
	end
	if noEquipId and type(noEquipId)=="table" then
		if bType==11 then
			for k,v in pairs(noEquipId) do
				if k==equipId then
					noEquipNum=noEquipNum+v
				end
			end
		else
			for k,v in pairs(noEquipId) do
				if v==equipId then --equipId 不是军徽部队
					noEquipNum=noEquipNum+1
				else
					local isTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(v)
					if isTroop==true and equipArr and SizeOfTable(equipArr)>1 then --如果v是军徽部队的话，需要把该军徽部队装配的该军徽个数记录
                		local troopId=equipArr[12]	
		          		local ownTroopVo=troopList[troopId] --镜像对应的玩家身上军徽部队当前数据（不是镜像）
                		local hasEmblemTb={}
                		if ownTroopVo and ownTroopVo.posTb then --当前军徽部队携带军徽记录
                			for kidx,posEquipId in pairs(ownTroopVo.posTb) do
                				if posEquipId and posEquipId~="0" and posEquipId==equipId then
                    				noEquipNum=noEquipNum+1
                    				hasEmblemTb[posEquipId]=(hasEmblemTb[posEquipId] or 0)+1
								end
                			end
                		end
						for j=1,3 do
							local posEquipId=equipArr[j+1]
							if posEquipId and posEquipId==equipId and hasEmblemTb[posEquipId]==nil then --如果玩家当前军徽部队上没有该军徽并且对应镜像上有该军徽则记录，否则不记录（避免重复记录）
								noEquipNum=noEquipNum+1
								do break end
							end
						end
						troopList[troopId]=nil --将已经处理的军徽部队剔除
					end
				end
			end
		end
	end
	for k,v in pairs(troopList) do --遍历除镜像以外的军徽部队携带军徽的情况
		for kidx,posEquipId in pairs(v.posTb) do
			if posEquipId==equipId then --将除镜像以外的军徽部队装配的军徽也记录上
				noEquipNum=noEquipNum+1
				do break end
			end
		end
	end
	if equipVo.num>noEquipNum then
		return true,(equipVo.num-noEquipNum)
	else
		return false
	end
end

-- 设置刷新钻石邮件的时间戳
function emblemVoApi:setRefreshTime(time)
	self.rtime = time
end

-- 获取刷新钻石邮件的时间戳
function emblemVoApi:getRefreshTime()
	return self.rtime
end

-- 获取军徽开放等级
function emblemVoApi:getPermitLevel()
	if self.permitLevel==nil then
		if emblemCfg and emblemCfg.equipOpenLevel then
			self.permitLevel = emblemCfg.equipOpenLevel
		end
	end
	return self.permitLevel
end

--抽军徽
--type 获取消耗稀土还是钻石   num 是抽1次 还是5次
function emblemVoApi:addEmblem(type,num,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.reward then
				local award = FormatItem(sData.data.reward)
				for k,v in pairs(award) do
					if v.type ~= "se" then
						G_addPlayerAward(v.type,v.key,v.id,v.num)
					end
				end
				local numIndex
				for k,v in pairs(emblemVoApi:getEquipNumCfg()[type]) do
					if(num==v)then
						numIndex=k
						break
					end
				end
				local cost=emblemVoApi:getEquipCost(type,numIndex) -- 获取当前使用钻石/稀土抽取1次/多次的消耗
				if type== 1 then
					playerVoApi:setGems(playerVoApi:getGems() - cost)
				elseif type== 2 then
				    playerVoApi:setGold(playerVoApi:getGold() - cost)
				end
				emblemVoApi:afterGetEquip(award,type,numIndex)--刷新数据
				if(callback)then
					callback(award)
				end
			end
		end
	end
	socketHelper:emblemAdd(type,num,onRequestEnd)
end

function emblemVoApi:sell(emblemID,qualityTb,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local award = FormatItem(sData.data.reward) or {}
			for k,v in pairs(award) do
				if v.type~="se" then
					G_addPlayerAward(v.type,v.key,v.id,v.num)
				end
			end
			G_showRewardTip(award,true)
			-- 刷新装备列表
			eventDispatcher:dispatchEvent("emblem.data.refresh",nil)
			if(callback)then
				callback()
			end
		end
	end
	if(emblemID)then
		socketHelper:emblemDecompose(emblemID,onRequestEnd)
	elseif(qualityTb)then
		socketHelper:emblemBulkSale(qualityTb,onRequestEnd)
	elseif(callback)then
		callback()
	end
end

function emblemVoApi:compose(emblemList,useGold,callback,need,specialCostTb)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local color
			for id,num in pairs(emblemList) do
				color=emblemVoApi:getEquipCfgById(id).color
				break
			end
			local needProp=emblemCfg.equipAdvance.prop[color]
			needProp=FormatItem(needProp)[1]
			local propID = (tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
			local propNum = bagVoApi:getItemNumId(propID)
			local totalNum=0
			for id,num in pairs(emblemList) do
				totalNum=totalNum + num
			end
			local composeNum=math.floor(totalNum/6)
			if(useGold > 0)then
				playerVoApi:setGems(playerVoApi:getGems() - useGold)
			end
			bagVoApi:useItemNumId(propID,math.min(propNum,composeNum))
			if specialCostTb and type(specialCostTb)=="table" then
				for k,v in pairs(specialCostTb) do
					print("v.id,v.num === >",v.id,v.num)
					bagVoApi:useItemNumId(v.id, v.num)
				end
			end
			local award = FormatItem(sData.data.reward)
			eventDispatcher:dispatchEvent("emblem.data.refresh",nil)
			if(callback)then
				callback(award)
			end
		end
 	end
	socketHelper:emblemAdvance(emblemList,(useGold>0) and true or false,onRequestEnd,need)
end

function emblemVoApi:upgrade(emblemVo,useGold,callback)
	local costGold = 0
	if(useGold)then
		local upCostReward=FormatItem({p=emblemVo.cfg.upCost})
		for k,v in pairs(upCostReward) do
			local havePropNum = bagVoApi:getItemNumId(v.id)
			if havePropNum<v.num then
				costGold = costGold + (v.num - havePropNum)*propCfg[v.key].gemCost
			end
		end
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if costGold > 0 then
				playerVoApi:setGems(playerVoApi:getGems() - costGold)
			end
			eventDispatcher:dispatchEvent("emblem.data.refresh",nil)
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:emblemLevelUp(emblemVo.id,useGold,onRequestEnd)
end

function emblemVoApi:checkEmblemCanSet(bType,selectedTabIndex,layerNum,clearCallback)
	--检测第几个军徽不能设置
    local list=self:getEquipList()
    local cannotSetIndex={}
    local hasSetTb={}
    local fType
    if bType==7 or bType==8 or bType==9 then
    	fType=6
	elseif bType==13 or bType==14 or bType==15 then
		fType=12
	elseif bType==21 or bType==22 or bType==23 then
		fType=20
	elseif bType==24 or bType==25 or bType==26 then
		fType=23
	end
	if fType then
	    for i=1,3 do
	    	local tType=fType+i
	        local emblemID1=self:getBattleEquip(tType)
	        if selectedTabIndex==i then
	            emblemID1=self:getTmpEquip(tType)
	        end
	        if emblemID1 then
	            local isCanSet=false
	            for k,v in pairs(list) do
	                if v and v.id==emblemID1 then
	                    if hasSetTb and hasSetTb[v.id] then
	                        hasSetTb[v.id]=hasSetTb[v.id]+1
	                        if v.num>0 and v.num>=hasSetTb[v.id] then
	                            isCanSet=true
	                        end
	                    else
	                        hasSetTb[v.id]=1
	                        if v.num>0 then
	                            isCanSet=true
	                        end
	                    end
	                end
	            end
	            if isCanSet==false then
	                -- cannotSetIndex=i
	                table.insert(cannotSetIndex,i)
	                -- break
	            end
	        end
	    end
	    -- print("cannotSetIndex",cannotSetIndex)
	    if cannotSetIndex and SizeOfTable(cannotSetIndex)>0 then
	    -- if cannotSetIndex~=0 then
	        local function confirmCallBackHandler()
	            -- if G_checkClickEnable()==false then
	            --     do
	            --         return
	            --     end
	            -- else
	            --     base.setWaitTime=G_getCurDeviceMillTime()
	            -- end
	            -- PlayEffect(audioCfg.mouseClick)

	            -- self:clearAllTroops()
	            if clearCallback then
	            	clearCallback()
	            end
	        end
	        if layerNum then
	        	local str=""
	        	for k,v in pairs(cannotSetIndex) do
	        		if str=="" then
		        		str=getlocal("world_war_sub_title2"..(v+1))
		        	else
		        		str=str..","..getlocal("world_war_sub_title2"..(v+1))
		        	end
	        	end
	        	-- if isCanClear==true then
			        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmCallBackHandler,getlocal("dialog_title_prompt"),getlocal("emblem_serverwar_not_exist",{str}),nil,layerNum)
			    -- else
			    -- 	smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("emblem_serverwar_not_exist",{str}),nil,layerNum)
			    -- end
		    end
	    end
	end
	-- if cannotSetIndex==0 then
	if cannotSetIndex and SizeOfTable(cannotSetIndex)==0 then
		return true
	else
		return false
	end
end

function emblemVoApi:addNumByKey(key,addNum)
	if not self.equipList then
		return
	end

	-- 存在，数量相加
	for k,v in pairs(self.equipList) do
		if v.id==key then
			v.num=(v.num or 0) + addNum
			return
		end
	end

	-- 不存在，插入
	local cfg = self:getEquipCfgById(key)
	local vo = emblemVo:new(cfg)
	vo:initWithData(key,addNum)
	table.insert(self.equipList,vo)

	local function sortFunc(a,b)
		if(a.cfg.color==b.cfg.color)then
			if(a.cfg.lv==b.cfg.lv)then
				return a.cfg.qiangdu>b.cfg.qiangdu
			else
				return a.cfg.lv>b.cfg.lv
			end
		else
			return a.cfg.color>b.cfg.color
		end
	end
	table.sort(self.equipList,sortFunc)

end

--获取品阶的颜色
function emblemVoApi:getEquipColor(id)
	local isTroop=emblemTroopVoApi:checkIfIsEmblemTroopById(id)
	if isTroop==true then
		do return G_ColorWhite end
	end
	local equipCfg=self:getEquipCfgById(id)
	local colorNum,color=equipCfg.color,G_ColorWhite
	if colorNum==2 then
		color=G_ColorGreen
	elseif colorNum==3 then
		color=G_ColorBlue
	elseif colorNum==4 then
		color=G_ColorPurple
	elseif colorNum==5 then
		color=G_ColorOrange
	end
	return color
end

function emblemVoApi:getColorByQuality(colorNum)
	local color=G_ColorWhite
	if colorNum==2 then
		color=G_ColorGreen
	elseif colorNum==3 then
		color=G_ColorBlue
	elseif colorNum==4 then
		color=G_ColorPurple
	elseif colorNum==5 then
		color=G_ColorOrange
	end
	return color
end

function emblemVoApi:isOpen()
	if base.emblemSwitch~=1 then
    	return false
    end
    local permitLevel = self:getPermitLevel()
    if permitLevel and playerVoApi:getPlayerLevel()>=permitLevel then
        return true
    end
    return false
end

--获取免费数据
--[[@return
	{ 
		{ 当前免费次数, 最大免费次数(写死1次) },
	}
--]]
function emblemVoApi:getFreeData()
	local num = 0
	if self:checkIfHadFreeCost()==true then
		num = 1
	end
	return { {num, 1} }
end

--获取水晶购买的数据
--[[@return
	{
		{ 当前可购买次数, 最大购买次数, 所需消耗的水晶数 },
	}
--]]
function emblemVoApi:getR5BuyNum()
	local num = 0
	local maxNum = self:getEquipNumCfg()[2][2]
	if self.lastGetTs and self.lastGetTs[2] and self.lastGetTs[2] > 0 and G_getWeeTs(base.serverTime) > G_getWeeTs(self.lastGetTs[2]) then
		self.getTimes[2] = 0--当前的领取次数重置
	end
	if self.getTimes then
		if type(self.getTimes[2]) == "number" then
			num = num + self.getTimes[2]
		end
	end
	num = maxNum - num
	if num < 0 then
		num = 0
	end
	local r5CostNum, r5CostMinNum = 0, nil
	for i = maxNum - num + 1, maxNum do
		r5CostNum = r5CostNum + emblemCfg.r5cost[i]
		if r5CostMinNum == nil then
			r5CostMinNum = emblemCfg.r5cost[i]
		end
	end 
	return { {num, maxNum, r5CostNum, r5CostMinNum} }
end

--获取水晶购买的消耗数据
--[[@return
	水晶购买的次数, 总共消耗的水晶数
--]]
function emblemVoApi:getR5Cost(num, maxNum)
	local gold = playerVoApi:getGold()
	local r5Cost = 0
	local r5CostNum = 0
	for i = maxNum - num + 1, maxNum do
		if gold >= emblemCfg.r5cost[i] then
			gold = gold - emblemCfg.r5cost[i]
			r5Cost = r5Cost + emblemCfg.r5cost[i]
			r5CostNum = r5CostNum + 1
		end
	end
	return r5CostNum, r5Cost
end

function emblemVoApi:updateLastGetTimes(getType, num)
	self.lastGetTs[getType] = base.serverTime
	if(self.getTimes[getType])then
		self.getTimes[getType] = self.getTimes[getType] + num
	else
		self.getTimes[getType]=num
	end
end

--equipId 装备id或大师id,如果是大师id,会自动转换成大师对应的配置ID
function emblemVoApi:getEmblemPicNameById(equipId,emTroopVo)
	local path="public/emblem/icon/"
    local iconId=equipId
    local isTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
    if isTroop==true then
        if equipArr then
            iconId=equipArr[1]
            local unlockIndex=emblemTroopVoApi:getEmblemTroopPosUnlockNum(equipArr[5])
            if unlockIndex>0 then
                return path.."emblemIcon_"..iconId.."_"..unlockIndex..".png"
            end
            return path.."emblemIcon_"..iconId..".png"
        else
            local troopVo=emTroopVo or emblemTroopVoApi:getEmblemTroopData(equipId)
            if troopVo and troopVo.type then
                iconId=troopVo.type
                local unlockIndex=emblemTroopVoApi:getEmblemTroopPosUnlockNum(troopVo:getMaxWashStrength())
                if unlockIndex>0 then
                    return path.."emblemIcon_"..iconId.."_"..unlockIndex..".png"
                end
                return path.."emblemIcon_"..iconId..".png"
            end
            return "st_emptyshadow.png"
        end
    end
    local equipCfg=self:getEquipCfgById(equipId)
    if equipCfg and equipCfg.lv>0 then
        local start=string.find(iconId,"_")
        if start and start>1 then
            iconId=string.sub(equipId,1,start-1)
        end
    end
    return iconId==nil and "st_emptyshadow.png" or path.."emblemIcon_"..iconId..".png"
end

--获取军徽强度，包括军徽部队的
function emblemVoApi:getEquipStrengthById(id)
	local strength=0
	local isTroop,data=emblemTroopVoApi:checkIfIsEmblemTroopById(id)
	if isTroop==true then --军徽部队
		if data then
			local type,posTb,washStrength,addSavedTb=emblemTroopVoApi:getTroopDataByJointId(id)
			strength=emblemTroopVoApi:getTroopStrengthByTroopData(type,posTb,addSavedTb,washStrength)
		else
			local troopVo=emblemTroopVoApi:getEmblemTroopData(id)
			if troopVo then
				strength=troopVo:getTroopStrength()
			end
		end
	else
    	local emblemCfg=emblemVoApi:getEquipCfgById(id)
  		strength=emblemCfg.qiangdu
	end
	return strength
end

function emblemVoApi:getEquipIdStr(equipId)
	local isTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
    if isTroop==true and equipArr==nil then
        local troopVo=emblemTroopVoApi:getEmblemTroopData(equipId)
        if troopVo then
            local seType=troopVo.type
            local pos1=troopVo.posTb[1] or 0
            local pos2=troopVo.posTb[2] or 0
            local pos3=troopVo.posTb[3] or 0
            local maxWashStrong=troopVo:getMaxWashStrength()
            local hp=troopVo.addSavedTb.hp or 0
            local dmg=troopVo.addSavedTb.dmg or 0
            local accuracy=troopVo.addSavedTb.accuracy or 0
            local evade=troopVo.addSavedTb.evade or 0
            local crit=troopVo.addSavedTb.crit or 0
            local anticrit=troopVo.addSavedTb.anticrit or 0
            local id=troopVo.id

            return seType.."-"..pos1.."-"..pos2.."-"..pos3.."-"..maxWashStrong.."-"..hp.."-"..dmg.."-"..accuracy.."-"..evade.."-"..crit.."-"..anticrit.."-"..id
        end
    end
    return equipId
end

function emblemVoApi:getEquipIdForBattle(equipId)
	local isTroop,equipArr=emblemTroopVoApi:checkIfIsEmblemTroopById(equipId)
    if isTroop==true and equipArr and SizeOfTable(equipArr)>=12 then
        local masterStr=self:getEquipIdStr(equipArr[12])
        if masterStr~=equipId then--如果当前保存时显示的军徽部队状态跟当前实际状态不一致就弹出提示
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_changed"),30)
            return -1
        end
        return equipArr[12]
    end
    return equipId
end

function emblemVoApi:initdefault()
	-- require "luascript/script/config/gameconfig/emblemListCfg"
	-- if self:isEmblem_e104UseNewSkill()==true then --使用优化技能时用新的配置，否则用老的配置
 --        emblemListCfg.skillCfg.s11={stype=4,value1={"az",1},value2={"az",2},value3={"az",3},value4={"az",4}}
 --        emblemListCfg.skillCfg.s12={stype=4,value1={"az",1},value2={"az",2},value3={"az",3},value4={"az",4},value5={"az",6},value6={"az",8}}
	-- else
 --        emblemListCfg.skillCfg.s11={stype=4,value1={"az",4},value2={"az",5},value3={"az",6},value4={"az",7}}
 --        emblemListCfg.skillCfg.s12={stype=4,value1={"az",6},value2={"az",7},value3={"az",8},value4={"az",10},value5={"az",12},value6={"az",14}}
	-- end
end

--爆破军徽是否使用新技能优化（部分平台不开新技能）
function emblemVoApi:isEmblem_e104UseNewSkill()
	return true
end

--同步军徽的出征状态
function emblemVoApi:syncStats(stats)
	if stats and next(stats) then
		-- 基地防守
		if stats.d then
			-- 设置军徽
			self:setBattleEquip(1,stats.d[1])
		end
		-- 出征
		if stats.a then
			self:clearBattleEquipList()
			--添加出征数量
			for k,v in pairs(stats.a) do
				-- 加到出征队列
				self:addBattleEquipNum(v)
			end
		end
		-- 军事演习
		if stats.m then
			-- -- 设置军徽
			self:setBattleEquip(5,stats.m[1])
		end
		-- 超级武器军徽出征
		if stats.w then
			self:setBattleEquip(20,stats.w[1])
		end
	end	
end
