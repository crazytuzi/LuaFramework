local Lplus = require("Lplus")
local GrowFundInfo = Lplus.Class("GrowFundInfo")
local ProductServiceType = require("consts.mzm.gsp.qingfu.confbean.ProductServiceType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GrowFundMgr = require("Main.Award.mgr.GrowFundMgr")
local GUIUtils = require("GUI.GUIUtils")
local PayNode = require("Main.Pay.ui.PayNode")
local PayData = require("Main.Pay.PayData")
local PayModule = require("Main.Pay.PayModule")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local instance
local def = GrowFundInfo.define
def.field("number").curActivityId = 0
def.field("userdata").m_node = nil
def.field("table").fundsortids = nil
def.field("number").serviceId = 0
def.static("=>", GrowFundInfo).Instance = function()
  if instance == nil then
    instance = GrowFundInfo()
  end
  return instance
end
def.method("number", "userdata").ShowGrowFund = function(self, activityId, node)
  self.curActivityId = activityId
  self.m_node = node
  warn("-------ShowGrowFund:", activityId)
  self:setGrowFoudInfo()
  if _G.IsEfunVersion() and _G.platform == _G.Platform.ios then
    local buyBtn = self.m_node:FindDirect("Btn_Buy")
    buyBtn:SetActive(false)
  end
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, GrowFundInfo.onUpdateGrowFund)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, GrowFundInfo.OnLevelUpAwardUpdate)
end
def.method().HideGrowFund = function(self)
  warn("-------HideGrowFund:", self.curActivityId)
  self.m_node = nil
  self.curActivityId = 0
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, GrowFundInfo.onUpdateGrowFund)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, GrowFundInfo.OnLevelUpAwardUpdate)
end
def.static("table", "table").onUpdateGrowFund = function(params)
  if instance and instance.m_node then
    instance:setGrowFoudInfo()
  end
end
def.static("table", "table").OnLevelUpAwardUpdate = function(params)
  if instance and instance.m_node then
    instance:setGrowFoudInfo()
  end
