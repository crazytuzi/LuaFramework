local Util   = require 'Zeus.Logic.Util'
local _M = {}
_M.__index = _M

local ui_names = {
    {
        name = "btn_close",
        click = function(self)
            self:Close();
        end
    },
    {name = "sp_pro"},
    {name = "cvs_breakthrough_pro"},
    {name = "cvs_addition_single1"},
    {name = "cvs_addition_single2"},
    {name = "cvs_addition_single3"},
}

function _M:Close()
    self.menu:Close()
end

local function setSumAdd(node,name,num)
    local lb_proterty_name = node:FindChildByEditName('lb_proterty_name',false)
    local lb_property_num = node:FindChildByEditName('lb_property_num',false)

    lb_proterty_name.Text = name
    lb_property_num.Text = "+" .. num
end

function _M:OnEnter()
    local userdata = DataMgr.Instance.UserData
    local  listdata = GlobalHooks.DB.Find("UpLevelExp",{})
    local num = userdata:GetAttribute(UserData.NotiFyStatus.REALM)
    num = num == nil and 0 or num
    
    local function UpdateListItem(gx,gy,node)
        node.Visible = true
        local index = gy + 1
        local pro1 = listdata[index].Max1
        local pro2 = listdata[index].Max2
        local pro3 = listdata[index].Max3
        local lb_wendaoLV = node:FindChildByEditName('lb_wendaoLV',false)
        local lb_pro = node:FindChildByEditName('lb_pro',false)
        local lb_gained = node:FindChildByEditName('lb_gained',false)
        local ib_lock = node:FindChildByEditName('ib_lock',false)

        if index > 1 then
            pro1 = pro1 - listdata[index-1].Max1
            pro2 = pro2 - listdata[index-1].Max2
            pro3 = pro3 - listdata[index-1].Max3
        end
        lb_wendaoLV.Text =  listdata[index].ClassName .. listdata[index].UPName
        lb_wendaoLV.FontColorRGBA = Util.GetQualityColorRGBA(listdata[index].Qcolor)

        lb_pro.Text = listdata[index].Prop1 .. "+" .. pro1 .. ",  " .. listdata[index].Prop2 .. "+" .. pro2 .. ",  " ..listdata[index].Prop3 .. "+" .. pro3

        if index <= num then
            lb_gained.Visible = true
            ib_lock.Visible = false
            lb_pro.IsGray = false
        else
            lb_gained.Visible = false
            ib_lock.Visible = true
            lb_pro.IsGray = true
        end

    end

    local s = self.cvs_breakthrough_pro.Size2D
    self.sp_pro:Initialize(s.x,s.y,math.ceil(#listdata-1),1,self.cvs_breakthrough_pro,UpdateListItem,function() end)

    if num > 0 then
        setSumAdd(self.cvs_addition_single1,listdata[num].Prop1,listdata[num].Max1)
        setSumAdd(self.cvs_addition_single2,listdata[num].Prop2,listdata[num].Max2)
        setSumAdd(self.cvs_addition_single3,listdata[num].Prop3,listdata[num].Max3)
    else
        setSumAdd(self.cvs_addition_single1,listdata[1].Prop1,0)
        setSumAdd(self.cvs_addition_single2,listdata[1].Prop2,0)
        setSumAdd(self.cvs_addition_single3,listdata[1].Prop3,0)
    end

    local  maxPosY = self.sp_pro.Scrollable.Container.Size2D.y - self.sp_pro.Size2D.y
    self.sp_pro.Scrollable.Container.Y = -(s.y *(num - 1))
    if -self.sp_pro.Scrollable.Container.Y > maxPosY then
        self.sp_pro.Scrollable.Container.Y = -maxPosY
    end
end

function _M:OnExit()

end

function _M:OnDispose()

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/character/property_look.gui.xml',tag)
    

    Util.CreateHZUICompsTable(self.menu, ui_names, self)

    self.cvs_breakthrough_pro.Visible = false
    self.menu:SubscribOnExit(function ()
        self:OnExit()
    end)
    self.menu:SubscribOnEnter(function ()
        self:OnEnter()
    end)
    self.menu:SubscribOnDestory(function ()
        
    end)
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end

return _M

