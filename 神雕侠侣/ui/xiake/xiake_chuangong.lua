
require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.xiake.cgetxklistchuangongprop"
require "protocoldef.knight.gsp.xiake.cxiakechuangong"
require "protocoldef.knight.gsp.xiake.coneoffxiakechuangong"
require "utils.mhsdutils"

XiakeChuanGong = {
    
    --for material xiakes
    m_selStateXiakeKeys = {},
    m_lCells = {},
    m_iMaxCells = 0,
    m_iMaxPage = 1,
	m_iCurPage = 1,
	m_iCellNum = 0,
    m_iOnePageCount = 8,
    m_iBarPos = 0,
    m_matXiakes = nil,
    m_eliteXKDes = nil,
    m_matXiakesProps = nil,

    --for selected material xiakes
    s_nCountSelMatDistrict = 3,
    m_arrSelResultXKKeys = {},

    --for main xiakes
    s_nCGPropsCount = 5,
    m_xkkey = -1,
    m_xkTotalProps = nil,
    m_indexSelProp = -1,
    m_arrPropExpChange = nil,
    
    --for star effects
    s_nTimeEachStarEff = 200,
    m_bShowStarEff = false,
    m_timeStarEff = 0,
    m_xkTotalPropsLast = nil,
    m_arrNumCurStarEff = {},
    m_arrNumNeedStarEff = {},
}

setmetatable(XiakeChuanGong, Dialog)
XiakeChuanGong.__index = XiakeChuanGong

local _instance

function XiakeChuanGong.getInstance()
    print("____XiakeChuanGong.getInstance")
    
	if not _instance then
		_instance = XiakeChuanGong:new()
		_instance:OnCreate()
	end

	return _instance
end

function XiakeChuanGong.peekInstance()
	return _instance
end

function XiakeChuanGong:SetVisible(bV)
    LogInfo("____XiakeChuanGong:SetVisible")
    
	if bV == self.m_pMainFrame:isVisible() then
        return
    end

	self.m_pMainFrame:setVisible(bV)

	if bV then
	else
	end
end

function XiakeChuanGong.GetLayoutFileName()
	return "inherit.layout"
end

function XiakeChuanGong.GetAndShow()
    LogInfo("____XiakeChuanGong.GetAndShow")
    
    local myXiake = MyXiake_xiake.peekInstance()
	if myXiake ~= nil then
		myXiake.m_pMainFrame:setVisible(false)
	end

	local xkcg = XiakeChuanGong.getInstance()
    
	if xkcg ~= nil then
		xkcg.m_pMainFrame:setVisible(true)
        xkcg:ClearDisplay()
	end
    
    return xkcg
end

function XiakeChuanGong.IsVisible()
    
    print("____XiakeChuanGong.IsVisible")

	local xkcg = XiakeChuanGong.peekInstance()
	if xkcg == nil then
        return false
    end

	return xkcg.m_pMainFrame:isVisible()
end

function XiakeChuanGong.DestroyDialog()
    LogInfo("____XiakeChuanGong.DestroyDialog")
	
    if _instance then
		_instance:ClearDisplay()
        _instance:OnClose()
		_instance = nil
	end
    
    local myXiake = MyXiake_xiake.peekInstance()
	if myXiake ~= nil then
        myXiake:RefreshMyXiakes()
		myXiake:RefreshCurrentXiake(myXiake.m_XiakeData)
		myXiake.m_pMainFrame:setVisible(true)
	end
end

function XiakeChuanGong.DeleteDialog()
    LogInfo("____XiakeChuanGong.DeleteDialog")
	
    if _instance then
		_instance:ClearDisplay()
        _instance:OnClose()
		_instance = nil
	end
end

function XiakeChuanGong:new()
    print("____XiakeChuanGong:new")

	local xkcg = {}
	xkcg = Dialog:new()
	setmetatable(xkcg, XiakeChuanGong)
	return xkcg
end

function XiakeChuanGong:OnCreate()
    LogInfo("____Enter XiakeChuanGong:OnCreate")

	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    --material xiakes list scrollable pane
    self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("inherit/main/scroll"))
	self.m_pPane:EnableHorzScrollBar(true)
    self.m_pPane:subscribeEvent("NextPage", XiakeChuanGong.HandleNextPage, self)
    
    self.m_arrWndPropPart = {}
    self.m_arrREdBoxStar = {}
    self.m_arrTxtPropName = {}
    self.m_arrWndPropLight = {}
    self.m_arrTxtPropExp = {}
    self.m_arrProgBarBlue = {}
    self.m_arrProgBarGreen = {}
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrWndPropPart[i] = winMgr:getWindow("inherit/top/ditu" .. i)
        self.m_arrWndPropPart[i]:setID(i)
        self.m_arrWndPropPart[i]:subscribeEvent("MouseClick", XiakeChuanGong.HandleClickPropPart, self)
        
        self.m_arrREdBoxStar[i] = CEGUI.Window.toRichEditbox(winMgr:getWindow("inherit/top/ditu/xingxing" .. i))
        self.m_arrTxtPropName[i] = winMgr:getWindow("inherit/top/txt" .. i)
        self.m_arrWndPropLight[i] = winMgr:getWindow("inherit/top/ditu/light" .. i)
        self.m_arrTxtPropExp[i] = winMgr:getWindow("inherit/top/num" .. i)
        self.m_arrProgBarBlue[i] = CEGUI.Window.toProgressBar(winMgr:getWindow("inherit/top/barture" .. i))
        self.m_arrProgBarGreen[i] = CEGUI.Window.toProgressBar(winMgr:getWindow("inherit/top/bar" .. i))
    end
    
    self.m_wndMXK = winMgr:getWindow("inherit/quack11")
    self.m_wndMXKEliteIcon = winMgr:getWindow("inherit/quack11/finish")
    self.m_wndMXKHead = winMgr:getWindow("inherit/icon11")
    self.m_txtMXKLevel = winMgr:getWindow("inherit/level11")
    self.m_wndMXKMark = winMgr:getWindow("inherit/mark11")
    self.m_txtMXKName = winMgr:getWindow("inherit/name11")
    
    self.m_txtPropNameNow = winMgr:getWindow("inherit/top/shuoming1")
    self.m_txtPropNameNext = winMgr:getWindow("inherit/top/shuoming12")
    self.m_txtPropValueNow = winMgr:getWindow("inherit/top/shuoming11")
    self.m_txtPropValueNext = winMgr:getWindow("inherit/top/shuoming111")
    
    self.m_txtSpendMoney = winMgr:getWindow("inherit/zhujue/yinliang/yinliangtxt")
    self.m_btnStart = CEGUI.Window.toPushButton(winMgr:getWindow("inherit/zhujue/ok"))
    self.m_btnStart:subscribeEvent("Clicked", XiakeChuanGong.HandleClickStartBtn, self)
    
    self.m_btnStartAll = CEGUI.Window.toPushButton(winMgr:getWindow("inherit/zhujue/okall"))
    self.m_btnStartAll:subscribeEvent("Clicked", XiakeChuanGong.HandleClickStartAllBtn, self)

    self.m_arrWndXKSelResult = {}
    self.m_arrWndXKSelResultEliteIcon = {}
    self.m_arrWndXKSelResultHead = {}
    self.m_arrTxtXKSelResultLevel = {}
    self.m_arrWndXKSelResultMark = {}
    self.m_arrTxtXKSelResultName = {}
    for i = 1, self.s_nCountSelMatDistrict, 1 do
        self.m_arrWndXKSelResult[i] = winMgr:getWindow("inherit/quack" .. i)
        self.m_arrWndXKSelResultEliteIcon[i] = winMgr:getWindow("inherit/quack/finish" .. i)
        
        self.m_arrWndXKSelResultHead[i] = winMgr:getWindow("inherit/icon" .. i)
        self.m_arrWndXKSelResultHead[i]:setID(i)
        self.m_arrWndXKSelResultHead[i]:subscribeEvent("MouseClick", XiakeChuanGong.HandleClickSelResultPart, self)
        
        self.m_arrTxtXKSelResultLevel[i] = winMgr:getWindow("inherit/level" .. i)
        self.m_arrWndXKSelResultMark[i] = winMgr:getWindow("inherit/mark" .. i)
        self.m_arrTxtXKSelResultName[i] = winMgr:getWindow("inherit/name" .. i)
    end
    
    self:GetWindow():subscribeEvent("WindowUpdate", XiakeChuanGong.HandleWindowUpdate, self)

    self:ClearDisplay()

	LogInfo("____Exit XiakeChuanGong:OnCreate")
