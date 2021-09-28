

local _M = {}
_M.__index = _M

local MyMountInfo = nil
local mountRingFlag = 0
local AllSkinList = {}
local AllRideLevelList = {}

local Util     = require "Zeus.Logic.Util"


local MaxUpLevel = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Ride.MaxUpLevel"})[1].ParamValue)
local mountMaxStar = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "mountMaxStar"})[1].ParamValue)

local inited = false

local function ActionStar(parent,num,cb)
  local starstr = "ib_Star"
  local starBeginNum = 10
  for i=1,10 do
    local star = parent:FindChildByEditName(starstr..i,true)
    if not star.Enable then
      starBeginNum = i
      break
    end
  end

  local function setStar(ChangeStrNum)
    parent:FindChildByEditName(starstr..ChangeStrNum,true).Enable = true
    local Da = DelayAction.New()
    Da.Duration = 0.1
    Da.ActionFinishCallBack = function (sender)
      if starBeginNum <= num then
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('starUp')
        setStar(starBeginNum)
      else
        cb()
        return
      end
      starBeginNum = starBeginNum + 1
    end
    parent:AddAction(Da)
  end
  setStar(starBeginNum)
end

function _M.chooseFirstSkinRequest(id,cb)
  Pomelo.MountHandler.chooseFirstSkinRequest(id,function (ex,sjson)
    if not ex then
      
      
      cb()
    end
  end)
end

function _M.getMountInfoRequest(cb)
  Pomelo.MountHandler.getMountInfoRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      MyMountInfo = msg.s2c_data
      cb()
    end
  end)
end

function _M.trainingMountRequest(type, cb)
  Pomelo.MountHandler.trainingMountRequest(type, function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      MyMountInfo = msg.s2c_data
      cb()
      _M.RreshRideFlag()
    end
  end)
end

function _M.activeMountSkinRequest(c2s_skinId,cb)
  Pomelo.MountHandler.activeMountSkinRequest(c2s_skinId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      
      if MyMountInfo then
        MyMountInfo.usingSkinID = c2s_skinId
      end
      cb()
    end
  end)
end

function GlobalHooks.DynamicPushs.mountNewSkinPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    DataMgr.Instance.UserData.HasMount = true
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGetNewSkin,0)
    lua_obj.SetRideSkinData(msg)

    EventManager.Fire("Event.IniRideSkin",{})
  end
end



function _M.saveMountRequest(c2s_mountId,c2s_skinId,cb)
  Pomelo.MountHandler.saveMountRequest(c2s_mountId,c2s_skinId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      AllMountInfo = msg.s2c_data
      cb()
    end
  end)
end

function _M.upMountStageRequest(cb)
  Pomelo.MountHandler.upMountStageRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      local Luckyv = 0
      if msg.s2c_curLuckyValue==nil then
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('advanced') 
        AllMountInfo = msg.s2c_data
        Luckyv = AllMountInfo.luckyValue
      else
        Luckyv = msg.s2c_curLuckyValue
      end
      
      cb(Luckyv)
    end
  end)
end

function _M.oneKeyTrainingRequest(StarParent,callfun,cb)
  local oldAllMountInfo = AllMountInfo
  Pomelo.MountHandler.oneKeyTrainingRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllMountInfo = msg.s2c_data
      callfun()
      
      local addStar = AllMountInfo.star - oldAllMountInfo.star
      ActionStar(StarParent,AllMountInfo.star,cb)
      
    end
  end)
end

function _M.ridingMountRequest(isup,cb)
  Pomelo.MountHandler.ridingMountRequest(isup,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      
      cb()
    end
  end)
end

function GlobalHooks.DynamicPushs.mountFlagPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    mountRingFlag = msg.s2c_flag
    if mountRingFlag == 1 then
      local params = GlobalHooks.DB.Find("SkinList", {SkinID=msg.s2c_usingSkinId})[1].Sound
      XmdsSoundManager.GetXmdsInstance():PlaySound(params)
    end
    
    EventManager.Fire("Event.Menu.MountRing", {params = mountRingFlag})
  end
end

function GlobalHooks.DynamicPushs.OpenSkinChoiceUI(eventname,params)
  GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINewSkinChoice,-1)
end

_M.mountCallback = {
  mountPushCb = {},
}

function _M.RemoveMountPushListener(key)
    _M.mountCallback.mountPushCb[key] = nil
end

function _M.AddMountPushListener(key, cb)
    _M.mountCallback.mountPushCb[key] = cb
end

function GlobalHooks.DynamicPushs.commonPropertyPush(ex, sjson)
  if ex == nil then
    local msg = sjson:ToData()
    
    if msg.s2c_property then
      local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIAttributeUP)
      if lua_obj==nil then
        node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIAttributeUP,0)
      end
      lua_obj:SetAttValue(msg.s2c_property)
    end
  end
