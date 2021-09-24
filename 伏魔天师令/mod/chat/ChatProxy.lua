local P_TOTAL_COUNT=50
local P_ChatLang=_G.Lang.chat_lang

local ChatProxy=classGc(function(self)
	self[_G.Const.CONST_CHAT_ALL]={}
	self[_G.Const.CONST_CHAT_WORLD]={}
	self[_G.Const.CONST_CHAT_CLAN]={}
	self[_G.Const.CONST_CHAT_TEAM]={}
	self[_G.Const.CONST_CHAT_PM]={}
	self[_G.Const.CONST_CHAT_SYSTEM]={}

	self.m_mediator=require("mod.chat.ChatProxyMediator")(self)
end)

function ChatProxy.getChatMsgArray(self,_channel)
	return self[_channel]
end

function ChatProxy.insertChatMsg(self,_chatMsg)
	-- print("insertChatMsg=====>>>",_chatMsg)
	if not _chatMsg or not _chatMsg.channel then return end

	local channel=_chatMsg.channel
	local msgArray=self[channel]
	msgArray[#msgArray+1]=_chatMsg

	if #msgArray>P_TOTAL_COUNT then
		table.remove(msgArray,1)
	end

	if channel~=_G.Const.CONST_CHAT_ALL then
		local allMsgArray=self[_G.Const.CONST_CHAT_ALL]
		allMsgArray[#allMsgArray+1]=_chatMsg

		if #allMsgArray>P_TOTAL_COUNT then
			table.remove(allMsgArray,1)
		end
	end

	local command=ChatMsgCommand()
	command.chatMsg=_chatMsg
	controller:sendCommand(command)
end

function ChatProxy.handleSystemNetworkMsg(self,_szContent)
	if _szContent==nil then return end

	local channel=_G.Const.CONST_CHAT_SYSTEM
	local totalArray=self:getTitleSystemMsg(channel)
	totalArray[#totalArray+1]={
		type=_G.Const.kChatTypeWord,
		szMsg=_szContent,
		color=_G.Const.CONST_COLOR_WHITE
	}
	local newMsg={}
	newMsg.channel=channel
	newMsg.contentArray=totalArray

	self:insertChatMsg(newMsg)
end
function ChatProxy.handleBroadcastNetworkMsg(self,_ackMsg)
	local broadcastId=_ackMsg.broadcast_id
	local broadcastCnf=_G.Cfg.broadcast[broadcastId]

	if broadcastCnf==nil then
		print("lua error! _G.Cfg.broadcast not find this:",broadcastId)
		return
	end
	local szContent=broadcastCnf.msg
	local contentArray=self:__handleBroadcastContentMsg(szContent,_ackMsg.data)
	if #contentArray>0 then
		local channel=broadcastCnf.pos
		local totalArray=self:getTitleSystemMsg(channel)
		local totalCount=#totalArray
		for i=1,#contentArray do
			totalCount=totalCount+1
			totalArray[totalCount]=contentArray[i]
		end

		local newMsg={}
		newMsg.channel=channel
		newMsg.contentArray=totalArray

		self:insertChatMsg(newMsg)

		self:__handleMarqueeMsg(totalArray)
	end
end
function ChatProxy.handleUserNetworkMsg(self,_ackMsg)
	local szContent=_ackMsg.msg
	local nTeamId=_ackMsg.team_id
	local contentArray=self:__handleUserContentMsg(szContent,nTeamId)

	-- print("handleUserNetworkMsg=======>>>>> 1,",#contentArray)
	if #contentArray>0 then
		local channel=_ackMsg.channel_id
		local szName=_ackMsg.uname
		local isGuide=_ackMsg.is_guide==1
		local vipLv=_ackMsg.vip
		local nGoodMsg=_ackMsg.goods_msg_no[1]
		local totalArray
		if channel==_G.Const.CONST_CHAT_PM then
			totalArray=self:getTitlePMMsg(_ackMsg.uid,szName,_ackMsg.p_uid,_ackMsg.p_name)
		else
			totalArray=self:getTitleNormalMsg(channel,_ackMsg.uid,szName,isGuide,vipLv)
		end
		local totalCount=#totalArray
		for i=1,#contentArray do
			if nGoodMsg and contentArray[i].touchType==_G.Const.kChatTouchGood then
				local goodId=nGoodMsg.goods_id
				local goodCnf=_G.Cfg.goods[goodId]
				if goodCnf~=nil then
					contentArray[i].goodMsg=nGoodMsg
					contentArray[i].szMsg=goodCnf.name -- string.format("[%s]",goodCnf.name)
					contentArray[i].color=goodCnf.name_color
					totalCount=totalCount+1
					totalArray[totalCount]=contentArray[i]
				else
					contentArray[i].touchType=nil
				end
			else
				totalCount=totalCount+1
				totalArray[totalCount]=contentArray[i]
			end
		end

		-- print("handleUserNetworkMsg=======>>>>> 2,",#totalArray)
		local newMsg={}
		newMsg.channel=channel
		newMsg.teamId=nTeamId
		newMsg.isGuide=isGuide
		-- newMsg.goodMsg=nGoodMsg
		newMsg.contentArray=totalArray

		-- for i,v in ipairs(totalArray) do
		-- 	print(i.." =====>>>>")
		-- 	for k,vv in pairs(v) do
		-- 		print(k,vv)
		-- 	end
		-- 	print("\n")
		-- end

		self:insertChatMsg(newMsg)
	end
end

function ChatProxy.handleVoiceMsg(self,_ackMsg)
	local channel=_ackMsg.channel_id
	local szName=_ackMsg.uname
	local nTeamId=_ackMsg.team_id
	local isGuide=_ackMsg.is_guide==1
	local vipLv=_ackMsg.vip
	local totalArray
	if channel==_G.Const.CONST_CHAT_PM then
		totalArray=self:getTitlePMMsg(_ackMsg.uid,szName,_ackMsg.p_uid,_ackMsg.p_uname)
	else
		totalArray=self:getTitleNormalMsg(channel,_ackMsg.uid,szName,isGuide,vipLv)
	end
	local totalCount=#totalArray
	totalCount=totalCount+1
	totalArray[totalCount]={
		type=_G.Const.kChatTypeVoice,
		szUrl=_ackMsg.url,
		second=_ackMsg.time,
		touchType=_G.Const.kChatTouchVoice
	}

	if _ackMsg.word then
		totalCount=totalCount+1
		totalArray[totalCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=string.format(" (%s)",_ackMsg.word),
			color=_G.Const.CONST_COLOR_WHITE
		}
	end

	local newMsg={}
	newMsg.channel=channel
	newMsg.teamId=nTeamId
	newMsg.isGuide=isGuide
	newMsg.contentArray=totalArray

	self:insertChatMsg(newMsg)
end

function ChatProxy.getTitleSystemMsg(self,_channel)
	local titleArray={}
	titleArray[1]={
		type=_G.Const.kChatTypeChanel,
		szMsg=_G.Lang.Chat_Channel_Name[_channel] or "[ERROR]",
		color=_G.Const.kChatChannelColor[_channel],
		channel=_channel
	}
	return titleArray
end
function ChatProxy.getTitlePMMsg(self,_sayUid,_sayName,_toUid,_toName)
	local nChannel=_G.Const.CONST_CHAT_PM
	local titleArray={}
	titleArray[1]={
		type=_G.Const.kChatTypeChanel,
		szMsg=_G.Lang.Chat_Channel_Name[nChannel],
		color=_G.Const.kChatChannelColor[nChannel],
		channel=nChannel
	}

	local nCount=1
	if _sayUid==_G.GPropertyProxy:getMainPlay():getUid() then
		-- 我对他说
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=P_ChatLang["您对"],
			color=_G.Const.CONST_COLOR_ORED
		}
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=_toName,
			color=_G.Const.CONST_COLOR_GREEN,
			touchType=_G.Const.kChatTouchName,
			name=_toName,
			uid=_toUid
		}
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=P_ChatLang["说:"],
			color=_G.Const.CONST_COLOR_ORED
		}
	else
		-- 他对我说
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=_sayName,
			color=_G.Const.CONST_COLOR_GREEN,
			touchType=_G.Const.kChatTouchName,
			name=_sayName,
			uid=_sayUid
		}
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=P_ChatLang["对您说:"],
			color=_G.Const.CONST_COLOR_ORED
		}

		if _G.GLayerManager then
			if not _G.GLayerManager:isChatViewOpen() then
				if _G.g_SmallChatView then
					_G.g_SmallChatView:showChatbtnAction()
				end
			end
		end
	end
	return titleArray
