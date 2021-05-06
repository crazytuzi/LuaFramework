local CEditorLineupView = class("CEditorLineupView", CViewBase)

function CEditorLineupView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorLineup/EditorLineupView.prefab", cb)
	self.m_DepthType = "Menu"

	local config = require "logic.editor.editor_lineup.editor_lineup_config"
	rawset(_G, "config", config)
end

function CEditorLineupView.OnCreateView(self)
	self.m_SaveAsBtn = self:NewUI(1, CButton)
	self.m_RefreshBtn = self:NewUI(2, CButton)
	self.m_Container = self:NewUI(3, CWidget)
	self.m_ArgBoxTable = self:NewUI(4,CTable)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ArgBoxDict = {}
	self.m_UserCache = {}
	self:InitContent()
	self:RedefineFunc()
	self:RefreshLineup()
end

function CEditorLineupView.RedefineFunc(self)
	local function nilfunc() end
	CViewCtrl.CloseAll = nilfunc
	CWarOrderCtrl.Bout = nilfunc
	CWarMainView.ShowView = nilfunc
	CHouseMainView.ShowView = nilfunc

	local oldfunc  = CWarCtrl.GetLinupPos
	CWarCtrl.GetLinupPos = function(s, isAlly, idx)
		local iType = self.m_ArgBoxDict["lineup_type"]:GetValue()
		local iMemberCnt = self.m_ArgBoxDict["member_cnt"]:GetValue()
		local iPartnerCnt = self.m_ArgBoxDict["partner_cnt"]:GetValue()
		g_WarCtrl.m_EnemyPlayerCnt = iMemberCnt + 1
		g_WarCtrl.m_AllyPlayerCnt = iMemberCnt + 1
		local list={}
		for i=1, iPartnerCnt do
			table.insert(list, i)
		end
		g_WarCtrl.m_AllyPartnerWids = list
		g_WarCtrl.m_EnemyPartnerWids = list
		return oldfunc(s, isAlly, idx)
	end
end

function CEditorLineupView.SetUserCache(self, key, val)
	local oldVal = self.m_UserCache[key]
	if not table.equal(oldVal, val) then
		self.m_UserCache[key] = val
		-- table.print(self.m_UserCache)
		IOTools.SetClientData("editor_magic", self.m_UserCache)
		return true
	else
		return false
	end
end

function CEditorLineupView.InitContent(self)
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "RefreshLineup"))
	self.m_SaveAsBtn:AddUIEvent("click", callback(self, "Save"))
	local lKey = {"lineup_type", "member_cnt", "partner_cnt"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		if oArgInfo.change_refresh then
			oBox:SetValueChangeFunc(callback(self, "OnArgChange", oArgInfo.change_refresh))
		end
		self.m_ArgBoxDict[k] = oBox
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)

	local dUserCache = IOTools.GetClientData("editor_lineup") or {}
	-- table.print(dUserCache, "--->editor_magic")
	self.m_UserCache = dUserCache
	for k, oBox in ipairs(self.m_ArgBoxTable:GetChildList()) do
		local v = dUserCache[oBox:GetKey()]
		if v~= nil then
			oBox:SetValue(v, true)
		else
			oBox:ResetDefault()
		end
	end
end

function CEditorLineupView.OnArgChange(self, iFlag, key)
	local newVal = self.m_ArgBoxDict[key]:GetValue()
	if self:SetUserCache(key, newVal) then
		self:RefreshWar()
	end
end

function CEditorLineupView.RefreshLineup(self)
	local sType = self.m_ArgBoxDict["lineup_type"]:GetValue()
	local iMemberCnt = self.m_ArgBoxDict["member_cnt"]:GetValue()
	local iPartnerCnt = self.m_ArgBoxDict["partner_cnt"]:GetValue()

	self:Refresh(iMemberCnt, iPartnerCnt)
end

