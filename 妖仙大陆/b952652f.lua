


local Util = require 'Zeus.Logic.Util'
local _M = {
    jumpNodes = nil
}
_M.__index = _M

local ui_names = {
    {name = "ib_getmoney_icon"},
    {name = "lb_getmoeny_name"},
    {name = "tb_getmoney_detail"},
    {name = "sp_get_way"},
    {name = "cvs_gt_single"}
}

function _M.CreateCurrencyData(cfgData)
    local currency = {}
    currency.cfgData = cfgData
    return currency
end

local function createJumpNode(self,data)
    local ctrl = self.cvs_gt_single:Clone()
    ctrl.Visible = true
    local lb_gt_name = ctrl:FindChildByEditName("lb_gt_name",false)
    local btn_gt_go = ctrl:FindChildByEditName("btn_gt_go",false)
    lb_gt_name.Text = data.Source
    if data.IsJump > 0 then
        btn_gt_go.Visible = true
        btn_gt_go.event_PointerClick = function()
            if(data.JumpTo == "Charge") then
                 GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0, "pay")
            end
        end
    else
        btn_gt_go.Visible = false
    end
    return ctrl
end

local function bindValue(self,currency)
    if currency then
        local cfgData = currency.cfgData
        if(cfgData) then
            self.lb_getmoeny_name.Text = cfgData.Name
            Util.HZSetImage(self.ib_getmoney_icon,cfgData.Icon)
            self.tb_getmoney_detail.UnityRichText = cfgData.Desc
            if self.jumpNodes then
                for k,v in pairs(self.jumpNodes) do
                    self.sp_get_way:RemoveNormalChild(v,true)
                end
            end
            self.jumpNodes = {}
            if cfgData.Source then
                local ctrl = createJumpNode(self,cfgData)
                table.insert(self.jumpNodes,ctrl)
                self.sp_get_way:AddNormalChild(ctrl)
            end
        else
            self.menu.Visible = false
        end
    else
        self.menu.Visible = false
    end
    
end

function _M:Open(currency)
    self.menu.Visible = true
    bindValue(self,currency)
end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function InitComponent(self,parent)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/bag/bag_currency_tip.gui.xml')
    self.menu.Enable = true
    self.menu.IsInteractive = true
    initControls(self.menu,ui_names,self)
    if(parent) then
        parent:AddChild(self.menu)
    end
    local function touch()
        self.menu.Visible = false
    end
    self.menu.event_PointerClick = touch
    self.cvs_gt_single.Visible = false
end

function _M.Create(parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,parent)
    return ret
end

return _M

