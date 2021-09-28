local DungeonFastBounsLayer = class("DungeonFastBounsLayer", UFCCSModelLayer)
local Colors = require("app.setting.Colors")
local BagConst = require("app.const.BagConst")
local FlyAttributeInstance = require("app.scenes.common.FlyAttributeInstance")
local FlyText = require("app.scenes.common.FlyText")

function DungeonFastBounsLayer.create(stageId, ...)
    return DungeonFastBounsLayer.new("ui_layout/dungeon_DungeonFastBounsLayer.json",Colors.modelColor, stageId, ...)
end

function DungeonFastBounsLayer:ctor(json, color, stageId, ...)
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
    local _stageData = dungeon_stage_info.get(G_Me.dungeonData:getCurrStageId())
    local _dungeonInfo = G_GlobalFunc.getDungeonData(_stageData.value)
    local _data = G_Me.dungeonData:getStageById(G_Me.dungeonData:getCurrStageId())
    self.fastTimes = _data._executeCount> 10 and 10 or _data._executeCount
    local nums = math.modf(G_Me.userData.vit/_dungeonInfo.cost)
    if nums < self.fastTimes then
        self.fastTimes = nums
    end

    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_FASTEXECUTESTAGE, self._recvFastExecuteStage, self)
    self:_setStartSend(true)
    self._timer = G_GlobalFunc.addTimer(0.2,handler(self,self._sendFastExecuteStage))
    --self:registerBtnClickEvent("Button_Stop", function ( widget )
    --    self:onBackKeyEvent()
    --end)
    
    self:_initWithSweep()

end

function DungeonFastBounsLayer:onBackKeyEvent( ... )
     if self.num >= self.fastTimes then
        self:_hitLevelup()
        self:_closeWindow()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
    end
    return true
end

function DungeonFastBounsLayer:_setStroke(labelName)
    local _name = self:getLabelByName(labelName)
    if _name then 
        _name:createStroke(Colors.strokeBrown,1)
    end
end

function DungeonFastBounsLayer:_setStartSend(bValue)
    self._startSend  = bValue
end
-- 收到秒杀结果
function DungeonFastBounsLayer:_recvFastExecuteStage(data)
    if data.ret == G_NetMsgError.RET_OK then

        self:_fragmentNumAdded(data)
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
function DungeonFastBounsLayer:_stopClean()
    self:getButtonByName("Button_Stop"):setVisible(true)
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end 
    self:getLabelByName("Label_SaoDang"):setVisible(false)

    -- 扫荡结束，隐藏碎片数量显示
  --    self:showWidgetByName("Image_OneKind", false)
--    self:showWidgetByName("Image_TwoKind", false)
end

function DungeonFastBounsLayer:_sendFastExecuteStage(dt)

    local CheckFunc = require("app.scenes.common.CheckFunc")
    local nChapterId = G_Me.dungeonData:getCurrChapterId()
    -- 如果传nil则设备上会有问题
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.dungeon.DungeonMainScene", {_, _, self._stageId, nChapterId})
    if CheckFunc.checkKnightFull(scenePack) == true then
         self:_stopClean()
         return
    end
    
    if CheckFunc.checkEquipmentFull(scenePack) == true then
         self:_stopClean()
         return
    end

    if self._startSend == true then
        if self.num< self.fastTimes then
            G_HandlersManager.dungeonHandler:sendFastExecuteStage(G_Me.dungeonData:getCurrStageId())
        else
            self:_stopClean()
        end
         self:_setStartSend(false)
    end

end

-- 开始扫荡 每秒一次
function DungeonFastBounsLayer:startClean(data)
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

function DungeonFastBounsLayer:_init(data,widget)
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

function DungeonFastBounsLayer:onTouchBegin(x,y)
    self.beginY = y
end

function DungeonFastBounsLayer:onTouchMove(x,y)
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

function DungeonFastBounsLayer:onTouchEnd(x,y)
end

function DungeonFastBounsLayer:setLabelText(widget,name,text)
    local label = widget:getChildByName(name)
    if label then
        label = tolua.cast(label,"Label")
        label:setText(text)
    end
end

