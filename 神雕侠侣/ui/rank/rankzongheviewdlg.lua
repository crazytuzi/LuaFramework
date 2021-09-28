local Dialog = require "ui.dialog"
local LuaProtocolManager = require "manager.luaprotocolmanager"

local RankZongheViewDlg = {}
setmetatable(RankZongheViewDlg, Dialog)
RankZongheViewDlg.__index = RankZongheViewDlg

RankZongheViewDlg.curData = nil

local _instance
function RankZongheViewDlg.getInstance()
    if not _instance then
        _instance = RankZongheViewDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankZongheViewDlg.getInstanceAndShow()
    if not _instance then
        _instance = RankZongheViewDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function RankZongheViewDlg.getInstanceNotCreate()
    return _instance
end

function RankZongheViewDlg.DestroyDialog()
    RankZongheViewDlg.curData = nil
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function RankZongheViewDlg.ToggleOpenClose()
    if not _instance then 
        _instance = RankZongheViewDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankZongheViewDlg.GetLayoutFileName()
    return "listzongheview.layout"
end

function RankZongheViewDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankZongheViewDlg)

    return self
end

function RankZongheViewDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 属性显示

    self.txtRoleID = winMgr:getWindow("listzongheview/title")
    self.txtName = winMgr:getWindow("listzongheview/name")
    self.txtLevel = winMgr:getWindow("listzongheview/level")
    self.txtZongheScore = winMgr:getWindow("listzongheview/score1")
    self.txtPetScore = winMgr:getWindow("listzongheview/score2")
    self.txtXiakeScore = winMgr:getWindow("listzongheview/score3")
    self.txtFactionName = winMgr:getWindow("listzongheview/family")
    self.txtSchool = winMgr:getWindow("listzongheview/school")
    self.txtCamp = winMgr:getWindow("listzongheview/camp")
    self.txtRank = winMgr:getWindow("listzongheview/rank/text")
    self.imgHead = winMgr:getWindow("listzongheview/PlayerHeadBack/PlayerHead")

    -- 详细信息按钮

    self.btnPet = CEGUI.toPushButton(winMgr:getWindow("listzongheview/user/cha1"))
    self.btnXiake = CEGUI.toPushButton(winMgr:getWindow("listzongheview/user/cha11"))

    self.btnPet:subscribeEvent("Clicked", RankZongheViewDlg.HandleClickePetBtn, self)
    self.btnXiake:subscribeEvent("Clicked", RankZongheViewDlg.HandleClickeXiakeBtn, self)
end

function RankZongheViewDlg:RefreshView()
    if RankZongheViewDlg.curData == nil then
        LogErr("RankZongheViewDlg.curData is nil in RankZongheViewDlg:RefreshView")
        return
    end

    -- 设置属性显示

    self.txtRoleID:setText(tostring(RankZongheViewDlg.curData.roleid))
    self.txtName:setText(tostring(RankZongheViewDlg.curData.rolename))
    self.txtLevel:setText(tostring(RankZongheViewDlg.curData.level))
    self.txtZongheScore:setText(tostring(RankZongheViewDlg.curData.zonghescore))
    self.txtXiakeScore:setText(tostring(RankZongheViewDlg.curData.xiakescore))
    self.txtPetScore:setText(tostring(RankZongheViewDlg.curData.petscore))

    if RankZongheViewDlg.curData.factionname == "" then
        local factionname = require "utils.mhsdutils".get_resstring(1663)
        self.txtFactionName:setText(factionname)
    else
        self.txtFactionName:setText(tostring(RankZongheViewDlg.curData.factionname))
    end

    local schoolname = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(RankZongheViewDlg.curData.school).name
    self.txtSchool:setText(tostring(schoolname))

    local campname = require "utils.mhsdutils".get_resstring(2795)
    if RankZongheViewDlg.curData.camp == 1 then
        campname = require "utils.mhsdutils".get_resstring(2793)
    elseif RankZongheViewDlg.curData.camp == 2 then
        campname = require "utils.mhsdutils".get_resstring(2794)
    end
    self.txtCamp:setText(campname)

    self.txtRank:setText(tostring(RankZongheViewDlg.curData.rank+1))

    local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(RankZongheViewDlg.curData.shape)
    local strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
    self.imgHead:setProperty("Image",strHead)

    -- 设置当前角色ID

    self.curRoleID = RankZongheViewDlg.curData.roleid
end

function RankZongheViewDlg:HandleClickePetBtn(args)
    if RankZongheViewDlg.curData == nil then
        LogErr("RankZongheViewDlg.curData is nil in RankZongheViewDlg:HandleClickePetBtn")
        return
    end
    local req = require "protocoldef.knight.gsp.ranklist.getrankinfo.cgetroledetailinfo".Create()
    req.infotype = 1
    req.roleid = RankZongheViewDlg.curData.roleid
    LuaProtocolManager.getInstance():send(req)
end

function RankZongheViewDlg:HandleClickeXiakeBtn(args)
    if RankZongheViewDlg.curData == nil then
        LogErr("RankZongheViewDlg.curData is nil in RankZongheViewDlg:HandleClickeXiakeBtn")
        return
    end
    local req = require "protocoldef.knight.gsp.ranklist.getrankinfo.cgetroledetailinfo".Create()
    req.infotype = 2
    req.roleid = RankZongheViewDlg.curData.roleid
    LuaProtocolManager.getInstance():send(req)
end

return RankZongheViewDlg