local Dialog = require "ui.dialog"
local MHSD_UTILS = require "utils.mhsdutils"
local CGemYuanSu = require "protocoldef.knight.gsp.item.cgemyuansu"
-- local LuaProtocolManager = require "manager.luaprotocolmanager"
-- local BeanConfigManager = require "manager.beanconfigmanager"

local YuanSuRongLianDlg = {}
setmetatable(YuanSuRongLianDlg, Dialog)
YuanSuRongLianDlg.__index = YuanSuRongLianDlg

YuanSuRongLianDlg.curData = nil

local _instance

-- 初始化元素熔炼的数据并打开元素熔炼界面
-- 不要直接用getInstanceAndShow
function YuanSuRongLianDlg.OnNpcService()
    local curDisplayData = YuanSuRongLianDlg.GetPackData()
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in YuanSuRongLianDlg.OnNpcService")
        return
    end

    local dlg = YuanSuRongLianDlg.getInstanceAndShow()
    if dlg then 
        dlg:SetDisPlayData(curDisplayData)
        dlg:RefreshView()
    end

end

-- 收到服务器响应SReqShenDiaoRoad
-- 刷新界面并显示结果
function YuanSuRongLianDlg.OnSGemYuanSu(protocol)
    -- 界面打开时才响应
    local dlg = YuanSuRongLianDlg.getInstanceNotCreate()
    if dlg then
        dlg:SetResult(protocol.itemkey)
        dlg:RefreshView()
    end

end

function YuanSuRongLianDlg.GetPackData()
    -- 初始化数据
    local newData = {}
    newData.yuansuList = {}
    for i=36096, 36110, 1 do
        newData.yuansuList[i] = 0
    end

    -- 读取背包信息
    local bagtype = knight.gsp.item.BagTypes.BAG
    local capacity = GetRoleItemManager():GetBagCapacity(bagtype)

    -- 读取物品信息并筛选元素信息
    for i=1, capacity do
        local item = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, i-1)
        if item ~= nil then
            local itemid = item:GetBaseObject().id
            if itemid >= 36096 and itemid <= 36110 then
                newData.yuansuList[itemid] = item:GetNum()
            end
        end
    end

    return newData
end

function YuanSuRongLianDlg.GetLayoutFileName()
    return "yuansuronglian.layout"
end

function YuanSuRongLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YuanSuRongLianDlg)

    return self
end

function YuanSuRongLianDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.spList = CEGUI.toScrollablePane(winMgr:getWindow("yuansuronglian/rightback/main"))

    self.vCell = {}
    self.vCellUse = {}
    self.vText = {}
    for i=0, 2 ,1 do
        self.vCell[i] = {}
        self.vCell[i].cellWnd = CEGUI.toItemCell(winMgr:getWindow("yuansuronglian/case/cell" .. tostring(i)))
        self.vCell[i].textWnd = winMgr:getWindow("yuansuronglian/case/text" .. tostring(i))
        self.vCell[i].id = 0
        self.vCell[i].cellWnd:setUserString("index", tostring(i))
        self.vCell[i].cellWnd:subscribeEvent("MouseButtonUp", YuanSuRongLianDlg.HandlePaneItemClicked, self)
    end

    self.result = {}
    self.result.cellWnd = CEGUI.toItemCell(winMgr:getWindow("yuansuronglian/case/line/cell"))
    self.result.cellWnd:subscribeEvent("MouseButtonUp", YuanSuRongLianDlg.HandleResultItemClicked, self)
    self.result.id = 0

    self.btnRongLian = CEGUI.toPushButton(winMgr:getWindow("yuansuronglian/btn"))
    self.btnRongLian:subscribeEvent("Clicked", YuanSuRongLianDlg.HandleRongLianBtnClicked, self)

    self.curType = 0
    self.waitResult = false
    self.lastPostion = self.spList:getVerticalScrollPosition()
end

