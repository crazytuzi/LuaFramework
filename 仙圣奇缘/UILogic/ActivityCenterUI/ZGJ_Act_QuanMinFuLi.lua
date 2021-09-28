Act_QuanMinFuLi = class("Act_QuanMinFuLi",Act_Template2)
Act_QuanMinFuLi.__index = Act_Template2

Act_QuanMinFuLi.suffix = _T("人")

function Act_QuanMinFuLi:setNumOfBuy(nNum)
	local ndivisor = 1000
	for i = 1, 4 do
		self.tbLabel_Count[i]:setText(math.floor(nNum / ndivisor))
		nNum = nNum % ndivisor
		ndivisor = ndivisor / 10
	end
end

function Act_QuanMinFuLi:totalJijinResponse(tbMsg)
	local msg = zone_pb.TotalJijinResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	local nNum = msg.total_buy_jijin_num
	self:setNumOfBuy(nNum)
end

--override
function Act_QuanMinFuLi:init(panel, tbItemList)
	self.tbLabel_Count = {}
	for i = 1, 4 do
		self.tbLabel_Count[i] = tolua.cast(panel:getChildByName("Label_Count"..i), "Label")
	end


	g_MsgMgr:sendMsg(msgid_pb.MSGID_JIJIN_REQUEST)
	--全服基金购买人数响应
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_JIJIN_RESPONSE,handler(self,self.totalJijinResponse))

	self.super.init(self, panel, tbItemList)
end

function Act_QuanMinFuLi:setButtonState(Button_Activety, nIndex)
	self.super.setButtonState(self, Button_Activety, nIndex)
	local state = self.tbMissions[self.tbItemList[nIndex]["ID"]]
	
	local function onShowRewardTip(pSender, nIndex)
		local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("DropSubPackClient", self.tbItemList[nIndex]["DropClientID"], 1)
		g_ShowDropItemTip(CSV_DropSubPackClient)
	end
	
	local function onCloseTip()
	end
			
	if ActState.INVALID == state then --已领取
		local function onShowSysTip(pSender, nTag)
			g_ShowSysTips({text=_T("该奖励已经被您领取了哦亲")})
		end
		g_SetBtnWithPressingEventAndImage(Button_Activety, nIndex, onShowRewardTip, onShowSysTip, onCloseTip, true, 0.5)
	elseif ActState.DOING == state then --未达到条件
		g_SetBtnWithPressImage(Button_Activety, nIndex, onShowRewardTip, true, 1)
	elseif ActState.FINISHED == state then --可领取
		local function onPressed_Button_Activety(pSender, nIndex)
			if self.tbButtonEnable[nIndex] then
				self:onClickGainReward(pSender, nIndex)
			end
		end
		g_SetBtnWithPressingEventAndImage(Button_Activety, nIndex, onShowRewardTip, onPressed_Button_Activety, onCloseTip, true, 0.5)
	end
end