function CEditorLineupView.Refresh(self, iOriMember, iOriPartner)
	iOriMember = math.min(iOriMember, 3)
	local iWarType = define.War.Type.PVP
	local sType = self.m_ArgBoxDict["lineup_type"]:GetValue()
	if sType == "team" then
		iOriMember = math.max(iOriMember, 1)
		self.m_ArgBoxDict["member_cnt"]:SetValue(iOriMember, true)
		self.m_ArgBoxDict["partner_cnt"]:SetValue(math.max(0, math.min(4-iOriMember, iOriPartner)), true)
	elseif sType == "single" then
		self.m_ArgBoxDict["member_cnt"]:SetValue(0, true)
		iOriPartner = math.min(math.max(iOriPartner, 1), 4)
		self.m_ArgBoxDict["partner_cnt"]:SetValue(iOriPartner, true)
	else
		self.m_ArgBoxDict["member_cnt"]:SetValue(3, true)
		self.m_ArgBoxDict["partner_cnt"]:SetValue(1, true)
		if sType == "boss" then
			iWarType = define.War.Type.Boss
		elseif sType == "yjfuben" then
			iWarType = define.War.Type.YjFuben
		end
	end

	local iMemberCnt = self.m_ArgBoxDict["member_cnt"]:GetValue()
	local iPartnerCnt = self.m_ArgBoxDict["partner_cnt"]:GetValue()
	local war_id = 1
	g_AttrCtrl:UpdateAttr({pid =101})
	netwar.GS2CShowWar({war_id=war_id, war_type=iWarType})
	netwar.GS2CEnterWar({})
	local iShape = 130
	local iWeapon = 2100
	local iPlayerCnt = iMemberCnt + 1
	for iCamp=1, 2 do
		for i=1, iPlayerCnt do
			local t = {war_id=war_id, camp_id=iCamp,type=1,warrior={pflist={3001}, wid=i+iCamp*100, pid=i+iCamp*100,pos=i, status={name=tostring(i), status=1, hp=6000, max_hp=7000, model_info={shape=iShape, weapon= iWeapon}},}}
			netwar.GS2CWarAddWarrior(t)
			local t = {war_id=war_id, camp_id=iCamp,type=1,warrior={pflist={3001}, wid=i+iCamp*100+4, pid=i+iCamp*100+4,pos=i+4, status={name=tostring(i+4), status=1, hp=6000, max_hp=7000, model_info={shape=iShape, weapon= iWeapon}},}}
			netwar.GS2CWarAddWarrior(t)
		end
		local iPartnerCnt = iPartnerCnt -1 --减去主战伙伴
		for i=1, iPartnerCnt do
			local t = {war_id=war_id, camp_id=iCamp,type=1,warrior={pflist={3001}, wid=i+iPlayerCnt+iCamp*100, pid=i+iPlayerCnt+iCamp*100,pos=iPlayerCnt+i, status={name=tostring(iPlayerCnt+i), status=1,hp=6000, max_hp=7000, model_info={shape=iShape, weapon= iWeapon}},}}
			netwar.GS2CWarAddWarrior(t)
		end

		for iPos=9, 10 do
			local t = {war_id=war_id, camp_id=iCamp,type=1,warrior={pflist={3001}, wid=iPos+iCamp*100, pid=iPos+iCamp*100,pos=iPos, status={name=tostring(iPos), status=1,hp=6000, max_hp=7000, model_info={shape=iShape, weapon= iWeapon}},}}
			netwar.GS2CWarAddWarrior(t)
		end
	end
	netwar.GS2CWarBoutStart({war_id = war_id, bout_id = 1, left_time=30})
	netwar.GS2CActionStart({war_id = war_id, wid = 2, action_id=1, left_time=30})
end

function CEditorLineupView.Save(self)
	local t = {}
	for i, oWarrior in pairs (g_WarCtrl:GetWarriors()) do
		local iAlly = oWarrior:IsAlly() and 1 or 2
		if not t[iAlly] then
			t[iAlly] = {}
		end
		local pos = oWarrior:GetPos()
		t[iAlly][oWarrior.m_CampPos] = {x=pos.x, z=pos.z}
	end
	
	local sType = self.m_ArgBoxDict["lineup_type"]:GetValue()
	local iCnt = 4
	if sType == "single" then
		iCnt = self.m_ArgBoxDict["partner_cnt"]:GetValue() + 1
	elseif sType == "team" then
		iCnt = self.m_ArgBoxDict["member_cnt"]:GetValue() + 1
	end
	if not data.lineupdata.PRIOR_POS[sType] then
		data.lineupdata.PRIOR_POS[sType] = {}
	end
	data.lineupdata.PRIOR_POS[sType][iCnt] = t
	if not table.index(data.lineupdata.LINEUP_TYPE, sType) then
		table.insert(data.lineupdata.LINEUP_TYPE, sType)
	end
	DataTools.SaveLineupData()
end

return CEditorLineupView