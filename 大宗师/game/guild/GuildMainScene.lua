--[[
 --
 -- add by vicky
 -- 2015.01.04 
 --
 --]]
require("data.data_error_error") 
 local data_config_union_config_union = require("data.data_config_union_config_union") 
 local data_feature_switch_config = require("data.data_feature_switch_config") 

 local MAX_ZORDER = 101 
 local BUILD_LEVEL_FONT_SIZE = 20  
 local CHILD_TAG = 1 


 local GuildMainScene = class("GuildMainScene", function()

    local bottomFile = "guild/guild_bottom_frame_main_normal.ccbi"  

    local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType  
    if jopType ~= GUILD_JOB_TYPE.normal then 
        bottomFile = "guild/guild_bottom_frame_main.ccbi" 
    end 

    return require("game.guild.utility.GuildBaseScene").new({
        contentFile = "guild/guild_main_scene.ccbi",
        topFile = "guild/guild_top_frame_main.ccbi",
        bottomFile = bottomFile, 
        isOther = true 
    })
 end)


 function GuildMainScene:modifyNote(text, node)
    RequestHelper.Guild.modify({
        text = text, 
        type = 0, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
            else
                if data.rtnObj.success == 0 then 
                    show_tip_label(data_error_error[2900043].prompt) 

                    self._rootnode["guild_note_lbl"]:setString(text) 
                    node:removeFromParentAndCleanup(true) 

                    -- 修改本地存储的帮派公告  
                    game.player:getGuildMgr():getGuildInfo().m_unionIndes = text 
                end 
            end 
        end 
        })
 end 


 function GuildMainScene:ctor(buildType)   
    game.runningScene = self 

    if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then 
        self._rootnode["tag_fuben"]:setVisible(true) 
    else
        self._rootnode["tag_fuben"]:setVisible(false)  
    end 
    
    local guildMgr = game.player:getGuildMgr()
    local guildInfo = guildMgr:getGuildInfo() 
    self._jopType = guildInfo.m_jopType 

    local centerH = self:getCenterHeight()  
    local scrollView = self._rootnode["tag_scrollView"] 
    local msgNodeH = self._rootnode["bottom_msg_node"]:getContentSize().height - self._rootnode["top_msg_node"]:getContentSize().height 
    -- local viewSizeH = centerH - msgNodeH 
    -- scrollView:setViewSize(CCSize(display.width, viewSizeH)) 
    scrollView:setBounceable(false)
    local scrollNodeH = self._rootnode["tag_scroll_bg"]:getContentSize().height 
    if centerH >= scrollNodeH then 
        scrollView:setTouchEnabled(false) 
    end 
    scrollView:setContentOffset(CCPointMake(0, -self._rootnode["bottom_msg_node"]:getContentSize().height), false)  

    if guildInfo.m_unionIndes ~= nil then 
        self._rootnode["guild_note_lbl"]:setString(tostring(guildInfo.m_unionIndes)) 
    else
        self._rootnode["guild_note_lbl"]:setString(data_config_union_config_union[1].guild_note_msg) 
    end 

    self:updateMsgDataLbl() 

    self._rootnode["guild_name_lbl"]:setString(tostring(guildInfo.m_name)) 
    self._rootnode["guild_level_lbl"]:setString(tostring(guildInfo.m_level)) 

    self._rootnode["guild_num_lbl_1"]:setString(tostring(guildInfo.m_nowRoleNum)) 
    self._rootnode["guild_num_lbl_2"]:setString("/" .. tostring(guildInfo.m_roleMaxNum)) 

    self._rootnode["guild_power_lbl"]:setString(tostring(guildInfo.m_sumAttack)) 

    if self._jopType == GUILD_JOB_TYPE.normal then 
        self._rootnode["modify_btn"]:setVisible(false)
    else 
        self._rootnode["modify_btn"]:setVisible(true) 
    end 

    -- 其他帮派 
    self._rootnode["check_guildList_btn"]:addHandleOfControlEvent(function(eventName, sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_GUILDLIST)
        end, CCControlEventTouchUpInside)

    -- 修改帮派公告 
    local modifyBtn = self._rootnode["modify_btn"]
    modifyBtn:addHandleOfControlEvent(function(eventName, sender)
        modifyBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:addChild(require("game.guild.GuildModifyMsgBox").new({
            title = "帮派公告", 
            text = game.player:getGuildMgr():getGuildInfo().m_unionIndes, 
            msgMaxLen = data_config_union_config_union[1]["guild_note_max_length"], 
            confirmFunc = function(text, node)
                modifyBtn:setEnabled(true) 
                self:modifyNote(text, node)  
            end, 
            cancelFunc = function()
                modifyBtn:setEnabled(true)  
            end
            }), MAX_ZORDER)             
        end, CCControlEventTouchUpInside) 

    self:initBuildLevel() 
    self:initBuildBtnFunc() 

    self._scheduler = require("framework.scheduler") 

    if buildType ~= nil then 
        self:toBuild(buildType) 
    end 
 end 


 -- 初始化建筑等级 
 function GuildMainScene:initBuildLevel() 
    local color = ccc3(255, 216, 0) 
    local shadowColor = ccc3(10,10,10) 
    local guildInfo = game.player:getGuildMgr():getGuildInfo() 

    local function createTTF(text, node)
        local lbl = ui.newTTFLabelWithOutline({
            text = "LV." .. text,
            size = BUILD_LEVEL_FONT_SIZE, 
            color = color,
            outlineColor = shadowColor,
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        }) 

        lbl:setPosition(-lbl:getContentSize().width/2, 0)
        node:addChild(lbl) 

        return lbl 
    end 

    -- 大殿
    self._dadianLvLbl = createTTF(tostring(guildInfo.m_level), self._rootnode["tag_dadian_lv_lbl"])

    -- 作坊 
    self._zuofangLvLbl = createTTF(tostring(guildInfo.m_workshoplevel), self._rootnode["tag_zuofang_lv_lbl"])

    -- 商店 
    if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then 
        self._shopLvLbl = createTTF(tostring(guildInfo.m_shoplevel), self._rootnode["tag_shop_lv_lbl"])
    end 

    -- 青龙堂  
    if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then 
        self._qinglongLvLbl = createTTF(tostring(guildInfo.m_greenDragonTempleLevel), self._rootnode["tag_qinglong_lv_lbl"]) 
    end 

    -- 帮派副本   
    if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then 
        self._fubenLvLbl = createTTF(tostring(guildInfo.m_fubenLevel), self._rootnode["tag_fuben_lv_lbl"]) 
    end 

 end 


 function GuildMainScene:toBuild(tag) 
    if tag ~= nil then 
        if tag == GUILD_BUILD_TYPE.dadian then 
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_DADIAN) 
            
        elseif tag == GUILD_BUILD_TYPE.zuofang then 
            local function toLayer(data) 
                local layer = require("game.guild.guildZuofang.GuildZuofangLayer").new(data) 
                game.runningScene:addChild(layer, MAX_ZORDER, CHILD_TAG)  
            end 
            if self:getChildByTag(CHILD_TAG) == nil then 
                game.player:getGuildMgr():RequestEnterWorkShop(toLayer) 
            end 

        elseif tag == GUILD_BUILD_TYPE.qinglong then 
            if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then 
                local function toLayer(data) 
                    local rtnObj = data.rtnObj 
                    if rtnObj.state == GUILD_QL_CHALLENGE_STATE.hasOpen then 
                        GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, true)  

                    elseif rtnObj.state == GUILD_QL_CHALLENGE_STATE.notOpen or rtnObj.state == GUILD_QL_CHALLENGE_STATE.hasEnd then 
                        local layer = require("game.guild.guildQinglong.GuildQinglongLayer").new(data) 
                        game.runningScene:addChild(layer, MAX_ZORDER, CHILD_TAG)  
                    end 
                end 

                if self:getChildByTag(CHILD_TAG) == nil then 
                    game.player:getGuildMgr():RequestBossHistory(toLayer) 
                end
            else 
                show_tip_label("即将开放") 
            end 
            
        elseif tag == GUILD_BUILD_TYPE.shop then 
            if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then 
                GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_SHOP, GUILD_SHOP_TYPE.all) 
            else
                show_tip_label("即将开放") 
            end 

        elseif tag == GUILD_BUILD_TYPE.houshandidong then 
            show_tip_label(data_error_error[2800001].prompt) 
        elseif tag == GUILD_BUILD_TYPE.baihu then 
            show_tip_label(data_error_error[2800001].prompt) 

        elseif tag == GUILD_BUILD_TYPE.fuben then 
            if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then 
                GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_FUBEN, GUILD_FUBEN_TYPE.none) 
            else
                show_tip_label("即将开放") 
            end 
        end
    end   
 end


 function GuildMainScene:initBuildBtnFunc()
    local btnNames = {"tag_dadian_btn", "tag_zuofang_btn", "tag_shop_btn", "tag_qinglong_btn", "tag_baihu_btn", "tag_houshan_btn", "tag_fuben_btn"}

    for i, v in ipairs(btnNames) do 
        if self._rootnode[v] ~= nil then 
            self._rootnode[v]:addHandleOfControlEvent(function(eventName, sender) 
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
                local tag = sender:getTag() 
                self:toBuild(tag) 
            end, CCControlEventTouchUpInside)
        end     
    end  
 end 


 function GuildMainScene:checkCover() 
    local guildMgr = game.player:getGuildMgr() 
    
    -- dump(guildMgr:getIsChangeCover()) 

    if guildMgr:getIsChangeCover() == true then 
        self._rootnode["top_msg_node"]:setVisible(true) 
        local coverInfo = guildMgr:getCoverVo() 
        local nameStr = ""
        if coverInfo.firstName ~= nil then 
            nameStr = nameStr .. tostring(coverInfo.firstName) 
        end 
        if coverInfo.secondName ~= nil then 
            nameStr = nameStr .. tostring(coverInfo.secondName)
        end 
        if coverInfo.threeName ~= nil then 
            nameStr = nameStr .. tostring(coverInfo.threeName)
        end 
        self._rootnode["top_msg_1"]:setString(nameStr) 
        arrangeTTFByPosX({
            self._rootnode["top_msg_1"], 
            self._rootnode["top_msg_2"]
            }) 

        local function checkTime()
            if coverInfo.time > 0 then 
                coverInfo.time = coverInfo.time - 1 
                self._rootnode["left_time_lbl"]:setString(format_time(coverInfo.time)) 
            end

            if coverInfo.time <= 0 then 
                if self._checkSchedule ~= nil then 
                    self._scheduler.unscheduleGlobal(self._checkSchedule)
                end

                -- 去服务器端验证 是否时间到 
                RequestHelper.Guild.updateUnionLeader({ 
                    callback = function(data)
                        dump(data)
                        if data.err ~= "" then 
                            dump(data.err) 
                        else
                            local rtnObj = data.rtnObj 
                            if rtnObj.time ~= nil then 
                                coverInfo.time = rtnObj.time 
                                self._rootnode["left_time_lbl"]:setString(format_time(coverInfo.time)) 
                                UnRegNotice(self, NoticeKey.GUILD_UPDATE_ZIJIAN) 
                            else
                                guildMgr:setIsChangeCover(false) 
                            end 
                        end 
                    end 
                    })
            end 
        end  
        self._schedule = self._scheduler.scheduleGlobal(checkTime, 1, false ) 
    else 
        self._rootnode["top_msg_node"]:setVisible(false) 
        if self._checkSchedule ~= nil then 
            self._scheduler.unscheduleGlobal(self._checkSchedule)
        end
    end 
 end 


 function GuildMainScene:updateMsgDataLbl()
    local guildInfo = game.player:getGuildInfo() 

    self._rootnode["guild_gold_lbl"]:setString(tostring(guildInfo.m_currentUnionMoney))
    self._rootnode["guild_contribute_lbl"]:setString(tostring(guildInfo.m_selfMoney)) 
 end 


 function GuildMainScene:updateBuildLevel()
    local guildInfo = game.player:getGuildMgr():getGuildInfo() 

    -- 大殿
    self._dadianLvLbl:setString("LV." .. tostring(guildInfo.m_level)) 

    -- 作坊 
    self._zuofangLvLbl:setString("LV." ..tostring(guildInfo.m_workshoplevel)) 

    -- 商店 
    if data_feature_switch_config[1].ENABLE_GUILD_SHOP == true then 
        self._shopLvLbl:setString("LV." ..tostring(guildInfo.m_shoplevel)) 
    end 

    -- 青龙堂  
    if data_feature_switch_config[1].ENABLE_QINGLONGTANG == true then 
        self._qinglongLvLbl:setString("LV." ..tostring(guildInfo.m_greenDragonTempleLevel)) 
    end 

    -- 帮派副本   
    if data_feature_switch_config[1].ENABLE_GUILD_FUBEN == true then 
        self._fubenLvLbl:setString("LV." ..tostring(guildInfo.m_fubenLevel)) 
    end 
 end 


 function GuildMainScene:regSelfNotice() 
    self:regNotice()

    RegNotice(self, 
        function() 
            self:checkCover() 
        end,
        NoticeKey.GUILD_UPDATE_ZIJIAN) 

    RegNotice(self, 
        function() 
            self:updateMsgDataLbl() 
        end, 
        NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA)
    
    RegNotice(self, 
        function() 
            self:updateBuildLevel() 
        end, 
        NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL)
 end


 function GuildMainScene:unregSelfNotice() 
    self:unregNotice() 
    UnRegNotice(self, NoticeKey.GUILD_UPDATE_ZIJIAN) 
    UnRegNotice(self, NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA) 
    UnRegNotice(self, NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL) 
 end


 function GuildMainScene:onEnter() 
    GameAudio.playMainmenuMusic(true) 
    
    game.runningScene = self 
    self:regSelfNotice() 
    PostNotice(NoticeKey.GUILD_UPDATE_ZIJIAN) 
 end 


 function GuildMainScene:onExit()
    self:unscheduleUpdate() 
    self:unregSelfNotice() 
 end 


 return GuildMainScene 
