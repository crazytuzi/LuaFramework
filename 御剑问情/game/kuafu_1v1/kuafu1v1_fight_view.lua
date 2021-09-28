require("game/kuafu_1v1/kuafu1v1_view_fight")

KuaFu1v1FightView = KuaFu1v1FightView or BaseClass(BaseView)

function KuaFu1v1FightView:__init()
	self.ui_config = {"uis/views/kuafu1v1_prefab","KuaFu1v1Fight"}
	self.view_layer = UiLayer.MainUI
	self.hide = false
end

function KuaFu1v1FightView:__delete()
end

function KuaFu1v1FightView:LoadCallBack()
	self.count_panel = self:FindObj("CountPanel")

	self.fight_panel = self:FindObj("FightPanel")
	self.fight_view = KuaFu1v1ViewFight.New(self.fight_panel)

	self.block = self:FindObj("Block")

	self:ListenEvent("ClickExit",
		BindTool.Bind(self.ClickExit, self))
end

function KuaFu1v1FightView:ReleaseCallBack()
	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end
	self.count_panel = nil
	self.fight_panel = nil
	self.block = nil
end

function KuaFu1v1FightView:OpenCallBack()
	self:OpenFightView()
end

function KuaFu1v1FightView:OnFlush()

end

function KuaFu1v1FightView:OpenFightView()
	self:CloseAllView()
	if self.fight_panel then
		self.fight_panel:SetActive(true)
		self.fight_view:StartCountDown()
	end
end

function KuaFu1v1FightView:CloseAllView()
	if self.fight_panel then
		self.fight_panel:SetActive(false)
	end
	if self.count_panel then
		self.count_panel:SetActive(false)
	end
	if self.block then
		self.block:SetActive(true)
	end
end

function KuaFu1v1FightView:StartFight()
	self:OpenFightView()
	if self.block then
		self.block:SetActive(false)
	end
	if self.fight_view then
		self.fight_view:StartFight()
	end
end

function KuaFu1v1FightView:OpenRewardPanel(result)
	self:CloseAllView()
	if self.fight_view then
		self.fight_view:ClearInfo()
	end
	-- if result == 1 then
	-- 	if self.vector_panel then
	-- 		self.vector_panel:SetActive(true)
	-- 		self.vector_view:Flush()
	-- 	end
	-- else
	-- 	if self.loser_panel then
	-- 		self.loser_panel:SetActive(true)
	-- 		self.loser_view:Flush()
	-- 	end
	-- end
end

function KuaFu1v1FightView:ClickExit()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Kuafu1V1.Exit, nil, nil, false)
end