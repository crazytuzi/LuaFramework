--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-6-8
-- 版  本:	1.0
-- 描  述:	激活码兑换
-- 应  用:  
---------------------------------------------------------------------------------------

Act_ExchangeKey = class("Act_ExchangeKey",Act_Template)
Act_ExchangeKey.__index = Act_Template

function Act_ExchangeKey:init(panel)
	
	--激活码兑换响应
	local order = msgid_pb.MSGID_ACTIVE_CODE_EXCHANGE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.ActiveCodeExchangeResponse))	
	
	local Button_LingQu = tolua.cast(panel:getChildByName("Button_LingQu"), "Button")
    
	local Image_GroupName = tolua.cast(panel:getChildByName("Image_GroupName"), "ImageView")
	local TextField_GroupName = tolua.cast(Image_GroupName:getChildByName("TextField_GroupName"), "TextField")
	local mString = nil
	local function textFieldEvent(sender, eventType)	
		if eventType == ccs.TextFiledEventType.insert_text  then
			mString = TextField_GroupName:getStringValue()
			if mString ~= nil then
				Button_LingQu:setTouchEnabled(true)
				Button_LingQu:setBright(true)
			end
		elseif  eventType == ccs.TextFiledEventType.delete_backward	 then
			mString = TextField_GroupName:getStringValue()
			if mString == nil then 
				Button_LingQu:setTouchEnabled(false)
				Button_LingQu:setBright(true)
			end
		end
	end
	
	TextField_GroupName:addEventListenerTextField(textFieldEvent) 
	
	local function onClickLingQu(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local account = TextField_GroupName:getStringValue()
			--预加载窗口缓存防止卡顿
			g_WndMgr:getFormtbRootWidget("Game_RewardBox")
			self:requestActiveCodeExchangeRequest(account)
		end
	end
	Button_LingQu:setBright(false)
	Button_LingQu:setTouchEnabled(false)
	Button_LingQu:addTouchEventListener(onClickLingQu)
	
	local Label_Desc = tolua.cast(panel:getChildByName("Label_Desc"), "Label")
	local CCNode_Desc = tolua.cast(Label_Desc:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Desc:disableShadow(true)
	
	local Button_GetCode = tolua.cast(panel:getChildByName("Button_GetCode"), "Button")
    
	if eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
		Button_GetCode:setVisible(true)
		Button_GetCode:setBright(true)
		Button_GetCode:setTouchEnabled(true)
		Button_GetCode:setPositionX(-130)
		Button_LingQu:setPositionX(130)
	else
		Button_GetCode:setVisible(false)
		Button_GetCode:setBright(false)
		Button_GetCode:setTouchEnabled(false)
		Button_GetCode:setPositionX(0)
		Button_LingQu:setPositionX(0)
	end
    local function onClickGetCode(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
		    if CGamePlatform:SharedInstance().OpenLinkOnWeb ~= nil then
                CGamePlatform:SharedInstance():OpenLinkOnWeb("http://login.gametaiwan.com/main/frontend/activity/dsssubs/index_m.html")
            end
		end
	end
    Button_GetCode:addTouchEventListener(onClickGetCode)
    if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
        Button_GetCode:setVisible(false)
        Button_GetCode:setTouchEnabled(false)
    end

    g_act:resetBubbleById(self.nActivetyID) --重置可领取奖励个数
end

--活动是否有效
function Act_ExchangeKey:isEnable(id)
    self.nActivetyID = id
    if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_cht_Taiwan  then --台湾版审核关掉兑换码窗口
        if g_Cfg.Csv_Platform == 0 then
            return false 
        else
            return true
        end
    else
        return true
    end
end

function Act_ExchangeKey:requestActiveCodeExchangeRequest(serialNum)
	cclog("激活码兑换请求")
	local msg = zone_pb.ActiveCodeExchangeRequest() 
	msg.serial_num = serialNum  --兑换码
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ACTIVE_CODE_EXCHANGE_REQUEST,msg)
end

function Act_ExchangeKey:ActiveCodeExchangeResponse(tbMsg)
	cclog("---------激活码兑换响应-------------")
	local msgDetail = zone_pb.ActiveCodeExchangeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local serialNum = msgDetail.serial_num
	-- g_WndMgr:showWnd("Game_RewardBox", tbData)
	
	-- g_ClientMsgTips:showMsgConfirm("您已经领取过该礼包奖励了。")
	-- g_ClientMsgTips:showMsgConfirm("该兑换码已经被其他人使用。")
	-- g_ClientMsgTips:showMsgConfirm("兑换码验证失败，请确认兑换码输入是否正确。")
	

end