end
function ChatProxy.getTitleNormalMsg(self,_channel,_uid,_szName,_isGuide,_vipLv)
	local titleArray={}
	local nCount=0
	local channelName=_G.Lang.Chat_Channel_Name[_channel] or "????"
	nCount=nCount+1
	titleArray[nCount]={
		type=_G.Const.kChatTypeChanel,
		szMsg=channelName,
		color=_G.Const.kChatChannelColor[_channel],
		channel=_channel
	}

	if _vipLv>0 then
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeVip,
			vipLv=_vipLv
		}
	end

	if _isGuide then
		nCount=nCount+1
		titleArray[nCount]={
			type=_G.Const.kChatTypeWord,
			szMsg=P_ChatLang["(新手指导员)"],
			color=_G.Const.CONST_COLOR_GREEN
		}
	end

	if _szName then
		nCount=nCount+1
		if _uid==_G.GPropertyProxy:getMainPlay():getUid() then
			titleArray[nCount]={
				type=_G.Const.kChatTypeWord,
				szMsg="您:",
				color=_G.Const.CONST_COLOR_ORED,
				-- touchType=_G.Const.kChatTouchName,
				-- name=_szName,
				-- uid=_uid
			}
		else
			titleArray[nCount]={
				type=_G.Const.kChatTypeWord,
				szMsg=_szName,
				color=_G.Const.CONST_COLOR_GREEN,
				touchType=_G.Const.kChatTouchName,
				name=_szName,
				uid=_uid
			}

			nCount=nCount+1
			titleArray[nCount]={
				type=_G.Const.kChatTypeWord,
				szMsg=":",
				color=_G.Const.CONST_COLOR_GREEN,
			}
		end
	end

	return titleArray
