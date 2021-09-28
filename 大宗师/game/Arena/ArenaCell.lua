


local MAX_ZORDER = 10003 

local ArenaCell = class("ArenaCell", function ()


    return CCTableViewCell:new()		
	 
end)

function ArenaCell:getContentSize() 
    if self.cntSize == nil then 
        local proxy = CCBProxy:create()
        local rootNode = {}

        local node = CCBuilderReaderLoad("arena/arena_item.ccbi", proxy, rootNode)
        self.cntSize = rootNode["itemBg"]:getContentSize()
        self:addChild(node)
        node:removeSelf()
    end 

    return self.cntSize 
end


function ArenaCell:timeSchedule(param)
    self.restTime = param.time
    local timeLabel = param.label
    local callBack = param.callBack --时间执行完毕后的回调
    
    timeLabel:setString(format_time(self.restTime))
    local function update( dt )
        if timeLabel == nil  or timeLabel:getParent()==nil  or self.restTime <= 0 then
            self.scheduler.unscheduleGlobal(self.timeData) 
            if self.restTime <= 0 then
                callBack()
            end
        else
            self.restTime = self.restTime - 1
            timeLabel:setString(format_time(self.restTime))
        end
    end
    self.scheduler = require("framework.scheduler")
    if self.timeData ~= nil then
        self.scheduler.unscheduleGlobal(self.timeData) 
    end
    self.timeData = self.scheduler.scheduleGlobal( update, 1, false )
end

function ArenaCell:onExit()
    self:unregNotice()
    -- self.scheduler.unscheduleGlobal(self.timeData) 
end


function ArenaCell:regNotice()
    RegNotice(self,
        function(timeStr, ss)

           local curTime = ss:getValue()
           self._rootnode["rest_time"]:setString(format_time(curTime))
      
        end,
        NoticeKey.ArenaRestTime)

    RegNotice(self,
        function()
             if self.timeType == 1 then --正好反过来了
                self._rootnode["time_rest_name"]:setString("领奖倒计时")            
            else
                self._rootnode["time_rest_name"]:setString("奖励发放中:")
            end
        end,
        NoticeKey.SwitchArenaTimeType)

    
end

function ArenaCell:unregNotice()

    UnRegNotice(self, NoticeKey.ArenaRestTime)
    UnRegNotice(self, NoticeKey.SwitchArenaTimeType)

end


function ArenaCell:refresh(id,restTime,timeType) 
    local cellData = self.data[id]
    self.timeType = timeType
    -- print("cellDATA")
    -- dump(cellData)
    self.restTime = restTime

    self.acc = cellData["acc"]
    self.cards = cellData["card"]
    self.getPopual = cellData["getPopual"]
    self.getSilver = cellData["getSilver"]
    self.level = cellData["level"]
    self.name = cellData["name"]
    self.rank = cellData["rank"]
    self.isVip = cellData["vip"]
    self.faction = cellData["faction"]--帮会
    if self.faction == "" then
        self._rootnode["gang_name"]:setVisible(false)
    else
        self._rootnode["gang_name"]:setVisible(true)
        self._rootnode["gang_name"]:setString("【"..self.faction.."】")
    end

    if self.timeType == 1 then
        self._rootnode["time_rest_name"]:setString("奖励发放中:") 
    else
        self._rootnode["time_rest_name"]:setString("领奖倒计时:") 
    end 

    -- dump(cellData) 
    -- print("game.pLayer.m_uid"..game.player.m_uid) 

    local playerBgName = "#arena_name_bg_4.png"
    local bgname = "#arena_itemBg_4.png"

    if game.player:checkIsSelfByAcc(self.acc) then 
        playerBgName = "#arena_name_bg_5.png" 
        bgname = "#arena_itemBg_5.png"

        self._rootnode["challenge_btn"]:setVisible(false)
        self._rootnode["time_rest_node"]:setVisible(true) 
        self:regNotice()

        self.btnFunc = function() print("主角") end
    else
        self._rootnode["challenge_btn"]:setVisible(true)
        self._rootnode["time_rest_node"]:setVisible(false)  
        self.btnFunc = function() print("replace scene"..self.acc)
            if game.player.m_energy < 2 then --体力不足 
                self.notEnoughFunc()
            else
                --发送check请求 看看是不是排名不变
                ResMgr.oppName = self.name
                self:sendCheckRankList()                
            end
        end 
    end

    self._rootnode["bg_node"]:removeAllChildren() 
    local bg = display.newScale9Sprite(bgname, 0, 0, self._rootnode["bg_node"]:getContentSize()) 
    bg:setAnchorPoint(0, 0)
    self._rootnode["bg_node"]:addChild(bg) 

    self._rootnode["name_bg"]:removeAllChildren() 
    local playerBg = display.newScale9Sprite(playerBgName, 0, 0, self._rootnode["name_bg"]:getContentSize()) 
    playerBg:setAnchorPoint(0, 0)
    self._rootnode["name_bg"]:addChild(playerBg) 
    
    self._rootnode["lv_num"]:setString("LV." .. tostring(self.level)) 
    self._rootnode["player_name"]:setString(self.name) 
    -- arrangeTTF({
    --     self._rootnode["player_name"],
    --     self._rootnode["gang_name"]
    --     })
    self._rootnode["reward_money"]:setString(tostring(self.getSilver)) 
    self._rootnode["shengwang_num"]:setString("x" .. tostring(self.getPopual)) 
    self._rootnode["rank_num"]:setString("排名: " .. tostring(self.rank))

    for i =1,4 do
        if i > #self.cards then
            self._rootnode["icon_"..i]:setVisible(false)
        else
            self._rootnode["icon_"..i]:setVisible(true)
            local cls = self.cards[i]["cls"]
            local resId = self.cards[i]["resId"]

            ResMgr.refreshIcon({id = resId,itemBg = self._rootnode["icon_"..i],resType = ResMgr.HERO,cls = cls})
        end
    end 
   
