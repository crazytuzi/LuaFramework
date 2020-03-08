Activity.YuanXiaoDengMiAct = Activity.YuanXiaoDengMiAct or {}
local tbAct = Activity.YuanXiaoDengMiAct;

----------------对服务器的接口----------------------
--获取问题信息
function tbAct:TryGetQuestions()

end

--试图答题
function tbAct:TryAnswerQuestion(nNpcId, nQuestionId, nTry)
	-- body
end

--------------服务器调用客户端接口------------------

--燃放烟花
function tbAct:PlayYanHuaEffect()
	local nEffect = MathRandom(1 , #tbAct.tbYanHuaTeXiao);
	Ui:PlayEffect(tbAct.tbYanHuaTeXiao[nEffect] or 9180,0,0,0);
end

--打开答题面板
function tbAct:OpenQuestionPanel(nQuestionId)
	if not tbAct.tbQuestion then
		tbAct:LoadSetting();
	end
	local tbInfo = tbAct.tbQuestion[nQuestionId];
	local tbData = {tbInfo.szTitle,tbInfo.szA1,tbInfo.szA2,tbInfo.szA3,tbInfo.szA4};
	local fnFunc = function(Idx)
		RemoteServer.YuanXiaoJieClientCall("TryAnswerQuestion",Idx);
		local tbUi = Ui.tbUi["QuestionAnswerPanel"];
		local bRight = false;
		if Idx == tbInfo.nAnswerId then bRight = true end;
		tbUi:OnSyncResult(bRight, Idx, tbInfo.nAnswerId);
	end
	Ui:OpenWindow("QuestionAnswerPanel",tbData,fnFunc);
end

function tbAct:OnSyncResult()

end

function tbAct:Test()
	tbAct:OpenQuestionPanel(1);
	-- Ui:OpenWindow("QuestionAnswerPanel",tbData)
	-- local tbUi = Ui:GetClass("QuestionAnswerPanel");
	-- tbUi:OnSyncResult(true , 1, 2);
end
