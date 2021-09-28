local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local _5V5Api = require 'Zeus.Model.5v5'
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {}

local function InitUI()
    local UIName = {
        "btn_close",
        "sp_show",
        "cvs_single",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

end


local  function InitList(self)
    local function updateItem(gx, gy, node)
        node.Visible = true
        local data = self.listData[gy+1]
        local lb_result = node:FindChildByEditName("lb_result",true) 
        local lb_num = node:FindChildByEditName("lb_num",true)       
        local lb_killnum = node:FindChildByEditName("lb_killnum",true)   
        local lb_dpsnum = node:FindChildByEditName("lb_dpsnum",true)     
        local lb_treatmentnum = node:FindChildByEditName("lb_treatmentnum",true) 
        local lb_time = node:FindChildByEditName("lb_time",true)  
        local ib_head = node:FindChildByEditName("ib_head",true)   
        local lb_level = node:FindChildByEditName("lb_level",true)  
   
        if data.status == 1 then 
            lb_result.Text = Util.GetText(TextConfig.Type.SOLO, "win")
            lb_result.FontColor = Util.FontColorGreen
        elseif data.status == 2 then
            lb_result.Text = Util.GetText(TextConfig.Type.SOLO, "lose")
            lb_result.FontColor = Util.FontColorRed
        else
            lb_result.Text = Util.GetText(TextConfig.Type.SOLO, "tie")
            lb_result.FontColor = Util.FontColorWhite
        end

        if data.scoreChange > 0 then
            lb_num.Text = "+" .. data.scoreChange
            lb_num.FontColor = Util.FontColorGreen
        elseif data.scoreChange == 0 then
            if data.status == 2 then
                lb_num.Text = "-" .. data.scoreChange
                lb_num.FontColor = Util.FontColorRed
            else
                lb_num.Text = "+" .. data.scoreChange
                lb_num.FontColor = Util.FontColorOrange
            end
        else
            lb_num.Text = data.scoreChange
            lb_num.FontColor = Util.FontColorRed
        end
        lb_killnum.Text = data.killCount
        lb_dpsnum.Text = data.hurt
        lb_treatmentnum.Text = data.treatMent
        lb_time.Text = data.createTime

        Util.SetHeadImgByPro(ib_head,DataMgr.Instance.UserData.Pro)
        local rolelv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
        lb_level.Text = tostring(rolelv)
    end

    local s = self.cvs_single.Size2D
    self.sp_show:Initialize(s.x,s.y,#self.listData, 1, self.cvs_single, updateItem,function() end)
end


local function OnEnter()
    self.menu.Visible = false

    _5V5Api.requestRecordList(function(data)
        self.menu.Visible = true
        self.listData = data.br
        if self.listData and #self.listData>0 then
            InitList(self)
        else
            
        end

    end)

end


local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/5v5/5v5_record.gui.xml',tag)
    InitUI()


    self.menu:SubscribOnEnter(OnEnter)
    self.cvs_single.Visible = false

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
            self.menu:Close()
        end
    end

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
