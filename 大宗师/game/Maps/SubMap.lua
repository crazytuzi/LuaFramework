 --[[
 --
 -- @authors shan 
 -- @date    2014-05-13 13:54:41
 -- @version 
 --
 --]]
-- local SubMapList = import(".SubMapList")

local data_battle_battle = require("data.data_battle_battle")
local data_item_item = require("data.data_item_item")
local data_field_field = require("data.data_field_field")
local data_world_world =  require("data.data_world_world") 

local OPENLAYER_ZORDER = 10001
local NEWLEVEL_ZORDER = OPENLAYER_ZORDER + 3 
local EFFECT_TAG = 11 


local CommonButton = require("utility.CommonButton")


local SubMap = class("SubMap", function() 
        -- display.removeUnusedSpriteFrames()
    return require("game.BaseScene").new({
            topFile = "public/top_frame_other.ccbi", 
            contentFile = "fuben/sub_map_layer.ccbi", 
            isOther = true, 
            isHideBottom = true  
        })
end)


local function calSubmapStar(id)
     local num = 0
     if data_field_field[id] then
        for k, v  in ipairs(data_field_field[id].arr_battle) do
            if(v == nil) then
                CCMessageBox(v, "")
            end
            num = num + data_battle_battle[v].star
        end
     end
     return num
end 


function SubMap:ctor(param) 
    
    display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
    -- display.addSpriteFramesWithFile("ui/ui_bigmap_cloud.plist", "ui/ui_bigmap_cloud.png")

    self.battleId =  param.battleId
    
    game.runningScene = self 

    ResMgr.createBefTutoMask(self)

    local subMap = param.subMap 
    local subMapID = param.submapID 

    self.isRefreshList =  param.isRefresh
    game.player.m_cur_normal_fuben_ID = subMapID 

    -- 当前关卡，包含多少个小关卡，关卡奖励 
    self.subMapInfo = data_field_field[subMapID] 
    local curBigMapID = self.subMapInfo.world  

    -- 背景图片 
    self._bg = display.newSprite("ui/jpg_bg/bigmap/" .. data_world_world[curBigMapID].background .. ".jpg")
    self._bg:setPosition(display.cx, display.cy) 
    self:addChild(self._bg, -10) 

    if subMap ~= nil then 
        self:initLevelInfo(subMap) 
    end 

    -- 关卡列表 
    local listViewNode = self._rootnode["listView_node"] 
    local listHeigt = self:getCenterHeight() - self._rootnode["bottom_node"]:getContentSize().height - self._rootnode["top_node"]:getContentSize().height 
    local listSize = CCSizeMake(listViewNode:getContentSize().width * 0.95, listHeigt) 
    self._listViewSize = CCSizeMake(listSize.width, listSize.height * 0.97)

    local listBg = display.newScale9Sprite("#submap_bg.png", 0, 0, listSize) 
    listBg:setAnchorPoint(0.5, 0) 
    listBg:setPosition(listViewNode:getContentSize().width/2, 0) 
    listViewNode:addChild(listBg) 

    self._listViewNode = display.newNode() 
    self._listViewNode:setContentSize(self._listViewSize) 
    self._listViewNode:setAnchorPoint(0.5, 0) 
    self._listViewNode:setPosition(listViewNode:getContentSize().width/2, listSize.height * 0.01)
    listViewNode:addChild(self._listViewNode) 

    local LvIcon = self._rootnode["level_icon"] 
    LvIcon:setDisplayFrame(display.newSprite("lvl/".. self.subMapInfo.icon  ..".png"):getDisplayFrame()) 
    self._rootnode["level_name_lbl"]:setString(data_field_field[subMapID].name) 
    self._rootnode["level_name_lbl"]:setPositionX(LvIcon:getContentSize().width * LvIcon:getScaleX() + 10) 

    self._rootnode["backBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true then
            if TutoMgr.notLock() then
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                display.replaceScene(require("game.Maps.BigMap").new(curBigMapID))
            end
        end
    end, CCControlEventTouchUpInside)

    self._rootnode["zhenrongBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true then
            if TutoMgr.notLock() then
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
                local formCtrl = require("game.form.FormCtrl")
                formCtrl.createFormSettingLayer({
                    parentNode = game.runningScene,
                    touchEnabled = true,
                })
            end
        end
    end, CCControlEventTouchUpInside) 

    TutoMgr.addBtn("submap_back_btn",self._rootnode["backBtn"])


    self:getSubLevelList(subMapID)

    self.subMapID  = subMapID


    -- 速度提升
    -- local function initsubmapinfoRes( ... )
    --     local proxy = CCBProxy:create()
    --     local rootnode = {}
    --     local levelBoard = CCBuilderReaderLoad("ccbi/battle/level_grade.ccbi", proxy, rootnode)
    --     local node = CCBuilderReaderLoad("fuben/sub_map_info.ccbi", proxy, rootnode)
    -- end
    -- initsubmapinfoRes()
