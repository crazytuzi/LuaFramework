local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local FateModel     = require 'Zeus.Model.Fate'

local function InitList(self)
	
	local function UpdateListItem(gx,gy,node)
        local  index = gy+1
        node.Visible = true
        local  itemData = self.datas[self.infoList[index].configId]
        local ib_icon = node:FindChildByEditName('ib_icon',false)
        local lb_cross = node:FindChildByEditName('lb_cross',false)
        local lb_help = node:FindChildByEditName('lb_help',false)
        local lb_get_num = node:FindChildByEditName('lb_get_num',false)

        Util.HZSetImage(ib_icon,itemData.Icon)
        lb_cross.Text = itemData.Event
        lb_help.Text = itemData.BriefDesc
        lb_get_num.Text =  self.infoList[index].todayRecive ..  "/".. self.infoList[index].todayLimite 
        node.UserTag = index
        node.UserData = node.X .. "," ..node.Y
        node.event_PointerDown = function (sender) 
            sender.X = sender.X + sender.Width*0.05
            sender.Y = sender.Y + sender.Height*0.05
            sender.Scale = Vector2.New(0.9, 0.9)
        end

        node.event_PointerUp = function (sender)
            local tmp = string.split(sender.UserData,',')

            sender.X = tonumber(tmp[1])
            sender.Y = tonumber(tmp[2])
            sender.Scale = Vector2.New(1, 1)
        end

        node.TouchClick = function (sender)
        	if self.cvs_detail.Visible and self.cvs_detail.UserTag == sender.UserTag  then
        		self.cvs_detail.Visible = false
                self.cvs_tipTouch.Visible = false
        		return
        	end
        	self.cvs_detail.Visible = true
            self.cvs_tipTouch.Visible = true
        	self.cvs_detail.UserTag = sender.UserTag
        	self.lb_location.Text = self.datas[self.infoList[sender.UserTag].configId].Event
        	self.tb_deatil.Text  = self.datas[self.infoList[sender.UserTag].configId].DetailDesc
        	self.lb_max_num.Text = self.datas[self.infoList[sender.UserTag].configId].NumLimit

        	local pos = node:LocalToGlobal()
        	local pos1 = self.cvs_detail.Parent:GlobalToLocal(pos,true)

        	self.cvs_detail.Y = pos1.y - node.Size2D.y*0.5
        end
    end

	local s = self.cvs_get_single.Size2D
    self.sp_get:Initialize(s.x,s.y,#self.infoList,1,self.cvs_get_single,UpdateListItem,function() end)
    self.sp_get.Scrollable.Enable = false
end


function _M:OnEnter()
    FateModel.requestFateInfo(function(moneyNum,infoList)
        self.moneyNum = moneyNum
        self.infoList = infoList
        self.lb_number.Text = moneyNum
        InitList(self)
    end)
end

function _M:OnExit()

end

local ui_names = 
{
	{name = 'lb_number'},
	{name = 'btn_go_shop'},
    {name = 'sp_get'},
    {name = 'cvs_get_single'},
    {name = 'cvs_detail'},
    {name = 'cvs_main'},
    {name = 'lb_location'},
    {name = 'tb_deatil'},
    {name = 'lb_max_num'},
    {name = 'cvs_tipTouch'},
    {name = 'btn_go_shop',click = function(self)
        EventManager.Fire('Event.Goto', {id = "FateShop"})
    end}
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
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/activity/fate.gui.xml')
    initControls(self.menu,ui_names,self)
    self.cvs_get_single.Visible = false
    self.cvs_detail.Visible = false

    self.datas = {}
    local datas = GlobalHooks.DB.Find('Fate',{})
    for i,v in ipairs(datas) do
        self.datas[v.ID] = v
    end

    self.cvs_detail.UserTag = 0
    self.cvs_tipTouch.TouchClick = function()
    	self.cvs_detail.Visible = false
    	self.cvs_detail.UserTag = 0
        self.cvs_tipTouch.Visible = false
    end

    self.cvs_detail.TouchClick = function()
    	self.cvs_detail.Visible = false
    	self.cvs_detail.UserTag = 0
        self.cvs_tipTouch.Visible = false
    end

    return self.menu
end

function _M.Create()
    local ret = {}
    setmetatable(ret,_M)
    local node = InitComponent(ret)
    return ret,node
end

return _M
