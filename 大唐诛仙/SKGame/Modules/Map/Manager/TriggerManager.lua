-- -- 触发机制管理器
-- -- 所有注册了id(可以是字符串也可以是数值)的东西需，都触发到这来处理（条件， 机关， buff， 动作， 动作中的帧触发点）
-- TriggerManager =BaseClass()
-- function TriggerManager:__init( ... )
-- 	self.cfg = nil
-- end
-- function TriggerManager:GetCfg()
-- 	if not self.cfg then
-- 		self.cfg = GetLocalData( "Map/SceneCfg/CfgActionTrigger" )
-- 	end
-- 	return self.cfg
-- end

-- function TriggerManager:TrigId( id, data )
-- 	if self["handle"..id] then
-- 		self["handle"..id](self, data)
-- 	end
-- end

-- -- 受击变色
-- function TriggerManager:handle10000( data )
-- 	if data == nil then return end
-- 	data.obj:SetBodyColor( data.color )
-- end

-- -- 受指定帧动作中的id处理
-- function TriggerManager:handle10001( data )
-- 	if data.id == 10000 then
-- 	elseif data.id == 10001 then
		
-- 	end
-- end

-- function TriggerManager:GetInstance()
-- 	if TriggerManager.inst == nil then
-- 		TriggerManager.inst = TriggerManager.New()
-- 	end
-- 	return TriggerManager.inst
-- end
-- function TriggerManager:__delete()
-- 	TriggerManager.inst = nil
-- end