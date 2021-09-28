
local ShowRebelBossResultLayer = class("ShowRebelBossResultLayer",  function()  return display.newNode() end)

function ShowRebelBossResultLayer.create(  )
    return ShowRebelBossResultLayer.new()
    
end

function ShowRebelBossResultLayer:ctor(  )
    
    
end

function ShowRebelBossResultLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

end

function ShowRebelBossResultLayer:setData(key, value)
    self._value = value
    if value == nil then
        return
    end

    dump(value)

    if table.nums(value["First"]) == 0 and table.nums(value["Kill"]) == 0 then
        return
    end

    local nLine = 1
    local nSpaceY = 50
    local nFontSize = 24

    local label = nil
    if value["First"] and table.nums(value["First"]) ~= 0 then
        local tGoods = G_Goods.convert(value["First"].type, value["First"].value, value["First"].size)

        label = GlobalFunc.createGameLabel(G_lang:get("LANG_REBEL_BOSS_FIRST_ATTACK"), nFontSize, Colors.darkColors.DESCRIPTION)
        local label02 = GlobalFunc.createGameLabel(tGoods.name .. "x" .. tGoods.size, nFontSize, Colors.qualityColors[tGoods.quality])
        label:setAnchorPoint(ccp(0, 0.5))
        label02:setAnchorPoint(ccp(0, 0.5))

        local space = 5 --2个文本的间距        
        local width = label:getContentSize().width + label02:getContentSize().width + space
        label:setPosition(ccp(0 - width/2, -nLine * nSpaceY))
        label02:setPosition(ccp(0 - width/2 + label:getContentSize().width + space, -nLine * nSpaceY))
        self:addChild(label)
        self:addChild(label02)
        nLine = nLine + 1
    end

    if value["Kill"] and table.nums(value["Kill"]) ~= 0 then
        local tGoods = G_Goods.convert(value["Kill"].type, value["Kill"].value, value["Kill"].size)

        label = GlobalFunc.createGameLabel(G_lang:get("LANG_REBEL_BOSS_KILL_BY_YOU"), nFontSize, Colors.darkColors.DESCRIPTION)
        local label02 = GlobalFunc.createGameLabel(tGoods.name .. "x" .. tGoods.size, nFontSize, Colors.qualityColors[tGoods.quality])
        label:setAnchorPoint(ccp(0, 0.5))
        label02:setAnchorPoint(ccp(0, 0.5))

        local space = 5 --2个文本的间距        
        local width = label:getContentSize().width + label02:getContentSize().width + space
        label:setPosition(ccp(0 - width/2, -nLine * nSpaceY))
        label02:setPosition(ccp(0 - width/2 + label:getContentSize().width + space, -nLine * nSpaceY))
        self:addChild(label)
        self:addChild(label02)
        nLine = nLine + 1
    end

    if (value["First"] and table.nums(value["First"]) ~= 0) or (value["Kill"] and table.nums(value["Kill"]) ~= 0) then
        label = GlobalFunc.createGameLabel(G_lang:get("LANG_REBEL_BOSS_AWARD_GRANT_CENTER"), nFontSize, Colors.darkColors.TIPS_01)
        label:setAnchorPoint(ccp(0, 0.5))

        local space = 5 --2个文本的间距        
        local width = label:getContentSize().width 
        label:setPosition(ccp(0 - width/2, -nLine * nSpaceY))
        self:addChild(label)
        nLine = nLine + 1
    end

--    self:setContentSize(CCSizeMake(0, label:getContentSize().height + 20))
end


function ShowRebelBossResultLayer:play()
	--闪动数字直到目标self._value
	self._endCallback()
end

return ShowRebelBossResultLayer
