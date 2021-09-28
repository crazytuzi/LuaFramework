require("app.cfg.treasure_fragment_info")
require("app.cfg.treasure_compose_info")

local AwardConst = require("app.const.AwardConst")
local TreasureRobLayer = class("TreasureRobLayer", UFCCSNormalLayer)

local TreasureRobItem = require("app.scenes.treasure.cell.TreasureRobItem")

function TreasureRobLayer.create(...)
    return require("app.scenes.treasure.TreasureRobLayer").new("ui_layout/treasure_TreasureRobLayer.json", ...)
end

function TreasureRobLayer:ctor(json,fragmentId,userList,...)

    self._refershCD = 0
    self._startRefresh = false

    self._isFirstTime = true
    self._fragmentId = fragmentId
    local fragment = treasure_fragment_info.get(self._fragmentId)
    if fragment then
        self._composeId = fragment.compose_id
    end
    self._mianzhanTagLabel = nil
    self._timeLabel = nil
    self._listview = nil
    self._userList = userList
    
    self._ShowMatchSuccess = false
    self.super.ctor(self, ...)
    self:_initWidgets()
    self:_createStroke()
    self:_initEvents()
    self:_onRefreshMianZhanTime()  
    --刷新免战时间
    self._timerHandler = G_GlobalFunc.addTimer(1, function()
        self:_onRefreshMianZhanTime() 
        if self._refershCD > 0 then
            self._refershCD = self._refershCD -1 
            self:showWidgetByName("Label_cd",true)
            self:showWidgetByName("ImageView_743",false)
            self:getLabelByName("Label_cd"):setText(string.format("00:00:0%d",self._refershCD))
        else
            self:showWidgetByName("Label_cd",false)
            self:showWidgetByName("ImageView_743",true)
        end
    end)
end

function TreasureRobLayer:_initWidgets()
    self._timeLabel = self:getLabelByName("Label_mianzhan")
    self:getLabelByName("Label_tipTag"):setText(G_lang:get("LANG_DUO_BAO_XIAOHAO_JINGLI"))
    self:_refreshJingLiLabel()
end

--刷新免战时间
function TreasureRobLayer:_onRefreshMianZhanTime()
    if G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time) > 0 then
        self._timeLabel:setVisible(true)
        local timeString = G_ServerTime:getLeftSecondsString(G_Me.userData.forbid_battle_time)
        self._timeLabel:setText(G_lang:get("LANG_MIANZHAN_LEFT_TIME",{time=timeString}))
    else
        self._timeLabel:setVisible(false)
    end
end


function TreasureRobLayer:_refreshJingLiLabel()
    require("app.const.FigureType")
    local info = basic_figure_info.get(TYPE_SPIRIT) -- 精力
    local currentJingliLabel = self:getLabelByName("Label_currentJingli")
    local jingliString = string.format("%s/%s",G_Me.userData.spirit,info.time_limit)
    self:getLabelByName("Label_currentJingliTag"):setText(G_lang:get("LANG_CURRENT_JINGLI"))
    currentJingliLabel:setText(jingliString)
end

function TreasureRobLayer:_createStroke()
    self._timeLabel:createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_tab"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_currentJingliTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_currentJingli"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_tipTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_tip"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_mianzhan"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_cd"):createStroke(Colors.strokeBrown,1)
end 

function TreasureRobLayer:_initEvents()
    self:registerBtnClickEvent("Button_back",function()
        self:onBackKeyEvent()
    end)
    
    self:registerBtnClickEvent("Button_huanyipi",function()
        if self._refershCD == 0 then
            self._ShowMatchSuccess = true
            self._refershCD = 6
            G_HandlersManager.treasureRobHandler:sendTreasureFragmentRobList(self._fragmentId)
        end
    end)
end

function TreasureRobLayer:onLayerEnter()
    self:adapterWidgetHeight("Panel_list", "Panel_head", "Panel_Bottom", 10, 110)
    self:adapterWidgetHeight("Panel_RobListContainer", "Panel_Head", "Panel_Bottom", 0, 0)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_ROB_LIST, self._onRobList, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_ROB_RESULT, self._onRobResult, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._refreshJingLiLabel, self)
    if self._isFirstTime == true then
        if not self._userList then
            G_HandlersManager.treasureRobHandler:sendTreasureFragmentRobList(self._fragmentId)
        else
            self:_setListView()
        end
    end
end

function TreasureRobLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function TreasureRobLayer:onBackKeyEvent()
    -- uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(fragmentId.treasure_id))
    -- if CCDirector:sharedDirector():getSceneCount() > 1 then 
    --     uf_sceneManager:popScene()
    -- else
        
    -- end
    uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._composeId))
    return true
end



function TreasureRobLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

--获取抢夺列表
function TreasureRobLayer:_onRobList(data)
    if self._ShowMatchSuccess == true then
        G_MovingTip:showMovingTip(G_lang:get("LANG_GET_ROB_LIST_SUCCESS"))
    end
    self._userList = data.rob_users
    self:_setListView()
end

