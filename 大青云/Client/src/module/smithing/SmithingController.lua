_G.SmithingController = setmetatable({},{__index=IController});
SmithingController.name = "SmithingController";

function SmithingController:Create()
	--镶嵌
	MsgManager:RegisterCallBack(MsgType.SC_EquipGem,self,self.OnEquipGemInfo);
	MsgManager:RegisterCallBack(MsgType.SC_GemInstallResult,self,self.OnInstallResult);
	MsgManager:RegisterCallBack(MsgType.SC_GemChangeResult,self,self.OnGemChangeResult);
	MsgManager:RegisterCallBack(MsgType.SC_GemUninstallResult,self,self.OnUninstallResult);
	MsgManager:RegisterCallBack(MsgType.SC_EquipGemUpLevelInfo,self,self.OnGemUpgradeResult);
	--升星
	MsgManager:RegisterCallBack(MsgType.SC_Stren,self,self.OnEquipStarResult);
	MsgManager:RegisterCallBack(MsgType.SC_EmptyStarOpen,self,self.OnOpenStarResult);

	---融合
	MsgManager:RegisterCallBack(MsgType.SC_EquipMerge,self,self.OnEquipMergeResult);
	

	-- 套装
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupActiInfo, self, self.OnEquipGroupInit)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupOpenPos, self, self.OnEquipGroupActiveResult)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupOpenSet, self, self.OnEquipGroupOpenResult)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupUpLvl, self, self.OnEquipGroupLvUpResult)

	-- 左戒
	MsgManager:RegisterCallBack(MsgType.SC_RingInfo, self, self.OnRingDataUpdate)
	MsgManager:RegisterCallBack(MsgType.SC_RingQuestUpdate, self, self.OnRingTaskUpdate)
	MsgManager:RegisterCallBack(MsgType.SC_RingUpGrade, self, self.OnRingUpGradeResult)

	--- 装备收集（我想睡觉、、、）
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupCollectInfo, self, self.OnEquipCollectInit)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupGet, self, self.AddEquipCollectInfo)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupGetReward, self, self.OnEquipCollectRewardResult)
	MsgManager:RegisterCallBack(MsgType.SC_EquipGroupActivit, self, self.OnEquipCollectActiveResult)
end

function SmithingController:OnEquipGemInfo(msg)
	for i,vo in pairs(msg.list) do
		SmithingModel:AddGem(vo);
	end
	
	self:sendNotification(NotifyConsts.GemInlayInfoChange);
	
end

function SmithingController:SendReqGemInstall(pos,hole,gemid, bAuto)
	local msg = ReqGemInstallMsg:new();
	msg.pos = pos;
	msg.slot = hole;
	msg.tid = gemid;
	msg.bAutoBuy = bAuto
	MsgManager:Send(msg);
end
function SmithingController:OnInstallResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.GemInlayResult,SmithingModel:AddGem(msg));
		UISmithingInlay:PlayInlayPfx(msg.slot)
	else
		
	end
end

function SmithingController:SendGemUninstall(pos,hole,gemid)
	local msg = ReqGemUninstallMsg:new();
	msg.pos = pos;
	msg.slot = hole;
	msg.tid = gemid;
	MsgManager:Send(msg);
end
function SmithingController:OnUninstallResult(msg)
	if msg.result == 0 then
		SmithingModel:RemoveGemInEquip(msg.pos,msg.slot)
		self:sendNotification(NotifyConsts.GemInlayUnResult, {msg.slot});
	else
		
	end
end

function SmithingController:SendGemUpgrade(id,pos,hole,onekey,buy)
	local msg = ReqEquipGemUpLevelMsg:new();
	msg.tid = id;
	msg.pos = pos;
	msg.slot = hole;
	msg.autoUp = onekey;
	msg.autoBuy = buy;
	MsgManager:Send(msg);
end
function SmithingController:OnGemUpgradeResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.GemInlayUpgradeResult,SmithingModel:AddGem(msg));
		UISmithingInlay:PlayInlayPfx(msg.slot)
	else
		
	end
end

function SmithingController:SendChangeGem(pos,hole,srcid,dstid)
	local msg = ReqGemChangeMsg:new();
	msg.pos = pos;
	msg.slot = hole;
	msg.gem_oldId = srcid;
	msg.gem_newId = dstid;
	MsgManager:Send(msg);
end
function SmithingController:OnGemChangeResult(msg)
	if msg.result == 0 then
		SmithingModel:RemoveGemInEquip(msg.pos,msg.slot);
		msg.tid = msg.gem_newId;
		self:sendNotification(NotifyConsts.GemInlayChangeResult,SmithingModel:AddGem(msg));
		UISmithingInlay:PlayInlayPfx(msg.slot)
	else
	
	end
end


function SmithingController:SendEquipStar(id,useyuanbao)
	local msg = ReqStrenMsg:new();
	msg.id = id;
	msg.useyuanbao = useyuanbao;
	MsgManager:Send(msg);
end
function SmithingController:OnEquipStarResult(msg)
	EquipModel:SetStrenInfo(msg.id,msg.strenLvl,msg.emptystarnum);
	self:sendNotification(NotifyConsts.EquipStarResult, {msg.result, msg.id, msg.strenLvl, msg.emptystarnum});
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig['smithingstar1'])
	else
		FloatManager:AddNormal(StrConfig['smithingstar2'])
		UISmithingStar:playFailPfx1()
	end
