local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local RedPacketModel = require 'Zeus.Model.RedPacket'
local self = {}

local function GetMinData(dataList)
	if #dataList < 2 then
		return 1
	end
	local index = 1
	for i=2,#dataList do
		if dataList[index].fetcherValue > dataList[i].fetcherValue then
			index = i
		end
	end
	return index
end

local function GetMaxData( dataList )
	if #dataList < 2 then
		return 1
	end
	local index = 1
	for i=2,#dataList do
		if dataList[index].fetcherValue < dataList[i].fetcherValue then
			index = i
		end
	end
	return index
end

local function IsInDataList(dataList,id)
	if #dataList > 0 then
		for i=1,#dataList do
			if dataList[i].fetcherId == id then
				return true
			end
		end
	end
	return false
end

local function updateItemCell(data, node)
	if data == nil then
		node.Visible = false
		return
    else
        node.Visible = true
	end
	local getCount = 0
	if data.fetcherList ~= nil then
		getCount = #data.fetcherList
	end
	local fetcherList = data.fetcherList

	local isGetRedPacket = false

	if fetcherList ~= nil  then
		for i=1,#fetcherList do
			if fetcherList[i].fetcherId == DataMgr.Instance.UserData.RoleID then
				isGetRedPacket = true
			end
		end
	end
	local cvs_putong = node:FindChildByEditName("cvs_putong",true)
	local cvs_kouling = node:FindChildByEditName("cvs_kouling",true)
	local cvs_signed = node:FindChildByEditName("cvs_signed",true)
	local cvs_temp = cvs_putong

	if getCount < data.count then
		if not isGetRedPacket then
			if data.fetchType == 0 then
    			cvs_temp = cvs_kouling
    			cvs_kouling.Visible = true
    			cvs_putong.Visible = false
    			cvs_signed.Visible = false
    		else
    			cvs_temp = cvs_putong
    			cvs_kouling.Visible = false
    			cvs_putong.Visible = true
    			cvs_signed.Visible = false
    		end
    	else
    		cvs_temp = cvs_signed
    		cvs_kouling.Visible = false
    		cvs_putong.Visible = false
    		cvs_signed.Visible = true
    	end
    else
    	cvs_temp = cvs_signed
    	cvs_kouling.Visible = false
    	cvs_putong.Visible = false
    	cvs_signed.Visible = true
    	local lb_over = cvs_temp:FindChildByEditName("lb_over",true)
    	lb_over.Visible = true
    end

    local lb_name = cvs_temp:FindChildByEditName("lb_name",true)
    lb_name.Text = data.providerName
    local tbx_word = cvs_temp:FindChildByEditName("tbx_word",true)
    tbx_word.UnityRichText = data.message

    local btn_get = cvs_temp:FindChildByEditName("btn_get",true)

    local layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|172", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
    if data.benifitType == 0 then
    	layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|173", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
    end

    local tempData = {}

    if isGetRedPacket or getCount >= data.count then
    	btn_get.TouchClick = function()
    		local lb_name2 = self.cvs_xiangqing:FindChildByEditName("lb_name2",true)
    		local lb_word2 = self.cvs_xiangqing:FindChildByEditName("lb_word2",true)
    		local lb_money = self.cvs_xiangqing:FindChildByEditName("lb_money",true)
    		local lb_count = self.cvs_xiangqing:FindChildByEditName("lb_count",true)
    		local lb_redTitle = self.cvs_xiangqing:FindChildByEditName("lb_redTitle",true)
    		local cvs_shouqi = self.cvs_xiangqing:FindChildByEditName("cvs_shouqi",true)
    		local cvs_tuofei = self.cvs_xiangqing:FindChildByEditName("cvs_tuofei",true)
    		local cvs_moreplayer = self.cvs_xiangqing:FindChildByEditName("cvs_moreplayer",true)
    		local sp_list2 = self.cvs_xiangqing:FindChildByEditName("sp_list2",true)

    		local redkouling = Util.GetText(TextConfig.Type.CHAT, "redkouling")
			local redjiyu = Util.GetText(TextConfig.Type.CHAT, "redjiyu")

    		lb_name2.Text = data.providerName
    		lb_word2.Text = data.message
    		lb_money.Text = data.totalNum..Util.GetText(TextConfig.Type.SHOP, "Diamond")
    		lb_count.Text = #data.fetcherList.."/"..data.count
    		lb_redTitle.Text = data.fetchType == 0 and redkouling or redjiyu

    		if getCount < data.count then
    			cvs_shouqi.Visible = false
    			cvs_tuofei.Visible = false
    			if #fetcherList > 0 then
    				for i=1,#fetcherList do
    					if not IsInDataList(tempData,fetcherList[i].fetcherId) then
    						table.insert(tempData,fetcherList[i])
    					end
    				end
    			end
    		else
    			cvs_shouqi.Visible = true
    			cvs_tuofei.Visible = true
    			local lb_name3 = cvs_shouqi:FindChildByEditName("lb_name",true)
    			local lb_money3 = cvs_shouqi:FindChildByEditName("lb_money",true)
    			local lb_name4 = cvs_tuofei:FindChildByEditName("lb_name",true)
    			local lb_money4 = cvs_tuofei:FindChildByEditName("lb_money",true)

    			local maxIndex = GetMaxData(fetcherList)
    			local minIndex = GetMinData(fetcherList)
    			local MaxData = fetcherList[maxIndex]
    			if MaxData ~= nil then
    				lb_name3.Text = MaxData.fetcherName
    				lb_money3.Text = MaxData.fetcherValue
    				lb_money3.Layout = layout
    			end
    			local MinData = fetcherList[minIndex]
    			if MinData ~= nil then
    				lb_name4.Text = MinData.fetcherName
    				lb_money4.Text = MinData.fetcherValue
    				lb_money4.Layout = layout 
    			end

    			for i=1,#fetcherList do
    				if fetcherList[i].fetcherId ~= MaxData.fetcherId and fetcherList[i].fetcherId ~= MinData.fetcherId then
    					if not IsInDataList(tempData,fetcherList[i].fetcherId) then
    						table.insert(tempData,fetcherList[i])
    					end
    				end
    			end

    		end
    		if tempData ~= nil and #tempData > 0 then
    			sp_list2.Visible = true
    			sp_list2:Initialize(cvs_moreplayer.Width, cvs_moreplayer.Height+15, #tempData,1, cvs_moreplayer, 
    			function(x, y, cell)
    				local index = y + 1
    				local dataInfo = tempData[index]
    				local lb_name = cell:FindChildByEditName("lb_name",true)
    				local lb_money = cell:FindChildByEditName("lb_money",true)
    				lb_name.Text = dataInfo.fetcherName
    				lb_money.Text = dataInfo.fetcherValue
    				lb_money.Layout = layout 
    				cell.Visible = true
    			end,
    			function()
    				
    			end
    			)
 			else
 				sp_list2.Visible = false
    		end
    		self.cvs_xiangqing.Visible = true
    	end
    else
    	btn_get.TouchClick = function()
    		RedPacketModel.fetchRedPacketRequest(data.id,function ( params)
    			if params.s2c_code == 200 then
                    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRedPacketGet, 0)
                    obj:setData(params.value,data.benifitType)
    			end
    		end)
    	end
    end
