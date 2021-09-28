local HardDungeonFastBounsLayer = class("HardDungeonFastBounsLayer", UFCCSModelLayer)
local Colors = require("app.setting.Colors")

function HardDungeonFastBounsLayer.create(stageId, ...)
    return HardDungeonFastBounsLayer.new("ui_layout/dungeon_Hard_DungeonFastBounsLayer.json", Colors.modelColor, stageId, ...)
end

function HardDungeonFastBounsLayer:ctor(json, color, stageId,...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()
    
    self._upgradeList = {}
    self:registerBtnClickEvent("Button_Stop", function ( ... )
        self:_hitLevelup()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
        self:_closeWindow()
    end)
    
    self:registerBtnClickEvent("Button_Close", function ( ... )
        self:_hitLevelup()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
        self:_closeWindow()
    end)
    
    self._stageId = stageId
    self.item1 = nil
    self.item2 = nil
    self.num = 0
    self._height = 0
    self.beginY = 0
    self._Panel = self:getPanelByName("Panel_Base")
    self._Panel:setAnchorPoint(ccp(0,1))
    self.PanelLenth = self:getPanelByName("PanelBouns"):getContentSize().height
    self:registerTouchEvent(false,true,0)
    self:registerKeypadEvent(true)
    
    self:getLabelByName("Label_SaoDang"):setText(G_lang:get("LANG_DUNGEON_SAODANG"))
    -- 今日扫荡次数
     -- 1.先根据当前体力，算出可扫荡次数
    --2.当剩余挑战次数>可扫荡次数时，显示可扫荡次数
    --3.当剩余挑战次数<可扫荡次数时，显示剩余挑战次数
    local _stageData = hard_dungeon_stage_info.get(G_Me.hardDungeonData:getCurrStageId())
    local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
    local _data = G_Me.hardDungeonData:getStageById(G_Me.hardDungeonData:getCurrStageId())
    self.fastTimes = _data._executeCount> 10 and 10 or _data._executeCount
    local nums = math.modf(G_Me.userData.vit/_dungeonInfo.cost)
    if nums < self.fastTimes then
        self.fastTimes = nums
    end

    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_FASTEXECUTESTAGE, self._recvFastExecuteStage, self)
    self:_setStartSend(true)
    self._timer = G_GlobalFunc.addTimer(0.2,handler(self,self._sendFastExecuteStage))
    --self:registerBtnClickEvent("Button_Stop", function ( widget )
    --    self:onBackKeyEvent()
    --end)
    
end

function HardDungeonFastBounsLayer:onBackKeyEvent( ... )
     if self.num >= self.fastTimes then
        self:_hitLevelup()
        self:_closeWindow()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
    end
    return true
end

function HardDungeonFastBounsLayer:_setStroke(labelName)
    local _name = self:getLabelByName(labelName)
    if _name then 
        _name:createStroke(Colors.strokeBrown,1)
    end
end

function HardDungeonFastBounsLayer:_setStartSend(bValue)
    self._startSend  = bValue
end
-- 收到秒杀结果
function HardDungeonFastBounsLayer:_recvFastExecuteStage(data)
    if data.ret == G_NetMsgError.RET_OK then
        self:startClean(data)
        self:_setStartSend(true)       
        -- 魔神来了
        if data.rebel > 0 then
            self:_setStartSend(false)
            G_GlobalFunc.showRebelDialog(data.rebel,data.rebel_level,function(bValue)
                -- 点击了取消
                    if bValue == false then
                         self:_setStartSend(true)       
                    end
                end)
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_MOSHEN"))
        end
    else -- 停止扫荡
        self:_stopClean()
    end
end

-- 停止扫荡
function HardDungeonFastBounsLayer:_stopClean()
    self:getButtonByName("Button_Stop"):setVisible(true)
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end 
    self:getLabelByName("Label_SaoDang"):setVisible(false)

end

