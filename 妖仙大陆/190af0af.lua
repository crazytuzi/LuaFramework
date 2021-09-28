

local Helper    = require 'Zeus.Logic.Helper'
local Util      = require 'Zeus.Logic.Util'
local Quest     = require 'Zeus.Model.Quest'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M

local function Close(self)
  self.menu:Close()  
end



local Text = {
  costDiamond = Util.GetText(TextConfig.Type.ITEM,'costDiamond'),
  btn_double_complete = Util.GetText(TextConfig.Type.QUEST,'btn_double_complete'),
  btn_quick_complete = Util.GetText(TextConfig.Type.QUEST,'btn_quick_complete'),
  btn_quest = Util.GetText(TextConfig.Type.QUEST,'btn_quest'),
  complete_all = Util.GetText(TextConfig.Type.QUEST,'complete_all'),
	complete_state = Util.GetText(TextConfig.Type.QUEST,'complete_state'),
  complete_state1 = Util.GetText(TextConfig.Type.QUEST,'complete_state1'),
	uplv_limit = Util.GetText(TextConfig.Type.QUEST,'uplv_limit'),
  lv_limit = Util.GetText(TextConfig.Type.QUEST,'lv_limit'),
	new_state = Util.GetText(TextConfig.Type.QUEST,'new_state'),
	complete_state1 = Util.GetText(TextConfig.Type.QUEST,'complete_state1'),
	complete_state = Util.GetText(TextConfig.Type.QUEST,'complete_state'),
	progress_state = Util.GetText(TextConfig.Type.QUEST,'progress_state'),
	progress_state1 = Util.GetText(TextConfig.Type.QUEST,'progress_state1'),
	btn_accept = Util.GetText(TextConfig.Type.QUEST,'btn_accept'),
	btn_text_directly = Util.GetText(TextConfig.Type.QUEST,'btn_text_directly'),
	complete_quest = Util.GetText(TextConfig.Type.QUEST,'complete_quest'),
	new_quest = Util.GetText(TextConfig.Type.QUEST,'new_quest'),
}

local function CheckAccepetState(quest)
  local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
  local upLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
  local q_lv = quest:GetIntParam('Level')
  local q_uplv = quest:GetIntParam('UpOrder')	
  if q_uplv > 0 and upLv < q_uplv then
  	return -1
  elseif q_lv > 0 and lv < q_lv then
  	return -2
  else
  	return 0
  end  
end

local function GetProgressFormat(quest,append)
	local fp = quest:GetFormatProgress(0)
	if quest.State == QuestData.QuestStatus.CAN_FINISH then
		
		if append then
			return GameUtil.Quality_Green,(fp or ''),Text.complete_state
		else
			return GameUtil.Quality_Green,Text.complete_state1
		end
	elseif quest.State == QuestData.QuestStatus.NEW then
		if append then
			local s = CheckAccepetState(quest)
			if s == -1 then
				return GameUtil.Quality_Default,'',Text.uplv_limit
			elseif s == -2 then
				return GameUtil.Quality_Default,'',Text.lv_limit
			else
				return GameUtil.Quality_Default,'',Text.new_state
			end		
		else
			return GameUtil.Quality_Default,''
		end
	else
		
		if append then
			return GameUtil.Quality_Default,(fp or ''),Text.progress_state
		else
			return GameUtil.Quality_Default,fp or Text.progress_state1
		end
	end
end

