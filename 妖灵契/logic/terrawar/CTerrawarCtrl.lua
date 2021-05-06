local CTerrawarCtrl = class("CTerrawarCtrl", CCtrlBase)

define.Terrawar = {
	Scenes = {1001,1002,1003,1004,1005,1006}, --据点地图scenedata
	Event = {
		RefreshMap = 1,
		RefreshMine = 2,
		RefreshWorldRank = 3,
		RefreshOrgRank = 4,
		TerraWarQueue = 5,
		State = 6,
		TerraWarLog = 7,
	},

	Open = {
		Yes = 1,
	},

	status = {
		Not = 0,     --无
		Attack = 1,  --战斗中
		Protect = 2, --保护中
		Occupy = 3,  --占领中
	},

	Operate = {
		--1:召回,2:传送,3:观战,4:攻击,5:支援
		Recall = 1,
		WatchWar = 3,
		Attack = 4,
		Help = 5,
	},

	Next = {
		GetTerraInfo = 1,
		GetListInfo = 2,
	},

	Effect = {
		Type = {Big = "Big", Medium = "Medium", Small = "Small"},
		Path = {
			Big = {
				Normal 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_001.prefab", 	--空据点
				Enemy  	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_002_03.prefab",	--敌方据点
				Ally   	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_003_03.prefab",	--友方据点
				N2E 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_002.prefab",		--空据点到敌方据点	
				N2A 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_003.prefab",		--空据点到友方据点
				E2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_002_02.prefab",	--敌方据点到空据点
				A2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_c_003_02.prefab",	--友方据点到空据点
			},
			Medium = {
				Normal 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_001.prefab", 	--空据点
				Enemy  	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_002_03.prefab",	--敌方据点
				Ally   	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_003_03.prefab",	--友方据点
				N2E 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_002.prefab",		--空据点到敌方据点	
				N2A 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_003.prefab",		--空据点到友方据点
				E2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_002_02.prefab",	--敌方据点到空据点
				A2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_b_003_02.prefab",	--友方据点到空据点
			},
			Small = {
				Normal 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_001.prefab", 	--空据点
				Enemy  	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_002_03.prefab",	--敌方据点
				Ally   	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_003_03.prefab",	--友方据点
				N2E 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_002.prefab",		--空据点到敌方据点	
				N2A 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_003.prefab",		--空据点到友方据点
				E2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_002_02.prefab",	--敌方据点到空据点
				A2N 	= "Effect/UI/ui_eff_terrawar/Prefabs/ui_eff_terrawar_a_003_02.prefab",	--友方据点到空据点
			},
		},
	}
}

function CTerrawarCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTerrawarCtrl.ResetCtrl(self)
	self.m_TerrawarMapInfo = {} 	--据点地图信息
	self.m_TerrawarMineInfo = {} 	--我的据点信息
	self.m_ServerRankInfo = {} 		--全服排行
	self.m_MyServerRank = {}     	--我的全服排行
	self.m_OrgRankInfo = {} 		--公会排行
	self.m_MyOrgRank = {}     		--我的公会排行
	self.m_TerraWarState = nil  	--2为预热，1为显示，0为关闭
	self.m_TerraWarTime = 0			--TerraWarState 的倒计时
	self.m_TerraWarLog = {}			--军情界面
end

function CTerrawarCtrl.C2GSTerrawarMain(self)
	nethuodong.C2GSTerrawarMain()
end

function CTerrawarCtrl.C2GSTerrawarMapInfo(self, mapid)
	printc("从服务器获取据点位置信息：",mapid)
	nethuodong.C2GSTerrawarMapInfo(mapid)
end

function CTerrawarCtrl.C2GSTerrawarMine(self)
	nethuodong.C2GSTerrawarMine()
end

function CTerrawarCtrl.GetTerraWarOrgPage(self)
	local oView = COrgActivityCenterView:GetView()
	if oView then
		local oPage = oView.m_TerraWarOrgPage
		if oPage:GetActive() then
			return oPage
		end
	end
end

function CTerrawarCtrl.IsOpenTerrawar(self)
	return self.m_OpenStatus == define.Terrawar.Open.Yes
end

function CTerrawarCtrl.OpenTerrawarMain(self, personal_points, org_points, end_time, contribution, status)
	self.m_OpenStatus = status
	local oPage = self:GetTerraWarOrgPage()
	if oPage then
		oPage:RefreshInfo(personal_points, org_points, end_time, contribution, status)
		return
	end
	local oView = CTerraWarMainView:GetView()
	if oView then
		oView:RefreshInfo(personal_points, org_points, end_time, contribution, status)
	else
		CTerraWarMainView:ShowView(function (oView)
			oView:RefreshInfo(personal_points, org_points, end_time, contribution, status)
		end)
	end
end

function CTerrawarCtrl.SetTerrawarMapInfo(self, mapid, terrainfo)
	self.m_TerrawarMapInfo[mapid] = terrainfo
	self:OnEvent(define.Terrawar.Event.RefreshMap)
