GuildQuestionPanel = GuildQuestionPanel or class("GuildQuestionPanel",BasePanel)
local GuildQuestionPanel = GuildQuestionPanel

function GuildQuestionPanel:ctor()
	self.abName = "guild_house"
	self.assetName = "GuildQuestionPanel"
	self.layer = "UI"

	self.change_scene_close = true 				--切换场景关闭
	--self.click_bg_close = true
	self.use_background = true
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 1								--窗体样式  1 1280*720  2 850*545
	--self.show_sidebar = true		--是否显示侧边栏
	--if self.show_sidebar then		-- 侧边栏配置
	--	self.sidebar_data = {
	--		{text = ConfigLanguage.Custom.Message,id = 1,img_title = "system:ui_img_text_title",icon = "roleinfo:img_message_icon_1",dark_icon ="roleinfo:img_message_icon_2",},
	--	}
	--end
	self.table_index = nil
	self.model = GuildHouseModel:GetInstance()

	self.height = 0
	self.events = {}
	self.global_events = {}
	self.question_list = {}
	self.chat_list = {}
	self.rank_list = {}
end

function GuildQuestionPanel:dctor()
end

--data:m_guild_house_question_toc
function GuildQuestionPanel:Open(data)
	GuildQuestionPanel.super.Open(self)
	self.data = data
	self.model.is_opened_panel = true
end

function GuildQuestionPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","middle/InputField","middle/sendbtn","number",
		"question","ScrollView/Viewport/Content/GuildAnswerItem","right/score",
		"middle/MidScrollView/Viewport/MidContent","middle/MidScrollView",
		"countdown","countdown/countdowntext","countdown2","right/RightScrollView/Viewport/RightContent/QuestionRankItem",
		"right/RightScrollView/Viewport/RightContent","middle/sendbtn/countdown3","closebtn","first_bg/first_name",
		"activity_time_title","activity_time_title/activity_time","right/viewrewardbtn","question/countdown4",
		"tipbtn","middle/sendbtn/Text",
	}
	self:GetChildren(self.nodes)
	self.number = GetText(self.number)
	self.question = GetText(self.question)
	self.InputField = self.InputField:GetComponent('InputField')
	self.score = GetText(self.score)
	self.GuildAnswerItem_gameobject = self.GuildAnswerItem.gameObject
	self.rectTra = self.MidScrollView:GetComponent('RectTransform')
	self.contentRectTra = self.MidContent:GetComponent('RectTransform')
	self.scrollRect = self.MidScrollView:GetComponent('ScrollRect')
	self.QuestionRankItem_gameobject = self.QuestionRankItem.gameObject
	self.first_name = GetText(self.first_name)
	self.activity_time = GetText(self.activity_time)
	self.Text_btn = GetText(self.Text)
	SetVisible(self.QuestionRankItem_gameobject, false)
	self.sendbtn_button = self.sendbtn:GetComponent("Button")

	self:AddEvent()
	RankController:GetInstance():RequestRankListInfo(self.model.rank_id, 1)
	GuildHouseController:GetInstance():RequestQuestionScore()
	if #self.model.messages > 0 then
		for i=1, #self.model.messages do
			self:AddMsg(self.model.messages[i])
		end
	end
end

