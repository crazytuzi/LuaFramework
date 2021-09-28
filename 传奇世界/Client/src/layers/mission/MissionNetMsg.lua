local MissionNetMsg = class("MissionNetMsg", require ("src/MsgHandler") )
local msgids = {}
local isFirstEvery = true   --剧情是否是第一次登陆添加
function MissionNetMsg:ctor(handler_node)
	self.voiceTemp = 0
	self.parent  = handler_node
	DATA_Mission.ContributionTime = 0
	
	msgids = {
					DIALOG_SC_CLICKNPC,
					TASK_SC_ADD_TASK,
					TASK_SC_STATUS_CHANGE, 
					TASK_SC_TARGET_STATE_CHANGE,
					TASK_SC_CUR_MAIN_TASK,
					TASK_SC_ADD_DAILY_TASK, 
					TASK_SC_FINISH_DAILY_TASK, 
					TASK_SC_DAILY_TARGET_STATE_CHANGE ,
					TASK_SC_UP_REWARD_STAR_RET ,
					--镖车
					DART_SC_CLICK_NPC_RET,

					--密令
					TASK_SC_ADD_BRANCH_TASK , 
					TASK_SC_FINISH_BRANCH_TASK , 
					TASK_SC_GET_FINISH_BRANCH_RET , 
					TASK_SC_BRANCH_TARGET_STATE_CHANGE , 

					--悬赏
                    TASK_SC_SELECT_OWNER_REWARDTASK,
                    TASK_SC_SELECT_REWARDTASK,
                    TASK_SC_ADD_REWARD_TASK,
                    TASK_SC_FINISH_REWARD_TASK,
                    TASK_SC_REWARD_TARGET_STATE_CHANGE,
                    
                    TASK_SC_SEND_LASTTASK_INFO,

					-- 共享任务
					TASK_SC_SHARE_TASK,
					TASK_SC_GET_SHARED_TASK_PRIZE_RET,
					TASK_SC_ADD_SHARED_TASK,
					TASK_SC_FINISH_SHARED_TASK,
					TASK_SC_SHARED_TARGET_STATE_CHANGE,
					TASK_SC_AFTER_GET_SHARED_TASK,
					TASK_SC_GET_SHARED_TASK_TIMES,
				}
	
	local callbacks = {
						function(buff) self:recvClickNPC(buff) end ,
						function(buff) self:addTask(buff , 1 ) end , 
						function(buff) self:recvTaskStateChange(buff) end ,
						function(buff) self:recvTaskProgress(buff) end , 
						function(buff) self:addTask(buff , 2 ) end ,
						function(buff) self:recvDaylyTask(buff) end ,
						function(buff) self:recvFilishTask(buff) end, 
						function(buff) self:recvDaylyTaskState(buff) end ,
						function(buff) self:recvTaskUpStar(buff) end ,

						--镖车
						function(buff) self:recvBodyguard(buff) end ,

						--密令
						function(buff) self:addBranchTask(buff) end ,
						function(buff) self:finishBranch(buff) end ,
						function(buff) self:historyBranch(buff) end ,
						function(buff) self:branchChange(buff) end ,

						--悬赏
                        function(buff) self:RecvSelfRewardTask(buff) end,
                        function(buff) self:RecvAcceptableRewardTask(buff) end,
                        function(buff) self:RecvAddRewardTask(buff) end,
                        function(buff) self:RecvFinishRewardTask(buff) end,
                        function(buff) self:RecvRewardTargetStatusChange(buff) end,

                        function(buff) self:recvShowEvery(buff) end, 

						-- 共享任务
						function(buff) self:RecvShareTaskTransmit(buff) end,
						function(buff) self:RecvShareTaskPrize(buff) end,
						function(buff) self:RecvShareTaskBegin(buff) end,
						function(buff) self:RecvShareTaskFinish(buff) end,
						function(buff) self:RecvShareTaskUpdate(buff) end,
						function(buff) self:RecvShareTaskGetTask(buff) end,
						function(buff) self:RecvShareTaskGetTaskTimes(buff) end,
					}

	self:init(handler_node,msgids,callbacks)


end

function MissionNetMsg:unregistMsgHander()
    for k,v in pairs(msgids)do 
        g_msgHandlerInst:registerMsgHandler(v,nil)
    end	
    MissionNetMsg.has_register = nil
    msgids = {}
end

function MissionNetMsg:init(handler_node,msgids,callbacks)
    local func = function(buff,msgid)
        if callbacks then
            for k,v in pairs(msgids)do
                if v == msgid and __TASK then
                    callbacks[k](buff)
                end
            end
        elseif handler_node.networkHander then
            handler_node:networkHander(buff,msgid)
        end
    end
    local function eventCallback(eventType)
        if eventType == "enter" then
            if not MissionNetMsg.has_register then
                for k,v in pairs(msgids)do 
                    g_msgHandlerInst:registerMsgHandler(v,func)
                end
            end
        elseif eventType == "exit" and (not noclean) then
            self:unregistMsgHander(msgids)       
        end
    end
    for k,v in pairs(msgids)do 
        g_msgHandlerInst:registerMsgHandler(v,func)
    end
    MissionNetMsg.has_register = true
    self:registerScriptHandler(eventCallback)
    handler_node:addChild(self)
end

function MissionNetMsg:getCurrentTask()
	-- body
	return MissionNetMsg.cur_chapter_id, MissionNetMsg.cur_task_id
end
--获取任务配置信息
function MissionNetMsg:getCurrentTaskCfg()
	return getConfigItemByKeys("TaskDB",{"q_chapter","q_taskid"},{ MissionNetMsg:getCurrentTask() })
end
--客户端点击npc，通知服务端
function MissionNetMsg:sendClickNPC( npcID )
	--TIPS( { type = 1 , str = "sendClickNPC:"..npcID} )
	local isUseTaskTag = false	--是否是使用任务的目标
 	if DATA_Mission then 
 		DATA_Mission:setFindPath( true ) --可以支持密令自动寻路了
 		isUseTaskTag = DATA_Mission:checkUseTag( 2 , npcID ) --检测是否是使用任务目标
	end
	if isUseTaskTag == false then
		local sendClickNpc = function()
			g_msgHandlerInst:sendNetDataByTableExEx(DIALOG_CS_CLICKNPC, "DialogClickProtocol", { npcId = npcID } )
		end
		if G_ROLE_MAIN and G_MAINSCENE and G_MAINSCENE.map_layer then 
			local tile_pos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
			local span_dis = math.max(math.abs(tile_pos.x-G_ROLE_MAIN.tile_pos.x),math.abs(tile_pos.y-G_ROLE_MAIN.tile_pos.y))
			if span_dis >= 3 then
				if span_dis > 5 then span_dis = 5 end
				performWithDelay(G_MAINSCENE,sendClickNpc,0.2*span_dis)
			else
				sendClickNpc()
			end
		else
			sendClickNpc()
		end
	end

	-- if g_npcDelay == nil then
	-- end
	-- g_npcDelay = false
	-- performWithDelay( __TASK , function() g_npcDelay = nil  end , 1.5 )  --1.5秒内禁止发请求
