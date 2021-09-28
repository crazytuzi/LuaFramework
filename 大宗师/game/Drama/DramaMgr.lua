local DramaMgr = {}


local TUTO_TAG = 10000
local SHOW_DRAMA = true
--新手引导表 等松鹏那边完事后可生成
local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
--剧情表 等松鹏那边完事后 可生成
local data_drama_drama = require("data.data_drama_drama")

local data_field_field = require("data.data_field_field")
local data_world_world = require("data.data_world_world")

--这个值用来存储当前数组
local dramaValueData 
local dramaFieldData = nil 
local dramaWorldData

function DramaMgr.runDramaBefWorld(bigMapId,endFunc)
    
    if SHOW_DRAMA then
        RequestHelper.getDramaValue({
            callback = function (data)
            dramaValueData = data["1"]            
            local num = dramaValueData[1]
            
            if num < bigMapId then
                dramaValueData[1] = bigMapId
                RequestHelper.setDramaValue({
                    param = dramaValueData,
                    callback = function()
                        dramaWorldData = data_world_world[bigMapId]
                        local fieldDramaTable = dramaWorldData.arr_drama
                        DramaMgr.dramaMachine(1, fieldDramaTable, endFunc)
                    end})           
            else
                endFunc()
            end

            end})
    else
        endFunc()
    end
   
end

function DramaMgr.runDramaBefSub(submapID,endFunc)	
	-- 
    if SHOW_DRAMA then
    	RequestHelper.getDramaValue({
    		callback = function (data)
    		dramaValueData = data["1"]
    		local num = dramaValueData[2]
    		if num < submapID then
    			dramaValueData[2] = submapID
    			RequestHelper.setDramaValue({
    				param = dramaValueData,
    				callback = function()
    					dramaFieldData = data_field_field[submapID]
    					local fieldDramaTable = dramaFieldData.arr_drama
    					DramaMgr.dramaMachine(1, fieldDramaTable, endFunc)
    				end})			
    		else
    			endFunc()
    		end
    		end})
	else
        endFunc()
    end
end

function DramaMgr.runDramaBefNpc(npcData,endFunc)

     if SHOW_DRAMA then
         RequestHelper.getDramaValue({
        		callback = function (data)
        		print("cb data")
        		dump(data)
        		dramaValueData = data["1"]
        		local serNpcValue = dramaValueData[3] --服务器的剧情值
    		    local curNpcValue = npcData.id  --当前关卡的剧情值 

    		    if SHOW_DRAMA and curNpcValue > serNpcValue then
    		        dramaFieldData = data_field_field[npcData.field]

    		    	local arr_battle = dramaFieldData.arr_battle
    		        local arr_npc_drama = dramaFieldData.arr_npc_drama

    		        if arr_battle ~= nil and type(arr_battle) == "table" and #arr_battle > 0 then
    		            local curIndex = 0
    		            for i  = 1,#arr_battle do
    		                if arr_battle[i] == curNpcValue then
    		                    curIndex = i
    		                    break
    		                end
    		            end
    		            local activeDrama 
    		            if curIndex ~= 0 and arr_npc_drama ~= nil and curIndex <= #arr_npc_drama and arr_npc_drama[curIndex] ~= 0 then
    		            	--发送设置请求
    		                dramaValueData[3] =curNpcValue
    		                RequestHelper.setDramaValue({
    		                    param = dramaValueData,
    		                    callback = function()
    		                        local npcDramaTable = arr_npc_drama[curIndex] 
    		                        DramaMgr.dramaMachine(1, npcDramaTable, endFunc)
    		                    end})   
    		    		else
    		    			endFunc()
    		            end

    		        else
    		    	  
    		    	   endFunc()
    		        end
    		    else
    		        endFunc()
    		    end
    	end})
    else
        endFunc()
    end
end

DramaMgr.isSkipDrama = false