end

function XiakeChuanGong:ClearDisplay()
    LogInfo("____XiakeChuanGong:ClearDisplay")
    
    self:CloseEffectState()
    self:ResetMatXKList()
    self:ResetSelResultList()
    self:ResetStarsProps()
    self:ResetMXKDestrict()
end

function XiakeChuanGong:AddStarEffect(indexProp)
    if indexProp < 1 or indexProp > self.s_nCGPropsCount then
        print("____error indexProp, out of range")
        return false
    end
    if not self.m_arrNumCurStarEff[indexProp]  then
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

function XiakeChuanGong:HandleWindowUpdate(eventArgs)
    
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

function XiakeChuanGong:ResetMatXKList()
    LogInfo("____XiakeChuanGong:ResetMatXKList")
    
    self.m_lCells = {}
    self.m_iMaxCells = 0
    self.m_iCurPage = 1
    self.m_iCellNum = 0
    self.m_iBarPos = 0
    self.m_pPane:cleanupNonAutoChildren()
    self.m_selStateXiakeKeys = {}
end

function XiakeChuanGong:DeleteSelResultByIndex(index)
    LogInfo("____XiakeChuanGong:DeleteSelResultByIndex")
    
    if index < 1 or index > self.s_nCountSelMatDistrict then
        print("____error index, out of range")
        return
    end
    
    if not self.m_arrSelResultXKKeys then
        print("____error not self.m_arrSelResultXKKeys")
        return
    end
    
    if not self.m_arrSelResultXKKeys[index] or not self.m_arrSelResultXKKeys[index].xkkey or not self.m_arrSelResultXKKeys[index].idcell then
        print("____error not self.m_arrSelResultXKKeys[index] or not xkkey or not idcell")
        return
    end
    
    if self.m_arrSelResultXKKeys[index].xkkey <= 0 or self.m_arrSelResultXKKeys[index].idcell <= 0 then
        print("____error xkkey <= 0 or idcell <= 0")
        return
    end
    
    local xkkey = self.m_arrSelResultXKKeys[index].xkkey
    local idcell = self.m_arrSelResultXKKeys[index].idcell
    
    if not self.m_selStateXiakeKeys[idcell] then
        print("____error not self.m_selStateXiakeKeys[idcell]")
        return
    end

    if xkkey ~= self.m_selStateXiakeKeys[idcell].xiakekey then
        print("____error xkkey not correspond")
        return
    end
    
    local winMgr = CEGUI.WindowManager:getSingleton()
    local lightWndName = tostring(idcell) .. "inherititem/quack0/selected"
    local lightWnd = winMgr:getWindow(lightWndName)
    if not lightWnd then
        print("____error not lightWnd")
        return
    end
    
    self.m_selStateXiakeKeys[idcell].bSelected = false
    lightWnd:setVisible(false)
    
    self.m_arrSelResultXKKeys[index] = nil
    self.m_arrWndXKSelResult[index]:setProperty("Image", XiakeMng.eXiakeFrames[3])
    self.m_arrWndXKSelResultEliteIcon[index]:setVisible(false)
    self.m_arrWndXKSelResultHead[index]:setVisible(false)
    self.m_arrTxtXKSelResultLevel[index]:setVisible(false)
    self.m_arrWndXKSelResultMark[index]:setVisible(false)
    self.m_arrTxtXKSelResultName[index]:setVisible(false)
    
    self:RefreshStarsProps()

    return
end

