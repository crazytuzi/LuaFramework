-- 我的队伍
ZDMinePanel = BaseClass(LuaUI)
function ZDMinePanel:__init(root)
	self.ui = UIPackage.CreateObject("Team","ZDMinePanel")
	self.bg = self.ui:GetChild("bg")
	self.typeLayer = self.ui:GetChild("typeLayer")
	self.txtTarget = self.ui:GetChild("txtTarget")
	self.txtLimitLev = self.ui:GetChild("txtLimitLev")
	self.btnHandle = self.ui:GetChild("btnHandle") -- 自动匹配｜归队
	self.btnQuit = self.ui:GetChild("btnQuit")
	self.btnChangeType = self.ui:GetChild("btnChangeType")
	self.btnRequestList = self.ui:GetChild("btnRequestList")
	self.reqTip = self.ui:GetChild("reqTip")
	self.reqTip.visible = false
	self.btnHanhua = self.ui:GetChild("btnHanhua")
	self.btnHanhua.visible = false
	root:AddChild(self.ui)
	self:SetXY(145,110)
	self:Config()
	self:Layout()
	self:InitEvent()
end
function ZDMinePanel:Config()
	self.model = ZDModel:GetInstance()
	self.cells = {}
end
function ZDMinePanel:InitEvent()
	self.btnHandle.onClick:Add(function ()
		if self.model:IsLeader() then
			if self.model.teamMath == 0 then
				self.model.teamMath = 1
			else
				self.model.teamMath = 0
			end
			self.btnHandle.title=self.model.teamMath==1 and "取消匹配" or "自动匹配"
			ZDCtrl:GetInstance():C_TeamAutoMatch()
		else
			self.model:SetFollow(not self.model.isFollow)
			self.btnHandle.title=self.model.isFollow and "归队" or "取消归队"
		end
	end)
	self.btnQuit.onClick:Add(function ()
		ZDCtrl:GetInstance():C_QuitTeam()
	end)
	self.btnChangeType.onClick:Add(function ()
		local panel = ZDJoinTarget.New()
		UIMgr.ShowCenterPopup(panel)
	end)
	self.btnRequestList.onClick:Add(function ()
		self.model:SetHasReq( false )
		self.reqTip.visible = false
		local panel = ZDApplyPanel.New()
		UIMgr.ShowCenterPopup(panel)
		ZDCtrl:GetInstance():C_GetTeamApplyList()
	end)
	self.btnHanhua.onClick:Add(function()
		self:OnHanhuaClick()
	end)
	self.reqTeamHandle= GlobalDispatcher:AddEventListener(EventName.NOTICE_REQ_INTEAM, function ()
		if self.model:IsLeader() then
			self.reqTip.visible = true
		end
	end)
	self.followHandler = self.model:AddEventListener(ZDConst.FOLLOW, function ()
		if not self.model then return end
		self:UpdateFollow()
	end)
end
-- 布局UI
function ZDMinePanel:Layout()
	for i=1,ZDConst.TeamMaxMem do
		local cell = ZDMemCell.New()
		cell:AddTo(self.typeLayer)
		cell:SetXY((cell:GetW()+9)*(i-1)+3, 8)
		self.cells[i] = cell
		-- debugDrag(cell)

		cell:SetAddCallback(function ()
			local panel = ZDInvitePanel.New()
			UIMgr.ShowCenterPopup(panel)
		end)
	end
end

function ZDMinePanel:Update()
	if not self.cells then return end
	local model = self.model
	local members = model.members
	local cell = nil
	local map = {}
	for _,v in pairs(members) do
		cell = self.cells[v.teamIndex]
		if cell then
			cell:Update(v)
			map[v.teamIndex] = true
		end
	end
	for i,cell in ipairs(self.cells) do
		if not map[i] then
			cell:Update(nil)
		end
	end
	local targetInfo = GetCfgData("teamTarget"):Get(model:GetActivityId())
	if targetInfo then
		self.txtTarget.text = targetInfo.targetName or "无"
	end
	self.txtLimitLev.text = model.minLevel or 0
	self:UpdateFollow()
	if model:IsLeader() then
		self.reqTip.visible = model.hasReq
	end
	self.btnHanhua.visible = model:IsLeader() or false
end
function ZDMinePanel:UpdateFollow()
	if self.model:IsLeader() then
		self.btnChangeType.visible = true
		self.btnRequestList.visible = true
		self.btnHandle.title=self.model.teamMath==1 and "取消匹配" or "自动匹配"
	else
		self.btnChangeType.visible = false
		self.btnRequestList.visible = false
		self.btnHandle.title = self.model.isFollow and "取消归队" or "归队"
	end
end
function ZDMinePanel:Close()
	if self.cells then
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
	end
	self.cells = nil
end

function ZDMinePanel:__delete()
	if self.cells then
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
	end
	self.cells = nil
	GlobalDispatcher:RemoveEventListener(self.reqTeamHandle)
	if self.model then
		self.model:RemoveEventListener(self.followHandler)
	end
	self.model = nil
end

--一键喊话
function ZDMinePanel:OnHanhuaClick()
	local res0 = UIPackage.GetItemURL("Common", "btnBg_001")
	local res1 = UIPackage.GetItemURL("Common", "btnBg_002")
	local x = 10
	local y = 10
	local tabType = 0
	local yInternal = 55
	local redW = 144
	local redH = 49
	local tabData = {}
	for i = 1, #ZDConst.TXT_HANHUA_PREFIX do
		local txt = ZDConst.TXT_HANHUA_PREFIX[i][1] .. ZDConst.TXT_HANHUA_SUFFIX
		table.insert(tabData, {label = txt, res0 = res0, res1 = res1, red = false, id = i})
	end
	local panel = CreatePopTabs(tabType, function(idx, id)
		self:popTabClickCallback(idx, id)
	end, tabData, x, y, nil, yInternal, redW, redH)
	UIMgr.ShowPopupToPos(panel, 513, 440)
end

function ZDMinePanel:popTabClickCallback(idx, id)
	UIMgr.HidePopup()
	if self.model:IsHanhuaCDing(idx + 1) then UIMgr.Win_FloatTip(ZDConst.TXT_HANHUA_FAIL) return end
	if self.model then self.model:SetAutoAgree(true) end
	local params = {}
	local tab = { ChatVo.ParamType.Team, self.model:GetTeamId(), 0, 0 }
	table.insert(params, tab)
	local targetInfo = GetCfgData("teamTarget"):Get(self.model:GetActivityId())
	local str = ""
	local tType = targetInfo.targetGroup
	if targetInfo and tType ~= 0 and ZDConst.bigType[tType + 1] then
		local strName = targetInfo.targetName or "无"
		str = ZDConst.bigType[tType + 1][2] or "无"
		str = StringFormat("[{0}] {1}开组啦~",str,strName)
	else
		str = "[自由] "
	end
	local lev = self.model.minLevel or 0
	local strFinal = StringFormat("{0} {1}级以上进组~!{2}",str, lev, "{0}")
	ChatNewController:GetInstance():C_Chat(ZDConst.TXT_HANHUA_PREFIX[idx + 1][2], strFinal, nil, params)
	UIMgr.Win_FloatTip(ZDConst.TXT_HANHUA_SUCCESS)
	self.model:StartHanhuaCD(idx + 1)
end