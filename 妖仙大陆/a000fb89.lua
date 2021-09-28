local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local intergalMallModel = require 'Zeus.Model.IntergalMall'
local ItemModel = require 'Zeus.Model.Item'
local ServerTime   = require 'Zeus.Logic.ServerTime'

local self = {}
local tData = {}
local tiplimitGoodsMax = ""
local Sliver = ""
local ShopCard = ""
local XianYuanNum = ""
local ZongShiBi = ""
local XianMengGX = ""

local function getMoneyDetail(id)
    return ItemModel.GetItemDetailByCode(self.tabInfo[id].Icon)
end 










local function changeMoney()
    self.ti_number.Text = self.buyCount
    local tab = self.tabdata[self.selectTabIndex]
    local itemdata = tab.items[self.selectItemIndex].itemdata 
    self.lb_deplete_num.Text = self.buyCount*itemdata.Price
end

local function selectItem(index)
    
    
	local tab = self.tabdata[self.selectTabIndex]
	local item = tab.items[index]
    
    local lastSelect = self.selectItemIndex
    if lastSelect ~= nil and lastSelect > 0 then
        local ib_choose = tab.items[lastSelect].node:FindChildByEditName("ib_choose",true)
        ib_choose.Visible = false
    end
    item.node:FindChildByEditName("ib_choose",true).Visible = true
	if index ~= self.selectItemIndex then
		self.selectItemIndex = index
		
	else
		
	end

    
    
    

    

	self.buyCount = 1
	changeMoney()

	local itemdata = item.itemdata 
	local detail = ItemModel.GetItemDetailByCode(itemdata.ItemCode)

	self.lb_name.Text = detail.static.Name 
	self.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)

	self.tb_explain.UnityRichText = detail.static.Desc
	self.lb_stack_max.Text = Util.GetText(TextConfig.Type.ITEM,'maxCount')..detail.static.GroupCount
	self.lb_use_level.Text = string.format(Util.GetText(TextConfig.Type.ITEM,'useLevel'),detail.static.LevelReq)

	if item.lastcount == 0 then
		self.cvs_tips1.Visible = true
    	self.cvs_tips2.Visible = false
    	self.btn_buy.Visible = false
	else
		self.cvs_tips1.Visible = false

		local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
	    if lv >= itemdata.ReqLvl then
	    	self.cvs_tips2.Visible = false
	    	self.btn_buy.Visible = true
	    else
	    	self.cvs_tips2.Visible = true
	    	self.btn_buy.Visible = false
	    end
	end

	if itemdata.isBind == 0 then
		self.lb_lock.Visible = false
	elseif itemdata.isBind == 1 then
		self.lb_lock.Visible = true
	elseif itemdata.isBind == 2  then
		self.lb_lock.Visible = false
	end
end

