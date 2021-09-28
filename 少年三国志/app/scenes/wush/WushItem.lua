
require("app.cfg.dead_battle_info")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

local WushItem = class("WushItem", function (  )
    return CCSItemCellBase:create("ui_layout/wush_hero.json")
end)

-- function WushItem.create(...)
--     return require("app.scenes.wush.WushItem").new("ui_layout/wush_hero.json", ...)
-- end

function WushItem:ctor(floorId, towerLayer)
    self._floorId = floorId
    self._tinfo = dead_battle_info.get(floorId)
    self._knight =KnightPic.createKnightPic( self._tinfo.monster_image, self:getPanelByName("Panel_Knight"), "tower_floor_"..floorId,true )
    self:getPanelByName("Panel_Knight"):setScale(0.4)
    -- self._knight:setTouchEnabled(true)
    self._tomb = ImageView:create()
    self._tomb:loadTexture("ui/tower/tomb.png")
    self:getPanelByName("Panel_Knight"):addChild(self._tomb)
    self._tomb:setVisible(false)
    self._tomb:setPosition(ccp(-50,55))
    self:breathe(true)
    
    local floorLabel = self:getLabelByName("Label_floor")
    floorLabel:createStroke(Colors.strokeBrown, 1)
    local nameLabel = self:getLabelByName("Label_name")
    nameLabel:createStroke(Colors.strokeBrown, 1)
    floorLabel:setText(G_lang:get("LANG_WUSH_CENGSHU",{floor = floorId}))
    nameLabel:setText(self._tinfo.name2)

    self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
    self:getImageViewByName("ImageView_Qipao"):setVisible(false)

    self:getPanelByName("Panel_star"):setVisible(false)
    for i = 1,3 do 
            self:getImageViewByName("Image_star"..i):setVisible(false)
    end

    -- self:regisgerWidgetTouchEvent("tower_floor_"..floorId, function(widget,_type)
    --         if _type == TOUCH_EVENT_ENDED then 
    --             towerLayer:_onClickMonsterHead(floorId) end
    --         end)
end

function WushItem:showQipao(f)
    if f == false then
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
        self:getImageViewByName("ImageView_Qipao"):setVisible(false)
        return
    end
    local i = self._floorId % 3
    if i ~= 0  then
        -- self:getImageViewByName("ImageView_QipaoBoss"):setVisible(true)
        GlobalFunc.sayAction(self:getImageViewByName("ImageView_QipaoBoss"))
        self:getImageViewByName("ImageView_Qipao"):setVisible(false)
        self:getLabelByName("Label_duihuaBoss"):setText(self._tinfo.talk)
    else
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
        -- self:getImageViewByName("ImageView_Qipao"):setVisible(true)
        GlobalFunc.sayAction(self:getImageViewByName("ImageView_Qipao"))
        self:getLabelByName("Label_duihua"):setText(self._tinfo.talk)
    end
end

function WushItem:showGray(f)
    -- self._knight:showAsGray(f)
end

function WushItem:pass(star)
    self._tomb:setVisible(true)
    self._knight:setVisible(false)
    self:getLabelByName("Label_floor"):setVisible(false)
    self:getLabelByName("Label_name"):setVisible(false)
    self:getPanelByName("Panel_Knight"):setScale(0.75)
    -- self._knight:setPosition(ccp(0, 90))
    self:getImageViewByName("ImageView_Qipao"):setVisible(false)
    self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
    self:getPanelByName("Panel_star"):setVisible(true)
    for i = 1,3 do 
            self:getImageViewByName("Image_star"..i):setVisible(false)
    end
    self:showStar(star,false)
    self:breathe(false)
end

function WushItem:nopass()
    self._knight:showAsGray(true)
    self:getImageViewByName("ImageView_Qipao"):setVisible(false)
    self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
    self:getPanelByName("Panel_star"):setVisible(false)
    self:breathe(false)
end

function WushItem:showStar(star,isAct,func)
    -- star = 1
    local panel = self:getPanelByName("Panel_star")
    panel:setVisible(true)
    if self.starEffectNode then
        self.starEffectNode:removeFromParentAndCleanup(true)
    end
    if isAct then
        self.starEffectNode = EffectNode.new("effect_" .. star .. "star_play", function(event, frameIndex)
            func()
        end)   
    else
        self.starEffectNode = EffectNode.new("effect_" .. star .. "star", function(event, frameIndex)
            end)  
    end
    self.starEffectNode:setTag(100)
       --starEffectNode:setPosition(pt)
    local _x = panel:getContentSize().width/2
    local _y = panel:getContentSize().height/2
    panel:addNode(self.starEffectNode,10)
    self.starEffectNode:setPosition(ccp(_x,_y))
    -- self.starEffectNode:play()
    if isAct then
        self.starEffectNode:play()
    end
end

function WushItem:come()
    self._knight:showAsGray(false)
    local i = self._floorId % 3
    local target = nil
    if i ~= 0  then
        target = self:getImageViewByName("ImageView_QipaoBoss")
        self:getImageViewByName("ImageView_Qipao"):setVisible(false)
        self:getLabelByName("Label_duihuaBoss"):setText(self._tinfo.talk)
    else
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
        target = self:getImageViewByName("ImageView_Qipao")
        self:getLabelByName("Label_duihua"):setText(self._tinfo.talk)
    end
    -- target:setVisible(true)
    -- target:setScale(0.01)
    -- target:runAction(CCScaleTo:create(0.3, 1))
    GlobalFunc.sayAction(target)
    self:breathe(true)
end

function WushItem:breathe(status)
    if status then
        if self._bossEffect == nil then
                    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                    self._bossEffect = EffectSingleMoving.run(self:getPanelByName("Panel_Knight"), "smoving_idle", nil, {})
        end
    else
        if self._bossEffect ~= nil then
                    self._bossEffect:stop()
                    self._bossEffect = nil
        end
    end
end

return WushItem


