local WorldBossMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "WorldBossMediator"
	self.view = _view
	self:regSelf() 
end)
WorldBossMediator.protocolsList = {
   _G.Msg.ACK_WORLD_BOSS_REPLY,         -- 世界Boss面板返回      
   -- _G.Msg.ACK_WORLD_BOSS_XXX,           -- 世界Boss状态信息块
   -- _G.Msg.ACK_WORLD_BOSS_MAP_DATA,      -- 返回地图数据
   -- _G.Msg.ACK_WORLD_BOSS_WAR_RS,        -- 返回结果
   _G.Msg.ACK_WORLD_BOSS_SETTLEMENT,    -- 结算榜显示
   -- _G.Msg.ACK_WORLD_BOSS_SETTLE_DATA,   -- 结算块
   _G.Msg.ACK_ART_HOLIDAY,           --[16725]精彩活动节日奖励翻倍

  _G.Msg.ACK_WORLD_BOSS_BUY_INFO_ANS,  --世界BOSS购买信息返回
  -- _G.Msg.ACK_WORLD_BOSS_BUY_ANS,      -- 请求购买世界BOSS返回
}

function WorldBossMediator.ACK_ART_HOLIDAY( self,_ackMsg)
  print("ACK_ART_HOLIDAY==>>",_ackMsg.value)
    self.value=_ackMsg.value
end

function WorldBossMediator.ACK_WORLD_BOSS_REPLY( self, _ackMsg )
    local data1={}
    data1.count = _ackMsg.count      -- 信息块数量
    if data1.count~=0 then
    	print("世界Boss状态信息")
    	  self : getView():setBossState(_ackMsg.data,_ackMsg.count,self.value) -- 设置boss状态
      else
        self:getView():setBossState(0,_ackMsg.count,self.value)
    end
  
    -- self:ACK_WORLD_BOSS_XXX(_ackMsg.data)
    
end
-- function WorldBossMediator.ACK_WORLD_BOSS_XXX( self, data )
-- end
function WorldBossMediator.ACK_WORLD_BOSS_SETTLEMENT( self, _ackMsg )  -- 结算榜
    local data2={}
    data2.type=_ackMsg.type
    data2.count=_ackMsg.count
    if data2.count~=0 then
    	if _G.g_Stage:getScenesType()== _G.Const.CONST_MAP_TYPE_CLAN_BOSS then
			     self.rankView = require("mod.worldboss.WorldBossRankView")()
	         self.rankView:initRankView("击杀排行",_ackMsg.data)
	        _G.g_Stage.m_lpPlay:setAI(0)
       else
       		--self.view:setRankLab(_ackMsg.data,data2.count)
       		if  _G.g_Stage:getScenesType()== _G.Const.CONST_MAP_TYPE_BOSS then
       			self.view = require("mod.worldboss.WorldBossView")
       			_G.g_Stage.m_lpPlay:setAI(0)
       			self.view:initRankView("勾魂使者",_ackMsg.data,1,self.value)
       		else
       			self.view:initRankView("勾魂使者",_ackMsg.data,0,self.value)
       		end
       		
       end
    end
end
function WorldBossMediator.ACK_WORLD_BOSS_BUY_INFO_ANS(self,_ackMsg)
  print("ACK_WORLD_BOSS_BUY_INFO_ANS--->",_ackMsg.call_demand,_ackMsg.p_call_time,_ackMsg.w_call_time,_ackMsg.call_cost,_ackMsg.flag)
  self:getView() : updateZHLab(_ackMsg)
end 
-- function WorldBossMediator.ACK_WORLD_BOSS_BUY_ANS(self,_ackMsg)
--   self : getView() : ACK_WORLD_BOSS_BUY_ANS(_ackMsg)
-- end 

-- function WorldBossMediator.ACK_WORLD_BOSS_SETTLE_DATA( self, data )   
-- end
return WorldBossMediator