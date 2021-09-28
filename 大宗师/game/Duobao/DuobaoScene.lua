--[[
 --
 -- add by vicky
 -- 2014.08.13
 --
 --]]



local OPENLAYER_ZORDER = 1001

local MOVE_OFFSET = display.width / 3
local SHOWTYPE = {
    NONE        = 0,
    NEIGONG     = 1,
    WAIGONG     = 2
}


local DuobaoScene = class("DuobaoScene", function()
    return require("game.BaseScene").new({
        contentFile = "duobao/duobao_bg.ccbi",
        subTopFile = "duobao/duobao_up_tab.ccbi",
        bgImage = "bg/duobao_bg.jpg",
        topFile = "public/top_frame_other.ccbi",
        isOther = true,
        scaleMode = 1
    })
end)


-- 获取内外功列表
function DuobaoScene:sendReq()
    RequestHelper.Duobao.getNeiWaiGongList({
        callback = function(data)
            dump(data)
            if string.len(data["0"]) > 0 then
                CCMessageBox(data["0"], "Tip")
            else
                self:createDataList(data)

                if not self._isHasInit then
                    self._isHasInit = true

                    self:init(data)
                else
                    self:selectedTab(self._showType)
                    local index = self:getIndexById(self._showType, self._curItemNodeId)
                    self:reSetShowType(self._showType, index)
                end
            end
        end
    })
end


-- 请求合成 
function DuobaoScene:synthReq(param) 
    self:setAllBtnEnabled(false) 

    RequestHelper.Duobao.synth({
        id = param.id,
        t = param.t,
        errback = function(data) 
            self:setAllBtnEnabled(true) 
            ResMgr.removeMaskLayer() 
        end, 
        callback = function(data) 
            dump(data) 
            if data["0"] ~= "" then 
                dump(data["0"]) 
                self:setAllBtnEnabled(true) 
                ResMgr.removeMaskLayer() 
            else 
                if data["3"] then
                    self:addChild(require("utility.LackBagSpaceLayer").new({
                        bagObj = data["4"],
                    }), 100) 

                    self:setAllBtnEnabled(true) 
                    return
                end 

                self._rootnode["mixAllBtn"]:setVisible(false)

                local itemId = data["1"]
                local itemNum = data["2"]
                for _, v in ipairs(self._curItemList[self._index].debris) do
                    v.num = v.num - itemNum
                    if v.num < 0 then v.num = 0 end
                end

                self._currentItemNode:refreshItem({
                    index = self._index,
                    itemData = self._curItemList[self._index]
                })

                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_duobaohecheng))
                -- 加特效，特效完成之后弹出详细信息界面 
                local effect = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT,
                    armaName = "lianhuatexiao",
                    isRetain = false,
                    finishFunc = function()
                        show_tip_label("成功合成")
                        self:detailInfo(itemId, self._showType, true)
                        ResMgr.removeMaskLayer()
                    end
                })
                self._currentItemNode:getAnimEffectNode():addChild(effect, 1000)
            end
        end
    })
end


function DuobaoScene:setAllBtnEnabled(bEnabled) 
    self:setBottomBtnEnabled(bEnabled) 
    self:setScrollEnabled(bEnabled) 
    self._rootnode["touchNode"]:setTouchEnabled(bEnabled) 
    self._rootnode["mixBtn"]:setEnabled(bEnabled) 
    self._rootnode["mixAllBtn"]:setEnabled(bEnabled) 
    self._rootnode["backBtn"]:setEnabled(bEnabled) 
    self._rootnode["avoidWarBtn"]:setEnabled(bEnabled) 
    self._currentItemNode:setItemTouchEnabled(bEnabled) 

    for i = 1, 2 do 
        self._rootnode["tab" ..tostring(i)]:setEnabled(bEnabled) 
    end 

end


