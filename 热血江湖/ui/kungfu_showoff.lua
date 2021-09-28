module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_kungfu_showOff = i3k_class("wnd_kungfu_showOff", ui.wnd_base)

function wnd_kungfu_showOff:ctor()
	self.bqData = {}
	self.chatState = {}
end

function wnd_kungfu_showOff:configure()
	local widgets = self._layout.vars
--    widgets.imgBK:onClick(self,self.onClose)
	widgets.ok:onClick(self,self.finish)
	widgets.cancel:onClick(self,self.onClose)
	--bq_btn
	self.bq_img = {widgets.bq1,widgets.bq2,widgets.bq3}
	self.bq_btn = {widgets.bq1_btn,widgets.bq2_btn,widgets.bq3_btn}
	self.chatType_btn = {widgets.world_btn,widgets.sect_btn,widgets.team_btn}
	self.chatType_img = {widgets.world_img,widgets.sect_img,widgets.team_img}
	self:updateSendType(1)
	for i=1,3 do
		self.bq_img[i]:hide()
		self.bq_btn[i]:setTag(i)
		self.bq_btn[i]:onClick(self,self.choosebq)
		self.chatType_btn[i]:setTag(i)
		self.chatType_btn[i]:onClick(self,self.selectType)
		local isVisible = self.chatType_img[i]:isVisible()
		if isVisible then
			table.insert(self.chatState,1)
		else
			table.insert(self.chatState,0)
		end
	end
end

function wnd_kungfu_showOff:refresh(pos)
	self.skillPos = pos
	self:initScroll()
end

function wnd_kungfu_showOff:initScroll()
	local ScrollView = self._layout.vars.scroll 
	local children = ScrollView:addChildWithCount("ui/widgets/ltbqt",6,16)
	for i,e in ipairs(children) do
		local imgIcon = g_i3k_db.i3k_db_get_icon_path(1400+i)
		e.vars.bqImg:setImage(imgIcon)
		e.vars.btn:setTag(i)--图片的id
		e.vars.btn:onClick(self,self.onSendBq)
	end
end

function wnd_kungfu_showOff:updateBq(id)
	local imgIcon = g_i3k_db.i3k_db_get_icon_path(1400+id)
	for i,e in ipairs(self.bq_img) do
		local isVisible = e:isVisible()
		if not isVisible then
			table.insert(self.bqData,id)
			e:setImage(imgIcon)
			e:show()
			break;
		end
	end
end

function wnd_kungfu_showOff:updateSendType(tag)
	for i=1,3 do
		if i == tag then
			self.chatType_img[i]:show()
			self.chatState[i] = 1
		else
			self.chatType_img[i]:hide()
			self.chatState[i] = 0
		end
	end
end

function wnd_kungfu_showOff:checkInputType(sendType)
	local canSend = true
	local isHaveTime = false
	local text = ""
	local timeNow = i3k_game_get_time()
	if sendType==0 then
		canSend = false
		text = "本频道不能发言，请去其他频道。"
	elseif sendType==1 then
		local needItemId = i3k_db_common.chat.worldNeedId
		local count = g_i3k_game_context:GetCommonItemCanUseCount(needItemId)
		if count<=0 then
			canSend = false
			text=i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(needItemId))
		else
			local sendTime = g_i3k_game_context:GetWorldSendTime()
			if sendTime == nil then
				isHaveTime = true	
			else
				if timeNow-sendTime>=i3k_db_common.chat.timeWorld then
					isHaveTime = true	
				end
			end
		end
	elseif sendType==2 then
		local sectId = g_i3k_game_context:GetSectId()
		if sectId <= 0 then
			canSend = false
			text = "您当前没有加入帮派，无法发言"
		else
			local sendTime = g_i3k_game_context:GetSectSendTime()
			if sendTime == nil then
				isHaveTime = true	
			else
				if timeNow-sendTime>=i3k_db_common.chat.timeTeamSect then
					isHaveTime = true
				end
			end
		end
	elseif sendType==3 then
		local teamId = g_i3k_game_context:GetTeamId()
		if teamId <= 0 then
			canSend = false
			text = "您当前没有队伍，无法发言"
		else
			local sendTime = g_i3k_game_context:GetTeamSendTime()
			if sendTime == nil then
				isHaveTime = true	
			else
				if timeNow-sendTime>=i3k_db_common.chat.timeTeamSect then
					isHaveTime = true
				end
			end
		end
	end
	if not canSend then
		g_i3k_ui_mgr:PopupTipMessage(text)
	else
		if not isHaveTime then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
		end
	end
	return canSend,isHaveTime
end

-- listener
function wnd_kungfu_showOff:selectType(sender)
	local tag = sender:getTag()
--[[	local isVisible = self.chatType_img[tag]:isVisible()
	if isVisible then
		self.chatType_img[tag]:hide()
		self.chatState[tag] = 0
	else
		self.chatState[tag] = 1
		self.chatType_img[tag]:show()
	end--]]
	self:updateSendType(tag)
end

function wnd_kungfu_showOff:choosebq(sender)
	local tag = sender:getTag()
	self.bq_img[tag]:hide()
	if self.bqData[tag] then
		table.remove(self.bqData,tag)
	end
end

function wnd_kungfu_showOff:onSendBq(sender)
	local id = sender:getTag()
	self:updateBq(id)
end

function wnd_kungfu_showOff:onClose(sender)
    g_i3k_ui_mgr:CloseUI(eUIID_KungfuShowOff)
end

function wnd_kungfu_showOff:finish(sender)
	local roleId = g_i3k_game_context:GetRoleId()
	local sendType = 1
	local iconstb = {}
	for k,v in pairs(self.bqData)do
		table.insert(iconstb,v)
	end
	
	for i=1,3 do
		if self.chatState[i] == 1 then
			local isCanSend,isHaveTime = self:checkInputType(i)
			if isCanSend and isHaveTime then 
				--self.channel:		int32	
				--self.skillPos:		int32	
				--self.icons:		vector[int32]	
				local data = i3k_sbean.diyskill_flaunt_req.new()
				data.channel = i
				data.skillPos = self.skillPos
				data.icons = iconstb
				i3k_game_send_str_cmd(data,i3k_sbean.diyskill_flaunt_res.getName())
			end
		end
	end
    g_i3k_ui_mgr:CloseUI(eUIID_KungfuShowOff)
end
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_kungfu_showOff.new();
		wnd:create(layout);
	return wnd;
end
