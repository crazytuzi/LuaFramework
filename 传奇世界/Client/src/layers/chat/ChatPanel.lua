local ChatPanel = class("ChatPanel", function() return cc.Node:create() end)

require "src/utf8"

function ChatPanel:ctor(topNode)
	if not G_CHAT_INFO.data_tinyChatView then
        G_CHAT_INFO.data_tinyChatView = {}
    end
	self.showMsgMax = 3
	self.updateProtectTime = 3
	self.isUpdateAvailable = true
	self.contentPadding = 4

	self.topData = {}
	self.topDataMax = 30
	self.topShowNormalTime = 20
	self.topShowShortTime = 1
	self.topNode = topNode

	if G_BLACK_INFO and #G_BLACK_INFO == 0 then
		startTimerAction(self, 1, false, UpdateBlack)
	end
	startTimerAction(self, self.updateProtectTime, true, function() self:updateUI() end)

	self:initTopShow()

    local function cb()
        G_MAINSCENE.chatLayer = G_MAINSCENE.base_node:getChildByTag(305)
        if G_MAINSCENE.chatLayer == nil or tolua.cast(G_MAINSCENE.chatLayer, "cc.Node") == nil then
	   		local chatLayer = require("src/layers/chat/Chat").new()
	   		G_MAINSCENE.chatLayer = chatLayer
	   		G_MAINSCENE.base_node:addChild(chatLayer)
	   		chatLayer:setLocalZOrder(200)
	   		chatLayer:setTag(305)
		else
			G_MAINSCENE.chatLayer:show()
		end	     
        
        self:setVisible(false)  
	end

    self.bg = createScale9Sprite(self, "res/chat/bg_chat_scale_2.png", cc.p(127, 32), cc.size(246, 106))
    self.bgNodes = cc.Node:create()
    self.bg:addChild(self.bgNodes)

    --弹出聊天框按钮
    local item = createScale9SpriteMenu(self.bgNodes,"res/chat/bg_chat_scale_2.png",cc.size(210, 106),cc.p(105,53.5),cb)
    item:setActionEnable(false)
    item:setOpacity(0)

    --创建内容scroll
    self:createScroll()

    --内容收缩按钮
    local function shrink()
        self.bg:setVisible(false)
        self.spreadBtn:setVisible(true)      
    end

    item = createScale9SpriteMenu(self.bgNodes,"res/chat/bg_chat_scale_2.png",cc.size(50, 106),cc.p(233,53.5),shrink)
    item:setOpacity(0)
    local closeSpr = createSprite(self.bgNodes,"res/chat/btn_chat.png",cc.p(233,0),cc.p(0,0))
    --closeSpr:setOpacity(196) 

    --内容展开按钮
    local function spread()
        self.bg:setVisible(true)
        self.spreadBtn:setVisible(false)
    end

    cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
    self.spreadBtn = createTouchItem(self,{"mainui/anotherbtns/chat.png"},cc.p(26,36),spread,true)
    self.spreadBtn:setVisible(false)
    G_MAINSCENE.chatStartBtn = self.spreadBtn

    --语聊快捷按钮
    self.ChatVoiceSimple = require("src/layers/chat/ChatVoiceSimple").new(self, cc.p(0,5))

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            local function update()
                if G_MAINSCENE then 
                    if require("src/layers/weddingSystem/WeddingSysCommFunc").isWeddingSys then
                        return
                    end
                    G_MAINSCENE.chatLayer = G_MAINSCENE.base_node:getChildByTag(305)
                    if G_MAINSCENE.chatLayer == nil then
                         self:setVisible(true)
                    else
                         self:setVisible((not G_MAINSCENE.chatLayer.isShow))
                    end
                end
            end
            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.3, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil
            end 

            G_CHAT_INFO.chatPanel = nil
        end
    end)

end

function ChatPanel:createScroll()
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(235, 90))
        scrollView:setPosition(cc.p(2, 4))
        local node = cc.Node:create()
        self.textNode= node
        scrollView:setContainer(node)
        scrollView:setContentSize(cc.size(235, 90))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(false)
        self.bgNodes:addChild(scrollView)
        self.scrollView = scrollView
    end
end

