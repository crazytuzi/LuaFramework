local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'




function _M.Close(self)
  self.menu:Close()  
end










local function OnReworkSelect(sender,self)
	local tags = FlagPushData.FLAG_REWORK_SCURBING
	if sender.UserTag ~= 0 then
		
		local sub_menu,obj
		if self.menu_tab[sender.UserTag] == nil then
			sub_menu,obj = GlobalHooks.CreateUI(sender.UserTag,0)
			self.menu_tab[sender.UserTag] = sub_menu;
			self.obj_tab[sender.UserTag] = obj
		else
			sub_menu = self.menu_tab[sender.UserTag]
			obj = self.obj_tab[sender.UserTag]
		end
        
        if sender.UserTag ~= GlobalHooks.UITAG.GameUIEquipReworkMake then 
            local make_obj = self.obj_tab[GlobalHooks.UITAG.GameUIEquipReworkMake]
            if make_obj ~= nil then
                make_obj:CloseUI()
            end            
            self.rework_main.cvs_main_left.Visible = true 
            
            self.rework_main.cvs_main_center:RemoveAllChildren(false)
		    self.rework_main.cvs_main_center:AddChild(sub_menu)
        else 
            self.rework_main.cvs_main_center:RemoveAllChildren(false)
            self.rework_main.cvs_main_left.Visible = false 
            
            self.rework_main.cvs_main_build:RemoveAllChildren(false)
            self.rework_main.cvs_main_build:AddChild(sub_menu)
        end        
        
        self.current_center = obj 
        if obj then
        	obj:ShowUI(self.rework_main)
        end
		
		
		local strTitle = Util.GetText(TextConfig.Type.ITEM, "xilian")
		if sender.UserTag  == GlobalHooks.UITAG.GameUIEquipReworkMake then
			strTitle = Util.GetText(TextConfig.Type.ITEM, "dazhao")
		elseif sender.UserTag  == GlobalHooks.UITAG.GameUIEquipReworkReMake then
			strTitle = Util.GetText(TextConfig.Type.ITEM, "chongzhu")
			tags = FlagPushData.FLAG_REWORK_REMAKE
		elseif sender.UserTag == GlobalHooks.UITAG.GameUIEquipReworkScurbing then
			strTitle = Util.GetText(TextConfig.Type.ITEM, "xilian")
			tags = FlagPushData.FLAG_REWORK_SCURBING
		
		
		elseif sender.UserTag  == GlobalHooks.UITAG.GameUIEquipReworkKaiguang then	
			strTitle = Util.GetText(TextConfig.Type.ITEM, "kaiguang")
			tags = FlagPushData.FLAG_REWORK_KAIGUANG
		elseif sender.UserTag  == GlobalHooks.UITAG.GameUIEquipReworkChuancheng then	
			strTitle = Util.GetText(TextConfig.Type.ITEM, "chuancheng")
		end
		self.rework_main.lb_title.Text = strTitle
	end
	if (tags == FlagPushData.FLAG_REWORK_SCURBING and self.lb_scrubbing_point.Visible) or
		(tags == FlagPushData.FLAG_REWORK_REMAKE and self.lb_remake_point.Visible) or
		(tags == FlagPushData.FLAG_REWORK_KAIGUANG and self.lb_kaiguang_point.Visible) then
		ItemModel.OpenEquipHandlerRequest(tags)
	end
	
end

function _M.OnExit(self)
    if self.current_center ~= nil then
    	self.current_center:OnExit()
    end
end

function _M.OnBuySuccess(self)
    if self.current_center ~= nil then
    	self.current_center:OnBuySuccess()
    end
end

local function  UpdateRedPoint(self,status)
	if status == FlagPushData.FLAG_REWORK_SCURBING then 
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_SCURBING)
        self.lb_scrubbing_point.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_REWORK_REFINE then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_REFINE)
        self.lb_refine_point.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_REWORK_REMAKE then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_REMAKE)
        self.lb_remake_point.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_REWORK_MAKE then  
        local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_MAKE)
        self.lb_make_point.Visible = (num ~= nil and num > 0)
    elseif status == FlagPushData.FLAG_REWORK_KAIGUANG then  
	    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_KAIGUANG)
	    self.lb_kaiguang_point.Visible = (num ~= nil and num > 0)
    end
end

function _M.OnUpdateRedPoint(self,status,flagData)
	if flagData ~= DataMgr.Instance.FlagPushData then
		return
	end
    UpdateRedPoint(self,status)
end

local function OnEnter(self)
	
end

local ui_names = 
{
	"lb_make_point",
	"lb_remake_point",
	"lb_refine_point",
	"lb_scrubbing_point",
	"lb_kaiguang_point",
	"tbt_scrubbing",
	"tbt_make",
	"tbt_remake",
	"tbt_refine",
	"tbt_kaiguang",
	"tbt_chuancheng",
}

local function InitComponent(self,tag)
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_right.gui.xml",tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self) 

  
  self.lb_make_point = self.menu:GetComponent("lb_make_point")
  self.lb_remake_point = self.menu:GetComponent("lb_remake_point")
  self.lb_refine_point = self.menu:GetComponent("lb_refine_point")
  self.lb_scrubbing_point = self.menu:GetComponent("lb_scrubbing_point")
  self.lb_kaiguang_point = self.menu:GetComponent("lb_kaiguang_point")

  UpdateRedPoint(self,FlagPushData.FLAG_REWORK_MAKE) 
  UpdateRedPoint(self,FlagPushData.FLAG_REWORK_SCURBING)
  UpdateRedPoint(self,FlagPushData.FLAG_REWORK_REMAKE)
  UpdateRedPoint(self,FlagPushData.FLAG_REWORK_KAIGUANG)
end

local function Create(tag)
  local self = {}
  setmetatable(self, _M)
  InitComponent(self,tag)
  return self
end

function _M.OnChangeSelect(self)
	if self.current_center ~= nil then
       self.current_center:ShowUI(self.rework_main)
    end
end

function _M.SetReWorkMain(self,rework,defaultOpenPage)
 self.rework_main = rework

  local tbt_tab = {
	tbt_scrubbing = GlobalHooks.UITAG.GameUIEquipReworkScurbing,
	tbt_make = GlobalHooks.UITAG.GameUIEquipReworkMake,
	tbt_remake = GlobalHooks.UITAG.GameUIEquipReworkReMake,
	
	tbt_kaiguang = GlobalHooks.UITAG.GameUIEquipReworkKaiguang,
	tbt_chuancheng = GlobalHooks.UITAG.GameUIEquipReworkChuancheng,
	}
	
  local tbts = {}
  local default_tbt = nil
  for k,v in pairs(tbt_tab) do
	local tbt = self.menu:GetComponent(k)
	tbt.UserTag = v
	if not GlobalHooks.CheckFuncIsOpenByName(v,false) then   
	  tbt.Visible = false 
	  tbt.TouchClick = function (sender)
		if sender.IsChecked then
		  sender.IsChecked = false
		  GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM, "notopenlevel"))
		end       
	  end
	else
		tbt.Visible = true 
		table.insert(tbts,tbt)
	end	
	
	if tostring(v) == tostring(defaultOpenPage) then 
		default_tbt = tbt
		
	end		
	
  end
	
	self.menu_tab = {}
	self.obj_tab = {}
	
  Util.InitMultiToggleButton(function(sender)
	OnReworkSelect(sender,self)
	end
, default_tbt, tbts)	
end

_M.Create = Create
return _M
