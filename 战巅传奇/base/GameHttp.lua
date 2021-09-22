local GameHttp = class("GameHttp")

function GameHttp:ctor()
	
end

function GameHttp:appCheckReceipt(params,log_money)
	-- local receipt=string.sub(params,9)
	-- if string.len(receipt)<20 then return end

	-- if cc.UserDefault:getInstance():getStringForKey("last_receipt","")=="" then
	-- 	cc.UserDefault:getInstance():setStringForKey("last_receipt",receipt)
	-- 	cc.UserDefault:getInstance():setStringForKey("last_money",tostring(log_money))
	-- 	cc.UserDefault:getInstance():setStringForKey("last_count","0")
	-- 	cc.UserDefault:getInstance():flush()
	-- end

	-- if GameBaseLogic.gameUserid == "" then
	-- 	GameBaseLogic.gameUserid = cc.UserDefault:getInstance():getStringForKey("last_usertid","")
	-- end
	-- if GameBaseLogic.seedName == "" then
	-- 	GameBaseLogic.seedName = cc.UserDefault:getInstance():getStringForKey("last_sid","")
	-- end

	-- if GameBaseLogic.gameUserid == "" and GameBaseLogic.seedName == "" then
	-- 	GameCCBridge.showMsg("您有一笔未结算的订单,请重新登陆")
	-- 	return
	-- end

	-- GameCCBridge.showWaiting({msg="正在提交支付结果,请稍候",delay=20,outtime=function()
	-- 	GameCCBridge.showMsg("结算超时,请联系客服")
	-- 	GameBaseLogic.applePaying = false
	-- end})

	-- local xhr = cc.XMLHttpRequest:new()
 --    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
 --    xhr:open("POST", CONFIG_APPLE_PAY_URL.."/sku/"..GameBaseLogic.sku)

 --    local function onReadyStateChange()
 --        GameCCBridge.hideWaiting()

	-- 	GameBaseLogic.applePaying = false

 --    	local json_table = GameUtilSenior.decode(xhr.response)
 --        if json_table then
 --    		local status=json_table["status"]

 --    		if status and status=="ok" then
 --    			GameCCBridge.showMsg("充值成功,元宝将在3分钟内到账")

	--     		cc.UserDefault:getInstance():setStringForKey("last_receipt","")
	--     		cc.UserDefault:getInstance():setStringForKey("last_money","")
	--     		cc.UserDefault:getInstance():setStringForKey("last_count","0")
	-- 			cc.UserDefault:getInstance():flush()
 --    			return
 --    		else
 --    			GameCCBridge.showMsg("结算失败,请联系客服")
 --    		end
 --        end
 --    end

 --    xhr:registerScriptHandler(onReadyStateChange)
 --    xhr:send("userid="..GameBaseLogic.gameUserid.."&serverid="..GameBaseLogic.zoneId.."&sid="..GameBaseLogic.seedName.."&receipt="..receipt.."&money="..log_money)
end

function GameHttp:requestRename(old_name,new_name,node)
	local url = GameBaseLogic.renameUrl.."?sku="..GameBaseLogic.sku.."&account="..GameBaseLogic.gameUserid.."&oldchr="..old_name.."&newchr="..new_name.."&serverId="..GameBaseLogic.zoneId
				.."&idfa="..GameCCBridge.getConfigString("system_code")
	local function httpcallback(request)
		if request.status==200 then
	        local json_table = GameUtilSenior.decode(request.response)
	        if json_table then
				if json_table["ErrorDesc"] then
					GameUtilSenior.showAlert("错误", json_table["ErrorDesc"], "知道了")
				elseif json_table["desc"] then
					GameUtilSenior.showAlert("提示", json_table["desc"], "知道了")
				end

				if json_table["status"]=="1" then
					GameSocket:ListCharacter()
				else
					-- GameCCBridge.hideWaiting()
				end
	        end
	    else
	    	GameUtilSenior.showAlert("", "改名请求失败", "知道了")
	    end
	end
    print(url)
    GameUtilSenior.httpRequest(url, httpcallback, node)
end

