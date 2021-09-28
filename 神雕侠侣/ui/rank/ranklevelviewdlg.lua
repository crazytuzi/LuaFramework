local Dialog = require "ui.dialog"

local RankLevelViewDlg = {}
setmetatable(RankLevelViewDlg, Dialog)
RankLevelViewDlg.__index = RankLevelViewDlg 

RankLevelViewDlg.curData = nil

local ARMS = 0
local CUFF = 1
local ADORN = 2
local LORICAE = 3
local WAISTBAND = 4
local BOOT = 5
local TIRE = 6
local KITBAG= 7
local EYEPATCH = 8
local RESPIRATOR = 9
local JEWELRY = 6

local function GetSecondType(typeid)
    local n = math.floor(typeid / 0x10)
    return n % 0x10
end

local _instance
function RankLevelViewDlg.getInstance()
    if not _instance then
        _instance = RankLevelViewDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankLevelViewDlg.getInstanceAndShow()
    if not _instance then
        _instance = RankLevelViewDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function RankLevelViewDlg.getInstanceNotCreate()
    return _instance
end

function RankLevelViewDlg.DestroyDialog()
    RankLevelViewDlg.curData = nil 
    if _instance then
        _instance:OnClose() 
        _instance = nil
    end
end

function RankLevelViewDlg.ToggleOpenClose()
    if not _instance then 
        _instance = RankLevelViewDlg:new() 
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function RankLevelViewDlg.GetLayoutFileName()
    return "listdengjiview.layout"
end

function RankLevelViewDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankLevelViewDlg)

    return self
end

function RankLevelViewDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 角色信息

    self.txtRoleID = winMgr:getWindow("listdengjiview/Back/id")
    self.txtName = winMgr:getWindow("listdengjiview/Back/name")
    self.txtLevel = winMgr:getWindow("listdengjiview/Back/level")
    self.txtSchool = winMgr:getWindow("listdengjiview/Back/school")
    self.txtRank = winMgr:getWindow("listdengjiview/rank/text")

    -- 装备栏

    self.txtEquipScore = winMgr:getWindow("listdengjiview/point")
    self.txtJewelryScore = winMgr:getWindow("listdengjiview/ring")

    self.SpriteWnd = winMgr:getWindow("listdengjiview/spriteBack")
    self.EffeectWnd = winMgr:getWindow("listdengjiview/Back/SpriteEffectTop")

    self.vEquip = {}
    self.vEquip[ADORN] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/adorn"))
    self.vEquip[ARMS] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/arms"))
    self.vEquip[CUFF] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/cuff"))
    self.vEquip[WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/waistband"))
    self.vEquip[TIRE] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/tire"))
    self.vEquip[KITBAG] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/kitbag"))
    self.vEquip[LORICAE] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/loricae"))
    self.vEquip[BOOT] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/boot"))
    self.vEquip[EYEPATCH] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/mask"))
    self.vEquip[RESPIRATOR] = CEGUI.toItemCell(winMgr:getWindow("listdengjiview/mask1"))

    self.vEquip[CUFF]:SetBackGroundImage("BaseControl","Cuff")
    self.vEquip[ADORN]:SetBackGroundImage("BaseControl","Accessories")
    self.vEquip[LORICAE]:SetBackGroundImage("BaseControl","Armour")
    self.vEquip[ARMS]:SetBackGroundImage("BaseControl","Weapon")
    self.vEquip[TIRE]:SetBackGroundImage("BaseControl","Head")
    self.vEquip[KITBAG]:SetBackGroundImage("BaseControl","Back")
    self.vEquip[BOOT]:SetBackGroundImage("BaseControl","Shoe")
    self.vEquip[WAISTBAND]:SetBackGroundImage("BaseControl","Belt")
    self.vEquip[EYEPATCH]:SetBackGroundImage("BaseControl","Mask")
    self.vEquip[RESPIRATOR]:SetBackGroundImage("BaseControl","Mask")

    for i = 0, 9 do
        self.vEquip[i]:subscribeEvent("TableClick", RankLevelViewDlg.HandleItemClick, self)
    end

end

function RankLevelViewDlg:RefreshView()
    if RankLevelViewDlg.curData == nil then
        LogErr("RankLevelViewDlg.curData is nil in RankLevelViewDlg:RefreshView")
        return
    end

    -- 设置角色信息

    self.txtRoleID:setText(tostring(RankLevelViewDlg.curData.roleid))
    self.txtName:setText(tostring(RankLevelViewDlg.curData.rolename))
    self.txtLevel:setText(tostring(RankLevelViewDlg.curData.level))

    local schoolname = knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(RankLevelViewDlg.curData.school).name
    self.txtSchool:setText(tostring(schoolname))

    self.txtRank:setText(tostring(RankLevelViewDlg.curData.rank+1))

    -- 设置模型
    local fpConfig = knight.gsp.game.GetCfootprintTableInstance():getRecorder(RankLevelViewDlg.curData.footlogoid)
    if fpConfig then
        GetGameUIManager():AddUIEffect(self.EffeectWnd, fpConfig.effectpath, true)
    else
        GetGameUIManager():RemoveUIEffect(self.EffeectWnd)
    end

    local roleSprite = GetGameUIManager():AddWindowSprite(self.SpriteWnd, RankLevelViewDlg.curData.shape, XiaoPang.XPDIR_BOTTOM, 0, 0, false)

    -- 设置装备栏

    local totalscore = 0
    local jewelryscore = 0

    self.vID = {}

    for i, v in pairs(RankLevelViewDlg.curData.baginfo.items) do
        local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(v.id)
        self.vEquip[v.position]:setID(v.key)
        self.vEquip[v.position]:SetImage(GetIconManager():GetItemIconByID(itemattr.icon))
        self.vID[v.key] = v.id

        -- 在模型上添加武器
        if v.position == ARMS then
            roleSprite:SetSpriteComponent(eSpriteWeapon, v.id)
        end

        local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(v.id)
        local equipColor = equipConfig.equipcolor
        local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipColor)
        GetGameUIManager():RemoveUIEffect(self.vEquip[v.position])
        GetGameUIManager():AddUIEffect(self.vEquip[v.position],colorconfig.effectshow)

        if GetSecondType(itemattr.itemtypeid) ~= JEWELRY then
            local config = GNET.Marshal.OctetsStream(RankLevelViewDlg.curData.tips[v.key])
            local equipObject = require "manager.octets2table.equip"(config)
            totalscore = totalscore + GetLuaEquipScore(v.id, equipObject,  GetSecondType(itemattr.itemtypeid)) --item:GetEquipScore()
        else
            local config = GNET.Marshal.OctetsStream(RankLevelViewDlg.curData.tips[v.key])
            local itemobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
            itemobj:unmarshal(config)
            jewelryscore = jewelryscore + GetLuaEquipScore(v.id, itemobj,  GetSecondType(itemattr.itemtypeid), school)
        end
    end
    local strTotalSorce = require "utils.mhsdutils".get_resstring(1637) .. tostring(totalscore)
    local strJewelryScore = require "utils.mhsdutils".get_resstring(3000) .. tostring(jewelryscore)
    self.txtEquipScore:setText(strTotalSorce)
    self.txtJewelryScore:setText(strJewelryScore)
end

function RankLevelViewDlg:HandleItemClick(args)
    if RankLevelViewDlg.curData == nil then
        LogErr("RankLevelViewDlg.curData is nil in RankLevelViewDlg:HandleItemClick")
        return
    end

    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()
    local e = CEGUI.toMouseEventArgs(args)
    local pt = e.position
    if RankLevelViewDlg.curData.tips[id] then
        local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.vID[id])
        local config = GNET.Marshal.OctetsStream(RankLevelViewDlg.curData.tips[id])
        local pobj
        if GetSecondType(attr.itemtypeid) ~= JEWELRY then
            local config = GNET.Marshal.OctetsStream(RankLevelViewDlg.curData.tips[id])
            pobj = require "manager.octets2table.equip"(config)
        else
            local config = GNET.Marshal.OctetsStream(RankLevelViewDlg.curData.tips[id])
            pobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
            pobj:unmarshal(config)
        end
        local dlg = CToolTipsDlg:GetSingletonDialog()
        local luadlg = require "ui.tips.tooltipsdlg"
        if not luadlg.isPresent() then
            CToolTipsDlg:GetSingletonDialogAndShowIt()
        end
        luadlg.init()
        luadlg.SetTipsItem(attr, pobj, pt.x, pt.y, true, RankLevelViewDlg.curData.School)
        if not luadlg.m_pMainFrame:isVisible() then
            luadlg.m_pMainFrame:setVisible(true)
        end
    end
end

return RankLevelViewDlg