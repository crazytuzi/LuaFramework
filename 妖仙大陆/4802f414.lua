

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local EventDetail = require 'Zeus.UI.EventItemDetail'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
local DisplayUtil   = require "Zeus.Logic.DisplayUtil"
local ReworkUtil = require "Zeus.UI.XMasterReWork.GameUIReworkUtil"

function _M.Close(self)
  self.menu:Close()  
end

local function GetMaxSameAttrCount(attrMap)
  local count = #attrMap
  local index = 0
  for i=1,count do
    local tmp = 0
    for j=1,count do
      if attrMap[j].id == attrMap[i].id then
        tmp = tmp+1
      end
    end
    if tmp > index then
      index = tmp
    end
  end
  return index
end

local function GetAttrCount(attrMap)
  local count = #attrMap

  local index = 0
  local temp = 0

  local idList = {}
  local function isNewAttr(id)
    for i=1,#idList do
      if id == idList[i] then
        return true
      end
    end
    return false
  end
  for i=1,count do
    if not isNewAttr(attrMap[i].id) then
      table.insert(idList,attrMap[i].id)
    end
  end

  local index = #idList

  if count == 2 then
    if index == 1 then
      temp = 2
    end
  elseif count == 3 then
    if index == 2 then
      temp = 2
    end
  elseif count == 4 then
    if index == 2 then
      temp = GetMaxSameAttrCount(attrMap)
    end
  elseif count == 5 then
    if index == 1 then
      temp = 5
    elseif index == 2 then
      temp = GetMaxSameAttrCount(attrMap)
    elseif index == 3 then
      temp = GetMaxSameAttrCount(attrMap)
    elseif index == 4 then
      temp = 2
    end
  end
  return index,temp
end

local function UpdateAttrStars(self, cans, attrMap, posStr)
  local count = #attrMap
  if count <= 0 then
    cans.Visible = false
    return
  else
    cans.Visible = true
  end

  local index, temp = GetAttrCount(attrMap)

  if count == 1 then
      for i=1,5 do
          local star = cans:FindChildByEditName('ib_star'..i,false)
          star.Visible = false
      end
  elseif count == 2 then
      if index == 1 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 2 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      else
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              star.Visible = false
          end
      end
  elseif count == 3 then
      if index == 1 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 3 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      elseif index == 2 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 2 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      else
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              star.Visible = false
          end
      end
  elseif count == 4 then
      if index == 1 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 4 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      elseif index == 2 then
          if temp == 3 then
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 3 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Visible = false
                  end
              end
          else
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 2 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  elseif i <= 4 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Visible = false
                  end
              end
          end
      elseif index == 3 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 2 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      else
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              star.Visible = false
          end
      end
  elseif count == 5 then
      if index == 1 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
              star.Visible = true
          end
      elseif index == 2 then
          if temp == 4 then
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 4 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Visible = false
                  end
              end
          elseif temp == 3 then
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 3 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  end
              end
          end
      elseif index == 3 then
          if temp == 3 then
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 3 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Visible = false
                  end
              end
          else
              for i=1,5 do
                  local star = cans:FindChildByEditName('ib_star'..i,false)
                  if i <= 2 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|19", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  elseif i <= 4 then
                      star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                      star.Visible = true
                  else
                      star.Visible = false
                  end
              end
          end
      elseif index == 4 then
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              if i <= 2 then
                  star.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/ride/ride.xml|ride|5", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                  star.Visible = true
              else
                  star.Visible = false
              end
          end
      else
          for i=1,5 do
              local star = cans:FindChildByEditName('ib_star'..i,false)
              star.Visible = false
          end
      end
  end
end

local function SetEquipListItem(self,node,equip,index)
  if equip == nil then
    return
  end
  local static_data = ItemModel.GetItemStaticDataByCode(equip.TemplateId)
  
  local lb_detail_name = node:FindChildByEditName('lb_detail_name',false)
  local lb_detail_level = node:FindChildByEditName('lb_detail_level',false)
  
  local ib_icon = node:FindChildByEditName('ib_detail_icon',false)
  local itshow = Util.ShowItemShow(ib_icon,equip.IconId,equip.Quality)
  itshow.EnableTouch = true
  itshow.TouchClick = function (sender)
    
  end 
  
  node.Name = equip.Id

  local tbt_main = node:FindChildByEditName('tbt_deatil',false)
  tbt_main:SetBtnLockState(HZToggleButton.LockState.eLockSelect)  
  
  lb_detail_name.Text = static_data.Name
  lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)
  local equipLevel = Util.GetText(TextConfig.Type.ITEM,"equipLevel")
  
  lb_detail_level.Text =string.format(equipLevel,static_data.LevelReq)

  tbt_main.IsChecked = false
  tbt_main.Enable = true
  tbt_main.TouchClick = function (sender)
      if sender.IsChecked then
          sender.Enable = false
          UpdateRightEquip(self,equip)
      end
      if self.lastSender ~= nil then
          self.lastSender.IsChecked = false
          self.lastSender.Enable = true
      end
      self.lastSender = sender
  end

  if self.target_equip ~= nil and self.target_equip.Id == equip.Id then 
      tbt_main.IsChecked = true
      tbt_main.Enable = false
      UpdateRightEquip(self,equip)
      self.lastSender = tbt_main
  end
