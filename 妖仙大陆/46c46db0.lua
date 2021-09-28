


local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local EventItemDetail = require "Zeus.UI.XmasterBag.EventItemDetail"
local Bag = require "Zeus.UI.XmasterBag.UIBagMain"
local Player = require "Zeus.Model.Player"
local ItemComposeUI = require "Zeus.UI.XmasterBag.ItemComposeUI"
local _M = {
    selectPos = nil,selectSockGem = nil
}
_M.__index = _M
local PosCount = 10 
local self = {menu = nil,}

local string_item_name = "<color=#%s>%s</color>"
local format1 = '%s:%s'
local format2 = '%s:%s-%s'
local format3 = '<color=#00f012ff>+%s</color>'


local clickNew=false

local function GotoGemShop()
    local equipSockProp = GlobalHooks.DB.Find("EquipSock",self.selectPos)
    if equipSockProp == nil then
        return
    end
    local gemList = string.split(equipSockProp.GemTypeList,",")
    local gemCode = gemList[2]
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, gemCode)
end

local function GetEquipGridStrengthInfo(pos) 
    return ItemModel.GetEquipStrgData(pos)
end

local function GetJewelAttInfo(pos,index) 
    local gridInfo = GetEquipGridStrengthInfo(pos)
	local jewelAtts = gridInfo.jewelAtts or {}
	for i = 1 , #(jewelAtts) do
		if jewelAtts[i].index == index then
			return jewelAtts[i]
		end
	end
	return nil	
end

local function initEquipInlayInfo (self,node, index) 
	local lb_wenben = node:FindChildByEditName("lb_wenben", true)
	
	local gemNum = 0
	
	local gridInfo = GetEquipGridStrengthInfo(index)
	local jewelAtts = gridInfo.jewelAtts or {}
	for i = 1 , #(jewelAtts) do
		if jewelAtts[i].gem ~= nil then
			gemNum = gemNum + 1
		end
	end
	
	lb_wenben.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 118,gemNum,gridInfo.socks)
end

local function InitGemInlayInfoItem (self,node,jewelAttInfo) 
	local curValue = 0
	local gemItem = nil
	if jewelAttInfo ~= nil and jewelAttInfo.gem ~= nil then
		gemItem = ItemModel.GetItemStaticDataByCode(jewelAttInfo.gem.code)
	end
	
	local ib_down = node:FindChildByEditName("ib_down",false)
    local ib_up = node:FindChildByEditName("ib_up",false)
	
	local nodeItem = self.nodeItems[node]
	
	
	
end

local function InitGemInlayInfoTotal (self) 
	local jewelAttInfo = GetJewelAttInfo(self.selectPos,self.selectGemIndex)
    for k, v in pairs(self.jewelNodes) do
		if v then
			InitGemInlayInfoItem(self,v,jewelAttInfo)
		end
	end
end

local function SendBi(index)
    local counterStr ="InlayCultivate"
    local valueStr =""
    local kingdomStr = Util.GetText(TextConfig.Type.ATTRIBUTE, 134) .. Util.GetText(TextConfig.Type.ITEM, 'equipPos' .. index)
    local phylumStr =""
    local classfieldStr = ""

    local familyStr = Util.GetText(TextConfig.Type.ATTRIBUTE, 135) 
    local gridInfo = GetEquipGridStrengthInfo(self.selectPos)
    if(gridInfo) then
        local jewelAtts = gridInfo.jewelAtts or {}
        for i = 1 , #(jewelAtts) do
            if jewelAtts[i].gem ~= nil then
                familyStr = familyStr .. string.format("%s(%s):1,",jewelAtts[i].gem.name,jewelAtts[i].gem.code)
            end
        end
        local genusStr =""
        Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)
    end
end

