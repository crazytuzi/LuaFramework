--[[
 --
 -- add by vicky
 -- 2014.09.09
 --
 --]]

 local ZORDER = 100 
 local listViewDisH = 95 
 local data_item_item = require("data.data_item_item")

local KaifuRewardLayer = class("KaifuRewardLayer", function ()
	return require("utility.ShadeLayer").new()
end)


-- 向服务器端请求开服礼包数据
function KaifuRewardLayer:sendRequest()
    RequestHelper.kaifuReward.getInfo({
        callback = function(data)
            dump(data)
            if data["0"] ~= "" then 
		        dump(data["0"]) 
		    else
		    	self:init(data)
		    end
        end
        })
end


-- 点击领取功能
function KaifuRewardLayer:onReward(cell)  
    RequestHelper.kaifuReward.getReward({
	    day = cell:getDay(), 
	    callback = function(data)
            -- dump(data)
            cell:setRewardEnabled(true)

	        if data["0"] ~= "" then 
	            dump(data["0"]) 
	        else
                table.insert(self._hasRewardDays, cell:getDay())
                
                cell:getReward(self._hasRewardDays)

	            --更新玩家数据
	            game.player:updateMainMenu({silver = data["1"].silver, gold = data["1"].gold})
                PostNotice(NoticeKey.MainMenuScene_Update)

                game.player:setKaifuLibao(game.player:getKaifuLibao() - 1)
                PostNotice(NoticeKey.MainMenuScene_KaifuLibao)

                -- 弹出得到奖励提示框
                local title = "恭喜您获得如下奖励："
                local index = cell:getIdx() + 1 
                local msgBox = require("game.Huodong.RewardMsgBox").new({
                    title = title, 
                    cellDatas = self._cellDatas[index].itemData
                    })

                self:addChild(msgBox, ZORDER)
	        end
	    end
    })
end


-- 点击图标，显示道具详细信息
function KaifuRewardLayer:onInformation(param)
    if self._curInfoIndex ~= -1 then 
        return 
    end 

    local index = param.index 
    self._curInfoIndex = index 

    local iconIdx = param.iconIndex 
    local icon_data = self._cellDatas[index + 1].itemData[iconIdx]
	
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


function KaifuRewardLayer:init(data)
    
    self._curDay = data["1"] 
    -- 需要服务器端返回，领取的奖励有哪些天
    self._hasRewardDays = data["2"] 
    self._giftList = data["3"] 
    self._cellDatas = {} 

    for i, v in ipairs(self._giftList) do
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

        table.insert(self._cellDatas, {
            id = v.id, 
            day = v.day, 
            itemData = itemData
            })
    end

	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height - listViewDisH

    -- 创建
    local function createFunc(index)

    	local item = require("game.Huodong.kaifuReward.KaifuRewardCell").new()
    	return item:create({
            curDay = self._curDay, 
            hasRewardDays = self._hasRewardDays, 
    		viewSize = CCSizeMake(boardWidth, boardHeight), 
            cellData = self._cellDatas[index + 1], 
            rewardListener = handler(self, KaifuRewardLayer.onReward)
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            day = self._cellDatas[index + 1].day, 
            itemData = self._cellDatas[index + 1].itemData
            })
    end

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)


    local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()

    self._ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #self._cellDatas, 
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

    self._ListTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._ListTable)
    self:checkTopCell()
end


-- 默认将可领取奖励的第一天置顶显示
function KaifuRewardLayer:checkTopCell() 
    local minDay_index = 1    -- 可领取的最低等级索引
    local minDay = self._giftList[1].day

    -- 判断是否还有可领取的等级礼包，若有则置顶，否则置顶玩家下次领取的最小等级
    local needTop = false
    for i, v in ipairs(self._giftList) do
        if v.day <= self._curDay then 
            local has = false 
            for j, vl in ipairs(self._hasRewardDays) do 
                if vl == v.day then
                    has = true
                    break
                end
            end
            if not has then needTop = true end 
        end
    end

    if needTop then 
        for i, v in ipairs(self._giftList) do 
            if v.day <= self._curDay and v.day > minDay then
                minDay = v.day
                minDay_index = i
            end
        end

        local function isHasGot(day)
            for i, v in ipairs(self._hasRewardDays) do 
                if v == day then
                    return true
                end
            end
            return false
        end

        for i, v in ipairs(self._giftList) do 
            if v.day <= self._curDay then 
                if not isHasGot(v.day) and v.day < minDay then 
                    minDay = v.day
                    minDay_index = i
                end
            end
        end
    else
        for i, v in ipairs(self._giftList) do 
            if v.day > self._curDay then
                minDay = v.day
                minDay_index = i
                break 
            end
        end
    end

    local cellContentSize = require("game.Huodong.kaifuReward.KaifuRewardCell").new():getContentSize()

    local pageCount = (self._ListTable:getViewSize().height) / cellContentSize.height 
    
    local maxMove = #self._cellDatas - pageCount      -- 4为当前每页显示的个数
    local tmpDayIndex = minDay_index - 1

    if tmpDayIndex > maxMove then tmpDayIndex = maxMove end

    local curIndex = maxMove - tmpDayIndex 

    self._ListTable:setContentOffset(CCPoint(0, -(curIndex * cellContentSize.height)))
end


function KaifuRewardLayer:ctor(data)
    self._curInfoIndex = -1  

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/normal_reward_bg.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer) 
    
	self._rootnode["titleLabel"]:setString("开服礼包")

	self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
                self:removeFromParentAndCleanup(true)
            end, CCControlEventTouchUpInside)

    self:init(data) 
end	

function KaifuRewardLayer:onExit( ... )
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return KaifuRewardLayer
