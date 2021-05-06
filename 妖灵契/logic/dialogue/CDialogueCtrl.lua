local CDialogueCtrl = class("CDialogueCtrl", CCtrlBase)

CDialogueCtrl.DIALOUGE_10509_ID = 99910509  --剧场10509触发的本地对话
CDialogueCtrl.DIALOUGE_ACCEPT_SHIMEN_TASK_ID = 99999999  --接取下一轮师门本地对话


CDialogueCtrl.NpcTipsDialogueConfig = 
{
	IntervalTime = 20,
	StartTime = 2,	
}

function CDialogueCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_NpcSayData = nil

	self.m_NpcDialogInfo = nil

	self.m_StoryData = nil

	self.m_IsPlayStory = false

	self.m_HideView = {}

	self.m_FightNpc = {}

	self.m_DialogueNpcEmoji = {}

	self.m_CacheSocialDialogue = {}

	self.m_DestroyNpcEffectWalkers = {}
end

function CDialogueCtrl.NewNpcSayData(self, pbdata)
	local d = 
	{
		dialog = 
		{
			[1] = 
			{	content = pbdata.text,
				type = 2, --与目标Npc对话
				ui_mode = define.Dialogue.Mode.MainMenu,
				voice = 0,
			}
		},
		dialog_id = 0,
		sessionidx = pbdata.sessionidx,
		npcid = pbdata.npcid,
		shape = pbdata.shape,
		npc_name = pbdata.name,
		text = pbdata.text,
		task_type = 0,
	}
	return d
end

function CDialogueCtrl.GS2CNpcSay(self, pbdata)
	--如果当前正在引导，则不会显示NPC对话
	local oView = CGuideView:GetView()	
	if (oView and oView:GetActive() == true) or g_HouseCtrl:IsInHouse() then	
		return 
	end
	if pbdata then
		local isFightNpc = pbdata.fight or false
		self.m_FightNpc[pbdata.npcid] = isFightNpc
		self.m_NpcSayData = self:NewNpcSayData(pbdata)
		CDialogueMainView:ShowView(function (oView)
			oView:SetContent(self.m_NpcSayData)
			self:OnEvent(define.Dialogue.Event.Dialogue, self.m_NpcSayData)
		end)
	end
end

function CDialogueCtrl.GS2CDialog(self, pbdata)
	--如果当前正在引导，则不会显示NPC对话
	local oView = CGuideView:GetView()	
	if (oView and oView:GetActive() == true) or g_HouseCtrl:IsInHouse() then		
		return 
	end	
	if pbdata then
		self.m_NpcDialogInfo = table.copy(pbdata) 
		self.m_NpcDialogInfo.npcid = self.m_NpcDialogInfo.npc_id
		self.m_NpcDialogInfo.npc_id = nil
		local oView = CDialogueMainView:GetView()
		if oView then
			oView:SetContent(self.m_NpcDialogInfo)
			self:OnEvent(define.Dialogue.Event.Dialogue, self.m_NpcDialogInfo)
		else
			CDialogueMainView:ShowView(function (oView)
				oView:SetContent(self.m_NpcDialogInfo)
				self:OnEvent(define.Dialogue.Event.Dialogue, self.m_NpcDialogInfo)
			end)	
		end		
	end
end

--获取下一句对白的编号和对话选择文本
function CDialogueCtrl.GetSwithDialogueTable(self, str)
	local t = {}
	if str and str ~= "" then
		local info = string.split(str, '|')
		if #info > 0 then
			for i = 1, #info do				
				local temp = string.split(info[i], '=')
				local d = {}
				if #temp >= 2 then	
					d.id = temp[1]
					d.str = temp[2]
				else			  			
					d.id = temp[1]
					d.str = ""
				end
				table.insert(t, d)
			end
		end
	end
	return t
end

