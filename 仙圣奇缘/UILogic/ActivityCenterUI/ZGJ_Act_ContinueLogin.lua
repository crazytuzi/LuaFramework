--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-5
-- 版  本:	1.0
-- 描  述:	连续登录活动
-- 应  用:  
---------------------------------------------------------------------------------------
if not Act_ContinueLogin then
Act_ContinueLogin = class("Act_ContinueLogin", Act_Template)
Act_ContinueLogin.__index = Act_Template
end

--领取响应回调
function Act_ContinueLogin:gainRewardResponse(tbMsg)
	cclog("----------GainLoginResponse---------")
	local msgDetail = zone_pb.GainLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	g_Hero:setContinuousLoginDate(msgDetail.continuous_login)
	
	self:convertMsg()
	g_act:decBubbleByID(self.nActivetyID)
	self.super.gainRewardResponseCB(self)

	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_ActivityCenter") then
		cclog("=================ÐÂÊÖÒýµ¼ServerReponseÊÂ¼þ====================")
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

--领取按钮回调
function Act_ContinueLogin:onClickGainReward(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		pSender:setTouchEnabled(false)
		local msg = zone_pb.GainLoginRequest()
		msg.gain_id = self.tbItemList[pSender:getTag()].ID
		g_MsgMgr:sendMsg(msgid_pb.MSGID_GAIN_LOGIN_REQUEST,msg)
	end
end



function Act_ContinueLogin:init(panel, tbItemList)
	self.super.init(self, panel, tbItemList)
	--注册领取响应回调
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GAIN_LOGIN_RESPONSE,handler(self,self.gainRewardResponse))
end

--转换连续登录信息
function Act_ContinueLogin:convertMsg()
	self.nContinuousLogin = g_Hero:getContinuousLoginDate()
	if not self.tbMissions then
		self.tbMissions = {}
	end
	self.nLoginDaysCount = 0
	self.nHasGetCount = 0
	for i=1,8 do

		local lowBit = API_GetBitsByPos(self.nContinuousLogin,i)
		if lowBit == 1 then
			self.nHasGetCount = self.nHasGetCount + 1
		end

		local highBit = API_GetBitsByPos(self.nContinuousLogin,i + 8)
		if highBit == 1 then
			self.nLoginDaysCount = self.nLoginDaysCount + 1
		end

		self.tbMissions[i] = highBit + 1 - lowBit * 2
	end
	return self.tbMissions, self.nLoginDaysCount - self.nHasGetCount
end

--活动是否有效
function Act_ContinueLogin:isEnable(id)
	self.nActivetyID = id
	--return self.nHasGetCount ~= 8
    for i = 1, 7 do
        if self.tbMissions[i] ~= 0 then
           return true
        end
    end
    return false
end

--24点刷新 
function Act_ContinueLogin:refreshContinueDay()
	self.nContinuousLogin = g_Hero:getContinuousLoginDate()
	for i=1,8 do
		local highBit = API_GetBitsByPos(self.nContinuousLogin,i + 8)
		if highBit == 0 then
			self.nContinuousLogin = self.nContinuousLogin + math.pow(2,i + 7)
			break
		end
	end
	g_Hero:setContinuousLoginDate(self.nContinuousLogin)
end
