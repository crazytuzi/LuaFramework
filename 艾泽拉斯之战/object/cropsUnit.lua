
local actorManager = LORD.ActorManager:Instance()

function  ___targertHurtEnd(self)
	--[[
	do
		return true
	end	
	--]]--
	if( self and self.m_Targets ~= nil)then
		--[[
		if(self.__time == nil)then
			 self.__time = dataManager.getServerTime()
		end	
		if(dataManager.getServerTime() - self.__time >= CHECK_LOCK_TIME)then
				print("@@@@@@@@@@@@##################################-----!!!!------!!!!!")
				dump(self.m_Targets)
				for i,v in pairs (self.m_Targets)do		
					if( v~= nil  and v.HIT_CALLBACK_FINISH > 0)then					
						v:enterStateIdle()
					end									
				end	
				self.__time = nil		
		end 		
		]]---
		for i,v in pairs (self.m_Targets)do		
				if( v~= nil  and v.HIT_CALLBACK_FINISH > 0)then					
					--print("___targertHurtEnd index "..self.index.." v.HIT_CALLBACK_FINISH "..v.HIT_CALLBACK_FINISH.." v.index "..v.index);
					return false
				end									
		end		
	end		
	return true
end


function __directDanmage(caster, addAoeAtt)
	for i, v in pairs(caster.m_Targets) do
		if(v ~= nil)then
			v.callbackindex = 1
			v.callbacknum = 1		
			v.hurtSourceActor  = sceneManager.battlePlayer():getCropsByIndex(caster.m_TargetsDamage[i].target.casterId);				
			if not v.hurtSourceActor then
				v.hurtSourceActor = caster;
			end
			v:enterStateHurt(caster.m_TargetsDamage[i], addAoeAtt == true)												 
		end								
	end						
end	

function __onTargetDanmage(self,tcropsUnit,callbackindex,callbacknum )
	local cur = nil
	
	
	 print("__onTargetDanmage 1 callbackindex: "..callbackindex)
	for i, v in pairs(self.m_Targets) do
		if(v == tcropsUnit)then
			v.callbackindex = callbackindex
			v.callbacknum = callbacknum		
			v.hurtSourceActor  = self	
			cur = i			
				 print("__onTargetDanmage 2")
			v:enterStateHurt(self.m_TargetsDamage[i],false)							
				for k,m in pairs(self.m_Targets) do	
					if(m ~= nil and k ~= cur)then
					print("__onTargetDanmage 3")
						m.callbackindex = callbackindex
						m.callbacknum = callbacknum		
						m.hurtSourceActor  = self
						m:enterStateHurt( self.m_TargetsDamage[k],self.skillIsAoe == true)	
					end								
				end			
															
			return  
		end								
	end				
end	

function _onKingCastDamage(caster, callbackindex,callbacknum)
	
	for i, v in pairs(caster.m_Targets) do
			v.callbackindex = callbackindex;
			v.callbacknum = callbacknum
			v.hurtSourceActor  = caster
			v:enterStateHurt(caster.m_TargetsDamage[i],caster.skillIsAoe == true);
	end
end

kingClass = class("kingClass")

function kingClass:_init()
	
end

kingClass.INDEX_DEFAULT = 1000
kingClass.INDEX_CASTER_KING = 1001;
kingClass.INDEX_TARGET_NULL = 1002;

function kingClass:ctor(actor,skill,uiActor)
	 self:_init()
	 skill = skill or "idle"
	 uiActor = uiActor or false   
	 self.actor = actorManager:CreateActor(actor, "", uiActor)
	 self.index = kingClass.INDEX_DEFAULT
	 self.force = 1;
end
function kingClass:getActor()
		return  self.actor
end
function kingClass:enterSkill(t)
	skillSys.Play(self,t)	
 
	
end

function kingClass:logic(t)
	 return skillSys.OnTick(t)	and  ___targertHurtEnd(self)
end

function kingClass:initKing()
	self.m_name = "king"

	self.actor:SetPosition(LORD.Vector3(0, 5, 0));
			
	self.m_Targets = {}	
	self.m_TargetsDamage = {}	

end

function kingClass:release()
	if(self.actor ~= nil)then
		actorManager:DestroyActor(self.actor)
		self.actor  = nil
	end
end

function  kingClass:enterStateIdle()
end	

function   kingClass:setIndex(index)
	self.index = index;
	self.actor:SetUserData(self.index)			
end	

function kingClass:reviveTarget(_target)
	sceneManager.battlePlayer().m_AllCrops[_target.target]:enterStateRevive(_target)	
end


local cropsUnit = class("cropsUnit")
--cropsUnit.s_initq = -0.35 
cropsUnit.s_initq = 0;
cropsUnit.MAX_SKILL = 16
cropsUnit.WAIT_PALY_DEAD = true
cropsUnit.__MIRROE_ = false

local STIRPS =
{
 Humans = 0,
 Orcs =1,
 NE =2,
 UD = 3,
 OTHER =4
}

--人兽暗夜不死特殊


--军团伤害类型
local DAMAGETYPE = {
	DT_Physics = 1,
	DT_Magic = 2,
}

local CROPSSTATE ={
	 CS_IDLE  = 1 ,--待机
	 CS_LOCKED = 2 ,--卡死	
	 CS_MOVING = 3 ,--移动
	 CS_ATTACK = 4 ,--攻击
	 CS_DEAD = 5 ,--死亡	
	 CS_WIN = 6 ,--胜利
	 CS_SKILL = 7 ,--技能
	 CS_HURT = 8 ,-- 被扁
	 CS_HANDLBUFFER = 9 ,--   handler buffer
	 CS_DELBUFFER = 10 ,-- del buffer
	 CS_MOVE_SPECIAL = 11, -- 特殊移动
	 CS_REVIVE = 12,  --被复活
	 CS_TURNBACK = 13,  --转身
}

local CS_MOVING_STATE ={
	up = 0,
	run = 1,
	flying = 2,
	down = 3,
	tp_pre = 4,
	tp_ing = 5,
	tp_end = 6
}

function cropsUnit:ctor(_actor,skill,uiActor, createdActor)
	 self:_init()
	 self._____skill = skill or "idle"
	 self._____uiActor = uiActor or false   
	 self._____actor = _actor
	 
	 if createdActor then
	 	self.actor = createdActor;
	 else
	 	self.actor = actorManager:CreateActor( self._____actor, self._____skill, self._____uiActor);
	 end
	
	self.backupActor = nil;
	
	local t = tolua.getpeer(cropsUnit)		
	local t1 = tolua.getpeer( self.actor)
	
	 
end

function cropsUnit:release()
	if(self.actor ~= nil)then
		actorManager:DestroyActor(self.actor)
		self.actor  = nil		
	end
	
	if(self.backupActor ~= nil)then
		actorManager:DestroyActor(self.backupActor)
		self.backupActor  = nil		
	end
		
	LORD.GUIWindowManager:Instance():DestroyGUIWindow(self.headInfoUI);
	LORD.GUIWindowManager:Instance():DestroyGUIWindow(self.soldierHeadTip);
	if(self.soldierHpUi)then
		LORD.GUIWindowManager:Instance():DestroyGUIWindow(self.soldierHpUi);
		self.soldierHpUi = nil
	end
	self.soldierHeadTip = nil
	self.headInfoUI = nil;
	self.bufferList = nil;
	self.buffIDCounter = nil;
	--print("cropsUnit:release");
	self.bufferHandData = nil
	self.bufferDelList = nil
end

local ATTR_STATUS_TYPE = 
{
	ATTR_STATUS_TYPE_INVALID = -1,
	ATTR_STATUS_TYPE_ATTR = 0,
	ATTR_STATUS_TYPE_ATTR_PERCENT = 1,
	ATTR_STATUS_TYPE_STATUS = 2,
	ATTR_STATUS_TYPE_SPECIAL_EFFECT =3,
};

function cropsUnit:getActor()
		return  self.actor
end

function cropsUnit:changeActor(actorName)
	
	-- 备份起来
	if(self.actor == nil)then
		return;
	end
	
	self.backupActor = self.actor;
	self.backupActor:setActorBackup(true);
	
	self.actor = actorManager:CreateActor( actorName, "idle", 0, false, true, true);
	if self.actor and self.backupActor then
		self.actor:SetPosition(self.backupActor:GetPosition());
		self.actor:SetUserData(self.backupActor:getUserData());
		self.actor:SetScale(self.backupActor:GetScale());
		self.actor:SetOrientation(self.backupActor:GetOrientation());
	end
end

function cropsUnit:restoreActor()
	

	if(self.actor == nil or self.backupActor == nil )then
		return;
	end

	self.backupActor:SetPosition(self.actor:GetPosition());
	self.backupActor:SetUserData(self.actor:getUserData());
	self.backupActor:SetScale(self.actor:GetScale());
	self.backupActor:SetOrientation(self.actor:GetOrientation());

	actorManager:DestroyActor(self.actor);
	self.actor = self.backupActor;
	self.actor:setActorBackup(false);
	
	if self.m_bAlive == false then
		self:getActor():SetActorTranslateAlpha(0.0);
	else
		self:getActor():SetActorTranslateAlpha(1.0);
	end
	
end

function cropsUnit:_init()
  
  self.ejectionHit = false;
  
  self.actor = nil
	--dead状态下需要的参数
	self.m_bFade = false				--被杀死了
	self.m_bPlayedOverTime =0			--播放死亡    
	self.m_bPlayedDeadOver = false		--开始死亡动画播放完毿
	self.m_bFadeTime = 0				--消隐时间
	
	--attack状态下需要的参数
	self.m_bPlayedAttack = false		--是否出手
	self.m_AttackPlayedTime = 0			--剩余时间	
	self.m_attackSteerAngle = 0			--剩余的转角比
	self.m_attackSteerLeft = false		--左转还是右转
	self.m_bAttackSteering = false		--是否需要转躿
	
	--Locking状态下需要的敿	
	self.m_bLockRightFirst = false  --先右转还是左轿
	self.m_LockingTimes = 0			--如何轿可配罿
	self.m_InnerLockingTimes = 0		
	self.m_LockAngle = 0				--最大角庿可配罿
	self.m_innerLockAngle = 0			--当前角度
	self.m_savedAngle = 0				--记住当前角度
	
	--Moving状态下需要的数据		
    self.m_PathIdx = 0	
	self.m_pathArray  = nil
	self.m_movingX = 0				--下一格x
	self.m_movingY = 0				--下一格y
	self.m_movingPos = LORD.Vector3(0,0,0)		 --移动到下一格的位置
	self.m_movingDir = LORD.Vector3(0,0,0)	 --移动方向
	self.m_movinglength = 0				--需要移动多长距禿
	self.m_movedlength = 0			--已经移动了多少距禿
	self.m_steerAngle = 0			--剩余的转角比便仍需转身多少
	self.m_steerLeft = false				--左转还是右转
	self.m_bSteering = false				--是否需要转躿
	self.m_bFirstSteering = false			--是否需要先转身

	-- 需要服务器同步的属性表
	self.attribute ={}
	self.attribute[ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_ATTR] = {
		[enum.UNIT_ATTR.UNIT_ATTR_SPEED] = 0,
		[enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP] = 0,
	};
	
	self.attribute[ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_SPECIAL_EFFECT] = {	
		[enum.BUFF_SPECIAL_EFFECT.BUFF_SPECIAL_EFFECT_MOVE_TYPE] = nil,
	};	
	
	--以下属性为控制角色表现需汿
	self.m_CropsNum = 0					--军团人数
	self.m_bAttacker = enum.FORCE.FORCE_INVALID				--进攻斿
	self.m_PosX = 0						--格子坐标
	self.m_PosY= 0								--格子坐标
	self.m_State = 	 CROPSSTATE.CS_IDLE			--军团状怿
	self.m_Postion = LORD.Vector3(0,0,0) --世界坐标	
	self.m_BaseAngle = 0				--基准角度
	self.m_Angle = 0				--当前角度	
	self.m_Targets = {} 			--目标对象
	self.m_TargetsDamage = {}  -- 伤害列表
	self.m_bAlive = true			--是否存活	
	self.m_upTime = 0;
	self.m_downTime = 0;
	-- 计算行动序列的时间
	self.m_leftTime = 0;
	
	self.m_tpPreTime = 0;
	self.m_tpEndTime = 0;
	self.m_tpIngTime = 20;
	
	self.m_bPlayedHited= false			--受击动作时间   
	self.m_bPlayedHitTime = 0			--受击动作时间   
    self.HIT_CALLBACK_FINISH = 0	
	self.charmed = false --被媚惑
	
	self._beHurtData = {}
 
	self.callbackindex = 1
	self.callbacknum = 1
	self.hurtSourceActor = nil
	self.bufferList = nil
	self.buffIDCounter = nil;
	self.bufferHandData = nil
	self.bufferDelList = nil
	self.stateFinish = false
	
	self.chuanCiState = enum.UNIT_CHUANCI_STATE.NONE;