-- 道具icon列表
function DuobaoScene:createDuobaoIconList(showType)
    self._curItemList = self._neiList
    if (showType == SHOWTYPE.WAIGONG) then
        self._curItemList = self._waiList
    end

    local boardWidth = self._rootnode["iconListView"]:getContentSize().width
    local boardHeight = self._rootnode["iconListView"]:getContentSize().height

    local function createFunc(index)
        local item = require("game.Duobao.DuobaoIconCell").new()
        return item:create({
            id = self._curItemList[index + 1].id,
            type = self._curItemList[index + 1].type,
            viewSize = CCSizeMake(boardWidth, boardHeight)
        })
    end

    local function refreshFunc(cell, index)
        dump(self._curItemList)
        index = index + 1
        cell:refresh({
            id = self._curItemList[index].id,
            type = self._curItemList[index].type,
        })
    end

    if(self._ListTable ~= nil) then
        self._ListTable:removeFromParentAndCleanup(true)
    end

    local cellContentSize = require("game.Duobao.DuobaoIconCell").new():getContentSize()

    self._ListTable = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight),
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum   	= #self._curItemList,
        cellSize    = cellContentSize,
        touchFunc   = function(cell)
            cell:selected()
            self._index = cell:getIdx() + 1
            self._curItemNodeId = self._curItemList[self._index].id

            self._currentItemNode:refreshItem({
                index = self._index,
                itemData = self._curItemList[self._index]
            })
        end
    })

    self._ListTable:setPosition(0, 0)
    self._rootnode["iconListView"]:addChild(self._ListTable)
end


function DuobaoScene:checkSnatchBtn(itemList)
    -- 判断是否隐藏“合成”、“全部合成”按钮
    local debris = itemList.debris
    local canMixAll = 1
    for _, v in ipairs(debris) do
        if v.num <= 1 then
            canMixAll = 0
            break
        end
    end

    if canMixAll == 1 then
        self._rootnode["mixAllBtn"]:setVisible(true)
    end

    self._rootnode["mixBtn"]:setVisible(true)
end


function DuobaoScene:detailInfo(id, showType, isRefresh)
    self._rootnode["touchNode"]:setTouchEnabled(false)

    self:addChild(require("game.Duobao.DuobaoItemInfoLayer").new({
        id = id,
        confirmListen = function()
            self._rootnode["touchNode"]:setTouchEnabled(true)
            self:setAllBtnEnabled(true) 
            if isRefresh then 
                self:onEnter()
            end
        end
    }), OPENLAYER_ZORDER)
end


-- 抢夺碎片成功后，更新现有碎片的数量
function DuobaoScene:updateDuobaoItem(param)
    local debrisId = param.debrisId
    local index = -1
    local bFind = false
    local type = SHOWTYPE.NONE

    local function findDebris(ctype)
        local list = self._neiList
        if ctype == SHOWTYPE.WAIGONG then
            list = self._waiList
        end

        for i, v in ipairs(list) do
            if not bFind then
                for j, vd in ipairs(v.debris) do
                    if vd.id == debrisId then
                        dump("find")
                        vd.num = vd.num + param.num
                        index = i
                        bFind = true
                        type = ctype
                        break
                    end
                end
            end
        end
    end

    findDebris(SHOWTYPE.NEIGONG)
    findDebris(SHOWTYPE.WAIGONG)

    -- 判断是否是当前显示的碎片，若是则更新碎片的数量和颜色
    if bFind then
        if type == self._showType and index == self._index then
            if self._currentItemNode ~= nil then
                self._currentItemNode:refreshItem({
                    index = self._index,
                    itemData = self._curItemList[self._index]
                })
            end
        end
    end
end


function DuobaoScene:updateMixAllBtn(showMixAll)
    if showMixAll then
        self._rootnode["mixAllBtn"]:setVisible(true)
    else
        self._rootnode["mixAllBtn"]:setVisible(false)
    end
end