end

local function ChuanchengFilter(self,it)
  local static_data = ItemModel.GetItemStaticDataByCode(it.TemplateId)
  local select_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)
  if static_data.Qcolor < 4 then
      return false
  elseif it.Id == self.select_equip.Id then
      return false
  elseif static_data.LevelReq < select_data.LevelReq then
      return false
  elseif static_data.Type ~= select_data.Type then
      return false
  elseif it.detail.equip.pro ~= DataMgr.Instance.UserData.Pro then
      return false
  end
  return true
end

local function InitRightEquipList(self)
  self.cvs_equip_inherit.Visible = true

  local bag1 = DataMgr.Instance.UserData.RoleEquipBag
  local filter1 = ItemPack.FilterInfo.New()
  filter1.Type  = ItemData.TYPE_EQUIP
  filter1.CheckHandle = function (it)
        return ChuanchengFilter(self,it)
    end
  bag1:AddFilter(filter1)   
  local count1 = filter1.ShowData.Count

  local bag2 = DataMgr.Instance.UserData.RoleBag
  local filter2 = ItemPack.FilterInfo.New()
  filter2.Type  = ItemData.TYPE_EQUIP
  filter2.CheckHandle = function (it)
      return ChuanchengFilter(self,it)
    end
  bag2:AddFilter(filter2)   
  local count2 = filter2.ShowData.Count

  local totleCount = count1 + count2

  self.sp_scroll.Scrollable:ClearGrid()
  self.lastSender = nil

  if self.sp_scroll.Rows <= 0 then
    self.sp_scroll.Visible = true
    local cs = self.cvs_detail.Size2D
    self.sp_scroll:Initialize(cs.x,cs.y,totleCount,1,self.cvs_detail,
    function (gx,gy,node)
      local index = gy + 1
      local data = nil
      if index <= count1 then
        data = filter1:GetItemDataAt(index)
      else
        data = filter2:GetItemDataAt(index-count1)
      end
      SetEquipListItem(self,node,data,index)
    end,function () end)
  else
    self.sp_scroll.Rows = totleCount
  end 
  
  self.lb_none.Visible = totleCount <= 0

  bag1:RemoveFilter(filter1)
  bag2:RemoveFilter(filter2)
end

local function OnEnter(self)

end

local function OnExit(self)
  	  DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
end

local function GetComoboStrByAttrId(attr)
    if not attr then 
        return ""
    end
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
        return string.gsub(attrdata.attDesc,'{A}',tostring(v))
    end 
    return ""
end 

local function SetSPAttItem(self,node,attr)
    if attr == nil then
        node.Visible = false    
        return
    end
    local gg_main_single = node:FindChildByEditName('gg_main_single',false)
    gg_main_single.Text = ""
    local ib_main_single = node:FindChildByEditName('ib_main_single',false)
    local lb_wenzi = node:FindChildByEditName('lb_wenzi',false)

    ib_main_single.Visible = false

    lb_wenzi.Text = GetComoboStrByAttrId(attr)  
    gg_main_single:SetGaugeMinMax(attr.minValue, attr.maxValue) 
    gg_main_single.Value = (attr.value < attr.maxValue and attr.value) or attr.maxValue
    local gao = Util.GetText(TextConfig.Type.ITEM, "gao")
    local man = Util.GetText(TextConfig.Type.ITEM, "man")
    if attr.value == attr.maxValue then
        lb_wenzi.Text = gao..lb_wenzi.Text..man
        gg_main_single:SetGaugeMinMax(0, attr.maxValue)
    else
        if gg_main_single.ValuePercent >= 70 then
            lb_wenzi.Text = gao..lb_wenzi.Text
        end     
    end

    
    if gg_main_single.ValuePercent >= 70 then
        local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xba75f5ff)
        local layoutColor = gg_main_single.Strip.UnityObject:GetComponent("UILayoutGraphics");
        layoutColor.color = color
    else
        local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xfee49cff)
        local layoutColor = gg_main_single.Strip.UnityObject:GetComponent("UILayoutGraphics");
        layoutColor.color = color
    end

