local _M = {}
_M.__index = _M


local PetModel      = require 'Zeus.Model.Pet'
local Util          = require 'Zeus.Logic.Util'
local Culture       = require 'Zeus.UI.XmasterPet.PetUICulture'
local Upgrade       = require 'Zeus.UI.XmasterPet.PetUIUpgrade'
local Associate       = require 'Zeus.UI.XmasterPet.PetAssociate'
local PetAttribute     = require 'Zeus.UI.XmasterPet.PetUIAttribute'
local PetModelBase          = require 'Zeus.UI.XmasterPet.PetModelBase'
local ExchangeUtil          = require 'Zeus.UI.ExchangeUtil'

local toPlaySoundPath = nil
local associateData = {}
local self = {
    m_Root = nil,

}

local function chekRedPoint()
    local filter = self.petItemFilter
    if filter then
      DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
    end
    filter = ItemPack.FilterInfo.New()
    self.petItemFilter = filter

    filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
      return item.detail.static.Type == 'petItem' and item.detail.static.Prop ~= 'pet'
    end

    filter.NofityCB = function(pack, type, index)
      if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
          local itemData = filter:GetItemDataAt(index)
          
          
          
        local data = self.petConfigData[self.listId[self.curSelectIndex]]
        self.lb_bj_train.Visible = PetModel.checkCanSummon(data.PetID)
        self.lb_bj_upgrade.Visible = PetModel.checkCanUpgrade(data.PetID)
        self.lb_red_lvup.Visible = PetModel.checkCanUpLevel(data.PetID)
        self.lb_red_call.Visible = PetModel.checkCanSummon(data.PetID)
        self.sp_tab:RefreshShowCell()
      end


    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function OnClickClose(displayNode)
    
    if self ~= nil and self.m_Root ~= nil then
        self.m_Root:Close()
    end
end


local function RefreshState(self,data)
    if data == nil then
        data = self.petConfigData[self.listId[self.curSelectIndex]]
    end

    local serverData = self.curPetList[data.PetID]
    local isWar = self.fightid == data.PetID

    if serverData ~= nil then  
        self.lb_petname.Text = self.curPetList[data.PetID].name
        self.btn_changename.Visible = true

        self.ib_havenot.Visible = false
        
        self.cvs_pet_evolution.Visible = true
        

        if isWar then 
            self.ib_comeout.Visible = true
            self.btn_rest.Visible = true
            self.btn_gowar.Visible = false
        else
            self.ib_comeout.Visible = false
            self.btn_rest.Visible = false
            self.btn_gowar.Visible = true
        end
        self.cvs_pet_get.Visible = false

        self.lb_level.Text = serverData.level ..  Util.GetText(TextConfig.Type.ITEM,'lvSuffix')
        self.lb_level_step.Text = serverData.upLevel .. Util.GetText(TextConfig.Type.ITEM,'advanceSuffix')

        local expData =  GlobalHooks.DB.Find("PetExpLevel", serverData.level) 
        self.gg_evolution:SetGaugeMinMax(0, expData.Experience)
        self.gg_evolution.Value = serverData.exp > expData.Experience and expData.Experience or serverData.exp
        local text = serverData.exp .. "/" .. expData.Experience
        
        
        
        
            self.tb_evolution_num.Text = text
        

        self.cvs_combatpower.Visible = true
        self.lb_combatpower.Text = serverData.fightPower
    else
        self.lb_petname.Text = data.PetName
        self.btn_changename.Visible = false

        self.ib_havenot.Visible = true
        self.ib_comeout.Visible = false
        self.cvs_pet_evolution.Visible = false
        
        self.btn_rest.Visible = false
        self.btn_gowar.Visible = false
        self.cvs_pet_get.Visible = true

        local item = GlobalHooks.DB.Find("Items", data.PetItemCode)
        self.itemShow = Util.ShowItemShow(self.ib_pet_get, item.Icon, item.Qcolor)
        self.itemShow.TouchClick = function (sender)
                EventManager.Fire('Event.ShowItemDetail',{data=item}) 
        end

        self.lb_get_name.Text =  item.Name

        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem = bag_data:MergerTemplateItem(data.PetItemCode)
        local num = (vItem and vItem.Num) or 0    

        self.gg_get:SetGaugeMinMax(0, data.ItemCount)
        self.gg_get.Value = num > data.ItemCount and data.ItemCount or num
        local text = num .. "/" .. data.ItemCount
        if num < data.ItemCount then
            text = string.format("<f color='%s'>%s</f>",Util.GetQualityColorARGBStr(GameUtil.Quality_Red),text) 
            self.tb_get_num.XmlText = text
            
            
            self.btn_getway.Visible = true
            self.btn_call.Visible = false
        else
            self.tb_get_num.XmlText = text
            
            self.btn_getway.Visible =false
            
            self.btn_call.Visible = true
        end

        self.cvs_combatpower.Visible = false
        
            
            
        chekRedPoint()
    end