-- 道具详细列表
function DuobaoScene:createDuobaoItem(showType, index)
    self._index = index
    self._curItemList = self._neiList
    if (showType == SHOWTYPE.WAIGONG) then
        self._curItemList = self._waiList
    end

    self._curItemNodeId = self._curItemList[self._index].id

    self:checkSnatchBtn(self._curItemList[self._index])

    local touchNode = self._rootnode["touchNode"]
    local boardWidth = touchNode:getContentSize().width
    local boardHeight = touchNode:getContentSize().height

    if(self._currentItemNode ~= nil) then
        self._currentItemNode:removeFromParentAndCleanup(true)
        self._currentItemNode = nil
    end

    touchNode:setTouchEnabled(true)

    self._currentItemNode = require("game.Duobao.DuobaoItem").new({
        index = self._index,
        viewSize = CCSizeMake(boardWidth, boardHeight),
        itemData = self._curItemList[self._index],
        -- itemUpdateListener = handler(self, DuobaoScene.updateDuobaoItem),
        updateMixAllBtn  = handler(self, DuobaoScene.updateMixAllBtn),
        getMianzhanTime = function()
            return self._warFreeTime
        end
    })

    touchNode:addChild(self._currentItemNode)

    local duobaoCellBtn = self._currentItemNode:getTutoBtn()
    TutoMgr.addBtn("duobao_item",duobaoCellBtn)
    TutoMgr.addBtn("duobao_hecheng_btn",self._rootnode["mixBtn"])
    TutoMgr.addBtn("zhujiemian_btn_zhenrong",self._rootnode["formSettingBtn"])

    local waigongBtn = self._currentItemNode:getWaiGongTutoBtn()
    TutoMgr.addBtn("waigong_item",waigongBtn)
    TutoMgr.addBtn("waigong_tag",self._rootnode["tab2"])
    self:regLockNotice()

    TutoMgr.active()
    self.isAllTouchItem = true

    local targPosX, targPosY
    local offsetX = 0
    local bTouch
    local bMoved = false  

    local function moveToTargetPos()
        self._currentItemNode:runAction(transition.sequence({
            CCMoveTo:create(0.1, ccp(targPosX, targPosY)),
            CCDelayTime:create(0.15),
            CCCallFunc:create(function()
                bMoved = false
            end)
        }))
    end

    local function resetItemImage(side)
        if side  == 1 then --左滑动
            self._currentItemNode:setPosition(display.width * 1.5, targPosY)
        elseif side == 2 then  --右滑动
            self._currentItemNode:setPosition(-display.width * 0.5, targPosY)
        end

        self._currentItemNode:runAction(transition.sequence({
            CCMoveTo:create(0.1, ccp(targPosX, targPosY)),
            CCDelayTime:create(0.15),
            CCCallFunc:create(function()
                bMoved = false
            end)
        }))
    end

    local function onTouchBegan(event) 
        if not bMoved then
            local touchSize = self._currentItemNode:getCanTouchSize()
            local cntSz = self._currentItemNode:getContentSize()
            local point = self._currentItemNode:convertToNodeSpaceAR(ccp(event.x, event.y))
            if (CCRectMake((cntSz.width - touchSize.width)/2, (cntSz.height - touchSize.height)/2, touchSize.width, touchSize.height):containsPoint(point)) then
                bTouch = true
                bMoved = true
            end

            local sz = touchNode:getContentSize()
            if (CCRectMake(0, 0, sz.width, sz.height):containsPoint(touchNode:convertToNodeSpace(ccp(event.x, event.y)))) then
                targPosX, targPosY = self._currentItemNode:getPosition()

                offsetX = event.x
                bMoved = true
                return true
            end
        else
            return false
        end
    end

    local function onTouchMove(event)
        if self._bScrollEnabled ~= false then
            local posX, posY = self._currentItemNode:getPosition()
            self._currentItemNode:setPosition(posX + event.x - event.prevX, posY)
        end

        if math.abs(event.x - event.prevX) > 8 then
            bTouch = false
        end
    end

    local function onTouchEnded(event)
        if self._bScrollEnabled ~= false then
            offsetX = event.x - offsetX
            if offsetX >= MOVE_OFFSET  then
                if self._index > 1 then
                    self._index = self._index - 1
                    self._currentItemNode:refreshItem({
                        index = self._index,
                        itemData = self._curItemList[self._index]
                    })
                    resetItemImage(2)
                else
                    moveToTargetPos()
                end
            elseif offsetX <= -MOVE_OFFSET then
                if self._index < #self._curItemList then
                    self._index = self._index + 1
                    self._currentItemNode:refreshItem({
                        index = self._index,
                        itemData = self._curItemList[self._index]
                    })
                    resetItemImage(1)
                else
                    moveToTargetPos()
                end
            else
                moveToTargetPos()
            end

            if(offsetX >= MOVE_OFFSET or offsetX <= -MOVE_OFFSET) then
                self:checkSnatchBtn(self._curItemList[self._index])
            end
        end

        if bTouch then
            bTouch = false
            bMoved = false
            local id = self._curItemList[self._index].id
            self:detailInfo(id, self._showType, false)
        end

        self._curItemNodeId = self._curItemList[self._index].id
    end

    if not self._hasAddListen then
        touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                return onTouchBegan(event)
            elseif event.name == "moved" then
                onTouchMove(event)
            elseif event.name == "ended" then
                if self.isAllTouchItem == true then
                    onTouchEnded(event)
                end
            end
        end)
        self._hasAddListen = true
    end