local function InitUI()
    local UIName = {
        "btn_close",
        "sp_list",
        "tb_single",
        "sp_content",
        "cvs_deatil",

        "ib_icon1",
        "tbx_reward",
        "ib_own_icon",
        "lb_own_num",

        "lb_name",
        "tb_explain",
        "lb_stack_max",
        "lb_use_level",
        "btn_less",
        "btn_plus",
        "btn_max",
        "ti_number",
        "ib_icon2",
        "lb_deplete_num",
        "btn_buy",

        "cvs_tips1",
        "tbx_tips1",

        "cvs_tips2",

        "cvs_own",
        "cvs_detail_ways",
        "lb_location",
        "tb_deatil",
        "lb_lock",

    }

    tiplimitGoodsMax = Util.GetText(TextConfig.Type.SHOP,"tiplimitGoodsMax")
    Sliver = Util.GetText(TextConfig.Type.SHOP, "Sliver")
    ShopCard = Util.GetText(TextConfig.Type.SHOP, "ShopCard")
    XianYuanNum = Util.GetText(TextConfig.Type.SHOP, "XianYuanNum")
    ZongShiBi = Util.GetText(TextConfig.Type.SHOP, "ZongShiBi")
    XianMengGX = Util.GetText(TextConfig.Type.SHOP, "XianMengGX")

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.tb_single.Visible = false
    self.cvs_deatil.Visible = false
    self.cvs_detail_ways.Visible = false
    self.lvText = self.cvs_deatil:FindChildByEditName("lb_tips",true).Text

    self.cvs_own.TouchClick = function(sender)
    	self.cvs_detail_ways.Visible = not self.cvs_detail_ways.Visible
    end

    self.cvs_detail_ways.TouchClick = function (sender)
    	self.cvs_detail_ways.Visible = false
    end

    self.btn_less.TouchClick = function(sender)
        if self.selectItemIndex>0 then
            self.buyCount = self.buyCount - 1
            if self.buyCount < 1 then
                self.buyCount = 1
            end
            changeMoney()
        end
    end

    self.btn_plus.TouchClick = function(sender)
        if self.selectItemIndex>0 then
        	local tab = self.tabdata[self.selectTabIndex]
			local item = tab.items[self.selectItemIndex]
            local playerMoney = self.tData.currencyNum == nil and 0 or self.tData.currencyNum
            local count = 999
            local maxCount = 999

            if item.lastcount >= 0 then
                count = item.lastcount
            else
                count = 999
            end
            local canCount = math.floor(playerMoney / item.itemdata.Price)
             maxCount = count > canCount and canCount or count

            if self.buyCount >= maxCount then
                self.buyCount = maxCount
                GameAlertManager.Instance:ShowNotify(tiplimitGoodsMax)
                return
            else
                 self.buyCount = self.buyCount + 1
            end
  
            changeMoney()
        end
    end

    
    
    
    self.btn_max.TouchClick = function(sender)
        if self.selectItemIndex>0 then
            local maxCount = 999
            local playerMoney = self.tData.currencyNum == nil and 0 or self.tData.currencyNum
            local tab = self.tabdata[self.selectTabIndex]
			local item = tab.items[self.selectItemIndex]
            local count = 0
            if item.lastcount >= 0 then
                count = item.lastcount
            else
                count = 999
            end
            local canCount = math.floor(playerMoney / item.itemdata.Price)
            maxCount = count > canCount and canCount or count
            
            self.buyCount = maxCount < 1 and 1 or maxCount
            changeMoney()
        end
    end

    self.ti_number.Enable = true
    self.ti_number.IsInteractive = true
    self.ti_number.event_PointerClick = function()
        local view,numInput = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINumberInput)
        local x = self.ti_number.X + self.ti_number.Parent.X + self.ti_number.Parent.Parent.X 
        local y = self.ti_number.Y + self.ti_number.Parent.Y + self.ti_number.Parent.Parent.Y 
        local pos = {X =x-180,Y = y -290}
        numInput:SetPos(pos)
        local function funcClickCallback(value)
            self.buyCount = value
            changeMoney()
        end
        local canCount = 999
        local tab = self.tabdata[self.selectTabIndex]
		local item = tab.items[self.selectItemIndex]

        if item.lastcount > 0 then
            canCount = item.lastcount
        end
        numInput:SetValue(1,canCount,self.buyCount,funcClickCallback)
    end

    self.btn_buy.TouchClick = function (sender)
     	local tab = self.tabdata[self.selectTabIndex]
		local item = tab.items[self.selectItemIndex]
    	intergalMallModel.requestBuyIntergalItem(tab.tabId,item.id,tonumber(self.ti_number.Text),function(itemnum,moneynum,totalCount)
    		local ShopItemNum = self.ti_number.Text
            item.lastcount = itemnum
    		local lb_lase_num = item.node:FindChildByEditName("lb_lase_num",true)
    		lb_lase_num.Text = itemnum
    		local index = self.selectItemIndex
    		tab.currencyNum = moneynum
    		self.lb_own_num.Text = moneynum
    		self.selectItemIndex = 0
    		selectItem(index)

            
            local counterStr = "IntegralShopBI"
            local valueStr = ""
            local kingdomStr = ""
            local detail = ItemModel.GetItemDetailByCode(item.itemdata.ItemCode)
            local phylumStr = detail.static.Name.."("..item.itemdata.ItemCode..")"..":"..ShopItemNum
            local classfieldStr = ""
            local familyStr = ""
            local genusStr = ""
            if tab.tabId == 1 then
                kingdomStr = "1"
                classfieldStr = Sliver
                familyStr = ShopItemNum * item.itemdata.Price
            elseif tab.tabId == 2 then
                kingdomStr = "2"
                classfieldStr = ShopCard
                familyStr = ShopItemNum * item.itemdata.Price
            elseif tab.tabId == 3 then
                kingdomStr = "3"
                classfieldStr = XianYuanNum
                familyStr = ShopItemNum * item.itemdata.Price
            elseif tab.tabId == 4 then   
                kingdomStr = "4"
                classfieldStr = ZongShiBi
                familyStr = ShopItemNum * item.itemdata.Price
            elseif tab.tabId == 5 then
                kingdomStr = "5"
                classfieldStr = XianMengGX
                familyStr = ShopItemNum * item.itemdata.Price
            end    
            Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)

            EventManager.Fire("Event.ShopMall.BuySuccess",{itemCode = item.itemdata.ItemCode,buyCount = tonumber(ShopItemNum),totalCount = totalCount})
    	end)
    end

    
    MenuBaseU.SetEnableUENode(self.tbx_tips1,true,false)
    self.tbx_tips1:DecodeAndUnderlineLink(self.tbx_tips1.Text)
    self.tbx_tips1.LinkClick = function (link_str)
        EventManager.Fire('Event.Goto', {id = "Card"})
    end