end

local function SwitchPage(sender)
	




	local  data = self.petConfigData[self.listId[self.curSelectIndex]]
	if sender == self.tbt_upgrade then

		if self.curPetList[data.PetID] ~= nil then
			if self.culture ~= nil then
				self.culture:onExit()
				self.culture = nil
			end

            if self.petattribute ~= nil then
                self.petattribute:onExit()
                self.petattribute = nil
            end

            if self.associates ~= nil then
                self.associates:onExit()
                self.associates = nil
            end
			if self.upgrade == nil then
				self.upgrade = Upgrade.CreateUpgradeUI(self.cvs_center,self.ib_peteffectsnew)
			end
			self.upgrade:setPetInfo(data)
            self.lastTab = sender
		else
			GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.PET,'no_thispet'))
            if self.lastTab == nil then
                self.lastTab = self.tbt_train
            end
			Util.ChangeMultiToggleButtonSelect(self.lastTab,{self.tbt_train,self.tbt_upgrade,self.tbt_associate,self.tbt_attribute})

      
      
    		
		end
    elseif sender == self.tbt_associate then
        if self.upgrade ~= nil then
            self.upgrade:onExit()
            self.upgrade = nil
        end

        if self.petattribute ~= nil then
            self.petattribute:onExit()
            self.petattribute = nil
        end
        if self.associates == nil then
            self.associates = Associate.CreateAssociateUI(self.cvs_middle,associateData)
        end
        self.lastTab = sender
	elseif sender == self.tbt_train then

		if self.upgrade ~= nil then
			self.upgrade:onExit()
			self.upgrade = nil
		end
        if self.associates ~= nil then
            self.associates:onExit()
            self.associates = nil
        end

        if self.petattribute ~= nil then
            self.petattribute:onExit()
            self.petattribute = nil
        end

		if self.culture == nil then
			self.culture = Culture.CreateCultureUI(self.cvs_center)
		end
		self.culture:setPetInfo(data)
        self.lastTab = sender
    elseif sender == self.tbt_attribute then

        local isfind = false
        for k,v in pairs(self.curPetList) do
            isfind = true
            break
        end

        if not isfind then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.PET,'no_pet'))
            Util.ChangeMultiToggleButtonSelect(self.tbt_train,{self.tbt_train,self.tbt_upgrade,self.tbt_associate,self.tbt_attribute})
        else
            if self.culture ~= nil then
                self.culture:onExit()
                self.culture = nil
            end

            if self.upgrade ~= nil then
                self.upgrade:onExit()
                self.upgrade = nil
            end

            if self.associates ~= nil then
                self.associates:onExit()
                self.associates = nil
            end

            if self.petattribute == nil then
                self.petattribute = PetAttribute.CreateAttUI(self.cvs_center,associateData)
            end
            self.lastTab = sender
        end
        
    end

end

