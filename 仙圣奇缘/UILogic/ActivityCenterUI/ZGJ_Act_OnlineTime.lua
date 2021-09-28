--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-8
-- 版  本:	1.0
-- 描  述:	在线时长活动
-- 应  用:  
---------------------------------------------------------------------------------------
--应对刷新脚本
if not Act_OnlineTime then
	Act_OnlineTime = class("Act_OnlineTime",Act_Template)
	Act_OnlineTime.__index = Act_Template
elseif Act_OnlineTime.nTimeID then
	Act_OnlineTime.nTimeID = g_Timer:pushLoopTimer(1, handler(Act_OnlineTime,Act_OnlineTime.updateOnlineTime))
end


function Act_OnlineTime:initTime(nSec)
	local csvConfig = g_DataMgr:getCsvConfig("ActivityOnline")
	for k,v in pairs(csvConfig) do
		if v.FunctionType == self.__cname then
			self.nActivetyID = v.ActivityOnlineID
			self.tbRewardList = g_DataMgr:getCsvConfig(v.Desc3)
			break
		end
	end
	self.tbMissions = g_act:getMissionsByID(self.nActivetyID)
	if not self.tbMissions then 
		return
	end

	self.nSec = nSec
	if g_GetServerTime() - self.nSec < 0 then
		cclog("ActivityOnline online_reward_start_time error")
		return
	end

	table.sort(self.tbRewardList, function (a, b)
		local state_a = self.tbMissions[a.ID]
		local state_b = self.tbMissions[b.ID]
		if state_a == state_b then
			return a.ID < b.ID
		else
			return state_a > state_b
		end
	end)

	if self.tbMissions[self.tbRewardList[1].ID] == ActState.DOING then
		g_Timer:destroyTimerByID(self.nTimeID)
		self.nTimeID = g_Timer:pushLoopTimer(1, handler(self,self.updateOnlineTime))
	end
	-- for k,v in ipairs(self.tbMissions) do
	-- 	if v == ActState.FINISHED then--可领取
	-- 		self.nCurReward = k
	-- 		break
	-- 	elseif v == ActState.DOING then
 --            self.nCurReward = k
 --            self.nTimeID = g_Timer:pushLoopTimer(1, handler(self,self.updateOnlineTime))
 --            break
 --        end
	-- end
 --    if not self.nCurReward then
 --        self.nCurReward = #self.tbRewardList + 1
 --    end


end

function Act_OnlineTime:updateStatus()
    local rank_again = false
    --判断当前任务的状态是否已经更新
    for i,v in pairs(self.tbMissions) do
        if self.tbMissions_old[i] ~= v then
            rank_again = true
            self.tbMissions_old[i] = v
        end
    end

    if rank_again then --任务状态已经更新，更新listView
        self:sortAndUpdate()
    end
end

function Act_OnlineTime:updateOnlineTime()
	self.nCountdown = self.tbRewardList[1]["NeedOnlineTime"] - ( g_GetServerTime() - self.nSec )
	if self.nCountdown <=  0 then
	--if self.nOnlineSec + os.time() - tClientTime > self.tbRewardList[self.nCurReward]["NeedOnlineTime"] then
		g_Timer:destroyTimerByID(self.nTimeID)
		self.nTimeID = nil
		g_act:setMission(self.nActivetyID, self.tbRewardList[1].ID , 2) --可领取
		g_act:incBubbleByID(self.nActivetyID)
		
		if self.bInit and self.cCurPanelItem and self.cCurPanelItem:isExsit() then
            local Button_Activety = tolua.cast(self.cCurPanelItem:getChildByName("Button_Activety"), "Button")
		    self.cCurImage_RewardStatus:setVisible(true)
		    self.cCurLabel_CountDown:setVisible(false)
			self:setButtonState(Button_Activety, ActState.FINISHED)
			self.bInit = false
		end
		if self.Label_CountDown_Home and self.Label_CountDown_Home:isExsit() then
			self.Label_CountDown_Home:setVisible(false)
		end
		local HomeWnd = g_WndMgr:getWnd("Game_Home")
		if HomeWnd ~= nil then
			HomeWnd:addNoticeAnimation_OnLineReward()
		end
	else
		local szMin = math.floor(self.nCountdown/60)
		local szSec = self.nCountdown%60
		if szMin < 10 then
			szMin = "0"..szMin
		end
		if szSec < 10 then
			szSec = "0"..szSec
		end
		local szTime = szMin..":"..szSec

		if self.Label_CountDown_Home and self.Label_CountDown_Home:isExsit() then
			self.Label_CountDown_Home:setVisible(true)
			self.Label_CountDown_Home:setText(szTime)
		end
		if self.bInit and self.cCurLabel_CountDown and self.cCurLabel_CountDown:isExsit() then
			self.cCurLabel_CountDown:setText(szTime)
		end
	end

end

function Act_OnlineTime:setButtonGetReward()

end

--override 设置每个按钮列表项
function Act_OnlineTime:setPanelItem(widget, nIndex)
	self.super.setPanelItem(self,widget,nIndex)
	if nIndex ==  1 then
		self.cCurPanelItem = widget
        if  self.tbMissions[self.tbItemList[nIndex].ID] == ActState.DOING then
			local Button_Activety = tolua.cast(self.cCurPanelItem:getChildByName("Button_Activety"), "Button")
			local Button_GetReward = tolua.cast(Button_Activety:getChildByName("Button_GetReward"), "Button")
		    self.cCurImage_RewardStatus = tolua.cast(Button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")
		    self.cCurImage_RewardStatus:setVisible(false)
		    self.cCurLabel_CountDown = tolua.cast(Button_GetReward:getChildByName("Label_CountDown"), "Label")
		    self.cCurLabel_CountDown:setColor(ccc3(255,0,0))
		    self.cCurLabel_CountDown:setText("")
		    self.cCurLabel_CountDown:setVisible(true)
		    self.bInit = true
        end
	end
end

-- -- --override 
-- function Act_OnlineTime:init(panel, tbItemList)
--  	self.super.init(self, panel, tbItemList)

-- end

--override
function Act_OnlineTime:destroy()
	self.super.destroy(self)
	self.bInit = false

	--优化因窗口缓存
	if self.cCurImage_RewardStatus and self.cCurImage_RewardStatus:isExsit() then
		self.cCurImage_RewardStatus:setVisible(true)
	end
	if self.cCurLabel_CountDown and self.cCurLabel_CountDown:isExsit() then
		self.cCurLabel_CountDown:setVisible(false)
	end
end

--override
function Act_OnlineTime:gainRewardResponseCB(tbMsg)
	self.super.gainRewardResponseCB(self, tbMsg)
	if self.tbRewardList[1].ID <= #self.tbRewardList then
		self.nSec = g_GetServerTime()
		g_Timer:destroyTimerByID(self.nTimeID)
		self.nTimeID = g_Timer:pushLoopTimer(1, handler(self,self.updateOnlineTime))	
	end
end

function Act_OnlineTime:setOnlineLabel(label)
	--主界面在线按钮label
 	self.Label_CountDown_Home = label
end
	