function XiakeChuanGong:SetSelResultContent(index, xkkey, idcell)
    LogInfo("____XiakeChuanGong:SetSelResultContent")
    
    if index < 1 or index > self.s_nCountSelMatDistrict then
        print("____error index, out of range")
        return
    end

    if xkkey <= 0 then
        print("____error xkkey")
        return
    end
    
    if idcell <= 0 then
        print("____error idcell")
        return
    end
    
    if not self.m_arrSelResultXKKeys then
        print("____not self.m_arrSelResultXKKeys")
        return
    end

    if not self.m_selStateXiakeKeys[idcell] then
        print("____error not self.m_selStateXiakeKeys[idcell]")
        return
    end
    
    if xkkey ~= self.m_selStateXiakeKeys[idcell].xiakekey then
        print("____error no correspond xkkey idcell")
        return
    end
    
    local winMgr = CEGUI.WindowManager:getSingleton()
    local lightWndName = tostring(idcell) .. "inherititem/quack0/selected"
    local lightWnd = winMgr:getWindow(lightWndName)
    if not lightWnd then
        print("____error not lightWnd")
        return
    end

    local vXiaKe = XiakeMng.GetXiakeFromKey(xkkey)
    if not vXiaKe then
        print("____error get no xiake from xkkey")
        return
    end
        
    self.m_selStateXiakeKeys[idcell].bSelected = true
    lightWnd:setVisible(true)

    local xkXiaKe = XiakeMng.ReadXiakeData(vXiaKe.xiakeid)
    self.m_arrSelResultXKKeys[index] = {}
    self.m_arrSelResultXKKeys[index].xkkey = xkkey
    self.m_arrSelResultXKKeys[index].idcell = idcell

    self.m_arrWndXKSelResult[index]:setProperty("Image", XiakeMng.eXiakeFrames[vXiaKe.color])
    self.m_arrWndXKSelResultHead[index]:setVisible(true)
    self.m_arrTxtXKSelResultLevel[index]:setVisible(true)
    self.m_arrWndXKSelResultMark[index]:setVisible(true)
    self.m_arrTxtXKSelResultName[index]:setVisible(true)
    
    if self.m_eliteXKDes and self.m_eliteXKDes[xkkey] and self.m_eliteXKDes[xkkey] == 1 then
        self.m_arrWndXKSelResultEliteIcon[index]:setVisible(true)
    else
        self.m_arrWndXKSelResultEliteIcon[index]:setVisible(false)
    end

    self.m_arrWndXKSelResultHead[index]:setProperty("Image", xkXiaKe.path)
    self.m_arrTxtXKSelResultLevel[index]:setText(tostring(GetDataManager():GetMainCharacterLevel()))
    self.m_arrWndXKSelResultMark[index]:setProperty("Image", XiakeMng.eLvImages[vXiaKe.starlv])
    self.m_arrTxtXKSelResultName[index]:setText(scene_util.GetPetNameColor(vXiaKe.color)..xkXiaKe.xkxx.name)
    
    self:RefreshStarsProps()

    return
end

function XiakeChuanGong:ResetSelResultList()
    LogInfo("____XiakeChuanGong:ResetSelResultList")

    self.m_arrSelResultXKKeys = {}
    
    for i = 1, self.s_nCountSelMatDistrict, 1 do
        self.m_arrWndXKSelResult[i]:setProperty("Image", XiakeMng.eXiakeFrames[3])
        self.m_arrWndXKSelResultEliteIcon[i]:setVisible(false)
        self.m_arrWndXKSelResultHead[i]:setVisible(false)
        self.m_arrTxtXKSelResultLevel[i]:setVisible(false)
        self.m_arrWndXKSelResultMark[i]:setVisible(false)
        self.m_arrTxtXKSelResultName[i]:setVisible(false)
    end
end

function XiakeChuanGong:ResetStarsProps()
    LogInfo("____XiakeChuanGong:ResetStarsProps")
    
    self.m_xkTotalProps = nil
    self.m_arrPropExpChange = nil
    
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrWndPropPart[i]:setVisible(false)
    end
end

function XiakeChuanGong:ResetMXKDestrict()
    LogInfo("____XiakeChuanGong:ResetMXKDestrict")
    
    self.m_xkkey = -1
    self.m_indexSelProp = -1

    self.m_wndMXKEliteIcon:setVisible(false)
    self.m_wndMXKHead:setVisible(false)
    self.m_txtMXKLevel:setVisible(false)
    self.m_wndMXKMark:setVisible(false)
    self.m_txtMXKName:setVisible(false)
    
    self.m_txtPropNameNow:setText("")
    self.m_txtPropNameNext:setText("")
    self.m_txtPropValueNow:setText("")
    self.m_txtPropValueNext:setText("")
    self.m_txtSpendMoney:setText("")
    self.m_btnStart:setEnabled(false)
end

function XiakeChuanGong:RefreshMXKDestrict()
    LogInfo("____XiakeChuanGong:RefreshMXKDestrict")
    
    self:RefreshMXKPictrue()
    self:RefreshMXKMainProp()
    self:RefreshMXKSpendMoney()
end

function XiakeChuanGong:RefreshMXKPictrue()
    LogInfo("____XiakeChuanGong:RefreshMXKPictrue")
    
    if self.m_xkkey <= 0 then
        print("____error self.m_xkkey <= 0")
        return
    end

    local vXiaKe = XiakeMng.GetXiakeFromKey(self.m_xkkey)
    if not vXiaKe then
        print("____error get no xiake from xkkey")
        return
    end
    
    local xkXiaKe = XiakeMng.ReadXiakeData(vXiaKe.xiakeid)
    
    self.m_wndMXK:setProperty("Image", XiakeMng.eXiakeFrames[vXiaKe.color])
    self.m_wndMXKHead:setVisible(true)
    self.m_txtMXKLevel:setVisible(true)
    self.m_wndMXKMark:setVisible(true)
    self.m_txtMXKName:setVisible(true)
    
    if self.m_xkTotalProps and self.m_xkTotalProps.elite and self.m_xkTotalProps.elite == 1 then
        self.m_wndMXKEliteIcon:setVisible(true)
    else
        self.m_wndMXKEliteIcon:setVisible(false)
    end

    self.m_wndMXKHead:setProperty("Image", xkXiaKe.path)
    self.m_txtMXKLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()))
    self.m_wndMXKMark:setProperty("Image", XiakeMng.eLvImages[vXiaKe.starlv])
    self.m_txtMXKName:setText(scene_util.GetPetNameColor(vXiaKe.color)..xkXiaKe.xkxx.name)
end

