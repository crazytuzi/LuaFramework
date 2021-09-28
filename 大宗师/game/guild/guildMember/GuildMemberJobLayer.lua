--[[
 --
 -- add by vicky
 -- 2015.01.08  
 --
 --]]

 require("data.data_error_error") 
 local data_ui_ui = require("data.data_ui_ui") 

 local MAX_ZORDER = 100 
 local kParentScene 

 local FRIEND_TYPE = {
    friend = 0,     -- 是好友
    notApply = 1,   -- 不是好友，未申请
    hasApply = 2,   -- 不是好友，已申请 
    }


 local GuildMemberJobLayer = class("GuildMemberJobLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 -- 退出帮派 
 local function exitUnion(msgBox) 
    RequestHelper.Guild.exitUnion({  
        uid = game.player:getGuildMgr():getGuildInfo().m_id, 
        errback = function(data)
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                msgBox:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    GameStateManager:ChangeState(GAME_STATE.STATE_GUILD) 
                else
                    msgBox:setBtnEnabled(true) 
                end 
            end 
        end 
        })    
 end


 -- 踢出帮派 
 local function kickRole(roleId, msgBox)
    RequestHelper.Guild.kcikRole({  
        appRoleId = roleId, 
        errback = function(data)
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                msgBox:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    if kParentScene ~= nil then 
                        local index = kParentScene:removeItemFromNormalList(roleId) 
                        kParentScene:forceReloadNormalListView(index - 1)  
                        msgBox:removeFromParentAndCleanup(true) 
                    end 
                else
                    msgBox:setBtnEnabled(true) 
                end 
            end 
        end, 
        })    
 end 


 -- 取消/任命职位 
 function GuildMemberJobLayer:setPosition(roleId, jopType)
    RequestHelper.Guild.setPosition({  
        appRoleId = roleId, 
        jopType = jopType,  
        errback = function(data)
            self:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data)
            if data.err ~= "" then 
                dump(data.err) 
                self:setBtnEnabled(true)   
            else 
                local rtnObj = data.rtnObj 
                if rtnObj.success == 0 then 
                    self._itemData.jopType = jopType 
                    if kParentScene ~= nil then 
                        kParentScene:forceReloadNormalListView(0) 
                        self:removeFromParentAndCleanup(true) 
                    end 
                else
                    self:setBtnEnabled(true) 
                end 
            end 
        end, 
        })    
 end 


 -- 请求加好友 
 function GuildMemberJobLayer:reqAddFriend(param)
    local box = param.box 

    RequestHelper.friend.applyFriend({
        content = param.content,
        account = param.roleAcc,
        errback = function()
            self:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            self:setBtnEnabled(true) 
            box:removeFromParentAndCleanup() 

            --result  1-申请成功 2-已申请过 
            local result = data.rtnObj.result 
            if result == 1 then
                ResMgr.showErr(3200115) 
                self._itemData.isFriend = FRIEND_TYPE.hasApply 
            elseif result == 2 then 
                ResMgr.showErr(2900018) 
                self._itemData.isFriend = FRIEND_TYPE.hasApply 
            end     
        end})  
 end 


 function GuildMemberJobLayer:ctor(param) 
    local title = param.title 
    self._itemData = param.itemData 
    kParentScene = param.parentScene 

    local guildMgr = game.player:getGuildMgr() 
    local jopType = guildMgr:getGuildInfo().m_jopType 

    local fileName 
    if self._itemData.isSelf == true then 
        fileName = "ccbi/guild/guild_job_self.ccbi"  
    else 
        if jopType == GUILD_JOB_TYPE.leader then 
            fileName = "ccbi/guild/guild_job_another_leader.ccbi"  
        elseif jopType == GUILD_JOB_TYPE.assistant and self._itemData.jopType == GUILD_JOB_TYPE.normal then 
            fileName = "ccbi/guild/guild_job_another_assistant.ccbi"  
        else
            fileName = "ccbi/guild/guild_job_another_normal.ccbi"  
        end 
    end 

    local proxy = CCBProxy:create()
    self._rootnode = {}
 	local node = CCBuilderReaderLoad(fileName, proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	self._rootnode["titleLabel"]:setString(title) 

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        closeFunc() 
    end, CCControlEventTouchUpInside)

    if self._itemData.isSelf == false and jopType == GUILD_JOB_TYPE.leader then 
        if self._itemData.jopType == GUILD_JOB_TYPE.assistant then 
            self._rootnode["set_assistant_btn"]:setVisible(false) 
            self._rootnode["cancel_assistant_btn"]:setVisible(true) 
        end 

        if self._itemData.jopType == GUILD_JOB_TYPE.elder then 
            self._rootnode["set_elder_btn"]:setVisible(false) 
            self._rootnode["cancel_elder_btn"]:setVisible(true) 
        end 
    end 

    if self._itemData.isSelf == false then 
        if self._itemData.isFriend == FRIEND_TYPE.friend then 
            self._rootnode["hasAdded_icon"]:setVisible(true) 
            self._rootnode["addFriend_btn"]:setVisible(false) 
        else 
            self._rootnode["hasAdded_icon"]:setVisible(false) 
            self._rootnode["addFriend_btn"]:setVisible(true) 
        end 
    end 

    -- 切磋、私聊、加好友、设为副帮主、取消副帮主、设为长老、取消长老、踢出帮派、退出帮派
    self._btnTags = {"battle_btn", "chat_btn", "addFriend_btn", "set_assistant_btn", "cancel_assistant_btn", 
                    "set_elder_btn", "cancel_elder_btn", "kick_btn", "exit_btn" }
    
    if self._rootnode["battle_btn"] ~= nil then 
        if game.player:getAppOpenData().b_qiecuo == APPOPEN_STATE.close then 
            self._rootnode["battle_btn"]:setVisible(false) 
        else
            self._rootnode["battle_btn"]:setVisible(true)  
        end   
    end 

    if self._rootnode["chat_btn"] ~= nil then 
        if game.player:getAppOpenData().b_siliao == APPOPEN_STATE.close then 
            self._rootnode["chat_btn"]:setVisible(false) 
        else
            self._rootnode["chat_btn"]:setVisible(true)  
        end 
    end 

    self:registerBtnEvent() 
 end 


 function GuildMemberJobLayer:setBtnEnabled(bEnabled)
    for i, v in ipairs(self._btnTags) do 
        if self._rootnode[v] ~= nil then 
            self._rootnode[v]:setEnabled(bEnabled) 
        end 
    end   
 end


 function GuildMemberJobLayer:registerBtnEvent() 
    local function onTouchBtn(tag)
        self:setBtnEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

        -- 切磋
        if tag == self._btnTags[1] then 
            show_tip_label("暂未开放")
            self:setBtnEnabled(true)

        -- 私聊
        elseif tag == self._btnTags[2] then 
            show_tip_label("暂未开放")
            self:setBtnEnabled(true)

        -- 加好友
        elseif tag == self._btnTags[3] then 
            if self._itemData.isFriend == FRIEND_TYPE.hasApply then 
                ResMgr.showErr(2900018)
                self:setBtnEnabled(true)

            elseif self._itemData.isFriend ~= FRIEND_TYPE.friend then 
                local applyBox = require("game.Friend.FriendApplyBox").new({
                    confirmFunc = function(box, content)
                        self:reqAddFriend({
                            box = box, 
                            roleAcc = self._itemData.roleAcc, 
                            content = content 
                            }) 
                    end, 
                    cancelFunc = function()
                        self:setBtnEnabled(true) 
                    end, 
                    })
                game.runningScene:addChild(applyBox, MAX_ZORDER) 
            end 

        -- 设为副帮主
        elseif tag == self._btnTags[4] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.assistant) 
        -- 取消副帮主
        elseif tag == self._btnTags[5] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal) 

        -- 设为长老
        elseif tag == self._btnTags[6] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.elder) 

        -- 取消长老
        elseif tag == self._btnTags[7] then 
            self:setPosition(self._itemData.roleId, GUILD_JOB_TYPE.normal) 

        -- 踢出帮派
        elseif tag == self._btnTags[8] then 
            local content = "是否确定将" .. tostring(self._itemData.roleName) .. "踢出帮派?" 
            local roleId = self._itemData.roleId 
            game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    msg = content,  
                    isSingleBtn = false, 
                    confirmFunc = function(msgBox) 
                        kickRole(roleId, msgBox) 
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 

        -- 退出帮派 
        elseif tag == self._btnTags[9] then 
            -- 提示退出帮派后需要等待24小时的CD时间才可再次申请加入帮派
            game.runningScene:addChild(require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    msg = data_ui_ui[7].content, 
                    isSingleBtn = false, 
                    confirmFunc = function(msgBox) 
                        exitUnion(msgBox) 
                    end 
                }), MAX_ZORDER) 
            self:removeFromParentAndCleanup(true) 
        end 

    end 

    for i, v in ipairs(self._btnTags) do 
        if self._rootnode[v] ~= nil then 
            self._rootnode[v]:addHandleOfControlEvent(function(eventName, sender)
                onTouchBtn(v) 
            end, CCControlEventTouchUpInside) 
        end 
    end 

 end  


 return GuildMemberJobLayer 
