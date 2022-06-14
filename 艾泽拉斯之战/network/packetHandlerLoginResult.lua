
function onLoadPlayerConfig()

end

function LoginResultHandler( result )
	
	print("LoginResultHandler result "..result);
	if result == enum.LOGIN_RESULT.LOGIN_RESULT_LOAD_PLAYER_SUCCESS then
		
		dataManager.playerData.login = true;
		
		dataManager.loginData:setLogin(true);
		
		game.__________ENTER_GAME = true
		--local pushInfo = global.getPushInfo();
		--dump(pushInfo);
		
		dataManager.loginData:onLoginSuccess();
		
		dataManager.buddyData:askServer()
		dataManager.buddyData:viewApplyList()	
		dataManager.buddyData:viewRecommendList()	

		dataManager.transactionData:askServerVerify();

		-- ask shop
		eventManager.dispatchEvent({name = global_event.SHOP_ON_ASK_REFRESH});
		
		if dataManager.loginData:isReconnect() == false then
			global.changeGameState(function() 
				game.EnterProcess( game.GAME_STATE_MAIN);
				eventManager.dispatchEvent({name = global_event.LOGIN_WIN_UI_HIDE});
				eventManager.dispatchEvent({name = global_event.GUIDE_ON_LOGIN});
				--dataManager.buddyData:askServer()
				--dataManager.buddyData:viewApplyList()	
				--dataManager.buddyData:viewRecommendList()	
				
				if dataManager.playerData:isFirstLogin() and dataManager.playerData:getLevel() >= dataConfig.configs.ConfigConfig[0].levelRewardLevelLimit then
					eventManager.dispatchEvent({name = "TASK_SHOW", showType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN});
				end		
				
				sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_ASK_MSG, 0);
				
			end);		
			
		else
			eventManager.dispatchEvent({name = global_event.LOADING_HIDE,});
		end
	
	else
 		
 		dataManager.loginData:setLogin(false);
 			 
			function loginResulAnotherDevice()
				GameClient.CGame:Instance():ResetGame();
			end
		local callBack = 	loginResulAnotherDevice
		
		if result ~= enum.LOGIN_RESULT.LOGIN_RESULT_PLAYER_NOT_EXIST then
			--callBack()
			--callBack = nil
		end
		local enableButton = true;
		
		if result == enum.LOGIN_RESULT.LOGIN_RESULT_PLAYER_NOT_EXIST then
			
			-- 这个是正常流程的返回结果，不需要enablebutton
			enableButton = false;
			sendCreateRole(1,global.randomPlayerName(true));
			
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_PASSWORD_WRONG then
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "密码错误",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_INVALID_NAME then
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "用户名错误",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_ANOTHER_DEVICE_LOGIN then


			GameClient.NetworkEngine:Instance():close(false);

			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "你的账号在另一台设备登录，请点击确定重新登录", callBack = callBack });
						
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_DISCONNECT_BY_SERVER then
		
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "连接被关闭",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_FORBIN_BY_SERVER then
			
			dataManager.loginData:setDisconectType(enum.LOGIN_RESULT.LOGIN_RESULT_FORBIN_BY_SERVER);
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "此号已停封",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_SERVER_SHUT_DOWN then
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "服务器维护",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_INVALID_VERSION then
			
			function onLoginVersionFailed()
				os.exit(1);
			end
			
			--print("--------------version failed-----------");
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo ="游戏有更新，请重启客户端更新!",callBack = onLoginVersionFailed });
							
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_INVALID_ACCOUNT then
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "无效的账号",callBack = callBack});

        elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_ACCOUNT_REPEAT then
            eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "此账号已有人注册",callBack = callBack});
				
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_SDK_CHECK_FAILED then

			-- 账号验证失败的处理
			function loginResultSDKCheckFailed()
				GameClient.CGame:Instance():ResetGame();
			end
		
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "登录游戏验证失败，请点击确定重新登录", callBack = loginResultSDKCheckFailed });
						
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_QUEUE_RESET then

			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "队列位置被重置"});
						
		elseif result == enum.LOGIN_RESULT.LOGIN_RESULT_CAN_NOT_KICK_CLOSING_PLAYER then
			
			eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
				textInfo = "无法踢掉正在关闭的玩家",callBack = callBack});
				
		end
		
		
		-- 都是登录失败的情况
		-- eventManager.dispatchEvent({name = global_event.LOGIN_WIN_ENABLE_LOGIN, enabled = enableButton});
			
	end
	
end
