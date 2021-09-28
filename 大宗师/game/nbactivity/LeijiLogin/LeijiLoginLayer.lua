--[[
 --
 -- add by vicky
 -- 2014.11.13 
 --
 --]]


 local MAX_ZORDER = 1111 

 local LeijiLoginLayer = class("LeijiLoginLayer", function()
 		return display.newNode()
 	end)


 function LeijiLoginLayer:getStatusData()
    RequestHelper.leijiLogin.getStatusData({
        callback = function(data)
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
            else
                self:initData(data)
            end 
        end
        })
 end 


 function LeijiLoginLayer:ctor(param) 
 	local viewSize = param.viewSize 
    self._rewardDatas = param.rewardDatas 
    dump(param) 

 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	
    local node = CCBuilderReaderLoad("nbhuodong/leijiLogin_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(node) 

    local titleIcon = self._rootnode["title_icon"] 
    local msgNode = self._rootnode["msg_node"] 

    self._rootnode["msg_node"]:setPositionY(titleIcon:getPositionY() - titleIcon:getContentSize().height + 5) 

    local listBgHeight = viewSize.height - titleIcon:getContentSize().height - msgNode:getContentSize().height + 15 
    local listBg = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, CCSize(viewSize.width, listBgHeight))
    listBg:setAnchorPoint(0.5, 0) 
    listBg:setPosition(display.width/2, 0) 
    node:addChild(listBg) 
    self._listViewSize = CCSizeMake(viewSize.width * 0.98, listBgHeight - 25) 

    self._listViewNode = display.newNode() 
    self._listViewNode:setContentSize(self._listViewSize) 
    self._listViewNode:setAnchorPoint(0.5, 0.5) 
    self._listViewNode:setPosition(display.width/2, listBgHeight/2) 
    listBg:addChild(self._listViewNode) 

    self:getStatusData() 
 end 


 function LeijiLoginLayer:initData(data) 
    self._hasGetAry = data.rtnObj.hasGet 
    self._hasLoginDays = data.rtnObj.days  
    local activeTime = data.rtnObj.activeTime 

    self._rootnode["time_lbl_2"]:setString(tostring(self._hasLoginDays)) 

    arrangeTTFByPosX({ 
            -- self._rootnode["time_lbl_1"], 
            self._rootnode["time_lbl_2"],
            self._rootnode["time_lbl_3"]
            }) 

    local starTime = activeTime[1] or "" 
    local endTime = activeTime[2] or "" 
    local timeStr = "活动时间：" .. starTime .. " ——— " .. endTime 
    local timeLbl = ResMgr.createShadowMsgTTF({text = timeStr, color = ccc3(0, 219, 52), shadowColor = ccc3(0, 0, 0), size = 20})
    timeLbl:setPosition(-timeLbl:getContentSize().width/2, 0) 
    self._rootnode["time_lbl"]:removeAllChildren() 
    self._rootnode["time_lbl"]:addChild(timeLbl) 

    self:initRewardListView() 
 end 


 function LeijiLoginLayer:initRewardListView()  
    local function getReward(cell) 
        RequestHelper.leijiLogin.getReward({
            day = cell:getDay(), 
            callback = function(data)
                dump(data)
                if data.err ~= "" then 
                    dump(data.err) 
                else
                    -- result:   领取结果 1-成功 2-失败
                    local rtnObj = data.rtnObj
                    local result = rtnObj.result 

                    if result == 1 then 
                        game.player:updateMainMenu({gold = rtnObj.gold, silver = rtnObj.silver}) 
                        
                        table.insert(self._hasGetAry, cell:getDay())
                        cell:getReward(self._hasGetAry) 

                        -- 弹出得到奖励提示框
                        local title = "恭喜您获得如下奖励："
                        local msgBox = require("game.Huodong.RewardMsgBox").new({
                            title = title, 
                            cellDatas = self._rewardDatas[cell:getIdx() + 1].itemData   
                            })

                        game.runningScene:addChild(msgBox, MAX_ZORDER)
                    end 
                end 
            end
        })
    end 

    -- 创建 
    local function createFunc(index)
    	local item = require("game.nbactivity.LeijiLogin.LeijiLoginItem").new()
    	return item:create({
    		viewSize = self._listViewSize, 
    		cellDatas = self._rewardDatas[index + 1], 
            hasGetAry = self._hasGetAry, 
            hasLoginDays = self._hasLoginDays, 
            rewardListener = function(cell) 
                getReward(cell) 
            end
    		})
    end

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh(self._rewardDatas[index + 1])
    end

    local cellContentSize = require("game.nbactivity.LeijiLogin.LeijiLoginItem").new():getContentSize()

    self.ListTable = require("utility.TableViewExt").new({
    	size        = self._listViewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #self._rewardDatas, 
        cellSize    = cellContentSize 
    	})

    self.ListTable:setPosition(0, 0)
    self._listViewNode:addChild(self.ListTable) 
 end


 return LeijiLoginLayer 