end

function SubMap:update()

    self._scrollItemList = nil 
    self:getSubLevelList(self.subMapID)
    -- self:getSubLevelList(self.subMapID)
end


function SubMap:initLevelInfo(subMap) 
    local TILE_WIDTH = 32
    local TILE_HEIGHT = 32 
    local maxZorder = 10

    local i = 0
    for k, v in pairs(subMap) do 
        local submapID = checkint(k)

        local subMapData = data_field_field[checkint(k)]
        local buildBtn = require("utility.CommonButton").new({
            img = "lvl/".. subMapData.icon  ..".png",
            listener = function ()
            end
            })
        buildBtn:setTouchEnabled(false) 

        local btnW = buildBtn:getContentSize().width
        local btnH = buildBtn:getContentSize().height
        buildBtn:setPosition(subMapData.x_axis * TILE_WIDTH - btnW/2, subMapData.y_axis * TILE_HEIGHT - btnH/2)
        self._bg:addChild(buildBtn,maxZorder-i)
        i = i + 1

        local nameBg = display.newSprite("lvl/lv_b_name_bg.png")
        nameBg:setPosition(buildBtn:getContentSize().width/2, 0)
        buildBtn:addChild(nameBg, maxZorder) 

        local nameLabel = ui.newTTFLabel({
            text = subMapData.name,
            font = FONTS_NAME.font_fzcy,
            size = 20,
            color = fontColor,
            x = nameBg:getContentSize().width/2,
            y = nameBg:getContentSize().height/2,
            align = ui.TEXT_ALIGN_CENTER
        })
        nameBg:addChild(nameLabel)

        --star
        local star = subMap[tostring(subMapData.id)]            
        local starLabel = ui.newBMFontLabel({
            text = star .. "/" .. data_field_field[subMapData.id].star,
            font = FONTS_NAME.font_property,
            size = 22,
            color = display.COLOR_WHITE,
            x = nameBg:getContentSize().width/2,
            y = -nameBg:getContentSize().height*0.8,
            align = ui.TEXT_ALIGN_CENTER
            })
        nameBg:addChild(starLabel)

        local starIcon = display.newSprite("#bigmap_star.png")
        starIcon:setPosition(nameBg:getContentSize().width*0.65 + starIcon:getContentSize().width/2, -nameBg:getContentSize().height/2)
        nameBg:addChild(starIcon)
    end 
end


