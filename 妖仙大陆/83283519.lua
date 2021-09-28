

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local EventDetail = require 'Zeus.UI.EventItemDetail'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
local DisplayUtil   = require "Zeus.Logic.DisplayUtil"
local ReworkUtil = require "Zeus.UI.XMasterReWork.GameUIReworkUtil"

local currentScore = 0
local newScore = 0
local seniorAddSore = 0

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

local function UpdateAttrStarScore(self, count, index, temp, posStr)
  local scoreAdd = GlobalHooks.DB.Find('ReBuildCf',temp).AddCf
  local scoreAddEx = GlobalHooks.DB.Find('ReBuildCf',2).AddCf
  if count == 4 then
    if index == 2 then
      scoreAdd = scoreAdd + scoreAddEx
    end
  elseif count == 5 then
    if index == 2 then
        if temp ==3 then
          scoreAdd = scoreAdd + scoreAddEx
        end
    elseif index == 3 then
      if temp == 2 then
        scoreAdd = scoreAdd + scoreAddEx
      end
    end
  end

  if posStr == "left" then
    currentScore = tonumber(self.lb_quality_old.Text) + scoreAdd
    self.lb_quality_old.Text = currentScore
    
  elseif posStr == "right" then
    newScore = tonumber(self.lb_quality_new.Text) + scoreAdd
    self.lb_quality_new.Text = newScore
  end
end

local function UpdateAttrStars(self, cans, attrMap, posStr)
  if posStr == "left" then
    seniorAddSore = 0
  end

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

local function GetAttrScoreByRandomAttr(attrs)
    local score = 0
    local maxScore = 0
    for i = 1, #(attrs) do
        local attr = attrs[i]
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
        if attrdata ~= nil  then
            score = math.ceil (score + attr.value*attrdata.ScoreRatio)
            maxScore = maxScore + attr.maxValue*attrdata.ScoreRatio
        end 
    end
    return score,maxScore
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
    if attr.value == attr.maxValue then
        lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text..Util.GetText(TextConfig.Type.ITEM, "man")
        gg_main_single:SetGaugeMinMax(0, attr.maxValue)
    else
        if gg_main_single.ValuePercent >= 70 then
            lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text
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

local function UpdateAttrFlag(node, attr, index, randomAtts)
  local up = node:FindChildByEditName('ib_up',false)
  local down = node:FindChildByEditName('ib_down',false)

  local isUp = 0
  for i,v in ipairs(randomAtts) do
    if v.id == attr.id and index == i then
      if v.value < attr.value then
        isUp = 1
      elseif v.value > attr.value then
        isUp = -1
      end
      break
    end
  end
  up.Visible = isUp > 0
  down.Visible = isUp < 0
end

local function UpdateReWorkAttsReBuild(self,select_equip)
    local attrMap = {}
    if self.reMakeType == 1 then
      local baseAtts = select_equip.detail.equip.tempExtAtts or { }
      
      
      
      
      for _, attr in ipairs(baseAtts) do
          if attr.value ~= nil then
              table.insert(attrMap,attr)      
          end        
      end      
    
      local tempstarAttr = select_equip.detail.equip.tempstarAttr or { }
      
      local item_counts = #attrMap
      self.sp_main_right.Scrollable:ClearGrid()
  
      if self.sp_main_right.Rows <= 0 then
          self.sp_main_right.Visible = true
          local cs = self.cvs_main_single.Size2D
          self.sp_main_right:Initialize(cs.x,cs.y,item_counts,1,self.cvs_main_single,
          function (gx,gy,node)
              node:FindChildByEditName('tbt_gou1',false).Visible = false
              node:FindChildByEditName('ib_none',false).Visible = false
              node:FindChildByEditName('btn_refine_lock',false).Visible = false
              SetSPAttItem(self,node,attrMap[gy+1])
          end,function () end)
      else
          self.sp_main_right.Rows = item_counts
      end
      UpdateAttrStars(self, self.cvs_star_right, attrMap, "right")
      if tempstarAttr and #tempstarAttr > 0 then
        self.lb_starpro_right.Text = GetComoboStrByAttrId(tempstarAttr[1])
        self.lb_starpro_right.Visible = true
      else
        self.lb_starpro_right.Visible = false
      end
    else
      local baseAtts = select_equip.detail.equip.tempExtAtts_senior or { }
      
      
      
      
      for _, attr in ipairs(baseAtts) do
          if attr.value ~= nil then
              table.insert(attrMap,attr)      
          end        
      end      
  
      local item_counts = #attrMap
      self.sp_main_right_senior.Scrollable:ClearGrid()
  
      if self.sp_main_right_senior.Rows <= 0 then
          self.sp_main_right_senior.Visible = true
          local cs = self.cvs_main_single_senior.Size2D
          self.sp_main_right_senior:Initialize(cs.x,cs.y,item_counts,1,self.cvs_main_single_senior,
          function (gx,gy,node)
              UpdateAttrFlag(node,attrMap[gy+1],gy+1, select_equip.detail.equip.randomAtts or { })
              SetSPAttItem(self,node,attrMap[gy+1])
          end,function () end)
      else
          self.sp_main_right_senior.Rows = item_counts
      end
    end
