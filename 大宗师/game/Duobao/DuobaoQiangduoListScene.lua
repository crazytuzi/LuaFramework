--[[
 --
 -- add by vicky
 -- 2014.08.16
 --
 --]]

 local OPENLAYER_ZORDER = 1111


local DuobaoQiangduoListScene = class("DuobaoQiangduoListScene", function()
    return require("game.BaseScene").new({
        subTopFile = "duobao/duobao_qiangduo_up_tab.ccbi",
        contentFile = "duobao/duobao_qiangduo_bg.ccbi",
        -- bgImage = "bg/duobao_bg.jpg", 
        topFile = "public/top_frame_other.ccbi", 
        isOther = true, 
    })
end)


function DuobaoQiangduoListScene:updateNaiLiLbl()
    self._rootnode["naili_num"]:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
    PostNotice(NoticeKey.CommonUpdate_Label_Naili)
    PostNotice(NoticeKey.CommonUpdate_Label_Tili)
end


function DuobaoQiangduoListScene:snatchAgain(index)
    game.runningScene = self 
    self:startSnatch(index, true) 
end


-- 开始抢夺
function DuobaoQiangduoListScene:startSnatch(index, isSnatchAgain)

    local isNPC = true 
    if self._itemsData[index].type == 1 then isNPC = false end

    local function snatch() 
        -- 是否是由"再抢一次"进入抢夺
        local snatchAgain = false 
        if isSnatchAgain ~= nil then 
            snatchAgain = isSnatchAgain 
        end 

        -- 判断耐力是否足够
        if game.player.m_energy < 2 then
            local layer = require("game.Duobao.DuobaoBuyMsgBox").new({updateListen = handler(self, DuobaoQiangduoListScene.updateNaiLiLbl)})
            game.runningScene:addChild(layer,10000)
            return
        end

        -- 判断背包空间是否足，如否则提示扩展空间 
        local function extendBag(data)
            -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size 
            if self._bagObj[1].curCnt < data["1"] then 
                table.remove(self._bagObj, 1)
            else
                self._bagObj[1].cost = data["4"]
                self._bagObj[1].size = data["5"]
            end

            if #self._bagObj > 0 then 
                self:addChild(require("utility.LackBagSpaceLayer").new({
                    bagObj = self._bagObj, 
                    callback = function(data)
                        extendBag(data)
                    end}), OPENLAYER_ZORDER)
            else
                self._isBagFull = false 
            end
        end

        if self._isBagFull then 
            self:addChild(require("utility.LackBagSpaceLayer").new({
                bagObj = self._bagObj, 
                callback = function(data)
                    extendBag(data)
                end}), OPENLAYER_ZORDER)

            return
        end

        if not isNPC then 
            self._warFreeTime = 0 
        end 

        RequestHelper.Duobao.snatch({
            id = self._debrisId,
            data = self._itemsData[index],
            callback = function(data)
                -- dump(data["6"])
                dump(data) 
                if data["0"] ~= "" then 
                    dump(data["0"]) 
                else 
                    local isSnatch = data["8"] 
                    if isSnatch == 1 then
                        if snatchAgain == true then 
                            pop_scene() 
                        end

                        -- 更新耐力值 
                        game.player:updateMainMenu({naili = game.player.m_energy - data["6"]})
                        self:updateNaiLiLbl() 

                        push_scene(require("game.Duobao.DuobaoBattleScene").new({
                            data = data,
                            resultFunc = function() 
                                self:createResult({
                                    data = data,
                                    name = self._itemsData[index].name,
                                    enemyAcc = self._itemsData[index].acc,
                                    isNPC = isNPC,
                                    title = self._title,
                                    snatchIndex = index,
                                    debrisId = self._debrisId,  
                                    snatchAgain = handler(self, DuobaoQiangduoListScene.snatchAgain)
                                })
                            end
                        }))

                    elseif isSnatch == 2 then
                        -- 不可抢夺，碎片已被抢，刷新列表。提示玩家重新选择
                        show_tip_label("碎片刚刚被其他玩家夺走了，请重新选择目标")
                        self:requestUpdateList()
                    elseif isSnatch == 3 then
                        show_tip_label("对方处于免战时间，请重新选择目标")
                        self:requestUpdateList() 
                    end
                end
            end
        })
    end

    -- 判断自己是否处于免战期间 
    dump("warFreeTime: " .. self._warFreeTime) 

    if not isNPC and self._warFreeTime > 0 then 
        local layer = require("utility.MsgBox").new({
                size = CCSizeMake(500, 250),
                leftBtnName = "取消",
                rightBtnName = "确定",
                content = "免战期间内抢夺其他玩家将会解除免战时间，是否继续抢夺？", 
                leftBtnFunc = function()
                end,
                rightBtnFunc = function() 
                    snatch() 
                end
            })
        self:addChild(layer, OPENLAYER_ZORDER)
    else
        snatch() 
    end 
end


