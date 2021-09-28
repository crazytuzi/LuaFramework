--------------------------------------------------------------------------------------
-- 文件名:	LYP_StartGame.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	游戏开始界面
-- 应  用:  本例子使用一般方法的实现Scene
--http://blog.csdn.net/cagehe/article/details/18017019
---------------------------------------------------------------------------------------

StartGameLayer = nil
local Label_Server = nil
local Label_Account = nil
local rootLayout = nil
local bUCLogining = nil
g_goBackReLogin = g_goBackReLogin or  nil

local bcheckNetWorkBack = nil
local function checkNetWork(nRet)
	cclog("=====checkNetWork===="..nRet)
	g_MsgMgr.nSendMsgTime = nil
	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	bcheckNetWorkBack = true
	if(nRet == 11 or nRet == 10)then
		checkClientNetWork()
	elseif(nRet == 12)then
		-- g_MsgMgr:registerErrorCallBackFunc()
	end

	--g_MsgMgr:setWaitTimeOut(0.5)
end
		
local function reLogin(bOver)
	if(g_MsgMgr.nWaitTimeOut == 2)then
		return true 
	end
	
	if(bOver)then
		g_MsgNetWorkWarning:closeNetWorkWarning()
	end
	
	if(not g_MsgMgr:checkNetWork())then
        checkClientNetWork()
		return true
	else
		g_MsgMgr:requestLogin() --请求登录
	end
end

function RequestLogin()
	
	-- g_MsgMgr:setWaitTimeOut(1.8)
	
	g_MsgMgr:requestLogin() --请求登录
	
	-- reLogin()
	-- g_Timer:pushLimtCountTimer(2, 1.5, reLogin)
	-- g_MsgMgr:registerErrorCallBackFunc(checkNetWork)
end

function showConnectServerTip()
	bcheckNetWorkBack = nil
    local function callback()
        if(not g_MsgMgr:checkNetWork() and not bcheckNetWorkBack)then
           g_MsgNetWorkWarning:showWarningText()
        end 

        bcheckNetWorkBack = nil
    end
    g_Timer:pushTimer(0.5, callback)
end

function setLoginServer(nCfgServerID)
	local ip, port, name = g_ServerList:GetCurUseServer()
	if Label_Server then
		Label_Server:setText(name)
        if g_strStandAloneGame == "open" then
            Label_Server:setText("进入游戏")
        end
	end
end

function ucLoginSucc(nType, bRet, szSID)
	cclog("uc login succ "..nType)
	if nType == 1 then
		local function delayToLogin()
			UCManager:getInstance():login()
            AccountRegResponse()
		end
		g_Timer:pushTimer(0.6, delayToLogin)  
		bUCLogining = true
	elseif nType == 2 then
		if bRet then	
            g_MsgMgr:connectToDir()
			local function delayToLoginServer()
				bUCLogining = nil
				g_MsgMgr:requestUCLogin(szSID)   
			end
			g_Timer:pushTimer(0.5, delayToLoginServer)			
		end
	end
end

