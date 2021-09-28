
local ShowRobResultLayer = class("ShowRobResultLayer",  function()  return display.newNode() end)
require("app.cfg.treasure_fragment_info")

function ShowRobResultLayer.create(  )
    return ShowRobResultLayer.new()
    
end

function ShowRobResultLayer:ctor(  )
    
    
end

function ShowRobResultLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

end



--[[
    显示采用富文本 
    成功抢夺  xxx碎片
    ]]
function ShowRobResultLayer:setData(key, value)
    self._value = value
    if value == nil then
        return
    end
    local fragment = treasure_fragment_info.get(value)
    self._key = key
    local label 
    if self._value > 0 and fragment then
        label = GlobalFunc.createGameLabel(G_lang:get("LANG_FIGHTEND_ROB_OK"), 26, Colors.darkColors.TITLE_01)
        local label02 = GlobalFunc.createGameLabel(fragment.name, 26, Colors.qualityColors[fragment.quality])
        label:setAnchorPoint(ccp(0, 0.5))
        label02:setAnchorPoint(ccp(0, 0.5))

        local space = 5 --2个文本的间距        
        local width = label:getContentSize().width + label02:getContentSize().width + space
        label:setPosition(ccp(0 - width/2,0))
        label02:setPosition(ccp(0 - width/2 + label:getContentSize().width + space,0))
        self:addChild(label)
        self:addChild(label02)
        local sprite = CCSprite:create(G_Path.getTreasureFragmentIcon(fragment.res_id))
        sprite:setPositionY(label:getPositionY()-70)
        self:addChild(sprite)
    else
        label = GlobalFunc.createGameLabel(G_lang:get("LANG_FIGHTEND_ROB_FAILED"), 26, Colors.darkColors.DESCRIPTION)

        self:addChild(label)
    end

    self:setContentSize(CCSizeMake(0, label:getContentSize().height + 20))
end


function ShowRobResultLayer:play()
	--闪动数字直到目标self._value
	self._endCallback()
end

return ShowRobResultLayer
