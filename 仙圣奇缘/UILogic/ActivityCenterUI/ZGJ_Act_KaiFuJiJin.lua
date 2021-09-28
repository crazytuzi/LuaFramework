if not Act_KaiFuJiJin then
	Act_KaiFuJiJin = class("Act_KaiFuJiJin",Act_Template2)
	Act_KaiFuJiJin.__index = Act_Template2
end

Act_KaiFuJiJin.suffix = _T("级")

function Act_KaiFuJiJin:isBuy()
	return self.bBuy or false
end

function Act_KaiFuJiJin:buyJiJinResponse()
	self.bBuy = true
	
	g_act:decBubbleByID(common_pb.AOLT_KAIFU_JIJIN)
	if self.Button_Buy and self.Button_Buy:isExsit() then
		g_SetBubbleNotify(self.Button_Buy, 0, 35, 35, 1)
		self:sortAndUpdate()
	end
end

local function onClick_Button_Buy(pSender, nTag)
	if Act_KaiFuJiJin.bBuy then
		 g_ClientMsgTips:showMsgConfirm(_T("您已经购买过开服基金了,无法继续购买"))
		 return
	end
	if not Act_KaiFuJiJin:isBuy() then
		local tbParam = {
			OpenType = "KaiFuJiJin",
			ListViewIndex = 1
		}
		g_WndMgr:openWnd("Game_ReCharge", tbParam)
	else
		local tbParam = {
			OpenType = "KaiFuJiJin",
			ListViewIndex = 3
		}
		g_WndMgr:openWnd("Game_ReCharge", tbParam)
	end
end

--override
function Act_KaiFuJiJin:init(panel, tbItemList)
	self.Button_Buy = panel:getChildByName("Button_Buy")
	g_SetBtnWithPressImage(self.Button_Buy, 1, onClick_Button_Buy, true, 1)
	if self.bBuy then
		g_SetBubbleNotify(self.Button_Buy, 0, 35, 35, 1)
	else
		g_SetBubbleNotify(self.Button_Buy, 1, 35, 35, 1)
	end
	self.super.init(self, panel, tbItemList)
end

--override
function Act_KaiFuJiJin:setButtonState(Button_Activety, nIndex)
	self.super.setButtonState(self, Button_Activety, nIndex)
	
	local state = self.tbMissions[self.tbItemList[nIndex]["ID"]]
	if ActState.INVALID == state then --已领取
		local function onShowSysTip(pSender, nTag)
			g_ShowSysTips({text=_T("该奖励已经被您领取了哦亲")})
		end
		g_SetBtnWithPressImage(Button_Activety, nIndex, onShowSysTip, true, 1)
	elseif ActState.DOING == state then --未达到条件
		local function onShowSysTip(pSender, nTag)
			g_ShowSysTips({text=_T("您需要达到")..self.tbItemList[nIndex]["NeedValue"].._T("级才能领取返还的元宝")})
		end
		g_SetBtnWithPressImage(Button_Activety, nIndex, onShowSysTip, true, 1)
	elseif ActState.FINISHED == state then --可领取
		local function onPressed_Button_Activety(pSender, nIndex)
			if self.tbButtonEnable[nIndex] then
				self:onClickGainReward(pSender, nIndex)
			end
		end
		g_SetBtnWithPressImage(Button_Activety, nIndex, onPressed_Button_Activety, true, 1)
	else
		local function onShowSysTip(pSender, nTag)
			g_ShowSysTips({text=_T("您还没有购买开服基金, 购买后方可参与返还计划")})
		end
		g_SetBtnWithPressImage(Button_Activety, nIndex, onShowSysTip, true, 1)
	end
end

--开服基金购买响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BUY_JIJIN_RESPONSE,handler(Act_KaiFuJiJin, Act_KaiFuJiJin.buyJiJinResponse))