end

function _M.GetAllMountSkins()
  return AllMountInfo
end

function _M.GetmountRingFlag()
  return mountRingFlag
end


function _M.GetSkinAttrNameId(id)
  local data = GlobalHooks.DB.Find("Attribute", {ID=id})[1]
  
  return data.attName
end

function _M.GetAddAttrString(name, value, value1)
    local string = Util.GetText(TextConfig.Type.MOUNT, "attrStr1")
    return string.format(string,name,value,value1)
end

function _M.GetAttrString(name, value)
    local string = Util.GetText(TextConfig.Type.MOUNT, "attrStr")
    return string.format(string,name,value)
end

function _M.NewGetAttrString(name, value)
    local string = Util.GetText(TextConfig.Type.MOUNT, "attrStr2")
    return string.format(string,name,value)
end


function _M.GetSkinDataById(id)
  for i,v in ipairs(AllSkinList) do
    if v.SkinID == id then
        
        return v
    end
  end
end

function _M.GetSkinAttrById(id)
  local data
  for i,v in ipairs(AllSkinList) do
    if v.SkinID == id then
        data = v
    end
  end
  if data then
    local list = {{name=data.Prop1, maxValue=data.Max1},
                {name=data.Prop2, maxValue=data.Max2},
                {name=data.Prop3, maxValue=data.Max3},
                {name=data.Prop4, maxValue=data.Max4},
                {name=data.Prop5, maxValue=data.Max5},
                {name=data.Prop6, maxValue=data.Max6},}
    return list
  end
  return nil
end

function _M.IsRideTopLevel(upLevel, level)
  if upLevel >= MaxUpLevel and level >= mountMaxStar then
    return true
  else
    return false
  end
end

function _M.GetRideUpCost(upLevel)
  for i,v in ipairs(AllRideLevelList) do
    if v.RideLevel == upLevel then
        return v
    end
  end
end

function _M.GetMyMountInfo()
  return MyMountInfo
end

function _M.GetAllSkinList()
  return AllSkinList
end

function _M.InitSkinList()
    AllSkinList = GlobalHooks.DB.Find("SkinList", {})
end

function _M.InitRideLevelList()
    AllRideLevelList = GlobalHooks.DB.Find("RideList", {})
end

function _M.ClearCache()
    MyMountInfo = nil
end

function _M.RreshRideFlag()
  if MyMountInfo ~= nil then
      local bag_data = DataMgr.Instance.UserData.RoleBag
      local isTopLv = _M.IsRideTopLevel(MyMountInfo.rideLevel, MyMountInfo.starLv)
      if not isTopLv then
        local ItemData = _M.GetRideUpCost(MyMountInfo.rideLevel)
        local itemCode = ItemData.UpStarItemCode
        local itemCount = ItemData.UpStarItemCount
        local canUpLevel = MyMountInfo.starLv < 10
        if not canUpLevel then
          itemCode = ItemData.UpLevelItemCode
          itemCount = ItemData.UpLevelItemCount
        end

        local vItem = bag_data:MergerTemplateItem(itemCode)
        local hasCount = (vItem and vItem.Num) or 0
        if hasCount < itemCount then
          DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_MOUNT,0,true)
        else
          DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_MOUNT,1,true)
        end
      else
        bag_data:RemoveFilter(_M.filter)
        DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_MOUNT,0,true)
      end
    end
end

function _M.InitRideFlagNotify()
  local bag_data = DataMgr.Instance.UserData.RoleBag
  _M.filter = ItemPack.FilterInfo.New()
  bag_data:AddFilter(_M.filter)
  _M.filter.CheckHandle = function (it)
    return it.SecondType == 203
  end
  _M.filter.NofityCB = function ()
    _M.RreshRideFlag()
  end

  _M.getMountInfoRequest(function()
    _M.RreshRideFlag()
  end)
end

function _M.fin(relogin)
    if relogin then
        
        inited = false
    end
end

function _M.InitNetWork()
  if not inited then
    _M.InitSkinList()
    _M.InitRideLevelList()
  
    _M.InitRideFlagNotify()

    inited = true
  end
  
  EventManager.Subscribe("Event.OpenUI.OpenSkinChoiceUI", GlobalHooks.DynamicPushs.OpenSkinChoiceUI)
  Pomelo.MountHandler.mountFlagPush(GlobalHooks.DynamicPushs.mountFlagPush)
  Pomelo.MountHandler.mountNewSkinPush(GlobalHooks.DynamicPushs.mountNewSkinPush)
  
end

return _M
