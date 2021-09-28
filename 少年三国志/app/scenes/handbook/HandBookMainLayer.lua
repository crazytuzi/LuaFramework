require("app.cfg.knight_info")
require("app.cfg.handbook_info")

local HandBookMainLayer = class("HandBookMainLayer",UFCCSModelLayer)

local _guojia = {"LANG_WEIGUO","LANG_SHUGUO","LANG_WUGUO","LANG_QUNXIONG"}

function HandBookMainLayer.create(...)   
    local layer = HandBookMainLayer.new("ui_layout/handbook_HandBookMainLayer.json",require("app.setting.Colors").modelColor,...) 
    layer:updateView()
    return layer
end

function HandBookMainLayer:updateView()
    G_HandlersManager.handBookHandler:sendGetHandbookInfo(require("app.const.HandBookConst").HandType.KNIGHT)
end

function HandBookMainLayer:ctor( ... )
    self.super.ctor(self,...)
    self.handbookList ={}
    self.show_id = 1
    self.currHandBookId = 0 -- 当前图鉴id
    self._knightLayer = nil  -- 武将信息页面
    self._inited = {false,false,false,false}
    self:showAtCenter(true)
    
    self:addCheckBoxGroupItem(1, "CheckBox_Wei")
    self:addCheckBoxGroupItem(1, "CheckBox_Shu")
    self:addCheckBoxGroupItem(1, "CheckBox_Wu")
    self:addCheckBoxGroupItem(1, "CheckBox_Qun")
    self:setCheckStatus(1, "CheckBox_Wei")
    
    self:registerBtnClickEvent("Button_Back",handler(self,self.onBack))
    
    self:registerCheckBoxGroupEvent(function(groupId, oldName, newName, widget )
        if groupId == 1 then
            local _tag = widget:getTag()
            function setViewVisible(_viewName)
                local view = self:getScrollViewByName(_viewName)
                if _tag == view:getTag() then
                    view:setVisible(true)
                    self:_panelShow(view:getTag())
                else
                    view:setVisible(false)
                end
            end
            -- self:_setPro(self.handbookList[_tag].activeKnightNum, self.handbookList[_tag].totalKnightNum)
            setViewVisible("ScrollView_1")
            setViewVisible("ScrollView_2")
            setViewVisible("ScrollView_3")
            setViewVisible("ScrollView_4")
        end
    end)
    self:setVisible(false)
end

function HandBookMainLayer:onLayerEnter( ... )
    self:closeAtReturn(true)
    --require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HANDBOOK_GETHANDBOOKINFO, self._recvGetList, self)
end

function HandBookMainLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

function HandBookMainLayer:onBack(widget)
    self:animationToClose()
end

function HandBookMainLayer:onSceneUnload(...)
    uf_eventManager:removeListenerWithTarget(self)
end

function HandBookMainLayer:_setPro(activeKnightNum, totalKnightNum)
    self:getLoadingBarByName("LoadingBar_Pro"):setPercent(activeKnightNum/totalKnightNum*100)
    self:getLabelByName("Label_Pro"):setText(activeKnightNum .. "/" .. totalKnightNum)
    self:getLabelByName("Label_Pro"):createStroke(Colors.strokeBrown, 1)
end