function XiakeChuanGong.GetUpdateResultRecordID(idRecord, curexp, addexp)
    LogInfo("____XiakeChuanGong:GetUpdateResultRecordID")
    
    if curexp < 0 then
        print("____error curexp < 0")
        curexp = 0
    end
    if addexp < 0 then
        print("____error addexp < 0")
        addexp = 0
    end

    local totalExp = 0
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakenenglixingji")
    if idRecord < 0 then
        print("____error idRecord < 0")
        totalExp = curexp + addexp
    elseif idRecord == 0 then
        totalExp = curexp + addexp
    elseif idRecord < 42 then
        local expThisRecord = 0
        for i = 1, idRecord, 1 do
            local record = tt:getRecorder(i)
            if record and record.id > 0 then
                expThisRecord = expThisRecord + record.scheduleexp
            else
                print("____error record")
                return idRecord
            end
        end
        totalExp = expThisRecord + curexp + addexp
    else
        return 42
    end

    local idRecordResult = -1
    local totalExpReg = 0
    for i = 1, 42, 1 do
        local record = tt:getRecorder(i)
        if record and record.id > 0 then
            totalExpReg = totalExpReg + record.scheduleexp
        else
            print("____error record")
            return idRecord
        end
        
        if totalExp < totalExpReg then
            idRecordResult = i-1
            break
        end
    end
    
    if idRecordResult < 0 then
        idRecordResult = 42
    end
    
    return idRecordResult
end

function XiakeChuanGong:RefreshMXKMainProp(idRecord, cur)
    LogInfo("____XiakeChuanGong:RefreshMXKMainProp")

    self.m_txtPropNameNow:setText("")
    self.m_txtPropNameNext:setText("")
    self.m_txtPropValueNow:setText("")
    self.m_txtPropValueNext:setText("")
    
    LogInfo("____self.m_xkkey: " .. self.m_xkkey)
    LogInfo("____self.m_indexSelProp: " .. self.m_indexSelProp)

    local bClear = false
    if self.m_xkkey <= 0 or self.m_indexSelProp <= 0 then
        print("____self.m_xkkey <= 0 or self.m_indexSelProp <= 0")
        bClear = true
    elseif self.m_indexSelProp > self.s_nCGPropsCount then
        print("____error self.m_indexSelProp > self.s_nCGPropsCount")
        return
    end
    
    local curProp = self.m_xkTotalProps[self.m_indexSelProp]
    if not curProp then
        print("____not curProp")
        bClear = true
    end
    
    if bClear then
        return
    end
    
    self.m_txtPropNameNow:setText(curProp.name)
    self.m_txtPropNameNext:setText(curProp.name)

    local idRecord = -1
    if curProp.color == 0 then
        idRecord = 0
    elseif curProp.color >= 1 and curProp.color <= 7 then
        idRecord = (curProp.color-1)*6 + curProp.star
    end
    
    local idRecordNext = idRecord
    if self.m_arrPropExpChange and self.m_arrPropExpChange[self.m_indexSelProp] 
        and self.m_arrPropExpChange[self.m_indexSelProp].curexp and self.m_arrPropExpChange[self.m_indexSelProp].addexp then
        local curexpReg = self.m_arrPropExpChange[self.m_indexSelProp].curexp
        local addexpReg = self.m_arrPropExpChange[self.m_indexSelProp].addexp
        idRecordNext = XiakeChuanGong.GetUpdateResultRecordID(idRecord, curexpReg, addexpReg)
    else
        print("____error self.m_arrPropExpChange")
    end
    
    local valueNow = -1
    local valueNext = -1
    if idRecord >= 1 and idRecord <= 42 then
        valueNow = SelfChuanGong.GetTotalPropValueFromIDAndType(idRecord, curProp.type)
        self.m_txtPropValueNow:setText(tostring(valueNow))
    elseif idRecord == 0 then
        valueNow = 0
        self.m_txtPropValueNow:setText("0")
    else
    end
    if idRecordNext >= 1 and idRecordNext <= 42 then
        valueNext = SelfChuanGong.GetTotalPropValueFromIDAndType(idRecordNext, curProp.type)
        if valueNext >= 0 then
            if valueNext > valueNow and valueNow >= 0 then
                self.m_txtPropValueNext:setText(tostring(valueNow) .. "+" .. tostring(valueNext-valueNow))
            else
                self.m_txtPropValueNext:setText(tostring(valueNext))
            end
        else
        end
    elseif valueNow >= 0 then
        self.m_txtPropValueNext:setText(tostring(valueNow))
    end
    print("____curProp.type: " .. curProp.type)
    print("____idRecord: " .. idRecord .. " idRecordNext: " .. idRecordNext)
    print("____valueNow: " .. valueNow .. " valueNext: " .. valueNext)
end

function XiakeChuanGong:RefreshMXKSpendMoney()
    LogInfo("____XiakeChuanGong:RefreshMXKSpendMoney")
    
    if not self.m_arrPropExpChange then
        print("____error not self.m_arrPropExpChange")
        return
    end
    
    local moneySpend = 0
    for i = 1, self.s_nCGPropsCount, 1 do
        local proChange = self.m_arrPropExpChange[i]
        if proChange and proChange.addexp then
            moneySpend = moneySpend + proChange.addexp
        end
    end
    
    if moneySpend > 0 then
        moneySpend = moneySpend * 1000
        self.m_btnStart:setEnabled(true)
    else
        self.m_btnStart:setEnabled(false)
    end
    
    self.m_txtSpendMoney:setText(tostring(moneySpend))
end

function XiakeChuanGong.GetJinDuTillThisLv(color, star, curexp)
    print("____XiakeChuanGong.GetJinDuTillThisLv")
    
    if color < 0 or color > 7 then
        print("____error color out of range")
        return 0
    end
    
    if star < 0 or star > 6 then
        print("____error star out of range")
        return 0
    end
    
    if curexp < 0 then
        print("____error curexp < 0")
        return 0
    end
    
    local jinduTotal = 0
    local indexMax = -1
    if color > 0 then
        indexMax = (color-1)*6 + star
    end
    
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakenenglixingji")
    for i = 1, indexMax, 1 do
        local record = tt:getRecorder(i)
        if record and record.id > 0 then
            jinduTotal = jinduTotal + record.scheduleexp
        else
            print("____error not record")
        end
    end
    
    jinduTotal = jinduTotal + curexp
    return jinduTotal
end