end

local function CreateTemplate(dataList)
    local count = #dataList
	local row = math.ceil(count/4)
    local column = 4
    self.curRedList = dataList

    self.sp_list.Scrollable:ClearGrid()
    self.sp_list.Scrollable:Reset(column,row)
    self.sp_list.Scrollable:LookAt(Vector2.New(0,1),true)
end

local function SortData(dataList)
	table.sort(dataList,function(a,b)
		return a.dispatchTimestamp > b.dispatchTimestamp
	end)
end

local function SwitchPage(sender)
	if sender == self.tbt_shijie then
        self.chanType = 0
		if #self.worldList > 1 then
			SortData(self.worldList)
		end
		CreateTemplate(self.worldList)
	elseif sender == self.tbt_xianmeng then
        self.chanType = 1
		if not DataMgr.Instance.UserData.Guild then
			GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "noGuildTips"))
            return
		end
		if#self.guildList > 1 then
			SortData(self.guildList)
		end
		CreateTemplate(self.guildList)
	end
	self.selectBtn = sender
end

local function IsInList(dataList,id)
	for k,v in pairs(dataList) do
		if v.id == id then
			return k
		end
	end
	return false
end

local function OnUpdateRedPacket( eventname,params )
	if params.redPacketInfo ~= nil then
		if params.redPacketInfo.channelType == 0 then
			local value = IsInList(self.worldList,params.redPacketInfo.id)
			if value then
				table.remove(self.worldList,value)
				table.insert(self.worldList,value,params.redPacketInfo)
			else
				table.insert(self.worldList,1,params.redPacketInfo)
			end
			CreateTemplate(self.worldList)
		else
			local value = IsInList(self.guildList,params.redPacketInfo.id)
			if value then
				table.remove(self.guildList,value)
				table.insert(self.guildList,value,params.redPacketInfo)
			else
				table.insert(self.guildList,1,params.redPacketInfo)
			end
			CreateTemplate(self.guildList)
		end
	else
		for k,v in pairs(self.worldList) do
			if v.id == params.id then
				table.remove(self.worldList,k)
                CreateTemplate(self.worldList)
                return
			end
		end
		for m,n in pairs(self.guildList) do
			if n.id == params.id then
				table.remove(self.guildList,m)
                CreateTemplate(self.guildList)
                return
			end
		end
	end 
