local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local ItemModel         = require 'Zeus.Model.Item'
local MountModel        = require "Zeus.Model.Mount"
local MasteryUtil   	= require 'Zeus.UI.MasteryUtil'
local RideModelBase     = require 'Zeus.UI.XmasterRide.RideModelBase'
local RideEquipListUI = require "Zeus.UI.XmasterRide.RideEquipList"

local self = {
	menu = nil,
}

local function OpenRideEquipList()
	if (self.equipListUI == nil) then
       	self.equipListUI = RideEquipListUI.Create(GlobalHooks.UITAG.GameUIRideEquipList,self)
       	self.cvs_main_center:AddChild(self.equipListUI.menu)
       	self.equipListUI.menu.X = self.cvs_culture.X - 48
       	self.equipListUI.menu.Y = self.cvs_culture.Y - 5
  end
  self.equipListUI:OnEnter()
end

local function showRideEffect(index)
  Util.clearAllEffect(self.cvs_effect)
  if index == 2 then
    Util.showUIEffect(self.cvs_effect,6)
  else
    Util.showUIEffect(self.cvs_effect,54)
  end
end

local function showcpjAnimo(index) 
  local path = "dynamic_n/effects/pet_lvup/pet_lvup.xml"
  local cpjname = "starup_success"
  if index == 1 then
    path = "dynamic_n/effects/evolve_suc/evo_suc.xml"
    cpjname = "evolve_suc"
  end
  local animationNode = GameAlertManager.Instance.CpjAnime:CreateCpjAnime(nil,path,cpjname,0,0,false)
  self.animationNode = animationNode
  if nil ~= animationNode then
      if index == 1 then
    	animationNode.Scale = Vector2.New(2.0, 2.0)
      else
        animationNode.Scale = Vector2.New(4.0, 4.0)
      end
    	animationNode.X = 0
    	animationNode.Y = 0
  	
     
     
     
     
  end
end

local function ReqUpRideLv(type)
	MountModel.trainingMountRequest(type, function ()
    local PreviousStarLv = self.RideData.starLv
    local PreviousRideLevel = self.RideData.rideLevel
    
    local ItemData = nil
    local familyStr = nil
    ItemData = MountModel.GetRideUpCost(self.RideData.rideLevel)
    
    local detail = nil
    
    if type == 2 then
      detail = ItemModel.GetItemDetailByCode(ItemData.UpStarItemCode)
      familyStr = detail.static.Name.."("..ItemData.UpStarItemCode..")"..":"..ItemData.UpStarItemCount
    else
      detail = ItemModel.GetItemDetailByCode(ItemData.UpLevelItemCode) 
      familyStr = detail.static.Name.."("..ItemData.UpLevelItemCode..")"..":"..ItemData.UpLevelItemCount
    end
    self.RideData = MountModel.GetMyMountInfo()
    
    
    showRideEffect(type)
    RefreshRideData()
    
    
    if type == 2 then
      Util.showUIEffect(self.ib_zuoqitexiao,32)
      XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('ridelevelup')
      
    else
      Util.showUIEffect(self.ib_zuoqitexiao,33)
      XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('ridebreak')
      
    end  
    
    
    
    
    
    

  end)
end

local function RefreshBtnCallBack(canUpLevel)
  if canUpLevel then 
      self.btn_up.TouchClick = function ()
        ReqUpRideLv(2)
        self.openGetDetail = false
      end
      self.btn_up.Text = Util.GetText(TextConfig.Type.MOUNT, 'starUp')
  else 
      self.btn_up.TouchClick = function ()
        ReqUpRideLv(1)
      end
      self.btn_up.Text = Util.GetText(TextConfig.Type.MOUNT, 'upgrade')
  end
end