end

local function IsNeedLock(self,attrId)
  for i,v in ipairs(self.lockIdList) do
    if v == attrId then
      return true
    end
  end
  return false
end

local function UpdateLockStatus(self)
  local lockCount = #self.lockIdList
  for i,v in ipairs(self.lockNodeList) do
      local lockBtn = v:FindChildByEditName('tbt_gou1',false)
      local ib_none = v:FindChildByEditName('ib_none',false)
      local lockImg = v:FindChildByEditName('btn_refine_lock',false)
      local needLock = IsNeedLock(self,v.UserTag)
      lockBtn.IsChecked = needLock
      lockBtn.Enable = lockBtn.IsChecked or lockCount < self.maxLockNum
      ib_none.Visible = not lockBtn.Enable
      lockImg.Visible = lockBtn.IsChecked
  end

    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId) 
    UpdateReWorkAttsMat(self,static_data,lockCount) 
end

local function InitLockStatus(self,attrMap)
  local attrCount = #attrMap
  self.maxLockNum = 0
  if attrCount > 2 then
    self.maxLockNum = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Equipment.ReBuild_MaxNumtoLock"..attrCount})[1].ParamValue)
  end

  self.lockNodeList = {}
  for i,v in ipairs(attrMap) do
      local node = DisplayUtil.getCell(self.sp_main_left, i)
      if node ~= nil then
          node.UserTag = v.index
          table.insert(self.lockNodeList,node)
      end
  end

  local function insertLockId(id)
    local exist = false
    for i,v in ipairs(self.lockIdList) do
      if v == id then
        exist = true
      end
    end
    if exist == false then
      table.insert(self.lockIdList,id)
    end
  end

  local function removeLockId(id)
    for i,v in ipairs(self.lockIdList) do
      if v == id then
        table.remove(self.lockIdList,i)
        return
      end
    end
  end

  for i,v in ipairs(self.lockNodeList) do
      local lockBtn = v:FindChildByEditName('tbt_gou1',false)
      lockBtn.TouchClick = function (sender)
        if lockBtn.IsChecked then
          insertLockId(v.UserTag)
        else
          removeLockId(v.UserTag)
        end
        UpdateLockStatus(self)
      end
  end

  UpdateLockStatus(self)
end

