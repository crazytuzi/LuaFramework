require("game/arena/arena_fight_view")

ArenaFight = ArenaFight or BaseClass(BaseView)
function ArenaFight:__init()
	self.ui_config = {"uis/views/arena_prefab","ArenaFight"}
	self.view_layer = UiLayer.MainUI
	self.hide = false
end

function ArenaFight:__delete()
end

function ArenaFight:LoadCallBack()
	self.count_panel = self:FindObj("CountPanel")

	self.fight_panel = self:FindObj("FightPanel")
	self.fight_view = ArenaFightView.New(self.fight_panel)

	self.block = self:FindObj("Block")

	self:ListenEvent("ClickExit",
		BindTool.Bind(self.ClickExit, self))
end

function ArenaFight:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	self.count_panel = nil
	self.fight_panel = nil
	self.fight_view = nil
	self.block = nil
end

function ArenaFight:OpenCallBack()
	self:OpenFightView()
	self.fight_view:OpenCallBack()
end

function ArenaFight:OnFlush()
end

function ArenaFight:OpenFightView()
	self:CloseAllView()
	if self.fight_panel then
		self.fight_panel:SetActive(true)
		self.fight_view:StartCountDown()
	end
end

function ArenaFight:CloseAllView()
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

function ArenaFight:StartFight()
	self:OpenFightView()
	if self.block then
		self.block:SetActive(false)
	end
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

function ArenaFight:OpenRewardPanel()
	self:CloseAllView()
end

function ArenaFight:ClickExit()
	local func = function()
		self:OpenRewardPanel()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit2, nil, nil, false)
end