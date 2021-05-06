module(..., package.seeall)
g_LinkCache = {}
g_LinkFuncMap = {
	link1 = "ItemLink",
	link2 = "CreateTeamLink",
	link3 = "GetTeamInfoLink",
	link4 = "ApplyTeamLink",
	link5 = "SummonLink",
	link6 = "SpeechLink",
	link7 = "EquipSpecialEffLink",
	link8 = "ScheduleLink",
	link9 = "NameLink",
	link10 = "OrgRespondLink",
	link11 = "OrgWorldAdvertiseLink",
	link12 = "OuQiLink",
	link13 = "QAnswerLink",
	link14 = "NilLink",
	link15 = "PartnerEquipLink",
	link16 = "CopyLink",
	link17 = "FightRecordLink",
	link18 = "ATPlayerLink",
	link19 = "OwnerPartnerLink",
	link20 = "JoinOrg",
	link21 = "RedPacketLink",
	link22 = "HelpTerraWarLink",
	link23 = "OpenUILink",
	link24 = "OrgGiveWish",
	link25 = "WalkToOrgWar",
	link26 = "WalkToGlobalNpc",
	link27 = "PartnerSoulLink",
	link28 = "SimpleItemLink",
	link29 = "SimplePartnerLink",
	link30 = "OpenAppUrl",
}

--type func
--{link1,1001}
function ItemLink(iUrlID, idx, itemid, iShape, iAmount)
	idx = tonumber(idx)
	iShape = tonumber(iShape)
	iAmount = tonumber(iAmount)
	itemid = tonumber(itemid)
	local dLink = {
		sType = "ItemLink",
		iShape = iShape,
		idx = idx,
		iLinkid = itemid,
		func = function() g_LinkInfoCtrl:OnClickItemLink(idx) end
	}
	local itemdata = DataTools.GetItemData(iShape)
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", itemdata.name), idx)
	if iAmount > 1 then
		local sUrl = BuildUrlText(iUrlID, string.format("#G[%s×%d]#n", itemdata.name, iAmount), idx)
	end
	return sUrl, dLink
end

