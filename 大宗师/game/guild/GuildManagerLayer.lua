--[[
 --
 -- add by vicky
 -- 2015.01.06 
 --
 --]]

 local data_config_union_config_union = require("data.data_config_union_config_union") 
 require("data.data_error_error") 
 local data_ui_ui = require("data.data_ui_ui") 

 local MAX_ZORDER = 100 

 local GuildManagerLayer = class("GuildManagerLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 -- 修改帮派宣言  
 local function modifyManifesto(text, node)
    RequestHelper.Guild.modify({
        text = text, 
        type = 1, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
            else
                if data.rtnObj.success == 0 then 
                    show_tip_label(data_error_error[2900043].prompt) 
                    
                    -- 修改本地存储的帮派宣言   
                    game.player:getGuildMgr():getGuildInfo().m_unionOutdes = text 

                    node:removeFromParentAndCleanup(true) 
                end 
            end 
        end 
        })
 end 


 -- 自荐帮主 
 local function zijian(node) 
    RequestHelper.Guild.zijian({
        leaderId = game.player:getGuildMgr():getGuildInfo().m_bossId, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                node:setBtnEnabled(true) 
            else 
                local rtnObj = data.rtnObj 
                game.player:getGuildMgr():setCoverVo(rtnObj) 
                PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN) 
                node:removeFromParentAndCleanup(true) 

                -- 成功开启自荐提示
                game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                        title = "提示", 
                        msg = data_ui_ui[6].content, 
                        isSingleBtn = true, 
                        confirmFunc = function(msgBox) 
                            msgBox:removeFromParentAndCleanup(true) 
                        end 
                    }), MAX_ZORDER) 
            end 
        end, 
        errback = function(data)
            node:removeFromParentAndCleanup(true)  
        end
        })
 end 


 -- 禅让帮主  
 local function reqDemise(node) 
    RequestHelper.Guild.demise({ 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                node:setBtnEnabled(true) 
            else 
                if data.rtnObj.success == 0 then 
                    -- 更改职位 
                    game.player:getGuildMgr():setJopType(GUILD_JOB_TYPE.normal) 
            
                    -- 根据不同的界面，刷新不同的界面(帮派主界面、帮派列表、帮派成员、帮派大殿、帮派动态、帮派商店) 
                    if GameStateManager.currentState == GAME_STATE.STATE_GUILD_MAINSCENE or 
                        GameStateManager.currentState == GAME_STATE.STATE_GUILD_GUILDLIST or 
                        GameStateManager.currentState == GAME_STATE.STATE_GUILD_ALLMEMBER or 
                        GameStateManager.currentState == GAME_STATE.STATE_GUILD_VERIFY or
                        GameStateManager.currentState == GAME_STATE.STATE_GUILD_DADIAN or 
                        GameStateManager.currentState == GAME_STATE.STATE_GUILD_DYNAMIC then 

                        GameStateManager:setState(GameStateManager.currentState) 
                    else
                        
                    end 
                end 

                node:removeFromParentAndCleanup(true)  
            end 
        end, 
        errback = function(data)
            node:removeFromParentAndCleanup(true)  
        end
        })
 end 


 function GuildManagerLayer:ctor() 
 	local proxy = CCBProxy:create()
 	local rootnode = {}
    local ccbiName = "guild/guild_manager_leader.ccbi" 
    local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType  
    if jopType ~= GUILD_JOB_TYPE.leader then 
        ccbiName = "guild/guild_manager_normal.ccbi" 
    end 

 	local node = CCBuilderReaderLoad(ccbiName, proxy, rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	rootnode["titleLabel"]:setString("帮派功能")  

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        closeFunc() 
    end, CCControlEventTouchUpInside)

    if rootnode["zijian_btn"] ~= nil then 
        if game.player:getAppOpenData().zijianbangzhu == APPOPEN_STATE.close then 
            rootnode["zijian_btn"]:setVisible(false) 
        else
            rootnode["zijian_btn"]:setVisible(true)  
        end
    end    

    -- 成员审核、自荐帮主、修改宣言、禅让帮主 
    local tags = {"verify_btn", "zijian_btn", "modify_btn", "demise_btn"} 

    local function onTouchBtn(tag) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if tag == tags[1] then 
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_VERIFY) 

        elseif tag == tags[2] then 
            show_tip_label(data_error_error[2800001].prompt) 
            -- -- 自荐帮主
            -- game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
            --         title = "提示", 
            --         msg = data_ui_ui[5].content, 
            --         isSingleBtn = false, 
            --         confirmFunc = function(node) 
            --             zijian(node) 
            --         end 
            --     }), MAX_ZORDER) 
            -- self:removeFromParentAndCleanup(true) 

        elseif tag == tags[3] then 
            -- 修改帮派宣言  
            game.runningScene:addChild(require("game.guild.GuildModifyMsgBox").new({
                    title = "帮派宣言", 
                    text = game.player:getGuildMgr():getGuildInfo().m_unionOutdes, 
                    msgMaxLen = data_config_union_config_union[1]["guild_manifesto_max_length"], 
                    confirmFunc = function(text, node)
                        modifyManifesto(text, node)  
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 

        elseif tag == tags[4] then 
            -- 禅让帮主 
            game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    msg = data_ui_ui[4].content, 
                    isSingleBtn = false, 
                    confirmFunc = function(node) 
                        reqDemise(node) 
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 
        end 

    end 

    for i, v in ipairs(tags) do 
        if rootnode[v] ~= nil then 
            rootnode[v]:addHandleOfControlEvent(function(eventName, sender)
                onTouchBtn(v) 
            end, CCControlEventTouchUpInside) 
        end 
    end 

 end 


 return GuildManagerLayer  
