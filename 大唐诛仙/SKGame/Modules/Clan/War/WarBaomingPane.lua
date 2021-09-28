WarBaomingPane = BaseClass(LuaUI)
function WarBaomingPane:__init()
	local ui = UIPackage.CreateObject("Duhufu","WarBaomingPane")
	self.ui = ui
	self.t1 = ui:GetChild("t1")
	self.t2 = ui:GetChild("t2")
	self.t3 = ui:GetChild("t3")
	self.t4 = ui:GetChild("t4")
	self.b1 = ui:GetChild("b1")
	self.b2 = ui:GetChild("b2")
	self.b3 = ui:GetChild("b3")
	self.b4 = ui:GetChild("b4")
	self.b5 = ui:GetChild("b5")
	self.close = ui:GetChild("close")
	self:Layout()
	self:InitEvent()
end
function WarBaomingPane:Layout()
	local model = ClanModel:GetInstance()
	local msg = model.cityWar
	self.t1.text = msg.defendName
	self.t2.text = msg.attackName
	self.t3.text = ClanConst.warBaomingTimeContent
	self.t4.text = StringFormat([[1、必须为都护或副都护
					2、都护府成员数量达到{0}个
					3、报名费用{1}万金]],
					GetCfgData("constant"):Get(66).value,
					GetCfgData("constant"):Get(67).value/10000)
end
function WarBaomingPane:InitEvent()
	local model = ClanModel:GetInstance()
	self.close.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
	end)
	self.b4.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
		UIMgr.ShowCenterPopup(WarJieshaoPane.New(),function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(WarBaomingPane.New(), nil, true)
			end, 0.1)
		end, true)
	end)

	self.b1.onClick:Add(function () -- 报名
		if model.job < 2 then
			UIMgr.Win_FloatTip("操作失败，您的权限不足，只有都护或副都护才可以报名")
		else
			UIMgr.HidePopup(self.ui)
			UIMgr.Win_Confirm("提示", StringFormat("报名需要缴纳{0}金币费用,确认报名吗？",
				GetCfgData("constant"):Get(67).value),
			 "确认", "取消", function ()
				ClanCtrl:GetInstance():C_ApplyGuildFight()
			end, nil)
			
		end
	end)
	self.b2.onClick:Add(function () --成员列表
		ClanCtrl:GetInstance():C_GetGuildFights()
	end)
	self.b3.onClick:Add(function () --联盟
		ClanCtrl:GetInstance():C_GetUnions()
	end)
	self.b5.onClick:Add(function () --交攻城令
		local num = PkgModel:GetInstance():GetTotalByBid(GetCfgData("constant"):Get(68).value)
		if num == 0 then UIMgr.Win_FloatTip("您背包没有攻城令！") return end
		ConfirmNum.Show(StringFormat("您背包总共拥有{0}个攻城令，请滑动下面滑动条以选择要提交的数量",num),
		"提示", "提交", "取消", function (v)
			if v == 0 then return end
			ClanCtrl:GetInstance():C_SubmitItem(v)
		end, nil, num, num)
	end)
end

function WarBaomingPane:__delete()

end