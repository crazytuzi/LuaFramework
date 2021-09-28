--HeroFosterLayer.lua

local KnightConst = require("app.const.KnightConst")
local funLevelConst = require("app.const.FunctionLevelConst")

local HeroFosterLayer = class("HeroFosterLayer", UFCCSNormalLayer)

-- 与 bagselllayer 中对应
HeroFosterLayer.SELL_FRAGMENT = 1

function HeroFosterLayer:ctor( jsonFile, func, style, detailKnight, scenePack, ... )
    self._scenePack = scenePack
    G_GlobalFunc.savePack(self, scenePack)

    self._listview = nil
    self._curKnightId = type(detailKnight) == "number" and detailKnight or 0

    __Log("self._curKnightId=%d", self._curKnightId)
    --碎片listview
    self._fragmentListView = nil
    --保存点击的fragment Cell用来刷新
    self._fragmentClickCell = nil
    
    self._style = style or 1
    self._knightList = {}
    
    self._shouldReload = false
    self._wearonKnight = {}
    
    self.super.ctor(self, jsonFile, func, style, ...)
    self:_initEvent()
    self:_createStroke()
    --self:getLabelByName("Label_count"):createStroke(Colors.strokeBrown,1)

end

function HeroFosterLayer:onLayerLoad( ...  )
    self:registerKeypadEvent(true)

    self:addCheckBoxGroupItem(1, "CheckBox_knights")
    self:addCheckBoxGroupItem(1, "CheckBox_suipian")
    
    self:addCheckNodeWithStatus("CheckBox_knights", "Label_knight_check", true)
    self:addCheckNodeWithStatus("CheckBox_knights", "Label_knight_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_suipian", "Label_fragment_check", true)
    self:addCheckNodeWithStatus("CheckBox_suipian", "Label_fragment_uncheck", false)


    self:enableLabelStroke("Label_knight_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_fragment_check", Colors.strokeBrown, 2 )    

    if self._style == 1 then 
        self:setCheckStatus(1, "CheckBox_knights")
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_yinliang_sell.png", UI_TEX_TYPE_LOCAL)
    else
        self:setCheckStatus(1, "CheckBox_suipian")
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_hunyu_sell.png", UI_TEX_TYPE_LOCAL)
    end
    
    self:registerCheckboxEvent("CheckBox_knights", function ( widget, type, isCheck )
        self._style = 1
        self:initHeroList()
        self:showWidgetByName("Panel_count",true)
        self:showWidgetByName("Button_sell",true)
        self:showWidgetByName("Panel_strength_list",true)
        self:showWidgetByName("Panel_fragment_list",false)
        self:showWidgetByName("Panel_noFragment",false)
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_yinliang_sell.png", UI_TEX_TYPE_LOCAL)
    end)
    self:registerCheckboxEvent("CheckBox_suipian", function ( widget, type, isCheck )
        self._style = 2
        self:_initFragmentList()

        --碎片数量为0
        if self._fragmentListData == nil or #self._fragmentListData == 0 then
            self:showWidgetByName("Panel_fragment_list",false)
            self:showWidgetByName("Panel_noFragment",true)
        else 
            self:showWidgetByName("Panel_fragment_list",true)
            self:showWidgetByName("Panel_noFragment",false)
        end 
        self:showWidgetByName("Button_sell",true)
        self:showWidgetByName("Panel_count",false)
        self:showWidgetByName("Panel_strength_list",false)
        self:getImageViewByName("Image_Sell_Result"):loadTexture("ui/bag/icon_hunyu_sell.png", UI_TEX_TYPE_LOCAL)
    end)
    --检查是否有碎片可以合成
    self:_checkFragmentComposeable()

    -- 1.7.0 VIP增加包裹容量按钮
    self:registerBtnClickEvent("Button_Add_Vip_Level", function (  )
        self:_onAddVipLevelBtnClicked()
    end)
end