function YuanSuRongLianDlg:HandleRongLianBtnClicked(args)
    local keys = {}

    -- 生成和校验数据
    for i=0, 2, 1 do
        if self.vCell[i].id >= 36096 and self.vCell[i].id <= 36110 then
            keys[i+1] = self.vCell[i].id
        else
            return
        end
    end

    -- 等待状态
    self.waitResult = true

    -- 发送协议
    local req = CGemYuanSu.Create()
    req.itemkeys = keys
    LuaProtocolManager.getInstance():send(req)

    -- 刷新界面
    self:RefreshView()

end

function YuanSuRongLianDlg:HandleResultItemClicked(args)
    if self.result.id == 0 then
        return
    end

    -- 清除结果
    self.result.id = 0

    -- 刷新界面
    self:RefreshView()

end

function YuanSuRongLianDlg:HandlePaneItemClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    local index = tonumber(e.window:getUserString("index"))
    local itemid = self.vCell[index].id

    -- 空栏位
    if itemid == 0 then
        return
    end

    -- 取下该栏位元素
    self.vCell[index].id = 0

    -- 是否取下了最后一个
    local isEmpty = true
    for i=0, 2, 1 do
        isEmpty = isEmpty and self.vCell[i].id == 0
    end
    if isEmpty then
        self.curType = 0
    end

    -- 左侧计数
    self.DisplayData.yuansuList[itemid] = self.DisplayData.yuansuList[itemid] + 1

    self:RefreshView()
end

function YuanSuRongLianDlg:HandleListItemClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    local itemid = e.window:getID()

    if itemid == 0 then
        return
    end

    local needRefresh = false

    -- 是否三个栏位都有东西
    local isFull = true
    for i=0, 2, 1 do
        isFull = isFull and self.vCell[i].id ~= 0
    end
    if isFull then
        return
    end

    -- 三个栏位都是空的
    if self.curType == 0 then 
        self.vCell[0].id = itemid
        self.curType = math.floor((itemid - 36096)/3)+1
    -- 有栏位占用
    else
        -- 类型不符
        if math.floor((itemid - 36096)/3)+1 ~= self.curType then 
            return
        else
            -- 寻找空位放置新元素
            local haveGet = false
            for i=0, 2, 1 do
                -- 找到了空位
                if self.vCell[i].id == 0 then
                    self.vCell[i].id = itemid
                    haveGet = true
                    break
                end
            end
            -- 全满了
            if not haveGet then
                return
            end
        end
    end

    -- 左侧计数
    if self.DisplayData.yuansuList[itemid] >= 1 then
        self.DisplayData.yuansuList[itemid] = self.DisplayData.yuansuList[itemid] - 1
    end

    -- 结果栏
    self.result.id = 0

    self:RefreshView()
end

function YuanSuRongLianDlg:SetDisPlayData(data)
    self.DisplayData = data
end

function YuanSuRongLianDlg:SetResult(itemid)
    self.result.id = itemid
    -- 清空右侧界面
    for i=0, 2, 1 do
        self.vCell[i].id = 0
    end

    -- 复位元素类型
    self.curType = 0

    -- 复位等待状态
    self.waitResult = false
end

