local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local self = {}

local function OnEnter()
    local eles = GlobalHooks.DB.Find('SoloRank',{})
    print("OnEnter " .. #eles)

    local function updateItem(gx, gy, cell)
        cell.Visible = true
        local index = gy + 1
        local data = eles[#eles-gy] 
        local lb_grade = cell:FindChildByEditName("lb_grade", true)
        local lb_need = cell:FindChildByEditName("lb_need", true)
        local ib_icon = cell:FindChildByEditName("ib_icon", true)

        lb_grade.Text = data.RankName
        lb_grade.FontColor = GameUtil.RGB2Color(tonumber(data.TextColour, 16))
        lb_need.Text = Util.GetText(TextConfig.Type.SOLO,"needScore") .. data.RankScore

         
         Util.HZSetImage(ib_icon, data.Icon)
    end

    local cvs_single = self.menu:GetComponent("cvs_single")
    local sp_show = self.menu:GetComponent("sp_show")
    cvs_single.Visible = false
    local s = cvs_single.Size2D
    sp_show:Initialize(s.x,s.y,10, 1, cvs_single, updateItem,function() end)


    local  maxPosY = sp_show.Scrollable.Container.Size2D.y - sp_show.Height
    sp_show.Scrollable.Container.Y = -(cvs_single.Height *(#eles - (self.params+1)))
    if -sp_show.Scrollable.Container.Y > maxPosY then
        sp_show.Scrollable.Container.Y = -maxPosY
    end
end

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/solo_grade.gui.xml',tag)
    print("params = " .. params)
    self.params = tonumber(params)

    self.menu:SubscribOnEnter(OnEnter)

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function(sender)
        self.menu:Close()
    end})


    return self.menu
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
