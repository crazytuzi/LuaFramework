

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local Quest = require 'Zeus.Model.Quest'
local _M = {}
_M.__index = _M

local MOCK = nil
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
	new_state1 = Util.GetText(TextConfig.Type.QUEST,'new_state1'),
	complete_state1 = Util.GetText(TextConfig.Type.QUEST,'complete_state1'),
	complete_state = Util.GetText(TextConfig.Type.QUEST,'complete_state'),
	progress_state = Util.GetText(TextConfig.Type.QUEST,'progress_state'),
	progress_state1 = Util.GetText(TextConfig.Type.QUEST,'progress_state1'),
	btn_text_directly = Util.GetText(TextConfig.Type.QUEST,'btn_text_directly'),
	giveup_quest = Util.GetText(TextConfig.Type.QUEST,'giveup_quest'),
	complete_all_main = Util.GetText(TextConfig.Type.QUEST,'complete_all_main')
	
}

local function GetTypeQuestInfo(self,t)
	return self.quests_map[t]
end

local function GetTitleColor(lvLimit)
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  return Util.GetQualityColorRGBA(GameUtil.Quality_Default)
end

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

local function GetProgressFormat(quest,append,index)
	local fp = quest:GetFormatProgress(index)
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

local function GetQuestTitleFormat(quest)
	local c = GetTitleColor(quest:GetIntParam("Level"))
	local txt = quest:GetStringParam("Name")
	return c,txt
end

