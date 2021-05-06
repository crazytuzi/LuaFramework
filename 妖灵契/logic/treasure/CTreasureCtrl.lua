local CTreasureCtrl = class("CTreasureCtrl", CCtrlBase)

function CTreasureCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTreasureCtrl.ResetCtrl(self)
	self.m_CaCheNpcs = {}
end

function CTreasureCtrl.OpenTreasureNormalView(self, rewardinfo, times, sessionidx)
	times = times or 0
	CTreasureNormalView:ShowView(function (oView)
		oView:InitRewardTable(rewardinfo or {})
		oView:SetGroove(times + 1)
		oView:SetSessionidx(sessionidx)
	end)
end

function CTreasureCtrl.OpenTreasureDescView(self, itemid)
	if g_TeamCtrl:IsJoinTeam() then 
    	g_NotifyCtrl:FloatMsg("挖宝这么神秘的事情还是一个人完成较好")
    	return
    end
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		return
	end
	local itemInfo = g_ItemCtrl:GetItem(itemid)
	local treasureinfo = itemInfo:GetValue("treasure_info")
	local mapID = treasureinfo.treasure_mapid
	if mapID and g_MapCtrl:GetMapID() ~= mapID then
		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapID)
		local function delay(self)
			if g_MapCtrl:GetMapID() == mapID then
				CTreasureDescView:ShowView(function (oView)
					oView:RefreshDesc(itemid)
				end)
				return false
			end
			return true
		end
		self.m_DelayTimer = Utils.AddTimer(delay, 0.1, 0.1)
	else
		CTreasureDescView:ShowView(function (oView)
			oView:RefreshDesc(itemid)
		end)
	end
end

function CTreasureCtrl.OpenTreasurePlayBoyView(self, createtime, rewardinfo, haschangepos, dialog, cost, sessionidx)
	local oView = CTreasurePlayBoyView:GetView()
	if oView then
		oView:InitInfo(createtime, rewardinfo, haschangepos, dialog, cost, sessionidx)
	else
		CTreasurePlayBoyView:ShowView(function (oView)
			oView:InitInfo(createtime, rewardinfo, haschangepos, dialog, cost, sessionidx)
		end)
	end
end

function CTreasureCtrl.CheckTreasureNormalViewOpen(self, func)
	local oView = CTreasureNormalView:GetView()
	if oView then
		oView:SetTreasureReward(func)
		return true
	end
	return false
end

function CTreasureCtrl.OpenTreasureCaiQuanView(self, sessionidx, record)
	local oView = CTreasureCaiQuanView:GetView()
	if oView then
		oView:SetSessionidx(sessionidx)
		oView:SetRecord(record)
	else
		CTreasureCaiQuanView:ShowView(function (oView)
			oView:SetSessionidx(sessionidx)
			oView:SetRecord(record)
		end)
	end
end

--设置贪玩童子id，自动触发
function CTreasureCtrl.CreateHuodongNpc(self, npcinfo)
	local oView = CTreasureNormalView:GetView()
	if oView then
		oView:SetPlayBoy(npcinfo)
	end
	local id = npcinfo.npcid
	self.m_CaCheNpcs[id] = npcinfo
end

function CTreasureCtrl.RemoveHuodongNpc(self, npcid)
	g_MapCtrl:DelDynamicNpc(npcid)
	self.m_CaCheNpcs[npcid] = nil
end

function CTreasureCtrl.LoginHuodongInfo(self, npcinfo)
	local id
	for k,v in pairs(npcinfo) do
		id = v.npcid
		self.m_CaCheNpcs[id] = v
	end
	self:RefreshNpc()
end

function CTreasureCtrl.RefreshNpc(self)
	for _,v in pairs(self.m_CaCheNpcs) do
		if v.map_id == g_MapCtrl:GetMapID() and v.sceneid == g_MapCtrl:GetSceneID() then
			g_MapCtrl:AddDynamicNpc(v)
		end		
	end
end

--宝图指针结果
function CTreasureCtrl.SetTreasureResult(self, idx, iType)
	local oView = CTreasureNormalView:GetView()
	if oView then
		oView:SetTreasureResult(idx, iType)
	end
end

--猜拳结果
function CTreasureCtrl.SetCaiQuanResult(self, syschoice, result, sessionidx)
	local oView	= CTreasureCaiQuanView:GetView()
	if oView then
		oView:ShowCaiQuanResult(syschoice, result, sessionidx)
	end
end

function CTreasureCtrl.CaiQuanGameEnd(self, result)
	local oView = CTreasureCaiQuanView:GetView()
	if oView then
		oView:SetCaiQuanGameEnd(result)
	else
		if result == 1 then
			CTreasureCaiQuanView:ShowView(function (oView)
				oView:SetCaiQuanGameEnd(result)
				oView:ShowCaiQuanGameEnd()
			end)
		else
			g_NotifyCtrl:FloatMsg("游戏结束，即将退出副本")
		end
	end
end

--获取奖励列表
function CTreasureCtrl.GetProviewRewardList(self)
	local rewardList = {}
	for k,d in pairs(data.rewarddata.TREASURE) do
		rewardList[k] = {idx=k, sid=d.sid, name=d.name, desc=d.desc, amount=d.reward[1].amount}
	end
	return rewardList
end

--获取贪玩童子奖励
function CTreasureCtrl.GetPlayBoyRewardList(self)
	local rewardList = {}
	local dreward
	for k,d in pairs(data.rewarddata.TREASURE) do
		dreward = d.reward[1]
		if dreward then
			rewardList[k] = {idx=k, sid=dreward.sid, name=d.name, desc=d.desc, amount=dreward.amount}
		end
	end
	return rewardList
end

function CTreasureCtrl.IsInChuanshuoScene(self)
	--scene_id = 100001
	--scene_name = "传说伙伴幻境"
	--g_MapCtrl:GetSceneName() == "传说伙伴幻境"
	return g_MapCtrl:GetSceneName() == "幻境"
end

return CTreasureCtrl