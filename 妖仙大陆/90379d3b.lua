local Item = require "Zeus.Model.Item"
local Util   = require 'Zeus.Logic.Util'
local GDRQ = require "Zeus.Model.Guild"
local ItemModel = require 'Zeus.Model.Item'
local ItemDetail = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'

local _M = {}
_M.__index = _M

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function Close(self)
  self.menu:Close()  
end

local function initControls(view, names, tbl)
  for i = 1, #names, 1 do
    local ui = names[i]
    local ctrl = view:FindChildByEditName(ui.name, true)
    if (ctrl) then
      tbl[ui.name] = ctrl
      if (ui.click) then
        ctrl.event_PointerClick = function()
          ui.click(tbl)
        end
      end
    end
  end
end

local function OnEnter(self)
  
end

local function OnExit(self)
  
  self.cvs_mid:RemoveAllChildren(true)
  self.cvs_right:RemoveAllChildren(true)
  self.cvs_left:RemoveAllChildren(true)
  if self._exitcb then 
    self._exitcb()
  end
end

local function OnDestory(self)
  
end

local function SetExitCallback(self,cb)
  self._exitcb = cb 
end

local ui_names = 
{
  {name = 'cvs_bg'},
  {name = 'cvs_left'},
  {name = 'cvs_right'},
  {name = 'cvs_mid'}
}


local function InitComponent(self,tag,param)
	
	self.menu = LuaMenuU.Create('xmds_ui/consignment/coordinate.gui.xml',tag)
  
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.menu:SubscribOnExit(function ()
    OnExit(self)
    end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
    end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
    end)
  self.cvs_bg.TouchClick = function()
    Close(self)
  end
end

function _M.Createtest(tag, parent, buttons, callback)
  local ret = { }
  setmetatable(ret, _M)
  ret.menu = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniitem_info_detailed.gui.xml")
  initControls(ret.menu, ui_names, ret)
  initMiniMaterial(ret)
  ret.cvs_information_detailed:AddChild(ret.material)
  initMiniEquipment(ret)
  ret.cvs_information_detailed:AddChild(ret.equip)
  ret.eventItemDetail = EventItemDetail.Create(3)
  if(buttons) then
    ret:setButtons(buttons,callback)
  end

  if (parent) then
    parent:AddChild(ret.menu)
  end
  return ret
end


local  ui_auction_names = 
{
  {name = 'tb_op_tip'},
  {name = 'lb_surplusnum'},
  {name = 'btn_cancel'},
  {name = 'btn_delete',},
  {name = 'btn_deposit',},
  {name = 'btn_take',}
}

local function FindWHvalue(code)
  local eq = GlobalHooks.DB.Find("Items",code)
  local eqvalue = GlobalHooks.DB.Find("WareHouseValue",{})
  for k,v in pairs(eqvalue) do
    if eq.LevelReq == v.EquipLv and eq.Qcolor == v.EquipColor then
      return v
    end
  end
end

local function setOPDetailTip(itshow,is_bag,data,self)
  if is_bag then
    self.lb_surplusnum.Text = (data.savaData.maxnum - data.savaData.curnum).."/"..data.savaData.maxnum
    if data.savaData.maxnum - data.savaData.curnum == 0 then
      self.lb_surplusnum.FontColor = GameUtil.RGBA2Color(0xff0000ff) 
    else
      self.lb_surplusnum.FontColor = GameUtil.RGBA2Color(0x00d600ff) 
    end
  else
    self.lb_surplusnum.Text = (data.deleteData.max - data.deleteData.cur).."/"..data.deleteData.max
    if data.deleteData.max - data.deleteData.cur == 0 then
      self.lb_surplusnum.FontColor = GameUtil.RGBA2Color(0xff0000ff) 
    else
      self.lb_surplusnum.FontColor = GameUtil.RGBA2Color(0x00d600ff) 
    end
  end

  local staticVo = GlobalHooks.DB.Find("Items", itshow.LastItemData.TemplateId)
  if not GuildUtil.GetItemIsDepotInterval(staticVo) then
    self.tb_op_tip.XmlText = GetTextConfg("guild_Depot_cannotin")
    return
  end

  local stv = FindWHvalue(itshow.LastItemData.TemplateId)
  local curPointNum = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PAWNGOLD)
  local numvalue = is_bag and stv.WareHouseValue or stv.WareHouseCost
  local num_txt = string.format("<f color='ff00d600'>%s</f>",numvalue)
  if not is_bag and curPointNum<numvalue then
    num_txt = string.format("<f color='ffff0000'>%s</f>",numvalue)
  end
  if is_bag then
    self.tb_op_tip.XmlText = string.format(GetTextConfg("guild_Depot_in"),num_txt)
  else
    self.tb_op_tip.XmlText = string.format(GetTextConfg("guild_Depot_out"),num_txt)
  end
end

local function SetItemData(self,it,is_bag,data)
  local detail = it.LastItemData.detail
  print("--------------detaildetaildetaildetail = " .. PrintTable(detail))
  local  node
  local  lvTextNode
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(detail.static.Code)

  if detail.equip ~= nil then
    local data = ItemModel.GetLocalCompareDetail(detail.itemSecondType)
    local  parent = self.cvs_mid
    if data then 
      parent = self.cvs_right
      self.cvs_mid.Enable = false
      self.cvs_left.Enable = true
      self.cvs_right.Enable = true

      local compEquip = ItemDetail.CreateWithBagUI(0,self.cvs_left)
      compEquip:setEquip(data)
      compEquip.equip.Visible = true
    else
      self.cvs_mid.Enable = true
      self.cvs_left.Enable = false
      self.cvs_right.Enable = false
    end
    node = XmdsUISystem.CreateFromFile("xmds_ui/guild/information_equip.gui.xml")
    
    self.item = ItemDetail.SetGuildWareHouseItemUI(nil,node,detail)
    parent:AddChild(node)

    lvTextNode =  self.item.equipCtrl.lb_level
    if Util.GetProTxt(DataMgr.Instance.UserData.Pro) ~= detail.static.Pro then
      self.item.equipCtrl.lb_profession.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
    end
  end

  local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
  if self_lv < detail.static.LevelReq then
    lvTextNode.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
  end

  initControls(node,ui_auction_names,self)
  setOPDetailTip(it,is_bag,data,self)

  if is_bag == true then 
    self.btn_cancel.Visible = true
    self.btn_delete.Visible = false
    self.btn_deposit.Visible = true
    self.btn_take.Visible = false
  else 
    self.btn_cancel.Visible = true
    self.btn_delete.Visible = GDRQ.GetMyInfoFromGuild().job==1 and not is_bag
    self.btn_deposit.Visible = false
    self.btn_take.Visible = true
  end
end


local function Create(tag,param)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag,param)
  return ret
end

_M.SetItemData = SetItemData
_M.Create = Create
_M.Close  = Close
_M.SetExitCallback = SetExitCallback

return _M