function TreasureRobLayer:_setListView()
    if self._listview == nil then
        local panel = self:getPanelByName("Panel_list")
        self._listview = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._listview:setCreateCellHandler(function(list,index)
            local item = TreasureRobItem.new()        
            return item
        end)
        self:registerListViewEvent("Panel_list", function ( ... )
            -- this function is used for new user guide, you shouldn't care it
        end)
        self._listview:setSpaceBorder(0,150)
        self._listview:setUpdateCellHandler(function(list,index,cell)  
            cell:update(self._userList[index+1],index)
            cell:setQiangduoBtnEvent(function()
                --判断精力是否满足
                if G_Me.userData.spirit < 2 then
                    G_GlobalFunc.showPurchasePowerDialog(2)
                    return
                end
                --发送抢夺请求时，只需要传一个排名即可
                local robFunc = function()
                    G_HandlersManager.treasureRobHandler:sendRobTreasureFragment(index)
                end
                local user = self._userList[index+1]
                --又改成机器人不删免战了2014-09-29
                 if G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time) > 0 and user.is_robot ~= true then
                --又改成 不管是否机器人都扣除掉免战时间
                -- if G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time) > 0 then
                    --处于免战状态
                    MessageBoxEx.showYesNoMessage(nil,G_lang:get("LANG_STATUS_IN_MIANZHAN"),false,function()
                        robFunc()
                    end,nil,self)
                    return
                end
                
                if G_Me.userData.spirit < 2 then
                    --精力不足
                    G_GlobalFunc.showPurchasePowerDialog(2)
                    return
                end
                
                robFunc()
                
            end)

            cell:setSaoDangEvent(function()
                -- require("app.scenes.treasure.TreasureSaoDangLayer").show()
                -- uf_sceneManager:replaceScene("app.scenes.treasure.TreasureSaoDangScene").new(index,self._userList)
                local FunctionLevelConst = require("app.const.FunctionLevelConst")
                if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_ROB_5_TIMES) then
                    return
                end

                if G_Me.userData.spirit < 2 then
                    --精力不足
                    G_GlobalFunc.showPurchasePowerDialog(2)
                    return
                end

                uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureSaoDangScene").new(index,self._fragmentId,self._userList))
                end)
        end)
        -- self._listview:setSpaceBorder(0,140);
    end 
    if self._isFirstTime == true then
        self._listview:reloadWithLength(#self._userList,0,0.2)
        self._isFirstTime = false
    else
        self._listview:reloadWithLength(#self._userList,0)
    end 
end

--抢夺结果
function TreasureRobLayer:_onRobResult(data)
    if data.ret == 1 then
        local callback = nil
        callback = function(result) 
            local FightEnd = require("app.scenes.common.fightend.FightEnd")
            local _exp = 0
            local _money = 0
            for i,v in ipairs(data.rewards) do 
                if v.type == G_Goods.TYPE_MONEY then
                    _money = v.size
                elseif v.type == G_Goods.TYPE_EXP then
                    _exp = v.size
                end
            end
            
            local picks = nil
            if rawget(data, "turnover_rewards")  then
                picks= data.turnover_rewards.rewards
            end
            local _rob_result = (data.rob_result and self._fragmentId or 0)
            FightEnd.show(FightEnd.TYPE_ROB,data.battle_report.is_win,
            {exp=_exp,
                money=_money,
                rob_result = _rob_result,
                awards=data.turnover_rewards,
                picks = picks
            },
            function() 
                if data.battle_report.is_win == true and data.rob_result == true then
                    -- uf_sceneManager:popToSceneStackLevel(1)
                    -- uf_sceneManager:popToRootScene()
                    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._composeId))
                    local treasureFragment = treasure_fragment_info.get(data.base_id)
                    local rewards = {{
                        type = G_Goods.TYPE_TREASURE_FRAGMENT,
                        value = data.base_id,
                        size = 1}
                    }
                    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(rewards,function() 
                        --抛个事件出来
                        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_TREASURE_FRAGMENT_SUCCESS, nil, false,data.base_id)
                    end ,G_lang:get("LANG_ROB_FRAGMENT_SUCCESS"),treasureFragment.name,treasureFragment.quality)
                    uf_notifyLayer:getModelNode():addChild(_layer)
                else
                    local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(self._fragmentId)
                    if fragment ~= nil then
                        --虽然没抢到，但是奖励到了
                        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_TREASURE_FRAGMENT_SUCCESS, nil, false,data.base_id)
                        -- uf_sceneManager:popToRootScene()
                        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._composeId))
                    else
                        -- uf_sceneManager:popScene()
                        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureRobScene").new(self._fragmentId,self._userList))
                    end
                end
            end,result
            )
        end
        --uf_sceneManager:pushScene(require("app.scenes.treasure.TreasureRobBattleScene"):new(data.battle_report,callback))

            G_Loading:showLoading(function ( ... )
            --创建战斗场景
                if self then
                    self.scene = require("app.scenes.treasure.TreasureRobBattleScene"):new(data.battle_report,callback)
                    uf_sceneManager:pushScene(self.scene)
                end
            end, 
            function ( ... )
                if self and self.scene then
                    self.scene:play()
                end
                --开始播放战斗
            end)
            
    end 
end


function TreasureRobLayer:_onBattleEvent(event)
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_FINISH then
        uf_sceneManager:popScene()
    end 
end

function TreasureRobLayer:onLayerUnload( ... )
    if self._timerHandler then
        GlobalFunc.removeTimer(self._timerHandler)
    end
end

function TreasureRobLayer:adapterLayer(...)
    
end


return TreasureRobLayer

