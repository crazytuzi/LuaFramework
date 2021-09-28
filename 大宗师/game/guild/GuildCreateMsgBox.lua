--[[
 --
 -- add by vicky
 -- 2014.12.31 
 --
 --]]

 local data_config_union_config_union = require("data.data_config_union_config_union") 

 local guildNameMaxLen = data_config_union_config_union[1]["guild_name_max_length"] 
 local createNeedGold = data_config_union_config_union[1].create_guild_need_gold 


 local CreateGuildType = {
 	gold = 0, 
 	coin = 1, 
 }


 local GuildCreateMsgBox = class("GuildCreateMsgBox", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function GuildCreateMsgBox:reqCreateGuild(guildName, createType)
 	RequestHelper.Guild.create({ 
 		name = guildName, 
 		type = CreateGuildType.gold, 
		callback = function(data)
			dump(data) 
			if data.err ~= "" then 
				dump(data.err) 
			else 
				local rtnObj = data.rtnObj 
				local guildMgr = game.player:getGuildMgr()
                guildMgr:setIsInUnion(true) 
				guildMgr:setGuildInfo(rtnObj) 
                -- 更新当前元宝数
                game.player:updateMainMenu({gold = rtnObj.surplusGold}) 

				-- 进入帮派主界面 
                GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_MAINSCENE) 
			end 
		end 
	})
 end 


 function GuildCreateMsgBox:ctor() 
 	local proxy = CCBProxy:create()
 	local rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/guild/guild_create_guild_msgBox.ccbi", proxy, rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	rootnode["titleLabel"]:setString("建立帮派") 

 	local editBoxNode = rootnode["editBox_node"]
    local cntSize = editBoxNode:getContentSize()

    self._editBox = ui.newEditBox({
        image = "#win_base_inner_bg_black.png",
        size = CCSizeMake(cntSize.width, cntSize.height),
        x = cntSize.width/2, 
        y = cntSize.height/2 
    })

    self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setFontColor(FONT_COLOR.WHITE)
    -- self._editBox:setMaxLength(guildNameMaxLen)
    self._editBox:setPlaceHolder("") 
    self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
    self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
    self._editBox:setReturnType(1)
    self._editBox:setInputMode(0) 
    editBoxNode:addChild(self._editBox) 

 	local function closeFunc()
 		self:removeFromParentAndCleanup(true) 
 	end 

 	rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        closeFunc() 
    end, CCControlEventTouchUpInside)

    rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
    	local textStr = self._editBox:getText() 
    	if textStr == "" then 
    		show_tip_label(data_error_error[2900003].prompt) 

    	elseif string.utf8len(textStr) > guildNameMaxLen then 
    		show_tip_label(data_error_error[2900039].prompt)

    	elseif game.player:getGold() < createNeedGold then 
    		show_tip_label(data_error_error[2900004].prompt) 

    	elseif ResMgr.checkSensitiveWord(textStr) == true then 
    		show_tip_label(data_error_error[2900041].prompt) 

    	else 
	        self:reqCreateGuild(textStr, CreateGuildType.gold) 
	        self._editBox:setText("") 
	    end 

    end, CCControlEventTouchUpInside) 

 end 


 return GuildCreateMsgBox 