end


function MissionNetMsg:recvClickNPC( luaBuffer )
		
		local t = g_msgHandlerInst:convertBufferToTable( "DialogClickRetProtocol" , luaBuffer ) 
        -- this is weddingsystem use special deal way
        if t.npcId == 11000 then     -- special npc id check
            require("src/layers/weddingSystem/WeddingSysCommFunc").showXunLiLayer()
            do return end
        elseif (t.npcId >= 11002 and t.npcId <= 11051) then
            require("src/layers/weddingSystem/WeddingSysCommFunc").showYueLaoNpcLayerInWeddingScene()
            do return end
        elseif t.npcId == 11001 then
            -- do nothing here 
            do return end
        end

		local tempData = {}
		tempData["npcid"]  		= t.npcId   		--npcid 					
		tempData["txtid"]  		= t.txtId   		--对话文本id 
		tempData["typeV"] 		= t.type 			--对话文本类型 1是任务对话，2是npc对话
		tempData["txt"] = ""
		local txt 				= t.txt	 			--对话文本内容，如果txtId小于等于0时候使用 , 如果typeV为1时 这里代表任务的章数
		tempData["npcCfg"] 		= getConfigItemByKey("NPC", "q_id"  )[ tempData["npcid"] ]

		print("recvClickNPC", tempData["typeV"], tempData["npcid"])
		if tempData["txtid"] <= 0 then
			tempData["txt"] = txt
		else
			if tempData["typeV"] == 1 then
				local state = tempData["txtid"]%10	--1,任务激活 2,--任务完成，还没交 3,--任务提交( 不会出现在这里的 只是后台的定义 )    4,--可接
				tempData["state"] = state
				tempData["txtid"] = math.floor( tempData["txtid"]/10 )
				 --txt  第一位是任务类型（1主线任务 2诏令任务（不会出现在前台的） 3狩魔猎人 4密令任务 ）   后两位表示章节（只有主线任务后边有章节  其它类型任务都为00）
				local task_type = math.floor(tonumber(txt)/100)
				local cfgTxt = { "q_task_active" , "q_task_done" , "Error" , "q_task_accept" }
				if task_type == 1 then
					local q_chapterid = tonumber(txt)%100
					
					local curData =  getConfigItemByKeys( "TaskDB" , { "q_chapter" , "q_taskid" } , { q_chapterid , tempData["txtid"] } )
					curData = DATA_Mission:formatTaskData( curData )
				    if curData then
				    	local speakCfg = getConfigItemByKey( "NPCSpeak" , "q_id" )[ curData.q_speakID ]				    	
				    	tempData["txt"] = speakCfg[ cfgTxt[state] ] or ""
				    	tempData["awrds"] = curData["awrds"]
				    end
				elseif task_type == 2 then
					
				elseif task_type == 3 then
					--狩魔猎人
					local speakCfg = getConfigItemByKey( "NPCSpeak" , "q_id" )[ 5014 ]
					if speakCfg then
						tempData["txt"] = speakCfg[ cfgTxt[state] ] or ""
					end
				elseif task_type == 4 then
					--4密令任务
					local curData =  getConfigItemByKeys( "BranchDB" , "q_taskid" )[  tempData["txtid"] ]
					curData = DATA_Mission:formatTaskData( curData )
					local speakCfg = getConfigItemByKey( "NPCSpeak" , "q_id" )[ curData.q_speakID ]
					if speakCfg then
						tempData["txt"] = speakCfg[ cfgTxt[state] ] or ""
						tempData["awrds"] = curData["awrds"]
					end
				end
				
			elseif tempData["typeV"] == 2 then
				tempData["txt"] = getConfigItemByKey("NPC","q_id",tempData["npcid"],"q_dialog")
				--特殊Npc面板，对话文本处理 (万人迷)
				if tempData["npcid"] == 10394 then
					local str = game.getStrByKey("charm_NoTop")
					if G_CharmRankList and G_CharmRankList.ListData and #G_CharmRankList.ListData > 0 then
						local data = G_CharmRankList.ListData[1]
						if data[2] and data[4] then
							str = string.format(tempData["txt"], tostring(data[2]), tostring(data[4]), tostring(data[2]))
						end
					end
					tempData["txt"] = str
				elseif tempData["npcid"] >= 10420 and tempData["npcid"] <= 10425 then  --天下第一
					local npcid = tempData["npcid"]
					if G_NO_ONEINFO and G_NO_ONEINFO[npcid - 10420 + 1] and G_NO_ONEINFO[npcid - 10420 + 1] ~= "" and tempData["npcCfg"].q_name then
						tempData["txt"] = string.format(game.getStrByKey("task_forNO1"), G_NO_ONEINFO[npcid - 10420 + 1], tempData["npcCfg"].q_name)
					end
				elseif tempData["npcid"] >= 10455 and tempData["npcid"] <= 10460 then  --中州王
					if G_EMPIRE_INFO and G_EMPIRE_INFO.BIQI_KING and G_EMPIRE_INFO.BIQI_KING.name and G_EMPIRE_INFO.BIQI_KING.name ~= "" then
						tempData["txt"] = string.format(game.getStrByKey("biqi_npcChat"), G_EMPIRE_INFO.BIQI_KING.name)
					else
						tempData["txt"] = string.format(game.getStrByKey("biqi_npcChat"), game.getStrByKey("biqi_str16"))
					end
				elseif tempData["npcid"] == 11099 then--江湖百晓生，对话是随机文本
					if not G_TIPS then
						require("src/config/LoadingTips")
					end
					print("G_TIPS", G_TIPS)
					if G_TIPS then
						local nLength = #G_TIPS
						local nRandomIndex = math.random(1, nLength)
						print("nRandomIndex", nRandomIndex, G_TIPS[nRandomIndex])
						tempData["txt"] = G_TIPS[nRandomIndex]
					end
				elseif tempData["npcid"] == 10454 then
					if G_CharmRankList and G_CharmRankList.ListData and #G_CharmRankList.ListData > 0 then
						local data = G_CharmRankList.ListData[1]
						if data[2] then
							tempData["txt"] = string.format(game.getStrByKey("charm_NpcText"), tostring(data[2]))
						end
					end
				end
			end
		end		

		local controlFilter = {  
									["5"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY )  , 			--模块控制(副本 进入副本 )
									["7"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_SINPVP )  , 			--模块控制(挑战竞技场)
									["8"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY )  , 			--模块控制(副本 运镖)
									["9"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER )  , 			--模块控制(送花 -- 魅力榜)
									["11"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK )  , 			--模块控制(接受任务 )
									["12"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK )  , 			--模块控制(发布任务)
									["13"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,  	 		--模块控制(副本 屠龙传说)
									["21"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,  	 		--模块控制(副本 落霞夺宝)
									["22"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,  	 		--模块控制(副本 多人守卫)
									["23"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,  	 		--模块控制(副本 通天塔)
									["24"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,  	 		--模块控制(副本 进入炼狱)
									["25"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_UNDEFINE ) ,  	 	--模块控制(副本 未知暗殿)
									["26"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) ,	  	 	--模块控制(完成任务)
									["28"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) ,	  	 	--模块控制(副本 焰火屠魔)
									["29"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_RANK )  ,    		--模块控制(排行榜)
									["31"] = G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY )  ,    		--模块控制(副本 仙翁赐酒)
								}
		local controlIndex = {}
		tempData["optionTable"] = {}
		local options = t.options
		local optioncnt 	= #options		--选项个数
		for i = 1 , optioncnt do
			local _tempTabel = {}
			_tempTabel["optionid"] = options[i].op_id  			--小于1000读配置，大于0则读取下面的数据
			if _tempTabel["optionid"] > 1000 then
				_tempTabel["optiontext"] 	= options[i].text  	--选项文本
				--optiontype 选项类型 1Runtime_Task运行时任务类 2Doer执行某项功能 3Client客户端操作( 约定操作 )4Close关闭对话框5执行客户端指定函数
				_tempTabel["optiontype"] 	= options[i].type 	
				_tempTabel["optionvalue"] 	= options[i].value  	--选项参数
				_tempTabel["optionicon"] 	= options[i].icon  	--选项图标id
				_tempTabel["optionparam"] 	= options[i].param  	--选项参数
				
				if  string.find( _tempTabel["optiontext"] , '###' )  then
					local splitStr = stringsplit( _tempTabel["optiontext"] , "###")
					_tempTabel["optiontext"] = splitStr[1]
					_tempTabel["optionvalue"] = splitStr[2]
				end
			else
				--读取配置
				local cfg = getConfigItemByKey("NpcOptionDB","id")[ _tempTabel["optionid"] ]
				_tempTabel["optiontext"] 	= cfg["text"]  	--选项文本
				_tempTabel["optiontype"] 	= cfg["type"] 	--选项类型 1Runtime_Task运行时任务类 2Doer执行某项功能 3Client客户端操作( 约定操作 )4Close关闭对话框
				_tempTabel["optionvalue"] 	= cfg["value"]  --选项参数
				_tempTabel["optionicon"] 	= cfg["icon"]  	--选项图标id
				_tempTabel["optionparam"] 	= cfg["param"]  --选项参数(  optiontype为1 并且optionparam为11时  为任务等级不足 )

				local controlValue = controlFilter[ _tempTabel["optionid"] .. "" ]
				if controlValue ~= nil then
					if not controlValue then table.insert( controlIndex , i ) end
				end
			
			end

			tempData["optionTable"][i] = _tempTabel
		end

		if #controlIndex>0 then
			table.sort( controlIndex, function( a , b ) return a>b end  )
			for i = 1 , #controlIndex do
				table.remove( tempData["optionTable"] , controlIndex[i] )
			end
		end

		if #tempData["optionTable"] > 1 then
			table.sort( tempData["optionTable"] , function( a , b ) return a.optionid<b.optionid end )
		end

        ----------------------------这里特殊NPC可能会与任务挂钩，特殊处理(后台没有走正常的NPC流程 ，这里完全没必要特殊处理)------------------------------------
        local commConst = require("src/config/CommDef");
        local getNpcOptionsById = function(npcid)
            local tab = {};
            local optionStr = getConfigItemByKey("NPC", "q_id", npcid, "q_options");
            local optionTmp = stringToTable(string.sub(optionStr, 2, #optionStr-1));
            optionTmp = optionTmp[1];
            for i = 1, #optionTmp do
                local optionId = tonumber(optionTmp[i]);
                --读取配置
                local tmpTab = {}
				local cfg = getConfigItemByKey("NpcOptionDB","id")[ optionId ]
				tmpTab["optiontext"] 	= cfg["text"]  	--选项文本
				tmpTab["optiontype"] 	= cfg["type"] 	--选项类型 1Runtime_Task运行时任务类 2Doer执行某项功能 3Client客户端操作( 约定操作 )4Close关闭对话框
				tmpTab["optionvalue"] 	= cfg["value"]  --选项参数
				tmpTab["optionicon"] 	= cfg["icon"]  	--选项图标id
				tmpTab["optionparam"] 	= cfg["param"]  --选项参数

				local isAdd = true
				local controlValue = controlFilter[ optionId .. "" ]
				if controlValue ~= nil then
					if not controlValue then isAdd = false end
				end
				if isAdd then
                	tab[i] = tmpTab
				end
            end

            return tab;
        end
        if tempData["npcid"] == commConst.NPC_ID_SHADOW_PAVILION then  -- 幽影阁门人
            tempData["optionTable"] = getNpcOptionsById(commConst.NPC_ID_SHADOW_PAVILION);
            local hasTask = false;
            local isFinish = false;
            local curData = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"];
            if curData ~= nil then
                hasTask = true;
                if curData.finished == 6 then
                    tempData["awrds"] = curData["awrds"]
                    isFinish = true;
                else
                    if curData.targetData.cur_num >= curData.targetData.count then
                        tempData["awrds"] = curData["awrds"]
                        isFinish = true;
                    else    -- 未完成任务提示
					    tempData["txt"] = game.getStrByKey("taskNotFinished");
                    end
			    end
			end
            if hasTask then
                if isFinish then
                    tempData["optionTable"][1] = tempData["optionTable"][3];
                    tempData["optionTable"][2] = nil;
                    tempData["optionTable"][3] = nil;
                else
                    tempData["optionTable"][1] = tempData["optionTable"][2];

                    tempData["optionTable"][2] = nil;
                    tempData["optionTable"][3] = nil;
                end
            else
                tempData["optionTable"][2] = nil;
                tempData["optionTable"][3] = nil;
            end
        elseif tempData["npcid"] == commConst.NPC_ID_DRAGON_SLIAYER then  -- 屠龙传说
            tempData["optionTable"] = getNpcOptionsById(commConst.NPC_ID_DRAGON_SLIAYER);
        end
        ---------------------------------------------------------------------------------
		
		self:initChatBtnStatus(tempData.optionTable)

		if tempData["npcid"] then
			--npc语音
			local npcVoiceId = getConfigItemByKey("NPC","q_id",tempData["npcid"],"q_voice")
			if (tempData["typeV"] == 1 and self.voiceTemp ~= npcVoiceId) or tempData["typeV"] == 2 then
				if npcVoiceId  then
					if G_NPC_SOUND then
						AudioEnginer.stopEffect(G_NPC_SOUND)
						G_NPC_SOUND = nil
					end
					G_NPC_SOUND = AudioEnginer.randNPCMus(tempData["npcid"],npcVoiceId)
					self.voiceTemp = npcVoiceId
				end
			end
		end
        __TASK:npcNewChat( tempData );
end

function MissionNetMsg:initChatBtnStatus(tempTable)
	for k,v in pairs(tempTable) do
		if v.optionid == 36 then --兑换结晶
			if G_WKINFO then 
				local flg = G_WKINFO.changeFlg and G_WKINFO.changeFlg or false
				v.BtnEnabled = G_WKINFO.changeFlg
			end
		elseif v.optionid == 34 then
			local facID = MRoleStruct:getAttr(PLAYER_FACTIONID)
			if not facID or facID == 0 then
				tempTable[k] = nil
			end
		elseif v.optionid == 50 then
			local facID = MRoleStruct:getAttr(PLAYER_FACTIONID)
			if not facID or facID == 0 then
				tempTable[k] = nil
			end
		elseif v.optionid == 79 then
			local facID = MRoleStruct:getAttr(PLAYER_FACTIONID)
			if facID and facID ~= 0 then
				tempTable[k] = nil
			end
		elseif v.optionid == 67 then 
			-- if G_MAINSCENE.storyNode and G_MAINSCENE.storyNode.m_curMineCount and G_MAINSCENE.storyNode.m_curMineCount < 8 then
				-- v.BtnEnabled = false
			-- end
			local commConst = require("src/config/CommDef")
			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5008 and userInfo.lastFbType == commConst.CARBON_MINE and G_MAINSCENE.map_layer.mineState ~= 2  then
				v.BtnEnabled =false
			end

			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.robMineHasTalkNpc then
				v.BtnEnabled =false
			end
		end
	end
end

--服务器增加一个任务，通知客户端任务id和任务目标信息
function MissionNetMsg:addTask( luaBuffer , flag )
	local plotNetData = {}   						--剧情网络数据
	if flag == 1  then
		local t = g_msgHandlerInst:convertBufferToTable("AddTaskProtocol", luaBuffer ) 
		plotNetData["taskID"] = t.taskID		--任务ID
		plotNetData["isNew"] = t.isNew 		--1接取任务，0表示已经接取
		plotNetData["chapterID"] = t.chapter 	--章节的ID
		plotNetData["targetNum"] = #t.targetState 	--任务目标的数量
		plotNetData["targetState"] = t.targetState  				--任务目标的状态值表
		setLocalRecordByKey( 2 , "plot_taskID" .. ( userInfo.currRoleStaticId or 0 )  , tostring( plotNetData["taskID"] ) )
	else
		local t = g_msgHandlerInst:convertBufferToTable("CurMainTaskProtocol", luaBuffer ) 
		local cur_task_id = t.taskID
		local cur_chapter_id = t.chapter

		--当前任务不够接取等级的时候，
		if cur_task_id == 0 then
			--主线任务全部完成
			return
		end

		plotNetData["taskID"] = cur_task_id		    --任务ID
		plotNetData["chapterID"] = cur_chapter_id 	--章节的ID
		plotNetData["isBan"] = true --阻挡任务

	end

	local tempData =  DATA_Mission:getLastTaskData()

	if tempData then
		G_MAINSCENE.map_layer:setNpcNormal( tempData.q_endnpc )
		G_MAINSCENE.map_layer:setNpcNormal( tempData.q_startnpc )
	end


	DATA_Mission:upPlotData( plotNetData )
	tempData = DATA_Mission:getLastTaskData()

	if tempData then
		if tempData.finished == 6 or tempData.finished == 3 then 
			G_MAINSCENE.map_layer:setNpcState( tempData.q_endnpc , 1 )
		else
			if tempData.finished == 2 then
				G_MAINSCENE.map_layer:setNpcState( tempData.q_startnpc , 3 )
			else
				G_MAINSCENE.map_layer:setNpcState( tempData.q_startnpc , 2 )
			end
		end
	end


	
	if flag == 2 then
		-- 	__TASK:findPath(tempData)
	else
		if plotNetData["isNew"] == 1 then 
			-- __TASK:playTaskEffect(1)  
			local tempData = DATA_Mission:getLastTaskData()
			if tempData.q_done_event and tonumber( tempData.q_done_event ) == 0 then 
				if  G_ROLE_MAIN:getHP() > 0 then
					__TASK:findPath(tempData)
				end
			end
			if tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 then
				game.setAutoStatus(0)
			end
		end
	end
	

	if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE.check then
		G_NFTRIGGER_NODE:check()
	end
end


--任务完成度改变，通知客户端
function MissionNetMsg:recvTaskStateChange( luaBuffer )
	local t = g_msgHandlerInst:convertBufferToTable("SatusChangeProtocol", luaBuffer ) 
	local plotNetData = {}   						--剧情网络数据
	plotNetData["taskType"] = t.taskType		--任务类型（1, --主线任务2, --日常任务 3, --怪物猎人任务  4, --密令任务 5，悬赏任务 6 共享任务 ）
	plotNetData["taskID"] = t.taskID		--任务ID
	plotNetData["chapterID"] = t.chapter 	--章节的ID
	plotNetData["taskState"] = { t.taskState } 				--1 激活, 2 完成未提交, 3完成提交
	--dump(plotNetData)
	
	--1, --主线任务
	local fun1 = function()
			local tempData = DATA_Mission:getLastTaskData()
			local autoTask = function()
				local isAuto = false 
				local autoSpecialCfg = { [53] = true , [54] = true , [55] = true , [56] = true ,[57] = true  } --可以自动执行的任务
				local q_done_event = tonumber( stringsplit( tempData.q_done_event , "_" )[1] )
				if autoSpecialCfg[q_done_event] then
					isAuto = true 
				end
				if game.getAutoStatus() >= AUTO_TASK or isAuto then
					game.setAutoStatus(0)
    				if (q_done_event and q_done_event ~= 0) or isAuto then  -- 收集任务
						__TASK:findPath( tempData ) 
					end
				end
			end
			
			if plotNetData["taskState"][1] == 1 then 
				autoTask()
				G_MAINSCENE.map_layer:setNpcState( tempData["q_startnpc"] , 3 )
			elseif plotNetData["taskState"][1] == 2 then 
				G_MAINSCENE.map_layer:setNpcNormal( tempData["q_startnpc"] )
				
				if tempData.targetType == 1 then
					tempData.finished = 3
				else
					if __TASK.hunterFindPath or ( DATA_Mission and DATA_Mission.plotFindPath ~= nil ) then
						__TASK:findPath( tempData )
					end
				end
				G_MAINSCENE.map_layer:setNpcState( tempData["q_endnpc"] , 1 )

				if  tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 then
					tempData.isBegin = nil
					tempData.isEnd = true
					tempData = copyTable( tempData )
					tempData.q_done_event = 0 
					tempData.targetType = 1 					
					__TASK:findPath( tempData )
				end

				if tempData.q_fast_talk and tempData.q_fast_talk == 1 and __TASK then
					if __TASK.hunterFindPath or ( DATA_Mission and DATA_Mission.plotFindPath ~= nil ) then
						__TASK:fastTalk( tempData )
					end
				end

			elseif plotNetData["taskState"][1] == 3 then
				--任务完成，完成特效
				AudioEnginer.playEffect("sounds/uiMusic/ui_complete.mp3",false) 		
				__TASK:playTaskEffect(2)
				G_MAINSCENE.map_layer:setNpcState( tempData["q_endnpc"] , 1 )
				G_MAINSCENE.map_layer:setNpcNormal( tempData["q_startnpc"] )

				if tonumber(tempData.q_start_type) == 2 then
					-- q_start_type == 1 自动接取，执行寻路 q_start_type == 2时需要手动接取，通过点击操作寻路 
					if tonumber( tempData.q_done_event ) ~= 0 then
						--此处 先强制 转换 
						tempData.q_done_event = 0 
						tempData.targetType = 1 
					end
					__TASK:findPath( tempData )
				end
				if plotNetData["taskID"] == 10000 then
					G_MAINSCENE:csbdOpen(2)
				end
			end



	end
	--2, --日常任务 
	local fun2 = function()
		if plotNetData["taskState"][1] == 2 then 
			if TOPBTNMG then TOPBTNMG:showRedMG( "Every" , true )  end
		else
			if TOPBTNMG then TOPBTNMG:showRedMG( "Every" , false )  end
		end
	end
	--3, --怪物猎人任务  
	local fun3 = function()
	end
	--4, --密令任务
	local fun4 = function()
		plotNetData.id = plotNetData["taskID"]
		--dump(plotNetData)
		if plotNetData["taskState"][1] == 2 or plotNetData["taskState"][1] == 3 then
			plotNetData.isFull = true
		end
		DATA_Mission:upBranchData( plotNetData )
		local branchCfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ plotNetData.id ]
		local typeNum = DATA_Mission:chechWing( branchCfg )
		local curData = DATA_Mission:getLastBranch( typeNum == 1 and "branch" or "wing" )

		if plotNetData["taskState"][1] == 1 then

			local startNpc =  curData["q_startnpc"]
			G_MAINSCENE.map_layer:setNpcState( startNpc , 3 )

			-- --展示接取动画
			-- require("src/layers/mission/BranchLayer" ):showFirstEff( plotNetData.id )
			
		elseif plotNetData["taskState"][1] == 2 then

			local endNpc =  curData["q_endnpc"]
			G_MAINSCENE.map_layer:setNpcState( endNpc , 1 )

			if plotNetData["taskID"] == 50001 and getLocalRecord("showFirstEff") ~= true then
				--展示接取动画
				require("src/layers/mission/BranchLayer" ):showFirstEff( plotNetData.id )
				setLocalRecord("showFirstEff", true)
			end
		elseif plotNetData["taskState"][1] == 3 then
			AudioEnginer.playEffect("sounds/uiMusic/ui_complete.mp3",false) 		
			__TASK:playTaskEffect(2)
			
			if require("src/layers/mission/BranchLayer" ):checkWingLast( plotNetData.id ) then
				if __TASK then __TASK:playGetWingEffect() end
			end

			local endNpc =  curData["q_endnpc"]
			G_MAINSCENE.map_layer:setNpcNormal( endNpc )
		end

	end

    -- 5，悬赏任务
    local fun5 = function()
	end

	-- 6 共享任务
    local fun6 = function()
	end


	local switchFun = { fun1 , fun2 , fun3 , fun4, fun5, fun6 }
	switchFun[plotNetData["taskType"]]()
end


--任务进度改变，通知客户端
function MissionNetMsg:recvTaskProgress(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("TargetSatusChangeProtocol", luaBuffer ) 
	local plotNetData = {}   						--剧情网络数据
	plotNetData["taskID"] = t.taskID		--任务ID
	plotNetData["chapterID"] = t.chapter 	--章节的ID
	plotNetData["targetNum"] = #t.targetState 	--任务目标的数量
	plotNetData["targetState"] = t.targetState 				--任务目标的状态值表

	DATA_Mission:upPlotData( plotNetData )

	__TASK:showTip()
end

--日常任务
function MissionNetMsg:recvDaylyTask( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "AddDailyTaskProtocol" , buff ) 
	local everyData = {}
	everyData.id = t.taskID    --任务ID
	everyData.isNew = t.isNew    --是否为新任务 1表示新接任务，0表示原来的任务
	everyData.turnNum = t.curloop 	--日常任务当前环数
	everyData.rewardid = t.rewardId	--日常任务奖励ID
	everyData.taskstate = t.targetState

	everyData.curCost = t.needFinishIngot 		--当前这个任务完美完成需要多少元宝
	everyData.allCost = t.needAllIngot 		--第二个是剩下的所有任务一键完成需要多少元宝(包含当前任务的花费)
	everyData.expNum = t.etrXp 		--完美完成 额外的经验奖励 

	--接受任务
	if not isFirstEvery then
		__TASK:playTaskEffect(1)
		AudioEnginer.playEffect("sounds/uiMusic/ui_accept.mp3",false)
	end
	DATA_Mission:upEveryData( everyData )
	
end

function MissionNetMsg:recvFilishTask( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "FinishDailyTaskProtocol" , buff ) 
	local taskid = t.taskID
	local curloop = t.curloop
	DATA_Mission:changeKeyValue( "turnNum" , curloop )

	AudioEnginer.playEffect("sounds/uiMusic/ui_complete.mp3",false)
	--播放完成
	__TASK:playTaskEffect(2)


end

--完成任务再次登陆，任务通知
function MissionNetMsg:recvShowEvery( buff )
	local t = g_msgHandlerInst:convertBufferToTable( "SendLastTaskInfoProtocol" , buff ) 
	local taskType = t.taskType --任务类型   1, --主线任务2, --日常任务3, --怪物猎人任务4, --密令任务
	local taskid = t.taskID    --任务ID
	local rewardid = t.rewardID --奖励ID（日常任务用）
	
	local switchFun = {
		handler1 = function()

		end,
		handler2 = function()
			local everyData = {}
			everyData.id = taskid
			everyData.isNew = 0    --是否为新任务 1表示新接任务，0表示原来的任务
			everyData.turnNum = __TASK:getEveryNum() 	--日常任务当前环数
			everyData.rewardid = rewardid 
			everyData.taskstate = { 0 }
			everyData.isOverLogin = true 		

			--接受任务
			DATA_Mission:upEveryData( everyData )

			DATA_Mission:changeKeyValue( "turnNum" , __TASK:getEveryNum() )
		end,
		handler3 = function()
		end,
		handler4 = function()

		end,
	}

	if switchFun[ "handler" .. taskType ] then switchFun[ "handler" .. taskType ]() end
end

--日常击杀
function MissionNetMsg:recvDaylyTaskState( buff )
	local t = g_msgHandlerInst:convertBufferToTable("DailyTargetStateChangeProtocol", buff ) 
	-- body
	local taskid = t.taskID
	local state = t.targetState

	DATA_Mission:changeKeyValue( "KillNum" , state[1] )
end

--采集任务，客户端向后端发送数据
function MissionNetMsg:sendCollectTask( roleID, goodsId )
	g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_PICK_UP, "PickUpProtocol", { matID = goodsId } )
end

function MissionNetMsg:recvTaskUpStar( buff )
	--任务奖励升星成功
	DATA_Mission:changeEveryStar( 2 )
	TIPS( { type = 1 , str = game.getStrByKey( "task_up_tip" ) } )
end

--点击镖师返回
function MissionNetMsg:recvBodyguard( luaBuffer )

	local t = g_msgHandlerInst:convertBufferToTable("DartClickRetProtocol", luaBuffer ) 

	local tempData = {}
	tempData.dart_state = t.state --是否满足镖车条件（0：否，1：是，2：已完成镖车,3：正在镖车 4:镖车倒计时中 ）
	tempData.modeid = t.rewardType  --道具类型（ 0 无效数据 1青铜 2白银 3黄金 ）
	tempData.level = t.level  --参与等级
	tempData.selfTeamID = t.teamID  --自已的队伍ID（没有组队时为0）
	tempData.runNum = t.count  --运镖次数

	local num = t.teamNum  --队伍个数
	local teamData = t.teamData
	tempData.teamList = {}
	for i = 1 , num do
		tempData.teamList[i] = {}
		tempData.teamList[i]["teamID"] = teamData[i].teamID  --队伍ID
		tempData.teamList[i]["teamMax"] = teamData[i].maxCnt  --队伍可容纳人数
		tempData.teamList[i]["teamNum"] = teamData[i].realCnt  --队伍实际人数
		tempData.teamList[i]["teamName"] = teamData[i].name  --队伍所有者的名字
	end
	if __TASK.isClickBtn then
		__TASK.isClickBtn = nil 		--主动请求
		__GotoTarget( { ru = "a16" , data = tempData } )
	else
	 	if __BODYGUARD ~= nil then
			__BODYGUARD.upDataFun( tempData )
		end
	end


end

------------------------新悬赏任务---------------------------------------------

-- 发布新悬赏任务, 请求服务器数据
--[[
if actionType == 0 then --发布悬赏任务 param1 = taskrank 0-蓝色 1-紫色
		self:create(roleSid, param1)
	elseif actionType == 1 then --查询自己可接悬赏任务 param1 = taskrank param2 = start(default = 0，一次默认返回max 50条)
		g_RewardTaskMgr:select(roleSid, param1)
	elseif actionType == 2 then --自己接取悬赏任务 param1 = taskGUID param2 = taskID
		g_RewardTaskMgr:receive(roleSid, param1, param2)
	elseif actionType == 3 then --完成自己今天接取的一个悬赏任务 无需参数
		g_RewardTaskMgr:finish(roleSid)
	elseif actionType == 4 then --删除自己发布的悬赏任务 param1 = taskGUID
		g_RewardTaskMgr:delete(roleSid, param1)
	elseif actionType == 5 then --获取自己发布的悬赏任务列表[数量不多] 无需参数
		g_RewardTaskMgr:GetOwnerRewardTask(roleSid)
    elseif actionType == 6 then --放弃自己今天接取的一个悬赏任务 无需参数
	else
		print("悬赏任务非法操作类型")
	end
]]
function MissionNetMsg:SendRewardTaskReq(actionType, param1, param2)
    local t = {};
    t.actionType = actionType;
    t.param1 = param1;
    t.param2 = param2;
    g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_REWARDTASK_REQ, "RewardTaskReq", t);
end

-- 自己接取的新悬赏任务状态改变
function MissionNetMsg:RecvRewardTargetStatusChange(buff)
    if buff == nil then return end
    local t = g_msgHandlerInst:convertBufferToTable("RewardTaskStateChange", buff)

    local taskid = t.taskID;
    local num = t.targetNum;
    local state = {};
    for i=1, num do
        state[i] = t.targetStateDatas[i];
    end

    DATA_Mission:UpdateRewardStatus( taskid , state );
end

-- 完成自己接取的一个新悬赏任务
function MissionNetMsg:RecvFinishRewardTask(buff)
    if buff == nil then return end
    local t = g_msgHandlerInst:convertBufferToTable("FinishRewardTaskRet", buff)
    
    local state = t.actionType;         -- 完成0， 放弃1

    if state == 0 then
        __TASK:playTaskEffect(2)
	    AudioEnginer.playEffect("sounds/uiMusic/ui_complete.mp3",false)
    end
    
    DATA_Mission:FinishRewardTask( state );
end

-- 自己当前接取的一个新悬赏任务
function MissionNetMsg:RecvAddRewardTask(buff)
    if buff == nil then return end
    local t = g_msgHandlerInst:convertBufferToTable("AddRewardTaskRet", buff)

    local tmpData = {};

    tmpData["id"] = t.taskID;                           -- 任务ID
    tmpData["isNew"] = t.isNew                          --1接取任务，0表示已经接取
    tmpData["taskguid"] = t.taskGUID;                   --任务guid
    tmpData["guardExpiredTime"] = t.guardExpiredTime;   -- 独占剩余s，0表示不独占

    local tmpNum = t.targetNum;                         -- 任务目标的数量
    tmpData["targetState"] = {};                        -- 任务目标的状态值表
    for i=1, tmpNum do
        tmpData["targetState"][i] = t.targetStates[i];
    end

    DATA_Mission:FormatHadRewardTask(tmpData);
end

-- 收到服务器返回的当前自己发布的新悬赏任务[一天可发布多个]
function MissionNetMsg:RecvSelfRewardTask(buff)
    if buff == nil then return end
    local t = g_msgHandlerInst:convertBufferToTable("OwnerRewardTaskRet", buff);

    local rewardTaskData = {};

    rewardTaskData.pubNum = t.remainAnnRewardTaskNum; -- 今天剩余的可发布次数
    rewardTaskData.pubExtreNum = t.remainAnnSuperRewardTaskNum; -- 今天剩余的至尊悬赏可发布次数

    local taskNum = t.taskNum
    rewardTaskData.taskList = {};
    for i=1, taskNum do
        rewardTaskData.taskList[i] = {};
        rewardTaskData.taskList[i].taskguid = t.tasks[i].taskGUID;               -- 唯一ID
        rewardTaskData.taskList[i].expiretime = t.tasks[i].expireTime;             -- 过期时间(sec)
        rewardTaskData.taskList[i].status = t.tasks[i].taskStatus;                 -- 状态 [0 未完成, 1 完成, 需另判断是否过期状态]
        rewardTaskData.taskList[i].taskrank = t.tasks[i].taskRank;               -- 1 蓝色, 2 紫色
        rewardTaskData.taskList[i].taskid = t.tasks[i].taskID;                 -- 任务ID
    end

    DATA_Mission:FormatRewardTaskData(rewardTaskData)
end

-- 收到服务器返回可接取新悬赏任务数据
function MissionNetMsg:RecvAcceptableRewardTask(buff)
    if buff == nil then return end
    local t = g_msgHandlerInst:convertBufferToTable("SelectRewardTaskRet", buff);
    
    if t.status == 1 then
        --刷新界面回调
        DATA_Mission:RefreshAcceptRewardTasks()
        return
    end

    local acceptableData = {};

    acceptableData.blueLeftNum = t.remainAccBlueRewardTaskNum;  -- 返回查询的对应颜色任务剩余可接取
    acceptableData.purpleLeftNum = t.RemainAccPurpleRewardTaskNum;
    acceptableData.extremeLeftNum = t.remainAccSuperRewardTaskNum;

    local taskNum = t.taskNum;

    local tmpStr = "";
    local path = getDownloadDir() .. "rewardTask_" .. tostring(userInfo.currRoleStaticId) .. ".txt";
    local file = io.open(path, "w");
    if file ~= nil then
        tmpStr = t.remainAccBlueRewardTaskNum .. "," .. t.RemainAccPurpleRewardTaskNum .. "," .. t.remainAccSuperRewardTaskNum .. "," .. taskNum;
        file:write(tmpStr);
        file:write("\n");
    end

    acceptableData.taskList = {};
    local isBlue = nil;
    for i=1, taskNum do
        acceptableData.taskList[i] = {};
        acceptableData.taskList[i].taskguid = t.rewardTasks[i].taskGUID;               -- 唯一ID
        acceptableData.taskList[i].ownername = t.rewardTasks[i].ownerName;           -- 发布者名字
        acceptableData.taskList[i].expiretime = t.rewardTasks[i].expireTime;             -- 过期时间(到期时的秒数)
        acceptableData.taskList[i].taskrank = t.rewardTasks[i].taskRank;               -- 1 蓝色, 2 紫色, 3 至尊
        acceptableData.taskList[i].taskid = t.rewardTasks[i].taskID;                 -- 任务ID
        acceptableData.taskList[i].receiveNum = t.rewardTasks[i].receiveNum;                 -- 任务被接取次数
        acceptableData.taskList[i].newTag = t.rewardTasks[i].newTag;                -- 1. new 标记

        if file ~= nil then
            tmpStr = t.rewardTasks[i].taskGUID .. "," .. t.rewardTasks[i].ownerName .. "," .. t.rewardTasks[i].expireTime .. "," .. t.rewardTasks[i].taskRank .. "," .. t.rewardTasks[i].taskID .. "," .. t.rewardTasks[i].receiveNum;
            file:write(tmpStr);
            file:write("\n");
        end
    end

    if file ~= nil then
        io.close(file);
    end
    
    DATA_Mission:FormatAcceptRewardTasks(acceptableData)
end

---------------------------------------------------------------------------------

-- 增加一个密令任务
function MissionNetMsg:addBranchTask( luaBuffer )	
	local t = g_msgHandlerInst:convertBufferToTable("AddBranchProtocol", luaBuffer )

	local branchTab = {}
	branchTab["id"] = t.taskID 		--任务的ID 
	branchTab["isAdd"] = true
	branchTab["targetState"] = t.targetState

	DATA_Mission:upBranchData( branchTab )
	
end
--密令状态变化
function MissionNetMsg:branchChange( luaBuffer )
	local t = g_msgHandlerInst:convertBufferToTable("BranchTargetStateChangeProtocol", luaBuffer )

	__TASK.branchFindPath = true
	local branchTab = {}
	branchTab["id"] = t.taskID 		--任务的ID 
	branchTab["targetState"] = t.targetState

	DATA_Mission:upBranchData( branchTab )
	local curData = nil
	local tempData = getConfigItemByKeys( "BranchDB" , "q_taskid" )[ t.taskID ] 
	if DATA_Mission:chechWing( tempData ) == 1  then
		curData = DATA_Mission:getLastBranch("branch")
	else
		curData = DATA_Mission:getLastBranch("wing")
	end
	if curData and ( curData.targetType == 3 or curData.targetType == 2 ) then
		__TASK:showTip( curData )
	end
end
--完成密令任务
function MissionNetMsg:finishBranch( luaBuffer )
	local t = g_msgHandlerInst:convertBufferToTable("FinishBranchProtocol", luaBuffer )
	__TASK.branchFindPath = true
	local id = t.taskID

	DATA_Mission:upBranchData( { isFinished = true , id = id } )

end

--拉取完成的密令任务结果返回
function MissionNetMsg:historyBranch( luaBuffer )
	local t = g_msgHandlerInst:convertBufferToTable("GetFinishBranchRetProtocol", luaBuffer )
	__TASK.branchFindPath = true
	local taskNum = #t.taskID 		--完成任务个数 
	for i = 1 , taskNum do
		local id = t.taskID[i]
		DATA_Mission:upBranchData( { isComplete = true , id = id } )
	end

end



-----------------------------------------------------------
-- 共享任务

-- 转发共享任务
function MissionNetMsg:RecvShareTaskTransmit(luaBuffer)
    if DATA_Mission.m_isRecvShareTask then
        return;
    else
        DATA_Mission.m_isRecvShareTask = true;
    end

	local t = g_msgHandlerInst:convertBufferToTable("ShareTaskRetProtocol", luaBuffer)
	local roleId = t.roleId
	local taskId = t.taskId
	local roleName = t.name

	cclog("[MissionNetMsg:RecvShareTaskTransmit] roleId = %s, taskId = %s, roleName = %s.", roleId, taskId, roleName)

	local funcAccept = function()
		local MainRoleId = 0
		if userInfo then
			MainRoleId = userInfo.currRoleId
		end
		local ts = {}
		ts.taskId = taskId
		ts.sRoleId = roleId
		ts.result = 1
		g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_CONFIRM_SHARE_TASK, "ConfirmShareTaskProtocol", ts)
		cclog("[TASK_CS_CONFIRM_SHARE_TASK] sent. role_id = %s, task_id = %s, target_role_id = %s, value = 1.", MainRoleId, taskId, roleId)

        DATA_Mission.m_isRecvShareTask = false;
	end

	local funcDecline = function()
		local MainRoleId = 0
		if userInfo then
			MainRoleId = userInfo.currRoleId
		end
		local ts = {}
		ts.taskId = taskId
		ts.sRoleId = roleId
		ts.result = 0
		g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_CONFIRM_SHARE_TASK, "ConfirmShareTaskProtocol", ts)
		cclog("[TASK_CS_CONFIRM_SHARE_TASK] sent. role_id = %s, task_id = %s, target_role_id = %s, value = 0.", MainRoleId, taskId, roleId)

        DATA_Mission.m_isRecvShareTask = false;
	end

	local taskName = ""
	local taskdb_item = getConfigItemByKey("SharedTaskDB", "q_taskid", taskId);
	if taskdb_item then
		taskName = taskdb_item.q_name
	end
    
	local text_hint = string.format(game.getStrByKey("share_task_hint"), roleName, taskName)
	MessageBoxYesNo(nil, text_hint, funcAccept, funcDecline)
end

-- 领取共享任务奖励
function MissionNetMsg:RecvShareTaskPrize(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("GetSharedTaskPrizeRetProtocol", luaBuffer)
	local roleId = t.roleId
	local result = t.errCode
	local count_cur = t.sharedTaskPrizeNum
	local count_max = t.allPrizeNum

	cclog("[MissionNetMsg:RecvShareTaskPrize] roleId = %s, result = %s, count_cur = %s, count_max = %s.", roleId, result, count_cur, count_max)

	if result == -1 then
		TIPS(getConfigItemByKeys("clientmsg", {"sth","mid"}, {6000,-82}))
	elseif result == -2 then
		TIPS(getConfigItemByKeys("clientmsg", {"sth","mid"}, {6000,-81}))
	elseif result == -3 then
		TIPS(getConfigItemByKeys("clientmsg", {"sth","mid"}, {6000,-83}))
	end

	----------------------------------------------------------

	if count_cur == count_max then
		if DATA_Battle then
			DATA_Battle:setRedData("teamTreasure", false, false)
		end

--		if G_MAINSCENE then
--			G_MAINSCENE:removeActivityIconData({btnResName = "res/mainui/subbtns/teamTreasure.png",})
--		end
	end
end

-- 开始共享任务
function MissionNetMsg:RecvShareTaskBegin(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("AddSharedTaskProtocol", luaBuffer)
	local task_id = t.taskId		-- 任务ID
	if task_id == 0 then
        local data = DATA_Mission:getShareData();
        if data then
            if data.flag == 0 then
                performWithDelay(getRunScene(), function()
                        -- TIPS{type=1, str=game.getStrByKey("treasure_deltask")};
                        if __TASK then
							__TASK:popupLayout("branch")
						end
                    end, 1);
            end
        end
		DATA_Mission:deleteShareData(0)
		cclog("[MissionNetMsg:RecvShareTaskBegin] taskId = 0.")
		return
	end

	local task_flag = t.taskOwner			-- 任务标记
	local num = t.taskNum					-- 任务目标数量

	local shareTab = {}
	shareTab["id"] = task_id
	shareTab["flag"] = task_flag
	shareTab["targetState"] = {}
	for i = 1, num do
		shareTab["targetState"][i] = t.taskState[i]	-- 任务目标的状态值表
	end

	cclog("t.taskTargetPos",t.taskTargetPos)
	shareTab["taskTargetPos"] = unserialize(t.taskTargetPos)
	DATA_Mission:setShareData(shareTab)

	cclog("[MissionNetMsg:RecvShareTaskBegin] taskId = %s, taskFlag = %s, targetCount = %s.", task_id, task_flag, num)
end

-- 完成共享任务
function MissionNetMsg:RecvShareTaskFinish(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("FinishSharedTaskProtocol", luaBuffer)
	local taskId = t.taskId			-- 完成任务ID

	cclog("[MissionNetMsg:RecvShareTaskFinish] taskId = %s.", taskId)

	DATA_Mission:deleteShareData(taskId)
end

-- 更新共享任务
function MissionNetMsg:RecvShareTaskUpdate(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("SharedTargetStateChangeProtocol", luaBuffer)
	local taskId = t.taskId			-- 任务ID
	local num = t.taskNum
	local state = {}
	for i = 1, num do
		state[i] = t.taskStates[i]
	end

	DATA_Mission:updateShareData(taskId, state)

	cclog("[MissionNetMsg:RecvShareTaskUpdate] taskId = %s, taskCount = %s.", taskId, num)
end

function MissionNetMsg:RecvShareTaskGetTask(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("AfterGetSharedTaskProtocol", luaBuffer)
	local roleId = t.roleId

	cclog("[MissionNetMsg:RecvShareTaskGetTask] role_id = %s.", roleId)

	if __TASK then
		__TASK:popupLayout("share")
	end

end

function MissionNetMsg:RecvShareTaskGetTaskTimes(luaBuffer)
	local t = g_msgHandlerInst:convertBufferToTable("GetSharedTaskTimesRetProtocol", luaBuffer)
	local count_cur = t.remainNum
	local count_max = t.allNum

	log("[RecvShareTaskGetTaskTimes] received. count_cur = %s, count_max = %s.", count_cur, count_max)

	DATA_Mission:setShareData_Times(count_cur, count_max)
end

-----------------------------------------------------------



return MissionNetMsg