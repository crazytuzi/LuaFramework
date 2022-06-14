bufferSys = {}
bufferSys.allBuffer = nil

local BUFFER_TYPE =
{	
	Normal = -1,
			--免疫负面状态
			--免疫心智控制
			--游击
			--灵魂收割
			--虚弱毒药
			--迟缓毒药
			--慢性毒药
			--鬼爪
			--流血
			--灼烧
	Charmed = 11,--魅惑
			--咆哮
			--回春术
			--伤口感染
			--石像形态
			--超级石像形态
			--嗜血术
			--奔袭
			--投网
			--稳固投射
			--睡眠
			--昏迷
			--割裂
			--射手天赋
			--嘲讽	
	CharmedKing = 121,--魅惑		
}

bufferSys.buffer_class = {}
function bufferSys.RegisterBufferClass(class,_type)
		bufferSys.buffer_class[_type]= class
end	
function bufferSys.getBufferClass(_type)
	if( bufferSys.buffer_class[_type])then
		return bufferSys.buffer_class[_type]
	else
		return bufferSys.buffer_class[BUFFER_TYPE.Normal]
	end
end

function bufferSys.Destroy()
	bufferSys.allBuffer = nil
end
	
function bufferSys.CreateBuffer(buffID, buffCaster, cropsUnit)
	--print("bufferSys.CreateBuff id "..buffID.." caster : "..buffCaster.." unitindex "..cropsUnit.index);
	
	local class = bufferSys.getBufferClass(buffID)
	local instance = class.new(cropsUnit, buffID, buffCaster);
	--bufferSys.allBuffer[cropsUnit.index] =  bufferSys.allBuffer[cropsUnit.index] or {}
	--bufferSys.allBuffer[cropsUnit.index][_type] = instance
	
	if cropsUnit then
		cropsUnit:addBuffIDReference(buffID);
		table.insert(cropsUnit.bufferList, instance);
	end
	return instance
end

function bufferSys.GetBuffer(buffID, buffCaster,cropsUnit)
	--if(bufferSys.allBuffer == nil)then
	--	bufferSys.allBuffer = {}
	--end		
	--local buffers = bufferSys.allBuffer[cropsUnit.index]
	--local bufferInstance = nil
	--	if(buffers and buffers[_type])then
	--			bufferInstance = buffers[_type]
	--	else
	--			bufferInstance = bufferSys.__createBuffer(_type,cropsUnit)
	--	end	
	--return 	bufferInstance
	
	-- 到军团身上去找
	-- 如果buffcaster == -1 就不检查，否则的话，要检查caster
	
	if cropsUnit then
		
		local buffList = cropsUnit.bufferList;
		for k, v in ipairs(buffList) do
			if v.buffID == buffID and 
				( buffCaster == -1 or v.buffCaster == buffCaster ) then
				
				return v;	
			end
		end
		
	end
	
	return nil;
	
end

function bufferSys.delayDeleteAtt(unitIndex, attName)
	
	scheduler.performWithDelayGlobal(function(params) 
		
		if sceneManager.battlePlayer() then
			local unit = sceneManager.battlePlayer():getCropsByIndex(params.unitIndex);
			
			if unit and unit:getActor() then
			
				unit:getActor():RemoveSkillAttack(params.attName);
				
			end
			
		end
		
	end, 0, {unitIndex = unitIndex, attName = attName});
		
end
	
