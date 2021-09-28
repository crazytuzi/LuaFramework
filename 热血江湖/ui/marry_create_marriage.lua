-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--缔结姻缘  结婚双方必须均为单身 结婚双方未处于离婚冷却时间内 结婚双方需要组队前往月老 
--结婚双方善恶值均低于10 结婚双方等级大于等于30 结婚双方需要好友度达到1000  结婚双方性别为异性
-------------------------------------------------------
local marryDistance =10 --人到npc  人到人的距离
wnd_marry_create_marriage = i3k_class("wnd_marry_create_marriage",ui.wnd_base)

function wnd_marry_create_marriage:ctor()
	self.cheakTab = {}
	for i=1 ,8 do
		self.cheakTab[i] = {}
		self.cheakTab[i] = false
	end
	--条件1：有队伍
	--条件2，两人队伍
	--条件3：两人共同拜访月老（算距离）
	--条件4：等级
	--条件5：异性
	--条件6：罪恶值
	--条件7：好友
	--条件8：好友度（待定）--魅力值
end

function wnd_marry_create_marriage:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close
	self.closeBtn:onClick(self, self.closeButton)
	self.Scroll = widgets.Scroll
	self.NotMarryBtn = widgets.NotMarryBtn  --再考虑下
	self.NotMarryBtn:onClick(self, self.onNotMarryBtn)
	self.ToMarryBtn = widgets.ToMarryBtn	--立即求婚
	self.ToMarryBtn:onClick(self, self.onToMarryBtn)
	
	self.goBackBtn = widgets.goBackBtn  --返回上层
	self.goBackBtn:onClick(self, self.onGoBackBtn)
end

function wnd_marry_create_marriage:cheakData()
	--检查按钮的显示与否
	local state = g_i3k_game_context:getEnterProNum() --1 代表月老处 可点 --2 代表姻缘处
	if state ==1 then
		--显示上一层
		self.goBackBtn:show()
		self.NotMarryBtn:hide()
		self.ToMarryBtn:hide()
	elseif state ==2 then
		local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
		if step== -1 then
			self.goBackBtn:show()
			self.NotMarryBtn:hide()
			self.ToMarryBtn:hide()
		end
	else
		--npc第一个按钮走流程进入
	end
end