end

function cropsUnit:isCharmed()
	return self.charmed;	
end	

function   cropsUnit:setIndex(index)
	self.index = index
	self:getActor():SetUserData(self.index)			
end	

function cropsUnit:resetRoundTime()
	self.m_leftTime = self.m_roundTime;
end

function cropsUnit:getAttribute(attrType)
	if self.attribute and self.attribute [ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_ATTR] then
		return self.attribute[ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_ATTR][attrType];
	end		
	return nil;
end


 
function cropsUnit:setAttribute(attrType, attrValue)
	print("cropsUnit:setAttribute attrType "..attrType.." attrValue "..attrValue);
	if self.attribute  and attrType then
		local t = self.attribute[ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_ATTR]
		if t and t [attrType] then
			print("22  cropsUnit:setAttribute t[attrType] "..t[attrType]);
			if t[attrType] ~= attrValue then 
				local oldValue = t[attrType];
				t[attrType] = attrValue;
				self:onAttributeChange(attrType, attrValue, oldValue);
			end
		else
			--print("cropsUnit:setAttribute error attr does not exist! "..attrType);
			if t then
				t[attrType] = attrValue;
			end
		end
	end
end

function cropsUnit:onAttributeSpecialChange(attrType, attrValue)
 
	if attrType == enum.BUFF_SPECIAL_EFFECT.BUFF_SPECIAL_EFFECT_MOVE_TYPE then
		self.m_moveType = 	attrValue		
	end
end	
 
function cropsUnit:setSpecialAtt(attrType, attrValue)
	if self.attribute  and attrType then
		local t = self.attribute[ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_SPECIAL_EFFECT]
		if t then
			if t[attrType] ~= attrValue then 
				t[attrType] = attrValue;
				self:onAttributeSpecialChange(attrType, attrValue);
			end
		else
			print("cropsUnit:setSpecialAtt error attr does not exist! "..attrType);
		end
	end
end

function cropsUnit:setAttributeAll( typeIndex,attrType, attrValue)
	 	
	if  typeIndex == ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_ATTR  then 		
		self:setAttribute(attrType, attrValue);
	elseif  typeIndex == ATTR_STATUS_TYPE.ATTR_STATUS_TYPE_SPECIAL_EFFECT  then 		
	
		self:setSpecialAtt(attrType, attrValue);
	end

end

function cropsUnit:onAttributeChange(attrType, attrValue, oldValue)
	local typeMap = enum.UNIT_ATTR;
	print("cropsUnit:onAttributeChange"..attrType.." value "..attrValue.."typeMap[UNIT_ATTR_SPEED] "..typeMap.UNIT_ATTR_SPEED);
	if attrType == typeMap.UNIT_ATTR_SPEED then
		
		local oldTime = math.floor(enum.TIME_UNIT / oldValue);
		local newTime = math.floor(enum.TIME_UNIT / attrValue);
		self.m_leftTime = self.m_leftTime + newTime - oldTime;
	
		self.m_roundTime = math.floor(enum.TIME_UNIT / attrValue);
		
		if sceneManager.battlePlayer().unitInstanseInitOK then
			-- 初始化过程中的变化，不刷新行动序列
			-- 更新行动序列
			local uiupdate = sceneManager.battlePlayer():calcAllActionOrder(false);
			sceneManager.battlePlayer().m_UiOrderTranslationed = false;
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_UNIT_INFO})
		end
			
	elseif attrType == typeMap.UNIT_ATTR_SOLDIER_HP then
		print("cropsUnit:onAttributeChange oldValue "..oldValue);
		if self.m_TotalHP and self.m_TotalHP <= 0 then
			return;
		end
		
		if oldValue ~= 0 then
			self.m_currentSoldierHP = math.floor(self.m_currentSoldierHP * attrValue / oldValue);
			self.m_TotalHP = math.floor(self.m_TotalHP * attrValue / oldValue );
			if self.m_TotalHP <= 0 then
				self.m_TotalHP = 1;
			end
			
			print("cropsUnit:onAttributeChange hp index "..self.index.." hp "..self.m_TotalHP);			
		end
	end
end

-- 总血量改变接口 ignoreUnitNumChange 是否忽略骷髅头
function cropsUnit:changeTotalHP(value, fontName, ignoreUnitNumChange)
	if(value == 0)then
		return 
	end
	local newFontName = "";
	if fontName == nil then
		newFontName = "damage";
		if value > 0 then
			newFontName = "healnum";
		elseif value < 0 then
			newFontName = "damage";
		end
	else
		newFontName = fontName;
	end
	
	battleText.addHitText(tostring(value), self.index, newFontName);
	
	scheduler.performWithDelayGlobal(function ()
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_UNIT_HP_CHAGE,arg1 = value })
	end, 0.5);

	
	
	print("cropsUnit:changeTotalHP index "..self.index.." value "..value);
	local totalHP = math.floor(self.m_TotalHP + value);
	self:setTotalHP(totalHP, ignoreUnitNumChange);
end

function cropsUnit:getTotalHP()
	return self.m_TotalHP;
end

function cropsUnit:getMaxHP()
	return self:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP) * self.m_TotalCropsNum;
end

function cropsUnit:getHPPercent()
	return self:getTotalHP()/self.MaxSoldierHP   
end

function cropsUnit:getUnitNum()
	return self.m_CropsNum;
end

function cropsUnit:setTotalHP(value, ignoreUnitNumChange)
	print("cropsUnit:setTotalHP index "..self.index.." value "..value);
	local oldHp = self.m_TotalHP 
	local oldUnitNum = self.m_CropsNum;
	self.m_TotalHP = value;
	local soldierHP = self:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP);
	self.m_CropsNum = math.ceil(self.m_TotalHP / soldierHP);
	
	-- -0的处理
	if self.m_CropsNum <= 0 then
		self.m_CropsNum = 0;
	end
	
	self.m_currentSoldierHP = math.fmod(self.m_TotalHP, soldierHP);
	
	if ignoreUnitNumChange ~= true then
		local unitCountChange = self.m_CropsNum - oldUnitNum;
		
		battleText.changeUnitNum(unitCountChange, self.index);
		--延迟触发伤害事件
		function  delay_unit_hp_call ()
			--unitCountChange
		end
		scheduler.performWithDelayGlobal(delay_unit_hp_call, 0.2)
	end
	
	--self.headInfoUI:SetText(self.m_CropsNum);
	if(self.headInfoUI)then
		self.headInfoUI:SetText(oldUnitNum);
	end
	local __unitCountChange = self.m_CropsNum - oldUnitNum

	local _rTime = 0.4  --军团数量改变时长
	
	
	function headInfoUIHandleTimeTick(dt)
		
		self._dt = self._dt or 0
		self._dt = self._dt + dt
	
		if(self._dt >= _rTime)then
			scheduler.unscheduleGlobal(self.headInfoUIHandle);
			self.headInfoUIHandle = nil;
			self._dt = nil
			if self.headInfoUI then
				self.headInfoUI:SetText(self.m_CropsNum);
			end
			if(	self.soldierHpUi)then
				local allHp = self:getMaxHP()
				local hp = self:getTotalHP() 
				if(allHp == 0)then
					hp = 0
				end
				self.soldierHp_pro:SetProperty("Progress", hp/allHp)
			end
			return
		end

		if(	self.soldierHpUi)then
				local allHp = self:getMaxHP()
				local hp = oldHp + ( self.m_TotalHP -oldHp )* self._dt/_rTime 
				if(allHp == 0)then
					hp = 0
				end
				self.soldierHp_pro:SetProperty("Progress", hp/allHp)
		end
		
		local result = 0
		if(__unitCountChange > 0)then
			  result =  math.ceil(oldUnitNum + self._dt/_rTime * __unitCountChange)
		else
			  result =  math.floor(oldUnitNum + self._dt/_rTime * __unitCountChange)
		end
		
		if self.headInfoUI then
			self.headInfoUI:SetText(result);
		end
	 
		--[[
		local result = __calcValueChange(oldUnitNum, self.m_CropsNum,0.15);
		if result == -1 then
	
			if self.headInfoUIHandle then
				scheduler.unscheduleGlobal(self.headInfoUIHandle);
				self.headInfoUIHandle = nil;
			end
			self.headInfoUI:SetText(self.m_CropsNum);
		else
			oldUnitNum = result; 
			self.headInfoUI:SetText(result);
		end
		]]--
	end		
	  
	if(self.headInfoUIHandle ~= nil)then
		scheduler.unscheduleGlobal(self.headInfoUIHandle)
		self.headInfoUIHandle = nil
	end
	if(self.headInfoUIHandle == nil)then
		self.headInfoUIHandle = scheduler.scheduleGlobal( headInfoUIHandleTimeTick,0)
	end	
end




function cropsUnit:isAttacker()
	return self.m_force == enum.FORCE.FORCE_ATTACK	
end

function cropsUnit:isFriendlyForces()
	return self.m_force == battlePlayer.force	
end

function cropsUnit:getForces()
	return self.m_force
end

function cropsUnit:getUnitID()
	return self.m_ID;
end

-- 船的属性
function cropsUnit:setShipAttr(shipAttrEnum, shipAttrValue)
	self.shipAttr[shipAttrEnum] = shipAttrValue;
end

function cropsUnit:getShipAttr(shipAttrEnum)
	return self.shipAttr[shipAttrEnum];
end


function cropsUnit:getStarLevel()
		return self.starLevel
end	