local function RefreshRideCost()
	local isTopLv = MountModel.IsRideTopLevel(self.RideData.rideLevel, self.RideData.starLv)
	local canUpLevel = self.RideData.starLv < 10
    self.cvs_material.Visible = not isTopLv
	self.lb_up.Visible = false

  if self.filter then
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
  end
	if not isTopLv then
      RefreshBtnCallBack(canUpLevel)
      local ItemData = MountModel.GetRideUpCost(self.RideData.rideLevel)
      local itemCode = ItemData.UpStarItemCode
      local itemCount = ItemData.UpStarItemCount
      if not canUpLevel then
          itemCode = ItemData.UpLevelItemCode
          itemCount = ItemData.UpLevelItemCount
      end

      local it = GlobalHooks.DB.Find("Items",itemCode)
      local c = Util.GetQualityColorRGBA(it.Qcolor)
      self.lb_mate.Text = it.Name
      self.lb_mate.FontColorRGBA = c
      local itshow = Util.ShowItemShow(self.cvs_mate,it.Icon,it.Qcolor)
      local bag_data = DataMgr.Instance.UserData.RoleBag
      self.filter = self.filter or ItemPack.FilterInfo.New()
      self.filter.CheckHandle = function (it)
        return it.TemplateId == itemCode
      end
      self.filter.NofityCB = function ()
        local vItem = bag_data:MergerTemplateItem(itemCode)
        local hasCount = (vItem and vItem.Num) or 0
        local isLessItem
        if hasCount < itemCount then
          isLessItem = true
          self.tb_num.XmlText = string.format("<b> <f size='22' color='ffff0000'>%d</f>/%d</b>",hasCount,itemCount)
        else
          isLessItem = false
          self.tb_num.XmlText = string.format("<b> <f size='22' color='ffe7e5d1'>%d</f>/%d</b>",hasCount,itemCount)
        end
        self.lb_up.Visible = not isLessItem
        Util.NormalItemShowTouchClick(itshow,itemCode,isLessItem)
        if isLessItem == true then
          self.btn_up.TouchClick = function ()
            if self.openGetDetail then
                return
            end
            self.openGetDetail = true
            local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, itemCode)
            obj.closeEvent = function()
               self.openGetDetail = false
            end
          end
        else
          RefreshBtnCallBack(canUpLevel)
        end
      end
      bag_data:AddFilter(self.filter)
  else
    self.lb_up.Visible = not isTopLv
	end
end

local function RefreshRideStar()
	local num = self.RideData.starLv
  	for i=1,#self.stars do
        self.stars[i].Enable = i <= num
  	end
end

local function RefreshRideAttr()
    for i=1,#self.RideData.mountAttrs do
        if i <= 8 then
          local v = self.RideData.mountAttrs[i]         
          local name = MountModel.GetSkinAttrNameId(v.id)
      
          
          
          
          if self.RideData.mountAttrsNext and  #self.RideData.mountAttrsNext > 0 then
            local m = self.RideData.mountAttrsNext[i]
            if v.id == 1 then
              self.tb_shengming.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 3 then
              self.tb_gongji.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 9 then
              self.tb_mingzhong.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 12 then
              self.tb_shanbi.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 15 then
              self.tb_baoji.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 18 then
              self.tb_kangbao.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            elseif v.id == 23 then
              self.tb_fangyu.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), tostring(m.maxValue))
            end
              
          else
            self.btn_up.Visible = false
            local MaxLevel = Util.GetText(TextConfig.Type.MOUNT, "MaxLevel")
            if v.id == 1 then
              self.tb_shengming.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 3 then
              self.tb_gongji.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 9 then
              self.tb_mingzhong.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 12 then
              self.tb_shanbi.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 15 then
              self.tb_baoji.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 18 then
              self.tb_kangbao.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            elseif v.id == 23 then
              self.tb_fangyu.XmlText = MountModel.GetAddAttrString(name, tostring(v.maxValue), MaxLevel)
            end  
              
          end
          
          
        end
    end
end


