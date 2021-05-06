local CMapBookScreenPage = class("CMapBookScreenPage", CPageBase)

function CMapBookScreenPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookScreenPage.OnInitPage(self)
	self.m_ContentLabel = self:NewUI(1, CLabel)
	self.m_ClickBox = self:NewUI(2, CWidget)
	self.m_ContiueLabel = self:NewUI(3, CLabel)
	self.m_ContiueLabel:SetActive(false)
	self.m_ClickBox:AddUIEvent("click", callback(self, "OnContinue"))
end

function CMapBookScreenPage.OnShowPage(self)
	local str = [[    世界由35%的大陆及65%的海洋组成。北方是世界的最高端，终年寒冷空气稀薄，生存环境十分恶劣。南方为一片汪洋，包围着所有陆地，海洋上布有零星岛屿至今少有人探索。东西两方陆地沿星球中轴线呈块状分布，主要分成3大块由海峡间隔，这里便是人类与妖怪们共同生存的区域。
    星球诞生之后，随着物种激烈进化，世界出现了最早的拟人态种群。通过繁衍及基因的优胜劣汰，世界终于分化出两个未来世界最强大的种族：人族和妖族。
    能力强大的妖怪能够优先在世界进化的恶劣环境下生存，而越平凡的人则只能依赖于妖怪。妖怪靠本身强大的环境适应能力，外形随环境变化而进化。人类擅长改造环境造就了强大的脑力，形成人的统一外形不继承任何基因进化。
    截然不同的生活习性使得两族进入无休止的纷争之中，这便是星球的记忆，世界的起源。]]
	self:SetContent(str)
	self.m_ContiueLabel:SetActive(false)
	self.m_ContentLabel:SetText("")
	self.m_ContentStr = str
end

function CMapBookScreenPage.SetContent(self, str)
	local strList = string.getutftable(str)
	local step = 1
	local n = 0
	local str = ""
	local function update()
		local i = 1
		local k = 0
		if Utils.IsNil(self) then
			return
		end
		while n <= #strList and k < 2 do
			if strList[n+i] then
				str = str..strList[n+i]
				if strList[n+i] ~= " " then
					k = k + 1
				end
				i = i + 1
			else
				self.m_ContentLabel:SetText(str)
				self:EndTextAni()
				return false
			end
		end
		self.m_ContentLabel:SetText(str)
		n = n + i - 1
		return true
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(update, 0.2, 0)
end

function CMapBookScreenPage.EndTextAni(self)
	self.m_ClickBox:SetActive(true)
end

function CMapBookScreenPage.OnContinue(self)
	if self.m_ContiueLabel:GetActive() then
		self.m_ParentView:ShowMainPage()
	else
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
		end
		self.m_ContentLabel:SetText(self.m_ContentStr)
		self.m_ContiueLabel:SetActive(true)
	end
end

return CMapBookScreenPage