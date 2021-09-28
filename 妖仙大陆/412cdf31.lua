local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local self = {}

function _M:OnEnter()
	
end

function _M:OnExit()

end

local function updateList(data)
    self.sp_show.Scrollable:ClearGrid()

    local function updateItem(gx, gy, node)
        local ib_rank = node:FindChildByEditName('ib_rank',false)
        local lb_rank = node:FindChildByEditName('lb_rank',false)
        local ib_pro = node:FindChildByEditName('ib_pro',false)
        local lb_name = node:FindChildByEditName('lb_name',false)
        local lb_ranknum = node:FindChildByEditName('lb_ranknum',false)
        local lb_norank = node:FindChildByEditName('lb_norank',false)

        if ib_rank~= nil then
            local iconIndex = gy+1 > 4 and 4 or gy+1
            ib_rank.Layout = XmdsUISystem.CreateLayoutFroXml(iconList[iconIndex],LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        end

        lb_ranknum.Text = Util.CSharpStringformat(ranktext,gy+1)

        
    end

    local s = self.cvs_single.Size2D
    self.sp_show:Initialize(s.x,s.y,#data, 1, cvs_single, updateItem,function() end)  
end

local function SwitchPage(sender)
    
end

local ui_names = 
{
    {name = 'tbt_type1'},
    {name = 'tbt_type2'},
    {name = 'tbt_type3'},
    {name = 'tbt_type4'},
    {name = 'sp_show'},
    {name = 'cvs_single'},
    {name = 'cvs_mine'},
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
            	end
        	end
    	end
	end
end

local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/solo/solo_rank.gui.xml')
    initControls(self.menu,ui_names,self)

    Util.InitMultiToggleButton(function (sender)
        SwitchPage(sender)
    end,self.tbt_type1,{self.tbt_type1,self.tbt_type2,self.tbt_type3,self.tbt_type4})

    self.cvs_single.Visible = false
    return self.menu
end

function _M.Create()
    setmetatable(self,_M)
    local node = InitComponent(self)
    return self,node
end

return _M
