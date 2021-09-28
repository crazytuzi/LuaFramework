
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local BoxNode = class("BoxNode", function (  )
	return display.newNode()
end)

 -- box1 金色箱子
 -- box2  银色
 -- box3 铜色
function BoxNode:ctor(boxType, itemList, onOpenCallback)
	self._boxType = boxType
	self._itemList = itemList

	self._onOpenCallback = onOpenCallback

	self:setNodeEventEnabled(true)
	self:setCascadeOpacityEnabled(true)

  self._imageMap = {cu="diaoluo_daoju.png",gold="diaoluo_wujiang.png",silver="diaoluo_zhuangbei.png"}
	self._node = EffectMovingNode.new("moving_fightend1_box", 
		function(key)
            if key == "box_normal" then
            	-- local image = CCSprite:create(G_Path.getFightEndDir() .. boxType ..".png")		
              local image = CCSprite:create(G_Path.getBattleImage(self._imageMap[boxType]))
              image:setCascadeOpacityEnabled(true)

              return image    
           	elseif key == "box_open" then
              local image = CCSprite:create(G_Path.getBattleImage(self._imageMap[boxType]))
       		    return image   
            end
        end,
        function(event)
            if event == "open"then
               	self._node:pause()
               	--底部加上一个发光特效


               	self._effectNode = EffectNode.new("effect_finish1", function(event, frameIndex) end)      
               	self._effectNode:play()
               	self:addChild(self._effectNode, 1)

               	if self._onOpenCallback ~= nil then
               		self._onOpenCallback()
               	end
            end   
        end
    )



    self:addChild(self._node, 2)


    

end


function BoxNode:play()
    self._node:play()    
end

function BoxNode:getType()
    return self._boxType
end

function BoxNode:getItemList()
    return self._itemList
end

function BoxNode:removeEffect()
   	if self._effectNode then
   		self._effectNode:stop()
   		self._effectNode:removeFromParentAndCleanup(true)
   		self._effectNode = nil
   	end 
end

function BoxNode:onExit()
    self:setNodeEventEnabled(false)
    if  self._node then
        self._node:stop()
    end

    if self._effectNode then
    	self._effectNode:stop()
    end
    
end
return BoxNode