function LYP_GetStartGameScene()

	-- local TDdata =  CDataEvent:CteateDataEvent()
	-- TDdata:PushDataEvent("Step3", "S") --S or F, Success or Fail
	-- gTalkingData:onEvent(TDEvent_Type.StartGame, TDdata)
    g_In_Game = false
	local Scene = CCScene:create()
    local function RegisterLayer()
        local layer = TouchGroup:create()
        layer:setTouchPriority(2)
		StartGameLayer = layer
        -- register root from json
		rootLayout = GUIReader:shareReader():widgetFromJsonFile("Game_StartGame1.json")
        layer:addWidget(rootLayout)
	--	g_setImgShader(rootLayout, pszBlurFSH3)
	
		local Image_Logo = tolua.cast(rootLayout:getChildByName("Image_Logo"), "ImageView")
		if g_Cfg.Platform  == kTargetWindows then --Windows
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo:setPositionXY(160, 605)
				Image_Logo:setScale(0.9)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo:setPositionX(Image_Logo:getPositionX() + 25)
					Image_Logo:setPositionY(Image_Logo:getPositionY() - 30)
					Image_Logo:setScale(1.25)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
				end
			else
				if g_IsXiaoXiaoXianSheng then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		elseif g_Cfg.Platform  == kTargetAndroid then --Android
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo:setPositionXY(160, 605)
				Image_Logo:setScale(0.9)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo:setPositionX(Image_Logo:getPositionX() + 25)
					Image_Logo:setPositionY(Image_Logo:getPositionY() - 30)
					Image_Logo:setScale(1.25)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
				end
			else
				if g_IsXiaoXiaoXianSheng then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		else --iOS越狱
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo:setPositionXY(160, 605)
				Image_Logo:setScale(0.9)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo:setPositionX(Image_Logo:getPositionX() + 25)
					Image_Logo:setPositionY(Image_Logo:getPositionY() - 30)
					Image_Logo:setScale(1.25)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
				end
			else
				if g_IsXiaoXiaoXianSheng then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		end
	
		local Panel_LoginButton = rootLayout:getChildByName("Panel_LoginButton")
		Panel_LoginButton:setVisible(false)
			
		local Image_LoginButtonPNL = tolua.cast(Panel_LoginButton:getChildByName("Image_LoginButtonPNL"), "ImageView")	
		-- --九游账号登陆
		-- local function onTouch9U(pSender, eventType)
		-- 	if eventType == ccs.TouchEventType.ended then
		-- 		cclog("九游账号登陆")
		-- 		if g_Cfg.Platform == kTargetAndroid then
		-- 			UCManager:getInstance():initSdk()
		-- 		end			
		-- 	end
		-- end
		-- local Button_Login9U = tolua.cast(Image_LoginButtonPNL:getChildByName("Button_Login9U"),"Button")
		-- Button_Login9U:setTouchEnabled(false)
		-- Button_Login9U:setTouchEnabled(false)
		-- Button_Login9U:addTouchEventListener(onTouch9U)
		--美天账号登陆或者QQ登录

		local function onTouchMeiTian(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
                local btnName = pSender:getName()
                local loginType = nil

                if btnName == "Button_LoginWeChat" then loginType = 1
                elseif btnName == "Button_LoginQQ" then  loginType = 0 end

				if g_GamePlatformSystem:OnClickGameLogin(loginType) == true then
                	return
                end

				openAccountWnd(g_MsgMgr.nCsvID)
			end
		end


		local Button_LoginMeiTian = tolua.cast(Image_LoginButtonPNL:getChildByName("Button_LoginMeiTian"),"Button")
		local Button_LoginWeChat = tolua.cast(Image_LoginButtonPNL:getChildByName("Button_LoginWeChat"),"Button")
		local Button_LoginQQ = tolua.cast(Image_LoginButtonPNL:getChildByName("Button_LoginQQ"),"Button")
        Button_LoginMeiTian:setVisible(false)
        Button_LoginWeChat:setVisible(false)
        Button_LoginQQ:setVisible(false)

        if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_QQ then
            Button_LoginWeChat:setVisible(true)
		    Button_LoginWeChat:setTouchEnabled(true)
		    Button_LoginWeChat:addTouchEventListener(onTouchMeiTian)

            Button_LoginQQ:setVisible(true)
		    Button_LoginQQ:setTouchEnabled(true)
		    Button_LoginQQ:addTouchEventListener(onTouchMeiTian)

        else
             Button_LoginMeiTian:setVisible(true)
		    Button_LoginMeiTian:setTouchEnabled(true)
		    Button_LoginMeiTian:addTouchEventListener(onTouchMeiTian)
        end


		local Button_Server = tolua.cast(rootLayout:getChildByName("Button_Server"), "Button")
		Button_Server:setVisible(false)
		Button_Server:setTouchEnabled(true)
		local function onClickChooseArea(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
                if g_strStandAloneGame == "open" then
                    g_playSoundEffect("Sound/ButtonClick.mp3")
     			    --点击界面就跟游戏服建立链接
     			    g_ServerList:OnEventGetServerList()    
                else
                    -- showSelectServerWnd()
				    g_ServerList:RequestServerListInfo()
				    showSelectServerWnd()
                end    
			end
		end
		Button_Server:addTouchEventListener(onClickChooseArea)
		
		local Image_TouchScreen = tolua.cast(Button_Server:getChildByName("Image_TouchScreen"), "ImageView")
		g_CreateScaleInOutAction(Image_TouchScreen)
		
		Label_Server = tolua.cast(Button_Server:getChildByName("Label_Server"), "Label")
		Label_Account = tolua.cast(rootLayout:getChildByName("Label_Account"), "Label")
		local nAreaID = CCUserDefault:sharedUserDefault():getIntegerForKey("nCsvID", 0)
		--是否有账号了 没有账号
		if(g_IsExistedActor)then
			local tbServer = nil
			-- if nAreaID == 0 then
			-- 	tbServer, nAreaID = g_DataMgr:getSeverInfoCsvNew()
			-- else
			-- 	tbServer = g_DataMgr:getSeverInfoCsv(nAreaID)			
			-- end

			local ip, port, name = g_ServerList:GetCurUseServer()
			-- cclog("------2222222222-----> Label_Server:setText ip="..ip.." port="..port.." name="..name)
			Label_Server:setText(name)
		else
			setLoginServer(nAreaID)
		end

        if g_strStandAloneGame == "open" then
            local Label_Tip = Button_Server:getChildByName("Label_Tip")
            Label_Tip:setVisible(false)

            Label_Server:setText("进入游戏")
            Label_Server:setPositionX(-50)
        end
		
		local szAccount = g_MsgMgr.szNickName  or g_MsgMgr.szAccount
		Label_Account:setText(szAccount)
		if szAccount == "" then 
			Panel_LoginButton:setVisible(true)
			Button_Server:setVisible(false)
		else
			Panel_LoginButton:setVisible(false)
			Button_Server:setVisible(true)
			
			-- if g_Cfg.Platform == kTargetAndroid and g_MsgMgr.loginPlatform == macro_pb.LOGIN_PLATFORM_UC then
			-- 	if not UCManager:getInstance():checkInited() then
			-- 		UCManager:getInstance():initSdk()			
			-- 	end
			-- end	
		end
		
		local Label_Version = tolua.cast(rootLayout:getChildByName("Label_Version"), "Label")
		local nCurVersion =  CCUserDefault:sharedUserDefault():getStringForKey("Version", "1.0.0")
		Label_Version:setText(_T("Ver.")..nCurVersion)
		local CCNode_Version = tolua.cast(Label_Version:getVirtualRenderer(), "CCLabelTTF")
		CCNode_Version:disableShadow(true)
		
		rootLayout:setTouchEnabled(true)
		rootLayout:addTouchEventListener(function(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				-- local tClientTime = os.time()
				-- local locktime = os.time({year=2015, month=7, day=24, hour=22})
				-- if tClientTime >= locktime then
				-- 	g_ClientMsgTips:showMsgConfirm("封测结束,服务器维护中.....")
				-- 	return
				-- else
				-- 	g_ClientMsgTips:showMsgConfirm("封测今晚10点结束,祝您游戏愉快")
				-- end
                -- g_MsgMgr:registerErrorCallBackFunc(checkNetWork)
				g_playSoundEffect("Sound/ButtonClick.mp3")
     			--点击界面就跟游戏服建立链接
     			g_ServerList:OnEventGetServerList()
			end
		end)
		
		if false then
			local function setCreateDirect(pSender, eventType)
                if eventType == ccs.TouchEventType.ended then
				    openAccountWnd(g_MsgMgr.nCsvID)
				    cclog("setCreateDirectsetCreateDirectsetCreateDirectsetCreateDirect")
                end
			end
			Image_CreateDirect = ImageView:create()
			Image_CreateDirect:setPositionXY(1235, 677)
			Image_CreateDirect:ignoreContentAdaptWithSize(false)
			Image_CreateDirect:setSize(CCSizeMake(80, 80))
			Image_CreateDirect:setTouchEnabled(true)
			Image_CreateDirect:setVisible(true)
			Image_CreateDirect:setName("Image_CreateDirect")
			rootLayout:addChild(Image_CreateDirect, 100)
			Image_CreateDirect:addTouchEventListener(setCreateDirect)
		end
		
		local Panel_Logout = tolua.cast(rootLayout:getChildByName("Panel_Logout"), "Layout")
		local Button_Logout = tolua.cast(Panel_Logout:getChildByName("Button_Logout"), "Button")
		local function onTouchButtonLogout(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_IsExistedActor = nil
          		g_GamePlatformSystem:OnClickGameLoginOut()
			end
		end
		Button_Logout:setTouchEnabled(true)
		Button_Logout:addTouchEventListener(onTouchButtonLogout)
		local function onTouchLayerLogout(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				onTouchButtonLogout(Button_Logout, ccs.TouchEventType.ended)
			end
		end
		Panel_Logout:setTouchEnabled(true)
		Panel_Logout:addTouchEventListener(onTouchLayerLogout)

        -- if g_goBackReLogin then
        --     local function showMsg()
        --         g_goBackReLogin = nil
        --         g_ClientMsgTips:showMsgConfirm("您的账号已注销，请重新登陆。")
        --     end
        --     g_Timer:pushTimer(0, showMsg)
        -- end
		return layer
    end

	 local function onEnterOrExit(tag)
          if tag == "enter" then
            local function ConnectPlatPlatformSuc()
            	if Scene ~= nil then
            		cclog("--------每次接入平台后在此刷新--------")
            		setLoginServer(0)
            		AccountRegResponse()
            	end
			end
            g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_ConnectSucc,  ConnectPlatPlatformSuc)

            local tmlayer = RegisterLayer()

            Scene:addChild(tmlayer)

           	--添加过渡界面
          	g_StoryScene:InitAndRegister(tmlayer)

            SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)--先停止音乐

            --流程由平台处理
            if not g_StoryScene:GetInStoryBattleTeach() then
            	g_GamePlatformSystem:PlatformStart()
            end
            

            if g_PushOut then --是否是被挤下线
            	local szText = g_DataMgr:getMsgContentCsv(g_PushOut)
            	g_ClientMsgTips:showMsgConfirm(szText.Description_ZH, nil)
            	g_PushOut = nil
            end
            
          elseif tag == "exit" then
          	if g_WndMgr then
          		g_WndMgr:dumpAnimationResouce()
          	end
			
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
            StartGameLayer = nil
            rootLayout = nil
            Label_Server = nil
            Label_Account = nil
            bUCLogining = nil
            if g_FormMsgSystem then
            	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_ConnectSucc)
            end
         end
    end
    Scene:registerScriptHandler(onEnterOrExit)		

    return Scene
end

function AccountRegResponse(bShowLoginBtn)
    bShowLoginBtn = g_GamePlatformSystem:AccountRegResponse()
    cclog("-----------------------AccountRegResponse()-------ok------")
    --local bAccount = (CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "_Default_NO_Name") ~= "_Default_NO_Name")
    local Panel_LoginButton = rootLayout:getChildByName("Panel_LoginButton")
    Panel_LoginButton:setVisible(bShowLoginBtn)

    local Button_Server = rootLayout:getChildByName("Button_Server")
    Button_Server:setVisible(not bShowLoginBtn)
	
	if Label_Account then
		local szAccount = g_MsgMgr.szAccount
		Label_Account:setText(szAccount)
	end
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
end


function GameServerConnectSuccess()
	local Scene = CCDirector:sharedDirector():getRunningScene()
	 if g_IsExistedActor > 0 then
			--过渡界面
			-- g_MsgNetWorkWarning:closeNetWorkWarning()
            if gSys_EmergencyNotice:IsSaySorry(false, Scene) == false then
			    local loadingCity = Game_LoadingCity.new()
			    loadingCity:initView() 
			    Scene:addChild(loadingCity,10)
			
                RequestLogin()                    
            end

        else
        	-- 在ios 或 android 平台 战斗教学必须开
        	if g_Cfg.Platform ~= kTargetWindows then
        		g_Cfg.BattleTeach = true
        		g_Cfg.PlayVideo = true
        	end

        	if g_Cfg.Platform ~= kTargetWindows and g_Cfg.PlayVideo then
        		local videoEventType =
				{
				  PLAYING = 0,
				  PAUSED = 1,
				  STOPPED = 2,
				  COMPLETED = 3
				};

				local function videoCallBack(eventType)
					if(eventType == videoEventType.COMPLETED) then
						cclog("COMPLETEDCOMPLETEDCOMPLETEDCOMPLETEDCOMPLETED")						       
						sampleVideo:removeFromParentAndCleanup(true)

						if g_Cfg.BattleTeach   then
							
							-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
								local function overCallBack()
									CCDirector:sharedDirector():getRunningScene():removeChild(g_StoryScene.layer,true)
									g_MsgMgr:requestRandomName()
									g_StoryScene:SetFormBattleTeachTrue()
								end
								g_StoryScene:OnExitBattleScene(overCallBack)
							-- else
								-- g_BattleTeachSystem:Begin()
							-- end 
							
						else
							g_MsgMgr:requestRandomName()
						end
					
					elseif(eventType == videoEventType.PLAYING) then
						--交给战斗教学处理
						-- g_MsgMgr:requestRandomName()
					end
				end
				sampleVideo = SampleVideoPlayer:create()
				sampleVideo:setFileName("GameUI/Video/GameStarCG.mp4")
				sampleVideo:addEventListener(videoCallBack)
				sampleVideo:registerScriptTouchHandler(function() return true end,false,-128,true)
				sampleVideo:setTouchEnabled(true)
				--sampleVideo:setTouchMode(1)
				sampleVideo:play()
				Scene:addChild(sampleVideo,1)
				
			else
				--不播放方视频的时候 就进入战斗教学。然后在教学结束的时候走剩下的流程
                if gSys_EmergencyNotice:IsSaySorry(true, Scene) == false then

					if g_Cfg.BattleTeach then
						-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
							local function overCallBack()
								CCDirector:sharedDirector():getRunningScene():removeChild(g_StoryScene.layer,true)
								g_MsgMgr:requestRandomName()
								g_StoryScene:SetFormBattleTeachTrue()
							end
							g_StoryScene:OnExitBattleScene(overCallBack)
						-- else
							-- g_BattleTeachSystem:Begin()
						-- end 
					else
						g_MsgMgr:requestRandomName()
					end
				    
                end
				--g_BattleTeachSystem:Begin()
			end
        end
		-- g_playSoundEffect("Sound/Skill/Hit_LuanShiHongYan.mp3");
end