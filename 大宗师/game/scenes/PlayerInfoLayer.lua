 --[[
 --
 -- @authors shan 
 -- @date    2014-11-14 17:18:19
 -- @version 
 --
 --]]

local PlayerInfoLayer = class("PlayerInfoLayer", function ( mainMenuNode )
	return display.newNode("PlayerInfoLayer")
end)


function PlayerInfoLayer:ctor( mainMenuNode, cb )

	self.playerInfoNode = mainMenuNode
    self:setNodeEventEnabled(true)
	
    self.schedulePlayerInfo = require("framework.scheduler")

    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    self._rootNode = self._rootNode or {}

    local node = CCBuilderReaderLoad("ccbi/mainmenu/playerinfo.ccbi", proxy, self._rootNode)
    local layer = tolua.cast(node,"CCLayer")
    layer:setPosition(display.width/2, display.height*0.53)
    self:addChild(layer)

    layer:setTouchEnabled(true)

    local closeBtn = self._rootNode["tag_close"]
    closeBtn:addHandleOfControlEvent(function(eventName,sender)
        if(cb ~= nil) then
            cb()
        end 
        self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
        layer:removeSelf()
        
    end,
        CCControlEventTouchUpInside)

    local okBtn = self._rootNode["tag_ok_btn"]
    okBtn:addHandleOfControlEvent(function(eventName,sender)

        sender:runAction(transition.sequence({
            CCScaleTo:create(0.08, 0.8),
            CCCallFunc:create(function()
                if(cb ~= nil) then
                    cb()
                end
                self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
                layer:removeSelf()

            end),
            CCScaleTo:create(0.1, 1.2),
            CCScaleTo:create(0.02, 1)

        }))
    end,
        CCControlEventTouchUpInside)

    local playerHead = self._rootNode["tag_player_icon"]

    headImgName = game.player:getPlayerIconName()
    playerHead:setDisplayFrame(display.newSpriteFrame(headImgName))
    
    self._rootNode["tag_lv"]:setString(game.player.m_level)
    self._rootNode["tag_vip"]:setString(game.player.m_vip)

    self:ReqPlayerInfo()

end

function PlayerInfoLayer:ReqPlayerInfo( ... )
	 -- 从服务器获取玩家信息
    RequestHelper.getPlayerInfo({
        callback = function(data)
            dump(data)

            if #data["0"] > 0 then
                show_tip_label(data["0"])
                return
            end
            local info = data["1"]


            self._rootNode["text_shangzhen"]:setString(info.fmtCnt[1] .. "/" .. info.fmtCnt[2])
            self._rootNode["text_gold"]:setString(info.gold)
            self._rootNode["text_silver"]:setString(info.silver)
            self._rootNode["text_xiahun"]:setString(info.soul)
            self._rootNode["text_hunyu"]:setString(info.hunYuVal)

            self._rootNode["tag_tili"]:setString(info.physVal .. "/" .. info.physValLimit)
            self._rootNode["tag_naili"]:setString(info.resisVal .. "/" .. info.resisValLimit)


            local playerID = "(ID:" .. game.player:getPlayerID() .. ")"
            -- self._rootNode["player_name"]:setString(game.player.m_name)
            local text = ui.newTTFLabelWithOutline({
                text = game.player.m_name ,
                x = 0,
                y = self._rootNode["player_name"]:getContentSize().height * 0.78,
                font = FONTS_NAME.font_fzcy,
                size = 28,
                color = FONT_COLOR.PLAYER_NAME,
                outlineColor = ccc3(0,0,0),
                align = ui.TEXT_ALIGN_LEFT,

            })
            self._rootNode["player_name"]:addChild(text)

            local playerIDLabel = ui.newTTFLabel({
                text = playerID,
                x = text:getContentSize().width + 5,
                y = self._rootNode["player_name"]:getContentSize().height * 0.78,
                font = FONTS_NAME.font_fzcy,
                size = 24,
                color = ccc3(100,100,100),                
                align = ui.TEXT_ALIGN_LEFT,

            })
            text:addChild(playerIDLabel)

            -- 更新主界面玩家信息
            game.player:updateMainMenu({
                tili = info.physVal,
                naili = info.resisVal
            })
            self.playerInfoNode["label_tili"]:setString(game.player.m_strength .. "/" ..game.player.m_maxStrength)
            self.playerInfoNode["label_naili"]:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)


            
            self.tilihuifu_time = tonumber(info.physValTime[1])
            self.tilihuiman_time = tonumber(info.physValTime[2])
            self.nailihuifu_time = tonumber(info.resisValTime[1])
            self.nailihuiman_time = tonumber(info.resisValTime[2])

            -- update
            self:Update()

        end,

    })
end


function PlayerInfoLayer:Update(  )
    local function update( )
        if(self.tilihuifu_time > 0) then
            self.tilihuifu_time = self.tilihuifu_time - 1
            local text = format_time(self.tilihuifu_time)
            self._rootNode["tilihuifu_time"]:setString(text)
        end
        if(self.tilihuiman_time > 0) then
            self.tilihuiman_time = self.tilihuiman_time - 1
            local text = format_time(self.tilihuiman_time)
            self._rootNode["tilihuiman_time"]:setString(text)
        end
        if(self.nailihuifu_time > 0) then
            self.nailihuifu_time = self.nailihuifu_time - 1
            local text = format_time(self.nailihuifu_time)
            self._rootNode["nailihuifu_time"]:setString(text)
        end
        if(self.nailihuiman_time > 0) then
            self.nailihuiman_time = self.nailihuiman_time - 1
            local text = format_time(self.nailihuiman_time)
            self._rootNode["nailihuiman_time"]:setString(text)
        end

        if(self.tilihuifu_time == 0 and self.tilihuiman_time > 0) then
            self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
        	self:ReqPlayerInfo()
        elseif(self.nailihuifu_time == 0 and self.nailihuiman_time > 0) then
            self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
        	self.ReqPlayerInfo()
        end

    end
    self.playerinfoTextscheduler = self.schedulePlayerInfo.scheduleGlobal(update,1,false)
    dump(self.playerinfoTextscheduler)
end


function PlayerInfoLayer:onExit()
    self.schedulePlayerInfo.unscheduleGlobal(self.playerinfoTextscheduler)
end

return PlayerInfoLayer