function HeroFosterLayer:__prepareDataForAcquireGuide__( funId, param )
    if type(param) ~= "number" then 
        return
    end

    -- 弱引导时，要根据跳转类型决定要默认选择养成的武将位置和养成类型
    local _findDestKnight = function ( typeId )
        local heroCount = G_Me.formationData:getFormationHeroCount() or 1
        local destKnight = 0
        local ctrlName = nil
        for loopi = 2, heroCount do 
            if destKnight < 1 then 
                local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, loopi)
                local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)       
                --local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
                if knightInfo then
                    if (funId == 35 and param%100 == KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN and 
                         knightInfo["level"] == 1) then 
                    -- 上面,1代表找到可强化的武将,这里要找到当前为1级的武将,没办法,把param+100处理了
                        destKnight = knightId 
                        ctrlName = "Button_strength"
                    elseif (funId == 9 and param == KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN and 
                        G_Me.bagData.knightsData:canKnightStrengthen(knightId))  then 
                        destKnight = knightId 
                        ctrlName = "Button_strength"
                    
                    elseif param == KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE then
                        local notJingJieMaxLevel, canJingJie = G_Me.bagData.knightsData:canJingJieWithKnightId(knightId, true)
                        if notJingJieMaxLevel and canJingJie then 
                            destKnight = knightId
                            ctrlName = "Button_jingjie"
                        end
                    elseif param == KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING and 
                            G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_TRAINING) then 
                        local xilianUnlock, canXiLian = G_Me.bagData.knightsData:isKnightCanTraining(knightId)
                        if xilianUnlock and canXiLian then 
                            destKnight = knightId
                            ctrlName = "Button_xilian"
                        end
                    elseif param == KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN and
                            G_moduleUnlock:isModuleUnlock(funLevelConst.KNIGHT_GUANGHUAN)then 
                        local guanzhiUnlock, canGuanZhi = G_Me.bagData.knightsData:isKnightGuanghuanOpen(knightId)
                        if guanzhiUnlock and canGuanZhi then 
                            destKnight = knightId
                            ctrlName = "Button_guanzhi"
                        end
                    end
                end
            end
        end
        
        return destKnight, ctrlName
    end

    local knightId, ctrlName = _findDestKnight(param)
    __Log("funId:%d, param:%d, knightId:%d, ctrlName:%s", funId, param, knightId or -1, ctrlName or "nil")
    if type(knightId) ~= "number" or type(ctrlName) ~= "string" then 
        return 
    end

    -- 计算出要养成的武将和类型后，调整当前列表显示的起始位置，重新加载
    if self._listview ~= nil and knightId > 0 then
        local startIndex = self._listview:getShowStart()
        local curDetailIndex = 0
        for key, value in pairs(self._knightList) do 
            if value == knightId then 
                startIndex = key - 2
                curDetailIndex = key
            end
        end

        self._listview:reloadWithLength(#self._knightList, startIndex)

        if curDetailIndex >= 1 then
            self._listview:showDetailWithIndex(curDetailIndex - 1)
        end

        -- 计算弹出detailitem后，对应的养成按钮的坐标区域并返回
        local detailCell = self._listview:getDetailCell()
        if detailCell then
            local widget = detailCell:getWidgetByName(ctrlName)
            if widget then 
                local x, y = widget:convertToWorldSpaceXY(0, 0)
                local widgetSize = widget:getSize()
                local detailSize = detailCell:getSize()
                return CCRectMake(x - widgetSize.width/2, 
                    y - detailSize.height - widgetSize.height/2,
                     widgetSize.width, widgetSize.height)
            end
        end
    end

    return nil
end

function HeroFosterLayer:onBackKeyEvent( ... )
    local scenePack = G_GlobalFunc.createPackScene(self)
    if scenePack then
        uf_sceneManager:replaceScene(scenePack)
    else
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end
    return true
end

function HeroFosterLayer:_initEvent()
    self:registerBtnClickEvent("Button_return", function ( widget )
        self:onBackKeyEvent()
    end)
    self:registerWidgetTouchEvent("Label_zhandou", function ( widget,_type )
        if  _type == TOUCH_EVENT_ENDED then
            uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
        end
    end)
    self:registerWidgetTouchEvent("Label_juqing", function ( widget,_type )
        if  _type == TOUCH_EVENT_ENDED then
            local FunctionLevelConst = require("app.const.FunctionLevelConst")
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.STORY_DUNGEON) == true then
                uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonMainScene").new())
                return
            end
        end
    end)
    self:registerBtnClickEvent("Button_sell",function()
        if self._style == 1 then
            uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(G_Goods.TYPE_KNIGHT))
        elseif self._style == 2 then
            local BagConst = require("app.const.BagConst")
            local listData = G_Me.bagData:getFragmentListForSell(BagConst.FRAGMENT_TYPE_KNIGHT)
            if listData and #listData > 0 then
                uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(G_Goods.TYPE_FRAGMENT, HeroFosterLayer.SELL_FRAGMENT))
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_BAG_SELL_FRAGMENT_NUM_ZERO"))
            end
        end
    end)
