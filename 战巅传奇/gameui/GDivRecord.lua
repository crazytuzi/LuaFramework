GDivRecord = {}
local var = {}

function GDivRecord.init()
	--[[
	var = {
		voiceLayer,
		channel,
		send,
		playerSender,
		voiceRecord = {}
	}
	local layer = cc.Layer:create()
	var.voiceLayer = GUIAnalysis.load("ui/layout/GDivRecord.uif")
	if var.voiceLayer then
		var.voiceLayer:addTo(layer):align(display.CENTER, display.cx, display.cy):hide()
	end
	cc.EventProxy.new(GameSocket,layer)
		:addEventListener(GameMessageCode.EVENT_VOICE_HANDLE, GDivRecord.voiceHandler)
		:addEventListener(GameMessageCode.EVENT_VOICE_CALLBACK, GDivRecord.voiceCallback)
 		:addEventListener(GameMessageCode.EVENT_VOICE_PLAY_FINISH, GDivRecord.onPlayVoiceFinish)

 	cc.YvMsg:getInstance():Yvlogin(CCGhostManager:getMainAvatar():NetAttr(GameConst.net_name),CCGhostManager:getMainAvatar():NetAttr(GameConst.net_seedname))
	return layer
	]]--
end

function GDivRecord.voiceHandler(event)
	if var.voiceLayer then
		if event.channel then
			var.channel = event.channel
			var.send = nil
		end
		if event.send then
			var.send = event.send
		end
		local voiceLayer = var.voiceLayer
		local mark = voiceLayer:getChildByName("mark")
		if event.vis == true then
			voiceLayer:setVisible(event.vis)
			--录音
			--GameCCBridge.callVoiceChat("stop_voice")
			--GameCCBridge.callVoiceChat("start_record")
			GameMusic.pause()
			--cc.YvMsg:getInstance():YvStopRecord()
			cc.YvMsg:getInstance():YvStartRecord(var.channel,1)
			if not mark then
				mark = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("img_voice_circle"))
				:align(display.CENTER, voiceLayer:getContentSize().width/2, 10+voiceLayer:getContentSize().height/2)
				-- :setScaleX(-1)
				:addTo(voiceLayer,100)
				:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
				:setName("mark")
			end
			mark:stopAllActions()
			mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(30,0,100),cc.CallFunc:create(function(target)
				GDivRecord.voiceHandler({vis = false,send = true})
				--GameCCBridge.callVoiceChat("stop_record")
				cc.YvMsg:getInstance():YvStopRecord()
				GameMusic.resume()
			end)))

		elseif event.vis == false and voiceLayer:isVisible() then
			if GameUtilSenior.isObjectExist(mark) then mark:stopAllActions() end
			--发送或取消
			--GameCCBridge.callVoiceChat("stop_record")
			cc.YvMsg:getInstance():YvStopRecord()
			GameMusic.resume()
			voiceLayer:setVisible(false)
		end
		voiceLayer:getWidgetByName("img_voice_info"):setVisible(event.charVis)
		voiceLayer:getWidgetByName("img_voice_back"):loadTexture(event.charVis and "img_voice_back" or "img_voice_big" ,ccui.TextureResType.plistType)
	end
end

function GDivRecord.voiceCallback(event)
	print("2222222222222222222222222222222222222222222")
	if event.func then
		if event.func == "voiceRecordStop" and event.filepath and var.send then
			local record = {
				flag = tostring(event.flag),
				filepath = event.filepath,
				time = event.time,
				newTime = os.time(),
				channel=event.channel,
			}
			if tonumber(event.time)>1000 then --小于1000毫秒不发
				for k,v in pairs(var.voiceRecord) do
					if os.time() - record.newTime >300 then
						var.voiceRecord[k] = nil
					end
				end
				var.voiceRecord[event.flag] = record
			end
			print("voiceCallback   ",event.filepath)
		elseif event.func == "voiceUploadSucc" and event.url and var.send then
			local msg = "<voice>|"..GameUtilSenior.ToBase64(event.url).."|"..event.flag
			if var.voiceRecord[event.flag] and var.voiceRecord[event.flag].flag == event.flag then
				msg = msg .. "|".. GameUtilSenior.ToBase64(var.voiceRecord[event.flag].filepath)
				msg = msg .. "|".. var.voiceRecord[event.flag].time
			else
				return
			end
			print("voiceUploadSucc   ",msg)
			if event.channel == "VoiceChannelWorld" then
				GameSocket:WorldChat(msg)
			elseif event.channel == "VoiceChannelGuild" then
				GameSocket:GuildChat(msg)
			elseif event.channel == "VoiceChannelGroup" then
				GameSocket:GroupChat(msg)
			elseif event.channel == "VoiceChannelNear" then
				GameSocket:NormalChat(msg)
			elseif event.channel == "VoiceChannelPrivate" then
				if GameSocket.m_strPrivateChatTarget and GameSocket.m_strPrivateChatTarget~="" then
					GameSocket:PrivateChat(GameSocket.m_strPrivateChatTarget,msg)
				end
			end
		else

		end
	end
end

function GDivRecord.playVoice(sender)
	if sender and (sender.filepath or sender.url) then
		if GameUtilSenior.isObjectExist(var.playerSender) then
			var.playerSender:getWidgetByName("img_voice_chat"):stopAllActions():loadTexture("img_chat_voice3", ccui.TextureResType.plistType)
		end
		var.playerSender = sender
		--GameCCBridge.callVoiceChat("stop_voice")
		GameMusic.resume()
		-- if sender.selfvoice and sender.filepath then
		-- 	GameCCBridge.callVoiceChat("play_voice",{url=sender.filepath,flag = tostring(sender.flag)})
		-- else
			--GameCCBridge.callVoiceChat("play_voice",{url=sender.url,flag = tostring(sender.flag)})	
			print(sender.url)
			print(sender.flag)
			cc.YvMsg:getInstance():YvPlayRecord(sender.url,sender.flag)	
		-- end
		local i = 0
		-- print("filepath=",sender.filepath,"url=",sender.url,"flag=",sender.flag)
		-- sender.duration = 5
		local duration = math.ceil(sender.duration/1000)
		GameBaseLogic.isPlayVoice = true
		sender:getWidgetByName("img_voice_chat"):runAction(
			cca.seq({
				cca.rep(cca.seq({
					cca.delay(1/3),
					cca.cb(function(target)
						target:loadTexture("img_chat_voice"..(i%3+1), ccui.TextureResType.plistType)
						i = i+1
						end)
					}),sender.duration*3
				),
				cca.cb(function(target)
					GameBaseLogic.isPlayVoice = false
					target:loadTexture("img_chat_voice3", ccui.TextureResType.plistType)
				end)
			})
		)
	end
end

function GDivRecord.onPlayVoiceFinish(event)
	print("xxx---xxx-----xxx----xxx")
	print(var.playerSender)
	if GameUtilSenior.isObjectExist(var.playerSender) then 
	print("STPOOOOOOPPPPPPP")
		var.playerSender:getWidgetByName("img_voice_chat"):stopAllActions():loadTexture("img_chat_voice3", ccui.TextureResType.plistType)

		-- var.playerSender:setTouchEnabled(true)
	end
	GameMusic.resume()
end

return GDivRecord