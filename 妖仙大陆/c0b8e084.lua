local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"
local ItemModel = require 'Zeus.Model.Item'

local self = {
    menu = nil,
}

local function FindEquipListItem(self,tag)
    local child_list = self.sp_type.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        if v.UserTag == tag then
            return v
        end
    end
    return nil
end

function _M.Notify(status, flagData)
    if self ~= nil and self.menu ~= nil then
        local node = FindEquipListItem(self,status)
        if node ~= nil then
            local lb_bj = node:FindChildByEditName("lb_bj",true)
            local num = DataMgr.Instance.FlagPushData:GetFlagState(status)
            lb_bj.Visible = (num ~= nil and num == 2)
        end
    end
end

local function CloseChildUI()
    if self.ChildUITag then
        GlobalHooks.CloseUI(self.ChildUITag)
        self.ChildUITag = nil
    end
end

local function SwitchPage(sender)
    CloseChildUI()
    GlobalHooks.OpenUI(sender.UserTag, 0)
    if self.lastSender then
        self.lastSender.IsChecked = false
        self.lastSender.Enable = true
    end
    sender.IsChecked = true
    sender.Enable = false
    self.lastSender = sender
    self.ChildUITag = sender.UserTag
end

local function OnEnter()
    self.lastSender = nil
    self.ChildUITag = nil

    local btnTagList = {}
    if DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_CONTINUE) > 0 then
        table.insert(btnTagList, {GlobalHooks.UITAG.GameUIHotContinue, 
                      Util.GetText(TextConfig.Type.ACTIVITY, "activity_continue"), 
                      FlagPushData.FLAG_HOT_CONTINUE})
        self.ChildUITag = GlobalHooks.UITAG.GameUIHotContinue
    end
    if DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_RICH) > 0 then
        table.insert(btnTagList, {GlobalHooks.UITAG.GameUIHotRich, 
                      Util.GetText(TextConfig.Type.ACTIVITY, "activity_rich"), 
                      FlagPushData.FLAG_HOT_RICH})
        if not self.ChildUITag then
           self.ChildUITag = GlobalHooks.UITAG.GameUIHotRich
        end
    end
    if DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_SEVENTARGET) > 0 then
        table.insert(btnTagList, {GlobalHooks.UITAG.GameUIHotSeventarget, 
                      Util.GetText(TextConfig.Type.ACTIVITY, "activity_sevenDay"), 
                      FlagPushData.FLAG_HOT_SEVENTARGET})
        if not self.ChildUITag then
          self.ChildUITag = GlobalHooks.UITAG.GameUIHotSeventarget
        end
    end

    self.sp_type:Initialize(self.cvs_tmp.Width+20, self.cvs_tmp.Height+5, #btnTagList, 1, self.cvs_tmp, 
        function (x, y, node)
            local tag = btnTagList[y+1][1]
            node.UserTag = btnTagList[y+1][3]

            local lb_bj = node:FindChildByEditName("lb_bj", true)
            local tbt_subtype = node:FindChildByEditName("tbt_subtype", true)
            lb_bj.Visible = DataMgr.Instance.FlagPushData:GetFlagState(btnTagList[y+1][3]) == 2
            
            tbt_subtype.UserTag = tag
            tbt_subtype.Text = btnTagList[y+1][2]
            tbt_subtype.TouchClick = function (sender)
                SwitchPage(sender)
            end
            if not self.lastSender and tag == self.ChildUITag then
                SwitchPage(tbt_subtype)
            end
        end, 
        function ()

        end
    )

    DataMgr.Instance.FlagPushData:AttachLuaObserver(self.menu.Tag, self)
end

local function OnExit()
    DataMgr.Instance.FlagPushData:DetachLuaObserver(self.menu.Tag)
    CloseChildUI()
end

local ui_names = 
{
  
  {name = 'btn_close'},

  {name = 'cvs_tmp'},
  {name = 'sp_type'},
  {name = 'cvs_content'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_tmp.Visible = false

  self.btn_close.TouchClick = function ()
    self.menu:Close()
  end
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/carnival/hot_frame.gui.xml", GlobalHooks.UITAG.GameUIHotMainUI)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud

  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