function DungeonFastBounsLayer:_closeWindow()
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_SECKILL, nil, true,nil)
--    G_flyAttribute._clearFlyAttributes()
    self:close()
end

function DungeonFastBounsLayer:onLayerEnter()
     require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_762"), "smoving_bounce")

     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._onReceiveLevelUpdate, self)
end
function DungeonFastBounsLayer:onLayerExit()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
    uf_eventManager:removeListenerWithTarget(self)
--    G_flyAttribute:_clearFlyAttributes()
end
-- 物品掉落
function DungeonFastBounsLayer:_initGoods(bounsData,widget)
    
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
function DungeonFastBounsLayer:onClick(widget,_type)
    if  _type == TOUCH_EVENT_ENDED then
        require("app.scenes.common.dropinfo.DropInfo"
         ).show(widget.goodtype,widget.goodvalue)
    end

    --widget:setTouchEnabled(false)
end

function DungeonFastBounsLayer:_onReceiveLevelUpdate( oldLevel, newLevel )
    if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
        return 
    end

    self._upgradeList = self._upgradeList or {}
    table.insert(self._upgradeList, 1, {level1 = oldLevel, level2 = newLevel})
end

function DungeonFastBounsLayer:_hitLevelup( ... )
    if not self._upgradeList or #self._upgradeList < 1 then 
        return 
    end

    local upgradePair = self._upgradeList[1]
    if type(upgradePair) == "table" then 
        require("app.scenes.common.CommonLevelupLayer").show(upgradePair.level1, upgradePair.level2)
    end
    self._upgradeList = {}
end

function DungeonFastBounsLayer:_initWithSweep()
    self._hasFragment = false
    self._nKind = 1
    local tGoodsList = {}

    local tAwardList = G_Me.dungeonData:getFragmentList()
    if table.nums(tAwardList) == 0 then
        self._hasFragment = false
    elseif table.nums(tAwardList) == 1 then
        self._hasFragment = true
        self._nKind = 1
    elseif table.nums(tAwardList) == 2 then
        self._hasFragment = true
        self._nKind = 2
    end

    if self._hasFragment then
        for key, val in pairs(tAwardList) do
        local tAward = val
        local tGoods = G_Goods.convert(tAward.type, tAward.value, tAward.size)
            if tGoods then
                if tAward.type == 6 then
                    local tFragmentTmpl = fragment_info.get(tGoods.value)
                    if tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
                        table.insert(tGoodsList, 1, tGoods)
                    elseif tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
                        table.insert(tGoodsList, tGoods)
                    end
                end
            end
        end

        if self._nKind == 1 then
            self:_oneKindFragment(tGoodsList)
        elseif self._nKind == 2 then
            self:_twoKindFragment(tGoodsList)
        end
    else
        self:showWidgetByName("Image_OneKind", false)
        self:showWidgetByName("Image_TwoKind", false)
    end
end

