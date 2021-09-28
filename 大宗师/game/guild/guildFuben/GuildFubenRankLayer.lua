--[[
 --
 -- add by vicky
 -- 2015.03.09 
 --
 --]]  

 local data_ui_ui = require("data.data_ui_ui") 
 

 local GuildFubenRankLayer = class("GuildFubenRankLayer", function()
 		return require("utility.ShadeLayer").new()
 	end)


 function GuildFubenRankLayer:ctor(param) 
    self:setNodeEventEnabled(true)
    local hurtList = param.hurtList 
    local confirmFunc = param.confirmFunc 
    
    self._rootnode = {} 
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("huodong/worldBoss_rank_layer.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node) 

    self._rootnode["top_msg_lbl"]:setString(data_ui_ui[11].content) 

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            if confirmFunc ~= nil then 
                confirmFunc() 
            end 
            self:removeFromParentAndCleanup(true) 
        end, CCControlEventTouchUpInside) 

    self:initData(hurtList) 
    self:createListView() 
 end 


 function GuildFubenRankLayer:getIsHasAdd(index, indexList)
    local bHas = false 
    for i, v in ipairs(indexList) do 
        if v == index then 
            bHas = true 
            break 
        end 
    end 
    return bHas 
 end 


 function GuildFubenRankLayer:initData(topPlayers)
 	local rankData = topPlayers or {} 

    -- 先排好顺序，如果数量不够3个则在后面加入假数据
    local needAdd = false 
    if #rankData < 3 then 
        needAdd = true 
    end 

    --[[
    伤害排名规则：
    1.总伤害值最高者排名最高
    2.若伤害值相同则攻击次数最低者排名最高
    3.若伤害值和攻击次数都相同，则等级最高者排名最高
    4.若以上3条都相同，则时间早的排名在前
    ]] 

    local hurtList = {} 
    local attackList = {}
    local levelList = {} 
    local maxAttackNum = -1 
    local maxTime = -1 

    -- 根据伤害排名 
    local function getItemByHurt(indexList) 
        local max = -1  
        local curIndex = -1 
        hurtList = {} 
        for i, v in ipairs(rankData) do 
            if self:getIsHasAdd(i, indexList) == false and v.attackHp >= max then 
                curIndex = i 
                max = v.attackHp 
                table.insert(hurtList, rankData[i]) 
            end 
            if v.attackNum > maxAttackNum then 
                maxAttackNum = v.attackNum 
            end 
        end 
        return curIndex  
    end 

    -- 根据攻击次数排名 
    local function getItemByAttack(min, indexList) 
        local curIndex = -1 
        attackList = {} 
        for i, v in ipairs(rankData) do 
            if self:getIsHasAdd(i, indexList) == false and v.attackNum <= min then 
                curIndex = i 
                min = v.attackNum 
                table.insert(attackList, rankData[i]) 
            end 
        end 
        return curIndex 
    end 

    -- 根据等级排名 
    local function getItemByLevel(indexList) 
        local max = -1 
        local curIndex = -1 
        levelList = {} 
        for i, v in ipairs(rankData) do 
            if self:getIsHasAdd(i, indexList) == false and v.roleLevel >= max then 
                curIndex = i 
                max = v.roleLevel 
                table.insert(levelList, rankData[i]) 
            end 
            if v.createTime > maxTime then 
                maxTime = v.createTime 
            end 
        end 
        return curIndex 
    end 

    -- 根据时间排名 
    local function getItemByTime(min, indexList) 
        local curIndex = -1 
        for i, v in ipairs(rankData) do 
            if self:getIsHasAdd(i, indexList) == false and v.createTime <= min then 
                curIndex = i 
                min = v.createTime 
            end 
        end 
        return curIndex 
    end 

    self._rankData = {}
    local indexList = {} 

    local function addToList(index)
        if index ~= -1 then 
            local itemData = rankData[index] 
            itemData.rank = #self._rankData + 1  
            itemData.guildName = game.player:getGuildInfo().m_name 
            table.insert(indexList, index) 
            table.insert(self._rankData, itemData) 
        end 
    end 

    for i = 1, #rankData do 
        local hurtIndex = getItemByHurt(indexList) 
        addToList(hurtIndex) 
        
        local atkIndex = getItemByAttack(maxAttackNum, indexList) 
        addToList(atkIndex) 

        local lvIndex = getItemByLevel(indexList) 
        addToList(lvIndex) 

        local timeIdx = getItemByTime(maxTime, indexList)
        addToList(timeIdx) 
    end 

    -- 若没有数据返回，则置假数据 至少3个数据 
    if needAdd == true then 
        for i = #self._rankData + 1, 3 do 
            table.insert(self._rankData, {
                isTrueData = false,   -- 是否是真实数据
                rank = i,   
                acc = "", 
                name = "无", 
                roleLevel = 0, 
                attackHp = 0, 
                attackNum = 0, 
                createTime = 0  
                })
        end 
    end 
 end


 function GuildFubenRankLayer:createListView()
    local viewSize = self._rootnode["listView"]:getContentSize() 

    local fileName = "game.guild.guildFuben.GuildFubenRankItem" 

    -- 创建
    local function createFunc(index)
        local item = require(fileName).new()
        return item:create({
            viewSize = viewSize, 
            itemData = self._rankData[index + 1], 
            checkFunc = function(cell)
                local index = cell:getIdx() + 1 
                self:checkZhenrong(index) 
            end
            })
    end 

    -- 刷新 
    local function refreshFunc(cell, index)
        cell:refresh(self._rankData[index + 1]) 
    end 

    local cellContentSize = require(fileName).new():getContentSize()

    self._rootnode["listView"]:removeAllChildren() 

    local listTable = require("utility.TableViewExt").new({
        size        = viewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum     = #self._rankData, 
        cellSize    = cellContentSize 
        })

    listTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(listTable) 
 end 


 function GuildFubenRankLayer:checkZhenrong(index) 
    if ENABLE_ZHENRONG then  
        local layer = require("game.form.EnemyFormLayer").new(1, self._rankData[index].acc)
        layer:setPosition(0, 0) 
        self:addChild(layer, 10000) 
    else
        show_tip_label(data_error_error[2800001].prompt)
    end 
 end 


 function GuildFubenRankLayer:onExit()
    CCTextureCache:sharedTextureCache():removeUnusedTextures() 
 end


 return GuildFubenRankLayer 