end
def.method().setGrowFoudInfo = function(self)
  local activityid = self.curActivityId
  local info = GrowFundMgr.Instance():GetGrowFundInfoByActivityId(activityid)
  if self.m_node == nil then
    return
  end
  self.fundsortids = {}
  if info.purchased == 1 then
    self.m_node:FindDirect("Btn_Buy/Label"):GetComponent("UILabel"):set_text(textRes.Award[52])
    self.m_node:FindDirect("Btn_Buy"):SetActive(false)
    self.m_node:FindDirect("Img_HaveBuy"):SetActive(true)
  else
    self.m_node:FindDirect("Btn_Buy/Label"):GetComponent("UILabel"):set_text(textRes.Award[51])
    self.m_node:FindDirect("Btn_Buy"):SetActive(true)
    self.m_node:FindDirect("Img_HaveBuy"):SetActive(false)
  end
  local num = GrowFundMgr.Instance().num
  local fillInfo = GrowFundMgr.GetGrowFundCfgByActivityId(activityid)
  local mylevel = require("Main.Hero.Interface").GetHeroProp().level
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local listItem = self.m_node:FindDirect("Scroll View/List_Fund")
  local uilist = listItem:GetComponent("UIList")
  uilist.itemCount = #fillInfo
  uilist:Resize()
  local idx = 1
  local bannerId = 0
  for i, v in ipairs(fillInfo) do
    self.serviceId = v.serviceId
    bannerId = v.banner
    local item = listItem:FindDirect(string.format("Img_FundBg_%d", i))
    item:FindDirect(string.format("Img_Get_%d", i)):SetActive(false)
    local bindLabel = item:FindDirect(string.format("Label2_%d", i))
    if bindLabel ~= nil then
      bindLabel:SetActive(false)
    end
    if info.sortid >= v.sortid then
      item:FindDirect(string.format("Img_Get_%d", i)):SetActive(true)
      item:FindDirect(string.format("Btn_Get_%d", i)):SetActive(false)
    else
      item:FindDirect(string.format("Img_Get_%d", i)):SetActive(false)
      item:FindDirect(string.format("Btn_Get_%d", i)):SetActive(true)
      if mylevel >= v.level_cond and info.purchased == 1 then
        item:FindDirect(string.format("Btn_Get_%d", i)):GetComponent("UIButton"):set_isEnabled(true)
      else
        item:FindDirect(string.format("Btn_Get_%d", i)):GetComponent("UIButton"):set_isEnabled(false)
      end
    end
    item:FindDirect(string.format("Label1_%d", i)):GetComponent("UILabel"):set_text(v.desc)
    local key = string.format("%d_%d_%d", v.award_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    for kj, vj in ipairs(awardcfg.moneyList) do
      item:FindDirect(string.format("Label_Num_%d", i)):GetComponent("UILabel"):set_text(vj.num)
    end
    local r = {}
    r.sortid = v.sortid
    r.level = v.level_cond
    r.id = v.id
    self.fundsortids[i] = r
  end
  if bannerId > 0 then
    local Texture = self.m_node:FindDirect("Sprite/Texture")
    local bannerTexture = Texture:GetComponent("UITexture")
    GUIUtils.FillIcon(bannerTexture, bannerId)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if self.curActivityId == GrowFundMgr.GrowFundActivityId and not IsFeatureOpen(ModuleFunSwitchInfo.TYPE_LEVEL_GROWTH_FUND) then
    Toast(textRes.Award[110])
    return
  end
  if self.curActivityId == GrowFundMgr.StrongerFundActivityId and not IsFeatureOpen(ModuleFunSwitchInfo.TYPE_ADVANCED_LEVEL_GROWTH_FUND) then
    Toast(textRes.Award[110])
    return
  end
  if id == "Btn_Buy" then
    if _G.IsEfunVersion() and _G.platform == _G.Platform.ios then
      local url = require("Main.Common.URLBtnHelper").GetURLByCfgId(347508005)
      warn("-----------growFundInfo url:", url)
      if url then
        Application.OpenURL(url)
      else
        warn("!!!!!!error growFund url cfg id:", 347508005)
      end
      return
    end
    local qingfuCfg = PayData.LoadQingFuCfg()
    local cfgData
    for i, v in pairs(qingfuCfg) do
      if v.productServiceType == ProductServiceType.LEVEL_GROWTH_FUND and v.productServiceId == self.serviceId then
        cfgData = v
        break
      end
    end
    if cfgData then
      PayModule.Pay(cfgData)
      warn("------------pay serviceId:", cfgData.id, self.serviceId)
    else
      error("!!!!!!not qingfu cfg:", self.curActivityId, self.serviceId)
    end
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.GROWFUND, {1, 0})
  elseif string.sub(id, 1, 8) == "Btn_Get_" then
    local index = tonumber(string.sub(id, 9))
    local growFundInfo = GrowFundMgr.Instance():GetGrowFundInfo()
    local r = self.fundsortids[index]
    local mylevel = require("Main.Hero.Interface").GetHeroProp().level
    local gfi = GrowFundMgr.Instance():GetGrowFundInfoByActivityId(self.curActivityId)
    if r ~= nil and gfi ~= nil then
      if r.sortid > gfi.sortid and mylevel >= r.level then
        if gfi.sortid == -1 and r.sortid ~= 1 then
          Toast(textRes.Award[61])
          return
        end
        if 1 < r.sortid - gfi.sortid and gfi.sortid ~= -1 and r.sortid ~= 1 then
          Toast(textRes.Award[61])
          return
        end
        local req = require("netio.protocol.mzm.gsp.qingfu.CGetLevelGrowthFundActivityAward").new(self.curActivityId, r.sortid)
        gmodule.network.sendProtocol(req)
      end
      local ECMSDK = require("ProxySDK.ECMSDK")
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.GROWFUND, {
        2,
        r.id
      })
    end
  end
end
return GrowFundInfo.Commit()