function XiakeChuanGong:RefreshPropsChangeExp()
    LogInfo("____XiakeChuanGong:RefreshPropsChangeExp")
    
    if not self.m_xkTotalProps then
        print("____error not self.m_xkTotalProps")
        return false
    end
    
    self.m_arrPropExpChange = {}
    
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakenenglixingji")
    local ttJDJY = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakejindujingyan")
    for i = 1, self.s_nCGPropsCount, 1 do
    
        local curProp = self.m_xkTotalProps[i]
        if not curProp then
            print("____error not curProp")
            return false
        else
            local idRecord = -1
            local idRecordNext = -1
            print("____curProp.color: " .. curProp.color)
            print("____curProp.star: " .. curProp.star)
            if curProp.color == 0 then
                idRecord = 0
                idRecordNext = 1
            elseif curProp.color >= 1 and curProp.color <= 7 then
                idRecord = (curProp.color-1)*6 + curProp.star
                if idRecord >= 1 and idRecord < 42 then
                    idRecordNext = idRecord + 1
                elseif idRecord >= 42 then
                    idRecord, idRecordNext = 42, 42
                end
            end
            
            local recordNext = nil
            if idRecordNext > 0 then
                recordNext = tt:getRecorder(idRecordNext)
            end
            
            if recordNext and recordNext.id > 0 then
                print("____recordNext.id: " .. recordNext.id)
            else
                print("____error recordNext")
                return false
            end
            
            self.m_arrPropExpChange[i] = {}
            
            if idRecord == 42 then
                self.m_arrPropExpChange[i].curexp = recordNext.scheduleexp
                self.m_arrPropExpChange[i].scheduleexp = recordNext.scheduleexp
            else
                self.m_arrPropExpChange[i].curexp = curProp.curexp
                self.m_arrPropExpChange[i].scheduleexp = recordNext.scheduleexp
            end

            local addexp = 0

            for j = 1, self.s_nCountSelMatDistrict, 1 do
                if self.m_arrSelResultXKKeys and self.m_arrSelResultXKKeys[j]
                    and self.m_arrSelResultXKKeys[j].xkkey and self.m_arrSelResultXKKeys[j].xkkey > 0 then
                    
                    local xkkeyCurSel = self.m_arrSelResultXKKeys[j].xkkey
                    local xkInfo = XiakeMng.GetXiakeFromKey(xkkeyCurSel)

                    local recordJDJY = nil
                    local addBase = 0
                    local indexBaseAdd = -1
                    if xkInfo then
                        recordJDJY = ttJDJY:getRecorder(xkInfo.xiakeid)
                        indexBaseAdd = (xkInfo.color-1)*3 + xkInfo.starlv - 1
                    else
                        print("____error not xkInfo")
                    end
                    
                    if indexBaseAdd >= 0 and recordJDJY and recordJDJY.addexp and recordJDJY.addexp[indexBaseAdd] then
                        addBase = recordJDJY.addexp[indexBaseAdd]
                    else
                        print("____error no record or base add info")
                    end

                    if self.m_eliteXKDes and self.m_eliteXKDes[xkkeyCurSel] then
                        if self.m_eliteXKDes[xkkeyCurSel] == 1 then
                            local addJYPro = 0
                            local jinduNowJY = 0
                            if self.m_matXiakesProps and self.m_matXiakesProps[xkkeyCurSel] and self.m_matXiakesProps[xkkeyCurSel].props then
                                local useType = curProp.type
                                if curProp.type == 2 then
                                    if not self.m_matXiakesProps[xkkeyCurSel].props[curProp.type] then
                                        useType = 3
                                    end
                                elseif curProp.type == 3 then
                                    if not self.m_matXiakesProps[xkkeyCurSel].props[curProp.type] then
                                        useType = 2
                                    end
                                end
                                if self.m_matXiakesProps[xkkeyCurSel].props[useType] then
                                    local curPropSelJY = self.m_matXiakesProps[xkkeyCurSel].props[useType]
                                    jinduNowJY = XiakeChuanGong.GetJinDuTillThisLv(curPropSelJY.color, curPropSelJY.star, curPropSelJY.curexp)
                                end
                            end

                            if self.m_indexSelProp == i then
                                addexp = addexp + addBase
                                addJYPro = math.floor(0.8*jinduNowJY)
                            else
                                addJYPro = math.floor(0.5*jinduNowJY)
                            end
                            addexp = addexp + addJYPro
                        else
                            if self.m_indexSelProp == i then
                                addexp = addexp + addBase
                            end 
                        end
                    end
                end
            end
            
            if idRecord == 42 then
                self.m_arrPropExpChange[i].addexp = 0
            elseif self.m_indexSelProp < 1 or self.m_indexSelProp > self.s_nCGPropsCount then
                self.m_arrPropExpChange[i].addexp = 0
            else
                self.m_arrPropExpChange[i].addexp = addexp
            end
        end
    end
    
    return true
end

function XiakeChuanGong:CloseEffectState()
    LogInfo("____XiakeChuanGong:CloseEffectState")
    
    self.m_bShowStarEff = false
    self.m_timeStarEff = 0
    self.m_arrNumCurStarEff = {}
    self.m_arrNumNeedStarEff = {}
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrNumCurStarEff[i] = 0
        self.m_arrNumNeedStarEff[i] = 0
    end
end

function XiakeChuanGong:SetEffectState(bSendResult)
    LogInfo("____XiakeChuanGong:SetEffectState")
    
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
        end
    else
        print("____not send result")
    end
    
    self.m_xkTotalPropsLast = self.m_xkTotalProps
end

