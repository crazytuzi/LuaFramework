local _M = {}
_M.__index = _M
local self = {menu = nil}

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'

local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local RechargeAPI = require "Zeus.Model.Recharge"

local self = {
    m_Root = nil,
}

local ui_names = 
{
  
  {name = 'btn_Close'},
  {name = 'btn_charge'},
  {name = 'cvs_first'},
  {name = 'cvs_second'},
  {name = 'cvs_weapon'},
}

local function OnClickClose(displayNode)
    if self ~= nil and self.m_Root ~= nil then
        self.m_Root:Close()
    end
end

local function showcpjAnimo(xmlpath,cpjname,isbig)
  local animoXML = xmlpath
  local spriteSheet = cpjname
  local animationNode = GameAlertManager.Instance.CpjAnime:CreateCpjAnime(nil,animoXML,spriteSheet,0,0,false)
  self.animationNode = animationNode
  if nil ~= animationNode then
    if isbig then
      animationNode.Scale = Vector2.New(1.5, 1.5)
      animationNode.X = 315
      animationNode.Y = -200
    else
      animationNode.Scale = Vector2.New(1.0, 1.0)
      animationNode.X = 315
      animationNode.Y = -200
    end
    
    animationNode.Layout.SpriteController:PlayAnimate(
        0,
        1,
        function (sender)
            animationNode:RemoveFromParent(true);
        end
    )
  end
end

local function List2Luatable(list)
    if not list then return nil end
  local ret = {}
  local iter = list:GetEnumerator()
  while iter:MoveNext() do
    local item = iter.Current
    table.insert(ret,item)
  end
  return ret
end

local function GetChildrenWithType(parent,t)
    local list = List2Luatable(XmdsUISystem.GetAllChildren(parent))
    local ret = {}
    for _,node in ipairs(list) do
        if tostring(typeof(node)) == t then
            table.insert(ret,node)
        end
    end
    return ret
end

local function SetItemShow(item,code,num)
    local material = ItemModel.GetItemStaticDataByCode(code)  
    local itemshow = Util.ShowItemShow(item,material.Icon,material.Qcolor,num)
    Util.NormalItemShowTouchClick(itemshow, code, false)

end

local function UpDateFirstPay(self)
  self.cvs_icon1 = self.cvs_first:FindChildByEditName('cvs_icon1',true)
  self.cvs_icon2 = self.cvs_first:FindChildByEditName('cvs_icon2',true)
  self.cvs_icon3 = self.cvs_first:FindChildByEditName('cvs_icon3',true)
  self.cvs_icon4 = self.cvs_first:FindChildByEditName('cvs_icon4',true)
  

  SetItemShow(self.cvs_icon1,self.payTable.WeaponCode, 1)
  SetItemShow(self.cvs_icon2,self.payTable.RewardCode1, self.payTable.RewardNum1)
  SetItemShow(self.cvs_icon3,self.payTable.RewardCode2, self.payTable.RewardNum2)
  SetItemShow(self.cvs_icon4,self.payTable.RewardCode3, self.payTable.RewardNum3)
  LoadWeaponFile()
end

local function UpDateSecondPay(self,params)
  local function setItemInfo(node,itemInfo)
    node.Visible = (itemInfo ~= nil)
    if itemInfo ~= nil then
      local lb_charge_num = node:FindChildByEditName('lb_charge_num',false)
      lb_charge_num.Text = itemInfo.payMoney/100

      local ib_notyet = node:FindChildByEditName('ib_notyet',false)
      ib_notyet.Visible = (itemInfo.isFinish == 0)
      local ib_get = node:FindChildByEditName('ib_get',false)
      ib_get.Visible = (itemInfo.isFinish ~= 0)

      for i = 1,3 do 
        local icon = node:FindChildByEditName('cvs_icon'..i,false)
        if itemInfo.items[i] == nil then
          icon.Visible = false
        else
          icon.Visible = true
          local material = ItemModel.GetItemStaticDataByCode(itemInfo.items[i].key)  
          local itemshow = Util.ShowItemShow(icon,material.Icon,material.Qcolor,itemInfo.items[i].value)
          Util.NormalItemShowTouchClick(itemshow, itemInfo.items[i].key, false)

        end
      end
    end
  end

  local lb_num = self.cvs_second:FindChildByEditName('lb_num',true)
  lb_num.Text = params.totalPay/100

  local cvs_chargeList = {}
  for i = 1,4 do 
    cvs_chargeList[i] = self.cvs_second:FindChildByEditName('cvs_charge'..i,true)
    setItemInfo(cvs_chargeList[i],params.awards[i])
  end
