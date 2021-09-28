
require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.xiake.cselfchuangong"

SelfChuanGong = {
    
    s_nCGPropsCount = 5,
    m_exp = -1,
    m_xkkey = -1,
    m_xkTotalProps = nil,
    
    --for star effects
    s_nTimeEachStarEff = 200,
    m_bShowStarEff = false,
    m_timeStarEff = 0,
    m_xkTotalPropsLast = nil,
    m_arrNumCurStarEff = {},
    m_arrNumNeedStarEff = {},
}

setmetatable(SelfChuanGong, Dialog)
SelfChuanGong.__index = SelfChuanGong

local _instance

function SelfChuanGong.getInstance()
    print("____SelfChuanGong.getInstance")
    
	if not _instance then
		_instance = SelfChuanGong:new()
		_instance:OnCreate()
	end

	return _instance
end

function SelfChuanGong.peekInstance()
	return _instance
end

function SelfChuanGong:SetVisible(bV)
    LogInfo("____SelfChuanGong:SetVisible")
    
	if bV == self.m_pMainFrame:isVisible() then
        return
    end

	self.m_pMainFrame:setVisible(bV)

	if bV then
        
	else
	end
end

function SelfChuanGong.GetLayoutFileName()
	return "inheritall.layout"
end

function SelfChuanGong.GetAndShow()
    LogInfo("____SelfChuanGong.GetAndShow")
    
    local myXiake = MyXiake_xiake.peekInstance()
	if myXiake ~= nil then
		myXiake.m_pMainFrame:setVisible(false)
	end

	local scg = SelfChuanGong.getInstance()

	if scg ~= nil then
		scg.m_pMainFrame:setVisible(true)
        scg:ClearDisplay()
	end
    
    return scg
end

function SelfChuanGong.IsVisible()
    
    print("____SelfChuanGong.IsVisible")

	local scg = SelfChuanGong.peekInstance()
	if scg == nil then
        return false
    end

	return scg.m_pMainFrame:isVisible()
end

function SelfChuanGong.DestroyDialog()
    LogInfo("____SelfChuanGong.DestroyDialog")
	
    if _instance then
		_instance:ClearDisplay()
        _instance:OnClose()
		_instance = nil
	end
    
    local myXiake = MyXiake_xiake.peekInstance()
	if myXiake ~= nil then
		--myXiake:RefreshMyXiakes()
		--myXiake:RefreshCurrentXiake(myXiake.m_XiakeData)
        myXiake.m_pMainFrame:setVisible(true)
	end
end

function SelfChuanGong.DeleteDialog()
    LogInfo("____SelfChuanGong.DeleteDialog")
    
    if _instance then
		_instance:ClearDisplay()
        _instance:OnClose()
		_instance = nil
	end
end

function SelfChuanGong:new()
    print("____SelfChuanGong:new")

	local scg = {}
	scg = Dialog:new()
	setmetatable(scg, SelfChuanGong)
	return scg
end