function GameHttp:requestCDKey(text,node,func)
	if string.len(text)>0 then
		local url = GameBaseLogic.giftUrl.."?sku="..GameBaseLogic.sku.."&code="..text.."&chrname="..GameBaseLogic.chrName.."&ptflag="..GameCCBridge.getPlatform().."&pid="..GameCCBridge.getPlatformId().."&serverId="..GameBaseLogic.zoneId.."&idfa="..GameCCBridge.getConfigString("system_code")
		local function httpcallback(request)
			if request.status==200 then
		        local json_table = GameUtilSenior.decode(request.response)
		        if json_table then
		        	if json_table["ErrorDesc"] then
						-- GameUtilSenior.showAlert("错误", json_table["ErrorDesc"], "知道了")
						GameSocket:alertLocalMsg(json_table["ErrorDesc"], "alert")
					end
		        else
					if func then
						func(request.response)
					else
						-- GameUtilSenior.showAlert("提示", request.response, "知道了")
						GameSocket:alertLocalMsg(request.response, "alert")
					end
		        end
		    else
				-- GameUtilSenior.showAlert("错误", "兑换请求失败,请重试", "知道了")
				GameSocket:alertLocalMsg("兑换请求失败,请重试", "alert")
		    end
	    end
	    print(url)
	    GameUtilSenior.httpRequest(url, httpcallback, node)
	else
		GameUtilSenior.showAlert("提示", "请输入正确的礼包码","确定")
	end
end

function GameHttp:requestSmsCDKey(code,mobile,sms,node,func)
	print(string.len(sms),string.len(mobile),string.len(code))
	if string.len(sms)==4 and string.len(mobile)==11 and string.len(code)>0 then
		local url = GameBaseLogic.giftUrl.."?sku="..GameBaseLogic.sku.."&code="..code.."&mobile="..mobile.."&sms="..sms.."&chrname="..GameBaseLogic.chrName.."&ptflag="..GameCCBridge.getPlatform().."&pid="..GameCCBridge.getPlatformId().."&serverId="..GameBaseLogic.zoneId.."&idfa="..GameCCBridge.getConfigString("system_code")
		local function httpcallback(request)
			if request.status==200 then
		        local json_table = GameUtilSenior.decode(request.response)
		        if json_table then
		        	if json_table["ErrorDesc"] then
						-- GameUtilSenior.showAlert("错误", json_table["ErrorDesc"], "知道了")
						GameSocket:alertLocalMsg(json_table["ErrorDesc"], "alert")
					end
		        else
					if func then
						func(request.response)
					else
						-- GameUtilSenior.showAlert("提示", request.response, "知道了")
						GameSocket:alertLocalMsg(request.response, "alert")
					end
		        end
		    else
				-- GameUtilSenior.showAlert("错误", "兑换请求失败,请重试", "知道了")
				GameSocket:alertLocalMsg("兑换请求失败,请重试", "alert")
		    end
	    end
	    print(url)
	    GameUtilSenior.httpRequest(url, httpcallback, node)
	else
		GameUtilSenior.showAlert("提示", "输入错误","确定")
	end
end

function GameHttp:requestSMS(text,node,func)
	if string.len(text)==11 then
		local url = GameBaseLogic.giftUrl.."?act=sms&sku="..GameBaseLogic.sku.."&mobile="..text.."&chrname="..GameBaseLogic.chrName.."&ptflag="..GameCCBridge.getPlatform().."&pid="..GameCCBridge.getPlatformId().."&serverId="..GameBaseLogic.zoneId.."&idfa="..GameCCBridge.getConfigString("system_code")
		local function httpcallback(request)
			if request.status==200 then
		        local json_table = GameUtilSenior.decode(request.response)
		        if json_table then
		        	if json_table["ErrorDesc"] then
						-- GameUtilSenior.showAlert("错误", json_table["ErrorDesc"], "知道了")
						GameSocket:alertLocalMsg(json_table["ErrorDesc"], "alert")
					end
		        else
					if func then
						func(request.response)
					else
						-- GameUtilSenior.showAlert("提示", request.response, "知道了")
						GameSocket:alertLocalMsg(request.response, "alert")
					end
		        end
		    else
				-- GameUtilSenior.showAlert("错误", "兑换请求失败,请重试", "知道了")
				GameSocket:alertLocalMsg("请求失败,请重试", "alert")
		    end
	    end
	    print(url)
	    GameUtilSenior.httpRequest(url, httpcallback, node)
	else
		GameUtilSenior.showAlert("提示", "请输入正确的手机号码","确定")
	end
end

function GameHttp:requestGameNotice(url, callback, node)
	local function httpcallback(request)
		if request.status==200 then
	        local json_table = GameUtilSenior.decode(request.response)
	        if json_table then
	        	if callback and type(callback)=="function" then
			    	callback(json_table)
			    end
	        end
	    else

	    end
	end
    GameUtilSenior.httpRequest(url, httpcallback, node)
end


return GameHttp:new()