end

function ChatProxy.__handleUserContentMsg(self,_szContent,_chatType)
	local showStr = _szContent
	local chatDataList={}
	local chatDataCount=0

	if _chatType==_G.Const.CONST_CHAT_TYPE_TEAM then
		local _,_,teamId,copyId=string.find(showStr, "<#T(%d+)><#T(%d+)>")
		if teamId==nil or copyId==nil then
			return chatDataList
		end
		teamId=tonumber(teamId)
		copyId=tonumber(copyId)
		local copyCnf=_G.Cfg.scene_copy[copyId]
		local copyName=copyCnf and copyCnf.copy_name or "[ERROR]"
		copyName=copyName or "[ERROR]"
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={ 
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=copyName,
			color=_G.Const.CONST_COLOR_ORANGE,
		}
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={ 
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=string.format("%s,",_G.Lang.LAB_N[534]),
			color=_G.Const.CONST_COLOR_WHITE,
		}
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={ 
			-- 文字,点击组队
			type=_G.Const.kChatTypeWord,
			szMsg=_G.Lang.LAB_N[535],
			color=_G.Const.CONST_COLOR_ORANGE,
			touchType=_G.Const.kChatTouchTeam,
			teamId=teamId,
			copyId=copyId
		}
		return chatDataList
	elseif _chatType==_G.Const.CONST_CHAT_TYPE_CLAN then
		local _,_,clanId,clanName=string.find(showStr, "<#F(%d+)><#F(.*)>")
		if clanId==nil then
			return chatDataList
		end
		clanName=clanName or ""
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg="我们的目标是称霸三界，我在",
			color=_G.Const.CONST_COLOR_WHITE,
		}
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=clanName,
			color=_G.Const.CONST_COLOR_ORANGE,
		}
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg="中等你,",
			color=_G.Const.CONST_COLOR_WHITE,
		}
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={ 
			-- 文字,点击门派
			type=_G.Const.kChatTypeWord,
			szMsg=_G.Lang.LAB_N[535],
			color=_G.Const.CONST_COLOR_ORANGE,
			touchType=_G.Const.kChatTouchClan,
			clanId=clanId,
			clanName=clanName
		}
		return chatDataList
	elseif _chatType==_G.Const.CONST_CHAT_TYPE_CLAN_NOTICE then
		local szNotic=string.format("%s:%s",_G.Lang.LAB_N[528],showStr)
		chatDataCount=chatDataCount+1
		chatDataList[chatDataCount]={ 
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=szNotic,
			color=_G.Const.CONST_COLOR_WHITE,
		}
		return chatDataList
	end

	-- 处理表情、物品
	local resultStr        = ""
	local searchIndex      = 1
	local goodsSearchIndex = 1
	local faceSearchIndex  = 1
	local closeTagIndex    = 1
	local oldSearchIndex   = 1
	local focusGoodsOrFace = 0
	local faceTagLength    = 6
	print(string.len(showStr))
	while true and showStr~=nil do
		goodsSearchIndex = string.find(showStr, "<#G", searchIndex)
		faceSearchIndex = string.find(showStr, "<#F", searchIndex)
		oldSearchIndex=searchIndex
		if not goodsSearchIndex and not faceSearchIndex then
			break
		elseif not goodsSearchIndex and faceSearchIndex then
			focusGoodsOrFace=2
			searchIndex=faceSearchIndex
		elseif goodsSearchIndex and not faceSearchIndex then
			focusGoodsOrFace=1
			searchIndex=goodsSearchIndex
		elseif goodsSearchIndex>faceSearchIndex then
			focusGoodsOrFace=2
			searchIndex=faceSearchIndex
		elseif goodsSearchIndex<faceSearchIndex then
			focusGoodsOrFace=1
			searchIndex=goodsSearchIndex
		end

		closeTagIndex = string.find(showStr, ">", searchIndex)
		if closeTagIndex==nil then
			break
		end

		resultStr=string.sub(showStr,oldSearchIndex,searchIndex-1)
		if resultStr~=nil and string.len(resultStr)>0 then
			local wordTable = { 
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=resultStr,
			color=_G.Const.CONST_COLOR_WHITE,
			}
			chatDataCount=chatDataCount+1
			chatDataList[chatDataCount]=wordTable
		end
		if focusGoodsOrFace==1 then
			-- local subStr = string.sub(showStr,searchIndex+3,searchIndex+3)
   --  		local goodsIndex=tonumber(subStr)
   --  		if goodsIndex~=nil then
    			local goodsTable = {
    				-- type=_G.Const.kChatTypeGood,
    				type=_G.Const.kChatTypeWord,
    				touchType=_G.Const.kChatTouchGood,
					-- goodIdx=goodsIndex,
    			}
    			chatDataCount=chatDataCount+1
    			chatDataList[chatDataCount]=goodsTable
    			searchIndex=closeTagIndex+1
    -- 		else
				-- resultStr= string.sub(showStr,searchIndex,closeTagIndex)
				-- if resultStr~=nil and string.len(resultStr)>0 then
				-- 	print("错误的物品数据--->",resultStr)
				-- 	local wordTable = { 
				-- 	-- 文字
				-- 	type=_G.Const.kChatTypeWord,
				-- 	szMsg=resultStr,
				-- 	color=_G.Const.CONST_COLOR_WHITE,
				-- 	}
				-- 	table.insert(chatDataList,wordTable)
				-- end
    -- 			searchIndex=closeTagIndex+1
    -- 		end
		elseif focusGoodsOrFace==2 then
			--表情
			if closeTagIndex-searchIndex==faceTagLength-1 then
				local key =string.sub(showStr,searchIndex+3,closeTagIndex-1)
				if key~=nil then
					local faceTable = {
						type=_G.Const.kChatTypeFace,
						faceId=key,
					}
					chatDataCount=chatDataCount+1
					chatDataList[chatDataCount]=faceTable
					searchIndex=searchIndex+faceTagLength
				else
					resultStr= string.sub(showStr,searchIndex,searchIndex+3)
					if resultStr~=nil and string.len(resultStr)>0 then
						print("错误的表情数据 --->",resultStr)
						local wordTable = { 
						-- 文字
						type=_G.Const.kChatTypeWord,
						szMsg=resultStr,
						color=_G.Const.CONST_COLOR_WHITE,
						}
						chatDataCount=chatDataCount+1
						chatDataList[chatDataCount]=wordTable
					end
					searchIndex=searchIndex+3
				end				
			--不是表情
			else
				resultStr=string.sub(showStr,searchIndex,searchIndex+3)
				-- print("5 2--->",resultStr)
				if resultStr~=nil and string.len(resultStr)>0 then
					local wordTable = { 
					-- 文字
					type=_G.Const.kChatTypeWord,
					szMsg=resultStr,
					color=_G.Const.CONST_COLOR_WHITE,
					}
					chatDataCount=chatDataCount+1
					chatDataList[chatDataCount]=wordTable
				end
				searchIndex=searchIndex+3
			end
		else
			resultStr=string.sub(showStr,searchIndex,searchIndex+3)
			if resultStr~=nil and string.len(resultStr)>0 then
				local wordTable = { 
				-- 文字
				type=_G.Const.kChatTypeWord,
				szMsg=resultStr,
				color=_G.Const.CONST_COLOR_WHITE,
				}
				chatDataCount=chatDataCount+1
				chatDataList[chatDataCount]=wordTable
			end
			searchIndex=searchIndex+3
		end
	end

	if showStr~=nil then
		resultStr=string.sub(showStr,oldSearchIndex,-1)
		if resultStr~=nil and string.len(resultStr)>0 then
			local wordTable = { 
			-- 文字
			type=_G.Const.kChatTypeWord,
			szMsg=resultStr,
			color=_G.Const.CONST_COLOR_WHITE,
			}
			chatDataCount=chatDataCount+1
			chatDataList[chatDataCount]=wordTable
		end
	end
	return chatDataList