function SelfChuanGong:OnCreate()
    LogInfo("____Enter SelfChuanGong:OnCreate")

	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.m_arrPart = {}
    self.m_arrREdBoxStar = {}
    self.m_arrTxtPropStarName = {}
    self.m_arrTxtPropName = {}
    self.m_arrTxtPropNow = {}
    self.m_arrTxtArrow = {}
    self.m_arrTxtPropNext = {}
    self.m_arrTxtPropExpHave = {}
    self.m_arrTxtPropExpSym = {}
    self.m_arrTxtPropExpNeed = {}
    self.m_arrBtnUpdate = {}
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrPart[i] = winMgr:getWindow("inheritall/ditu" .. i)
        self.m_arrREdBoxStar[i] = CEGUI.Window.toRichEditbox(winMgr:getWindow("inheritall/ditu" .. i .. "/xingxing"))
        self.m_arrTxtPropStarName[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title")
        self.m_arrTxtPropName[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title1")
        self.m_arrTxtPropNow[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title3")
        self.m_arrTxtArrow[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title4")
        self.m_arrTxtPropNext[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title6")
        self.m_arrTxtPropExpHave[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title8")
        self.m_arrTxtPropExpSym[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title7")
        self.m_arrTxtPropExpNeed[i] = winMgr:getWindow("inheritall/ditu" .. i .. "/title5")
        self.m_arrBtnUpdate[i] = CEGUI.Window.toPushButton(winMgr:getWindow("inheritall/ditu" .. i .. "/ok"))
        self.m_arrBtnUpdate[i]:setID(i)
        self.m_arrBtnUpdate[i]:subscribeEvent("Clicked", SelfChuanGong.HandleClickUpdateBtn, self)
    end
    self:GetWindow():subscribeEvent("WindowUpdate", SelfChuanGong.HandleWindowUpdate, self)

    self:ClearDisplay()
	LogInfo("____Exit SelfChuanGong:OnCreate")
end

function SelfChuanGong:ClearDisplay()
    LogInfo("____SelfChuanGong:ClearDisplay")
    
    self.m_exp = -1
    self.m_xkkey = -1
    self.m_xkTotalProps = nil
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrPart[i]:setVisible(false)
    end
    
    self:CloseEffectState()
end

function SelfChuanGong:AddStarEffect(indexProp)
    if indexProp < 1 or indexProp > self.s_nCGPropsCount then
        print("____error indexProp, out of range")
        return false
    end
    if not self.m_arrNumCurStarEff[indexProp] or not self.m_arrNumCurStarEff[indexProp] then
        print("____error curStarNum")
        return false
    end
    if self.m_arrNumCurStarEff[indexProp] < 1 or self.m_arrNumCurStarEff[indexProp] > 6 then
        print("____error curStarNum out of range")
        return false
    end

    local startpos = 16
	local starsize = 24
	local offset = startpos + (self.m_arrNumCurStarEff[indexProp] - 1) * starsize 
	GetGameUIManager():AddUIEffect(self.m_arrREdBoxStar[indexProp], MHSD_UTILS.get_effectpath(10390), false, offset, 16)
    
    return true
end

function SelfChuanGong:HandleWindowUpdate(eventArgs)
    
    if not self.m_bShowStarEff then
        return true
    end
    
    if not self.m_arrNumCurStarEff or not self.m_arrNumNeedStarEff then
        print("____error not curNum or needNum")
        return true
    end
    
    if not self.m_xkTotalProps then
        print("____error not self.m_xkTotalProps")
        return true
    end

    self.m_timeStarEff = self.m_timeStarEff + CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame*1000
    
    local bShowStarEff = false
    local timeResult = self.m_timeStarEff
    for i = 1, self.s_nCGPropsCount, 1 do
        local curProp = self.m_xkTotalProps[i]
        
        if not curProp or not self.m_arrNumCurStarEff[i] or not self.m_arrNumNeedStarEff[i] then
            print("____error not curProp or curNum or needNum")
        elseif self.m_arrNumCurStarEff[i] >= self.m_arrNumNeedStarEff[i] then
        elseif curProp.color < 1 or curProp.color > 7 then
            print("____error color, index: " .. i)
        else
            self.m_arrREdBoxStar[i]:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
            
            local timeStarEff = self.m_timeStarEff 
            while timeStarEff >= self.s_nTimeEachStarEff do
                self.m_arrNumCurStarEff[i] = self.m_arrNumCurStarEff[i] + 1
                timeStarEff = timeStarEff - self.s_nTimeEachStarEff
                
                self:AddStarEffect(i)
                
                if self.m_arrNumCurStarEff[i] >= self.m_arrNumNeedStarEff[i] then
                    break
                end
            end
            timeResult = timeStarEff
            
            self.m_arrREdBoxStar[i]:Clear()
            if self.m_arrNumCurStarEff[i] > curProp.star then
                print("____error curNum > star")
            end
            for j = 1, 6, 1 do
                if j <= curProp.star then
                    if j <= self.m_arrNumCurStarEff[i] then
                        self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color)
                    else
                        self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color-1)
                    end
                else
                    self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color-1)
                end
            end
            self.m_arrREdBoxStar[i]:Refresh() 
        end
        
        if self.m_arrNumCurStarEff[i] and self.m_arrNumNeedStarEff[i] and self.m_arrNumCurStarEff[i] < self.m_arrNumNeedStarEff[i] then
            bShowStarEff = true
        end
    end
    
    self.m_bShowStarEff = bShowStarEff
    self.m_timeStarEff = timeResult
    
    if not self.m_bShowStarEff then
        self:CloseEffectState()
    end
    
    return true
end

function SelfChuanGong:HandleClickUpdateBtn(args)
    LogInfo("____SelfChuanGong:HandleClickUpdateBtn")
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        GetGameUIManager():AddMessageTipById(144879)
        return true
    end
    
    local idClicked = -1
    local WindowArgs = CEGUI.toWindowEventArgs(args)
	local wndClick = WindowArgs.window
    if wndClick then
        idClicked = wndClick:getID()
    end
    print("____idClicked: " .. idClicked)

    if idClicked >= 1 and idClicked <= self.s_nCGPropsCount and self.m_xkTotalProps and self.m_xkTotalProps[idClicked] then
        local selfCGAction = CSelfChuangong.Create()
        selfCGAction.xiakekey = self.m_xkkey
        selfCGAction.prop = self.m_xkTotalProps[idClicked].type
        LuaProtocolManager.getInstance():send(selfCGAction)
    else
        LogInfo("___click error id")
    end

    return true
end

function SelfChuanGong.GetPropNameFromType(type)
    print("____SelfChuanGong.GetPropNameFromType")
    
    local namePro = ""
    if type == 1 then
        namePro = MHSD_UTILS.get_resstring(2972)
    elseif type == 2 then
        namePro = MHSD_UTILS.get_resstring(2973)
    elseif type == 3 then
        namePro = MHSD_UTILS.get_resstring(2974)
    elseif type == 4 then
        namePro = MHSD_UTILS.get_resstring(2975)
    elseif type == 5 then
        namePro = MHSD_UTILS.get_resstring(2976)
    elseif type == 6 then
        namePro = MHSD_UTILS.get_resstring(2977)
    else
    end
    
    return namePro
end

function SelfChuanGong.GetTotalPropValueFromIDAndType(idRecord, type)
    LogInfo("____SelfChuanGong.GetTotalPropValueFromIDAndType")
    
    if idRecord < 1 or idRecord > 42 then
        return 0
    end
    
    local result = 0
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakenenglixingji")
    for i = 1, idRecord, 1 do
        local record = tt:getRecorder(i)
        if record and record.id > 0 then
            local valueCur = SelfChuanGong.GetPropValueFromRecordAndType(record, type)
            result = result + valueCur
        end
    end
    
    return result
end

function SelfChuanGong.GetPropValueFromRecordAndType(record, type)
    print("____SelfChuanGong.GetPropValueFromRecordAndType")
    
    local valuePro = "0@0"
    if not record then
    elseif type == 1 then
        valuePro = record.shengming
    elseif type == 2 then
        valuePro = record.waigong
    elseif type == 3 then
        valuePro = record.neigong
    elseif type == 4 then
        valuePro = record.waifang
    elseif type == 5 then
        valuePro = record.neifang
    elseif type == 6 then
        valuePro = record.sudu
    else
    end
    
    local first,second = string.match(valuePro, "(%d+)@(%d+)")
    local result = 0
    if second then
        result = tonumber(second)
    else
        print("____error not second")
    end
    print("____result: " .. result)

    return result
end

function SelfChuanGong:CloseEffectState()
    LogInfo("____SelfChuanGong:CloseEffectState")
    
    self.m_bShowStarEff = false
    self.m_timeStarEff = 0
    self.m_arrNumCurStarEff = {}
    self.m_arrNumNeedStarEff = {}
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrNumCurStarEff[i] = 0
        self.m_arrNumNeedStarEff[i] = 0
        self.m_arrBtnUpdate[i]:setEnabled(true)
    end
end

function SelfChuanGong:SetEffectState(bSendResult)
    LogInfo("____SelfChuanGong:SetEffectState")
    
    self:CloseEffectState()

    if bSendResult then
        print("____send result")
        
        local bChange = false
        if self.m_xkTotalPropsLast and self.m_xkTotalProps then
            for i = 1, self.s_nCGPropsCount, 1 do
                local propLast = self.m_xkTotalPropsLast[i]
                local prop = self.m_xkTotalProps[i]
                local bCurChange = false
                
                print("____i: " .. i)
                
                if propLast and prop and propLast.type == prop.type then
                    print("____propLast.color: " .. propLast.color .. " propLast.star: " .. propLast.star)
                    print("____prop.color: " .. prop.color .. " prop.star: " .. prop.star)
                    
                    if prop.color > 0 then
                        if propLast.color ~= prop.color then
                            bCurChange = true
                        elseif propLast.star ~= prop.star then
                            bCurChange = true
                        end
                    end
                end
                
                if bCurChange then
                    bChange = true
                    self.m_arrNumNeedStarEff[i] = prop.star
                end
            end
        end
        
        if bChange then
            self.m_bShowStarEff = true
            for i = 1, self.s_nCGPropsCount, 1 do
                self.m_arrBtnUpdate[i]:setEnabled(false)
            end
        end
    else
        print("____not send result")
    end
    
    self.m_xkTotalPropsLast = self.m_xkTotalProps
end

function SelfChuanGong:SetContent(xiakekey, xiakeprops, exp, bSendResult)
    LogInfo("____SelfChuanGong:SetContent")
    
    self:ClearDisplay()
    
    print("____exp: " .. exp .. " xiakekey: " .. xiakekey)
    
    self.m_exp = exp
    self.m_xkkey = xiakekey
    self.m_xkTotalProps = {}
    
    if not xiakeprops or not xiakeprops.props then
        print("____error invalid xiakeprops")
        return
    end

    for k,v in pairs(xiakeprops.props) do
        print("____k: " .. k)
        if k == 1 then
            self.m_xkTotalProps[1] = v
            self.m_xkTotalProps[1].type = k
            self.m_xkTotalProps[1].name = SelfChuanGong.GetPropNameFromType(k)
        elseif k == 2 or k == 3 then
            self.m_xkTotalProps[2] = v
            self.m_xkTotalProps[2].type = k
            self.m_xkTotalProps[2].name = SelfChuanGong.GetPropNameFromType(k)
        elseif k >= 4 and k <= 6 then
            self.m_xkTotalProps[k-1] = v
            self.m_xkTotalProps[k-1].type = k
            self.m_xkTotalProps[k-1].name = SelfChuanGong.GetPropNameFromType(k)
        else
        end
    end
    
    self:SetEffectState(bSendResult)

    for i = 1, self.s_nCGPropsCount, 1 do
        if self.m_xkTotalProps[i] then
            local curProp = self.m_xkTotalProps[i]
            self.m_arrPart[i]:setVisible(true)
            
            print("____i: " .. i)
            print("____curProp.color: " .. curProp.color)
            print("____curProp.star: " .. curProp.star)

            --star
            self.m_arrREdBoxStar[i]:Clear()
            self.m_arrREdBoxStar[i]:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
            if curProp.color == 0 then
                for j = 1, 6, 1 do
                    self.m_arrREdBoxStar[i]:AppendEmotion(150)
                end
            elseif curProp.color >= 1 and curProp.color <= 7 then
                if not self.m_bShowStarEff or self.m_arrNumCurStarEff[i] >= self.m_arrNumNeedStarEff[i] then
                    for j = 1, 6, 1 do
                        if j <= curProp.star then
                            self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color)
                        else
                            self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color-1)
                        end
                    end
                else
                    for j = 1, 6, 1 do
                        self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color-1)
                    end
                end
            else
                LogInfo("____error color, index: " .. i)
            end
            self.m_arrREdBoxStar[i]:Refresh()
            
            --property name
            self.m_arrTxtPropStarName[i]:setText(curProp.name .. MHSD_UTILS.get_resstring(2978))
            self.m_arrTxtPropName[i]:setText(curProp.name .. MHSD_UTILS.get_resstring(2979))
            
            --property upgrade des
            local idRecord = -1
            local idRecordNext = -1
            if curProp.color == 0 then
                idRecord = 0
                idRecordNext = 1
            elseif curProp.color >= 1 and curProp.color <= 7 then
                idRecord = (curProp.color-1)*6 + curProp.star
                if idRecord >= 1 and idRecord < 42 then
                    idRecordNext = idRecord+1
                end
            end
            
            local valueNow = -1
            local valueNext = -1
            if idRecord >= 1 and idRecord <= 42 then
                valueNow = SelfChuanGong.GetTotalPropValueFromIDAndType(idRecord, curProp.type)
                self.m_arrTxtPropNow[i]:setText(tostring(valueNow))
            elseif idRecord == 0 then
                valueNow = 0
                self.m_arrTxtPropNow[i]:setText("0")
            else
                self.m_arrTxtPropNow[i]:setText("")
            end
            print("____valueNow: " .. valueNow)
            if idRecordNext >= 1 and idRecordNext <= 42 then
                valueNext = SelfChuanGong.GetTotalPropValueFromIDAndType(idRecordNext, curProp.type)
                if valueNow >= 0 and valueNext > valueNow then
                    self.m_arrTxtArrow[i]:setVisible(true)
                    self.m_arrTxtPropNext[i]:setText(tostring(valueNext) .. "(+" .. tostring(valueNext-valueNow) .. ")")
                else
                    self.m_arrTxtArrow[i]:setVisible(false)
                    self.m_arrTxtPropNext[i]:setText("")
                end
            else
                self.m_arrTxtArrow[i]:setVisible(false)
                self.m_arrTxtPropNext[i]:setText("")
            end
            print("____valueNext: " .. valueNext)
            
            --property exp des
            local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakenenglixingji")
            local recordNext = nil
            if idRecordNext > 0 then
                recordNext = tt:getRecorder(idRecordNext)
            end
            if recordNext and recordNext.id > 0 then
                self.m_arrTxtPropExpHave[i]:setText(tostring(self.m_exp))
                
                if self.m_exp >= recordNext.roleexp then
                    self.m_arrTxtPropExpHave[i]:setProperty("TextColours", "FF33FF33")
                else
                    self.m_arrTxtPropExpHave[i]:setProperty("TextColours", "FFFF3333")
                end

                self.m_arrTxtPropExpSym[i]:setText("/")
                self.m_arrTxtPropExpNeed[i]:setText(tostring(recordNext.roleexp))
            else
                self.m_arrTxtPropExpHave[i]:setText("")
                self.m_arrTxtPropExpSym[i]:setText("")
                self.m_arrTxtPropExpNeed[i]:setText("")
            end
        end
    end
end

return SelfChuanGong



