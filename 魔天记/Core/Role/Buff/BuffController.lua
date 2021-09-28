require "Core.Role.Buff.AbsBuff";
require "Core.Role.Buff.AttributeAddBuff";
require "Core.Role.Buff.AttributePreAddBuff";
require "Core.Role.Buff.AttributePreSubBuff";
require "Core.Role.Buff.AttributeSubBuff";
require "Core.Role.Buff.ChangeBuff";
require "Core.Role.Buff.DebuffAvoidBuff";
require "Core.Role.Buff.DotBuff";
require "Core.Role.Buff.HealBuff";
require "Core.Role.Buff.NoCritBuff";
require "Core.Role.Buff.SilentBuff";
require "Core.Role.Buff.StillBuff";
require "Core.Role.Buff.StunBuff";
require "Core.Role.Buff.TauntBuff";
require "Core.Role.Buff.ForceBuff";

BuffController = class("BuffController")

BuffController.EVENT_ADDBUFF = "EVENT_ADDBUFF"
BuffController.EVENT_REMOVEBUFF = "EVENT_REMOVEBUFF"
BuffController.EVENT_REMOVEALLBUFF = "EVENT_REMOVEALLBUFF"

function BuffController:New(role)
	self = {};
	setmetatable(self, {__index = BuffController});
	self._role = role;
	self._buffs = {};
	self._listers = {};
	self._cantSelectBuffCount = 0 --buffer影响角色是否可以被选中
	return self;
end

function BuffController:HasListener(owner, handler)
	for i, v in pairs(self._listers) do
		if(v.owner == owner and v.handler == handler) then
			return true;
		end
	end
	return false
end

function BuffController:AddListener(owner, handler)
	if(owner and handler) then
		if(self:HasListener(owner, handler)) then return end
		local val = {};
		val.owner = owner;
		val.handler = handler;
		table.insert(self._listers, val);
	end
end

function BuffController:RemoveListener(owner, handler)
	for i, v in pairs(self._listers) do
		if(v.owner == owner and v.handler == handler) then
			table.remove(self._listers, i)
			return;
		end
	end
end

function BuffController:Dispatch(event, value)
	for i, v in pairs(self._listers) do
		if(v.owner and v.handler) then
			v.handler(v.owner, event, value);
		end
	end
end

function BuffController:_GetBuffInfo(id, level)
	return ConfigManager.GetBuffById(id .. "_" .. level)
end

function BuffController:_CreateBuff(id, level)
	local info = self:_GetBuffInfo(id, level)
	--Warning(id .. "___" .. level .. tostring(info))
	if(info) then
		local buff = nil;
		if(info.script == "add_attr") then
			buff = AttributeAddBuff:New(info);
		elseif(info.script == "stun") then
			buff = StunBuff:New(info);
		elseif(info.script == "silent") then
			buff = SilentBuff:New(info);
		elseif(info.script == "still") then
			buff = StillBuff:New(info);
		elseif(info.script == "taunt") then
			buff = TauntBuff:New(info);
		elseif(info.script == "heal") then
			buff = HealBuff:New(info);
		elseif(info.script == "dot") then
			buff = DotBuff:New(info);
		elseif(info.script == "no_crit") then
			buff = NoCritBuff:New(info);
		elseif(info.script == "debuff_avoid") then
			buff = DebuffAvoidBuff:New(info);
		elseif(info.script == "change") then
			buff = ChangeBuff:New(info);
		elseif(info.script == "force") then
			buff = ForceBuff:New(info);
		elseif(info.script == "invincibility") then
			self._cantSelectBuffCount = self._cantSelectBuffCount + 1
			buff = AbsBuff:New(info);
		else			
			buff = AbsBuff:New(info);
		end
		return buff;
	end
	return nil;
end

function BuffController:GetBuffs()
	return self._buffs;
end

function BuffController:HasBuffAction()
	for i, v in pairs(self._buffs) do
		if(v.action_id ~= nil and v.action_id ~= "") then
			return true
		end
	end
	return false;
end

function BuffController:GetBuff(id)
	for i, v in pairs(self._buffs) do
		if(v.info.id == id) then return v end
	end
	return nil
end

function BuffController:Add(caster, id, level, time, overlap)
	
	local buff = self:GetBuff(id);
	local isHasBuff = false;
	if(buff) then
		if(buff.info.level == level) then
			isHasBuff = true;
		else
			self:RemoveBuff(buff.info.id);
		end
	end
	
	if(isHasBuff) then
		buff:Reset(time);
		buff:SetOverlap(overlap);
	else
		buff = self:_CreateBuff(id, level)
		if(buff) then
			buff:SetController(self)
			buff:SetOverlap(overlap);
			buff:Start(self._role);
			buff:SetCaster(caster)
			buff:Reset(time);
			table.insert(self._buffs, buff)			
			self:Dispatch(BuffController.EVENT_ADDBUFF, buff)
		end
	end
	if(self._role and self._role.__cname == "HeroController") then
		self._role:CalculateAttribute(HeroController.CalculateAttrType.Buffer)
	end
	return buff;
end

function BuffController:ResetEffectPos()
	for i, v in pairs(self._buffs) do
		v:ResetEffectPos();
	end
end

function BuffController:GetBuffAllAttributs()
	local attrs = {};
	for i, v in pairs(self._buffs) do
		if(v.attributs) then
			for ii, vv in pairs(v.attributs) do
				if v.info.add_type == 1 then
					vv = v.overlap * vv
				end
				if(attrs[ii] ~= nil) then
					attrs[ii] = attrs[ii] + vv
				else
					attrs[ii] = vv
				end
			end
			-- table.copyTo(v.attributs, attrs);
		end
	end
	return attrs;
end

function BuffController:RemoveBuff(id, dispose)
	local blDispose = dispose or true;
	local len = #self._buffs;
	for i = len, 1, - 1 do
		local buff = self._buffs[i];
		if(buff.info.id == id) then
			if(buff.info.script == "invincibility") then
				self._cantSelectBuffCount = self._cantSelectBuffCount - 1
			end
			table.remove(self._buffs, i);
			if(dispose) then
				buff:Stop();
			end
			if(self._role and self._role.__cname == "HeroController") then
				self._role:CalculateAttribute(HeroController.CalculateAttrType.Buffer)
			end
			self:Dispatch(BuffController.EVENT_REMOVEBUFF, buff)
			return
		end
	end
end

function BuffController:RemoveAll(isFilter)
	for i, v in pairs(self._buffs) do
		if isFilter and v.info.is_dead_clear then
			v:Stop();
		end
	end
	
	if(self._role and self._role.__cname == "HeroController") then
		self._role:CalculateAttribute(HeroController.CalculateAttrType.Buffer)
	end
	if(isFilter ~= true) then
		self._buffs = {};
	end
	self._canSelect = true
	self:Dispatch(BuffController.EVENT_REMOVEBUFF)
end

function BuffController:Dispose()	
	self:RemoveAll();
	self._listers = nil;
	self._role = nil;
end

-- ????Buff?????????????????????? ??????????
-- enable:true ????????????buffer false????????????????buffer
function BuffController:SetBuffActive(enable)
	
	for i, v in pairs(self._buffs) do
		if(v:IsDisapper()) then
			v:SetActive(enable)
		end
	end
end

--获取该角色是否可以选择(没有不可选择的buffer的时候就是可选择)
function BuffController:GetCanSelect()
	return self._cantSelectBuffCount == 0
end