local function SwitchToUpgrade()
        local  data = self.petConfigData[self.listId[self.curSelectIndex]]
	    if self.curPetList[data.PetID] ~= nil then
			    if self.culture ~= nil then
				    self.culture:onExit()
				    self.culture = nil
			    end

                if self.petattribute ~= nil then
                    self.petattribute:onExit()
                    self.petattribute = nil
                end
                if self.associates ~= nil then
                    self.associates:onExit()
                    self.associates = nil
                end
			    if self.upgrade == nil then
				    self.upgrade = Upgrade.CreateUpgradeUI(self.cvs_center,self.ib_peteffectsnew)
			    end
			    self.upgrade:setPetInfo(data)
                self.lastTab = self.tbt_upgrade
                self.tbt_upgrade.IsChecked = true

    
		end
	
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "ib_peticon",
        "ib_qualitybox",
        "ib_choosebox",
        "ib_fight",
        "lb_bj_pet",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function setPetInfo(petData)
    PetModelBase.InitModelAvaterstr(self, self.cvs_petmodel, petData, nil, false)
    IconGenerator.instance:SetBackGroundImage(self.Model3DAssetBundel, "Textures/IconGenerator/petshowbk")
     
    self.lb_petquality.Text = petData.Type
    self.lb_petquality.FontColorRGBA = Util.GetQualityColorRGBA(tonumber(petData.Qcolor))
    if self.culture then
     self.culture:setPetInfo(petData)

    end
    
    
    
    

    local addAttr = GlobalHooks.DB.Find("PetConfig", { ParamName = "PetPro.Transform" .. petData.Qcolor})[1].ParamValue
    self.lb_tips_per.Text = addAttr .. "%"
end

local function findFightIndex()
    local  index = 1
    for i=1,#self.listId do
        local data = self.petConfigData[self.listId[i]]
        if self.fightid == data.PetID then
            index = i
            break
        end
    end
    return index
end

local function OnPetSelected(sender)
    if self.upgrade ~= nil then
        self.upgrade:onExit()
        self.upgrade = nil
    end
    if self.petattribute ~= nil then
        self.petattribute:onExit()
        self.petattribute = nil
    end
    if self.associates ~= nil then
        self.associates:onExit()
        self.associates = nil
    end

	local index = sender and sender.UserTag or findFightIndex()

    self.curSelectIndex = index
    local data = self.petConfigData[self.listId[self.curSelectIndex]]
    
    RefreshState(self,data)

    Util.ChangeMultiToggleButtonSelect(self.tbt_train,{self.tbt_train,self.tbt_upgrade,self.tbt_associate,self.tbt_attribute})

    SwitchPage(self.tbt_train)
    setPetInfo(data)
	self.sp_tab:RefreshShowCell()

    self.lb_bj_train.Visible = PetModel.checkCanSummon(data.PetID)
    self.lb_bj_upgrade.Visible = PetModel.checkCanUpgrade(data.PetID)
    self.lb_red_lvup.Visible = PetModel.checkCanUpLevel(data.PetID)
    self.lb_red_call.Visible = PetModel.checkCanSummon(data.PetID)

    if toPlaySoundPath then
          XmdsSoundManager.GetXmdsInstance():stopClipSource(data.Sound)
    end
    toPlaySoundPath = data.Sound
    XmdsSoundManager.GetXmdsInstance():PlaySound(data.Sound);


end

local function InitPetItem(node)
	node.TouchClick = OnPetSelected
end

local function RefreshPetItem(x, y, node)
	local index = y + 1

	if index > #self.listId then
        node.Visible = false
        return
    end

	node.Visible = true
    local data = self.petConfigData[self.listId[index]]
    node.UserTag = index
    local ui = {}
    InitItemUI(ui, node)

	if self.curSelectIndex ~= index then
    	ui.ib_choosebox.Visible = false
    else
    	ui.ib_choosebox.Visible = true
    end

    if self.fightid == data.PetID then
        ui.ib_fight.Visible = true
    else
        ui.ib_fight.Visible = false
    end

    local serverData = self.curPetList[data.PetID]
    if serverData ~= nil then
        ui.lb_bj_pet.Visible = PetModel.checkCanUpLevel(data.PetID) or PetModel.checkCanUpgrade(data.PetID)
    else
        ui.lb_bj_pet.Visible = PetModel.checkCanSummon(data.PetID)
    end
    Util.ShowItemShow(ui.ib_peticon,  "static_n/item/" .. data.Icon .. ".png", data.Qcolor, 0)


    	
    	
    
    

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    
    	
        
        
        
        
        
    
end



local function GetBaseData()
    if #self.petConfigData == 0 then

        self.petConfigData = GlobalHooks.DB.Find('BaseData',{})
        table.sort(self.petConfigData, function(aa, bb)
            
            if aa.PetID < bb.PetID then
                return true
            else
                return false
            end
        end)
    end

    return self.petConfigData
end

