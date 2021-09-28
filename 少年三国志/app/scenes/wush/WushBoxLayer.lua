require("app.cfg.drop_info")

local Colors = require("app.setting.Colors")

local WushBoxLayer = class("WushBoxLayer", UFCCSModelLayer)
    
function WushBoxLayer:ctor(json,color,startPos,star,award,callback,...)
    --self:init()
    self.super.ctor(self,...)
    self._boxType = nil
    self.bounsId = nil
    self._color = color
    self.startPt = startPos
    self._parent = nil
    self:setBackColor(ccc4(0,0,0,0))
    -- 掉落库id
    self.dropId = 0
    self:_init(star,award)
    self._callback = callback
    self:adapterWithScreen()
    -- 动画变化形式
    self._dir = "big"

end

function WushBoxLayer:onLayerEnter()
    self:showAnimation("big")

    if self._parent and self.__EFFECT_FINISH_CALLBACK__ then
        self._parent.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
    end

    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_Girl"))
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --     local img = self:getImageViewByName("Image_Girl")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end
end

-- 缓动动画
function WushBoxLayer:showAnimation(dir)
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
    
    local pt = self:convertToNodeSpace(self.startPt)
    local img = self:getImageViewByName("ImageView_762")
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.3,endPos))
    array:addObject(CCScaleTo:create(0.3,endScale))
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

function WushBoxLayer:_appendRichText(txt,color)
    local str = "<text value='" .. txt .. "'color='" .. color .. "'/>" 
    return str
end

function WushBoxLayer:_createRichText()
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

function WushBoxLayer:_initGateBouns(id,_richText)
    local _stageinfo = dungeon_stage_info.get(id)
    if _stageinfo then
        local _info = dungeon_stage_info.get(_stageinfo.premise_id)
        if _info then
            local _data = G_Me.dungeonData:getStageById(id)
            local statge_data = G_Me.dungeonData:getStageById(_stageinfo.premise_id)
            local isFinish = false
            if statge_data._star and statge_data._star > 0 and not _data._isFinished then -- 可以领取
                isFinish = true
            end
            if _data then
                local _btn = self:getButtonByName("getbounsbtn")
                if _btn then _btn:setTouchEnabled(isFinish) end
                --self:getImageViewByName("ImageView_Light"):showAsGray(isFinish)
--                local _starText = self:getLabelByName("condition")

--            local str = "<content>" .. self:_appendRichText(G_lang:get("LANG_DUNGEON_PASS"), '16764672')
--            str = str .. self:_appendRichText(_info.name, '7456723')
--            str = str .. self:_appendRichText(G_lang:get("LANG_DUNGEON_GETBOUNS"), '16764672') .. "</content>"
--            _richText:appendXmlContent(str)
--            _richText:reloadData()
            --if _starText then _starText:setText(G_lang:get("LANG_PASSGATEBOUNS",{gatename = _info.name})) end
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

function WushBoxLayer:setStarBoxStatus(gateStar,isGet,_totalStar)
    local _btn = self:getButtonByName("getbounsbtn")
    local _descLabel = self:getLabelByName("Label_Desc")
    function setRichText()
        -- local _richText = self:_createRichText()
        if _descLabel then 
            -- local str = "<content>" .. self:_appendRichText(G_lang:get("LANG_DAILYTASK_DES1"), '3342337')
            -- str = str .. self:_appendRichText(gateStar .. G_lang:get("LANG_DAILYTASK_DES2"), '3342337')
            -- str = str .. self:_appendRichText(G_lang:get("LANG_DAILYTASK_DES3"), '3342337') .. "</content>"
            local str = G_lang:get("LANG_WUSH_BOX",{star=gateStar})
            -- _richText:appendXmlContent(str)
            -- _richText:reloadData()
            _descLabel:setText(str)
        end
    end

    _btn:setTouchEnabled(true)
    setRichText()
end
    
function WushBoxLayer:_init(star,award)
    self:registerBtnClickEvent("getbounsbtn",handler(self,self._getBouns))
    self:registerBtnClickEvent("closebtn",handler(self,self._closeWindow))
    self:attachImageTextForBtn("getbounsbtn","ImageView_Light")
    local _title = self:getLabelBMFontByName("LabelBMFont_Title")
    self._award = award

    local open = G_Me.dailytaskData:getBoxStatus()
    local gateStar = G_Me.dailytaskData:getScoreList()
    local _totalStar = G_Me.dailytaskData:getScore()
    
    self:setStarBoxStatus(star)  
    
    -- 获取掉落奖励
    -- local award = G_Me.dailytaskData:getAward()
    -- local info = daily_box_info.get(award[self._boxType])
    for i=1,4 do
        local bouns = self:getWidgetByName("bouns" .. tostring(i))
        -- local data = G_Goods.convert(info["award" .. tostring(i).."_type"],info["award" .. tostring(i).."_value"])
        if bouns then
            if i <= #award and award[i].type ~= 0 then
                local data = G_Goods.convert(award[i].type,award[i].value)
                bouns:setTag(i)
                self:registerWidgetTouchEvent("bouns" .. tostring(i),handler(self,self.onClick))
                self:_setBouns(bouns,{info = data,bounsnum =award[i].size})
                bouns:getParent():setVisible(true)
                self:getImageViewByName("ImageView_bouns" .. i):loadTexture(G_Path.getEquipIconBack(data.quality))
            else
                bouns:getParent():setVisible(false)
            end
        end
    end
    
end

--@desc 设置文本内容
local function setText(widget,childName,txt)
    local _name = widget:getChildByName(childName) 
    _name = tolua.cast(_name,"Label")
    if _name then 
        _name:createStroke(Colors.strokeBrown,1)
        _name:setText(txt) 
    end
end

--@desc 设置奖励信息
function WushBoxLayer:_setBouns(widget,data)
    setText(widget,"bounsnum","X" .. data.bounsnum)
    widget = tolua.cast(widget,"ImageView")
    widget:loadTexture(data.info.icon)
    
    local _name = widget:getChildByName("bounsname")
    _name = tolua.cast(_name,"Label")
    _name:createStroke(Colors.strokeBrown,1)            
    local _ico = widget:getChildByName("ico")
    _ico = tolua.cast(_ico,"ImageView")
    _name:setColor(Colors.getColor(data.info.quality))
    setText(widget, "bounsname", data.info.name)
    _ico:loadTexture(G_Path.getEquipColorImage(data.info.quality,data.info.type))

end


function WushBoxLayer.create(startPos,star,award,callback)
    return WushBoxLayer.new("ui_layout/wush_boxLayer.json",Colors.modelColor,startPos,star,award,callback)
end
function WushBoxLayer:_closeWindow()
    --self:close()
    self:showAnimation("small")
end

function WushBoxLayer:_getBouns()
    -- G_HandlersManager.dailytaskHandler:sendGetDailyMissionAward(self.bounsId)
    if self._callback then
        self._callback()
    end
    self:animationToClose()
end

-- @desc 点击物品信息
function WushBoxLayer:onClick(widget,_type)
    if  _type == TOUCH_EVENT_ENDED then
        -- 获取掉落奖励
        local index = widget:getTag()
        local info = self._award[index]

        require("app.scenes.common.dropinfo.DropInfo"
         ).show(info.type,info.value)
    end

    --widget:setTouchEnabled(false)
end

function WushBoxLayer:_setParentLayer( parent )
    self._parent = parent

    if self._parent and self.__EFFECT_FINISH_CALLBACK__ then 
        self._parent.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
    end
end

return WushBoxLayer

