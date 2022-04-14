--
-- @Author: LaoY
-- @Date:   2018-12-21 19:20:54
--

MtTreasureDigPanel = MtTreasureDigPanel or class("MtTreasureDigPanel",BasePanel)
local MtTreasureDigPanel = MtTreasureDigPanel

function MtTreasureDigPanel:ctor()
	self.abName = "magictower_treasure"
	self.assetName = "MtTreasureDigPanel"
	self.layer = "UI"

	self.use_background = false
	self.change_scene_close = true

	self.model = MagictowerTreasureModel:GetInstance()
	self.model_event_list = {}
end

function MtTreasureDigPanel:dctor()
	if self.model_event_list then
		self.model:RemoveTabListener(self.model_event_list)
		self.model_event_list = {}
	end

	if self.npc_model then
		self.npc_model:destroy()
		self.npc_model = nil
	end
	if self.UIModelCamera_com then
		self.UIModelCamera_com.texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	if self.render_texture then
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
end

--[[
	@author LaoY
	@des	
	@param1 show_type 	是对话方式 1是选择挖宝方式 2是NPC对话
--]]
function MtTreasureDigPanel:Open(index,show_type)
	self.index = index
	self.show_type = show_type
	self.stage = 1
	if self.show_type == 2 then
		self.model.dig_talk_index = self.index
	end
	MtTreasureDigPanel.super.Open(self)
end

function MtTreasureDigPanel:LoadCallBack()
	self.nodes = {
		"btn_1","img_bg","btn_2","btn_3","btn_close",
		"btn_1/btn_text_1","btn_2/btn_text_2","btn_3/btn_text_3",
		"img_bg_11_1/text_monster_name","bottom_con/UIModelCamera/Camera",
		"bottom_con/UIModelCamera","bottom_con/text_name","bottom_con/text_des","bottom_con","img_mtt_fairy",
		"bottom_con/Image",
	}
	self:GetChildren(self.nodes)

	self.img_bg_component = self.img_bg:GetComponent('Image')
	local res = "img_mtt_bg_2"
	lua_resMgr:SetImageTexture(self,self.img_bg_component, "iconasset/icon_big_bg_"..res, res,false)

	self.btn_text_1_component = self.btn_text_1:GetComponent('Text')
	self.btn_text_2_component = self.btn_text_2:GetComponent('Text')
	self.btn_text_3_component = self.btn_text_3:GetComponent('Text')

	self.text_name_component = self.text_name:GetComponent('Text')

	self.img_mtt_fairy_component = self.img_mtt_fairy:GetComponent('Image')

	self.btn_text_1_component.text = "Subdue\nELf"
	self.btn_text_2_component.text = "Subdue\nELf"
	self.btn_text_3_component.text = "Absorbe\nELf"

	self.render_texture = CreateRenderTexture() 
	self.UIModelCamera_com = self.UIModelCamera:GetComponent("RawImage")
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.UIModelCamera_com.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture

	self.text_des_component = self.text_des:GetComponent('Text')

	SetAlignType(self.btn_close,bit.bor(AlignType.Right,AlignType.Top))
	-- SetAlignType(self.bottom_con,bit.bor(AlignType.Bottom,AlignType.Null))

	SetSizeDeltaX(self.Image,ScreenWidth - 8)
	SetLocalPositionX(self.text_name, (-ScreenWidth / 2) + 405)

	self:AddEvent()
end

function MtTreasureDigPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)
	AddClickEvent(self.Image.gameObject,call_back)

	local function call_back(target,x,y)
		if self.show_type == 1 then

		else
			if self.stage >= #MtTreasureConstant.TalkShow[1] then
				-- Notify.ShowText("最后一段对话完成")
				self.model:Brocast(MagictowerTreasureEvent.REQ_DIG,1,self.index)
			else
				self.stage = self.stage + 1
				self:UpdateView()
			end
		end
	end
	AddClickEvent(self.img_bg.gameObject,call_back)

	-- 打架
	local function call_back(target,x,y)
		if self.model.mt_treasure_info and self.model.mt_treasure_info.etime < os.time() then
			Notify.ShowText("Event timed out, please restart")
			return
		end
		self.model:Brocast(MagictowerTreasureEvent.REQ_DIG,2,self.index)
	end
	AddClickEvent(self.btn_1.gameObject,call_back)

	-- 对话
	local function call_back(target,x,y)
		if self.model.mt_treasure_info and self.model.mt_treasure_info.etime < os.time() then
			Notify.ShowText("Event timed out, please restart")
			return
		end
		-- self.model:Brocast(MagictowerTreasureEvent.REQ_DIG,1,self.index)

		-- self.show_type = 2
		-- self:OpenCallBack()
		self:Open(self.index,2)
	end
	AddClickEvent(self.btn_2.gameObject,call_back)

	-- 采集
	local function call_back(target,x,y)
		if self.model.mt_treasure_info and self.model.mt_treasure_info.etime < os.time() then
			Notify.ShowText("Event timed out, please restart")
			return
		end
		self.model:Brocast(MagictowerTreasureEvent.REQ_DIG,3,self.index)
	end
	AddClickEvent(self.btn_3.gameObject,call_back)

	local function call_back()
		self:Close()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_DIG, call_back)
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_STAT, call_back)

	local function time_out_func()
		Dialog.ShowOne("Tip","Event timed out, please restart","Confirm",handler(self,self.Close),10)
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.TimeOut,time_out_func)
end

function MtTreasureDigPanel:OpenCallBack()
	self:SetButtonVisible(self.show_type == 1)
	self:UpdateView()
end

function MtTreasureDigPanel:SetButtonVisible(flag)
	SetVisible(self.btn_1,flag)
	SetVisible(self.btn_2,flag)
	SetVisible(self.btn_3,flag)
end

function MtTreasureDigPanel:LoadModelCallBack()
	-- SetLocalPosition(self.npc_model.transform , -2240 ,-177, 1182);--172.2
 --    SetLocalRotation(self.npc_model.transform, 0, 172, 0);

    local config = Config.db_npc[self.npc_id] or {}
	if not config then
		SetLocalPosition(self.npc_model.transform , -2098 ,-65, 388);--172.2
	else
		local pos = String2Table(config.pos)
		SetLocalPosition(self.npc_model.transform , pos[1] ,pos[2], pos[3])
	end
    SetLocalRotation(self.npc_model.transform, 0, 172, 0);
    self.npc_model:SetCameraLayer();

    local npc_object = SceneManager:GetInstance():GetObject(self.npc_id)
    local show_action_name = SceneConstant.ActionName.show
    if npc_object then
    	show_action_name = npc_object:GetShowActionName()
    	npc_object:ChangeMachineState(show_action_name)
    end
    self.npc_model:AddAnimation({show_action_name ,"idle"},true,"idle",0)--,"casual"

end

function MtTreasureDigPanel:UpdateView()
	if not self.npc_model then
		local npc_id = MtTreasureConstant.NPCList[self.index]
		self.npc_id = npc_id
		local config = Config.db_npc[npc_id] or {}
		self.npc_model = UINpcModel(self.UIModelCamera,config.figure,handler(self,self.LoadModelCallBack))

		self.text_name_component.text = config.name
	end

	if self.show_type == 1 then
		self.text_des_component.text = MtTreasureConstant.DigDes
	else
		local talk_index = self.stage
		if self.stage > #MtTreasureConstant.TalkShow[self.index] then
			talk_index = #MtTreasureConstant.TalkShow[self.index]
		end
		self.text_des_component.text = MtTreasureConstant.TalkShow[self.index][talk_index]
	end

	self:SetFairyRes()
end

function MtTreasureDigPanel:SetFairyRes()
	local res = "img_mtt_fairy_" .. self.index
	local abName = "iconasset/icon_big_bg_"..res
	local assetName = res
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	lua_resMgr:SetImageTexture(self,self.img_mtt_fairy_component, abName, assetName,false)
end

function MtTreasureDigPanel:CloseCallBack()

end