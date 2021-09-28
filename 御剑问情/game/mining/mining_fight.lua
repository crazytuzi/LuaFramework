require("game/mining/mining_fight_view")

MiningFight = MiningFight or BaseClass(BaseView)
function MiningFight:__init()
	self.ui_config = {"uis/views/mining_prefab","MiningFight"}
	self.view_layer = UiLayer.MainUI
	self.hide = false
end

function MiningFight:__delete()
end

function MiningFight:LoadCallBack()
	self.count_panel = self:FindObj("CountPanel")

	self.fight_panel = self:FindObj("FightPanel")
	self.fight_view = MiningFightView.New(self.fight_panel)

	self.block = self:FindObj("Block")

	self:ListenEvent("ClickExit",
		BindTool.Bind(self.ClickExit, self))
end

function MiningFight:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	self.count_panel = nil
	self.fight_panel = nil
	self.fight_view = nil
	self.block = nil
end

function MiningFight:OpenCallBack()
	self:OpenFightView()
	self.fight_view:OpenCallBack()
end

function MiningFight:OnFlush()
end

function MiningFight:OpenFightView()
	self:CloseAllView()
	if self.fight_panel then
		self.fight_panel:SetActive(true)
		self.fight_view:StartCountDown()
	end
end

function MiningFight:CloseAllView()
	if self.fight_panel then
		self.fight_panel:SetActive(false)
	end
	if self.count_panel then
		self.count_panel:SetActive(false)
	end
	if self.block then
		self.block:SetActive(true)
	end
	if self.fight_view then
		self.fight_view:CloseCallBack()
	end
end

function MiningFight:StartFight()
	self:OpenFightView()
	if self.block then
		self.block:SetActive(false)
	end
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

function MiningFight:OpenRewardPanel()
	self:CloseAllView()
end

function MiningFight:ClickExit()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit3, nil, nil, false)
end