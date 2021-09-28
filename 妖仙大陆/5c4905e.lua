local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local self = {}
local prizeItems = {}

function _M.AwardBoxInfo(itemList,title)
    self.lb_boxname.Text = title

    local item_counts = #itemList
    self.sp_show.Scrollable:ClearGrid()
    if self.sp_show.Rows <= 0 then
        local cs = self.cvs_single.Size2D
        self.sp_show:Initialize(cs.x,cs.y,item_counts,1,self.cvs_single,
        function (gx,gy,node)
            local itemInfo = itemList[gy+1]
            local lb_name = node:FindChildByEditName('lb_name',false)
            local lb_num = node:FindChildByEditName('lb_num',false)
            local cvs_icon = node:FindChildByEditName('cvs_icon',false)

            local item = Util.ShowItemShow(cvs_icon, itemInfo.icon, itemInfo.qColor, 1)
            Util.NormalItemShowTouchClick(item,itemInfo.code,false)

            lb_name.Text = itemInfo.name
            lb_name.FontColorRGBA = Util.GetQualityColorRGBA(itemInfo.qColor)  

            lb_num.Text = itemInfo.groupCount

        end,function () end)
    else
        self.sp_show.Rows = item_counts
    end 
end

local function InitUI()
    local UIName = {
    	"btn_close",
        "lb_boxname",
        "sp_show",
        "cvs_single",
        "btn_ receive",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_single.Visible = false
end

local function OnEnter()

end

local function OnExit()

end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/welfare/qiandao_box.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
  
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function() self.menu:Close() end})

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
