--[[
 --
 -- add by vicky
 -- 2014.08.07
 --
 --]]


 local ZORDER = 100 
 local listViewDisH = 95 

local LevelRewardLayer = class("LevelRewardLayer", function ()
	return require("utility.ShadeLayer").new()
end)


-- 向服务器端请求用户签到数据
function LevelRewardLayer:sendRequest()
    RequestHelper.levelReward.getInfo({
        callback = function(data)
            dump(data)
            if string.len(data["0"]) > 0 then 
                CCMessageBox(data["0"], "Tip")
            else
                self:init(data)
            end 
        end
        })
end


-- 点击领取功能
function LevelRewardLayer:onReward(cell) 
    -- 判断背包是否已满 （等级礼包不检测背包）
    if self.isFull then 
        self:addChild(require("utility.LackBagSpaceLayer").new({
            bagObj = self.bagObj, 
            callback = function()
                self.isFull = false
            end
            }), ZORDER)
    else 

        RequestHelper.levelReward.getReward({
        level = cell:getLevel(), 
        callback = function(data)
            cell:setRewardEnabled(true) 

            if (string.len(data["0"]) > 0) then 
                show_tip_label(data["0"]) 
            else
                table.insert(self.hasRewardLvs, cell:getLevel())
                
                cell:getReward(self.hasRewardLvs)
                
                -- 弹出得到奖励提示框
                local title = "恭喜您获得如下奖励："
                local index = cell:getIdx() + 1 
                local msgBox = require("game.Huodong.RewardMsgBox").new({
                    title = title, 
                    cellDatas = self.cellDatas[index].itemData
                    })

                self:addChild(msgBox, ZORDER) 

                --更新玩家数据
                game.player:updateMainMenu({silver = data["1"].silver, gold = data["1"].gold})
                PostNotice(NoticeKey.MainMenuScene_Update)

                game.player:setDengjilibao(game.player:getDengjilibao() - 1)

                if self:checkIsCollectAllReward() then 
                    game.player.m_isSHowDengjiLibao = false 
                end

                PostNotice(NoticeKey.MainMenuScene_DengjiLibao) 
            end
        end
        })
    end
end


-- 检测是否已经领取完所有的奖励
function LevelRewardLayer:checkIsCollectAllReward()
    local collectAll = true 
    for _, v in ipairs(self.giftList) do 
        local collect = false 
        for j, vl in ipairs(self.hasRewardLvs) do 
            if v.level == vl then 
                collect = true 
                break 
            end
        end 

        if not collect then 
            collectAll = false 
            break 
        end 
    end

    return collectAll
end


-- 点击图标，显示道具详细信息
function LevelRewardLayer:onInformation(param) 
    if self._curInfoIndex ~= -1 then 
        return 
    end 
    
    local index = param.index 
    self._curInfoIndex = index 

    local iconIdx = param.iconIndex 
    local icon_data = self.cellDatas[index + 1].itemData[iconIdx]

    if icon_data then 
        local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = icon_data.id,
                        type = icon_data.type,
                        name = icon_data.name,
                        describe = icon_data.describe, 
                        endFunc = function()
                            self._curInfoIndex = -1 
                        end
                        })

        self:addChild(itemInfo, ZORDER) 
    end
end


