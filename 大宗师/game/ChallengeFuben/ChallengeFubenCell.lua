--[[
 --
 -- add by vicky
 -- 2015.03.12   
 --
 --]]


local ChallengeFubenCell = class("ChallengeFubenCell", function () 
    return CCTableViewCell:new() 	 
end)


function ChallengeFubenCell:getContentSize() 
    local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("challenge/challengeFuben_item.ccbi", proxy, rootNode) 
    local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf() 

    return size 
end 


function ChallengeFubenCell:create(param)
    local viewSize = param.viewSize 
    local itemData = param.itemData 
    local challengFunc = param.challengFunc 

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("challenge/challengeFuben_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, 0)
    self:addChild(node) 

    self._rootnode["challenge_btn"]:addHandleOfControlEvent(function(eventName,sender) 
        self:setBtnEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if challengFunc ~= nil then 
            challengFunc(self) 
        end 
    end, CCControlEventTouchUpInside)     

    self:refreshItem(itemData)

    return self 
end


function ChallengeFubenCell:refresh(itemData) 
    self:refreshItem(itemData) 
end 


function ChallengeFubenCell:setBtnEnabled(bEnable)
    self._rootnode["challenge_btn"]:setEnabled(bEnable) 
end 


function ChallengeFubenCell:refreshItem(itemData) 
    -- 标题、背景 
    local titlIconName = "#cfb_item_title_" .. itemData.diffBg .. ".png" 
    local itemBgName 

    local bgNode = self._rootnode["tag_bg"] 
    local iconNode = self._rootnode["title_icon"] 
    local iconBg 
    if itemData.isOpen == true then 
        self:setBtnEnabled(true) 
        itemBgName = "#cfb_item_bg_" .. itemData.diffBg .. ".png" 
        iconBg = display.newSprite(titlIconName)
    else 
        self:setBtnEnabled(false) 
        itemBgName = "#cfb_item_bg_gray.png"
        iconBg = display.newGraySprite(titlIconName, {0.4, 0.4, 0.4, 0.1}) 
    end 

    local itemBg = display.newScale9Sprite(itemBgName, 0, 0, bgNode:getContentSize()) 
    itemBg:setPosition(bgNode:getContentSize().width/2, bgNode:getContentSize().height/2)
    bgNode:removeAllChildren() 
    bgNode:addChild(itemBg) 

    iconNode:removeAllChildren()
    iconNode:addChild(iconBg) 

    self._rootnode["level_lbl"]:setString("Lv." .. tostring(itemData.needLv)) 
    self._rootnode["hard_lbl"]:setString(itemData.hardMsg) 
    self._rootnode["zhanli_lbl"]:setString(itemData.fight) 

end



return ChallengeFubenCell 

