local tbNpc = Npc:GetClass("GoodVoiceStatue")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("GoodVoice") or Activity.GoodVoice


function tbNpc:OnDialog()
	if not him.tbWinnerInfo or not him.tbStatueInfo then
		return
	end

	local OptList = {
		{Text = "查看资料", Callback = self.OpenPlayerUrl, Param = {self, him.nId}},
		{Text = "我再看看"},
	};

	local szDefaultText = self:GetDefaultTxt(him)

	if self:CheckStatueOwner(me, him) then
		table.insert(OptList, 1, {Text = "更新形象", Callback = self.UpdateStatue, Param = {self, him.nId}})
	end

	local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
	Dialog:Show(tbDialogInfo, me, him);
end

function tbNpc:GetDefaultTxt(pNpc)
	local tbDefaultTxt = 
		{
			-- 暂时只开小区赛
			-- [tbAct.WINNER_TYPE.FINAL_1] = "[FF69B4]「武林第一好声音」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.FINAL_2] = "[FF69B4]「武林第二好声音」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.FINAL_3] = "[FF69B4]「武林第三好声音」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_1] = "[FF69B4]「复赛第一好声音」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_1_1] = "[FF69B4]「华东最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_2_1] = "[FF69B4]「华南最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_3_1] = "[FF69B4]「华中最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_4_1] = "[FF69B4]「华北最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_5_1] = "[FF69B4]「西北最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_6_1] = "[FF69B4]「西南最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_7_1] = "[FF69B4]「东北最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_AREA_8_1] = "[FF69B4]「港澳最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_1_1] = "[FF69B4]「天王最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_2_1] = "[FF69B4]「峨嵋最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_3_1] = "[FF69B4]「桃花最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_4_1] = "[FF69B4]「逍遥最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_5_1] = "[FF69B4]「武当最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_6_1] = "[FF69B4]「天忍最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_7_1] = "[FF69B4]「少林最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_8_1] = "[FF69B4]「翠烟最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_9_1] = "[FF69B4]「唐门最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_10_1] = "[FF69B4]「昆仑最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_11_1] = "[FF69B4]「丐帮最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_12_1] = "[FF69B4]「五毒最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_13_1] = "[FF69B4]「藏剑最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_14_1] = "[FF69B4]「长歌最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_15_1] = "[FF69B4]「天山最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			-- [tbAct.WINNER_TYPE.SEMI_FINAL_FACTION_16_1] = "[FF69B4]「霸刀最强声」[-]%s\n来自：[FFFE0D]%s[-]";
			[tbAct.WINNER_TYPE.LOCAL_1] = "[FF69B4]「诗音阁冠军」[-]%s";
		}
	local szDefaultText = tbDefaultTxt[pNpc.tbWinnerInfo.nWinnerType] or "[FF69B4]「诗音阁冠军」[-]%s"
	return string.format(szDefaultText, pNpc.tbWinnerInfo.szPlayerName, pNpc.tbWinnerInfo.szServerName )
end

-- 是否是跨多服务器的雕像类型（就是别的服务器也有立雕像，本服好声音只有本服才有雕像）
function tbNpc:IsCrossType(nWinnerType)
	if nWinnerType ~= tbAct.WINNER_TYPE.LOCAL_1 then
		return true
	end
	return false
end

function tbNpc:CheckStatueOwner(pPlayer, pNpc)
	if not pPlayer or not pNpc then
		return false
	end

	if not pNpc.tbWinnerInfo or not pNpc.tbStatueInfo then
		return false
	end

	if self:IsCrossType(pNpc.tbWinnerInfo.nWinnerType) and
	 pPlayer.dwID == pNpc.tbWinnerInfo.nPlayerId and
	 math.floor(pNpc.tbWinnerInfo.nServerId/10000) == math.floor(GetServerIdentity()/10000)  then

	 	return true
	 -- 本服雕像只判断玩家id
	 elseif pPlayer.dwID == him.tbWinnerInfo.nPlayerId then
	 	return true
	end

	return false
end

function tbNpc:OpenPlayerUrl(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc or not pNpc.tbWinnerInfo or not pNpc.tbStatueInfo then
		return
	end
	local _, nPlatId, nPartitionId, nAreaId = GetWorldConfifParam()
	nAreaId = Sdk:GetAreaIdByServerId(nPartitionId)
	me.CallClientScript("Ui.HyperTextHandle:Handle", string.format(tbAct:GetPlayerPage(pNpc.tbWinnerInfo.nPlayerId, pNpc.tbWinnerInfo.szAccount, nPartitionId, nAreaId, nPlatId)));
end

function tbNpc:UpdateStatue(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc or not pNpc.tbWinnerInfo or not pNpc.tbStatueInfo then
		return
	end

	if not self:CheckStatueOwner(me, pNpc) then
		return
	end

	tbAct:UpdateStatueInfo(me, pNpc.tbWinnerInfo.nWinnerType, pNpc.tbWinnerInfo.nRank)
end
