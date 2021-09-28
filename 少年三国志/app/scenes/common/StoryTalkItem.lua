--StoryTalkItem.lua

local StoryTalkItem = class("StoryTalkItem", function ( ... )
	return Layout:create()
end)

function StoryTalkItem.create( ... )
	return StoryTalkItem.new("ui_layout/dungeon_StoryTalkItem.json", ...)
end

function StoryTalkItem:ctor( jsonFile, pos, name, text, dialogeType, soundCommond, showRapid, ... )
	self._talkItem = nil
	self._contentLabel = nil
	self._nextIcon = nil
    self._actFade = nil  -- 渐隐渐消的动作

	self._timer = nil
	self._isPlayingTalk = false
	self._isShowing = false
    self._showRapid = showRapid and true or false

	self._posIndex = pos
	self._content = text
	self._splitText = {}

    self._soundCommond = nil

	self:_doLoadItem(jsonFile, pos, name, text, dialogeType, soundCommond, showRapid)
end

function StoryTalkItem:_doLoadItem( jsonFile, pos, name, text, dialogeType, soundCommond, showRapid )
	dialogeType = dialogeType or 1
    self._soundCommond = soundCommond

	if self._talkItem  == nil then
        self._talkItem = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile(jsonFile)
        self._talkItem:setVisible(false)
        self:addChild(self._talkItem)
        self:setSize(self._talkItem:getSize())
    end

    if not self._talkItem then 
    	return 
    end

    local bg = self._talkItem:getChildByName("Image_Bg")
    if bg then
    	for i = 1, 3 do
        	local arrow = bg:getChildByName("Image_Arrow" .. i)
        	arrow:setVisible(i == pos and dialogeType < 3)
        	if i== pos then
            	arrow = tolua.cast(arrow,"ImageView")
            	arrow:loadTexture(G_Path.getStoryArrow(dialogeType))
        	end
    	end

    	local nameBg = bg:getChildByName("Image_NameBg")
    	if nameBg then 
    		nameBg:setVisible(true)

    		local nameLabel = nameBg:getChildByName("Label_Name")
        	nameLabel = tolua.cast(nameLabel,"Label")
        	if nameLabel then 
        		nameLabel:setText(name) 
        	end
        end

        local contentLabel = bg:getChildByName("Label_Desc")
        self._contentLabel = tolua.cast(contentLabel, "Label")
        if self._contentLabel then 
        	self._contentLabel:ignoreContentAdaptWithSize(true)
       		self._contentLabel:setColor(dialogeType < 3 and Colors.lightColors.DESCRIPTION or Colors.darkColors.DESCRIPTION) 
    	end

    	self._nextIcon = bg:getChildByName("Image_Next")
    end

    if self._contentLabel then 
    	local originSize = self._contentLabel:getSize()
    	local label = CCLabelTTF:create(text, self._contentLabel:getFontName(), 
    		self._contentLabel:getFontSize(), CCSizeMake(originSize.width, 0), kCCTextAlignmentLeft)
    	local curSize = label:getContentSize()
    	local heightOffset = curSize.height - originSize.height
    	self._contentLabel:setTextAreaSize(curSize)
    	self._contentLabel:setText("")
    	
    	local itemSize = self._talkItem:getSize()
    	self:setSize(CCSizeMake(itemSize.width, itemSize.height + (heightOffset > 0 and heightOffset or 0)))

		local bgImg = tolua.cast(bg,"ImageView")
		if bgImg then 
    		local bgSize = bgImg:getSize()
    		if heightOffset > 0 then 
    			bgImg:setSize(CCSizeMake(bgSize.width, bgSize.height + heightOffset))

    			local posx, posy = bg:getPosition()
	    		bg:setPosition(ccp(posx, posy + heightOffset))
    		end

    		if dialogeType ~= 1 then
    			bgImg:loadTexture(G_Path.getItemBg(dialogeType))
    		end
    	end

    	if heightOffset > 0 then 
    		local posx, posy = self._nextIcon:getPosition()
    		self._nextIcon:setPositionY(posy - heightOffset)
    	end
    end
end

