require("app.cfg.notice_info")
require("app.cfg.knight_info")
local NoticeLayer = class ("NoticeLayer", UFCCSNormalLayer)

local RoleColor =
{
    Blue = 1055734,
    Red = 16580889
}

function NoticeLayer:ctor(...)      
    self.super.ctor(self,...)
    self:adapterWithScreen()
    
    self._richTxt  = CCSRichText:createSingleRow()
    self._richTxt:enableStroke(Colors.strokeBrown)
    self._richTxt:setFontSize(22)
    --self._richTxt:setVerticalSpacing(10)
    self:getPanelByName("Panel_Bg"):addChild(self._richTxt,10)
    self._richTxt:clearRichElement()
    self._richTxt:setAnchorPoint(ccp(0,0.5))
    self._richTxt:setFontName("FZYiHei-M20S.ttf")
    
    local _spindleSprite = self:getWidgetByName("Image_Spindle"):getVirtualRenderer()
    _spindleSprite = tolua.cast(_spindleSprite,SCALE9SPRITE)
    _spindleSize = _spindleSprite:getPreferredSize()
    self._size = CCSize(_spindleSize.width,_spindleSize.height)
    local size = self:getPanelByName("Panel_Bg"):getContentSize()
    self._richTxt:setPosition(ccp(size.width,size.height/2))
    self:setVisible(false)
end

function NoticeLayer.create()
    return  NoticeLayer.new("ui_layout/common_NoticeLayer.json")
end

function NoticeLayer:_setText(txt)
    print("notice content:" .. txt)
    print("--------------------------------------")
    self._richTxt:appendXmlContent(txt)
    self._richTxt:reloadData()
end

function NoticeLayer:startMove()
    local data = G_Notice:getNotice()
    self:parseData(data)
    self:moveAnimation()
end

function NoticeLayer:moveAnimation()
    self:getWidgetByName("Image_Spindle"):setSize(self._size)
    GlobalFunc.flyFromMiddleToSize(self:getWidgetByName("Image_Spindle"), 0.3, 0.1, function ( ... )
        self:_doMoveNotice()        
            end)
end

function NoticeLayer:_doMoveNotice( ... )
    local size = self:getPanelByName("Panel_Bg"):getContentSize()
    self._richTxt:setPositionX(size.width)
    local _posY = self._richTxt:getPositionY()
    local _posX = self._richTxt:getContentSize().width
    if _posX <= 0 then
        _posX = 0
    else
        _posX = -_posX
    end
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function() self._richTxt:setVisible(true) end))
   
    arr:addObject(CCMoveTo:create(((math.abs(_posX)+size.width)/80),ccp(_posX,_posY)))   
    arr:addObject(CCCallFunc:create(handler(self, self._moveToCenter)))
    self._richTxt:stopAllActions()
    self._richTxt:runAction(CCSequence:create(arr))
end

function NoticeLayer:_moveToCenter()
    self._richTxt:setVisible(false)
    if self:_showNextData() then 
        return 
    end

    self.flyFromSizeToMiddle(self:getWidgetByName("Image_Spindle"), 0.3, 0.1, function ( ... )
        self:_finish()
    end)
