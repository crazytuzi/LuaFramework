-- 家族内面板
FamilyMainPanel = BaseClass(LuaUI)
function FamilyMainPanel:__init( root )
	self.ui = UIPackage.CreateObject("Family","FamilyMainPanel");

	self.txtName = self.ui:GetChild("txtName")
	self.txtDisband = self.ui:GetChild("txtDisband")
	self.btnGG = self.ui:GetChild("btnGG")
	self.layerInfo = self.ui:GetChild("layerInfo")
	self.btnGL = self.ui:GetChild("btnGL")
	self.btnZD = self.ui:GetChild("btnZD")
	self.btnJS = self.ui:GetChild("btnJS")

	root:AddChild(self.ui)
	self:SetXY(133,100)

	-- 家族成员列表
	self.listFamilyPlayer = {}
	self.cells = {}
	self.maxNum = self:GetCfgData(6).value
	self.isInited = true

	self.model = FamilyModel:GetInstance()
	self.ctrl = FamilyCtrl:GetInstance()
	self.teamCtrl = ZDCtrl:GetInstance()
	self.teamModel = ZDModel:GetInstance()

	self:InitEvent()
end

function FamilyMainPanel:InitEvent()
	self.model:ClearFamilyModel()
	self.modelHandler = GlobalDispatcher:AddEventListener(EventName.PLAYER_MODEL, function (  )
		if self.model:GetModelState() then
			self:Update()
		end
	end)
	self:AddListener()
	self:SetCell()
	self:Update()
	self.txtName.text = self.model.familyName
	self.isLeader = self.model:IsFamilyLeader()
	self:SetModelShow()
end

function FamilyMainPanel:SetCell()
	if self.cells then
		for i,v in ipairs(self.cells) do
		v:Destroy()
		end
	end
	self.cells = {}

	for i=1, FamilyConst.TeamMaxMem do
		local cell = FamilyCell.New( self.layerInfo )
		cell:SetXY((cell:GetW()+10)*(i-1), 0)
		self.cells[i] = cell
	end
end

function FamilyMainPanel:SetModelShow()
	self.layerInfo.scrollPane.onScroll:Remove(self.OnScrollHandler, self)
	-- 任务模型显示
	self.layerInfo.scrollPane.onScroll:Add(function ( e )
		self:OnScrollHandler()
	end)
end	

function FamilyMainPanel:OnScrollHandler()
	local posX = self.layerInfo.scrollPane.posX
	local isShow = false
	for i,v in ipairs(self.cells) do 
		v.ui.visible = self.layerInfo:IsChildInView(v.ui)
		-- isShow = ((posX - 98 - (i-1)*10) / v:GetW()) <= i-1 
		isShow = posX <= v:GetX() + 98 and posX + self.layerInfo.width - 200 >= v:GetX()
		v.ui:GetChild("modelConn").visible = isShow
	end
end

function FamilyMainPanel:Update()
	if not self.cells then return end
	local model = self.model
	local members = model.members
	local cell = nil
	local map = {}
	self.isLeader = model:IsFamilyLeader()
	self.btnGL.visible = self.isLeader
	if self.isLeader then
		self.btnJS.title = "解散家族"
		self.msg = "确定要解散家族吗？"
	else
		self.btnJS.title = "退出家族"
		self.msg = "确定要退出家族吗？"
	end

	self:SetCell()
	for _,v in pairs(members) do
		cell = self.cells[v.familySortId]
		if cell then
			cell:Update(v)
			if v.playerId ~= LoginModel:GetInstance():GetLoginRole().playerId then 
				cell:SetCallback( function ()
					local panel = FamilySubPanel.New()
					panel:Update( members[v.playerId] )
					UIMgr.ShowCenterPopup(panel)
				end)
			end
			map[v.familySortId] = true
		end
	end

	self.txtDisband.visible = #map < self:GetCfgData(37).value

	for i,cell in ipairs(self.cells) do
		if not map[i] then
			cell:Update(nil)
			cell:SetAddCallback(function ()
				local panel = FamilyHYPanel.New()
				UIMgr.ShowCenterPopup(panel)
			end)
		end
	end

	self:OnScrollHandler()
end

function FamilyMainPanel:AddListener()
	local id = LoginModel:GetInstance():GetLoginRole().playerId
	local members = self.model.members
	local data = members[id]
	local panel = nil
	-- 管理
	self.btnGL.onClick:Add( function ()
		FamilyModel:GetInstance():SetFamilyModelShow(false)
		panel = FamilyPWPanel.New()
		UIMgr.ShowCenterPopup(panel)
	end)

	-- 公告
	self.btnGG.onClick:Add( function ()
		panel = FamilyGGPanel.New()
		UIMgr.ShowCenterPopup(panel)
	end)

	-- 解散
	self.btnJS.onClick:Add( function ()
		UIMgr.Win_Confirm("提示", 
			self.msg, 
			"确定", 
			"取消", 
			function ()
				if self.isLeader then
					self.ctrl:C_DisbandFamily()
				else
					self.ctrl:C_ExitFamily()
				end
			end, 
			nil)
	end)

	-- 组队邀请
	self.btnZD.onClick:Add( function ()
		if ZDModel:GetInstance().teamId ~= 0 then
			if not self.teamModel:IsLeader() then
				UIMgr.Win_FloatTip("您不是队长，无权邀请")
				return
			end

			if self.model:IsTalkCD() then 
				UIMgr.Win_FloatTip("喊话过于频繁") 
				return 
			else
				-- 喊话
				local name = LoginModel:GetInstance():GetLoginRole().playerName
				self:OnTalkCilck( name )
			end
		else
			self.teamCtrl:C_CreateTeam()
			if #self.model.listFamilyPlayer > 1 then
				for i,v in ipairs(self.model.listFamilyPlayer) do
					-- 如果不是自己、玩家在线、没有队伍则邀请组队
					if v.playerId ~= LoginModel:GetInstance():GetLoginRole().playerId and v.online == 1 then
						local player = SceneModel:GetInstance():GetPlayerByPlayerId( v.playerId )
						if player then
							if not player:HasTeam() then
								self.teamCtrl:C_Invite(v.playerId)
							end
						end
					end
				end
			end
		end

		self.zdHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_ZD, function ()
			-- 喊话
			local name = LoginModel:GetInstance():GetLoginRole().playerName
			self:OnTalkCilck()
		end)

	end)

end

-- 一键喊话
function FamilyMainPanel:OnTalkCilck()
	UIMgr.Win_FloatTip("已发送邀请")
	GlobalDispatcher:RemoveEventListener(self.zdHandler)
	local str = "发起了家族组队~{0}"
	local params = {}
	local tab = { ChatVo.ParamType.Team, self.teamModel:GetTeamId(), 0, 0 }
	table.insert( params, tab )
	ChatNewController:GetInstance():C_Chat(ChatNewModel.Channel.Family, str, nil, params)
	FamilyModel:GetInstance():StartTalkCD()
end

-- 读表
function FamilyMainPanel:GetCfgData( id )
	return GetCfgData("constant"):Get(tonumber(id))
end
-- 提前关掉模型单元
function FamilyMainPanel:Close()
	if self.cells then
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
	end
	self.cells = nil
end
-- Dispose use FamilyMainPanel obj:Destroy()
function FamilyMainPanel:__delete()
	self:Close()
	self.isInited = false
	self.model = nil
	self.ctrl = nil
	self.teamCtrl = nil
	GlobalDispatcher:RemoveEventListener(self.modelHandler)
	self.modelHandler = nil
end