end

function DuobaoScene:setScrollEnabled(b)
    self._bScrollEnabled = b
end

function DuobaoScene:regLockNotice()

        RegNotice(self,
        function()
            self:setScrollEnabled(false)
        end,
        NoticeKey.LOCK_TABLEVIEW)

        RegNotice(self,
        function()
            self:setScrollEnabled(true)
        end,
        NoticeKey.UNLOCK_TABLEVIEW)

end

function DuobaoScene:unLockNotice()
    UnRegNotice(self,NoticeKey.LOCK_TABLEVIEW)
    UnRegNotice(self,NoticeKey.UNLOCK_TABLEVIEW)
end


function DuobaoScene:initNeiWaiGongList(param)
    local ary = param.ary
    local aryType = param.aryType

    local data_item_item = require("data.data_item_item")

    for _, v in ipairs(ary) do
        local debris = {}

        local neiItem = data_item_item[v.id]

        for j, vd in ipairs(neiItem.para1) do
            for k, num in pairs(v.items) do
                local id = checkint(k)
                if id == vd then
                    local item = data_item_item[id]
                    table.insert(debris, {
                        id = id,
                        num = num,
                        type = item.type,
                        name = item.name,
                        describe = item.describe
                    })
                end
            end
        end

        if(aryType == SHOWTYPE.NEIGONG) then
            table.insert(self._neiList, {
                id = v.id,
                type = neiItem.type,
                name = neiItem.name,
                debris = debris,
                posX = neiItem.posX or 0,
                posY = neiItem.posY or 0
            })
        elseif(aryType == SHOWTYPE.WAIGONG) then
            table.insert(self._waiList, {
                id = v.id,
                type = neiItem.type,
                name = neiItem.name,
                debris = debris,
                posX = neiItem.posX or 0,
                posY = neiItem.posY or 0
            })
        end
    end
end


function DuobaoScene:createDataList(data)
    -- 金币数
    self._gold = data["1"].gold
    -- 免战牌数
    self._warFreeCnt = data["1"].warFreeCnt
    -- 免战时间
    self._warFreeTime = data["1"].warFreeTime
    -- 耐力值
    self._resis = data["1"].resis
    -- 耐力丹数
    self._resisCnt = data["1"].resisCnt

    -- 内功列表
    local neiAry = data["2"]
    self._neiList = {}
    self:initNeiWaiGongList({
        ary = neiAry,
        aryType = SHOWTYPE.NEIGONG
    })

    -- 外功列表
    local waiAry = data["3"]
    self._waiList = {}
    self:initNeiWaiGongList({
        ary = waiAry,
        aryType = SHOWTYPE.WAIGONG
    })
end


-- 检测id所在的index
function DuobaoScene:getIndexById(showType, id)
    local curItemList = self._neiList
    if showType == SHOWTYPE.WAIGONG then
        curItemList = self._waiList
    end

    dump(curItemList)

    local index = 1
    dump("showType: " .. showType)
    dump("id: " .. id)

    for i, v in ipairs(curItemList) do
        if id == v.id then
            index = i
            break
        end
    end

    dump("index: " .. index)
    return index
end


function DuobaoScene:init()
    self._index = 1
    self._showType = SHOWTYPE.NEIGONG

    if self._warFreeTime > 0 then
        self._rootnode["mianzhanLbl"]:setVisible(true)
        self._rootnode["mianzhanLbl"]:setString("免战剩余时间：" .. format_time(self._warFreeTime))
    end

    self:initTimeSchedule()

    self:createTab()
end


function DuobaoScene:createMianzhanTimeInfo(time, curGold, curWarFreeCnt)
    self._warFreeTime = time
    if (self._warFreeTime > 0) then
        self._rootnode["mianzhanLbl"]:setVisible(true)
        self._rootnode["mianzhanLbl"]:setString("免战剩余时间：" .. format_time(self._warFreeTime))
        self._gold = curGold
        self._warFreeCnt = curWarFreeCnt
    end
