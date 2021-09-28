local GiftMailCell = class ("GiftMailCell", function (  )
    return CCSItemCellBase:create("ui_layout/giftmail_GiftMailCell.json")
end)

local CheckFunc = require("app.scenes.common.CheckFunc")
function GiftMailCell:ctor(list, index)
    self._txtTitle = self:getLabelByName("Label_title")
    self._txtTitle:createStroke(Colors.strokeBrown, 2)
    self._txtContent = self:getLabelByName("Label_desc")
    -- self._txtContent:createStroke(Colors.strokeBrown, 1)
    self._btnGet = self:getLabelByName("Button_get")
    -- self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_listgift"), LISTVIEW_DIR_HORIZONTAL)
    -- self._scrollView = self:getScrollViewByName("ScrollView_listgift")
    self._scrollView = self:getWidgetByName("ScrollView_listgift")
    self._scrollView = tolua.cast(self._scrollView,"ScrollView")
    self._txtTime = self:getLabelByName("Label_time")

    local label = self:getLabelByName("Label_desc")
    label:setVisible(false)
    local size = label:getSize()
    local clr = label:getColor()
    self._labelClr = ccc3(clr.r, clr.g, clr.b)
    self._richText = CCSRichText:create(size.width, size.height+15)
    self._richText:setFontName(label:getFontName())
    self._richText:setFontSize(label:getFontSize())
    local x, y = label:getPosition()
    self._richText:setPosition(ccp(x+size.width/2+15, y+size.height+10))
    self._richText:setShowTextFromTop(true)
    local parent = label:getParent()
    if parent then
        parent:addChild(self._richText, 5)
    end

    self._mail = nil
    self:registerBtnClickEvent("Button_get", function(widget)
        if not self._mail or (not self._mail.id) then
            return
        end
        if self._mail.awards and #self._mail.awards>0 then
            for i,v in ipairs(self._mail.awards) do
                if CheckFunc.checkDiffByType(v.type,v.size) then
                    return
                end
            end
        end
        G_HandlersManager.giftMailHandler:sendProcessGiftMail(self._mail.id )
    end)

end


function GiftMailCell:updateData(mail )
    self._mail = mail
    if not mail then
        return
    end
    -- dump(mail)
    self._txtTitle:setText(mail.mail_info_record.title)
    self._txtTime:setText(self:_getTime(mail.time))
    -- self._txtTitle:createStroke(Colors.strokeBrown, 1)

    self._txtContent:setText(mail.content)
    self._richText:clearRichElement()
    self._richText:appendContent(mail.content, self._labelClr)
    self._richText:reloadData()

    self:_initScrollView( mail.awards)
end

--根据awards列表创建一个图标列表
-- function GiftMailCell.buildIconList(listData )
   
--     -- listView:setUpdateCellHandler(function ( list, index, cell)
--     --     if  index < #listData then
--     --         cell:updateData(listData[index+1]) 
--     --     end
--     -- end)
    
--     -- listView:initChildWithDataLength( #listData)
--     GiftMailCell._initScrollView(listData)
-- end

function GiftMailCell:_initScrollView(listData)
    self._scrollView:removeAllChildren();
    local space = 5 --间隙
    local size = self._scrollView:getContentSize()
    local _knightItemWidth = 0
    for i,v in ipairs(listData) do
        
        local btnName = "gift_item" .. "_" .. i
        local widget = require("app.scenes.giftmail.GiftMailIconCell").new(v,btnName)
        widget:updateData(listData[i])
        _knightItemWidth = widget:getWidth()


        widget:setPosition(ccp(_knightItemWidth*(i-1)+i*space,0))
        --self:addChild(widget)
        self._scrollView:addChild(widget)
    end
    local _scrollViewWidth = _knightItemWidth*#listData+space*(#listData+1)
    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

function GiftMailCell:_getTime(time )
    -- local tab = os.date("*t",time) 
    -- return string.format("%d-%d-%d  %d:%02d:%02d", tab.year, tab.month, tab.day, tab.hour, tab.min, tab.sec)
    local t = G_ServerTime:getTime() - time
    local str = ""
    local day=math.floor(t/3600/24)
    local hour=math.floor(t/3600)
    local min=math.floor(t/60)
    if day > 0 then
        str = G_lang:get("LANG_MAIL_TIME1",{day=day})
    elseif hour > 0 then
        str = G_lang:get("LANG_MAIL_TIME2",{hour=hour})
    elseif min > 0 then 
        str = G_lang:get("LANG_MAIL_TIME3",{min=min})
    else 
        str = G_lang:get("LANG_MAIL_TIME3",{min=1})
    end
    return str
end

return GiftMailCell