end

function HeroFosterLayer:_createStroke()
    self:getLabelByName("Label_count"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_count_value"):createStroke(Colors.strokeBrown,1)
end


function HeroFosterLayer:_updateKnightCount( ... )
    local curCount = G_Me.bagData.knightsData:getKnightCount()
    require("app.cfg.role_info")
    local roleInfo = role_info.get(G_Me.userData.level)
    -- 1.7.0版本开始，根据VIP等级增加相应容量
    local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").KNIGHTBAGVIPEXTRA).value
    if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
    local maxCount = roleInfo and (roleInfo.knight_bag_num_client + vipExtrNum) or curCount
    if curCount >= maxCount then
        self:getLabelByName("Label_count_value"):setColor(Colors.uiColors.RED)
    else
        self:getLabelByName("Label_count_value"):setColor(Colors.darkColors.DESCRIPTION)
    end
    self:showTextWithLabel("Label_count_value", string.format("%d/%d", curCount, maxCount))
end

function HeroFosterLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end


function HeroFosterLayer:_initDetailKnight( ... )
    if self._style ~= 1 then 
        return 
    end

    if self._listview ~= nil and self._curKnightId > 0 then
            local startIndex = self._listview:getShowStart()
            local curDetailIndex = 0
            for key, value in pairs(self._knightList) do 
                if value == self._curKnightId then 
                    startIndex = key - 2
                    curDetailIndex = key
                end
            end
            self._listview:reloadWithLength(#self._knightList, startIndex)

            if curDetailIndex >= 1 then
                self._listview:showDetailWithIndex(curDetailIndex - 1)
            else
                self._listview:hideDetailCell(false)
                self._curKnightId = 0
            end
        end
end

function HeroFosterLayer:_reloadListViewIfShould()
    -- 当返回到武将列表界面时，根据标记位决定是否要从我写位置开始显示武将列表
    if self._shouldReload then
        self._shouldReload = false

        self:_generaterKnightList()
        if self._listview ~= nil then
            local startIndex = self._listview:getShowStart()
            local curDetailIndex = 0
            for key, value in pairs(self._knightList) do 
                if value == self._curKnightId then 
                    startIndex = key - 2
                    curDetailIndex = key
                end
            end
            self._listview:reloadWithLength(#self._knightList, startIndex)

            if curDetailIndex >= 1 then
                self._listview:showDetailWithIndex(curDetailIndex - 1)
            else
                self._listview:hideDetailCell(false)
                self._curKnightId = 0
            end
        end
    else
        
    end   
end

function HeroFosterLayer:onLayerEnter( ... )

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_ADVANCED_KNIGHT, self._onReceiveAdvancedRet, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_UPGRADE_KNIGHT, self._onReceiveStrengthRet, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AWAKEN_KNIGHT_NOTI, self._onAwakenKnightRet, self)
    --武将合成消息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BAG_FRAGMENT_COMPOUND, self._revFragmentCompound, self)
    --武将和装备碎片变化的消息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED,self._onBagChange,self)

    self:_updateKnightCount()
    self:_reloadListViewIfShould()
