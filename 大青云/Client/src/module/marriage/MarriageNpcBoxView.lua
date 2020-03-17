--[[
结婚npc，
wangshuai
]]

_G.UIMarryNpcBox = UINpcDialogBase:new("UIMarryNpcBox")

function UIMarryNpcBox:Create()
	self:AddSWF("marryNpcDialogBox.swf",true,"center");
end

function UIMarryNpcBox:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local cfg = self.npc:GetCfg();
	if cfg then 
		objSwf.labelNpcName.text = cfg.name;
		objSwf.tfTalk.text = cfg.talk;
	end;

	--draw3D
 	self:DrawNpc();
 	local optionList = {};
 	--功能
	if cfg.func ~= "" then
		local funcTable = split( cfg.func, "," );
		for i = 1, #funcTable do
			local listVO = {};
			listVO.itemType = 2;
			local id = tonumber( funcTable[i] )
			local cfg = UIMarryNpcBox.NpcFuncConfig[id]
			local label = cfg and cfg.label or "missing"
			listVO.id = id
			listVO.label = string.format( "<u><font color='#00FF00'>%s</font></u>", label );
			table.push( optionList, listVO );
		end
	end
		--刷新列表
	objSwf.optionList.dataProvider:cleanUp();
	for i = 1, #optionList do
		objSwf.optionList.dataProvider:push( UIData.encode( optionList[i] ) );
	end
	objSwf.optionList:invalidateData();

	--327,143  sp 32
	--动态坐标
	for i=0,5 do 
		local item = objSwf["item"..i + 1];
		if self.npc.npcId == MarriageConsts.NpcYuelao then 
			item._y = 143 + (i * 32);
		elseif self.npc.npcId == MarriageConsts.NpcSiyi 
			or self.npc.npcId == MarriageConsts.NpcHuatong  then
			-- 208
			item._y = 208 + (i * 32)
		end;
	end;
end;


--打开面板
--@param npcId  NPCID
--@param dungeonStepId stepID
function UIMarryNpcBox:Open( npcId,isAuto)
	local npc = NpcModel:GetNpcByNpcId(npcId);
	if not npc then return; end
	self.npc = npc;
	self:Show();
	if isAuto then 
		TimerManager:RegisterTimer(function()
			if UIDungeonDialogBox:IsShow() then 
				self:DoQuestAndHide();
			end;
		end, 5000, 1)
	end;
end

function UIMarryNpcBox:OnItemClick(e)
	if not e.item.itemType then	return; end
	--点击NPC功能,根据索引执行相应脚本
	if e.item.itemType == 2 then
		local id = e.item.id
		if not id then return end
		local cfg = UIMarryNpcBox.NpcFuncConfig[id]
		local func = cfg and cfg.func
		if func then func() end
	end
end

function UIMarryNpcBox:OnHide()
	--界面关闭，
	if UIMarryProposal:IsShow() then 
		UIMarryProposal:Hide()
	end;
	if UIMarryTimeSelect:IsShow() then 
		UIMarryTimeSelect:Hide()
	end;
	if UIDivorceTwo:IsShow() then 
		UIDivorceTwo:Hide()
	end;
	if UIDivorceOne:IsShow() then 
		UIDivorceOne:Hide()
	end;
	if MarriagController.tishiPanel then 
		UIConfirm:Close(MarriagController.tishiPanel);
	end;
end;	



UIMarryNpcBox.NpcFuncConfig = {
	[101] = {
		label = StrConfig["marriage001"],--求婚
		func = function()
			if not UIMarryProposal:IsShow() then 
				UIMarryProposal:ShowJudge();
			end;
		end
	},
	[102] = {
		label = StrConfig["marriage002"],--我们要结婚！
		func = function()
			local state = MarriageModel:GetMyMarryState()
			-- trace(MarriageModel.MarryState)
			if state == MarriageConsts.marryReserve then 

				if MarriageModel:GetMyMarryType() ~= 0 then 
					if MarriageModel:GetMyMarryTime() > 0 then 
						FloatManager:AddNormal( StrConfig["marriage046"]);
						return 
					end;
					if not UIMarryTimeSelect:IsShow() then 
						UIMarryTimeSelect:ShowJudge();
					return 
					end;
				end;
				if not UIMarryTypeSelect:IsShow() then 
					UIMarryTypeSelect:Show();
					return 
				end;

			elseif state == MarriageConsts.marryMarried then 
				FloatManager:AddNormal( StrConfig["marriage019"]);
			elseif state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then 
				FloatManager:AddNormal( StrConfig["marriage021"]);
			end;
			-- if not UIMarryTypeSelect:IsShow() then 
			-- 	UIMarryTypeSelect:ShowJudge();
			-- end;
		end
	},
	[103] = {
		label = StrConfig["marriage003"],--开启结巡游
		func = function()
			MarryUtils:MarryTravelStep()
		end
	},
	[104] = {
		label = StrConfig["marriage004"],--进入婚礼礼堂
		func = function()
			MarryUtils:MarryEnterSceneStep()
		end
	},
	[105] = {
		label = StrConfig["marriage005"],--双方协议离婚
		func = function()
			if not UIDivorceTwo:IsShow() then 
				UIDivorceTwo:ShowJudge();
			end;
		end
	},
	[106] = {
		label = StrConfig["marriage006"],--单方强制离婚
		func = function()
			if not UIDivorceOne:IsShow() then 
				UIDivorceOne:ShowJudge();
			end;
		end
	},
	[107] = {
		label = StrConfig["marriage007"],--邀请亲朋好友入场
		func = function()
			MarryUtils:MarrySceneInviteStep()
		end
	},
	[108] = {
		label = StrConfig["marriage008"],--开启婚礼仪式
		func = function()
			MarryUtils:MarryOpenStep()
		end
	},
	[109] = {
		label = "";--StrConfig["marriage009"],--开启婚礼酒宴
		func = function()
			MarryUtils:MarryOpenFEASTStep()
		end
	},
	[110] = {
		label = StrConfig["marriage011"],--送红包,得喜糖
		func = function()
			if not MarryGiveFive:IsShow() then 
				MarryGiveFive:ShowJudge();
			end;
		end
	},
	[111] = {
		label = StrConfig["marriage013"],--查看红包详情
		func = function()		
			if not MarryGiveBeFive:IsShow() then 
				MarryGiveBeFive:ShowJudge()
			end;
		end
	},
	[112] = {
		label = StrConfig["marriage038"],--新人发送全服红包
		func = function()		
			if not MarryGiveAllFive:IsShow() then 
				MarryGiveAllFive:ShowJudge()
			end;
		end
	},
}