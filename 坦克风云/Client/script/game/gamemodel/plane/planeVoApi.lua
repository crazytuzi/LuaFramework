-- 飞机的数据接口
planeVoApi={
	initFlag = nil,
	rtime = nil,
	lastGetTs = {},--上一次获取装备的时间
	getTimes = {},--已获取装备的次数集合{2,3}--其中2是钻石当天的获取次数  3是稀土当天的获取次数
	-- 当前玩家拥有的飞机table，里面都是vo
	planeList={},
	skillList={},
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
	serverWarTeamEquip = nil, -- 军团跨服战预设飞机
	serverWarTeamCurEquip = nil, -- 军团跨服战当前飞机
	dimensionalWarEquip = nil, -- 异元战场
	worldWarEquip = {}, -- 世界争霸
	swAttackEquip = nil, -- 超级武器攻击
    swDefenceEquip = nil, -- 超级武器防守
    serverWarLocalEquip = {},  --群雄争霸预设飞机
    serverWarLocalCurEquip = {},  --群雄争霸当前飞机
    platWarEquip = {}, --平台战飞机一
    permitLevel = nil, -- 飞机开放等级，后端传，后端不传取配置
    newYearBossEquip = nil, --除夕活动攻击年兽boss飞机
    skillRfreshFlag=false, --是否有新的技能
    nsinfo={},--战机革新新增飞机技能{s1={lv=1,q=0,l=0,t=0,n=0},s2={等级,队列结束时间,使用时等级,使用时间,使用次数},...}
    study={}, --研究值信息{v=0,t=0}{v值,t上次变化时间}
    studyList=nil, --研究队列
	championshipWarPersonalCurPlane=nil, --军团锦标赛个人战飞机
    championshipWarCurPlane=nil, --军团锦标赛军团战飞机
}

-- 清理
function planeVoApi:clear()
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

	self.initFlag = nil
	self.rtime = nil
	self.lastGetTs={}
	self.getTimes={}
	self.guideFlag = nil
	self.guideTs = nil
	self.planeList = {}
	self.tempList = {}
	self.skillList={}
	self.lockList=nil

	self.permitLevel = nil 
	self.skillRfreshFlag=false
	self.nsinfo={}
    self.study={}
    self.studyList=nil
    self.championshipWarPersonalCurPlane=nil
    self.championshipWarCurPlane=nil
    if planeRefitVoApi and planeRefitVoApi.clear then
    	planeRefitVoApi:clear()
    end
    if self.planeRefitListener then
    	planeRefitVoApi:removeEventListener(self.planeRefitListener)
    	self.planeRefitListener = nil
    end
end

function planeVoApi:tick()
	if self.studyList then
		local flag=false --是否有研究队列已完成
		for k, v in pairs(self.studyList) do
			if v and v.q<=base.serverTime then --研究完成
				self.studyList[k]=nil
				--更新 self.nsinfo 数据
				if self.nsinfo and self.nsinfo[k] then
					self.nsinfo[k].q=0
					self.nsinfo[k].lv=(self.nsinfo[k].lv or 0)+1
				end
				flag=true
			end
		end
		if flag==true then
			eventDispatcher:dispatchEvent("plane.newskill.refresh",{})
		end
	end
end

function planeVoApi:getPlaneRequest(getCallback)
    local cmd="plane.plane.get"
    local params={}
    local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self:initData(sData.data)
            if getCallback then
                getCallback()
            end
        end
    end
    local callback=onRequestEnd
    return cmd,params,callback
end

function planeVoApi:planeGet(callback)
	if base.plane==1 then
		local function onGet(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:initData(sData.data)
				if callback then
					callback()
				end
			end
		end
		socketHelper:planeGet(onGet)
	end
end

function planeVoApi:getInitFlag()
	return self.initFlag
end

function planeVoApi:needInitData()
	if base.plane==1 and planeVoApi:getInitFlag()~=true then
		return true
	else
		return false
	end
end

--获取飞机的加成效果
function planeVoApi:getPlaneAddStr(pid)
	local addStr=""
	local cfg=self:getPlaneCfgById(pid)
	local addBuffTb=self:getPlaneAddBuffByPlaneId(pid) --战机革新各个技能加成buff
	if cfg and cfg.attUp then
		if cfg.attUp.critical then --暴击
			addStr=getlocal("alliance_skill_name_13").."+"..((cfg.attUp.critical+(addBuffTb.critical or 0))*100).."%%"
			if addBuffTb.critical then
				addStr=addStr.."("..(cfg.attUp.critical*100).."%%".."<rayimg>+"..(addBuffTb.critical*100).."%%".."<rayimg>)"
			end
		elseif cfg.attUp.accurate then --精准
			addStr=getlocal("alliance_skill_name_11").."+"..((cfg.attUp.accurate+(addBuffTb.accurate or 0))*100).."%%"
			if addBuffTb.accurate then
				addStr=addStr.."("..(cfg.attUp.accurate*100).."%%".."<rayimg>+"..(addBuffTb.accurate*100).."%%".."<rayimg>)"
			end
		elseif cfg.attUp.avoid then --闪避
			addStr=getlocal("alliance_skill_name_12").."+"..((cfg.attUp.avoid+(addBuffTb.avoid or 0))*100).."%%"
			if addBuffTb.avoid then
				addStr=addStr.."("..(cfg.attUp.avoid*100).."%%".."<rayimg>+"..(addBuffTb.avoid*100).."%%".."<rayimg>)"
			end
		elseif cfg.attUp.decritical then --装甲
			addStr=getlocal("emblem_attUp_anticrit").."+"..((cfg.attUp.decritical+(addBuffTb.decritical or 0))*100).."%%"
			if addBuffTb.decritical then
				addStr=addStr.."("..(cfg.attUp.decritical*100).."%%".."<rayimg>+"..(addBuffTb.decritical*100).."%%".."<rayimg>)"
			end
		end
	end
	return addStr
end

--提供给战机改装使用，由于改装时可能会影响战机的相关数据(威力值,技能槽)
function planeVoApi:updatePlaneList(pData)
	if pData and pData.plane and pData.plane.plane then
		self.planeList = {}
		for k,v in pairs(pData.plane.plane) do
			local cfg = self:getPlaneCfgById(k)
			local vo = planeVo:new(cfg)
			vo:initWithData(v,k)
			table.insert(self.planeList,vo)
		end
	end
end

-- 初始化数据
function planeVoApi:initData(pData)
	if pData and pData.plane then
		local planeData=pData.plane
		if planeData and type(planeData)=="table" then
			if planeData.plane then
				self.planeList = {}
				for k,v in pairs(planeData.plane) do
					local cfg = self:getPlaneCfgById(k)
					local vo = planeVo:new(cfg)
					vo:initWithData(v,k)
					table.insert(self.planeList,vo)
				end
			end
			--初始化技能数据
			self:initSkillsInfo(planeData)
			--初始化抽奖数据
			self:initLotterySkill(planeData)
			if planeData.stats then
				self:syncStats(planeData.stats)
			end
			if planeData.nsinfo then
				self.nsinfo=planeData.nsinfo
				self:initStudyList()
			end
			if planeData.study then
				self.study=planeData.study
			end
			if planeRefitVoApi and planeRefitVoApi:isCanEnter() then
				planeRefitVoApi:initData(pData)
			end
		end
	end
	if self.initFlag==nil then
		--初始的时候通知一下主页面刷新技能研究队列
		eventDispatcher:dispatchEvent("plane.newskill.refresh",{})
	end
	self.initFlag=true
	if self.planeRefitListener == nil then
	    self.planeRefitListener = function(eventKey, eventData)
	  		if self and type(eventData) == "table" and type(eventData.sid) == "table" then
	  			local sid = nil
	  			local scfg = planeRefitVoApi:getCfg().refitSkill
	  			local pstypeTb = {} --存放发生变化的技能类型表
	  			for k,v in pairs(eventData.sid) do
	  				sid = "s" .. v
	  				if scfg[sid] then
	  					local stype = scfg[sid].skillType
	  					if pstypeTb[stype] == nil then
	  						self:planeRefitHandler(stype)
	  						pstypeTb[stype] = 1
	  					end
	  				end
	  			end
	  		end
	  	end
  		planeRefitVoApi:addEventListener(self.planeRefitListener)
	end
end

function planeVoApi:initLotterySkill(pData)
	if pData.info then
		if pData.info.gold then
			self.lastGetTs[1] = pData.info.gold[1]
			self.getTimes[1] = pData.info.gold[2]
		end
		if pData.info.r5 then
			self.lastGetTs[2] = pData.info.r5[1]
			self.getTimes[2] = pData.info.r5[2]
		end
		if pData.info.gems then
			self:setRefreshTime(G_getWeeTs(base.serverTime+86400))
		end
		if pData.info.olvl then
			self.permitLevel = tonumber(pData.info.olvl)
		end
		-- print("初始化装备获取数据：",self.getTimes[1],self.getTimes[2],self.lastGetTs[1],self.lastGetTs[2])
	end
end

function planeVoApi:initSkillsInfo(pData)
	if pData.sinfo then
		self.skillRfreshFlag=true
		self.skillList={}
		for sid,num in pairs(pData.sinfo) do
			if tonumber(sid)~=0 then
				self:addSkill(sid,num)
			end
		end
		self:sortSkillList()
	end
end

function planeVoApi:getOpenLevelCfg()
	return planeCfg.openLevel
end

function planeVoApi:getOpenLevel()
	if self.permitLevel==nil then
		self.permitLevel=self:getOpenLevelCfg()[1] or 0
	end
	return self.permitLevel
end

function planeVoApi:getPlaneCfgById(id)
	local cfg=planeCfg.plane[id]
	if cfg==nil then
		id="p"..id
		cfg=planeCfg.plane[id]
	end
	return cfg
end

function planeVoApi:getPlaneVoById(id)
	for k,vo in pairs(self.planeList) do
		if id==vo.pid then
			return vo
		end
	end
	return nil
end

--根据解锁位置获取飞机
function planeVoApi:getPlaneVoByPos(pos)
	if pos and tonumber(pos) then
		for k,vo in pairs(self.planeList) do
			if k==tonumber(pos) then
				return vo
			end
		end
	end
	return nil
end

--获取已经解锁了的飞机
function planeVoApi:getPlaneList()
	return self.planeList
end

--已经解锁飞机的数量
function planeVoApi:getPlaneTotalNum()
	if(self.planeList)then
		return #(self.planeList)
	else
		return 0
	end
end

--获取可以解锁的飞机的数量
function planeVoApi:getUnlockAbleNum()
	local playerLv=playerVoApi:getPlayerLevel()
	local planeList=self:getPlaneList()
	local planeNum=SizeOfTable(planeList)
	local openCfg=self:getOpenLevelCfg()
	local num=0
	for k,level in pairs(openCfg) do
		if playerLv>=level then
			num=num+1
		end
	end
	num=num-planeNum
	if num<0 then
		num=0
	end
	return num
end

--获取可以解锁的飞机
function planeVoApi:getLockPlanes()
	if self.lockList==nil then
		self:checkLockPlanes()
	end
	return self.lockList
end

function planeVoApi:checkLockPlanes()
	self.lockList={}
	for pid,v in pairs(planeCfg.plane) do
		local id=RemoveFirstChar(pid)
		table.insert(self.lockList,{pid=pid,index=id})
	end
	local function sortFunc(a,b)
		if a.index<b.index then
			return true
		end
		return false
	end
	table.sort(self.lockList,sortFunc)
	local planeList=self:getPlaneList()
	for k,vo in pairs(planeList) do
		for kk,v in pairs(self.lockList) do
			if vo.pid==v.pid then
				table.remove(self.lockList,kk)
				do break end
			end
		end
	end
end

function planeVoApi:isPlaneUnlock(pid)
	for k,vo in pairs(self.planeList) do
		if vo.pid==pid then
			return true
		end
	end
	return false
end

--获取当前飞机的强度
function planeVoApi:getPlaneStrengthById(id)
	local cfg=self:getPlaneCfgById(id)
	if cfg then
		return cfg.strength or 0
	end
	return 0
end

function planeVoApi:getPlanePeculiarityById(pid)
	local ridTb={"1","2","4","8"}
	local restrainCfg={r1="tanke",r2="jianjiche",r4="artillery",r8="huojianche"}
	local restrainStr=getlocal("help4_t2")
	local cfg=self:getPlaneCfgById(pid)
	local restrain=cfg.restrain
	local num=0
	local rTb={} --克制的队列
	for k,v in pairs(ridTb) do
		local rid=tonumber(v)
		if tonumber(restrain)==rid then
			rTb={}
			table.insert(rTb,rid)
			do break end
		end
		num=num+rid
		table.insert(rTb,rid)
		if tonumber(restrain)==num then
			do break end
		end
	end
	if G_getCurChoseLanguage() == "ko" then
		for k,rid in pairs(rTb) do
			if k~=1 then
				restrainStr=getlocal(restrainCfg["r"..rid])..","..restrainStr
			else
				restrainStr=getlocal(restrainCfg["r"..rid]).." "..restrainStr
			end
		end
	else
		for k,rid in pairs(rTb) do
			if k~=1 then
				restrainStr=restrainStr..","..getlocal(restrainCfg["r"..rid])
			else
				restrainStr=restrainStr..getlocal(restrainCfg["r"..rid])
			end
		end
	end
	
	return restrainStr
end

function planeVoApi:getPlaneIcon(pid,strong,callback,notShowBg)
	local function clickCallBack(object,fn,tag)
		if callback~=nil then
		   	callback(tag)
		end
	end
	-- 飞机的icon
	local pic="plane_icon_"..pid..".png"
	local icon
	if notShowBg==true then
		icon=LuaCCSprite:createWithSpriteFrameName(pic,clickCallBack)
		do return icon end
	else
		icon=CCSprite:createWithSpriteFrameName(pic)
		local scale=0.5
		-- if pid=="p1" then
		-- 	scale=0.4
		-- end
		icon:setScale(scale)
	end

	local bgName="planeSkillGreenBg.png"
	local iconBg=LuaCCSprite:createWithSpriteFrameName(bgName,clickCallBack)
	iconBg:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2))
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+30))
	iconBg:addChild(icon)
	icon:setTag(10905)
	
	local nameFontSize=18
	-- 装备强度
	local strongLb
	if strong then
		strongLb=GetTTFLabel(getlocal("skill_power",{FormatNumber(strong)}),nameFontSize)
		strongLb:setAnchorPoint(ccp(0.5,0))
		strongLb:setPosition(ccp(iconBg:getContentSize().width/2,25))
		iconBg:addChild(strongLb)
	end

	-- 装备名称
	local nameStr=getlocal("plane_name_"..pid) or ""
	local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
	local equipNameY
	if strongLb then
		equipNameY=25+strongLb:getContentSize().height+nameLb:getContentSize().height/2
	else
		equipNameY=25+nameLb:getContentSize().height/2
	end
	nameLb:setAnchorPoint(ccp(0.5,0.5))
	nameLb:setPosition(ccp(iconBg:getContentSize().width/2,equipNameY))
	nameLb:setTag(10904)
	iconBg:addChild(nameLb,2)

	return iconBg