function LevelRewardLayer:init(data)

    local data_item_item = require("data.data_item_item")
    
    self.curLevel = game.player.m_level
    local curLevel_index = 1

    -- 需要服务器端返回，领取的等级奖励有哪些等级
    self.hasRewardLvs = data["1"]
    self.isFull = data["2"]
    self.giftList = data["3"]
    self.bagObj = data["4"]
    self.cellDatas = {}

    for i, v in ipairs(self.giftList) do
        if (self.curLevel <= v.level) then 
        	curLevel_index = i
        end

        local itemData = {}
        for _, j in ipairs(v.item) do 
            local item = data_item_item[j.id]
            local iconType = ResMgr.getResType(j.type)
            if iconType == ResMgr.HERO then 
                item = ResMgr.getCardData(j.id)
            end
            
            table.insert(itemData, {
                id = j.id, 
                type = j.type, 
                name = item.name, 
                iconType = iconType, 
                describe = item.describe, 
                num = j.num or 0
                })
        end

        table.insert(self.cellDatas, {
            id = v.id, 
            level = v.level, 
            itemData = itemData
            })
    end

	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height - listViewDisH 

    -- 创建
    local function createFunc(index)
    	local item = require("game.Huodong.levelReward.LevelRewardCell").new()
    	return item:create({
    		id = index, 
            curLevel = self.curLevel, 
            hasRewardLvs = self.hasRewardLvs, 
            level = self.cellDatas[index + 1].level, 
    		viewSize = CCSizeMake(boardWidth, boardHeight), 
            cellData = self.cellDatas[index + 1], 
            rewardListener = handler(self, LevelRewardLayer.onReward)
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            level = self.cellDatas[index + 1].level, 
            itemData = self.cellDatas[index + 1].itemData
            })
    end

    local cellContentSize = require("game.Huodong.levelReward.LevelRewardCell").new():getContentSize()

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)


    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #self.cellDatas, 
        cellSize    = cellContentSize,
        touchFunc = function(cell)
            local idx = cell:getIdx()
            for i = 1, 4 do
                local icon = cell:getIcon(i)
                local pos = icon:convertToNodeSpace(ccp(posX, posY))
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                    self:onInformation({
                        index = idx,
                        iconIndex = i
                    })
                    break
                end
            end
        end
    })

    self.ListTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self.ListTable)
    self:checkTopCell()
end


-- 默认将可领取奖励的最低等级置顶显示
function LevelRewardLayer:checkTopCell()
    local minLevel_index = 1    -- 可领取的最低等级索引
    local minLevel = self.giftList[1].level

    -- 判断是否还有可领取的等级礼包，若有则置顶，否则置顶玩家下次领取的最小等级
    local needTop = false
    for i, v in ipairs(self.giftList) do
        if v.level <= self.curLevel then 
            local has = false 
            for j, vl in ipairs(self.hasRewardLvs) do 
                if vl == v.level then
                    has = true
                    break
                end
            end
            if not has then needTop = true end 
        end
    end

    if needTop then 
        for i, v in ipairs(self.giftList) do 
            if v.level <= self.curLevel and v.level > minLevel then
                minLevel = v.level
                minLevel_index = i
            end
        end

        local function isHasGot(level)
            for i, v in ipairs(self.hasRewardLvs) do 
                if v == level then
                    return true
                end
            end
            return false
        end

        for i, v in ipairs(self.giftList) do 
            if v.level <= self.curLevel then 
                if not isHasGot(v.level) and v.level < minLevel then 
                    minLevel = v.level
                    minLevel_index = i
                end
            end
        end
    else
        for i, v in ipairs(self.giftList) do 
            if v.level > self.curLevel then
                minLevel = v.level
                minLevel_index = i
                break
            end
        end
    end

    -- dump(minLevel)
    -- dump(minLevel_index)

    local cellContentSize = require("game.Huodong.levelReward.LevelRewardCell").new():getContentSize()

    local pageCount = (self.ListTable:getViewSize().height) / cellContentSize.height

    local maxMove = #self.cellDatas - pageCount     -- 3.5为当前每页显示的个数
    local tmpLevelIndex = minLevel_index - 1

    if tmpLevelIndex > maxMove then tmpLevelIndex = maxMove end

    local curIndex = maxMove - tmpLevelIndex

    self.ListTable:setContentOffset(CCPoint(0, -(curIndex * cellContentSize.height)))
end


function LevelRewardLayer:ctor(data)
	local proxy = CCBProxy:create()
	self._rootnode = {}

    self._curInfoIndex = -1  

	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer)
	
	self._rootnode["titleLabel"]:setString("等级礼包") 

	self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
                sender:runAction(transition.sequence({
                CCCallFunc:create(function()
                    --layer:removeSelf()
                    self:removeFromParentAndCleanup(true)
                end)
            }))
            end,
            CCControlEventTouchUpInside)

    self:init(data)
end	

function LevelRewardLayer:onExit( ... )
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return LevelRewardLayer