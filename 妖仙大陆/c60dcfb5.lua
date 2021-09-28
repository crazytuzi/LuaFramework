

local _M = {}
_M.__index = _M

local Util = require 'Zeus.Logic.Util'

local acts = {}

local function GetWorldData(event)
	local r = event:GetRootEvent()
	return r:GetAttribute('world')
end


local function CreateAction(bt,data)
	local name = bt[1]
	local act
	
	if type(name) ~= 'string' then
		return bt
	end
	if name == "Sequence" or name == "Selector" or name == "Parallel" then
		act = DramaHelper.CreateAction(name)
		local children = {}
		local param = {}
		for i=2,#bt do
			local child = CreateAction(bt[i],data)
			if type(child) == 'table' then
				param = child
			else
				table.insert(children,child)
			end			
		end	
		act = DramaHelper.CreateAction(name,param)
		for _,child in ipairs(children) do
			act:AddChild(child)
		end
	elseif name == 'Skill' then
		
		local param = bt[2]
		local targetParam = param.target
		if param and targetParam then
			
			if type(targetParam) == 'table' then
				for i,uid in ipairs(targetParam) do
					if i == 1 then
						param.target = data.units[uid]
					else
						param['target'..(i-1)] = data.units[uid]
					end
				end
			else
				param.target = data.units[targetParam]
			end
		end
		
		act = DramaHelper.CreateAction(name,param or {})
	else
		act = DramaHelper.CreateAction(name,bt[2] or {})
	end
	return act
end

local function IndexTable(t,u)
	for k,v in pairs(t) do
		if v == u then
			return k
		end
	end
	return nil
end


local function OnCreateSpells(sender,param,data)
	local spell = SingleSpell.New()
	table.insert(data.spells,spell)
	spell:SetWorld(data.world)
	local act = CreateAction({"UnitLaunchSpell",param},data)
	if act then
		spell:AddAction(act)
	end
end

local function OnDamage(sender, param,data)
	local u = param.target
	local attack = param.attack
	local act = CreateAction({"Damage",{attack = attack}},data)
	u:AddAction(act)
		
	DramaHelper.SendMessageToAction(u,'Skill',{stop=true})	
end

local function OnRemoveUnit(sender, param,data)
	local k = IndexTable(data.units,sender)
	data.units[k] = nil
	sender:Dispose()
end

local function OnHandleMessage(name,sender,param,data)
	
	param = Util.DictionaryToLuaTable(param)
	if name == SingleWorld.CREATE_SPELL then
		OnCreateSpells(sender,param,data)
	elseif name == SingleWorld.SPELL_REMOVED then
		table.remove(data.spells,IndexTable(data.spells,sender))
	elseif name == SingleWorld.ATTACK_PROP then
		OnDamage(sender, param, data)
	elseif name == SingleWorld.REMOVE_UNIT then
		OnRemoveUnit(sender,param,data)
	end
end

function _M.StopActionByType(parent, uid, typeName)
	_M.SendMessageToAction(parent, uid, typeName, {stop=true})
end

function _M.SendMessageToAction(parent, uid, typeName, param)
	local units = GetWorldData(parent).units
	DramaHelper.SendMessageToAction(units[uid], typeName, param)	
end

function _M.StopAction(parent, uid, act_id)
	local acts = GetWorldData(parent).acts[uid]
	if not acts then return end
	local act = acts[act_id]
	if not act then return end
	act:Stop()
end

function _M._asyncRunAction(self, id, bt, tag)
	
	

	local data = GetWorldData(self)
	local act = CreateAction(bt,data)
	local unit = data.units[id]
	if not unit then return end
	act.LuaCallBack = function (result)
		if not result then
			print('action failed!')
		end
		self:Done(id, result)
		local temp = data.acts[id]
		for k,v in pairs(temp) do
			if v == act then
				temp[k] = nil
				break
			end
		end
	end
	if tag then
		act.Name = tag
	end
	if not data.acts[id] then
		data.acts[id] = {}
	end
	data.acts[id][self.id] = act
	unit:AddAction(act)
	self:Await()
end

function _M.Init(parent)
	local data = {
		units = {},
		spells = {},
		acts = {},		
	}
	data.world = SingleWorld.New(function (name,sender,param)
		OnHandleMessage(name,sender,param,data)
	end)
	local r = parent:GetRootEvent()
	r:SetAttribute('world',data)
	
	r:AddTimer(function (delta)
		
		for _,u in pairs(data.units) do
			u:Update(delta)
		end
		for _,s in pairs(data.spells) do
			s:Update(delta)
		end
	end)
end


function _M.CreateUnit(parent)
	local id = parent:GenerateSubId()
	local data = GetWorldData(parent)
	local u = SingleUnit.New()
	data.units[id] = u
	u:SetWorld(data.world)
	return id
end

function _M.GetUnitPos(parent, uid)
	local units = GetWorldData(parent).units
	
	return units[uid].X,units[uid].Y
end

function _M.GetUnitDirection(parent, uid)
	local units = GetWorldData(parent).units
	return units[uid].Direction
end

function _M.GetTemplateSkills(parent, uid)
	local units = GetWorldData(parent).units
	return {DramaHelper.GetUnitSkills(units[uid])}
end


function _M.FindBattleUnit(parent, templateId, param)
	local id = parent:GenerateSubId()
	local u = DramaHelper.FindBattleUnit(templateId,param or {})
	if u then
		local units = GetWorldData(parent).units
		units[id] = u
		u:SetWorld(GetWorldData(parent).world)
	end
	return id
end

function _M.Remove(parent, uid)
	local units = GetWorldData(parent).units
	units[uid]:Dispose()
	units[uid] = nil
end

function _M.CopyBattleUnit(parent,templateId,param)
	local id = parent:GenerateSubId()
	local u = DramaHelper.CopyBattleUnit(templateId,param or {})
	if u then
		local units = GetWorldData(parent).units
		units[id] = u
		u:SetWorld(GetWorldData(parent).world)
		return id
	end
end

function _M.CheckUnitLoadOK(parent,id)
	local units = GetWorldData(parent).units
	return units[uid].IsLoadOk
end

function _M._asyncWaitUnitLoadOk(self,uid)
	local units = GetWorldData(self).units
	local u = units[uid]
	self:AddTimer(function (delta)
		if u.IsLoadOk then
			self:Done()
		end
	end)
	self:Await()
end


function _M.Clear(parent)
	local data = GetWorldData(parent)
	if not data then return end
	for _,u in pairs(data.units) do
		u:Dispose()
	end
	for _,s in pairs(data.spells) do
		s:Dispose()
	end
	parent:RemoveTimer(parent.name..'-world')
end

return _M