end

--设置部队面板
function planeVoApi:getPlaneIconNoBg(parent,pid,lbSize,noNameFlag)
	-- 飞机的icon
	local pic="plane_icon_"..pid..".png"
	local icon=CCSprite:createWithSpriteFrameName(pic)
	local bgWidht,bgHeight=parent:getContentSize().width,parent:getContentSize().height
	local scale=bgWidht/icon:getContentSize().width
	icon:setPosition(getCenterPoint(parent))
	icon:setScale(scale)
	icon:setTag(10906)
	
	-- 名称
	if noNameFlag==nil or noNameFlag==false then
		local nameStr=getlocal("plane_name_"..pid) or ""
		local fontSize = lbSize-1
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
	        fontSize =fontSize
	    end
		local nameLb=GetTTFLabelWrap(nameStr,fontSize,CCSizeMake(bgWidht,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0.5,0.5))
		nameLb:setPosition(ccp(bgWidht/2,bgHeight/2-45))
		nameLb:setTag(10905)
		parent:addChild(nameLb,2)
	end
	-- nameLb:setColor(G_ColorYellowPro)
	
	-- -- 强度
	-- if strong==nil then
	-- 	strong=0
	-- end
	-- local strongLb=GetTTFLabel(getlocal("plane_power"),lbSize)
	-- strongLb:setAnchorPoint(ccp(0.5,1))
	-- strongLb:setPosition(ccp(bgWidht/2,bgHeight/2-35))
	-- parent:addChild(strongLb,2)
	-- local numLb=GetTTFLabel(FormatNumber(strong),lbSize)
	-- numLb:setAnchorPoint(ccp(0.5,1))
	-- numLb:setPosition(ccp(bgWidht/2,bgHeight/2-53))
	-- parent:addChild(numLb,2)

	return icon
end

function planeVoApi:getPlaneIconNull()
	local iconBg = CCSprite:createWithSpriteFrameName("planeSkillGreenBg.png")
	local nullIcon = CCSprite:createWithSpriteFrameName("plane_icon.png")
	nullIcon:setAnchorPoint(ccp(0.5,0.5))
	nullIcon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+30))
	iconBg:addChild(nullIcon)
	nullIcon:setScale(1.7)
	local askIcon = CCSprite:createWithSpriteFrameName("noPlaneImg.png")
	askIcon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+30))
	iconBg:addChild(askIcon)
	return iconBg
end


function planeVoApi:getSkillCfgById(sid)
	return planeCfg.skillCfg[sid],planeGrowCfg.grow[sid]
end

--richFlag：是否使用富文本
--@refitSkillAttr : 战机改装中的增加技能槽位的技能属性值
function planeVoApi:getSkillInfoById(sid,noColor,richFlag,refitSkillAttr)
	local scfg,gcfg=self:getSkillCfgById(sid)
	local colorStr=getlocal("plane_skill_level_s"..gcfg.color)
	local nameStr=getlocal("plane_skill_name_s"..(gcfg.skillGroup+1))
	-- if noColor==nil or noColor==false then
	-- 	nameStr=colorStr..nameStr
	-- end
	if gcfg and gcfg.lv then
		if gcfg.lv>0 then
			nameStr=nameStr.."+"..gcfg.lv
		end
	end
	local myValue=scfg.myValue or 0
	if refitSkillAttr then
		myValue = (myValue * refitSkillAttr) * 100 .. "%%(" .. getlocal("planeRefit_inheritText") .. refitSkillAttr * 100 .. "%%)"
	else
		myValue=(myValue*100).."%%"
	end
	local planeAtk=scfg.planeAtk or 0
	planeAtk=(planeAtk*100).."%%"
	local buffValue=scfg.buffValue or 0
	if refitSkillAttr then
		buffValue = (buffValue * refitSkillAttr) * 100 .. "%%(" .. getlocal("planeRefit_inheritText") .. refitSkillAttr * 100 .. "%%)"
	else
		buffValue=(buffValue*100).."%%"
	end
	local rate=scfg.buffRate or 0 --概率生效
	rate=(rate*100).."%%"
	local takeEffectNum=scfg.effectNum or 0 --最大生效次数
	local cd=scfg.skillCD
	if richFlag==true then
		myValue="<rayimg>"..myValue.."<rayimg>"
		planeAtk="<rayimg>"..planeAtk.."<rayimg>"
		buffValue="<rayimg>"..buffValue.."<rayimg>"
		rate="<rayimg>"..rate.."<rayimg>"
		takeEffectNum="<rayimg>"..takeEffectNum.."<rayimg>"
	end
	local descStr=getlocal("plane_skill_desc_s"..(gcfg.skillGroup+1),{planeAtk,myValue,buffValue,cd,rate,takeEffectNum})
	local typeStr=""
	if scfg.skillType==1 or scfg.skillType==2 then
		typeStr=getlocal("plane_skill_passive")
	elseif scfg.skillType==3 or scfg.skillType==4 then
		typeStr=getlocal("plane_skill_active")
	end
	local privilegeStr
	if gcfg.exSkill then
		privilegeStr=getlocal("plane_skill_privilegeStr",{getlocal("plane_name_"..gcfg.exSkill)})
	end

	return nameStr,descStr,typeStr,privilegeStr,colorStr
