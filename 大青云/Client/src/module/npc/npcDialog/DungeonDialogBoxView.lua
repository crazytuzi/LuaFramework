
_G.UIDungeonDialogBox = UINpcDialogBase:new("UIDungeonDialogBox")

function UIDungeonDialogBox:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--显示npc名字
	local npcCfg = self.npc:GetCfg();
	if npcCfg then
		objSwf.labelNpcName.text = npcCfg.name;
	end
	--draw3D
	self:DrawNpc();
	--显示对话
	local dungeonStepVO = t_dunstep[self.dungeonStepId]
	-- local diffi = DungeonModel:GetDungeonDifficulty() 
	local list = split(dungeonStepVO.goals1, "#")
	local NpcCfg = split(list[1],",");  ---split(dungeonStepVO.goals1,",");
	if toint(NpcCfg[1]) == self.npc.npcId then 
		if dungeonStepVO.dialog and dungeonStepVO.dialog ~= "" then
			objSwf.tfTalk.text = dungeonStepVO.dialog
				--显示列表
			local listVO = { label = dungeonStepVO.self_dialog or StrConfig["npcDialog001"] }
			local uiList = objSwf.optionList
			uiList.dataProvider:cleanUp();
			uiList.dataProvider:push( UIData.encode( listVO ) )
			uiList:invalidateData();
		else
			local cfg = t_npc[20100168]
			objSwf.tfTalk.text = cfg.talk
			local uiList = objSwf.optionList
			uiList.dataProvider:cleanUp();
			uiList.dataProvider:push( UIData.encode( {} ) )
			uiList:invalidateData();
		end
	else
		local cfg = t_npc[20100168]
		objSwf.tfTalk.text = cfg.talk
		local uiList = objSwf.optionList
		uiList.dataProvider:cleanUp();
		uiList.dataProvider:push( UIData.encode( {} ) )
		uiList:invalidateData();
	end;
	
	
end

function UIDungeonDialogBox:OnItemClick()
	self:DoQuestAndHide()
end

function UIDungeonDialogBox:AutoCompleteDialog()
	self:DoQuestAndHide()
end

--点击下方按钮 
function UIDungeonDialogBox:DoQuestAndHide()
	self:DoQuest()
	self:Hide()
end

--执行任务处理
function UIDungeonDialogBox:DoQuest()
	if DungeonModel:GetDungeonStep() > 0 then
		DungeonController:ReqDungeonNpCTalkEnd()
		return true
	end
	if ZhuanModel:GetZhuanCopyid() > 0 then
		ZhuanContoller:ReqDungeonNpCTalkEnd();
		return true
	end
end

--打开面板
--@param npcId  NPCID
--@param dungeonStepId stepID
function UIDungeonDialogBox:Open( npcId, dungeonStepId ,isAuto)
	self:SendNPCGossipMsg(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId);
	if not npc then return; end
	self.npc = npc;
	self.dungeonStepId = dungeonStepId;
	self:Show();
	if isAuto then 
		TimerManager:RegisterTimer(function()
			if UIDungeonDialogBox:IsShow() then 
				self:DoQuestAndHide();
			end;
		end, 5000, 1)
	end;
end