function ChatPanel:addData(record)

    table.insert(G_CHAT_INFO.data_tinyChatView, 1, record)
    if #G_CHAT_INFO.data_tinyChatView > self.showMsgMax then
        table.remove(G_CHAT_INFO.data_tinyChatView, #G_CHAT_INFO.data_tinyChatView)
    end

	self.isUpdateAvailable = true
end

function ChatPanel:deleteDataById(userId)
	dump(userId)
	local removeTab = {}
	for i,v in ipairs(G_CHAT_INFO.data_tinyChatView) do
		dump(v.userId)
		if v.userId and v.userId == userId then
			removeTab[i] = true
		end
	end
	dump(removeTab)
	for i=#G_CHAT_INFO.data_tinyChatView,1,-1 do
		if removeTab[i] then
			table.remove(G_CHAT_INFO.data_tinyChatView, i)
		end
	end

	self.isUpdateAvailable = true
end

function ChatPanel:onSimpleVoiceAction(bLess)
    -- 去掉语音按钮和聊天信息的联动
    if bLess then
        if self.bg:isVisible() then
            --self.bgNodes:setVisible(true)
        else
            self.spreadBtn:setVisible(true) 
        end
    else
        if self.bg:isVisible() then
            --self.bgNodes:setVisible(false)
        else
            self.spreadBtn:setVisible(false) 
        end
    end
end

function ChatPanel:updateUI()
	if self.isUpdateAvailable == false then
		return
	end

    local y = 0
    self.textNode:removeAllChildren()
	for i=1,#G_CHAT_INFO.data_tinyChatView do
		local record = G_CHAT_INFO.data_tinyChatView[i]
        local strName = record.name
		local textColor = MColor.white	

        --前缀
        local commConst = require("src/config/CommDef")
        if record.channelId == commConst.Channel_ID_World then
            strName = "【"..game.getStrByKey("chat_world").."】"..strName
        elseif record.channelId == commConst.Channel_ID_Area then
            strName = "【"..game.getStrByKey("chat_area").."】"..strName
        elseif record.channelId == commConst.Channel_ID_Faction then
            strName = "【"..game.getStrByKey("chat_faction").."】"..strName
        elseif record.channelId == commConst.Channel_ID_Team then
            strName = "【"..game.getStrByKey("chat_teamup").."】"..strName
        elseif record.channelId == commConst.Channel_ID_Privacy then
            strName = "【"..game.getStrByKey("chat_personal").."】"..strName
        elseif record.channelId == commConst.Channel_ID_System then
            strName = "【"..game.getStrByKey("chat_system").."】"..strName
        end

		local richText = require("src/RichText").new(nil, cc.p(10, self.contentPadding), cc.size(235, 87), cc.p(0, 0), 20, 16, MColor.lable_yellow)
		richText:addTextItem(strName, MColor.lable_yellow, false)
		if record.isPrivacy then
			richText:addTextItem(game.getStrByKey("chat_talkToMe"), MColor.purple, false)
		end
		richText:addTextItem("：", MColor.lable_yellow, false)
		if record.isVoice then
			local text = require("src/layers/chat/Microphone"):getShieldMean(record.text)
			local wth = 36
			if string.utf8len(text) > wth then
				text = string.utf8sub(text,1,wth).."..."
			end

			richText:addText(text, textColor, false)
		else
			richText:addText(record.text, textColor, false)
		end
		richText:addCheckFunc(function() return false end)
		richText:format()

		local richTextSize = richText:getContentSize()
		self.textNode:addChild(richText)
        richText:setPosition(cc.p(0,y))
        y = richTextSize.height + y
	end

	self.isUpdateAvailable = false
end

function ChatPanel:addChatMsg(name, text, userId, isPrivacy, vip, isVoice,channelId)
	local record = {name = name,
					text = text,
					userId = userId,
					isPrivacy = isPrivacy,
					vip = vip,
					isVoice = isVoice,
                    channelId = channelId,
					}
	self:addData(record)
end

function ChatPanel:addTrumpetChatMsg(name, text, userId, vip, isVoice,channelId)
	local record = {name = name,
					text = text,
					userId = userId,
					vip = vip,
					isVoice = isVoice,
                    channelId = channelId,
					}
	self:addData(record)
end

function ChatPanel:initTopShow()
	startTimerAction(self, 1, true, function() self:updateTopShow() end)
end

function ChatPanel:clearTopShow()
	self.topNode:removeAllChildren()
end

function ChatPanel:createTopShow(record)
	self:clearTopShow()

	local maxWidth = 335
	local paddingX = 15
	local paddingY = 5

	local text = "^i(99)^"
	if record.name then
		text = text.."^c(yellow)"..record.name.."：^"
	end
	if record.text then
		text = text..record.text
	end

	local bg = createSprite(self.topNode, "res/chat/trumpetBg.png", cc.p(0, 0), cc.p(0.5, 1))
	local richText = require("src/RichText").new(bg , getCenterPos(bg) , cc.size(maxWidth, 25) , cc.p(0.5, 0.5), 28, 22, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(text)
	richText:setFont(18, MColor.lable_yellow, 1, MColor.black)
	richText:format()

	local size = richText:getContentSize()
	dump(size)
	bg:removeFromParent()

	local bg = createScale9Sprite(self.topNode, "res/common/scalable/10.png", cc.p(0, 0), cc.size(size.width+paddingX*2, size.height+paddingY*2), cc.p(0.5, 1))
	local richText = require("src/RichText").new(bg, cc.p(size.width/2+paddingX, size.height/2+paddingY), cc.size(maxWidth, 25) , cc.p(0.5, 0.5), 28, 22, MColor.lable_yellow)
	richText:setAutoWidth()
	dump(text)
	richText:addText(text)
	richText:setFont(18, MColor.lable_yellow, 1, MColor.black)
	richText:format()

	bg:setScaleY(0)

	local effTime = 0.5
	local action = cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(effTime, 1 )))
	bg:runAction(action)

	record.show = true
end

function ChatPanel:updateTopShow()
	if self.topData[1] then
		if self.topData[1].show and self.topData[1].show == true then
			self.topData[1].time = self.topData[1].time - 1

			if self.topData[2] then
				if self.topData[1].time <= self.topShowNormalTime - self.topShowShortTime then
					self:clearTopShow()
					table.remove(self.topData, 1)
					self:createTopShow(self.topData[1])
				end
			else
				if self.topData[1].time <= 0 then
					self:clearTopShow()
					table.remove(self.topData, 1)
				end
			end
		else
			self:createTopShow(self.topData[1])
		end
	else
		return
	end
end

function ChatPanel:addTopShowData(record)
	if record then
		record.time = self.topShowNormalTime
		record.show = false
	else
		return
	end

	table.insert(self.topData, record)

	if #self.topData > self.topDataMax then
		table.remove(self.topData)
	end
end

return ChatPanel