local function SetQuestDetail(self)
	self.cvs_right.Visible = true
	local quest = self.select_quest
    local index = 0
	local txt1 = quest:GetStringParam('Name')
    local sPos,ePos = string.find(txt1,"{0}")
    local questType = tonumber(quest:GetStringParam('Kind'))

    if(sPos and sPos > 1) then
        local s1 = string.sub(txt1,1,sPos-1)
        local s2 = string.sub(txt1,ePos+1,string.len(txt1))
        
        txt1 = s1 .. "%d"..s2
        txt1 = string.format(txt1,quest.Progress[0])
        index = index + 1
    end
    self.lb_right_title_name.Text = txt1

    if questType == 3 then
    	local data = GlobalHooks.DB.Find('CircleReward',{Lv=DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)})[1]
    	self.lb_gold.Text = tostring(data.Gold)
		self.lb_exp.Text = tostring(data.Exp)
		self.lb_xiuwei.Text = tostring(data.Cul)
    elseif questType == 2 then 
    	local data = GlobalHooks.DB.Find('DailyReward',{Lv=DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)})[1]
    	self.lb_gold.Text = tostring(data.Gold)
		self.lb_exp.Text = tostring(data.Exp)
		self.lb_xiuwei.Text = tostring(data.Cul)
    else
		local needexp = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.NEEDEXP)
		local exp = quest:GetIntParam('Exp') + quest:GetIntParam('ExpRatio') * needexp / 10000
		self.lb_gold.Text = tostring(quest:GetStringParam('Gold'))
		self.lb_exp.Text = tostring(math.floor(exp))
		self.lb_xiuwei.Text = tostring(quest:GetStringParam('UpExp'))
	end

	
	local Des = quest:GetStringParam('Des')
	self.tb_describe.XmlText = string.format("<f>%s</f>",Des)
	
	local c,txt1,txt2 = GetProgressFormat(quest,true,index)

	local prompt = quest:GetTargetString()

	c = Util.GetQualityColorARGB(c)
	prompt = string.format("<f>%s<f color='%x'>%s</f></f>",prompt,c,txt1)

	self.tb_target.XmlText = prompt
	
	local RewardName = quest:GetStringParam('RewardName')
	local rewards = string.split(RewardName,'|')

		
	local pro = DataMgr.Instance.UserData.Pro
	
	
	
	
	
	local pro_defined = {
		[1] = 'WarriorReward',
		[2] = 'AssassinReward',
		[3] = 'MagicianReward',
		[4] = 'HunterReward',
		[5] = 'MinisterReward',
	}

	local pro_rewardName = quest:GetStringParam(pro_defined[pro])
	local pro_rewards = string.split(pro_rewardName,'|')
	for _,v in ipairs(pro_rewards) do
		if v ~= '' then
			table.insert(rewards,1,v)
		end
	end

	for i=1,4 do	
		local check = i <= #rewards and rewards[i] ~= ''
		self['cvs_reward'..i].Visible = check
		if check then
			local tmp = string.split(rewards[i],':')
			
			local code = tmp[1] 
			local num = tmp[2] or 1
			local detail = ItemModel.GetItemDetailByCode(code)
			local cvs_gift = self['cvs_gift'..i]
			if detail then			
				
				
				cvs_gift.Visible = true
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
			else
				
				cvs_gift.Visible = false
			end
		end		
	end
	
	
	
	self.btn_giveup.Visible = (quest.Type ~= QuestData.QuestType.TRUNK and quest.Type ~= QuestData.QuestType.BRANCH)

	self.btn_take.Visible = false
	self.btn_go.Visible = true
	self.cvs_autofinish.Visible = false
	if quest.State == QuestData.QuestStatus.CAN_FINISH then
		
		local npcid = quest:GetIntParam('CompleteNpc')
        
		if npcid == 0 then
			self.btn_take.Visible = true
			self.btn_go.Visible = false
			local text1 = quest:GetStringParam('RewardBtn')
			if not text1 or text1 == '' then
				text1 = Text.btn_text_directly
			end
			self.btn_take.Text = text1
			
			if quest:GetIntParam('IsDouble') == 1 then
				self.cvs_autofinish.Visible = true
				self.tb_cost.XmlText = string.format(Text.costDiamond,quest:GetIntParam('DoubleCost'))
				self.btn_money.Text = Text.btn_double_complete
				self.btn_money.TouchClick = function (sender)
					Quest.CompleteRequest(self.select_quest,1,0)
				end
			end
			self.btn_take.TouchClick = function (send)
				Quest.CompleteRequest(self.select_quest,0,0)
			end
		end
	elseif quest.State == QuestData.QuestStatus.IN_PROGRESS then
		
		if quest:GetIntParam('IsFastComplete') == 1 then
			self.cvs_autofinish.Visible = true
			self.tb_cost.XmlText = string.format(Text.costDiamond,quest:GetIntParam('FastCompleteCost'))
			self.btn_money.Text = Text.btn_quick_complete
			self.btn_money.TouchClick = function (sender)
				Quest.QuickFinishRequest(self.select_quest,0)
			end
		end
	elseif quest.State == QuestData.QuestStatus.NEW and CheckAccepetState(quest) ~= 0 then
		
		self.btn_go.Visible = false
	end
end

local function FindQuestListItem(self,questid)
	local child_list = self.sp_mission.Scrollable.Container:GetAllChild()
	local children = Util.List2Luatable(child_list)
	for _,v in ipairs(children) do
		if v.UserTag == questid then
			return v
		end
	end
	return nil
end

local function OnSelectQuest(self,quest)
	if not quest then return end
	if self.select_quest then
		local item_node = FindQuestListItem(self,self.select_quest.TemplateID)
		if item_node then
			local tbt_main = item_node:FindChildByEditName('tbt_main',false)
			tbt_main.IsChecked = false
		end
	end
	self.select_quest = quest
	self.last_quest_id = quest.TemplateID
	
	
	SetQuestDetail(self)
end

local function GetTypeText(t)
	local t = Util.GetText(TextConfig.Type.QUEST,'type'..t)
	local txt = t..Text.btn_quest
	return txt	
end

