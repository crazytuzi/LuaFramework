UPGRADE = 1
HonourView = HonourView or BaseClass(BaseView)
function HonourView:__init()
	self.ui_config = {"uis/views/honourview", "HonourView"}
	self.play_audio = true
	self:SetMaskBg()
end

function HonourView:__delete()
	
end

function HonourView:LoadCallBack()
	self.fight_power = self:FindVariable("FightPower")
	self.attack = self:FindVariable("attack")
	self.defend = self:FindVariable("defend")
	self.hp = self:FindVariable("hp")
	self.cur_level = self:FindVariable("curlevel")
	self.cur_honour = self:FindVariable("curhonour")
	self.up_grade = self:FindVariable("upgrade")
	self.red_point = self:FindVariable("redpoint")
	self.max_level = self:FindVariable("maxlv")
	self.raw_image = self:FindVariable("image")
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("GetOnClick",BindTool.Bind(self.UpGradeOnClick, self))
	self:ListenEvent("Help",BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("GetWay",BindTool.Bind(self.GetWayClick, self))
	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))
end

function HonourView:ReleaseCallBack()
	self.fight_power = nil
	self.attack = nil
	self.defend = nil
	self.hp = nil
	self.cur_level = nil
	self.cur_honour = nil
	self.up_grade = nil
	self.red_point = nil
	self.max_level = nil
	self.raw_image = nil

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end
end

function HonourView:OpenCallBack()
	HonourCtrl.Instance:SendHonourInfo()
	TimeCtrl.Instance:SendTimeReq()
end

function HonourView:CloseCallBack()

end

function HonourView:OnFlush(param_t)
	self:SetData()
end

function HonourView:SetData()
	local info = HonourData.Instance:GetHonourInfo()
	local power = HonourData.Instance:GetPowerFight(info.add_gongji,info.add_fangyu,info.add_hp)
	local need_exp = HonourData.Instance:GetAutoIndex(info.level)
	local limit_level = HonourData.Instance:GetMaxHonourLimit()
	self.attack:SetValue(info.add_gongji)
	self.defend:SetValue(info.add_fangyu)
	self.hp:SetValue(info.add_hp)
	-- self.cur_honour:SetValue(CommonDataManager.ConverMoney(info.honour))
	self.cur_honour:SetValue(info.honour)
	self.cur_level:SetValue(info.level)
	self.fight_power:SetValue(power)
	self.up_grade:SetValue(need_exp > info.honour and string.format(Language.Honour.UpGrade,need_exp) or need_exp)
	self.max_level:SetValue(limit_level)
	self.red_point:SetValue(HonourData.Instance:GetRemind() == 1)
	local bundle, asset = ResPath.GetHonourRawImage("honour_01")
	self.raw_image:SetAsset(bundle, asset)
end

function HonourView:UpGradeOnClick()
	HonourCtrl.Instance:SendHonourInfo(UPGRADE)
end

function HonourView:HelpClick()
	TipsCtrl.Instance:ShowHelpTipView(247)
end

function HonourView:GetWayClick()
	ViewManager.Instance:Open(ViewName.SpanBattleView)
end