local function updateRedPoint(node,index)
    local ib_ricon = node:FindChildByEditName("ib_ricon", false) 
    
    local gemNum = 0
    local minGem = 10 
    local static_data = nil 

    index = tonumber(node.UserTag)
    local gridInfo = GetEquipGridStrengthInfo(index)
    local jewelAtts = gridInfo.jewelAtts or {}
    for i = 1 , #(jewelAtts) do
        if jewelAtts[i].gem ~= nil then
            gemNum = gemNum + 1
            static_data = ItemModel.GetItemStaticDataByCode(jewelAtts[i].gem.code) 
            if static_data.LevelReq < minGem then
                minGem = static_data.LevelReq
            end
        end
    end
    
    local equipSockProp = GlobalHooks.DB.Find("EquipSock",index)

    local jewelItemPack = DataMgr.Instance.UserData.RoleBag
    local filter_jewel = ItemPack.FilterInfo.New()
    filter_jewel.IsSequence = true
    filter_jewel.Type = ItemData.TYPE_BIJOU
    filter_jewel.CheckHandle = function(item)
        if string.find(equipSockProp.GemTypeList, item.detail.static.Code) ~= nil then
            return true
        else
            return false
        end
    end
    jewelItemPack:AddFilter(filter_jewel) 
    local count = filter_jewel.ShowData.Count
    

    if gemNum < gridInfo.socks then 
        ib_ricon.Visible = (count > 0)
    else
        local haveHigh = false 
        for i = 1,count do 
           local itemData = filter_jewel:GetItemDataAt(i) 
           if itemData.detail.static.LevelReq > minGem then
                haveHigh = true
                break
           end
        end
        ib_ricon.Visible = haveHigh
    end

    jewelItemPack:RemoveFilter(filter_jewel)
end

local function updateRedPointAll()
    if self.nodes ~= nil then 
        for i = 1,#self.nodes do
            updateRedPoint(self.nodes[i],i)
        end
    end
end

local ui_names = {
    {name = "sp_position_list"},
    {name = "cvs_gem1"},
    {name = "cvs_gem2"},
    {name = "cvs_gem3"},
    {name = "cvs_gem4"},
    {name = "cvs_gem5"},
    {name = "cvs_equip_brief"},
    {name = "cvs_jewel_brief"},
    {name = "lb_pro_altogether"},
    {name = "sp_gem_list"},
    {name = "btn_compose1",click = function(self)
        local equipSockProp = GlobalHooks.DB.Find("EquipSock",self.selectPos)
        if equipSockProp then
            local codeString = equipSockProp.GemTypeList
            local codes = string.split(codeString,",")
            local composeProp = ItemComposeUI.getPropByCodes(codes)
            if composeProp then
                local param = composeProp.ID.."-"..composeProp.ParentID.."-"..composeProp.TagetCode
                local openBagParam = Bag.CreateTbtParam(0,GlobalHooks.UITAG.GameUICombine,param)
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain,0,openBagParam)
            end
        end
    end},
    {name = "btn_shop",click = function()
        local param = "mall|diamond_109"
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop,0,param)
    end},
    {name = "lb_tips"}
}

function _M:SetVisible(visible)
    self.menu.Visible = visible
end


local function SetJewelPosSelected(self,gemIndex)
	self.selectGemIndex = gemIndex
    
	for i = 1,5 do
        local node = self["cvs_gem"..i]
		local ib_click = node:FindChildByEditName("ib_click",false)
		ib_click.Visible = (i == self.selectGemIndex)
    end 
end

local function setJewelTotalAttr(self)
	local attrId = nil
	local attrValue = 0
	
	local gridInfo = GetEquipGridStrengthInfo(self.selectPos)
	local jewelAtts = gridInfo.jewelAtts or {}
	for i = 1 , #(jewelAtts) do
		if jewelAtts[i].gem ~= nil then
			attrId = jewelAtts[i].id
			attrValue = attrValue + jewelAtts[i].value
		end
		
	end
	
	if attrId == nil then
		self.lb_pro_altogether.Text = ""
		return 
	end
	
	local attrdata = GlobalHooks.DB.Find('Attribute', attrId)
	if attrdata ~= nil  then
		local v = Mathf.Round((attrdata.isFormat == 1 and attrValue / 100) or attrValue)
		self.lb_pro_altogether.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 117,string.gsub(attrdata.attDesc,'{A}',tostring(v)))
	end
		
end




