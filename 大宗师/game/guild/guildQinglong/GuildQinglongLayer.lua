--[[
 --
 -- add by vicky
 -- 2015.01.22  
 --
 --]]

 local data_error_error = require("data.data_error_error") 
 local data_ui_ui = require("data.data_ui_ui") 
 local data_boss_qinglong_boss_qinglong = require("data.data_boss_qinglong_boss_qinglong")

 local MAX_ZORDER = 110  


 local GuildQinglongLayer = class("GuildQinglongLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)

 
 -- 建筑升级
 function GuildQinglongLayer:reqLevelup(msgBox) 
    levelupBtn = self._rootnode["levelup_btn"] 

    RequestHelper.Guild.unionLevelUp({
        unionid = game.player:getGuildMgr():getGuildInfo().m_id, 
        buildtype = self._buildType, 
        errback = function(data)
            levelupBtn:setEnabled(true) 
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            dump(data, "建筑升级", 8)  
            if data.err ~= "" then 
                dump(data.err) 
                levelupBtn:setEnabled(true) 
                msgBox:setBtnEnabled(true)
            else 
                ResMgr.showErr(2900083) 
            	local rtnObj = data.rtnObj 
                msgBox:removeFromParentAndCleanup(true) 
                self:updateLevel(rtnObj.buildLevel, rtnObj.currentUnionMoney) 
                self:checkBtnState(self._level, self._curState) 
                
                game.player:getGuildInfo():updateData({qinglongLevel = rtnObj.buildLevel, currentUnionMoney = rtnObj.currentUnionMoney}) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL) 

                levelupBtn:setEnabled(true) 
            end
        end
    })
 end 


 -- 请求开启挑战 
 function GuildQinglongLayer:reqOpen()
 	local openBtn = self._rootnode["open_btn"] 
 	RequestHelper.Guild.bossCreate({
        unionId = game.player:getGuildMgr():getGuildInfo().m_id, 
        errback = function(data)
            openBtn:setEnabled(true) 
        end, 
        callback = function(data) 
            dump(data, "开启", 8)  
            if data.err ~= "" then 
                dump(data.err) 
                openBtn:setEnabled(true) 
            else 
            	local rtnObj = data.rtnObj 

            	self:updateLevel(self._level, rtnObj.curUnionMoney) 
            	game.player:getGuildInfo():updateData({currentUnionMoney = rtnObj.curUnionMoney}) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA) 

                -- result:1/2	结果 【1-成功开启 2-已被别人开启，可直接进入】
                if rtnObj.result == 1 or rtnObj.result == 2 then 
	                GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, true)  
	            else
	            	openBtn:setEnabled(true) 
	            	show_tip_label("服务器端返回的开启resulte不对：" .. rtnObj.result) 
	            end 
            end
        end
    })
 end 


 function GuildQinglongLayer:ctor(data) 
 	dump(data, "青龙", 6) 
 	local rtnObj = data.rtnObj 
 	self._curState = rtnObj.state 
 	self._openCostCoin = rtnObj.createBossCost  
    self._bossLevel = rtnObj.dragonLevel 
 	self._buildType = GUILD_BUILD_TYPE.qinglong   

 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_qinglong_layer.ccbi", proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2) 
 	self:addChild(node) 

 	self._rootnode["titleLabel"]:setString("青龙堂") 
    self._rootnode["top_msg_lbl"]:setString(data_ui_ui[13].content) 

    self:createShadowLbl(tostring(self._bossLevel), ccc3(0, 219, 52), self._rootnode["boss_level_lbl"], 20) 

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true) 
        end,CCControlEventTouchUpInside) 


    local guildMgr = game.player:getGuildMgr() 
    local guildInfo = guildMgr:getGuildInfo() 

    self:updateLevel(rtnObj.templeLevel, rtnObj.curUnionMoney) 
    self:createAllLbl() 
    self:checkBtnState(self._level, self._curState) 

    -- 升级、开启挑战 按钮 
    local jopType = guildInfo.m_jopType 
    local levelupBtn = self._rootnode["levelup_btn"] 
    local openBtn = self._rootnode["open_btn"] 

    if jopType == GUILD_JOB_TYPE.leader or jopType == GUILD_JOB_TYPE.assistant then 
        levelupBtn:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then 
                show_tip_label(data_error_error[2900021].prompt) 
            else 
                levelupBtn:setEnabled(false) 
                local msgBox = require("game.guild.GuildBuildLevelUpMsgBox").new({
                    curLevel = self._level, 
                    toLevel = self._level + 1, 
                    needCoin = self._needCoin, 
                    curCoin = self._currentUnionMoney, 
                    buildType = self._buildType, 
                    cancelFunc = function()
                        levelupBtn:setEnabled(true)  
                    end,
                    confirmFunc = function(msgBox)
                        self:reqLevelup(msgBox) 
                    end 
                    })
                game.runningScene:addChild(msgBox, MAX_ZORDER) 
            end 
        end,CCControlEventTouchUpInside) 

        openBtn:addHandleOfControlEvent(function(eventName, sender)
        	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        	if self._currentUnionMoney < self._openCostCoin then 
        		show_tip_label(data_error_error[2900035].prompt) 
        	else 
        		openBtn:setEnabled(false) 
        		self:reqOpen() 
        	end 
        end, CCControlEventTouchUpInside)
    end 

    local shuchuBtn = self._rootnode["shuchuBtn"]
    local extraRewardBtn = self._rootnode["extraRewardBtn"] 
    -- 输出排行 
  	shuchuBtn:addHandleOfControlEvent(function(eventName, sender)
  			shuchuBtn:setEnabled(false) 
        	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        	local function toLayer(data) 
        		local layer = require("game.guild.guildQinglong.GuildQLBossRankLayer").new({
	        			topPlayers = data.rtnObj.topPlayers, 
	        			confirmFunc = function()
	        				shuchuBtn:setEnabled(true) 
		        		end 
        			})
        		game.runningScene:addChild(layer, MAX_ZORDER)
        	end 
        	guildMgr:RequestBossRank(toLayer, function() shuchuBtn:setEnabled(true) end )  

        end, CCControlEventTouchUpInside)

  	-- 奖励预览 
  	extraRewardBtn:addHandleOfControlEvent(function(eventName, sender)
            extraRewardBtn:setEnabled(false) 
        	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            local function confirmFunc()
                extraRewardBtn:setEnabled(true)
            end 
            
            self:addChild(require("game.Worldboss.WorldBossExtraRewardLayer").new({
                rewardListData = data_boss_qinglong_boss_qinglong, 
                confirmFunc = confirmFunc, 
                level = self._bossLevel, 
                isGuildBoss = true
                }), MAX_ZORDER)

        end, CCControlEventTouchUpInside) 

 end 


 -- 检测按钮显示状态 
 function GuildQinglongLayer:checkBtnState(level, state) 
    local guildMgr = game.player:getGuildMgr() 
    local guildInfo = guildMgr:getGuildInfo() 
    local jopType = guildInfo.m_jopType 

    local levelupBtn = self._rootnode["levelup_btn"] 
    local openBtn = self._rootnode["open_btn"] 
    local openNode = self._rootnode["open_node"] 
    local notOpenNode = self._rootnode["open_need_node"] 

    if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then 
        levelupBtn:setVisible(false) 
        openBtn:setVisible(false) 
        if level <= 0 then 
            openNode:setVisible(false) 
            notOpenNode:setVisible(true) 
        else
            openNode:setVisible(true) 
            notOpenNode:setVisible(false) 
        end 
    else 
        levelupBtn:setVisible(true) 
        openNode:setVisible(false) 
        if level <= 0 then 
            notOpenNode:setVisible(true) 
            openBtn:setVisible(false)   
        else
            notOpenNode:setVisible(false) 
            openBtn:setVisible(true) 
            if state == GUILD_QL_CHALLENGE_STATE.hasEnd then 
                openBtn:setEnabled(false) 
            elseif state == GUILD_QL_CHALLENGE_STATE.notOpen then 
                openBtn:setEnabled(true) 
            end 
        end 
    end 
 end 


 -- 更新等级 
 function GuildQinglongLayer:updateLevel(level, currentUnionMoney) 
    local guildMgr = game.player:getGuildMgr() 
    self._level = level 
    guildMgr:getGuildInfo().m_greenDragonTempleLevel = self._level 
    self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level) 

    self._currentUnionMoney = currentUnionMoney  

    -- 当前等级 
    self:createShadowLbl("LV." .. tostring(self._level), ccc3(255, 222, 0), self._rootnode["cur_level_lbl"])

    -- 当前帮派资金 
    self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode["cur_coin_lbl"])


    self:updateNeedCoinLbl(self._needCoin) 

 end 


 function GuildQinglongLayer:updateNeedCoinLbl(needCoin)
    local str 
    if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then 
        str = "已升到最大等级" 
    else
        str = tostring(needCoin) 
    end
    self:createShadowLbl(str, FONT_COLOR.WHITE, self._rootnode["cost_coin_lbl"]) 
 end 


 function GuildQinglongLayer:createShadowLbl(text, color, node, size) 
    node:removeAllChildren() 
    local lbl = ui.newTTFLabelWithShadow({
            text = text,
            size = size or 20, 
            color = color,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        }) 

    node:addChild(lbl) 
    return lbl 
 end 


 -- 阴影描边字 
 function GuildQinglongLayer:createAllLbl() 
    local guildMgr = game.player:getGuildMgr() 
    local jopType = guildMgr:getGuildInfo().m_jopType 

    local yColor = ccc3(255, 222, 0) 

    -- 升级消耗资金 
    self:createShadowLbl("升级消耗资金:", yColor, self._rootnode["cost_coin_msg_lbl"])  
    -- 当前拥有资金 
    self:createShadowLbl("当前拥有资金:", yColor, self._rootnode["cur_coin_msg_lbl"])  
  
    -- 今日挑战状态 
    self:createShadowLbl("今日挑战状态", FONT_COLOR.WHITE, self._rootnode["state_msg_lbl"])  
    local stateStr, stateColor 
    if self._curState == GUILD_QL_CHALLENGE_STATE.notOpen then 
    	stateStr = "未挑战" 
    	stateColor = ccc3(0, 219, 52)  

    elseif self._curState == GUILD_QL_CHALLENGE_STATE.hasEnd then 
    	stateStr = "已结束" 
    	stateColor = ccc3(240, 5, 5)  
    end 

    self:createShadowLbl(stateStr, stateColor, self._rootnode["state_lbl"])  

    -- 帮主/副帮主 
	self:createShadowLbl("帮主/副帮主", yColor, self._rootnode["leader_msg_lbl"], 30) 

	-- 可开启挑战 
	self:createShadowLbl("可开启挑战", ccc3(22, 255, 255), self._rootnode["open_msg_lbl"], 24) 

    -- 1级开启建筑功能 
    local lbl = self:createShadowLbl("1级开启建筑功能", ccc3(22, 255, 255), self._rootnode["open_need_msg_lbl"], 28)  
    lbl:setPosition(-lbl:getContentSize().width/2, 0) 

 end 



 return GuildQinglongLayer 

