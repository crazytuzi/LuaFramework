local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Team = require "Zeus.Model.Team"
local ItemModel = require 'Zeus.Model.Item'
local FubenAPI = require "Zeus.Model.Fuben"
local TeamUtil = require "Zeus.UI.XmasterTeam.TeamUtil"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"

local self = {
    menu = nil,
}

local itemCanPos = {
    {220},
    {160,280},
    {120,220,320},
    {70,170,270,370},
}

local function EnterFubenReq(mode)
    local teamData = DataMgr.Instance.TeamData
    local mapId = self.hardDetail[mode].mapId
    if teamData.HasTeam == true and DataMgr.Instance.TeamData.MemberCount > 1 then
        if mode == 1 then
            local tips = Util.GetText(TextConfig.Type.FUBEN, 'cannotReqWithTeam')
            GameAlertManager.Instance:ShowNotify(tips)
            return
        end
    end

    FubenAPI.requestEnterFuben(mapId)
end

local function CreateTeamBtnClick()
    
    local ID = TeamUtil.findTargetIdByMapId(self.SelectMapId)

    if DataMgr.Instance.TeamData.HasTeam then
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamMain, 0, "mineTeam|find|"..tostring(ID)..","..tostring(1))
    else
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamMain, 0, "platform|find|"..tostring(ID)..","..tostring(1))
    end

    
    local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
    local node1,lua_obj1 = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIFuben)
    if  lua_obj ~= nil and lua_obj1 ~= nil then
        lua_obj.SetVisible(false)
        lua_obj1.SetVisible(false)
    end
end


local function SetProfitTimes(data)
    local function SetProfitText(num)
        self.lb_wenben.Text = Util.GetText(TextConfig.Type.FUBEN, "profitTimes", num)
        if self.hasProfit then
            self.lb_wenben.FontColor = (num > 0 and Util.FontColorGreen) or Util.FontColorRed
        else
            
            self.lb_wenben.FontColor = Util.FontColorRed
        end

        for i,v in ipairs(self.hardDetail) do
            v.remainTimes = num
        end
    end

    SetProfitText(data.remainTimes)

    self.btn_buy.TouchClick = function(sender)
        self.cvs_buymore.Visible = not self.cvs_buymore.Visible
    end

    self.btn_buy.TouchClick = function(sender)
        self.cvs_buymore.Visible = not self.cvs_buymore.Visible
        if self.cvs_buymore.Visible then
            local bag_data = DataMgr.Instance.UserData.RoleBag
            local vItem = bag_data:MergerTemplateItem("dungeonprofit")
            local x = (vItem and vItem.Num) or 0

            local itemCode = "dungeonprofit"
            local it = GlobalHooks.DB.Find("Items",itemCode)
            Util.ShowItemShow(self.ib_icon,it.Icon,it.Qcolor,x,true)

            self.btn_none.Visible = x <= 0
            self.btn_use.Visible = x > 0

            self.btn_none.TouchClick = function(sender)
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, itemCode)
                self.cvs_buymore.Visible = false
            end
            self.btn_use.TouchClick = function(sender)
                FubenAPI.AddProfitRequest(self.fubenInfo.TemplateID, function ()
                    SetProfitText(data.remainTimes+1)
                    self.cvs_buymore.Visible = false
                end)
            end
        end
    end
end

