
local ShowLeftTimeLayer = class("ShowLeftTimeLayer",  function()  return display.newNode() end)
require("app.cfg.treasure_fragment_info")

function ShowLeftTimeLayer.create(  )
    return ShowLeftTimeLayer.new()
    
end

function ShowLeftTimeLayer:ctor(  )
    
    
end

function ShowLeftTimeLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

end



--[[
    显示采用富文本 
    成功抢夺  xxx碎片
    ]]
function ShowLeftTimeLayer:setData(key, value)
    self._value = value
    if value == nil then
        return
    end

    self._key = key
    if self._key == "left_time" then
        value = value or 0

        local label = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_END_LEFT_AWARD_TIME"), 24, Colors.darkColors.TITLE_02)
        local label02 = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_END_LEFT_AWARD_TIME_VALUE", {num=value}), 24, Colors.qualityColors[5])
        label:setAnchorPoint(ccp(0, 0.5))
        label02:setAnchorPoint(ccp(0, 0.5))

        local space = 5 --2个文本的间距        
        local width = label:getContentSize().width + label02:getContentSize().width + space
        label:setPosition(ccp(0 - width/2, -30))
        label02:setPosition(ccp(0 - width/2 + label:getContentSize().width + space, -30))
        self:addChild(label)
        self:addChild(label02)
    else

    end
end


function ShowLeftTimeLayer:play()
	--闪动数字直到目标self._value
	self._endCallback()
end

return ShowLeftTimeLayer
