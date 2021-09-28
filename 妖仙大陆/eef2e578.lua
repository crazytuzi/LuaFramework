local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local EventDetail = require 'Zeus.UI.EventItemDetail'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
local DisplayUtil = require "Zeus.Logic.DisplayUtil"

local self = {
    menu = nil,
}

function _M.Close(self)
  self.menu:Close()  
end

local function OnExit(self)
  	  DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
end

local select_pro = nil 
local select_make_index = nil 
local select_make_item = nil 
local make_index_script = {} 
local equip_make_script = {} 

local function CanMakeNum(self,make_item)
    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = nil
    
    local mateCanMake = 0

    if make_item.ReqMateCount1 > 0 then
        vItem = bag_data:MergerTemplateItem(make_item.ReqMateCode1)
        mateCanMake = vItem == nil and 0 or math.floor(vItem.Num/make_item.ReqMateCount1)
    end    
    if make_item.ReqMateCount2 > 0 then
        vItem = bag_data:MergerTemplateItem(make_item.ReqMateCode2)
        local mateCanMake2 = vItem == nil and 0 or math.floor(vItem.Num/make_item.ReqMateCount2)
        mateCanMake = (mateCanMake < mateCanMake2) and mateCanMake or mateCanMake2
    end
    if make_item.ReqMateCount3 > 0 then
        vItem = bag_data:MergerTemplateItem(make_item.ReqMateCode3)
        local mateCanMake3 = vItem == nil and 0 or math.floor(vItem.Num/make_item.ReqMateCount3)
        mateCanMake = (mateCanMake < mateCanMake3) and mateCanMake or mateCanMake3
    end

    return mateCanMake
end

local function GetEquipMakeScriptByProAndLevel(pro,lv)
    local getMap = {}
    local proName = GlobalHooks.DB.Find('Character',pro).ProName
    for _,v in ipairs(equip_make_script) do
        if v.Pro == proName and v.EquipLevel == lv then
            table.insert(getMap,v)
        end
    end    
    return getMap
end

local function IsEquipOnBody(code)
    local bag_data = DataMgr.Instance.UserData.RoleEquipBag
	local vItem = bag_data:GetTemplateItem(code)
    return (vItem ~= nil)     
end

local function InitSpRank(self)    
    self.cvs_rank_detail.Visible = false  
    self.sp_rank.Scrollable:ClearGrid() 
    
    local item_counts = #make_index_script    
    if self.sp_rank.Rows <= 0 then
		self.sp_rank.Visible = true
		local cs = self.cvs_rank_detail.Size2D
		self.sp_rank:Initialize(cs.x,cs.y,item_counts,1,self.cvs_rank_detail,
		function (gx,gy,node)
			local make_index = make_index_script[gy + 1]
            local btn_rank = node:FindChildByEditName('btn_rank',false)
             btn_rank.TouchClick = function (sender)
                OnRankSelect(self,make_index)
	        end
            btn_rank.Text = make_index.EquipLable
            node.Name = make_index.EquipLable
		end,function ()	end)
	else
		self.sp_rank.Rows = item_counts
	end	
      
    
end

