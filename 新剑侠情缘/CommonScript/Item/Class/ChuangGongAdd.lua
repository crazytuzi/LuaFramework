local tbItem = Item:GetClass("ChuangGongAdd");
tbItem.ADD_ACCEPT_TIMES = 1					-- 增加的被传次数
tbItem.ADD_SEND_TIMES = 1					-- 增加的传功次数

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end
	if DegreeCtrl:GetDegree(me, "ChuangGongAdd") < 1 then
		me.CenterMsg("当天的使用次数达到上限！")
		return
	end
	if not DegreeCtrl:ReduceDegree(me, "ChuangGongAdd", 1) then
		me.CenterMsg("扣除次数失败！")
		return
	end

	DegreeCtrl:AddDegree(me, "ChuangGong", self.ADD_ACCEPT_TIMES);
	DegreeCtrl:AddDegree(me, "ChuangGongSend", self.ADD_SEND_TIMES);

	me.CenterMsg(string.format("您的传功次数增加%d次，被传功次数增加%d次",self.ADD_SEND_TIMES,self.ADD_ACCEPT_TIMES));
	
	return 1
end