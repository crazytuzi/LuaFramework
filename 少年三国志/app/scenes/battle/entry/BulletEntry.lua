-- BulletEntry

require "app.cfg.knight_info"

local BulletEntry = class("BulletEntry", require "app.scenes.battle.entry.Entry")

function BulletEntry:ctor(bulletJsonId, attacker, victim, battleField, eventHandler, changeHp, isCritical, isDodge, isDouble, isPierce)
    
    self._attacker = attacker
    self._victim = victim
    self._changeHp = changeHp
    self._isCritical = isCritical
    self._isDodge = isDodge
    self._isDouble = isDouble
    self._isPierce = isPierce
    
    BulletEntry.super.ctor(self, bulletJsonId, nil, battleField, eventHandler)
end

function BulletEntry:initEntry()
    
    BulletEntry.super.initEntry(self)
    
    local attacker = self._attacker
    local victim = self._victim
    local bulletJson = self._data

    if not self._bullet then
        
        -- 初始特效的位移等数据
        local spJsonData = {}
        
        -- 配置参数
        spJsonData.spId = bulletJson
        
        -- 加载特效, 并添加进新的渲染队列
        local SpEntry = require "app.scenes.battle.entry.SpEntry"
        self._bullet = SpEntry.new(spJsonData, attacker, self._battleField)
        self._bullet:retainEntry()
        assert(self._bullet.isForever, "This bullet sp("..bulletJson..") must be forever !")
        
        local events = self._bullet:getData().events
        if events then
            for k, v in pairs(events) do
                self.isNonrotating = v == "Non-rotating"
                if self._isNonrotating then break end
            end
        end
        
        self._battleField:addToNormalSpNode(self._bullet:getObject())
        
        -- 计算位置
        -- 先获取每个角色身上关于弹道的偏移量
        local card = attacker:getCardConfig()
        local jsonName = G_Path.getBattleConfig("knight", card.res_id.."_fight")
        local cardJson = self:getJson(jsonName) or decodeJsonFile(jsonName)
        self:setJson(jsonName, cardJson)
        local bulletY = cardJson.bulletY * attacker:getScaleY()
        local bulletR = cardJson.bulletR * attacker:getScaleY()

        local attackerPosition = attacker:getCardBody():convertToWorldSpaceAR(ccp(0, bulletY))

        card = victim:getCardConfig()
        if not victim.isBoss then
            jsonName = G_Path.getBattleConfig("knight", card.res_id.."_fight")
            cardJson = self:getJson(jsonName) or decodeJsonFile(jsonName)
            self:setJson(jsonName, cardJson)
        else
            cardJson = {bulletY = 100}
        end
        bulletY = cardJson.bulletY * victim:getScaleY()
        
        local victimPosition = victim:getCardBody():convertToWorldSpaceAR(ccp(0, bulletY))
        
        local distance = ccpSub(victimPosition, attackerPosition)
        local angle = 0
        local percent = 0
        if device.platform == "wp8" or device.platform == "winrt" then 
            angle = math.deg(cc.pToAngleSelf(distance))
            percent = bulletR / math.sqrt( distance.x * distance.x + distance.y * distance.y )
        else
            angle = math.deg(distance:getAngle())
            percent = bulletR / distance:getLength()
        end
        attackerPosition = ccpAdd(attackerPosition, ccpMult(distance, percent))
        self._distance = ccpSub(victimPosition, attackerPosition)
        
        -- 受击者位置偏移
        self._dstOffset = ccp(0, bulletY)
        
        -- 初始化弹道的位置等参数
        self._bullet:setPositionXY(self._bullet:getObject():getParent():convertToNodeSpaceXY(attackerPosition.x, attackerPosition.y))
        if not self.isNonrotating then
            self._bullet:setRotation(angle * -1)
        end
    end
    
    self:addEntryToNewQueue(self._bullet, self._bullet.updateEntry)
    
    self:addEntryToQueue(self, self.update)
    
end

function BulletEntry:getVictim() return self._victim end
function BulletEntry:getChangeHp() return self._changeHp end
function BulletEntry:getIsCritical() return self._isCritical end
function BulletEntry:getIsDodge() return self._isDodge end
function BulletEntry:getIsDouble() return self._isDouble end
function BulletEntry:getIsPierce() return self._isPierce end


function BulletEntry:update(frameIndex)

    local victim = self._victim
    
    local dstPositionX, dstPositionY = self._bullet:getObject():convertToNodeSpaceXY(victim:getCardBody():convertToWorldSpaceARXY(self._dstOffset.x, self._dstOffset.y))
    local rectWidth = display.width/6   -- 取屏幕的六分之一宽度作为碰撞区域，避免如果写死宽度会导致理论上尺寸非常巨大的屏幕可能也还会错过碰撞点
    local dstRect = CCRectMake(dstPositionX - rectWidth/2, dstPositionY - rectWidth/2, rectWidth, rectWidth)
    
    local intersectRc = false
    if device.platform == "wp8" or device.platform == "winrt" then 
        intersectRc = cc.rectIntersectsRect(self._bullet:boundingBox(), dstRect)
    else
        intersectRc = self._bullet:boundingBox():intersectsRect(dstRect)
    end
    if intersectRc then
        self._bullet:stop()
        return true, "bullet_hurt", self
    else
        -- move
        --local angle = self._distance:getAngle()
        -- local angle = 0 
        -- if self._distance.x == 0 then 
        --     angle = 90
        -- else
        --     angle = math.deg(math.atan2(self._distance.y, self._distance.x))
        -- end
        local angle = 0
        if device.platform == "wp8" or device.platform == "winrt" then 
            angle = cc.pToAngleSelf(self._distance)
        else
            angle = self._distance:getAngle()
        end
        local unit = 90   -- speed pix/frame
        local distanceX, distanceY = math.cos(angle)*unit, math.sin(angle)*unit
        local _dstPositionX, _dstPositionY = self._bullet:getPosition()
        
        _dstPositionX = _dstPositionX + distanceX
        _dstPositionY = _dstPositionY + distanceY
        self._bullet:setPositionXY(_dstPositionX, _dstPositionY)
        
        local LocationFactory = require "app.scenes.battle.Location"
        local scaleFactor = LocationFactory.getScaleByPosition{_dstPositionX, _dstPositionY}
        self._bullet:setScaleX(scaleFactor)
        self._bullet:setScaleY(scaleFactor)
    end
    
    return false
end

function BulletEntry:destroyEntry()
    
    BulletEntry.super.destroyEntry(self)
    
    if self._bullet then
        self._bullet:releaseEntry()
        self._bullet = nil
    end
    
end

return BulletEntry