local function SetQuestListItem(self,node,quest)
	local lb_branch_name = node:FindChildByEditName('lb_branch_name',false)
	local lb_progress = node:FindChildByEditName('lb_progress',false)
	local tbt_main = node:FindChildByEditName('tbt_main',false)
	tbt_main:SetBtnLockState(HZToggleButton.LockState.eLockSelect)

	local c1,txt1 = GetQuestTitleFormat(quest)
    local index = 0
    local sPos,ePos = string.find(txt1,"{0}")
    if(sPos and sPos > 1) then
        local s1 = string.sub(txt1,1,sPos-1)
        local s2 = string.sub(txt1,ePos+1,string.len(txt1))
        txt1 = s1 .. "%d"..s2
        txt1 = string.format(txt1,quest.Progress[index])
        index = index + 1
    end
    
	lb_branch_name.FontColorRGBA = c1
	
	
	local int_type = GameUtil.TryEnumToInt(quest.Type)
	lb_branch_name.Text = (Util.GetText(TextConfig.Type.QUEST,'type_short'..int_type) ..txt1)

	
	local c2,txt2 = GetProgressFormat(quest,nil,index)
	lb_progress.FontColorRGBA = Util.GetQualityColorRGBA(c2)
	lb_progress.Text = txt2	
	tbt_main.IsChecked = self.select_quest == quest
	tbt_main.TouchClick = function (sender)
		if sender.IsChecked then
			OnSelectQuest(self,quest)
		end
	end
	node.UserTag = quest.TemplateID
end

local function ResetPosition(self)
	local nodes = {}
	if not self.main_quest then
		self.cvs_detail.Visible = false
		self.lb_finishall.Visible = true
		
	else
		self.cvs_detail.Visible = true
		
		self.lb_finishall.Visible = false
		self.cvs_othermiss.Y = self.cvs_main.Y + self.cvs_main.Height
	end

	local y = self.cvs_other_mission.Y
	for k,v in pairs(self.quests_map) do
		v.node.Y = y
		y = y + v.node.Height
		local tbt_open = v.node:FindChildByEditName('tbt_open',false)
		local tbt_open1 = v.node:FindChildByEditName('tbt_open1',false)
		if self.select_type ~= nil and self.select_type == k then
			
			self.cvs_mifr.Y = y
			y = y + self.cvs_mifr.Height
			tbt_open.IsChecked = true
		else
			tbt_open.IsChecked = false
		end
		tbt_open1.IsChecked = tbt_open.IsChecked
	end
	self.cvs_mifr.Visible = self.select_type ~= nil
end


local function ResetQuestShowList(self,t)
	
	self.select_type = QuestData.QuestType.DAILY;
	if t then
		local quests_list = DataMgr.Instance.QuestManager:GetAcceptedList()
		local quests = Util.List2Luatable(quests_list)
		table.sort(quests, function(a,b) return a.TemplateID<b.TemplateID end )
		
		self.sp_mission.Scrollable:ClearGrid()
		if self.sp_mission.Rows <= 0 then
			self.sp_mission.Visible = true
			local cs = self.cvs_missname.Size2D
			self.sp_mission:Initialize(cs.x,cs.y,#quests,1,self.cvs_missname,
			function (gx,gy,node)
				
				local quest = quests[gy+1]
				node.Name = quest:GetStringParam("Name")
				SetQuestListItem(self,node,quest)
			end,function ()	end)
		else
			self.sp_mission.Rows = #quests
		end
	end	
	
	
	



















	ResetPosition(self)
end

local function SwithSelectType(self,is_select,t)
	if is_select then
		
		ResetQuestShowList(self,t)
	elseif self.select_type == t then
		ResetQuestShowList(self,nil)
	end	
end

local function AddTypeNode(self,t)
	local node 
	if #self.quests_map == 0 then
		node = self.cvs_other_mission
	else
		node = self.cvs_other_mission:Clone()
		self.cvs_other_mission.Parent:AddChild(node)
	end
	local tbt_open = node:FindChildByEditName('tbt_open',false)
	local tbt_open1 = node:FindChildByEditName('tbt_open1',false)

	tbt_open.Enable = false
	tbt_open.IsChecked = false
	tbt_open.Visible = false
	tbt_open1.Enable = false
	tbt_open1.IsChecked = false
	

	local int_type = GameUtil.TryEnumToInt(t)
	node.UserTag = int_type
	














	local lb_name = node:FindChildByEditName('lb_name',false)
	lb_name.Text = GetTypeText(int_type)
	local info = {node = node,quests = {}}

	self.quests_map[int_type] = info
	return info
