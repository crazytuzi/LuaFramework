--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-3-23
-- 版  本:	2.0.19
-- 描  述:   开服7天累计消耗奖励
-- 应  用:  
---------------------------------------------------------------------------------------

Act_TotalCost = class("Act_TotalCost",Act_Template)
Act_TotalCost.__index = Act_Template

--初始化
function Act_TotalCost:init(panel, tbItemList)
	if not panel then
		return 
	end
    self.super.init(self, panel, tbItemList)
    self.mTotalCostTtf = tolua.cast(panel:getChildByName("Label_CurrentNum"), "Label")
    --设置累计消耗元宝数
    self:setTotalCost(g_Hero:getTotalCostYuanBao())
end

function Act_TotalCost:updateStatus()
    if not self.tbMissions then
        --活动不存在或者活动已经结束
		return false
	end
    local rank_again = false
    --判断当前任务的状态是否已经更新
    for i,v in pairs(self.tbMissions) do
        if self.tbMissions_old[i] ~= v then
            rank_again = true
            self.tbMissions_old[i] = v
        end
    end
    
    if rank_again then --任务状态已经更新，更新listView
        self:sortAndUpdate()
    end
    --设置累计消耗元宝数
    self:setTotalCost(g_Hero:getTotalCostYuanBao())
end

function Act_TotalCost:setTotalCost(yuanbao)
    local strTip = string.format(_T("您已累计消耗%d元宝"), yuanbao)
    self.mTotalCostTtf:setText(strTip)
end