-- 底部 关卡奖励相关 
function SubMap:checkLevelReward(subMapID)
    local _curStars = self._subMapInfo["2"].stars 
    local _boxState = self._subMapInfo["2"].box 

    -- 初始化关卡相关奖励 
    if self._allLevelReward == nil then 
        self._allLevelReward = {} 
        for i = 1, 3 do 
            local star 
            local arrReward 
            local arrNum 
            if i == 1 then
                star = self.subMapInfo.star1
                arrReward = self.subMapInfo.arr_reward1
                arrNum = self.subMapInfo.arr_num1
            elseif i == 2 then 
                star = self.subMapInfo.star2
                arrReward = self.subMapInfo.arr_reward2
                arrNum = self.subMapInfo.arr_num2
            else
                star = self.subMapInfo.star3
                arrReward = self.subMapInfo.arr_reward3
                arrNum = self.subMapInfo.arr_num3
            end 

            if star ~= nil and arrReward ~= nil and arrNum ~= nil then
                local rewardData = {} 
                for j, v in ipairs(arrReward) do 
                    local item = data_item_item[v]
                    local iconType = ResMgr.getResType(item.type)
                    table.insert(rewardData, {
                        id = item.id, 
                        type = item.type, 
                        name = item.name, 
                        iconType = iconType, 
                        num = arrNum[j] or 0 
                        })
                end

                table.insert(self._allLevelReward, {
                    star = star, 
                    hard = i, 
                    itemData = rewardData
                    })
            end
        end 
    end 

    for i = 1, 3 do  
        if i > #self._allLevelReward then 
            self._rootnode["box_" .. i]:setVisible(false)
        else
            self._rootnode["box_" .. i]:setVisible(true) 

            -- 星星数量
            local boxStarNumLbl = self._rootnode["box_starNum_" .. i] 
            local curNumLbl = ui.newTTFLabelWithOutline({
                text = tostring(self._allLevelReward[i].star),
                size = 22,
                color = ccc3(255, 216, 0), 
                outlineColor = ccc3(43, 6, 0),
                font = FONTS_NAME.font_haibao,
                align = ui.TEXT_ALIGN_LEFT
                })
            
            curNumLbl:setPosition(-curNumLbl:getContentSize().width, 0)
            boxStarNumLbl:removeAllChildren() 
            boxStarNumLbl:addChild(curNumLbl) 

            local boxIcon = self._rootnode["box_icon_" .. i] 
            local state = _boxState[i] 
            if state == 1 then 
                boxIcon:setDisplayFrame(display.newSprite("#submap_box_close_" .. i .. ".png"):getDisplayFrame()) 
            elseif state == 2 then 
                boxIcon:setDisplayFrame(display.newSprite("#submap_box_open_" .. i .. ".png"):getDisplayFrame()) 
                local effect = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT,
                    armaName = "fubenjiangli_shanguang",
                    isRetain = true,
                    finishFunc = function() 
                    end
                    })
                effect:setPosition(boxIcon:getContentSize().width/2, boxIcon:getContentSize().height/2) 
                boxIcon:addChild(effect, 1, EFFECT_TAG) 
            elseif state == 3 then 
                boxIcon:setDisplayFrame(display.newSprite("#submap_box_end_" .. i .. ".png"):getDisplayFrame()) 
            else
                CCMessageBox(state, "服务器端返回的关卡奖励，状态有问题！") 
            end 

            boxIcon:setTouchEnabled(true) 
            boxIcon:removeAllNodeEventListeners()  
            boxIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) 
               
                dump(event)
                -- dump(TutoMgr.isBtnLocked)
                if event.name == "began" then 
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

                    if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true then
                        if TutoMgr.notLock() then   
                      
                            boxIcon:setTouchEnabled(false) 
                            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                            ResMgr.createBefTutoMask(self)
                            local rewardLayer = require("game.Maps.SubmapRewardLayer").new({
                                id = subMapID,  
                                hard = self._allLevelReward[i].hard, 
                                needStar = self._allLevelReward[i].star,  
                                itemData = self._allLevelReward[i].itemData, 
                                bagState = self._subMapInfo["3"], 
                                state = _boxState[i], 
                                updateListener = function(hard) 
                                    self._subMapInfo["2"].box[hard] = 3 
                                    boxIcon:setDisplayFrame(display.newSprite("#submap_box_end_" .. i .. ".png"):getDisplayFrame()) 
                                    boxIcon:removeChildByTag(EFFECT_TAG, true)  
                                end,
                                closeListener = function() 
                                    boxIcon:setTouchEnabled(true)
                                end 
                                })
                            self:addChild(rewardLayer, OPENLAYER_ZORDER)
                        end 
                    end   
                    
                    return true
                elseif event.name == "end" then
                     
                end 
            end)
        end 
    end  
end 




function SubMap:getSubLevelList(id,refreshSubInfoFunc)
    RequestHelper.getSubLevelList({
        callback = function(data)

            if string.len(data["0"]) == 0 then 
                -- 总星星数量
                local tNumLbl = ui.newTTFLabelWithOutline({
                    text = "/" .. tostring(calSubmapStar(id)), 
                    size = 22, 
                    color = ccc3(255, 216, 0), 
                    outlineColor = ccc3(43, 6, 0), 
                    font = FONTS_NAME.font_haibao, 
                    align = ui.TEXT_ALIGN_LEFT 
                    })
                
                tNumLbl:setPosition(-tNumLbl:getContentSize().width, 0)
                local allStarLabel = self._rootnode["allStarLabel"] 
                allStarLabel:removeAllChildren()
                allStarLabel:addChild(tNumLbl)

                -- 当前星星数量
                local curNumLbl = ui.newTTFLabelWithOutline({
                    text = tostring(data["2"].stars),
                    size = 22,
                    color = ccc3(255, 216, 0), 
                    outlineColor = ccc3(43, 6, 0),
                    font = FONTS_NAME.font_haibao,
                    align = ui.TEXT_ALIGN_LEFT
                    })
                
                curNumLbl:setPosition(-curNumLbl:getContentSize().width, 0)
                local curStarLabel = self._rootnode["curStarLabel"] 
                curStarLabel:removeAllChildren() 
                curStarLabel:addChild(curNumLbl) 
                
                local allStarIcon = self._rootnode["allStar_icon"] 
                self._rootnode["curStar_icon"]:setPositionX(allStarIcon:getPositionX() - allStarIcon:getContentSize().width - tNumLbl:getContentSize().width)

                self._subMapInfo = data 
                self:createMapNode() 
                self:checkLevelReward(id) 

                if self.battleId ~= nil then

                    self:removeChildByTag(102)
                    if(self:getChildByTag(102) == nil) then

                        self._infoLayer = require("game.Maps.SubMapInfoLayer").new(data_battle_battle[self.battleId], self._subMapInfo,function()                          
                            self:update()
                            end,
                            function()
                                self._infoLayer:removeSelf()
                                self:refreshRes()
                            end)
                        self:addChild(self._infoLayer,102)
                        self.refreshSubId = data_battle_battle[self.battleId]
                        self.battleId = nil 
                    end
                end

                if refreshSubInfoFunc ~= nil then
                    refreshSubInfoFunc()
                end 


            else
                CCMessageBox("网络错误，请重试！", "Tip")
            end
        end,
        id = id
    })
