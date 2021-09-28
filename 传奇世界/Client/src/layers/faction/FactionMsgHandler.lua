--ÐÐ»áÁªÃË¡¢ÐûÕ½µÈ¹ã²¥Í¨Öª
local factionYSTOperNtf = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("FactionSocialOperatorSuc", buff) 
    local oper = t.opType
    local AFac = t.srcFactionName
    local BFac = t.dstFactionName
	if oper == 2 then   --½¨Á¢ÁªÃË
        local text = string.format(game.getStrByKey("factionYST_operNotify2"), AFac, BFac)
        TIPS({type = 4 , str=text})
    elseif oper == 4 then  --ÖÐÖ¹ÁªÃË
        local text = string.format(game.getStrByKey("factionYST_operNotify3"), AFac, BFac)
        TIPS({type = 4 , str=text})
    elseif oper == 5 then  --ÐûÕ½
        local text = string.format(game.getStrByKey("factionYST_operNotify1"), AFac, BFac)
        TIPS({type = 4 , str=text})
    end

    --Èç¹ûÉæ¼°±¾ÐÐ»áË¢ÐÂÊý¾Ý
    local m_fac_name = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONNAME)
    if m_fac_name == AFac or m_fac_name == BFac then
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETSOCIALINFO, "GetFactionSocialInfo", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    end
end

--ÐÐ»áÁªÃË¡¢ÐûÕ½µÈ¹ã²¥Í¨Öª
local factionTaskDoneNtf = function(buff)
    local t = g_msgHandlerInst:convertBufferToTable("FactionTaskDoneNotify", buff) 
    local factionName = t.factionName
    local taskID = t.taskID

   -- local task_info = getConfigItemByKey("FactionTaskDB","q_id",taskID)
   -- if task_info ~= nil then
        local text = string.format(game.getStrByKey("faction_task_done_ntf"), factionName)
        TIPS({type = 4 , str=text})
   -- end
end

--¹«»áµÈ¼¶Í¨Öª
local factionJobNtf = function(buff)
    if G_FACTION_INFO ~= nil then
        local t = g_msgHandlerInst:convertBufferToTable("FactionInviteNotify", buff) 
      
        --ÓïÁÄ´¦Àí£¬µÈ¼¶µÄ±ä»¯ÐèÒªÖØÐÂ¼Ó·¿¼ä
        --if G_FACTION_INFO.isInRealVoiceRoom and G_FACTION_INFO.job ~= nil and t.nCommandId ~= userInfo.currRoleStaticId then
        --   if (G_FACTION_INFO.job >= 3 and t.position < 3) or (G_FACTION_INFO.job < 3 and t.position >= 3) then
        --       cclog("yuexiaojun factionJobNtf sendExitVoiceRoom")
        --       sendExitVoiceRoom()
        --   end
        --end      
        
        G_FACTION_INFO.job = t.position
        G_FACTION_INFO.zhihuiID = t.nCommandId     
        G_FACTION_INFO.isHaveVoiceRoom = t.dwHasVoiceRoom > 0

        cclog("yuexiaojun factionJobNtf %d, %d, %s",t.position,t.dwHasVoiceRoom,t.nCommandId)
    end
end

--ÑûÇë¼ÓÈëÐÐ»á·µ»Ø
local factionInviteJoneRet = function(buff)
    TIPS({type = 4 , str=game.getStrByKey("faction_invite_join_ret")})    
end

--Í¨ÖªÊÜÑû·½
local factionInviteJoinNtf = function(buff)    
    if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FACTION) then
        local t = g_msgHandlerInst:convertBufferToTable("FactionInviteJoinNotify", buff)
        local senderIDV = t.inviteRoleSID
        local senderNameV = t.inviteRoleName
        local factionIDV = t.factionID
        local factionNameV = t.factionName
        table.insert(G_FACTION_INVITE_DATA, { senderID = senderIDV, senderName = senderNameV, factionID = factionIDV, factionName = factionNameV})
        G_MAINSCENE:createFactionInviteNoticeNode(G_FACTION_INVITE_DATA)
    end
