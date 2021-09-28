--[[
 --
 -- add by vicky
 -- 2014.10.01
 --
 --]]

 local data_error_error = require("data.data_error_error") 
 local data_item_item = require("data.data_item_item") 

 local ZORDER = 100

 local CDKeyRewardLayer = class("CDKeyRewardLayer", function()
 		return require("utility.ShadeLayer").new()
 end)


 function CDKeyRewardLayer:sendReq(cdkey)
 	RequestHelper.getCDKeyReward({
            pfid = CSDKShell.getChannelID(), 
            cdkey = cdkey, 
            callback = function(data)
                dump(data) 
                if data["0"] ~= "" then 
                    dump(data["0"]) 
                else 
                    -- 更新玩家数据 
                    if data["2"] ~= nil then 
                        game.player:updateMainMenu({gold = data["2"][1], silver = data["2"][2]})
                        PostNotice(NoticeKey.MainMenuScene_Update)
                    end 

                    local itemData = {} 
                    for i, v in ipairs(data["1"]) do 
                        local item = data_item_item[v.id]
                        local iconType = ResMgr.getResType(v.t)
                        if iconType == ResMgr.HERO then 
                            item = ResMgr.getCardData(v.id)
                        end

                        table.insert(itemData, {
                            id = v.id, 
                            type = v.t, 
                            num = v.n, 
                            iconType = iconType, 
                            name = item.name 
                            })
                    end 

                    -- 弹出得到奖励提示框 
                    local title = "恭喜您获得如下奖励："
                    local msgBox = require("game.Huodong.RewardMsgBox").new({
                        title = title, 
                        cellDatas = itemData, 
                        confirmFunc = function()
                            self._editBox:setVisible(true)
                        end  
                        })

                    self._editBox:setVisible(false) 
                    self:addChild(msgBox, ZORDER) 
                end  
            end 
        })

 end


 function CDKeyRewardLayer:ctor(param) 
	self:setNodeEventEnabled(true) 

    local endFunc = param.endFunc 

	local proxy = CCBProxy:create()
	local rootnode = {}

	local node = CCBuilderReaderLoad("huodong/cdkey_msg_box.ccbi", proxy, rootnode) 
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node) 

	local function closeFun(eventName, sender)
        if endFunc ~= nil then 
            endFunc() 
        end 
        self:removeFromParentAndCleanup(true) 
	end

	rootnode["closeBtn"]:addHandleOfControlEvent(closeFun, 
	 		CCControlEventTouchUpInside) 

    rootnode["confirmBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()
            if endFunc ~= nil then 
                endFunc() 
            end 
            self:removeFromParentAndCleanup(true)    
        end)

 	-- 兑换 
    rootnode["exchangeBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()
            if self._editBox:getText() == "" then 
                show_tip_label(data_error_error[1303].prompt)
            else
                self:sendReq(self._editBox:getText())
                self._editBox:setText("") 
            end 
        end)


 	local boxNode = rootnode["box_tag"]
    local cntSize = boxNode:getContentSize()

    self._editBox = ui.newEditBox({ 
        image = "#s_cdkey_input_bg.png", 
        size = CCSizeMake(cntSize.width * 0.98, cntSize.height * 0.98), 
        x = cntSize.width/2, 
        y = cntSize.height/2  
    })

    self._editBox:setFont(FONTS_NAME.font_fzcy, 25)
    self._editBox:setFontColor(FONT_COLOR.BLACK)
    self._editBox:setPlaceholderFont(FONTS_NAME.font_haibao, 25)
    self._editBox:setPlaceHolder("请输入礼包兑换码")
    self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
    self._editBox:setReturnType(1)
    self._editBox:setInputMode(0) 

    boxNode:addChild(self._editBox, 10)

 end 


 function CDKeyRewardLayer:onEnter()

 end 


 function CDKeyRewardLayer:onExit()
    
 end 


 return CDKeyRewardLayer
