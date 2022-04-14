--
-- @Author: LaoY
-- @Date:   2018-11-23 11:00:48
--
PkModeItem = PkModeItem or class("PkModeItem",BaseCloneItem)
local PkModeItem = PkModeItem

function PkModeItem:ctor(obj,parent_node,layer)
	PkModeItem.super.Load(self)
end

function PkModeItem:dctor()
end

function PkModeItem:LoadCallBack()
	self.nodes = {
		"img_click/img_line","img_click/btn_img","img_click/text_mode","img_click/text_des","img_click",
	}
	self:GetChildren(self.nodes)

	self.btn_img_component = self.btn_img:GetComponent('Image')
	self.text_mode_component = self.text_mode:GetComponent('Text')
	self.text_des_component = self.text_des:GetComponent('Text')

	if self.is_need_setimglinevisible then
		self:SetImageLineVisible(self.img_line_flag)
	end
	if self.is_need_SetData then
		self:SetData(self.pkmode)
	end
	self:AddEvent()
end

function PkModeItem:SetCallBack(call_back)
	self.call_back = call_back
end

function PkModeItem:AddEvent()
	local function on_click()
		GlobalEvent:Brocast(FightEvent.ReqPKMode,self.data.pkmode)
		if self.call_back then
			self.call_back()
		end
	end
	local function call_back(target,x,y)
		if not self.data then
			return
		end
		if self.data.pkmode == FightManager:GetInstance().pkmode then
			Notify.ShowText("You are already under this mode")
			return
		end
		local scene_type = SceneConfigManager:GetInstance():GetSceneType()
		if scene_type == SceneConstant.SceneType.Feild and 
			(self.data.pkmode == enum.PKMODE.PKMODE_ALLY or self.data.pkmode == enum.PKMODE.PKMODE_WHOLE) then
			Dialog.ShowTwo("Tip","Defeating other players in neutral area will cumulate your guilt. When you are defeated while being guilty, you will lose certain Bound Diamond, Switch mode?","Confirm",on_click,nil,"Cancel",nil,nil)
			return
		end
		on_click()
	end
	AddClickEvent(self.img_click.gameObject,call_back)
end

function PkModeItem:SetData(pkmode)
	self.pkmode = pkmode
	if not self.pkmode then
		return
	end
	if self.is_loaded then
		self.data = SceneConfigManager.PkModeConfig[self.pkmode]
		self.text_mode_component.text = self.data.name
		self.text_des_component.text = self.data.des
		self:SetButtonRes(self.data.res)
		self.is_need_SetData = false
	else
		self.is_need_SetData = true
	end
	
end

function PkModeItem:SetButtonRes(res)
	if self.btn_res == res then
		return
	end
	self.btn_res = res
	local res_list = string.split(res,":")
	local abName = res_list[1]
	local assetName = res_list[2]
	lua_resMgr:SetImageTexture(self,self.btn_img_component,abName,assetName,true)
end

function PkModeItem:SetImageLineVisible(flag)
	if self.is_loaded then
		self.is_need_setimglinevisible = false
		SetVisible(self.img_line,flag)
	else
		self.img_line_flag = self.flag
		self.is_need_setimglinevisible = true
	end
end