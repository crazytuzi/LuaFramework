local Dialog = require "ui.dialog"
local TableUtil = require "utils.tableutil"
local SDZhiLuDataManager = require "ui.sdzhaji.sdzhiludatamanager"
local LuaProtocolManager = require "manager.luaprotocolmanager"
local CReqShenDiaoRoad = require "protocoldef.knight.gsp.sdzhaji.creqshendiaoroad"

local SDZhiLuDlg = {}
setmetatable(SDZhiLuDlg, Dialog)
SDZhiLuDlg.__index = SDZhiLuDlg 

local _instance

-- 界面开启流程：
-- ->向服务器发送请求 OnRequireOpenSDZhiluDlg
-- ->收到返回协议 OnSReqShenDiaoRoad
-- ->生成并设置显示数据 SDZhiLuDataManager.GetDisplayData
-- ->打开并刷新界面 getInstanceAndShow,SetDisPlayData,RefreshView

-- 请求打开神雕之路界面CReqShenDiaoRoad
-- 不要直接用getInstanceAndShow
function SDZhiLuDlg.OnRequireOpenSDZhiluDlg()
    local req = CReqShenDiaoRoad.Create()
    LuaProtocolManager.getInstance():send(req)
end

-- 收到服务器响应SReqShenDiaoRoad
-- 界面在这个时候打开
function SDZhiLuDlg.OnSReqShenDiaoRoad(protocol)
    local curDisplayData = SDZhiLuDataManager.GetDisplayData(protocol)
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhiLuDlg.OnSReqShenDiaoRoad")
        return
    end

    local dlg = SDZhiLuDlg.getInstanceAndShow()
    if dlg then 
        dlg:SetDisPlayData(curDisplayData)
        dlg:RefreshView()
    end

    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    SDZhaJiLable.OnReadyShow(1)
end

function SDZhiLuDlg.GetLayoutFileName()
    return "shendiaozhajizhilu.layout"
end

function SDZhiLuDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 封面
    self.imgCover = winMgr:getWindow("shendiaozhajizhilu/left")

    -- 角标和正文
    self.vCorner = {}
    self.vContext = {}
    for i=1, 4, 1 do
        self.vCorner[i] = winMgr:getWindow("shendiaozhajizhilu/right/back/time" .. tostring(i))
        self.vContext[i] = CEGUI.toRichEditbox(winMgr:getWindow("shendiaozhajizhilu/right/back/talk" .. tostring(i)))
        self.vContext[i]:setMousePassThroughEnabled(true)
    end

    self.comLeftContext = winMgr:getWindow("shendiaozhajizhilu/right1")
    self.comRightContext = winMgr:getWindow("shendiaozhajizhilu/right1")

    -- 翻页按钮
    self.btnLast = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhilu/right/btn1"))
    self.btnNext = CEGUI.toPushButton(winMgr:getWindow("shendiaozhajizhilu/right/btn"))
    self.btnLast:subscribeEvent("Clicked", SDZhiLuDlg.HandleLastBtnClicked, self)
    self.btnNext:subscribeEvent("Clicked", SDZhiLuDlg.HandleNextBtnClicked, self)

    -- 页码
    self.curPage = 1
    self.maxPage = 1

    -- 数据
    self.DisplayData = nil

end

function SDZhiLuDlg:HandleLastBtnClicked(args)
    self.curPage = self.curPage - 1
    self:RefreshView()
end

function SDZhiLuDlg:HandleNextBtnClicked(args)
    self.curPage = self.curPage + 1
    self:RefreshView()
end

function SDZhiLuDlg:SetCoverVisible(bShow)
    self.imgCover:setVisible(bShow)
    self.comLeftContext:setVisible(not bShow)
end

function SDZhiLuDlg:SetDisPlayData(data)
    self.DisplayData = data
end

function SDZhiLuDlg:RefreshView()
    local curDisplayData = self.DisplayData
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhiLuDlg:RefreshView")
        return
    end

    self.maxPage = math.floor((TableUtil.tablelength(curDisplayData)+2-1)/4)+1

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

    if self.curPage == 1 then
        self:SetCoverVisible(true)
        for i=1, 2, 1 do
            if curDisplayData[i] ~= nil then
                self.vCorner[i+2]:setText(curDisplayData[i].corner)
                self.vContext[i+2]:Clear()
                self.vContext[i+2]:AppendParseText(CEGUI.String(curDisplayData[i].context))
                self.vContext[i+2]:Refresh()
            else
                self.vCorner[i+2]:setText("")
                self.vContext[i+2]:Clear()
                self.vContext[i+2]:Refresh()
            end
        end
    else
        self:SetCoverVisible(false)
        for i=1, 4, 1 do
            local index = 4*(self.curPage-1)+i-2
            if curDisplayData[index] ~= nil then
                self.vCorner[i]:setText(curDisplayData[index].corner)
                self.vContext[i]:Clear()
                self.vContext[i]:AppendParseText(CEGUI.String(curDisplayData[index].context))
                self.vContext[i]:Refresh()
            else
                self.vCorner[i]:setText("")
                self.vContext[i]:Clear()
                self.vContext[i]:Refresh()
            end
        end
    end
end

function SDZhiLuDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SDZhiLuDlg)

    return self
end

function SDZhiLuDlg.getInstance()
    if not _instance then
        _instance = SDZhiLuDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function SDZhiLuDlg.getInstanceAndShow()
    if not _instance then
        _instance = SDZhiLuDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function SDZhiLuDlg.getInstanceNotCreate()
    return _instance
end

function SDZhiLuDlg.DestroyDialog()
    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    if _instance then
        if SDZhaJiLable.getInstanceNotCreate() then
            SDZhaJiLable.getInstanceNotCreate().DestroyDialog()
        else
            _instance:CloseDialog()
        end

    end
end

function SDZhiLuDlg:CloseDialog()
    if _instance ~= nil then
        _instance:OnClose()
        _instance = nil
    end
end

function SDZhiLuDlg.ToggleOpenClose()
    if not _instance then 
        _instance = SDZhiLuDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

return SDZhiLuDlg