end

local function OnShopBtnClick()
  EventManager.Fire('Event.Goto', {id = "Pay"})
end

function _M.GetServerData()
  RechargeAPI.prepaidFirstAwardRequest(function(params)
    self.TotalPay = params.totalPay
    self.cvs_first.Visible = (params.totalPay == 0)
    self.cvs_second.Visible = (params.totalPay > 0)
    if self.TotalPay > 0 then
      UpDateSecondPay(self,params)
    else
      UpDateFirstPay(self)
    end

  end)
end

local function ClearModel()
    
    if self.weaponAsset ~= nil then
        GameObject.Destroy(self.weaponAsset)
        IconGenerator.instance:ReleaseTexture(self.weaponkey)
        self.weaponAsset = nil
        self.weaponkey = nil
    end
end

function LoadWeaponFile()
  if self.payTable.WeaponAssetBuddles ~= "" then
    self.weaponFile = '/res/unit/mount/'..(self.payTable.WeaponAssetBuddles)..'.assetBundles'
    self.weaponAsset, self.weaponkey = GameUtil.Add3DModel(self.cvs_weapon, self.weaponFile,nil, '', 0, true)
    self.weaponAsset.transform.sizeDelta = UnityEngine.Vector2.New(self.cvs_weapon.Height, self.cvs_weapon.Height)
    IconGenerator.instance:SetModelPos(self.weaponkey, Vector3.New(0.2, -1.2, 4.5))
    local percent = self.payTable.AssetBuddlesPercent
    IconGenerator.instance:SetModelScale(self.weaponkey, Vector3.New(percent, percent, percent))
    IconGenerator.instance:SetRotate(self.weaponkey, Vector3.New(0, 200, 0))
    IconGenerator.instance:SetCameraParam(self.weaponkey, 0.01, 5, 1.6)
  end
end

local function InitCompnent(self,tag)
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    self.menu.Enable = false
    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
end

local function ClearAll()
    if self.weaponFile then    
        UnityEngine.Object.DestroyObject(self.weaponAsset)
        if self.weaponkey then IconGenerator.instance:ReleaseTexture(self.weaponkey) end
        self.weaponFile = nil
    end
end

local function onDiamondAdd(nowDiamond)
    _M.GetServerData()
end

local function OnEnter(self)
    self.goldAdd:start()

    self.ID = 1
    local pro = DataMgr.Instance.UserData.Pro
    self.ProTable = GlobalHooks.DB.Find('Character',pro)
    self.payTable = GlobalHooks.DB.Find("FirstPay", {ID = pro})[1]

    _M.GetServerData()
end

local function OnExit(self)
    ClearModel()
    self.goldAdd:stop()

end

local function Init(self,tag)
    self.m_Root = LuaMenuU.Create("xmds_ui/gift/firstcharge.gui.xml", GlobalHooks.UITAG.GameUIFirstPay)
    self.menu = self.m_Root
    self.m_Root:SubscribOnExit(function ()
        OnExit(self)
    end)
    self.m_Root:SubscribOnEnter(function ()
        OnEnter(self)
    end)

    InitCompnent(self,tag)
    self.btn_Close.TouchClick = OnClickClose
    self.btn_charge.TouchClick = OnShopBtnClick
    self.goldAdd = UserDataValueExt.New(UserData.NotiFyStatus.DIAMOND, onDiamondAdd)
end

local function Create(tag)
    self = {}
    setmetatable(self, _M)
    Init(self,tag)
    return self
end


return {Create = Create}
