
local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local ShowValueList = class ("ShowValueList", function() return display.newNode() end)

local ShowValueLayer = require "app.scenes.common.fightend.controls.ShowValueLayer"
local ShowExpLayer = require "app.scenes.common.fightend.controls.ShowExpLayer"
local ShowRobResultLayer = require "app.scenes.common.fightend.controls.ShowRobResultLayer"

local ShowAwardLayer = require "app.scenes.common.fightend.controls.ShowAwardLayer"

local ShowDailyPVPValueLayer = require "app.scenes.common.fightend.controls.ShowDailyPVPValueLayer"
local ShowLeftTimeLayer = require "app.scenes.common.fightend.controls.ShowLeftTimeLayer"

function ShowValueList:ctor(result,keys, data, endCallback)
    self._result = result
    self._keys = {}
    --检查一下多余的key
    if keys and #keys > 0 then
        for k,v in ipairs(keys) do
            if data[v] then
                self._keys[#self._keys+1] = v
            end
        end
    end

    --key的长度，用于排版
    self._keyLen = self._keys and #self._keys or 1
    self._data = data


    self._endCallback =  endCallback
    self._ctrlPositionY = -100
    self:setNodeEventEnabled(true)
end

--失败走一套
--胜利不变
function ShowValueList:play()
    --先显示奖励标题,然后一个一个play
    local awardTitle = ""
    local awardTitleAnimation = ""

    if self._result == "win"  then
        awardTitleAnimation = "moving_fightend1_win_award"
        awardTitle = "title_tongguanjiangli.png"
        self._ctrlPositionY = -100
    elseif self._result == "arean_win"  then
        awardTitleAnimation = "moving_fightend1_win_award"
        awardTitle = "title_zhandoujiangli.png"
        self._ctrlPositionY = -100

    elseif self._result == "vip_result" then
        awardTitleAnimation = "moving_fightend1_win_award"
        awardTitle = "title_zhandoujiangli.png"
        self._ctrlPositionY = -100
    elseif self._result == "lost" or self._result == "lose" then --阿东的坑
        self._ctrlPositionY = 40
        self:_playNext()
        return
    elseif self._result == "daily_pvp_win" then
        awardTitleAnimation = "moving_fightend1_win_award"
        awardTitle = "title_zhandoujiangli.png"
        self._ctrlPositionY = -100
    elseif self._result == "daily_pvp_lose" then
        awardTitleAnimation = "moving_fightend1_win_award"
        awardTitle = "title_zhandoujiangli.png"
        self._ctrlPositionY = -100
    else
        awardTitleAnimation = "moving_fightend1_lose_award" 
        awardTitle = "title_zhandoujiangli.png"
        self._ctrlPositionY = 40

    end

    
    self._node = EffectMovingNode.new(awardTitleAnimation, function(key)
           if key == "award" then
                local bg =  CCSprite:create(G_Path.getFightEndDir() .. "jiesuan_title.png")    
                local title =  CCSprite:create(G_Path.getTextPath(awardTitle) )  
                local size = bg:getContentSize()  
                title:setPosition(ccp(size.width/2, size.height/2))
                bg:addChild(title)
                return bg
            end
        end,
        function (event) 
            if  event == "award" then
                self._node:pause()
                self:_playNext()
            end
        end
    )
    

    

    self._node:play()
    self:addChild(self._node)
    --self:_playNext()
end

function ShowValueList:_playNext(   )
    local key = table.remove(self._keys, 1)

    if key == nil then
        if self._endCallback ~= nil then
            self._endCallback()
            self._endCallback  = nil
        end

    else
        local valueNode 
   
        if key == "exp" then
            valueNode = ShowExpLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))            
        elseif key == "rob_result" then
            valueNode = ShowRobResultLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))      
       elseif key == "award" then
           valueNode = ShowAwardLayer.create()
           valueNode:setEndCallback(handler(self, self._finishPlayNext))    
        elseif key == "tower_score" then
            valueNode = ShowValueLayer.create(self._data.compare_value_1)
            valueNode:setEndCallback(handler(self, self._finishPlayNext))
        elseif key == "tower_money" then
            valueNode = ShowValueLayer.create(self._data.compare_value_2)
            valueNode:setEndCallback(handler(self, self._finishPlayNext))
        elseif key == "rebelboss_result" then
            local ShowRebelBossResultLayer = require("app.scenes.common.fightend.controls.ShowRebelBossResultLayer")
            valueNode = ShowRebelBossResultLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))     
        elseif key == "last_attack_award" then
            valueNode = ShowValueLayer.create(self._data.last_attack_award_extra)
            valueNode:setEndCallback(handler(self, self._finishPlayNext))     
        elseif key == "daily_pvp_score" then
            valueNode = ShowDailyPVPValueLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))  
        elseif key == "daily_pvp_honor" then
            valueNode = ShowDailyPVPValueLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))  
        elseif key == "left_time" then -- daily pvp 剩余次数
            valueNode = ShowLeftTimeLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))      
        else
            valueNode = ShowValueLayer.create()
            valueNode:setEndCallback(handler(self, self._finishPlayNext))            
        end

        
        
        valueNode:setData(key, self._data[key])

        local size = valueNode:getContentSize()
        if self._result == "lose" or self._result == "lost" then
            if self._keyLen == 2 then
                valueNode:setPosition( ccp(-valueNode:getContentSize().width/2, self._ctrlPositionY - size.height+80))
                self._ctrlPositionY  = self._ctrlPositionY  -  size.height-15
            else
                valueNode:setPosition( ccp(-valueNode:getContentSize().width/2, self._ctrlPositionY - size.height+100))
                self._ctrlPositionY  = self._ctrlPositionY  -  size.height-5
            end
        else
            valueNode:setPosition( ccp(-valueNode:getContentSize().width/2, self._ctrlPositionY - size.height))
            self._ctrlPositionY  = self._ctrlPositionY  -  size.height - 10
        end

        


        self:addChild(valueNode)
        valueNode:play()

    end

    

end

function ShowValueList:_finishPlayNext(   )
    self._waitTimer = GlobalFunc.addTimer(0.1, function() 
        GlobalFunc.removeTimer(self._waitTimer)
        self._waitTimer = nil
        self:_playNext()
    end)
end

function ShowValueList:onExit()
    self:setNodeEventEnabled(false)
    if self._waitTimer then
        GlobalFunc.removeTimer(self._waitTimer)
        self._waitTimer = nil
    end

    if  self._node ~= nil then
        self._node:stop()
    end
    
end

return ShowValueList