end
-- 解析协议
function NoticeLayer:parseData(data)
    -- 清除上一条显示内容
    if self._richTxt:getCurLineCount() > 0 then
        self._richTxt:clearRichElement()
    end
    
    local _name =data.name 
    local knightInfo = knight_info.get(data.base_id)
    -- __Log("knightInfo:")
    -- dump(knightInfo)
    local color = Colors.qualityDecColors[knightInfo.quality]
    -- 抽将
    if data.template_id == 1 then
        local _num2 = ""
        if data.template_args[1] == 1  then    -- 良将
            _num2 = G_lang:get("LANG_NOTICE_ZHANJIANG")
        elseif data.template_args[1] == 2  then    -- 神将十连抽
            _num2 = G_lang:get("LANG_NOTICE_ZHANJIANGSHI")
        elseif data.template_args[1] == 3  then    -- 神将
            _num2 = G_lang:get("LANG_NOTICE_SHENJIANG")
        elseif data.template_args[1] == 4  then --神将十连抽
            _num2 = G_lang:get("LANG_NOTICE_SHENJIANGSHI")
        elseif data.template_args[1] == 5  then     --神将二十抽
            _num2 = G_lang:get("LANG_NOTICE_SHENJIANGERSHI")
        else -- 阵营抽将
            _num2 = G_lang:get("LANG_NOTICE_ZHENYING")
        end

        local _num3= ""
        for i=2,#data.template_args do
            local _info = knight_info.get(data.template_args[i])
            -- 根据抽将的品质设置不同的颜色
            if i== 2 then
                _num3 = _num3 .. _info.name .. "'"
                _num3 = _num3 .. " color='" .. Colors.qualityDecColors[_info.quality]
                -- 只招一个紫卡以上品质
                if #data.template_args > 2 then
                    _num3 = _num3 .. "'" 
                end
            else
                 _num3 = _num3  .. " />" .. "<text color='" .. Colors.qualityDecColors[_info.quality] .. "'" ..  " value='" .. _info.name .. "'"
                 if #data.template_args > 3 and i ~= #data.template_args then
                     _num3 = _num3  .. " />"
                 end
            end
            if #data.template_args > 2 then
                if i == #data.template_args then -- 删除最后一个单引号
                    _num3 = string.sub(_num3,1,-2)
                else
                    _num3 = _num3  .. "/><text color='#fef6d8' value='、' "
                end -- 5449488
            end
        end
        self:_setText(self:getText(data.template_id,{name=_name,num2=_num2,num3=_num3,col= color},color))
        
    elseif data.template_id == 2 then -- 竞技场
        self:_setText(self:getText(data.template_id,{name=_name, col=color},color))
        
    elseif data.template_id == 3 then -- 突破
        local _info = knight_info.get(data.template_args[1])   
        qualityColor = Colors.qualityDecColors[_info.quality]
        if _info.name == G_Me.userData.name then
            -- 当完成突破的玩家当前突破的武将正好和显示走马灯的玩家武将baseid相同时，
            -- 会出现突破的武将名称显示为当前玩家的名字
            _info.name = G_lang:get("LANG_NOTICE_MAIN_KNIGHT")
        end
        self:_setText(self:getText(data.template_id,{name=_name,num2 = _info.name,num3= _info.advanced_level,col= color},qualityColor))
        
    elseif data.template_id == 4 then -- 闯关
        self:_setText(self:getText(data.template_id,{name=_name,num2 = data.template_args[1],col= color},color))
        
    elseif data.template_id == 5 then -- 主线副本
        self:_setText(self:getText(data.template_id,{name=_name,num2 = data.template_args[1],col= color},color))

    elseif data.template_id == 6 then -- 三国志残片
        self:_setText(self:getText(data.template_id,{name=_name,col= color},color))

    elseif data.template_id == 7 then -- 攻城略地
        local good = G_Goods.convert(data.template_args[1], data.template_args[2])
        if good then
            local goodsColor = Colors.qualityDecColors[good.quality]
            local text = good.name .. "x" .. data.template_args[3]
            self:_setText(self:getText(data.template_id,{name=_name,num2 =text ,col= color},goodsColor))
        end

    elseif data.template_id == 8 then -- 轮盘
        local good = G_Goods.convert(data.template_args[1], data.template_args[2])
        local _size = data.template_args[3]
        if good then
          local goodColor = Colors.qualityDecColors[good.quality]
          local text = good.name
          self:_setText(self:getText(data.template_id, {name=_name,col=color, colGood=goodColor, num=text, size=_size}, goodColor))
        end

    elseif data.template_id == 9 then 
        local good = G_Goods.convert(data.template_args[1], data.template_args[2])
        local _size = data.template_args[3]
        if good then
          local goodColor = Colors.qualityDecColors[good.quality]
          local text = good.name
          self:_setText(self:getText(data.template_id,{name=_name,col= color, colGood=goodColor, num=text, size=_size}, goodColor))
        end

    -- 元宝
    elseif data.template_id == 10 then 
        local _size = data.template_args[3]
        self:_setText(self:getText(data.template_id,{name=_name,col= color, size=_size},color))
    -- 元宝
    elseif data.template_id == 11 then 
        local _size = data.template_args[3]
        self:_setText(self:getText(data.template_id,{name=_name,col= color, size=_size},color))
    elseif data.template_id == 12 then
        -- dump(data)
        -- 巡游探宝
        local good = G_Goods.convert(data.template_args[2], data.template_args[3])
        local _size = data.template_args[4]
        if good then
          local goodColor = Colors.qualityDecColors[good.quality]
          local text = good.name
          self:_setText(self:getText(data.template_id,{name=_name,col= color, colGood=goodColor, name1=text}, goodColor))
        end
    elseif data.template_id == 13 then
        -- 精英副本暴动boss
        require("app.cfg.hard_dungeon_chapter_info")
        require("app.cfg.hard_dungeon_roit_info")
        local chapterName = hard_dungeon_chapter_info.get(data.template_args[1]).name
        -- TODO: 在服务器端更新之后去掉这个判断
        if data.template_args[2] == nil then
            return
        end
        local currentRoitInfo = hard_dungeon_roit_info.get(data.template_args[2])
        local mosterName = currentRoitInfo.name
        local mosterColor = Colors.qualityDecColors[currentRoitInfo.quality]
        self:_setText(self:getText(data.template_id, {name = _name, col = color, chapter_name = chapterName, monster_name = mosterName, col1 = mosterColor}))
    elseif data.template_id == 14 then
        -- 夺粮战走马灯，未使用
    elseif (data.template_id >= 15 and data.template_id <= 74) or data.template_id >= 77 then
        if not (data.template_args[1] and data.template_args[2] and data.template_args[3]) then 
            return
        end
        local good = G_Goods.convert(data.template_args[1], data.template_args[2])
        local _size = data.template_args[3]
        local _num2 = ""
        if good then
            _num2 = good.name .. "×" .. _size .. "' color='" .. Colors.qualityDecColors[good.quality]
        end

        if #data.template_args >= 4 then
            for i=4, #data.template_args, 3 do
                local good = G_Goods.convert(data.template_args[i], data.template_args[i + 1])
                local _size = data.template_args[i + 2]
                if good then
                    _num2 = _num2 .. "' />" .. "<text color='5449488' value='、'/>" .. "<text color='" .. Colors.qualityDecColors[good.quality] .. "'" ..  " value='" .. good.name .. "×" .. _size
                end
            end
        end

        self:_setText(self:getText(data.template_id,{num1=_name,col= color, colGood=goodColor, num2=_num2}, goodColor)) 
    elseif data.template_id == 75 then
        -- 将灵之点将台
        -- dump(data)
        if not data.template_args[1] then 
            return
        end
        require("app.cfg.ksoul_info")
        local ksoulInfo = ksoul_info.get(data.template_args[1])
        if not ksoulInfo then
            return
        end
        local ksoulName = ksoulInfo.name .. "' color='" .. Colors.qualityDecColors[ksoulInfo.quality]
        self:_setText(self:getText(data.template_id,{name=_name, col= color, num1=ksoulName},color))

    elseif  data.template_id == 76 then
        -- 将灵之名将试炼
        -- dump(data)
        if not (data.template_args[1] and data.template_args[2] )then 
            return
        end
        
        require("app.cfg.ksoul_dungeon_info")
        local ksoulDungeonInfo = ksoul_dungeon_info.get(data.template_args[1])
        if not ksoulDungeonInfo then
            return
        end
        local ksoulDungeonName = ksoulDungeonInfo.name
        
        require("app.cfg.ksoul_info")
        local ksoulInfo = ksoul_info.get(data.template_args[2])
        if not ksoulInfo then
            return
        end
        local ksoulName = ksoulInfo.name .. "' color='" .. Colors.qualityDecColors[ksoulInfo.quality]

        self:_setText(self:getText(data.template_id,{name=_name, col= color, dungeon_name=ksoulDungeonName, num3=ksoulName},color))
    end
    