end

local function UpdateTypeQuests(self,quest)
	local type_info = self.quests_map[GameUtil.TryEnumToInt(quest.Type)]
	if not type_info then
		type_info = AddTypeNode(self,quest.Type)
	end
	local has = false
	for _,q in ipairs(type_info.quests) do
		if q == quest then
			has = true
			break
		end
	end
	if not has then
		table.insert(type_info.quests,quest)
	end
end


local function AutoSelectQuest(self)
	self.select_quest = nil
    
	
	if not self.select_type or (not self.quests_map[self.select_type]) or #self.quests_map[self.select_type].quests == 0 then
		
		self.select_type = nil
		for k,v in pairs(self.quests_map) do
			if #v.quests > 0 then
				ResetQuestShowList(self,k)
				break
			end
		end
		
		
	end












	local trunk_quest = DataMgr.Instance.QuestManager:GetTrunkQuest()
	if trunk_quest then 
		self.select_type = QuestData.QuestType.DAILY
	end
	
	if not self.select_type then
		
		
		
		ResetQuestShowList(self,nil)
		self.cvs_right.Visible = false
	else
		
		local q = DataMgr.Instance.QuestManager:GetTrunkQuest()
		if q == nil then
			local type_info = self.quests_map[self.select_type]
			q = type_info.quests[1]
		end
		OnSelectQuest(self,q)
		ResetQuestShowList(self,self.select_type)
	end

	if not self.select_quest then
		
	end
end

local function FillQuest(self)
	self.select_type = nil
	local quests_list = DataMgr.Instance.QuestManager:GetAcceptedList()
	local quests = Util.List2Luatable(quests_list)
	for _,v in ipairs(quests) do
		if v.Type ~= QuestData.QuestType.TRUNK  and v.Type ~= QuestData.QuestType.DAILY then
			UpdateTypeQuests(self,v)
		end
	end
end

local function DiscardQuest(self,quest)
	if MOCK then
		DataMgr.Instance.QuestManager:UpdateQuestMock(quest.TemplateID,
			quest.Progress,
			GameUtil.TryEnumToInt(QuestData.QuestStatus.NONE),
			quest.LeftTime
			)
		return
	end
	Quest.DiscardRequest(quest)
end

local function OnEnter(self)
  
  self.quests_map = {}
  self.sp_quest_nodes = {}
  self.cvs_reward1.Visible = false
  self.cvs_reward2.Visible = false
  self.cvs_reward3.Visible = false
  self.cvs_reward4.Visible = false

  DataMgr.Instance.QuestManager:AttachLuaObserver(self.menu.Tag,self)
  
  AddTypeNode(self,QuestData.QuestType.DAILY)
  FillQuest(self)
end


local function OnExit(self)
  
  for k,v in pairs(self.quests_map) do
  	if v.node ~= self.cvs_other_mission then
  		v.node:RemoveFromParent(true)
  	end
  end
  self.quests_map = nil
  self.sp_quest_nodes = nil
  DataMgr.Instance.QuestManager:DetachLuaObserver(self.menu.Tag)
end

local function OnDestory(self)
  
end

