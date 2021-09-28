local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Team = require "Zeus.Model.Team"
local ItemModel = require 'Zeus.Model.Item'
local DemonTower = require "Zeus.Model.DemonTower"
local Leaderboard = require "Zeus.Model.Leaderboard"
local DisplayUtil = require "Zeus.Logic.DisplayUtil"
local ServerTime = require "Zeus.Logic.ServerTime"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"

local self = {
    
}

local function FindEquipListItem(self,controlName)
    local child_list = self.sp_type.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        if v.Name == controlName then
            return v
        end
    end
    return nil
end

local function UpdatePageRewards(sender)
    local id = sender.UserTag
    DemonTower.GetDemonTowerInfoRequest(id,function (data)
        self.DemonTowerInfo = data
        self.lb_name1.Text = ""
        self.lb_date1.Text = ""
        self.lb_name2.Text = ""
        self.lb_date2.Text = ""
        self.lb_name3.Text = ""
        self.lb_date3.Text = ""
        if self.DemonTowerInfo.DemonTowerFloorInfo.firstPlayerName ~= nil then  
            self.lb_name1.Text = self.DemonTowerInfo.DemonTowerFloorInfo.firstPlayerName
            self.lb_date1.Text =  os.date("%Y-%m-%d",self.DemonTowerInfo.DemonTowerFloorInfo.firstPlayerDate/1000)
        end
        if self.DemonTowerInfo.DemonTowerFloorInfo.fastPlayerName ~= nil then
            self.lb_name2.Text = self.DemonTowerInfo.DemonTowerFloorInfo.fastPlayerName
            self.lb_date2.Text = ServerTime.GetTimeStr(self.DemonTowerInfo.DemonTowerFloorInfo.fastPlayerTime)
        end
        if self.DemonTowerInfo.DemonTowerFloorInfo.myFastTime ~= nil then 
            self.lb_name3.Text =  DataMgr.Instance.UserData.Name
            self.lb_date3.Text = ServerTime.GetTimeStr(self.DemonTowerInfo.DemonTowerFloorInfo.myFastTime)
        end
        self.lb_power.Text = self.DemonTowerInfo.fcValue
        if self.DemonTowerInfo.fcValue > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.FIGHTPOWER) then
            self.lb_power.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
        else
            self.lb_power.FontColor = GameUtil.RGBA2Color(0x00cc00ff)
        end
        self.cvs_hide.Visible = self.DemonTowerInfo.maxFloor >= self.DemonTowerInfo.DemonTowerFloorInfo.floorId
        self.lb_tips2.Visible = self.DemonTowerInfo.maxFloor < self.DemonTowerInfo.DemonTowerFloorInfo.floorId
    end)
    local firstReward = string.split(self.firstRewardList[id],";")
    if firstReward ~= nil then
        self.sp_list1:Initialize(self.cvs_reward1.Width+10, self.cvs_reward1.Height, 1, #firstReward, self.cvs_reward1,
          function(x, y, cell)
              local index = x + 1
              local reward = string.split(firstReward[index],":")
              local code = reward[1]
              local it = GlobalHooks.DB.Find("Items",code)
              cell.Enable = true
              cell.EnableChildren = true
              cell.Visible = true
              local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor,reward[2],true)
              Util.NormalItemShowTouchClick(itshow,code,false)
          end,
          function()
    
          end
         )
    end

    local swpeerReward = string.split(self.swpeerRewardList[id],";")
    if swpeerReward ~= nil then
        self.sp_list2:Initialize(self.cvs_reward2.Width+10, self.cvs_reward2.Height, 1, #swpeerReward, self.cvs_reward2,
          function(x, y, cell)
              local index = x + 1
              local reward = string.split(swpeerReward[index],":")
              local code = reward[1]
              local it = GlobalHooks.DB.Find("Items",code)
              cell.Enable = true
              cell.EnableChildren = true
              cell.Visible = true
              local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor,reward[2],true)
              Util.NormalItemShowTouchClick(itshow,code,false)
          end,
          function()
    
          end
         )
    end

    local itemList = {}
    local list = string.split(self.weekRewardList[id], ';')
    for k,v in ipairs(list) do
        local item = string.split(v, ':')
        itemList[k] = {code = item[1], groupCount = item[2]}
    end
    self.tbt_chest.Enable = true
    self.tbt_chest.EnableChildren = true
    self.tbt_chest.TouchClick = function()
        EventManager.Fire('Event.OnPreviewItems',{items = itemList})
    end

end