local function InitPetData(data)
    
    self.listId = {}
    local petmodels = GlobalHooks.DB.Find('BaseData',{})
    for i,v in ipairs(petmodels) do
        self.petConfigData[v.PetID] = v
        self.listId[i] = v.PetID
    end
    associateData = data
    self.curPetList = data
    
    table.sort(self.listId, function(a, b)
            
            local  aa = self.petConfigData[a]
            local  bb = self.petConfigData[b]
            if self.curPetList[a] ~=nil and self.curPetList[b] ==nil then
                return true
            end

            if self.curPetList[a] ==nil and self.curPetList[b] ~=nil then
                return false
            end

            if aa.PetID < bb.PetID then
                return true
            else
                return false
            end
        end)

end

local function InitListInfo()
	
    self.curSelectIndex = 1
    
    self.sp_tab:Initialize(self.cvs_pet_deatil.Width, self.cvs_pet_deatil.Height,#self.listId, 1, self.cvs_pet_deatil,
    	LuaUIBinding.HZScrollPanUpdateHandler(RefreshPetItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitPetItem))


    chekRedPoint()
end






































local function InitShowData()
    
    
    
    
    
    
    
    
    
    self.menu.Visible = false
    PetModel.getPetDataList(function(params)

        self.fightid = PetModel.getFightingPetId()
        self.menu.Visible = true
        InitPetData(params)
        
        InitListInfo()
        OnPetSelected()
        Util.InitMultiToggleButton(function (sender)
                SwitchPage(sender)
            end,self.tbt_train,{self.tbt_train,self.tbt_upgrade,self.tbt_associate,self.tbt_attribute})
        end)
end

local function OnEnter()
	InitShowData()
    self.petItemFilter = nil


	self.cvs_pet_deatil.Visible = false
    self.ib_peteffectsnew.Visible = false
    local function RefreshUI(EventName,Eventdata)
        local data = self.petConfigData[self.listId[self.curSelectIndex]]
        setPetInfo(data)
        RefreshState(self,data)
        self.sp_tab:RefreshShowCell()

        if self.petattribute ~= nil then
            self.petattribute:onExit()
            self.petattribute = PetAttribute.CreateAttUI(self.cvs_center,associateData)
        end
        self.lb_red_lvup.Visible = PetModel.checkCanUpLevel(data.PetID)
        self.lb_bj_train.Visible = PetModel.checkCanSummon(data.PetID)
        self.lb_bj_upgrade.Visible = PetModel.checkCanUpgrade(data.PetID)
        if self.upgrade ~= nil then
           self.upgrade:setPetInfo(data)
        end
    end
    
    EventManager.Subscribe("Event.UI.PetUIMain.Refresh", RefreshUI)
    self.SubscribeFunction = RefreshUI

    EventManager.Subscribe("Event.UI.PetUIMain.SwitchUpgrade", SwitchToUpgrade)

end

local function OnExit()
    EventManager.Unsubscribe("Event.UI.PetUIMain.Refresh", self.SubscribeFunction);
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.petItemFilter)
    self.petItemFilter = nil

    PetModelBase.ClearModel(self)
    if self.culture~= nil then
    	self.culture:onExit()
    	self.culture = nil
	end
	if self.upgrade ~= nil then
		self.upgrade:onExit()
		self.upgrade = nil
	end
    if self.attribute ~=nil then
        self.attribute:onExit()
        self.attribute = nil
    end
    if self.associates ~=nil then
        self.associates:onExit()
        self.associates = nil
    end

    associateData = nil

    self.m_Root:RemoveAllSubMenu()

    if self.itemFilter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.itemFilter)
    end

    EventManager.Unsubscribe("Event.UI.PetUIMain.SwitchUpgrade", SwitchToUpgrade)

end


local function setItemFilter(self, code)
    if self.itemFilter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.itemFilter)
    end
    self.itemFilter = ItemPack.FilterInfo.New()
    local filter = self.itemFilter
    filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
        return item.TemplateId == code    
    end
    filter.NofityCB = function(pack, type, index)
        if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
            RefreshState(self)
        end
    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end


