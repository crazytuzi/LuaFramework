--实名认证小面板
realnameSmallDialog = smallDialog:new()

function realnameSmallDialog:new()
    local nc = {}
    nc.name = ""
    nc.id = ""
    setmetatable(nc, self)
    self.__index = self
    self.dialogHeight = 650
    self.dialogWidth = 550
    return nc
end

--param layerNum: 显示层次
function realnameSmallDialog:init(layerNum, closeFlag)
    self.layerNum = layerNum    
    local function nilFunc()
    end
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local size = CCSizeMake(self.dialogWidth, self.dialogHeight)
    local dialogBg = G_getNewDialogBg(size, getlocal("registRealName"), 33, nil, self.layerNum, closeFlag or false, close)
    LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png", CCRect(168, 86, 10, 10), nilFunc)
    self.dialogLayer = CCLayer:create()
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(size)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2);
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true);
    
    --遮罩层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), nilFunc);
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    sceneGame:addChild(self.dialogLayer, layerNum)
    
    local posY = self.dialogHeight - 76
    local lb1 = GetTTFLabel("请填写身份信息", 28)
    lb1:setColor(G_ColorYellowPro)
    lb1:setAnchorPoint(ccp(0, 1))
    lb1:setPosition(30, posY)
    self.bgLayer:addChild(lb1)
    
    posY = posY - lb1:getContentSize().height - 10
    local lb2 = GetTTFLabel(getlocal("RankScene_name") .. ":", 25)
    lb2:setAnchorPoint(ccp(0, 0.5))
    lb2:setPosition(50, posY - lb2:getContentSize().height / 2)
    self.bgLayer:addChild(lb2)
    local lb3 = GetTTFLabel("请填写真实姓名", 25)
    lb3:setColor(G_ColorRed)
    lb3:setAnchorPoint(ccp(0, 0.5))
    lb3:setPosition(50 + lb2:getContentSize().width + 10, posY - lb3:getContentSize().height / 2)
    self.bgLayer:addChild(lb3)
    
    local boxHeight = 60
    posY = posY - lb3:getContentSize().height - boxHeight / 2 - 10
    
    local function inputNameCallback(fn, eB, str, type)
        self.name = str
    end
    
    local nameBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png", CCRect(10, 10, 5, 5), nilFunc)
    nameBoxBg:setContentSize(CCSize(self.dialogWidth - 100, boxHeight))
    nameBoxBg:setPosition(ccp(self.dialogWidth / 2, posY))
    self.bgLayer:addChild(nameBoxBg)
    local nameLb = GetTTFLabel("", 30)
    nameLb:setAnchorPoint(ccp(0, 0.5))
    nameLb:setPosition(ccp(10, nameBoxBg:getContentSize().height / 2))
    local nameEditBox = customEditBox:new()
    nameEditBox:init(nameBoxBg, nameLb, "inputNameBg.png", nil, -(self.layerNum - 1) * 20 - 2, 20, inputNameCallback, nil, nil)
    
    posY = posY - boxHeight / 2 - 10
    local lb4 = GetTTFLabel("身份证号码:", 25)
    lb4:setAnchorPoint(ccp(0, 0.5))
    lb4:setPosition(50, posY - lb4:getContentSize().height / 2)
    self.bgLayer:addChild(lb4)
    local lb5 = GetTTFLabel("请填写真实身份证号码", 25)
    lb5:setColor(G_ColorRed)
    lb5:setAnchorPoint(ccp(0, 0.5))
    lb5:setPosition(50 + lb4:getContentSize().width + 10, posY - lb5:getContentSize().height / 2)
    self.bgLayer:addChild(lb5)
    
    posY = posY - lb5:getContentSize().height - boxHeight / 2 - 10
    local function inputIDCallback(fn, eB, str, type)
        self.id = str    
    end
    local idBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png", CCRect(10, 10, 5, 5), nilFunc)
    idBoxBg:setContentSize(CCSize(self.dialogWidth - 100, boxHeight))
    idBoxBg:setPosition(ccp(self.dialogWidth / 2, posY))
    self.bgLayer:addChild(idBoxBg)
    local idLb = GetTTFLabel("", 30)
    idLb:setAnchorPoint(ccp(0, 0.5))
    idLb:setPosition(ccp(10, idBoxBg:getContentSize().height / 2))
    local idEditBox = customEditBox:new()
    idEditBox:init(idBoxBg, idLb, "inputNameBg.png", nil, -(self.layerNum - 1) * 20 - 2, 20, inputIDCallback, nil, nil)
    
    posY = posY - boxHeight / 2 - 10
    local str = "根据文化部《网络游戏管理暂行办法》规定，网络游戏用户需要使用有效证件进行实名认证，才可正常游戏。\n同时为保护未成年人身心健康，身份信息验证未满18周岁的用户将受到防沉迷系统的限制。\n防沉迷系统具体规则请点击右上角按钮查看"
    local descLb = GetTTFLabelWrap(str, 22, CCSizeMake(self.dialogWidth - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0, 1))
    descLb:setPosition(50, posY)
    self.bgLayer:addChild(descLb)
    
    local function onConfirm()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:confirm()
    end
    local confirmIten = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onConfirm, 2, getlocal("confirm"), 24 / 0.8)
    confirmIten:setScale(0.8)
    local confirmBtn = CCMenu:createWithItem(confirmIten)
    confirmBtn:setPosition(self.dialogWidth / 2, 50)
    confirmBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(confirmBtn)
    
    --显示防沉迷规则
    local function showHealthyRules()
        local ruleTb = {
            "1、未满18周岁的用户每日22时至次日8时无法正常游戏，节假日每日累计在线时长不超过3小时，其它时间不超过1.5小时；",
            "2、未满8周岁用户不能使用充值服务；",
            "3、8周岁以上不满16周岁的用户单次充值金额不得超过50元，每月充值累计总金额不得超过200元；",
            "4、16周岁以上不满18周岁的用户单次充值金额不得超过100元，每月充值累计总金额不得超过400元；",
            "5、游客体验用户不能使用充值服务，每日累计在线时长不得超过1小时；",
            "6、未成年玩家每日累计时间超时后将无法进行游戏，请注意游戏时间，提前做好资源和部队的规划，以免受到损失。由超时等原因导致的各种损失无法进行补偿。",
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(layerNum, true, true, nil, "防沉迷系统规则", ruleTb, nil, 25)
    end
    G_addMenuInfo(self.bgLayer, self.layerNum, ccp(self.dialogWidth - 60, self.dialogHeight - 76 - 30), nil, nil, 0.8, nil, showHealthyRules, true)
end

function realnameSmallDialog:confirm()
    if verifyApi:checkName(self.name) == false then
        G_showTipsDialog("姓名有误，请您重新输入!")
        do return end
    end
    if verifyApi:checkIDCard(self.id) == false then
        G_showTipsDialog("身份证信息有误，请您重新输入!")
        do return end
    end
    --实名认证
    local function verifyCallback()
        self:close()
    end
    verifyApi:userVerify(self.name, self.id, verifyCallback)
    do return end
    --下面是原先的实名接口
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            playerVoApi.realNameRegist = true
            local function onConfirm()
                self:close()
            end
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), "恭喜您，认证成功！", nil, self.layerNum + 1, nil, onConfirm)
        end
    end
    socketHelper:realnameRegist(self.name, self.id, onRequestEnd)