local function UpdateMakeIcon(self)  
    if self.select_pro == nil then
       self.select_pro = DataMgr.Instance.UserData.Pro 
       self.cvs_typename.Visible = false 
    end
    
    if self.select_make_index == nil then 
        local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) 
        for i = 1,#(make_index_script) do
            if  make_index_script[i].LevelIndex <= lv then
                self.select_make_index = make_index_script[i]
                break
            end
        end
        
        if self.select_make_index == nil then 
            self.select_make_index = make_index_script[#make_index_script]
        end    
           
        InitSpRank(self)    
        
       self.sp_rank.Visible = false 
    
       self.cvs_set_list.Visible = false 
    end    
            
    
    OnUpdate(self)
end

local function UpdateScriptData(self)
    make_index_script = GlobalHooks.DB.Find('EquipMakeIndex', {})
    table.sort( make_index_script, function(a,b)
        return a.LevelIndex > b.LevelIndex
    end )
    
    equip_make_script = GlobalHooks.DB.Find('EquipMake', {})
end


local function UpdateSpType(self)       
    self.sp_type.Visible = true 
    self.cvs_detail.Visible = false
    
    local selectMakeSpPos2D = self.sp_type.Scrollable:GetScrollPos()
    self.sp_type.Scrollable:ClearGrid() 
    local make_item_map = GetEquipMakeScriptByProAndLevel(self.select_pro,self.select_make_index.LevelIndex)    
    local item_counts = #make_item_map    
    if self.sp_type.Rows <= 0 then
		self.sp_type.Visible = true
		local cs = self.cvs_detail.Size2D
		self.sp_type:Initialize(cs.x,cs.y,item_counts,1,self.cvs_detail,
		function (gx,gy,node)
			local make_item = make_item_map[gy + 1]
            SetEquipItem(self,node,make_item,gy + 1)                
		end,function ()	end)
	else
		self.sp_type.Rows = item_counts
	end	
    
    if selectMakeSpPos2D ~= nil then
        self.sp_type.Scrollable:LookAt(-selectMakeSpPos2D)
    end
end

local function SetNeedMat(self,matMap,node)
    node.Visible = true    
    local cvs_dep_need = node:FindChildByEditName('cvs_dep_need',false)
    
    local tb_dep_name = node:FindChildByEditName('tb_dep_name',false)
    local ib_dep_goicon = node:FindChildByEditName('ib_dep_goicon',false)
    
    local matName = matMap[1]    
    local matCount = matMap[2]      
    
    local bag_data = DataMgr.Instance.UserData.RoleBag
	local vItem = bag_data:MergerTemplateItem(matName)    
    
    local static_data = ItemModel.GetItemStaticDataByCode(matName)  
    if not static_data then
        
    end
    local item = Util.ShowItemShow(cvs_dep_need, static_data.Icon, static_data.Qcolor, 1)
    
	local x = (vItem and vItem.Num) or 0
	local cost = matCount
    local isLessItem    
        
	if x < cost then
		isLessItem = true
		tb_dep_name.XmlText = string.format("<b> <f size='22' color='ffff0000'>%d</f>/%d</b>",x,cost)
	else
		isLessItem = false
		tb_dep_name.XmlText = string.format("<b> <f size='22' color='ff00ff00'>%d</f>/%d</b>",x,cost)
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

local function UpdateMat(self)  
    local make_item = self.select_make_item    
    self.lb_gold_number.Text = make_item.CostMoney 
    local mygold = ItemModel.GetGold()
    self.lb_gold_number.FontColorRGBA = (mygold >= make_item.CostMoney) and 0xffffffff or 0xff0000ff 
    self.nextNeedNum = make_item.CostMoney
    local matMap = {}
    if make_item.ReqMateCount1 > 0 then
        table.insert(matMap,{make_item.ReqMateCode1,make_item.ReqMateCount1})
    end    
    if make_item.ReqMateCount2 > 0 then
        table.insert(matMap,{make_item.ReqMateCode2,make_item.ReqMateCount2})
    end
    if make_item.ReqMateCount3 > 0 then
        table.insert(matMap,{make_item.ReqMateCode3,make_item.ReqMateCount3})
    end
    
    self.cvs_dep_single1.Visible = false
    self.cvs_dep_single2.Visible = false
    self.cvs_dep_single3.Visible = false
    
    local matMapUI = {}
    if #matMap == 1 then
        table.insert(matMapUI,self.cvs_dep_single1)
        self.cvs_dep_single1.X = 103
    elseif #matMap == 2 then
        table.insert(matMapUI,self.cvs_dep_single2)  
        self.cvs_dep_single2.X = 72  
        table.insert(matMapUI,self.cvs_dep_single3) 
        self.cvs_dep_single3.X = 175 
    elseif #matMap == 3 then
        table.insert(matMapUI,self.cvs_dep_single2) 
        self.cvs_dep_single2.X = 20
        table.insert(matMapUI,self.cvs_dep_single1) 
        self.cvs_dep_single1.X = 130 
        table.insert(matMapUI,self.cvs_dep_single3)
        self.cvs_dep_single3.X = 240 
    end     
    for i=1, #(matMap) do
        
        SetNeedMat(self,matMap[i],matMapUI[i])
    end    
    
end

local function SetBaseAtts(self,attMap,node)
    node.Visible = true    
    local lb_bp_name = node:FindChildByEditName('lb_bp_name',false)
    local lb_bp_num = node:FindChildByEditName('lb_bp_num',false)
    lb_bp_name.Text = attMap[1]  
    lb_bp_num.Text = string.format("%s-%s",attMap[3],attMap[4])   
end

local function UpdateAtts(self,static_data)    
    local attMap = {}    
    if static_data.Prop1 ~= nil then
        table.insert(attMap,{static_data.Prop1,static_data.Par1,static_data.Min1,static_data.Max1})
    end
    if static_data.Prop2 ~= nil then
        table.insert(attMap,{static_data.Prop2,static_data.Par2,static_data.Min2,static_data.Max2})
    end
    if static_data.Prop3 ~= nil then
        table.insert(attMap,{static_data.Prop3,static_data.Par3,static_data.Min3,static_data.Max3})
    end
    
    self.cvs_build_property1.Visible = false
    self.cvs_build_property2.Visible = false
    self.cvs_build_property3.Visible = false
    
    local attMapUI = {}
    if #attMap == 1 then
        table.insert(attMapUI,self.cvs_build_property1)
        self.cvs_build_property1.Y = 29
    elseif #attMap == 2 then
        table.insert(attMapUI,self.cvs_build_property2)  
        self.cvs_build_property2.Y = 14  
        table.insert(attMapUI,self.cvs_build_property3) 
        self.cvs_build_property3.Y = 50 
    elseif #attMap == 3 then
        table.insert(attMapUI,self.cvs_build_property2) 
        self.cvs_build_property2.Y = 3 
        table.insert(attMapUI,self.cvs_build_property1) 
        self.cvs_build_property1.Y = 29 
        table.insert(attMapUI,self.cvs_build_property3)
        self.cvs_build_property3.Y = 55 
    end     
    for i=1, #(attMapUI) do
        
        SetBaseAtts(self,attMap[i],attMapUI[i])
    end 
    
    
    local randomMap = stringToTable(static_data.AffixCount)
    if randomMap[1] ~= randomMap[2] then
        self.lb_random_property.Text = Util.GetText(TextConfig.Type.ITEM, "randomproperty",randomMap[1],randomMap[2])  
    else
        self.lb_random_property.Text = Util.GetText(TextConfig.Type.ITEM, "randomproperty1",randomMap[1]) 
    end
end

local function UpdateSuitDetail(self,static_data,suit_data,suit_list)
    if suit_data == nil then
        self.cvs_set_list.Visible = false
        return    
    end  
    
    self.lb_suit_list_name.Text = suit_data.SuitName
    local have_equip_num = 0    
     for i = 1,7 do
        local lb_suit_part = self["lb_suit_part"..i]    
        if i > #suit_list then 
            lb_suit_part.Visible = false 
        else
            lb_suit_part.Visible = true
            local suit_other_part_item = ItemModel.GetItemStaticDataByCode(suit_list[i])
            lb_suit_part.Text = "."..suit_other_part_item.Name
            if IsEquipOnBody(suit_other_part_item.Code) then
                lb_suit_part.FontColorRGBA = 0x00f012ff
                have_equip_num = have_equip_num +1
            elseif suit_other_part_item.Code == static_data.Code then     
                lb_suit_part.FontColorRGBA = 0xddf2ffff
            else
                lb_suit_part.FontColorRGBA = 0x9aa9b5ff
            end     
        end        
     end
     self.tb_set_num.Text = string.format("(%d/%d)",have_equip_num,suit_data.PartCount)  
    
    local suit_atts = "<b>"
    local suit_config_table = GlobalHooks.DB.Find('SuitConfig',{SuitID = static_data.SuitID})
    local suit_atts_map = {}
    for i = 1,#(suit_config_table) do
        
        if suit_atts_map[suit_config_table[i].PartReqCount] == nil then 
            suit_atts_map[suit_config_table[i].PartReqCount] = {suit_config_table[i]}  
        else
            table.insert(suit_atts_map[suit_config_table[i].PartReqCount],suit_config_table[i])     
        end        
    end    
    
    local bFrist = true  
    for k,v in pairs(suit_atts_map) do
        local color = 'ff9aa9b5' 
        local attr = ""
        if have_equip_num >= k then
            color = 'ff00f012'
        end
       for i = 1,#(v) do
            local attrdata = nil
            local attrTemps = GlobalHooks.DB.Find('Attribute', {})
            for _,vv in pairs(attrTemps) do
                if v[i].Prop == vv.attName then
                    attrdata = vv
                    break
                end
            end

            local value = v[i].Min
            if attrdata.isFormat == 1 then
                value = value / 100
                local s = string.gsub(attrdata.attDesc,'{A}',string.format("%.2f",value))
                attr = attr .. string.format("\t%s",s) 
            else
                value = Mathf.Round(value)
                local s = string.gsub(attrdata.attDesc,'{A}',tostring(value))
                attr = attr .. string.format("\t%s",s) 
            end
            if i ~= #v then 
                attr = attr.."\n"
            end
        end  
        local paramsValue = Util.GetText(TextConfig.Type.ITEM,"haveEquip",k)              
        suit_atts = suit_atts..string.format("<f size='22' color='%s'>%s %s:\n%s </f> ",color,(bFrist and "" or "\n"),paramsValue,attr)
        if bFrist then
            bFrist = false
        end
    end    
    
    suit_atts = suit_atts.."</b>"
    self.tb_set_detail.XmlText = suit_atts
    
    self.ib_arrow_up.Visible = false
    self.ib_arrow_down.Visible = false
    
end

local function UpdateSuit(self,static_data)
    local suitShow = (static_data.SuitID ~= nil)
    local suit_data = GlobalHooks.DB.Find('SuitList',static_data.SuitID)      
    suitShow = suitShow and (suit_data ~= nil)    
        
    self.cvs_main_suit.Visible = suitShow
    if suitShow == true then 
        self.lb_set_name.Text = string.format("%s (1/%d)",suit_data.SuitName,suit_data.PartCount) 
        
        local part_text = "<b>"
        local suit_list = string.split(suit_data.PartCodeList,',')
        local isEnd = false  
        for i = 1,#(suit_list) do
            isEnd = (#suit_list == i)    
            local suit_other_part_item = ItemModel.GetItemStaticDataByCode(suit_list[i])
            if IsEquipOnBody(suit_other_part_item.Code) then
                part_text = part_text ..string.format("<f size='22' color='ff00f012'>%s</f>%s",suit_other_part_item.Type,isEnd and "" or ".")
            elseif suit_other_part_item.Code == static_data.Code then        
                part_text = part_text ..string.format("<f size='22' color='ffddf2ff'>%s</f>%s",suit_other_part_item.Type,isEnd and "" or ".")    
            else    
                part_text = part_text ..string.format("<f size='22' color='ff9aa9b5'>%s</f>%s",suit_other_part_item.Type,isEnd and "" or ".")
            end    
        end
        part_text = part_text .. "</b>"
        self.tb_set_kind.XmlText = part_text
        
        UpdateSuitDetail(self,static_data,suit_data,suit_list)    
        
    else
        
        self.cvs_set_list.Visible = false 
    end
end

local function UpdateBuildCenter(self)       
    if self.select_make_item ~= nil then
       self.cvs_buildcenter.Visible = true
    else
        self.cvs_buildcenter.Visible = false  
        return  
    end    
    
    local static_data = ItemModel.GetItemStaticDataByCode(self.select_make_item.TargetCode)    
	local itshow = Util.ShowItemShow(self.ib_equip,static_data.Icon,static_data.Qcolor)
    self.lb_equip.Text = static_data.Name
    self.lb_equip.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  
    self.lb_equip_type.Text = static_data.Type
    self.lb_use_job.Text = static_data.Pro    
    self.tb_build_level.Text = static_data.LevelReq    
    
    UpdateMat(self) 
    
    UpdateAtts(self,static_data)  
    
    UpdateSuit(self,static_data) 
    
end

function OnUpdate(self)       
    local ProName = GlobalHooks.DB.Find('Character',self.select_pro).ProName
    self.lb_jobname.Text = ProName    
    self.lb_rankname.Text = self.select_make_index.EquipLable
    
    UpdateSpType(self) 
    
    UpdateBuildCenter(self)
end

function SetEquipItem(self,node,make_item,index) 
    local static_data = ItemModel.GetItemStaticDataByCode(make_item.TargetCode)	
	local lb_detail_name = node:FindChildByEditName('lb_detail_name',false)
	local lb_detail_level = node:FindChildByEditName('lb_detail_level',false)
	local lb_detail_point = node:FindChildByEditName('lb_detail_point',false)
	local ib_icon = node:FindChildByEditName('ib_detail_icon',false)
    local lb_get= node:FindChildByEditName("Ib_get",false)
    
    if static_data == nil then
        node.Name = make_item.TargetCode 
        return
    end
    local equipLevel = Util.GetText(TextConfig.Type.ITEM, "equipLevel")
    lb_detail_level.Text = string.format(equipLevel,static_data.LevelReq)
    
	local itshow = Util.ShowItemShow(ib_icon,static_data.Icon,static_data.Qcolor)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	
	
	local tbt_main = node:FindChildByEditName('tbt_deatil',false)
	tbt_main:SetBtnLockState(HZToggleButton.LockState.eLockSelect)	
	
	lb_detail_name.Text = static_data.Name
	lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)
	
	tbt_main.IsChecked = (self.select_make_item == make_item)
	tbt_main.TouchClick = function (sender)
		if sender.IsChecked then
			OnEquipItemSelect(self,make_item,node,index)
		end
	end

    local num = CanMakeNum(self,make_item)
    lb_detail_point.Visible = (num > 0)
    lb_detail_point.Text = "" 

    if self.select_make_item == nil and index == 1 then 
        tbt_main.IsChecked = true
        OnEquipItemSelect(self,make_item,node,index)
    end

	node.Name = make_item.TargetCode

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(make_item.TargetCode)
    local equip_data = DataMgr.Instance.UserData.RoleEquipBag
    local eItem=equip_data:MergerTemplateItem(make_item.TargetCode)

    if vItem ~= nil or eItem ~=nil then
        lb_get.Visible = true
    else
        lb_get.Visible = false
    end
end

function OnEquipItemSelect(self,make_item,node,selectIndex) 
    if not make_item then return end
	if self.select_make_item then
		local item_node = FindEquipItem(self,self.select_make_item.TargetCode)
		if item_node then
			local tbt_main = item_node:FindChildByEditName('tbt_deatil',false)
			tbt_main.IsChecked = false
		end
	end
    self.select_make_item = make_item
    self.select_node = node

    UpdateBuildCenter(self)
end

 function FindEquipItem(self,targetCode)
	local child_list = self.sp_type.Scrollable.Container:GetAllChild()
	local children = Util.List2Luatable(child_list)
	for _,v in ipairs(children) do
		if v.Name == targetCode then
			return v
		end
	end
	return nil
end

local function OnShowJobTypeSelect(self)
    if self.cvs_typename.Visible == false then
		self.cvs_typename.Visible = true
		for i = 1,5 do 
            self["btn_JobType"..i].Text =   GlobalHooks.DB.Find('Character',i).ProName  
		end  
    else    
        self.cvs_typename.Visible = false
    end 
    self.tbt_job_open_pic.IsChecked = self.cvs_typename.Visible   
end

local function OnJobTypeSelect(self,index)
    OnShowJobTypeSelect(self)
    self.tbt_job_open.IsChecked = false
    self.tbt_job_open_pic.IsChecked = false    
    
    if self.select_pro ~= index then
        self.select_pro = index        
        OnUpdate(self)    
    end          
end

local function OnShowRankSelect(self)
    if self.sp_rank.Visible == false then
		self.sp_rank.Visible = true 
    else    
        self.sp_rank.Visible = false
    end  
    self.tbt_rank_open_pic.IsChecked = self.sp_rank.Visible  
end

function OnRankSelect(self,make_index)
    OnShowRankSelect(self)
    self.tbt_rank_open.IsChecked = false   
    self.tbt_rank_open_pic.IsChecked = false     
     
    if self.select_make_index ~= make_index then
        self.select_make_index = make_index
        OnUpdate(self)
    end          
end

local function OnShowClickCheckSuit(self)
    self.cvs_set_list.Visible = not self.cvs_set_list.Visible   
end

local function OnBuySuccess(self)
     UpdateMat(self)
     UpdateSpType(self) 
end

local function StartMake(self)
        ItemModel.EquipMakeRequest(self.select_make_item.TargetCode,function ()   
                if self.select_node ~= nil then
                    local lb_get= self.select_node:FindChildByEditName("Ib_get",false)
                    if lb_get ~= nil then
                        lb_get.Visible = true
                    end
                end

                
                UpdateMakeIcon(self)
                Util.showUIEffect(self.cvs_center,7) 
                Util.showUIEffect(self.cvs_center,34)

              
              local counterStr ="MakeCultivate"
              local valueStr =""
              local static_data = ItemModel.GetItemStaticDataByCode(self.select_make_item.TargetCode)    
              local kingdomStr = string.format("%s(%s)",static_data.Name,self.select_make_item.TargetCode)
              local phylumStr =""
              local classfieldStr = ""
              local familyStr = Util.GetText(TextConfig.Type.ITEM, "xiaohao")
              familyStr = familyStr .. string.format("%s(%s):%d,",self.select_make_item.ReqMateName1,self.select_make_item.ReqMateCode1,self.select_make_item.ReqMateCount1)
              familyStr = familyStr .. string.format("%s(%s):%d,",self.select_make_item.ReqMateName2,self.select_make_item.ReqMateCode2,self.select_make_item.ReqMateCount2)
              familyStr = familyStr .. string.format("%s(%s):%d,",self.select_make_item.ReqMateName3,self.select_make_item.ReqMateCode3,self.select_make_item.ReqMateCount3)

              local genusStr =Util.GetText(TextConfig.Type.ITEM, "dazhao")
              Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)

            end)         
 end

