local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local FubenAPI          = require "Zeus.Model.Fuben"
local FubenUtil         = require "Zeus.UI.XmasterFuben.FubenUtil"

local self = {
    menu = nil,
}

local function ItemClick(sender)
    local idx = sender.UserTag
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFubenSecond, 0)
    lua_obj.SetFubenInfo(self.FubelList[idx])
end

local function RefreshFubenItem(gx, gy, node)
    local idx = gy*2 + gx + 1
    node.UserTag = idx
    node:FindChildByEditName("btn_click", true).UserTag = idx
    node.Visible = idx <= self.itemCount

    if idx > self.itemCount  then return end

    local info = self.FubelList[idx]
    local isOk = FubenUtil.setEnterCondition(node, "lb_level", info)
    node:FindChildByEditName("btn_click", true).Enable = isOk > 0
    node:FindChildByEditName("lb_name", true).Text = info.Name
    local ib_mappic = node:FindChildByEditName("ib_mappic",true)
    local ib_bosspic = node:FindChildByEditName("ib_bosspic",true)
    Util.HZSetImage(ib_mappic, "dynamic_n/dungeonsbanner/" .. info.MapPic .. ".png",false,LayoutStyle.IMAGE_STYLE_BACK_4)
    Util.HZSetImage(ib_bosspic, "dynamic_n/dungeon/" .. info.BossPic .. ".png",false,LayoutStyle.IMAGE_STYLE_BACK_4)
    
    

    node:FindChildByEditName("img_zhezhao",true).Visible = isOk == 0

    node:FindChildByEditName("lb_go", true).Text = (isOk == 1 and Util.GetText(TextConfig.Type.FUBEN, "noprofit")) or (isOk == 2 and Util.GetText(TextConfig.Type.FUBEN, "goto")) or Util.GetText(TextConfig.Type.FUBEN, "notopen1")
    node:FindChildByEditName("lb_go", true).FontColor = (isOk > 0 and Util.FontColorBlue) or Util.FontColorRed
end

local function InitFubenCanAndData(node)
    node.Visible = true
    local selectBtn = node:FindChildByEditName("btn_click", true)
    selectBtn.TouchClick = function(sender)
        ItemClick(sender)
    end
end

local function GetFirstLimitFubenIndex()
    local firstLimitIndex = 0
    for i=1,self.itemCount do
        local text, isOk = FubenUtil.formatCondition(self.FubelList[i])
        if isOk > 0 then
            firstLimitIndex = i
            return firstLimitIndex
        end
    end
    return firstLimitIndex
end

local function InitFubenList()
    self.itemCount = #self.FubelList
    local rows = math.ceil(self.itemCount/2)
    self.sp_list:Initialize(self.cvs_dungeon_choose.Width + 10, self.cvs_dungeon_choose.Height + 10, rows, 2, self.cvs_dungeon_choose, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshFubenItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitFubenCanAndData))
end

local function OnExit()

end

local function OnEnter()
    InitFubenList()
    
    local index = math.floor((GetFirstLimitFubenIndex()-1)/2)
    if index > 0 then
        self.sp_list.Scrollable:LookAt(Vector2.New(0, index*(self.cvs_dungeon_choose.Height + 10)))
    else
        self.sp_list.Scrollable:LookAt(Vector2.New(0, 0))
    end
end

local function InitUI()
    local UIName = {
        
        "sp_list",
        "cvs_dungeon_choose",
        "btn_tips",
        "cvs_detail",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_dungeon_choose.Visible = false
    self.cvs_detail.Visible = false
    
    
    

    self.btn_tips.event_PointerDown = function()
        self.cvs_detail.Visible = true
    end
    self.btn_tips.event_PointerUp = function ()
        self.cvs_detail.Visible = false
    end

    self.FubelList = FubenAPI.getAllLimitFubenList()
end

local function InitCompnent(params)
    InitUI()

    self.menu.Enable = false
    self.menu.mRoot.Enable = false
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function SetVisible(bool)
    if self ~= nil and self.menu ~= nil then
        self.menu.Visible = bool
    end
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/dungeon/jixiandungeon.gui.xml", GlobalHooks.UITAG.GameUIFubenLimit)
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end


local function initial()
    
end

_M.SetVisible = SetVisible

return {Create = Create, initial = initial}