function YuanSuRongLianDlg:RefreshView()
    local curDisplayData = self.DisplayData
    if curDisplayData == nil then
        LogErr("curDisplayData is nil in SDZhiLuDlg:RefreshView")
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 左侧列表
    -- 没有优化
    -- 最多只有15个Cell
    self.lastPostion = self.spList:getVerticalScrollPosition()
    self.spList:cleanupNonAutoChildren()
    local cellIndex = 0
    local height = 1
    for itemid=36096, 36110, 1 do
        if curDisplayData.yuansuList[itemid] > 0 then
            local wndCell = winMgr:loadWindowLayout("itemcommoncell.layout", "ysrl" .. tostring(itemid))
            if wndCell ~= nil then
                local backWnd = winMgr:getWindow("ysrl" .. tostring(itemid) .. "itemcommoncell/back")
                local nameWnd = winMgr:getWindow("ysrl" .. tostring(itemid) .. "itemcommoncell/back/name")
                local describeWnd = winMgr:getWindow("ysrl" .. tostring(itemid) .. "itemcommoncell/back/info")
                local itemWnd = CEGUI.toItemCell(winMgr:getWindow("ysrl" .. tostring(itemid) .. "itemcommoncell/back/item"))
                local itemConfig = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid)

                -- 物品名
                nameWnd:setText(itemConfig.name)
                nameWnd:setProperty("TextColours", itemConfig.colour)
                nameWnd:setMousePassThroughEnabled(true)

                -- 物品类型
                describeWnd:setText(itemConfig.effectdes)
                describeWnd:setMousePassThroughEnabled(true)

                -- 物品ItemCell
                itemWnd:SetImage(GetIconManager():GetItemIconByID(itemConfig.icon))
                itemWnd:SetTextUnit(tostring(curDisplayData.yuansuList[itemid]))
                itemWnd:setID(itemid)

                -- 底板
                backWnd:setID(itemid)

                -- 可用状态
                local usable = true
                if self.curType ~= 0 and math.floor((itemid - 36096)/3)+1 ~= self.curType then
                    usable = false
                else
                    for i=0, 2, 1 do
                        if itemid == self.vCell[i].id then
                            usable = false
                            break
                        end
                    end
                end
                if usable then
                    itemWnd:setEnabled(true)
                    itemWnd:SetLockState(false)
                    backWnd:setMousePassThroughEnabled(false)
                    backWnd:setProperty("Image", "set:MainControl9 image:shopcellnormal")
                else
                    itemWnd:setEnabled(false)
                    itemWnd:SetLockState(true)
                    backWnd:setMousePassThroughEnabled(true)
                    backWnd:setProperty("Image", "set:MainControl9 image:shopcelldisable")
                end

                -- 点击事件
                itemWnd:subscribeEvent("MouseButtonUp", YuanSuRongLianDlg.HandleListItemClicked, self)
                backWnd:subscribeEvent("MouseButtonUp", YuanSuRongLianDlg.HandleListItemClicked, self)

                -- 设置窗体位置
                self.spList:addChildWindow(wndCell)
                wndCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,1.0),CEGUI.UDim(0.0,height)))
                height = height + wndCell:getPixelSize().height
            end
        end
    end
    self.spList:setVerticalScrollPosition(self.lastPostion)

    -- 右边界面
    if not self.waitResult then
        -- 右侧三个ItemCell
        for i=0, 2, 1 do
            self.vCell[i].cellWnd:Clear()
            self.vCell[i].textWnd:setText("")
            self.vCell[i].cellWnd:setEnabled(true)
            if self.vCell[i].id ~= 0 then
                local itemConfig = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.vCell[i].id)
                self.vCell[i].cellWnd:SetImage(GetIconManager():GetItemIconByID(itemConfig.icon))
                self.vCell[i].textWnd:setText(itemConfig.name)
                self.vCell[i].textWnd:setProperty("TextColours", itemConfig.colour)
                self.vCell[i].textWnd:setVisible(true)
            else
                self.vCell[i].cellWnd:Clear()
                self.vCell[i].textWnd:setVisible(false)
            end
            self.btnRongLian:setEnabled(true)
        end
    else
        -- 等结果状态
        for i=0, 2 ,1 do
            self.vCell[i].cellWnd:setEnabled(false)
        end
        self.btnRongLian:setEnabled(false)
    end
    if self.result.id == 0 then 
        self.result.cellWnd:Clear()
    else
        local itemConfig = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.result.id)
        self.result.cellWnd:SetImage(GetIconManager():GetItemIconByID(itemConfig.icon))
    end
end

function YuanSuRongLianDlg.getInstance()
    if not _instance then
        _instance = YuanSuRongLianDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function YuanSuRongLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = YuanSuRongLianDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function YuanSuRongLianDlg.getInstanceNotCreate()
    return _instance
end

function YuanSuRongLianDlg.DestroyDialog()
    YuanSuRongLianDlg.curData = nil
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function YuanSuRongLianDlg.ToggleOpenClose()
    if not _instance then 
        _instance = YuanSuRongLianDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

return YuanSuRongLianDlg