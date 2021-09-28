
require("app.cfg.tower_info")
require("app.cfg.item_info")
Path = require("app.setting.Path")
Goods = require("app.setting.Goods")
KnightPic = require("app.scenes.common.KnightPic")

local TowerItem = class("AwardLayer",UFCCSNormalLayer)

function TowerItem.create(...)
    return require("app.scenes.tower.TowerItem").new("ui_layout/tower_TowerItem.json", ...)
end

function TowerItem:ctor(jsonfile, floorId, towerLayer)
    self.super.ctor(self, jsonfile)
    self._floorId = floorId
    self._tinfo = tower_info.get(floorId)
    self._knight =KnightPic.createKnightPic( self._tinfo.monster_image, self:getPanelByName("Panel_Knight"), "tower_floor_"..floorId )
    self:getPanelByName("Panel_Knight"):setScale(0.4)
    self._knight:setTouchEnabled(true)
    local curfloor = towerLayer:getCurrentFloor()
    local towerInfo = towerLayer:getTowerInfo()
    self._tomb = ImageView:create()
    self._tomb:loadTexture("ui/tower/mubei.png")
    self:getPanelByName("Panel_Knight"):addChild(self._tomb)
    self._tomb:setVisible(false)
    self._tomb:setPosition(ccp(0,25))
    
    local floorLabel = self:getLabelByName("Label_floor")
    if self._tinfo.floor_type==2 then
        floorLabel:setColor(ccc3(255 , 0, 255))
        self:getImageViewByName("Image_namedi"):loadTexture("ui/dungeon/mingpai_boss.png")
    else
        floorLabel:setColor(ccc3(255 , 255, 255))
    end
    floorLabel:setText(G_lang:get("LANG_TOWER_CENGSHU",{floor = floorId}))
    floorLabel:createStroke(Colors.strokeBrown, 1)

    local timesdes = self:getLabelByName("Label_timesdes")
    local times = self:getLabelByName("Label_times")
    timesdes:setText(G_lang:get("LANG_TOWER_TIAOZHANCISHU"))
    timesdes:createStroke(Colors.strokeBrown, 1)
    timesdes:setVisible(true)
    times:createStroke(Colors.strokeBrown, 1)
    local max = self:getLabelByName("Label_max")
    max:setText(G_lang:get("LANG_TOWER_REACHMAX"))
    max:createStroke(Colors.strokeBrown, 1)
    max:setVisible(false)

    self._timesLeft = towerLayer:getCurTryLeft()
    self._timesTotal = towerLayer:getMaxTry()
        

    local i = floorId % 5
    if i ~= 0  then
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(true)
        self:getImageViewByName("ImageView_Qipao"):setVisible(false)
        self:getLabelByName("Label_duihuaBoss"):setText(self._tinfo.talk)
    else
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
        self:getImageViewByName("ImageView_Qipao"):setVisible(true)
        self:getLabelByName("Label_duihua"):setText(self._tinfo.talk)
    end
    if curfloor ~= floorId then 
        self._knight:showAsGray(true)
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
        self:getImageViewByName("ImageView_Qipao"):setVisible(false)
        times:setVisible(false)
        timesdes:setVisible(false)
        self._timesLeft = self._timesTotal
    end

    if self._timesLeft == 0 then 
        times:setColor(Colors.uiColors.RED)
        self:getLabelByName("Label_duihuaBoss"):setText(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
        self:getLabelByName("Label_duihua"):setText(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
    end
    times:setText(self._timesLeft.."/"..self._timesTotal)
    
    self:regisgerWidgetTouchEvent("tower_floor_"..floorId, function(widget,_type)
            if _type == TOUCH_EVENT_ENDED then 
                towerLayer:_onClickMonsterHead(floorId) end
            end)
end

function TowerItem:showGray(f)
    -- self._knight:showAsGray(f)
end

function TowerItem:pass(f)
    self._tomb:setVisible(true)
    self._knight:setVisible(false)
    self:getPanelByName("Panel_Knight"):setScale(1)
    self._knight:setPosition(ccp(0, 90))
    self:getLabelByName("Label_timesdes"):setVisible(false)
    self:getLabelByName("Label_times"):setVisible(false)
    self:getImageViewByName("ImageView_Qipao"):setVisible(false)
    self:getImageViewByName("ImageView_QipaoBoss"):setVisible(false)
end

function TowerItem:come()
    self._knight:showAsGray(false)
    local i = self._floorId % 5
    if i ~= 0 then
        self:getImageViewByName("ImageView_QipaoBoss"):setVisible(true)
    else
        self:getImageViewByName("ImageView_Qipao"):setVisible(true)
    end
    self:getLabelByName("Label_timesdes"):setVisible(true)
    self:getLabelByName("Label_times"):setVisible(true)
end

function TowerItem:refresh(times)
    self._timesLeft = times
    if self._timesLeft == 0 then 
        self:getLabelByName("Label_times"):setColor(Colors.uiColors.RED)
        self:getLabelByName("Label_duihuaBoss"):setText(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
        self:getLabelByName("Label_duihua"):setText(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
    end
    self:getLabelByName("Label_times"):setText(self._timesLeft.."/"..self._timesTotal)
end


function TowerItem:showMax(times)
    self:getLabelByName("Label_max"):setVisible(times)
end

return TowerItem