end

function CTerrawarCtrl.GetTerrawarMapInfo(self, mapid)
	return self.m_TerrawarMapInfo[mapid]
end

function CTerrawarCtrl.GetTerrawarDataForMapID(self, mapid)
	local terraconfig = data.terrawardata.TERRACONFIG
	local posDic = {}
	for i,v in pairs(terraconfig) do
		if v.map_id == mapid then
			posDic[v.id] = v
		end
	end
	return posDic
end

function CTerrawarCtrl.GetUpArea(self, mapid)
	local upArea = {}
	mapid = mapid or 101000
	local posDic = self:GetTerrawarDataForMapID(mapid)
	local mapInfo = self:GetTerrawarMapInfo(mapid)
	for k,v in pairs(mapInfo) do
		if v.orgid and v.orgid ~= 0 then
			if not upArea[v.orgid] then
				upArea[v.orgid] = {
					orgid=v.orgid,
					mapInfo = {}
				}
			end
			table.insert(upArea[v.orgid].mapInfo, v.id)
		end
	end
	return upArea
end

function CTerrawarCtrl.SetTerrawarMine(self, terrainfo)
	self.m_TerrawarMineInfo = terrainfo
	self:OnEvent(define.Terrawar.Event.RefreshMine)
end

function CTerrawarCtrl.GetTerrawarMineInfo(self)
	return self.m_TerrawarMineInfo
end

function CTerrawarCtrl.SetTerrawarServerRank(self, ServerRankInfo, myServerRank)
	self.m_ServerRankInfo = ServerRankInfo
	self.m_MyServerRank = myServerRank
	self:OnEvent(define.Terrawar.Event.RefreshServerRank)
end

function CTerrawarCtrl.GetTerrawarServerRank(self)
	return self.m_ServerRankInfo
end

function CTerrawarCtrl.GetMyServerRank(self)
	return self.m_MyServerRank
end

function CTerrawarCtrl.SetTerrawarOrgRank(self, orgRankInfo, myOrgRank)
	self.m_OrgRankInfo = orgRankInfo
	self.m_MyOrgRank = myOrgRank
	self:OnEvent(define.Terrawar.Event.RefreshOrgRank)
end

function CTerrawarCtrl.GetTerrawarOrgRank(self)
	return self.m_OrgRankInfo
end

function CTerrawarCtrl.GetMyOrgRank(self)
	return self.m_MyOrgRank
end

function CTerrawarCtrl.OpenTerraWarState(self, terrainfo, lingli_info)
	local oView = CTerraWarStateView:GetView()
	if oView then
		oView:InitView(terrainfo, lingli_info)
	else
		CTerraWarStateView:ShowView(function (oView)
			oView:InitView(terrainfo, lingli_info)
		end)
	end
end

function CTerrawarCtrl.OpenTerraWarLineUp(self, terraid, end_time)
	--预防closeall
	g_ViewCtrl:DontDestroyOnCloseAll("CTerraWarLineUpView", true)
	if g_WarCtrl:IsWar() then
		return
	end
	CTerraWarLineUpView:ShowView(function (oView)
		oView:InitView(terraid)
		oView:AutoClose(end_time)
	end)
end

function CTerrawarCtrl.TerraWarLineUpSuccess(self, terraid)
	CTerraWarStateView:CloseView()
	CTerraWarLineUpView:CloseView()
	nethuodong.C2GSGetTerraInfo(terraid)
end

function CTerrawarCtrl.TerrawarGiveUpSuccess(self, terraid)
	local oView
	oView = CTerraWarStateView:GetView()
	if oView then
		CTerraWarStateView:CloseView()
		nethuodong.C2GSGetTerraInfo(terraid)
		return
	end
	oView = CTerraWarMainView:GetView()
	if oView then
		self:C2GSTerrawarMine()
	end
end

function CTerrawarCtrl.OpenTerraWarQueue(self, terraid, helplist, attacklist, name, orgid)
	local oView = CTerraWarQueueView:GetView()
	if oView then
		oView:InitView(terraid, helplist, attacklist, name, orgid)
	else
		CTerraWarQueueView:ShowView(function (oView)
			oView:InitView(terraid, helplist, attacklist, name, orgid)
		end)
	end
end

function CTerrawarCtrl.SetTerraWarQueue(self, status)
	--1代表在队列中，为0代表不在
	self.m_TerraWarQueue = status
	self:OnEvent(define.Terrawar.Event.TerraWarQueue)
end

function CTerrawarCtrl.IsTerraWarQueue(self)
	if g_WarCtrl:IsPlayRecord() then
		return false
	end
	if g_WarCtrl:IsWar() then
		return false
	end
	return self:GetTerraWarQueue() == 1
end

function CTerrawarCtrl.GetTerraWarQueue(self)
	return self.m_TerraWarQueue
end