end

function planeVoApi:getSkillVoById(sid)
	local list=self:getSkillList()
	for k,v in pairs(list) do
		if v and v.sid==sid then
			return v
		end
	end
	return nil
end

--获取技能的icon，showType：技能图标的显示方式 1：道具的显示方式 2：显示名称，强度的显示方式
function planeVoApi:getSkillIcon(sid,iconWidth,callback,num,showType,strong)
	local iconBg
	local scfg,gcfg=self:getSkillCfgById(sid)
	if scfg and gcfg then
		local skillBg,frameBg
		local pic="public/plane/icon/plane_skill_icon_s"..(gcfg.skillGroup+1)..".png"
		local quality=gcfg.color
		local showType=showType or 1
		local skillBgPic
		local skillType=scfg.skillType
		if skillType==1 or skillType==2 then
			skillBgPic="passiveSkillBg"..quality..".png"
		elseif skillType==3 or skillType==4 then
			skillBgPic="activeSkillBg"..quality..".png"
		end
		if skillBgPic==nil then
			skillBgPic="passiveSkillBg1.png"
		end
		local function clickCallBack()
			if showType~=2 then
				if callback then
					callback()
				end
			end
		end
		skillBg=LuaCCSprite:createWithSpriteFrameName(skillBgPic,clickCallBack)
		if skillBg then
			local icon=CCSprite:create(pic)
			if icon then
				-- icon:setScale((skillBg:getContentSize().width-20)/icon:getContentSize().width)
				icon:setPosition(getCenterPoint(skillBg))
				if showType==2 then
				else
					skillBg:setScale(iconWidth/skillBg:getContentSize().width)
					-- icon:setScale(bgWidth*(1/scale)/icon:getContentSize().width)
				end
				skillBg:addChild(icon)
				if showType==3 then
					-- 装备名称
					local nameFontSize=18
					local nameStr,descStr,typeStr,privilegeStr,colorStr=self:getSkillInfoById(sid)
					local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					nameLb:setAnchorPoint(ccp(0.5,0.5))
					nameLb:setPosition(ccp(skillBg:getContentSize().width/2,-20))
					skillBg:addChild(nameLb,2)
					local color=self:getColorByQuality(quality)
					nameLb:setColor(color)
				end
			end
		end
		if showType==2 then
			local bgPic="planeSkillBg"..quality..".png"
			local function clickCallBack2()
				if callback then
					callback()
				end
			end
			frameBg=LuaCCSprite:createWithSpriteFrameName(bgPic,clickCallBack2)
			if frameBg then
				if skillBg then
					frameBg:addChild(skillBg)
					-- skillBg:setScale((frameBg:getContentSize().width-30)/skillBg:getContentSize().width)
					skillBg:setPosition(frameBg:getContentSize().width/2,frameBg:getContentSize().height/2+15)
				end
				local nameFontSize=18
				-- 装备强度
				local strong=strong or gcfg.skillStrength
				local strongLb
				if strong then
					strongLb=GetTTFLabel(getlocal("skill_power",{strong}),nameFontSize)
					strongLb:setAnchorPoint(ccp(0.5,1))
					strongLb:setPosition(ccp(frameBg:getContentSize().width/2,frameBg:getContentSize().height-8))
					strongLb:setTag(10903)
					frameBg:addChild(strongLb)
					-- strongLb:setColor(G_ColorRed)
				end
				-- 装备名称
				local nameStr,descStr,typeStr,privilegeStr,colorStr=self:getSkillInfoById(sid,true)
				-- 装备名称
				local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
				nameLb:setAnchorPoint(ccp(0.5,1))
				nameLb:setPosition(ccp(frameBg:getContentSize().width/2,60))
				nameLb:setTag(10904)
				frameBg:addChild(nameLb,2)
				local color=self:getColorByQuality(quality)
				nameLb:setColor(color)

				-- local colorLb=GetTTFLabel(colorStr,nameFontSize)
				-- colorLb:setAnchorPoint(ccp(1,1))
				-- colorLb:setPosition(ccp(frameBg:getContentSize().width-2,frameBg:getContentSize().height-5))
				-- frameBg:addChild(colorLb)
				if num and num>0 then
					local ownStr=getlocal("emblem_infoOwn",{num})
					local ownLb=GetTTFLabel(ownStr,nameFontSize)
					ownLb:setAnchorPoint(ccp(0.5,1))
					ownLb:setPosition(ccp(frameBg:getContentSize().width/2,nameLb:getPositionY()-nameLb:getContentSize().height))
					ownLb:setTag(10902)
					frameBg:addChild(ownLb)
				end
			end
		end
		if showType==2 then
			iconBg=frameBg
		else
			iconBg=skillBg
		end
		local uniqueId=gcfg.exSkill
		if uniqueId and iconBg then
			local planeSp=CCSprite:createWithSpriteFrameName("plane_smallicon_"..uniqueId..".png")
			if planeSp then
				if showType==2 then
					planeSp:setPosition(15,iconBg:getContentSize().height-15)
				else
					planeSp:setPosition(iconBg:getContentSize().width-20,20)
				end
				iconBg:addChild(planeSp,2)
			end
		end
	end
	return iconBg	
end

function planeVoApi:getColorByQuality(quality)
	local color=G_ColorWhite
	if quality then
	    if tonumber(quality)==1 then
	        color=G_ColorWhite
	    elseif tonumber(quality)==2 then
	        color=G_ColorGreen
	    elseif tonumber(quality)==3 then
	        color=G_ColorBlue
	    elseif tonumber(quality)==4 then
	        color=G_ColorPurple
	    elseif tonumber(quality)==5 then
	        color=G_ColorOrange
	    end
	end
    return color
end

--~~~~~~~~~~~~~~~~~~~~~~~~下面是装备抽取的代码~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function planeVoApi:getSkillList()
	return self.skillList
end
--获取装备获取数量的配置
function planeVoApi:getSkillNumCfg()
	return planeGetCfg.planeGetNumCfg
end
--获取装备需要消耗的钻石或稀土(getType 获取消耗方式 1 钻石  2 稀土；index 第几个连抽)
function planeVoApi:getSkillCost(getType,index)
	local num=self:getSkillNumCfg()[getType][index]
	if(self.getTimes==nil)then
		self.getTimes={}
	end 
	if self.lastGetTs and self.lastGetTs[getType] and self.lastGetTs[getType] > 0 and G_getWeeTs(base.serverTime) > G_getWeeTs(self.lastGetTs[getType]) then
		self.getTimes[getType] = 0--当前的领取次数重置
	end
	local cfg
	if getType == 1 then
		cfg = planeGetCfg.goldCost --钻石的抽取消耗
	elseif getType == 2 then
		cfg = planeGetCfg.r5Cost --稀土的抽取消耗
	end

	local maxTimes = SizeOfTable(cfg)
	local times=self.getTimes[getType] or 0
	if(getType==1 and index==2 and times==0)then
		times=1
	end
	local cost = 0
	local addCost= 0
	for i=1,num do
		if (times+i) > maxTimes then
			addCost = cfg[maxTimes]
		else
			addCost = cfg[times+i]
		end	
		cost = cost + addCost
	end
	if getType == 2 then --战机改装技能对资源消耗有加成
		local pskillRate = planeRefitVoApi:getSkvByType(59)
		cost = math.floor(cost * (1 - pskillRate))
	end
	return cost
end

function planeVoApi:checkIfHadFreeCost()
	if self:getSkillCost(1,1) == 0 or self:getSkillCost(2,1) == 0 then
		return true
	end
	return false
end

function planeVoApi:addSkill(sid,num)
	for k,skillVo in pairs(self.skillList) do
		if skillVo.sid==sid then
			skillVo:addNum(num)
			do return end
		end
	end
	self.skillRfreshFlag=true
	-- print("sid------->add",sid)
	local scfg,gcfg=self:getSkillCfgById(sid)
	local skillVo=planeSkillVo:new(scfg,gcfg)
	skillVo:initWithData(sid,num)
	table.insert(self.skillList,skillVo)
end

--是否有新的技能产生
function planeVoApi:getSkillRfreshFlag()
	return self.skillRfreshFlag
end

function planeVoApi:setSkillRfreshFlag(flag)
	self.skillRfreshFlag=flag
end

function planeVoApi:sortSkillList(slist)
	local function sortFunc(a,b)
		local sid1=tonumber(RemoveFirstChar(a.sid))
		local sid2=tonumber(RemoveFirstChar(b.sid))
		local lv1=a.gcfg.lv or 0
		local lv2=b.gcfg.lv or 0
		local numWeight1=0
		local numWeight2=0
		if a.num>0 then
			numWeight1=100000
		end
		if b.num>0 then
			numWeight2=100000
		end
		local weight1=a.equipFlag*1000000+numWeight1+a.gcfg.color*10000+a.scfg.skillType*1000+lv1*100+a.gcfg.skillStrength*0.01+(2000-sid1)*0.000001
		local weight2=b.equipFlag*1000000+numWeight2+b.gcfg.color*10000+b.scfg.skillType*1000+lv2*100+b.gcfg.skillStrength*0.01+(2000-sid2)*0.000001
		-- print("sid1,weight1,sid2,weight2------>",sid1,weight1,sid2,weight2)
		return weight1>weight2
	end
	if slist then
		table.sort(slist,sortFunc)
	else
		table.sort(self.skillList,sortFunc)
	end
end