local function setJewelPosValue(self,node,index,equipSockProp)
    local btn_get = node:FindChildByEditName("btn_get",false)
	local ib_click = node:FindChildByEditName("ib_click",false)
    local lb_gem_lv = node:FindChildByEditName("lb_gem_lv",false)
    local lb_gem_pro = node:FindChildByEditName("lb_gem_pro",false)
    local ib_gem = node:FindChildByEditName("ib_gem",false)
	local cvs_icon = node:FindChildByEditName("cvs_icon",false)
	local btn_unfill = node:FindChildByEditName("btn_unfill",false)
	local lb_sock_needlv = node:FindChildByEditName("lb_sock_needlv",true)
	local gridInfo = GetEquipGridStrengthInfo(self.selectPos)
	local unLockNum = gridInfo.socks
    
	

    local roleLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    
    if index >  unLockNum then 
        lb_gem_lv.Text = ""
        lb_gem_pro.Text = ""
        btn_get.Visible = false
        ib_gem.Visible = true
		cvs_icon.Visible = false
		btn_unfill.Visible = false
        local lv = equipSockProp["Sock"..index.."OpenLvl"]
        lb_sock_needlv.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 120,lv)
    else
        lb_sock_needlv.Text = ""
        
		local JewelAttInfo = GetJewelAttInfo(equipSockProp.TypeID,index)

        if JewelAttInfo ~= nil and JewelAttInfo.gem ~= nil and JewelAttInfo.gem.code ~= "" then
            btn_get.Visible = true
			ib_gem.Visible = false
			
            
            if not cvs_icon.Visible and not clickNew then
                local tempNode=self["cvs_gem"..index]:FindChildByEditName("cvs_icon"..index,false)
                Util.showUIEffect(tempNode,2)
                clickNew=true
            end
            
			cvs_icon.Visible = true
			btn_unfill.Visible = false
            Util.HZSetImage(cvs_icon,"static_n/item/" .. JewelAttInfo.gem.icon .. ".png", false, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            

			
			
			btn_get.event_PointerClick = function ()
				
				
				
				ItemModel.UnFillGem(equipSockProp.TypeID,index,function ()	
					ClickItemshow(self,nil,self.selectPos)
					
					SetJewelPosSelected(self,index)
					
					initEquipInlayInfo(self,self.nodes[self.selectPos],self.selectPos) 

                    updateRedPointAll() 
				end)	
			end	
			
			local static_data = ItemModel.GetItemStaticDataByCode(JewelAttInfo.gem.code) 
			lb_gem_lv.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 119,static_data.LevelReq)
			lb_gem_lv.Visible = true
			
			
			local attrdata = GlobalHooks.DB.Find('Attribute', JewelAttInfo.id)
			if attrdata ~= nil then
				local v =(attrdata.isFormat == 1 and JewelAttInfo.value / 100) or JewelAttInfo.value	
				lb_gem_pro.Text = string.gsub(attrdata.attDesc,'{A}',tostring(v))
			end
			lb_gem_pro.Visible = true

            
		else
            btn_get.Visible = false
            ib_gem.Visible = false
			cvs_icon.Visible = false
			btn_unfill.Visible = true
			lb_gem_lv.Text = ""
			lb_gem_pro.Text = ""
            btn_unfill.event_PointerClick = function()
                
                local count = self.JewelContainer.Filter.ItemCount
                if count > 0 then
                    local itemData = self.filter_jewel:GetItemDataAt(1)
                    if itemData == nil then
                        return
                    end

                    ItemModel.FillGem(self.selectPos,self.selectGemIndex,itemData.Index,function (inlayIndex) 
		                ClickItemshow(self,nil,self.selectPos) 
		                initEquipInlayInfo(self,self.nodes[self.selectPos],self.selectPos)

                        updateRedPointAll() 

                        Util.showUIEffect(self["cvs_gem"..inlayIndex]:FindChildByEditName("cvs_icon"..inlayIndex,false),2)

                        
                        SendBi(self.selectPos)
                    end)
                else
                    GotoGemShop()
                end
            end








        end
    end
end



local function setJewelPos(self,equipSockProp,itemData)
	
	local gridInfo = GetEquipGridStrengthInfo(self.selectPos)
	local index = 1
	local jewelAtts = gridInfo.jewelAtts or {}
	
	local defIndexMap = {} 
	for i = 1 ,gridInfo.socks do
		table.insert(defIndexMap,i)
	end
	
	for i = 1,#(jewelAtts) do
		table.remove(defIndexMap,jewelAtts[i].index)
	end
	if #defIndexMap > 0 then
		index = defIndexMap[1]
	end
	
	for i = 1,5 do
        local node = self["cvs_gem"..i]
        if i <= equipSockProp.SockNum then
            node.Visible = true
            setJewelPosValue(self,node,i,equipSockProp)
            
        else
            node.Visible = false
        end
    end 
	
	SetJewelPosSelected(self,index)
