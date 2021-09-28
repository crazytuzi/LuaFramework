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

local function GetProgressByAttrId(attr)
    if not attr then 
        return 0
    end
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
    if attrdata ~= nil  then
        return math.abs(attr.value*100 / attr.maxValue)
    end 
    return 0
end 

local function UpDateHaveRefineAtts(self,node,select_equip)
    local gg_main_single = node:FindChildByEditName('gg_main_single',false)
    local tbt_main_single = node:FindChildByEditName('tbt_main_single',false)
    local cvs_main_unusual = node:FindChildByEditName('cvs_main_unusual',false)
    local btn_refine_lock = node:FindChildByEditName('btn_refine_lock',false)
    cvs_main_unusual.Visible = false

    for _, attr in ipairs(select_equip.detail.equip.randomAtts or { }) do
        if select_equip.detail.equip.refineAttrId == attr.id then
            gg_main_single.Text = GetComoboStrByAttrId(attr)
            gg_main_single.Value = GetProgressByAttrId(attr)
            OnChooseSelectAttrItem(self,attr)
            self.select_attr = attr
            break
        end
    end   

    OnUpdateRefineAttrItem(self) 
end

function OnChooseSelectAttrItem( self,attr)
    if not attr then
        self.cvs_strat_left.Visible = false
        return
    end
    self.cvs_strat_left.Visible = true
    self.btn_refine.Visible = true

    local gg_strat_left = self.cvs_strat_left:FindChildByEditName('gg_strat_left',false)
    gg_strat_left.Text = GetComoboStrByAttrId(attr)
    gg_strat_left.Value = GetProgressByAttrId(attr)
end

function OnUpdateRefineAttrItem(self)
    if not self.select_equip.detail.equip.tempRefineAttr or self.select_equip.detail.equip.tempRefineAttr.id == 0 then
        self.cvs_strat_right.Visible = false
        return
    end
    self.cvs_strat_right.Visible = true

    local gg_strat_right = self.cvs_strat_right:FindChildByEditName('gg_strat_right',false)
    local attr = self.select_equip.detail.equip.tempRefineAttr
    gg_strat_right.Text = GetComoboStrByAttrId(attr)
    gg_strat_right.Value = GetProgressByAttrId(attr)
    
end

function OnSelectAttr(self,attr)
  if not attr then return end
    if self.select_attr then
        local item_node = FindtAttrListItem(self,self.select_attr.id)
        if item_node then
            local tbt_main = item_node:FindChildByEditName('tbt_main_single',false)
            tbt_main.IsChecked = false
        end
    end  
    self.select_attr = attr  
    
    OnChooseSelectAttrItem(self,attr)
end

 function FindtAttrListItem(self,attr_id)
    local child_list = self.sp_main_in.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        
        if v.Name == tostring(attr_id) then
            return v
        end
    end
    return nil
end

local function SetSPAttItem(self,node,attr)
    if attr == nil then
        node.Visible = false    
        return
    end
    local gg_main_single = node:FindChildByEditName('gg_main_single',false)
    local tbt_main_single = node:FindChildByEditName('tbt_main_single',false)
    local cvs_main_unusual = node:FindChildByEditName('cvs_main_unusual',false)
    local btn_refine_lock = node:FindChildByEditName('btn_refine_lock',false)
    btn_refine_lock.Visible = false
    cvs_main_unusual.Visible = false

    gg_main_single.Text = GetComoboStrByAttrId(attr)   
    gg_main_single.Value = GetProgressByAttrId(attr)

    tbt_main_single:SetBtnLockState(HZToggleButton.LockState.eLockSelect)  
    tbt_main_single.IsChecked = (self.select_attr ~= nil and self.select_attr.id == attr.id)
    tbt_main_single.TouchClick = function (sender)
        if sender.IsChecked then
            OnSelectAttr(self,attr)
        end
    end
    node.Name = attr.id 
end

local function UpDateNoRefineAtts(self,select_equip)
    local attrMap = {}
    for _, attr in ipairs(select_equip.detail.equip.randomAtts or { }) do
        if attr.value ~= nil then
            table.insert(attrMap,attr)      
        end        
    end    

    local item_counts = #attrMap
    self.sp_main_in.Scrollable:ClearGrid()

    if self.sp_main_in.Rows <= 0 then
        self.sp_main_in.Visible = true
        local cs = self.cvs_main_single.Size2D
        self.sp_main_in:Initialize(cs.x,cs.y,item_counts%2 == 0 and item_counts/2 or item_counts/2 +1,2,self.cvs_main_single,
        function (gx,gy,node)
            SetSPAttItem(self,node,attrMap[gy*2 + gx+1])
        end,function () end)
    else
        self.sp_main_in.Rows = item_counts
    end  
end

local function UpdateRefineAtts(self,select_equip)
    if select_equip.detail.equip.refineAttrId~= nil and select_equip.detail.equip.refineAttrId > 0 then 
        self.sp_main_in.Visible = false
        self.cvs_main_single_have_refine.Visible = true
        UpDateHaveRefineAtts(self,self.cvs_main_single_have_refine,select_equip)
    else
        self.sp_main_in.Visible = true
        self.cvs_main_single_have_refine.Visible = false 
        UpDateNoRefineAtts(self,select_equip)
    end
    
    
    if select_equip.detail.equip.tempRefineAttr ~= nil and select_equip.detail.equip.tempRefineAttr.id > 0 then 
        self.cvs_refine.Visible = false
        self.cvs_refine_save.Visible = true    
    else
        self.cvs_refine.Visible = true
        self.cvs_refine_save.Visible = false    
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

