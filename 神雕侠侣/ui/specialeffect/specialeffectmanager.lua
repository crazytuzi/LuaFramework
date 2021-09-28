require "utils.tableutil"
SpecialEffectManager = {}
SpecialEffectManager.__index = SpecialEffectManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SpecialEffectManager.getInstance()
	LogInfo("enter get specialeffectmanager instance")
    if not _instance then
        _instance = SpecialEffectManager:new()
    end
    
    return _instance
end

function SpecialEffectManager.getInstanceNotCreate()
    return _instance
end

function SpecialEffectManager.Destroy()
	if _instance then 
		LogInfo("destroy specialeffectmanager")
		for k,v in pairs(_instance.m_lLocationEffect) do	
			if v.effect then
				XiaoPang.GetEngine():GetWorld().RemoveEffect(tolua.cast(XiaoPang.GetEngine():GetWorld(), "XiaoPang::IWorld"), v.effect)
			end
		end
		_instance.m_lLocationEffect = nil
		_instance.m_lScreenEffect = nil
		_instance = nil
	end
end

------------------- private: -----------------------------------

function SpecialEffectManager:new()
    local self = {}
	setmetatable(self, SpecialEffectManager)

	self.m_lScreenEffect = {}
	self.m_lLocationEffect = {}

    return self
end

function SpecialEffectManager:run(delta)
	if TableUtil.tablelength(self.m_lScreenEffect) == 0 and TableUtil.tablelength(self.m_lLocationEffect) == 0 then
		return
	end 
	
	local serverTime = GetServerTime()	
	local time = StringCover.getTimeStruct(serverTime / 1000)
	local year = time.tm_year + 1900
	local month = time.tm_mon + 1
	local day = time.tm_mday
	local hour = time.tm_hour
	local minute = time.tm_min
	local second = time.tm_sec
	local curTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
	for k,v in pairs(self.m_lScreenEffect) do
		if v.starttime < curTime and v.deadline > curTime then
			v.inTime = true
		else
			v.inTime = false
		end
	end
	for k,v in pairs(self.m_lScreenEffect) do
		if v.inTime then
			v.time = v.time - delta
			if v.time < 0 then
				local cp = XiaoPang.GetEngine():GetWorld().GetViewport(tolua.cast(XiaoPang.GetEngine():GetWorld(), "XiaoPang::IWorld"))
				XiaoPang.GetEngine():GetWorld().PlayEffect(tolua.cast(XiaoPang.GetEngine():GetWorld(), "XiaoPang::IWorld") , MHSD_UTILS.get_effectpath(v.effectid), v.layer, (cp.left+cp.right)/2, (cp.top+cp.bottom)/2, 1, false, 2)
				v.time = v.cd
			end
		end		
	end

	local temp = {}
	for k,v in pairs(self.m_lLocationEffect) do 
		if v.starttime < curTime and v.deadline > curTime then
			if not v.effect then
				v.effect = XiaoPang.GetEngine():GetWorld().SetEffect(tolua.cast(XiaoPang.GetEngine():GetWorld(),"XiaoPang::IWorld"), MHSD_UTILS.get_effectpath(v.effectid) , v.layer, v.xpos, v.ypos,true)
			end
		else
			if v.effect then
				XiaoPang.GetEngine():GetWorld().RemoveEffect(tolua.cast(XiaoPang.GetEngine():GetWorld(), "XiaoPang::IWorld"), v.effect)
			end
			table.insert(temp, k)
		end
	end
	for i,v in ipairs(temp) do
		self.m_lLocationEffect[v] = nil
	end

end

function SpecialEffectManager:InitScreenEffect()
	LogInfo("SpecialEffectManager InitScreenEffect")
	local effectTabel = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cspecialeffectlua")
	for k,v in pairs(effectTabel.m_cache) do
		if v.SpecialEffectstyle == 1 then
			local specialEffect = {}
			specialEffect.effectid = v.id
			specialEffect.starttime = v.starttime
			specialEffect.deadline = v.deadline
			specialEffect.cd = v.SpecialEffectCD * 1000
			specialEffect.time = 0
			specialEffect.inTime = false
			specialEffect.layer = v.Effectionlay
			table.insert(self.m_lScreenEffect, specialEffect)
		end	
	end

end

function SpecialEffectManager:InitLocationEffect()
	LogInfo("SpecialEffectManager InitLocationEffect")
	self.m_lLocationEffect = nil
	self.m_lLocationEffect = {}
	local effectTabel = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cspecialeffectlua")
	for k,v in pairs(effectTabel.m_cache) do
		if v.SpecialEffectstyle == 2 and GetScene() and v.SpecialEffectmapID == GetScene():GetMapID() then
			local specialEffect = {}
			specialEffect.effectid = v.id
			specialEffect.starttime = v.starttime
			specialEffect.deadline = v.deadline
			specialEffect.xpos = v.xposition 
			specialEffect.ypos = v.yposition 
			specialEffect.layer = v.Effectionlay
			table.insert(self.m_lLocationEffect, specialEffect)
		end
	end

end

return SpecialEffectManager
