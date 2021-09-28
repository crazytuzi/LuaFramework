local _M = { }
_M.__index = _M

local AutoSettingApi = require "Zeus.Model.AutoSetting"
local Util          = require 'Zeus.Logic.Util'
local SliderExt = require "Zeus.Logic.SliderExt"
local VipUtil = require "Zeus.UI.Vip.VipUtil"
local DisplayUtil = require "Zeus.Logic.DisplayUtil"
local Item = require "Zeus.Model.Item"
local ServerTime = require "Zeus.Logic.ServerTime"

local function InitUI(self)
    local UIName = {
    	"ib_percent",
        "gg_hp",
		"ib_top",
		"tbt_gou1",
		"tbt_gou2",
		"tbt_gou3",
		"tbt_gou4",
		
		
		

        "cvs_icon",
        "lb_name",
        "lb_cd",
        "btn_change"
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:FindChildByEditName(UIName[i],true)
    end
end

function _M:setVisible(visible)
    self.menu.Visible = visible
    
end

local function getIsMapHangup(self) 
	local property = GameUtil.IsWildScene() and "isAutoFightMapModeInWild" or "isAutoFightMapModeInOther"
	return self.autoSetting[property]
end

local function setIsMapHangup(self,value)
	local property = GameUtil.IsWildScene() and "isAutoFightMapModeInWild" or "isAutoFightMapModeInOther"
	self.autoSetting[property] = value
end













local function setItemFilter(self, code)
    local filter = self.hpFilter
    if filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
    end
    filter = ItemPack.FilterInfo.New()
    self.hpFilter = filter

    filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
        return item.TemplateId == code
    end
    filter.NofityCB = function(pack, type, index)
        if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
            local bag_data = DataMgr.Instance.UserData.RoleBag
    		local vItem = bag_data:MergerTemplateItem(code)
    		local num = (vItem and vItem.Num) or 0
    		self.itemShow.ForceNum = num
        end
    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function setItemUI(self, itemCode,num)
	local item = GlobalHooks.DB.Find("Items", itemCode)
    if self.autoSetting.hpItemCode ~= item.Code then
        self.autoSetting.hpItemCode = item.Code
        AutoSettingApi.saveSetting()
    end

    self.itemShow = Util.ShowItemShow(self.cvs_icon, item.Icon, item.Qcolor, num, true)
    self.itemShow.UserData = item.Code
    
    self.itemShow.EnableTouch = true
    self.itemShow.IsSelected = false

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(itemCode)
    local itemDetail = Item.GetItemDetailByCode(item.Code)
    self.itemShow.TouchClick = function (sender)
        EventManager.Fire('Event.ShowItemDetail',{data=itemDetail}) 
    end
    
    
        
    
    
    
    
    
    
    
    

    DisplayUtil.setItemName(self.lb_name, item.Name, item.Qcolor)
    local staticVo = GlobalHooks.DB.Find("Items", item.Code)
    self.lb_cd.Text = ServerTime.GetCDStrCut(itemDetail.static.UseCD / 1000)

    
   setItemFilter(self, item.Code)
end














local function InitComponent(self, tag, parent)
    
    self.autoSetting = DataMgr.Instance.AutoSettingData

    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/set/guaji.gui.xml')
    InitUI(self)

    self.parent = parent
    if (parent) then
        parent:AddChild(self.menu)
    end



    self.btn_change.TouchClick = function()
    	
        
    	
    	local ui,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISetSelect)
    	if not ui then
       		ui,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUISetSelect,0)
        	local uiParent,_ = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISetMain)

        	uiParent:AddSubMenu(ui)
    	end
    	self.SelectUI = obj
    	self.SelectUI:setItems(function(itemCode)
    		local bag_data = DataMgr.Instance.UserData.RoleBag
  			local vItem = bag_data:MergerTemplateItem(itemCode)
	    	local num = (vItem and vItem.Num) or 0
    		setItemUI(self,itemCode,num)
    	end)
    end
end

function _M:OnEnter()
    self.hpFilter = nil

    self.ib_percent.Text = self.autoSetting.hpPercent .. "%"
    self.hpSlider = SliderExt.New(
        self.gg_hp,
        self.ib_top,
        0, function(value)
			value = math.floor(value)
    		self.autoSetting.hpPercent = value
    		self.ib_percent.Text = value .. "%"
        end, true
    )
    self.hpSlider:setValue(self.autoSetting.hpPercent)

    local defaultTbt1 = self.tbt_gou2
    if getIsMapHangup(self) then
    	defaultTbt1 = self.tbt_gou1
    end
    Util.InitMultiToggleButton(function (sender)
    	local  value = false
      	if sender == self.tbt_gou1 then
      		value = true
      	end
      	setIsMapHangup(self,value)
    end,defaultTbt1,{self.tbt_gou1,self.tbt_gou2})

    local defaultTbt2 = self.tbt_gou3
    if not self.autoSetting.autoFightBack then
    	defaultTbt2 = self.tbt_gou4
    end
    Util.InitMultiToggleButton(function (sender)
    	if sender == self.tbt_gou3 then
			self.autoSetting.autoFlee = false
			self.autoSetting.autoFightBack = true
    	else
			self.autoSetting.autoFlee = true
			self.autoSetting.autoFightBack = false
    	end
    end,defaultTbt2,{self.tbt_gou3,self.tbt_gou4})

    local btnMap = {tbt_gou5 = "Default", tbt_gou6 = "Blue", tbt_gou7="Purple"}
    local notVipQColor = GlobalHooks.DB.Find("ItemQualityConfig", {Key = "Default"})[1].ID
    self.vipLvOpenMap = {}
    self.qualityBtns = {}
    for k,v in pairs(btnMap) do
        local tbtBtn = self.menu:FindChildByEditName(k,true)
        tbtBtn.UserTag = GlobalHooks.DB.Find("ItemQualityConfig", {Key = v})[1].ID
        self.qualityBtns[tbtBtn.UserTag] = tbtBtn
        if tbtBtn.UserTag <= notVipQColor then
            self.vipLvOpenMap[tbtBtn.UserTag] = 0
        else
            self.vipLvOpenMap[tbtBtn.UserTag] = VipUtil.vipLvByFunc("ExtraQcolor", tbtBtn.UserTag)
        end
        tbtBtn.IsChecked = self.autoSetting:IskMeltQuality(tbtBtn.UserTag)
        tbtBtn.TouchClick = function(sender)
        
      
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    
		    self.autoSetting:SetMeltQuality(sender.UserTag, sender.IsChecked)
        end
    end

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(self.autoSetting.hpItemCode)
    
    setItemUI(self,self.autoSetting.hpItemCode,(vItem and vItem.Num) or 0)


end

function _M:OnExit()
    AutoSettingApi.saveSetting()
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.hpFilter)
    self.hpFilter = nil
end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag,parent)
    return ret
end

return _M
