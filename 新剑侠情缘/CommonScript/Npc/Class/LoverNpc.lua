
local tbNpc = Npc:GetClass("LoverNpc");

function tbNpc:OnDialog()
	local szText = "问世间情为何物，直教人生死相许！";
	local tbOptList = {};

	if BiWuZhaoQin:GetLover(me.dwID) and not self.bBiWuZhaoQinOpen then
		table.insert(tbOptList, { Text = "解除情缘关系", Callback = function () self:RemoveLover(); end});
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:OnBiWuZhaoQinStateChange(bOpen)
	self.bBiWuZhaoQinOpen = bOpen;
end

function tbNpc:RemoveLover(bConfirm)
	if not bConfirm then
		local nLover = BiWuZhaoQin:GetLover(me.dwID);
		if not nLover then
			me.CenterMsg("您没有情缘关系需要解除！");
			return;
		end

		local tbRoleInfo = KPlayer.GetRoleStayInfo(nLover or 0) or {szName = "无名"};
		me.MsgBox(string.format("您确定解除与侠士[FFFE0D]%s[-]的情缘关系吗？操作会[FFFE0D]立即生效[-]！", tbRoleInfo.szName), {{"确定", function ()
			self:RemoveLover(true);
		end}, {"取消"}})

		return;
	end

	local nOtherId = BiWuZhaoQin:RemoveLover(me);
	if not nOtherId then
		me.CenterMsg("您没有情缘关系需要解除！");
		return;
	end

	local tbRoleInfo = KPlayer.GetRoleStayInfo(nOtherId or 0) or {szName = "无名"};

	me.DeleteTitle(BiWuZhaoQin.nTitleId);
	Mail:SendSystemMail({
		To = nOtherId,
		Title = "情缘解除",
		Text = string.format("大侠，很遗憾的告诉您，侠士[FFFE0D]%s[-]于%s解除了与您的情缘关系！", me.szName, os.date("%Y年%m月%d日", GetTime())),
		From = "燕若雪",
	});

	local pOther = KPlayer.GetPlayerObjById(nOtherId);
	if pOther then
		BiWuZhaoQin:RemoveLover(pOther);
		pOther.DeleteTitle(BiWuZhaoQin.nTitleId);
	end
	me.CenterMsg(string.format("您解除了与侠士[FFFE0D]%s[-]的情缘关系！", tbRoleInfo.szName));
end

function tbNpc:TaskLove(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return 
	end
	LoverTask:AcceptTask(pPlayer)
end

function tbNpc:TodayLove(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return 
	end
	pPlayer.CallClientScript("Ui:OpenWindow", "LoverRecommondPanel")
end

function tbNpc:DoLoverTask(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return 
	end
	LoverTask:DoTask(pPlayer)
end