end

function ClickItemshow(self,roleEquip, index,itemData)
    
     local equipSockProp = GlobalHooks.DB.Find("EquipSock",self.selectPos)
     self.selectSockGem = string.split(equipSockProp.GemTypeList,",")
     self.filter_jewel = ItemPack.FilterInfo.New()
     self.filter_jewel.IsSequence = true
     self.filter_jewel.Type = ItemData.TYPE_BIJOU
     self.filter_jewel.CheckHandle = function(item)
        for i = 1,#self.selectSockGem,1 do
            if self.selectSockGem[i] == item.detail.static.Code then
                return true
            end
        end  
        return false
     end
    self.filter_jewel.CompareHandle = function(it1, it2)
        local d1 = it1.detail
        local d2 = it2.detail
        if d1.static.Par == d2.static.Par then
            
            if d1.static.Price > d2.static.Price then
                return -1
            elseif d1.static.Price == d2.static.Price then
                return 0
            else
                return 1
            end
        else
            return d1.static.Par < d2.static.Par and -1 or 1
        end
    end


     self.JewelContainer.Filter = self.filter_jewel
     local count = self.JewelContainer.Filter.ItemCount
     self.sp_gem_list.Scrollable:Reset(1,count)
     self.lb_tips.Visible = count == 0
	
    setJewelPos(self,equipSockProp,itemData)
	
	
	setJewelTotalAttr(self,equipSockProp)
end

local function ClickJewelInlay(self, node, itemData,index)
    self.rightGemSelectPos = index
    local ib_click = node:FindChildByEditName("ib_click", false)
    if ib_click.Visible == false then
        for k, v in pairs(self.jewelNodes) do
            if v then
                local ib_click = v:FindChildByEditName("ib_click", false)
                ib_click.Visible = false
            end
        end
        ib_click.Visible = true
    end
    
	ItemModel.FillGem(self.selectPos,self.selectGemIndex,itemData.Index,function (inlayIndex) 
        ClickItemshow(self,nil,self.selectPos) 
		initEquipInlayInfo(self,self.nodes[self.selectPos],self.selectPos)

        updateRedPointAll() 

        
        SendBi(self.selectPos)
    end)
end

local function getItemData(self,pos)
    local showdata = self.filter_target.ShowData
    for i=1,showdata.Count do
        local itemData = self.filter_target:GetItemDataAt(i)
        if(itemData.SecondType == pos) then
            return itemData
        end
    end
    return false
end

local function nodeClick(self, node, index,itemData)
    self.selectPos = index
    ClickItemshow(self, nil, index,itemData)
    for k, v in pairs(self.nodes) do
        if v then
            local ib_click = v:FindChildByEditName("ib_click", true)
            ib_click.Visible = false
        end
    end
    local ib_click = node:FindChildByEditName("ib_click", true)
    ib_click.Visible = true
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
    clickNew = true
end

local function initEquipNodeValue(self,node, index)
    local ctrlIcon = node:FindChildByEditName("cvs_equipicon", true)
    local itemData = getItemData(self,index)
    local lb_equipname = node:FindChildByEditName("lb_equipname", true)
    
    local ib_click = node:FindChildByEditName("ib_click", true)
    if(index == self.selectPos) then
        ib_click.Visible = true
        clickNew = true
    else
        ib_click.Visible = false
        clickNew = false
    end
    if self.itemShows[node] == nil then
        self.itemShows[node] = Util.ShowItemShow(ctrlIcon, "", 1)
    end
    
    if itemData ~= nil and type(itemData) ~= "boolean" then
        self.itemShows[node]:SetItemData(itemData)
    end

    local c = Util.GetQualityColorRGBAStr(0)
    if (itemData) then
        c = Util.GetQualityColorRGBAStr(itemData.detail.static.Qcolor)
        

    else
        c = Util.GetQualityColorRGBAStr(0)
        
        if self.itemShows[node] then
            self.itemShows[node]:SetItemData(nil)
        end
    end
	lb_equipname.Text = string.format(string_item_name, c, Util.GetText(TextConfig.Type.ITEM, 'equipPos' .. index))
	
	initEquipInlayInfo(self,node, index)
	
    node.Enable = true
    node.event_PointerClick = function()
        nodeClick(self,node,index,itemData)
    end
    local ditu = GlobalHooks.DB.Find('EquipdituConfig',index)
    Util.HZSetImage(ctrlIcon, ditu.SmallIcon)

    node.UserTag = index
    updateRedPointAll()
    