--获取可以装配的技能列表，euqipId：已经装配的技能id，perNum：每一页显示的技能个数
function planeVoApi:getCanEquipSkill(planeId,sid,perNum,activeFlag)
	local activeFlag=activeFlag or false
	local planeVo=self:getPlaneVoById(planeId)
	local list={}
	local skillList=self:getSkillList()
	if skillList then
		for k,vo in pairs(skillList) do
			local flag=false
			if vo.scfg.skillType==1 or vo.scfg.skillType==2 then
				flag=false
			elseif vo.scfg.skillType==3 or vo.scfg.skillType==4 then
				flag=true
			end
			if flag==activeFlag then
				local flag2=true
				if vo.gcfg.exSkill and vo.gcfg.exSkill~=planeId then
					flag2=false
				end
				if flag2==true then
					local scfg,gcfg=self:getSkillCfgById(sid)
					if sid~=0 and sid~=vo.sid and gcfg and gcfg.skillGroup==vo.gcfg.skillGroup then --如果是更换得把相同类型的插入到列表中
						table.insert(list,vo)
					else --已经装配的不能装配
						local equipFlag=self:isPlaneHasEquiped(planeVo,vo.sid)
						if equipFlag==false then
							table.insert(list,vo)
						end
					end
				end
			end
		end
	end
	local tmpList=list
	if perNum and perNum>0 then
		tmpList={}
		for k,v in pairs(list) do
			local page=math.ceil(k/perNum)
			if tmpList[page]==nil then
				tmpList[page]={}
			end
			table.insert(tmpList[page],v)
		end
	end
	return tmpList	
end

--判断飞机是否已经装配了该技能
function planeVoApi:isPlaneHasEquiped(planeVo,sid)
	if planeVo then
		local scfg,gcfg=self:getSkillCfgById(sid)
		if scfg and gcfg then
			local skills
			if scfg.skillType==1 or scfg.skillType==2 then --被动技能
				skills=planeVo:getPSkills()
			elseif scfg.skillType==3 or scfg.skillType==4 then --主动技能
				skills=planeVo:getASkills()
			end
			if skills then
				for k,skillId in pairs(skills) do
					if skillId~=0 and sid~=0 then
						local scfg2,gcfg2=self:getSkillCfgById(skillId)
						if skillId==sid or gcfg2.skillGroup==gcfg.skillGroup then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function planeVoApi:isSmameTypeSkill(osid,tsid)
	if osid and tsid then
		if osid==tsid then
			return true
		end
		local scfg1,gcfg1=self:getSkillCfgById(osid)
		local scfg2,gcfg2=self:getSkillCfgById(tsid)
		if gcfg1 and gcfg2 then
			if gcfg1.skillGroup==gcfg2.skillGroup then
				return true
			end
		end
	end
	return false
end

--判断有没有更好的技能可以装配
function planeVoApi:hasBetterEquip(planeId,sid,activeFlag)
	local sid=sid or 0
	local activeFlag=activeFlag or false
	local ablelist=self:getCanEquipSkill(planeId,sid,20000,activeFlag)
	if sid==0 then
		if #ablelist>0 then
			return true
		end
	else
		local scfg,gcfg=self:getSkillCfgById(sid)
		for k,list in pairs(ablelist) do
			for kk,vo in pairs(list) do
				local cfg=vo.gcfg
				if cfg and cfg.skillGroup==gcfg.skillGroup then
					if (cfg.color and gcfg.color and cfg.color>gcfg.color) then
						return true
					end
				end
			end
		end
	end
	return false
end

function planeVoApi:getSkillUpgradeCost(sid)
	local scfg,gcfg=self:getSkillCfgById(sid)
	if scfg==nil or gcfg==nil then
		return 0,{}
	end
	local costProps=FormatItem({p=gcfg.upCost})
	local useGems=0--所需要花费的钻石
	for k,v in pairs(costProps) do
		local havePropNum=bagVoApi:getItemNumId(v.id)
		if havePropNum<v.num then
			useGems=useGems+(v.num-havePropNum)*propCfg[v.key].gemCost
		end
	end
	return useGems,costProps
end

function planeVoApi:isSkillCanUpgrade(sid)
   	local scfg,gcfg=self:getSkillCfgById(sid)
    if gcfg then
    	local targetSid=gcfg.lvTo
        if targetSid and planeCfg.skillCfg[targetSid] then
        	return true
        end
    end
	return false
end

--获取融合的消耗
function planeVoApi:getSkillAdvanceCost(quality)
	local costProp={p=planeGetCfg.upgrade.prop[quality]}
	costProp=FormatItem(costProp,nil,true)[1]
	local useGems=0--所需要花费的钻石
	local havePropNum=bagVoApi:getItemNumId(costProp.id)
	if havePropNum<costProp.num then
		useGems=useGems+(costProp.num-havePropNum)*propCfg[costProp.key].gemCost
	end
	return costProp,havePropNum,useGems
end

function planeVoApi:getCanComposeSkills(quality,usedList)
	local slist={}
	local ownTb={}
	for k,v in pairs(self.skillList) do
		local usedNum=0
		if usedList and usedList[v.sid] then
			usedNum=usedList[v.sid]
		end
		local own=v.num-usedNum
		if (own>0 and quality and quality~=0 and v.gcfg.color==quality and v.gcfg.isCompose and v.gcfg.isCompose==1) then
			table.insert(slist,v)
			table.insert(ownTb,own)
		end
	end
	return slist,ownTb
end

--获取装备后刷新对应的数据(getType 获取消耗方式 1 钻石  2 稀土；index 第几个连抽)
function planeVoApi:afterGetSkill(getData,getType,index)
	-- local num = self:getSkillNumCfg()[getType][index]
	-- if getData ~= nil and (getType == 1 or getType == 2) and num > 0 then
	-- 	self.lastGetTs[getType] = base.serverTime
	-- 	if(self.getTimes[getType])then
	-- 		self.getTimes[getType] = self.getTimes[getType] + num
	-- 	else
	-- 		self.getTimes[getType]=num
	-- 	end
	-- end
end

--抽技能
--type 获取消耗稀土还是钻石   num 是抽1次 还是5次
function planeVoApi:lotterySkill(ltype,num,cost,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.plane then
				self:initLotterySkill(sData.data.plane)
			end
			if sData and sData.data and sData.data.reward then
				local award=FormatItem(sData.data.reward)
				for k,v in pairs(award) do
					G_addPlayerAward(v.type,v.key,v.id,v.num)
				end
				local numIndex
				for k,v in pairs(planeVoApi:getSkillNumCfg()[ltype]) do
					if(num==v)then
						numIndex=k
						break
					end
				end
				if ltype==1 then
					playerVoApi:setGems(playerVoApi:getGems() - cost)
				elseif ltype==2 then
				    playerVoApi:setGold(playerVoApi:getGold() - cost)
				end
				planeVoApi:afterGetSkill(award,ltype,numIndex)--刷新数据
				if(callback)then
					callback(award)
				end
				eventDispatcher:dispatchEvent("skill.freeget.refresh")
			end
		end
	end
	local cmd
	if ltype==1 then
		cmd="plane.skill.addbygold"
	elseif ltype==2 then
		cmd="plane.skill.addbyr5"
	end
	if cmd then
		socketHelper:planeLottery(cmd,num,onRequestEnd)
	end
end

function planeVoApi:skillEquipOrRemoveRequest(action,planeVo,pos,sid,activeFlag,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.plane then
				self:initSkillsInfo(sData.data.plane)
			end
			if planeVo then
				planeVo=planeVoApi:getPlaneVoById(planeVo.pid) --因原先的planeVo可能销毁重新创建所以需要重新获取一下vo
				if action==1 then --装配
					planeVo:replaceSkill(pos,sid,activeFlag)
				elseif action==2 then --卸载
					planeVo:removeSkill(pos,sid,activeFlag)
				end
			end
	
			if callback then
				callback()
			end
			local activeFlag=activeFlag or false
			local data={pid=planeVo.pid,idx=pos,activeFlag=activeFlag}
			eventDispatcher:dispatchEvent("plane.skill.refresh",data)
			local data2={sid=sid}
			eventDispatcher:dispatchEvent("plane.skillbag.refresh",data2)
			eventDispatcher:dispatchEvent("plane.data.refresh")
		end
	end
	if planeVo then
		socketHelper:planeSkillEquipOrRemove(action,planeVo.idx,pos,sid,onRequestEnd)
	end
end

--~~~~~~~~~~~~~~~~~~~~~~~~下面是装备分类获取的代码~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function planeVoApi:clearTempEquip(color)
	self.tempList[color] = {}
end

-- 选择一件装备后，添加id到已选择列表内（装备进阶）
function planeVoApi:addTempEquip(color,id)
	if SizeOfTable(self.tempList[color])<6 then
		table.insert(self.tempList[color],id)
	end
end

-- 取消选择一件装备后，从已选择列表内移除id（装备进阶）
function planeVoApi:deleteTempEquip(color,id)
	for k,v in pairs(self.tempList[color]) do
		if v==id then
			table.remove(self.tempList[color],k)
			do return end
		end
	end
end

-- 获取飞机的临时表 里面存储的是id
function planeVoApi:getTempList(color)
	return self.tempList[color]
end

-- 整理飞机列表，格式为 elist={ "e1"=2, "e2"=10, } (用于进阶)
function planeVoApi:formatEquipList(tb)
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
function planeVoApi:getSelectNum(color)
	return SizeOfTable(self.tempList[color])
end

-- 获取当前可选择的装备列表
function planeVoApi:getTempSelectList(color)
	local retTb = G_clone(self.planeList[color])
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

function planeVoApi:showAttackPlaneDialog(layerNum,tabIdx,planeId,studySid)
	require "luascript/script/game/scene/gamedialog/plane/planeAttackDialog"
	local td=planeAttackDialog:new(planeId,studySid)
	local tbArr={getlocal("plane_sub_title1"),getlocal("plane_sub_title2"),getlocal("plane_sub_title3")}
	local vd=td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("sample_build_name_106"),true,layerNum)
	sceneGame:addChild(vd,layerNum)
	if tabIdx then
		td:tabClick(tabIdx,false)
		td:tabClickColor(tabIdx)
	end
end

function planeVoApi:showUnlockPlaneDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/plane/unlockPlaneDialog"
	local td=unlockPlaneDialog:new()
	local tbArr={}
	local vd=td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("sample_build_name_106"),true,layerNum)
	sceneGame:addChild(vd,layerNum)
