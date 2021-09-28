-- 组队大厅
ZDHallPanel = BaseClass(LuaUI)
function ZDHallPanel:__init(root)
	self.ui = UIPackage.CreateObject("Team","ZDHallPanel")
	self.bg = self.ui:GetChild("bg")
	self.typeLayer = self.ui:GetChild("typeLayer")
	self.teamLayer = self.ui:GetChild("teamLayer")
	self.cbAutoMatch = self.ui:GetChild("cbAutoMatch")
	self.btnCreate = self.ui:GetChild("btnCreate")
	self.btnRefresh = self.ui:GetChild("btnRefresh")
	self.txtAuto= self.cbAutoMatch:GetChild("title")
	self.bSelect = false

	root:AddChild(self.ui)
	self:SetXY(145,110)

	self:Config()
	self:Layout()
	self:InitEvent()
end
function ZDHallPanel:Config()
	self.model = ZDModel:GetInstance()
	self.items = {}
	self.curType = 0
end
function ZDHallPanel:SelectAutoBtn(bSelect)
	if self.bSelect then
		self.txtAuto.text = ZDConst.TXT_CANCEL_AUTO
	else
		self.txtAuto.text = ZDConst.TXT_AUTO
	end
end
function ZDHallPanel:InitEvent()
	self.cbAutoMatch.onClick:Add(function () -- 匹配
		if self.model.teamId == 0 then
			local function cbFunc(id)
				self.bSelect = not self.bSelect
				self.model:AutoMathTeam(self.bSelect, id)
				self:SelectAutoBtn()
			end
			if not self.bSelect then
				local panel = ZDJoinTarget2.New()
				panel:SetData({cb = cbFunc})
				UIMgr.ShowCenterPopup(panel)
			else
				cbFunc()
			end
		else
			self.bSelect = false
			self:SelectAutoBtn(false)
		end
	end)

	self.btnCreate.onClick:Add(function () -- 创建队伍
		ZDCtrl:GetInstance():C_CreateTeam()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end)
	self.btnRefresh.onClick:Add(function () -- 刷新大厅
		self.model:ClearTeamList()
		ZDCtrl:GetInstance():C_GetTeamList(self.curType)
	end)
	if not self.finishMatch then
		self.finishMatch = self.model:AddEventListener(ZDConst.FINISH_MATCH_TEAM, function ()
			if self.cbAutoMatch then
				self.bSelect = false
				self:SelectAutoBtn(false)
			end
		end)
	end
end

function ZDHallPanel:Layout()
	local accordion = Accordion.New()
	accordion:SetArrowVisible(false)
	accordion:AddTo(self.typeLayer)
	accordion:SetXY(4, 0)
	self.accordion = accordion
	accordion:SetData( ZDConst.teamTargets, function (selectData)
		if selectData[1] and selectData[2] then
			if self.curType == selectData[2] then return end
			self.model:ClearTeamList()
			self.curType = selectData[2]
		elseif selectData[1] then
			if self.curType == selectData[1] then return end
			self.model:ClearTeamList()
			self.curType = selectData[1]
		end
		-- print("请求类型", self.curType)
		ZDCtrl:GetInstance():C_GetTeamList(self.curType)
	end, 0)
end
function ZDHallPanel:Update()
	if not self.model then return end
	local list = self.model.teamList
	local item = nil
	for i,v in ipairs(self.items) do
		v:RemoveFromParent()
	end
	local i = 1
	for _,v in pairs(list) do
		item = self.items[i]
		if item then
			item:Update(v)
		else
			item = ZDItem.New(v)
			item:SetSelectCallback(function ( o )
				if self.curSelected ~= o then
					if self.curSelected then
						self.curSelected.selected.visible = false
					end
					self.curSelected = o
					o.selected.visible = true
				end
			end)
		end
		item:SetXY(0, (i-1)*116)
		item:AddTo(self.teamLayer)
		self.items[i] = item
		i = i + 1
	end
	self:RefreshAccord()
end

function ZDHallPanel:RefreshAccord()

end

function ZDHallPanel:SetVisible(v)
	LuaUI.SetVisible(self, v)
	if v then
		ZDCtrl:GetInstance():C_GetTeamList(self.curType)
	end
end
function ZDHallPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.finishMatch)
	end
	self.finishMatch = nil
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	if self.accordion then
		self.accordion:Destroy()
		self.accordion = nil
	end
	self.model = nil
	self.items = nil
end