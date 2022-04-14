--
-- @Author: LaoY
-- @Date:   2018-11-10 20:51:03
--
GVoiceTestPanel = GVoiceTestPanel or class("GVoiceTestPanel",WindowPanel)
local GVoiceTestPanel = GVoiceTestPanel

function GVoiceTestPanel:ctor()
	self.abName = "main"
	self.assetName = "GVoiceTestPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.win_type = 2								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	-- if self.show_sidebar then		-- 侧边栏配置
	-- 	self.sidebar_data = {
	-- 		{text = ConfigLanguage.Custom.Message,id = 1,img_title = "system:ui_img_text_title"},
	-- 	}
	-- end
	self.table_index = nil
end

function GVoiceTestPanel:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function GVoiceTestPanel:Open( )
	GVoiceTestPanel.super.Open(self)
	VoiceManager:GetInstance():SetGVoiceAppInfo("10000abcdefg58")
end

function GVoiceTestPanel:LoadCallBack()
	self.nodes = {
		"btn_6","btn_5","btn_3","btn_4","btn_2","btn_1","account", "account/account_default", "account/account_text"
	}
	self:GetChildren(self.nodes)

	self.account:GetComponent("InputField").text = "58"

	self.input_component = self.account:GetComponent("InputField")
	self:AddEvent()
end

function GVoiceTestPanel:AddEvent()
	local file_name = "speak_100"
	local down_load_file_name = "down_100"
	local file_id
	VoiceManager:GetInstance():ApplyMessageKey()

	local function call_back(target,x,y)
		VoiceManager:GetInstance():StartRecording(file_name)
	end
	AddClickEvent(self.btn_1.gameObject,call_back)

	local function call_back(target,x,y)
		VoiceManager:GetInstance():StopRecording()
		VoiceManager:GetInstance():UploadRecordedFile(file_name)
	end
	AddClickEvent(self.btn_2.gameObject,call_back)

	local function call_back(target,x,y)
		if file_id then
			VoiceManager:GetInstance():DownloadRecordedFile(file_id,down_load_file_name,nil,true)
		end
	end
	AddClickEvent(self.btn_3.gameObject,call_back)

	local function call_back(target,x,y)
		VoiceManager:GetInstance():PlayRecordedFile(down_load_file_name)
	end
	AddClickEvent(self.btn_4.gameObject,call_back)

	local function call_back(target,x,y)
		VoiceManager:GetInstance():StopPlayFile()
	end
	AddClickEvent(self.btn_5.gameObject,call_back)

	local function call_back(target,x,y)
		if file_id then
			VoiceManager:GetInstance():SpeechToText(file_id)
		end
	end
	AddClickEvent(self.btn_6.gameObject,call_back)

	self.global_event_list = self.global_event_list or {}
	local function call_back(state,file_name,fileid)
		-- if state then
			file_id = fileid
			Yzprint('--LaoY GVoiceTestPanel.lua,line 96-- data=',state,file_name,fileid)
		-- end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.UploadVoiceState, call_back)

	local function call_back(state,fileid,str)
		-- if state then
			Notify.ShowText(str)
			Yzprint('--LaoY GVoiceTestPanel.lua,line 105-- str=',str)
		-- end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.SpeechToTextState, call_back)
end

function GVoiceTestPanel:SetText(str)
	self.input_component.text = str or ""
end

function GVoiceTestPanel:OpenCallBack()
end

function GVoiceTestPanel:CloseCallBack(  )

end