local function stopCdLabel()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local function RefreshDemonTowerInfo()
    self.firstRewardList = {}
    self.swpeerRewardList = {}
    self.weekRewardList = {}
    self.floorList = {}
    local infoData = GlobalHooks.DB.Find("DropList",{})
    for i=1,#infoData do
        table.insert(self.firstRewardList,infoData[i].FirstReward)
        table.insert(self.swpeerRewardList,infoData[i].ItemView)
        table.insert(self.floorList,infoData[i].FloorNo)
        table.insert(self.weekRewardList,infoData[i].WeekReward)
    end

    local di = Util.GetText(TextConfig.Type.SOLO, "di")
    local ceng = Util.GetText(TextConfig.Type.SOLO, "ceng")

    self.sp_type:Initialize(self.cvs_item.Width, self.cvs_item.Height+2, #self.floorList,1, self.cvs_item, 
      function(x, y, cell)
        local index = y + 1
        local tbt_subtype = cell:FindChildByEditName("tbt_subtype",true)
        local ib_subtype2 = cell:FindChildByEditName("ib_subtype2",true)
        local lb_suo = cell:FindChildByEditName("lb_suo",true)
        local ib_suo = cell:FindChildByEditName("ib_suo",true)
        ib_subtype2.Visible = index % 5 == 0
        ib_suo.Visible = self.DemonTowerInfo.maxFloor < index
        lb_suo.Text = di .. index .. ceng

        cell.Name = "cell" .. index
        tbt_subtype.UserTag = index

        tbt_subtype.TouchClick = function(sender)
            sender.IsChecked = true
            sender.Enable = false
            if self.selectName then
                local node = FindEquipListItem(self,self.selectName)
                if node then
                    local btn = node:FindChildByEditName("tbt_subtype",false)
                    if btn then
                        btn.IsChecked = false
                        btn.Enable = true
                    end
                end
            end
           self.selectName = cell.Name
           UpdatePageRewards(sender)
        end

        if self.selectName then
            tbt_subtype.IsChecked = self.selectName == cell.Name
            tbt_subtype.Enable = self.selectName ~= cell.Name
        end
      end,
      function()
      end
    )

    DisplayUtil.lookAt(self.sp_type,self.DemonTowerInfo.maxFloor,false)

    local function format(cd)
        if cd <= 0 then
            stopCdLabel()
        else
            local node = FindEquipListItem(self,"cell" .. self.DemonTowerInfo.maxFloor)
            if node then
                local btn = node:FindChildByEditName("tbt_subtype",false)
                if btn then
                    stopCdLabel()
                    self.selectName = node.Name
                    btn.IsChecked = true
                    btn.Enable = false
                    UpdatePageRewards(btn)
                end
            end
        end
    end
    self.CDLabelExt = CDLabelExt.New(nil,10,format) 
    self.CDLabelExt:start()

    
    self.lb_cz_num.Text = self.DemonTowerInfo.sweepCountLeft .. "/" .. self.DemonTowerInfo.sweepCountMax
    if self.DemonTowerInfo.sweepCountLeft <= 0 then
        self.lb_cz_num.FontColor = GameUtil.RGBA2Color(0xf43a1cff)
    else
        self.lb_cz_num.FontColor = GameUtil.RGBA2Color(0x00cc00ff)
    end
end

local function ReqDemonTowerInfo()
    self.DemonTowerInfo = {}
    DemonTower.GetDemonTowerInfoRequest(0,function (data)
        self.DemonTowerInfo = data
        RefreshDemonTowerInfo()
    end)
end

local function OnExit()
    self.DemonTowerInfo = nil
    stopCdLabel()
end

local function OnEnter()
    self.selectName = nil
    self.maxSelectName = nil

    ReqDemonTowerInfo()
    self.btn_saodang.TouchClick = function(sender)
        if self.DemonTowerInfo.maxFloor <= 1 then
            local tips = Util.GetText(TextConfig.Type.FUBEN, 'saodangTips2')
            GameAlertManager.Instance:ShowNotify(tips)
            return
        elseif self.DemonTowerInfo.sweepCountLeft <= 0 then
            local tips = Util.GetText(TextConfig.Type.FUBEN, 'saodangTips')
            GameAlertManager.Instance:ShowNotify(tips)
            return
        else
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIDemonTowerSweep, 0)
            self.menu:Close()
        end
    end

    self.btn_enter.TouchClick = function(sender)
        if DataMgr.Instance.TeamData.HasTeam and DataMgr.Instance.TeamData.MemberCount > 1 then
            local tips = Util.GetText(TextConfig.Type.FUBEN, 'cannotReqWithTeam')
            GameAlertManager.Instance:ShowNotify(tips)
            return
        else
            DemonTower.StartDemonTowerRequest(self.DemonTowerInfo.DemonTowerFloorInfo.floorId)
        end
    end

    self.btn_rank.TouchClick = function(sender)
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard,0,Leaderboard.LBType.DEMONTOWER)
    end
end

local function SetVisible(bool)
    if self ~= nil and self.menu ~= nil then
        self.menu.Visible = bool
    end
end

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_power",
        "lb_cz_num",
        "btn_enter",
        "btn_saodang",
        "btn_rank",
        "sp_type",
        "cvs_item",
        "ob_des",
        "sp_list1",
        "cvs_reward",
        "sp_list2",
        "cvs_reward2",
        "cvs_reward1",
        "lb_name1",
        "lb_name2",
        "lb_date1",
        "lb_date2",
        "lb_name3",
        "lb_date3",
        "tbt_chest",
        "cvs_hide",
        "lb_tips2",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_item.Visible = false

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end
end

local function InitCompnent(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/demontower/tower.gui.xml", tag)
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
    end)
end

local function Create(tag,params)
    setmetatable(self, _M)
    InitCompnent(tag,params)
    return self
end

_M.SetVisible = SetVisible

return {Create = Create}
