local Dialog = require "ui.dialog"
local MHSD_UTILS = require "utils.mhsdutils"

SDZhaJiTipsDlg = {}

setmetatable(SDZhaJiTipsDlg, Dialog)
SDZhaJiTipsDlg.__index = SDZhaJiTipsDlg

-- For singleton
local _instance;
function SDZhaJiTipsDlg.getInstance()
    if not _instance then
        _instance = SDZhaJiTipsDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function SDZhaJiTipsDlg.getInstanceAndShow()
    if not _instance then
        _instance = SDZhaJiTipsDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function SDZhaJiTipsDlg.getInstanceNotCreate()
    return _instance
end

function SDZhaJiTipsDlg.DestroyDialog()
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function SDZhaJiTipsDlg.ToggleOpenClose()
    if not _instance then 
        _instance = SDZhaJiTipsDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function SDZhaJiTipsDlg.GetLayoutFileName()
    return "shendiaozhajitips.layout"
end

function SDZhaJiTipsDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SDZhaJiTipsDlg)

    return self
end

function SDZhaJiTipsDlg:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.txtTitle = winMgr:getWindow("shendiaozhajitips/name")
    self.txtDiscirbe = CEGUI.toRichEditbox(winMgr:getWindow("shendiaozhajitips/back/txt"))
    self.btnGetTask = winMgr:getWindow("shendiaozhajitips/use")

end

function SDZhaJiTipsDlg:SetContext(title, discribe, state, taskid)
    self.txtTitle:setText(tostring(title))

    self.txtDiscirbe:Clear()
    self.txtDiscirbe:AppendParseText(CEGUI.String(discribe))
    self.txtDiscirbe:Refresh()

    self.btnGetTask:removeEvent("Clicked")

    if taskid == 0 or state == -3 then -- 未开放
        self.btnGetTask:setEnabled(false)
        self.btnGetTask:setText(MHSD_UTILS.get_resstring(3173))
    elseif state == -1 then -- 可领取
        self.btnGetTask:setEnabled(true)
        self.btnGetTask:setUserString("taskid", tostring(taskid))
        self.btnGetTask:subscribeEvent("Clicked", SDZhaJiTipsDlg.HandleGetTaskBtnClicked, self)
        self.btnGetTask:setText(MHSD_UTILS.get_resstring(3173))
    elseif state == 1 then -- 已完成
        self.btnGetTask:setEnabled(false)
        self.btnGetTask:setText(MHSD_UTILS.get_resstring(3172))
    elseif state == 4 then -- 进行中
        self.btnGetTask:setEnabled(false)
        self.btnGetTask:setText(MHSD_UTILS.get_resstring(3171))
    else
        self.btnGetTask:setEnabled(false)
        self.btnGetTask:setText(MHSD_UTILS.get_resstring(3173))
    end


end

function SDZhaJiTipsDlg:HandleGetTaskBtnClicked(args)
    local e = CEGUI.toMouseEventArgs(args)
    local taskid = tonumber(e.window:getUserString("taskid"))

    local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(10576)   
    GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)

    local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
    SDZhaJiLable.DestroyDialog()
    SDZhaJiTipsDlg.DestroyDialog()
end

return SDZhaJiTipsDlg