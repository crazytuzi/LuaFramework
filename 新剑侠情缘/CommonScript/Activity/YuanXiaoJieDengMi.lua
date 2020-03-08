 if not MODULE_GAMESERVER then
    Activity.YuanXiaoDengMiAct = Activity.YuanXiaoDengMiAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("YuanXiaoDengMiAct") or Activity.YuanXiaoDengMiAct

--------------------------策划填写-------------------------------------
tbAct.nRequireLv = 20 			--参与玩家等级
tbAct.nHuaDengStayTime = 10*60 	--花灯存在时间
tbAct.nYuanXiaoStayTime = 5*60 	--元宵存在时间
tbAct.nPlayerAnswerLimit = 8	--玩家答题上限
tbAct.nPlayerCollectLimit = 8	--玩家采集上限

tbAct.tbDengMiAward = {{"Contrib", 200},{"BasicExp", 15}};	--答对灯谜奖励

tbAct.nYuanXiaoNpcId = 3431;			--元宵NPCid
tbAct.nHuaDengNpcId = 3430;				--花灯NPCid
tbAct.nAnswerRate = 1;					--答对题目数与元宵比例
tbAct.tbYanHuaTeXiao = {9302,9303};		--答对题目时燃放的烟花特效(随机);
tbAct.tbExartFire = {10310,10311};		--随机奖励烟花
tbAct.nExartFireTime = 3*24*60*60;		--烟花过期时间
tbAct.nYuanXiaoAward = 10302;			--吃元宵的随机奖励;
function tbAct:LoadSetting()
	local tbFile = Lib:LoadTabFile("Setting/Activity/YuanXiaoJieDengMi.tab", {nAnswerId = 1, nA1 = 1, nA2 = 2, nA3 = 1, nA4 = 1})
	self.tbQuestion = {}
	for nIdx, tbInfo in ipairs(tbFile) do
		tbInfo.nId = nIdx
		self.tbQuestion[tbInfo.nId] = tbInfo
	end
	if MODULE_GAMESERVER then 
		local tbPosFile = Lib:LoadTabFile("Setting/Activity/YuanXiaoJieDengMiNpcPos.tab", {nMapId = 1, nX = 1, nY = 1})
		tbAct.tbHuaDengPos = tbPosFile;
	end
end