local function SetQuestDetail(self,quest)
	self.lb_right_title_name.Text = quest:GetStringParam('Name')

	self.lb_gold.Text = tostring(quest:GetStringParam('Gold'))
	self.lb_exp.Text = tostring(quest:GetStringParam('Exp'))

	self.btn_close.Visible = true
	
	local Des
	
	local c,txt1,txt2 = GetProgressFormat(quest,true)
	print('SetUpQuestDetail',txt1,quest.State)
	local prompt = quest:GetStringParam('Prompt')
	prompt = string.format(prompt,tostring(quest:GetIntParam("Quantity")))

	c = Util.GetQualityColorARGB(c)
	prompt = string.format("<f>%s<f color='%x'>%s</f></f>",prompt,c,txt1)
	
	self.tb_target.XmlText = prompt

	self.btn_go.TouchClick = function (sender)
		quest:Seek()
	end

	
	local RewardName = quest:GetStringParam('RewardName')
	local rewards = string.split(RewardName,'|')
	for i=1,4 do
		local check = i <= #rewards and rewards[i] ~= ''
		self['cvs_reward'..i].Visible = check
		if check then
			local tmp = string.split(rewards[i],':')
			
			local code = tmp[1] 
			local num = tmp[2] or 1
			local detail = ItemModel.GetItemDetailByCode(code)
			local cvs_gift = self['cvs_gift'..i]
			
			
			local itshow = Util.ShowItemShow(cvs_gift,detail.static.Icon,detail.static.Qcolor,num)
			itshow.EnableTouch = true
			itshow.event_PointerDown = function (sender) 
				itshow.IsSelected = true
				Util.ShowItemDetailTips(itshow,ItemModel.GetItemDetailByCode(code))
			end
			itshow.event_PointerUp = function (sender)
				itshow.IsSelected = false
				GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
			end
		end		
	end
	local check = (quest.State == QuestData.QuestStatus.IN_PROGRESS 
								and quest.Type ~= QuestData.QuestType.TRUNK)
	self.btn_giveup.Visible = check

	self.btn_take.Visible = false
	self.btn_money.Visible = false
	self.btn_go.Visible = false
	if quest.State == QuestData.QuestStatus.CAN_FINISH then
		self.lb_title.Text = Text.complete_quest
		
		local npcid = quest:GetIntParam('CompleteNpc')

		if npcid == 0 then
			Des = quest:GetStringParam('RewardSys')
			self.btn_take.Visible = true
			self.btn_take.Text = Text.btn_text_directly
			
			if quest:GetIntParam('IsDouble') == 1 then
				self.cvs_autofinish.Visible = true
				self.tb_cost.XmlText = string.format(Text.costDiamond,quest:GetIntParam('DoubleCost'))
				self.btn_money.Text = Text.btn_double_complete
				self.btn_money.TouchClick = function (sender)
					Quest.CompleteRequest(quest,1,0)
					Close(self)
				end
			end
			self.btn_take.TouchClick = function (send)
				Quest.CompleteRequest(quest,0,0)
				Close(self)
			end
		else
			self.btn_go.Visible = true
		end
	elseif quest.State == QuestData.QuestStatus.IN_PROGRESS then
		
		if quest:GetIntParam('IsFastComplete') == 1 then
			self.cvs_autofinish.Visible = true
			self.tb_cost.XmlText = string.format(Text.costDiamond,quest:GetIntParam('FastCompleteCost'))
			self.btn_money.Text = Text.btn_quick_complete
			self.btn_money.TouchClick = function (sender)
				Quest.QuickFinishRequest(quest,0)
				Close(self)
			end
		end 
	elseif quest.State == QuestData.QuestStatus.NEW then
		Des = quest:GetStringParam('AcceptSys')
		
		if CheckAccepetState(quest) == 0 then
			self.lb_title.Text = Text.new_quest
			self.btn_take.Visible = true
			local text1 = quest:GetStringParam('AcceptBtn')
			if not text1 or text1 == '' then
				text1 = Text.btn_accept
			end			
			self.btn_take.Text = text1
			if quest.Type == QuestData.QuestType.TRUNK then
				self.btn_close.Visible = false
			end
			self.btn_take.TouchClick = function (sender)
				Quest.AcceptRequest(quest,0)
				Close(self)
			end
		end
	end
	if not Des or Des == '' then
		Des = quest:GetStringParam('Des')
	end
	print('Des',Des)
	self.tb_describe.XmlText = string.format("<f>%s</f>",Des)
end

local function OnEnter(self)
  
end

local function OnExit(self)
  
end

local function OnDestory(self)
  
end

local ui_names = 
{
	{name = 'lb_title'},
	{name = 'lb_right_title_name'},
	{name = 'lb_tar'},
	{name = 'lb_word'},
	{name = 'tb_cost'},
	{name = 'lb_exp'},
	{name = 'lb_gold'},
	{name = 'lb_number'},
	
	
	
	
	{name = 'ib_titleleft'},
	{name = 'ib_titleright'},
	{name = 'ib_icon'},
	{name = 'tb_describe'},
	{name = 'tb_target'},
	{name = 'btn_close',click = Close},
	{name = 'btn_giveup'},
	{name = 'btn_go'},
	{name = 'btn_money'},
	{name = 'btn_take'},
	{name = 'cvs_curmiss'},
	{name = 'cvs_missframe'},
	{name = 'cvs_title'},
	{name = 'cvs_right'},
	{name = 'cvs_describe'},
	{name = 'cvs_target'},
	{name = 'cvs_reward'},
	{name = 'cvs_autofinish'},
	{name = 'cvs_reward1'},
	{name = 'cvs_gift1'},
	{name = 'cvs_reward2'},
	{name = 'cvs_gift2'},
	{name = 'cvs_reward3'},
	{name = 'cvs_gift3'},
	{name = 'cvs_reward4'},
	{name = 'cvs_gift4'},
}


local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/new_mission/new_mission_open.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.tb_cost.TextComponent.Anchor = TextAnchor.C_C
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function OnShowQuestDetail(eventname,params)
	
	local quest = DataMgr.Instance.QuestManager:GetQuest(params.id)
	if quest then
		local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIQuestDetail,0)
		obj:SetQuestDetail(quest)
	end
end


local function initial()
	
end

_M.Create = Create
_M.Close  = Close
_M.initial = initial
_M.SetQuestDetail = SetQuestDetail
return _M