function cropsUnit:initCrops(cropsid, xpos, ypos, soldiercount, force, unitIndex)
 	
 	self:setIndex(unitIndex);
 	self.shipAttr = {};
 		
	local config =  cropData:getCropsGonfig(cropsid)
	
	self.m_ID = config.id 	  --军团ID
	self.m_name = config.name --军团名称	
	self.m_Race = config.race --种族
	self.m_CropsNum = soldiercount or config.basenum --数量基数
	self.m_TotalCropsNum = soldiercount;
	--self.m_soldierHP = config.soldierHP  -- 单兵生命
	self.m_currentSoldierHP = config.soldierHP;
	self.starLevel = config.starLevel
	self.MaxSoldierHP = self.m_currentSoldierHP*soldiercount
	
	self.m_Defense = config.defence         -- 护甲
	self.m_isRange   = config.isRange             --是远程军囿
	self.m_DamageType =  config.damageType --伤害类型
	self.m_soldierDamage = config.soldierDamage     --单兵攻击势
	self.m_AttackRange = config.attackRange 	--攻击距离	
	self.m_moveType = config.moveType    --移动类型 陆地 飞行 闪烁
	--self.m_ActionSpeed =  config.actionSpeed--行动速度
	self:setAttribute(enum.UNIT_ATTR.UNIT_ATTR_SPEED, config.actionSpeed);
	self.m_leftTime = self.m_roundTime;
	self.m_moveRange = config.moveRange        	--一次行动能移动几格
	self.m_Desc = config.text	--描述	
	self.m_ActorResourceName = config.resourceName --Actor模型
	self.m_ActorMirrorResourceName = config.mirrorActor  --Actor模型
	self.m_Icon = config.icon --图标
	self.m_Card = config.card --卡牌		
	self.m_movingSpeed = config.movingSpeed	--移动速度
 	self.m_actorRunSpeed = config.actorRunSpeed --移动动画播放速度 引擎播放行走动画的时间缩放比
	self.m_steeringSpeed = config.steerSpeed/180 * math.PI --转身速度	
	self.modelScaling = config.modelScaling				--模型缩放
 	self.hp = 1
	self.criticalAttackName = config.criticalAttackName;
	
	self.m_Color = LORD.Color.WHITE 	--模型附加颜色
	
	if(config.colorR ~= -1)then
		self.m_Color.r = config.colorR/255
	end
	if(config.colorG ~= -1)then
		self.m_Color.g = config.colorG/255
	end
	if(config.colorB ~= -1)then
		self.m_Color.b = config.colorB/255
	end	
 
	self.m_SkillID = config.skill;
  
	self.m_PosX = 	xpos
	self.m_PosY = 	ypos	
	self.m_force = force	
	
	if(not self:isAttacker())then	
		if( self.m_ActorMirrorResourceName ~= nil)then
			if( self.actor ~= nil)then
				actorManager:DestroyActor(self.actor)
			end				
			 self.actor = actorManager:CreateActor( self.m_ActorMirrorResourceName, self._____skill, self._____uiActor)	
			 self:setIndex(self.index)
		end			
	end		
	
	-- 服务器同步相关属性
	self:setAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP, config.soldierHP);
	local soldierHP = self:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP);
	self.m_TotalHP = math.floor(self.m_CropsNum * soldierHP);
 
	self.m_Angle = 0	
	self.m_Postion =  sceneManager.battlePlayer():getWorldPostion(self.m_PosX , self.m_PosY)	
	
	--print("self.m_PosX "..self.m_PosX.." self.m_PosY "..self.m_PosY);
	
	self.m_bFade = false	
	self.m_bAlive = true
	self.m_PathIdx = 0
	self.m_steerLeft = true
	self.m_bSteering = false
	self.m_bFirstSteering = false
	self.m_bLockRightFirst = true
	self.m_bPlayedAttack = false
	self.m_attackSteerLeft = true
	self.m_bAttackSteering = false
	self.m_bPlayedDeadOver = false
	
	self:getActor():SetPosition(self.m_Postion)	
	
	if( false == self:isAttacker())then
		self.m_Angle = math.PI
		
		
		local  showangle =  0		
		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   self.m_Angle	
			else
				showangle =   self.m_Angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =    self.m_Angle - math.PI		
			else
				showangle =   self.m_Angle		
			end						
		end				
		
		self.m_BaseAngle = -math.PI_DIV2		
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)		
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)				
	    self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))	
	else
		self.m_Angle = 0	
		local  showangle =  0		
		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   self.m_Angle	
			else
				showangle =   self.m_Angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =    self.m_Angle - math.PI		
			else
				showangle =   self.m_Angle		
			end						
		end				
		self.m_BaseAngle = math.PI_DIV2
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
		
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)	
		self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))	
	     			
	end
	

	
	 
	
	
	if(cropsUnit.__MIRROE_)then		
	 self:getActor():SetMirror( not self:isAttacker())
	end
	
	
 	 self:getActor():SetScale(LORD.Vector3( self.modelScaling,self.modelScaling,self.modelScaling))		
	 self:getActor():SetAmbientColor(self.m_Color)	
   self.stateHandler = {}
   self.stateEndHandler = {};
     
   self.stateHandler[CROPSSTATE.CS_IDLE]    =  self.onStateIdle 
	 self.stateHandler[CROPSSTATE.CS_LOCKED]  =  self.onStateLocked
	 self.stateHandler[CROPSSTATE.CS_MOVING]  =  self.onStateMoving
	 self.stateEndHandler[CROPSSTATE.CS_MOVING]  =  self.onStateMovingEnd;
	  
	 self.stateHandler[CROPSSTATE.CS_ATTACK]  =  self.onStateAttack	 
	 self.stateHandler[CROPSSTATE.CS_DEAD]    =  self.onStateDead
	 self.stateEndHandler[CROPSSTATE.CS_DEAD]    =  self.onStateDeadEnd
	 
	 self.stateHandler[CROPSSTATE.CS_WIN]     =  nil	
	 self.stateHandler[CROPSSTATE.CS_SKILL]    =  self.onStateSkill
	 self.stateHandler[CROPSSTATE.CS_HURT]    =  self.onStateHurt
	
	 self.stateHandler[CROPSSTATE.CS_HANDLBUFFER]    =  self.onStateHandlerBuffer
	 self.stateHandler[CROPSSTATE.CS_DELBUFFER]    =  self.onStateDelBuffer
	 self.stateHandler[CROPSSTATE.CS_MOVE_SPECIAL]  =  self.onStateMoveSpecial 
	self.stateEndHandler[CROPSSTATE.CS_MOVE_SPECIAL]  =  self.onStateMoveSpecialEnd;
	
	self.stateHandler[CROPSSTATE.CS_REVIVE]  =  self.onStateRevive 
	
	self.stateHandler[CROPSSTATE.CS_TURNBACK]  =  self.onStateTrunBack
	
	
	self.headInfoUI = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("headInfoUI-"..self.index, "soldiernum.dlg");
	
	self.soldierHeadTip = LORD.toStaticText(LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("headInfoUI-"..self.index, "soldierHeadTip.dlg"));
	
	if (config.isDisplayHp == true )then
		self.soldierHpUi = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("headInfoUI-"..self.index, "bossHP.dlg");
		self.soldierHpUi:SetVisible(false);
		engine.uiRoot:AddChildWindow(self.soldierHpUi);
		self.soldierHp_pro = LORD.GUIWindowManager:Instance():GetGUIWindow("headInfoUI-"..self.index.."_bossHP-bar")
	end

	self:setUnitNumColor(self:isFriendlyForces());
	
	self.headInfoUI:SetVisible(false);
	self.soldierHeadTip:SetVisible(false); 
	engine.uiRoot:AddChildWindow(self.headInfoUI);
	engine.uiRoot:AddChildWindow(self.soldierHeadTip);
	self.headInfoUI:SetText(self.m_CropsNum);
	self.soldierHeadTip:SetText("")
	
	self.bufferList = {}
	
	-- 同一个buffid的引用计数
	self.buffIDCounter = {};
	 
	self.bufferHandData  = {} 
	self.bufferDelList = {}	
	self:enterStateIdle()
	self.isHide = false		
end

function cropsUnit:addBuffIDReference(buffID)
	self.buffIDCounter = self.buffIDCounter or {};
	self.buffIDCounter[buffID] = self.buffIDCounter[buffID] or 0;
	self.buffIDCounter[buffID] = self.buffIDCounter[buffID] + 1;
end

function cropsUnit:subBuffIDReference(buffID)
	if self.buffIDCounter and self.buffIDCounter[buffID] then
		self.buffIDCounter[buffID] = self.buffIDCounter[buffID] - 1;
		return self.buffIDCounter[buffID];
	end
	
	return 0;
end

function cropsUnit:getBuffIDReference(buffID)
	self.buffIDCounter = self.buffIDCounter or {};
	self.buffIDCounter[buffID] = self.buffIDCounter[buffID] or 0;
	
	return self.buffIDCounter[buffID];
end

function cropsUnit:isSummonUnit()
	return  self.isSummoned == true
end

function cropsUnit:setUnitNumColor(frindle)
	if frindle == true then
		self.headInfoUI:SetProperty("Font", "armynum");
	else
		self.headInfoUI:SetProperty("Font", "enemynum");
	end
end

function cropsUnit:SetSummoned(s)
	  self.isSummoned = s
end

function cropsUnit:getBuffList()
	return self.bufferList;
end

function cropsUnit:onStateIdle()
	return true
end

function cropsUnit:onStateLocked(dt)
	local res = false
	local dtAngle = dt *0.001* self.m_steeringSpeed
	if(self.m_bLockRightFirst)then 	
		self.m_Angle = self.m_Angle - dtAngle	
	else		
		self.m_Angle = self.m_Angle + dtAngle
	end

	self.m_innerLockAngle = self.m_innerLockAngle  - dtAngle
	if(self.m_innerLockAngle < 0)then
	
		if(self.m_bLockRightFirst)then
				self.m_Angle = self.m_Angle - self.m_innerLockAngle;
		else
			self.m_Angle = self.m_Angle + self.m_innerLockAngle;
		end
				
		self.m_Angle = self.m_Angle + self.m_innerLockAngle
		self.m_innerLockAngle = self.m_LockAngle		
		if(self.m_InnerLockingTimes%2==0)then
			self.m_bLockRightFirst = not self.m_bLockRightFirst
		end			
		self.m_InnerLockingTimes = self.m_InnerLockingTimes +1				
		if(self.m_LockingTimes == self.m_InnerLockingTimes)then		
			self.m_Angle = self.m_savedAngle
			self:enterStateIdle()
			res  = true						
		end
	end  		
		local  showangle =  0		
		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   self.m_Angle	
			else
				showangle =   self.m_Angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =    self.m_Angle - math.PI		
			else
				showangle =   self.m_Angle		
			end						
		end					
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)			
	    self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))		
	 return res		
end	

function cropsUnit:IsActionFinish()
	
	return self.stateFinish == true
end	
function cropsUnit:IsDeadState()
	
	return  self.m_State == CROPSSTATE.CS_DEAD
end	


function cropsUnit:_onStateRunMoving(dt)
	
	 
		if (self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_PHANTOM)then
				dt = dt * 3;
		end		
	
	if(self.m_bSteering) then		
		local dtAngle = dt *0.001* self.m_steeringSpeed	
		if(self.m_steerLeft)then 	
			self.m_Angle = self.m_Angle + dtAngle		
		else			
			self.m_Angle = self.m_Angle - dtAngle
		end
		
		self.m_steerAngle = self.m_steerAngle  - dtAngle
		if(self.m_steerAngle < math.PI/3 and self.m_bFirstSteering) then
			self.m_bFirstSteering = false
			self:getActor():PlaySkill("run",false,false,1)	
		end
		
		if(self.m_steerAngle < 0) then
		
			if(self.m_steerLeft)then
				self.m_Angle = self.m_Angle + self.m_steerAngle;
			else
				self.m_Angle = self.m_Angle - self.m_steerAngle;
			end
			
			self.m_bSteering = false;
			self.m_steerAngle = 0;
			self:reDisAngle()
		end			
		local  showangle =  0				
		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   self.m_Angle	
			else
				showangle =   self.m_Angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =    self.m_Angle - math.PI		
			else
				showangle =   self.m_Angle		
			end						
		end		
		 
	
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)			
	    self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))				
	end
	if(not self.m_bFirstSteering)then	
 
		local dtDis = dt* 0.001*self.m_movingSpeed
		self.m_Postion =  LORD.Vector3.Add(self.m_Postion,LORD.Vector3.MulNum(self.m_movingDir,dtDis ))
		self.m_movedlength = self.m_movedlength + dtDis
		local res = false		
		if(self.m_movedlength >= self.m_movinglength)then		
			--到位
			
			sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")
			--print			(self.m_name.."move end   to  n")		
			
		
			self.m_Postion = self.m_movingPos
			self.m_PosX = self.m_movingX
			self.m_PosY = self.m_movingY				
			if(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_WALK	 )then																							
				res =  self:movingOnSetp()	
			elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_FLY)then					
				res = true 
			elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_PHANTOM)then		
				res =  self:movingOnSetp()
			end				
		end											 	
		self:getActor():SetPosition(self.m_Postion)
		return res
	end
	return false		
end	

function cropsUnit:_onStateRunFlying(dt)
	 return self:_onStateRunMoving(dt)	
end	