function CreateTeamLink(iUrlID)
	local dLink = {
		sType = "CreateTeamLink",
		func = function() 
			if g_ActivityCtrl:ActivityBlockContrl("team") then
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSCreateTeam"]) then
					nettask.C2GSEnterShow(0, 0)
					netteam.C2GSCreateTeam()
				end
				CTeamMainView:ShowView(function (oView )
					oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
				end)			
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#G[组建队伍]#n")
	return sUrl, dLink
end

function SummonLink(iUrlID, idx, iParid, iPartnerType)
	idx = tonumber(idx)
	iPartnerType = tonumber(iPartnerType)
	iParid = tonumber(iParid)
	local dLink = {
		sType = "SummonLink",
		idx = idx,
		iPartnerType = iPartnerType,
		iLinkid = iParid,
		func = function() g_LinkInfoCtrl:OnClinkPartnerLink(idx) end
	}
	local summonInfo = data.partnerdata.DATA[iPartnerType]
	local name = summonInfo["name"]

	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", name))
	return sUrl, dLink
end

function GetTeamInfoLink(iUrlID, iTeamId, sTarget)
	local dLink = {
		sType = "GetTeamInfoLink",
		func = function() 
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamInfo"]) then
				netteam.C2GSTeamInfo(iTeamId) 
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#B[%s]#n", sTarget))
	return sUrl, dLink
end

function ApplyTeamLink(iUrlID, iPid)
	local dLink = {
		sType = "ApplyTeamLink",
		func = function() 
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeam"]) then
				nettask.C2GSEnterShow(0, 0)
				netteam.C2GSApplyTeam(iPid) 
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#G[u][申请加入][/u]#n")
	return sUrl, dLink
end

function SpeechLink(iUrlID, sSpeechKey, sTranslate, iTime)
	local dLink = {
		sType = "SpeechLink",
		sKey = sSpeechKey,
		sTranslate = sTranslate,
		iTime = iTime,
		func = function ()
			g_SpeechCtrl:PlayWithKey(sSpeechKey)
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#G#audio"..sTranslate)
	if g_SpeechCtrl:IsPlay(sSpeechKey) then
		sUrl = BuildUrlText(iUrlID, "#G#500"..sTranslate)
	end
	return sUrl, dLink
end

function EquipSpecialEffLink(iUrlID, iEffectId)
	local dLink = {
		sType = "EquipSpecialEffLink",
		iEffectId = iEffectId,
		func = function(oView) 
			local args = {widget =  oView, side = enum.UIAnchor.Side.Right,offset = Vector2.New(10, 50)}
			g_WindowTipCtrl:SetWindowEquipEffectTipInfo(iEffectId, args) 
		end
	}
	local sEffName = data.skilldata.SPECIAL_EFFC[tonumber(iEffectId)].name
	local sUrl = BuildUrlText(iUrlID, string.format("#B%s#n", sEffName))
	return sUrl, dLink
end

function ScheduleLink(iUrlID, sText, iSid)
	iSid = tonumber(iSid)
	local dLink = {
		sType = "ScheduleLink",
		iSid = iSid,
		sText = sText,
		func = function()
			CScheduleInfoView:ShowView(function (oView)
			oView:SetScheduleID(iSid)
			end)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

function NameLink(iUrlID, sText, idx, pid)
	pid = tonumber(pid)
	idx = tonumber(idx)
	local dLink = {
		sType = "NameLink",
		pid = pid,
		idx = idx,
		sText = sText,
		func = function()
			g_LinkInfoCtrl:OnClickNameLink(idx)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

function OrgRespondLink(iUrlID, orgid)
	local dLink = {
		sType = "OrgRespondLink",
		func = function()
			if g_AttrCtrl.org_id == 0 then
				netorg.C2GSJoinOrgBySpread(orgid)
			else
				g_NotifyCtrl:FloatMsg("已存在公会")
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#G[立刻加入]#n")
	return sUrl, dLink
end

function OrgWorldAdvertiseLink(iUrlID, orgid, leaderid)
	local dLink = {
		sType = "OrgWorldAdvertiseLink",
		func = function()
			if leaderid == g_AttrCtrl.pid then
				g_NotifyCtrl:FloatMsg("你是公会创建人")
			else
				netorg.C2GSJoinOrgBySpread(orgid)
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, "#G[响应入会]#n")
	return sUrl, dLink
end

function OuQiLink(iUrlID, oid, sText)
	local dLink = {
		sType = "OuQiLink",
		oid = oid,
		sText = sText,
		func = function()
			g_PartnerCtrl:GetOuQiBuff(oid)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#Q[%s]#n", sText))
	return sUrl, dLink
end

--世界答题链接
function QAnswerLink(iUrlID, id, sText)
	local dLink = {
		sType = "QAnswerLink",
		id = id,
		sText = sText,
		func = function()
			CChatMainView:ShowView(function(oView)
				oView:SetQAnswerModel()
				g_ActivityCtrl:GetQuesionAnswerCtrl():ShowQAView(oid)
			end)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[u][%s][/u]#n", sText))
	return sUrl, dLink
end

--空链接
function NilLink(iUrlID, iType, sText)
	local dLink = {
		sType = "NilLink",
		iType = iType,
		sText = sText,
		func = function()
		end
	}
	local sUrl = BuildUrlText(iUrlID, "")
	return sUrl, dLink
end

function PartnerEquipLink(iUrlID, itemid, pid, sText)
	itemid = tonumber(itemid)
	pid = tonumber(pid)
	local oItem = g_ItemCtrl:GetItem(itemid)
	local dLink = {
		sType = "PartnerEquipLink",
		itemid = itemid,
		pid = pid,
		func = function()
			if oItem:GetValue("type") == define.Item.ItemType.PartnerEquip  then
				g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {})
			elseif oItem:GetValue("type") == define.Item.ItemType.PartnerSoul then
				g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {hideui=true})
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

--可以复制的链接
function CopyLink(iUrlID, sText, sCopyText)
	local dLink = {
		sType = "CopyLink",
		func = function()
			C_api.Utils.SetClipBoardText(sCopyText)
			g_NotifyCtrl:FloatMsg("已复制到剪切板")
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[u]%s[/u]#n", sText))
	return sUrl, dLink
end

function FightRecordLink(iUrlID, fid, iView, playerName, targetName)
	local dLink = {
		sType = "FightRecordLink",
		func = function()
			if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
				netarena.C2GSArenaReplayByRecordId(fid, iView)
			end
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#O [战报] #B%s#R VS #B%s #G[点击观看]#n", playerName, targetName))
	return sUrl, dLink
end

function ATPlayerLink(iUrlID, pid, name)
	pid = tonumber(pid)
	local dLink = {
		sType = "ATPlayerLink",
		pid = pid,
		name = name,
		func = function() end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G@%s#n", name))
	return sUrl, dLink
end

function OwnerPartnerLink(iUrlID, iPartnerID, sText)
	iPartnerID = tonumber(iPartnerID)
	local dLink = {
		sType = "OwnerPartnerLink",
		iPartnerID = iPartnerID,
		func = function()
			CPartnerLinkView:ShowView(function (oView)
				oView:SetOwnerPartner(iPartnerID)
			end)
		end
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

function JoinOrg(iUrlID, sText)
	local dLink = {
		sType = "JoinOrg",
		func = function()
			if g_OrgCtrl:HasOrg() then
			else
				netorg.C2GSOrgList()
			end
		end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

function RedPacketLink(iUrlID, sText, sid, id)
	id = tonumber(id)
	sid = tonumber(sid)
	local dLink = {
		sType = "RedPacketLink",
		id = id,
		sid = sid,
		func = function()
			g_ChatCtrl:ClickRedPacket(id)
		end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

function HelpTerraWarLink(iUrlID, terraid, sText, endtime)
	terraid = tonumber(terraid)
	endtime = tonumber(endtime)
	local dLink = {
		sType = "HelpTerraWarLink",
		terraid = terraid,
		endtime = endtime,
		func = function()
			local windowConfirmInfo = {
				msg = "是否前往据点？",
				title = "提示",
				okCallback = function () 
					nethuodong.C2GSGoToHelpTerra(terraid, endtime)
				end,
				okStr = "确定",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("%s", sText))
	return sUrl, dLink
end

function OpenUILink(iUrlID, iOpenUIID, sText)
	iOpenUIID = tonumber(iOpenUIID)
	local dLink = {
		sType = "OpenUILink",
		iOpenUIID = iOpenUIID,
		sText = sText,
		func = callback(LinkTools, "OpenUI", iOpenUIID)
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[%s]#n", sText))
	return sUrl, dLink
end

OPENUI_DICT = {
	[1] = "OpenPowerGuide",
	[2] = "OpenYueKa",
	[3] = "OpenJijin",
}
function OpenUI(_, iOpenUIID)
	local sFuncName  = OPENUI_DICT[iOpenUIID]
	if sFuncName then
		g_OpenUICtrl[sFuncName](g_OpenUICtrl)
	end
end

function OrgGiveWish(iUrlID, sSid, sName, sPid, sText)
	local itemData = DataTools.GetItemData(tonumber(sSid))
	local iPid = tonumber(sPid)
	local dLink = {
		sType = "OrgGiveWish",
		func = function()
			local count = g_ItemCtrl:GetTargetItemCountBySid(itemData.id)
			if iPid == g_AttrCtrl.pid then
				g_NotifyCtrl:FloatMsg("自己无法完成自己的愿望")
			elseif count > 0 then
				local windowConfirmInfo = {
					msg = string.format("是否给予#R%s#n一个#O%s#n？\n%s剩余个数%s", sName, itemData.name, itemData.name, count),
					title = "提示",
					okCallback = function ()
						if itemData.type == define.Item.ItemType.PartnerChip then
							netorg.C2GSGiveOrgWish(iPid)
						else
							netorg.C2GSGiveOrgEquipWish(iPid)
						end
					end,
					okStr = "确定",
					cancelStr = "取消",
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			else
				g_NotifyCtrl:FloatMsg(string.format("你的#O%s#n数量不足", itemData.name))
			end
		end,
	}
	local sUrl = BuildUrlText(iUrlID, sText)
	return sUrl, dLink
end

function WalkToOrgWar(iUrlID, sName)
	local dLink = {
		sType = "WalkToOrgWar",
		func = function()
			g_OrgWarCtrl:WalkToOrgWar()
		end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G%s#n", sName))
	return sUrl, dLink
end

function WalkToGlobalNpc(iUrlID, iNpcID, sText)
	local dLink = {
		sType = "WalkToGlobalNpc",
		func = function()
			local taskData = 
			{
				acceptnpc = tonumber(iNpcID),
			}
			local oTask = CTask.NewByData(taskData)
			g_TaskCtrl:ClickTaskLogic(oTask)
		end,
	}
	local sUrl = BuildUrlText(iUrlID, string.format("#G[u]%s[/u]#n", sText))
	return sUrl, dLink
end

function PartnerSoulLink(iUrlID, sid, sText)
	local itemData = DataTools.GetItemData(sid)
	local oItem = CItem.NewBySid(itemData.id)
	local dLink = {
		sType = "PartnerSoulLink",
		func = function()
			g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {isLink = true, hideBtn = true})
		end,
	}
	local sUrl = BuildUrlText(iUrlID, sText)
	return sUrl, dLink
end

function SimpleItemLink(iUrlID, sid, iAmount)
	local itemData = DataTools.GetItemData(sid)
	local dLink = {
		sType = "SimpleItemLink",
		func = function()
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox}, nil)
		end,
	}
	local sText = ""
	iAmount = tonumber(iAmount)
	local dList = {"#W", "#B", "#P", "#O", "#G", "#R"}
	local sColor = dList[itemData.quality] or "#G"
	if iAmount < 2 then
		sText = string.format("%s[%s]#n", sColor, itemData.name)
	else
		sText = string.format("%s[%s]×%d#n", sColor, itemData.name, iAmount)
	end
	local sUrl = BuildUrlText(iUrlID, sText)
	return sUrl, dLink
end

function SimplePartnerLink(iUrlID, sid, iAmount)
	sid = tonumber(sid)
	local itemData = data.partnerdata.DATA[sid]
	local dLink = {
		sType = "SimpleItemLink",
		func = function()
			--g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox}, nil)
			CPartnerGuideView:ShowView(function (oView)
				oView:SetPartnerID(sid)
			end)
		end,
	}
	local sText = ""
	iAmount = tonumber(iAmount)
	local dList = {"#P", "#O"}
	local sColor = dList[itemData.rare] or "#P"
	if iAmount < 2 then
		sText = string.format("%s[%s]#n", sColor, itemData.name)
	else
		sText = string.format("%s[%s]×%d#n", sColor, itemData.name, iAmount)
	end
	local sUrl = BuildUrlText(iUrlID, sText)
	return sUrl, dLink
end

function OpenAppUrl(iUrlID, strUrl, sName)
	local dLink = {
		sType = "OpenAppUrl",
		func = function()
			Utils.OpenUrl(strUrl)			
		end,
	}
	local sText = string.format("[00ff00]%s#n", sName)
	local sUrl = BuildUrlText(iUrlID, sText)
	return sUrl, dLink
end

--client generate func
function GenerateCreateTeamLink()
	return "{link2}"
end

function GenerateItemLink(idx, itemid, shape, amount)
	return string.format("{link1,%d,%d,%d,%d}", idx, itemid, shape, amount)
end

function GenerateSummonLink(idx, iParid, iPartnerType)
	return string.format("{link5,%d,%d,%d}", idx, iParid, iPartnerType)
end

function GenerateGetTeamFilterLink(iMin, iMax)
	return string.format("{link14,2,%d#%d}", iMin, iMax)
end

function GenerateGetTeamInfoLink(iTeamId, sTarget)
	return string.format("{link3,%d,%s}", iTeamId, sTarget)
end

function GenerateApplyTeamLink(iPid)
	return string.format("{link4,%d}", iPid)
end

function GenerateSpeechLink(sKey, sTranslate, iTime)
	return string.format("{link6,%s,%s,%d}", sKey, sTranslate, iTime)
end

function GenerateEquipSpecialEffLink(iEffectId)
	return string.format("{link7,%d}", iEffectId)
end

function GenerateNameLinkLink(sText,idx, pid)
	return string.format("{link9,%s,%d,%d}", sText, idx, pid)
end

function GenerateOrgRespondLink(orgid)
	return string.format("{link10,%d}", orgid)
end

function GenerateOrgWorldAdvertiseLink(orgid, leaderid)
	return string.format("{link11,%d,%d}", orgid, leaderid)
end

function GenerateOuQiLink(oid, sText)
	return string.format("{link12,%d,%s}", oid, sText)
end

function GenerateQAnswerLink(id, sText)
	return string.format("{link13,%d,%s}", id, sText)
end

function GeneratePartnerEquipLink(itemid, pid, sText)
	return string.format("{link15,%d,%d,%s}", itemid, pid, sText)
end

function GenerateCopyLink(sText, sCopytext)
	return string.format("{link16,%s,%s}", sText, sCopytext)
end

function GenerateFightRecordLink(fid, iView, playerName, targetName)
	return string.format("{link17,%d,%d,%s,%s}", fid, iView, playerName, targetName)
end

function GenerateATPlayerLink(pid, name)
	return string.format("{link18,%d,%s}", pid, name)
end

function GenerateOwnerPartnerLink(iPartnerID, sName)
	return string.format("{link19,%d,%s}", iPartnerID, sName)
end

function GenerateJoinOrgLink(sText)
	return string.format("{link20,%s}", sText)
end

function GenerateHelpTerraWarLink(terraid, sText, endtime)
	return string.format("{link22,%d,%s,%d}", terraid, sText, endtime)
end

function GenerateOpenUILink(iOpenUIID, sText)
	return string.format("{link23,%d,%s}", iOpenUIID, sText)
end

function GenerateOrgGiveWish(iSid, sName, iPid, sText)
	return string.format("{link24,%d,%s,%d,%s}", iSid, sName, iPid, sText)
end

function GenerateWalkToOrgWar(sName)
	return string.format("{link25,%s}", sName)
end

function GenerateWalkToGlobalNpc(iNpcID, sText)
	return string.format("{link26,%d,%s}", iNpcID, sText)
end

function GeneratePartnerSoulLink(iSid, sText)
	return string.format("{link27,%d,%s}", iSid, sText)
end

function GenerateOpenAppUrl(sUrl, sName)
	return string.format("{link30,%s,%s}", sUrl, sName)
end

function FindLink(text, sType)
	local _, lLink = GetLinks(text)
	for k, dLink in pairs(lLink) do
		if dLink.sType == sType then
			return dLink
		end
	end
end

function FindLinkList(text, sType)
	local _, lLink = GetLinks(text)
	local list = {}
	for k, dLink in pairs(lLink) do
		if dLink.sType == sType then
			table.insert(list, dLink)
		end
	end
	return list
end

function GetLinks(text)
	if g_LinkCache[text] then
		return g_LinkCache[text].sUrl, g_LinkCache[text].lLink
	end
	local lLink = {} 
	local iUrlID = 1
	local function process(match)
		iUrlID = #lLink + 1
		local sOneUrl, dLink = ParseOne(match, iUrlID)
		dLink.m_LinkText = match
		table.insert(lLink, dLink)
		return sOneUrl
	end
	local sUrl = string.gsub(text, "%b{}", process)
	g_LinkCache[text] = {sUrl=sUrl, lLink=lLink}
	return sUrl, lLink
end

function ClearLinkCache(text)
	if g_LinkCache[text] then
		g_LinkCache[text] = nil
	end
end

function ClearAllLinkCache()
	g_LinkCache = {}
end

function ParseOne(s, iUrlID)
	local list = string.split(string.gsub(s, "[{}]", ""), ",")
	if #list > 0 then
		local sType = table.remove(list, 1)
		local funcName = g_LinkFuncMap[sType]
		if funcName then
			local linkFunc = LinkTools[funcName]
			if linkFunc then
				local sUrl, dLink = linkFunc(iUrlID, unpack(list, 1, #list))
				return sUrl, dLink
			end
		end

	end
	return s, {}
end

function GetPrintedText(text)
	if text == "" then
		return text
	end
	local sUrl, _ = GetLinks(text) 
	local sText, _ = string.gsub(sUrl, "%[url=(.-)%](.-)%[/url%]", "%2")
	sText = string.gsub(sText, "#%u", "")
	sText = string.gsub(sText, "#n", "")
	sText = string.gsub(sText, "%[u%]", "")
	sText = string.gsub(sText, "%[/u%]", "")
	return sText
end

if g_IsEditor then
	--...可以不传, 只是为了显示在Label中方便查看
	function BuildUrlText(iUrlID, sPrinted, ...)
		local sArgs = table.concat({...}, ",")
		local s = string.format("[url=%d,%s]%s[/url]" , iUrlID , sArgs, sPrinted)
		return s
	end
else
	function BuildUrlText(iUrlID, sPrinted)
		local s = string.format("[url=%d]%s[/url]" , iUrlID, sPrinted)
		return s
	end
end