end

local function SetCostMoney(self, needNum)
     self.lb_gold_number.Text = needNum
     local mygold = ItemModel.GetGold()
     self.lb_gold_number.FontColorRGBA = (mygold >= needNum) and 0xffffffff or 0xff0000ff
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
        if self.nextNeedNum then
            SetCostMoney(self, self.nextNeedNum)
        end
    end
end

local function SetChuanChengNeedMat(self,matMap,node)
  node.Visible = true    
  local cvs_dep_need = node:FindChildByEditName('cvs_dep_need',false)
  local tb_dep_single = node:FindChildByEditName('tb_dep_single',false)
  local ib_dep_goicon = node:FindChildByEditName('ib_dep_goicon',false)
  
  local matName = matMap[1]    
  local matCount = matMap[2]      
  
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(matName)    
  local x = (vItem and vItem.Num) or 0
  
  local item = nil  
  if vItem == nil then
    local static_data = ItemModel.GetItemStaticDataByCode(matName)  
    item = Util.ShowItemShow(cvs_dep_need, static_data.Icon, static_data.Qcolor, 1)
  else
    item = Util.ShowItemShow(cvs_dep_need, vItem.IconId, vItem.Quality, 1)
  end
  
  local cost = matCount
    local isLessItem    
        
  if x < cost then
    isLessItem = true
    tb_dep_single.XmlText = string.format("<b> <f size='22' color='ffff0000'>%d</f>/%d</b>",x,cost)
  else
    isLessItem = false
    tb_dep_single.XmlText = string.format("<b> <f size='22' color='ff00ff00'>%d</f>/%d</b>",x,cost)
  end
  ib_dep_goicon.Visible = (x < cost)    
    
  Util.NormalItemShowTouchClick(item,matName,isLessItem)
end

function UpdateChuanChengCost(self,select_equip)
    local chuanChengCost = GlobalHooks.DB.Find("Smriti", {Level = select_equip.LevelReq})[1]

    self.lb_gold_number.Text = chuanChengCost.CostGold 
    local mygold = ItemModel.GetGold()
    self.lb_gold_number.FontColorRGBA = (mygold >= chuanChengCost.CostGold) and 0xffffffff or 0xff0000ff 

    self.nextNeedNum = chuanChengCost.CostGold
    local matMap = {}
    if chuanChengCost.MateCount1 > 0 then
        table.insert(matMap,{chuanChengCost.MateCode1,chuanChengCost.MateCount1})
    end    
    if chuanChengCost.MateCount2 > 0 then
        table.insert(matMap,{chuanChengCost.MateCode2,chuanChengCost.MateCount2})
    end
    if chuanChengCost.MateCount3 > 0 then
        table.insert(matMap,{chuanChengCost.MateCode3,chuanChengCost.MateCount3})
    end
    self.cvs_dep_single1.Visible = false
    self.cvs_dep_single2.Visible = false
    self.cvs_dep_single3.Visible = false
    
    local matMapUI = {}
    if #matMap == 1 then
        table.insert(matMapUI,self.cvs_dep_single1)
        self.cvs_dep_single1.X = 97
    elseif #matMap == 2 then
        table.insert(matMapUI,self.cvs_dep_single2) 
        self.cvs_dep_single2.X = 72   
        table.insert(matMapUI,self.cvs_dep_single3) 
        self.cvs_dep_single3.X = 175
    elseif #matMap == 3 then
        table.insert(matMapUI,self.cvs_dep_single2)   
        self.cvs_dep_single2.X = 40
        table.insert(matMapUI,self.cvs_dep_single1) 
        self.cvs_dep_single1.X = 130
        table.insert(matMapUI,self.cvs_dep_single3)
        self.cvs_dep_single3.X = 220
    end     

    for i=1, #(matMap) do
        SetChuanChengNeedMat(self,matMap[i],matMapUI[i])
    end
end

local function ClearRightEquip(self)
    
    self.lb_quality_new.Text = 0
    self.sp_main_right.Scrollable:ClearGrid()

    self.cvs_star_right.Visible = false
    self.lb_starpro_right.Visible = false
    self.ib_icon2.Visible = false

    self.lb_initial.Visible = true
    self.ib_texiao2.Visible = false