end
function ChatProxy.__handleBroadcastContentMsg(self,_szContent,_msg_data)
	-- print("__handleBroadcastContentMsg======>>>>",_szContent)
	local chatDataList={}
	local chatDataCount=0
	local msgContent=_szContent

	local startTagIndex=1
	local closeTagIndex=1
	local searchIndex=1
	local parameterIndex=1

	local resultStr=nil

	while true and _msg_data~=nil do
		startTagIndex=string.find(msgContent,"<",searchIndex)
		closeTagIndex=string.find(msgContent,">",searchIndex)

		local parameterData=_msg_data[parameterIndex]
		parameterIndex=parameterIndex+1
		if not parameterData then
			resultStr=string.sub(msgContent,searchIndex,-1)

			if resultStr and string.len(resultStr)>0 then
				local wordTable={ 
					type=_G.Const.kChatTypeWord,
					szMsg=resultStr,
					color=_G.Const.CONST_COLOR_WHITE,
				}
				chatDataCount=chatDataCount+1
				chatDataList[chatDataCount]=wordTable
				-- print("最后的文字===>>>",resultStr)
			end
			break
		end

		if startTagIndex and closeTagIndex then
			resultStr=string.sub(msgContent,searchIndex,startTagIndex-1)

			if resultStr and string.len(resultStr)>0 then
				local wordTable={ 
					type=_G.Const.kChatTypeWord,
					szMsg=resultStr,
					color=_G.Const.CONST_COLOR_WHITE,
				}
				chatDataCount=chatDataCount+1
				chatDataList[chatDataCount]=wordTable
				-- print("参数前的文字===>>>",resultStr)
			end

			resultStr=string.sub(msgContent,startTagIndex+1,closeTagIndex-1)
			local parameterType=tonumber(resultStr)
			if parameterType then
				local parameterString,colorIdx,goods_id
				if parameterType==_G.Const.CONST_BROAD_PLAYER_NAME then --1     玩家名字
					parameterString=parameterData.uname or "[ERROR]"
					colorIdx=_G.Const.CONST_COLOR_ORANGE
				elseif parameterType==_G.Const.CONST_BROAD_CLAN_NAME then --2     家族名字
					parameterString=parameterData.clan_name or "[ERROR]"
					colorIdx=_G.Const.CONST_COLOR_CYANBLUE
				elseif parameterType==_G.Const.CONST_BROAD_GROUP_NAME then --3     团队名字
					parameterString=parameterData.group_name or "[ERROR]"
					colorIdx=_G.Const.CONST_COLOR_ORANGE
				elseif parameterType==_G.Const.CONST_BROAD_COPY_ID then --4     副本Id
					if parameterData.copy_id then
						local copyCnf=_G.Cfg.scene_copy[parameterData.copy_id]
						if copyCnf then
							parameterString=copyCnf.copy_name
							colorIdx=_G.Const.CONST_COLOR_ORED
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_STRING then --50    普通字符串
					parameterString=parameterData.string or "[ERROR]"
					colorIdx=_G.Const.CONST_COLOR_BROWN
				elseif parameterType==_G.Const.CONST_BROAD_NUMBER then --51    普通数字
					parameterString=tostring(parameterData.number)
					colorIdx=_G.Const.CONST_COLOR_GOLD
				elseif parameterType==_G.Const.CONST_BROAD_MAPID then --52    地图ID
					if parameterData.map_id then
						local sceneCnf=get_scene_data(parameterData.map_id)
						if sceneCnf then
							parameterString=sceneCnf.scene_name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_ORED
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_GOODSID then --54    物品
					if parameterData.goods_id then
						local goodsCnf=_G.Cfg.goods[parameterData.goods_id]
						if goodsCnf then
							parameterString=goodsCnf.name or "[ERROR]"
							colorIdx=goodsCnf.name_color--_G.Const.CONST_COLOR_BROWN
							goods_id=parameterData.goods_id
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_MONSTERID then --55    怪物ID
					if parameterData[1] then
						local monsterCnf=_G.Cfg.scene_monster[parameterData[1]]
						if monsterCnf then
							parameterString=monsterCnf.monster_name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_ORANGE
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_DOUQI_ID then --62    获得霸气
					if parameterData.douqi_id then
						local douqiCnf=_G.Cfg.fight_gas_total[parameterData.douqi_id]
						if douqiCnf then
							parameterString=douqiCnf.gas_name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_ORANGE
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_VIP_LV then --63    VIP等级 
					if parameterData.vip_lv then
						parameterString=tostring(parameterData.vip_lv)
						colorIdx=_G.Const.CONST_COLOR_GOLD
					end
				elseif parameterType==_G.Const.CONST_BROAD_MOUNT then --64    坐骑id 
					if parameterData.mount_id then
						local mountCnf=_G.Cfg.mount[parameterData.mount_id]
						if mountCnf then
							parameterString=mountCnf.name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_GOLD
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_MEIREN then --65    美人ID
					if parameterData.meiren_id then
						local meirenCnf=_G.Cfg.meiren_des[parameterData.meiren_id]
						if meirenCnf then
							parameterString=meirenCnf.name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_GOLD
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_TITLE then --66    称号名称
					if parameterData.title_id then
						local titleCnf=_G.Cfg.title[parameterData.title_id]
						if titleCnf then
							parameterString=titleCnf.title_name or "[ERROR]"
							colorIdx=_G.Const.CONST_COLOR_GOLD
						end
					end
				elseif parameterType==_G.Const.CONST_BROAD_TOP then --67    排行榜
					if parameterData.title_id then
						parameterString=_G.Lang.rank_type[parameterData.title_id] or "[ERROR]"
						colorIdx=_G.Const.CONST_COLOR_GOLD
					end
				elseif parameterType==_G.Const.CONST_BROAD_PLAYER_ID then --70     家族名字ID
					-- local sysID=parameterData.sys_id
					-- local sysCnf=_G.Cfg.sales_total[sysID]
					-- if sysCnf~=nil then
					-- 	parameterString=sysCnf.tag
					-- end
					parameterString=parameterData.sys_name or "[ERROR]"
					colorIdx=_G.Const.CONST_COLOR_CYANBLUE
				end
				if parameterString and colorIdx then
					local wordTable={ 
						type=_G.Const.kChatTypeWord,
						szMsg=parameterString,
						color=colorIdx,
					}
					if goods_id~=nil then
						wordTable.touchType=_G.Const.kChatTouchGood
						wordTable.goods_id=goods_id
					end
					chatDataCount=chatDataCount+1
					chatDataList[chatDataCount]=wordTable
					-- print("参数===>>>",parameterString)
				end
			end
			searchIndex=closeTagIndex+1
		else
			resultStr=string.sub(msgContent,searchIndex,-1)
			if resultStr and string.len(resultStr)>0 then
				local wordTable={ 
					type=_G.Const.kChatTypeWord,
					szMsg=resultStr,
					color=_G.Const.CONST_COLOR_WHITE,
				}
				chatDataCount=chatDataCount+1
				chatDataList[chatDataCount]=wordTable
				-- print("最后的文字===>>>",resultStr)
			end
			break
		end
	end
	-- print("__handleBroadcastContentMsg===> end")
	return chatDataList