function HandBookMainLayer:_recvGetList(data)
    -- print("_recvGetList "..FuncHelperUtil:getCurrentMillSecond())
    -- getCurrentTime()
    self.knightList = {}
    for k,v in pairs(data) do
       self.knightList[v] = true
    end
    self:readHandBookcfg()
    self:_panelShow(1)

    self:setVisible(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    -- G_WaitingLayer:setVisible(false)
end

function HandBookMainLayer:_panelShow( index )
    -- local time1 = FuncHelperUtil:getCurrentMillSecond()
    if not self._inited[index] then
        local _jsonPanel = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/handbook_HandBookItem.json")
        self:_initView("ScrollView_"..index,self.handbookList[index],_jsonPanel)
        self._inited[index] = true
    end
    self:_setPro(self.handbookList[index].activeKnightNum, self.handbookList[index].totalKnightNum)
    self:getLabelByName("Label_10"):setText(G_lang:get(_guojia[index]))
    -- local time2 = FuncHelperUtil:getCurrentMillSecond()
    -- print("time "..time2-time1)
end

-- 读取图鉴配置表
function HandBookMainLayer:readHandBookcfg()
    for k=1,handbook_info.getLength() do
        local v = handbook_info.indexOf(k)
        if self.handbookList[v.country] == nil then
            self.handbookList[v.country] = {}
            self.handbookList[v.country].activeKnightNum = 0
            self.handbookList[v.country].totalKnightNum = 0
        end
        local _knightinfo = knight_info.get(v.associate_id)
        if _knightinfo and v.is_seen == 1 then 
            if _knightinfo then
                if self.handbookList[v.country][_knightinfo.quality] == nil then
                    self.handbookList[v.country][_knightinfo.quality] = {}
                    self.handbookList[v.country][_knightinfo.quality].knightList = {}
                    -- 当前星级激活武将数
                    self.handbookList[v.country][_knightinfo.quality].starActiveKnightNum = 0
                    self.handbookList[v.country][_knightinfo.quality].starTotalKnightNum = 0
                end
            end
            -- 武将列表
            if self.knightList[k] then 
                self.handbookList[v.country][_knightinfo.quality].knightList[v.id] = {knight_id = _knightinfo.id,isActive= true}
                -- 当前星级激活武将数
                self.handbookList[v.country][_knightinfo.quality].starActiveKnightNum = 
                self.handbookList[v.country][_knightinfo.quality].starActiveKnightNum + 1
                
            -- 当前阵营激活武将数
                self.handbookList[v.country].activeKnightNum = self.handbookList[v.country].activeKnightNum + 1
            else
                self.handbookList[v.country][_knightinfo.quality].knightList[v.id] = {knight_id = _knightinfo.id,isActive= false}
            end
        
            self.handbookList[v.country][_knightinfo.quality].starTotalKnightNum = 
            self.handbookList[v.country][_knightinfo.quality].starTotalKnightNum + 1
            
            -- 当前阵容总武将数
            self.handbookList[v.country].totalKnightNum = self.handbookList[v.country].totalKnightNum + 1
        end
    end
end


-- 初始化视图列表
function HandBookMainLayer:_initView(viewName,_list,jsonPanel)
    local _scrollView = self:getScrollViewByName(viewName)
    if _scrollView then
        -- 整个滑动区域大小
        local _totalheightView = 0
        local _width = _scrollView:getContentSize().width
        local _width2 = jsonPanel:getChildByName("Panel_Item"):getContentSize().width
        local _scrollViewH = _scrollView:getContentSize().height
        
        -- 计算滑动区域高度
        local _size = jsonPanel:getContentSize()
        local _size2 = jsonPanel:getChildByName("Panel_top"):getContentSize()
        local _itemtemp = jsonPanel:getChildByName("Panel_Item")
        
        local _item_h = _itemtemp:getContentSize().height + 15
        local offset = 60

        for i=1,6 do
            if _list[i] then
                local num = 0
                if _list[i].starTotalKnightNum-1 > 0 then
                     num = math.floor((_list[i].starTotalKnightNum-1)/5)
                end
                --panel增长量
                local _total_h = _size.height + num*_item_h + offset
                _totalheightView = _totalheightView+_total_h
            end
        end
        _scrollView:setInnerContainerSize(CCSize(_width,_totalheightView))

        for i=6,1,-1 do -- 星级
            
            if _list[i] then
                local _panel = jsonPanel:clone()
                local num = 0 
                if _list[i].starTotalKnightNum-1 > 0 then
                    num = math.floor((_list[i].starTotalKnightNum-1)/5)
                end
                local _item = _panel:getChildByName("Panel_Item")
                --panel增长量
                local _total_h = _size.height + num*_item_h + offset
                -- 设置panel大小
                _panel:setSize(CCSize(_size.width,_total_h)) 
                -- 设置侠客列表大小
                _item:setSize(CCSize(_width2,(num+1)*_item_h+offset))  

                local bg = _item:getChildByName("Image_14")
                bg:setContentSize(CCSizeMake(_item:getContentSize().width, _item:getContentSize().height))
                bg:setPosition(ccp(_item:getContentSize().width, _item:getContentSize().height))

                _scrollView:addChild(_panel)
                -- 设置滑动区域大小
                -- 设置panel坐标
                _panel:setPositionY(_totalheightView-_total_h)
                _totalheightView = _totalheightView -_total_h
                 -- 单个item间距
                local _width = (_width2 - 30)/5 

                local top = _panel:getChildByName("Panel_top")
                if top then
                    local Image_12 = top:getChildByName("Image_12")
                    if Image_12 then
                        local wujiang = Image_12:getChildByName("Label_title")
                        if wujiang then
                            wujiang = tolua.cast(wujiang,"Label")
                            -- wujiang:loadTexture(self:_switchImage(i))
                            -- wujiang:loadTexture(Colors.dropKnightQuality[i])
                            wujiang:setColor(Colors.getColor(i))
                            wujiang:setText(G_lang:get(Colors.getColorText(i)))
                            wujiang:createStroke(Colors.strokeBrown, 1)
                        end
                    end

                    -- 当前星级进度
                    local _proLabel = top:getChildByName("Label_num") 
                    if _proLabel then
                        _proLabel = tolua.cast(_proLabel,"Label")
                        _proLabel:setText(G_lang:get("LANG_BAG_ITEM_NUM").._list[i].starActiveKnightNum .. "/" .. _list[i].starTotalKnightNum )
                    end
                end
                
                if i > 3 then 
                    local index = 0
                    for k,v in pairs(_list[i].knightList) do
                        self:addKnight(k,v.knight_id,v.isActive,_item,index,_width,(num)*_item_h,_item_h)
                        index = index + 1
                    end
                else
                    self:callAfterFrameCount(5, function ( ... )
                        local index = 0
                        for k,v in pairs(_list[i].knightList) do
                            self:addKnight(k,v.knight_id,v.isActive,_item,index,_width,(num)*_item_h,_item_h)
                            index = index + 1
                        end
                    end)
                end
            end
        end
    end
    
end

-- @param _width 单个侠客图标宽度 
-- @param _height 侠客图标所在panel高度 
-- @param _item_h 单个侠客图标高度
-- @param knight_id 武将id
-- @param isActive 是否激活武将
-- @param _panel 列表面板

function HandBookMainLayer:addKnight(id,knight_id,isActive,_panel,index,_width,_height,_item_h)
    local _data = knight_info.get(knight_id)
    if _data then
        local _ico = G_Path.getKnightIcon(_data.res_id)

        local btn = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/handbook_knight.json")
        _panel:addChild(btn)

        local Image_center = btn:getChildByName("Image_center")
        if Image_center then
            Image_center = tolua.cast(Image_center,"ImageView")
            Image_center:loadTexture(_ico)
            Image_center:showAsGray(not isActive)
        end

        local Image_board = btn:getChildByName("Image_board")
        if Image_board then
            Image_board = tolua.cast(Image_board,"ImageView")
            Image_board:loadTexture(G_Path.getEquipColorImage(_data.quality,G_Goods.TYPE_KNIGHT))
            Image_board:showAsGray(not isActive)
            Image_board:setName("Image_board"..knight_id)
            self:regisgerWidgetTouchEvent("Image_board"..knight_id, function ( widget, param )
                if param == TOUCH_EVENT_ENDED then -- 点击事件
                    self:onClickKnight(knight_id)
                end
            end)
        end

        local _proLabel = btn:getChildByName("Label_name") 
        if _proLabel then
            _proLabel = tolua.cast(_proLabel,"Label")
            _proLabel:setText(_data.name )
            _proLabel:createStroke(Colors.strokeBrown, 1)
            if isActive then 
                _proLabel:setColor(Colors.getColor(_data.quality))
            else 
                _proLabel:setColor(Colors.uiColors.GRAY)
            end
        end
        
        local _y = math.floor(index/5)
        local _x = math.floor(index%5)
        local pos_y = _height
        btn:setAnchorPoint(ccp(0,0))
        btn:setPosition(ccp(_x*_width+20, pos_y-(_y)*_item_h))
        btn:setTag(id)
    end
    
end



function HandBookMainLayer:onClickKnight(knight_id)
    if knight_id > 0 then 
        GlobalFunc.showBaseInfo(G_Goods.TYPE_KNIGHT, knight_id)
    end
    --local _knightinfo = knight_info.get(knight_id)
    --require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, _knightinfo.id) 
end


return HandBookMainLayer