end

local function UpdateLeftEquip(self,select_equip)
    self.select_equip = select_equip

    
    

    local static_data = ItemModel.GetItemStaticDataByCode(select_equip.TemplateId)	
	  local itshow = Util.ShowItemShow(self.ib_icon1,select_equip.IconId,select_equip.Quality)
	  itshow.EnableTouch = true
	  itshow.TouchClick = function (sender)
	  end

    
    local score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.randomAtts or {})
    self.leftScore = select_equip.detail.equip.remakeScore or score
    self.lb_quality_old.Text = self.leftScore

    local attrMap = {}
    local baseAtts = select_equip.detail.equip.randomAtts or { }
    for _, attr in ipairs(baseAtts) do
        local a = attr
        a.index = _
        if a.value ~= nil then
            table.insert(attrMap,a)      
        end        
    end
    local starAttr = select_equip.detail.equip.starAttr or { }
    local item_counts = #attrMap
    self.sp_main_left.Scrollable:ClearGrid()

    if self.sp_main_left.Rows <= 0 then
        self.sp_main_left.Visible = true
        local cs = self.cvs_main_single.Size2D
        self.sp_main_left:Initialize(cs.x,cs.y,item_counts,1,self.cvs_main_single,
        function (gx,gy,node)
            SetSPAttItem(self,node,attrMap[gy+1])
        end,function () end)
    else
        self.sp_main_left.Rows = item_counts
    end
    UpdateAttrStars(self, self.cvs_star, attrMap, "left")
    if starAttr and #starAttr > 0 then
      self.lb_starpro.Text = GetComoboStrByAttrId(starAttr[1])
      self.lb_starpro.Visible = true
    else
      self.lb_starpro.Visible = false
    end

    local baseAtts = select_equip.detail.equip.randomAtts or { }
    if #baseAtts > 0 then 
      self.btn_chuancheng.Visible = true
      self.tbt_choose.Visible = true
    else
      self.btn_chuancheng.Visible = false
      self.tbt_choose.Visible = false
    end

    UpdateChuanChengCost(self,static_data)
end

local function FindEquipListItem(self,equip_id)
  local child_list = self.sp_scroll.Scrollable.Container:GetAllChild()
  local children = Util.List2Luatable(child_list)
  for _,v in ipairs(children) do
    if v.Name == equip_id then
      return v
    end
  end
  return nil
end

function UpdateRightEquip(self,target_equip)
    self.target_equip = target_equip

    if target_equip == nil then
        ClearRightEquip(self)
        return
    end

    self.lb_initial.Visible = false
    self.ib_texiao2.Visible = true
    
    

    local static_data = ItemModel.GetItemStaticDataByCode(target_equip.TemplateId)
    self.ib_icon2.Visible = true
    local itshow = Util.ShowItemShow(self.ib_icon2,target_equip.IconId,target_equip.Quality)
    itshow.EnableTouch = true
    itshow.TouchClick = function (sender)
    end

    
    local score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(target_equip.detail.equip.randomAtts or {})
    self.rightScore = target_equip.detail.equip.remakeScore or score
    self.lb_quality_new.Text = self.rightScore

    local attrMap = {}
    local baseAtts = target_equip.detail.equip.randomAtts or { }
    for _, attr in ipairs(baseAtts) do
        local a = attr
        a.index = _
        if a.value ~= nil then
            table.insert(attrMap,a)      
        end        
    end
    local starAttr = target_equip.detail.equip.starAttr or { }
    local item_counts = #attrMap
    self.sp_main_right.Scrollable:ClearGrid()

    if self.sp_main_right.Rows <= 0 then
        self.sp_main_right.Visible = true
        local cs = self.cvs_main_single.Size2D
        self.sp_main_right:Initialize(cs.x,cs.y,item_counts,1,self.cvs_main_single,
        function (gx,gy,node)
            SetSPAttItem(self,node,attrMap[gy+1])
        end,function () end)
    else
        self.sp_main_right.Rows = item_counts
    end
    UpdateAttrStars(self, self.cvs_star_right, attrMap, "right")
    if starAttr and #starAttr > 0 then
      self.lb_starpro_right.Text = GetComoboStrByAttrId(starAttr[1])
      self.lb_starpro_right.Visible = true
    else
      self.lb_starpro_right.Visible = false
    end
end

local function OnBuySuccess(self)
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)
    UpdateChuanChengCost(self,static_data) 
end