function CDialogueCtrl.GetDialogNpcConfig(self, shape)	
	local t = nil
	local d = data.npcdata.DIALOG_NPC_CONFIG[shape]
	if d then
		t = {}
		t.leftConfig = {}
		t.rightConfig = {}
		local left = string.split(d.left_config, "|")
		local right = string.split(d.right_config, "|")
		if left and #left >= 4 then
			t.leftConfig.x = tonumber(left[1]) 
			t.leftConfig.y = tonumber(left[2]) 
			t.leftConfig.w = tonumber(left[3]) 
			t.leftConfig.h = tonumber(left[4]) 
		else
			printc(string.format("人物左侧对话配置有错误 %d", shape))
		end

		if right and #right >= 4 then
			t.rightConfig.x = tonumber(right[1]) 
			t.rightConfig.y = tonumber(right[2]) 
			t.rightConfig.w = tonumber(right[3]) 
			t.rightConfig.h = tonumber(right[4]) 
		else
			printc(string.format("人物右侧对话配置有错误 %d", shape))
		end		
	end

	return t
end

function CDialogueCtrl.GetFullTextureSize(self, shape)
	local d = data.npcdata.DIALOG_NPC_CONFIG[shape]
	if d then
		return d["full_size"]
	end
end

function CDialogueCtrl.GetFullTextureOffset(self, shape)
	local d = data.npcdata.DIALOG_NPC_CONFIG[shape]
	if d then
		return d["full_center"]
	end
end

--显示对话界面时，隐藏其他所有界面	
function CDialogueCtrl.HideAllViews(self)
	self.m_HideView = {}
	local MaskView = 
	{
	 	["CDialogueMainView"] = true,
	 	["CNotifyView"] = true,
	 	["CHouseExchangeView"] = true,
	 	["CLockScreenView"] = true,
	 	["CBottomView"] = true,
	 	["CGuideView"] = true,
	}
	local t = g_ViewCtrl.m_Views
	if t and next(t) then
		for k, oView in pairs(t) do
			if oView:GetActive() == true and MaskView[oView.classname] == nil then
				oView:SetActive(false)
				table.insert(self.m_HideView, oView)
			end
		end
	end
	self:OnEvent(define.Dialogue.Event.HideAllViews)
end

--关闭对话界面时，显示开始隐藏的所有界面
function CDialogueCtrl.ShowAllViews(self)
	if self.m_HideView and next(self.m_HideView) then
		for k, oView in pairs(self.m_HideView) do
			if not Utils.IsNil(oView) then
				oView:SetActive(true)
			end
		end		
	end
	self.m_HideView = {}
end

--Npc消失时关闭对话界面
function CDialogueCtrl.CloseView(self)
	CDialogueMainView:CloseView()
end

--关闭对话界面时，显示开始隐藏的所有界面
function CDialogueCtrl.AddSubTalker(self, subTalkerNnpc)
	g_MapCtrl:AddSubTaskerNpc(subTalkerNnpc)
end

--关闭对话界面时，显示开始隐藏的所有界面
function CDialogueCtrl.DelSubTalker(self, npctype)
	g_MapCtrl:DelayDelSubTalkerNpc()
end

--播放主线章节动画
function CDialogueCtrl.PlayStartStory(self, aniId)
	aniId = tonumber(aniId)
	self.m_StoryData = data.taskdata.TASK.STORY.ANI_CONFIG[aniId]
	if self.m_StoryData then
		CDialogueStoryStartView:ShowView(function (oView)
			oView:SetContent(self.m_StoryData)
			self:SetPlayStoryState(true)			
		end)	
	end	
end

function CDialogueCtrl.IsPlayStory(self)
	return self.m_IsPlayStory
end

function CDialogueCtrl.SetPlayStoryState(self, bState)
	self.m_IsPlayStory = bState
end

function CDialogueCtrl.GetDialogAnimationCommand(self, command)
	local t = {}
	if command and command ~= "" then 
		local list = string.split(command, "|")
		if #list > 0 then
			for i = 1, #list do 
				local cmd = string.split(list[i], ",")
				if #cmd >= 2 then
					local timeKey = tonumber(cmd[1])
					local actionKey = tostring(cmd[2]) 					
					t[timeKey] = t[timeKey] or {}
					local temp = {}
					for k = 3, #cmd do
						table.insert(temp, cmd[k])
					end					
					t[timeKey][actionKey] = temp
				end
			end
		end
	end
	return t
end