end



function ArenaCell:sendCheckRankList()
    --发送请求，请求检查排名是否已经发生改变，返回后如果成功
    RequestHelper.sendCheckRankList({
        acc2 = self.acc,rank = self.rank,
        callback = function(data)
            print("check data")
            dump(data)
            local change = data["1"]
            if change == 1 then
                game.player.m_energy = game.player.m_energy - 2
                --发送战斗请求
                self:sendBattleReq()     

            elseif change == 2 then 
                --名次发生了改变，弹出提示框 要求玩家选择是否战斗
                local changeMsgBox = require("game.Arena.ArenaChangeMsgBox").new({
                    battleFunc = function() self:sendBattleReq() end,
                    resetFunc = function() self.resetFunc() end
                    })
                display.getRunningScene():addChild(changeMsgBox, MAX_ZORDER)

            elseif change == 3 then 
                local isBagFull = true 
                local bagObj = data["2"] 

                -- 判断背包空间是否足，如否则提示扩展空间 
                local function extendBag(data)
                    -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size 
                    if bagObj[1].curCnt < data["1"] then 
                        table.remove(bagObj, 1)
                    else
                        bagObj[1].cost = data["4"]
                        bagObj[1].size = data["5"]
                    end

                    if #bagObj > 0 then 
                        game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
                            bagObj = bagObj, 
                            callback = function(data)
                                extendBag(data)
                            end}), MAX_ZORDER)
                    else
                        isBagFull = false 
                    end
                end

                if isBagFull then 
                    game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
                        bagObj = bagObj, 
                        callback = function(data)
                            extendBag(data)
                        end}), MAX_ZORDER)
                end
            end
        end
        })
end

function ArenaCell:sendBattleReq()
    RequestHelper.ArenaBattle({
        rank = self.rank,
        callback = function(data)
            local isSelf = data["6"]
            self.battleData = data
            if isSelf == 1 then
                GameStateManager:ChangeState(GAME_STATE.STATE_ARENA_BATTLE,self.battleData)
            elseif isSelf == 2 then
                --要战斗的人是自己，弹出框框，直接重新刷新界面
                show_tip_label("您的名次已经发生变化，请重新选择挑战目标")
                self.resetFunc()
            elseif isSelf == 3 then
                show_tip_label("奖励发放中，大侠请稍后再战")
            end
        end
        })
end

function ArenaCell:create(param)

    local _id       = param.id
    local _viewSize = param.viewSize 
    self.data = param.listData
    self.restTime = param.restTime
    self.timeType = param.timeType
    self.notEnoughFunc = param.notEnoughFunc
    self.resetFunc = param.resetFunc
    -- dump(self.data)
    self:setNodeEventEnabled(true)
    -- local hechengFunc = param.hechengFunc

    -- local createDiaoLuoLayer = param.createDiaoLuoLayer

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("arena/arena_item.ccbi", proxy, self._rootnode) 
    node:setPosition(_viewSize.width/2, 0) 
    self:addChild(node) 

    self.btnFunc = function() print("nonono") end

    self._rootnode["challenge_btn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self.btnFunc()
    end, CCControlEventTouchUpInside)

    self:refresh(_id+1, self.restTime, self.timeType)

      

    return self

end

function ArenaCell:beTouched()
	
	
end



function ArenaCell:runEnterAnim(  )

end



return ArenaCell