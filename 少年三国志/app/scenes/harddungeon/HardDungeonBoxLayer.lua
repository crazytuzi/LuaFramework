require("app.cfg.drop_info")
require("app.cfg.story_dungeon_info")

local Colors = require("app.setting.Colors")
local BOXTYPE = require("app.const.BoxType")

local HardDungeonBoxLayer = class("HardDungeonBoxLayer", UFCCSModelLayer)
    
function HardDungeonBoxLayer.create(name,value,id,startPos, ...)
    return HardDungeonBoxLayer.new("ui_layout/dungeon_DungeonBoxLayer.json", Colors.modelColor, name, value, id, startPos, ...)
end

function HardDungeonBoxLayer:ctor(json, color, box_Type, value, id, startPos, ...)
    --self:init()
    self.super.ctor(self, json, color, ...)
    self._boxType = nil
    self.bounsId = nil
    self._color = color
    self.startPt = startPos
    self._parent = nil
    self:setBackColor(ccc4(0,0,0,0))
    -- 掉落库id
    self:_init(box_Type,value,id)
    self:adapterWithScreen()
    -- 动画变化形式
    self._dir = "big"
    self:registerKeypadEvent(true)

    self._nDropId = value
end



function HardDungeonBoxLayer:onLayerEnter()
    self:showAnimation("big")

    if self._parent and self.__EFFECT_FINISH_CALLBACK__ then
        self._parent.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
    end
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion or IS_HEXIE_VERSION  then 
        local img = self:getImageViewByName("Image_Girl")
        if img then
            img:loadTexture("ui/arena/xiaozhushou_hexie.png")
        end
    end
end

function HardDungeonBoxLayer:onBackKeyEvent( ... )
    self:_closeWindow()
    return true
end

-- 缓动动画
function HardDungeonBoxLayer:showAnimation(dir)
    self._dir = dir
    local startScale = 1
    local endScale = 1
    local startPos = ccp(0,0)
    local endPos = ccp(0,0)
    local _size = self:getContentSize()
    if dir == "big" then
        startScale = 0.2
        endScale = 1
        startPos = self.startPt
        endPos = ccp(_size.width/2,_size.height/2)
    else
        startScale = 1
        endScale = 0.2
        startPos = ccp(_size.width/2,_size.height/2)
        endPos = self.startPt
    end
    local img = self:getImageViewByName("ImageView_762")
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2,endPos))
    array:addObject(CCScaleTo:create(0.2,endScale))
    local sequence = transition.sequence({CCSpawn:create(array),
    CCCallFunc:create(
        function()
            if self._dir == "small" then
                self:close() 
            else
                self:setBackColor(self._color)
            end
        end),
})
    img:runAction(sequence)
end

function HardDungeonBoxLayer:_appendRichText(txt,color)
    local str = "<text value='" .. txt .. "'color='" .. color .. "'/>" 
    return str
end

function HardDungeonBoxLayer:_createRichText()
    local label = self:getLabelByName("Label_Desc")
    local _richTxt  = CCSRichText:createSingleRow()
    _richTxt:setPosition(label:getPositionInCCPoint())
    _richTxt:setFontSize(label:getFontSize())
    _richTxt:setVerticalSpacing(10)
    _richTxt:setMaxRowCount(30)
    label:getParent():addChild(_richTxt,5)
    _richTxt:clearRichElement()
    _richTxt:setFontName(label:getFontName())
    label:setVisible(false)
    return _richTxt
end

function HardDungeonBoxLayer:_initGateBouns(id)
    local _stageinfo = hard_dungeon_stage_info.get(id)
    if _stageinfo then
        local _info = hard_dungeon_stage_info.get(_stageinfo.premise_id)
        if _info then
            local _data = G_Me.hardDungeonData:getStageById(id)
            local statge_data = G_Me.hardDungeonData:getStageById(_stageinfo.premise_id)
            local isFinish = false
            if statge_data._star and statge_data._star > 0 and not _data._isFinished then -- 可以领取
                isFinish = true
            end
            if _data then
                local _btn = self:getButtonByName("getbounsbtn")
                if _btn then 
                    _btn:setTouchEnabled(isFinish) 
                end
                self:getImageViewByName("ImageView_Light"):showAsGray(not isFinish)

                local _btn = self:getButtonByName("getbounsbtn")
                
                -- 宝箱描述信息
                local _descLabel = self:getLabelByName("Label_Desc")
                if _data._isFinished then
                    _btn:setVisible(false)
                     local _getLabel = self:getImageViewByName("ImageView_AleadyGet")
                     if _getLabel then _getLabel:setVisible(true) end
                     _descLabel:setText(G_lang:get("LANG_DUNGEON_ALREADYGET"))
                else
                   _btn:setTouchEnabled(isFinish)
                   _descLabel:setText(G_lang:get("LANG_DUNGEON_PASSGATE",{name=_info.name}))
                   
                end
            end
        end
    end
        