--~g_TerrawarCtrl:ClientTerraWarHelp(1, g_TimeCtrl:GetTimeS() + 100)
function CTerrawarCtrl.ClientTerraWarHelp(self, terraid, endtime)
	if endtime and endtime ~= 0 and g_TimeCtrl:GetTimeS() > endtime then
		g_NotifyCtrl:FloatMsg("求救信息已失效")
		return
	end
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade then
		g_NotifyCtrl:FloatMsg(string.format("等级%d开启据点战", data.globalcontroldata.GLOBAL_CONTROL.terrawars.open_grade))
		return
	end
	if not g_ActivityCtrl:ActivityBlockContrl("terrawars") then
		return
	end
	local terraconfig = data.terrawardata.TERRACONFIG[terraid]
	local pos = Vector3.New(terraconfig.position.posx, terraconfig.position.posy, 0)
	local mapID = terraconfig.map_id
	local npctype = terraconfig.id
	local function autowalk()
		if g_MapCtrl:GetMapID() ~= mapID or g_MapCtrl.m_MapLoding then
			return true
		else
			g_MapTouchCtrl:WalkToPos(pos, nil, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
				for i,v in pairs(g_MapCtrl.m_Npcs) do
					if v.m_NpcAoi.npctype == npctype then
						local oNpc = g_MapCtrl:GetNpc(v.m_NpcAoi.npcid)
						if oNpc then
							oNpc:Trigger()
						end
					end
				end
			end)
		end
	end
	if g_MapCtrl:GetMapID() ~= mapID then
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapID)
			if self.m_AutoWalkTimer then
				Utils.DelTimer(self.m_AutoWalkTimer)
			end
			self.m_AutoWalkTimer = Utils.AddTimer(autowalk, 0.1, 0.1)
		end
	else
		autowalk()
	end
end

function CTerrawarCtrl.ShowTerraWarResult(self, oCmd)
	CWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
		oView:SetDelayCloseView()
	end)
end

function CTerrawarCtrl.OpenCTerraReady(self, ready, end_time)
	CTerraWarReadyView:ShowView(function (oView)
		oView:InitView(ready, end_time)
	end)
end

function CTerrawarCtrl.SetTerraWarState(self, state, time)
	--2为预热，1为显示，0为关闭
	self.m_TerraWarState = state
	self.m_TerraWarTime = time
	self:OnEvent(define.Terrawar.Event.State)
end

function CTerrawarCtrl.GetTerrawarTipsTxt(self)
	local txt
	if self:IsKaiqi() then
		txt = self:GetKaiqiLeftTime()
		if txt == "" then
			txt = "正在进行"
		end
	elseif self:IsYure() then
		txt = self:GetYureLeftTime()
		if txt == "" then
			txt = "即将开启"
		end
	end
	return txt
end

function CTerrawarCtrl.IsYure(self)
	return self.m_TerraWarState == 2
end

function CTerrawarCtrl.IsKaiqi(self)
	return self.m_TerraWarState == 1
end

function CTerrawarCtrl.IsClose(self)
	return self.m_TerraWarState == 0
end

function CTerrawarCtrl.GetYureLeftTime(self)
	--即将开启距离正在进行倒计时12小时
	local sTime = ""
	local curtime = g_TimeCtrl:GetTimeS()
	local lefttime = self.m_TerraWarTime - curtime
	if lefttime <= 12 * 3600 then
		sTime = g_TimeCtrl:GetLeftTime(lefttime, true)
	elseif lefttime <= 0 then
		sTime = "正在进行"
	end
	return sTime, lefttime
end

function CTerrawarCtrl.GetKaiqiLeftTime(self)
	--正在进行距离即将开启倒计时12小时
	local sTime = ""
	local curtime = g_TimeCtrl:GetTimeS()
	local lefttime = self.m_TerraWarTime - curtime
	if lefttime <= 12 * 3600 then
		sTime = g_TimeCtrl:GetLeftTime(lefttime, true)
	end
	return sTime, lefttime
end

function CTerrawarCtrl.GetNextLeftTime(self)
	--距离下次开启
	local sTime = ""
	local curtime = g_TimeCtrl:GetTimeS()
	local lefttime = self.m_TerraWarTime - curtime
	sTime = g_TimeCtrl:GetLeftTime(lefttime, true)
	return sTime, lefttime
end

function CTerrawarCtrl.TerrawarsCountDown(self, endtime, type)
	local oView = CTerrawarsCountDown:GetView()
	if oView then
		oView:InitView(endtime, type)
	else
		CTerrawarsCountDown:ShowView(function (oView)
			oView:InitView(endtime, type)
		end)
	end
end

function CTerrawarCtrl.C2GSTerrawarsLog(self)
	nethuodong.C2GSTerrawarsLog()
end

function CTerrawarCtrl.SetTerraWarLog(self, terrawarlog)
	self.m_TerraWarLog = terrawarlog
	self:OnEvent(define.Terrawar.Event.TerraWarLog)
end

function CTerrawarCtrl.GetTerraWarLog(self)
	return self.m_TerraWarLog
end

return CTerrawarCtrl