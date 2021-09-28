

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
local ReworkUtil = require "Zeus.UI.XMasterReWork.GameUIReworkUtil"

local currentScore = 0
local newScore = 0

function _M.Close(self)
    self.menu:Close()  
end

local function OnEnter(self)
    
end

local function OnExit(self)
    DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
end













local function GetAttrQualityByBaseAttr(self,attrs) 
    if not attrs or #attrs == 0 then
        return -1
    end
    local attr_num = #attrs 

    local attr_random_area = 0 
    local attr_grow_value = 0 
    local attr_grow_precent = 0 

    local attr_max_num = 0 
    local attr_grow_precent_num = 0 
    local attr_grow_precent_total = 0 

    
    for i = 1, #(attrs) do
        attr_random_area = attrs[i].maxValue - attrs[i].minValue
        attr_grow_value = attrs[i].value - attrs[i].minValue
        attr_grow_precent = attr_grow_value *100 / attr_random_area

        if attrs[i].value == attrs[i].maxValue then 
            attr_max_num = attr_max_num + 1
        end

        if attr_grow_precent >= 80 then 
            attr_grow_precent_num = attr_grow_precent_num + 1
        end
        attr_grow_precent_total = attr_grow_precent_total + attr_grow_precent 
    end

    
    local attr_grow_precent_avg = attr_grow_precent_total/attr_num 

    if attr_num == 3 and attr_max_num == 3 then 
        return 5
    elseif attr_grow_precent_num >= 3 then   
        return 4 
    elseif attr_grow_precent_num >= 1 and attr_grow_precent_avg >= 65 then   
        return 3     
    elseif attr_grow_precent_num >= 1 and attr_grow_precent_avg >= 50 then   
        return 2 
    elseif attr_grow_precent_num >= 1 then   
        return 1
    else
        return 0       
    end

end

local  function UpdateScurbingAttrQuality(self,select_equip)
    local score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.baseAtts)
    local color = ReworkUtil.GetAttrQualityByScore(score,maxScore)

    
    self.lb_quality_old.Text = score
    currentScore = score

    score,maxScore = ReworkUtil.GetAttrScoreByBaseAttr(select_equip.detail.equip.tempBaseAtts)
    color = ReworkUtil.GetAttrQualityByScore(score,maxScore)
    if color == -1 then 
        self.lb_quality_new.Text = ""  
    else 
        
        self.lb_quality_new.Text = score
    end
    newScore = score
end 

local function SetScurbingAttsOldAttr(self,attr,node,att)
    node.Visible = true    
    local gg_detail = node:FindChildByEditName('gg_detail_old',false)
    local ib_detail = node:FindChildByEditName('ib_detail_old',false)
    local lb_wenzi = node:FindChildByEditName('lb_wenzi',false)
    lb_wenzi.Text = attr
    gg_detail.Text = ""

    for _, attr in ipairs(self.select_equip.detail.equip.baseAtts or { }) do 
        if att.id == attr.id then
            gg_detail:SetGaugeMinMax(attr.minValue, attr.maxValue)
            gg_detail.Value = (attr.value < attr.maxValue and attr.value) or attr.maxValue

            if attr.value == attr.maxValue then
                lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text..Util.GetText(TextConfig.Type.ITEM, "man")
                gg_detail:SetGaugeMinMax(0, att.maxValue)
            else
                 if gg_detail.ValuePercent >= 70 then
                    lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text
                 end
            end

            
            if gg_detail.ValuePercent >= 70 then
                local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xba75f5ff)
                local layoutColor = gg_detail.Strip.UnityObject:GetComponent("UILayoutGraphics");
                layoutColor.color = color
            else
                local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xfee49cff)
                local layoutColor = gg_detail.Strip.UnityObject:GetComponent("UILayoutGraphics");
                layoutColor.color = color
            end

            break
        end 
    end
end

local function UpdateScurbingAttsOld(self,attrMap,attrinfo)
    
    local attrUI = {}
    self.cvs_old_single1.Visible = false    
    self.cvs_old_single2.Visible = false 
    self.cvs_old_single3.Visible = false 
    
    if #attrMap == 1 then
        table.insert(attrUI,self.cvs_old_single1)
        self.cvs_old_single1.Y = 0
    elseif #attrMap == 2 then
        table.insert(attrUI,self.cvs_old_single2) 
        self.cvs_old_single2.Y = 15   
        table.insert(attrUI,self.cvs_old_single3) 
        self.cvs_old_single3.Y = 57 
    elseif #attrMap == 3 then
        table.insert(attrUI,self.cvs_old_single2)   
        self.cvs_old_single2.Y = 0  
        table.insert(attrUI,self.cvs_old_single1) 
        self.cvs_old_single1.Y = 36  
        table.insert(attrUI,self.cvs_old_single3)
        self.cvs_old_single3.Y = 72 
    end    

    for i=1, #(attrMap) do
        SetScurbingAttsOldAttr(self,attrMap[i],attrUI[i],attrinfo[i])
    end