local function RebirthCancel()
            local AD = GameAlertManager.Instance.AlertDialog
            if AD:GetPriorityDialogCount(AlertDialog.PRIORITY_RELIVE) <= 1 then
                VisibleReliveMsgBox(true)
            end
        end

local function MakeCheck(self)
    
    
    if self.select_make_item == nil then
        return
    end

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(self.select_make_item.TargetCode)
    local equip_data = DataMgr.Instance.UserData.RoleEquipBag
    local eItem=equip_data:MergerTemplateItem(self.select_make_item.TargetCode)

    local havedazhao = Util.GetText(TextConfig.Type.ITEM, "havedazhao")
    local notdazhao = Util.GetText(TextConfig.Type.ITEM, "notdazhao")
    local mindazhao = Util.GetText(TextConfig.Type.ITEM, "mindazhao")
    local btnOK = Util.GetText(TextConfig.Type.ITEM, "btnOK")
    local cancel = Util.GetText(TextConfig.Type.ITEM, "cancel")

    if vItem ~=nil or eItem ~=nil then
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,havedazhao,btnOK,cancel,nil,function() StartMake(self) end,function() end)
        return
    end

    local user_Pro=DataMgr.Instance.UserData.Pro
    if self.select_pro ~=nil and self.select_pro ~= user_Pro then
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,notdazhao,btnOK,cancel,nil,function() StartMake(self) end,function() end)
        return
    end

    local user_lv=DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    if user_lv ~=nil and  self.select_make_index.LevelIndex ~= nil and user_lv - 9 > self.select_make_index.LevelIndex then
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,mindazhao,btnOK,cancel,nil,function() StartMake(self) end,function() end)
        return  
    end

    StartMake(self)