end

function HeroFosterLayer:_onReceiveAdvancedRet( ret, newKnightId )
    if ret == NetMsg_ERROR.RET_OK then
        self._shouldReload = true
    end
    
    --__Log("_onReceiveAdvancedRet: ret=%d, _shouldReload=%d", ret, self._shouldReload and 1 or 0)
end

function HeroFosterLayer:_onReceiveStrengthRet( ret )
    if ret == NetMsg_ERROR.RET_OK  then
        self._shouldReload = true
    end
    --__Log("_onReceiveStrengthRet: ret=%d, _shouldReload=%d", ret, self._shouldReload and 1 or 0)
end

function HeroFosterLayer:_onAwakenKnightRet( ret )
    if ret == NetMsg_ERROR.RET_OK  then
        self._shouldReload = true
    end
end


--@desc 收到包裹变化消息,检查下是否有显示
function HeroFosterLayer:_onBagChange(_type,_)
    local BagConst = require("app.const.BagConst")
    if _type == BagConst.CHANGE_TYPE.FRAGMENT then
        self:_checkFragmentComposeable()
    elseif _type == BagConst.CHANGE_TYPE.KNIGHT then
        --碎片合成 成功获取到 新武将，需要刷新武将列表
        self:_updateKnightCount()
        self:_generaterKnightList()
        if self._listview then
            self._shouldReload = true
            -- 这里会导致列表reload异常，先注释掉，待我找找问题的原因
            -- self:_reloadListViewIfShould()
        end
    end
end

function HeroFosterLayer:sortFragmentList( list )
    if type(list) ~= "table" or #list < 1 then
        return {}
    end

    local groupIds = G_Me.formationData:getMainTeamCountryIds()
    local sortFunc = function(indexA,indexB)      
        local fragmenta = fragment_info.get(indexA.id)
        local fragmentb = fragment_info.get(indexB.id)
        
        local onTeama = G_Me.formationData:getKnightTeamIdByFragment(fragmenta.fragment_value)
        local onTeamb = G_Me.formationData:getKnightTeamIdByFragment(fragmentb.fragment_value)
        
        local kniA = knight_info.get(fragmenta.fragment_value)
        local kniB = knight_info.get(fragmentb.fragment_value)
        if not kniA then 
            __LogError("a wrong knigh info for baseid:%d", a.base_id)
            return false
        end
        if not kniB then 
            __LogError("b wrong knigh info for baseid:%d", b.base_id)
            return true
        end

        -- 碎片满的放最前面
        local aFull = (fragmenta.max_num <= indexA.num) and 1 or 0
        local bFull = (fragmentb.max_num <= indexB.num) and 1 or 0
        if aFull ~= bFull then 
            return aFull > bFull
        end

        -- 上阵武将的碎片排前面
        if onTeama ~= onTeamb and (onTeama == 1 or onTeamb == 1) then
            return onTeama == 1
        end

        --再比较品质
        if kniA.quality ~= kniB.quality then
            return kniA.quality > kniB.quality
        end

        --再比较阵营
        if kniA.group ~= kniB.group then
            local groupANum = groupIds[kniA.group] or 0
            local groupBNum = groupIds[kniB.group] or 0
            if groupANum ~= groupBNum then
                return groupANum > groupBNum
            end

            return kniA.group < kniB.group
        end

        if indexA.num ~= indexB.num then 
            return indexA.num > indexB.num 
        end

        return indexA.id > indexB.id
    end
    
    table.sort(list, sortFunc)

    return list
end