local ui_names = 
{
	{name = 'cvs_center'}, 
	{name = 'ib_icon1'}, 
  {name = 'ib_icon2'}, 
  {name = 'sp_main_left'}, 
	{name = 'sp_main_right'}, 
  {name = 'cvs_main_single'},
  {name = 'cvs_detail'},
  {name = 'sp_scroll'},
  {name = 'cvs_deplete'}, 
  {name = 'lb_quality_old'}, 
  {name = 'lb_quality_new'}, 
	{name = 'cvs_remake'},
  {name = 'cvs_star'},
  {name = 'cvs_star_right'}, 
  {name = 'lb_starpro'}, 
  {name = 'lb_starpro_right'},
  {name = 'lb_none'},
  {name = 'lb_initial'},
  {name = 'cvs_mask',click = function (self)
      self.cvs_mask.Visible = false
      self.cvs_intrduce.Visible = false
  end},
	{name = 'btn_chuancheng',click = function (self)
    if self.target_equip ~= nil then
      local OkFun = function()
          ItemModel.SmritiRequest(self.select_equip.Id,self.target_equip.Id,function ()
              self.cvs_equip_inherit.Visible = false
              UpdateLeftEquip(self,self.select_equip)
              UpdateRightEquip(self,self.target_equip)
              Util.showUIEffect(self.cvs_center,7)
              Util.showUIEffect(self.cvs_center,60)
          end)
      end
      local string = Util.GetText(TextConfig.Type.ITEM, "rightequip")
      if self.rightScore > self.leftScore then
        string = Util.GetText(TextConfig.Type.ITEM, "rightequip2")
      end
      local ok = Util.GetText(TextConfig.Type.ITEM, "ok")
      local cancel = Util.GetText(TextConfig.Type.ITEM, "cancel")
      local notice = Util.GetText(TextConfig.Type.ITEM, "notice")
      GameAlertManager.Instance:ShowAlertDialog(
              AlertDialog.PRIORITY_NORMAL, 
              string,
              ok,
              cancel,
              notice,
              nil,
              OkFun,
              nil
      )
    else
      GlobalHooks.Drama.Start('guide_chuancheng', true)
    end
	end},
  {name = 'cvs_dep_single1'}, 
  {name = 'cvs_dep_single2'}, 
  {name = 'cvs_dep_single3'}, 
	{name = 'lb_gold_number'}, 
  {name = 'btn_choice2',click = function (self)
      if self.cvs_equip_inherit.Visible == false then
        InitRightEquipList(self)
      end
      self.tbt_choose.IsChecked = self.cvs_equip_inherit.Visible
  end},
  {name = 'tbt_choose',click = function (self)
      if self.cvs_equip_inherit.Visible == false then
        InitRightEquipList(self)
      else
        self.cvs_equip_inherit.Visible = false
      end
  end},
  {name = 'btn_close',click = function (self)
      self.tbt_choose.IsChecked = false
      self.cvs_equip_inherit.Visible = false
  end},
  {name = 'cvs_equip_inherit'},
  {name = 'btn_help',click = function (self)
      self.cvs_intrduce.Visible = true
      self.cvs_mask.Visible = true
  end},
  {name = 'cvs_intrduce',click = function (self)
      self.cvs_intrduce.Visible = false
  end},
  {name = 'ib_texiao2',click = function (self)
      self.cvs_intrduce.Visible = false
  end},
}

local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_chuancheng.gui.xml",tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self) 

  DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
  self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)

  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)

  self.menu:SubscribOnExit(function ()
	OnExit(self)
	end)
end

local function Create(tag)
  local self = {}
  setmetatable(self, _M)
  InitComponent(self,tag)
  return self
end


local function ShowUI(self,rework_main)
  self.rework_main = rework_main
  if self.rework_main.left_choose_part ~= nil and self.rework_main.left_choose_part.select_equip ~= nil then
      self.cvs_center.Visible = true
  
      self.select_equip = self.rework_main.left_choose_part.select_equip
      self.target_equip = nil
      UpdateLeftEquip(self,self.select_equip)
      UpdateRightEquip(self,self.target_equip)
      self.tbt_choose.Visible = true
  else
      self.tbt_choose.Visible = false
	    self.cvs_center.Visible = false
  end

  self.tbt_choose.IsChecked = false
  self.cvs_equip_inherit.Visible = false
  self.cvs_main_single.Visible = false
  self.cvs_detail.Visible = false
  self.cvs_mask.Visible = false
  self.cvs_intrduce.Visible = false

  
end

_M.Create = Create
_M.ShowUI = ShowUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit =OnExit
return _M