function DungeonFastBounsLayer:_fragmentNumAdded(data)
    if not self._hasFragment then
        return
    end

    local isAdd = false
    local addFragmentList = {}
    for key, val in pairs(data.awards) do
        local tAward = val
        local tGoods = G_Goods.convert(tAward.type, tAward.value, tAward.size)
        if tGoods then
            if tAward.type == 6 then
                isAdd = true
                local tFragmentTmpl = fragment_info.get(tGoods.value)
                if tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
                    table.insert(addFragmentList, 1, tGoods)
                elseif tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
                    table.insert(addFragmentList, tGoods)
                end
            end
        end
    end

    if isAdd then
        local fragemtkind = table.nums(addFragmentList)
        if fragemtkind == 1 then
            local tFragment = addFragmentList[1]
            local labelFragment = nil
            if self._nKind == 1 then
                labelFragment = self:getLabelByName("Label_FragmentCount")
            else
                local tFragmentTmpl = fragment_info.get(addFragmentList[1].value)
                if tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
                    labelFragment = self:getLabelByName("Label_FragmentCount1")
                elseif tFragmentTmpl.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
                    labelFragment = self:getLabelByName("Label_FragmentCount2")
                end
            end
        
            local nFragment = G_Me.bagData:getFragmentNumById(tFragment.value) or 0
            local function updateFragmentNum1(fragment, nNeedNum)
                if labelFragment then
                    labelFragment:setText(fragment .. "/" .. nNeedNum)
                    local actSeq = self:_creatScaleAction()
                    labelFragment:stopAllActions()
                    labelFragment:runAction(actSeq)
                end
            end

            local tFragmentTmpl = fragment_info.get(addFragmentList[1].value)
            local nNeedNum = (tFragmentTmpl and tFragmentTmpl.max_num) and tFragmentTmpl.max_num or 0
            updateFragmentNum1(nFragment, nNeedNum)
        elseif fragemtkind == 2 then
            local tFragmentKnight = addFragmentList[1]
            local tFragmentEquip = addFragmentList[2]
            local labelFragmentKnight = self:getLabelByName("Label_FragmentCount1")
            local labelFragmentEquip = self:getLabelByName("Label_FragmentCount2")

            local nFragmentKnightNum = G_Me.bagData:getFragmentNumById(tFragmentKnight.value) or 0
            local nFragmentEquipNum = G_Me.bagData:getFragmentNumById(tFragmentEquip.value) or 0
            local function updateFragmentNum2(knightFragment, equipFragment, nNeedNum1, nNeedNum2)
                if labelFragmentKnight then
                    labelFragmentKnight:setText(knightFragment .. "/" .. nNeedNum1)
                    local actSeq = self:_creatScaleAction()
                    labelFragmentKnight:stopAllActions()
                    labelFragmentKnight:runAction(actSeq)
                end

                if labelFragmentEquip then
                    labelFragmentEquip:setText(equipFragment .. "/" .. nNeedNum2)
                    local actSeq = self:_creatScaleAction()
                    labelFragmentEquip:stopAllActions()
                    labelFragmentEquip:runAction(actSeq)
                end
            end

            local tFragmentTmpl1 = fragment_info.get(addFragmentList[1].value)
            local nNeedNum1 = (tFragmentTmpl1 and tFragmentTmpl1.max_num) and tFragmentTmpl1.max_num or 0
            local tFragmentTmpl2 = fragment_info.get(addFragmentList[2].value)
            local nNeedNum2 = (tFragmentTmpl2 and tFragmentTmpl2.max_num) and tFragmentTmpl2.max_num or 0

            updateFragmentNum2(nFragmentKnightNum, nFragmentEquipNum, nNeedNum1, nNeedNum2)
        end
    end
end

-- 只可能掉落一种碎片
function DungeonFastBounsLayer:_oneKindFragment(tGoodsList)
    self:showWidgetByName("Image_OneKind", true)
    self:showWidgetByName("Image_TwoKind", false)

    local tGoods = tGoodsList[1]
    if tGoods then
        local nTotalSize = G_Me.bagData:getFragmentNumById(tGoods.value) or 0
        local tFragmentTmpl = fragment_info.get(tGoods.value)
        local nNeedNum = (tFragmentTmpl and tFragmentTmpl.max_num) and tFragmentTmpl.max_num or 0
        self:getLabelByName("Label_Fragment"):setText(tGoods.name .. ":")
        self:getLabelByName("Label_FragmentCount"):setText(nTotalSize .. "/" .. nNeedNum)
        local imgBg = self:getImageViewByName("Image_OneKind")
        if imgBg then
            local widthOffset = 40
            local heightOffset = 10
            local nWidth = self:getLabelByName("Label_Fragment"):getSize().width + self:getLabelByName("Label_FragmentCount"):getSize().width
            local nHeight = self:getLabelByName("Label_Fragment"):getSize().height
            imgBg:setSize(CCSizeMake(nWidth + widthOffset, nHeight + heightOffset))
            imgBg:setScale9Enabled(true)
            imgBg:setCapInsets(CCRectMake(16, 16, 1, 1))

            -- 中间对齐
            local nPanelWidth = self:getPanelByName("Panel_4"):getSize().width
            imgBg:setPositionX(nPanelWidth/2)
            -- label中间对齐
            local nWidthDt = nPanelWidth - nWidth
            self:getLabelByName("Label_Fragment"):setPositionX(nWidthDt/2)
            self:getLabelByName("Label_FragmentCount"):setPositionX(nWidthDt/2+self:getLabelByName("Label_Fragment"):getSize().width)
        end
    end