end

local function initJewelNodeValue(self,node, index)
    node.Name = "inlayCell_"..index
    local itemData = self.filter_jewel:GetItemDataAt(index)
    if itemData then
        local ctrlIcon = node:FindChildByEditName("cvs_equipicon0",false)
        if self.nodeItems[node] == nil then
            self.nodeItems[node] = Util.ShowItemShow(ctrlIcon, itemData.detail.static.Icon, itemData.detail.static.Qcolor)
        end
        self.nodeItems[node]:SetItemData(itemData)
        local lb_equipname = node:FindChildByEditName("lb_equipname",false)
        local lb_wenben = node:FindChildByEditName("lb_wenben",false)
        local lb_score = node:FindChildByEditName("lb_score",false)
        local ib_down = node:FindChildByEditName("ib_down",false)
        local ib_up = node:FindChildByEditName("ib_up",false)
        local ib_click = node:FindChildByEditName("ib_click",true)
        ib_click.Visible = (self.rightGemSelectPos == index)
        local btn_equip = node:FindChildByEditName("btn_equip",false)
        btn_equip.Text = Util.GetText(TextConfig.Type.ITEM,'inset')
        local btn_getoff = node:FindChildByEditName("btn_getoff",false)
        local btn_compose = node:FindChildByEditName("btn_compose",false)
        local detail = itemData.detail
        lb_equipname.Text = detail.static.Name
        lb_wenben.Text = detail.static.Prop
        if(detail.static.Min >= 0) then
            lb_score.Text = "+"..detail.static.Min
        else
            lb_score.Text = "-"..detail.static.Min
        end
















        btn_getoff.Visible = false
        btn_compose.Visible = false
        btn_equip.event_PointerClick = function()
            
            ClickJewelInlay(self,node,itemData,index)
            clickNew=false
        end
        self.eventItemDetail:SetItem(itemData)
        self.eventItemDetail:bindBtnEvent(btn_equip,"Event.JewelryInlay")
        node.Enable = true
        node.event_PointerClick = function()
            for k,v in pairs(self.jewelNodes) do
                if v then
                    local ib = v:FindChildByEditName("ib_click",true)
                    ib.Visible = false
                end
            end
            ib_click.Visible = true
            self.rightGemSelectPos = index
        end
    else
        node.Enable = false
    end
end

local function initJewelPosValue(self)
    for i = 1,5 do
        local cvs = self["cvs_gem"..i]
        local btn_get = cvs:FindChildByEditName("btn_get",false)
        local lb_gem_lv = cvs:FindChildByEditName("lb_gem_lv",false)
        local lb_gem_pro = cvs:FindChildByEditName("lb_gem_pro",false)
        btn_get.Visible = false
        lb_gem_lv.Visible = false
        lb_gem_pro.Visible = false
    end
end

function _M.Notify(status, userdata, self)

end

local function onBuySuccess(evtName, param)
    self.filter_jewel = ItemPack.FilterInfo.New()
    self.filter_jewel.IsSequence = true
    self.filter_jewel.Type = ItemData.TYPE_BIJOU
    self.filter_jewel.CheckHandle = function(item)
        for i = 1, #self.selectSockGem, 1 do
            if self.selectSockGem[i] == item.detail.static.Code then
                return true
            end
        end
        return false
    end
    self.filter_jewel.CompareHandle = function(it1, it2)
        local d1 = it1.detail
        local d2 = it2.detail
        if d1.static.Par == d2.static.Par then
            
            if d1.static.Price > d2.static.Price then
                return -1
            elseif d1.static.Price == d2.static.Price then
                return 0
            else
                return 1
            end
        else
            return d1.static.Par < d2.static.Par and -1 or 1
        end
    end
    self.JewelContainer.Filter = self.filter_jewel
    local count = self.JewelContainer.Filter.ItemCount
    self.sp_gem_list.Scrollable:Reset(1, count)
    self.lb_tips.Visible = count == 0

    updateRedPointAll()
