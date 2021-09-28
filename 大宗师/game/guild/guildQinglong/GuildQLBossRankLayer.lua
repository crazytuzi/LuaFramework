--[[
 --
 -- add by vicky
 -- 2015.01.23 
 --
 --]]  

 local data_ui_ui = require("data.data_ui_ui") 
 

 local GuildQLBossRankLayer = class("GuildQLBossRankLayer", function()
 		return require("utility.ShadeLayer").new()
 	end) 


 function GuildQLBossRankLayer:initData(topPlayers)
 	self._rankData = topPlayers  

    -- 击杀者 
    local hitData = self._rankData[1] 
    if hitData.acc == "" then 
        hitData.isTrueData = false 
        hitData.name = "无" 
    end 

    -- 若没有数据返回，则置假数据 
    local curNum = #self._rankData 
    if self._rankData ~= nil and curNum < 11 then 
        for i = curNum + 1, 11 do 
            table.insert(self._rankData, {
                isTrueData = false,   -- 是否是真实数据
                rank = i - 1,   
                acc = "", 
                name = "无", 
                hurt = 0, 
                lv = 0 
                })
        end 
    end 

	local viewSize = self._rootnode["listView"]:getContentSize() 

 	-- 创建
    local function createFunc(index)
    	local item = require("game.Worldboss.WorldBossRankItem").new()
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

    local cellContentSize = require("game.Worldboss.WorldBossRankItem").new():getContentSize()

    self._rootnode["listView"]:removeAllChildren() 

    self._listTable = require("utility.TableViewExt").new({
    	size        = viewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #self._rankData, 
        cellSize    = cellContentSize 
    	})

    self._listTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._listTable) 
 end


 function GuildQLBossRankLayer:ctor(param) 
 	self:setNodeEventEnabled(true)
    local topPlayers = param.topPlayers 
    local confirmFunc = param.confirmFunc 
 	
 	self._rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("huodong/worldBoss_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

    self._rootnode["top_msg_lbl"]:setString(data_ui_ui[8].content) 

	self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            if confirmFunc ~= nil then 
                confirmFunc() 
            end 
            self:removeFromParentAndCleanup(true) 
        end, CCControlEventTouchUpInside) 

 	self:initData(topPlayers) 

 end 


 function GuildQLBossRankLayer:checkZhenrong(index) 
    if ENABLE_ZHENRONG then  
        local layer = require("game.form.EnemyFormLayer").new(1, self._rankData[index].acc)
        layer:setPosition(0, 0) 
        self:addChild(layer, 10000) 
    else
        show_tip_label(data_error_error[2800001].prompt)
    end 
 end 


 function GuildQLBossRankLayer:onExit()
    
 end


 return GuildQLBossRankLayer 