function DuobaoQiangduoListScene:updateDebrisItem()
    -- self._itemUpdateListener({
    --    debrisId = self._debrisId,
    --    num = 1
    --    })
end


function DuobaoQiangduoListScene:createResult(param)
    dump(param)
    game.runningScene:addChild(require("game.Duobao.DuobaoResult").new(param), 3000)
end


function DuobaoQiangduoListScene:requestUpdateList()
    RequestHelper.Duobao.getSnatchList({
        id = tostring(self._debrisId),
        callback = function(data)
            self:updateQiangduoList(data)
        end
    })
end


function DuobaoQiangduoListScene:updateQiangduoList(data)
    if string.len(data["0"]) > 0 then
        CCMessageBox:create(data["0"], "Tip")
        return
    end

    local nailiAry = data["2"] 
    game.player:updateMainMenu({naili = nailiAry[2], maxNaili = nailiAry[3]}) 
    self._rootnode["naili_num"]:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)

    self._itemsData = data["1"] 
    self:createListView()
end


function DuobaoQiangduoListScene:createListView()
    if self._listTable ~= nil then
        self._listTable:removeFromParentAndCleanup(true)
        self._listTable = nil
    end 

    local boardWidth = self._rootnode["listView"]:getContentSize().width
    local boardHeight = self._rootnode["listView"]:getContentSize().height - self._rootnode["top_node"]:getContentSize().height 

    -- 创建
    local function createFunc(index)
        local item = require("game.Duobao.DuobaoQiangduoItem").new()
        local itemData = self._itemsData[index + 1]
        return item:create({
            itemData = itemData,
            viewSize = CCSizeMake(boardWidth, boardHeight), 
            snatchListener = handler(self, DuobaoQiangduoListScene.startSnatch)
        })
    end

    -- 刷新
    local function refreshFunc(cell, index)
        local itemData = self._itemsData[index + 1]
        cell:refresh(itemData)
    end

    local cellContentSize = require("game.Duobao.DuobaoQiangduoItem").new():getContentSize()

    self._listTable = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self._itemsData,
        cellSize    = cellContentSize
    })

    -- self._listTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(self._listTable)


end


function DuobaoQiangduoListScene:ctor(param)
    game.runningScene = self
    dump(param)
    ResMgr.createBefTutoMask(self)

    local _bg = display.newSprite("ui_common/common_bg.png")
    local _bgW = display.width
    local _bgH = display.height - self._rootnode["bottomMenuNode"]:getContentSize().height - self._rootnode["topFrameNode"]:getContentSize().height
    _bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode["bottomMenuNode"]:getContentSize().height)

    _bg:setScaleX(_bgW / _bg:getContentSize().width)
    _bg:setScaleY(_bgH / _bg:getContentSize().height)
    self:addChild(_bg, 0)


    self._debrisId = param.id
    self._itemsData = param.data["1"]
    self._title = param.title
    self._isBagFull = param.data["3"]
    self._bagObj = param.data["4"]
    self._warFreeTime = param.warFreeTime 

    local nailiAry = param.data["2"] 

    game.player:updateMainMenu({naili = nailiAry[2], maxNaili = nailiAry[3]}) 

    self._rootnode["xiaohao_num"]:setString(tostring(math.abs(nailiAry[1])) )
    self._rootnode["naili_num"]:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)

    self._rootnode["backBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        CCDirector:sharedDirector():popToRootScene()
    end, CCControlEventTouchUpInside)

    self._rootnode["changeBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:requestUpdateList()
    end, CCControlEventTouchUpInside)

    self:createListView()

    self:schedule(function()
        if (self._warFreeTime > 0) then 
            self._warFreeTime = self._warFreeTime - 1 
        end
    end, 1) 
end


function DuobaoQiangduoListScene:onExit()
    TutoMgr.removeBtn("qiangduo_board_btn")

    self:unscheduleUpdate()
    self:unregNotice() 
end


function DuobaoQiangduoListScene:onEnter()
    game.runningScene = self 
    GameAudio.playMainmenuMusic(true)  
    self:regNotice()

    self:updateNaiLiLbl() 

    -- 是否开启新系统
    local levelData = game.player:getLevelUpData() 
    if levelData.isLevelUp then 
        local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel) 
        -- dump(systemIds)

        game.player:updateLevelUpData({isLevelUp = false})
        local function createOpenLayer()
            if #systemIds > 0 then 
                local systemId = systemIds[1] 
                self:addChild(require("game.OpenSystem.OpenLayer").new({
                    systemId = systemId, 
                    confirmFunc = createOpenLayer
                }), OPENLAYER_ZORDER) 
                table.remove(systemIds, 1)
            end 
        end 
        createOpenLayer()
    end

    local cell = self._listTable:cellAtIndex(0)
    if cell ~= nil then
        local tutoBtn = cell:getTutoBtn()
        TutoMgr.addBtn("qiangduo_board_btn",tutoBtn)
        
    end
    TutoMgr.active() 
end



return DuobaoQiangduoListScene