local function SkinRefreshSkinAttr(skinId, cans)
    local list = MountModel.GetSkinAttrById(skinId)
    for k,v in pairs(list) do
        if k <= 6  then
          local label = cans:FindChildByEditName("tb_attr"..k,true)
          if k == 1 then
            v.maxValue = v.maxValue / 100
            label.XmlText = MountModel.NewGetAttrString(v.name, v.maxValue .."%")
          else
            label.XmlText = MountModel.GetAttrString(v.name, v.maxValue)  
          end     
          label.TextComponent.Anchor = TextAnchor.L_C
          label.Visible = v.maxValue > 0
        end
    end
end



local function RefreshRideEquip()
	local equipsNum = 0
  if self.RideData.equipList and #self.RideData.equipList > 0 then
    equipsNum = #self.RideData.equipList
  end
	
	
	
	
	
	
	
end

local function RefreshRideNameAndSkin()
  local nameString = MountModel.GetSkinDataById(self.RideData.usingSkinID).SkinName
  local SkinQColor = MountModel.GetSkinDataById(self.RideData.usingSkinID).SkinQColor
	self.lb_name.Text = nameString
  self.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(SkinQColor)

	local glvStr = MasteryUtil.numToHanzi[self.RideData.rideLevel+1]
	local starLv = MasteryUtil.numToHanzi[self.RideData.starLv+1]
	self.tb_level.XmlText = Util.GetText(TextConfig.Type.MOUNT, 'level', glvStr,starLv)
  self.tb_level.TextComponent.Anchor = TextAnchor.C_C
end

function RefreshRideData()
	RefreshRideNameAndSkin()
	RefreshRideAttr()
	RefreshRideStar()
	RefreshRideCost()
end

local function DestoryMod()
  	if self.modObj ~=nil then
    	RideModelBase.ClearModel(self.modObj)
    	self.modObj = nil
  	end
end

local function Refresh3dModel()
 	local modelFile = MountModel.GetSkinDataById(self.RideData.usingSkinID).ModelFile
  if self.modObj ~= nil then
 	 	DestoryMod()
  end
  self.modObj = {}
  RideModelBase.InitModelAvaterstr(self.modObj, self.cvs_3d, modelFile, nil, false)
  IconGenerator.instance:SetBackGroundImage(self.modObj.Model3DAssetBundel, "Textures/IconGenerator/mountshowbk")
end

local function ReqRideInfo()
	MountModel.getMountInfoRequest(function ()
		  self.RideData = MountModel.GetMyMountInfo()
		  Refresh3dModel()
		  RefreshRideEquip()
      RefreshRideData()
      SkinRefreshSkinAttr(self.RideData.usingSkinID, self.cvs_prop1)
    end)
end

local function OnExit()
	self.RideData = nil

	if self.animationNode then
    self.animationNode:RemoveFromParent(true)
  end
	DestoryMod()
  Util.clearAllEffect(self.cvs_effect)
end

local function OnEnter()
	ReqRideInfo()

  GlobalHooks.Drama.Start('guide_ride', true)
end

local function InitUI()
	local UIName = {
		    "cvs_main_center",
        "cvs_3d",
        "lb_name",
        "tb_level",
        "cvs_effect",
        
        
        "cvs_culture",
        "cvs_prop",
        "cvs_prop1",

        "cvs_material",
        "cvs_mate",
        "lb_mate",
        "tb_num",
        "btn_up",
        "lb_up",
        "ib_zuoqitexiao",
        "tb_gongji",
        "tb_baoji",
        "tb_fangyu",
        "tb_shanbi",
        "tb_mingzhong",
        "tb_kangbao",
        "tb_shengming"
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.stars = {}
    for i=1,10 do
    	self.stars[i] = self.menu:GetComponent("ib_star"..i)
    end

    self.cvs_Showprop = self.menu:GetComponent("cvs_prop1")
    self.SkinsData = MountModel.GetAllSkinList()
    
    
    
    
    
    
    

    
    
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
	self.menu = LuaMenuU.Create("xmds_ui/ride/culture.gui.xml", GlobalHooks.UITAG.GameUIRideTrain)
	self.menu.Enable = false
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

return {Create = Create, initial = initial}
