local ArenaScrollViewItem = class("ArenaScrollViewItem",function()
    -- return ImageView:create()
    return CCSItemCellBase:create("ui_layout/arena_ListViewItem.json")
end)
local EffectNode = require("app.common.effects.EffectNode")
local ArenaDefier = require("app.scenes.arena.ArenaDefier")


-- local ITEM_HEIGHT = 190

--[[
	index为在listview中的index
]]
function ArenaScrollViewItem:ctor(isLeft,layer)
    self._isLeft = isLeft
    self._layer = layer
    self._arenaDefier = nil
    self:setTouchEnabled(true)
    self._bgImageView = UIHelper:seekWidgetByName(self,"ImageView_bg")
    self._bgImageView = tolua.cast(self._bgImageView,"ImageView")
    self._bgImageView:loadTexture("ui/arena/bg_jinji_" .. (isLeft%6+1) .. ".png",UI_TEX_TYPE_LOCAL)
end

function ArenaScrollViewItem.getHeight()
    return 190
end

function ArenaScrollViewItem:isLeft()
    return self._isLeft
end

function ArenaScrollViewItem:getUser()
    return self._user
end

function ArenaScrollViewItem:getZorder()
    return self._zorder
end

--获取武将的矩形,世界坐标系
function ArenaScrollViewItem:getKnightRect()
    if self._arenaDefier == nil then
        return CCRectMake(0,0,0,0)
    end
    return self._arenaDefier:getKnightRect()
end

function ArenaScrollViewItem:updateItem(isLeft,user,zorder)
    if type(zorder) == "number" then
        self:setZOrder(zorder)
    end
    self._isLeft = isLeft
    self._user = user
    self._zorder = zorder
    if user == nil then 
        if self._arenaDefier ~= nil then
            self._arenaDefier:setVisible(false)
        end
    else
        if self._arenaDefier == nil then
            self._arenaDefier = ArenaDefier.new()
            self:addChild(self._arenaDefier)
        end
        self._arenaDefier:setVisible(true)
        self._arenaDefier:update(isLeft%2==0,user,self._layer,function(widget) 
            self:sendChallenge(user,widget)
        end)

        if isLeft %2 == 1 then
            self._arenaDefier:setPosition(ccp(-50,180))
        else
            self._arenaDefier:setPosition(ccp(210,180))
        end
    end
    self._bgImageView:loadTexture("ui/arena/bg_jinji_" .. (isLeft%6+1) .. ".png",UI_TEX_TYPE_LOCAL)
end

function ArenaScrollViewItem:sendChallenge(user,widget)
    if G_Me.userData.id == user.user_id then
        G_MovingTip:showMovingTip(G_lang:get("LANG_ARENA_CANNOT_ATTACK_SELF"))
        return
    end
    local CheckFunc = require("app.scenes.common.CheckFunc")
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.arena.ArenaScene", {})
    if CheckFunc.checkKnightFull(scenePack) then
        return
    elseif CheckFunc.checkEquipmentFull(scenePack) then
        return
    elseif CheckFunc.checkTreasureFull(scenePack) then
        return
    end

    --100名以内才能攻打前10名
    if user.rank <= 10 and self._layer:getMyRank() >20 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_ARENA_RANK_LESS_THAN_20"))
        return
    end

    if G_Me.userData.spirit < 2 then
        G_GlobalFunc.showPurchasePowerDialog(2)
        return
    end
    self._layer:setScrollViewEnable(false)
    --记录挑战者的名词
    self._layer:setChallengeRank(user.rank)
    G_HandlersManager.arenaHandler:sendChallenge(user.rank)
end


--检查是否能挑战，即检查包裹是否满了,有一类包裹满了就不满足
function ArenaScrollViewItem:_checkChallengeEnable()
    local bagData = G_Me.bagData
    return not(bagData:isEquipmentFull() or bagData:isKnightFull())
end


--单个更新
function ArenaScrollViewItem:playEffect(user,user02)
    if not user or not user02 then
        return
    end    
    
    local _callback = function() 
        self._arenaDefier:update(self:isLeft()%2==0,user,self,function(widget) 
            local CheckFunc = require("app.scenes.common.CheckFunc")
            local scenePack = G_GlobalFunc.sceneToPack("app.scenes.arena.ArenaScene", {})
            if CheckFunc.checkKnightFull(scenePack) then
                return 
            elseif CheckFunc.checkEquipmentFull(scenePack) then
                return 
            elseif CheckFunc.checkTreasureFull(scenePack) then
                return 
            end
            self:sendChallenge(user,widget)
        end)
    end

    if user.user_id == G_Me.userData.id then
        local left = self:isLeft()
        require("app.cfg.knight_info")
        self._arenaDefier:getQizhi():setVisible(false)
        self._arenaDefier:playDefierAnimation(user,user02,left%2==0,function()
                _callback()
                --播放旗帜下落的动画
                self._arenaDefier:getQizhi():setVisible(true)
                local size = CCDirector:sharedDirector():getWinSize()
                local posX,posY = self._arenaDefier:getQizhi():getPosition() 
                self._arenaDefier:getQizhi():setPosition(self:convertToWorldSpace(ccp(posX,size.height)))
                local ease1 = CCMoveTo:create(0.8*posY/size.height, ccp(posX,posY))
                local arr = CCArray:create()
                arr:addObject(ease1)
                arr:addObject(CCCallFunc:create(function (  )
                    self._arenaDefier:getQizhi():setVisible(true)
                    self._layer:flushDown()
                end))
                self._arenaDefier:getQizhi():runAction(CCSequence:create(arr)) 

                -- 添加笑脸
                self._arenaDefier:setFaceWinVisible(true, left%2==0, false)
            end)
    else
        _callback()
    end
end

-- 挑战失败时对手的效果
function ArenaScrollViewItem:playLoseEffect( user, user02 )
    -- 添加吐舌
    local left = self:isLeft()
    self._arenaDefier:setFaceWinVisible(true, left%2==0, true)
end

function ArenaScrollViewItem:showTrashTalkDialog( isRankHigher )
    self._arenaDefier:showTrashTalkDialog(isRankHigher, self:isLeft() % 2 == 0)
end

function ArenaScrollViewItem:hideTrashTalkDialog( isRankHigher )
    self._arenaDefier:hideTrashTalkDialog()
end

function ArenaScrollViewItem:isMe()
    if self._user == nil then
        return false
    end
    return self._user.user_id == G_Me.userData.id
end
function ArenaScrollViewItem:destory()
    self._arenaDefier:destory()
    self._arenaDefier = nil
end

return ArenaScrollViewItem