end

function ChatProxy.__handleMarqueeMsg(self,_msgArray)
	local tempArray={}
	local tempCount=0
	for i=1,#_msgArray do
		if _msgArray[i].type==_G.Const.kChatTypeWord then
			tempCount=tempCount+1
			tempArray[tempCount]={str=_msgArray[i].szMsg,color=_msgArray[i].color}
		end
	end
	-- local szContent
	-- if tempCount>0 then
	-- 	szContent=table.concat(tempArray)
	-- else
	-- 	szContent="[ACK_SYSTEM_BROADCAST ERROR....]"
	-- end
	local tempT={contentArray=tempArray,level=2}
	_G.Util:getLogsView():pushMarquee(tempT)
end

local P_SIZE_CHANNEL=cc.size(90,20)
function ChatProxy.insertRichTextOne(self,_data,_richText,_fontSize)
	local nType=_data.type
	local nFontSize=_fontSize or 20

	-- print("insertRichTextOne=====>>>",nType)
	if nType==_G.Const.kChatTypeChanel then
		local tempNode=cc.Node:create()
		tempNode:setContentSize(P_SIZE_CHANNEL)

		local tempY=_fontSize and 0 or 2
		local channelSpr=cc.Sprite:createWithSpriteFrameName(string.format("general_chat_name%d.png",_data.channel))
		channelSpr:setPosition(P_SIZE_CHANNEL.width*0.5,P_SIZE_CHANNEL.height*0.5+tempY)
		tempNode:addChild(channelSpr)

		local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,tempNode)
		_richText:pushBackElement(elementNode)

		-- local channelBg=cc.Sprite:createWithSpriteFrameName("general_chat_tab.png")
		-- local channelLabel=_G.Util:createLabel(_data.szMsg,18)
		-- channelLabel:setColor(_G.ColorUtil:getRGB(_data.color))
		-- channelLabel:setPosition(27,15)
		-- channelBg:addChild(channelLabel)
		-- channelBg:setPositionY(-20)
		-- local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,channelBg)
		-- _richText:pushBackElement(elementNode)
	elseif nType==_G.Const.kChatTypeWord then
		local nTouchType=_data.touchType
		if nTouchType==nil then
			local color=_G.ColorUtil:getRGB(_data.color)
			local elementNode=ccui.RichElementText:create(1,color,255,_data.szMsg,_G.FontName.Heiti,nFontSize)
			_richText:pushBackElement(elementNode)
		else
			local nColor=_G.ColorUtil:getRGB(_data.color)
			local fColor=_G.ColorUtil:getFloatRGBA(_data.color)
			local tempLabel=_G.Util:createLabel(_data.szMsg,nFontSize)
			local tempSize=tempLabel:getContentSize()
			local tempNode=cc.Node:create()
			tempNode:setContentSize(tempSize)
			tempNode:addChild(tempLabel)
			tempLabel:setPosition(tempSize.width*0.5,tempSize.height*0.5-1)
			tempLabel:setColor(nColor)

			local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,tempNode)
			_richText:pushBackElement(elementNode)

			local lineNode=cc.DrawNode:create()
			lineNode:drawLine(cc.p(0,0),cc.p(tempSize.width,0),fColor)
			tempNode:addChild(lineNode,2)

			return tempNode
		end
	elseif nType==_G.Const.kChatTypeFace then
		local szImg=string.format("chat_%.2d.png",_data.faceId)
		local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(szImg)
		if spriteFrame==nil then return end

		local tempNode,nScale,tempY
		if _fontSize then
			nScale=_fontSize/20*0.65
			tempY=0
		else
			nScale=1
			tempY=5
		end
		local tempSpr=cc.Sprite:createWithSpriteFrame(spriteFrame)
		tempSpr:setScale(nScale)
		tempSpr:setAnchorPoint(cc.p(0,0))

		local sprSize=tempSpr:getContentSize()
		sprSize=cc.size(sprSize.width*nScale+2,sprSize.height*nScale)
		tempNode=cc.Node:create()
		tempNode:setContentSize(sprSize)
		tempNode:addChild(tempSpr)

		tempSpr:setPosition(1,-tempY)

		local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,tempNode)
		_richText:pushBackElement(elementNode)

	elseif nType==_G.Const.kChatTypeVip then
		local vipSpr=cc.Sprite:createWithSpriteFrameName(string.format("general_headvip_%d.png",_data.vipLv))
		local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,vipSpr)
		_richText:pushBackElement(elementNode)

	elseif nType==_G.Const.kChatTypeVoice then
		local tempScale,tempY,tempFontSize
		if _fontSize then
			tempScale=0.75
			tempY=-2
		else
			tempScale=1
			tempY=-4
		end

		local tempSpr=cc.Sprite:createWithSpriteFrameName("general_chat_voice_btn.png")
		tempSpr:setAnchorPoint(cc.p(0,0))
		tempSpr:setScale(tempScale)
		tempSpr:setTag(100)
		tempSpr:setPosition(0,tempY)

		local tempSize=tempSpr:getContentSize()
		tempSize=cc.size(tempSize.width*tempScale,tempSize.height*tempScale)
		local tempNode=cc.Node:create()

		local secondLab=_G.Util:createLabel(tostring(_data.second).."'",nFontSize+1)
		secondLab:setPosition(tempSize.width*0.5+14,tempSize.height*0.5+tempY+1)
		secondLab:setColor(_G.Const.kChatVoiceColorEndLab)
		secondLab:setTag(90)
		tempNode:addChild(secondLab,1)
		tempNode:addChild(tempSpr)
		tempNode:setContentSize(tempSize)

		if _data.isPlayEnd then
			tempSpr:setColor(_G.Const.kChatVoiceColorEndSpr)
		-- 	secondLab:setColor(_G.Const.kChatVoiceColorEndLab)
		-- else
		-- 	secondLab:setColor(_G.Const.kChatVoiceColorPlayLab)
		end

		local elementNode=ccui.RichElementCustomNode:create(1,cc.c3b(255,255,255),255,tempNode)
		_richText:pushBackElement(elementNode)
		return tempNode
	end
