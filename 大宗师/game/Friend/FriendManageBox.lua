
local FriendManageBox = class("FriendManageBox", function (param)	
	return  require("utility.ShadeLayer").new()
end)



function FriendManageBox:ctor(id)
	local listData = FriendModel.getList(1)
    local cellData = listData[id]

    self.id = id

    self.acc = cellData.account

	self:setNodeEventEnabled(true)

	local rootProxy = CCBProxy:create()
    self._rootnode = {}

    local rootnode = CCBuilderReaderLoad("friend/friend_manage_box.ccbi", rootProxy, self._rootnode)
    rootnode:setPosition(display.cx, display.cy)
    self:addChild(rootnode, 1)

    if game.player:getAppOpenData().hy_qiecuo == APPOPEN_STATE.close then 
        self._rootnode["pk_btn"]:setVisible(false) 
    else
        self._rootnode["pk_btn"]:setVisible(true)  
    end 


    ResMgr.setControlBtnEvent(self._rootnode["chat_btn"], function()
    		self:createChatBox()
    	end)

    ResMgr.setControlBtnEvent(self._rootnode["info_btn"], function()
	    	self:createFriendInfo()
    	end)

    ResMgr.setControlBtnEvent(self._rootnode["pk_btn"], function()
    		self:createPKLayer()
    	end)

    ResMgr.setControlBtnEvent(self._rootnode["break_btn"], function()
    		self:createBreakBox()
    	end)

    ResMgr.setControlBtnEvent(self._rootnode["close_btn"], function() 
    		self:removeSelf()
    	end,SFX_NAME.u_guanbi)

    self.playerName = cellData.name
	
end




function FriendManageBox:createChatBox()
	local layer = require("game.Chat.ChatLayer").new(nil,1,self.id)
    layer:setPosition(0, 0)
    game.runningScene:addChild(layer, 10000)
	self:removeSelf()
end

function FriendManageBox:createFriendInfo()
	local layer = require("game.form.EnemyFormLayer").new(1, self.acc)
    layer:setPosition(0, 0)
    game.runningScene:addChild(layer, 10000)
	self:removeSelf()
end

function FriendManageBox:createPKLayer()
	show_tip_label("暂未开放")
	-- self:removeSelf()
end

function FriendManageBox:createBreakBox()
	local rowOneTable ={}
	local descFirst = ResMgr.createShadowMsgTTF({text = "你确定要删除好友",color = ccc3(255,255,255)}) 
	rowOneTable[#rowOneTable + 1] = descFirst
	local name = ResMgr.createShadowMsgTTF({text = self.playerName,color = ccc3(255,210,0)}) 
	rowOneTable[#rowOneTable + 1] = name
	local descEnd = ResMgr.createShadowMsgTTF({text = "吗？",color = ccc3(255,255,255)}) 
	rowOneTable[#rowOneTable + 1] = descEnd

	local rowAll = {rowOneTable}

	 
	local curAcc = self.acc
	local friendBreakBox = require("utility.MsgBoxEx").new({
	    resTable = rowAll,
	    confirmFunc = function(node)
	    	FriendModel.removeFriendReq({account = curAcc})
	        node:removeSelf() 
	    end
	    })

	game.runningScene:addChild(friendBreakBox, BOX_ZORDER.MIN) 

	self:removeSelf()
end









return FriendManageBox