end

--ÊÜÑû·½´¦ÀíÇëÇó·µ»Ø
local factionInviteJoinChooseRet = function(buff)

end

--Í¨ÖªÑûÇë·½
local factionInviteChooseNtf = function(buff)
    local t = g_msgHandlerInst:convertBufferToTable("FactionInviteJoinChooseNotify", buff)
    local Name = t.playerName
    local idx = t.choose
    if idx == 1 then
        local text = string.format(game.getStrByKey("faction_invite_join_choose_ntf"), Name)
        TIPS({type = 4 , str=text})
    else
        local text = string.format(game.getStrByKey("faction_invite_join_choose_ntf2"), Name)
        TIPS({type = 4 , str=text})
    end
end

--ÉêÇë¼ÓÈëÐÐ»áÊýÁ¿±ä»¯Í¨Öª
local factionApplyListChangeOperNtf = function(buff)
    local t = g_msgHandlerInst:convertBufferToTable("ApplyCntNotify", buff) 
    local count = t.count
    if G_MAINSCENE ~= nil then 
        G_MAINSCENE:setFactionRedPointVisible(1, count > 0) 
    end
end

--ÐÐ»áÐÅÏ¢¸üÐÂÍ¨Öª
local factionInfoChange = function(buff)
    local t = g_msgHandlerInst:convertBufferToTable("FactionInfoNotify", buff)
    if G_FACTION_INFO ~= nil then 
        G_FACTION_INFO.Money = t.money
    end
end

local factionAllyList = function( buff )
    local t = g_msgHandlerInst:convertBufferToTable("FactionUnionSocialNotify", buff) 
    G_FACTION_INFO.ally_fac_list = {}
    local fac_num =  #t.factionIDs
    for i=1, fac_num do
         G_FACTION_INFO.ally_fac_list[i] = t.factionIDs[i]
    end

    if G_ROLE_MAIN and G_ROLE_MAIN.updateCornerSign_ex then
        G_ROLE_MAIN:updateCornerSign_ex(2)
    end

    if G_MAINSCENE then
        if G_MAINSCENE:checkShaWarState() then
            G_MAINSCENE.map_layer:ShaWarTransforCheck()
        end
        G_MAINSCENE:changePlayColor()
    end
end

local HostilityFactionList = function( buff )
    local t = g_msgHandlerInst:convertBufferToTable("FactionHostilitySocialNotify", buff) 
    G_FACTION_INFO.Hostile_fac_list = {}
    local fac_num =  #t.factionIDs
    for i=1, fac_num do
         G_FACTION_INFO.Hostile_fac_list[i] = t.factionIDs[i]
    end
    --dump(G_FACTION_INFO.Hostile_fac_list, "G_FACTION_INFO.Hostile_fac_list")
    
    if G_MAINSCENE then 
        G_MAINSCENE:changePlayColor()
    end
end


