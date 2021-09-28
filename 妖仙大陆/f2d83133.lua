local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ServerTime = require "Zeus.Logic.ServerTime"
local AutoSettingApi = require "Zeus.Model.AutoSetting"

local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "sp_list",
		"cvs_equip_brief",
        "tbt_choose",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.tbt_choose.TouchClick = function (sender)
         self.autoSetting.autoBuyHpItem = self.tbt_choose.IsChecked
         AutoSettingApi.saveSetting()
    end
end

local function setItemFilter(self)
    local filter = self.hpFilter
    if filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
    end
    filter = ItemPack.FilterInfo.New()
    self.hpFilter = filter

    filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
        return item.detail.static.Type == 'hpot'
    end
    filter.NofityCB = function(pack, type, index)
    	if self.itemShows==nil or #self.itemShows<=0 then
			return
		end
        if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
        	local itemData = self.hpFilter:GetItemDataAt(index)
        	local num = itemData.Num
        	local  tag = 0
        	for i,v in ipairs(self.HpItems) do
        		if v.Code == itemData.detail.static.Code then
        			tag = i
        			break
        		end
        	end

        	if tag ~= 0 then
        		if num >= 1 and self.itemShows[tag].ForceNum == 0 then
    				local  cell = self.sp_list.Scrollable:GetCell(0,tag-1)
    				cell:FindChildByEditName("btn_equip",true).Visible = true
                    cell:FindChildByEditName("ib_zhezhao",true).Visible = false
                    cell:FindChildByEditName("ib_get",true).Visible = false
    			end
    			self.itemShows[tag].ForceNum = num
        	end
        end


    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function OnEnter()
	self.hpFilter = nil
	setItemFilter(self)
	self.itemShows = {}

    self.tbt_choose.IsChecked = self.autoSetting.autoBuyHpItem
end

local function OnExit()
	DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.hpFilter)
    self.hpFilter = nil
    self.itemShows = nil
end


function _M:setItems(callback)
	local function updateCell(gx, gy, cell)
	    local tag = gy + 1
	    cell.Visible = true

	    local item = self.HpItems[tag]
        local ib_zhezhao = cell:FindChildByEditName("ib_zhezhao", true)
        local ib_get = cell:FindChildByEditName("ib_get", true)
	    local icon = cell:FindChildByEditName("cvs_equipicon0", true)
	    local btn_get = cell:FindChildByEditName("btn_get",true)
	    local btn_equip = cell:FindChildByEditName("btn_equip",true)
	    local nameLabel = cell:FindChildByEditName("lb_equipname", true)
	    local cdLabel = cell:FindChildByEditName("lb_score", true)
        local ib_click = cell:FindChildByEditName("ib_click",true)

        if item.Code == self.autoSetting.hpItemCode then
            ib_click.Visible = true
            btn_equip.Visible = false
        else    
            ib_click.Visible = false
            btn_equip.Visible = true
        end
	    local itshow = Util.ShowItemShow(icon, item.Icon, item.Qcolor)
	    self.itemShows[tag] = itshow
	    local lb_wenben = cell:FindChildByEditName("lb_wenben",true)

	    nameLabel.Text = item.Name
	    nameLabel.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(item.Qcolor))
	    cdLabel.Text = ServerTime.GetCDStrCut(item.UseCD/1000)
	    lb_wenben.XmlText = item.Desc

	    local bag_data = DataMgr.Instance.UserData.RoleBag
  		local vItem = bag_data:MergerTemplateItem(item.Code)
	    local num = (vItem and vItem.Num) or 0

		btn_get.TouchClick = function ()
			
			
			
			
			
            
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, item.Code)
    	end
		btn_equip.TouchClick = function(sender)
            if item.LevelReq > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) then
                
                local levelequip = Util.GetText(TextConfig.Type.GUILD, "levelequip")
                GameAlertManager.Instance:ShowNotify(item.Name .. item.LevelReq..levelequip)
                return
            end
			if self.callback then
				self.callback(item.Code)
			end
            self.sp_list:RefreshShowCell()
			
		end

		itshow.ForceNum = num
	    if num == 0 then
            ib_zhezhao.Visible = true
            ib_get.Visible = true
	    	
	    else 
            ib_zhezhao.Visible = false
            ib_get.Visible = false
	    	
	    end
	end

    self.callback = callback
    self.sp_list:Initialize(self.cvs_equip_brief.Width, self.cvs_equip_brief.Height,
         #self.HpItems, 1, self.cvs_equip_brief, updateCell,nil)

    
end

local function InitComponent(self,tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/set/drug_choice.gui.xml',tag)
    self.autoSetting = DataMgr.Instance.AutoSettingData

    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.event_PointerClick = function(sender)
        self.menu:Close()
   end
    self.cvs_equip_brief.Visible = false


    self.HpItems = GlobalHooks.DB.Find("Potion", {Type = 'hpot'})
    table.sort(self.HpItems,function (i1,i2)
            if i1.Qcolor ~= i2.Qcolor then
                return i1.Qcolor < i2.Qcolor
            else
                return i1.Min < i2.Min
            end
        end)
    return self.menu
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