function HeroFosterLayer:_revFragmentCompound(data)
    __LogTag("wkj","-------------------这里是武将合成的消息")
    if data.ret == NetMsg_ERROR.RET_OK  then
        self._fragmentListData = G_Me.bagData:getKnightFragmentList()
        self._fragmentListData = self:sortFragmentList(self._fragmentListData)
        --检查碎片是否没有了
        if self._style == 2 then
            --碎片数量为0
            if self._fragmentListData == nil or #self._fragmentListData == 0 then
                self:showWidgetByName("Panel_fragment_list",false)
                self:showWidgetByName("Panel_noFragment",true)
            end 
        end

        local fragment = fragment_info.get(data.id)
        require("app.cfg.knight_info")
        local knight = knight_info.get(fragment.fragment_value)
        G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_FRAGMENT_COMPOSE_SUCCESS",{name=knight.name}))

        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knight.id) 
        local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
        OneKnightDrop.show(3, knight.id, nil, data.num)
        --判断fragment数量
        local __fragment = G_Me.bagData.fragmentList:getItemByKey(data.id)
        --重新取一遍
        
        
        if __fragment == nil or __fragment["num"] == 0 then
            --移除
            if self._fragmentClickCell ~= nil then
                -- self._listView:removeChild(self._clickCell)
                self._fragmentListView:reloadWithLength(#self._fragmentListData,self._fragmentListView:getShowStart())
                self._fragmentClickCell = nil
            end
        else 
            --update
            if self._fragmentClickCell ~= nil then
                if __fragment["num"] > fragment.max_num then
                    self._fragmentClickCell:updateData(__fragment)
                else
                    self._fragmentListView:reloadWithLength(#self._fragmentListData,self._fragmentListView:getShowStart())
                end
            end
        end
    end
end

--检查是否有碎片可合成
function HeroFosterLayer:_checkFragmentComposeable()
    self:showWidgetByName("Image_composeTips", G_Me.bagData:CheckKnightFragmentCompose())
end

function HeroFosterLayer:_createList( ... )
    local panel = self:getPanelByName("Panel_strength_list")
    if panel == nil then
        return 
    end
    
    local isKnightWearon = function ( knightId )
        for key, value in pairs(self._wearonKnight) do 
            if value == knightId then 
                return true
            end
        end
        
        return false
    end
    
    -- 保存已经上阵的武将列表，以便于做上阵武将计算
    local firstTeam = G_Me.formationData:getFirstTeamKnightIds()
    local secondTeam = G_Me.formationData:getSecondTeamKnightIds()
    
    self._wearonKnight = {}
    if firstTeam then
        table.foreach(firstTeam, function ( i , value )
            if value > 0 then
                table.insert(self._wearonKnight, #self._wearonKnight + 1, value)
            end
        end)
    end
    if secondTeam then
        table.foreach(secondTeam, function ( i , value )
            if value > 0 then
                table.insert(self._wearonKnight, #self._wearonKnight + 1, value)
            end
        end)
    end
    
    self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.herofoster.HeroFosterItem").new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
    	local knightId = self:_getKnightInList(index)
        cell:updateHeroItem( knightId, index == self._listview:getDetailCellIndex() )
    end)
    local postfix = require("app.scenes.herofoster.HeroDetailLayer").create(self._scenePack)
    self._listview:setDetailCell(postfix)
    self._listview:setDetailEnabled(true)
    self._listview:setDetailCellHandler(function ( list, detail, cell, index, show )

        self._curKnightId = show and self:_getKnightInList(index) or 0
    	if show then
            detail:updateDetailWithKnightId(self:_getKnightInList(index))
    	end
    	if cell then
            cell:onDetailShow(show)
    	end
    end)
    self._listview:setSelectCellHandler(function ( list, knightId, param, cell )
    	self._listview:showDetailWithIndex(cell:getCellIndex())
    end)
    self:registerListViewEvent("Panel_strength_list", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
    end)

    self._listview:setSpaceBorder(0, 40)

    self:addCheckNodeWithStatus("CheckBox_knights", "Panel_strength_list", true)
end

function HeroFosterLayer:adapterLayer( ... )
    self:adapterWidgetHeight("Panel_strength_list", "Panel_181", "", 14, -40)
    self:adapterWidgetHeight("Panel_fragment_list", "Panel_181", "", 14, -40)
    --空列表提示
    self:adapterWidgetHeight("Panel_noFragment", "Panel_181", "", 0, 0)
    
    if self._style == 1 then 
        self:initHeroList()
        self:_initDetailKnight()
    else
        self:_initFragmentList()
    end

    require("app.scenes.common.EmptyLayer").createWithPanel(
        require("app.const.EmptyLayerConst").KNIGHTSP,self:getPanelByName("Panel_noFragment"))
end

function HeroFosterLayer:initHeroList( )
    if not self._listview then
        self:_createList()

        self:_generaterKnightList()
        if self._listview ~= nil then
            self._listview:reloadWithLength(#self._knightList, 0, 0.2)
        end

    end    
end
function HeroFosterLayer:_initFragmentList()
    if self._fragmentListView ~= nil then
        return 
    end

    self._fragmentListData = G_Me.bagData:getKnightFragmentList() 
    self._fragmentListData = self:sortFragmentList(self._fragmentListData)
    if self._fragmentListView == nil then
        local panel = self:getPanelByName("Panel_fragment_list")
        self._fragmentListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._fragmentListView:setCreateCellHandler(function(list,index) 
            return require("app.scenes.herofoster.KnightFragmentListCell").new()
        end)
        self._fragmentListView:setUpdateCellHandler(function ( list, index, cell)
            local fragment = self._fragmentListData[index+1]
            if index < #self._fragmentListData then
                cell:updateData(fragment)
            end
            
            cell:setComposeFunc(function()
                self._fragmentClickCell = cell
                --先判断包裹
                local CheckFunc = require("app.scenes.common.CheckFunc")
                if CheckFunc.checkKnightFull() then
                    return
                end
                -- 用于一键多次合成
                if (fragment.num / fragment_info.get(fragment.id).max_num) < 2 then
                    G_HandlersManager.bagHandler:sendFragmentCompoundMsg(fragment.id)
                else
                    local maxNum = G_Me.bagData:getMaxKnightNumByLevel(G_Me.userData.level)
                    local currNum = G_Me.bagData.knightsData:getKnightCount()
                    require("app.scenes.equipment.MultiComposeLayer").show(fragment, maxNum, currNum)
                end
            end)
            cell:setTogetButtonClickEvent(function()
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, fragment.id,
                 GlobalFunc.sceneToPack("app.scenes.herofoster.HeroFosterScene", {2, fragment.id}))
            end)
            cell:setCheckFragmentInfoFunc(function()
                GlobalFunc.showBaseInfo(G_Goods.TYPE_FRAGMENT, fragment.id)
                --require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, fragment.id) 
                end)
    	end)
    end

    local curSelectFragment = 0
    if self._fragmentListView ~= nil and self._curKnightId > 0 then
            for key, value in pairs(self._fragmentListData) do 
                if curSelectFragment == 0 and value.id == self._curKnightId then 
                    curSelectFragment = key
                end
            end
            self._curKnightId = 0
    end

    self._fragmentListView:setVisible(true)
    self._fragmentListView:reloadWithLength(#self._fragmentListData, curSelectFragment - 2, 0.2)
    self._fragmentListView:setSpaceBorder(0, 40)

    if curSelectFragment > 0 then
        local cell = self._fragmentListView:getCellByIndex(curSelectFragment - 1)
        if cell then
            cell:blurFragment(true)
        end
        self:callAfterDelayTime(3.0, nil, function ( ... )
            if cell and cell.blurFragment then 
                cell.blurFragment(cell, false)
            end
        end)
    end

    self:addCheckNodeWithStatus("CheckBox_suipian", "Panel_fragment_list", true)
end

function HeroFosterLayer:_generaterKnightList(  )
    local exceptArr = {}
    exceptArr[G_Me.formationData:getMainKnightId()] = 1
    -- 这里取到的id列表已经是排序过的
    self._knightList = G_Me.bagData.knightsData:getKnightsIdListCopy()

end

function HeroFosterLayer:_getKnightInList( index )
    return self._knightList[index + 1]
end

function HeroFosterLayer:_onAddVipLevelBtnClicked(  )
    G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").KNIGHTBAGVIPEXTRA)       
end

return HeroFosterLayer