function XiakeChuanGong:RefreshStarsProps()
    LogInfo("____XiakeChuanGong:RefreshStarsProps")
    
    for i = 1, self.s_nCGPropsCount, 1 do
        self.m_arrWndPropPart[i]:setVisible(false)
    end

    if not self.m_xkTotalProps then
        print("____error not self.m_xkTotalProps")
        return
    end
    
    if not self:RefreshPropsChangeExp() then
        print("____error not self:RefreshPropsChangeExp")
        return
    end

    for i = 1, self.s_nCGPropsCount, 1 do
        if self.m_xkTotalProps[i] and self.m_arrPropExpChange[i] and self.m_arrPropExpChange[i].curexp
            and self.m_arrPropExpChange[i].scheduleexp and self.m_arrPropExpChange[i].addexp then
            
            self.m_arrWndPropPart[i]:setVisible(true)

            local curProp = self.m_xkTotalProps[i]
            local curExpChange = self.m_arrPropExpChange[i]
            self.m_arrREdBoxStar[i]:Clear()
            self.m_arrREdBoxStar[i]:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
            if curProp.color == 0 then
                for j = 1, 6, 1 do
                    self.m_arrREdBoxStar[i]:AppendEmotion(150)
                end
            elseif curProp.color >= 1 and curProp.color <= 7 then
                if not self.m_bShowStarEff or self.m_arrNumCurStarEff[i] >= self.m_arrNumNeedStarEff[i] then
                    for j = 1, 6, 1 do
                        print("\n 11111: ",150+curProp.color, " ", 150+curProp.color-1)
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
            self.m_arrTxtPropName[i]:setText( curProp.name .. MHSD_UTILS.get_resstring(2980))
            self.m_arrWndPropLight[i]:setVisible(self.m_indexSelProp == i)
            
            local curExp, expAdd, neededExp, afterExp
            curExp = curExpChange.curexp
            expAdd = curExpChange.addexp
            neededExp = curExpChange.scheduleexp
            if curExp > neededExp then
                print("____error curExp > neededExp")
                curExp = neededExp
            end
            
            afterExp = curExp+expAdd
            if afterExp > neededExp then
                afterExp = neededExp
            end

            if expAdd <= 0 then
                self.m_arrTxtPropExp[i]:setText(tostring(curExp) .. "/" .. tostring(neededExp))
            else
                self.m_arrTxtPropExp[i]:setText(tostring(curExp).."[colour='FF00FF00']+"..tostring(expAdd).."[colour='FFFFFFFF']/"..tostring(neededExp))
            end
            
            print("____i: " .. i .. " curExp: " .. curExp .. " afterExp: " .. afterExp .. " neededExp: " .. neededExp)

            if neededExp >= 1 then
                self.m_arrProgBarBlue[i]:setProgress(curExp/neededExp)
                self.m_arrProgBarGreen[i]:setProgress(afterExp/neededExp)
            else
                print("____error neededExp <= 0")
                self.m_arrProgBarBlue[i]:setProgress(0.0)
                self.m_arrProgBarGreen[i]:setProgress(0.0)
            end
        end
    end
    
    --now we need to refresh yinliang display info
    self:RefreshMXKMainProp()
    self:RefreshMXKSpendMoney()
end

function XiakeChuanGong:HandleClickStartBtn(args)
    LogInfo("____XiakeChuanGong.HandleClickStartBtn")
    
    if self.m_bShowStarEff then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    if GetBattleManager() and GetBattleManager():IsInBattle() then
        GetGameUIManager():AddMessageTipById(144879)
        return true
    end
    
    if self.m_indexSelProp < 1 or self.m_indexSelProp > self.s_nCGPropsCount then
        print("____error self.m_indexSelProp out of range")
        return true
    end
    
    if not self.m_xkTotalProps or not self.m_xkTotalProps[self.m_indexSelProp] then
        print("____error totalprops")
        return true
    end
    
    local curProp = self.m_xkTotalProps[self.m_indexSelProp]
    
    if self.m_xkkey <= 0 or curProp.type < 1 or curProp.type > 6 then
        print("____error xkkey or curProp.type")
        return true
    end
    
    local xkCGAction = CXiakeChuangong.Create()
    xkCGAction.xiakekey = self.m_xkkey
    xkCGAction.prop = curProp.type
    xkCGAction.xiakelist = {}
    local bSelXK = false
    for i = 1, self.s_nCountSelMatDistrict, 1 do
        if self.m_arrSelResultXKKeys[i] and self.m_arrSelResultXKKeys[i].xkkey > 0 then
            bSelXK = true
            local keySel = self.m_arrSelResultXKKeys[i].xkkey
            xkCGAction.xiakelist[#xkCGAction.xiakelist+1] = keySel
        end
    end
    
    if bSelXK then
        LuaProtocolManager.getInstance():send(xkCGAction)
    else
        print("____error not select any xiake")
    end

    return true
end

function XiakeChuanGong:HandleStartAllConfirmClicked(args)
    LogInfo("____XiakeChuanGong:HandleStartAllConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    if self.m_bShowStarEff then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    if GetBattleManager() and GetBattleManager():IsInBattle() then
        GetGameUIManager():AddMessageTipById(144879)
        return true
    end
    
    if self.m_indexSelProp < 1 or self.m_indexSelProp > self.s_nCGPropsCount then
        print("____error self.m_indexSelProp out of range")
        return true
    end
    
    if not self.m_xkTotalProps or not self.m_xkTotalProps[self.m_indexSelProp] then
        print("____error totalprops")
        return true
    end
    
    local curProp = self.m_xkTotalProps[self.m_indexSelProp]
    
    if self.m_xkkey <= 0 or curProp.type < 1 or curProp.type > 6 then
        print("____error xkkey or curProp.type")
        return true
    end
    
    local xkCGAction = COneoffXiakeChuangong.Create()
    xkCGAction.xiakekey = self.m_xkkey
    xkCGAction.prop = curProp.type
    LuaProtocolManager.getInstance():send(xkCGAction)

    return true
end

function XiakeChuanGong:HandleClickStartAllBtn(args)
    LogInfo("____XiakeChuanGong:HandleClickStartAllBtn")

    local xkname = ""
    local curProp = nil
    
    if self.m_indexSelProp >= 1 and self.m_indexSelProp <= self.s_nCGPropsCount and self.m_xkTotalProps and self.m_xkTotalProps[self.m_indexSelProp] then
        curProp = self.m_xkTotalProps[self.m_indexSelProp]
    else
        print("____error not correct curprop info")
    end
    
    local strbuilder = StringBuilder:new()
    local strMsg = ""
    if curProp and curProp.name then
        xkname = curProp.name
        print("XK name: ", xkname)
    else
        print("____error not curProp or not curProp.name")
    end
    strbuilder:Set("parameter1", xkname)

    strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145368))
    
    print("MSG: ", strMsg)

    GetMessageManager():AddConfirmBox(eConfirmNormal,strMsg,XiakeChuanGong.HandleStartAllConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    
    strbuilder:delete()

    return true
end

function XiakeChuanGong:HandleClickPropPart(args)
    LogInfo("____XiakeChuanGong:HandleClickPropPart")
    
    if self.m_bShowStarEff then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    local WindowArgs = CEGUI.toWindowEventArgs(args)
	local wndClick = WindowArgs.window
    if wndClick then
        local idClick = wndClick:getID()
        
        if idClick >= 1 and idClick <= self.s_nCGPropsCount and self.m_indexSelProp ~= idClick then
            self.m_indexSelProp = idClick
            self:RefreshStarsProps()
        end
    else
        print("____error click")
    end

    return true
end

function XiakeChuanGong:HandleClickSelResultPart(args)
    LogInfo("____XiakeChuanGong:HandleClickSelResultPart")
    
    if self.m_bShowStarEff then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end

    local WindowArgs = CEGUI.toWindowEventArgs(args)
	local wndClick = WindowArgs.window
    local idClick = -1
    if wndClick then
        idClick = wndClick:getID()
    else
        print("____error click")
    end
    
    if idClick < 1 or idClick > self.s_nCountSelMatDistrict then
        print("____error idClick not correct")
        return true
    end

    self:DeleteSelResultByIndex(idClick)

    return true
end

function XiakeChuanGong.GetGivenTableNum(tableReg)
    local len = 0
    for k,v in pairs(tableReg) do
        len = len + 1
    end
    
    return len
end



function XiakeChuanGong:useConfirm()
    self.checking = 2
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    self:HandleClickSomeMatXiaKe()
end

function XiakeChuanGong:useReject()
    self.checking = nil
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end



function XiakeChuanGong:HandleClickSomeMatXiaKe(args)

    LogInfo("____XiakeChuanGong:HandleClickSomeMatXiaKe")
    if self.m_bShowStarEff then
        GetGameUIManager():AddMessageTipById(142848)
        return true
    end
	
    local winMgr = CEGUI.WindowManager:getSingleton()

	local pCell = nil
    local idCell = nil
    
    if self.checking == 2 then
        pCell = self.pCell
        idCell = self.idCell
    else
        local WindowArgs = CEGUI.toWindowEventArgs(args)
        pCell = CEGUI.toItemCell(WindowArgs.window)
        idCell = pCell:getID()
    end


    if not self.m_selStateXiakeKeys[idCell] then
        return true
    end

    if not self.m_selStateXiakeKeys[idCell].xiakekey then
        return true
    end
    



    if not self.checking then
        if  XiakeMng.practiseLevel[self.m_selStateXiakeKeys[idCell].xiakekey] and XiakeMng.practiseLevel[self.m_selStateXiakeKeys[idCell].xiakekey] > 1 and self.m_selStateXiakeKeys[idCell].bSelected == false then
            self.checking = 1
            self.pCell = pCell
            self.idCell = idCell
            GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(146496),self.useConfirm,self,self.useReject,self)
            return
        end
    elseif self.checking == 2 then
        self.checking = nil
    else
        return
    end











    LogInfo("_____click xia ke key is: " .. self.m_selStateXiakeKeys[idCell].xiakekey)
    
    local lightWndName = tostring(idCell) .. "inherititem/quack0/selected"
    local lightWnd = winMgr:getWindow(lightWndName)
    local xkkeyCur = self.m_selStateXiakeKeys[idCell].xiakekey
	if pCell and lightWnd then
        if not self.m_selStateXiakeKeys[idCell] then

        elseif self.m_selStateXiakeKeys[idCell].bSelected then
            for i = 1, self.s_nCountSelMatDistrict, 1 do
                if self.m_arrSelResultXKKeys[i] and xkkeyCur == self.m_arrSelResultXKKeys[i].xkkey then
                    self:DeleteSelResultByIndex(i)
                    break
                end
            end
        else
            for i = 1, self.s_nCountSelMatDistrict, 1 do
                if not self.m_arrSelResultXKKeys[i] then
                    self:SetSelResultContent(i, xkkeyCur, idCell)
                    break
                end
            end
        end
    end
    
    return true
