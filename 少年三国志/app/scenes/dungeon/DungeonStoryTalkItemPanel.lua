local DungeonStoryTalkItemPanel = class("DungeonStoryTalkItemPanel",function()
    return Layout:create()
end
    )

function DungeonStoryTalkItemPanel:ctor(...)
    self._height = 0
    self.strList = {}
    self.maxHeight = 550
    self.isCanClick = false
    self.copyItem = nil
    self.itemHeight = nil
    self.itemPosX = 0
    self._skip = false
    self.itemList = {}
end

--@param name 说话者名字 text 说话内容 pos箭头位置 如果是旁白 pos则传0
function DungeonStoryTalkItemPanel:createItem(name,text,pos,dialogue_type)
    self.isCanClick = false
    self._skip = false
    if self.copyItem  == nil then
        self.copyItem = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonStoryTalkItem.json")
        self.copyItem:setVisible(false)
        self:addChild(self.copyItem)
        self.itemHeight = self.copyItem:getSize().height
    end
    
    local item = self.copyItem:clone()
    item:setVisible(true)
    table.insert(self.itemList, 1, item)
    self:setItemOpacity(true)
    item:setCascadeOpacityEnabled(true)
    self:addChild(item)
    

    
   -- item:setAnchorPoint(ccp(0,1))
    local bg = item:getChildByName("Image_Bg")
            -- 提示谁说话
    for i=1,3 do
        local arrow = bg:getChildByName("Image_Arrow" .. i)
        arrow:setVisible(i == pos and dialogue_type < 3)
        if i== pos then
            arrow = tolua.cast(arrow,"ImageView")
            arrow:loadTexture(G_Path.getStoryArrow(dialogue_type))
        end
    end
    
    bg = tolua.cast(bg,"ImageView")
    bg:loadTexture(G_Path.getItemBg(dialogue_type))
    local size = item:getSize()
    local nameBg = bg:getChildByName("Image_NameBg")
    nameBg:setVisible(true)
    if nameBg then
        self:splitStr(text)
        item:setPosition(ccp((self:getSize().width-size.width)/2,self._height))
        self._height = self._height +size.height
        local nameLabel = nameBg:getChildByName("Label_Name")
        nameLabel = tolua.cast(nameLabel,"Label")
        nameLabel:setText(name) 
        
        local descLabel = bg:getChildByName("Label_Desc")
        descLabel = tolua.cast(descLabel,"Label")
        descLabel:ignoreContentAdaptWithSize(true)
        descLabel:setColor(dialogue_type < 3 and Colors.lightColors.DESCRIPTION or Colors.darkColors.DESCRIPTION) 

        descLabel:setText("")

        item:setScale(0.1)
        -- 根据说话人物位置弹出 对话框位置
        local _pos = item:getPositionInCCPoint()
        if pos == 1 then -- 左
            item:setPosition(ccp(_pos.x- size.width ,_pos.y))
        elseif pos == 2 then -- 中
            item:setPosition(ccp(_pos.x + size.width/2,_pos.y))
        else -- 右
            item:setPosition(ccp(_pos.x+ size.width ,_pos.y))
        end
        local arr = CCArray:create()        
        arr:addObject(CCSpawn:createWithTwoActions(CCEaseBackOut:create(CCMoveTo:create(0.6,_pos)), CCEaseBackOut:create(CCScaleTo:create(0.6,1))) )
        arr:addObject(CCCallFunc:create(function()self:_showText(item,bg,dialogue_type) end))
        item:runAction(CCSequence:create(arr))
        local pt = self:getPositionInCCPoint()
        local labelHeight = descLabel:getContentSize().height
        pt.y = self:getSize().height - self._height 
        self:runAction(CCMoveTo:create(0.3,pt))

        
    end

end

-- 设置是否跳过当次对话
function DungeonStoryTalkItemPanel:setIsSkip(_bSkip)
    self._skip = _bSkip
end

function DungeonStoryTalkItemPanel:isSkip()
    return self._skip
end

