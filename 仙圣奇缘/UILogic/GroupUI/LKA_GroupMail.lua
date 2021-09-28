--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupMail.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	帮派管理
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_GroupMail = class("Game_GroupMail")
Game_GroupMail.__index = Game_GroupMail
local chatStrNum = 126
function Game_GroupMail:setWnd()
	
end

function Game_GroupMail:initWnd()
	local Image_GroupMailPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMailPNL"), "ImageView")
	local Label_RemainCountLB = tolua.cast(Image_GroupMailPNL:getChildByName("Label_RemainCountLB"), "Label")
	self.Label_RemainCount = tolua.cast(Label_RemainCountLB:getChildByName("Label_RemainCount"), "Label")

	local Image_Content = tolua.cast(Image_GroupMailPNL:getChildByName("Image_Content"), "ImageView")
	
	self.Label_Input = tolua.cast(Image_Content:getChildByName("Label_Input"), "Label")
	self.Label_Input1 = tolua.cast(Image_Content:getChildByName("Label_Input1"), "Label")
	self.Label_Input2 = tolua.cast(Image_Content:getChildByName("Label_Input2"), "Label")
	self.Label_Input3 = tolua.cast(Image_Content:getChildByName("Label_Input3"), "Label")
	self.Label_Input4 = tolua.cast(Image_Content:getChildByName("Label_Input4"), "Label")
	self.Label_Input5 = tolua.cast(Image_Content:getChildByName("Label_Input5"), "Label")

	self.TextField_Input = tolua.cast(Image_GroupMailPNL:getChildByName("TextField_Input"), "TextField")
	self.Label_RemainCount:setText("("..chatStrNum..")")
	local tbLabel = {
			{["label"] = self.Label_Input},
			{["label"] = self.Label_Input1},
			{["label"] = self.Label_Input2},
			{["label"] = self.Label_Input3},
			{["label"] = self.Label_Input4},
			{["label"] = self.Label_Input5},
	}
	local function callBack(InputNum)
		self.Label_RemainCount:setText("("..InputNum..")")
	end
	-- setTextField(self.TextField_Input, tbLabel,chatStrNum,520,callBack) 
	setTextField(self.TextField_Input, tbLabel,chatStrNum,520,callBack) 
	
	local function onClickButton(pSender, nTag)
		local nString = self.TextField_Input:getStringValue()
		local tbMsg = {title = _T("帮派邮件"), context = nString }
		self:requestGuildSendMailRequest(tbMsg)
	end
	g_SetBtn(self.rootWidget, "Button_SendMsg", onClickButton, true,true,1)
	

	local order = msgid_pb.MSGID_GUILD_SENDMAIL_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildSendMailResponse))	
	
	self.Label_RemainCount:setPositionX(Label_RemainCountLB:getSize().width)
	
end

function Game_GroupMail:openWnd()
	if g_bReturn  then return  end 
	self:setWnd()
end

--帮派邮件请求 3004689
function Game_GroupMail:requestGuildSendMailRequest(tbMsg)
	cclog("---------requestGuildSendMailRequest-------------")
	cclog("---------帮派邮件请求-------------")
	local msg = zone_pb.GuildSendMailRequest() 
	msg.title = tbMsg.title
	msg.context = tbMsg.context
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_SENDMAIL_REQUEST, msg)
end

--帮派邮件请求响应
function Game_GroupMail:requestGuildSendMailResponse(tbMsg)
	cclog("---------requestGuildSendMailResponse-------------")
	cclog("---------帮派邮件请求响应-------------")
	self.TextField_Input:setText("")
	self.Label_Input:setText("")
	self.Label_RemainCount:setText("("..chatStrNum..")")
	g_WndMgr:closeWnd("Game_GroupMail")
	g_ShowSysTips({text = "      ".._T("帮派邮件发送成功~").."      "})
end

function Game_GroupMail:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupMailPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMailPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupMailPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupMail:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupMailPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMailPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupMailPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
