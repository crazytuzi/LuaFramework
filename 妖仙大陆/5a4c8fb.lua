
local _M = {}
_M.__index = _M
local cjson = require "cjson" 


local petDataList = nil
local fightingPetId = 0
local maxLv = tonumber(GlobalHooks.DB.Find("PetConfig", { ParamName = "LevelLimit" })[1].ParamValue)

local function setPetDataList(data)
  local expData =  GlobalHooks.DB.Find("PetExpLevel", data.level) 

  petDataList[data.id] = data
  petDataList[data.id].Experience = expData.Experience
end

local function getAllPetsInfoRequest(cb)
  petDataList = {}
  fightingPetId = 0
  Pomelo.PetNewHandler.getAllPetsInfoRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if param.s2c_petInfo then
        for i,v in ipairs(param.s2c_petInfo) do
          setPetDataList(v)
        end
      end
      fightingPetId = param.s2c_fightingPetId
      cb(petDataList)
    end
  end)
end

function _M.getPetDataList(cb)
  
  
  
  
  
  
  
  getAllPetsInfoRequest(cb)
end

function _M.getPetData(id)
  return petDataList[id]
end

function _M.getFightingPetId()
  return fightingPetId
end

function _M.summonPetRequest(petid,cb)
  Pomelo.PetNewHandler.summonPetRequest(petid,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.addExpByItemRequest(petid,itemstr,cb)
  Pomelo.PetNewHandler.addExpByItemRequest(petid,itemstr,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      setPetDataList(param.petInfo)
      cb()
    end
  end)
end

function _M.upgradeOneLevelRequest(petid,cb)
  Pomelo.PetNewHandler.upgradeOneLevelRequest(petid,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      setPetDataList(param.petInfo)
      cb()
    end
  end)
end

function _M.upgradeToTopRequest(petid,cb)
  Pomelo.PetNewHandler.upgradeToTopRequest(petid,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      setPetDataList(param.petInfo)
      cb()
    end
  end)
end

function _M.upGradeUpLevelRequest(petid,cb)
  Pomelo.PetNewHandler.upGradeUpLevelRequest(petid,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      setPetDataList(param.petInfo)
      cb()
    end
  end)
end

function _M.changePetNameNewRequest(petid,name,cb)
  Pomelo.PetNewHandler.changePetNameNewRequest(petid,name,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      setPetDataList(param.petInfo)
      cb()
    end
  end)
end

function _M.petFightRequest(petid,type,cb)
    Pomelo.PetNewHandler.petFightRequest(petid,type,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if type == 1 then
        fightingPetId = petid
      else
        fightingPetId = 0
      end
      cb(param)
    end
  end)
end

function _M.getAllPetsBaseInfoRequest(cb)
  Pomelo.PetHandler.getAllPetsBaseInfoRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.getPetInfoRequest(s2c_petId, s2c_ownId,cb)
    





end

function _M.developPetRequest(s2c_type,s2c_itemCode,s2c_petId, cb)
    Pomelo.PetHandler.developPetRequest(s2c_type,s2c_itemCode,s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.changePetNameRequest(s2c_petId,s2c_petName, cb)
    Pomelo.PetHandler.changePetNameRequest(s2c_petId,s2c_petName,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.randPetNameRequest(cb)
  Pomelo.PetHandler.randPetNameRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.freePetRequest(s2c_petId,s2c_type, cb)
    Pomelo.PetHandler.freePetRequest(s2c_petId,s2c_type,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.petOutFightRequest(s2c_petId, s2c_type, cb)
    Pomelo.PetHandler.petOutFightRequest(s2c_petId, s2c_type,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.petReliveRequest(s2c_petId, cb)
    Pomelo.PetHandler.petReliveRequest(s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.upGradeInfoRequest(s2c_petId, cb, errorcb)
  
  Pomelo.PetHandler.upGradeInfoRequest(s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      else
        if errorcb ~= nil then
          errorcb()
        end
      end
    end)
end

function _M.upGradeLevelRequest(s2c_petId, cb)
  
  Pomelo.PetHandler.upGradeLevelRequest(s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.upGradeRandPropertyRequest(s2c_petId,s2c_pos,s2c_materialItems, cb)
  Pomelo.PetHandler.upGradeRandPropertyRequest(s2c_petId,s2c_pos,s2c_materialItems,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.reSetRandPropertyRequest(s2c_petId,s2c_pos,cb)
  Pomelo.PetHandler.reSetRandPropertyRequest(s2c_petId,s2c_pos,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.randPropertyListRequest(s2c_petId,cb)
  Pomelo.PetHandler.randPropertyListRequest(s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.petIllusionRequest(s2c_petId,cb)
  Pomelo.PetHandler.petIllusionRequest(s2c_petId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
    end)
end

function _M.petIllusionInfoRequest(s2c_petId,cb, errorcb)
  Pomelo.PetHandler.petIllusionInfoRequest(s2c_petId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      else
        if errorcb ~= nil then
          errorcb()
        end
      end
    end)
end

function _M.petIllusionReviewRequest(s2c_petId,cb)
  
  Pomelo.PetHandler.petIllusionReviewRequest(s2c_petId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      else
        if errorcb ~= nil then
          errorcb()
        end
      end
  end)
end

function _M.petComprehendSkillRequest(s2c_petId,s2c_skillBookCode,s2c_lockPos,cb, errorcb)
  Pomelo.PetHandler.petComprehendSkillRequest(s2c_petId,s2c_skillBookCode,s2c_lockPos, function (ex,sjson)
  	  
      if not ex then
        local param = sjson:ToData()
        cb(param)
      else
        if errorcb ~= nil then
          errorcb()
        end
      end
  end)
end

function _M.petSkillListRequest(s2c_petId,cb)
  Pomelo.PetHandler.petSkillListRequest(s2c_petId, function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.petOnHookSetRequest(s2c_petId,s2c_onHookData,cb)
  
  Pomelo.PetHandler.petOnHookSetRequest(s2c_petId,s2c_onHookData,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

function _M.petOnHookGetRequest(s2c_petId,cb, timeoutcb)
  
  Pomelo.PetHandler.petOnHookGetRequest(s2c_petId,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end, XmdsNetManage.PackExtData.New(true, true, timeoutcb))
end

function _M.changePetPkModelRequest(c2s_model, cb)
  
  Pomelo.PetHandler.changePetPkModelRequest(c2s_model,function (ex,sjson)
      if not ex then
        local param = sjson:ToData()
        cb(param)
      end
  end)
end

_M.petCb = {
  petExpCb = {},
}


function _M.RemovePetExpListener(key)
  _M.petCb.petExpCb[key] = nil
end

function _M.AddPetExpListener(key, cb)
  _M.petCb.petExpCb[key] = cb
end

local function dealPetExpPush(param)
  
  for key,val in pairs(_M.petCb.petExpCb) do
    
    val(param)
  end
end

function GlobalHooks.DynamicPushs.OnPetExpPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    
    if(param ~= nil)then
      dealPetExpPush(param)
    end
  end
end

function GlobalHooks.DynamicPushs.OnPetDetailPush(ex, json)
  
  
  if ex == nil then
      local param = json:ToData()
      
      local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIPetGetNewPush)
      if  lua_obj == nil then
        node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetGetNewPush, 0)
      end
      lua_obj.setPetInfo(param)
  end
end

function GlobalHooks.DynamicPushs.OnNewPetDetailPush(ex, json)
  if ex == nil then
      local param = json:ToData()
      
      local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIPetGetNewPush)
      if  lua_obj == nil then
        node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetGetNewPush, 0)
      end
      lua_obj.setPetInfo(param)
      setPetDataList(param.petInfo)
      EventManager.Fire("Event.UI.PetUIMain.Refresh",{data = param.petInfo})


  end
end

local petItemFilter = nil
local petExpItem = {}
local petUpExp = {}
local petModels = {}

local function checkCanSummon(petid)
  local petData = petDataList[petid]
  if petData ~= nil then
    return false
  end

  if petUpExp[petid]~=nil then
    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(petUpExp[petid].PetItemCode)
    local num = (vItem and vItem.Num) or 0 

    if num >=petUpExp[petid].ItemCount then
      return true
    end
  end

  return false
end

local function checkCanUpLevel(petid)
  local petData = petDataList[petid]
  if petData == nil then
    return false
  end

  if petData.level >= maxLv then
    return false
  end

  local needExp =  petData.Experience - petData.exp
  local upgrade = petUpExp[petid].upgrade[petData.upLevel+1]


  if petUpExp[petid].expSum > needExp and petData.level < upgrade.ReqLevel and petData.level < tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)) + 5  then
    return true
  end

  return false
end

local function checkCanUpgrade(petid)
  local petData = petDataList[petid]
  if petData == nil then
    return false
  end

  if petData.level >= maxLv then
    return false
  end

  local upgrade = petUpExp[petid].upgrade[petData.upLevel+1]
  local bag_data = DataMgr.Instance.UserData.RoleBag

  local maxUpLv = tonumber(GlobalHooks.DB.Find("PetConfig", { ParamName = "Upgrade.LevelLimit" })[1].ParamValue)
  local vItem = bag_data:MergerTemplateItem(upgrade.upgradeCode)
  local num = (vItem and vItem.Num) or 0 
  if petData.upLevel < maxUpLv and  num >= upgrade.upgradeNum then
    return true
  end
  
  return false
end

local function getExpSum(expCode)
  local itemcodes = string.split(expCode,',')

  local expSum = 0
  for i,v in ipairs(itemcodes) do
    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(v)
    local num = (vItem and vItem.Num) or 0 

    expSum = expSum + petExpItem[v] *num
  end

  return expSum
end

local function checkRedPoint()
  local isShowRedPoint = false
  for i,v in ipairs(petModels) do
    isShowRedPoint = checkCanSummon(v.PetID)  
    if isShowRedPoint then
      break
    end
  end

  if not isShowRedPoint then
    for _,v in pairs(petDataList) do
      isShowRedPoint = checkCanUpLevel(v.id)   
      if not isShowRedPoint then
        isShowRedPoint = checkCanUpgrade(v.id)
        if isShowRedPoint then
          break
        end
      else
        if isShowRedPoint then
          break
        end
      end
    end
  end

  if isShowRedPoint then  
    DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PET,1,true)
  else
    DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PET,0,true)
  end
  

  
  
  
  
  
      
      
      
      
      
  
  
end

local function checkPetRedPoint()
    local items = GlobalHooks.DB.Find("PetItem", {Prop = 'ptexp'})
    for i,v in ipairs(items) do
      petExpItem[v.Code] = v.Min
    end

    local petModelData = GlobalHooks.DB.Find("BaseData", {})
    for i,v in ipairs(petModelData) do
      petUpExp[v.PetID] = {PetItemCode = v.PetItemCode, ItemCount = v.ItemCount, ExpCode = v.ExpCode}

      petUpExp[v.PetID].expSum = getExpSum(v.ExpCode)
    end

    local upgrade = GlobalHooks.DB.Find("PetUpgrade", {})
    for i,v in ipairs(upgrade) do
      if petUpExp[v.PetID] ~= nil then
        petUpExp[v.PetID].upgrade = petUpExp[v.PetID].upgrade or {}
        petUpExp[v.PetID].upgrade[v.TargetUpLevel] = {ReqLevel = v.ReqLevel, upgradeCode = v.MateCode,upgradeNum=v.MateCount}
      end
    end

    petModels = GlobalHooks.DB.Find("BaseData", {})

    getAllPetsInfoRequest(function ()

      local filter = petItemFilter
      if filter then
          DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
      end
      filter = ItemPack.FilterInfo.New()
      petItemFilter = filter

      filter.MergerSameTemplateID = true
      filter.CheckHandle = function(item)
          return item.detail.static.Type == 'petItem' and item.detail.static.Prop == 'ptexp'
      end

      filter.NofityCB = function(pack, type, index)
          if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
              local itemData = petItemFilter:GetItemDataAt(index)
              if itemData == nil then
                return
              end
              for _,v in pairs(petDataList) do
                local expCode = string.gsub(petUpExp[v.id].ExpCode,"-","")
                local code  = string.gsub(itemData.detail.static.Code,"-","")
                local pos,len = string.find(expCode, code)
                if pos ~= nil then
                  petUpExp[v.id].expSum = getExpSum(petUpExp[v.id].ExpCode)
                end
              end
              checkRedPoint()
          end


      end
      DataMgr.Instance.UserData.RoleBag:AddFilter(filter)

      checkRedPoint()
    end)
end


function GlobalHooks.DynamicPushs.OnPetExpUpdatePush(ex, json)
  if ex == nil then
      local param = json:ToData()
      local petData = petDataList[param.s2c_petId]
      if petData ~= nil then
        petData.exp = param.s2c_curExp
        if checkCanUpLevel(param.s2c_petId) then
          DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PET,1,true)
        else
          DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PET,0,true)
        end
      end
  end
end

function GlobalHooks.DynamicPushs.OnPetInfoUpdatePush(ex, json)
  if ex == nil then
      local param = json:ToData()
      setPetDataList(param.s2c_pet)
      checkRedPoint()
  end
end

function _M.InitNetWork()
    checkPetRedPoint()
    
    
    Pomelo.PetNewHandler.onNewPetDetailPush(GlobalHooks.DynamicPushs.OnNewPetDetailPush)
    Pomelo.PetNewHandler.petExpUpdatePush(GlobalHooks.DynamicPushs.OnPetExpUpdatePush)
    Pomelo.PetNewHandler.petInfoUpdatePush(GlobalHooks.DynamicPushs.OnPetInfoUpdatePush)
end

_M.checkCanSummon = checkCanSummon
_M.checkCanUpLevel = checkCanUpLevel
_M.checkCanUpgrade = checkCanUpgrade

return _M