local function UpdateReWorkAtts(self,select_equip) 
    local attrMap = {}
    if self.reMakeType == 1 then
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
      InitLockStatus(self, attrMap)
      UpdateAttrStars(self, self.cvs_star, attrMap, "left")
      if starAttr and #starAttr > 0 then
        self.lb_starpro.Text = GetComoboStrByAttrId(starAttr[1])
        self.lb_starpro.Visible = true
      else
        self.lb_starpro.Visible = false
      end
    else
      local baseAtts = select_equip.detail.equip.randomAtts or { }
      
      
      
      
      for _, attr in ipairs(baseAtts) do
          if attr.value ~= nil then
              table.insert(attrMap,attr)      
          end        
      end      

      local item_counts = #attrMap
      self.sp_main_left_senior.Scrollable:ClearGrid()
  
      if self.sp_main_left_senior.Rows <= 0 then
          self.sp_main_left_senior.Visible = true
          local cs = self.cvs_main_single_senior.Size2D
          self.sp_main_left_senior:Initialize(cs.x,cs.y,item_counts,1,self.cvs_main_single_senior,
          function (gx,gy,node)
              node:FindChildByEditName('ib_up',false).Visible = false
              node:FindChildByEditName('ib_down',false).Visible = false
              SetSPAttItem(self,node,attrMap[gy+1])
          end,function () end)
      else
          self.sp_main_left_senior.Rows = item_counts
      end

      local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId) 
      UpdateReWorkAttsMat(self,static_data,#self.lockIdList) 
    end
end

local function SetReWorkAttsNeedMat(self,matMap,node)
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

function UpdateReWorkAttsMat(self,select_equip,lockNum)
    local reBuildData
    if self.reMakeType == 1 then
      reBuildData = GlobalHooks.DB.Find("ReBuild", {Level = select_equip.LevelReq, LockNum = lockNum})[1]
    else
      reBuildData = GlobalHooks.DB.Find("SeniorReBuild",select_equip.LevelReq)
    end  

    self.lb_gold_number.Text = reBuildData.CostGold 
    local mygold = ItemModel.GetGold()
    self.lb_gold_number.FontColorRGBA = (mygold >= reBuildData.CostGold) and 0xffffffff or 0xff0000ff 

    self.nextNeedNum = reBuildData.CostGold
    local matMap = {}
    if reBuildData.MateCount1 > 0 then
        table.insert(matMap,{reBuildData.MateCode1,reBuildData.MateCount1})
    end    
    if reBuildData.MateCount2 > 0 then
        table.insert(matMap,{reBuildData.MateCode2,reBuildData.MateCount2})
    end
    if reBuildData.MateCount3 > 0 then
        table.insert(matMap,{reBuildData.MateCode3,reBuildData.MateCount3})
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
        
        SetReWorkAttsNeedMat(self,matMap[i],matMapUI[i])
    end
    
end

local function ClearSeniorAttrInfo(self,select_equip)
  select_equip.detail.equip.tempExtAtts_senior = {}
end

local function UpdateReMakeIcon(self,select_equip)
  self.select_equip = select_equip
  local static_data = ItemModel.GetItemStaticDataByCode(select_equip.TemplateId)	
	local itshow = Util.ShowItemShow(self.ib_hpd_icon,select_equip.IconId,select_equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	 
    
    
   
    
    
    
    local score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.randomAtts or {})
    local color = ReworkUtil.GetAttrQualityByScore(score,maxScore)
    if self.reMakeType == 1 then
      
      self.lb_quality_old.Text = select_equip.detail.equip.remakeScore or score
    else
      
      self.lb_quality_old_senior.Text = select_equip.detail.equip.remakeScore or score
    end
    currentScore = select_equip.detail.equip.remakeScore or score

    if self.reMakeType == 1 then
      score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.tempExtAtts or {})
    else
      score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.tempExtAtts_senior or {})
    end
    color = ReworkUtil.GetAttrQualityByScore(score,maxScore)
    if self.reMakeType == 1 then
      if color == -1 then 
          self.lb_quality_new.Text = ""
          newScore = 0
      else 
          
          self.lb_quality_new.Text = select_equip.detail.equip.tempRemakeScore or score
          newScore = select_equip.detail.equip.tempRemakeScore or score
      end
    else
      if color == -1 then 
          self.lb_quality_new_senior.Text = ""
          self.ib_up_senior.Visible = false
          self.ib_down_senior.Visible = false
          newScore = 0
      else 
          
          self.lb_quality_new_senior.Text = select_equip.detail.equip.seniorTempRemakeScore or score
          newScore = select_equip.detail.equip.seniorTempRemakeScore or score
          self.ib_up_senior.Visible = newScore >= currentScore and score > 0
          self.ib_down_senior.Visible = newScore < currentScore and score > 0
      end
    end
    

    UpdateReWorkAtts(self,select_equip) 

    
    if self.reMakeType == 1 then
      if select_equip.detail.equip.tempExtAtts ~= nil and #select_equip.detail.equip.tempExtAtts > 0 then
          self.cvs_remake.Visible = false
          self.cvs_remake_save.Visible = true  
          self.sp_main_right.Visible = true
          self.lb_detail_start.Visible = false
          UpdateReWorkAttsReBuild(self,select_equip) 
      else
          self.cvs_remake.Visible = true
          self.cvs_remake_save.Visible = false 
          self.sp_main_right.Visible = false
          self.lb_detail_start.Visible = true
          self.cvs_star_right.Visible = false
          self.lb_starpro_right.Visible = false
      end
    else
      if select_equip.detail.equip.tempExtAtts_senior ~= nil and #select_equip.detail.equip.tempExtAtts_senior > 0 then
          self.cvs_remake.Visible = false
          self.cvs_remake_save.Visible = true  
          self.sp_main_right_senior.Visible = true
          self.lb_detail_start_senior.Visible = false
          UpdateReWorkAttsReBuild(self,select_equip) 
      else
          self.cvs_remake.Visible = true
          self.cvs_remake_save.Visible = false 
          self.sp_main_right_senior.Visible = false
          self.lb_detail_start_senior.Visible = true
      end
    end

    local baseAtts = select_equip.detail.equip.randomAtts or { }
    if #baseAtts > 0 then 
      self.btn_remake.Visible = true
      
    else
      self.btn_remake.Visible = false
      
    end
