-- 
-- @Author: LaoY
-- @Date:   2018-08-21 15:02:31
-- 
require("game/config/auto/db_server")
require("game/config/client/db_server_channel")
require("common/input/GmItem")

LoginSelectPanel = LoginSelectPanel or class("LoginSelectPanel", WindowPanel)
local LoginSelectPanel = LoginSelectPanel


--[[ local search_config_list = {}

local function initSearchConfig(config,search_key,save_key,func)
    if not search_config_list[config] then
        search_config_list[config] = FuzzySearch(config,search_key,save_key,func)
    end
end

local function find(config,str)
    if search_config_list[config] then
        return search_config_list[config]:find(str)
    end
    return nil
end ]]

function LoginSelectPanel:ctor()
	self.abName = "login"
	self.assetName = "LoginSelectPanel"
	self.layer = "UI"

	self.is_click_bg_close = true;
	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 3
	--self.model = LoginModel:GetInstance()


   --[[  local function handlerSearchFunc(list)
        local t = {}
        local len = #list
        for i=1,len do
            local v = list[i]
            t[#t+1] = v.name
        end
        return t
    end
    initSearchConfig(Config.db_server,"name",nil,handlerSearchFunc) ]]
end

function LoginSelectPanel:dctor()
	if self.item_list then
		for k,item in pairs(self.item_list) do
			item:destroy()
		end
		self.item_list = {}
	end
end


--[[
	@param callback 选择回调
	@param isDevChannelLogin --ffh 渠道登录添加
]]
function LoginSelectPanel:Open(callback, isDevChannelLogin)
	self.callback = callback
	self.isDevChannelLogin = isDevChannelLogin
	LoginSelectPanel.super.Open(self)
end

function LoginSelectPanel:LoadCallBack()
	self.nodes = {
		"GmItem","scroll/Viewport/Content","btn_serach","btn_serach/text_serach","input_serverName",
	}
	self:GetChildren(self.nodes)

	self.GmItem_gameObject = self.GmItem.gameObject
	
	self.input_serverName = self.input_serverName:GetComponent("InputField")
	self.btn_serach = self.btn_serach:GetComponent("Button");
	self.text_serach = self.text_serach:GetComponent('Text')

	self:AddEvent()
end

function LoginSelectPanel:AddEvent()
	--[[ local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.con.gameObject,call_back) ]]

	local function call_back(target, x, y)

		if self.text_serach.text == "Cancel search" then
			--取消搜索 显示出所有Item
            for k, v in pairs(self.item_list) do
                v:SetVisible(true)
			end
			self.input_serverName.text = ""
            self.text_serach.text = "Search"
		else
			--进行搜索
			self:OnSearch()
			self.text_serach.text = "Cancel search"
        end
    end
    AddClickEvent(self.btn_serach.gameObject, call_back)

end

function LoginSelectPanel:OpenCallBack()
	self:UpdateView()
end

function LoginSelectPanel:CloseCallBack(  )

end

function LoginSelectPanel:UpdateView( )
	--[[ self.item_list = {}
	local list = self.model.ip_list
	local function call_back(index)
		if index and self.callback then
			self.callback(index)
		end
		self:Close()
	end
	SetSizeDeltaY(self.content,#list * 30)
	for i=1,#list do
		local vo = list[i]
		local item = self.item_list[i]
		if not item then
			item = LoginSelectItem(self.content)
			self.item_list[i] = item
		end
		item:SetPosition(0,-(i-1) * 30)
		item:SetText(string.format("%s:%s",vo.name,vo.ip))
		item:SetIndex(call_back,i)
	end ]]

	self.item_list = {}
	local list = Config.db_server
	--ffh 渠道登录添加
	if self.isDevChannelLogin then
		list = Config.db_server_channel or {}
	end
	DebugLog("db_server ====== ", Table2String(list))
	local function call_back(index)
		if index and self.callback then
			self.callback(index, self.isDevChannelLogin)
		end
		self:Close()
	end

	for i=1,#list do
		local vo = list[i]
		local item = self.item_list[i]
		if not item then
			item = LoginSelectItem(self.GmItem_gameObject,self.Content)
			self.item_list[vo.name] = item
		end
		
		item:SetText(vo.name)
		item:SetIndex(call_back,i)
	end
end



function LoginSelectPanel:OnSearch()

    local str = self.input_serverName.text
    if #str < 1 then
        return
    end

	--先隐藏所有item
    for k, item in pairs(self.item_list) do
        item:SetVisible(false)
	end
	
	--然后显示符合的item 
	--local t = find(Config.db_server,str)
	
	local t = {}
    for k, v in pairs(Config.db_server) do
        if string.find(v.name, str) then
            t[#t + 1] = v.name;
        end
	end
	
    for k, v in pairs(t) do
        self.item_list[v]:SetVisible(true)
    end

end
