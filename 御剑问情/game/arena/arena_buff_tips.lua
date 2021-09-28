ArenaBuffTips = ArenaBuffTips or BaseClass(BaseView)

function ArenaBuffTips:__init()
	self.ui_config = {"uis/views/arena_prefab", "ArenaBuffBuyTips"}
	self.view_layer = UiLayer.Pop
end

function ArenaBuffTips:__delete()

end

function ArenaBuffTips:LoadCallBack()
	self.damage_text = self:FindVariable("damage_text")
	self.hp_text = self:FindVariable("hp_text")
	self.money_text = self:FindVariable("money_text")
	self.before_one = self:FindVariable("before_one")
	self:ListenEvent("IsBuy", BindTool.Bind(self.OnClickIsBuy, self))
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
end

function ArenaBuffTips:ReleaseCallBack()
	-- 清理变量和对象
	self.damage_text = nil
	self.hp_text = nil
	self.money_text = nil
	self.before_one = nil
end

function ArenaBuffTips:OpenCallBack()
	self:Flush()
end

function ArenaBuffTips:OnFlush()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	self.damage_text:SetValue(cfg.buff_add_gongji_per / 100)
	self.hp_text:SetValue(cfg.buff_add_maxhp_per / 100)
	self.money_text:SetValue(cfg.buy_buff_gold)
	self.before_one:SetValue(ArenaData.Instance:GetBuffBuyTimes())
end

function ArenaBuffTips:ClickClose()
	self:Close()
end

function ArenaBuffTips:OnClickIsBuy()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local buy_times = ArenaData.Instance:GetBuffBuyTimes()
	local max_guwu = cfg.buy_buff_times_max
	if buy_times >= max_guwu then
		return TipsCtrl.Instance:ShowSystemMsg(Language.FB.InspireLimit)
	end
	local need_money = cfg.buy_buff_gold
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.gold >= need_money then
		ArenaCtrl.Instance:ReqArenaBuff()
	else
		TipsCtrl.Instance:ShowLackDiamondView()
	end
end