function bufferSys.DeleteBuff(buffID, buffCaster, cropsUnit)
		
	print("bufferSys.DeleteBuff(buffID, buffCaster, cropsUnit)");
	-- 如果buffcaster == -1 就不检查，否则的话，要检查caster
	if cropsUnit then
		
		local buffList = cropsUnit.bufferList;
		local pos = 1;
		local count = table.nums(buffList);
		while pos <= count do
			
			local buffInstance = buffList[pos];

			if buffInstance.buffID == buffID and 
				( buffCaster == -1 or buffInstance.buffCaster == buffCaster ) then
				table.remove(buffList, pos);
				cropsUnit:subBuffIDReference(buffID);
				count = table.nums(buffList);
			else
				pos = pos + 1;
			end
			
		end
		
		local referenceCount = cropsUnit:getBuffIDReference(buffID);
		
		if referenceCount == 0 then
			-- 删除buff的时候，把挂的所有的att特效都删掉
			local buffInfo = dataConfig.configs.buffConfig[buffID];
			if buffInfo and cropsUnit then
				if buffInfo.deleteAtt then
					for k,v in ipairs(buffInfo.deleteAtt) do
						--cropsUnit:getActor():RemoveSkillAttack(v);----  485 冰冻buff（buff ID： 68）消失时不播放消失光效
					end
				end
				
				if buffInfo.continueAtt then
					for k,v in ipairs(buffInfo.continueAtt) do
						--cropsUnit:getActor():RemoveSkillAttack(v);
						bufferSys.delayDeleteAtt(cropsUnit.index, v);

					end
				end
	
				if buffInfo.handleAtt then
					for k,v in ipairs(buffInfo.handleAtt) do
						
						bufferSys.delayDeleteAtt(cropsUnit.index, v);
						--cropsUnit:getActor():RemoveSkillAttack(v);
					end
				end						
			end
		end
		
		-- 变羊处理
		if buffID == enum.BUFF_TABLE_ID.YANG or 
			buffID == enum.BUFF_TABLE_ID.YongHengShiXiang then
			cropsUnit:restoreActor();
		elseif buffID == enum.BUFF_TABLE_ID.Frozen then
			cropsUnit:setFrozen(false);
		end
	end
end

local buffer_STATUS = 
{
	BEGIN = 1,
	HANDLE =2,
	END = 3,
}

buffer_base = class("buffer_base")
function buffer_base:ctor(cropsUnit, buffID, buffCaster)
	 self.cropsUnit = cropsUnit
	 self.m_State  = nil
	 self.buffID = buffID;
	 self.buffLayer = 0;
	 self.buffCD = 0;
	 self.buffCaster = buffCaster;
	 self.buffCasterForce = enum.FORCE.FORCE_INVALID;
	 self.bufferSource = -1;
	 self.sourceSkillOrMagic = -1;
	 --print("buffer_base:ctor caster "..self.buffCaster.." self.buffID "..self.buffID);	
	 self.stateHandler ={}
	 self.stateHandler[buffer_STATUS.BEGIN]    =  self.onBegin 
	 self.stateHandler[buffer_STATUS.HANDLE]  =  self.onHandle
	 self.stateHandler[buffer_STATUS.END]  =  self.onEnd 
end

function buffer_base:SetBuffSource(source)
	self.bufferSource = source;
	
	if source == enum.SOURCE.SOURCE_MAGIC then
		self.buffCasterForce = self.buffCaster - 10000;
	else
		local unitInstance = sceneManager.battlePlayer():getCropsByIndex(self.buffCaster);
		self.buffCasterForce = unitInstance:getForces();
	end
	
end

function buffer_base:GetBuffSource()
	return self.bufferSource;
end

function buffer_base:SetSourceSkillOrMagicID(id)
	self.sourceSkillOrMagic = id;
end

function buffer_base:GetSourceSkillOrMagicID()
	return self.sourceSkillOrMagic;
end

function buffer_base:GetBuffID()
	return self.buffID;
end

function buffer_base:SetLayer(layer)
	self.buffLayer = layer;
end

function buffer_base:GetLayer()
	return self.buffLayer;
end

function buffer_base:SetCD(cd)
	self.buffCD = cd;
end

function buffer_base:getCD()
	return self.buffCD;
end

--击中光效
--持续光效
function buffer_base:onBegin(dt)	
	return true
end	
-- 生效光效
function buffer_base:onHandle(dt)	
	if(self.playEd)then
		self.playTime = self.playTime - dt	 
		if(	self.playTime <=0)then
			return true
		end
		return false	
	end
	
	return true
