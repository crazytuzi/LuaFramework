--
-- @Author: LaoY
-- @Date:   2018-11-23 20:32:36
--

MainBuffIconItem = MainBuffIconItem or class("MainBuffIconItem",BaseCloneItem)
local MainBuffIconItem = MainBuffIconItem

function MainBuffIconItem:ctor(obj,parent_node,layer)
	MainBuffIconItem.super.Load(self)
end

function MainBuffIconItem:dctor()
end

function MainBuffIconItem:LoadCallBack()
	self.img = self.gameObject:GetComponent('Image')
	self:AddEvent()
end

function MainBuffIconItem:AddEvent()
	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(BuffShowPanel):Open(self.index)
	end
	AddClickEvent(self.gameObject,call_back)
end

function MainBuffIconItem:SetCallBack(call_back)
	self.call_back = call_back
end

function MainBuffIconItem:SetData(data,index)
	self.data = data
	self.index = index
	if not self.data then
		return 
	end
	local config = Config.db_buff[self.data.id]
	if config then
		self:SetRes(config.icon)
	end
end

function MainBuffIconItem:SetRes(res)
	if self.res == res then
		return
	end
	self.res = res
    lua_resMgr:SetImageTexture(self,self.img, "iconasset/icon_leftlittle", tostring(res),true)
end