function cropsUnit:onStateMoving(dt)
	if(self.m_moveState == CS_MOVING_STATE.up)then
		self.m_upTime = self.m_upTime - dt
		if(self.m_upTime <=0 )then
			self:_enterFlying()			
		end
		return false		
	elseif(self.m_moveState == CS_MOVING_STATE.run)then		
		
		 return self:_onStateRunMoving(dt)		
	elseif(self.m_moveState == CS_MOVING_STATE.flying)then		
		 if(self:_onStateRunFlying(dt))then
			self:_doRunEnd()		
		 end		
		 return false		
	elseif(self.m_moveState == CS_MOVING_STATE.down)then
		self.m_downTime = self.m_downTime - dt
		if(self.m_downTime <=0 )then
			self:enterStateIdle()					
			sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")
			return true
		end
		return false			
	elseif(self.m_moveState == CS_MOVING_STATE.tp_pre)then
		self.m_tpPreTime = self.m_tpPreTime - dt
		if(self.m_tpPreTime <=0 )then		
			self.m_PathIdx = 1 -- table.nums(self.m_pathArray)
			self.m_movingX  = self.m_pathArray[self.m_PathIdx].x
			self.m_movingY  = self.m_pathArray[self.m_PathIdx].y	
			self.m_movingPos = sceneManager.battlePlayer():getWorldPostion(self.m_movingX,self.m_movingY )			
			self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos , self.m_Postion)
			self.m_movinglength = self.m_movingDir:len()
			self.m_movingDir:normalize()
			self.m_movedlength = 0			
			self.m_tpDisPerMSec = 1/self.m_tpIngTime * self.m_movinglength				
			self:_enterTpIng()								
		end	
		return false
	elseif(self.m_moveState == CS_MOVING_STATE.tp_ing)then
		self.m_tpIngTime = self.m_tpIngTime - dt
		if(self.m_tpIngTime <=0 )then
			 self:_enterTpEnd()		
			return true
		end	
		
		self.m_tpDisPerMSec = self.m_tpDisPerMSec * dt		
		self.m_Postion =  LORD.Vector3.Add(self.m_Postion,LORD.Vector3.MulNum(self.m_movingDir,self.m_tpDisPerMSec))									 						
		self:getActor():SetPosition(self.m_Postion)	
		return false		
	elseif(self.m_moveState == CS_MOVING_STATE.tp_end)then
		 self.m_tpEndTime = self.m_tpEndTime - dt
		if(self.m_tpEndTime <=0 )then
			self:enterStateIdle()		
			return true
		end		
		return false
	end		
	return false		
end

function cropsUnit:onStateMovingEnd(dt)
	self:onMoveEndCheckDamage();
end

function cropsUnit:onStateMoveSpecialEnd(dt)
	self:onMoveEndCheckDamage();
end

function cropsUnit:___doRunEnd()
	if(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_FLY)then	
		 self:_enterDown()		
	elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_WALK)then									
		self:enterStateIdle()	
	elseif(self.m_moveType ==enum.MOVE_TYPE.MOVE_TYPE_BLINK)then									
		self:_enterTpEnd()		
	elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_PHANTOM)then	
		self:getActor():SetActorTranslateAlpha(1.0)								
		self:enterStateIdle()		
	end	
end
function cropsUnit:_doRunEnd()
		
	if(self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_GOBACK )then
		local targetAngle = math.PI + self.m_Angle	
		self.m_attackSteerAngle ,self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,targetAngle)	
		self.m_bAttackSteering	 = true
	end
	self:___doRunEnd()
end
function cropsUnit:onStateTrunBack(dt)
	if(self:__AttacSteering(dt))then
		return true
	end
	return false
end	

function cropsUnit:__AttacSteering(dt)
	
	
	if(self.m_bAttackSteering)then
		local dtAngle =  dt*0.001*self.m_steeringSpeed
		if(self.m_attackSteerLeft)then
			self.m_Angle = self.m_Angle + dtAngle;
		else
			self.m_Angle = self.m_Angle - dtAngle;
		end
		
		self.m_attackSteerAngle = self.m_attackSteerAngle - dtAngle;
		
		if(self.m_attackSteerAngle < 0)then		
			
			if(self.m_attackSteerLeft)then
				self.m_Angle = self.m_Angle + self.m_attackSteerAngle;
			else
				self.m_Angle = self.m_Angle - self.m_attackSteerAngle;
			end
		 	
			self.m_bAttackSteering = false;
			self:reDisAngle()
			
			local  showangle =  0
			if(self:isAttacker())then		
				if(self.charmed  == false)then
					showangle =   self.m_Angle	
				else
					showangle =   self.m_Angle - math.PI		
				end						
			else			
				if(self.charmed  == false)then
					showangle =    self.m_Angle - math.PI		
				else
					showangle =   self.m_Angle		
				end						
			end			
			local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
			local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
			local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)			
			self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))			
			
			return true		
		 end
		
		local  showangle =  0
		
		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   self.m_Angle	
			else
				showangle =   self.m_Angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =    self.m_Angle - math.PI		
			else
				showangle =   self.m_Angle		
			end						
		end		
	 				
 				
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)			
	    self:getActor():SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))
		return false		
	end		
	return true
end
function cropsUnit:onStateAttack(dt)
		
	if(self.m_bAttackSteering)then --转完毕再攻击
		self:__AttacSteering(dt)	
		return false
	end		
		if(self.m_bPlayedAttack)then
			self.m_AttackPlayedTime = self.m_AttackPlayedTime - dt --不需要乘以scale亿因为playSkill返回的就是scale以后皿
			if(self.m_AttackPlayedTime < 0) then		
				self:enterStateIdle()
				return true
			end
		end					
	return false
end

function cropsUnit:onStateDead(dt)
	local res = true
	
	if(false == self.m_bFade)then
			self.m_bPlayedDeadTime  = self.m_bPlayedDeadTime - dt
			self.m_bFadeTime  = self.m_bFadeTime - dt	
			if(cropsUnit.WAIT_PALY_DEAD )then
				res = false					
			else
				res = true	
				self.HIT_CALLBACK_FINISH = 0	

				self.stateFinish = true
				--echoInfo("onStateDead  self.HIT_CALLBACK_FINISH %d = %d",self.index, self.HIT_CALLBACK_FINISH  )				

			end					
			if(self.m_bPlayedDeadTime <= 0 and  self.m_bFadeTime <=0  )then			
				self.m_bPlayedDeadOver = true
				self.m_bFade = true
				self:getActor():StartActorFadeOut()
				if self.backupActor then
					self.backupActor:StartActorFadeOut();
				end
				res = true	
				self.HIT_CALLBACK_FINISH = 0	

				self.stateFinish = true
				--echoInfo("onStateDead  self.HIT_CALLBACK_FINISH %d = %d",self.index, self.HIT_CALLBACK_FINISH  )								

			end				
	end
 
	return res
end

function cropsUnit:onStateDeadEnd(dt)

	if self.deadFlag == 1 then
		self:resetRoundTime();	
	
		self:onDeadDeleteBuff();
		
		self.deadFlag = nil;
	end
	
end

function cropsUnit:decrease_HIT_CALLBACK_FINISH()
		if(self.HIT_CALLBACK_FINISH >= 1)then
			self.HIT_CALLBACK_FINISH =  self.HIT_CALLBACK_FINISH  -1
		end				
end
function cropsUnit:enterStateIdle()
	self.stateFinish = true
	self.HIT_CALLBACK_FINISH = 0	
	--print(self.index.."idle  to  n   self.m_State "..self.m_State)
	self:getActor():PlaySkill("idle",false,false,1)	
	self.m_State = CROPSSTATE.CS_IDLE		
	sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")	
end

function cropsUnit:enterStateLocked()
	if self.m_moveRange ~= 0 then
		self.stateFinish = false
		self.m_bLockRightFirst =   false ---math.RandomRange(0,1 ) ~= 0
		self.m_LockingTimes = 4
		self.m_InnerLockingTimes = 0
		self.m_LockAngle = math.PI/3
		self.m_innerLockAngle = self.m_LockAngle
		self.m_savedAngle = self.m_Angle
		self.m_State =  CROPSSTATE.CS_LOCKED	
	end
end
function cropsUnit:setMoveFlag(moveFlag)
	self.moveFlag = moveFlag
end	
function cropsUnit:enterStateMoving(t,skills)

	--print("enterStateMoving");
	--dump(skills);
	
	self.stateFinish = false	
	self.m_PathIdx = 0
	self.m_pathArray = t	
	self.moveHanlSkills = skills
	-- 伤害量备份起来，最后move结束的时候做个检查
	self.moveDamageList = {};
	for k,targets in ipairs(self.moveHanlSkills) do
		self.moveDamageList[k] = {};
		for kk, v in ipairs(targets) do
			self.moveDamageList[k][kk] = v.target.damage;
		end 
	end
	
	for i,v in ipairs (self.m_pathArray) do
		sceneManager.battlePlayer():signGrid(v.x,v.y,"b")
	end	
 
	if( self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_NORMAL or  self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_GOBACK ) then
	
		self.m_State = CROPSSTATE.CS_MOVING 
	
		if(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_FLY)then	
				 self:_enterUp()		
		elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_WALK)then					
				 self:_enterRun()
		elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_BLINK)then		
				 self:_enterTpPre()
		elseif(self.m_moveType == enum.MOVE_TYPE.MOVE_TYPE_PHANTOM)then		
				 self:getActor():SetActorTranslateAlpha(0.3)	
				 self:_enterRun()
		end
		
	else		
		self.m_State = CROPSSTATE.CS_MOVE_SPECIAL 	
		self.m_PathIdx = self.m_PathIdx + 1	
		
		self.m_movingX  = self.m_pathArray[self.m_PathIdx].x
		self.m_movingY  = self.m_pathArray[self.m_PathIdx].y		
		self.m_movingPos = sceneManager.battlePlayer():getWorldPostion(self.m_movingX,self.m_movingY )
		
		if( self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_REPEL ) then	
				self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos,self.m_Postion)
		elseif( self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_MEETHOOK ) then					
				self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos,self.m_Postion)		
		elseif( self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_TRANSFER ) then					
				self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos , self.m_Postion)		
		end				
		self.m_movinglength = self.m_movingDir:len()
		self.m_movingDir:normalize()
		self.m_movedlength = 0		
		self.SPECIAL_nums = math.floor(self.m_movinglength  /  battlePrepareScene.hexagonWidth);
		if self.SPECIAL_nums <= 0 then
			self.SPECIAL_nums = 1;
		end	
		self.SPECIAL_step = self.m_movedlength  /  battlePrepareScene.hexagonWidth
	end		
	
end

function cropsUnit:onMoveEndCheckDamage()
	
	if self.moveHanlSkills == nil then
		return;
	end
	
	-- 检查移动造成的伤害	
	local size = #(self.moveHanlSkills)	
	for i = 1 , size do		
		local paramTargets = self.moveHanlSkills[i];
				
		for k,v in ipairs(paramTargets) do
			if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then		
				local crops = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
				if self.moveDamageList[i][k] > 0 then
					crops:changeTotalHP(-self.moveDamageList[i][k]);
				end
			end
		end
		
	end
	
	self.moveHanlSkills  = nil;
	self.moveDamageList = nil;
end

function cropsUnit:onStateMoveSpecial(dt)

  if( self.m_PathIdx >  table.nums(self.m_pathArray) )then	
	   self:enterStateIdle()
	  return true
	end		
	
	
    local step  = self.m_movedlength  / battlePrepareScene.hexagonWidth	
	--print("onStateMoveSpecial step "..step.." self.m_movedlength "..self.m_movedlength.." self.SPECIAL_step "..self.SPECIAL_step.." self.SPECIAL_nums "..self.SPECIAL_nums);
	step = math.floor(step)
	if( step >= 1 and  step ~= self.SPECIAL_step  )then
			self.SPECIAL_step = step 
			self:__handleMovingSkill(step, math.floor(self.SPECIAL_nums));							
	end			
	
	local dtDis = dt* 0.001 * self.m_movingSpeed * 7	
	self.m_Postion =  LORD.Vector3.Add(self.m_Postion,LORD.Vector3.MulNum(self.m_movingDir,dtDis ))	
	self.m_movedlength = self.m_movedlength + dtDis
	
	--print("self.m_movinglength "..self.m_movinglength);
	
	local res = false		
	if(self.m_movedlength >= self.m_movinglength and step >= 1 )then	
			--print("cropsUnit:onStateMoveSpecial ");		
			sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")						
			self.m_Postion = self.m_movingPos
			self.m_PosX = self.m_movingX
			self.m_PosY = self.m_movingY	
			self:enterStateIdle();							
			
			if self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_MEETHOOK or
				self.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_HOLD_POSITION then
				self:getActor():RemoveSkillAttack("tufuA_rougou01.att");
			end
			
			res = true 				
	end												 	
	self:getActor():SetPosition(self.m_Postion)	
 
	return res	
