--------------------------------------------------------------------------------------
-- 文件名:	HF_LoginOrRegister.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-03-28 18:24
-- 版  本:	1.0
-- 描  述:	登陆注册界面
-- 应  用:  
---------------------------------------------------------------------------------------
local rootWidget = nil
local strDailyAccount = nil
local strPasswd = nil

function onPressed_Button_Close()
	if rootWidget then
		rootWidget:removeFromParentAndCleanup(true)
		rootWidget = nil
	end
   -- g_MsgMgr:setWaitTimeOut()
end

function checkClientNetWork(bNotShowTip)
	local updateResMgr = CResUpdateMgr:create()
	local bRet = nil
	for i = 1, 1 do
		bRet = updateResMgr:checkNetWork("http://www.baidu.com/", 2)
		if(not bRet)then
			break
		end
	end
	
    if not bNotShowTip then
	    if(not bRet)then
		    g_ClientMsgTips:showMsgConfirm(_T("网络异常, 请检查网络环境"))
	    else
		    g_ClientMsgTips:showMsgConfirm(_T("服务器维护中"))
	    end
	end
	
	updateResMgr:release()
	
	return bRet
end

-- local function requestMsg(strDailyAccount, strPasswd, bRegister)
-- 	showConnectServerTip()
-- 	if(not g_MsgMgr.bConnectSucc)then
-- 		g_MsgMgr:connectToDir() --防止一直不请求
-- 	else
-- 		if(bRegister)then
-- 			g_MsgMgr:requestAccountReg(strDailyAccount, strPasswd)
-- 		else
--             g_MsgMgr:setWaitTimeOut(1)
-- 			g_MsgMgr:requestAccountLogin(strDailyAccount, strPasswd)
-- 		end
-- 	end
-- end

function setUserRegData()
	cclog("---------->setUserRegData".."strPasswd ="..g_ServerList:GetLoaclAccount().." strDailyAccount="..g_ServerList:GetLoaclPassWord())
	CCUserDefault:sharedUserDefault():setStringForKey("Passwd", g_ServerList:GetLoaclPassWord())
	CCUserDefault:sharedUserDefault():setStringForKey("DailyAccount", g_ServerList:GetLoaclAccount())
end

function openAccountWnd(nAreaId)
	--直接进入游戏
	rootWidget = GUIReader:shareReader():widgetFromJsonFile("Game_LoginOrRegister.json")
	StartGameLayer:addWidget(rootWidget)
	rootWidget:setTouchEnabled(true)
	rootWidget:addTouchEventListener(function(pSender,eventType) return end)
	
	local Button_Close = tolua.cast(rootWidget:getChildByName("Button_Close"), "Button")
	g_SetBtnWithEvent(Button_Close, 1, onPressed_Button_Close, true)
	
	local PageView_LoginOrRegister = tolua.cast(rootWidget:getChildByName("PageView_LoginOrRegister"), "PageView")
	PageView_LoginOrRegister:setTouchEnabled(false)
	--按钮组
	local Panel_TabBtnPNL = tolua.cast(rootWidget:getChildByName("Panel_TabBtnPNL"), "Layout")
	local Button_Login = tolua.cast(Panel_TabBtnPNL:getChildByName("Button_Login"), "Button")
	local Button_Register = tolua.cast(Panel_TabBtnPNL:getChildByName("Button_Register"), "Button")
	local ButtonGroup = ButtonGroup:create()
	ButtonGroup:PushBack(Button_Login,nil ,function()
		PageView_LoginOrRegister:scrollToPage(0)
	end, true)
	ButtonGroup:PushBack(Button_Register, nil,function()
		PageView_LoginOrRegister:scrollToPage(1)
	end)
	
	
	local Panel_Login = PageView_LoginOrRegister:getChildByName("Panel_Login")
	Panel_Login:setVisible(true)
	local Image_UserName = tolua.cast(Panel_Login:getChildByName("Image_UserName"), "ImageView")
	local TextField_UserName = tolua.cast(Image_UserName:getChildByName("TextField_UserName"), "TextField")
	local Image_Password = tolua.cast(Panel_Login:getChildByName("Image_Password"), "ImageView")
	local TextField_Password = tolua.cast(Image_Password:getChildByName("TextField_Password"), "TextField")
    strDailyAccount = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")
    strPasswd = CCUserDefault:sharedUserDefault():getStringForKey("Passwd","")
	if strDailyAccount~="" then TextField_UserName:setText(strDailyAccount) end
	if strPasswd~="" then TextField_Password:setText(strPasswd) end

	local Button_Login = tolua.cast(Panel_Login:getChildByName("Button_Login"), "Button")
	local function onPressed_Button_Login(pSender, nTag)
		local strDailyAccount = TextField_UserName:getStringValue()
		local strPasswd = TextField_Password:getStringValue()
		if strDailyAccount=="" or strPasswd=="" then
			g_ClientMsgTips:showMsgConfirm("用户名和密码不能为空")
			return
		end
		
	    local tbMsg = {}
		tbMsg.account  = strDailyAccount
		tbMsg.platform = 0
		g_MsgMgr:setAccount(tbMsg)
	
		local regMsg = {}
		regMsg.name = strDailyAccount
		regMsg.password = strPasswd
		g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_OnClickLogin, regMsg)
	end
	g_SetBtnWithEvent(Button_Login, 1, onPressed_Button_Login, true)
	
	local Panel_Register = PageView_LoginOrRegister:getChildByName("Panel_Register")
	Panel_Register:setVisible(true)
	local Image_UserName = tolua.cast(Panel_Register:getChildByName("Image_UserName"), "ImageView")
	local TextField_UserName = tolua.cast(Image_UserName:getChildByName("TextField_UserName"), "TextField")
	local Image_Password = tolua.cast(Panel_Register:getChildByName("Image_Password"), "ImageView")
	local TextField_Password = tolua.cast(Image_Password:getChildByName("TextField_Password"), "TextField")
	local Image_PasswordConfirm = tolua.cast(Panel_Register:getChildByName("Image_PasswordConfirm"), "ImageView")
	local TextField_PasswordConfirm = tolua.cast(Image_PasswordConfirm:getChildByName("TextField_PasswordConfirm"), "TextField")
	
	local Button_Register = tolua.cast(Panel_Register:getChildByName("Button_Register"), "Button")
	local function onPressed_Button_Register(pSender, nTag)
		strDailyAccount = TextField_UserName:getStringValue()
		strPasswd = TextField_Password:getStringValue()
		local strConfirmPasswd = TextField_PasswordConfirm:getStringValue()
		if strDailyAccount=="" or strPasswd=="" or strConfirmPasswd=="" then
			g_ClientMsgTips:showMsgConfirm(_T("用户名和密码不能为空"))
			return
		end
		if strPasswd~=strConfirmPasswd then
			g_ClientMsgTips:showMsgConfirm(_T("两次输入的密码不一致"))
			return
		end
	    local tbMsg = {}
		tbMsg.account  = strDailyAccount
		tbMsg.platform = 0
		g_MsgMgr:setAccount(tbMsg)

		local regMsg = {}
		regMsg.name = strDailyAccount
		regMsg.password = strPasswd
		g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_RequestRegistAccout, regMsg)
	end
	g_SetBtnWithEvent(Button_Register, 1, onPressed_Button_Register, true)

    local Image_LoginOrRegisterPNL = rootWidget:getChildByName("Image_LoginOrRegisterPNL")
    Image_LoginOrRegisterPNL:setTouchEnabled(true)
end