local onRecvFireData = function(buffer)
	log("onRecvFireData")
	local t = g_msgHandlerInst:convertBufferToTable("FactionAreaFireStatusRetProcotol", buffer)
	--local isOn = t.status
	local exp = t.addExp
	local totalTime = t.totalWood
    local time = t.time
    --local isOpen = t.isOpen
    local state = t.state
	log("totalTime = "..totalTime)
	--dump(G_FACTION_INFO)
	if G_FACTION_INFO then
		G_FACTION_INFO.fireData = {}
		--G_FACTION_INFO.fireData.isFireOn = isOn
		G_FACTION_INFO.fireData.exp = exp
		G_FACTION_INFO.fireData.totalTime = totalTime
        G_FACTION_INFO.fireData.time = time
        --G_FACTION_INFO.fireData.isOpen = isOpen
        G_FACTION_INFO.fireData.state = state --0 »î¶¯Î´¿ªÆô 1 µÈ´ý»á³¤¿ªÆô 2 Ô¤¿ªÆô 3 ÒÑ¿ªÆô 4 »î¶¯½áÊø
	end
	dump(G_FACTION_INFO)
	log("isOn = "..tostring(isOn))
	--dump(G_MAINSCENE.map_layer.npc_tab)
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.npc_tab then
		for k,v in pairs(G_MAINSCENE.map_layer.npc_tab) do
			if k == 10463 then
				local fireSprite = v
				fireSprite = tolua.cast(fireSprite, "SpriteMonster")
				if fireSprite then
					local titleNode = fireSprite:getTitleNode()

                    local function updateFireInfo(passTime)
                        --dump(passTime)
                        titleNode:removeChildByTag(124)
                        
                        local timeStr = ""
                        if G_FACTION_INFO.fireData.time then
                            G_FACTION_INFO.fireData.time = G_FACTION_INFO.fireData.time - passTime
                            if G_FACTION_INFO.fireData.time <= 0 then
                                G_FACTION_INFO.fireData.time = 0
                            end

                            --Í¬²½·þÎñÆ÷Ê±¼ä
                            -- if G_FACTION_INFO.fireData.time > 0 and G_FACTION_INFO.fireData.time % 10 == 0 then
                            --     --log("111111111111111111111111 "..G_FACTION_INFO.fireData.time)
                            --     local t = {}
                            --     t.factionID =  G_MAINSCENE.map_layer.inviteFactionId or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
                            --     g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_FIRE_STATUS, "FactionAreaFireStatusPtotocol", t)
                            -- end
                            --dump(G_FACTION_INFO.fireData.time)
                            timeStr = string.format("%02d", (math.floor(G_FACTION_INFO.fireData.time/60)%60))..":"..string.format("%02d", (G_FACTION_INFO.fireData.time%60))
                        end
                        local str = string.format(game.getStrByKey("faction_fire_top_tip_3"), timeStr, G_FACTION_INFO.fireData.exp, G_FACTION_INFO.fireData.totalTime)
                        local richText = require("src/RichText").new(titleNode, cc.p(0, 45), cc.size(200, 30) , cc.p(0.5, 0.5), 20, 18, MColor.white)
                        richText:addText(str, MColor.white, true)
                        richText:setFont(18, MColor.white, 1, MColor.black)
                        richText:format()
                        richText:setTag(124)
                    end

                    local function createFireInfo()
                        updateFireInfo(0)
                        local timeNode = startTimerActionEx(titleNode, 1, true, function(passTime) updateFireInfo(passTime) end)
                        timeNode:setTag(125)
                    end

                    local function createNormalInfo(state)
                        local str = game.getStrByKey("faction_fire_top_tip_"..state)
                        local richText = require("src/RichText").new(titleNode, cc.p(0, 15), cc.size(200, 30) , cc.p(0.5, 0), 20, 18, MColor.white)
                        richText:setAutoWidth()
                        richText:addText(str, MColor.white, true)
                        richText:setFont(18, MColor.white, 1, MColor.black)
                        richText:format()
                        richText:setTag(124)
                    end

                    local function updatePreInfo(passTime)
                        --dump(passTime)
                        titleNode:removeChildByTag(124)
                        
                        local timeStr = ""
                        if G_FACTION_INFO.fireData.time then
                            G_FACTION_INFO.fireData.time = G_FACTION_INFO.fireData.time - passTime
                            if G_FACTION_INFO.fireData.time <= 0 then
                                G_FACTION_INFO.fireData.time = 0
                            end

                            --Í¬²½·þÎñÆ÷Ê±¼ä
                            -- if G_FACTION_INFO.fireData.time > 0 and G_FACTION_INFO.fireData.time % 10 == 0 then
                            --     --log("111111111111111111111111 "..G_FACTION_INFO.fireData.time)
                            --     local t = {}
                            --     t.factionID =  G_MAINSCENE.map_layer.inviteFactionId or require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
                            --     g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_FIRE_STATUS, "FactionAreaFireStatusPtotocol", t)
                            -- end
                            dump(G_FACTION_INFO.fireData.time)
                            timeStr = string.format("%02d", (math.floor(G_FACTION_INFO.fireData.time/60)%60))..":"..string.format("%02d", (G_FACTION_INFO.fireData.time%60))
                        end
                        local str = string.format(game.getStrByKey("faction_fire_top_tip_2"), timeStr)
                        local richText = require("src/RichText").new(titleNode, cc.p(0, 15), cc.size(200, 30) , cc.p(0.5, 0), 20, 18, MColor.white)
                        richText:setAutoWidth()
                        richText:addText(str, MColor.white, true)
                        richText:setFont(18, MColor.white, 1, MColor.black)
                        richText:format()
                        richText:setTag(124)
                    end

                    local function createPreInfo()
                        updatePreInfo(0)
                        local timeNode = startTimerActionEx(titleNode, 1, true, function(passTime) updatePreInfo(passTime) end)
                        timeNode:setTag(125)
                    end

                    local function createFire()
                        if titleNode:getChildByTag(123) == nil then
                            local effect = Effects:create(false)
                            effect:setCleanCache()
                            effect:playActionData("Guildbonfire", 19, 2, -1)
                            titleNode:addChild(effect)
                            effect:setAnchorPoint(cc.p(0.5, 0.5))
                            addEffectWithMode(effect, 1)
                            dump(fireSprite:getContentSize())
                            effect:setPosition(cc.p(0, -125))
                            effect:setTag(123)
                        end
                    end

                    local function removeFire()
                        if titleNode:getChildByTag(123) then
                            titleNode:removeChildByTag(123)
                        end
                    end

                    --titleNode:removeChildByTag(123)
                    titleNode:removeChildByTag(124)
                    titleNode:removeChildByTag(125)

                    if state == 0 then
                        createNormalInfo(0)
                        removeFire()
                    elseif state == 1 then
                        removeFire()
                        createNormalInfo(1)
                    elseif state == 2 then
                        removeFire()
                        createPreInfo()
                    elseif state == 3 then
                        createFire()
                        createFireInfo()
                    elseif state == 4 then
                        removeFire()
                        createNormalInfo(4)
                    end




					-- if titleNode then
					-- 	if isOn then
     --                        if titleNode:getChildByTag(123) == nil then
    	-- 						local effect = Effects:create(false)
    	-- 						effect:setCleanCache()
    	-- 					    effect:playActionData("Guildbonfire", 19, 2, -1)
    	-- 					    titleNode:addChild(effect)
    	-- 					    effect:setAnchorPoint(cc.p(0.5, 0.5))
    	-- 					    addEffectWithMode(effect, 1)
    	-- 					    effect:setPosition(cc.p(fireSprite:getContentSize().width/2, fireSprite:getContentSize().height/2-15))
    	-- 					    effect:setTag(123)
     --                        end

					-- 	    local str = string.format(game.getStrByKey("faction_fire_top_tip"), G_FACTION_INFO.fireData.exp, G_FACTION_INFO.fireData.totalTime)
					-- 	    local richText = require("src/RichText").new(titleNode, cc.p(fireSprite:getContentSize().width/2, fireSprite:getContentSize().height+160), cc.size(200, 30) , cc.p(0.5, 0.5), 20, 18, MColor.white)
					-- 	  	richText:addText(str, MColor.white, true)
					-- 	  	richText:setFont(18, MColor.white, 1, MColor.black)
					-- 	  	richText:format()
					-- 	  	richText:setTag(124)
     --                        createRichText(0)
     --                        local timeNode = startTimerActionEx(titleNode, 1, true, function(passTime) createRichText(passTime) end)
     --                        timeNode:setTag(125)
     --                    else
     --                        titleNode:removeChildByTag(123)
					-- 	end
					-- end
				end
			end
		end
	end