end

--studySid：正在研究的技能id
function planeVoApi:showMainDialog(layerNum,tabIdx,planeId,subType,studySid)
	if base.plane==0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage17000"),30)
		do return end
	end
	local openLv=self:getOpenLevel()
	local bName=getlocal(buildingCfg[106].buildName)
	if playerVoApi:getPlayerLevel()<openLv then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("armorMatrix_building_not_permit",{bName,openLv}),nil,layerNum)
		do return end
	end
	local function showDialog()
		local num=self:getUnlockAbleNum()
		if num>0 then --有可以解锁的飞机则显示解锁飞机的压面
			self:showUnlockPlaneDialog(layerNum)
		else --无可解锁的显示系统主页面
			self:showAttackPlaneDialog(layerNum,tabIdx,planeId,studySid)
			if subType=="get" then
				self:showGetDialog(layerNum+1)
			end
		end
	end
	self:planeGet(showDialog)
end

-- 批量分解的面板
function planeVoApi:showBulkSaleDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillBulkSaleDialog"
	local smallDialog=planeSkillBulkSaleDialog:new()
	smallDialog:init(layerNum)
	return smallDialog
end

--@refitSkillAttr : 战机改装中的增加技能槽位的技能属性值
function planeVoApi:showInfoDialog(skillVo,layerNum,isEquip,equipHandler,refitSkillAttr)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillInfoDialog"
	local smallDialog=planeSkillInfoDialog:new(skillVo)
	smallDialog:init(layerNum,isEquip,equipHandler,refitSkillAttr)
end

