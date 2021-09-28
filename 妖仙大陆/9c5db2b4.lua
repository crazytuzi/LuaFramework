

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'

function _M.Close(self)
  self.menu:Close()  
end

local function ShowFromEquip(self)	
	ShowEquipItem(self,DataMgr.Instance.UserData.RoleEquipBag)
end

local function ShowFromBag(self) 	
	ShowEquipItem(self,DataMgr.Instance.UserData.RoleBag)
end

local function OnSwitchEquip(sender,self)
	
	self.select_equip = nil
	if sender.EditName == 'tbt_equip' then
		ShowFromEquip(self)
	else
		ShowFromBag(self)
	end

end

local ui_names = 
{
	{name = 'tbt_equip'},
	{name = 'tbt_bag'},
	{name = 'sp_scroll'},
	{name = 'cvs_detail'},
}

 local function SetEquipListItem(self,node,equip,index)
	local static_data = ItemModel.GetItemStaticDataByCode(equip.TemplateId)
	
	local lb_detail_name = node:FindChildByEditName('lb_detail_name',false)
	local lb_detail_level = node:FindChildByEditName('lb_detail_level',false)
	local lb_detail_point = node:FindChildByEditName('lb_detail_point',false)
	
	local ib_icon = node:FindChildByEditName('ib_detail_icon',false)
	local itshow = Util.ShowItemShow(ib_icon,equip.IconId,equip.Quality)
	itshow.EnableTouch = true
	itshow.TouchClick = function (sender)
		
	end	
	
	local tbt_main = node:FindChildByEditName('tbt_deatil',false)
	tbt_main:SetBtnLockState(HZToggleButton.LockState.eLockSelect)	
	
	lb_detail_name.Text = static_data.Name
	lb_detail_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)
	local equipLevel = Util.GetText(TextConfig.Type.ITEM, "equipLevel")
	lb_detail_level.Text = string.format(equipLevel,static_data.LevelReq)
	lb_detail_point.Visible = false

	tbt_main.IsChecked = (self.select_equip == equip)
	tbt_main.TouchClick = function (sender)
		if sender.IsChecked then
			OnSelectEquip(self,equip)
		end
	end

	if self.select_equip == nil and index == 1 then 
        tbt_main.IsChecked = true
        OnSelectEquip(self,equip)
    end

	node.Name = equip.Id
end

function ShowEquipItem(self,item_pack)
	local filter_equip = ItemPack.FilterInfo.New()
	filter_equip.Type  = ItemData.TYPE_EQUIP
	filter_equip.CheckHandle = function (it)
		local static_data = ItemModel.GetItemStaticDataByCode(it.TemplateId)	
        return static_data.Qcolor > 0
    end
	item_pack:AddFilter(filter_equip)   
	local item_counts = filter_equip.ShowData.Count
	self.sp_scroll.Scrollable:ClearGrid()
	
	if item_counts < 1 then 
    	if self.rework_main ~= nil and self.rework_main.right_toggle_part then
            self.rework_main.right_toggle_part:OnChangeSelect()
        end	
	end

	if self.sp_scroll.Rows <= 0 then
		self.sp_scroll.Visible = true
		local cs = self.cvs_detail.Size2D
		self.sp_scroll:Initialize(cs.x,cs.y,item_counts,1,self.cvs_detail,
		function (gx,gy,node)
			local equip = filter_equip:GetItemDataAt(gy + 1)
			SetEquipListItem(self,node,equip,gy + 1)
		end,function ()	end)
	else
		self.sp_scroll.Rows = item_counts
	end	
	
	item_pack:RemoveFilter(filter_equip)
end

function OnSelectEquip(self,equip)
  if not equip then return end
	if self.select_equip then
		local item_node = FindEquipListItem(self,self.select_equip.Id)
		if item_node then
			local tbt_main = item_node:FindChildByEditName('tbt_deatil',false)
			tbt_main.IsChecked = false
		end
	end
	
	self.select_equip = equip
    if self.rework_main ~= nil and self.rework_main.right_toggle_part then
        self.rework_main.right_toggle_part:OnChangeSelect()
    end	    
end

 function FindEquipListItem(self,equip_id)
	local child_list = self.sp_scroll.Scrollable.Container:GetAllChild()
	local children = Util.List2Luatable(child_list)
	for _,v in ipairs(children) do
		if v.Name == equip_id then
			return v
		end
	end
	return nil
end

local function OnEnter(self)
  self.cvs_detail.Visible = false
end

function _M.SetReWorkMain(self,rework)
  local tbt_tab = {
	tbt_equip = GlobalHooks.UITAG.GameUIEquipReworkLeftChoose,
	tbt_bag = GlobalHooks.UITAG.GameUIEquipReworkLeftChoose,
	}
	
  local tbts = {}
  local default_tbt = nil
  for k,v in pairs(tbt_tab) do
	local tbt = self.menu:GetComponent(k)
	tbt.UserTag = v
	if v == 0 then    
	  tbt.TouchClick = function (sender)
		if sender.IsChecked then
		  sender.IsChecked = false
		  GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM, "notopenlevel"))
		end       
	  end
	else
		table.insert(tbts,tbt)
	end	
	
	if k == "tbt_equip" then 
		default_tbt = tbt
	end	
  end

  Util.InitMultiToggleButton(function (sender)
	OnSwitchEquip(sender,self)
  end, default_tbt, tbts)	

   self.rework_main = rework 
 
end

local function InitComponent(self,tag)
  
  self.menu = LuaMenuU.Create("xmds_ui/rework/rework_left.gui.xml",tag)
  Util.CreateHZUICompsTable(self.menu,ui_names,self) 
  
  self.sp_scroll.ShowSlider = true
  OnEnter(self)
end

local function Create(tag)
  local self = {}
  setmetatable(self, _M)
  InitComponent(self,tag)
  return self
end

_M.Create = Create
return _M