end		
-- 消失光效
function buffer_base:onEnd(dt)	
		return true
end			

function buffer_base:Tick(dt)
		 
	local handler = self.stateHandler[self.m_State] 	
	if(handler ~= nil)then			
		 return handler(self,dt)
	end	
	return true		
end		

--击中光效
--持续光效
function buffer_base:enterBegin()	
	self.m_State = buffer_STATUS.BEGIN	
 							
end	
-- 生效光效
function buffer_base:enterHandle(data)	
	self.m_State = buffer_STATUS.HANDLE
	self.playTime = 2
	self.playEd=  true
	self.cropsUnit:OnBufferHandle(data)
	
	self:SetCD(data.cd);
	self:SetLayer(data.layer);
end		

-- 消失光效
function buffer_base:enterEnd()	
	self.m_State = buffer_STATUS.END
 	 
end		


buffer_Normal = class("buffer_Normal",buffer_base)
function buffer_Normal:ctor(cropsUnit, buffID, buffCaster)
		buffer_Normal.super.ctor(self,cropsUnit, buffID, buffCaster)
end		

--击中光效
--持续光效
function buffer_Normal:enterBegin(targetData)	
	local buffInfo = dataConfig.configs.buffConfig[targetData.bufferId];
	if buffInfo and buffInfo.continueAtt and self.cropsUnit then
		
		local referenceCount = self.cropsUnit:getBuffIDReference(targetData.bufferId);
		if referenceCount == 1 then
			-- 只有第一次加的时候才播att
			for k,v in ipairs(buffInfo.continueAtt) do
				self.cropsUnit:getActor():AddSkillAttack(v, nil, false, enum.SKILL_CALLBACK_TYPE.SCT_INVALID, -1);
			end
		end
		
		if buffInfo.id == enum.BUFF_TABLE_ID.YANG then
			self.cropsUnit:changeActor("yang.actor");
			
			if self.cropsUnit:getActor() then
				scheduler.performWithDelayGlobal(function()
					self.cropsUnit:getActor():AddSkillAttack("aofaS_bianyang01.att");
				end, 0);
			end

		elseif buffInfo.id == enum.BUFF_TABLE_ID.YongHengShiXiang then
			
			print(self.cropsUnit._____actor);
			if self.cropsUnit._____actor == "yuangushixiangguiA.actor" then
				self.cropsUnit:changeActor("yuangushixiangguiposuiA.actor");
			elseif self.cropsUnit._____actor == "yuangushixiangguiS.actor" then
				self.cropsUnit:changeActor("yuangushixiangguiposuiS.actor");
			end

		elseif buffInfo.id == enum.BUFF_TABLE_ID.Frozen then
			self.cropsUnit:setFrozen(true);
		
		elseif buffInfo.id == enum.BUFF_TABLE_ID.ChaoFeng then
			
			local unitInstance = sceneManager.battlePlayer():getCropsByIndex(self.buffCaster);
			
			if unitInstance then
				self.cropsUnit:turnToTarget(unitInstance.m_PosX, unitInstance.m_PosY);
			end
			
		elseif buffInfo.id == enum.BUFF_TABLE_ID.WeiMingZhong then
			battleText.addHitText("未命中", self.cropsUnit.index, "damage");
		end
		
		-- display
		if buffInfo.display then
			
			local hitTextType = nil;
			if buffInfo.buffFlag == 1 then
				hitTextType = "buff";
			elseif buffInfo.buffFlag == -1 then
				hitTextType = "debuff";
			end
			
			if hitTextType then
				local displaylist = string.split(buffInfo.display, "#n");
				for k,v in ipairs(displaylist) do
					
					battleText.addHitText(v, self.cropsUnit.index, "buffword", hitTextType);
					
				end			
			end
						
		end
	end
end