end

local function OnEnter()
	self.worldList = {}
	self.guildList = {}
    RedPacketModel.getRedPacketListRequest(function(data)
    	local dataSource = data.redPacketInfo or {}
		for k,v in pairs(dataSource) do
			if v.channelType == 0 then
				table.insert(self.worldList, v)
			else
				table.insert(self.guildList, v)
			end
		end
        self.tbt_shijie.IsChecked = true
	end)
    local redType = 0
    self.btn_kouling.TouchClick = function ()
        redType = 0
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRedPacketSend, 0)
        obj:setData(redType,self.chanType)
    end

    self.btn_putong.TouchClick = function ()
        redType = 1
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRedPacketSend, 0)
        obj:setData(redType,self.chanType)
    end
	EventManager.Subscribe('Event.redPacketHandler.onRedPacketDispatchPush',OnUpdateRedPacket)
end

local function OnExit()
	EventManager.Unsubscribe('Event.redPacketHandler.onRedPacketDispatchPush',OnUpdateRedPacket)
end

local function InitUI()
    local UIName = {
        "sp_list",
        "cvs_detail",
        "btn_close",
        "btn_kouling",
        "btn_putong",
        "tbt_xianmeng",
        "tbt_shijie",
        "cvs_xiangqing",
        "btn_close2",
    }
    for i=1,#UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    
    self.cvs_detail.Visible = false

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
            self.menu:Close()
        end
    end

    self.btn_close2.TouchClick = function()
        self.cvs_xiangqing.Visible = false
    end
    self.chanType = 0
    self.sp_list:Initialize(self.cvs_detail.Width+12, self.cvs_detail.Height+5, 0,0 , self.cvs_detail,
        LuaUIBinding.HZScrollPanUpdateHandler(
        function (x, y, node)
            local index = x+1+y*4
            local cellData = self.curRedList[index]
            updateItemCell(cellData, node)
        end
        ),
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
        end)
    )

    Util.InitMultiToggleButton(function (sender)
        SwitchPage(sender)
    end,nil,{self.tbt_shijie,self.tbt_xianmeng})
end

local function  Init( params )
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_hongbao.gui.xml", GlobalHooks.UITAG.GameUIRedPacket)
	self.menu.Enable = true
	self.menu.mRoot.Enable = true
	InitUI()
	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return { Create = Create }
