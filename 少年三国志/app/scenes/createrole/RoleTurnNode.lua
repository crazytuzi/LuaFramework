local _knightPic = require("app.scenes.common.KnightPic")
local TurnNode = require("app.scenes.common.turnplate.TurnNode")
local RoleTurnNode = class("RoleTurnNode", TurnNode)



function RoleTurnNode.create(...)
    return RoleTurnNode.new("ui_layout/createrole_Knight.json", ...)
end

RoleTurnNode._lastPlaySound = 0

function RoleTurnNode:ctor(...)
    self.super.ctor(self,...)
    self._roleId = 0
    self._image = nil
end

function RoleTurnNode:setData(roleId)

    self._roleId = roleId
 -- self:getImageViewByName("ImageView_huwei"):loadTexture(G_Path.getKnightPic(knight_info.get(1).res_id))
 -- self:getImageViewByName("ImageView_shenshe"):loadTexture(G_Path.getKnightPic(knight_info.get(3).res_id))
 -- self:getImageViewByName("ImageView_moushi"):loadTexture(G_Path.getKnightPic(knight_info.get(2).res_id))
 -- self:getImageViewByName("ImageView_yueshi"):loadTexture(G_Path.getKnightPic(knight_info.get(4).res_id))


    local resId = knight_info.get(roleId).res_id
    local _pedestal = self:getPanelByName("Panel_Knight")
    self._image = _knightPic.createKnightNode(resId, "sprite_" .. self._roleId, true)
    self._image:setScale(0.8)
    _pedestal:addNode(self._image)


    if roleId == 1 then
        self:getImageViewByName("Image_name"):loadTexture("ui/createrole/huwei.png")
    elseif roleId == 2 then
        self:getImageViewByName("Image_name"):loadTexture("ui/createrole/moushi.png")

    elseif roleId == 3 then
        self:getImageViewByName("Image_name"):loadTexture("ui/createrole/shenshe.png")

    elseif roleId == 4 then
        self:getImageViewByName("Image_name"):loadTexture("ui/createrole/yueshi.png")
    end
                    
    -- self:showName(false)
    self:setSelected(false)

    -- -- --侠客呼吸动作
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    EffectSingleMoving.run(self._image, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))

end

-- function RoleTurnNode:showName(b)
--     self:getPanelByName("Panel_Name"):setVisible(b)
-- end

function RoleTurnNode:setSelected(b)
    self:getPanelByName("Panel_Name"):setVisible(b)
    self:getImageViewByName("ImageView_Pedestal"):setVisible(not b)
    if b then 
        if type(RoleTurnNode._lastPlaySound) == "string" then 
            G_SoundManager:stopSound(RoleTurnNode._lastPlaySound)
        end
        RoleTurnNode._lastPlaySound = knight_info.get(self._roleId).common_sound
        G_SoundManager:playSound(knight_info.get(self._roleId).common_sound)
    end
end

function RoleTurnNode:setImageScale(s)
    self:getRootWidget():setScale(s)
end

function RoleTurnNode:getImageScale()
    return self._image:getScale()*self:getRootWidget():getScale()
end

function RoleTurnNode:getImageWorldPosition()
    return self._image:convertToWorldSpace(ccp(0, 0))
end



function RoleTurnNode:getRoleId()
    return self._roleId
end

--pt是个世界坐标, 判断Pt是否落在RoleTurnNode 上
function RoleTurnNode:containsPt(pt)
    local image 




    if image == nil then
        return false
    end
    image = self._image.imageNode 

 
    local imagePt = image:convertToNodeSpace(  pt  )
    --print("ptx=" .. imagePt.x .. ",pty=" .. imagePt.y)
    local size = image:getContentSize()
    local w = size.width*image:getScaleX()
    local h = size.height*image:getScaleY()

    local rect = CCRectMake(-w/2, -h/2, w, h)
    --return rect:containsPoint(imagePt)
    return G_WP8.CCRectContainPt(rect, imagePt)
end


return RoleTurnNode