end

--验证城市
function realnameSmallDialog:checkArea(area)
    local num1 = tonumber(string.sub(area, 1, 2))
    local num2 = tonumber(string.sub(area, 3, 4))
    local num3 = tonumber(string.sub(area, 5, 6))
    if num1 > 10 and num1 < 66 then -- 省市
        return true
    end
    return false
end

--验证出生年月
function realnameSmallDialog:checkDate(date)
    local date1, date2, date3, statusY, nowY
    local len = string.len(date)
    if len == 6 then
        date1 = tonumber(string.sub(date, 1, 2))
        date2 = tonumber(string.sub(date, 3, 4))
        date3 = tonumber(string.sub(date, 5, 6))
        statusY = self:checkY("19", date1)
    else
        date1 = tonumber(string.sub(date, 1, 4))
        date2 = tonumber(string.sub(date, 5, 6))
        date3 = tonumber(string.sub(date, 7, 8))
        nowY = self:getYearMonthData(base.serverTime)
        if date1 > 1900 and date1 <= nowY then
            statusY = self:checkY(date1)
        else
            return false
        end
    end
    if date2 > 0 and date2 < 13 then
        if date2 == 2 then
            if statusY then -- 闰年
                if date3 > 0 and date3 < 30 then
                    return true
                else
                    return false
                end
            else -- 平年
                if date3 > 0 and date3 < 29 then
                    return true
                else
                    return false
                end
            end
        else
            local maxDateNum = self:getDateNum(date2)
            if date3 > 0 and date3 <= maxDateNum then
                return true
            else
                return false
            end
        end
    end
    return false
end

-- 验证平年润年，参数年份,返回 true为润年  false为平年
function realnameSmallDialog:checkY(y)
    local year = tonumber(y)
    if year % 100 == 0 then
        if year % 400 == 0 then
            return true
        else
            return false
        end
    elseif year % 4 == 0 then
        return true
    end
    return false
end

function realnameSmallDialog:getYearMonthData(ts)
    --获得time时间table，有year,month,day,hour,min,sec等元素。
    local tab = os.date("*t", ts)
    return tab.year
end

--当月天数 参数月份（不包括2月）  返回天数
function realnameSmallDialog:getDateNum(month)
    if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12 then
        return 31
    elseif month ~= 2 then
        return 30
    end
    return 0
end

function realnameSmallDialog:checkEnd(endNum, id)
    if(string.len(id) == 15)then
        return true
    end
    local checkHou = {1, 0, "x", 9, 8, 7, 6, 5, 4, 3, 2}
    local checkGu = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}
    local sum = 0
    for i = 1, SizeOfTable(checkGu) do
        sum = sum + tonumber(checkGu[i]) * tonumber(string.sub(id, i, i))
    end
    
    local checkHouParameter = sum % 11 + 1
    if(checkHou[checkHouParameter] == "x" and (endNum == "x" or endNum == "X"))then
        return true
    elseif checkHou[checkHouParameter] ~= tonumber(endNum) then
        return false
    end
    return true
end

function realnameSmallDialog:dispose()
    self.name, self.id = nil, nil
end