local ui_names = 
{
	{name = 'ib_titleleft'},
	{name = 'ib_titleright'},
	{name = 'ib_progress'},
	{name = 'lb_finishall'},
	{name = 'tbt_main_quest'},
	{name = 'sp_mission'},
	{name = 'cvs_detail'},
	{name = 'cvs_missionpanel'},
	{name = 'cvs_missframe'},
	{name = 'cvs_title'},
	{name = 'cvs_main'},
	{name = 'cvs_main_title'},
	{name = 'cvs_othermiss'},
	{name = 'cvs_branch'},
	{name = 'cvs_mifr'},
	{name = 'cvs_progress'},
	{name = 'cvs_other_mission'},
	{name = 'cvs_missname'},
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
	{name = 'tb_describe'},
	{name = 'tb_target'},
	{name = 'btn_close',click = Close},
	{name = 'btn_take'},
	{name = 'btn_money'},
	{name = 'btn_return',click = Close},
	{name = 'btn_giveup',click = function (self)
		GameAlertManager.Instance:ShowAlertDialog(
			AlertDialog.PRIORITY_NORMAL,
			Text.giveup_quest,'','',
			nil,
			function ()
				DiscardQuest(self,self.select_quest)
			end,
			function ()
				
			end
	  )	
	end},
	{name = 'btn_go',click = function (self)
		Close(self)
		self.select_quest:Seek()
		
		
	end},
	{name = 'lb_exp'},
	{name = 'lb_gold'},
	{name = 'lb_xiuwei'},
	{name = 'lb_title'},
	{name = 'lb_main'},
	{name = 'lb_mainname'},
	{name = 'lb_isfinish'},
	{name = 'lb_content'},
	{name = 'lb_name'},
	{name = 'lb_branch_name'},
	{name = 'lb_isfinish'},
	{name = 'lb_right_title_name'},
	{name = 'lb_tar'},
	{name = 'lb_word'},
	{name = 'tb_cost'},
	
	
	
	
}



local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/new_mission/new_mission.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.cvs_missname.Visible = false
	self.tbt_main_quest:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.menu.ShowType = UIShowType.HideBackHud
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
  self.sp_mission.ShowSlider = true
  self.tb_cost.TextComponent.Anchor = TextAnchor.C_C
	self.cvs_main.TouchClick = function (sender)
		if not self.cvs_detail.Visible then
			GameAlertManager.Instance:ShowNotify(Text.complete_all_main)
		end
	end
  
  
  
  

  
  
  
  
  
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function Notify(status,questMgr,self)
	local questid = status
	local q = questMgr:GetQuest(questid)



	if q.State == QuestData.QuestStatus.DONE 
		or q.State == QuestData.QuestStatus.NONE then
		
		if q ~= self.main_quest then
			local int_type = GameUtil.TryEnumToInt(q.Type)
			local type_info = self.quests_map[int_type]
			if type_info then
				for i,v in ipairs(type_info.quests) do
					if v == q then
						table.remove(type_info.quests,i)
						break
					end
				end
			end
		end
		if self.select_quest == q then
			if self.select_quest == self.main_quest then
				self.main_quest = nil
			end
			AutoSelectQuest(self)
		end
	elseif q.State == QuestData.QuestStatus.CAN_FINISH 
		or q.State == QuestData.QuestStatus.IN_PROGRESS then
		if self.select_quest == q then
			
			SetQuestDetail(self,q)
		end
		
		
		local node = FindQuestListItem(self,q.TemplateID)
		if node then
			SetQuestListItem(self,node,q)
		else
			local int_type = GameUtil.TryEnumToInt(q.Type)
			UpdateTypeQuests(self,q)
			if self.select_type == int_type then			
				ResetQuestShowList(self,int_type)
			end
		end

	elseif q.State == QuestData.QuestStatus.NEW then
		if q.Type == QuestData.QuestType.TRUNK then
			
			
		
		 	UpdateTypeQuests(self,q)
		
		
		
		end
	end
end

local function SelectQuest(self,templateId)
	local q = DataMgr.Instance.QuestManager:GetQuest(templateId)	
	
	if not q then
		AutoSelectQuest(self)
	else
		OnSelectQuest(self,q)
		local int_type = GameUtil.TryEnumToInt(q.Type)
		ResetQuestShowList(self,int_type)
	end
end

local function OnShowGameUIQuest(ename,params)
	local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIQuest,0)
	if params.id then
		obj.last_quest_id = tonumber(params.id) 
	end
	if obj.last_quest_id then
		SelectQuest(obj,obj.last_quest_id)
	else
		AutoSelectQuest(obj)
	end
end

local function initial()
	EventManager.Subscribe("Event.ShowGameUIQuest",OnShowGameUIQuest)


end

_M.initial = initial
_M.Create = Create
_M.Close  = Close
_M.Notify = Notify

return _M
