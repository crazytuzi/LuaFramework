WarTaxPane = BaseClass(LuaUI)
function WarTaxPane:__init()
	local ui = UIPackage.CreateObject("Duhufu","WarTaxPane")
	self.ui = ui
	self.t1 = ui:GetChild("t1")
	self.t2 = ui:GetChild("t2")
	self.t3 = ui:GetChild("t3")
	self.b1 = ui:GetChild("b1")
	self.b2 = ui:GetChild("b2")
	self.b3 = ui:GetChild("b3")
	self.b5 = ui:GetChild("b5")
	self.b6 = ui:GetChild("b6")
	self.b4 = ui:GetChild("b4")
	self.close = ui:GetChild("close")
	self:Layout()
	self:InitEvent()
end

function WarTaxPane:Layout()
	local model = ClanModel:GetInstance()
	local msg = model.tax
	self.t1.text = StringFormat("{0} (都护府)", msg.guildName)
	self.t2.text = msg.headerName
	self.t3.text = ClanConst.warTaxContent
	local msg = model.tax
	if msg.openFB == 0 then
		self.b6.title = "开启凌烟阁"
	else
		self.b6.title = "进入凌烟阁"
	end
end
function WarTaxPane:InitEvent()
	local model = ClanModel:GetInstance()
	self.close.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
	end)

	self.b4.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
		UIMgr.ShowCenterPopup(WarJieshaoPane.New(),function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(WarTaxPane.New(), nil, true)
			end, 0.1)
		end, true)
	end)

	
	self.b1.onClick:Add(function ()
		local msg = model.tax
		UIMgr.HidePopup(self.ui)
		UIMgr.Win_Confirm("提示", 
			StringFormat("昨日累计税收：{0}金币,\n未领取税收：{1}金币。", msg.allRevenue, msg.revenue),
			"领取", "取消", function ()
			ClanCtrl:GetInstance():C_ReceiveRevenue()
		 	msg.revenue=0
		end, nil)
	end)
	self.b2.onClick:Add(function ()
		local msg = model.tax
		UIMgr.HidePopup(self.ui)
		UIMgr.Win_Confirm("提示", 
			StringFormat("长安城会根据昨日的税收额来给成员发放俸禄。\n都护府今日剩余俸禄份数{0}/{1}, \n可领取俸禄：{2}金币。",
			msg.salaryNum,GetCfgData("constant"):Get(71).value,msg.salary),
		 	"领取", "取消", function ()
			ClanCtrl:GetInstance():C_ReceiveSalary()
		end, nil)
	end)
	self.b3.onClick:Add(function ()
		local msg = model.tax
		ClanCtrl:GetInstance():C_ReceiveGift()
	end)
	self.b5.onClick:Add(function ()
		ClanCtrl:GetInstance():C_GetGuildBuyData()
	end)
	self.b6.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
		local msg = model.tax
		if msg.openFB == 0 then
			UIMgr.Win_Confirm("提示", "您确定要开启凌烟阁（副本）！",
			 	"确认", "取消", function ()
				ClanCtrl:GetInstance():C_GuildFB(1)
			end, nil)
		else
			-- UIMgr.Win_Confirm("提示", "您确定要进入凌烟阁（副本）！"),
			--  "确认", "取消", function ()
			ClanCtrl:GetInstance():C_GuildFB(2)
			-- end, nil)
		end
	end)
end

function WarTaxPane:__delete()
	
end