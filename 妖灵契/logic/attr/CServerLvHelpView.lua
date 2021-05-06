local CServerLvHelpView = class("CServerLvHelpView", CViewBase)

function CServerLvHelpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/ServerLvHelpView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CServerLvHelpView.OnCreateView(self)
	self.m_DescLabel = self:NewUI(1, CLabel)
	self.m_ServerLvLabel = self:NewUI(2, CLabel)
	self.m_TipsLabel = self:NewUI(3, CLabel)
	self.m_BgTexture = self:NewUI(4, CSprite)
	self.m_CountDownLabel = self:NewUI(5, CCountDownLabel)
	self:InitContent()
end

function CServerLvHelpView.InitContent(self)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	self.m_DescLabel:SetText(data.helpdata.DATA.attr_main.content)
	self:Refresh()
end

function CServerLvHelpView.Refresh(self)
	self.m_ServerLvLabel:SetText(string.format("当前服务器等级：%s", g_AttrCtrl.server_grade))
	local gradeLimit = tonumber(data.globaldata.GLOBAL.player_gradelimit.value)
	if g_AttrCtrl.server_grade >= gradeLimit then
		self.m_CountDownLabel:DelTimer()
		self.m_CountDownLabel:SetText("[ff0000]当前服务器等级已达到最大")
	else
		for i,v in ipairs(data.servergradedata.DATA) do
			if v.server_grade > g_AttrCtrl.server_grade then
				self.m_NextGrade = v.server_grade
				break
			end
		end
		local curt = os.date("*t", 0)
		local iLeave = g_AttrCtrl.days * 86400 - ((g_TimeCtrl:GetTimeS() + curt.hour * 3600) % 86400)
		self.m_CountDownLabel:SetTickFunc(callback(self, "OnUpdate"))
		self.m_CountDownLabel:BeginCountDown(iLeave)
	end
	if g_AttrCtrl.grade >= gradeLimit then
		self.m_TipsLabel:SetText("[ff0000]已达到人物最大等级")
	else
		self.m_TipsLabel:SetText(g_AttrCtrl:GetServerGradeData().help_desc)
	end
end

function CServerLvHelpView.OnUpdate(self, iValue)
	if iValue < 60 then
		self.m_CountDownLabel:SetText(string.format("服务器等级即将提升至%s级", self.m_NextGrade))
	elseif iValue < 86400 then
		local hour = math.modf(iValue / 3600)
		local min = math.modf((iValue - hour * 3600) / 60)
		self.m_CountDownLabel:SetText(string.format("%s小时%s分钟 后服务器等级提升至%s级", hour, min, self.m_NextGrade))
	else
		local day = math.modf(iValue / 86400)
		local hour = math.modf((iValue - day * 86400) / 3600)
		self.m_CountDownLabel:SetText(string.format("%s天%s小时 后服务器等级提升至%s级", day, hour, self.m_NextGrade))
	end
end

function CServerLvHelpView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:Refresh()
	end
end

return CServerLvHelpView