end

local function SetScurbingAttsNewAttr(self,attr,node,att)
    node.Visible = true    
    local gg_detail = node:FindChildByEditName('gg_detail_new',false)
    local ib_detail = node:FindChildByEditName('ib_detail_new',false)
    local lb_wenzi = node:FindChildByEditName('lb_wenzi',false)
    lb_wenzi.Text = attr
    gg_detail.Text = ""

    local ib_up = node:FindChildByEditName('ib_up',false)
    local ib_down = node:FindChildByEditName('ib_down',false)

    local bUp = nil
    for _, attr in ipairs(self.select_equip.detail.equip.baseAtts or { }) do 
        if att.id == attr.id then
            if att.value > attr.value then
                bUp = true
            elseif  att.value < attr.value then
                 bUp = false  
            end
            gg_detail:SetGaugeMinMax(att.minValue, att.maxValue)
            gg_detail.Value = (att.value < att.maxValue and att.value) or att.maxValue
            
            if att.value == att.maxValue then
                lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text..Util.GetText(TextConfig.Type.ITEM, "man")
                gg_detail:SetGaugeMinMax(0, att.maxValue)
            else
                if gg_detail.ValuePercent >= 70 then
                    lb_wenzi.Text = Util.GetText(TextConfig.Type.ITEM, "gao")..lb_wenzi.Text
                end    
            end

            
            if gg_detail.ValuePercent >= 70 then
                local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xba75f5ff)
                local layoutColor = gg_detail.Strip.UnityObject:GetComponent("UILayoutGraphics");
                layoutColor.color = color
            else
                local color = CommonUnity3D.UGUI.UIUtils.UInt32_RGBA_To_Color(0xfee49cff)
                local layoutColor = gg_detail.Strip.UnityObject:GetComponent("UILayoutGraphics");
                layoutColor.color = color
            end
            break
        end 
    end 
    
    ib_up.Visible = (bUp ~= nil) and (bUp == true)
    ib_down.Visible = (bUp ~= nil) and (bUp == false)
end

local function UpdateScurbingAttsNew(self,attrMap,attrInfos) 
    
    local attrUI = {}
    self.cvs_new_single1.Visible = false    
    self.cvs_new_single2.Visible = false 
    self.cvs_new_single3.Visible = false 
    
    if #attrMap == 1 then
        table.insert(attrUI,self.cvs_new_single1)
        self.cvs_new_single1.Y = 0
    elseif #attrMap == 2 then
        table.insert(attrUI,self.cvs_new_single2) 
        self.cvs_new_single2.Y = 15   
        table.insert(attrUI,self.cvs_new_single3) 
        self.cvs_new_single3.Y = 57 
    elseif #attrMap == 3 then
        table.insert(attrUI,self.cvs_new_single2)   
        self.cvs_new_single2.Y = 0  
        table.insert(attrUI,self.cvs_new_single1) 
        self.cvs_new_single1.Y = 36  
        table.insert(attrUI,self.cvs_new_single3)
        self.cvs_new_single3.Y = 72 
    end    

    for i=1, #(attrMap) do
        SetScurbingAttsNewAttr(self,attrMap[i],attrUI[i],attrInfos[i])
    end
end

local function SetScurbingAttsNeedMat(self,matMap,node)
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
  self.lb_gold_number.Text = costNum
  local mygold = ItemModel.GetGold()
  self.lb_gold_number.FontColorRGBA = (mygold >= costNum) and 0xffffffff or 0xff0000ff
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
        if self.nextCostNum then
            SetCostMoney(self, self.nextCostNum)
        end
    end