end

function HardDungeonBoxLayer:setStarBoxStatus(gateStar,isGet,conditionTxt,_totalStar)
    local _btn = self:getButtonByName("getbounsbtn")
    local _descLabel = self:getLabelByName("Label_Desc")

    function setRichText()
        local _richText = self:_createRichText()
        if _descLabel then 
            local str = "<content>" .. self:_appendRichText(G_lang:get("LANG_DUNGEON_REACH"), '3342337')
            str = str .. self:_appendRichText(conditionTxt .. G_lang:get("LANG_DUNGEON_STAR"), '3342337')
            str = str .. self:_appendRichText(G_lang:get("LANG_DUNGEON_GETBOUNS"), '3342337') .. "</content>"
            _richText:appendXmlContent(str)
            _richText:reloadData()
        end
    end


    local btnText = self:getImageViewByName("ImageView_Light")
    if _totalStar >= gateStar then
        if isGet  then
            _btn:setVisible(false)
             local _getLabel = self:getImageViewByName("ImageView_AleadyGet")
             if _getLabel then _getLabel:setVisible(true) end
             _descLabel:setText(G_lang:get("LANG_DUNGEON_ALREADYGET"))
        else
             _btn:setTouchEnabled(true)
             setRichText()
             btnText:showAsGray(false)
        end
    else
        _btn:setTouchEnabled(false)
        setRichText()
        btnText:showAsGray(true)
    end
end
    
function HardDungeonBoxLayer:_init(box_Type,value,id)
    self.bounsId = id
    self._name = name
    self:registerBtnClickEvent("getbounsbtn",handler(self,self._getBouns))
    self:registerBtnClickEvent("closebtn",handler(self,self._closeWindow))
    local _title = self:getLabelBMFontByName("LabelBMFont_Title")
    self._boxType = box_Type
    if box_Type ~= BOXTYPE.STORYGATEBOX then
        local chapterId = G_Me.hardDungeonData:getCurrChapterId()
        local data = hard_dungeon_chapter_info.get(chapterId)
        local _totalStar = G_Me.hardDungeonData:getChapterStar(chapterId)


        local _isOpenCopperbox,_isOpenSilverbox,_isOpenGoldbox = 
            G_Me.hardDungeonData:getBoxStuatus(chapterId)
            
        if box_Type == BOXTYPE.COPPERBOX then  -- 铜宝箱
            self:getImageViewByName("ImageView_CopperBox"):setVisible(true)
            self:setStarBoxStatus(data.copperbox_star,_isOpenCopperbox,tostring(data.copperbox_star),_totalStar)  
        elseif box_Type == BOXTYPE.SIVLERBOX then -- 银宝箱
            self:getImageViewByName("ImageView_SilverBox"):setVisible(true)
            self:setStarBoxStatus(data.silverbox_star,_isOpenSilverbox,tostring(data.silverbox_star),_totalStar)   
        elseif box_Type == BOXTYPE.GOLDBOX   then -- 金宝箱
            self:getImageViewByName("ImageView_GoldBox"):setVisible(true)
            self:setStarBoxStatus(data.goldbox_star,_isOpenGoldbox,tostring(data.goldbox_star),_totalStar)
        elseif box_Type == BOXTYPE.DUNGEONGATEBOX then -- 关卡宝箱
            self:getImageViewByName("ImageView_GateBox"):setVisible(true)
            self:_initGateBouns(id)
        end
    else -- 武将传关卡宝箱
        self:getImageViewByName("ImageView_GateBox"):setVisible(true)
        self:_initStoryGateBouns()
    end
    