local function RefreshHardDetail(index, data)
    self.SelectMapId = self.hardDetail[index].mapId
    self.tb_desc.UnityRichText = self.fubenModes[index].MapDesc
    SetProfitTimes(data)

    if data.awardItems ~= nil and #data.awardItems > 0 then
        for i,v in ipairs(data.awardItems) do
            self.dropCans[i].Visible = true
            self.dropCans[i].X = itemCanPos[#data.awardItems][i]
            
            
            
            
            local iconCan = self.dropCans[i]:FindChildByEditName("cvs_icon", true)
                    
            local detail = ItemModel.GetItemDetailByCode(data.awardItems[i].code)
            
            local itshow = Util.ShowItemShow(iconCan,data.awardItems[i].icon,data.awardItems[i].qColor)
            Util.NormalItemShowTouchClick(itshow,data.awardItems[i].code,false)
        end
    end

    self.btn_organize.TouchClick = function(sender)
        CreateTeamBtnClick()
    end

    self.btn_goto.TouchClick = function(sender)
        EnterFubenReq(index)
    end

    self.btn_goto_solo.TouchClick = function(sender)
        EnterFubenReq(index)
    end
end

local function FubenModeClick(sender)
    for i=1,4 do
        self.dropCans[i].Visible = false
    end
    
    if self.CurSelect ~= nil and self.CurSelect ~= sender then
        self.CurSelect.IsChecked = false
        self.CurSelect.Enable = true
    end
    self.CurSelect = sender
    self.CurSelect.IsChecked = true
    self.CurSelect.Enable = false

    local idx = sender.UserTag
    self.btn_goto_solo.Visible = idx == 1
    self.btn_goto.Visible = idx == 2
    self.btn_organize.Visible = idx == 2
    self.ib_discount.Visible = idx == 2
    self.lb_tips.Visible = idx == 2

    local data = self.hardDetail[idx]
    RefreshHardDetail(idx, data)
end














local function InitModeCans(info)
    self.fubenModes = FubenAPI.getFubenModesByName(info.Name)
    local hasTeam = DataMgr.Instance.TeamData.HasTeam
    FubenAPI.requestFubenInfo(info.MapID,info.Type, function (list)
        if list == nil then 
            return
        end

        self.hardDetail = list
        for i=1,2 do
            local node
            local data = self.hardDetail[i]
            if i == 1 then
                node = self.cvs_danren
            else
                node = self.cvs_zudui
            end
            if node and data then
                local toggBtn = node:FindChildByEditName("tbn_1", true)
                toggBtn.IsChecked = false
                toggBtn.Enable = true
                toggBtn.UserTag = i
    
                if (i == 1 and not hasTeam) or (i == 2 and hasTeam) then
                    self.CurSelect = toggBtn
                end
                toggBtn.TouchClick = function(sender)
                    FubenModeClick(sender)
                end
            end
        end
        if self.CurSelect ~= nil then
            FubenModeClick(self.CurSelect)
        end
    end)
end

local function InitTitleAndDesc(info)
    self.lb_title.Text = info.Name
    local text, pro = FubenUtil.formatCondition(info)
    self.hasProfit = pro ~= 1

    self.btn_buy.Visible = pro == 2
end

local function SetFubenInfo(info)
    self.fubenInfo = info
    InitTitleAndDesc(info)
    InitModeCans(info)
end

local function OnExit()

end

local function OnEnter()
    self.CurSelect = nil

    for i=1,4 do
        self.dropCans[i].Visible = false
    end

    self.cvs_buymore.Visible = false
end

local function InitCloneCans()
    self.cvs_drop_item.Visible = false

    self.dropCans = {}
    for i=1,4 do
        self.dropCans[i] = self.cvs_drop_item:Clone()
        self.dropCans[i].X = self.cvs_drop_item.X+(self.cvs_drop_item.Size2D.x+10)*(i-1)
        self.cvs_drop_pre:AddChild(self.dropCans[i])
    end
end

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_title",

        "cvs_dungeon_information",
        "cvs_danren",
        "cvs_zudui",
        "tb_desc",
        "cvs_drop_pre",
        "cvs_drop_item",
        "lb_wenben",

        "btn_organize",
        "ib_discount",
        "lb_tips",
        "btn_goto",
        "btn_goto_solo",

        "btn_buy",
        "cvs_buymore",
        "ib_icon",
        "btn_none",
        "btn_use",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    InitCloneCans()

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.cvs_dungeon_information.TouchClick = function(sender)
        self.menu:Close()
    end

    self.cvs_buymore.TouchClick = function(sender)
        self.cvs_buymore.Visible = false
    end
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/dungeon/dungeon_information.gui.xml", GlobalHooks.UITAG.GameUIFubenSecond)
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end


local function initial()
    
end

_M.SetFubenInfo = SetFubenInfo

return {Create = Create, initial = initial}
