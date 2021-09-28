local _M = {}
_M.__index = _M

local Util                  = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"
local ChatModel = require 'Zeus.Model.Chat'
local ChatSendVoice     = require "Zeus.UI.Chat.ChatSendVoice"
local ItemModel = require 'Zeus.Model.Item'

local self = {
	menu = nil,
}

local MaxLength = 50
local function utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end



local function OnClickBegin(displayNode)
	self.menu:Close()
end

local function SpeakerNum()
	local bag_data = DataMgr.Instance.UserData.RoleBag
	local vItem = bag_data:MergerTemplateItem("loud")    
	local x = (vItem and vItem.Num) or 0
	self.lb_num.Text = x

	if vItem == nil then
		vItem = {}
		local static_data = ItemModel.GetItemStaticDataByCode("loud")	
		vItem.IconId = static_data.Icon
		vItem.Quality = static_data.Qcolor
	end	
	if self.itemShow == nil then
        self.itemShow = Util.ShowItemShow(self.cvs_item, vItem.IconId, vItem.Quality) 
    else
        
    end
end

local function InitRichTextLabel(self)

    if(self.m_htmlText == nil) then
        local canvas = HZCanvas.New()
        canvas.Size2D = self.ti_content.Size2D
        canvas.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/shade.png", LayoutStyle.IMAGE_STYLE_ALL_9, 8)
        local mask = canvas.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask))
        mask.showMaskGraphic = false

        self.m_htmlText = HZRichTextPan.New();
        self.m_htmlText.Size2D = self.ti_content.Size2D
        self.m_htmlText.RichTextLayer.UseBitmapFont = true
        self.m_htmlText.RichTextLayer:SetEnableMultiline(true)
        self.m_htmlText.TextPan.Width = self.ti_content.Size2D.x
        canvas:AddChild(self.m_htmlText)
        self.ti_content:AddChild(canvas)
        self.m_htmlText.Visible = false;
        self.m_htmlText.X = 10
        self.m_htmlText.Y = 10
    end
end

local function AddStringInput(msg, self, copy)
    
    InitRichTextLabel(self)

    if string.gsub(msg, " ", "") ~= "" or self.m_titleMsg ~= "" or string.gsub(self.m_StrTmpOriginal, " ", "") ~= "" then
        self.lb_click.Visible = false
        self.m_htmlText.Visible = true
        
    else
        self.lb_click.Visible = true
        self.m_htmlText.Visible = false
        
    end

    if string.gsub(msg, " ", "") == "" then
        msg = ""
    end
    
    if copy then
        if ChatUtil.StartsWith(msg, "|") then
            self.m_StrTmpOriginal = self.m_StrTmpOriginal .. msg
        else
            self.m_StrTmpOriginal = self.m_StrTmpOriginal .. "|" .. msg .. "|"
        end 
    else
        self.m_StrTmpOriginal = self.m_StrTmpOriginal .. msg
    end
    local linkdata = ChatUtil.HandleChatClientDecode(self.m_titleMsg .. self.m_StrTmpOriginal, 0xffffffff)
    self.m_htmlText.RichTextLayer:SetString(linkdata)
	
	local num = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal)
    
	self.lb_tips2.Text = (MaxLength - utf8len(num))
	if tonumber(self.lb_tips2.Text) < 0 then
		self.lb_tips2.Text = 0
	end	
	
end

local function HandleTxtInputPrivate(displayNode, self)
    self.lb_click.Visible = false
    
    if self.ti_content.Input.text == " " then
        self.m_StrInput = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal)
        self.ti_content.Input.text = self.m_StrInput

        if(self.m_htmlText ~= nil)then
            self.m_htmlText.Visible = false;
        end
    end
end

local function HandleInputFinishCallBack(displayNode, self)
    
    local msg = ""
    msg = ChatUtil.HandleInputToOriginal(self.ti_content.Input.text)
    self.m_StrTmpOriginal = ""
    AddStringInput(msg, self)
    self.ti_content.Input.text = " "
	
	local num = ChatUtil.HandleOriginalToInput(msg)	
	self.lb_tips2.Text = (MaxLength - utf8len(num))
	if tonumber(self.lb_tips2.Text) < 0 then
		self.lb_tips2.Text = 0
	end
	