end	



function cropsUnit:_enterRun()
		self.m_moveState = CS_MOVING_STATE.run	
		self:getActor():PlaySkill("run",false,false,self.m_actorRunSpeed)	
		self:movingOnSetp()
end

function cropsUnit:_enterUp()
	self.m_moveState = CS_MOVING_STATE.up
	self.m_upTime  = self:getActor():PlaySkill("up",false,false,1)	
end

function cropsUnit:_enterFlying()
	self.m_moveState = CS_MOVING_STATE.flying	
	self:getActor():PlaySkill("run",false,false,self.m_actorRunSpeed)	
		
	self.m_PathIdx = self.m_PathIdx + 1		
	self.m_movingX  = self.m_pathArray[self.m_PathIdx].x
	self.m_movingY  = self.m_pathArray[self.m_PathIdx].y	
	
	self.m_movingPos = sceneManager.battlePlayer():getWorldPostion(self.m_movingX,self.m_movingY )
	
	--根据移动速度算出时间	
	self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos , self.m_Postion)
	self.m_movinglength = self.m_movingDir:len()
	self.m_movingDir:normalize()
	self.m_movedlength = 0
	---获取转身角度 当前先转身，后移动一格，然后转身，再移动.
	
	local targetAngle = self:gettoTargetAngle(self.m_movingPos)
	self.m_steerAngle, self.m_steerLeft = self:caculateSteering(self.m_Angle,targetAngle)
	
	if(self.m_steerAngle < math.PI_DIV2)then
		self.m_bFirstSteering = false	
		if(self.m_steerAngle <0.0001)then
			self.m_bSteering = false
		end				
	else 			
		self.m_bFirstSteering = true
		self.m_bSteering = true		
	end				
end


function cropsUnit:_enterDown()
	self.m_moveState = CS_MOVING_STATE.down	
	self.m_downTime  = self:getActor():PlaySkill("down",false,false,1)	
end	  

function cropsUnit:_enterTpIng()
	self.m_moveState = CS_MOVING_STATE.tp_ing	
	self:getActor():PlaySkill("run",false,false,self.m_actorRunSpeed)			
end

function cropsUnit:_enterTpEnd()
	self.m_moveState = CS_MOVING_STATE.tp_end	
	self.m_tpEndTime  = self:getActor():PlaySkill("down",false,false,1)	
	
	self.m_PathIdx = 1
	
	sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")
	self.m_movingX  = self.m_pathArray[self.m_PathIdx].x
	self.m_movingY  = self.m_pathArray[self.m_PathIdx].y	
	self.m_movingPos = sceneManager.battlePlayer():getWorldPostion(self.m_movingX,self.m_movingY )	
	self.m_Postion = self.m_movingPos
	self:getActor():SetPosition(self.m_Postion)		
	self.m_PosX = self.m_movingX
	self.m_PosY = self.m_movingY		
	sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")
	self:__handleMovingSkill(1,table.nums(self.m_pathArray))
	
end	  

function cropsUnit:_enterTpPre()
	self.m_moveState = CS_MOVING_STATE.tp_pre	
	-- 播放tp 前动作
  	self.m_tpPreTime  = self:getActor():PlaySkill("up",false,false,1)		
end	

function cropsUnit:__handleMovingSkill( currentStep, wholeStep )
	print("__handleMovingSkill--------------------------------------");
	if(self.m_PathIdx ~= 0 and self.moveHanlSkills ~= nil)then
			local size = #(self.moveHanlSkills)	
			for i = 1 , size do		
				local paramTargets = self.moveHanlSkills[i];
				
				for k,v in ipairs(paramTargets) do
					if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then		
						local crops = sceneManager.battlePlayer():getCropsByIndex(v.target.id)
						local percent = 1 / wholeStep;
						local value =  math.floor(v.target.damage * percent) 
						-- 最后一次全都减掉
						print("__handleMovingSkill currentStep "..currentStep.." wholeStep "..wholeStep.." value "..value);
						if currentStep == wholeStep then
							value = v.target.damage - value * (wholeStep -1);
						end
						
						self.moveDamageList[i][k] = self.moveDamageList[i][k] - value;
													
						crops:changeTotalHP(-value);
						
						crops:getActor():AddSkillAttack("samanS_liuxue.att");
						
					elseif(v.server_action_type == SERVER_ACTION_TYPE.CURE)then								
					elseif(v.server_action_type == SERVER_ACTION_TYPE.BUFF)then	
						  						
					elseif(v.server_action_type == SERVER_ACTION_TYPE.SUMMON)then											
					elseif(v.server_action_type == SERVER_ACTION_TYPE.REVIVE)then										
					end	
				end

			end							
		end			
end
function cropsUnit:movingOnSetp()
	self.m_PathIdx = self.m_PathIdx + 1	
  
  if self.m_PathIdx > 1 then
  	self:__handleMovingSkill(self.m_PathIdx-1, table.nums(self.m_pathArray));
  end
  	
  if( self.m_PathIdx >  table.nums(self.m_pathArray) )then	
		self:_doRunEnd()
	  return true
	end
	
	self.m_movingX  = self.m_pathArray[self.m_PathIdx].x
	self.m_movingY  = self.m_pathArray[self.m_PathIdx].y	
	self.m_movingPos = sceneManager.battlePlayer():getWorldPostion(self.m_movingX,self.m_movingY )
	
	--根据移动速度算出时间	
	self.m_movingDir = LORD.Vector3.Sub(self.m_movingPos , self.m_Postion)
	self.m_movinglength = self.m_movingDir:len()
	self.m_movingDir:normalize()
	self.m_movedlength = 0
	---获取转身角度 当前先转身，后移动一格，然后转身，再移动.
	
	local targetAngle = self:gettoTargetAngle(self.m_movingPos)
	self.m_steerAngle, self.m_steerLeft = self:caculateSteering(self.m_Angle,targetAngle)
	
	if(self.m_steerAngle < math.PI_DIV2)then
		self.m_bFirstSteering = false	
		if(self.m_steerAngle <0.0001)then
			self.m_bSteering = false
		end				
	else 			
		self.m_bFirstSteering = true
		self.m_bSteering = true
		--self:getActor():PlaySkill("idle",false,false,1)	
	end	
	return false		
end	

function cropsUnit:gettoTargetAngle(targetPos)
	 local TEMP = LORD.Vector3.Sub(targetPos,self.m_Postion)
	 TEMP:normalize()	
	 return math.atan2(-TEMP.z,TEMP.x)
end

function cropsUnit:caculateSteering( currentAngle, targetAngle)
	 
	self.m_bSteering = true
	local trunleft = nil
	
	local _tar = targetAngle + math.PI  --[-180 180] -> [0 360]
	local _now = currentAngle + math.PI   --[-180 180] -> [0 360]

	local dst = _tar -_now
	if(dst >= 0)then
	 
		if(dst >  math.PI )then	
			trunleft = false
			return  math.PI *2 -dst,trunleft			
		else			
			trunleft = true
			return dst ,trunleft
		end		
	else
	 
		if(dst < - math.PI)then	
			trunleft = true
			return math.PI *2+dst ,trunleft			
		else			
			trunleft = false
			return -dst ,trunleft
		end
	 end						
end

function cropsUnit:reDisAngle()
	
	while (self.m_Angle <= - math.PI)do 	
		self.m_Angle = self.m_Angle + math.PI * 2
	end
	
	while (self.m_Angle >=  math.PI)do 	
		self.m_Angle = self.m_Angle - math.PI * 2
	end		
end	

function cropsUnit:rotateActor_forCamera() 
		local  showangle =  0
		local  angle = 0
		if(self.m_attackSteerLeft)then
			angle = self.m_Angle + self.m_attackSteerAngle;
		else
			angle = self.m_Angle - self.m_attackSteerAngle;
		end

		if(self:isAttacker())then		
			if(self.charmed  == false)then
				showangle =   angle
			else
				showangle =   angle - math.PI		
			end						
		else			
			if(self.charmed  == false)then
				showangle =   angle - math.PI		
			else
				showangle =   angle		
			end						
		end		
	 				
 				
		local q = self:getActor():GetOrientation();
		local qy = LORD.Quaternion(LORD.Vector3(0,1,0),self.m_BaseAngle)
		local qx = LORD.Quaternion(LORD.Vector3(1,0,0),cropsUnit.s_initq)	
		local qz = LORD.Quaternion(LORD.Vector3(0,1,0),showangle)	
		local result = LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy); 	
	    self:getActor():SetOrientation(result);

		return q
end

function cropsUnit:enterStateAttack(action_targets)
	
	self.stateFinish = false
--	dump(action_targets[1])
	self.m_Targets[1] = sceneManager.battlePlayer():getCropsByIndex(action_targets.id)		
	sceneManager.battlePlayer():signGrid(self.m_Targets[1].m_PosX,self.m_Targets[1].m_PosY,"r")
	--print(self.m_Targets[1].m_name.." enterStateAttacked end   to  r")		
		
	self.m_bPlayedAttack = false
	self.m_AttackPlayedTime = 0		
	local enemyPos = sceneManager.battlePlayer():getWorldPostion(self.m_Targets[1].m_PosX,self.m_Targets[1].m_PosY)
	local targetAngle = self:gettoTargetAngle(enemyPos)	
    
    self.m_attackSteerAngle ,self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,targetAngle)	
	self.m_bAttackSteering	 = true
	if(self.m_attackSteerAngle <0.0001)then
		self.m_bAttackSteering	 = false
	end							
 
	self.m_Targets[1].HIT_CALLBACK_FINISH =   1
	self:getActor():ClearAttackTargetActors()
	self:getActor():AddAttackTargetActors(self.m_Targets[1].actor,false)	

	local q = self:rotateActor_forCamera()
	
	-- 根据伤害类型和是否有暴击动作判断是否需要摄像机镜头
	local actorNameArray = self.actor:getActorNameID().."|"..self.m_Targets[1].actor:getActorNameID();
	local damageFlag = action_targets.hurt.target.damageFlag;
	local frequent = math.random();
	
	local skillName = "attack";
	local isPlayCamera = false;
	
	local shiftRadio = sceneManager.battlePlayer():getCameraRadio();
	
	--print("frequent "..frequent);
	if damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL then
		isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].attackCF * shiftRadio;
		--print("attack enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL");
	elseif damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL then
		if self.criticalAttackName == "attack" then
			-- 没有特殊暴击动作
			isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].attackCriticalCF * shiftRadio;
			--print("attack enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL");
		else
			-- 有特殊暴击动作
			isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].attack_critCF * shiftRadio;
			skillName = self.criticalAttackName;
			--print("attack enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL special");
		end	
	end
	
	if isPlayCamera then
		self.m_AttackPlayedTime = self:getActor():PlaySkill(skillName,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1, actorNameArray);	
	else
		self.m_AttackPlayedTime = self:getActor():PlaySkill(skillName,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1, "");	
	end
	
	self:getActor():SetOrientation(q);

	self.m_bPlayedAttack = true	
	self.m_TargetsDamage[1] = action_targets.hurt
	self.m_State = CROPSSTATE.CS_ATTACK 
	
		--print("enterStateAttack"..  t[1].damage)
	--echoInfo("enterStateAttack  self.HIT_CALLBACK_FINISH %d = %d",self.m_Targets[1].index, self.m_Targets[1].HIT_CALLBACK_FINISH  )	
