--[[
 --
 -- add by vicky
 -- 2014.09.10
 --
 --]]


 local ChatItem = class("ChatItem", function()
 	return display.newNode()
 end)
 

 function ChatItem:getContentSize()
 	-- 必须初始化之后才可以获取，否则为0
 	if self._contentSz == nil then
 		self._contentSz = CCSizeMake(0, 0)
 	end

 	return self._contentSz
 end


 function ChatItem:getIsLeft()
     return self._isLeft 
 end


 function ChatItem:ctor(param)
 	-- msg, gender, isLeft, name 
 	local msg = param.msg 
 	local gender = param.gender
 	local name = param.name 
 	self._isLeft = param.isLeft 

    if(param.guildName ~= nil and param.guildName ~= "" and self._isLeft == true) then
        name = name .. "【" .. param.guildName .. "】"
    end

    local proxy = CCBProxy:create()
    local rootnode = {}
    local length = string.utf8len(msg) 
    
    if length > 22 then
    	self._contentSz = CCSizeMake(500, 80)
    else
        local len = string.len(msg) 
        -- local w = 70 + 20 * length - (length * 3 - len)*20 * 0.3 
        local w = 70 + (440/22 * len * 0.34)
        
    	self._contentSz = CCSizeMake(w, 50)
    end 

    local color = ccc3(0, 129, 220)
    if self._isLeft and gender == 2 then 
        color = ccc3(221, 1, 221)
    elseif not self._isLeft then
        color = ccc3(1, 170, 48)
    end 

    -- local nameLbl = ui.newTTFLabel({
    --         text = name,
    --         size = 22,
    --         color = color, 
    --         -- outlineColor = ccc3(225, 255, 255), 
    --         font = FONTS_NAME.font_fzcy,
    --         align = ui.TEXT_ALIGN_LEFT
    --         })

    local nameNode 
    local msgNode 
    local pos 

    if self._isLeft then 
        nameNode = CCBuilderReaderLoad("chat/chat_left_name.ccbi", proxy, rootnode) 
        if gender == 1 then 
            msgNode = CCBuilderReaderLoad("chat/chat_left_msg_boy.ccbi", proxy, rootnode, self, self._contentSz)
        else
            msgNode = CCBuilderReaderLoad("chat/chat_left_msg_girl.ccbi", proxy, rootnode, self, self._contentSz)
        end 
        -- pos = CCPointMake(0, nameLbl:getContentSize().height/2)

    else
        nameNode = CCBuilderReaderLoad("chat/chat_right_name.ccbi", proxy, rootnode) 
        msgNode = CCBuilderReaderLoad("chat/chat_right_msg.ccbi", proxy, rootnode, self, self._contentSz) 
        -- pos = CCPointMake(-nameLbl:getContentSize().width, nameLbl:getContentSize().height/2)
    end

    rootnode["nameLbl"]:setString(name)
    rootnode["nameLbl"]:setColor(color)
    
    self._contentSz = CCSizeMake(msgNode:getContentSize().width, msgNode:getContentSize().height + nameNode:getContentSize().height + 10)
    self:addChild(nameNode)

    msgNode:setPosition(0, -nameNode:getContentSize().height - 10)
    self:addChild(msgNode) 

    -- nameLbl:setPosition(pos)
    -- rootnode["nameLbl"]:addChild(nameLbl)

    rootnode["msgLbl"]:setString(msg)
    -- rootnode["msgLbl"]:setColor(ccc3(255, 255, 255)) 

 end


 return ChatItem 
 