local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local EventDetail = require 'Zeus.UI.EventItemDetail'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
function _M.Close(self)
  self.menu:Close()  
end


local function OnEnter(self)
    
end

local function OnExit(self)
  	DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
end

local function GetComoboStrByAttrId(attr, showType)
    
    if not attr then 
        return ""
    end
    local max = attr.maxValue
    if max < 0 then
      max = attr.minValue
    end
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
        if showType == 2 then
          v = (attrdata.isFormat == 1 and string.format("%.2f", max / 100)) or max
        end
        local txt = ""
        if attr.param3 and attr.param3 > 0 then
            local pv = Mathf.Round((attrdata.PFormat == 1 and attr.param3 / 100) or attr.param3)
            local s = string.gsub(attrdata.attDesc, '{P}', tostring(pv))
            txt = string.gsub(s, '{A}', string.format('<color=#00a0ffff>%s</color>', tostring(v)))
        else
            txt = string.gsub(attrdata.attDesc, '{A}', string.format('<color=#00a0ffff>%s</color>', tostring(v)))
        end
        if showType == 2 then
          txt = "[上限: ".. txt .. "]"
        end
        return string.format('<color=#ddac00ff>%s</color>', txt)
    end 
    return ""
end 

local function UpdateKaiGuangAtts(self,select_equip)
    if select_equip.detail.equip.uniqueAtts~= nil and #select_equip.detail.equip.uniqueAtts > 0 then 
        local attr = select_equip.detail.equip.uniqueAtts[1]
        self.tb_att_current.UnityRichText = GetComoboStrByAttrId(attr,1)
        self.btn_refine.Visible = true
        self.cvs_max1.Visible = true
        self.cvs_max1.UnityRichText = GetComoboStrByAttrId(attr,2)
    else
        self.tb_att_current.UnityRichText = Util.GetText(TextConfig.Type.ITEM, "notchuanqi")
        self.btn_refine.Visible = false
        self.cvs_max1.Visible = false
    end
    
    if select_equip.detail.equip.tempUniqueAtts~= nil and #select_equip.detail.equip.tempUniqueAtts > 0 then 
        self.cvs_main_single_kaiguang.Visible = true
        self.cvs_refine.Visible = false
        self.cvs_refine_save.Visible = true   

        local attr = select_equip.detail.equip.tempUniqueAtts[1]
        self.tb_att_kaiguang.UnityRichText = GetComoboStrByAttrId(attr,1)
        self.cvs_max2.Visible = true
        self.cvs_max2.UnityRichText = GetComoboStrByAttrId(attr,2)
    else
        self.cvs_main_single_kaiguang.Visible = false 
        self.cvs_refine.Visible = true
        self.cvs_refine_save.Visible = false
        self.cvs_max2.Visible = false
    end
end

local function SetRefineAttsNeedMat(self,matMap,node)
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

local function SetCostMoney(self, costNum)
    self.lb_gold_num.Text = costNum
    local mygold = ItemModel.GetGold()
    self.lb_gold_num.FontColorRGBA = (mygold >= costNum) and 0xffffffff or 0xff0000ff
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
        if self.nextCostNum then
            SetCostMoney(self, self.nextCostNum)
        end
    end
end

local function UpdateKaiGuangAttsMat(self,select_equip)
    local refineData = GlobalHooks.DB.Find("KaiGuang",select_equip.LevelReq)    
    self.lb_gold_num.Text = refineData.CostGold 
    local mygold = ItemModel.GetGold()
    self.lb_gold_num.FontColorRGBA = (mygold >= refineData.CostGold) and 0xffffffff or 0xff0000ff 
    self.nextCostNum = refineData.CostGold

    local matMap = {}
    if refineData.MateCount1 > 0 then
        table.insert(matMap,{refineData.MateCode1,refineData.MateCount1})
    end    
    if refineData.MateCount2 > 0 then
        table.insert(matMap,{refineData.MateCode2,refineData.MateCount2})
    end
    
    self.cvs_dep_single1.Visible = false
    self.cvs_dep_single2.Visible = false
    self.cvs_dep_single3.Visible = false
    
    local matMapUI = {}
    if #matMap == 1 then
        table.insert(matMapUI,self.cvs_dep_single1)
        self.cvs_dep_single1.X = 110
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
        
        SetRefineAttsNeedMat(self,matMap[i],matMapUI[i])
    end
    
end

local function UpdateKaiGuangIcon(self,select_equip)
    self.select_equip = select_equip

  local static_data = ItemModel.GetItemStaticDataByCode(select_equip.TemplateId)	
	local itshow = Util.ShowItemShow(self.ib_hpd_icon,select_equip.IconId,select_equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	 
    self.lb_detail_name.Text = static_data.Name
    self.lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  
    
    UpdateKaiGuangAtts(self,select_equip) 
    
    UpdateKaiGuangAttsMat(self,static_data) 

end

local function OnBuySuccess(self)
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)    
    UpdateKaiGuangAttsMat(self,static_data) 
end