end

local function OnBuySuccess(self)
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId) 
    UpdateReWorkAttsMat(self,static_data,#self.lockIdList) 
end

local function SendBI(self)
  local strAttBefore = ""
  local strAttAfter = ""
  local baseAtts = self.select_equip.detail.equip.randomAtts or { }
  for _, attr in ipairs(baseAtts) do
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
        local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
        strAttBefore = strAttBefore..str..";"
     end  
  end

  if self.reMakeType == 1 then
    baseAtts = self.select_equip.detail.equip.tempExtAtts or { }
  else
    baseAtts = self.select_equip.detail.equip.tempExtAtts_senior or { }
  end
  for _, attr in ipairs(baseAtts) do
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
        local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
        strAttAfter = strAttAfter..str..";"
     end  
  end

  local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)

  local strCost = ""
  local ReBornData = GlobalHooks.DB.Find("ReBuild", {Level = static_data.LevelReq, LockNum = #self.lockIdList})[1]

  local static_data_mat = ItemModel.GetItemStaticDataByCode(ReBornData.MateCode1)  
  strCost = string.format("%s(%s):%d,",static_data_mat.Name,ReBornData.MateCode1,ReBornData.MateCount1)
  local static_data_mat = ItemModel.GetItemStaticDataByCode(ReBornData.MateCode2) 
  strCost = strCost .. string.format("%s(%s):%d",static_data_mat.Name,ReBornData.MateCode2,ReBornData.MateCount2)

  local counterStr ="ReMakeCultivate"
  local valueStr =""
  local kingdomStr = string.format("%s_%s(%s)",self.select_equip.Id,static_data.Name,self.select_equip.TemplateId)
  local phylumStr =Util.GetText(TextConfig.Type.ITEM, "chongzhuqian") ..strAttBefore
  local classfieldStr = Util.GetText(TextConfig.Type.ITEM, "chongzhuhou").. strAttAfter

  local familyStr = Util.GetText(TextConfig.Type.ITEM, "xiaohao") .. strCost
  local genusStr =Util.GetText(TextConfig.Type.ITEM, "chongzhu")
end

local ui_names = 
{
	{name = 'cvs_center'}, 
	{name = 'ib_hpd_icon'}, 
	
	{name = 'lb_detail_start'}, 
  {name = 'lb_detail_start_senior'}, 
  {name = 'sp_main_left'}, 
	{name = 'sp_main_right'}, 
  {name = 'sp_main_left_senior'}, 
  {name = 'sp_main_right_senior'}, 
  {name = 'cvs_main_single'}, 
  {name = 'cvs_main_single_senior'}, 
  {name = 'cvs_deplete'}, 
  {name = 'lb_quality_old'}, 
  {name = 'lb_quality_new'}, 
  {name = 'lb_quality_old_senior'}, 
  {name = 'lb_quality_new_senior'}, 
  {name = 'ib_up_senior'}, 
  {name = 'ib_down_senior'}, 
	{name = 'cvs_remake'}, 
  {name = 'cvs_star'},
  {name = 'cvs_star_right'}, 
  {name = 'lb_starpro'}, 
  {name = 'lb_starpro_right'}, 
	{name = 'btn_remake',click = function (self)
      if self.reMakeType == 1 then
         ItemModel.EquipRebuildRequest(self.select_equip.Id,self.lockIdList,function ()   
            
            UpdateReMakeIcon(self,self.select_equip)
            Util.showUIEffect(self.cvs_center,7)
            Util.showUIEffect(self.cvs_center,37)

            
            
          end)
      else
        ItemModel.EquipSeniorRebuildRequest(self.select_equip.Id,function ()   
            
            UpdateReMakeIcon(self,self.select_equip)
            Util.showUIEffect(self.cvs_center,7)
            Util.showUIEffect(self.cvs_center,37)

            
            
          end)
      end
	end}, 
	
	{name = 'cvs_remake_save'}, 
	{name = 'btn_save',click = function (self)
          local strAttBefore = ""
          local strAttAfter = ""
          local baseAtts = self.select_equip.detail.equip.randomAtts or { }
          for _, attr in ipairs(baseAtts) do
            local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
            if attrdata ~= nil  then
                local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                strAttBefore = strAttBefore..str..";"
             end  
          end
          if self.reMakeType == 1 then
            baseAtts = self.select_equip.detail.equip.tempExtAtts or { }
          else
            baseAtts = self.select_equip.detail.equip.tempExtAtts_senior or { }
          end
          for _, attr in ipairs(baseAtts) do
            local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
            if attrdata ~= nil  then
                local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                strAttAfter = strAttAfter..str..";"
             end  
          end

          local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)  
      if self.reMakeType == 1 then
		    ItemModel.SaveRebuildRequest(self.select_equip.Id,function ()   
            
            ClearSeniorAttrInfo(self,self.select_equip)
            UpdateReMakeIcon(self,self.select_equip)
        end)
      else
        ItemModel.SaveSeniorRebuildRequest(self.select_equip.Id,function ()
            
            UpdateReMakeIcon(self,self.select_equip)
        end)
      end
	   end}, 
	{name = 'btn_continue',click = function (self)
    local OkFun = function()
      if self.reMakeType == 1 then
          ItemModel.EquipRebuildRequest(self.select_equip.Id,self.lockIdList,function ()   
                
                UpdateReMakeIcon(self,self.select_equip)
                Util.showUIEffect(self.cvs_center,7)
                Util.showUIEffect(self.cvs_center,37)
    
                
                
          end)
      else
          ItemModel.EquipSeniorRebuildRequest(self.select_equip.Id,function ()
            
            UpdateReMakeIcon(self,self.select_equip)
            Util.showUIEffect(self.cvs_center,7)
            Util.showUIEffect(self.cvs_center,37)

            
            
          end)
      end
    end

     if newScore > currentScore then
      local pingfengao = Util.GetText(TextConfig.Type.ITEM, "pingfengao")
      local goonchongzhu = Util.GetText(TextConfig.Type.ITEM, "goonchongzhu")
      local fanhui = Util.GetText(TextConfig.Type.ITEM, "fanhui")
      local notice = Util.GetText(TextConfig.Type.ITEM, "notice")

            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL, 
                pingfengao,
                goonchongzhu,
                fanhui,
                notice,
                nil,
                OkFun,
                nil
            )
        else
            OkFun()
        end

	            end}, 
	
  {name = 'cvs_dep_single1'}, 
  {name = 'cvs_dep_single2'}, 
  {name = 'cvs_dep_single3'}, 
	{name = 'lb_gold_number'}, 

  {name = 'tbn_left',click = function (self) 
    self.reMakeType = 1
    self.tbn_left.IsChecked = true
    self.tbn_left.Enable = false
    self.tbn_right.IsChecked = false
    self.tbn_right.Enable = true
    self.cvs_remake_main.Visible = true
    self.cvs_main_in.Visible = true
    self.cvs_remake_main_senior.Visible = false
    self.cvs_main_in_senior.Visible = false
    UpdateReMakeIcon(self,self.select_equip)
  end},

  {name = 'tbn_right',click = function (self) 
    self.reMakeType = 2
    self.tbn_left.IsChecked = false
    self.tbn_left.Enable = true
    self.tbn_right.IsChecked = true
    self.tbn_right.Enable = false
    self.cvs_remake_main.Visible = false
    self.cvs_main_in.Visible = false
    self.cvs_remake_main_senior.Visible = true
    self.cvs_main_in_senior.Visible = true
    UpdateReMakeIcon(self,self.select_equip)
  end},

  {name = 'cvs_remake_main'}, 
  {name = 'cvs_main_in'}, 
  {name = 'cvs_remake_main_senior'}, 
  {name = 'cvs_main_in_senior'}, 
  {name = 'btn_help',click = function (self)
      self.cvs_intrduce.Visible = not self.cvs_intrduce.Visible
  end},
  {name = 'cvs_intrduce'},
  {name = 'btn_intrduce',click = function (self)
      self.cvs_intrduce.Visible = false
  end},
}

local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_remake.gui.xml",tag)
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
  self.lockIdList = {}

  self.rework_main = rework_main
  if self.rework_main.left_choose_part ~= nil and self.rework_main.left_choose_part.select_equip ~= nil then
      self.cvs_center.Visible = true
  
      self.reMakeType = 1
      self.tbn_left.IsChecked = true
      self.tbn_left.Enable = false
      self.tbn_right.IsChecked = false
      self.tbn_right.Enable = true
      self.cvs_remake_main.Visible = true
      self.cvs_main_in.Visible = true
      self.cvs_remake_main_senior.Visible = false
      self.cvs_main_in_senior.Visible = false
      self.select_equip = self.rework_main.left_choose_part.select_equip
      UpdateReMakeIcon(self,self.select_equip)
  else
	    self.cvs_center.Visible = false
  end

  self.cvs_main_single.Visible = false
  self.cvs_main_single_senior.Visible = false
    

  GlobalHooks.Drama.Start("guide_remake", true)
end

_M.Create = Create
_M.ShowUI = ShowUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit =OnExit
return _M
