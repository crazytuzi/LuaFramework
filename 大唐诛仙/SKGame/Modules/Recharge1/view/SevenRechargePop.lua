SevenRechargePop = BaseClass(BaseView)

SevenRechargePop.CELL_NUM = 3
function SevenRechargePop:__init(...)
	self.URL = "ui://wvu017cppzhgu"
	self:RegistUI()
	self:Config()
	self:InitEvent()
	self.isInited = true
end
function SevenRechargePop:Config()
	self.model = RechargeModel:GetInstance()
end
function SevenRechargePop:RegistUI()
	self.ui = UIPackage.CreateObject("Recharge", "SevenRechargePop")
	self.comContent = self.ui:GetChild("comContent")
	self.btnClose = self.ui:GetChild("btnClose")
	self.n3 = self.comContent:GetChild("n3")
	self.n3.visible = false
	self.n15 = self.comContent:GetChild("n15")
	self.n15.visible = false
	self.n21 = self.comContent:GetChild("n21")
	self.n21.visible = true
	self.btnRechardDaily = self.comContent:GetChild("btnRechardDaily")
	self.rechardNumDaily = self.comContent:GetChild("rechardNumDaily")
	self.textTime = self.comContent:GetChild("textTime")
	self.textDesc = self.comContent:GetChild("textDesc")
	self.cells = {}
	for i = 1, SevenRechargePop.CELL_NUM do
		self.cells[i] = self.comContent:GetChild("cell" .. i)
	end
end

function SevenRechargePop.Create(ui, ...)
	return SevenRechargePop.New(ui, "#", {...})
end

function SevenRechargePop:__delete()
	self:RemoveEvent()
	self.model = nil
	GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.SevenRecharge, show = false, isClose = true})
end

function SevenRechargePop:RefreshUI()
	local state, idx = self.model:GetSevenState()
	local cfg = GetCfgData("chargeActivity"):Get(idx)
	if not cfg then return end
	self:RefreshRechargeNum()
	self:RefreshTimeArea(cfg, state)
	self:RefreshCells(cfg)
end

function SevenRechargePop:RefreshTimeArea(cfg, state)
	local startM, startD = self.model:GetTimeMDByStr(cfg.startDate)
	local endM, endD = self.model:GetTimeMDByStr(cfg.endDate)
	self.textTime.text = StringFormat("{0}月{1}日-{2}月{3}日", startM, startD, endM, endD-1)
	if state == RechargeConst.SevenState.Open then
		self.textDesc.text = "(奖励通过邮件发放)"
		self.textDesc.color = newColorByString("1EFF00")
	else
		self.textDesc.text = "(活动未开启)"
		self.textDesc.color = newColorByString("FF0000")
	end
end

function SevenRechargePop:RefreshRechargeNum()
	self.rechardNumDaily.text = StringFormat("{0}元", self.model:GetSevenRechargeNum())
end

function SevenRechargePop:RefreshCells(cfg)
	for i = 1, SevenRechargePop.CELL_NUM do
		self:RefreshOneCell(self.cells[i], i, cfg)
	end
end

function SevenRechargePop:RefreshOneCell(cell, idx, cfg)
	local imgFlag = cell:GetChild("imgFlag")
	--local imgTitle = cell:GetChild("imgTitle")
	local txtCost = cell:GetChild("txtCost")
	local imgCost = cell:GetChild("imgCost")
	local txtRecNum = cell:GetChild("txtRecNum")

	local comRewardList = {}
	for i = 1, SevenRechargeContent.CELL_NUM do
		comRewardList[i] = cell:GetChild("comReward" .. i)
	end

	local comRewardTab = cell:GetChild("comReward")
	local songStrTab = { "song", "zaisong", "yifa" }
	--local yuanStrTab = { "30", "60", "100" }
	local rewardId = cfg.rewardStr[idx]
	if not rewardId then return end
	local songStr
	if self.model:IsSevenRewardGot(rewardId) then
		songStr = songStrTab[3]
	elseif idx == 1 then
		songStr = songStrTab[1]
	else
		songStr = songStrTab[2]
	end
	local songUrl = UIPackage.GetItemURL("Recharge", songStr)
	imgFlag.url = songUrl
	-- local yuanUrl = UIPackage.GetItemURL("Recharge", yuanStrTab[idx] .. "yuan")
	-- imgTitle.url = yuanUrl

	local num = GetCfgData("reward"):Get(rewardId).condition
	txtRecNum.text = num

	txtCost.text = cfg.des[idx] or ""
	imgCost.url = "Icon/Goods/diamond"

	local rewardList = self.model:GetRewardListByRewardId(rewardId)
	local comIdx = 1
	for i = 1, #comRewardList do
		if #rewardList == i then
			comRewardList[i].visible = true
			comIdx = i
		else
			comRewardList[i].visible = false
		end
	end
	self:RefreshComReward(cell, comIdx, rewardList)
end

function SevenRechargePop:RefreshComReward(com, idx, rewardList)
	rewardList = self.model:TransRewardToVo(rewardList)
	if idx == 1 then
		local imgReward = com:GetChild("imgReward11")
		local txtReward = com:GetChild("txtReward11")
		local vo = rewardList[i]
		imgReward.url = GoodsVo.GetIconUrl(vo.goodsType, vo.bid)
		txtReward.text = StringFormat("{0}X{1}", vo.cfg.name, vo.num)
	else
		for i = 1, idx do
			local str = StringFormat("item{0}{1}", idx, i)
			local item = com:GetChild(str)
			if item then
				self:RefreshOneCellCom(item, i, rewardList[i])
			end
		end
	end
end

function SevenRechargePop:RefreshOneCellCom(item, idx, vo)
	local imgReward = item:GetChild("imgReward")
	local txtRewardName = item:GetChild("txtRewardName")
	local txtRewardNum = item:GetChild("txtRewardNum")
	imgReward.url = GoodsVo.GetIconUrl(vo.goodsType, vo.bid)
	txtRewardName.text = vo.cfg.name
	txtRewardNum.text = StringFormat("X{0}", vo.num)
end

function SevenRechargePop:InitEvent()
	self.btnRechardDaily.onClick:Add( self.OnRechardDailyClick, self )
	self.btnClose.onClick:Add( self.OnCloseClick, self )
	local function OnSevenData()
		self:RefreshUI()
	end
	self._hGetSevenData = self.model:AddEventListener(RechargeConst.E_GetSevenPayData, OnSevenData)
end

function SevenRechargePop:RemoveEvent()
	if self.model then
		self.model:RemoveEventListener(self._hGetSevenData)
	end
end

function SevenRechargePop:OnRechardDailyClick()
	MallController:GetInstance():OpenMallPanel(0, 2)
end

function SevenRechargePop:OnCloseClick()
	self:Close()
end