end

-- 检查列表里面是否还有其他的消息
function NoticeLayer:_finish()
    local sprite = self:getWidgetByName("Image_Spindle"):getVirtualRenderer()
    sprite = tolua.cast(sprite,SCALE9SPRITE)
    sprite:setPreferredSize(self._size)
    --sprite:setScale(1)
    self:setVisible(false)
     --self:_showNextData()

end

function NoticeLayer:_showNextData( ... )
  local data = G_Notice:getNotice()
     if data then
            if self._richTxt:getCurLineCount() > 0 then
                self._richTxt:clearRichElement()
            end
            self:parseData(data)
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(1))
            arr:addObject(CCCallFunc:create(
                function() 
                    --self:setVisible(true) 
                    self:_doMoveNotice() 
                    end ))  
            self:runAction(CCSequence:create(arr))
            return true
     end

     return false
end

function NoticeLayer.flyFromSizeToMiddle( ctrl, delay1, delay2, func1, func2 )
    if not ctrl then 
        return 
    end

    if delay1 < 0 then 
        delay1 = 0
    end
    
    if delay1 <= 0 then 
        if func1 then 
            func1()
        end
        if func2 then 
            func2()
        end
    end

    local ctrlSize = ctrl:getSize()
    local ctrlSizeCopy = CCSizeMake(ctrlSize.width, ctrlSize.height)
    local startWidth = ctrlSize.width
    ctrl:setSize(CCSizeMake(startWidth, ctrlSize.height))
    local resetSize = function ( number )
        ctrl:setSize(CCSizeMake(number, ctrlSizeCopy.height))
    end
    
    local maxExtendLen = ctrlSizeCopy.width*0.12

    local numberChange1 = CCNumberGrowupAction:create(startWidth, maxExtendLen, delay1, function ( number )
        resetSize(number)
    end)
    local ease1 = CCEaseIn:create(numberChange1, delay1)
    local arr = CCArray:create()
    arr:addObject(ease1)
    arr:addObject(CCCallFunc:create(function (  )
        if func1 then
            func1()
        end
    end))
    ctrl:runAction(CCSequence:create(arr)) 
end

function NoticeLayer:getText(key, values,nameColor)
    local tmpl = notice_info.get(key).comment
    if tmpl == nil then
        __Error("cannot get lang for key :" .. key)
        return key
    end
    if values ~= nil then
        --replace vars in tmpl
        for k,v in pairs(values) do
            
            if (key==3 or key==7 )and k == "num2" then
                tmpl = string.gsub(tmpl, "value='#num2#'", "color='" .. nameColor .. "' value='" .. v .. "'")
            else
                tmpl = string.gsub(tmpl, "#" .. k .. "#", v)
            end
	end
        
    end
    
    return tmpl
end

return NoticeLayer

