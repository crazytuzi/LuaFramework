local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local SoloAPI = require "Zeus.Model.Solo"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {}

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_win",
        "lb_lose",
        "lb_chance",
        "lb_maxwin",
        "lb_maxlose",
        "lb_yixian",
        "lb_yujian",
        "lb_canglang",
        "lb_linghu",
        "lb_shenjian",
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
        local data = self.listData.s2c_batttleList[gy+1]
  
  
  
  
  
  
  
  
        local ib_win = node:FindChildByEditName("ib_win",true)
        local ib_lose = node:FindChildByEditName("ib_lose",true)
        local lb_menum = node:FindChildByEditName("lb_menum",true)
        local ib_playerpro = node:FindChildByEditName("ib_playerpro",true)
        local lb_playername = node:FindChildByEditName("lb_playername",true)
        local lb_ally = node:FindChildByEditName("lb_ally",true)
        local lb_playernum = node:FindChildByEditName("lb_playernum",true)
        local lb_aptitude = node:FindChildByEditName("lb_aptitude",true)
        local lb_time = node:FindChildByEditName("lb_time",true)
        local btn_show = node:FindChildByEditName("btn_show",true)

        if data.result == 1 then
            ib_win.Visible = true
            ib_lose.Visible = false
        elseif data.result == 2 then
            ib_win.Visible = false
            ib_lose.Visible = true
        else
            ib_win.Visible = false
            ib_lose.Visible = false
        end

        lb_menum.Text = data.score
        
        Util.SetIconImagByPro(ib_playerpro,data.vsPro)
        lb_playername.Text = data.vsName
        lb_ally.Text = data.vsGuildName
        lb_playernum.Text = data.vsScore
        if data.scoreChange > 0 then
            lb_aptitude.Text = "+" .. data.scoreChange
        else
            lb_aptitude.Text = data.scoreChange
        end
        lb_time.Text = ServerTime.GetCDStrCut(ServerTime.GetServerUnixTime() - data.battleTime/1000)

        btn_show.TouchClick = function()
            
        end
    end

    local s = self.cvs_single.Size2D
    self.sp_show:Initialize(s.x,s.y,#self.listData.s2c_batttleList, 1, self.cvs_single, updateItem,function() end)
end


local function OnEnter()
    self.menu.Visible = false

    SoloAPI.requsetBattleRecord(function(data)
        self.listData = data
        print("self.listData " .. PrintTable(self.listData))
        self.lb_canglang.Text =  string.format("%.2f", data.s2c_canglang / 100) .. '%' 
        self.lb_yixian.Text =  string.format("%.2f", data.s2c_yixian / 100) .. '%' 
        self.lb_yujian.Text =  string.format("%.2f", data.s2c_yujian / 100) .. '%' 
        self.lb_linghu.Text =  string.format("%.2f", data.s2c_linghu / 100) .. '%' 
        self.lb_shenjian.Text =  string.format("%.2f", data.s2c_shenjian / 100) .. '%' 

        if self.listData.s2c_batttleList~=nil and #self.listData.s2c_batttleList>0 then

            InitList(self)
        end
        self.menu.Visible = true
    end)

end

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/solo_record.gui.xml',tag)
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

function _M:setMyInfo(myInfo)
    self.lb_win.Text = myInfo.winTotalTimes
    self.lb_lose.Text = myInfo.loseTotalTimes
    self.lb_chance.Text = (myInfo.battleTimes~=0 and string.format("%.2f", myInfo.winTotalTimes*100 / myInfo.battleTimes) or "0.00") .. '%'
    self.lb_maxwin.Text = myInfo.maxContWinTimes
    self.lb_maxlose.Text = myInfo.maxContLoseTimes
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
