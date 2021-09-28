ClanXXPanel = BaseClass(LuaUI)
function ClanXXPanel:__init( root )
	self.parent = root
	self.ui = UIPackage.CreateObject("Duhufu","XXPanel")
	self.btnGotoClan = self.ui:GetChild("btnGotoClan")
	self.btnEdit = self.ui:GetChild("btnEdit")
	self.inputNotice = self.ui:GetChild("inputNotice")
	self.label1 = self.ui:GetChild("label1")
	self.label2 = self.ui:GetChild("label2")
	self.label3 = self.ui:GetChild("label3")
	self.label4 = self.ui:GetChild("label4")
	self.label5 = self.ui:GetChild("label5")
	self.label6 = self.ui:GetChild("label6")
	self.label7 = self.ui:GetChild("label7")
	self.label8 = self.ui:GetChild("label8")
	self.label9 = self.ui:GetChild("label9")

	self.editable = false
	self.inputNotice.editable = self.editable

	self:Layout()

	self.btnEdit.onClick:Add(function (e)
		self.editable = not self.editable
		self.inputNotice.editable = self.editable
		if self.editable then
			self.btnEdit.title = "提交"
		else
			self.btnEdit.title = "编辑"
			if isExistSensitive(self.inputNotice.text) then
				UIMgr.Win_FloatTip("贵府公告存在不合法词语！")
				return
			end
			ClanCtrl:GetInstance():C_ModifyNotice(self.inputNotice.text)
		end
	end)

	self.btnGotoClan.onClick:Add(function (e)
		ClanCtrl:GetInstance():C_GuildManor()		
	end)
	
end

function ClanXXPanel:Layout()
	self.model = ClanModel:GetInstance()
	self:AddTo(self.parent)
	self:SetXY(186, 135)
end
function ClanXXPanel:Update()
	local model = self.model
	local clanInfo = model.clanInfo
	self.label1:GetChild("txtContent").text = clanInfo.guildName
	self.label2:GetChild("txtContent").text = clanInfo.headerName
	self.label3:GetChild("txtContent").text = clanInfo.level
	self.label4:GetChild("txtContent").text = clanInfo.memberNum
	self.label5:GetChild("txtContent").text = clanInfo.battleValue
	self.label6:GetChild("txtContent").text = clanInfo.buildNum
	self.label7:GetChild("txtContent").text = clanInfo.money
	self.label8:GetChild("txtContent").text = TimeTool.getYMDHMS(clanInfo.createTime)
	self.label9:GetChild("txtContent").text = model.contribution
	self.inputNotice.text = clanInfo.notice
	self.btnEdit.visible = model.job>1
end

function ClanXXPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		ClanCtrl:GetInstance():C_GetGuild()
	end
end

function ClanXXPanel:__delete()
end