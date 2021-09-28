--[[
 --
 -- add by vicky
 -- 2015.01.12   
 --
 --]]

 require("data.data_error_error") 
 local data_union_juanxian_union_juanxian = require("data.data_union_juanxian_union_juanxian") 


 local MAX_ZORDER = 101 
 local NORMAL_SIZE = 20 


 local GuildDadianScene = class("GuildDadianScene", function() 
    local bottomFile = "guild/guild_bottom_frame_normal.ccbi" 
    local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType  
    if jopType ~= GUILD_JOB_TYPE.normal then 
        bottomFile = "guild/guild_bottom_frame.ccbi" 
    end 

    return require("game.guild.utility.GuildBaseScene").new({ 
        topFile = "public/top_frame.ccbi",
        bottomFile = bottomFile, 
        -- bgImage = "#guild_cbg_bottomBg.png", 
        bgImage = "ui_common/common_bg.png", 
        isOther = false  
    })
 end) 


 -- 捐献 
 function GuildDadianScene:reqContribute(cell) 
    RequestHelper.Guild.unionDonate({
        unionid = game.player:getGuildMgr():getGuildInfo().m_id, 
        donatetype = cell:getId(), 
        errback = function(data)
            cell:setBtnEnabled(true) 
        end, 
        callback = function(data)
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
                cell:setBtnEnabled(true) 
            else 
                ResMgr.showErr(2900084) 
                local addmoney = data_union_juanxian_union_juanxian[cell:getIdx() + 1].addmoney 
                table.insert(self._dynamciList, 1, {
                    roleName = game.player:getPlayerName(), 
                    conMoney = addmoney 
                    }) 
                self:reloadDynamicListView(self._dynamciList) 

                self:updateContributeNum(self._curContributedNum + 1) 
                self:updateLevel(self._level, self._currentUnionMoney + addmoney) 

                -- 更新银币、元宝数量 
                game.player:updateMainMenu({
                    silver = data.rtnObj.surplusSliver, 
                    gold = data.rtnObj.surplusGod 
                    })
                PostNotice(NoticeKey.CommonUpdate_Label_Silver) 
                PostNotice(NoticeKey.CommonUpdate_Label_Gold) 

                self:setContributeState(true) 
            end
        end
    })
 end 


 -- 建筑升级
 function GuildDadianScene:reqLevelup(msgBox) 
    levelupBtn = self._rootnode["levelup_btn"] 

    RequestHelper.Guild.unionLevelUp({
        unionid = game.player:getGuildMgr():getGuildInfo().m_id, 
        buildtype = self._buildType, 
        errback = function(data)
            levelupBtn:setEnabled(true) 
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
                levelupBtn:setEnabled(true) 
                msgBox:setBtnEnabled(true)
            else 
                ResMgr.showErr(2900083) 
                msgBox:removeFromParentAndCleanup(true) 
                self:updateLevel(data.rtnObj.buildLevel, data.rtnObj.currentUnionMoney) 
                self:updateContributeNum(self._curContributedNum, data.rtnObj.roleMaxNum)  
                levelupBtn:setEnabled(true) 
            end
        end
    })
 end 


 function GuildDadianScene:ctor(data) 
    -- dump(data, "", 5)  
    -- dump(data) 

    game.runningScene = self 
    self._buildType = GUILD_BUILD_TYPE.dadian 

    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("guild/guild_dadian_layer.ccbi", proxy, self._rootnode)
    
    local centerH = self:getCenterHeight() 
    local topH = self:getTopHeight() 
    local bottomH = self:getBottomHeight() 
    local bagH = self._rootnode["tag_bag"]:getContentSize().height 
    
    local posY = (display.height - (topH - bottomH)) / 2 
    node:setPosition(display.width/2, posY) 
    self:addChild(node) 

    if bagH > centerH then 
        self._rootnode["tag_bag"]:setScale(centerH/bagH) 
    end 

    self._rootnode["titleLabel"]:setString("帮派大殿") 

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD) 
        end,CCControlEventTouchUpInside) 


    local guildMgr = game.player:getGuildMgr() 
    local guildInfo = guildMgr:getGuildInfo() 

    -- 升级按钮 
    local jopType = guildInfo.m_jopType  
    local levelupBtn = self._rootnode["levelup_btn"] 
    if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then 
        levelupBtn:setVisible(false) 
    else 
        levelupBtn:setVisible(true) 
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
    end 

    local rtnObj = data.rtnObj 

    game.player:setVip(rtnObj.viplevel) 
    self:updateContributeNum(rtnObj.contributed, rtnObj.roleMaxNum) 

    -- 0未捐献1已捐献 
    self._hasContribute = true  
    if rtnObj.isCon == 0 then 
        self._hasContribute = false 
    end 

    self:updateLevel(rtnObj.unionLevel, rtnObj.currentUnionMoney) 

    self:createAllLbl() 
    self:reloadCrontributeListView() 

    self._dynamciList = {} 
    for i, v in ipairs(rtnObj.dynamciList) do 
        table.insert(self._dynamciList, {
            roleName = v[1], 
            conMoney = v[4]  
            })
    end 
    -- dump(#rtnObj.dynamciList) 
    -- dump(rtnObj.dynamciList[1]) 

    self:reloadDynamicListView(self._dynamciList) 
 end 


 -- 阴影描边字 
 function GuildDadianScene:createAllLbl() 
    local guildMgr = game.player:getGuildMgr() 

    local yColor = ccc3(255, 222, 0) 
    
    -- 升级消耗资金 
    self:createTTF("升级消耗资金:", yColor, self._rootnode["cost_coin_msg_lbl"])  

    -- 当前拥有资金 
    self:createTTF("当前拥有资金:", yColor, self._rootnode["cur_coin_msg_lbl"])  

    self:createTTF("升级帮派大殿可以:", ccc3(0, 219, 52), self._rootnode["levelup_msg_lbl"]) 

 end 


 function GuildDadianScene:createTTF(text, color, node, size)
    node:removeAllChildren() 
    local lbl = ui.newTTFLabelWithShadow({
        text = text,
        size = size or NORMAL_SIZE, 
        color = color,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    }) 

    node:addChild(lbl) 
    return lbl 
 end 


 function GuildDadianScene:updateContributeNum(curNum, totalNum) 
    self._curContributedNum = curNum 
    self._roleMaxNum = totalNum or self._roleMaxNum    
    self._rootnode["contribute_num_lbl"]:setString("今日捐献次数: " .. tostring(self._curContributedNum) .. "/" .. tostring(self._roleMaxNum)) 
 end 


 -- 更新大殿等级 
 function GuildDadianScene:updateLevel(level, currentUnionMoney) 
    local guildMgr = game.player:getGuildMgr() 
    self._level = level 
    guildMgr:getGuildInfo().m_level = self._level 
    self._currentUnionMoney = currentUnionMoney  
    self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level) 

    -- 当前等级 
    self:createTTF("LV." .. tostring(self._level), ccc3(255, 222, 0), self._rootnode["cur_level_lbl"])

    -- 当前帮派资金 
    self:createTTF(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode["cur_coin_lbl"])

    self:updateNeedCoinLbl(self._needCoin) 
 end  


 function GuildDadianScene:updateNeedCoinLbl(needCoin)
    local str 
    if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then 
        str = "已升到最大等级" 
    else
        str = tostring(needCoin) 
    end
    self:createTTF(str, FONT_COLOR.WHITE, self._rootnode["cost_coin_lbl"]) 
 end 


 -- 根据是否已捐献，更改捐献按钮状态 
 function GuildDadianScene:setContributeState(bHasCont) 
    self._hasContribute = bHasCont  
    self:reloadCrontributeListView()
 end 
 

 -- 创建捐献列表 
 function GuildDadianScene:reloadCrontributeListView()
    if self._conListTable ~= nil then 
        self._conListTable:removeFromParentAndCleanup(true)  
        self._conListTable = nil 
    end 

    local listViewSize = self._rootnode["contribute_listView"]:getContentSize() 

    -- 创建 
    local function createFunc(index)
        local item = require("game.guild.guildDadian.GuildDadianContributeItem").new() 
        return item:create({ 
                hasContribute = self._hasContribute, 
                itemData = data_union_juanxian_union_juanxian[index + 1], 
                viewSize = listViewSize, 
                contributeFunc = function(cell) 
                    local bCan = true 
                    local contInfo = data_union_juanxian_union_juanxian[cell:getIdx() + 1] 
                    if game.player:getVip() < contInfo.nedvip then 
                        bCan = false 
                        show_tip_label("需要VIP" .. tostring(contInfo.nedvip) .. "级") 

                    elseif self._curContributedNum >= self._roleMaxNum then 
                        bCan = false 
                        show_tip_label(data_error_error[2900081].prompt) 

                    elseif contInfo.type == 1 and game.player:getSilver() < contInfo.number then 
                        bCan = false 
                        show_tip_label(data_error_error[2900022].prompt)

                    elseif contInfo.type == 2 and game.player:getGold() < contInfo.number then 
                        bCan = false 
                        show_tip_label(data_error_error[2900023].prompt)

                    end 

                    if bCan == true then 
                        cell:setBtnEnabled(false) 
                        self:reqContribute(cell)
                    else
                        cell:setBtnEnabled(true) 
                    end 
                end  
            })
    end

    -- 刷新 
    local function refreshFunc(cell, index) 
        cell:refresh(data_union_juanxian_union_juanxian[index + 1])
    end 

    local cellContentSize = require("game.guild.guildDadian.GuildDadianContributeItem").new():getContentSize()

    self._conListTable = require("utility.TableViewExt").new({
        size        = listViewSize, 
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #data_union_juanxian_union_juanxian, 
        cellSize    = cellContentSize 
    })

    self._rootnode["contribute_listView"]:addChild(self._conListTable) 
 end 


 -- 创建动态列表
 function GuildDadianScene:reloadDynamicListView(listData)  

    if self._dynamicListTable ~= nil then 
        self._dynamicListTable:removeFromParentAndCleanup(true)  
        self._dynamicListTable = nil 
    end 

    local listViewSize = self._rootnode["dynamic_listView"]:getContentSize()  

    -- 创建 
    local function createFunc(index)
        local item = require("game.guild.guildDadian.GuildDadianDynamicItem").new() 
        return item:create({ 
                itemData = listData[index + 1], 
                viewSize = listViewSize 
            })
    end

    -- 刷新 
    local function refreshFunc(cell, index) 
        cell:refresh(listData[index + 1])
    end 

    local cellContentSize = require("game.guild.guildDadian.GuildDadianDynamicItem").new():getContentSize()

    self._dynamicListTable = require("utility.TableViewExt").new({
        size        = listViewSize,
        direction   = kCCScrollViewDirectionVertical,  
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #listData, 
        cellSize    = cellContentSize 
    })

    self._rootnode["dynamic_listView"]:addChild(self._dynamicListTable) 
 end 



 function GuildDadianScene:onEnter() 
    game.runningScene = self 
    self:regNotice() 
 end 


 function GuildDadianScene:onExit() 
    self:unregNotice() 
 end 


 return GuildDadianScene  