end	

function cropsUnit:enterStateAttackBack(action_targets)
	self.stateFinish = false
	self.m_Targets[1] = sceneManager.battlePlayer():getCropsByIndex(action_targets.id)   -- t.target --- damage		
	--sceneManager.battlePlayer():signGrid(self.m_Targets[1].m_PosX,self.m_Targets[1].m_PosY,"r")
	--print(self.m_Targets[1].m_name.." enterStateAttackBacked end   to  r")	
	
	
	self.m_bPlayedAttack = false
	self.m_AttackPlayedTime = 0		
	local enemyPos = sceneManager.battlePlayer():getWorldPostion(self.m_Targets[1].m_PosX,self.m_Targets[1].m_PosY)
	local targetAngle = self:gettoTargetAngle(enemyPos)	
    
    self.m_attackSteerAngle ,self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,targetAngle)		
	self.m_bAttackSteering	 = true
	if(self.m_attackSteerAngle <0.0001)then
		self.m_bAttackSteering	 = false
	end				
	self.m_Targets[1].HIT_CALLBACK_FINISH =   1	
	self:getActor():ClearAttackTargetActors()
	self:getActor():AddAttackTargetActors(self.m_Targets[1].actor,false)	
	
	local strike = "strike01"
	
	local dis = battleDistance.distance(self.m_PosX,self.m_PosY, self.m_Targets[1].m_PosX,self.m_Targets[1].m_PosY)	
	if(dis > 1)then	
		if(self:getActor():IsSkillExist("strike02"))then
			strike = "strike02"
		end
	end		
	
	local q = self:rotateActor_forCamera()	
	self.m_AttackPlayedTime = self:getActor():PlaySkill(strike,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON)	
	self:getActor():SetOrientation(q)
		
	self.m_bPlayedAttack = true	
	self.m_TargetsDamage[1]  = action_targets.hurt
	battleText.addHitText("反", self.index, "damage");
 
	self.m_State = CROPSSTATE.CS_ATTACK 
	
	--echoInfo("enterStateAttackBack  self.HIT_CALLBACK_FINISH %d = %d",self.m_Targets[1].index, self.m_Targets[1].HIT_CALLBACK_FINISH  )	
end	



function cropsUnit:enterStateDead(deadFlag)
	
	self.deadFlag = deadFlag;
	print("----------------------------------------enterStateDead index "..self.index);
	
	self.stateFinish = false
	self.m_bPlayedDeadTime = self:getActor():PlaySkill("dead",false,false,1)		
	
	self.m_bAlive = false
    self.m_bPlayedDeadOver = false	
	self.m_bFadeTime = 1800		
	self.m_bFade = false	
	self.m_State = CROPSSTATE.CS_DEAD 
	sceneManager.battlePlayer():onCropsDead(self)
	sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")	
	
	-- 战斗记录
	battleRecord.pushDead(self);
		--print(self.m_name.."dead  to  n")
		
	--触发友军死亡引导
	if(  ( self:isFriendlyForces() and self:isCharmed() == false )   or (  not self:isFriendlyForces() and self:isCharmed() == true  ) )then
		scheduler.performWithDelayGlobal(function ()
			eventManager.dispatchEvent( {name =  global_event.GUIDE_ON_FRIENDLY_UNIT_DEAD} ) 
		end, 1)
	end	
	--
end

function cropsUnit:enterStateWin()
	self:getActor():PlaySkill("win",false,false,1)
	self.m_State = CROPSSTATE.CS_WIN		
end


function cropsUnit:updateUI(dt)
	if(self.m_bAlive)then
		local color = LORD.Color(1,0,0,1)
		if(self:isFriendlyForces())then
			color = LORD.Color(0,1,0,1)
		end		
		
		if(self.charmed)then
			color = LORD.Color(0,0,1,1)
		end	
	
		-- 头顶信息
		local screenpos = self:getActor():GetTextScreenPosition();
		local uisize = self.headInfoUI:GetPixelSize();
		--self.headInfoUI:SetText(self.m_CropsNum);
		self.headInfoUI:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y+10)));
	 
		local worldPos = self:getActor():GetTextWorldPosition();
		worldPos.x = worldPos.x
		worldPos.y = worldPos.y + 2;
		worldPos.z = worldPos.z
		local initPos = LORD.Vector2(0, 0);
		initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);		
 
		local x = initPos.x -  self.soldierHeadTip:GetPixelSize().x  /2
		local y = initPos.y
		self.soldierHeadTip:SetPosition(LORD.UVector2(LORD.UDim(0, x), LORD.UDim(0, y)));
		
		
		if(self.soldierHpUi)then
			local uisize = self.soldierHpUi:GetPixelSize();
			
				local config =  cropData:getCropsGonfig(self.m_ID )
				local deatl =  config.modelScaling * 80 
	
				self.soldierHpUi:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y -deatl )));
		end		
		
	end
	
	if LORD.SceneManager:Instance():isPlayingCameraAnimate() then
		self.headInfoUI:SetVisible(false);
		if(self.soldierHpUi)then
			self.soldierHpUi:SetVisible(false);
		end
	else
		 
		self.headInfoUI:SetVisible(self.m_bAlive);
		if(self.soldierHpUi)then
			self.soldierHpUi:SetVisible(self.m_bAlive);
		end
	end
	
	if(self.isHide)then
		self.headInfoUI:SetVisible(false);
		if(self.soldierHpUi)then
			self.soldierHpUi:SetVisible(false);
		end
	end
	
end


	
function cropsUnit:logic(dt)
	
	--print("cropsUnit:logic ----index"..self.index);
	-- render index text
	 local returnResult = true
	
	 local handler = self.stateHandler[self.m_State];
	 local endHnadler = self.stateEndHandler[self.m_State];
	 
	 if(handler ~= nil)then
	 	 local handlerReturn = handler(self,dt);
	 	 if handlerReturn and endHnadler then
	 	 	endHnadler(self, dt);
	 	 end
		 returnResult =  handlerReturn and  ___targertHurtEnd(self)
	 end	
	
	
	self:updateUI(dt)
	
	
	 return returnResult
end

function cropsUnit:enterSkill(t)
	self.stateFinish = false
	self.m_State = CROPSSTATE.CS_SKILL	
	local target = nil
	
	if(t and t._param and t._param.targets )then
		local num = #t._param.targets
		for i = 1 ,num do
			local index = t._param.targets[i].target.id
			target = sceneManager.battlePlayer():getCropsByIndex(index)
			if(target)then
				break
			end
		end			
	end
	--self.m_Targets[1]
	
	-- 如果没有技能动作就不转向目标
	local skillId = t._param.skillid;
	local skillInfo = dataConfig.configs.skillConfig[skillId];
	
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_UNIT_PLAY_SKILL,arg1 = self.index,arg2 = skillId })		
	
	
	local turnToTarget = true;
	if skillInfo and (skillInfo.actionName == nil or skillInfo.actionName == "") then
		turnToTarget = false;
	end
	
	if( turnToTarget and target~= nil  and  (target.m_PosX ~= self.m_PosX  or  self.m_PosY ~=  target.m_PosY))then	
		local enemyPos = sceneManager.battlePlayer():getWorldPostion(target.m_PosX,target.m_PosY)
		local targetAngle = self:gettoTargetAngle(enemyPos)		
		self.m_attackSteerAngle ,self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,targetAngle)	
		self.m_bAttackSteering	 = true	
		if(self.m_attackSteerAngle < 0.0001 )then
			self.m_bAttackSteering	 = false
		end							
	end	
	
	
	local q = self:rotateActor_forCamera()	
	skillSys.Play(self,t)	
	self:getActor():SetOrientation(q);
		
end

function cropsUnit:onStateSkill(dt)
	if(self.m_bAttackSteering)then --转完毕再攻击
		self:__AttacSteering(dt)	
		return false
	end		
	return skillSys.OnTick(dt)
end

function cropsUnit:onStateHurt(dt)
	
	if(self.m_bAttackSteering)then --  媚惑转身
		self:__AttacSteering(dt)	
		return false
	end		
	
	self.m_bPlayedHitTime = self.m_bPlayedHitTime - dt
	
	if( self.m_bPlayedHitTime <= 0 )then
	 		self:enterStateIdle()	
		if( self.m_bPlayedHited == true and self.callbackindex == self.callbacknum)then				
			self:decrease_HIT_CALLBACK_FINISH()
			--echoInfo("onStateHurt  m_bPlayedHited" )	
		end				
		 -- echoInfo("onStateHurt  self.HIT_CALLBACK_FINISH %d = %d",self.index, self.HIT_CALLBACK_FINISH  )
		self.m_bPlayedHited = false		
		return true
	end
	
	return false
end	

