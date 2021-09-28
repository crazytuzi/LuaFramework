local Dialog = require "ui.dialog"
local SDZhaJiTipsDlg = require "ui.sdzhaji.sdzhajitipsdlg"
-- local TableUtil = require "utils.tableutil"
local BeanConfigManager = require "manager.beanconfigmanager"
local CReqTaskState = require "protocoldef.knight.gsp.sdzhaji.creqtaskstate"

local SDZhangJieDlg = {}
setmetatable(SDZhangJieDlg, Dialog)
SDZhangJieDlg.__index = SDZhangJieDlg 

local _instance

-- 请求打开神雕传记界面CReqTaskState flag=1
-- 不要直接用getInstanceAndShow
function SDZhangJieDlg.OnRequireOpenSDZhangJieDlg()
    local req = CReqTaskState.Create()
    req.flag = 1
    LuaProtocolManager.getInstance():send(req)
end

-- 收到服务器响应STaskState flag=1
-- 界面在这个时候打开
function SDZhangJieDlg.OnSTaskState(protocol)
    local curDisplayData = SDZhangJieDlg.GetDisplayData(protocol)
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhangJieDlg.OnSTaskState")
        return
    end

    local dlg = SDZhangJieDlg.getInstanceAndShow()
    if dlg then 
        dlg:SetDisPlayData(curDisplayData)
        dlg:RefreshView()
    end

    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    SDZhaJiLable.OnReadyShow(3)
end

function SDZhangJieDlg.GetDisplayData(protocol)
    local newDisPlayData = {}

    local index = 0
    local allIDs =  BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhangjie"):getDisorderAllID()

    for k,v in pairs(allIDs) do
        local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshendiaozhangjie"):getRecorder(v)
        newDisPlayData[index] = {}
        newDisPlayData[index].id = cfg.id
        newDisPlayData[index].sort = cfg.paixu
        newDisPlayData[index].name = cfg.name
        newDisPlayData[index].discribe = cfg.miaoshu
        newDisPlayData[index].taskid = cfg.taskid
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

function SDZhangJieDlg.GetLayoutFileName()
    return "shendiaozhajizhangjie.layout"
end

function SDZhangJieDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 列表
    self.vText = {}
    self.vButton = {}

    for i=0, 7, 1 do
        self.vText[i] = winMgr:getWindow("shendiaozhajizhangjie/left/back/img/txt" .. tostring(i))
        self.vButton[i] = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhangjie/left/back/img" .. tostring(i)))
        self.vText[i]:setMousePassThroughEnabled(true)
    end

    -- 翻页按钮
    self.btnLast = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhangjie/right/btn11"))
    self.btnNext = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhangjie/right/btn1"))
    self.btnLast:subscribeEvent("Clicked", SDZhangJieDlg.HandleLastBtnClicked, self)
    self.btnNext:subscribeEvent("Clicked", SDZhangJieDlg.HandleNextBtnClicked, self)

    -- 页码
    self.curPage = 1
    self.maxPage = 1

end

function SDZhangJieDlg:HandleLastBtnClicked(args)
    self.curPage = self.curPage - 1
    self:RefreshView()
end

function SDZhangJieDlg:HandleNextBtnClicked(args)
    self.curPage = self.curPage + 1
    self:RefreshView()
end

function SDZhangJieDlg:HandleHeadClicked(args)

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
    local title = curDisplayData[index].name
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

function SDZhangJieDlg:SetDisPlayData(data)
    self.DisplayData = data
end

function SDZhangJieDlg:RefreshView()

    local curDisplayData = self.DisplayData
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhangJieDlg:RefreshView")
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
        self.vText[i]:removeEvent("MouseButtonUp")
        self.vButton[i]:removeEvent("MouseButtonUp")
        local index = 8*(self.curPage-1)+i
        if curDisplayData[index] ~= nil then
            self.vText[i]:setText(curDisplayData[index].name)
            self.vButton[i]:setVisible(true)
            self.vText[i]:setUserString("index", tostring(index))
            self.vButton[i]:setUserString("index", tostring(index))
            self.vButton[i]:subscribeEvent("MouseButtonUp", SDZhangJieDlg.HandleHeadClicked, self)
        else
            self.vText[i]:setVisible(false)
            self.vButton[i]:setVisible(false)
        end
    end
end

function SDZhangJieDlg.getInstance()
    if not _instance then
        _instance = SDZhangJieDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function SDZhangJieDlg.getInstanceAndShow()
    if not _instance then
        _instance = SDZhangJieDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function SDZhangJieDlg.getInstanceNotCreate()
    return _instance
end

function SDZhangJieDlg.DestroyDialog()
    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    if _instance then
        if SDZhaJiLable.getInstanceNotCreate() then
            SDZhaJiLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end

    end
end

function SDZhangJieDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function SDZhangJieDlg.ToggleOpenClose()
    if not _instance then 
        _instance = SDZhangJieDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function SDZhangJieDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SDZhangJieDlg)

    return self
end

return SDZhangJieDlg