function StoryTalkItem:animationShow( func )
	if not self._talkItem then
		if func then 
			func()
		end
		return false
	end

    if self._soundCommond and self._soundCommond ~= "0" then
        G_SoundManager:playSound(G_Path.getVoice(self._soundCommond))
    end

	self._isShowing = true
	self._talkItem:setVisible(true)
	local size = self:getSize()
	local posx, posy = self:getPosition()

	local _pos = self._talkItem:getPositionInCCPoint()
    if self._posIndex == 1 then -- 左
        self._talkItem:setPosition(ccp(_pos.x- size.width ,_pos.y))
    elseif self._posIndex == 2 then -- 中
        self._talkItem:setPosition(ccp(_pos.x + size.width/2,_pos.y))
    else -- 右
        self._talkItem:setPosition(ccp(_pos.x+ size.width ,_pos.y))
    end
    local arr = CCArray:create()        
    arr:addObject(CCSpawn:createWithTwoActions(CCEaseBackOut:create(CCMoveTo:create(0.6,_pos)), CCEaseBackOut:create(CCScaleTo:create(0.6,1))) )
    arr:addObject(CCCallFunc:create(function()
    		self._isShowing = false
    		if func then 
				func()
			end
    	end))
    self._talkItem:runAction(CCSequence:create(arr))

    self:setPosition(ccp(posx, posy + size.height))
    self:runAction(CCMoveTo:create(0.3, ccp(posx, posy)))

    return true
end

function StoryTalkItem:showNextIcon( show )
	local isShow = not not show
	if self._nextIcon then 
		self._nextIcon:setVisible(isShow)

        local nTime = 1
        if self._nextIcon:isVisible() and not self._actFade then
            local actFadeOut = CCFadeOut:create(nTime)
            local actFadeIn = CCFadeIn:create(nTime)
            local seq = CCSequence:createWithTwoActions(actFadeOut, actFadeIn)
            self._actFade = CCRepeatForever:create(seq)
            self._nextIcon:runAction(self._actFade)
        end

        if not self._nextIcon:isVisible() and self._actFade then
            self._nextIcon:stopAction(self._actFade)
            self._actFade = nil
        end
	end
end

function StoryTalkItem:doPlayTalk( func )
	local _doCallback = function ( ... )
		if func then 
			func()
		end
	end

	if type(self._content) ~= "string" or not self._contentLabel then 
		return _doCallback()
	end

    if self._showRapid then
        self._contentLabel:setText(self._content)
        self:showNextIcon(true)
        return _doCallback()
    end

	for uchar in string.gfind(self._content, "[%z\1-\127\194-\244][\128-\191]*") do 
        self._splitText[#self._splitText+1] = uchar 
    end

    if #self._splitText < 1 then 
    	return _doCallback()
    end

    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
    
    local desc = ""
    local num = 1
    self._isPlayingTalk = true
    self._timer = G_GlobalFunc.addTimer(0.05,function()
        if self._splitText[num] then
            desc = desc..self._splitText[num]
            num = num + 1
            self._contentLabel:setText(desc)
        end
        if num <= #self._splitText then
            desc = desc .. self._splitText[num]
            num = num + 1
            self._contentLabel:setText(desc)
        end      
        
        if num - 1 >= #self._splitText then
            if self._timer then
                G_GlobalFunc.removeTimer(self._timer)
                self._timer = nil
            end
            self._isPlayingTalk = false
            self._splitText = {}
            self:showNextIcon(true)
            _doCallback()
        end
    end)
end

function StoryTalkItem:isShowing( ... )
	return self._isShowing
end

function StoryTalkItem:isPlayingTalk( ... )
	return self._isPlayingTalk
end

function StoryTalkItem:rapidFinishTalk( ... )
    if self._soundCommond and self._soundCommond ~= "0" then 
        return 
    end

	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end

	if self._contentLabel then 
		self._contentLabel:setText(self._content)
	end
	self._isPlayingTalk = false
end

function StoryTalkItem:stopAudio(  )
    if self._soundCommond and self._soundCommond ~= "0" then
        G_SoundManager:stopSound(G_Path.getVoice(self._soundCommond))
    end
end

return StoryTalkItem
