local tbItem = Item:GetClass("WeddingWelcome");
function tbItem:OnUse(it)
	if Wedding:IsPlayerMarring(me.dwID) then
		me.CenterMsg("您正在举行婚礼，暂不能前往", true)
		return 
	end
	if Wedding:IsPlayerTouring(me.dwID) then
		me.CenterMsg("您正在进行花轿游城，暂不能前往", true)
		return 
	end
	if not Env:CheckSystemSwitch(me, Env.SW_ChuangGong) then
		me.CenterMsg("当前状态不能前往", true)
		return 
	end
	if not Env:CheckSystemSwitch(me, Env.SW_Muse) then
		me.CenterMsg("当前状态不能前往", true)
		return 
	end
	local nMapId = it.GetIntValue(1)
	if not nMapId then
		return
	end
	local tbInst = Fuben.tbFubenInstance[nMapId]
	if not tbInst then
		me.CenterMsg("该场婚礼已经结束", true)
		return
	end
	tbInst:SynWelcomeInfo(me)
end

function tbItem:GetTip(it)
	if type(it) ~= "userdata" then
		return ""
	end
	local szNameStr = it.GetStrValue(1) or ""
	local szManName, szFemanName = unpack(Lib:SplitStr(szNameStr, ";"))
	return string.format("新郎：%s\n新娘：%s", szManName or "", szFemanName or "")
end