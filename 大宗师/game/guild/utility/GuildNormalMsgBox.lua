--[[
 --
 -- add by vicky
 -- 2015.01.06 
 --
 --]]

 require("data.data_error_error") 



 local GuildNormalMsgBox = class("GuildNormalMsgBox", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 function GuildNormalMsgBox:setBtnEnabled(bEnaled)
    self._rootnode["single_confirmBtn"]:setEnabled(bEnaled) 
    self._rootnode["confirmBtn"]:setEnabled(bEnaled) 
    self._rootnode["cancelBtn"]:setEnabled(bEnaled) 
    self._rootnode["tag_close"]:setEnabled(bEnaled) 
 end   


 function GuildNormalMsgBox:ctor(param) 
    local title = param.title 
    local msg = param.msg 
    local isSingleBtn = param.isSingleBtn 
    local confirmFunc = param.confirmFunc 
    local cancelFunc = param.cancelFunc 
    local isBuyExtraBuild = param.isBuyExtraBuild -- 是否购买工坊额外生产次数 
    local extraCostGold = param.extraCostGold 

 	local proxy = CCBProxy:create()
 	self._rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/guild/guild_normal_msgBox.ccbi", proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2)
 	self:addChild(node)

 	self._rootnode["titleLabel"]:setString(title) 

    if isBuyExtraBuild ~= nil and isBuyExtraBuild == true then 
        self._rootnode["tag_extra_build"]:setVisible(true) 
        self._rootnode["extra_cost_gold_lbl"]:setString(tostring(extraCostGold)) 
    else
        self._rootnode["tag_extra_build"]:setVisible(false)  
        self._rootnode["msg_lbl"]:setString(msg) 
    end 

 	local function closeFunc()
        if cancelFunc ~= nil then 
            cancelFunc() 
        end 
 		self:removeFromParentAndCleanup(true) 
 	end 

    local function confirm()
        if confirmFunc ~= nil then 
            self:setBtnEnabled(false) 
            confirmFunc(self) 
        end 
    end 

    if isSingleBtn == true then 
        self._rootnode["single_confirmBtn"]:setVisible(true) 
        self._rootnode["normal_btn_node"]:setVisible(false) 

        self._rootnode["single_confirmBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            confirm() 
        end, CCControlEventTouchUpInside) 
    else
        self._rootnode["single_confirmBtn"]:setVisible(false) 
        self._rootnode["normal_btn_node"]:setVisible(true) 

        self._rootnode["cancelBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            closeFunc() 
        end, CCControlEventTouchUpInside) 

        self._rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            confirm() 
        end, CCControlEventTouchUpInside) 
    end 

    self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        closeFunc() 
    end, CCControlEventTouchUpInside) 

 end 


 return GuildNormalMsgBox 