function CDialogueCtrl.CheckDialogTips(self, isAdd, list)
	local hero = g_MapCtrl:GetHero()
	if hero then
		hero:SetDialogTipsTag(0)
	end
	local function DelDialogTipsTable(t)
		if t and next(t) ~= nil then
			for k, v in pairs(t) do
				v:SetDialogTipsTag(0)
			end
		end
	end

	local function AddDialogTips(t, name)
		if t and next(t) ~= nil then
			for k, v in pairs(t) do
				if v.m_Name and v.m_Name == name then
					v:SetDialogTipsTag(1)
					v:SetTaskMark()
				end
			end
		end
	end

	DelDialogTipsTable(g_MapCtrl.m_Npcs)
	DelDialogTipsTable(g_MapCtrl.m_DynamicNpcs)
	DelDialogTipsTable(g_MapCtrl.m_EscortNpcs)
	DelDialogTipsTable(g_MapCtrl.m_SubTalkerNpcs)

	if isAdd == true and list and #list > 0 then
		for i = 1, #list do
			if list[i].isHero == true then
				if hero then
					hero:SetDialogTipsTag(1)
				end				
			else
				AddDialogTips(g_MapCtrl.m_Npcs, list[i].name)
				AddDialogTips(g_MapCtrl.m_DynamicNpcs, list[i].name)
				AddDialogTips(g_MapCtrl.m_EscortNpcs, list[i].name)
				AddDialogTips(g_MapCtrl.m_SubTalkerNpcs, list[i].name)
			end
		end
	end

end

function CDialogueCtrl.GetTalkDistanceOffset(self)
	local offset = {0, 0.1, 0.2}
	return table.randomvalue(offset)
end

function CDialogueCtrl.CheckLastOpenBtn(self, taskId)
	local b = true
	if self.m_OpenBtnTaskId == taskId then
		b = false
	end
	return b
end

function CDialogueCtrl.CacheTaskOpenBtn(self, taskId)
	self.m_OpenBtnTaskId = taskId
end

function CDialogueCtrl.HasNpcFightTime(self, npcId)
	return self.m_FightNpc[npcId] or false
end

function CDialogueCtrl.GetDynamicNpcAddEffectData(self, npcType)
	local t = nil
	local d = data.npcdata.TASK_NPC[npcType]
	if d and d.addEffectType ~= 0 then
		t = d
	end
	return t
end

function CDialogueCtrl.AddEffectNpc(self, npcType)
	local npc = g_MapCtrl:GetDynamicNpcByNpcType(npcType)
	if npc and npc.m_AddEffData then
		if npc.m_AddEffData.addEffectType == 1 then
			if not npc.m_IsAddDone then
				npc:SetFadeIn()
			end			
		elseif npc.m_AddEffData.addEffectType == 2 then
			if not npc.m_IsAddDone then
				npc:AddWalkEffect()
			end
		elseif npc.m_AddEffData.addEffectType == 4 then
			if not npc.m_IsAddDone then
				npc:DoSocialAction()
			end			
		end
	end
end

function CDialogueCtrl.ProgressNpcAddEffect(self, idstr)
	if not idstr or idstr == "" then
		return
	end
	local list = string.split(idstr, ",")
	if #list > 0 then
		for i = 1, #list do
			local npcType = tonumber(list[i])
			self:AddEffectNpc(npcType)
		end
	end
end

function CDialogueCtrl.DestroyDynamicEffect( self, oWalker)
	if oWalker then
		self.m_DestroyNpcEffectWalkers[oWalker:GetInstanceID()] = oWalker
	end
end

function CDialogueCtrl.GetDialogueSpineConfig(self, shape, isMid)
	local t
	if shape then
		--三兄弟暂时没有对话的spine动画
		if tonumber(shape) == 1005 or tonumber(shape) == 1006 or tonumber(shape) == 1007 then
			return t
		end
		local d = data.spinedata.CONFIG[tostring(shape)]
		if d then
			if isMid then
				t = d.dialogue_mid_config
			else
				t = d.dialogue_side_config
			end		
		end
	end
	return t
end

function CDialogueCtrl.ResetData(self)
	self.m_NpcSayData = nil
	self.m_NpcDialogInfo = nil
	self.m_StoryData = nil
end

function CDialogueCtrl.GetDialogueSpineAni(self, dialogueId, sudId, side)
	local anis = {"idle"}
	local t = data.taskdata.TASK.STORY.DIALOG
	if t[dialogueId] and t[dialogueId][sudId] then
		local d = t[dialogueId][sudId].spine_ani_list
		if d and d ~= "" then
			local list = string.split(d, ";")
			if next(list) and #list >= side then				
				local str = list[side]
				if str and str ~= "" then
					anis = string.split(str, ",")
				end				
			end
		end
	end
	return anis