local function SubConditionXmlText()
 local detailStr1 = Util.GetText(TextConfig.Type.ITEM, "chuanqiproperty1").."\n"
 local detailStr2 = Util.GetText(TextConfig.Type.ITEM, "chuanqiproperty2").."\n"
 local detailStr3 = Util.GetText(TextConfig.Type.ITEM, "chuanqiproperty3").."\n"
 local detailStr4 = Util.GetText(TextConfig.Type.ITEM, "chuanqiproperty4").."\n"
 return detailStr1..detailStr2..detailStr3..detailStr4
end

local function SendBI(self)

  local attr = self.select_equip.detail.equip.uniqueAtts[1]
  local strAttBefore = GetComoboStrByAttrId(attr,1)

  attr = self.select_equip.detail.equip.tempUniqueAtts[1]
  local strAttAfter = GetComoboStrByAttrId(attr,1)
  local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)  

  local strCost = ""
  local refineData = GlobalHooks.DB.Find("KaiGuang",static_data.LevelReq)   

  local static_data_mat = ItemModel.GetItemStaticDataByCode(refineData.MateCode1)  
  strCost = string.format("%s(%s):%d,",static_data_mat.Name,refineData.MateCode1,refineData.MateCount1)
  local static_data_mat = ItemModel.GetItemStaticDataByCode(refineData.MateCode2) 
  strCost = strCost .. string.format("%s(%s):%d",static_data_mat.Name,refineData.MateCode2,refineData.MateCount2)

  local counterStr ="KaiguangCultivate"
  local valueStr =""
  local kingdomStr = string.format("%s_%s(%s)",self.select_equip.Id,static_data.Name,self.select_equip.TemplateId)
  local phylumStr = Util.GetText(TextConfig.Type.ITEM, "kaiguangqian") ..strAttBefore
  local classfieldStr = Util.GetText(TextConfig.Type.ITEM, "kaiguanghou").. strAttAfter

  local familyStr = Util.GetText(TextConfig.Type.ITEM, "xiaohao") .. strCost
  local genusStr = Util.GetText(TextConfig.Type.ITEM, "kaiguang")
  Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)
end

local ui_names = 
{
	{name = 'cvs_center'}, 
	{name = 'ib_hpd_icon'}, 
	{name = 'lb_detail_name'}, 

	{name = 'cvs_main_single_kaiguang'}, 
    {name = 'tb_att_current'}, 
    {name = 'tb_att_kaiguang'}, 

	{name = 'cvs_refine'}, 
	{name = 'btn_refine',click = function (self)
        ItemModel.EquipRefineLegendRequest(self.select_equip.Id,function ()   
            
            UpdateKaiGuangIcon(self,self.select_equip)
            Util.showUIEffect(self.cvs_center,7)
             Util.showUIEffect(self.cvs_center,38)

             SendBI(self)
        end)      
	            end}, 
	
	{name = 'cvs_refine_save'}, 
	{name = 'btn_save',click = function (self)
        
        local attr = self.select_equip.detail.equip.uniqueAtts[1]
        local strAttBefore = GetComoboStrByAttrId(attr,1)

        attr = self.select_equip.detail.equip.tempUniqueAtts[1]
        local strAttAfter = GetComoboStrByAttrId(attr,1)
        local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)  

        ItemModel.SaveRefineLegendRequest(self.select_equip.Id,function ()   
            
            UpdateKaiGuangIcon(self,self.select_equip)

            
            local counterStr ="KaiguangCultivate"
            local valueStr =""
            local kingdomStr = string.format("%s_%s(%s)",self.select_equip.Id,static_data.Name,self.select_equip.TemplateId)
            local phylumStr = Util.GetText(TextConfig.Type.ITEM, "kaiguangqian") ..strAttBefore
            local classfieldStr = Util.GetText(TextConfig.Type.ITEM, "kaiguanghou").. strAttAfter

            local familyStr = Util.GetText(TextConfig.Type.ITEM, "wuxiaohao") 
            local genusStr = Util.GetText(TextConfig.Type.ITEM, "baocun")
            Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)

        end)
	        end}, 

	{name = 'btn_continue',click = function (self)
        ItemModel.EquipRefineLegendRequest(self.select_equip.Id,function ()   
            
            UpdateKaiGuangIcon(self,self.select_equip)
            Util.showUIEffect(self.cvs_center,7)
            Util.showUIEffect(self.cvs_center,38)

            SendBI(self)
        end)  
            end}, 
	
	
    {name = 'cvs_dep_single1'}, 
    {name = 'cvs_dep_single2'}, 
    {name = 'cvs_dep_single3'}, 
    
	  {name = 'lb_gold_num'}, 
    {name = 'ib_chuanqishuxing',click = function (self) 
      local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShowXmlTips, 1)
     obj.SetXmlSingleLineStr(SubConditionXmlText())
	            end
    },
    {name = 'cvs_max1'}, 
    {name = 'cvs_max2'},
}


local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_kaiguang.gui.xml",tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self) 
  

  DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
  self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)

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
  if rework_main.left_choose_part ~= nil and rework_main.left_choose_part.select_equip ~= nil then
    self.cvs_center.Visible = true
    UpdateKaiGuangIcon(self,rework_main.left_choose_part.select_equip)	
  else
	self.cvs_center.Visible = false
  end 
  

  GlobalHooks.Drama.Start("guide_refine", true)
end

_M.Create = Create
_M.ShowUI = ShowUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit = OnExit
return _M
