local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local RedPacketModel = require 'Zeus.Model.RedPacket'
local self={}


local function InitUI()
	local UIName = {
		"btn_close",
		"tbt_gou1",
		"tbt_gou2",
		"tbt_gou3",
		"tbt_gou4",
		"lb_redCount",
		"lb_moneyCount",
		"btn_jian",
		"btn_jian1",
		"btn_jia",
		"btn_jia1",
		"ti_information",
		"lb_numtomax",
		"cvs_commonpops",
		"cvs_commonpop2",
		"lb_total",
		"lb_num",
		"tb_showtext",
		"bt_no",
		"bt_yes",
		"bt_sendout",
		"lb_title",
		"lb_diamond",
		"lb_gold",
		"lb_redtitle",
		"lb_cost",
	}
	for i=1,#UIName do
		self[UIName[i]] = self.menu:GetComponent(UIName[i])
	end
	
	self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.world = Util.GetText(TextConfig.Type.CHAT, "worldRedPacket")
    self.guild = Util.GetText(TextConfig.Type.CHAT, "guildRedPacket")

end

local function SwitchPage(sender)
	if sender == self.tbt_gou1 then
		self.index = 0
	elseif sender == self.tbt_gou2 then
		self.index = 1
	end  
end

local function SwitchMoneyType(sender)
	if sender == self.tbt_gou3 then
		self.moneyType = 0
	elseif sender == self.tbt_gou4 then
		self.moneyType = 1
	end  
end


local function SetParameters()
	local minMoney = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.DiamondNumber.Down" })[1].ParamValue)
	local maxMoney = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.DiamondNumber.Up" })[1].ParamValue)
	local addMoney = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.DiamondNumber.Add" })[1].ParamValue)
	local minCount = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.HongbaoNumber.Down" })[1].ParamValue)
	local maxCount = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.HongbaoNumber.Up" })[1].ParamValue)
	local exchangeRate = tonumber(GlobalHooks.DB.Find('Parameters', { ParamName = "Red.HongbaoRatio" })[1].ParamValue)
	minCount = 1
	self.redType = 0
	self.redCount = minCount
	self.moneyCount = minMoney
	self.lb_redCount.Text = minCount
	self.lb_moneyCount.Text = minMoney
	self.lb_diamond.Text = minMoney
	self.lb_gold.Text = minMoney * exchangeRate


	local minTips = Util.GetText(TextConfig.Type.SHOP, "minTips")
	local maxTips = Util.GetText(TextConfig.Type.SHOP, "tiplimitGoodsMax")

	local redkouling = Util.GetText(TextConfig.Type.CHAT, "redkouling")
	local redjiyu = Util.GetText(TextConfig.Type.CHAT, "redjiyu")

	self.btn_jian.TouchClick = function ()
		if self.redCount <= minCount then
			GameAlertManager.Instance:ShowNotify(minTips)
		else
			self.redCount = self.redCount - 1
		end 
		self.lb_redCount.Text = self.redCount
	end

	self.btn_jia.TouchClick = function ()
		if self.redCount >= maxCount then
			GameAlertManager.Instance:ShowNotify(maxCount)
		else
			self.redCount = self.redCount + 1
		end
		self.lb_redCount.Text = self.redCount
	end

	self.btn_jian1.TouchClick = function ()
		if self.moneyCount <= minMoney then
			GameAlertManager.Instance:ShowNotify(minTips)
		else
			self.moneyCount = self.moneyCount - addMoney
		end 
		self.lb_moneyCount.Text = self.moneyCount
		self.lb_diamond.Text = self.moneyCount
		self.lb_gold.Text = self.moneyCount * exchangeRate
	end

	self.btn_jia1.TouchClick = function ()
		if self.moneyCount >= maxMoney then
			GameAlertManager.Instance:ShowNotify(maxMoney)
		else
			self.moneyCount = self.moneyCount + addMoney
		end
		self.lb_moneyCount.Text = self.moneyCount
		self.lb_diamond.Text = self.moneyCount
		self.lb_gold.Text = self.moneyCount * exchangeRate
	end

	local wordList = GlobalHooks.DB.Find("RedPackage",{})
	local wordStr = math.random(1,#wordList)

	self.lb_numtomax.Text = "0/30"
	self.ti_information.Input.characterLimit = 30
	self.ti_information.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineNewline
    local oldtext = wordList[wordStr].Words
    self.ti_information.Input.Text = oldtext
    self.ti_information.event_endEdit = function(sender, txt)

        if Util.widthString(txt) <= 30 then
            oldtext = txt
        else
            inputText.Input.Text = oldtext
        end
        local len = Util.widthString(oldtext)
        self.lb_numtomax.Text = tostring(len) .. "/30"
    end

    self.bt_sendout.TouchClick = function ()
		if self.redType == 0 then
			self.lb_redtitle.Text = redkouling
		else
			self.lb_redtitle.Text = redjiyu
		end
    	if oldtext == "" or oldtext == nil  then
    		if self.redType == 0 then
    			GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, "koulingTips"))
    		else
    			GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, "putongTips"))
    		end
    		return
    	end
    	self.cvs_commonpop2.Visible = true
    	self.cvs_commonpops.Visible = true
    	if self.moneyType == 0 then
    		self.lb_total.Text = self.moneyCount
    	else
    		self.lb_total.Text = self.moneyCount * exchangeRate
    	end
    	self.lb_cost.Text = self.moneyCount
    	self.lb_num.Text = self.redCount
    	self.tb_showtext.UnityRichText = oldtext
    	if self.index == 0 then 
    		self.lb_title.Text = self.world
    	else
    		self.lb_title.Text = self.guild
    	end
    end

    self.bt_no.TouchClick = function ()
    	self.cvs_commonpop2.Visible = false
    	self.cvs_commonpops.Visible = false
    end
    self.bt_yes.TouchClick = function()
    	RedPacketModel.dispatchRedPacketRequest(self.redCount,self.moneyCount,self.index,self.redType,self.moneyType,oldtext,function(params)
    		if params.s2c_code == 200 then
    			self.cvs_commonpop2.Visible = false
    			if self ~= nil and self.menu ~= nil then
        			self.menu:Close()
    			end
    		end
    	end)
    end
end

function _M:setData(redType,channel)
	self.redType = redType
	if channel == 0 then
		self.tbt_gou1.IsChecked = true
	else
		self.tbt_gou2.IsChecked = true
	end
end

local function OnEnter()

	Util.InitMultiToggleButton(function (sender)
        SwitchPage(sender)
    end,nil,{self.tbt_gou1,self.tbt_gou2})
    Util.InitMultiToggleButton(function (sender)
        SwitchMoneyType(sender)
    end,self.tbt_gou3,{self.tbt_gou3,self.tbt_gou4})
	SetParameters()
end

local function OnExit()
	 self.cvs_commonpops.Visible = false
	 self.redCount = nil
	 self.moneyCount = nil
	 self.index = nil
	 self.redType = nil
end


local function  Init( params )
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_hongbao_send.gui.xml", GlobalHooks.UITAG.GameUIRedPacketSend)
	self.menu.Enable = true
	self.menu.mRoot.Enable = true
	InitUI()
	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
	return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return { Create = Create }
