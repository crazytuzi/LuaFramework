local MailCell = class ("MailCell", function (  )
    return CCSItemCellBase:create("ui_layout/mail_MailCell.json")
end)

-- local dst = {"app.scenes.treasure.TreasureComposeScene",
-- 	"app.scenes.arena.ArenaScene",
-- 	"app.scenes.tower.TowerScene",
-- 	"app.scenes.tower.TowerScene",
-- 	"app.scenes.tower.TowerScene"}

-- local dst2 = {"quduobao",
--         "qujijichang",
--         "quVIP",
--         "quVIP",
--         "quVIP",
--         "quVIP",
--         "quVIP",
--         "quVIP",
--         "quVIP",
--         "tongyi", --加好友
--         "quVIP",}

function MailCell:ctor(list, index)
    self._txtTitle = self:getLabelByName("Label_title")
    self._txtTitle:createStroke(Colors.strokeBrown,2)
    self._txtTitle2 = self:getLabelByName("Label_title2")
    self._txtTitle2:setVisible(false)
    self._txtTitle3 = self:getLabelByName("Label_title3")
    self._txtTitle3:setVisible(false)
    self._txtContent = self:getLabelByName("Label_content")
    self._txtTime = self:getLabelByName("Label_time")
    self:getImageViewByName("Image_go"):loadTexture("ui/text/txt-small-btn/quduobao.png")
     self:registerBtnClickEvent("Button_51", function(widget)
        if self._mail then
            self:_goOthers(self._mail.mail_info_id)
        end
        self:selectedCell(index, 0)
     end)
--        
--        self:regisgerWidgetTouchEvent("Panel_25", function ( widget, _type)
--            if _type == 0 then
--                uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FRIENDS_USER_INFO, nil, false, self._friend)
--            end
--        end)

    local label = self:getLabelByName("Label_content")
    label:setVisible(false)
    local size = label:getSize()
    local clr = label:getColor()
    self._labelClr = ccc3(clr.r, clr.g, clr.b)
    self._richText = CCSRichText:create(size.width+60, size.height+40)
    self._richText:setFontName(label:getFontName())
    self._richText:setFontSize(label:getFontSize())
    local x, y = label:getPosition()
    self._richText:setPosition(ccp(x+24, y))
    self._richText:setShowTextFromTop(true)
    -- self._richText:setTextAlignment(ui.TEXT_ALIGN_CENTER)
    local parent = label:getParent()
    if parent then
        parent:addChild(self._richText, 5)
    end
    -- print(Colors.getRichTextValue(ccc3(0x50,0x3e,0x42)))
end

--12922112 mingxian
--5258818 miaoshu
--3509514 shuxing

function MailCell:updateData(mail )
    -- mail.mail_info_id = 1
    self._mail = mail
    self._txtTitle:setText(mail.mail_info_record.title)
    local text = ""

    if mail.mail_info_id == 8 then
        --好友邮件
        self._txtTitle2:setVisible(true)
        self._txtTitle3:setVisible(true)
        self._txtTitle2:setText(G_lang:get("LANG_MAIL_SENDER"))
        self._txtTitle3:setText(mail.name)
        -- self._txtContent:setText(mail.comment)
        text = mail.comment
        self:getImageViewByName("Image_go"):loadTexture("ui/text/txt-small-btn/huifu.png")
        self:getButtonByName("Button_51"):loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
    else
        self._txtTitle2:setVisible(false)
        self._txtTitle3:setVisible(false)
        -- self._txtContent:setText(mail.content)
        text = mail.content
        if mail.mail_info_id == 1 then
            self:getImageViewByName("Image_go"):loadTexture("ui/text/txt-small-btn/quduobao.png")
        else
            self:getImageViewByName("Image_go"):loadTexture("ui/text/txt-small-btn/qujijichang.png")
        end
        self:getButtonByName("Button_51"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
    end
    -- print(text)
    self._richText:clearRichElement()
    self._richText:appendContent(text, self._labelClr)
    self._richText:reloadData()

    self._txtContent:setText(text)
    
    self._txtTime:setText(self:_getTime(mail.time))

    self._txtTitle:setColor(Colors.lightColors.TITLE_01)
    


    if mail.mail_info_id == 1 or mail.mail_info_id == 8 or mail.mail_info_id == 17 or mail.mail_info_id == 18 or mail.mail_info_id == 19 then
        self:getButtonByName("Button_51"):setVisible(true)
    else
        self:getButtonByName("Button_51"):setVisible(false)
    end

end

function MailCell:_getTime(time )
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

function MailCell:_goOthers( id)
    if id == 1 then
        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new())
    elseif id == 8 then
        G_HandlersManager.friendHandler:sendGetPlayerInfo(self._mail.source_id, nil)
    else
        uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new())
    end
    -- uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new())
end

return MailCell