-- 生效光效
function buffer_Normal:enterHandle(data)	
	 	--print("onStateHandlerBuffer id :"..v.id)		
		--print("onStateHandlerBuffer currentHp :"..v.currentHp)	
		--print("onStateHandlerBuffer hurt :"..v.hurt)	
		--print("onStateHandlerBuffer cd :"..v.cd)		
		--print("onStateHandlerBuffer layer :"..v.layer)	
		
	local buffInfo = dataConfig.configs.buffConfig[data.id];
	if buffInfo and buffInfo.handleAtt and self.cropsUnit then
		for k,v in ipairs(buffInfo.handleAtt) do
			self.cropsUnit:getActor():AddSkillAttack(v, nil, false, enum.SKILL_CALLBACK_TYPE.SCT_INVALID, -1);
		end
	end
	
	buffer_Normal.super.enterHandle(self, data);
end		

-- 消失光效
function buffer_Normal:enterEnd(buffID)	
	local buffInfo = dataConfig.configs.buffConfig[buffID];
	
	local referenceCount = self.cropsUnit:getBuffIDReference(buffID);
	
	if referenceCount == 1 and buffInfo and buffInfo.continueAtt and self.cropsUnit then
		for k,v in ipairs(buffInfo.continueAtt) do
			
			bufferSys.delayDeleteAtt(self.cropsUnit.index, v);
			--self.cropsUnit:getActor():RemoveSkillAttack(v);
		end
	end
	
	if referenceCount == 1 and buffInfo and buffInfo.deleteAtt and self.cropsUnit then
		for k,v in ipairs(buffInfo.deleteAtt) do
			self.cropsUnit:getActor():AddSkillAttack(v, nil, false, enum.SKILL_CALLBACK_TYPE.SCT_INVALID, -1);
		end
	end
		
end		

buffer_Charmed = class("buffer_Charmed",buffer_base)
function buffer_Charmed:ctor(cropsUnit, buffID, buffCaster)
		buffer_Charmed.super.ctor(self,cropsUnit, buffID, buffCaster)
end		


--击中光效
--持续光效
function buffer_Charmed:enterBegin(targetData)	
	self.m_State = buffer_STATUS.BEGIN	
	print("buffer_Charmed:enterBegin")	
	self.cropsUnit:onChangeCharmed()	
	
	local referenceCount = self.cropsUnit:getBuffIDReference(targetData.bufferId);
	
	local buffInfo = dataConfig.configs.buffConfig[targetData.bufferId];
	if referenceCount == 1 and buffInfo and buffInfo.continueAtt and self.cropsUnit then
		for k,v in ipairs(buffInfo.continueAtt) do
			self.cropsUnit:getActor():AddSkillAttack(v, nil, false, enum.SKILL_CALLBACK_TYPE.SCT_INVALID, -1);
		end
	end
							
end

-- 生效光效
function buffer_Charmed:enterHandle(data)	
	self.m_State = buffer_STATUS.HANDLE
	self.playTime = 2
	self.playEd=  true
	print("buffer_Charmed:enterHandle")
end		

-- 消失光效
function buffer_Charmed:enterEnd(buffID)	
	self.m_State = buffer_STATUS.END
	print("buffer_Charmed:enterEnd")	
	self.cropsUnit:onChangeCharmed()
	
	local buffInfo = dataConfig.configs.buffConfig[buffID];
	local referenceCount = self.cropsUnit:getBuffIDReference(buffID);
	if referenceCount == 1 and buffInfo and buffInfo.continueAtt and self.cropsUnit then
		for k,v in ipairs(buffInfo.continueAtt) do
			bufferSys.delayDeleteAtt(self.cropsUnit.index, v);
			--self.cropsUnit:getActor():RemoveSkillAttack(v);
		end
	end
				
end		

function bufferSys.Init()
	bufferSys.RegisterBufferClass(buffer_Charmed, BUFFER_TYPE.Charmed);	
	bufferSys.RegisterBufferClass(buffer_Normal, BUFFER_TYPE.Normal);	
	
	bufferSys.RegisterBufferClass(buffer_Charmed, BUFFER_TYPE.CharmedKing);			
end	