function GuildQuestionPanel:AddEvent()
	local function call_back(index)
		self.InputField.text = self.model:AnswerIndexToLetter(index)
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.AnswerClick, call_back)

	local function call_back(data)
		self.score.text = data.score
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.AnswerEvent, call_back)

	local function call_back(data)
		self.data = data
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.GetQuestionEvent, call_back)

	local function call_back()
		self.score.text = self.model.score
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.UpdateQuestionScoreEvent, call_back)

	local function call_back(name)
		self.first_name.text = name
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.QuestionFirstEvent, call_back)

	local function call_back()
		self:Close()
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.QuestionResult, call_back)

	local function call_back(data)
		if data.channel_id ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION then
			return
		end
		self:AddMsg(data)
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(ChatEvent.ReceiveMessage, call_back)

	local function call_back( message )
		self:Relayout(message)
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(ChatEvent.CreateItemEnd, call_back)

	local function call_back(data)
		if data.id ~= self.model.rank_id then
			return
		end
		self.rank_data = data
		local num = #data.list
		num = (num >= 30 and 30 or num)
		for i=1, num do
			local item = self.rank_list[i] or QuestionRankItem(self.QuestionRankItem_gameobject, self.RightContent)
			item:SetData(data.list[i])
			self.rank_list[i] = item
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(RankEvent.RankReturnList, call_back)

	local function call_back(target,x,y)
		if not self.sendbtn_button.enabled then
			return Notify.ShowText("In cooldown")
		end
		local index = self.model:LetterToIndex(self.InputField.text)
		if index and self.data and self.data.id > 0 then
			GuildHouseController:GetInstance():RequestAnswer(index)
		end
		local text = string.trim(self.InputField.text)
		if text == "" then
			Notify.ShowText("Unable to send empty content")
			return
		end
		ChatController:GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION, 0, text)
		SetButtonEnable(self.sendbtn_button, false)
		self.Text_btn.text = ""
		if not self.coundownitem3 then
			local param = {
				isShowMin = false,
		        duration = 0.033,
		        formatText = "%s sec",
		        formatTime="%d",
			}
			self.coundownitem3 = CountDownText(self.countdown3, param)
		end
		self.coundownitem3:ActiveText()
		local function finish()
			SetButtonEnable(self.sendbtn_button, true)
			self.Text_btn.text = "Send"
		end
		self.coundownitem3:StartSechudle(os.time()+5, finish)
		self.InputField.text = ""
	end
	AddClickEvent(self.sendbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(GuildQuestionRewadPanel):Open()
	end
	AddClickEvent(self.viewrewardbtn.gameObject,call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.GuildHouse.tips, true)
	end
	AddClickEvent(self.tipbtn.gameObject,call_back)
end

function GuildQuestionPanel:OpenCallBack()
	self:UpdateView()
end

function GuildQuestionPanel:UpdateView( )
	if self.model:IsInQuestion() then
		if self.data and self.data.id > 0 then
			self:ShowQuestion()
		else
			self:ShowNoStart()
			SetVisible(self.countdown4, true)
			self.question.text = "Quiz is about to start, please get yourselves prepared"
			local param = {
		        duration = 0.033,
		        formatText = "Countdown: %s",
		        formatTime="%d",
			}
			self.countdownitem4 = CountDownText(self.countdown4, param)
			local activity = ActivityModel:GetInstance():GetActivity(self.model.activity_id)
			self.countdownitem4:StartSechudle(activity.stime+60)
		end
	else
		self:ShowNoStart()
	end
end

function GuildQuestionPanel:AddMsg(data)
	local role = data.sender
	local item
	if role.id == RoleInfoModel:GetInstance():GetMainRoleId() then
		item = AnswerSelfChatItem(self.MidContent)
	else
		item = AnswerChatItem(self.MidContent)
	end
	if #self.chat_list >= 50 then
		self.chat_list[1]:destroy()
		table.remove(self.chat_list, 1)
	end
	self.chat_list[#self.chat_list+1] = item
	item:SetInfo(data, self.scrollRect)
end

--未开始时显示
function GuildQuestionPanel:ShowNoStart()
	SetVisible(self.activity_time_title, true)
	SetVisible(self.countdown, false)
	SetVisible(self.countdown2, false)
	SetVisible(self.number, false)
	SetVisible(self.GuildAnswerItem_gameobject, false)
	for i=1, 4 do
		local item = self.question_list[i] or GuildAnswerItem(self.GuildAnswerItem.gameObject, self.Content)
		local tab = {i, "Closed"}
		item:SetData(tab)
		self.question_list[i] = item
	end
	local time_duration = String2Table(Config.db_activity[self.model.activity_id].time)
	local start_time = time_duration[1]
	local end_time = time_duration[2]
	self.activity_time.text = start_time[1] .. ":" .. start_time[2] .. "-" .. end_time[1] .. ":" .. string.format("%02d",end_time[2])
end

--显示问题
function GuildQuestionPanel:ShowQuestion()
	--self.data = self.model.question
	SetVisible(self.activity_time_title, false)
	SetVisible(self.countdown4, false)
	SetVisible(self.countdown, true)
	SetVisible(self.countdown2, true)
	SetVisible(self.number, false)
	self.first_name.text = "None"
	local question = Config.db_guild_question[self.data.id]
	local total_num = String2Table(Config.db_game["guild_question_num"].val)[1]
	--self.number.text = string.format(ConfigLanguage.Common.TwoNum, self.data.num, total_num)
	self.question.text = self.data.num .. ".  " .. question.content
	local options = String2Table(question.options)
	SetVisible(self.GuildAnswerItem_gameobject, false)
	for i=1, #options do
		local item = self.question_list[i] or GuildAnswerItem(self.GuildAnswerItem.gameObject, self.Content)
		item:SetData(options[i], question.answer)
		self.question_list[i] = item
	end
	if self.data.score > 0 then
		self.score.text = self.data.score
	end
	local param = {
        isShowMin = false,
        duration = 0.033,
        formatText = "Countdown: %s",
        formatTime="%d",
    }
    if not self.countdownitem then
		self.countdownitem = CountDownText(self.countdown, param)
	else
		self.countdownitem:ActiveText()
	end
	self.countdownitem:StartSechudle(self.data.end_time-1, handler(self,self.QuestionFinish))
	local param2 = {
        isShowMin = false,
        duration = 0.033,
        formatText = "Next: %s",
        formatTime="%d",
    }
	if not self.countdownitem2 then
		self.countdownitem2 = CountDownText(self.countdown2, param2)
	else
		self.countdownitem2:ActiveText()
	end
	SetVisible(self.countdown2, false)
	self.countdownitem2:StartSechudle(self.data.end_time+5, nil, handler(self,self.NextUpdate))
end

function GuildQuestionPanel:CloseCallBack(  )
	for i=1, #self.events do
		self.model:RemoveListener(self.events[i])
	end
	for i=1, #self.global_events do
		GlobalEvent:RemoveListener(self.global_events[i])
	end
	for i=1, #self.question_list do
		self.question_list[i]:destroy()
	end
	for i=1, #self.chat_list do 
		self.chat_list[i]:destroy()
	end
	if self.countdownitem then
		self.countdownitem:destroy()
		self.countdownitem = nil
	end
	if self.countdownitem2 then
		self.countdownitem2:destroy()
		self.countdownitem2 = nil
	end
	if self.coundownitem3 then
		self.coundownitem3:destroy()
		self.countdownitem3 = nil
	end
	if self.countdownitem4 then
		self.countdownitem4:destroy()
		self.countdownitem4 = nil
	end
end
function GuildQuestionPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end

function GuildQuestionPanel:Relayout(chatMsg)
	if chatMsg.channel_id ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION then
		return
	end
	local height = 0
	for i, v in pairs(self.chat_list) do
		height = height + v.height
	end
	self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x,height)
	local y = height - self.rectTra.sizeDelta.y
	local height2 = 0
	for i, v in pairs(self.chat_list) do
		if v.is_loaded then
			v.itemRectTra.localPosition = Vector3(0,-height2,0)
			v.y = height2
			height2 = height2 + v.height
		end
	end
	self.contentRectTra.localPosition = Vector2(self.contentRectTra.anchoredPosition.x,y,0)
end

function GuildQuestionPanel:QuestionFinish()
	RankController:GetInstance():RequestRankListInfo(self.model.rank_id, 1)
	self.model:Brocast(GuildHouseEvent.QuestionEnd)
end

function GuildQuestionPanel:NextUpdate(timeTab)
	if timeTab.sec <= 5 then
		SetVisible(self.countdown2, true)
	end
end