function cropsUnit:enterStateHurt(_hurt, aoeMainTargetDispatch)
		
		-- 触发击退
		if _hurt.repelData then
			--print("startRepel")
			self:startRepel(_hurt);
		end
		
		self.ejectionHit = true;
		
		self.stateFinish = false
		--print("cropsUnit:enterStateHurt(");
		--dump(_hurt);
		
		if(self.m_bAlive == false)then
			trace("我已经挂了 你还鞭尸~~~~~~~~~~~~~~~~~ 我不会放过你们的")		
			self.HIT_CALLBACK_FINISH = 0
			
			-- 由于为了部落技能会报错，所以这里做个特殊处理
			if _hurt.server_action_type == SERVER_ACTION_TYPE.DAMAGE then
				local damage = _hurt.target.damage;
				
				if damage ~= nil then
					local per = 1/ self.callbacknum
					-- 由于有除不尽的情况，所以计算余数
					local reminder = math.fmod (damage, self.callbacknum);
					damage =  math.floor(per *damage);
					
					if self.callbackindex == self.callbacknum then
						damage = damage + reminder;
					end
			
					damage = -damage
					self:changeTotalHP(damage);
				end

			end
			-- 处理结束
			return;
		end			
		
		if(	self.m_State ~= CROPSSTATE.CS_SKILL	)then
			self.m_State = CROPSSTATE.CS_HURT							
		end
 
		local bHited = false
		local text =  "damage"
		local hurtFlag = nil  
		local value = nil
		local damageSource =  nil	
		local hitToDead = false
		local buffAdd = fasle;
		local deadFlag = 1;
		
		if(_hurt.server_action_type == SERVER_ACTION_TYPE.ATTACK)then
				hurtFlag = _hurt.target.damageFlag	
				value = _hurt.target.damage
				bHited = true				
				hitToDead = _hurt.target.hitToDead
				deadFlag = _hurt.target.deadFlag	
				damageSource = enum.SOURCE.SOURCE_ATTACK;
	 	
		elseif(_hurt.server_action_type == SERVER_ACTION_TYPE.RETALIATE)then
				hurtFlag = _hurt.target.damageFlag	
				value = _hurt.target.damage	
				hitToDead = _hurt.target.hitToDead
				deadFlag = _hurt.target.deadFlag 	
				bHited = true
				damageSource = enum.SOURCE.SOURCE_RETALIATE;
				
		elseif(_hurt.server_action_type == SERVER_ACTION_TYPE.BUFF)then
				
				if(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_ADD )then
				 	
				 	if self.callbackindex == self.callbacknum then
				 		--buffAdd = true;
					 	
					 	--local instance = bufferSys.getBuffer(_hurt.target.bufferId,self)		
						--instance:enterBegin(_hurt.target)					
						--table.insert(self.bufferList,_hurt.target.bufferId)				 	
				 		-- 新的添加buff的代码
				 		
				 		local addRet = _hurt.target.addRet;
				 		
				 		if addRet == enum.ADD_BUFF_RESULT.ADDBUFFRET_OVERRIDE then
				 			-- 检查相同的ID的BUFF，如果有就删除掉再添加
				 			bufferSys.DeleteBuff(_hurt.target.bufferId, -1, self);
				 			buffAdd = true;
				 		elseif addRet == enum.ADD_BUFF_RESULT.ADDBUFFRET_OVERLAY  then
				 			-- 检查相同的ID，并且相同的caster，如果有就删除掉
				 			bufferSys.DeleteBuff(_hurt.target.bufferId, _hurt.target.casterId, self);
				 			buffAdd = true;
				 		elseif addRet == enum.ADD_BUFF_RESULT.ADDBUFFRET_SUCCESS then
				 			-- 直接添加
				 			buffAdd = true
				 		else
				 			-- 添加失败，全都显示免疫
				 			battleText.addHitText("免疫", self.index, "damage");
				 		end
						
						if buffAdd then
							local buffInstance = bufferSys.CreateBuffer(_hurt.target.bufferId, _hurt.target.casterId, self);
							buffInstance:SetLayer(_hurt.target.layer);
							buffInstance:SetCD(_hurt.target.cd);
							buffInstance:SetBuffSource(_hurt.target.bufferSource);
							buffInstance:SetSourceSkillOrMagicID(_hurt.target.skillId);
							
					 		buffInstance:enterBegin(_hurt.target);
						end
				 		--print("addRet"..addRet)	
				 	end
				 	
				elseif(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE )then
				
					self:enterStateDelBuffer(_hurt.target.bufferId, _hurt.target.buffInnerCasterIndex);				
				
				elseif(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_CD )then
					
					local buffInstance = bufferSys.GetBuffer(_hurt.target.bufferId, _hurt.target.buffInnerCasterIndex, self);
					if buffInstance then
						buffInstance:SetCD(_hurt.target.cd);
					end
				elseif(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_LAYER )then
				
					local buffInstance = bufferSys.GetBuffer(_hurt.target.bufferId, _hurt.target.buffInnerCasterIndex, self);
					if buffInstance then
						buffInstance:SetLayer(_hurt.target.layer);
					end
				end
				
		elseif(_hurt.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then
				value = _hurt.target.damage
				hurtFlag = _hurt.target.damageFlag	
				hitToDead = _hurt.target.hitToDead
				deadFlag = _hurt.target.deadFlag 		
				bHited = true		
				damageSource = _hurt.target.damageSource				
		elseif(_hurt.server_action_type == SERVER_ACTION_TYPE.CURE)then
				value = _hurt.target.cure
				text =  "healnum"
				damageSource = _hurt.target.cureSource
		end

		if value ~= nil then
			local per = 1/ self.callbacknum
			-- 由于有除不尽的情况，所以计算余数
			local reminder = math.fmod (value, self.callbacknum);
			value =  math.floor(per *value);
			
			if self.callbackindex == self.callbacknum then
				value = value + reminder;
			end
	
			if(bHited == true)then
				value = -value
			end
		end
		
---------------------------------log-----------------------------------------------------------------------------------------------		
	-- 战斗记录
		if(damageSource == enum.SOURCE.SOURCE_ATTACK)then	
				
			battleRecord.pushAttackDamage(self, self.hurtSourceActor, value);
			
		elseif(damageSource == enum.SOURCE.SOURCE_RETALIATE)then
				
			battleRecord.pushRetailateDamage(self, self.hurtSourceActor, value);
		
		elseif _hurt.server_action_type == SERVER_ACTION_TYPE.DAMAGE or _hurt.server_action_type == SERVER_ACTION_TYPE.CURE then
			
			-- 伤害的回调记录，包括skill，magic， buff
			if(damageSource == enum.SOURCE.SOURCE_SKILL)then
				local skillInfo = dataConfig.configs.skillConfig[_hurt.target.skillId];
				if(skillInfo)then
					if bHited == true then
						battleRecord.pushSkillDamage(self, self.hurtSourceActor, skillInfo.name, value);
					else
						battleRecord.pushSkillCure(self, self.hurtSourceActor, skillInfo.name, value);
					end
				end
			
			elseif(damageSource == enum.SOURCE.SOURCE_MAGIC)then				
				local magicInfo = dataConfig.configs.magicConfig[_hurt.target.skillId];
				if(magicInfo and iskindof(self.hurtSourceActor, "kingClass"))then
						if bHited == true then
							battleRecord.pushMagicDamage(self, magicInfo.name, value, self.hurtSourceActor.force);
						else
							battleRecord.pushMagicCure(self, magicInfo.name, value, self.hurtSourceActor.force);
						end
				end						
			elseif(damageSource == enum.SOURCE.SOURCE_BUFF)then	
						
			end				
		
		elseif _hurt.server_action_type == SERVER_ACTION_TYPE.BUFF then

			local buffInfo = dataConfig.configs.buffConfig[_hurt.target.bufferId];

			if buffInfo then
				if(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_ADD and buffAdd )then

					if _hurt.target.bufferSource == enum.SOURCE.SOURCE_SKILL then
						
						local skillInfo = dataConfig.configs.skillConfig[_hurt.target.skillId];
						battleRecord.pushSkillAddBuff(self, self.hurtSourceActor, skillInfo.name, buffInfo.name);

					elseif _hurt.target.bufferSource == enum.SOURCE.SOURCE_MAGIC then
						local magicInfo = dataConfig.configs.magicConfig[_hurt.target.skillId];
						
						if magicInfo and iskindof(self.hurtSourceActor, "kingClass") then
							battleRecord.pushMagicAddBuff(self, magicInfo.name, buffInfo.name, self.hurtSourceActor.force);
						end
					end
					
				elseif(_hurt.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE )then
					if skillInfo then
						--battleRecord.pushDeleteBuffBySkill(self, buffInfo.name, skillInfo.name);
					else
						--battleRecord.pushDeleteBuffBySkill(self, buffInfo.name );
					end
				end
			end
		end
---------------------------------log--------------------------------------------------------------------------------------------
		
		if( self.callbackindex == self.callbacknum	and hitToDead == true)then		
			 self:enterStateDead(deadFlag)
		end		
 
		if(value ~= nil and value ~= 0)then

				battleRecord.pushDamageFlag(hurtFlag);
				-- 先缓存军团数
				if self.callbackindex == 1 then
					self.backupUnitNum = self:getUnitNum();
				end
				
				-- 暴击用新的字体
				if hurtFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL then
					self:changeTotalHP(value, "crinum", true);
				else
					if value > 0 then
						self:changeTotalHP(value, "healnum", true);
					else
						self:changeTotalHP(value, "damage", true);
					end
				end
				
				-- 计算军团数变化
				if( self.callbackindex == self.callbacknum and self.backupUnitNum ) then
					 local unitNumChanged = self:getUnitNum() - self.backupUnitNum;
					 battleText.changeUnitNum(unitNumChanged, self.index);
				end
				
		end
		
		if(bHited == false)then
			
			if(self.callbackindex == self.callbacknum)then				
				self:decrease_HIT_CALLBACK_FINISH()
			end
			 --print("self.callbacknum "..self.callbacknum.."  self.callbackindex  "..self.callbackindex);
			 --echoInfo("enterStateHurt  self.HIT_CALLBACK_FINISH %d = %d",self.index, self.HIT_CALLBACK_FINISH  )	
		else
			if(	self.m_State == CROPSSTATE.CS_SKILL	)then
				if(self.callbackindex == self.callbacknum)then				
					self:decrease_HIT_CALLBACK_FINISH()
				end						
			end
 
		end

											
		if(enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL == hurtFlag)then--正常伤害
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_DOGE == hurtFlag)then ---闪避
			battleText.addHitText("闪避", self.index, "damage");					
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_IMMUNE == hurtFlag)then --免疫
			battleText.addHitText("免疫", self.index, "damage", "immune");				
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_BLOCK == hurtFlag)then -- 格挡			
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_ABSORB == hurtFlag)then -- 吸收	
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_TRANSFER == hurtFlag)then -- 迁移
			battleText.addHitText("迁移", self.index, "damage");
		elseif(enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL == hurtFlag)then -- 暴击
			--battleText.addHitText("暴击", self.index, "damage");				
		end	
	
							
		if(self.m_State == CROPSSTATE.CS_HURT and bHited == true )then		
			self.m_bPlayedHitTime = 0			
			if(value ~= 0 )then   --伤害为0 不播放动作
				self.m_bPlayedHitTime = self:getActor():PlaySkill("hit",false,false,1)	
			end
		 	if(self.m_bPlayedHited == true)then -- 上次伤害还没播放完毕
				if(self.callbackindex == self.callbacknum)then					
					self:decrease_HIT_CALLBACK_FINISH()
				end
			end		
				
			self.m_bPlayedHited = true
		end	
		
			if(aoeMainTargetDispatch == true)then
				local att = nil			
				 if(damageSource == enum.SOURCE.SOURCE_SKILL or _hurt.target.bufferSource == enum.SOURCE.SOURCE_SKILL or
				 		damageSource == enum.SOURCE.SOURCE_FORCE_SKILL )then
					local skillInfo = dataConfig.configs.skillConfig[_hurt.target.skillId];
					if(skillInfo)then
						if skillInfo.aoeAttName then
							att = skillInfo.aoeAttName;
						else
							print("skill does not set the aoeAttName skill id  ".._hurt.target.skillId);
						end
					end						
				 elseif(damageSource == enum.SOURCE.SOURCE_MAGIC or _hurt.target.bufferSource == enum.SOURCE.SOURCE_MAGIC)then				
					local magicInfo = dataConfig.configs.magicConfig[_hurt.target.skillId];
					if(magicInfo)then
						if magicInfo.aoeAttName then
							att = magicInfo.aoeAttName;
						else
							print("magic does not set the aoeAttName magic id  ".._hurt.target.skillId);
						end
					end						
				 elseif(damageSource == enum.SOURCE.SOURCE_BUFF)then	
					 				
				 end				
				if(att)then
					--print("aoe att name"..att);
					self:getActor():AddSkillAttack(att,self.hurtSourceActor:getActor(),false, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1)	
				end
			end
			
end





function cropsUnit:onStateDelBuffer(dt)
	
	if(self.m_bAttackSteering)then --转完毕
		self:__AttacSteering(dt)	
		return false
	end		
	
	local res = true
	--[[
	for i, v in ipairs (self.bufferDelList)	do		
		if(v.handlerOver == false)then
			local instance = bufferSys.GetBuffer(v.id, v.buffCaster, self);
			
			if instance then
				local _res = instance:Tick(dt)	
				if(_res == false)then
					_res =  false
				else
					v.handlerOver = true;
					bufferSys.DeleteBuff(v.id, v.buffCaster, self);		
				end			
			end
		end	
	end
	
	if(res == true)then
		self.bufferDelList = {}
	end	
	
	--]]
		
	return res
end

function cropsUnit:enterHandlerBuffer(action)  
	self.m_State = CROPSSTATE.CS_HANDLBUFFER		
	local bufferId  = action._param.bufferId
					
	local bufferInfo = {}
	bufferInfo.id = action._param.bufferId
	bufferInfo.cd = action._param.cd	
	bufferInfo.layer = action._param.layer
	bufferInfo.handled  = false
	bufferInfo.effect = {}
	bufferInfo.effect.damage = {}
	bufferInfo.effect.cure = {}		
	for i,v in ipairs(action._param.effectList) do		
			if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then
				 table.insert( bufferInfo.effect.damage,{hitToDead = v.effect.hitToDead, id = v.effect.id, damage = v.effect.damage, damageSource = v.effect.damageSource, damageFlag = v.effect.damageFlag})		
			elseif(v.server_action_type == SERVER_ACTION_TYPE.CURE)then
				 table.insert( bufferInfo.effect.cure, { id = v.effect.id, cure = v.effect.cure, cureSource = v.effect.cureSource})		
			end				
	end						
	table.insert(self.bufferHandData,bufferInfo)	
		
	local instance = bufferSys.GetBuffer(bufferId, -1, self);

	if instance then
		instance:enterHandle(bufferInfo)
	end
 