end

--ÓïÁÄÏà¹Ø
local onVoiceAuthKeyRetData = function( buff ) 
    cclog("yuexiaojun onVoiceAuthKeyRetData")
    
    local t = g_msgHandlerInst:convertBufferToTable( "ApolloAuthKeyRetProtocol" , buff )

    cclog("yuexiaojun ApolloAuthKeyRetProtocol")

    if t.dwErrno == 0 then
        cclog("yuexiaojun VoiceApollo:onGetAuthKey")
        
        VoiceApollo:onGetAuthKey(t.dwMainSvrUrl1, t.dwMainSvrUrl2, t.dwSlaveSvrUrl1, t.dwSlaveSvrUrl2, t.dwAuthkeyLen, t.szAuthKey, t.dwExpireIn)
        G_FACTION_INFO.isSetAuthKey = true
    end
end

sendCreateVoiceRoom = function()
    if G_FACTION_INFO.lastCreateRoomReqTime ~= nil and os.time() - G_FACTION_INFO.lastCreateRoomReqTime < 15 then
        return
    end

    G_FACTION_INFO.lastCreateRoomReqTime = os.time()
    
    cclog("yuexiaojun FACTION_VOICE_CS_CREATE_ROOM")
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_VOICE_CS_CREATE_ROOM, "FactionVoiceCreateRoomProtocol", {})
end