end

local function onComposeSuccess() 
    onBuySuccess(nil,nil)
end

function _M:OnEnter()
    self.EquipContainer.ItemPack = DataMgr.Instance.UserData.RoleEquipBag
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
    self.selectPos = 1
    local count = PosCount
    self.sp_position_list.Scrollable:Reset(1,count)
    local itemData = getItemData(self,self.selectPos)
    ClickItemshow(self,nil,self.selectPos)
    local node = self.nodes[self.selectPos]
    if node then
        for k, v in pairs(self.nodes) do
            if v then
                local ib_click = v:FindChildByEditName("ib_click", true)
                ib_click.Visible = false
            end
        end
        local ib_click = node:FindChildByEditName("ib_click", true)
        ib_click.Visible = true
        clickNew = true 
    end

    GlobalHooks.Drama.Start("guide_inlay", true)
    EventManager.Subscribe("Event.ShopMall.BuySuccess",onBuySuccess)
    EventManager.Subscribe("Event.ItemCompose.ComposeSuccess",onComposeSuccess)
end

function _M:OnExit()
    self.menu.Visible = false
end

function _M:OnDispose()
    self.itemShows = nil
end

local function InitComponent(self,tag)
    
    self.menu = LuaMenuU.Create("xmds_ui/character/inlay.gui.xml",tag)
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.EquipContainer = HZItemsContainer.New()
    self.EquipContainer.CellSize = self.cvs_equip_brief.Size2D
    self.EquipContainer.IsShowLockUnlock = false
    self.EquipContainer.IsShowStrengthenLv = true
    self.filter_target = ItemPack.FilterInfo.New()
    self.filter_target.IsSequence = true
    self.filter_target.Type = ItemData.TYPE_EQUIP
    self.filter_target.CheckHandle = function(item)
        return true
    end
    self.EquipContainer.Filter = self.filter_target
    self.cvs_equip_brief.Visible = false
    self.cvs_jewel_brief.Visible = false
    self.nodes = {}
    self.itemShows = {}
    self.sp_position_list:Initialize(self.cvs_equip_brief.Width, self.cvs_equip_brief.Height, 0, 1, self.cvs_equip_brief,
    function(gx, gy, node)
        initEquipNodeValue(self, node, gy + 1)
        self.nodes[gy + 1] = node
    end ,
    function(cell)
        cell.Visible = true
    end
    )
    initJewelPosValue(self)
    self.JewelContainer = HZItemsContainer.New()
    self.JewelContainer.CellSize = self.cvs_jewel_brief.Size2D
    self.JewelContainer.IsShowLockUnlock = false
    self.JewelContainer.IsShowStrengthenLv = true
    local rolebag = DataMgr.Instance.UserData.RoleBag
    self.JewelContainer.ItemPack = rolebag
    self.jewel_click = function(roleEquip, it,isData)
        local itemData = nil
        if(isData == nil) then
            itemData = it.LastItemData
        else
            itemData = it
        end
        ClickJewelshow(self, roleEquip, itemData)
    end
    self.jewelNodes = {}
    self.nodeItems = {}
    self.sp_gem_list:Initialize(self.cvs_jewel_brief.Width, self.cvs_jewel_brief.Height, 0, 1, self.cvs_jewel_brief,
    function(gx, gy, node)
        initJewelNodeValue(self, node, gy + 1)
        self.jewelNodes[gy + 1] = node
    end ,
    function(cell)
        cell.Visible = true
    end
    )
    
    
end

function _M.Create(tag,parent)
    self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    self.parent = parent
    self.parent.cvs_content:AddChild(self.menu)
    self.eventItemDetail = EventItemDetail.Create(3)
    local function callback(sender, name, item)
        if(name == "Event.EquipItem") then
            self:refreshEquipList(item)
        end
    end
    self.eventItemDetail:SubscribCallBack(callback)
    return self
end

return _M