end

function SubMap:refreshRes()
     self._scrollItemList = nil
    self:getSubLevelList(self.subMapID,function()
            self:refreshSubInfo()
        end)
end


function SubMap:refreshSubInfo()
    -- if(self:getChildByTag(102) == nil) then

    self:removeChildByTag(102, true)
    if(self:getChildByTag(102) == nil) then
        self.dramainfoLayer = require("game.Maps.SubMapInfoLayer").new(self.refreshSubId, self._subMapInfo,
                function()            
                    self:update()
                end,
                function()
                    self.dramainfoLayer:removeSelf()

                   self:refreshRes()
                end)
        self:addChild(self.dramainfoLayer,102)  
        self.refreshSubId = self.refreshSubId
    end
end

function SubMap:createMapNode()

    if self._scrollItemList then
        self._rootnode["infoNode"]:setVisible(true)
        return
    end

    local _data = {}


    for k, v in pairs(self._subMapInfo["1"]) do
        if(tonumber(k) <= game.player.m_maxLevel) then
            table.insert(_data, {
                id = checkint(k),
                cnt = v.cnt,
                star = v.star,
                baseInfo = data_battle_battle[checkint(k)]
            })
        end
    end

    -- 将关卡重新排序，最新关卡在最上面
    table.sort(_data, function(l, r)
        return l.id > r.id
    end)

    -- dump(_data)

    local function onItemDetail(idx)  
        DramaMgr.runDramaBefNpc(_data[idx].baseInfo,function()
                -- ResMgr.createMaskLayer(display.getRunningScene())

                self:removeChildByTag(102)    
                if(self:getChildByTag(102) == nil) then
                    self.dramainfoLayer = require("game.Maps.SubMapInfoLayer").new(_data[idx].baseInfo, self._subMapInfo,
                        function()                            
                            self:update() end,
                        function()
                            self.dramainfoLayer:removeSelf()
                           self:refreshRes()
                        end)
                    if(idx ~= 1 or self._scrollItemList:getCellNum() == #self.subMapInfo.arr_battle) then
                        game.player.submapOffsetId = self.subMapInfo.id
                        game.player:setSubmapOffset(self._scrollItemList:getContentOffset())
                    else
                        game.player:setSubmapOffset(ccp(0,0))
                    end
                    self:addChild(self.dramainfoLayer,102)
                end
                self.refreshSubId = _data[idx].baseInfo
            end) 
    end 
    self._scrollItemList = nil
    self._scrollItemList = require("utility.TableViewExt").new({
        size        = self._listViewSize,
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            local item = require("game.Maps.SubMapScrollCell").new()
            idx = idx + 1
            return item:create({
                viewSize = self._listViewSize,
                itemData = _data[idx],
                idx      = idx,
                mapInfo  = self._subMapInfo,
                onBtn    = function(idx) 
                    if ResMgr.isInSubInfo ~= true and ResMgr.intoSubMap ~= true then
                        ResMgr.isInSubInfo = true 
                        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                        onItemDetail(idx + 1)
                    end
                end
            })
        end,

        refreshFunc = function(cell, idx)
            idx = idx + 1  
            cell:refresh({
                idx = idx,
                itemData = _data[idx], 
                mapInfo = self._subMapInfo 
            })
        end,
        cellNum   = #_data,
        cellSize    = require("game.Maps.SubMapScrollCell").new():getContentSize(),
        touchFunc = function(cell)

            -- local idx = cell:getIdx() + 1
            -- onItemDetail(idx)
        end,
        scrollFunc = function()
             PageMemoModel.saveOffset("submap_"..self.subMapID,self._scrollItemList)
        end
    })

    self._scrollItemList:setPosition(0, 5)

    if self.isRefreshList ~= true then
        PageMemoModel.resetOffset("submap_"..self.subMapID,self._scrollItemList) 
    else
        PageMemoModel.saveOffset("submap_"..self.subMapID,self._scrollItemList)
    end

    -- mark the submap pos for submap list

    -- if (game.player.submapOffsetId == self.subMapInfo.id and game.player:getSubmapOffet().y ~= 0  and self._scrollItemList:getCellNum() > 3) then    

        -- PageMemoModel.resetOffset("submap_"..self.subMapID,self._scrollItemList)  
      
        --     if(self._scrollItemList:getCellNum() * self._scrollItemList:cellAtIndex(1):getContentSize().height > self._scrollItemList:getContentSize().height) then
        --         self._scrollItemList:setContentOffset(game.player:getSubmapOffet())
        --     end

    -- end
    -- self._rootnode["frameBg"]:addChild(self._scrollItemList)
    self._listViewNode:removeAllChildrenWithCleanup(true)
    self._listViewNode:addChild(self._scrollItemList) 

    --新手引导
    local cell
 
    cell = self._scrollItemList:cellAtIndex(0)
    if cell ~= nil then
        local btn = cell:getBtn()
        TutoMgr.addBtn("putongfuben_btn_niujiacunliebiao1", btn)
    end


    TutoMgr.addBtn("submap_baoxiang_box" ,self._rootnode["box_icon_1"])
    TutoMgr.addBtn("submap_btn_zhenrong", self._rootnode["zhenrongBtn"])
    TutoMgr.active()

end 





function SubMap:onEnter()
    game.runningScene = self
    
    local soundName = ResMgr.getSound(data_world_world[self.subMapInfo.world].bgm)
    GameAudio.playMusic(soundName, true)

    local levelName 
    local battleData = game.player:getBattleData() 
    print("battll data")
    dump(battleData) 

    if battleData.new_subMapId > battleData.cur_subMapId then 
        game.player:setBattleData({
            cur_subMapId = battleData.new_subMapId 
            })
        -- 第一个关卡不提示
        if battleData.new_subMapId ~= 1101 then 
            levelName = data_field_field[battleData.new_subMapId].name 
            self:addChild(require("game.Maps.SubmapNewMsg").new("新副本开启！", levelName), NEWLEVEL_ZORDER)
        end 
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

                local function jumpToMainScene()
                    GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
                end 

                ResMgr.createMaskLayer(display.getRunningScene())               

                local openLayer = require("game.OpenSystem.OpenLayer").new({
                    systemId = systemId, 
                    confirmFunc = createOpenLayer, 
                    goFunc = jumpToMainScene, 
                   
                })

                self:addChild(openLayer, OPENLAYER_ZORDER) 
                table.remove(systemIds, 1)
            end 
        end 

        createOpenLayer()
    end 

    self:regNotice() 

    if(GAME_DEBUG == true) then
        ResMgr.showTextureCache(  )
    end
    -- print("rereree   "..self._scrollItemList:getContentOffset().y)
    -- PageMemoModel.resetOffset("submap_"..self.subMapID,self._scrollItemList)
    
end


function SubMap:onExit() 

   
    self:unregNotice() 
    TutoMgr.removeBtn("putongfuben_btn_niujiacunliebiao1")
    TutoMgr.removeBtn("submap_back_btn")    
    TutoMgr.removeBtn("submap_baoxiang_box")

    display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    -- display.removeSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
    -- display.removeSpriteFramesWithFile("ui/ui_bigmap_cloud.plist", "ui/ui_bigmap_cloud.png")
    display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")    
    display.removeSpriteFrameByImageName("fonts/font_title.png")
    
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun1_piaodong/yun_1.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun2_piaodong/yun_2.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun3_piaodong/yun_3.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun4_piaodong/yun_4.png")

    display.removeSpriteFrameByImageName("ccs/ui_effect/yun1_sankai/yun_1.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun2_sankai/yun_2.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun3_sankai/yun_3.png")
    display.removeSpriteFrameByImageName("ccs/ui_effect/yun4_sankai/yun_4.png")

    ResMgr.ReleaseUIArmature("fubenjiangli_shanguang")


    display.removeSpriteFrameByImageName("ui/jpg_bg/bigmap/" .. data_world_world[self.subMapInfo.world].background .. ".jpg")
    display.removeSpriteFrameByImageName("ui/ui_bigmap_cloud.png")

    CCTextureCache:sharedTextureCache():removeUnusedTextures()

    collectgarbage("collect")
end


return SubMap