end

function XiakeChuanGong:RefreshUIFromOpening(xiakekey, xiakeprops, otherxiakes)
    LogInfo("____XiakeChuanGong:RefreshUIFromOpening")
    
    if xiakekey <= 0 or not xiakeprops then
        print("____error not invalid info")
        return
    end

    print("____xiakekey: " .. xiakekey)
    
    self.m_xkkey = xiakekey
    
    self.m_xkTotalProps = {}
    
    if not xiakeprops or not xiakeprops.props then
        print("____error invalid xiakeprops")
        return
    end
    
    self.m_xkTotalProps.xiakekey = xiakeprops.xiakekey
    self.m_xkTotalProps.elite = xiakeprops.elite
    for k,v in pairs(xiakeprops.props) do
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
    
    self:SetEffectState(false)

    self.m_eliteXKDes = otherxiakes
    
    self.m_indexSelProp = 1
    self.m_arrPropExpChange = {}

    --start refresh each part info and display
    self:RefreshMatXiakesInfo()
    self:RefreshStarsProps()
    self:RefreshMXKDestrict()
end

function XiakeChuanGong:RefreshUIFromResult(xiakekey, xiake, xiakelist)
    LogInfo("____XiakeChuanGong:RefreshUIFromResult")

    if xiakekey <= 0 or not xiake then
        print("____error not invalid info")
        return
    end

    print("____xiakekey: " .. xiakekey)
    
    self.m_xkkey = xiakekey
    
    self.m_xkTotalProps = {}
    
    if not xiake or not xiake.props then
        print("____error invalid xiake")
        return
    end

    self.m_xkTotalProps.xiakekey = xiake.xiakekey
    self.m_xkTotalProps.elite = xiake.elite
    for k,v in pairs(xiake.props) do
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
    
    self:SetEffectState(true)

    --self.m_indexSelProp = 1
    self.m_arrPropExpChange = {}

    --start refresh each part info and display
    self:RefreshMatXiakesInfo(xiakelist)
    self:RefreshStarsProps()
    self:RefreshMXKDestrict()
end

function XiakeChuanGong:RefreshXKListProps(xkpropslist)
    LogInfo("____XiakeChuanGong:RefreshXKListProps")
    
    if not self.m_matXiakesProps then
        self.m_matXiakesProps = {}
    end

    for k,v in pairs(xkpropslist) do
        print("____key: " .. k)
        self.m_matXiakesProps[k] = v
    end

    self:RefreshStarsProps()
end

function XiakeChuanGong:RefreshMatXiakesInfo(removedXKList)
    LogInfo("____XiakeChuanGong:RefreshMatXiakesInfo")
    
    self:RefreshMatXiakes(removedXKList)

    local num = XiakeChuanGong.GetGivenTableNum(self.m_matXiakes)
	self.m_iMaxPage = math.ceil(num / self.m_iOnePageCount)
	self.m_iCurPage = 1
    self.m_iCellNum = 0
    self.m_iBarPos = 0
    self.m_selStateXiakeKeys = {}

    self:RefreshOpponent()
    
    self:ResetSelResultList()