end	
function cropsUnit:onStateHandlerBuffer(dt)
	local res = true			
 
	for i, v in ipairs (self.bufferHandData)	do			
		if(v.handled  == false )then		
			local instance = bufferSys.GetBuffer(v.id, -1, self)	
			if instance then
				res = instance:Tick(dt)	
				if(res == false)then
					res =  false
				else
					v.handlerOver = true										
				end	
			end			
		end			
	end
	
	if(res == true) then
		self.bufferHandData	 = {}
		if(self._bufferEffectToDead == true)then
			self:enterStateDead(self._buffEffectToDeadFlag);
			return false
		end
		
		-- 进入idle状态
		self:enterStateIdle();
	end
			
	return res	
end	
function cropsUnit:OnBufferHandle(data)
	
	local hitToDead = false
	local deadFlag = 1;
	for i,v in ipairs(data.effect.damage) do		
	 	 	
	 	 	self:changeTotalHP(-v.damage);
	 	 	
			 if(hitToDead ==false)then
				hitToDead = v.hitToDead
				deadFlag = v.deadFlag;
			 end

			--战斗记录
			battleRecord.pushBuffEffectDamage(self, data.id, v.damage);
	end
				
	for i,v in ipairs(data.effect.cure) do		

	 	 	self:changeTotalHP(v.cure,"healnum");
	 	 	
			--战斗记录
			battleRecord.pushBuffEffectCure(self, data.id, v.cure);
	end		
			
	self._bufferEffectToDead = hitToDead
	self._buffEffectToDeadFlag = 	deadFlag				
end	
 
function cropsUnit:enterStateDelBuffer(bufferId, buffCasterIndex)
	-- 这个暂时只能直接删掉，因为有buffer被技能删除的情况，这是还在伤害状态，不能handle删除
	--self.m_State = CROPSSTATE.CS_DELBUFFER				
	
	table.insert(self.bufferDelList,{ id = bufferId, buffCaster = buffCasterIndex, handlerOver = false})

	--print("enterStateDelBuffer id :"..bufferId.." buffCasterIndex "..buffCasterIndex);
	--dump(self.bufferList);
	local instance = bufferSys.GetBuffer(bufferId, buffCasterIndex, self);
	
	--print("cropsUnit:enterStateDelBuffer buffID "..bufferId.." casterIndex "..buffCasterIndex.." unitindex "..self.index);
	if instance then
		instance:enterEnd(bufferId);
	end
	
	-- 直接删除
	bufferSys.DeleteBuff(bufferId, buffCasterIndex, self);	
			
	-- 战斗记录
	local buffInfo = dataConfig.configs.buffConfig[bufferId];
	if buffInfo then
		battleRecord.pushDeleteBuffBySkill(self, buffInfo.name, nil);
	end
end

function cropsUnit:onDeadDeleteBuff()
	
	-- 删除buff ，id， caster
	local deleteList = {};
	
	for k,v in ipairs(self.bufferList) do
		local buffid = v:GetBuffID();
		local buffcaster = v.buffCaster;
		
		local buffInfo = dataConfig.configs.buffConfig[buffid];
		if(buffInfo and buffInfo.absoluteDieDisappear)then			
			table.insert(deleteList, {buffid = buffid, buffcaster = buffcaster});
		end
		
	end
	
	for k,v in ipairs(deleteList) do
		self:enterStateDelBuffer(v.buffid, v.buffcaster);
	end
		
end

function cropsUnit:hasSpecialBufferWithId(id)
	for k,v in ipairs(self.bufferList) do
		if v then
			if(v:GetBuffID() == id)then
				return true
			end
		end
	end	
	return false	
end	

function cropsUnit:onChangeCharmed()
 	self.charmed = not self.charmed			
	if(self.m_force == enum.FORCE.FORCE_ATTACK	)then
		self.m_force = enum.FORCE.FORCE_GUARD
	elseif(self.m_force == enum.FORCE.FORCE_GUARD	)then
		self.m_force = enum.FORCE.FORCE_ATTACK
	end		
	
	self:setUnitNumColor(self:isFriendlyForces())
	if(cropsUnit.__MIRROE_)then		
		self:getActor():SetMirror( not self:isAttacker())		
	end			
	
	--[[
	self.m_attackSteerAngle ,self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,self.m_Angle + math.PI)						
	self.m_bAttackSteering	 = true					
	if(self.m_attackSteerAngle < 0.0001)then
		self.m_bAttackSteering	 = false
	end		
	]]--	
end

function cropsUnit:reviveTarget(_target)
	sceneManager.battlePlayer().m_AllCrops[_target.target]:enterStateRevive(_target)	
end

function cropsUnit:enterStateRevive(_target)
	
	--[[
	if _target then
		_target:resetRoundTime();
	end
	--]]
	
	self.m_PosX = 	_target.x
	self.m_PosY = 	_target.y		
	self.m_Postion =  sceneManager.battlePlayer():getWorldPostion(self.m_PosX , self.m_PosY)	
	self:getActor():SetPosition(self.m_Postion)		
		
	self.stateFinish = false
	--print("cropsUnit:enterStateRevive( -------------")
	self.m_State = CROPSSTATE.CS_REVIVE	
	self.m_bAlive = true
	self.m_bFade = true
	self:getActor():SetActorTranslateAlpha(1.0)
    self.m_AttackPlayedTime  = 3000
    self:getActor():PlaySkill("idle",false,false,1)		

	self:setTotalHP(_target.hp); 
 			
end

function cropsUnit:onStateRevive(dt)

	self.m_AttackPlayedTime = 	self.m_AttackPlayedTime - dt
	if(	self.m_AttackPlayedTime <= 0 )then
		self:enterStateIdle()	
		print("cropsUnit:onStateRevive( idle:")
		return true
	else
		return false	
	end										
end

-- 穿刺表现效果
function cropsUnit:startChuanCi(hurtData, casterUnit)
		
	self.chuanCiState = enum.UNIT_CHUANCI_STATE.UPDOWN;
	self.chuanCiTime = 0;

	self.maxRaiseHeight = 4; -- m
	self.chuanCiCycle = 500; -- ms
	
	self:getActor():AddSkillAttack("dixuelingzhuS_ci.att", casterUnit:getActor(), false);

	self.callbackindex = 1;
	self.callbacknum = 1;
	self.hurtSourceActor = casterUnit;
	self:enterStateHurt(hurtData, false);
				
end

function cropsUnit:onChuanCi(dt)
	
	local y = battlePrepareScene.centerPosition.y;
	if self.chuanCiState == enum.UNIT_CHUANCI_STATE.UPDOWN then
		
		--print("self.chuanCiTime "..self.chuanCiTime.." dt "..dt);
			
		if self.chuanCiTime >= self.chuanCiCycle then
			self.chuanCiState = enum.UNIT_CHUANCI_STATE.OVER;
			self.chuanCiTime = 0;
			y = battlePrepareScene.centerPosition.y;
		else			
			y = battlePrepareScene.centerPosition.y + self.maxRaiseHeight * math.sin(self.chuanCiTime * math.PI / self.chuanCiCycle);
			self.chuanCiTime = self.chuanCiTime + dt;
			
		end
		
		if self:getActor() then
			local position = self:getActor():GetPosition();
			position.y = y;
			self:getActor():SetPosition(position);
		end

	elseif self.chuanCiState == enum.UNIT_CHUANCI_STATE.OVER then
				
		if self:getActor() then
			local position = self:getActor():GetPosition();
			position.y = y;
			self:getActor():SetPosition(position);
		end
		
		return true;
	end
	
	return false;
end

-- 触发击退
function cropsUnit:startRepel(hurtData)

	--print("startRepel");
	--dump(hurtData);
	 sceneManager.battlePlayer():signGrid(self.m_PosX,self.m_PosY,"n")
	self.repelTimer = 0;
	self.repelStart = true;
	local targetPosition = hurtData.repelData.points[hurtData.repelData.pointNum];
	self.repelTargetPos = sceneManager.battlePlayer():getWorldPostion(targetPosition.x, targetPosition.y);
	self.repelStartPos = sceneManager.battlePlayer():getWorldPostion(self.m_PosX, self.m_PosY);
	
	--print("self.repelTargetPos "..self.repelTargetPos.x.." "..self.repelTargetPos.y.." "..self.repelTargetPos.z);
	--print("self.repelStartPos "..self.repelStartPos.x.." "..self.repelStartPos.y.." "..self.repelStartPos.z);
	
	self.moveHanlSkills = hurtData.repelData.skills;
	
	-- 伤害量备份起来，最后move结束的时候做个检查
	self.moveDamageList = {};
	for k,targets in ipairs(self.moveHanlSkills) do
		self.moveDamageList[k] = {};
		for kk, v in ipairs(targets) do
			self.moveDamageList[k][kk] = v.target.damage;
		end 
	end
	
	
	-- 设置最终的x，y
	self.m_PosX = targetPosition.x;
	self.m_PosY = targetPosition.y;
	self.m_Postion = self.repelTargetPos;
end

-- 击退表现
function cropsUnit:onRepel(dt)
	
	local wholeTime = 300;
	
	if self.repelStart then
		self.repelTimer =  self.repelTimer + dt;
		
		if self.repelTimer > wholeTime then
			self.repelStart = false;
			
			self.repelTimer = 0;
			
			self:getActor():SetPosition(self.repelTargetPos);
			
			--print("self.repelStartPos "..self.repelStartPos.x.." "..self.repelStartPos.y.." "..self.repelStartPos.z);
			
			self:onMoveEndCheckDamage();
			
			return true;
		
		else
			
			local percent = self.repelTimer / wholeTime;
			
			local newPosition = self.repelStartPos + (self.repelTargetPos - self.repelStartPos) * percent;
			
			--print("self.newPosition "..newPosition.x.." "..newPosition.y.." "..newPosition.z.." dt "..dt);
			
			self:getActor():SetPosition(newPosition);
			
			return false;
		end
		
	end
	
	
	return false;
end

function cropsUnit:disSquareToUnit(unit)
	local postion1 = unit:getActor():GetPosition();
	local postion2 = self:getActor():GetPosition();
	
	return (postion1.x - postion2.x) * (postion1.x - postion2.x) + 
					(postion1.y - postion2.y) * (postion1.y - postion2.y)
end

function cropsUnit:showTipReduceInfo( reduceNum,isLimit)
	if(self.soldierHeadTip)then
		self.soldierHeadTip:SetText("减("..math.abs(reduceNum)..")");
		self.soldierHeadTip:SetVisible(true)
		if(isLimit)then
			self.soldierHeadTip:SetTextColor(LORD.Color.RED )
		else
			self.soldierHeadTip:SetTextColor(LORD.Color.WHITE)	
		end
	end	
end

function cropsUnit:hideTipReduceInfo()
	if(self.soldierHeadTip)then
		self.soldierHeadTip:SetVisible(false)
	end
end




function cropsUnit:showTipFloatArrayInfo( rate)
	if(self.soldierHeadTip)then
		self.soldierHeadTip:SetText("("..math.abs(rate).."%)");
		self.soldierHeadTip:SetVisible(true)
	end	
end

function cropsUnit:hideTipFloatArrayInfo()
	if(self.soldierHeadTip)then
		self.soldierHeadTip:SetVisible(false)
	end
end

function cropsUnit:setFrozen(flag)
	if self:getActor() then
		if flag then
			self:getActor():ChangeFrozen();
		else
			self:getActor():RevertEffectTexture();
		end
	end
end

function cropsUnit:hideCrops()
	if self:getActor() then
		self:getActor():setActorHide(true);
	end
	self.isHide = true
end

function cropsUnit:turnToTarget(targetX, targetY)
	
	local enemyPos = sceneManager.battlePlayer():getWorldPostion(targetX, targetY);
	
	local targetAngle = self:gettoTargetAngle(enemyPos)	
    
  self.m_attackSteerAngle, self.m_attackSteerLeft =  self:caculateSteering(self.m_Angle,targetAngle)	
		
	if(self.m_attackSteerAngle <0.0001)then
		self.m_bAttackSteering	 = false
	else
		self.m_bAttackSteering	 = true;
	end
	
end

return cropsUnit