-- 设置块透明度
function DungeonStoryTalkItemPanel:setItemOpacity(isGray)
    if #self.itemList > 1 then
        for i=2,#self.itemList do
            self.itemList[i]:setOpacity(isGray == true and 200 or 255)
            local bg = self.itemList[i]:getChildByName("Image_Bg")
            bg:getChildByName("Image_Next"):setVisible(false)
        end
    end
end

function DungeonStoryTalkItemPanel:_movePanel(item)
    self:setPositionY(self._height)
end

function DungeonStoryTalkItemPanel:_showText(item,bg,dialogue_type)
    --bg:setAnchorPoint(ccp(0.5,1))
    --bg:setPositionX(self.itemPosX)
    local nameBg = bg:getChildByName("Image_NameBg")
    nameBg:setVisible(dialogue_type ~= 3)
    local descLabel = bg:getChildByName("Label_Desc")
    descLabel = tolua.cast(descLabel,"Label")
    local fontSize = descLabel:getFontSize()
    local labelHeight = descLabel:getContentSize().height
    local desc = ""
    local lenth = descLabel:getSize().width/fontSize
    local num = 1
    local ttf = descLabel:getVirtualRenderer()
    ttf = tolua.cast(ttf,"CCLabelTTF")
    
    function addNewLine(_num)
        -- 根据文字调整块大小
        if (_num <= #self.strList) and _num/lenth*labelHeight > item:getSize().height - self.itemHeight +labelHeight then
            local size = item:getSize()
            size.height = size.height + labelHeight
            item:setSize(CCSize(size.width,size.height))
            
            --local bg = item:getChildByName("Image_Bg")
            size = bg:getSize()
            size.height = size.height + labelHeight
            bg:setSize(CCSize(size.width,size.height))
            item:setPositionY(item:getPositionY()+labelHeight)
            local dim = ttf:getDimensions()
            dim.height = dim.height + labelHeight
            descLabel:setTextAreaSize(CCSize(dim.width,dim.height))
            descLabel:setSize(CCSize(dim.width,dim.height))
            self._height = self._height + labelHeight
            self:setPositionY(self:getSize().height - self._height)
        end    
    end
    
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
    
    self._timer = G_GlobalFunc.addTimer(0.05,function()
        
        if self._skip == true then -- 跳过当次对话
            while num-1 < #self.strList do
                desc =desc  .. self.strList[num]
                num = num + 1
                addNewLine(num)
                descLabel:setText(desc)
            end
        else
            if self.strList[num] then
                desc =desc  .. self.strList[num]
                num = num + 1
                addNewLine(num)

                descLabel:setText(desc)
            end
            if num <= #self.strList then
                desc = desc .. self.strList[num]
                num = num + 1
                addNewLine(num)
                descLabel:setText(desc)
            end      
        end
        
        if num-1 >= #self.strList then
            if self._timer then
                G_GlobalFunc.removeTimer(self._timer)
                self._timer = nil
            end
            self.strList = {}
            bg:getChildByName("Image_Next"):setPositionY(-bg:getSize().height)
            bg:getChildByName("Image_Next"):setVisible(true)
            --self._height = item:getPositionY()
            self.isCanClick = true
        end
        --descLabel:sets

    end
        )
end

function DungeonStoryTalkItemPanel:splitStr(str)
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        self.strList[#self.strList+1] = uchar 
    end
end

function DungeonStoryTalkItemPanel:isClick()
    return self.isCanClick
end

function DungeonStoryTalkItemPanel:setClick(bClick)
    self.isCanClick = bClick
end

function DungeonStoryTalkItemPanel:touchMovePanel(dir)
    local posY = self:getPositionY()
    posY = posY + dir*10
    local size = self:getSize()
    if self._height > size.height then
        self:setItemOpacity(false)
        if posY > 0 then
            posY = 0
        elseif posY <= size.height - self._height then
            posY = size.height - self._height
        end
        self:setPositionY(posY)
    end
end

return DungeonStoryTalkItemPanel