end

 

local ui_names = 
{
    {name='cvs_center'},
    {name = 'cvs_main'}, 
    {name = 'cvs_left'}, 
    {name = 'cvs_job'}, 
    {name = 'lb_jobname'}, 
    {name = 'tbt_job_open_pic'}, 
    {name = 'tbt_job_open',click = function (self)      
                OnShowJobTypeSelect(self)
	            end}, 
    {name = 'cvs_typename'}, 
    {name = 'btn_JobType1',click = function (self)      
                OnJobTypeSelect(self,1)
	            end}, 
    {name = 'btn_JobType2',click = function (self)      
                OnJobTypeSelect(self,2)
	            end}, 
    {name = 'btn_JobType3',click = function (self)      
               OnJobTypeSelect(self,3)
	            end}, 
    {name = 'btn_JobType4',click = function (self)      
               OnJobTypeSelect(self,4)
	            end}, 
    {name = 'btn_JobType5',click = function (self)      
                OnJobTypeSelect(self,5)
	            end}, 
    
    {name = 'cvs_rank'}, 
    {name = 'cvs_rankall'}, 
    {name = 'tbt_rank_open_pic'}, 
    {name = 'tbt_rank_open',click = function (self)      
                OnShowRankSelect(self)
	            end}, 
    {name = 'lb_rankname'}, 
    
    {name = 'sp_rank'}, 
    {name = 'cvs_rank_detail'}, 
    {name = 'btn_rank'}, 
    
    {name = 'sp_type'}, 
    {name = 'cvs_detail'}, 
    
    {name = 'cvs_buildcenter'}, 

    {name = 'ib_equip'}, 
    {name = 'lb_equip'}, 
    {name = 'lb_equip_type'}, 
    {name = 'lb_use_job'}, 
    {name = 'tb_build_level'}, 
    
    {name = 'cvs_build_property1'}, 
    {name = 'cvs_build_property2'}, 
    {name = 'cvs_build_property3'}, 
    {name = 'lb_random_property'}, 
    
    {name = 'cvs_main_suit'}, 
    {name = 'lb_set_name'}, 
    {name = 'tb_set_kind'}, 
    {name = 'btn_look',click = function (self)      
                OnShowClickCheckSuit(self)
	            end}, 
    
    {name = 'cvs_dep_single1'}, 
    {name = 'cvs_dep_single2'}, 
    {name = 'cvs_dep_single3'}, 
    
    {name = 'cvs_set_list',click = function (self)      
                self.cvs_set_list.Visible = false
                end}, 
    {name = 'lb_suit_list_name'}, 
    {name = 'tb_set_num'}, 
    {name = 'lb_suit_part1'}, 
    {name = 'lb_suit_part2'}, 
    {name = 'lb_suit_part3'}, 
    {name = 'lb_suit_part4'}, 
    {name = 'lb_suit_part5'}, 
    {name = 'lb_suit_part6'}, 
    {name = 'lb_suit_part7'}, 
    {name = 'tb_set_detail'}, 
    {name = 'ib_arrow_up'}, 
    {name = 'ib_arrow_down'}, 
        
    {name = 'btn_make',click = function (self)  
                     MakeCheck(self)
                     end}, 
    {name = 'lb_gold_number'}, 
    {name = 'cvs_make_effect'}, 
}



local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_build.gui.xml",tag)
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
    self.menu.Visible = true
    if self.select_pro == nil and self.select_make_index == nil then
        UpdateScriptData(self)	
        
        UpdateMakeIcon(self) 
    end
    
end

local function CloseUI(self)
    self.menu.Visible = false
end


_M.Create = Create
_M.ShowUI = ShowUI
_M.CloseUI = CloseUI
_M.OnBuySuccess = OnBuySuccess
_M.OnExit = OnExit
return _M
