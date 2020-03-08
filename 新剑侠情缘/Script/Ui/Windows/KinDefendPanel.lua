local tbUi = Ui:CreateClass("KinDefendPanel")
tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnJoin = function(self)
		RemoteServer.TryJoinKinDefend()
		Ui:CloseWindow(self.UI_NAME)
	end,

	Difficulty1 = function(self)
		self:ChooseDifficulty(1)
		self:UpdateDifficulty()
	end,

	Difficulty2 = function(self)
		self:ChooseDifficulty(2)
		self:UpdateDifficulty()
	end,

	Difficulty3 = function(self)
		self:ChooseDifficulty(3)
		self:UpdateDifficulty()
	end,
}

function tbUi:OnOpen()
	self.bCanChoose = false
	self.nSelectIdx = 0
	self:UpdateDifficulty()
	for i=1, 3 do
		self.pPanel:Label_SetText("Number"..i, string.format("（推荐%d人）", Fuben.KinDefendMgr.Def.tbSuggestJoinCount[i]))
	end

	self.pPanel:Label_SetText("Time", "")
	self.pPanel:Label_SetText("TipTxtDesc", [[
[FFFE0D]介绍：[-]
·活动开启前[FFFE0D]族长[-]或[FFFE0D]副族长[-]需根据本家族情况选择难度挑战。
·家族成员需要齐心协力抵抗[FFFE0D]完颜宗翰[-]及其属下的进攻。
·[FFFE0D]八骠骑、八步将[-]死亡后会鼓舞友军士气，提高友军属性，大侠应均衡攻破。
·[FFFE0D]完颜宗翰[-]会一分为四，分别与我方[FFFE0D]4位[-]勇士决战，其他家族成员需尽力为[FFFE0D]4位[-]勇士提供支持。
·地图中会刷新不同属性的[FFFE0D]仙芝[-]，采集[FFFE0D]5个[-]可为相应的勇士提供[FFFE0D]1个[-]回春术技能。
·地图中会刷新不同属性的[FFFE0D]携宝斥候[-]，击杀[FFFE0D]5个[-]可为相应的勇士提供[FFFE0D]1个[-]光盾术技能。
	]])

	Fuben.KinDefendMgr:RefreshDifficulty()

	self.nTimer = Timer:Register(Env.GAME_FPS, function()
		self:UpdateTime()
		return true
	end)
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:UpdateTime()
	local szDesc = ""
	local nNow = GetTime()
	if self.tbDifficulty and (self.tbDifficulty.nPrepareEndTime or 0) > 0 and self.tbDifficulty.nPrepareEndTime > nNow then
		szDesc = string.format("准备时间：%s", Lib:TimeDesc(self.tbDifficulty.nPrepareEndTime - nNow))
	elseif not self.tbDifficulty or self.tbDifficulty.bCanSetDifficulty then
		szDesc = "挑战未开始"
	else
		szDesc = self.tbDifficulty.bStoped and "挑战未开始" or "挑战进行中"
	end
	self.pPanel:Label_SetText("Time", szDesc)
end

function tbUi:SetDifficulty(tbInfo)
	self.tbDifficulty = tbInfo
	self.tbDifficulty.bCanOperate = Kin:CanControlFuben(me.dwID)
	if tbInfo.nPrepareTime > 0 then
		self.tbDifficulty.nPrepareEndTime = GetTime() + tbInfo.nPrepareTime
	end
	self.nSelectIdx = tbInfo.nDifficulty

	self.bCanChoose = tbInfo.nDifficulty <= 0
	self:UpdateDifficulty()
end

function tbUi:ChooseDifficulty(nDifficulty)
	if not self.bCanChoose then
		me.CenterMsg("不可更改")
		return
	end

	if not self.tbDifficulty.bCanSetDifficulty then
		me.CenterMsg("不在可选难度时间段！")
		return
	end
	if not self.tbDifficulty.bCanOperate then
		me.CenterMsg("你没有权限！")
		return
	end

	local szDifficulty = {"简单", "普通", "困难"}
	local szMsg = string.format("是否选择今日活动的难度为%s？确认后将不能修改！", szDifficulty[nDifficulty])
    me.MsgBox(szMsg, {{"确定", function()
        self.nSelectIdx = nDifficulty
        self:UpdateDifficulty()
		Fuben.KinDefendMgr:ChooseDifficulty(nDifficulty)
    end}, {"取消"}})
end

function tbUi:UpdateDifficulty()
	for i=1, 3 do
		self.pPanel:Toggle_SetChecked("Difficulty"..i, i == self.nSelectIdx)
	end
end