end

function ChatProxy.requestClanNotic(self,_clanNotic)
	gcprint("ChatProxy.requestClanNotic====>  _clanNotic=",_clanNotic)
	local sendString=tostring(_clanNotic or "")
	local msg=REQ_CHAT_SEND()
	msg:setArgs(_G.Const.CONST_CHAT_TYPE_CLAN,0,_G.Const.CONST_CHAT_TYPE_CLAN_NOTICE,sendString,0)
	_G.Network:send(msg)
end
function ChatProxy.requestClanRecruit(self,_clanId,_clanName)
	gcprint("ChatProxy.requestClanRecruit====>  clanId=",_clanId," ,clanName=",_clanName)
	_clanName=string.gsub(_clanName,"\n","")
	
	local sendString=string.format("<#F%s><#F%s>",tostring(_clanId),tostring(_clanName))
	local msg=REQ_CHAT_SEND()
	msg:setArgs(_G.Const.CONST_CHAT_WORLD,0,_G.Const.CONST_CHAT_TYPE_CLAN,sendString,0)
	_G.Network:send(msg)
end
function ChatProxy.requestInviteTeam(self,_teamId,_copyId)
	gcprint("ChatProxy.requestInviteTeam====>  _teamId=",_teamId," ,_copyId=",_copyId)

	local sendString=string.format("<#T%s><#T%s>",tostring(_teamId),tostring(_copyId))
	local msg=REQ_CHAT_SEND()
	msg:setArgs(_G.Const.CONST_CHAT_WORLD,0,_G.Const.CONST_CHAT_TYPE_TEAM,sendString,0)
	_G.Network:send(msg)
end

return ChatProxy