function DramaMgr.dramaEndLogin()
    local isNewUser = 1
    local nameBg = require("game.login.ChoosePlayerNameLayer").new(function()
        DramaMgr.request(isNewUser)
    end)
    game.runningScene:addChild(nameBg, 1000)
end

function DramaMgr.createChoseLayer(data)
	local function dramaEndStartLogin()
        -- if DramaMgr.isSkipDrama == false then
        --     DramaMgr.isSkipDrama = true
            DramaMgr.dramaEndLogin()
        -- end
    end

    if SHOW_DRAMA then
        local msg = {}
        msg.dramaSceneId = 1
        msg.battleData = data["6"]
        msg.nextFunc = dramaEndStartLogin
        GameStateManager:ChangeState(GAME_STATE.DRAMA_SCENE,msg)
    else
        dramaEndStartLogin()
    end

end

function DramaMgr.dramaMachine(index, dramaTable, dramaEndFunc)
		if dramaTable ~= nil and index <= #dramaTable then

		local finFunc = function()
			return DramaMgr.dramaMachine(index+1, dramaTable, dramaEndFunc)
		end

		local activeId = dramaTable[index]

		local dramaLayer = require("game.Tutorial.DramaLayer").new(activeId,finFunc)
		game.runningScene:addChild(dramaLayer,DRAMA_ZORDER)
	else		
		dramaEndFunc()
	end
end

function DramaMgr.request(isNew, data)
	--警告,此函数是从 LoginScene里整体考进来的，要改俩一起改
	 SDKGameWorks.GameUpGrade(game.player.m_level, game.player.m_uid, "1", "1")
    local function requestOnlineReward( ... )
        local reqs = {}
        local RequestInfo = require("network.RequestInfo")

        --请求在线奖励
        table.insert(reqs, RequestInfo.new({
            modulename = "onlineReward",
            funcname   = "list",
            param      = {},
            oklistener = function(data)

                dump(data)
                if #data["0"] > 0 then
                    device.showAlert("Server Data Error",data["0"])
                else
                    game.player.m_onlineRewardTime = data["3"]
                    game.player.m_isShowOnlineReward = data["4"]
                end
            end
        }))
        RequestHelperV2.request2(reqs, function()
            TutoMgr.getServerNum(function(plotNum)
                if plotNum == 0  and game.player.m_level == 1 then
                   
                    --leve 110101 grade 1 star 1
                    -- plotNum = 30
                    GameStateManager:ChangeState(GAME_STATE.STATE_NORMAL_BATTLE,{levelData = {id = 110101},grade = 1,star = 0})
                else
                    
                    if plotNum == 0 then
                        --剧情值为0 且玩家级别不为1，则证明玩家已经打过第一场战斗了
                        plotNum = 40
                        TutoMgr.setServerNum({setNum = 40})
                        
                    end
                    local msg = {}
                    msg.showNote = true
                    GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU, msg)
                end
            end)

        end)
    end
    --从服务器获取玩家信息，进入游戏
    local function initGame(baseData)
        game.player:init(baseData)
        SDKTKData.setBaseInfo({accountId = game.player.m_uid ,accountName = game.player.m_name, level = game.player.m_level, gameServer = game.player.m_serverID})
        requestOnlineReward()
    end

    if( isNew == 1) then
        RequestHelper.game.loginGame({
            sessionId  = game.player.m_sessionID,
            uin        = game.player.m_uid,
            platformID = game.player.m_platformID,
            callback = function(data)
                if(data and data["0"] == "") then
                    if(data["4"] ~= nil and data["4"] ~= "") then
                        game.player.m_serverKey = data["4"]
                    end
                    initGame(data["1"])
                    game.player.m_gamenote = data["2"]
                    CSDKShell.submitExtData({
                        isNewUser = true
                    })
                else
                    show_tip_label("服务器异常，稍后重试")
                end
            end,
        })
        -- end
    else
        initGame(data["1"])
        game.player.m_gamenote = data["2"]
        CSDKShell.submitExtData({
            isNewUser = false
        })
        -- requestOnlineReward()
    end
end






return DramaMgr