end
local function UpdateScurbingAttsMat(self,select_equip)
    local rebornData = GlobalHooks.DB.Find("ReBorn",select_equip.LevelReq)    
    self.lb_gold_number.Text = rebornData.CostGold 
    local mygold = ItemModel.GetGold()
    self.lb_gold_number.FontColorRGBA = (mygold >= rebornData.CostGold) and 0xffffffff or 0xff0000ff 
    self.nextCostNum = rebornData.CostGold
    local matMap = {}
    if rebornData.MateCount1 > 0 then
        table.insert(matMap,{rebornData.MateCode1,rebornData.MateCount1})
    end    
    if rebornData.MateCount2 > 0 then
        table.insert(matMap,{rebornData.MateCode2,rebornData.MateCount2})
    end
    
    self.cvs_dep_single1.Visible = false
    self.cvs_dep_single2.Visible = false
    self.cvs_dep_single3.Visible = false
    
    local matMapUI = {}
    if #matMap == 1 then
        table.insert(matMapUI,self.cvs_dep_single1)
        self.cvs_dep_single1.X = 101
    elseif #matMap == 2 then
        table.insert(matMapUI,self.cvs_dep_single2)  
        self.cvs_dep_single2.X = 72  
        table.insert(matMapUI,self.cvs_dep_single3) 
        self.cvs_dep_single3.X = 175 
    elseif #matMap == 3 then
        table.insert(matMapUI,self.cvs_dep_single2) 
        self.cvs_dep_single2.X = 10 
        table.insert(matMapUI,self.cvs_dep_single1) 
        self.cvs_dep_single1.X = 101 
        table.insert(matMapUI,self.cvs_dep_single3)
        self.cvs_dep_single3.X = 192 
    end     
    for i=1, #(matMap) do
        
        SetScurbingAttsNeedMat(self,matMap[i],matMapUI[i])
    end
    
end

local function UpdateScurbingIcon(self,select_equip)
    self.select_equip = select_equip
    local static_data = ItemModel.GetItemStaticDataByCode(select_equip.TemplateId)	
	local itshow = Util.ShowItemShow(self.ib_hpd_icon,select_equip.IconId,select_equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	 
    self.lb_detail_name.Text = static_data.Name
    self.lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)    
    
    
    local attrMap = {}
    local attrinfo = {}

    local baseAtts = select_equip.detail.equip.baseAtts or { }
    table.sort(baseAtts, function(a,b)
        
        return a.id < b.id
    end) 
    for _, attr in ipairs(baseAtts) do
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)

        if attrdata ~= nil  then
            local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
            local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
            table.insert(attrMap,str)  
            table.insert(attrinfo,attr)
         end  
    end
       
    UpdateScurbingAttsOld(self,attrMap,attrinfo) 
    
     
    attrMap = {}
    attrinfo = {}
    baseAtts = select_equip.detail.equip.tempBaseAtts or { }
     table.sort(baseAtts, function(a,b)
        
        return a.id < b.id
    end) 
    
    for _, attr in ipairs(baseAtts) do
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)

        if attrdata ~= nil  then
            local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
            local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
            table.insert(attrMap,str)  
            table.insert(attrinfo,attr)
         end  
    end
       
    UpdateScurbingAttsNew(self,attrMap,attrinfo) 

    UpdateScurbingAttsMat(self,static_data) 
    
    
    self.cvs_Scurbing.Visible = (select_equip.detail.equip.tempBaseAtts == nil or #select_equip.detail.equip.tempBaseAtts == 0)
    self.cvs_Scurbing_save.Visible = (select_equip.detail.equip.tempBaseAtts ~= nil and #select_equip.detail.equip.tempBaseAtts > 0)    
    self.cvs_detail_start.Visible = self.cvs_Scurbing.Visible     
    self.cvs_detail_new.Visible = self.cvs_Scurbing_save.Visible  
    
    
    UpdateScurbingAttrQuality(self,select_equip)
end

local function OnBuySuccess(self)
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)    
    UpdateScurbingAttsMat(self,static_data) 
end

local function SendBI(self)
  local strAttBefore = ""
  local strAttAfter = ""
  local baseAtts = self.select_equip.detail.equip.baseAtts or { }
  for _, attr in ipairs(baseAtts) do
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
        local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
        strAttBefore = strAttBefore..str..";"
     end  
  end

  baseAtts = self.select_equip.detail.equip.tempBaseAtts or { }
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
  local ReBornData = GlobalHooks.DB.Find("ReBorn",static_data.LevelReq)   

  local static_data_mat = ItemModel.GetItemStaticDataByCode(ReBornData.MateCode1)  
  strCost = string.format("%s(%s):%d,",static_data_mat.Name,ReBornData.MateCode1,ReBornData.MateCount1)
  local static_data_mat = ItemModel.GetItemStaticDataByCode(ReBornData.MateCode2) 
  strCost = strCost .. string.format("%s(%s):%d",static_data_mat.Name,ReBornData.MateCode2,ReBornData.MateCount2)

  local counterStr ="ScurbingCultivate"
  local valueStr =""
  local kingdomStr = string.format("%s_%s(%s)",self.select_equip.Id,static_data.Name,self.select_equip.TemplateId)
  local phylumStr =Util.GetText(TextConfig.Type.GUILD, "xilianqian") ..strAttBefore
  local classfieldStr = Util.GetText(TextConfig.Type.GUILD, "xilianhou").. strAttAfter

  local familyStr = Util.GetText(TextConfig.Type.ITEM, "xiaohao") .. strCost
  local genusStr =Util.GetText(TextConfig.Type.ITEM, "xilian")
  Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)