end

function XiakeChuanGong:RefreshMatXiakes(removedXKList)
    LogInfo("_____XiakeChuanGong:RefreshMatXiakes")
    
    self.m_matXiakes = nil
    if self.m_xkkey > 0 then
        self.m_matXiakes = XiakeMng.GetIdleXiakesOrderByColorScoreIncreExceptGivenKey(self.m_xkkey, removedXKList)
    else
        print("____error not main xiake key")
        return
    end

    for k,v in pairs(self.m_matXiakes) do
        print("____new idle xiakes keys: " .. v.xiakekey)
    end
end

function XiakeChuanGong:RefreshOpponent()
    
    LogInfo("____XiakeChuanGong:RefreshOpponent")
    
    if not self.m_matXiakes then
        self:RefreshMatXiakes()
    end
    
    if not self.m_matXiakes then
        return
    end 

    if not self.m_iCurPage then
		return
	end

	local num = XiakeChuanGong.GetGivenTableNum(self.m_matXiakes)
    
	local winMgr = CEGUI.WindowManager:getSingleton()
	local startPos = (self.m_iCurPage - 1) * self.m_iOnePageCount + 1
	local endPos = self.m_iCurPage * self.m_iOnePageCount
	if endPos > num then
		endPos = num
	end
    
    self.m_iCellNum = self.m_iCellNum or 0
    
    if not self.m_matXiakesProps then
        self.m_matXiakesProps = {}
    end
    local vecAddKey = {}

	for index = startPos, endPos, 1 do
        local v = self.m_matXiakes[index]
        local xk = XiakeMng.ReadXiakeData(v.xiakeid)
        local namePrefix = tostring(index)
        if xk then

            local bOutLet = false
            if self.m_iMaxCells < index then
                bOutLet = true
                self.m_iMaxCells = index
                self.m_lCells[self.m_iMaxCells] = winMgr:loadWindowLayout("inherititem.layout",namePrefix)
            end

            local rootWnd = self.m_lCells[index]

            if rootWnd then
                if bOutLet then
                    print("_____add child window: " .. namePrefix)
                    self.m_pPane:addChildWindow(rootWnd)
                end
                
                self.m_iCellNum = self.m_iCellNum + 1

                self.m_selStateXiakeKeys[index] = {xiakekey = v.xiakekey, bSelected = false}
                
                local width = rootWnd:getPixelSize().width
                local xPos=1.0+(width+5.0)*(index-1)
                local yPos=1.0
                rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
                rootWnd:setVisible(true)
                
                local wndEliteIconName = namePrefix .. "inherititem/quack/finish"
                local wndEliteIcon = winMgr:getWindow(wndEliteIconName)
                if wndEliteIcon then
                    if self.m_eliteXKDes and self.m_eliteXKDes[v.xiakekey] and self.m_eliteXKDes[v.xiakekey] == 1 then
                        wndEliteIcon:setVisible(true)
                    else
                        wndEliteIcon:setVisible(false)
                    end
                end

                local headWndName = namePrefix .. "inherititem/back"
                local headWnd = CEGUI.toItemCell(winMgr:getWindow(headWndName))
                if headWnd then
                    headWnd:setProperty("Image", xk.path)
                    headWnd:setID(index)
                    headWnd:removeEvent("MouseClick")
                    headWnd:subscribeEvent("MouseClick", XiakeChuanGong.HandleClickSomeMatXiaKe, self)
                end
                
                local levelWndName = namePrefix .. "inherititem/level"
                local levelWnd = winMgr:getWindow(levelWndName)
                if levelWnd then
                    levelWnd:setText(tostring(GetDataManager():GetMainCharacterLevel()));
                end
                
                local markWndName = namePrefix .. "inherititem/mark"
                local markWnd = winMgr:getWindow(markWndName)
                if markWnd then
                    markWnd:setProperty("Image", XiakeMng.eLvImages[v.starlv]);
                end

                local frameWndName = namePrefix .. "inherititem/quack0"
                local frameWnd = winMgr:getWindow(frameWndName)
                if frameWnd then
                    frameWnd:setProperty("Image", XiakeMng.eXiakeFrames[v.color]);
                end

                local nameWndName = namePrefix .. "inherititem/name"
                local nameWnd = winMgr:getWindow(nameWndName)
                if nameWnd then
                    nameWnd:setText(scene_util.GetPetNameColor(v.color)..xk.xkxx.name)
                end
                
                local lightWndName = namePrefix .. "inherititem/quack0/selected"
                local lightWnd = winMgr:getWindow(lightWndName)
                if lightWnd then
                    lightWnd:setVisible(false)
                end
                
                --now this xiake succed to add in the celllist, we check if we need to add this key or not
                if not self.m_matXiakesProps[v.xiakekey] then
                    vecAddKey[#vecAddKey+1] = v.xiakekey
                end
            end
        end
	end
    
    for j = self.m_iCellNum+1, self.m_iMaxCells, 1 do
        if self.m_lCells[j] then
            self.m_lCells[j]:setPosition(CEGUI.UVector2(CEGUI.UDim(1,0),CEGUI.UDim(1,0)))
            self.m_lCells[j]:setVisible(false)
        end
        self.m_selStateXiakeKeys[j] = nil
    end

    --set scroll bar pos
	if self.m_iCurPage == 1 then
		self.m_pPane:getHorzScrollbar():setScrollPosition(0)
	else
		self.m_pPane:getHorzScrollbar():setScrollPosition(self.m_iBarPos)
	end
    
    --finally we see if we have any xiakes needed to be request from server the info about the chuan gong props
    if #vecAddKey > 0 then
        local getCGPropsAction = CGetXKListChuangongProp.Create()
        getCGPropsAction.xiakelist = vecAddKey
        LuaProtocolManager.getInstance():send(getCGPropsAction)
    end
end

function XiakeChuanGong:HandleNextPage(args)
	LogInfo("____XiakeChuanGong:HandleNextPage")
    
	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
            self.m_iBarPos = self.m_pPane:getHorzScrollbar():getScrollPosition()
			self.m_pPane:getHorzScrollbar():Stop()
			self:RefreshOpponent()
		end
	end
    
	return true
end

return XiakeChuanGong



