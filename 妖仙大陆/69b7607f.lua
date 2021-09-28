local _M = {}
_M.__index = _M


local Util              = require "Zeus.Logic.Util"
local ChatUtil          = require "Zeus.UI.Chat.ChatUtil"
local ItemModel         = require 'Zeus.Model.Item'

local self = {
    m_Root = nil,

}

local function GetNextData()
    
    if self == nil or self.m_Item == nil or (#self.m_Item) < 2 then
        self.m_Item = {}
        return nil
    end
    
    for i = 1, #self.m_Item do
        self.m_Item[i] = self.m_Item[i + 1]
    end
    
    local data = self.m_Item[1]
    
    if ItemModel.CheckIsCanUsed(data) then
        return data
    else
        return GetNextData()
    end
end

local function OnClickClose(displayNode)
    
    local data = GetNextData()
    if data == nil then
         Util.clearUIEffect(self.btn_now,39)  
         self.m_Root:Close()
    else
        InitShowInfo(data)
    end
end

local function OnClickEquip(displayNode)
  local function DoEquip()
    
    if self.curItemdata ~= nil then
        ItemModel.EquipItem(self.curItemdata.Index, function()
            
            
            if self ~= nil and self.m_Item ~= nil and #self.m_Item > 0 and self.m_Item[1].Index == self.curItemdata.Index then
                
                OnClickClose(displayNode)
            end
            DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PROPERTY_EQUIP,0,true)
            EventManager.Fire("Event.Menu.IsShowHudRedPoint",{showType = "0"})
            
        end, function()
            
            
            OnClickClose(displayNode)
        end)
    end    
  end
  if self.curItemdata and self.curItemdata.detail.bindType ~= 1 then
    
    GameAlertManager.Instance:ShowAlertDialog(
      AlertDialog.PRIORITY_NORMAL,
      Util.GetText(TextConfig.Type.ITEM,'bindTips'),
      '',
      '',nil,
      function ()
        DoEquip()
      end,
      function() 
        OnClickClose(displayNode)
      end)
  else
      DoEquip()
  end

end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "btn_now",
        "cvs_icon",
        "lb_name",
        "lb_zhanli",
        "ib_noweffect",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end

local function OnEnter()
    self.filter = ItemPack.FilterInfo.New()

    self.filter.CheckHandle = function (item)
        return true
    end
    self.hasEffect = false
    self.filter.NofityCB = function (pack,status,index)
        
        if status == ItemPack.NotiFyStatus.RMITEM then
            for i = 1, #self.m_Item do
                if self.m_Item[i] == nil or self.m_Item[i].id == self.filter:GetItemDataAt(index).Id then
                    table.remove(self.m_Item, i)
                    break
                end
            end
            
            if #self.m_Item > 0 and ItemModel.CheckIsCanUsed(self.m_Item[1]) then
                InitShowInfo(self.m_Item[1])
                
            else
                
                OnClickClose(nil)
            end
        end
    end

    DataMgr.Instance.UserData.RoleBag:AddFilter(self.filter)
    if(not self.hasEffect) then
        Util.showUIEffect(self.btn_now,39)
        self.hasEffect = true  
    end
end

local function OnExit()
    
    RemoveUpdateEvent("Event.GameUIGoodItem.Update", true)
    if self.filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
        self.filter = nil
    end
    Util.clearUIEffect(self.btn_now,39)
    self.hasEffect = false  
    self.m_Item = {}
end

local function InitCompnent()
    InitUI()
    self.btn_close.TouchClick = OnClickClose
    self.btn_now.TouchClick = OnClickEquip
    
    self.ib_noweffect.Scale = Vector2.New(1.45, 1.2) 
    
    
    
    self.m_Item = {}

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

function InitShowInfo(data)
    
    
    local starNum = 0
    local itemdata = DataMgr.Instance.UserData.RoleBag:FindItem(data.id)
    local itemdata2 = nil
    if itemdata ~= nil then
        self.curItemdata = itemdata
        starNum = itemdata.StarNum
        itemdata2 = DataMgr.Instance.UserData.RoleEquipBag:GetItemAt(data.itemSecondType)
        if itemdata2 ~= nil then
            itemdata2 = ItemModel.GetItemDetailById(itemdata2.Id)
        end
    else
        RemoveUpdateEvent("Event.GameUIGoodItem.Update", true)
        AddUpdateEvent(
            "Event.GameUIGoodItem.Update",
            function(dt)
                RemoveUpdateEvent("Event.GameUIGoodItem.Update", true)
                InitShowInfo(data)
            end
        )
        return
    end

    if itemdata2 == nil then
        self.lb_zhanli.Text = data.equip.score
    else
        if itemdata2.equip.baseScore < data.equip.score then
            self.lb_zhanli.Text = data.equip.score - itemdata2.equip.score
        else
            self.lb_zhanli.Text = "0"
        end
    end

    self.lb_name.Text = data.static.Name
    self.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(tonumber(data.static.Qcolor))

    local item = Util.ShowItemShow(self.cvs_icon, data.static.Icon, data.static.Qcolor, 1)
    item.Star = starNum
end

function _M.InitInfo(data)
    
    if data == nil then
        return
    end
    
    for i = 1, #self.m_Item do
        if self.m_Item[i].itemSecondType == data.itemSecondType
            and self.m_Item[i].equip.baseScore >= data.equip.baseScore then
            return 
        end
    end
    self.m_Item[#self.m_Item + 1] = data
    
    if #self.m_Item == 1 then
        InitShowInfo(data)
    end
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/common/commom_good.gui.xml", GlobalHooks.UITAG.GameUIGoodItem)
    self.m_Root.Enable = false
    self.m_Root.ShowType = UIShowType.Cover
    InitCompnent()
    self.menu = self.m_Root
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end

return {Create = Create}