function wnd_marry_create_marriage:refresh()
	self:cheakData()
	
	local tab = i3k_db_marry_rules.marryTextId
	local labelTab = {[699] = i3k_db_marry_rules.marryLevel, [700] = i3k_db_marry_rules.marryFriends, [703] = i3k_db_marry_rules.evilValue}
	for i, v in ipairs(tab) do
		local layer = require("ui/widgets/jhdjyyt")()
		self.blockTXImage = layer.vars.blockTXImage
		self.textLabel = layer.vars.textLabel
		self.number = layer.vars.number
		self.number:setText(i)
		self.textLabel:setText(i3k_get_string(v, labelTab[v]))
		self.Scroll:addItem(layer)
	end
	self.myTeam= g_i3k_game_context:GetTeam()
	 --1条件有队伍
	if not next(self.myTeam.membersProfile) then
		self.cheakTab[1] = false --条件没有队伍
		return
	else
		self.cheakTab[1] = true --条件有队伍
	end

	local myId= g_i3k_game_context:GetRoleId()
	local myGender = g_i3k_game_context:GetRoleGender()
	local myLevel = g_i3k_game_context:GetLevel()
	local myEvilValue =g_i3k_game_context:GetCurrentPKValue()  --罪恶值
	local myTeamLeader = g_i3k_game_context:GetTeamLeader()
	local other = g_i3k_game_context:GetTeamOtherMembersProfile() --除了自己以外的其他人
	--2条件两个人
	if #other == 1 then
		self.cheakTab[2] = true 
	end
	--	local desc, color = g_i3k_db.i3k_db_get_transfer_desc() --正邪不要
	local otherUesr = other[1].overview
	local otherUesrId = other[1].overview.id
	local otherUesrGender = other[1].overview.gender
	local otherUesrLevel = other[1].overview.level
	
	--条件3 两人距离 自己和npc距离 不能太远(客户端不处理距离 由服务器判断)
	--[[if npcId ~= nil then
		local my_pos_mapId = self.myTeam.membersPosition[myId].mapId
		local my_pos_pos = self.myTeam.membersPosition[myId].pos
		my_pos_pos = {x=my_pos_pos.x, y= my_pos_pos.y, z=my_pos_pos.z}
		local v,npc_pos  = g_i3k_db.i3k_db_get_npc_point_by_Id(npcId)
		local my_istrue = g_i3k_game_context:Caculator(my_pos_pos,npc_pos,marryDistance)	
		local other_pos = self.myTeam.membersPosition[otherUesrId].pos
		other_pos =  {x=other_pos.x, y= other_pos.y, z=other_pos.z}
		--local roleLine = g_i3k_game_context:GetCurrentLine()
		local lovers_istrue = g_i3k_game_context:Caculator(my_pos_pos,other_pos,marryDistance)
		--if my_istrue and lovers_istrue then 
			self.cheakTab[3] = true 
		--end
	else
	end]]
	self.cheakTab[3] = true 
	--4条件两个人等级大于等于30
	self.NeedLevel = i3k_db_marry_rules.marryLevel~=nil and i3k_db_marry_rules.marryLevel or 30
	if myLevel>=self.NeedLevel  and otherUesrLevel>= self.NeedLevel  then
		self.cheakTab[4] = true 
	end
	
	--5条件结婚双方性别为异性
	if myGender ~= otherUesrGender then
		self.cheakTab[5] = true 
	end
	--6条件结婚双方罪恶值小于10
	self.NeedEvilValue = i3k_db_marry_rules.evilValue~=nil and i3k_db_marry_rules.evilValue or 10
	if myEvilValue <= self.NeedEvilValue then
		self.cheakTab[6] = true 
	end
	--7条件结婚双方是好友
	local friendData = g_i3k_game_context:GetFriendsDataByID(otherUesrId)
	self.NeedFriends = i3k_db_marry_rules.marryFriends~=nil and i3k_db_marry_rules.marryFriends or 1000
	if friendData then
		self.cheakTab[7] = true 
	else
		self.cheakTab[7] = false --不是好友 
	end
	--8条件结婚双方关注度大于1000
	self.NeedCharm = i3k_db_marry_rules.marryFriends~=nil and i3k_db_marry_rules.marryFriends or 1000
	--local myCharm = g_i3k_game_context:GetCharm()
	--if myCharm>= self.NeedCharm then
	self.cheakTab[8] = true --关注度暂不处理
	--end

end



function wnd_marry_create_marriage:onNotMarryBtn(sender)
	self:closeButton()
end

function wnd_marry_create_marriage:onToMarryBtn(sender)
	--校验条件是否全部满足
	local other = g_i3k_game_context:GetTeamOtherMembersProfile()
	if not next(other) then
		g_i3k_ui_mgr:PopupTipMessage("结婚对象离开队伍请重新组队")
		self:onCloseUI()
		return
	end
	local otherUesrLevel = other[1].overview.level
	local myLevel = g_i3k_game_context:GetLevel()
	local otherName = other[1].overview.name
	for i,v in ipairs(self.cheakTab) do
		if v== false then
			if i==1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(862))
			elseif i==2 then
				g_i3k_ui_mgr:PopupTipMessage("结婚需要两个人，求婚失败")
			elseif i==3 then
				g_i3k_ui_mgr:PopupTipMessage("结婚需要两个人一同拜访月老，求婚失败")
			elseif i==4 then
				if myLevel<self.NeedLevel then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(863, "您", self.NeedLevel))
				elseif otherUesrLevel< self.NeedLevel then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(863, otherName, self.NeedLevel))
				end
			elseif i==5 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(865))	
			elseif i==6 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(867, "您", self.NeedEvilValue))	
			elseif i==7 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(869, otherName))	
			elseif i==8 then
				g_i3k_ui_mgr:PopupTipMessage("结婚魅力值必须超过"..self.NeedFriends.."，求婚失败")		
			end
			return
		end
	end
	
	g_i3k_logic:OpenGotoMarry()
	self:closeButton()

end

--返回上层
function wnd_marry_create_marriage:onGoBackBtn(sender)
	self:closeButton()
end

function wnd_marry_create_marriage:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Create_Marriage)
end

function wnd_create(layout)
	local wnd = wnd_marry_create_marriage.new()
		wnd:create(layout)
	return wnd
end