function planeVoApi:showGetDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillGetDialog"
	local td=planeSkillGetDialog:new()
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("skill_lottery"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function planeVoApi:showAdvanceDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillAdvanceDialog"
	local td=planeSkillAdvanceDialog:new(self.selectedTabIndex)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("skill_merge"),false,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function planeVoApi:showSellSkillDialog(sVoTb,layerNum,callback,bulkFlag)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillSellSmallDialog"
	local sd=planeSkillSellSmallDialog:new(sVoTb,callback,bulkFlag)
	sd:init(layerNum)
end

-- dtype：35 领土争夺战新加
function planeVoApi:showSelectPlaneDialog(quality,dialogType,layerNum,callback,usedList,canNotUseList,dtype,cid)
	local function realShow()
		require "luascript/script/game/scene/gamedialog/plane/planeSelectDialog"
		local sd=planeSelectDialog:new(quality,dialogType,usedList,callback,canNotUseList,dtype,cid)
		sd:init(layerNum)
	end
	if self.initFlag==nil then
		self:planeGet(realShow)
	else
		realShow()
	end
end

-- 领土争夺战新增 dtype
function planeVoApi:showPlaneInfoDialog(planeVo,layerNum,callback,dtype)
	require "luascript/script/game/scene/gamedialog/plane/planeDetailInfoDialog"
	local sd=planeDetailInfoDialog:new()
	sd:init(planeVo,layerNum,callback,dtype)
end

function planeVoApi:showUpgradeDialog(sid,layerNum,planeVo,pos,activeFlag)
	require "luascript/script/game/scene/gamedialog/plane/planeSkillUpgradeDialog"
	local td = planeSkillUpgradeDialog:new(sid,planeVo,pos,activeFlag)
	local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("plane_skill_upgrade"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--弹出面板信息
function planeVoApi:showInfoSmallDialog(sid,layerNum,isShowBtn,planeVo,pos,activeFlag)
    require "luascript/script/game/scene/gamedialog/plane/planeSkillInfoSmallDialog"
	local smallDialog=planeSkillInfoSmallDialog:new()
	smallDialog:init(sid,layerNum,isShowBtn,planeVo,pos,activeFlag)
	return smallDialog
end

--弹出装配面板
function planeVoApi:showSelectDialog(planeVo,pos,activeFlag,layerNum)
    require "luascript/script/game/scene/gamedialog/plane/planeSkillSelectDialog"
	local td=planeSkillSelectDialog:new(planeVo,pos,activeFlag)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("skill_equip_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--弹出选择技能的面板
function planeVoApi:showSkillSelectSmallDialog(quality,usedList,callback,layerNum,dialogType)
    require "luascript/script/game/scene/gamedialog/plane/planeSkillSelectSmallDialog"
	local td=planeSkillSelectSmallDialog:new(quality,usedList,callback,dialogType)
	local dialog=td:init(layerNum)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~获取属性加成~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--获得该装备提升的属性加成值
--param eId: 装备id
--return {100,100,2000,2000}
function planeVoApi:getTankAttAdd(eId)
	local result={0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	return result
end

-- 通过sid获取到分解所得配置
function planeVoApi:getSkillDecomposeByIdAndNum(sid,num)
	-- 装备分解配置
	local scfg,gcfg=self:getSkillCfgById(sid)

	local dCfg=G_clone(gcfg.deCompose)
	local awardCfg={}
	-- 多件数量计算
	for k,v in pairs(dCfg) do
		dCfg[k]=dCfg[k]*num
		local pType=string.sub(k,1,1)
		if(awardCfg[pType]==nil)then
			awardCfg[pType]={}
		end
		awardCfg[pType][k]=dCfg[k]
	end
	local award=FormatItem(awardCfg)
	return award
end

-- 批量分解获得道具
function planeVoApi:getSkillDecomposeByElist(skillTb)
	-- 分解获得的所有道具
	local totalProp={}
	-- 循环分解装备
	for k,sVo in pairs(skillTb) do
		local sellCfg=sVo.gcfg.deCompose
		for pid,pNum in pairs(sellCfg) do
			local pType=string.sub(pid,1,1)
			if(totalProp[pType]==nil)then
				totalProp[pType]={}
			end
			if(totalProp[pType][pid]==nil)then
				totalProp[pType][pid]=pNum*sVo.num
			else
				totalProp[pType][pid]=totalProp[pType][pid]+pNum*sVo.num
			end
		end
	end
	totalProp=FormatItem(totalProp,false,true)
	return totalProp
end

-- 获取强度最大的装备id
function planeVoApi:getMaxStrongEquip(bType)
	local maxStrongPlanePos=nil
	local value=0
	for k,vo in pairs(self.planeList) do
		if vo then
			if planeVoApi:checkEquipCanUse(bType,vo.idx)==true then
				if maxStrongPlanePos==nil then
					maxStrongPlanePos=vo.idx
				end
				local tmpValue=vo:getStrength() or 0
				if value<tmpValue then
					value=tmpValue
					maxStrongPlanePos=vo.idx
				end
			end
		end
	end
	return maxStrongPlanePos
end

-- -- 通过装备id获取带兵量增加数量
-- function planeVoApi:getTroopsAddById(equipId)
-- 	local troopsAdd = 0
-- 	local color = 1
-- 	if base.plane==1 then
-- 		local equipCfg = self:getEquipCfgById(equipId)
-- 		if equipCfg and equipCfg.attUp and equipCfg.attUp.troopsAdd then
-- 			troopsAdd = equipCfg.attUp.troopsAdd
-- 			color = equipCfg.color
-- 		end
-- 	end
-- 	return troopsAdd,color
-- end

-- 设置临时的飞机
function planeVoApi:setTmpEquip(equipId,bType)
	if base.plane==0 then
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
		if bType==7 or bType==8 or bType==9 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		elseif bType==13 or bType==14 or bType==15 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		elseif bType==21 or bType==22 or bType==23 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		elseif bType==24 or bType==25 or bType==26 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		elseif bType==27 or bType==28 or bType==29 then
			if self.tmpEquip==nil then
				self.tmpEquip = {}
			end
			self.tmpEquip[bType] = equipId
		-- elseif bType==35 or bType==36 then -- 领土争夺战
		-- 	if self.tmpEquip==nil then
		-- 		self.tmpEquip = {}
		-- 	end
		-- 	self.tmpEquip[bType] = equipId
		else
			self.tmpEquip = equipId
		end
	end 
end

-- 获取临时的飞机
function planeVoApi:getTmpEquip(bType)
	if base.plane~=1 then
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

-- 设置战斗的飞机
-- bType：战斗类型
-- equipId：装备id
function planeVoApi:setBattleEquip(bType,equipId)
	if base.plane==0 then
		do return end
	end
	if equipId==0 then
		equipId = nil
	end

	if equipId and type(equipId)=="string" then
		local planeVo=self:getPlaneVoById(equipId)
		if planeVo and planeVo.idx then
			equipId=planeVo.idx
		end
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
	elseif bType==38 then
		self.championshipWarPersonalCurPlane=equipId
	elseif bType==39 then
		self.championshipWarCurPlane=equipId
	end
end

-- 获取战斗的飞机
-- bType：战斗类型
function planeVoApi:getBattleEquip(bType,cid)
	if base.plane~=1 then
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
		equipId = ltzdzFightApi:getDefencePlane(bType,cid)
	elseif bType==38 then
		equipId=self.championshipWarPersonalCurPlane
	elseif bType==39 then
		equipId=self.championshipWarCurPlane
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

-- 通过pos获取是否已出征
function planeVoApi:getIsBattleEquip(equipId)
	if self.battleEquipList then
		for k,v in pairs(self.battleEquipList) do
			if v and v==equipId then
				return true
			end
		end
	end
	return false
end

-- 通过id获取已的飞机{c7582690=3,},{序列id=解锁位置,}
function planeVoApi:setBattleEquipList(equipTb)
	self.battleEquipList=equipTb or {}
end

-- -- 往出征队列中加equip
-- function planeVoApi:addBattleEquipNum(equipId)
-- 	if self.battleEquipList==nil then
-- 		self.battleEquipList = {}
-- 	end
-- 	if self.battleEquipList[equipId]==nil then
-- 		self.battleEquipList[equipId] = 1
-- 	else
-- 		self.battleEquipList[equipId] = self.battleEquipList[equipId] + 1
-- 	end
-- end

-- 清空出征队列
function planeVoApi:clearBattleEquipList()
	self.battleEquipList = nil
end

-- 清空不可重复使用的飞机
function planeVoApi:clearEquipCanNotUse(bType)
	if bType==11 then
		self.expeditionDeadEquip = {}
	else
		do return end
	end
end

-- 获取不可重复使用的飞机
function planeVoApi:getEquipCanNotUse(bType)
	if bType==11 then
		return self.expeditionDeadEquip
	elseif bType==7 or bType==8 or bType==9 then
		local retTb = G_clone(self.serverWarPersonalEquip)
		retTb[bType] = nil 
		return retTb
	elseif bType==13 or bType==14 or bType==15 then
		local retTb = G_clone(self.worldWarEquip)
		retTb[bType] = nil 
		return retTb
	elseif bType==21 or bType==22 or bType==23 then
		local retTb = G_clone(self.platWarEquip)
		retTb[bType] = nil 
		return retTb
	elseif bType==24 or bType==25 or bType==26 then
		local retTb = G_clone(self.serverWarLocalEquip)
		retTb[bType] = nil 
		return retTb
	elseif bType==35 or bType==36 then -- 领土争夺战
		return {}
	else
		do return end
	end
end

-- 设置不可重复使用的飞机
function planeVoApi:setEquipCanNotUse(bType,equipTb)
	--远征
    if bType==11 then
        self.expeditionDeadEquip = equipTb
    end
end


-- 判断此id的装备数量是否还有剩余的可以上阵
-- bType:战斗类型
-- equipId:装备id
function planeVoApi:checkEquipCanUse(bType,equipId)
	-- print("bType,equipId",bType,equipId)
	local equipVo = self:getPlaneVoByPos(equipId)
	if equipVo==nil then
		return false
	end
	-- 不可用的飞机(大战和远征不可重复使用)
	local noEquipId = self:getEquipCanNotUse(bType)
	-- 是否不可用的飞机(出征)
	local isBattle = self:getIsBattleEquip(equipId)
	-- print("isBattle",isBattle)
	if isBattle==true then
		do return false end
	end
	-- 只有多个的时候才会涉及重复问题
	if noEquipId and type(noEquipId)=="table" then
		for k,v in pairs(noEquipId) do
			-- print("k,v~~~~~~",k,v)
			if v==equipId then
				do return false end
			end
		end
	end
	return true
end

-- 设置刷新钻石邮件的时间戳
function planeVoApi:setRefreshTime(time)
	self.rtime = time
end

-- 获取刷新钻石邮件的时间戳
function planeVoApi:getRefreshTime()
	return self.rtime
end

-- 获取飞机开放等级
function planeVoApi:getOpenLevel()
	return self:getOpenLevelCfg()[1]
end

--解锁飞机 pid：飞机id；callback：解锁后的回调处理
function planeVoApi:unlock(pid,callback)
	local function unlockCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			self:initData(sData.data)
			self:checkLockPlanes()
			if callback then
				callback()
			end
		end
	end
	socketHelper:planeUnlock(pid,unlockCallBack)
end

function planeVoApi:sell(sid,qualityTb,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local award = FormatItem(sData.data.reward) or {}
			for k,v in pairs(award) do
				G_addPlayerAward(v.type,v.key,v.id,v.num)
			end
			if sData.data then
				self:initData(sData.data)
			end
			G_showRewardTip(award,true)
			eventDispatcher:dispatchEvent("plane.skillbag.refresh")
			eventDispatcher:dispatchEvent("plane.skillpage.refresh")
			
			if(callback)then
				callback()
			end
		end
	end
	if(sid)then
		socketHelper:planeSkillSell(sid,nil,onRequestEnd)
	elseif(qualityTb)then
		socketHelper:planeSkillSell(nil,qualityTb,onRequestEnd)
	elseif(callback)then
		callback()
	end
end

--融合
function planeVoApi:compose(skillList,gemsCost,callback,need,specialCostTb)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				self:initData(sData.data)
			end
			local color
			for sid,num in pairs(skillList) do
				local scfg,gcfg=self:getSkillCfgById(sid)
				color=gcfg.color
				break
			end
			local needProp,havePropNum,useGems=self:getSkillAdvanceCost(color)
			local propID=(tonumber(needProp.key) or tonumber(RemoveFirstChar(needProp.key)))
			local propNum=bagVoApi:getItemNumId(propID)
			if(gemsCost)then
				playerVoApi:setGems(playerVoApi:getGems()-gemsCost)
			end
			local totalNum=0
			for id,num in pairs(skillList) do
				totalNum=totalNum + num
			end
			local composeNum=math.floor(totalNum/6)
			bagVoApi:useItemNumId(propID,math.min(propNum,composeNum*needProp.num))
			if specialCostTb and type(specialCostTb)=="table" then
				for k,v in pairs(specialCostTb) do
					print("v.id,v.num === >",v.id,v.num)
					bagVoApi:useItemNumId(v.id, v.num)
				end
			end
			local award=FormatItem(sData.data.reward)
			if(callback)then
				callback(award)
			end
		end
 	end
 	local costFlag=false
 	if gemsCost>0 then
 		costFlag=true
 	end
	socketHelper:planeSkillAdvance(skillList,costFlag,onRequestEnd,need)
end

function planeVoApi:upgrade(sid,useGems,callback,planeVo,pos,activeFlag)
	if sid==nil then
		do return end
	end
	local costGems=self:getSkillUpgradeCost(sid)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			self:initData(sData.data)
			if costGems>0 then
				playerVoApi:setGems(playerVoApi:getGems()-costGems)
			end
			if planeVo then --如果升级的是飞机上装配的技能，则刷新装配页面
				local data={pid=planeVo.pid,idx=pos,activeFlag=activeFlag or false}
				eventDispatcher:dispatchEvent("plane.skill.refresh",data)
				eventDispatcher:dispatchEvent("plane.data.refresh")
			end
			local data={sid=sid}
			eventDispatcher:dispatchEvent("plane.skillbag.refresh",data)
			eventDispatcher:dispatchEvent("plane.skillpage.refresh")
			if(callback)then
				callback()
			end
		end
	end
	local planeIdx
	if planeVo then
		planeIdx=planeVo.idx
	end
	socketHelper:planeSkillUpgrade(sid,planeIdx,useGems,onRequestEnd)
end

--筛选出未获得的技能
function planeVoApi:getLockSkill(sid,list)	
	local scfg,gcfg=self:getSkillCfgById(sid)
	if scfg and gcfg then
		for k,cfg in pairs(list) do
			if (cfg.lv and cfg.lv>0) then
				list[k]=nil
			end
		end
	end
	return list
end

--结束飞机功能教学
function planeVoApi:endPlaneGuide()
	for i=32,39 do
		otherGuideMgr:setGuideStepDone(i)
	end
	otherGuideMgr:endNewGuid()
end

-- 当前角色等级解锁的槽位
function planeVoApi:getSlotNumByLevel()
	local playerLv=playerVoApi:getPlayerLevel()
	local openlevelCfg=planeVoApi:getOpenLevelCfg()

	for k,v in pairs(openlevelCfg) do
		if playerLv<v then
			return k-1
		end
	end
	return #openlevelCfg
end

--获取部分飞机数据（用于飞机建筑功能图标提示）
function planeVoApi:setPlanePartData(pData)
	if pData and pData.plane then
		self.planeList={}
		for k,v in pairs(pData.plane) do
			local cfg=self:getPlaneCfgById(k)
			local vo=planeVo:new(cfg)
			vo:initWithData(v,k)
			table.insert(self.planeList,vo)
		end
	end
	if pData and pData.info then
		if pData.info.gold then
			self.lastGetTs[1]=pData.info.gold[1]
			self.getTimes[1]=pData.info.gold[2]
		end
		if pData.info.r5 then
			self.lastGetTs[2]=pData.info.r5[1]
			self.getTimes[2]=pData.info.r5[2]
		end
	end
	if pData and pData.nsinfo then --战机革新的数据
		self.nsinfo=pData.nsinfo
		self:initStudyList()
	end
end

--获取战机革新的配置
function planeVoApi:getNewSkillCfg()
	local skillCfg=G_requireLua("config/gameconfig/planeNewSkillCfg")
  	return skillCfg
end

--判断战机革新功能是否开启（当玩家把所有战机解锁后开启战机革新功能）
function planeVoApi:isSkillTreeSystemOpen()
	if base.plane==0 then
		do return false end
	end
	local num=SizeOfTable(planeCfg.plane)
	local planeList=self:getPlaneList()
	local planeNum=SizeOfTable(planeList)
	if planeNum==num then --说明所有的飞机都已经解锁了
		return true
	end
	return false
end

--获取对应技能id的信息
function planeVoApi:getNewSkillInfoById(sid)
	local nscfg=self:getNewSkillCfg()
	local maxLv,sinfo=0,{} --技能数据，最大等级
	local cfg=nscfg.skill[sid]
	if cfg then
		maxLv=cfg.maxLevel
	end
	if self.nsinfo and self.nsinfo[sid] then
		sinfo=self.nsinfo[sid]
	end
	return sinfo,maxLv
end

--升级指定技能
function planeVoApi:upgradeNewSkill(sid,callback)
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data and sData.data.plane then
        		planeVoApi:initData(pData)
        	end
        	if callback then
        		callback()
        	end
        end
	end
	socketHelper:planeNewSkillUpgrade(sid,socketCallback)
end

--取消指定升级技能的队列
function planeVoApi:cancelUpgradeNewSkill(sid,callback)
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data and sData.data.plane then
        		planeVoApi:initData(pData)
        	end
        	if callback then
        		callback()
        	end
        end
	end
	socketHelper:planeNewSkillCancelUpgrade(sid,socketCallback)
end

--加速指定升级技能
function planeVoApi:speedupUpgradeNewSkill(sid,callback)
	local function socketCallback(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data and sData.data.plane then
        		planeVoApi:initData(pData)
        	end
        	if callback then
        		callback()
        	end
        end
	end
	socketHelper:planeNewSkillSpeedUpgrade(sid,socketCallback)
end

--使用战机革新中的主动技能
function planeVoApi:useNewActiveSkill(sid,callback)
	local function useCallBack(fn,data)
  		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.plane then
				self:initData(sData.data.plane)
			end
			if callback then
				if sid=="s5" then --赠送坦克
					callback(sData.data.gives)
				else
					callback()
				end
			end
		end
	end
	socketHelper:usePlaneNewSkill(sid,useCallBack)
end

function planeVoApi:getNewSkillNameStr(sid)
	local nscfg=self:getNewSkillCfg()
	local planeName=getlocal("plane_name_p"..nscfg.skill[sid].schoolId)
	local id=tonumber(RemoveFirstChar(sid))
	local skillName=""
	if id>=1 and id<=4 then
		skillName=getlocal("plane_nsname_".."s1",{planeName})
	elseif id>=6 and id<=9 then
		skillName=getlocal("plane_nsname_".."s6",{planeName})
	elseif id>=11 and id<=14 then
		skillName=getlocal("plane_nsname_".."s11",{planeName})
	elseif id>=16 and id<=19 then
		skillName=getlocal("plane_nsname_".."s16",{planeName})
	else
		skillName=getlocal("plane_nsname_"..sid)
	end
	return skillName
end

function planeVoApi:getNewSkillIcon(sid,callback,isGray)
	local skillSp
	local pic="plane_nspic_"..sid..".png"
	if isGray then
		skillSp=GraySprite:createWithSpriteFrameName(pic)
		do return skillSp end
	end
	local function touch()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		if callback then
			callback()
		end
	end
	skillSp=LuaCCSprite:createWithSpriteFrameName(pic,touch)
	
	return skillSp
end

--获取研究值
function planeVoApi:getStudyPoint()
	local nscfg=self:getNewSkillCfg()
	local point=self.study.v or nscfg.useCostLimit
	if self.study.t and self.study.t>0 and point<nscfg.useCostLimit then
		local returnSpeed = self:getStudyPointReturnSpeed()
		point=point+math.floor((base.serverTime-self.study.t)/returnSpeed)
		if point>nscfg.useCostLimit then --累计增加的研究值不能大于最大值
			point=nscfg.useCostLimit
		end
	end
	return point,nscfg.useCostLimit --当前研究值，研究值上限
end

function planeVoApi:getNewSkillCfgByLv(sid,lv)
	local nscfg=self:getNewSkillCfg()
	if nscfg.skill[sid] and nscfg.skill[sid].lvinfo then
		return (nscfg.skill[sid].lvinfo[lv] or nil)
	end
	return nil
end

--判断技能是否在研究中
function planeVoApi:isNewSkillStudying(sid)
	local sinfo,maxLv=self:getNewSkillInfoById(sid)
	if sinfo.q and sinfo.q>base.serverTime then
		return true,(sinfo.q-base.serverTime)
	end
	return false
end

--获取主动技能的使用状态 0：未使用，1：生效中，2：冷却中
function planeVoApi:getNewActiveSkillUseFlag(sid)
	local sinfo,maxLv=self:getNewSkillInfoById(sid)
	if sinfo and sinfo.l and sinfo.t then
		local scfg=self:getNewSkillCfgByLv(sid,sinfo.l)
		if scfg then
			if scfg.buffTime and (base.serverTime<(sinfo.t+scfg.buffTime)) then
				if (sid=="s10" or sid=="s20") and sinfo.n and sinfo.n>0 then --如果是击飞和戏谑技能的话，需要判断生效次数，次数大于0说明已经生效过，则不生效
					if scfg.cd and (base.serverTime<(sinfo.t+scfg.cd)) then
						return 2,(sinfo.t+scfg.cd),scfg.cd
					end
				end		
				return 1,(sinfo.t+scfg.buffTime),scfg.buffTime
			elseif scfg.cd and (base.serverTime<(sinfo.t+scfg.cd)) then
				return 2,(sinfo.t+scfg.cd),scfg.cd
			end
		end
	end
	return 0
end

--战机革新主动技能是否有空闲的使用队列
function planeVoApi:isNewActiveSkillUseSlotEmpty()
	local nscfg=self:getNewSkillCfg()
	for k,sid in pairs(nscfg.activeSkill) do
		local sinfo=self:getNewSkillInfoById(sid)
		if sinfo and sinfo.lv and tonumber(sinfo.lv)>0 then
			if sinfo.l==nil or sinfo.l==0 then --没有使用等级，说明没有使用过
				return true
			elseif sinfo.t and sinfo.l then
				local lvinfo=self:getNewSkillCfgByLv(sid,sinfo.l)
				if lvinfo and lvinfo.cd and (base.serverTime>(sinfo.t+lvinfo.cd)) then --已过了冷却时间，则可以使用
					return true
				end 
			end
		end
	end
	return false
end

--获取飞机的各个buff的加成
function planeVoApi:getPlaneAddBuffByPlaneId(planeId)
	local pid=(type(planeId)=="number") and planeId or tonumber(RemoveFirstChar(planeId))
	local buffTb={}
	local nscfg=self:getNewSkillCfg()
	for sid,v in pairs(self.nsinfo) do
		local scfg=nscfg.skill[sid]
		if tonumber(scfg.schoolId)==pid then
			local buff=self:getPlaneNewSkillAddBuff(sid)
			for k,v in pairs(buff) do
				buffTb[k]=(buffTb[k] or 0)+v --相同属性相加
			end
		end
	end
	return buffTb
end

--获取战机革新功能增加的飞机的威力值
function planeVoApi:getAddStrengthByPlaneId(planeId)
	local pid=(type(planeId)=="number") and planeId or tonumber(RemoveFirstChar(planeId))
	local strength=0
	local nscfg=self:getNewSkillCfg()
	for sid,v in pairs(self.nsinfo) do
		local scfg=nscfg.skill[sid]
		--schoolId=0表示给所有类型飞机加成
		if tonumber(scfg.schoolId)==pid or tonumber(scfg.schoolId)==0 then
			local sinfo=self:getNewSkillInfoById(sid)
			if sinfo and sinfo.lv and tonumber(sinfo.lv)>0 then
				local lvinfo=self:getNewSkillCfgByLv(sid,sinfo.lv)
				if lvinfo and lvinfo.skillStrength and tonumber(lvinfo.skillStrength)>0 then
					strength=strength+tonumber(lvinfo.skillStrength)
				end
			end
		end
	end
	return strength
end

--获取指定技能的buff加成
function planeVoApi:getPlaneNewSkillAddBuff(sid)
	local buffTb={}
	if base.plane==0 then --飞机未解锁
		do return buffTb end
	end
	local nscfg=self:getNewSkillCfg()
	local sinfo=self:getNewSkillInfoById(sid)
	local scfg=nscfg.skill[sid]
	if scfg and sinfo and sinfo.lv and sinfo.lv>0 and scfg.lvinfo[sinfo.lv] then
		local lvinfo=scfg.lvinfo[sinfo.lv] --属性相关
		if scfg.type==0 then --被动技能（始终生效）
			buffTb=lvinfo.attUp
		elseif scfg.type==1 and sinfo.l and sinfo.l>0 and sinfo.t and lvinfo.addTroops then --主动技能（有生效时间）buff效果目前只考虑增加带兵量（因需要显示带兵量），其他的buff效果都是后台处理
			local einfo=self:getNewSkillCfgByLv(sid,sinfo.l) --技能生效等级的配置
			if einfo and einfo.buffTime and base.serverTime<(sinfo.t+einfo.buffTime) then
				buffTb.add=lvinfo.addTroops.num --增加的带兵量
			end
		end
	end

	return buffTb
end

--获取最大研究队列数
function planeVoApi:getMaxStudyListNum()
	local nscfg=self:getNewSkillCfg()
	return nscfg.process or 1
end

--初始化研究队列
function planeVoApi:initStudyList()
	if self.nsinfo then
		local perNum,curNum=0,0
		if self.studyList then
			perNum=SizeOfTable(self.studyList)
		end
		self.studyList=nil
		for k, v in pairs(self.nsinfo) do
			if v and type(v.q)=="number" and v.q>0 and base.serverTime<v.q then
				if self.studyList==nil then
					self.studyList={}
				end
				self.studyList[k]=v
				curNum=curNum+1
			end
		end
		if perNum~=curNum then --有技能研究队列发生变化
			eventDispatcher:dispatchEvent("plane.newskill.refresh",{})
		end
	end
end

--获取研究队列
function planeVoApi:getStudyList()
	if base.plane==0 then
		do return nil end
	end
	local studyTb=nil
	if self.studyList then
		for k, v in pairs(self.studyList) do
			if studyTb==nil then
				studyTb={}
			end
			table.insert(studyTb,{sid=k,lv=v.lv,q=v.q})
		end
	end
	return studyTb
end

function planeVoApi:getNewSkillDesc(sid,lv,isShowPlaneName)
	local addStr=""
	local lvinfo=self:getNewSkillCfgByLv(sid,lv)
	if lv==0 then
		lvinfo=self:getNewSkillCfgByLv(sid,1)
	end
	if lvinfo then
		if lvinfo.attUp then --被动技能
			if lvinfo.attUp.critical then --暴击
				addStr=getlocal("alliance_skill_name_13").."+"..(lv==0 and 0 or (lvinfo.attUp.critical*100)).."%"
			elseif lvinfo.attUp.accurate then --精准
				addStr=getlocal("alliance_skill_name_11").."+"..(lv==0 and 0 or (lvinfo.attUp.accurate*100)).."%"
			elseif lvinfo.attUp.avoid then --闪避
				addStr=getlocal("alliance_skill_name_12").."+"..(lv==0 and 0 or (lvinfo.attUp.avoid*100)).."%"
			elseif lvinfo.attUp.decritical then --坚韧
				addStr=getlocal("property_anticrit").."+"..(lv==0 and 0 or (lvinfo.attUp.decritical*100)).."%"
			elseif lvinfo.attUp.restrain then --克制系数
				addStr=getlocal("restrain_coefficient").."+"..(lv==0 and 0 or (lvinfo.attUp.restrain*100)).."%"
			elseif lvinfo.attUp.energy then --能量点上限
				addStr=getlocal("power_spot").."+"..(lv==0 and 0 or lvinfo.attUp.energy)
			elseif lvinfo.attUp.atk then --伤害
				addStr=getlocal("BossBattle_damagePoint").."+"..(lv==0 and 0 or (lvinfo.attUp.atk*100)).."%"
			end
			if isShowPlaneName and addStr~="" then
				local nscfg=self:getNewSkillCfg()
				local planeName=getlocal("plane_name_p"..nscfg.skill[sid].schoolId)
				local id=tonumber(RemoveFirstChar(sid))
				if id>=1 and id<=4 then
					planeName=planeName..getlocal("fleetInfoTitle2")
				elseif id>=16 and id<=19 then
					planeName=planeName..getlocal("self_text")
				end
				addStr=planeName..addStr
			end
		elseif lvinfo.addBox then --增加坦克,pool随机,与道具箱子一致,num抽取的次数
			local cd = GetTimeStr(lv==0 and 0 or lvinfo.cd,true)
			local num = (lv==0 and 0 or lvinfo.addBox.num*2)
			addStr=getlocal("plane_skill_nsdesc_s5",{num,cd})
		elseif lvinfo.hitFly then --hitFly: 击飞,prosperous 繁荣度,低于此繁荣度击飞,haveTime 拥有敌方产量的时间,单位's
			local buffTime = GetTimeStr(lv==0 and 0 or lvinfo.buffTime,true)
			local prosperous = (lv==0 and 0 or (lvinfo.hitFly.prosperous*100))
			local haveTime = GetTimeStr(lv==0 and 0 or lvinfo.hitFly.haveTime,true)
			local cd = GetTimeStr(lv==0 and 0 or lvinfo.cd,true)
			addStr=getlocal("plane_skill_nsdesc_s10",{buffTime,prosperous,haveTime,cd})
		elseif lvinfo.addTroops then --addTroops:临时增加带兵量,num 增加的数量
			local num = (lv==0 and 0 or lvinfo.addTroops.num)
			local buffTime = GetTimeStr(lv==0 and 0 or lvinfo.buffTime,true)
			local cd = GetTimeStr(lv==0 and 0 or lvinfo.cd,true)
			addStr=getlocal("plane_skill_nsdesc_s15",{num,buffTime,cd})
		elseif lvinfo.killProtect then --killProtect:破保护杀兵,myLost 我方损兵率, enemyLost 敌方损兵率
			local buffTime = GetTimeStr(lv==0 and 0 or lvinfo.buffTime,true)
			-- local myLost = (lv==0 and 0 or (lvinfo.killProtect.myLost*100))
			-- local enemyLost = (lv==0 and 0 or (lvinfo.killProtect.enemyLost*100))
			local cd = GetTimeStr(lv==0 and 0 or lvinfo.cd,true)
			addStr=getlocal("plane_skill_nsdesc_s20",{buffTime,cd})
		end
	end
	return addStr
end

--判断一个技能是否已经解锁
function planeVoApi:isNewSkillUnlock(sid)
	local unlockFlag=true
	local nscfg=self:getNewSkillCfg()
	local scfg=nscfg.skill[sid]
	local lvinfo=self:getNewSkillCfgByLv(sid,1)
	if lvinfo and lvinfo.preSkill then
		for k,v in pairs(lvinfo.preSkill) do
			local id,lv=v[1],v[2]
			local sinfo=self:getNewSkillInfoById(id)
			if sinfo and tonumber(sinfo.lv or 0)<tonumber(lv) then --前置技能等级达不到的话就未解锁
				unlockFlag=false
				do break end
			end
		end
	end
	return unlockFlag
end

--获取技能研究剩余时间
function planeVoApi:getStudyLeftTime(sid)
	local leftTime=0
	if self.studyList and self.studyList[sid] then
		local skill=self.studyList[sid]
		leftTime=skill.q-base.serverTime
	end
	return leftTime
end

--是否有空闲的研究队列
function planeVoApi:isStudySlotEmpty()
	if self.studyList==nil or SizeOfTable(self.studyList)==0 then
		return true
	end
	return false
end

function planeVoApi:isOpen()
	if base.plane==0 then
		return false
	end
	local openLv=self:getOpenLevel()
	if playerVoApi:getPlayerLevel()>=openLv then
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
function planeVoApi:getFreeData()
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
function planeVoApi:getR5BuyNum()
	local num = 0
	local maxNum = self:getSkillNumCfg()[2][2]
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
		r5CostNum = r5CostNum + planeGetCfg.r5Cost[i]
		if r5CostMinNum == nil then
			r5CostMinNum = planeGetCfg.r5Cost[i]
		end
	end 
	return { {num, maxNum, r5CostNum, r5CostMinNum} }
end

--获取水晶购买的消耗数据
--[[@return
	水晶购买的次数, 总共消耗的水晶数
--]]
function planeVoApi:getR5Cost(num, maxNum)
	local gold = playerVoApi:getGold()
	local r5Cost = 0
	local r5CostNum = 0
	for i = maxNum - num + 1, maxNum do
		if gold >= planeGetCfg.r5Cost[i] then
			gold = gold - planeGetCfg.r5Cost[i]
			r5Cost = r5Cost + planeGetCfg.r5Cost[i]
			r5CostNum = r5CostNum + 1
		end
	end
	return r5CostNum, r5Cost
end

function planeVoApi:updateLastGetTimes(getType, num)
	self.lastGetTs[getType] = base.serverTime
	if(self.getTimes[getType])then
		self.getTimes[getType] = self.getTimes[getType] + num
	else
		self.getTimes[getType]=num
	end
end

--是否已经有飞机装配了主动技能
function planeVoApi:hasPlaneEquip()
	for k,v in pairs(self.planeList) do
		if v.aSkillTb and SizeOfTable(v.aSkillTb)>0 then --只判断主动技能
			return true
		end
	end
	return false
end

function planeVoApi:getPlanePic(pid)
	return "plane_icon_"..pid..".png"
end

function planeVoApi:getPlaneSmallPic(pid)
	return "plane_smallicon_"..pid..".png"
end

--同步飞机的出征状态
function planeVoApi:syncStats(stats)
	if stats and next(stats) then
		-- 基地防守
		if stats.d then
			-- 设置飞机
			self:setBattleEquip(1,stats.d[1])
		end
		-- 出征
		if stats.a then
			self:clearBattleEquipList()
			--添加出征数量
			self:setBattleEquipList(stats.a)
		end
		-- 军事演习
		if stats.m then
			-- -- 设置飞机
			self:setBattleEquip(5,stats.m[1])
		end
		-- 超级武器飞机
		if stats.w then
			self:setBattleEquip(20,stats.w[1])
		end
	end
end

--更新研究值数据
function planeVoApi:updateStudyPoint()
	local nscfg = self:getNewSkillCfg()
	local point = self.study.v or nscfg.useCostLimit
	if self.study.t and self.study.t > 0 and point < nscfg.useCostLimit then
		local returnSpeed = self:getStudyPointReturnSpeed()
		local addPoint = math.floor((base.serverTime - self.study.t) / returnSpeed)
		if addPoint > 0 then --如果按照恢复速度矫正一下更新时间戳和研究值
			self.study.t = self.study.t + addPoint * returnSpeed
			self.study.v = point + addPoint
		end
		if self.study.v > nscfg.useCostLimit then --累计增加的研究值不能大于最大值
			self.study.v = nscfg.useCostLimit
		end
	end
end

--获取能量点回复速度
function planeVoApi:getStudyPointReturnSpeed()
	local nscfg=self:getNewSkillCfg()
	local rs = nscfg.returnSpeed

	local drate = planeRefitVoApi:getSkvByType(56)
	rs = rs * (1 - drate)

	return rs
end

--战机改装刷新回调
function planeVoApi:planeRefitHandler(skvtype)
	local lastSkv = planeRefitVoApi:getSkvByType(skvtype)
	local skv = planeRefitVoApi:getSkillAttribute(skvtype)
	-- print("skvtype,lastSkv,skv===>",skvtype,lastSkv,skv)
	if lastSkv ~= skv then --技能属性发生变化先用老的技能属性结算一下
		if skvtype == 56 then --战机革新研究值回复
			planeVoApi:updateStudyPoint()
		elseif skvtype == 61 then --体力恢复
			superWeaponVoApi:setCurEnergy(true)
		elseif skvtype == 62 then --能量恢复
		elseif skvtype == 63 then --叛军行动力恢复
			rebelVoApi:getRebelEnergy(true)
		end

		planeRefitVoApi:setSkvByType(skvtype, skv) --同步技能属性

		if skvtype == 62 then
			--能量恢复改为后端同步了，所以类型为62的代码逻辑注释掉
		elseif skvtype == 66 then -- 采集金币上限
			goldMineVoApi:setRefreshGemsFlag(true)
		end
	end
end

--战机革新技能研究消耗资源的buff加成
function planeVoApi:getSkillStudyResCostBuff()
	local rate = planeRefitVoApi:getSkvByType(57)
	return rate
end

function planeVoApi:getSkillNumsAndPlanePower()
	local allPowers = 0
	local nums1,nums2 = 0,0--紫色，橙色 技能数量
	for k,vo in pairs(self.planeList) do
		local cfg=self:getPlaneCfgById(vo.pid)
		if cfg then
			local strengthV=vo:getStrength()	
			allPowers = allPowers + strengthV
		end

		for kk,vv in pairs(vo.aSkillTb) do
			local scfg,gcfg = self:getSkillCfgById(vv)
			if gcfg then
				if gcfg.color == 4 then
					nums1 = nums1 + 1
				elseif gcfg.color == 5 then
					nums2 = nums2 + 1
				end
			end
		end

		for kk,vv in pairs(vo.pSkillTb) do
			if vv ~= 0 then
				local scfg,gcfg = self:getSkillCfgById(vv)
				if gcfg then
					if gcfg.color == 4 then
						nums1 = nums1 + 1
					elseif gcfg.color == 5 then
						nums2 = nums2 + 1
					end
				end
			end
		end
	end
	return nums2,nums1, allPowers
end