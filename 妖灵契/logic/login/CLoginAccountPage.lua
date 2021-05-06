local CLoginAccountPage = class("CLoginAccountPage", CPageBase)

function CLoginAccountPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CLoginAccountPage.OnInitPage(self)
	self.m_AccountInput = self:NewUI(1, CInput)
	self.m_PwdInput = self:NewUI(2, CInput)
	self.m_LoginBtn = self:NewUI(3, CButton)
	self.m_AccountBtn = self:NewUI(5, CButton)
	self.m_AccountNode = self:NewUI(6 ,CObject)
	self.m_AccountGrid = self:NewUI(7, CGrid)
	self.m_AccountBox = self:NewUI(8, CBox)
	
	self.m_AccountNode:SetActive(false)
	self.m_AccountBox:SetActive(false)
	self.m_AccountBtn:AddUIEvent("click", callback(self, "OnAccountBtn"))
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnLogin"))
	self.m_MinInputChar = 1
	self.m_MaxInputChar = 255
	self.m_PermittedCharStart = '!'
	self.m_PermittedCharEnd = '~'
	self:InitAccountGird()
	self:SetCharLimits(self.m_PermittedCharStart, self.m_PermittedCharEnd)
	self:SetPermittedChars(self.m_PermittedCharStart, self.m_PermittedCharEnd)
	g_GuideCtrl:AddGuideUI("click_ui_test", self.m_LoginBtn)
	self.m_BtnList = {}
end

function CLoginAccountPage.Test(self, oBtn)
	
	local seq = DOTween.Sequence(oBtn.m_Transform)
	for i=1, 100 do
	-- 	local btn = oBtn:Clone()
		-- btn:SetParent(oBtn:GetParent())
		local btn = oBtn:Clone()
		btn:SetParent(oBtn:GetParent())
		local interval = 0.5
		-- local i = 100
		local tween1  = DOTween.DOLocalMoveY(btn.m_Transform, 200+i, interval)
		-- DOTween.Append(seq, tween1)
		btn.m_Tween = tween1
		DOTween.OnComplete(tween1, function ()
			for j, obj in ipairs(self.m_BtnList) do
				if (j%2)==0 then
					DOTween.DOKill(obj.m_Transform, false)
				end
				
			end
			local tween2  = DOTween.DOLocalMoveX(btn.m_Transform, i*2, interval*4)
			DOTween.OnComplete(tween2, function ()
				-- DOTween.DOTween.Kill(btn.m_Transform, false)
				printc("???????????????????", i)
			end)
			btn.m_Tween = tween2
		end)
		-- 

		-- DOTween.Append(seq, tween2)
		table.insert(self.m_BtnList, btn)
	end
	

	
	-- DOTween.Append(seq, tween2)
	-- local tween3  = DOTween.DOLocalRotate(oBtn.m_Transform, Vector3.New(0, 90, 0), interval)
	-- DOTween.Insert(oBtn.m_Sequence, interval * 2 , tween3)

	-- local tween4  = DOTween.DOLocalRotate(oBtn.m_Transform, Vector3.New(0, 0, 0), interval)
	-- DOTween.Insert(oCardBox.m_Sequence, interval * 3 , tween4)
end

function CLoginAccountPage.SetCharLimits(self)
	self.m_AccountInput:SetCharLimit(self.m_MaxInputChar)
	self.m_PwdInput:SetCharLimit(self.m_MaxInputChar)
end

function CLoginAccountPage.SetPermittedChars(self, charStart, charEnd)
	self.m_AccountInput:SetPermittedChars(charStart, charEnd)
	self.m_PwdInput:SetPermittedChars(charStart, charEnd)
end

function CLoginAccountPage.OnLogin(self)
	local t = {
		account = self.m_AccountInput:GetText(),
		pwd = self.m_PwdInput:GetText(),
	}
	if #t.account < self.m_MinInputChar then
		g_NotifyCtrl:FloatMsg("请输入用户名")
		return
	end
	if g_NetCtrl:IsConnecting() then
		g_NotifyCtrl:FloatMsg("正在连接中...")
		return
	end
	self:SetLoginVerify(t)
	g_LoginCtrl:UpdateVerifyInfo(t)
	self.m_ParentView:ShowServerPage()
end



function CLoginAccountPage.SetLoginVerify(self, t)
	t.time = os.time()
	local loginVerify = self:GetLoginVerify()
	local bInsert = true
	for i,v in ipairs(loginVerify) do
		if v.account == t.account then
			v.time = t.time
			bInsert = false
		end
	end
	if bInsert then
		table.insert(loginVerify, t)
	end
	table.sort(loginVerify, function (a, b)
		return a.time > b.time
	end)
	if #loginVerify > 10 then
		table.remove(loginVerify, 11)
	end
	IOTools.SetClientData("login_verify", loginVerify)
end

function CLoginAccountPage.GetLoginVerify(self)
	local loginVerify = IOTools.GetClientData("login_verify")
	if loginVerify and loginVerify[1] then
		return loginVerify
	end
	return {}
end

function CLoginAccountPage.RandomAccount(self)
	local s = ""
	for i=1, 10 do
		local c = Utils.RandomInt(39, 122)
		s = s..string.char(c)
	end
	return s
end

function CLoginAccountPage.GetLoginVerifyOne(self)
	local loginVerify = self:GetLoginVerify()
	return loginVerify[1] or {}
	-- return {account = self:RandomAccount(), pwd =""}
end

function CLoginAccountPage.OnAccountBtn(self, obj)
	local bAct = self.m_AccountNode:GetActive()
	self.m_AccountNode:SetActive(not bAct)
end

function CLoginAccountPage.InitAccountGird(self)
	local one = self:GetLoginVerifyOne()
	if one then
		self.m_AccountInput:SetText(one.account)
		self.m_PwdInput:SetText(one.pwd)
	end
	local loginVerify = self:GetLoginVerify()
	self.m_AccountGrid:Clear()
	for i,v in ipairs(loginVerify) do
		local oBox = self.m_AccountBox:Clone()
		oBox:SetActive(true)
		oBox.m_AccountLabel = oBox:NewUI(1, CLabel)
		oBox.account = v.account
		oBox.pwd = v.pwd
		oBox.m_AccountLabel:SetText(v.account)
		oBox:AddUIEvent("click", callback(self, "OnAccountBox"))
		self.m_AccountGrid:AddChild(oBox)
	end
	self.m_AccountGrid:Reposition()
end

function CLoginAccountPage.OnAccountBox(self, obj)
	self.m_AccountInput:SetText(obj.account)
	self.m_PwdInput:SetText(obj.pwd)
	self.m_AccountNode:SetActive(false)
end

return CLoginAccountPage