end

--任务npc动态隐藏
function CDialogueCtrl.ProgressHideDynamicNpc(self, dialogueId, sudId)
	local t = data.taskdata.TASK.STORY.DIALOG
	if t[dialogueId] and t[dialogueId][sudId] then
		local hideList = t[dialogueId][sudId].dialogue_hide_action
		if hideList and hideList ~= "" then
			local list = string.split(hideList, ";")
			if list and next(list) then
				for i = 1, #list do

					local npcType = tonumber(list[i])					
					local npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
					if npcId then
						local npc = g_MapCtrl:GetDynamicNpc(npcId)
						if npc and npc.m_IsHide ~= true then						
							npc:SetFadeOutUnActive()
						end					
					end
				end
			end
		end
	end
end

--任务npc对话跳过时隐藏处理
function CDialogueCtrl.ProgressWhenJumpView(self, dialogueData)
	if dialogueData then
		local dialogueId = dialogueData.dialog_id
		local dialog = dialogueData.dialog
		if dialogueId and dialog and next(dialog) then
			for i, v in ipairs(dialog) do
				self:ProgressHideDynamicNpc(dialogueId, v.subid)
			end
		end
	end
end

CDialogueCtrl.LOCAL_DIALOG = 
{
	[99910509]={
		[1]={
			social_action_list=[[0,mengbi]],
		}
	} 
}

--任务npc社交表情
function CDialogueCtrl.ProgressDynamicSocailEmoji(self, dialogueId, sudId)
	if self.m_DialogueNpcEmoji and next(self.m_DialogueNpcEmoji) then
		for k, v in pairs(self.m_DialogueNpcEmoji) do
			if k ~= 0 then
				local npc = g_MapCtrl:GetDynamicNpc(k)
				if npc then
					npc:SetSocialEmoji()
				end
			else
				local oHero = g_MapCtrl:GetHero()
				if oHero then
					oHero:SetSocialEmoji()
				end
			end
		end
		 self.m_DialogueNpcEmoji = {}
	end
	local t = data.taskdata.TASK.STORY.DIALOG
	--如果是本地的对话id
	if dialogueId == CDialogueCtrl.DIALOUGE_10509_ID then
		t = CDialogueCtrl.LOCAL_DIALOG
	end	
	if t[dialogueId] and t[dialogueId][sudId] then
		local social = t[dialogueId][sudId].social_action_list
		if social and social ~= "" then
			local info = string.split(social, ";")
			if info and next(info) then
				for i = 1, #info do			
					local list = string.split(info[i], ",")
					if list and #list == 2 then						
						local npcType = tonumber(list[1])				
						local emojiId = tostring(list[2])						
						local npcId
						if npcType == 0 then
							npcId = 0
						else
							npcId = g_MapCtrl:GetNpcIdByNpcType(npcType)
						end						 
						if npcId and emojiId then							
							local npc
							if npcId == 0 then
								npc = g_MapCtrl:GetHero()
							else
								npc = g_MapCtrl:GetDynamicNpc(npcId)
								if npc and npc.m_IsHide == true then
									npc = nil
								end
							end 
							if npc then			
								npc:SetSocialEmoji(emojiId)								
								self.m_DialogueNpcEmoji[npcId] = emojiId
							end					
						end
					end					
				end
			end
		end
	end
end