sendJoinVoiceRoom = function()
    if G_FACTION_INFO.lastJoinRoomReqTime ~= nil and os.time() - G_FACTION_INFO.lastJoinRoomReqTime < 15 then
        return
    end

    G_FACTION_INFO.lastJoinRoomReqTime = os.time()
    
    cclog("yuexiaojun FACTION_VOICE_CS_JOIN_ROOM")
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_VOICE_CS_JOIN_ROOM, "FactionVoiceJoinRoomProtocol", {dwFactionId=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
end

sendExitVoiceRoom = function()
    cclog("yuexiaojun FACTION_VOICE_CS_EXIT_ROOM")
    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_VOICE_CS_EXIT_ROOM, "FactionVoiceExitRoomProtocol", {dwFactionId=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    
    --µ÷ÓÃsdkÖÐµÄÓïÁÄÍË³ö½Ó¿Ú
    cclog("yuexiaojun sendExitVoiceRoom VoiceApollo:onExitRoom")
    VoiceApollo:onExitRoom()
    G_FACTION_INFO.isInRealVoiceRoom = false
end

local onCreateVoiceRoomRet = function(buffer)
    cclog("yuexiaojun onCreateVoiceRoomRet")
end

local onJoinVoiceRoomRet = function(buffer)   
    cclog("yuexiaojun onJoinVoiceRoomRet")
    
    local t = g_msgHandlerInst:convertBufferToTable("FactionVoiceJoinRoomRetProtocol", buffer)
    cclog("yuexiaojun onJoinVoiceRoomRet parm")
    
    local onJoin = function(resultType) 
        cclog("yuexiaojun onJoinVoiceRoomRet onJoin %d", resultType)
        if resultType > 0 then
            G_FACTION_INFO.isInRealVoiceRoom = true  
            if G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
                VoiceApollo:OpenMic()
                VoiceApollo:OpenSpeaker() 
                VoiceApollo:SetSpeakerVolume(120)    
                VoiceApollo:SetMicVolume(120)   
            else
                VoiceApollo:CloseMic()
                VoiceApollo:OpenSpeaker() 
                VoiceApollo:SetSpeakerVolume(120)    
            end        
        end
    end

    VoiceApollo:onExitRoom()
    VoiceApollo:SetJoinRoomDoneCallback(onJoin)
    VoiceApollo:onJoinRoom(t.user_access, t.roomid, t.roomkey, t.business_id, t.roletype, t.memberid, t.user_openid)
    --VoiceApollo:CloseMic()
    
    G_FACTION_INFO.voiceRome = {} 
    G_FACTION_INFO.voiceRome.user_access = t.user_access
    G_FACTION_INFO.voiceRome.roomid = t.roomid
    G_FACTION_INFO.voiceRome.roomkey = t.roomkey
    G_FACTION_INFO.voiceRome.memberid = t.memberid
    G_FACTION_INFO.voiceRome.user_openid = t.user_openid
    G_FACTION_INFO.voiceRome.roletype = t.roletype
    G_FACTION_INFO.voiceRome.business_id = t.business_id
end

local onExitVoiceRoomRet = function(buffer)
    cclog("yuexiaojun onExitVoiceRoomRet")
end

local onCloseVoiceRoomRet = function(buffer)
    cclog("yuexiaojun onCloseVoiceRoomRet")
end

local onCreateVoiceRoomNtf = function(buffer)
    G_FACTION_INFO.isHaveVoiceRoom = true
    cclog("yuexiaojun onCreateVoiceRoomNtf")
end

local onCloseVoiceRoomNtf = function(buffer)
    --ÉèÖÃÅäÖÃ
    G_FACTION_INFO.isHaveVoiceRoom = false
    cclog("yuexiaojun onCloseVoiceRoomNtf")
end

local onComandIDNtf = function(buffer)
    local isCommand = false
    if G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
        isCommand = true
    end   
     
    local t = g_msgHandlerInst:convertBufferToTable("FactionCommandSetUserIdNtfProtocol", buffer)
	G_FACTION_INFO.zhihuiID = t.memberid

    if G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
        cclog("yuexiaojun onComandIDNtf is zhihui")
    else
        cclog("yuexiaojun onComandIDNtf isnot zhihui")
    end

    --command±ä»¯¶Ô×Ô¼ºµÄÓ°Ïì£¬»á¶ÔÆÕÍ¨»áÔ±Ó°Ïì
    if G_FACTION_INFO.zhihuiID ~= userInfo.currRoleStaticId and isCommand then   --±»³·ÏúÖ¸»Ó
        if G_FACTION_INFO.isInRealVoiceRoom then
            cclog("yuexiaojun factionJobNtf sendExitVoiceRoom")
            sendExitVoiceRoom()
        end
    elseif G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId and not isCommand then --±»ÈÎÃüÖ¸»Ó
        if G_FACTION_INFO.isInRealVoiceRoom then
            cclog("yuexiaojun factionJobNtf sendExitVoiceRoom")
            sendExitVoiceRoom()
        end
    end
end

local factionDel = function(buffer)
    local t = g_msgHandlerInst:convertBufferToTable("FactionDisbandNotify", buffer)

    local factionID = t.factionID
    local changeFlg = false
    dump(factionID, "factionID")
    dump(G_FACTION_INFO.ally_fac_list, "G_FACTION_INFO.ally_fac_list")
    if G_FACTION_INFO.ally_fac_list and #G_FACTION_INFO.ally_fac_list > 0 then
        for k,v in pairs(G_FACTION_INFO.ally_fac_list) do
            if v == factionID then
                table.remove(G_FACTION_INFO.ally_fac_list, k)
                changeFlg = true
            end
        end
    end
    --dump(G_FACTION_INFO.ally_fac_list, "G_FACTION_INFO.ally_fac_list")
    dump(G_FACTION_INFO.Hostile_fac_list, "G_FACTION_INFO.ally_fac_list")
    if G_FACTION_INFO.Hostile_fac_list and #G_FACTION_INFO.Hostile_fac_list > 0 then
        for k,v in pairs(G_FACTION_INFO.Hostile_fac_list) do
            if v == factionID then
                table.remove(G_FACTION_INFO.Hostile_fac_list, k)
                changeFlg = true
            end
        end
    end
    --dump(G_FACTION_INFO.Hostile_fac_list, "G_FACTION_INFO.ally_fac_list")
    if G_MAINSCENE and changeFlg then
        G_MAINSCENE:changePlayColor()
    end
end

g_msgHandlerInst:registerMsgHandler( FACTION_SC_SOCIALAPPLYUNION , function( ... ) TIPS({type = 4 , str=game.getStrByKey("factionYST_applyNotify")})  end )   --ÇëÇóÁªÃËÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_SOCIALOPERATOR_SUC , factionYSTOperNtf)   --ÁªÃË²Ù×÷Í¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_APPLYCNT_RET , factionApplyListChangeOperNtf)   --ÓÐÈËÉêÇë¼ÓÈë¹«»áÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_SOCIALRETURNITEM , function( ... ) TIPS({type = 4 , str=game.getStrByKey("factionYST_goodsRetNotify")})  end )   --ÎïÆ·Í¨¹ýÓÊ¼þÍË»ØÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_PRAYRETURNITEM , function( ... ) TIPS({type = 4 , str=game.getStrByKey("factionQFT_goodsRetNotify")})  end )   --ÎïÆ·Í¨¹ýÓÊ¼þÍË»ØÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_NOTIFYFACTIONINFO, factionInfoChange)
g_msgHandlerInst:registerMsgHandler( FACTION_SC_TASKDONE_NOTIFY , factionTaskDoneNtf )   --ÐÐ»áÈÎÎñÍê³ÉÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_INVITE_NOTIFY_FACTIONINFO , factionJobNtf )   --¹«»áµÈ¼¶Í¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_SC_INVITE_JONE_RET , factionInviteJoneRet)   --ÑûÇë¼ÓÈëÐÐ»á·µ»Ø
g_msgHandlerInst:registerMsgHandler( FACTION_SC_INVITE_NOTIFY_JONE , factionInviteJoinNtf)   --Í¨ÖªÊÜÑû·½
g_msgHandlerInst:registerMsgHandler( FACTION_SC_INVITE_JOIN_CHOOSE_RET , factionInviteJoinChooseRet)   --ÊÜÑû·½´¦ÀíÇëÇó·µ»Ø
g_msgHandlerInst:registerMsgHandler( FACTION_SC_INVITE_NOTIFY_CHOOSE , factionInviteChooseNtf)   --Í¨ÖªÑûÇë·½

