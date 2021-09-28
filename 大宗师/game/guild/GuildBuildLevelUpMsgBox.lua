--[[
 --
 -- add by vicky
 -- 2015.01.12 
 --
 --]] 

 require("data.data_error_error") 


 local GuildBuildLevelUpMsgBox = class("GuildBuildLevelUpMsgBox", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 function GuildBuildLevelUpMsgBox:ctor(param)  
    local toLevel = param.toLevel 
    local curLevel = param.curLevel 
    local needCoin = param.needCoin 
    local curCoin = param.curCoin 
    local buildType = param.buildType 
    local confirmFunc = param.confirmFunc 
    local cancelFunc = param.cancelFunc 

 	local proxy = CCBProxy:create()
 	local rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/guild/guild_build_levelup_msgBox.ccbi", proxy, rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	rootnode["titleLabel"]:setString("提示") 

    rootnode["need_coin_lbl"]:setString(tostring(needCoin)) 
    rootnode["level_lbl"]:setString(tostring(toLevel)) 

    rootnode["name_lbl"]:setString("资金, 将" .. GUILD_BUILD_NAME[buildType] .. "提升") 

 	local function closeFunc()
        if cancelFunc ~= nil then 
            cancelFunc() 
        end 
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

        local guildMgr = game.player:getGuildMgr() 
        dump(guildMgr:getGuildInfo().m_level) 
        local requireStr = guildMgr:getRequireStr(buildType, curLevel) 

        if curCoin < needCoin then 
            show_tip_label("帮派资金不足，无法升级" .. GUILD_BUILD_NAME[buildType]) 

        elseif guildMgr:checkIsReachMaxLevel(buildType, curLevel) == true then 
            show_tip_label(data_error_error[2900021].prompt) 

        elseif requireStr ~= nil then 
            show_tip_label(requireStr) 

        elseif confirmFunc ~= nil then 
            self:setBtnEnabled(false) 
            confirmFunc(self) 
        end 

    end, CCControlEventTouchUpInside) 

    self.setBtnEnabled = function(_, bEnabled)
        rootnode["confirmBtn"]:setEnabled(bEnabled) 
        rootnode["cancelBtn"]:setEnabled(bEnabled) 
        rootnode["tag_close"]:setEnabled(bEnabled) 
    end

 end 


 return GuildBuildLevelUpMsgBox   
