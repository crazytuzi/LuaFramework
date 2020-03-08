--local tbActUi = Activity:GetUiSetting("IdiomsAct")
--
--tbActUi.nShowLevel = 30
--tbActUi.szTitle    = "有缘一线牵";
--tbActUi.szBtnText  = "前往"
----tbActUi.fnCall = function () tbActUi:GoNpc() end
--tbActUi.szBtnTrap  = "[url=pos:text, 10, 9570, 11560]"
--
--tbActUi.FuncContent = function (tbData)
--        local tbTime1 = os.date("*t", tbData.nStartTime)
--        local tbTime2 = os.date("*t", tbData.nEndTime)
--        local szContent = "    在下南宫飞云，见过各位武林朋友。这次我与惜花阿姨给大家出了个新点子：\n1、需前往[FFFE0D] 襄阳城 [-]寻找老板娘[FFFE0D] 公孙惜花 [-]开始进行本次的活动\n2、必须为[FFFE0D] 两人 [-]组成一队，且两人必须是[FFFE0D] 异性角色 [-]\n3、活动中，需要击杀小怪，每只被击败的小怪的名字，必须与上一只怪的名字首尾相连构成 成语接龙，如击败的第一只小怪名字是“飞鸿踏雪”，那么第二只小怪必须以“雪”字开头，如“雪月风花”\n4、5分钟内，连接的成语越多，击杀的小怪越多，奖励越高\n5、如果击杀的小怪没有构成成语接龙，则挑战失败\n\n奖励内容：\n    根据获得的[FFFE0D] 积分[-]，可获得一定的[FFFE0D] 贡献[-]，达到[FFFE0D] 40积分[-]可以获得[FFFE0D] 限量称号[-]\n诸位侠士，出发吧！"
--        local nMax = DegreeCtrl:GetMaxDegree("Idioms", me)
--        local nCompleteNum = math.min(DegreeCtrl:GetDegree(me, "Idioms"), nMax)
--        local szComplete = string.format("     [c8ff00]今日可参与次数：%d/%d", nCompleteNum, nMax)
--        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent, szComplete)
--end
--
function IdiomFuben:SynSwitch(nEndTime)
	self.nEndTime = nEndTime
end

function IdiomFuben:GetDegreeInfo()
	local szDegree = Calendar:GetDegree("Idioms")
	local szInfo = string.format("次数: %s", szDegree)
	return szInfo
end

function IdiomFuben:OnLeaveMap()
	Ui:CloseWindow("HomeScreenFuben","TeamFuben")
end--