end

-- 有可能同时掉落2种碎片
function DungeonFastBounsLayer:_twoKindFragment(tGoodsList)
    self:showWidgetByName("Image_OneKind", false)
    self:showWidgetByName("Image_TwoKind", true)

    local tGoods1 = tGoodsList[1]
    local tGoods2 = tGoodsList[2]
    if tGoods1 and tGoods2 then
        local nTotalSize1 = G_Me.bagData:getFragmentNumById(tGoods1.value) or 0
        local nTotalSize2 = G_Me.bagData:getFragmentNumById(tGoods2.value) or 0

        local tFragmentTmpl1 = fragment_info.get(tGoods1.value)
        local nNeedNum1 = (tFragmentTmpl1 and tFragmentTmpl1.max_num) and tFragmentTmpl1.max_num or 0
        local tFragmentTmpl2 = fragment_info.get(tGoods2.value)
        local nNeedNum2 = (tFragmentTmpl2 and tFragmentTmpl2.max_num) and tFragmentTmpl2.max_num or 0

        self:getLabelByName("Label_Fragment1"):setText(tGoods1.name .. ":")
        self:getLabelByName("Label_Fragment2"):setText(tGoods2.name .. ":")
        self:getLabelByName("Label_FragmentCount1"):setText(nTotalSize1 .. "/" .. nNeedNum1)
        self:getLabelByName("Label_FragmentCount2"):setText(nTotalSize2 .. "/" .. nNeedNum2)
        local imgBg = self:getImageViewByName("Image_TwoKind")
        if imgBg then
            local widthOffset = 40
            local heightOffset = 23
            local nWidth1 = self:getLabelByName("Label_Fragment1"):getSize().width + self:getLabelByName("Label_FragmentCount1"):getSize().width
            local nHeight1 = self:getLabelByName("Label_Fragment1"):getSize().height
            local nWidth2 = self:getLabelByName("Label_Fragment2"):getSize().width + self:getLabelByName("Label_FragmentCount2"):getSize().width
            local nHeight2 = self:getLabelByName("Label_Fragment2"):getSize().height
            local nTotalWidth = math.max(nWidth1, nWidth2)
            imgBg:setSize(CCSizeMake(nTotalWidth + widthOffset, nHeight1 + nHeight2 + heightOffset))
            imgBg:setScale9Enabled(true)
            imgBg:setCapInsets(CCRectMake(12, 16, 1, 1))

            -- 中间对齐
            local nPanelWidth = self:getPanelByName("Panel_4"):getSize().width
            imgBg:setPositionX(nPanelWidth/2)
            -- 
            local nPanelWidth1 = self:getPanelByName("Panel_17"):getSize().width
            local nWidthDt1 = nPanelWidth1 - nWidth1
            self:getLabelByName("Label_Fragment1"):setPositionX(nWidthDt1/2)
            self:getLabelByName("Label_FragmentCount1"):setPositionX(nWidthDt1/2+self:getLabelByName("Label_Fragment1"):getSize().width)
            --
            local nPanelWidth2 = self:getPanelByName("Panel_18"):getSize().width
            local nWidthDt2 = nPanelWidth2 - nWidth2
            self:getLabelByName("Label_Fragment2"):setPositionX(nWidthDt2/2)
            self:getLabelByName("Label_FragmentCount2"):setPositionX(nWidthDt2/2+self:getLabelByName("Label_Fragment2"):getSize().width)
        end
    end
end

function DungeonFastBounsLayer:_creatScaleAction()
    local actSacleTo1 = CCScaleTo:create(0.25, 2)
    local actSacleTo2 = CCScaleTo:create(0.15, 1)
    local arr = CCArray:create()
    arr:addObject(actSacleTo1)
    arr:addObject(actSacleTo2)
    local actSeq = CCSequence:create(arr)
    return actSeq
end



return DungeonFastBounsLayer

 