end

local function HandleInputChangeCallBack(displayNode, self)
    
    local msg = ChatUtil.HandleInputToOriginal(self.ti_content.Input.text)
	local num = ChatUtil.HandleOriginalToInput(msg)	
	self.lb_tips2.Text = (MaxLength - utf8len(num))
	
	if tonumber(self.lb_tips2.Text) < 0 then
		self.lb_tips2.Text = 0
	end
end

local function clearMsg(self)
    
    self.m_StrTmpOriginal = ""
    AddStringInput("", self)
    self.ti_content.Text = ""
end

local function OnEnter()
	SpeakerNum()
end

local function OnExit()
	if self.OnCloseCb ~= nil then
		self.OnCloseCb()
	end
	clearMsg(self)
end

function _M.InitData(chatMain)
  self.chat_main = chatMain
end

function _M.AddStr(msg,copy)
	local num = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal ..msg)		
	if utf8len(num) <= MaxLength then
        AddStringInput(msg, self,copy)
    else
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_limit'))
    end
end

function _M.Close()
  OnClickBegin()
end

local function OnClickExtend(displayNode)
    if self.OnExtendCb ~= nil then
		self.OnExtendCb(nil)
	end
end

local function OnClickYuYin(displayNode)
    
end

local function OnClickEnter(displayNode)
    if self.OnClickCb ~= nil then
		self.OnClickCb(self.m_StrTmpOriginal)
		clearMsg(self)
	end
end

local function OnClickAdd(displayNode)
    
 

	
	
	
	
	
	
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, "loud")
end

local function InitUI()
    
    local UIName = {
        "tb_text",
        "btn_extend",
        "btn_yuyin",
        "ti_content",
		"btn_enter",
		"btn_jia",
		"lb_num",
		"cvs_item",
		"lb_click",
		"lb_tips1",
		"lb_tips2",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
	
	self.btn_extend.TouchClick = OnClickExtend
	self.btn_yuyin.TouchClick = OnClickYuYin
	self.btn_enter.TouchClick = OnClickEnter
	self.btn_jia.TouchClick = OnClickAdd

    self.ti_content.Input.characterLimit = MaxLength
    self.ti_content.Input.text = " "
    self.ti_content.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineSubmit
    self.ti_content.InputTouchClick = function(displayNode)
        HandleTxtInputPrivate(displayNode, self)
    end
    self.ti_content.event_endEdit = LuaUIBinding.InputValueChangedHandler(function(displayNode)
        HandleInputFinishCallBack(displayNode, self)
    end)
	
	self.ti_content.event_ValueChanged = LuaUIBinding.InputValueChangedHandler(function(displayNode)
        HandleInputChangeCallBack(displayNode, self)
    end)
	self.lb_tips2.Text = MaxLength
	self.m_StrTmpOriginal = ""
	self.m_titleMsg = ""
end

local function OnBuySuccess(name,param)
    if param.itemCode == "loud" then
        local count = param.buyCount
        local oldCount = tonumber(self.lb_num.Text)
        self.lb_num.Text = oldCount + count
        
    end
end

local function InitCompnent()
    InitUI()
    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickBegin})
    self.btn_close = self.menu:GetComponent("btn_close")
    self.btn_close.TouchClick = OnClickBegin
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
    EventManager.Subscribe("Event.ShopMall.BuySuccess", OnBuySuccess)
end

local function Init(tag,params)

    local index = tonumber(params)
    if index then
        self.default = index
    end
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_speaker.gui.xml", GlobalHooks.UITAG.GameUIChatSpeaker)
    self.menu.ShowType = UIShowType.Cover
	InitCompnent()

	return self.menu
end

local function Create(tag,params)
	self = {}
    
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

local function initial()
  
end

return {Create = Create, initial = initial}