function HardDungeonFastBounsLayer:_sendFastExecuteStage(dt)

    local CheckFunc = require("app.scenes.common.CheckFunc")
    --[[
    if CheckFunc.checkKnightFull() == true then
         self:_stopClean()
         return
    end
    ]]
    local nChapterId = G_Me.hardDungeonData:getCurrChapterId()
    -- 如果传nil则设备上会有问题
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.harddungeon.HardDungeonMainScene", {_, _, self._stageId, nChapterId})
    if CheckFunc.checkEquipmentFull(scenePack) == true then
         self:_stopClean()
         return
    end

    if self._startSend == true then
        if self.num< self.fastTimes then
            G_HandlersManager.hardDungeonHandler:sendFastExecuteStage(G_Me.hardDungeonData:getCurrStageId())
        else
            self:_stopClean()
        end
         self:_setStartSend(false)
    end

end

-- 开始扫荡 每秒一次
function HardDungeonFastBounsLayer:startClean(data)
    self.num  = self.num + 1
    local jsonWidget = nil
    if #data.awards <= 5 then -- 小于5个奖励
        if self.item1 == nil then
            jsonWidget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonBounsItem1.json")
            --jsonWidget = self.item1
        else
            jsonWidget = self.item1:clone()
        end
    else
        if self.item2 == nil then
            jsonWidget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonBounsItem2.json")
            --jsonWidget = self.item2
        else
            jsonWidget = self.item2:clone()
        end
    end
    self._height = self._height + jsonWidget:getContentSize().height
    jsonWidget:setPositionY(-self._height)
    local _size = self._Panel:getContentSize()
    _size.height = self._height
    self._Panel:addChild(jsonWidget)
    if _size.height >self.PanelLenth then
        self._Panel:setPositionY(_size.height)
    else
        self._Panel:setPositionY(self.PanelLenth)
    end
    self:_init(data,jsonWidget)
end

function HardDungeonFastBounsLayer:_init(data,widget)
    widget = widget:getChildByName("Image_2")
    self:_initGoods(data.awards,widget)
    self:setLabelText(widget, "Label_ExpValue", data.stage_exp)
    self:setLabelText(widget, "Label_MoneyValue", data.stage_money)
    self:setLabelText(widget, "Label_Exp", G_lang:get("LANG_EXP") .. "：" )
    self:setLabelText(widget, "Label_Money", G_lang:get("LANG_SILVER") .. "：" )
    self:setLabelText(widget, "Label_Title", G_lang:get("LANG_DUNGEON_GATENUM",{num = self.num}))

    --新手光环经验
    self:setLabelText(widget, "Label_rookieBuffValue", G_Me.userData:getExpAdd(data.stage_exp))

    local label = widget:getChildByName("Label_Title")
    if label then
        label = tolua.cast(label,"Label")
         label:createStroke(Colors.strokeBrown,2)
    end
--    self:getLabelByName("Label_Silver"):setText(data.stage_money)
--    self:getLabelByName("Label_Bouns"):setText(data.stage_bouns)
--    self:getLabelByName("Label_TotalBouns"):setText(G_lang:get("LANG_DUNGEON_TOTALGET"))
    
--    self:_setStroke("Label_Silver")
--    self:_setStroke("Label_Bouns")
--    self:_setStroke("Label_TotalBouns")
end

function HardDungeonFastBounsLayer:onTouchBegin(x,y)
    self.beginY = y
end

function HardDungeonFastBounsLayer:onTouchMove(x,y)
    local lenth = y - self.beginY 
    local posY = self._Panel:getPositionY()
    local _size = self._Panel:getContentSize()
    self.beginY = y
    if _size.height > self.PanelLenth then
        posY = posY + lenth
        if posY > self.PanelLenth and  posY < _size.height then
            self._Panel:setPositionY(posY)
        end
    end

end

function HardDungeonFastBounsLayer:onTouchEnd(x,y)
end

function HardDungeonFastBounsLayer:setLabelText(widget,name,text)
    local label = widget:getChildByName(name)
    if label then
        label = tolua.cast(label,"Label")
        label:setText(text)
    end