end

local ui_names = 
{
	{name = 'cvs_center'}, 
	{name = 'ib_hpd_icon'}, 
	{name = 'lb_detail_name'}, 
	{name = 'lb_quality_old'}, 
	{name = 'lb_quality_new'}, 

    {name = 'cvs_detail_old'}, 
    {name = 'cvs_detail_new'}, 
    {name = 'cvs_detail_start'}, 
    
    {name = 'cvs_old_single1'}, 
    {name = 'cvs_old_single2'}, 
    {name = 'cvs_old_single3'}, 
    
    {name = 'cvs_new_single1'}, 
    {name = 'cvs_new_single2'}, 
    {name = 'cvs_new_single3'}, 
    
	{name = 'cvs_Scurbing'}, 
	{name = 'btn_Scurbing',click = function (self)

        		
                ItemModel.EquipRebornRequest(self.select_equip.Id,function ()   
                    
                    print("select_equip.Id :".. self.select_equip.Id)
                    UpdateScurbingIcon(self,self.select_equip)
                    for i=1,3,1 do
                        local node1=self["cvs_new_single"..i]
                        local node2 =node1:FindChildByEditName("ib_detail_new",false)
                        Util.showUIEffect(node2,18)
                        
                    end
                    Util.showUIEffect(self.cvs_center,7)
                    Util.showUIEffect(self.cvs_center,35)

                    
                    SendBI(self)
                end)
	            end}, 
	
	{name = 'cvs_Scurbing_save'}, 
	{name = 'btn_save',click = function (self)
                
                  local strAttBefore = ""
                  local strAttAfter = ""
                  local baseAtts = self.select_equip.detail.equip.baseAtts or { }
                  for _, attr in ipairs(baseAtts) do
                    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
                    if attrdata ~= nil  then
                        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                        local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                        strAttBefore = strAttBefore..str..";"
                     end  
                  end

                  baseAtts = self.select_equip.detail.equip.tempBaseAtts or { }
                  for _, attr in ipairs(baseAtts) do
                    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
                    if attrdata ~= nil  then
                        local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                        local str = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                        strAttAfter = strAttAfter..str..";"
                     end  
                  end

                  local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId) 

		        
                ItemModel.SaveRebornRequest(self.select_equip.Id,function ()   
                    
                    UpdateScurbingIcon(self,self.select_equip)

                      local counterStr ="ScurbingCultivate"
                      local valueStr =""
                      local kingdomStr = string.format("%s_%s(%s)",self.select_equip.Id,static_data.Name,self.select_equip.TemplateId)
                      local phylumStr =Util.GetText(TextConfig.Type.GUILD, "xilianqian") ..strAttBefore
                      local classfieldStr = Util.GetText(TextConfig.Type.GUILD, "xilianhou").. strAttAfter

                      local familyStr = Util.GetText(TextConfig.Type.GUILD, "wuxiaohao") 
                      local genusStr =Util.GetText(TextConfig.Type.ITEM, "baocun") 
                      Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)

                end)
	            end}, 
	{name = 'bt_continue',click = function (self)
        local OkFun = function() 
                
                ItemModel.EquipRebornRequest(self.select_equip.Id,function ()   
                    
                    UpdateScurbingIcon(self,self.select_equip)
                    for i=1,3,1 do
                        local node1=self["cvs_new_single"..i]
                        local node2 =node1:FindChildByEditName("ib_detail_new",false)
                        Util.showUIEffect(node2,18)

                    end
                    Util.showUIEffect(self.cvs_center,7)
                    Util.showUIEffect(self.cvs_center,35)

                    
                    SendBI(self)
                end)
        end

        if newScore > currentScore then
            local xiliantips = Util.GetText(TextConfig.Type.GUILD, "xiliantips")
            local goonxilian = Util.GetText(TextConfig.Type.GUILD, "goonxilian")
            local fanhui = Util.GetText(TextConfig.Type.ITEM, "fanhui")
            local notice = Util.GetText(TextConfig.Type.ITEM, "notice")
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL, 
                xiliantips,
                goonxilian,
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
}

local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_scurbbing.gui.xml",tag)
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
	UpdateScurbingIcon(self,rework_main.left_choose_part.select_equip)	
    
  else
	self.cvs_center.Visible = false
  end 
  
  GlobalHooks.Drama.Start("guide_scurbing", true)
end

_M.Create = Create
_M.ShowUI = ShowUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit = OnExit
return _M