local function InitUI()
    local UIName = {
        "btn_close",
		"tbt_train",
		"tbt_upgrade",
        "tbt_associate",
        "tbt_attribute",
		"sp_tab",

		"cvs_pet_deatil",
        "cvs_center",
        "cvs_middle",
        "lb_petname",
        "lb_petquality",
        "ib_havenot",
        "ib_comeout",
        "cvs_combatpower",
        "lb_combatpower",
        "cvs_rest_level",
        "btn_changename",
        "cvs_petmodel",
        "btn_gowar",
        "btn_rest",
        "cvs_pet_evolution",
        "cvs_pet_get",
        "btn_evolution",
        "ib_peteffectsnew",

        "ib_pet_get",
        "lb_get_name",
        "gg_get",
        "tb_get_num",
        
        "btn_getway",

        "lb_level",
        "lb_level_step",
        "gg_evolution",
        "tb_evolution_num",

        "lb_bj_train",
        "lb_bj_upgrade",
        "lb_red_lvup",
        "lb_red_call",
        "btn_call",
        "lb_tips_per",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end

    self.ib_peteffectsnew.Visible = false 
    self.btn_rest.TouchClick = function () 
        
        
        PetModel.petFightRequest(self.listId[self.curSelectIndex],0,function()
            
            self.fightid = 0
            RefreshState(self)
            self.sp_tab:RefreshShowCell()
        end)
    end

    self.btn_gowar.TouchClick = function () 
        
        
        PetModel.petFightRequest(self.listId[self.curSelectIndex],1,function()
            
            self.fightid = self.listId[self.curSelectIndex]
            RefreshState(self)
            self.sp_tab:RefreshShowCell()
        end)
    end

    self.btn_getway.TouchClick = function ()
        local data = self.petConfigData[self.listId[self.curSelectIndex]]
        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem = bag_data:MergerTemplateItem(data.PetItemCode)
        local num = (vItem and vItem.Num) or 0
        

        if num >= data.ItemCount then
            PetModel.summonPetRequest(self.listId[self.curSelectIndex],function(data)
                if data.s2c_fight == 1 then
                    self.fightid = self.listId[self.curSelectIndex]
                    RefreshState(self)
                    self.sp_tab:RefreshShowCell()
                end
                EventManager.Fire("Event.UI.PetUIMain.Refresh", { })
            end)
        else
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, data.PetItemCode)
            setItemFilter(self,data.PetItemCode)
        end
        
    end

     self.btn_call.TouchClick = function ()
        local data = self.petConfigData[self.listId[self.curSelectIndex]]
        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem = bag_data:MergerTemplateItem(data.PetItemCode)
        local num = (vItem and vItem.Num) or 0
        

        if num >= data.ItemCount then
            PetModel.summonPetRequest(self.listId[self.curSelectIndex],function(data)
                if data.s2c_fight == 1 then
                    self.fightid = self.listId[self.curSelectIndex]
                    RefreshState(self)
                    self.sp_tab:RefreshShowCell()
                end
                EventManager.Fire("Event.UI.PetUIMain.Refresh", { })
            end)
        else
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, data.PetItemCode)
            setItemFilter(self,data.PetItemCode)
        end
        
    end

    self.btn_changename.TouchClick = function() 
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetRename, 0)
        local  petData = self.petConfigData[self.listId[self.curSelectIndex]]
        local serverData = self.curPetList[petData.PetID]
        lua_obj.setNameInfo(serverData.name,function(newName)
            if newName ~= serverData.name then
                PetModel.changePetNameNewRequest(petData.PetID,newName,function()
                    print("newName " .. newName)
                    serverData.name = newName
                    self.lb_petname.Text = serverData.name
                    
                end)
            end
        end)
    end

    self.btn_evolution.TouchClick = function ()
        local  data = self.petConfigData[self.listId[self.curSelectIndex]]
        local serverData = self.curPetList[data.PetID]
        if serverData ~= nil then
            local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetEvolution,0)
            lua_obj:setPetInfo(data)
        end
    end



end

local function InitCompnent()
    InitUI()
    self.petConfigData = {}

    self.btn_close.TouchClick = function()
        OnClickClose()
        
    end

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)

end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/pet/main.gui.xml", GlobalHooks.UITAG.GameUIPetMain)
    
    self.menu = self.m_Root
    self.menu.ShowType = UIShowType.HideBackHud
    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}
