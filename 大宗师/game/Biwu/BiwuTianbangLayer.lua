--
-- Author: Daneil
-- Date: 2015-01-15 22:13:07
--
local ZORDER = 100 
local BiwuTianbangLayer = class("BiwuTianbangLayer", function ()
    return display.newLayer("BiwuTianbangLayer")
end)

--初始化界面
function BiwuTianbangLayer:setUpView(param)
    
    --测试数据
    --顶部区域
    local titleBng = display.newSprite("#arena_msg_bg.png")
    local titleBng = display.newScale9Sprite("#arena_msg_bg.png", 0, 0, 
                            cc.size(param.size.width, 
                                param.size.height * 0.1))
                            :pos(param.size.width /2 - 30, param.size.height * 0.92)
    titleBng:setAnchorPoint(cc.p(0.5,1))
    titleBng:setPosition(cc.p(param.size.width * 0.5 , param.size.height * 0.98))
    self:addChild(titleBng)

    local text1 = "排名前十的玩家会进入天榜。"
    local text2 = "排名前20的玩家可直接对天榜内的玩家进行挑战，成功可得大量积分。"
    local txt1 = ui.newTTFLabel({text = text1, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 20,color = ccc3(99,47,8)})
    	:pos(titleBng:getContentSize().width * 0.02,titleBng:getContentSize().height * 0.5)
    	:addTo(titleBng)
    local txt2 = ui.newTTFLabel({text = text2, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 20,color = ccc3(99,47,8)})
    	:pos(titleBng:getContentSize().width * 0.02,titleBng:getContentSize().height * 0.1)
    	:addTo(titleBng)
    txt1:setAnchorPoint(cc.p(0,0))	
    txt2:setAnchorPoint(cc.p(0,0))	

    -- 创建
    local function createFunc(index)

        local item = require("game.Biwu.BiwuTianbangItem").new()
        return item:create({
            viewSize = cc.size(param.size.width,param.size.width / 3.1), 
            rewardListener = handler(self, BiwuTianbangLayer.onRefresh),
            data = self._data[index + 1],
            rank = self._rank,
            times = self._timeLeft,
            roleid = self._roleid,
            })
    end

    -- 刷新
    local function refreshFunc(cell, index)
        cell:refresh({ 
        	viewSize = cc.size(param.size.width,param.size.width / 3.1), 
            rewardListener = handler(self, BiwuTianbangLayer.onRefresh),
            data = self._data[index + 1],
            rank = self._rank,
            times = self._timeLeft,
            roleid = self._roleid,
			})
    end

    local boardWidth  = param.size.width
    local boardHeight = param.size.height 
    self._tableView = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight - titleBng:getContentSize().height - 30), 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum     = #self._data, 
        cellSize    = cc.size(boardWidth,param.size.width / 3.1)
        })

    self._tableView:setPosition(0, 0)
    self._tableView:setAnchorPoint(cc.p(0,0))
    self:addChild(self._tableView)
end

function BiwuTianbangLayer:ctor(param)
    self:setContentSize(param.size)
	local func = function ()
		self:setUpView(param)
	end
	self:_getData(func)
end 

function BiwuTianbangLayer:remove()
	self:removeFromParent()
end

function BiwuTianbangLayer:onRefresh()
	
end

function BiwuTianbangLayer:_getData(func)
	local function initData(data)
		self._data = {}
		for k,v in pairs(data.list) do
			table.insert(self._data,v)
		end
	    self._rank = data.self.rank
	    self._roleid = data.self.roleId
	    self._timeLeft = data.self.challengeTimes
		func()
	end
	RequestHelper.biwuSystem.getTianbangList({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
	
end

return BiwuTianbangLayer