end


function DuobaoScene:initTimeSchedule()
    self:schedule(function()
        if (self._warFreeTime > 0) then
            self._warFreeTime = self._warFreeTime - 1
            self._rootnode["mianzhanLbl"]:setString("免战剩余时间：" .. format_time(self._warFreeTime))
        else
            self._rootnode["mianzhanLbl"]:setVisible(false)
        end
    end, 1)
end


function DuobaoScene:reSetShowType(showType, index)
    self._showType = showType
    self:createDuobaoItem(self._showType, index)
    self:createDuobaoIconList(self._showType)

end


function DuobaoScene:selectedTab(tag)
    if tag == 2 then
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
    end

    for i = 1, 2 do
        if tag == i then
            self._rootnode["tab" ..tostring(i)]:selected()
            self._rootnode["btn" ..tostring(i)]:setZOrder(10)
        else
            self._rootnode["tab" ..tostring(i)]:unselected()
            self._rootnode["btn" ..tostring(i)]:setZOrder(0)
        end
    end
end


function DuobaoScene:createTab()
    local function onTabBtn(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
        self:selectedTab(tag)
        self:reSetShowType(tag, 1)
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 2 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
        self:selectedTab(1)
    end

    initTab()
    onTabBtn(SHOWTYPE.NEIGONG)
end


function DuobaoScene:ctor()
    self.isAllTouchItem = false
    self._bScrollEnabled = true  

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
    end,
        CCControlEventTouchUpInside)
    ResMgr.createBefTutoMask(self)

    -- 免战
    local avoidWarBtn = self._rootnode["avoidWarBtn"]
    avoidWarBtn:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        avoidWarBtn:setEnabled(false)
        game.runningScene:addChild(require("game.Duobao.DuobaoMianzhanInfo").new({
            warFreeCnt = self._warFreeCnt,
            gold = self._gold,
            callback = handler(self, DuobaoScene.createMianzhanTimeInfo),
            closeFunc = function()
                avoidWarBtn:setEnabled(true)
            end
        }), 100)
    end, CCControlEventTouchUpInside)

    -- 合成
    local mixBtn = self._rootnode["mixBtn"]
    local mixAllBtn = self._rootnode["mixAllBtn"]

    mixBtn:setVisible(false)
    mixAllBtn:setVisible(false)

    local function mixFunc(mixAll)
        local t = "1"
        if mixAll then
            t = "2"
        end

        local canMix = true
        local debris = self._curItemList[self._index].debris
        for _, v in ipairs(debris) do
            if v.num <= 0 then
                canMix = false
                break
            end
        end

        if canMix then
            self:synthReq({
                id = self._curItemList[self._index].id,
                t = t
            })
        else
            show_tip_label("碎片不足")
            if mixAll then
                mixAllBtn:setEnabled(true)
            else
                mixBtn:setEnabled(true)
            end
        end
    end

    mixBtn:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        mixBtn:setEnabled(false)
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        mixFunc(false)
    end, CCControlEventTouchUpInside)

    mixAllBtn:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        mixAllBtn:setEnabled(false)
        mixFunc(true)
    end, CCControlEventTouchUpInside)

    self._curItemNodeId = -1
    self._isHasInit = false
    self._hasAddListen = false
    self._bExit = false

end


function DuobaoScene:onEnter()
    game.runningScene = self
    GameAudio.playMainmenuMusic(true)

    self:sendReq()

    self:regNotice()
        PostNotice(NoticeKey.UNLOCK_BOTTOM)
    PostNotice(NoticeKey.CommonUpdate_Label_Naili)
    PostNotice(NoticeKey.CommonUpdate_Label_Tili)

    -- 广播
    if self._bExit then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"]
        if game.broadcast:getParent() ~= nil then
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

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

end


function DuobaoScene:onExit()
    TutoMgr.removeBtn("duobao_item")
    TutoMgr.removeBtn("duobao_hecheng_btn")
    TutoMgr.removeBtn("zhujiemian_btn_zhenrong")
    TutoMgr.removeBtn("waigongBtn")
    TutoMgr.removeBtn("waigong_tag")
    self._bExit = true
    self:unscheduleUpdate()
    self:unregNotice()
    self:unLockNotice()
end


return DuobaoScene