end

function SmithingController:SendOpenStar(id)
	local msg = ReqEmptyStarOpenMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end
function SmithingController:OnOpenStarResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.EquipOpenStarResult, {msg.id});
	else
	end
end

function SmithingController:SendEquipFusion(id1,id2,typeOne,TypeTwo)
	local msg = ReqEquipMerge:new();
	msg.id = id1
	msg._id = id2
	msg.src_bag = typeOne
	msg.dst_bag = TypeTwo
	MsgManager:Send(msg)
end

--OnEquipMergeResult
function SmithingController:OnEquipMergeResult(msg)
	print("返回结果:",msg.result)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.EquipMergeResult,msg.result);
		return;
	end
	if msg.result == -1 then
		FloatManager:AddNormal( StrConfig["role434"] )
		return;
	end
	if msg.result == -2 then
		FloatManager:AddNormal( StrConfig["role435"] )
		return;
	end
	if msg.result == -3 then
		FloatManager:AddNormal( StrConfig["role436"] )
		return;
	end
	if msg.result == -4 then
		FloatManager:AddNormal( StrConfig["role437"] )
		return;
	end
	if msg.result == -5 then
		FloatManager:AddNormal( StrConfig["role438"] )
		return;
	end
	if msg.result == -6 then
		FloatManager:AddNormal( StrConfig["role439"] )
		return;
	end
end

----------------------------------------------------------------------套装------------------------------------------------------------------
function SmithingController:OnEquipGroupInit(msg)
	SmithingModel:InitEquipGroupInfo(msg.list)
end

function SmithingController:OnEquipGroupOpenResult(msg)
	if msg.result == 0 then
		SmithingModel:EquipGroupOpen(msg.pos, msg.index)
		self:sendNotification(NotifyConsts.EquipGroupOpenSlot, {msg.pos, msg.index});
	end
end

function SmithingController:OnEquipGroupActiveResult(msg)
	if msg.result == 0 then
		SmithingModel:EquipGroupActive(msg.pos, msg.index)
		self:sendNotification(NotifyConsts.EquipGroupActive, {msg.pos, msg.index});
	end
end

function SmithingController:OnEquipGroupLvUpResult(msg)
	if msg.result == 0 then
		SmithingModel:EquipGroupUpLv(msg.pos, msg.index, msg.lvl)
		self:sendNotification(NotifyConsts.EquipGroupUpdate, {msg.pos, msg.index});
	end
end

function SmithingController:AskActiveEquipGroup(pos, index, groupTid)
	local msg = ReqEquipGroupOpenPosMsg:new();
	msg.pos = pos;
	msg.index = index;
	msg.groupTid = groupTid;
	MsgManager:Send(msg);
end

function SmithingController:AskOpenEquipGroup(pos, index, groupTid)
	local msg = ReqEquipGroupOpenSetMsg:new();
	msg.pos = pos;
	msg.index = index;
	msg.groupTid = groupTid;
	MsgManager:Send(msg);
end

function SmithingController:AskUpLvEquipGroup(pos, index, groupTid)
	local msg = ReqEquipGroupUpLvlMsg:new();
	msg.pos = pos;
	msg.index = index;
	msg.groupTid = groupTid;
	MsgManager:Send(msg);
end

-------------------------------------------------------------------左戒------------------------------------------------------------
function SmithingController:OnRingDataUpdate(msg)
	SmithingModel:RingDataUpdate(msg)
end

function SmithingController:OnRingTaskUpdate(msg)
	SmithingModel:RingTaskUpdate(msg)
	self:sendNotification(NotifyConsts.RingTaskUpdate)
end

function SmithingController:OnRingUpGradeResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.RingUpGrade)
	end
end

function SmithingController:AskRingUpGrade(cid)
	local msg = ReqRingUpGradeMsg:new();
	msg.cid = cid
	MsgManager:Send(msg);
end

------------------------------------------------------------------------装备收集--------------------------------------------

function SmithingController:OnEquipCollectInit(msg)
	for k, v in pairs(msg.list) do
		SmithingModel:OnEquipCollectInfoInit(v)
	end
end

function SmithingController:AddEquipCollectInfo(msg)
	SmithingModel:AddEquipCollectInfo(msg)
	self:sendNotification(NotifyConsts.EquipCollectUpdate)
end

function SmithingController:OnEquipCollectRewardResult(msg)
	if msg.result == 0 then
		SmithingModel:GetCollectRewardResult(msg.lv)
		self:sendNotification(NotifyConsts.EquipCollectUpdate)
	end
end

function SmithingController:OnEquipCollectActiveResult(msg)
	if msg.result == 0 then
		SmithingModel:EquipCollectActiveResult(msg.lv, msg.number)
		self:sendNotification(NotifyConsts.EquipCollectUpdate)
	end
end

function SmithingController:AskEquipCollectActive(lv, number)
	local msg = ReqEquipGroupActivit:new();
	msg.lv = lv
	msg.number = number
	MsgManager:Send(msg);
end

function SmithingController:GetEquipCollectReward(lv)
	local msg = ReqEquipGroupGetReward:new();
	msg.lv = lv
	MsgManager:Send(msg);
end
function SmithingController:IsOpen()
	local openLevel = t_funcOpen[FuncConsts.equipCollect].open_level
	return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end