-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenTask2 = i3k_class("wnd_petWakenTask2",ui.wnd_base)
local LAYER_SCLBT = "ui/widgets/jxrw2t"
local star_icon = {405,409,410,411,412,413}
local BtnType1 = 1;
local BtnType2 = 2;
function wnd_petWakenTask2:ctor()
	self._playPets = {}
	self._Pets = {}
	self._task = nil;
	self._topDes = {}
end

function wnd_petWakenTask2:configure(...)
	local widgets	= self._layout.vars
	self.name		= widgets.name;
	self.icon		= widgets.icon;
	self.iconBg		= widgets.iconBg;
	self.des		= widgets.des;
	self.stepDes	= widgets.stepDes;
	self.targetDes	= widgets.targetDes;
	self.stepBtn	= widgets.stepBtn;	
	self.scroll		= widgets.scroll;
	self.model		= widgets.model;
	self.okBtn		= widgets.okBtn
	self.cancelBtn	= widgets.cancelBtn
	self.topDes		= widgets.topDes;
	self.achieveTxt	= widgets.achieveTxt
	for i = 1,3 do
		self._topDes[i]		= widgets["topDes"..i];
	end
	widgets.closeBtn:onClick(self, self.onCloseUI)	
	widgets.cancelBtn:onClick(self, self.onCancelBtn)
end

function wnd_petWakenTask2:refresh(id)
	self:updateDate(id)
	self:updateScroll(id);
end

function wnd_petWakenTask2:onAchieveBtn(sender, btnType)
	if g_i3k_game_context:IsInRoom() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16893))
	else
		if btnType == BtnType1 and self._task then
			local pets = {};
			for k,v in pairs(self._playPets) do
				table.insert(pets, v)
			end
			if self._task and self._task.taskArg.Arg1 then
				if #pets < 3  then
					local tmp_str = i3k_get_string(16835)
					local fun = (function(ok)
						if ok then
							i3k_sbean.petAwakeMap(self._id, self._task.taskArg.Arg1, pets);
						end
					end)
					g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(16836),i3k_get_string(1140), tmp_str, fun) 
				else
					i3k_sbean.petAwakeMap(self._id, self._task.taskArg.Arg1, pets);
				end
			end
		elseif btnType == BtnType2 and self._id > 0 then
			i3k_sbean.awakeTaskFinish(self._id, g_TaskType2)
		end
	end
end	

function wnd_petWakenTask2:onCancelBtn(sender)
	if self._id > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenGiveUp)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenGiveUp, g_TaskType2)
	end
end	

function wnd_petWakenTask2:onStepBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenStep)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenStep)
end	

function wnd_petWakenTask2:updateScroll(id)
	self._isSelect = {}
	local width = self.scroll:getContentSize().width
	local height = self.scroll:getContentSize().height
	local allPets, playPets = g_i3k_game_context:GetYongbingData(true)
	local allPets, playPets = g_i3k_game_context:GetYongbingData(true)
	local petsCount = {}
	for i,v in ipairs(allPets) do
		if v.id ~= id then
			table.insert(petsCount, v)
		end
	end
	
	local children = self.scroll:addChildWithCount("ui/widgets/jxrw2t", 4, #petsCount)
	self.scroll:setBounceEnabled(false)
	
	for i,v in ipairs(children) do
		local id = petsCount[i].id
		local lvl = petsCount[i].level
		local star =  petsCount[i].starlvl
		local name = i3k_db_mercenaries[id].name
		local iconid = g_i3k_db.i3k_db_get_head_icon_id(id)
		if g_i3k_game_context:getPetWakenUse(id) then
			iconid = i3k_db_mercenariea_waken_property[id].headIcon;
		end
		v.vars.pet_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconid, true))
		v.vars.pet_iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		v.vars.level_label:setText(lvl)
		v.vars.start_icon:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[star+1]))
		local mercenaryPower = g_i3k_game_context:getBattlePower(id)
		v.vars.pet_power:setText(mercenaryPower)
		v.vars.play_btn:setTag(i+1000)
		table.insert(self._isSelect, v.vars.isSelect)
		v.vars.isSelect:hide()
		v.vars.play_btn:onClick(self,self.onPetPlay, id)
	end
end

function wnd_petWakenTask2:onPetPlay(sender, id)
	local index = sender:getTag()-1000
	local count = 0;
	for k,v in pairs(self._playPets) do
		count = count + 1;
	end
	local isSelect = self._isSelect[index]
	local isShow = isSelect:isVisible()
	if count < 3 or isShow then
		if isShow then
			isSelect:hide()
			self._playPets[id] = nil;
		else
			self._playPets[id] = id;
			isSelect:show()
		end
	end
end

function wnd_petWakenTask2:updateDate(id)
	local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id);
	local task = g_i3k_game_context:getPetWakenTask(id)
	if cfg_data and task then
		local state = g_i3k_game_context:getPetWakenTaskState(id);
		self._id = id;
		self._task = task;
		self.topDes:setText("第二步："..task.taskName);
		self.des:setText(task.teskDes1);
		self.name:setText(cfg_data.name)
		self.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(cfg_data.icon, true))
		self.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		self:showModel(task.taskArg.Arg3);
		for i,e in ipairs(i3k_db_mercenariea_waken_task[id]) do
			self._topDes[i]:setText(e.taskName);
		end
		if state == g_TaskState2 then
			self.achieveTxt:setText("完成");
			self.okBtn:onClick(self, self.onAchieveBtn, BtnType2)
		else
			self.achieveTxt:setText("挑战");
			self.okBtn:onClick(self, self.onAchieveBtn, BtnType1)	
		end	
	end
end

function wnd_petWakenTask2:showModel(id)
	local modelID = i3k_db_monsters[id].modelID;
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction("stand")
	self.model:setRotation(2);
end

function wnd_create(layout)
	local wnd = wnd_petWakenTask2.new()
	wnd:create(layout)
	return wnd
end