end

local function ToCountDownSecond(endTime)
    local passTime = math.floor(endTime/1000-ServerTime.GetServerUnixTime())
    return passTime
end



local function setSellItems(tabData)
	
    self.tData = tabData
	local data = self.tabInfo[tabData.tabId]
	local items = tabData.items
    
	self.lb_own_num.Text = tabData.currencyNum == nil and 0 or tabData.currencyNum

    local itemDetail = getMoneyDetail(tabData.tabId)
	Util.ShowItemShow(self.ib_own_icon,itemDetail.static.Icon,-1)
	

	Util.ShowItemShow(self.ib_icon2,itemDetail.static.Icon,-1)
	
	local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)

	local function updateItem(gx, gy, node)
		node.Visible = true
		local ib_props_icon = node:FindChildByEditName("ib_props_icon",false)
		local lb_props_name = node:FindChildByEditName("lb_props_name",false)
		local ib_icon = node:FindChildByEditName("ib_icon",false)
		local lb_icon_num = node:FindChildByEditName("lb_icon_num",false)
		local lb_props_shengyu = node:FindChildByEditName("lb_props_shengyu",false)
		local lb_lase_num = node:FindChildByEditName("lb_lase_num",false)
		local lb_lave_time = node:FindChildByEditName("lb_lave_time",false)
		local ib_discount = node:FindChildByEditName("ib_discount",false)
		local lb_tips = node:FindChildByEditName("lb_tips",false)
		local ib_choose = node:FindChildByEditName("ib_choose",false)

		if self.selectItemIndex == gy +1 then
			ib_choose.Visible = true
		else
			ib_choose.Visible = false
		end
		items[gy+1].node = node
        
		node.UserTag = gy+1
		local item = items[gy+1].itemdata 
		local detail = ItemModel.GetItemDetailByCode(item.ItemCode)
		Util.ShowItemShow(ib_props_icon,detail.static.Icon,detail.static.Qcolor)

		lb_props_name.Text = detail.static.Name
        lb_props_name.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)

        
        Util.ShowItemShow(ib_icon,itemDetail.static.Icon,-1)
        lb_icon_num.Text = item.Price

        if item.Price > tabData.currencyNum then
        	lb_icon_num.FontColor = Util.FontColorRed
        else
        	lb_icon_num.FontColor = Util.FontColorWhite
        end

        
        
        if items[gy+1].lastcount ~= -1 and lv >= item.ReqLvl then
			lb_props_shengyu.Visible = true
        	lb_lase_num.Visible = true
        	lb_lase_num.Text = items[gy+1].lastcount
        else
        	lb_props_shengyu.Visible = false
        	lb_lase_num.Visible = false
        end

        if lv >= item.ReqLvl then
        	lb_tips.Visible = false
        else
        	lb_tips.Visible = true
        	lb_tips.Text = item.ReqLvl .. self.lvText
        end

        if item.Series then
        	ib_discount.Visible = true
        	if item.Series == -1 then
	        	Util.HZSetImage(ib_discount,"#static_n/func/common2.xml|common2|159")
	        elseif item.Series == -2 then
	        	Util.HZSetImage(ib_discount,"#dynamic_n/land/land.xml|land|11")
	        else
	        	ib_discount.Visible = false
	        end
	    end

        if items[gy+1].countdown and items[gy+1].countdown >0 then
        	lb_lave_time.Text = GameUtil.GetTimeToString(ToCountDownSecond(items[gy+1].countdown))
        	lb_lave_time.Visible = true
        else
        	lb_lave_time.Visible = false
        end

        node.TouchClick = function(sender)
        	selectItem(gy+1)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('xuanqu')
        end

        local index = gy + 1
        if self.needSelect ~= nil then
            if(self.needSelect(index,node)) then
                self.needSelect = nil
            end
        end
	end

	local s = self.cvs_deatil.Size2D
    
    self.sp_content:Initialize(s.x,s.y,#items, 1, self.cvs_deatil, updateItem,function() end)
    self.selectItemIndex = 0

    if self.paramItemCode == nil then
	   selectItem(1)
       
    else
        local index = 1
        for i,v in ipairs(items) do
            if v.itemdata.ItemCode == self.paramItemCode then
                index = i
                self.paramItemCode = nil
                break
            end
        end
        
        
        
        
        local function setSelect(index,node)
            if index == self.selectItemIndex then
                selectItem(index)
                self.itemParam = nil
                self.selectItemIndex = 0
                return true
            end
            return false
        end

        if items[index].node then
            selectItem(index)
             
            self.itemParam = nil
        else
             self.sp_content.Scrollable.event_Scrolled = function(sender,pos)
                
                if items[index].node then
                     
                     
                    selectItem(index)
                    self.sp_content.Scrollable.event_Scrolled = function(sender,pos)

                    end
                end
            end
            self.selectItemIndex = index
            self.needSelect = setSelect
            self.sp_content.Scrollable:LookAt(Vector2.New(0,self.cvs_deatil.Height*(index-1)),true)    
        end
    end
end

local function UpdateCountDown(self)
    if not self.tabdata then
        return 
    end

	local tab = self.tabdata[self.selectTabIndex]
	local len = #tab.items
	
    for i=len,1,-1 do
        local item = tab.items[i]
        if item and item.countdown and item.countdown > 0 then
        	local countDownSecond = ToCountDownSecond(item.countdown)
	        if countDownSecond <= 0 then
	            table.remove(tab.items,i)
	        end
        end
        
    end

    
    if len > #tab.items then
        
        
        self.sp_content:RefreshShowCell()
    else
        
        Util.ForEachChild(self.sp_content.Scrollable.Container,function (node)
        	local item = tab.items[node.UserTag]
        	if item and item.countdown and item.countdown > 0 then
	            local lb_lave_time = node:FindChildByEditName('lb_lave_time',true)
	      
	            lb_lave_time.Text = GameUtil.GetTimeToString(ToCountDownSecond(item.countdown))
	            
        	end
        end)
    end


end

local function selectTab(index)
	
	self.selectTabIndex = index
	for i,v in ipairs(self.tabdata) do
		if i ~= index then
			v.node.IsChecked = false
        	v.node.Enable = true
        else
        	v.node.IsChecked = true
        	v.node.Enable = false
		end
	end
    
	setSellItems(self.tabdata[index])
    local itemDetail = getMoneyDetail(self.tabdata[index].tabId)
    
	self.tbx_reward.UnityRichText = Util.GetText(TextConfig.Type.SHOP,"buytip",itemDetail.static.Name)
	Util.ShowItemShow(self.ib_icon1,itemDetail.static.Icon,-1)
	

	self.lb_location.Text = itemDetail.static.Name
	self.tb_deatil.UnityRichText = self.tabInfo[self.tabdata[index].tabId].desc

end

local function setTabNode()
    local function updateItem(gx, gy, node)
    	node.Visible = true
        local data = self.tabInfo[self.tabdata[gy+1].tabId]
        self.tabdata[gy+1].node = node
        node.Text = data.btnText
        if gy+1 ~= self.selectTabIndex then
			node.IsChecked = false
        	node.Enable = true
        else
        	node.IsChecked = true
        	node.Enable = false
		end

        node.TouchClick = function (sender)
        	selectTab(gy+1)
        end
    end

    local s = self.tb_single.Size2D
    self.sp_list:Initialize(s.x,s.y,#self.tabdata, 1, self.tb_single, updateItem,function() end)
end

local function OnEnter()
    self.menu.Visible = false
	intergalMallModel.requestMallScoreItemList(function(data)
		
        
		self.tabdata = data

        for i=1,5 do
            local tab = self.tabdata[i]
            for k,v in ipairs(tab.items) do
                local itemdata = GlobalHooks.DB.Find(self.tabInfo[tab.tabId].controlName, v.id)
                v.itemdata = itemdata
            end
        end

		setTabNode()
		self.selectTabIndex = 0
        if self.params==nil or self.params=="" then
            self.paramItemCode = nil
            selectTab(1)
        else
            local par = string.split(self.params, '|')
            if par[2] ~= nil then
                self.paramItemCode = par[2]
            end

            local  num = 1
            for k,v in pairs(self.tabInfo) do
                if v.controlName == par[1] then
                    num = tonumber(k)
                    
                    
                end
            end
            selectTab(num)
        end

        self.menu.Visible = true
		local passTime = 0
		AddUpdateEvent("Event.UI.intergalMallUI.Update", function(deltatime)
	       passTime = passTime + deltatime
	       if passTime >= 1 then
	        
	           passTime = 0
	           UpdateCountDown(self)
	       end
	   end)
	end)
end

local function OnExit()
	RemoveUpdateEvent("Event.UI.intergalMallUI.Update", true)
end

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/shop/main.gui.xml',tag)
    InitUI()
    
    self.params = params
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnEnter(OnExit)
    

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
            self.menu:Close()
        end
    end

    self.tabInfo = {}
    local tabs = GlobalHooks.DB.Find("ShopLab", {})
    for i,v in ipairs(tabs) do
    	self.tabInfo[v.id] = v
        
        
    end
    

    return self.menu
end



local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
