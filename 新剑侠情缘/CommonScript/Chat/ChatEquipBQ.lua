ChatMgr.ChatEquipBQ = ChatMgr.ChatEquipBQ or {}
local ChatEquipBQ = ChatMgr.ChatEquipBQ
ChatEquipBQ.nNpcType = -1
ChatEquipBQ.tbEquipBQ = ChatEquipBQ.tbEquipBQ or {}
function ChatEquipBQ:LoadSetting()
	local tbData = LoadTabFile("Setting/Chat/ChatEquipBQ.tab", "dd", nil, {"nEquipId", "nChatID"});
	for _, v in ipairs(tbData) do
		ChatEquipBQ.tbEquipBQ[v.nEquipId] = ChatEquipBQ.tbEquipBQ[v.nEquipId] or {}
		table.insert(ChatEquipBQ.tbEquipBQ[v.nEquipId], v.nChatID)
	end
end

if not next(ChatEquipBQ.tbEquipBQ) then
	ChatEquipBQ:LoadSetting()
end

function ChatEquipBQ:GetAllEquipBQ(pPlayer)
	local tbAllBQ = {}
	local tbAllBQRef = {}
	--local tbEquips = pPlayer.GetEquips() or {}
	local tbWaiYi = self:GetWaiYiEquip(pPlayer)
	--local tbEquips = Lib:MergeMapTable(tbEquips, tbWaiYi)
	for _, nEquipId in pairs(tbWaiYi) do
		local tbBQ = ChatEquipBQ.tbEquipBQ[nEquipId] or {}
		for _, nBQId in ipairs(tbBQ) do
			if not tbAllBQRef[nBQId] then
				tbAllBQRef[nBQId] = {}
				table.insert(tbAllBQ, nBQId)	
			end
			tbAllBQRef[nBQId][nEquipId] = true
		end
	end
	return tbAllBQ, tbAllBQRef
end

function ChatEquipBQ:GetWaiYiEquip(pPlayer)
	local tbWaiYi = {}
	local pWaiyi = pPlayer.GetEquipByPos(Item.EQUIPPOS_WAIYI)
	if pWaiyi and pWaiyi.dwTemplateId then
		table.insert(tbWaiYi, pWaiyi.dwTemplateId)
	end
	return tbWaiYi
end

function ChatEquipBQ:CheckEquipBQ(pPlayer, nBQId)
	local _, tbAllBQRef = self:GetAllEquipBQ(pPlayer)
	return tbAllBQRef[nBQId]
end

function ChatEquipBQ:CheckSafeArea(pPlayer)
	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		return false
	end
	return true
end

function ChatEquipBQ:CheckCommon(pPlayer, bNotCheckSafe)
	local pWaiyi = pPlayer.GetEquipByPos(Item.EQUIPPOS_WAIYI)
	if not pWaiyi then
		return false
	end
	local tbBQ = ChatEquipBQ.tbEquipBQ[pWaiyi.dwTemplateId] or {}
	if not next(tbBQ) then
		return false
	end
	if not bNotCheckSafe and not self:CheckSafeArea(pPlayer) then
		return false
	end
	return true
end

function ChatEquipBQ:OnUseEquip(pPlayer, nEquipId)
	if not self:CheckCommon(pPlayer) then
		return
	end
	pPlayer.CallClientScript("ChatMgr.ChatEquipBQ:TryOpenEquipBQGuideC")
end

function ChatEquipBQ:TryOpenEquipBQGuideC(bNotCheckSafe)
	local nFlag = Client:GetFlag("EquipBQGuide") or 0
	if nFlag ~= 0 then
		return
	end
	if not self:CheckCommon(me, bNotCheckSafe) then
		return
	end
	self:DoOpenEquipBQGuideC()
end

function ChatEquipBQ:DoOpenEquipBQGuideC()
	Client:SetFlag("EquipBQGuide", 1)
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("WaiyiPreview")
	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Public, nil, "OpenEmotionLink", nil, {szTab = "ActionExpression", bShowGuide = true})
end

function ChatEquipBQ:OnPlayerTrapC(nMapTemplateID, szTrapName)
	if Map:IsFieldFightMap(nMapTemplateID) or Map:IsBossMap(nMapTemplateID) then
		if szTrapName == "TrapPeace" and me.nFightMode ~= 0 then
			self:TryOpenEquipBQGuideC(true)
		end
	end
end