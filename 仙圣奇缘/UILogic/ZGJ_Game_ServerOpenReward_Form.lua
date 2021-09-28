Game_ServerOpenReward = class("Game_ServerOpenReward")
Game_ServerOpenReward.__index = Game_ServerOpenReward

function Game_ServerOpenReward:onClickGetReward(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		widget:setTouchEnabled(false)
		g_SOTSystem:allRewardRequest()
	end
end

--设置剩余时间
function Game_ServerOpenReward:setRemainTime(fDelta, bFirst)
	if not g_WndMgr:getWnd("Game_ServerOpenReward") then return true end
	
	local nDays, nHours, nMins, nSecs = g_SOTSystem:getRemainTime()
	if not nDays then
		g_Timer:destroyTimerByID(self.nTimerID)
		self.Label_CountTime:setVisible(false)
		if self.nCurLevel > 0 then
			self.Button_Obtain:setBright(true)
			self.Button_Obtain:setTouchEnabled(true)
		end
		return
	end
	self.Label_CountTime:setText(nDays.._T("天")..nHours.._T("时")..nMins.._T("分")..nSecs.._T("秒"))
end

function Game_ServerOpenReward:initWnd()
	local Image_ServerOpenRewardPNL = self.rootWidget:getChildByName("Image_ServerOpenRewardPNL")
	local Image_ContentPNL = Image_ServerOpenRewardPNL:getChildByName("Image_ContentPNL")
	local Image_RewardInfoPNL = Image_ContentPNL:getChildByName("Image_RewardInfoPNL")
	
	local Button_KuangHuanGuide = tolua.cast(Image_ServerOpenRewardPNL:getChildByName("Button_KuangHuanGuide"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_KuangHuanGuide)

	local csv_TaskReward = g_DataMgr:getCsvConfig("ActivityTaskReward")
	local key_table = {}
	for key,_ in pairs(csv_TaskReward) do  
	    table.insert(key_table,key)  
	end
	table.sort(key_table)

	--当前进度
	-- local csv_Task = g_DataMgr:getCsvConfig("ActivityTask")
	-- local nTotalTasks = 0
	-- for k, v in ipairs(csv_Task) do
	-- 	nTotalTasks = nTotalTasks + #v
	-- end
	local nMaxProgress = key_table[#key_table]
	local nFinishedTasks = g_SOTSystem:getFinishedTasks()
	local Label_ProgressLB = Image_RewardInfoPNL:getChildByName("Label_ProgressLB")
	local Label_Progress = tolua.cast(Label_ProgressLB:getChildByName("Label_Progress"), "Label")
	Label_Progress:setText(nFinishedTasks.."/"..nMaxProgress)

	--已达进度
	local Label_CurProgressLB = Image_RewardInfoPNL:getChildByName("Label_CurProgressLB")
	local Label_CurProgress = tolua.cast(Label_CurProgressLB:getChildByName("Label_CurProgress"), "Label")
	Label_CurProgress:setText(math.floor(nFinishedTasks/nMaxProgress * 100 ).."%")

	--当前档次
	local nCurLevel = 0
	for i = 1, #key_table do
		if nFinishedTasks < key_table[i] then
			break
		end
		nCurLevel = i
	end
	self.nCurLevel = nCurLevel
	

	--当前可领
	local csv_Reward = g_DataMgr:getCsvConfigByOneKey("ActivityTaskReward", key_table[nCurLevel])
	local Label_CurCanObtainLB = Image_RewardInfoPNL:getChildByName("Label_CurCanObtainLB")
	local Label_CurCanObtain = tolua.cast(Label_CurCanObtainLB:getChildByName("Label_CurCanObtain"), "Label")
	Label_CurCanObtain:setText(csv_Reward["RewardNum"])

	--下档可领
	local nNextLevel = key_table[nCurLevel + 1] and nCurLevel + 1 or nCurLevel
	local csv_Reward = g_DataMgr:getCsvConfigByOneKey("ActivityTaskReward", key_table[nNextLevel])
	local Label_NextCanObtainLB = Image_RewardInfoPNL:getChildByName("Label_NextCanObtainLB")
	local Label_NextCanObtain = tolua.cast(Label_NextCanObtainLB:getChildByName("Label_NextCanObtain"), "Label")
	Label_NextCanObtain:setText(csv_Reward["RewardNum"])

	--下档进度
	local Label_NextProgressLB = Image_RewardInfoPNL:getChildByName("Label_NextProgressLB")
	local Label_NextProgress = tolua.cast(Label_NextProgressLB:getChildByName("Label_NextProgress"), "Label")
	Label_NextProgress:setText(nFinishedTasks.."/"..key_table[nNextLevel])

	--领取按钮
	self.Button_Obtain = Image_ContentPNL:getChildByName("Button_Obtain")
	self.Button_Obtain:setBright(false)
	self.Button_Obtain:setTouchEnabled(false)
	self.Button_Obtain:addTouchEventListener(handler(self, self.onClickGetReward))

	--魂魄
	local Image_RewardHunPo = tolua.cast(Image_RewardInfoPNL:getChildByName("Image_RewardHunPo"), "ImageView")
	local Image_RewardHunPo = tolua.cast(Image_RewardInfoPNL:getChildByName("Image_RewardHunPo"),"ImageView")
	Image_RewardHunPo:loadTexture(getUIImg("SummonHunPoBase"..1))
	Image_RewardHunPo:removeAllNodes()
	local spriteCover = SpriteCoverlipping(getUIImg("PlayerIcon"..g_Hero:getMasterSex()), getUIImg("SummonHunPoBase"..1))
	if spriteCover ~= nil then
		Image_RewardHunPo:addNode(spriteCover,1)
	end


	--刷新时间
	self.Label_CountTime = tolua.cast(Image_ContentPNL:getChildByName("Label_CountTime"), "Label")
	self.nTimerID = g_Timer:pushLoopTimer(1, handler(self, self.setRemainTime))
	self:setRemainTime()

end

function Game_ServerOpenReward:openWnd()
	
end

function Game_ServerOpenReward:closeWnd()
	g_Timer:destroyTimerByID(self.nTimerID)
end

function Game_ServerOpenReward:ModifyWnd_viet_VIET()

	local Label_ProgressLB = self.rootWidget:getChildAllByName("Label_ProgressLB")
	local Label_Progress = self.rootWidget:getChildAllByName("Label_Progress")
	Label_Progress:setPositionX(Label_ProgressLB:getSize().width)

	local Label_CurCanObtainLB = self.rootWidget:getChildAllByName("Label_CurCanObtainLB")
	local Label_CurCanObtain = self.rootWidget:getChildAllByName("Label_CurCanObtain")
	Label_CurCanObtain:setPositionX(Label_CurCanObtainLB:getSize().width)

	local Label_CurProgressLB = self.rootWidget:getChildAllByName("Label_CurProgressLB")
	local Label_CurProgress = self.rootWidget:getChildAllByName("Label_CurProgress")
	Label_CurProgress:setPositionX(Label_CurProgressLB:getSize().width)

	local Label_NextCanObtainLB = self.rootWidget:getChildAllByName("Label_NextCanObtainLB")
	local Label_NextCanObtain = self.rootWidget:getChildAllByName("Label_NextCanObtain")
	Label_NextCanObtain:setPositionX(Label_NextCanObtainLB:getSize().width)

	local Label_NextProgressLB = self.rootWidget:getChildAllByName("Label_NextProgressLB")
	local Label_NextProgress = self.rootWidget:getChildAllByName("Label_NextProgress")
	Label_NextProgress:setPositionX(Label_NextProgressLB:getSize().width)
	--local Label_FreeRevertTimesMax = self.rootWidget:getChildAllByName("Label_FreeRevertTimesMax")
	--Label_FreeRevertTimesLB:setPositionX(30)
	--Label_FreeRevertTimes:setPositionX(Label_FreeRevertTimesLB:getSize().width)
    --g_AdjustWidgetsPosition({Label_ProgressLB, Label_Progress},2)
end