local Dialog = require "ui.dialog"
local SDZhaJiTipsDlg = require "ui.sdzhaji.sdzhajitipsdlg"
-- local TableUtil = require "utils.tableutil"
local BeanConfigManager = require "manager.beanconfigmanager"
local CReqTaskState = require "protocoldef.knight.gsp.sdzhaji.creqtaskstate"

local SDZhuanJiDlg = {}
setmetatable(SDZhuanJiDlg, Dialog)
SDZhuanJiDlg.__index = SDZhuanJiDlg 

local _instance

-- 请求打开神雕传记界面CReqTaskState flag=2
-- 不要直接用getInstanceAndShow
function SDZhuanJiDlg.OnRequireOpenSDZhuanJiDlg()
    local req = CReqTaskState.Create()
    req.flag = 2
    LuaProtocolManager.getInstance():send(req)
end

-- 收到服务器响应STaskState flag=2
-- 界面在这个时候打开
function SDZhuanJiDlg.OnSTaskState(protocol)
    local curDisplayData = SDZhuanJiDlg.GetDisplayData(protocol)
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhuanJiDlg.OnSTaskState")
        return
    end

    local dlg = SDZhuanJiDlg.getInstanceAndShow()
    if dlg then 
        dlg:SetDisPlayData(curDisplayData)
        dlg:RefreshView()
    end

    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    SDZhaJiLable.OnReadyShow(2)
end

function SDZhuanJiDlg.GetDisplayData(protocol)
    local newDisPlayData = {}

    local index = 0
    local allIDs =  BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhuanji"):getDisorderAllID()

    for k,v in pairs(allIDs) do
        local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhuanji"):getRecorder(v)
        newDisPlayData[index] = {}
        newDisPlayData[index].id = cfg.id
        newDisPlayData[index].sort = cfg.paixu
        newDisPlayData[index].name = cfg.name
        newDisPlayData[index].tipsname = cfg.tips
        newDisPlayData[index].discribe = cfg.miaoshu
        newDisPlayData[index].taskid = cfg.taskid
        newDisPlayData[index].picid = cfg.picid
        newDisPlayData[index].state = -3 -- 初始化为无法领取
        index = index + 1
    end

    for kp,vp in pairs(protocol.statemap) do
        for kt,vt in pairs(newDisPlayData) do
            if vt.id == kp then
                vt.state = vp
            end
        end
    end

    return newDisPlayData

end

function SDZhuanJiDlg.GetLayoutFileName()
    return "shendiaozhajizhuanji.layout"
end

function SDZhuanJiDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 头像
    self.vHead = {}
    self.vHeadText = {}
    self.vFrame = {}

    for i=0, 7, 1 do
        self.vHead[i] = winMgr:getWindow("shendiaozhajizhuanji/left/back/pic/head" .. tostring(i))
        self.vHeadText[i] = winMgr:getWindow("shendiaozhajizhuanji/left/back/pic/head/tback/txt" .. tostring(i))
        self.vFrame[i] = winMgr:getWindow("shendiaozhajizhuanji/left/back/pic" .. tostring(i))
    end

    -- 翻页按钮
    self.btnLast = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhuanji/left/fanye"))
    self.btnNext = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhuanji/left/fanye1"))
    self.btnLast:subscribeEvent("Clicked", SDZhuanJiDlg.HandleLastBtnClicked, self)
    self.btnNext:subscribeEvent("Clicked", SDZhuanJiDlg.HandleNextBtnClicked, self)

    -- 页码
    self.curPage = 1
    self.maxPage = 1

end

function SDZhuanJiDlg:HandleLastBtnClicked(args)
    self.curPage = self.curPage - 1
    self:RefreshView()
end

function SDZhuanJiDlg:HandleNextBtnClicked(args)
    self.curPage = self.curPage + 1
    self:RefreshView()
end

function SDZhuanJiDlg:HandleHeadClicked(args)

    -- 获取点击位置

    local e = CEGUI.toMouseEventArgs(args)
    local index = tonumber(e.window:getUserString("index"))
    local position = e.position

    local winMgr = CEGUI.WindowManager:getSingleton()
    local ypos = position.y
    local xpos = position.x

    -- 获取Tips窗口

    local tipsDlg = SDZhaJiTipsDlg.getInstanceAndShow()

    if tipsDlg == nil then
        return
    end

    local tipsWnd = tipsDlg:GetWindow()

    if tipsWnd == nil then
        return
    end

    -- 设置窗口内容

    local curDisplayData = self.DisplayData
    local title = curDisplayData[index].tipsname
    local discribe = curDisplayData[index].discribe
    local state = curDisplayData[index].state
    local taskid = curDisplayData[index].taskid

    tipsDlg:SetContext(title, discribe, state, taskid)

    -- 设置窗口位置

    local rootWnd = CEGUI.System:getSingleton():getGUISheet()
    if xpos+tipsWnd:getPixelSize().width > rootWnd:getPixelSize().width then
        xpos = xpos - tipsWnd:getPixelSize().width
    end

    if ypos+tipsWnd:getPixelSize().width > rootWnd:getPixelSize().height then
        ypos = ypos - tipsWnd:getPixelSize().height
    end

    tipsWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xpos),CEGUI.UDim(0.0,ypos)))

end

function SDZhuanJiDlg:SetDisPlayData(data)
    self.DisplayData = data
end

function SDZhuanJiDlg:RefreshView()

    local curDisplayData = self.DisplayData
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhuanJiDlg:RefreshView")
        return
    end

    self.maxPage = math.floor((TableUtil.tablelength(curDisplayData)-1)/8)+1

    -- 翻页按钮状态及越界检查
    if self.curPage >= self.maxPage then
        self.curPage = self.maxPage 
        self.btnNext:setVisible(false)
    else
        self.btnNext:setVisible(true)
    end

    if self.curPage <= 1 then 
        self.curPage = 1
        self.btnLast:setVisible(false)
    else
        self.btnLast:setVisible(true)
    end

    for i=0, 7, 1 do
        local index = 8*(self.curPage-1)+i
        self.vHeadText[i]:removeEvent("MouseButtonUp")
        self.vHead[i]:removeEvent("MouseButtonUp")
        if curDisplayData[index] ~= nil then
            self.vHeadText[i]:setText(curDisplayData[index].name)
            self.vHead[i]:setProperty("Image", GetIconManager():GetImagePathByID(curDisplayData[index].picid):c_str())
            self.vFrame[i]:setVisible(true)
            self.vHead[i]:setUserString("index", tostring(index))
            self.vHeadText[i]:setUserString("index", tostring(index))
            self.vHeadText[i]:subscribeEvent("MouseButtonUp", SDZhuanJiDlg.HandleHeadClicked, self)
            self.vHead[i]:subscribeEvent("MouseButtonUp", SDZhuanJiDlg.HandleHeadClicked, self)
        else
            self.vFrame[i]:setVisible(false)
        end
    end
end

function SDZhuanJiDlg.getInstance()
    if not _instance then
        _instance = SDZhuanJiDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function SDZhuanJiDlg.getInstanceAndShow()
    if not _instance then
        _instance = SDZhuanJiDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function SDZhuanJiDlg.getInstanceNotCreate()
    return _instance
end

function SDZhuanJiDlg.DestroyDialog()
    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    if _instance then
        if SDZhaJiLable.getInstanceNotCreate() then
            SDZhaJiLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end

    end
end

function SDZhuanJiDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function SDZhuanJiDlg.ToggleOpenClose()
    if not _instance then 
        _instance = SDZhuanJiDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function SDZhuanJiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SDZhuanJiDlg)

    return self
end

return SDZhuanJiDlg