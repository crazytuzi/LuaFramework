--[[
 --
 -- add by vicky
 -- 2015.03.16    
 --
 --]]

local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")

local HERO_STATE = {
    unselected = -1,    -- 未被选择
    selected = 1,       -- 已上阵
}

local VIEW_TYPE = {
    ALL   = 1,
    GONG  = 2,
    FANG  = 3,
    FU    = 4
}

local MAX_ZORDER = 11  

local ChallengeFubenChooseHeroScene = class("ChallengeFubenChooseHeroScene", function()
    return require("game.BaseSceneExt").new({
        contentFile = "huashan/huashan_choose_scene.ccbi",
        bottomFile  = "huashan/huashan_bottom.ccbi",
        topFile     = "huashan/huashan_top.ccbi"
    })
end)


function ChallengeFubenChooseHeroScene:ctor(param) 
    local _bg    = display.newSprite("ui_common/common_bg.png")
    local _bgW   = display.width

    self._fbId = param.fbId 
    self._sysId = param.sysId 
    local showFunc = param.showFunc 
    local changeFormaitonFunc = param.changeFormaitonFunc 
    self._heros = param.cards 
    self._formHero = param.formHero 
    self._bHasChangeFormation = false   -- 是否改变了阵容 
    self._bHasSaveFormaiton = false     -- 是否保存了阵容  
    self._zhandouLi = 0 

    dump(self._heros, "侠客选择界面", 8)

    local _bgH = display.height - self._rootnode["topFrameNode"]:getContentSize().height
    _bg:setPosition(_bgW / 2, _bgH / 2)

    _bg:setScaleX(_bgW / _bg:getContentSize().width)
    _bg:setScaleY(_bgH / _bg:getContentSize().height)
    self:addChild(_bg, 0)

    self._rootnode["save_node"]:setVisible(true) 
    self._rootnode["startBtn"]:setVisible(false)  
    self._rootnode["content_msg_lbl"]:setString(data_huodongfuben_huodongfuben[self._fbId].recommend) 

    local function getHeroById(id)
        for k, v in ipairs(self._heros) do
            if id == v.id then
                return k, v
            end
        end
        return nil
    end 

    local function getfmtstr()
        local str = "["
        for k, v in ipairs(self._formHero) do
            local hero = self._heros[v.index]
            if hero then
                str = str .. string.format("[%s,%d],", hero.id, v.pos)
            end
        end
        str = str .. "]"
        dump("====================")
        dump(str) 
        return str
    end

    local function getFormInfo() 
        local formList = {}
        for i = 1, 6 do
            local idxHero = self._formHero[i]
            if idxHero then
                local hero = self._heros[idxHero.index]
                if hero then
                    local tmp = {
                        pos    = idxHero.pos,
                        resId  = hero.resId,
                        cls    = hero.cls,
                        level  = hero.level,
                        star   = hero.star,
                        objId  = hero.id
                    }
                    table.insert(formList, tmp)
                end
            end
        end
        return formList
    end

    -- 如果改变了阵容并且保存了，返回的时候，需要重置副本详情阵容界面 
    local function changeFormFunc()
        if changeFormaitonFunc ~= nil then 
            for i, v in ipairs(self._formHero) do 
                self._heros[v.index].pos = v.pos 
            end 
            local fmt = getfmtstr() 
            changeFormaitonFunc(self._heros, self._zhandouLi, fmt)  
        end 
    end 

    local function saveFormation()
        local str = getfmtstr() 
        local saveFormBtn = self._rootnode["saveFormBtn"] 
        RequestHelper.challengeFuben.save({
            aid = self._fbId, 
            fmt = str, 
            sysId = self._sysId, 
            errback = function()
                saveFormBtn:setEnabled(true) 
            end, 
            callback = function(data)
                saveFormBtn:setEnabled(true)
                dump(data)
                if data.err == "" then 
                    self._bHasSaveFormaiton = true 
                    self._zhandouLi = data.rtnObj  
                    changeFormFunc()
                    pop_scene() 
                end 
            end,
            })
    end 

    -- 返回
    self._rootnode["returnBtn"]:addHandleOfControlEvent(function() 
        if self._bHasChangeFormation == true then 
            if self._bHasSaveFormaiton == true then 
                changeFormFunc() 
                pop_scene()
            else
                -- 提示是否保存 若是则保存之后退出 
                local lbl1 = ResMgr.createOutlineMsgTTF({text = "您还未保存当前调整的阵容，是否", color = white, outlineColor = black, size = size})
                local lbl2 = ResMgr.createOutlineMsgTTF({text = "保存阵容", color = white, outlineColor = black, size = size})
                local msgBox = require("utility.MsgBoxEx").new({
                    resTable = {{lbl1}, {lbl2}}, 
                    confirmFunc = function(msgBox) 
                        saveFormation() 
                        msgBox:removeSelf()
                    end,
                    closeFunc = function(msgBox) 
                        msgBox:removeSelf()
                        pop_scene() 
                    end, 
                    backFunc = function(msgBox) 
                        msgBox:removeSelf()
                    end
                    })
                game.runningScene:addChild(msgBox, MAX_ZORDER) 
            end 
        else
            pop_scene()
        end 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end, CCControlEventTouchUpInside) 

    -- 保存阵容 
    local saveFormBtn = self._rootnode["saveFormBtn"] 
    saveFormBtn:addHandleOfControlEvent(function() 
        if #self._formHero == 0 then 
            ResMgr.showErr(2900097) 
        else 
            saveFormBtn:setEnabled(false) 
            local lbl = ResMgr.createOutlineMsgTTF({text = "是否保存您当前调整的阵容", color = white, outlineColor = black, size = size})
            local msgBox = require("utility.MsgBoxEx").new({
                resTable = {{lbl}}, 
                confirmFunc = function(msgBox) 
                    saveFormation() 
                end,
                closeFunc = function(msgBox) 
                    saveFormBtn:setEnabled(true) 
                    msgBox:removeSelf()
                end
                })
            game.runningScene:addChild(msgBox, MAX_ZORDER) 
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchUpInside)

    -- 布阵 
    local setFormBtn = self._rootnode["setFormBtn"] 
    setFormBtn:addHandleOfControlEvent(function()
        setFormBtn:setEnabled(false)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        if #self._formHero == 0 then
            ResMgr.showErr(2900097) 
            setFormBtn:setEnabled(true)
            return
        end

        local formHero = getFormInfo() 
        -- 计算战斗力 
        RequestHelper.huashan.zhandouli({
            fmt = getfmtstr(),
            callback = function(data)
                dump(data) 
                local formCtrl = require("game.form.FormCtrl")
                self._formSettingView = formCtrl.createFormSettingLayer({
                    parentNode    = self,
                    touchEnabled  = true,
                    list          = formHero,
                    bTmpPos       = true,
                    zdlNum        = data.rtnObj,
                    closeListener = function(bHasChange)
                        for k, v in ipairs(self._formHero) do
                            v.pos = formHero[k].pos
                        end
                        setFormBtn:setEnabled(true) 
                        
                        self._bHasChangeFormation = bHasChange 
                    end,
                    callback     = function()

                    end
                })
            end
        })
    end, CCControlEventTouchUpInside) 

    local function onTabBtn(tag)
        for i = 1, 4 do
            if tag == i then
                self._rootnode["tab" ..tostring(i)]:selected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(5)
            else
                self._rootnode["tab" ..tostring(i)]:unselected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(tag)
            end
        end
        self._viewType = tag
        self._heroList:resetCellNum(#self._groupHerosData[tag])

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 4 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
    end

    initTab()
    self._groupHerosData = {}
    for _, v in pairs(VIEW_TYPE) do
        self._groupHerosData[v] = {}
    end

    -- 初始化侠客 
    for i, v in ipairs(self._heros) do 
        v.id = v.cardId 
        -- 主角的resId为1或2
        if v.resId == 1 or v.resId == 2 then 
            v.bIsSelf = true 
        else
            v.bIsSelf = false 
        end 
        v.state = HERO_STATE.unselected  
        for _, m in ipairs(self._formHero) do 
            if m.index == i then 
                v.state = HERO_STATE.selected 
                break 
            end 
        end 
    end 

    self._viewType = VIEW_TYPE.ALL 
    self:groupHero()
    self:initChooseListView()
    self:initHeroListView()
    self._rootnode["tab1"]:selected() 

    if showFunc ~= nil then
        showFunc()
    end 
end


function ChallengeFubenChooseHeroScene:groupHero()
    local heroGroup = {}
    for k, v in pairs(VIEW_TYPE) do
        heroGroup[v]   = {}
    end

    for k, v in pairs(self._heros) do
        local hero = ResMgr.getCardData(v.resId)
        if hero.job == 1 then
            table.insert(heroGroup[VIEW_TYPE.GONG], v)
        elseif hero.job == 2 then
            table.insert(heroGroup[VIEW_TYPE.FANG], v)
        elseif hero.job == 3 then
            table.insert(heroGroup[VIEW_TYPE.FU], v)
        end

        table.insert(heroGroup[VIEW_TYPE.ALL], v)
        local path = "hero/icon/" .. hero["arr_icon"][v.cls + 1]..".png"
        CCTextureCache:sharedTextureCache():addImage(path)
    end

    --  5个一组
    for _, viewType in pairs(VIEW_TYPE) do
        local t = self._groupHerosData[viewType]
        for k, v in ipairs(heroGroup[viewType]) do
            if k % 5 == 1 then
                table.insert(t, {})
            end
            table.insert(t[#t], v)
        end
    end
end


function ChallengeFubenChooseHeroScene:getEmptyPos()
    local tmpPos = #self._formHero + 1
    local b
    for i = 1, 6 do
        b = true
        for _, v in ipairs(self._formHero) do
            if i == v.pos then
                b = false
                break
            end
        end
        if b then
            tmpPos = i
            break
        end
    end
    return tmpPos
end


function ChallengeFubenChooseHeroScene:initHeroListView()
    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)

    local function existSameHero(id)
        for k, v in ipairs(self._formHero) do
            if self._heros[v.index].id == id then
                return true
            end
        end
        return false
    end

    local sz = self._rootnode["scrollListView"]:getContentSize()
    local heroItem = require("game.guild.guildFuben.GuildFubenHeroItem")

    self._heroList = require("utility.TableViewExt").new({
        size = CCSizeMake(sz.width, sz.height - 45), 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            local item = heroItem.new()
            idx = idx + 1
            return item:create({
                viewSize = sz,
                itemData = self._groupHerosData[self._viewType][idx],
                idx      = idx,
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._groupHerosData[self._viewType][idx]
            })
        end,
        cellNum   = #self._groupHerosData[self._viewType],
        cellSize    = heroItem.new():getContentSize(),
        touchFunc = function(cell)
            local idx = cell:getIdx() + 1
            local pos = cell:convertToNodeSpace(ccp(posX, posY))
            local sz = cell:getContentSize()
            local i = 0
            if pos.x > sz.width * (4 / 5) and pos.x < sz.width then
                i = 5
            elseif pos.x > sz.width * (3 / 5)  then
                i = 4
            elseif pos.x > sz.width * (2 / 5)  then
                i = 3
            elseif pos.x > sz.width * (1 / 5) then
                i = 2
            elseif pos.x > 0 then
                i = 1
            end

            if i >= 1 and i <= 5 then
                local info = self._groupHerosData[self._viewType][idx]
                if info and info[i] then
                    for k, v in ipairs(self._heros) do
                        if info[i].id == v.id then 
                            if info[i].state == HERO_STATE.selected then 
                                ResMgr.showErr(2900096)  
                            elseif info[i].state == HERO_STATE.unselected then 
                                if #self._formHero >= 6 then 
                                    ResMgr.showErr(2900095)  
                                elseif existSameHero(info[i].id) then
                                    ResMgr.showErr(600005)  
                                else
                                    self._bHasChangeFormation = true 
                                    info[i].state = HERO_STATE.selected 
                                    self._heroList:reloadCell(idx - 1, {
                                        itemData = info
                                    })

                                    table.insert(self._formHero, {
                                        index = k,
                                        pos = self:getEmptyPos()
                                    })

                                    self._chooseItemList:resetListByNumChange(#self._formHero)
                                    self._rootnode["numLabel"]:setString(tostring(#self._formHero))

                                    if #self._formHero > 1 then
                                        local w = self._chooseItemList:cellAtIndex(0):getContentSize().width * #self._formHero
                                        if w > self._chooseItemList:getContentSize().width then
                                            self._chooseItemList:setContentOffset(ccp(self._chooseItemList:getContentSize().width - w, 0), true)
                                        end
                                    end
                                end 
                            end 
                            break 
                        end
                    end
                end
            end
        end
    })
    self._heroList:setPosition(0, 9)
    self._rootnode["scrollListView"]:addChild(self._heroList)
end


function ChallengeFubenChooseHeroScene:initChooseListView() 
    local sz = self._rootnode["selectListView"]:getContentSize()
    local selectedItem = require("game.guild.guildFuben.GuildFubenHeroSelectItem")

    self._chooseItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(sz.width, sz.height),
        direction   = kCCScrollViewDirectionHorizontal,
        createFunc  = function(idx)
            local item = selectedItem.new()
            idx = idx + 1 
            return item:create({
                viewSize = sz,
                itemData = self._heros[self._formHero[idx].index],
                idx      = idx,
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._heros[self._formHero[idx].index]
            })
        end,
        cellNum   = #self._formHero,
        cellSize    = selectedItem.new():getContentSize(),
        touchFunc = function(cell)
            local idx = cell:getIdx() + 1 
            local curIndex = self._formHero[idx].index 
            if self._heros[curIndex].bIsSelf == true then 
                ResMgr.showErr(2900088)
            else 
                self._heros[curIndex].state = HERO_STATE.unselected 
                self._heros[curIndex].pos = -1 
                local bBreak = false
                for k, v in ipairs(self._groupHerosData[self._viewType]) do
                    for i = 1, 5 do
                        if v[i] then 
                            if v[i].id == self._heros[curIndex].id then
                                self._heroList:reloadCell(k - 1, {
                                    itemData = v
                                }) 
                                bBreak = true
                                self._bHasChangeFormation = true 
                            end
                        end
                    end
                    if bBreak then
                        break
                    end
                end
                table.remove(self._formHero, idx)
                self._chooseItemList:resetListByNumChange(#self._formHero)
                self._rootnode["numLabel"]:setString(tostring(#self._formHero))
            end 
        end
    })
    self._chooseItemList:setPosition(0, 0)
    self._rootnode["selectListView"]:addChild(self._chooseItemList)
end


function ChallengeFubenChooseHeroScene:onEnter()
    game.runningScene = self 
end 


function ChallengeFubenChooseHeroScene:onExit()
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end


return ChallengeFubenChooseHeroScene