--    {name = goods.name,icon = _ico,info=goods,quality=_quality,desc=_desc,size=size,type=_type,value = _value,icon_mini = _icon_mini, texture_type=_texture_type}
--    local goods = {name=drop.name,icon=_icon,desc=drop.directions,quality=drop.quality, goodsArray = {}}

    local nDropId = value
    local tDrops = G_Drops.convert(nDropId)

    for i=1, 4 do
        local bouns = self:getWidgetByName("bouns" .. i)
        local tGoods = tDrops.goodsArray[i]
        if tGoods then
            bouns:setTag(i)
            self:registerWidgetTouchEvent("bouns" .. i, handler(self,self.onClick))
            self:_setBouns(bouns,{info = tGoods, bounsnum = tGoods.size })
            bouns:getParent():setVisible(true)
            self:getImageViewByName("ImageView_bouns" .. i):loadTexture(G_Path.getEquipIconBack(tGoods.quality))
        else
            bouns:getParent():setVisible(false)
        end
    end
end

function HardDungeonBoxLayer:_initStoryGateBouns()
    local _stageinfo = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    if _stageinfo then
        local _data = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
        if _data then
            local isFinish = _data.is_finished
            local _btn = self:getButtonByName("getbounsbtn")
            if _btn then 
                _btn:setTouchEnabled(isFinish) 
            end
            self:getImageViewByName("ImageView_Light"):showAsGray(not isFinish)

            -- 宝箱描述信息
            local _descLabel = self:getLabelByName("Label_Desc")
            if _data.has_award then
                _btn:setVisible(false)
                 local _getLabel = self:getImageViewByName("ImageView_AleadyGet")
                 if _getLabel then _getLabel:setVisible(true) end
                 _descLabel:setText(G_lang:get("LANG_DUNGEON_ALREADYGET"))
            else
               _btn:setTouchEnabled(isFinish)
               local _info = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
               _descLabel:setText(G_lang:get("LANG_DUNGEON_PASSGATE",{name=_info.name}))
            end
        end
    end
end

--@desc 设置文本内容
local function setLabelText(widget,childName,txt)
    local _name = widget:getChildByName(childName) 
    _name = tolua.cast(_name,"Label")
    if _name then 
        _name:createStroke(Colors.strokeBrown,1)
        _name:setText(txt) 
    end
end

--@desc 设置奖励信息
function HardDungeonBoxLayer:_setBouns(widget,data)
    setLabelText(widget,"bounsnum","X" .. data.bounsnum)
    widget = tolua.cast(widget,"ImageView")
    widget:loadTexture(data.info.icon)
    
    local _name = widget:getChildByName("bounsname")
    _name = tolua.cast(_name,"Label")
    _name:createStroke(Colors.strokeBrown,1)            
    local _ico = widget:getChildByName("ico")
    _ico = tolua.cast(_ico,"ImageView")
    _name:setColor(Colors.getColor(data.info.quality))
    setLabelText(widget, "bounsname", data.info.name)
    _ico:loadTexture(G_Path.getEquipColorImage(data.info.quality,data.info.type))



end

function HardDungeonBoxLayer:_closeWindow()
    --self:close()
    self:showAnimation("small")
end

function HardDungeonBoxLayer:_getBouns()
    -- 检查包裹已满
    local CheckFunc = require("app.scenes.common.CheckFunc")
    if CheckFunc.checkBagWithDropId(self._nDropId) then
        return
    end
    
    if self._boxType == BOXTYPE.DUNGEONGATEBOX then
        G_HandlersManager.hardDungeonHandler:sendExecuteStage(self.bounsId, true)
    elseif self._boxType == BOXTYPE.STORYGATEBOX then
        G_HandlersManager.storyDungeonHandler:sendGetBarrierAward(G_Me.storyDungeonData:getCurrDungeonId())
    else
        G_HandlersManager.hardDungeonHandler:sendFinishChapterBoxRwd(G_Me.hardDungeonData:getCurrChapterId(),self._boxType)
    end
    self:_closeWindow()
end

-- @desc 点击物品信息
function HardDungeonBoxLayer:onClick(widget,_type)
    if  _type == TOUCH_EVENT_ENDED then
        local nDropId = self._nDropId
        local tDrops = G_Drops.convert(nDropId)
        local nIndex = widget:getTag()
        local tGoods = tDrops.goodsArray[nIndex]
        if tGoods then
            require("app.scenes.common.dropinfo.DropInfo").show(tGoods.type, tGoods.value)
        end
    end

end

function HardDungeonBoxLayer:_setParentLayer( parent )
    self._parent = parent

    if self._parent and self.__EFFECT_FINISH_CALLBACK__ then 
        self._parent.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
    end
end

return HardDungeonBoxLayer

