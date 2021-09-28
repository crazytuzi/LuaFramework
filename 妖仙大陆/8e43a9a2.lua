


local Util   = require 'Zeus.Logic.Util'
local _M = {}
_M.__index = _M

local ui_names = {

    {name = "cvs_main"},

    { name = "lb_shuxing1"},
    { name = "lb_shuxing2"},
    { name = "lb_shuxing3"},
    { name = "lb_shuxing4"},
    { name = "lb_shuxing5"},
    { name = "lb_shuxing6"},
    { name = "lb_shuxing7"},
    { name = "lb_shuxing8"},
    { name = "lb_num00"},
    { name = "lb_num11"},
    { name = "lb_num12"},
    { name = "lb_num13"},
    { name = "lb_num14"},
    { name = "lb_num15"},
    { name = "lb_num16"},
    { name = "lb_num17"},
    { name = "lb_num18"},
    { name = "lb_num21"},
    { name = "lb_num22"},
    { name = "lb_num23"},
    { name = "lb_num24"},
    { name = "lb_num25"},
    { name = "lb_num26"},
    { name = "lb_num27"},
    { name = "lb_num28"},
    { name = "cvs_zhanshi1"},
    { name = "cvs_zhanshi2"},
    { name = "cvs_zhanshi3"},
    { name = "cvs_zhanshi4"},
    { name = "cvs_zhanshi5"},
    { name = "cvs_zhanshi6"},
    { name = "cvs_zhanshi7"},
    { name = "cvs_zhanshi8"},
    { name = "lb_shuxingend"},
  
    
}

local oldValue = {}

local isCreate = true
function _M:Close()
    self:OnExit()
end

local vz = {}
local function ValueCompare( v, num ,attr, txt)
    
    if oldValue[v] == nil then
        oldValue[v]={}
        oldValue[v].name=attr
    end
    if oldValue[v].nums ~= nil and num > oldValue[v].nums then
        table.insert(vz,{name=attr,oldnums=oldValue[v].nums, tempnums=oldValue[v].nums, newnums=num})
    end
    oldValue[v].nums=num
    oldValue[v].txts=txt 
end 

local function SetAttrText(status, index, v, attr, isFormat)
    local txt
    local userdata = DataMgr.Instance.UserData
    if userdata:ContainsKey(status, v) then
        local num = userdata:GetAttribute(v)
        num = num~=nil and num or 0
        if isFormat then
            txt = tostring(num/100) .. '%'
        else
            txt = tostring(num)
        end
        ValueCompare(index,num,attr,txt)
    end
end

local function IsCreate(status,create)
    
    
    if create then
        vz={}
        isCreate = create
    end
    SetAttrText(status, 1, UserData.NotiFyStatus.FIGHTPOWER,"战斗力" )

    local num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.PHY,0)
    num = num~=nil and num or 0
    local phyNum = num
    num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.MAG,0)
    num = num~=nil and num or 0
    local magNum = num

    if magNum > phyNum then
        SetAttrText(status, 2, UserData.NotiFyStatus.MAG,"魔攻:")
    else
        SetAttrText(status, 2, UserData.NotiFyStatus.PHY,"物攻:")
    end

    SetAttrText(status, 3, UserData.NotiFyStatus.HIT,"命中:")
    SetAttrText(status, 4, UserData.NotiFyStatus.CRIT,"暴击:")
    SetAttrText(status, 5, UserData.NotiFyStatus.DODGE,"闪避:")
    SetAttrText(status, 6, UserData.NotiFyStatus.RESCRIT,"抗暴:")
    SetAttrText(status, 7, UserData.NotiFyStatus.AC,"物防:")
    SetAttrText(status, 8, UserData.NotiFyStatus.RESIST,"魔防:")
    SetAttrText(status, 9, UserData.NotiFyStatus.CRITDAMAGE,"暴击伤害:",true)
    SetAttrText(status, 10, UserData.NotiFyStatus.CRITDAMAGERES,"暴伤抵抗:",true)
    
    return #vz>1 and vz[1].newnums>vz[1].oldnums 
end

local isTimeStop = 0
local count = 1
local z = 0
 function initProperties(self)
    isCreate = false
    if #vz>1 then
    self["cvs_main"].Visible = true
    self["cvs_main"].Height = 78 + (#vz * 40)
    self["lb_shuxingend"].Y = 261 + (#vz * 40)
    for i=1,8 do
        self["cvs_zhanshi"..i].Visible = false
    end

    local function setEndAttr()
        self["lb_num00"].Text = vz[1].newnums-vz[1].oldnums
        for i=1,8 do
            
            if i<=#vz then
                if count==i then
                    count = count + 1
                    return
                end
                if count-#vz >= i then
                    self["lb_num2"..i].Text = vz[i].newnums 
                    if count-#vz == i then
                        count = count + 1
                        return
                    end                    
                end
            end
        end
    end


    local  function AddNums( ... )
        
        if z < vz[1].newnums - vz[1].oldnums then 
            z = z + math.max(Mathf.Round((vz[1].newnums-vz[1].oldnums) * 0.05),1) 
            self["lb_num00"].Text = z
        else
            
            self["lb_num00"].Text = vz[1].newnums - vz[1].oldnums
            isTimeStop = isTimeStop + 1
            
        end
        for i=1,8 do
            
            if i<=#vz then
                self["cvs_zhanshi"..i].Visible = true
                self["lb_shuxing"..i].Text = vz[i].name
                self["lb_num1"..i].Text = vz[i].oldnums
                self["lb_num2"..i].Visible = false
                if count==i then
                    count = count + 1
                    return
                end
                if count-#vz >= i then
                    self["lb_num2"..i].Visible = true
                    if vz[i].tempnums < vz[i].newnums then 
                        vz[i].tempnums = vz[i].tempnums + math.max(Mathf.Round((vz[1].newnums-vz[1].oldnums) * 0.05),1)
                        
                        self["lb_num2"..i].Text = vz[i].tempnums
                    else
                        self["lb_num2"..i].Text = vz[i].newnums 
                        isTimeStop = isTimeStop + 1
                        
                    end
                    if count-#vz ==i then
                        count = count + 1
                        return
                    end                    
                end
            else
                self["cvs_zhanshi"..i].Visible = false
            end
        end
        if isTimeStop >= #vz+1 then
            
            setEndAttr()
            self.timer:Stop()                      
            LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
            self.menu:Close()
            end})            
            isTimeStop = 0
            count = 1
            z=0
            vz={}
        end
    end 
    self.timer=Timer.New(AddNums, 0.08, -1)
    self.timer:Start()
end
end

function _M:OnEnter()
    if isCreate and IsCreate(UserData.NotiFyStatus.ALL) then
        
        self.menu.Visible = true
        initProperties(self)
    else
        self.menu:Close()
    end
end

function _M:OnExit()
    if self.timer then
        self.timer:Stop()
    end
    self.menu.Visible = false
end

function _M:OnDispose()

end

local function InitComponent(self, tag)
    self.menu = LuaMenuU.Create('xmds_ui/common/common_zhandouli.gui.xml',tag)
    self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.IsInteractive = true
    
    
    

    self.menu.Visible = false
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu.Enable = false
    self.menu:SubscribOnExit(function ()
        self:OnExit()
    end)
    self.menu:SubscribOnEnter(function ()
        self:OnEnter()
    end)
    self.menu:SubscribOnDestory(function ()
           self = nil
    end)
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end
_M.IsCreate = IsCreate
return _M