-- 获取任务奖励
function CDialogueCtrl.GetNpcFightRewardItmeList(self, rewardIDList)
	local itemList = {}
	if rewardIDList and next(rewardIDList) then
		local coinId = tonumber(data.globaldata.GLOBAL.attr_coin_itemid.value)  --金币id
		local expId= tonumber(data.globaldata.GLOBAL.attr_exp_itemid.value) --经验id
		local goldCoinId = tonumber(data.globaldata.GLOBAL.attr_goldcoin_itemid.value) --水晶id
		local partnerId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)--伙伴奖励道具id

		local sidList = {}

		for i = 1, #rewardIDList do

			local d = data.rewarddata.NPCFIGHT[rewardIDList[i]]			
			if d then
				if d.reward and next(d.reward) then
					for k, v in ipairs(d.reward) do
						if v.sid and v.sid ~= "" then
							local list = string.split(v.sid, ",")
							for j = 1, #list do
								if string.find(list[j], "value") then
									local sid, value = g_ItemCtrl:SplitSidAndValue(list[i])
									sidList[sid] = sidList[sid] or 0
									sidList[sid] = sidList[sid] + value
							
								elseif string.find(list[i], "partner") then
									local sid, parId = g_ItemCtrl:SplitSidAndValue(list[i])
									sidList[sid] = sidList[sid] or {}	
									sidList[sid][parId] = sidList[sid][parId] or {}											
									sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount or 0
									sidList[sid][parId].partner_amount = sidList[sid][parId].partner_amount + v.amount

								else
									local sid = tonumber(list[i])
									sidList[sid] = sidList[sid] or 0
									sidList[sid] = sidList[sid] + v.amount
								end
							end
						end
					end					
				end
			end
								

			if d.coin and tonumber(d.coin) and tonumber(d.coin) > 0 then
				sidList[coinId] = sidList[coinId] or 0
				sidList[coinId] = sidList[coinId] + tonumber(d.coin)
			end

			if d.exp and tonumber(d.exp) and tonumber(d.exp) > 0 then
				sidList[expId] = sidList[expId] or 0
				sidList[expId] = sidList[expId] + tonumber(d.exp)
			end	
		end

		for sid, v in pairs(sidList) do							
			local localSid = tonumber(sid)										
			if localSid == partnerId then
				if v and next(v) ~= nil then
					for parid, partner in pairs(v) do
						local d = {}
						d.sid = localSid
						d.partnerId = parid
						d.amount = partner.partner_amount								
						table.insert(itemList, d)
					end	
				end						
			else
				local d = {}
				d.sid = localSid
				d.amount = v
				table.insert(itemList, d)
			end				
		end

		table.sort(itemList, function (a, b)
			return a.sid > b.sid
		end)
	end
	return itemList
end

function CDialogueCtrl.UpdateTeam(self)
	local oView = CDialogueMainView:GetView()	
	if oView then
		if g_TeamCtrl:IsInTeam() and not g_TeamCtrl:IsLeader() then
			oView:CloseView()
		end
	end
end

function CDialogueCtrl.ResetSocialDialogue(self)
	if self.m_CacheSocialDialogue and next(self.m_CacheSocialDialogue) then
		local npc = g_MapCtrl:GetDynamicNpc(self.m_CacheSocialDialogue.tPid)
		if npc and not Utils.IsNil(npc) and npc.m_Actor then
			npc:CrossFade("idleCity")
			npc:SetPos(self.m_CacheSocialDialogue.tPos)
			npc.m_Actor:SetLocalRotation(Quaternion.Euler(0, self.m_CacheSocialDialogue.tRotaY or 150, 0))
		end
		local oHero = g_MapCtrl:GetHero()
		if oHero and not oHero:IsWalking() then
			oHero:CrossFade("idleCity")
			oHero.m_Actor:SetLocalRotation(Quaternion.Euler(0, self.m_CacheSocialDialogue.oRotaY, 0))
		end
	end
	self.m_CacheSocialDialogue = nil
end

function CDialogueCtrl.CaCheSocialDialogue(self, t)
	self.m_CacheSocialDialogue = t 
end

function CDialogueCtrl.GetSpecialShape(self, shape)
	local myShape = g_AttrCtrl.model_info.shape
	local mySex = g_AttrCtrl.sex
	local sexShape =  
	{
		[1] = {[1] = {110, 113}, [2] = {130, 133}, [3] = {150, 153} },
		[2] = {[1] = {120, 123}, [2] = {140, 143}, [3] = {160, 163}}
	}

	local converShape = shape
	--相同模型
	if converShape == 1603 then
		converShape = myShape

	--相同性别不同的模型
	elseif converShape == 1601 then
		if sexShape[mySex][1][1] == myShape or sexShape[mySex][1][2] == myShape then
			converShape = sexShape[mySex][2][1]
		else
			converShape = sexShape[mySex][1][1]
		end

	--不同性别不同的模型
	elseif converShape == 1602 then
		mySex = mySex == 1 and 2 or 1
		if sexShape[mySex][1][1] == myShape or sexShape[mySex][1][2] == myShape then
			converShape = sexShape[mySex][2][1]
		else
			converShape = sexShape[mySex][1][1]
		end
	end
	return converShape
end

return CDialogueCtrl