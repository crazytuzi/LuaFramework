ClanGuildBossPane = BaseClass(LuaUI)
function ClanGuildBossPane:__init()
	local ui = UIPackage.CreateObject("Duhufu","GuildBossPane")
	self.ui = ui
	self.t1 = self.ui:GetChild("t1")
	self.b1 = self.ui:GetChild("b1")
	self.b2 = self.ui:GetChild("b2")
	self.b3 = self.ui:GetChild("b3")
	self.close = self.ui:GetChild("close")

	self:Layout()

end

function ClanGuildBossPane:Layout()
	self.b1.onClick:Add(function()
		ClanCtrl:GetInstance():C_CallManorBoss()
		UIMgr.HidePopup(self.ui)
	end)
	self.b2.onClick:Add(function ()
		local num = PkgModel:GetInstance():GetTotalByBid(GetCfgData("constant"):Get(75).value)
		if num == 0 then UIMgr.Win_FloatTip("您背包没有精华！") return end
		ConfirmNum.Show(StringFormat("您背包总共拥有{0}个精华，请滑动下面滑动条以选择要提交的数量",num),
		"提示", "提交", "取消", function (v)
			if v == 0 then return end
			ClanCtrl:GetInstance():C_FeedManorBoss(v)
		end, nil, num, num)
	end)
	self.b3.onClick:Add(function()
		PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.refined)
		UIMgr.HidePopup(self.ui)
	end)
	self.close.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
	end)
end
function ClanGuildBossPane:Update( msg )
	self.msg = msg
	self.t1.text = StringFormat(ClanConst.guildBossPaneContent,
		GetCfgData("constant"):Get(73).value,
		msg.callNum,
		msg.feedNum,
		GetCfgData("constant"):Get(74).value)
end

function ClanGuildBossPane:__delete()
	
end