
local tbItem = Item:GetClass("ZhenQiNoLimitItem");
tbItem.SET_ZHENQI_VALUE = 20000 				-- 设置值
tbItem.USE_TIME_FRAME = "OpenLevel79" 			-- 使用时间轴
function tbItem:OnUse(it)
	if self.USE_TIME_FRAME and GetTimeFrameState(self.USE_TIME_FRAME) ~= 1 then
		me.CenterMsg("暂时不能使用", true)
		return
	end
	local nDegree = DegreeCtrl:GetDegree(me, "ZhenQiLimitCount")
	if nDegree < 1 then
		me.CenterMsg("今日已不能使用", true)
		return 
	end
	local nHave = me.GetMoney("ZhenQi")
	if nHave >= self.SET_ZHENQI_VALUE then
		me.CenterMsg(string.format("身上真气值已经超过%s", self.SET_ZHENQI_VALUE), true)
		return 
	end
	if not DegreeCtrl:ReduceDegree(me, "ZhenQiLimitCount", 1) then
		me.CenterMsg("次数扣除失败", true)
		return
	end	
	local nAdd = self.SET_ZHENQI_VALUE - nHave
	me.SendAward({{"ZhenQi", nAdd}}, true, true, Env.LogWay_ZhenQiNoLimitItem);
end

