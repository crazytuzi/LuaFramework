--[[
 --
 -- add by vicky
 -- 2014.12.02 
 --
 --]]

 local data_mail_mail = require("data.data_mail_mail") 
 local data_item_item = require("data.data_item_item") 
 require("data.data_error_error") 

 local SHOWTYPE = {
    NONE        = 0, 
    BATTLE      = 1, 
    FRIENDS     = 2,
    SYSTEM      = 3  
 } 

 local DayStr = {
    "今天", "一天前", "两天前", "三天前", "四天前", "五天前", "六天前", "七天前", "八天前", "九天前", "十天前",
    "十一天前", "十二天前", "十三天前", "十四天前"  
 }


 local MailScene = class("MailScene", function()
    return require("game.BaseScene").new({
        contentFile = "mail/mail_bg.ccbi", 
        topFile = "mail/mail_up_tab.ccbi", 
        adjustSize = CCSizeMake(0, -20) 
    })
 end) 


 function MailScene:reqMailData(viewType, bGetMore, curMailId) 
    RequestHelper.Mail.getMailList({
        type = viewType, 
        mailId = curMailId, 
        callback = function(data)
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
            else 
                if bGetMore == false then 
                    self._mailTotalNum = data.rtnObj.mailCnt 
                end 

                -- 若是刷新，记录上一次tableView的位置 
                local lastPosIndex = 0 
                if bGetMore == true then 
                    lastPosIndex = #self._itemDatas - 1 
                end 

                self:initMailData(data.rtnObj.mailList) 

                self:reloadListView(viewType, lastPosIndex) 

                if(viewType == SHOWTYPE.BATTLE) then
                    self._rootnode["mail_battle_notice"]:setVisible(false)
                    game.player:resetMailBattle()
                elseif(viewType == SHOWTYPE.SYSTEM)  then
                    self._rootnode["mail_system_notice"]:setVisible(false)
                    game.player:resetMailSystem()
                elseif(viewType == SHOWTYPE.FRIENDS)  then

                end

            end 
        end 
        }) 
 end 


 function MailScene:ctor() 
    ResMgr.removeBefLayer()
    game.runningScene = self 
    self._viewType = SHOWTYPE.NONE  
    self._curMailId = 0 
    self._mailTotalNum = 0 
    self._itemDatas = {} 

    local _bg = display.newSprite("ui_common/common_bg.png") 
    local _bgW = display.width
    local _bgH = display.height - self._rootnode["bottomMenuNode"]:getContentSize().height - self._rootnode["topFrameNode"]:getContentSize().height
    _bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode["bottomMenuNode"]:getContentSize().height)

    _bg:setScaleX(_bgW / _bg:getContentSize().width)
    _bg:setScaleY(_bgH / _bg:getContentSize().height)
    self:addChild(_bg, 0) 

    local function onTabBtn(tag) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
        for i = 1, 3 do
            if i ~= 2 then 
                if tag == i then
                    self._rootnode["tab" ..tostring(i)]:selected()
                    self._rootnode["btn" ..tostring(i)]:setZOrder(10) 
                else 
                    self._rootnode["tab" ..tostring(i)]:unselected()
                    self._rootnode["btn" ..tostring(i)]:setZOrder(10 - i)  
                end
            end 
        end

        if self._viewType ~= tag then 
            self._curMailId = 0 
            self._itemDatas = {}  
            self._viewType = tag 

            self:reqMailData(self._viewType, false, self._curMailId)  
        end 
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 3 do
            if i ~= 2 then 
                self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
            end 
        end 
    end 

    initTab() 
    onTabBtn(SHOWTYPE.BATTLE) 

    
    if(game.player:getMailBattle() > 0) then
        self._rootnode["mail_battle_notice"]:setVisible(true)
        self._rootnode["mail_battle_notice"]:setZOrder(11)
    else
        self._rootnode["mail_battle_notice"]:setVisible(false)
        game.player:resetMailBattle()
    end

    if(game.player:getMailSystem() > 0) then
        self._rootnode["mail_system_notice"]:setVisible(true)
        self._rootnode["mail_system_notice"]:setZOrder(11)
    else
        self._rootnode["mail_system_notice"]:setVisible(false)
        game.player:resetMailSystem()
    end 

 end 


 function MailScene:onEnter()
    game.runningScene = self 
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
    
 end

 function MailScene:onExit()
    self:unregNotice()
 end 


 function MailScene:getDataByTypeAndId(mailType, mailId) 
    local mailData 
    for i, v in ipairs(data_mail_mail) do 
        if v.type == mailType and v.id == mailId then 
            mailData = v 
            break 
        end 
    end 

    return mailData 
 end 


 function MailScene:getStrColorAndFont(item, mailId) 
    -- dump(item) 
    local color = "#5c2601" 
    local name = "" 
    local str = "" 
    if item ~= nil then 
        if item.paraType == 1 then 
            -- 物品，根据品质定颜色， 货币类型的颜色为绿色 
            local iconType = ResMgr.getResType(item.item_type) 
            local infoData  

            if iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then 
                if item.item_type == 7 and item.item_id <= 50 then 
                    color = "#4eff00"
                else
                    color = ResMgr.getItemNameColorHex(item.item_id) 
                end 
                infoData = data_item_item[item.item_id] 

            elseif iconType == ResMgr.HERO then 
                color = ResMgr.getHeroNameColorHexByClass(item.item_id, 1) 
                infoData = ResMgr.getCardData(item.item_id) 
            end 

            if mailId == 5 then 
                name = tostring(infoData.name) 
            else
                name = tostring(infoData.name) .. tostring(item.item_num) 
            end 

        elseif item.paraType == 2 then 
            -- 人物名，根据阶数定颜色 
            color = ResMgr.getHeroNameColorHexByClass(1, item.cls) 
            name = item.str 

        elseif item.paraType == 3 then 
            -- 数值日期等 
            name = item.str 
        end 
        
        if item.paraType == 1 or item.paraType == 2 then 
            str = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"" .. tostring(color)  .. "\">" .. tostring(name) .. "</font>"
        elseif item.paraType == 3 then 
            str = name 
        end 
    end 

    -- dump(str) 

    return str 
 end 


 function MailScene:getRichHtmlTextByItemData(item, mailData) 
    local itemRichText 
    local paras = item.paras 
    local htmlText = mailData.content 

    local paraList = {} 
    for i, v in ipairs(paras) do 
        local str = self:getStrColorAndFont(v, mailData.id) 
        table.insert(paraList, str) 
    end 

    local paraNum = #paraList 

    if paraNum == 1 then 
        htmlText = string.format(htmlText, paraList[1]) 
    elseif paraNum == 2 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2])  
    elseif paraNum == 3 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3])  
    elseif paraNum == 4 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4])  
    elseif paraNum == 5 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5])  
    elseif paraNum == 6 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6]) 
    elseif paraNum == 7 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6], paraList[7]) 
    elseif paraNum == 8 then 
        htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6], paraList[7], paraList[8]) 
    end 

    return htmlText 
 end 


 function MailScene:initMailData(rtnObj) 
    -- dump(rtnObj) 
    for i, v in ipairs(rtnObj) do  
        local mailData = self:getDataByTypeAndId(v.type, v.strId) 
        if mailData == nil then 
            ResMgr.showAlert(mailData, "服务器端返回的mail数据有问题，在mial表里找不到，type: " .. v.type .. ", id: " .. v.strId) 
        else 
            local richHtmlText = self:getRichHtmlTextByItemData(v, mailData) 
            table.insert(self._itemDatas, {
                title = mailData.title, 
                battleType = mailData.battleType, 
                disDay = DayStr[v.disDay + 1] or "",   
                richHtmlText = richHtmlText 
                })

            if i == #rtnObj then 
                self._curMailId = v.mailId   
            end 
        end 
    end 

 end 


 function MailScene:reloadListView(viewType, lastPosIndex) 

    if self._listViewTable ~= nil then 
        self._listViewTable:removeFromParentAndCleanup(true)
        self._listViewTable = nil
    end 

    -- 需要判断是否需要显示 更多邮件 
    local isCanShowMoreBtn = false 
    local tableNum = #self._itemDatas 
    if #self._itemDatas < self._mailTotalNum then 
        isCanShowMoreBtn = true 
        tableNum = tableNum + 1 
    end 

    local viewSize = self._rootnode["listView"]:getContentSize() 

    -- 创建 
    local function createFunc(index)
        local item 
        if viewType == SHOWTYPE.BATTLE then 
            item = require("game.Mail.MailBattleItem").new() 
        elseif viewType == SHOWTYPE.SYSTEM then 
            item = require("game.Mail.MailSystemItem").new()
        end 

        local itemData 
        if isCanShowMoreBtn == false or (index + 1) <= #self._itemDatas then 
            itemData = self._itemDatas[index + 1] 
        end 
        
        return item:create({
                id = index + 1, 
                itemData = itemData, 
                viewSize = viewSize, 
                totalNum = self._mailTotalNum, 
                curMailNum = tableNum, 
                isCanShowMoreBtn = isCanShowMoreBtn 
            })
    end

    -- 刷新 
    local function refreshFunc(cell, index) 
        local itemData 
        if isCanShowMoreBtn == false or (index + 1) <= #self._itemDatas then 
            itemData = self._itemDatas[index + 1] 
        end 

        cell:refresh({
            id = index + 1,  
            itemData = itemData 
            })
    end 

    local cellContentSize = require("game.Mail.MailBattleItem").new():getContentSize()

    self._listViewTable = require("utility.TableViewExt").new({
        size        = viewSize, 
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = tableNum, 
        cellSize    = cellContentSize, 
        touchFunc   = function(cell)
            local idx = cell:getIdx() + 1 
            if isCanShowMoreBtn == true and idx == tableNum then 
                if #self._itemDatas < self._mailTotalNum then 
                    self:reqMailData(viewType, true, self._curMailId) 
                else 
                    show_tip_label(data_error_error[2600001].prompt) 
                end 
            end 
        end
    })

    self._rootnode["listView"]:addChild(self._listViewTable) 

    -- 新请求到得item置顶显示
    local pageCount = (self._listViewTable:getViewSize().height) / cellContentSize.height  -- 当前每页显示的个数 
    if lastPosIndex + 1 > pageCount then 
        local maxMove = tableNum - pageCount   
        if maxMove < 0 then maxMove = 0 end 
        if lastPosIndex > maxMove then lastPosIndex = maxMove end 
        local curIndex = maxMove - lastPosIndex 

        self._listViewTable:setContentOffset(CCPoint(0, -(curIndex * cellContentSize.height))) 
    end 

 end 


 return MailScene 