end

function HardDungeonFastBounsLayer:_closeWindow()
    --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_SECKILL, nil, false,nil)
    self:close()
end

function HardDungeonFastBounsLayer:onLayerEnter()
     require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_762"), "smoving_bounce")
     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._onReceiveLevelUpdate, self)
end
function HardDungeonFastBounsLayer:onLayerExit()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
    uf_eventManager:removeListenerWithTarget(self)
end
-- 物品掉落
function HardDungeonFastBounsLayer:_initGoods(bounsData,widget)
    
    function setGoods(_index,data,_parentWidget,_type,_value,num)
        local _bounsPic = _parentWidget:getChildByName("bouns" .. _index)
        
        local _name = _bounsPic:getChildByName("bounsname")
        _name = tolua.cast(_name,"Label")
        _name:setColor(Colors.getColor(data.quality))
        _name:setText(data.name)
        _name:createStroke(Colors.strokeBrown,1)

        _bounsPic = tolua.cast(_bounsPic,"ImageView")
        _bounsPic:loadTexture(data.icon)
        -- 物品图标
        local _ico = _bounsPic:getChildByName("ico")
        _ico = tolua.cast(_ico,"ImageView")
        _ico:loadTexture(G_Path.getEquipColorImage(data.quality,data.type))
         _bounsPic:setTag(_index)
         _bounsPic:setName("bouns" .. self.num .."_" ..  tostring(_index))
         
         -- 物品数量
         local numLabel = _bounsPic:getChildByName("bounsnum")
        numLabel = tolua.cast(numLabel,"Label")
        numLabel:setText("x" .. num)
        numLabel:createStroke(Colors.strokeBrown,1)
         
         -- 物品类型和物品类型值
         _bounsPic.goodtype = _type
         _bounsPic.goodvalue = _value
         
        self:registerWidgetTouchEvent("bouns" .. self.num .."_" ..  tostring(_index),handler(self,self.onClick))
    end
    
    --local bounsBg = widget:getChildByName("Image_2")
    for i = 1,8 do
        local bouns = widget:getChildByName("ImageView_bouns" .. i)
        local data = nil
        if i <= #bounsData then
             data = G_Goods.convert(bounsData[i].type,bounsData[i].value)
             bouns = tolua.cast(bouns,"ImageView")
             bouns:loadTexture(G_Path.getEquipIconBack(data.quality))
            setGoods(i,data,bouns,bounsData[i].type,bounsData[i].value,bounsData[i].size)
        end
        if data == nil and bouns then
            bouns:setVisible(false)
        end
    end
    
    local labelNothing = widget:getChildByName("Label_Nothing")
    if labelNothing then
        -- 没有得到奖励
        if #bounsData == 0 then
            labelNothing = tolua.cast(labelNothing,"Label")
            labelNothing:setText(G_lang:get("LANG_DUNGEON_NOTHING"))
        else
            labelNothing:setVisible(false)
        end
    end

end


-- @desc 点击物品获取详细信息
function HardDungeonFastBounsLayer:onClick(widget,_type)
    if  _type == TOUCH_EVENT_ENDED then
        require("app.scenes.common.dropinfo.DropInfo"
         ).show(widget.goodtype,widget.goodvalue)
    end

    --widget:setTouchEnabled(false)
end

function HardDungeonFastBounsLayer:_onReceiveLevelUpdate( oldLevel, newLevel )
    if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
        return 
    end

    self._upgradeList = self._upgradeList or {}
    table.insert(self._upgradeList, 1, {level1 = oldLevel, level2 = newLevel})
end

function HardDungeonFastBounsLayer:_hitLevelup( ... )
    if not self._upgradeList or #self._upgradeList < 1 then 
        return 
    end

    local upgradePair = self._upgradeList[1]
    if type(upgradePair) == "table" then 
        require("app.scenes.common.CommonLevelupLayer").show(upgradePair.level1, upgradePair.level2)
    end
    self._upgradeList = {}
end
return HardDungeonFastBounsLayer

