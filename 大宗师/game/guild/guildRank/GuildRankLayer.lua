--[[
 --
 -- add by vicky
 -- 2015.01.04 
 --
 --]]  


 local NORMAL_FONT_SIZE = 22 

 local GuildRankLayer = class("GuildRankLayer", function()
 		return require("utility.ShadeLayer").new()
 	end)
 

 function GuildRankLayer:getRankData()
 	RequestHelper.Guild.rank({
 		callback = function(data) 
            dump(data) 
 			if data.err ~= "" then 
 				dump(data.err) 
 			else 
 				self:initData(data.rtnObj) 
 			end 
	 	end 
 		}) 
 end 


 function GuildRankLayer:initData(rtnObj)
 	local mysumAttack = rtnObj.mysumAttack 
    local myrank = rtnObj.myrank
    local isInUnion = rtnObj.isInUnion 
    local rankData = rtnObj.unionList 

    local mysumAttackStr 
    local myrankStr 

    if isInUnion == 1 then 
        myrankStr = "未加入帮派"
        mysumAttackStr = "无" 
    elseif isInUnion == 0 then 
        myrankStr = myrank 
        mysumAttackStr = mysumAttack 
    end 

    -- 帮派排名 
    local myRankLbl = ui.newTTFLabelWithShadow({
        text = tostring(myrankStr), 
        size = NORMAL_FONT_SIZE,
        color = ccc3(78, 255, 0),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT 
    }) 
    self._rootnode["my_rank_lbl"]:addChild(myRankLbl) 

    -- 战力
    local powerLbl = ui.newTTFLabelWithShadow({
        text = tostring(mysumAttackStr), 
        size = NORMAL_FONT_SIZE,
        color = ccc3(78, 255, 0),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT 
    }) 
    self._rootnode["my_power_lbl"]:addChild(powerLbl) 

	local viewSize = self._rootnode["listView"]:getContentSize() 

 	-- 创建
    local function createFunc(index)
    	local item = require("game.guild.guildRank.GuildRankItem").new()
    	return item:create({
            id = index + 1, 
    		viewSize = viewSize, 
    		itemData = rankData[index + 1] 
    		})
    end 

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh({
            id = index + 1, 
            itemData = rankData[index + 1] 
            }) 
    end 

    local cellContentSize = require("game.guild.guildRank.GuildRankItem").new():getContentSize()

    self._rootnode["listView"]:removeAllChildren() 

    local listTable = require("utility.TableViewExt").new({
    	size        = viewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #rankData, 
        cellSize    = cellContentSize 
    	})

    listTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(listTable) 
 end


 function GuildRankLayer:ctor() 
 	self._rootnode = {} 
 	local proxy = CCBProxy:create()
 	local node = CCBuilderReaderLoad("guild/guild_rank_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

	self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true) 
        end, CCControlEventTouchUpInside) 

 	self:getRankData() 
 end 



 return GuildRankLayer 

