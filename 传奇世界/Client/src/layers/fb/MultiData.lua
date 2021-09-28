-- -- 新多人守卫 数据层

-- MultiData = class("MultiData");

-- function MultiData:Init()
--     self:ClearSelfTeamInfo();
    
--     -- 队伍列表信息
--     self.m_listFbId = 0;
--     self.m_teamNum = 0;
--     self.m_teamInfo = nil;

--     self.m_callbacks = {};

--     self.m_curLvl = 1;
-- end

-- function MultiData:ExecuteCallback(name, para)
--     if self.m_callbacks == nil then
--         return;
--     end

--     if self.m_callbacks[name] ~= nil then
--         self.m_callbacks[name](para);
--     end
-- end

-- function MultiData:RegisterCallback(name, func)
--     self.m_callbacks[name] = func;
-- end

-- function MultiData:ClearSelfTeamInfo()
--     -- 自身队伍信息
--     self.m_currTeamId = 0;
--     self.m_fbId = 0;
--     self.m_battleRequire = 0;
--     self.m_teamMemNum = 0;
--     self.m_teamMemInfo = nil;
-- end

-- function MultiData:ShowLeaveTeamTips()
--     local str = getConfigItemByKeys("clientmsg",{"sth","mid"},{EVENT_COPY_SETS, 14})
--     TIPS(str);
-- end