local function UpdateRefineAttsMat(self,select_equip)
    local refineData = GlobalHooks.DB.Find("Refine",select_equip.LevelReq)    
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
        self.cvs_dep_single2.X = 54 
        table.insert(matMapUI,self.cvs_dep_single3) 
        self.cvs_dep_single3.X = 151
    elseif #matMap == 3 then
        table.insert(matMapUI,self.cvs_dep_single2)  
        self.cvs_dep_single2.X = 42 
        table.insert(matMapUI,self.cvs_dep_single1)
        self.cvs_dep_single1.X = 110 
        table.insert(matMapUI,self.cvs_dep_single3)
        self.cvs_dep_single3.X = 179
    end     
    for i=1, #(matMap) do
        
        SetRefineAttsNeedMat(self,matMap[i],matMapUI[i])
    end
    
end

local function UpdateRefineIcon(self,select_equip)
    self.select_equip = select_equip

    self.cvs_strat_left.Visible = false
    self.cvs_strat_right.Visible = false
    self.btn_refine.Visible = false

    local static_data = ItemModel.GetItemStaticDataByCode(select_equip.TemplateId)	
	local itshow = Util.ShowItemShow(self.ib_hpd_icon,select_equip.IconId,select_equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	 
    self.lb_detail_name.Text = static_data.Name
    self.lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  
    
    UpdateRefineAtts(self,select_equip) 
    
    UpdateRefineAttsMat(self,static_data) 

end

local function UpdateRefineReplaceAttr(self,extAtts)
    
    local strCombo = ""
    local strFormat = "(%d-%d)"
    local attr =  nil
    for i = 1,#(extAtts) do
       
        attr =  extAtts[i]
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
        if attrdata ~= nil  then
            strCombo = strCombo .. string.gsub(attrdata.attDesc,'{A}',string.format(strFormat,attr.minValue,attr.maxValue))..'\n'
        end 
    end
    self.tb_give_explain.Text = strCombo
end

local function OnBuySuccess(self)
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_equip.TemplateId)    
    UpdateRefineAttsMat(self,static_data) 
end

local ui_names = 
{
	{name = 'cvs_center'}, 
	{name = 'ib_hpd_icon'}, 
	{name = 'lb_detail_name'}, 

	{name = 'cvs_main_single_have_refine'}, 

    {name = 'sp_main_in'}, 
    {name = 'cvs_main_single'}, 
    
    {name = 'cvs_closet_explain'}, 
    {name = 'btn_refine_lock',click = function (self)
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM, "chongzhutips"))            
        end}, 
    
    {name = 'cvs_strat_left'}, 
    {name = 'gg_strat_left'}, 
    {name = 'cvs_strat_right'}, 
    {name = 'gg_strat_right'}, 
    
    {name = 'cvs_give_explain'}, 
    {name = 'tb_give_explain'}, 
    {name = 'lb_give_explain'}, 
    {name = 'btn_give_explain',click = function (self)
        		
                self.cvs_give_explain.Visible = false        
	            end}, 
    
    {name = 'btn_give_examine',click = function (self)
        		
        ItemModel.GetRefineExtPropRequest(self.select_equip.Id,function (extAtts)   
            UpdateRefineReplaceAttr(self,extAtts)
            self.cvs_give_explain.Visible = true 
        end)                
	            end},    
    
	{name = 'cvs_refine'}, 
	{name = 'btn_refine',click = function (self)
        if self.select_attr then
            local attrdata = GlobalHooks.DB.Find('Attribute', self.select_attr .id)
            ItemModel.EquipRefineRequest(self.select_equip.Id,attrdata.attKey,function ()   
                
                UpdateRefineIcon(self,self.select_equip)
                Util.showUIEffect(self.cvs_main_single,36)
            end)  
        end        
	            end}, 
	
	{name = 'cvs_refine_save'}, 
	{name = 'btn_save',click = function (self)
		if self.select_attr then
            local attrdata = GlobalHooks.DB.Find('Attribute', self.select_attr .id)
            ItemModel.SaveRefineRequest(self.select_equip.Id,attrdata.attKey,function ()   
                
                UpdateRefineIcon(self,self.select_equip)
            end)  
        end
	            end}, 

	{name = 'btn_continue',click = function (self)
		 if self.select_attr then
            local attrdata = GlobalHooks.DB.Find('Attribute', self.select_attr .id)
            ItemModel.EquipRefineRequest(self.select_equip.Id,attrdata.attKey,function ()   
                
                UpdateRefineIcon(self,self.select_equip)
                Util.showUIEffect(self.cvs_main_single,36)
            end)  
        end 
	            end}, 
	
	
    {name = 'cvs_dep_single1'}, 
    {name = 'cvs_dep_single2'}, 
    {name = 'cvs_dep_single3'}, 
    
	{name = 'btn_refine_lock'}, 
	{name = 'btn_refine_help'}, 
	{name = 'lb_gold_num'}, 
}


local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_refine.gui.xml",tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self) 
  Util.showUIEffect(self.ib_hpd_icon,17)

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
    self.cvs_give_explain.Visible = false  
    self.select_attr = nil 
    UpdateRefineIcon(self,rework_main.left_choose_part.select_equip)	
  else
	self.cvs_center.Visible = false
  end 
   self.cvs_main_single.Visible = false 
   Util.showUIEffect(self.ib_hpd_icon,17)
end

_M.Create = Create
_M.ShowUI = ShowUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit =OnExit
return _M