g_msgHandlerInst:registerMsgHandler( APOLLO_SC_AUTHKEY , onVoiceAuthKeyRetData ) --ÓïÁÄÊý¾ÝÏà¹Ø
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_CREATE_ROOM , onCreateVoiceRoomRet)   --´´½¨ÓïÁÄ·¿¼äÓ¦´ð
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_JOIN_ROOM , onJoinVoiceRoomRet)   --¼ÓÈëÓïÁÄ·¿¼äÓ¦´ð
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_EXIT_ROOM , onExitVoiceRoomRet)   --ÍË³öÓïÁÄ·¿¼äÓ¦´ð
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_CLOSE_ROOM , onCloseVoiceRoomRet)   --¹Ø±ÕÓïÁÄ·¿¼äÓ¦´ð
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_NTF_CREATE_ROOM , onCreateVoiceRoomNtf)   --´´½¨ÓïÁÄ·¿¼äÍ¨Öª
g_msgHandlerInst:registerMsgHandler( FACTION_VOICE_SC_NTF_CLOSE_ROOM , onCloseVoiceRoomNtf)   --¹Ø±ÕÓïÁÄ·¿¼äÍ¨Öª
g_msgHandlerInst:registerMsgHandler(FACTION_COMMAND_SC_NTF_USERID, onComandIDNtf)  --Ö¸»ÓÕßIDÍ¨Öª

g_msgHandlerInst:registerMsgHandler( FACTION_SC_UNIONSOCIALR_RET , factionAllyList)   --ÃË°îÁÐ±í 
g_msgHandlerInst:registerMsgHandler( FACTION_SC_HOSTILITYSOCIALR_RET , HostilityFactionList)   --µÐ¶ÔÐÐ»áÁÐ±í
g_msgHandlerInst:registerMsgHandler(FACTIONAREA_SC_FIRE_STATUS, onRecvFireData)
g_msgHandlerInst:registerMsgHandler(FACTION_SC_DISBAND_NOTIFY, factionDel)
