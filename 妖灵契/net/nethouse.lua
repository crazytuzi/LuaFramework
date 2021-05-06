module(..., package.seeall)

--GS2C--

function GS2CEnterHouse(pbdata)
	local furniture_info = pbdata.furniture_info --家具信息
	local partner_info = pbdata.partner_info --伙伴信息
	local item_info = pbdata.item_info --道具信息
	local warm_degree = pbdata.warm_degree --温馨度
	local max_warm_degree = pbdata.max_warm_degree --温馨度上限
	local max_train = pbdata.max_train --训练次数上限
	local owner_pid = pbdata.owner_pid --目标宅邸玩家id
	local talent_level = pbdata.talent_level --才艺等级
	local handle_type = pbdata.handle_type --1-登录,0-客户端请求
	local buff_info = pbdata.buff_info --总亲密度信息
	--todo
	--必须先设置owner_pid
	g_HouseCtrl:SetHouseInfo(furniture_info, partner_info, owner_pid)
	
	if owner_pid == g_AttrCtrl.pid then
		g_HouseCtrl:SetTalent(talent_level, 0)
		g_HouseCtrl:LoginItem(item_info)
		g_PlayerBuffCtrl:UpdateHouseBuff(buff_info)
		-- g_HouseCtrl:SetWarm(warm_degree, max_warm_degree)
		g_HouseCtrl:SetMaxTrain(max_train)
	end
	if handle_type == 0 or g_HouseCtrl:IsHouseOnly() then
		g_HouseCtrl:EnterHouse()
	end
end

function GS2CFurnitureInfo(pbdata)
	local furniture_info = pbdata.furniture_info
	--todo
	g_HouseCtrl:SetFurnitureInfo(furniture_info)
end

function GS2CPartnerInfo(pbdata)
	local partner_info = pbdata.partner_info
	--todo
	g_HouseCtrl:SetPartnerInfo(partner_info)
end

function GS2CRefreshHouseWarm(pbdata)
	local warm_degree = pbdata.warm_degree
	local max_warm_degree = pbdata.max_warm_degree
	--todo
	-- g_HouseCtrl:SetWarm(warm_degree, max_warm_degree)
end

function GS2COpenWorkDesk(pbdata)
	local desk_info = pbdata.desk_info --工作台顺序,自己:1-3,好友:4
	local talent_level = pbdata.talent_level --才艺等级
	local talent_schedule = pbdata.talent_schedule --才艺进度
	local owner_pid = pbdata.owner_pid --宅邸玩家的pid
	local handle_type = pbdata.handle_type --1-登录,0-客户端请求
	--todo
	g_HouseCtrl:SetTalent(talent_level, talent_schedule, owner_pid)
	for i, info in ipairs(desk_info) do
		g_HouseCtrl:SetWorkDeskInfo(info, owner_pid)
	end
	if handle_type == 0 then
		if owner_pid == g_AttrCtrl.pid then
			g_GuideCtrl:CheckTeaarViewGuide()
			CTeaartView:ShowView()
		else
			CFriendTeaArtView:ShowView(function (oView)
				oView:SetOwner(owner_pid)
			end)
		end
	end
end

function GS2CRefreshWorkDesk(pbdata)
	local desk_info = pbdata.desk_info
	local owner_pid = pbdata.owner_pid --宅邸玩家的pid
	--todo
	g_HouseCtrl:SetWorkDeskInfo(desk_info, owner_pid)
end

function GS2CRefreshTalent(pbdata)
	local talent_level = pbdata.talent_level
	local talent_schedule = pbdata.talent_schedule
	--todo
	g_HouseCtrl:SetTalent(talent_level, talent_schedule)
end

function GS2CPartnerExchangeUI(pbdata)
	local love_cnt = pbdata.love_cnt --剩余可以抚摸次数
	local max_love_cnt = pbdata.max_love_cnt --最大次数
	local partner_gift_cnt = pbdata.partner_gift_cnt --剩余赠送礼物的次数
	local supple_love_time = pbdata.supple_love_time --补充下一次抚摸次数需要的时间
	local max_gift_cnt = pbdata.max_gift_cnt --最大送礼次数
	local handle_type = pbdata.handle_type --1-登录,0-客户端请求
	local daily_buy_gift = pbdata.daily_buy_gift --购买送礼次数
	--todo
	g_HouseCtrl:SetTouchCnt(love_cnt, max_love_cnt, supple_love_time)
	g_HouseCtrl:SetRemainGiveCnt(partner_gift_cnt, max_gift_cnt, daily_buy_gift)
end

function GS2CHouseAddItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_HouseCtrl:AddHouseItem(table.copy(itemdata))
end

function GS2CHouseDelItem(pbdata)
	local id = pbdata.id --服务的道具id
	--todo
	g_HouseCtrl:DelHouseItem(id)
end

function GS2CHouseItemAmount(pbdata)
	local id = pbdata.id
	local amount = pbdata.amount
	--todo
	g_HouseCtrl:RefreshHouseItemAmount(id, amount)
end

function GS2CFriendHouseProfile(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	g_HouseCtrl:RefreshFriend(profile_list)
end

function GS2CGivePartnerGift(pbdata)
	--todo
	g_HouseCtrl:OnEvent(define.House.Event.GivePartnerGift)
end

function GS2CAddHousePartner(pbdata)
	local type = pbdata.type --宅邸伙伴导表id
	--todo
	g_HouseCtrl:PlayHousePartnerAni(type)
end

function GS2CRefreshHouseBuff(pbdata)
	local buff_info = pbdata.buff_info
	--todo
	g_PlayerBuffCtrl:UpdateHouseBuff(buff_info)
end

function GS2CRecieveHouseCoin(pbdata)
	local frd_pid = pbdata.frd_pid --好友pid
	local status = pbdata.status --0-已领取
	--todo
	g_HouseCtrl:OnRecieveHouseCoin(frd_pid, status)
end

function GS2CUseFriendWorkDesk(pbdata)
	local frd_pid = pbdata.frd_pid --好友pid
	local status = pbdata.status --０-成功，１-工作台被占用
	--todo
	if status == 0 then
		g_HouseCtrl:OnEvent(define.House.Event.UpdateFriendWorkDesk)
	end
end


--C2GS--

function C2GSEnterHouse(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("house", "C2GSEnterHouse", t)
end

function C2GSLeaveHouse()
	local t = {
	}
	g_NetCtrl:Send("house", "C2GSLeaveHouse", t)
end

function C2GSHousePromoteFurniture(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("house", "C2GSHousePromoteFurniture", t)
end

function C2GSHouseSpeedFurniture(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("house", "C2GSHouseSpeedFurniture", t)
end

function C2GSOpenWorkDesk(target_pid)
	local t = {
		target_pid = target_pid,
	}
	g_NetCtrl:Send("house", "C2GSOpenWorkDesk", t)
end

function C2GSTalentShow(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("house", "C2GSTalentShow", t)
end

function C2GSTalentDrawGift(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("house", "C2GSTalentDrawGift", t)
end

function C2GSHelpFriendWorkDesk()
	local t = {
	}
	g_NetCtrl:Send("house", "C2GSHelpFriendWorkDesk", t)
end

function C2GSUseFriendWorkDesk(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("house", "C2GSUseFriendWorkDesk", t)
end

function C2GSOpenExchangeUI()
	local t = {
	}
	g_NetCtrl:Send("house", "C2GSOpenExchangeUI", t)
end

function C2GSLovePartner(type, body_part)
	local t = {
		type = type,
		body_part = body_part,
	}
	g_NetCtrl:Send("house", "C2GSLovePartner", t)
end

function C2GSGivePartnerGift(type, itemid)
	local t = {
		type = type,
		itemid = itemid,
	}
	g_NetCtrl:Send("house", "C2GSGivePartnerGift", t)
end

function C2GSTrainPartner(type, train_type)
	local t = {
		type = type,
		train_type = train_type,
	}
	g_NetCtrl:Send("house", "C2GSTrainPartner", t)
end

function C2GSRecievePartnerTrain(train_type)
	local t = {
		train_type = train_type,
	}
	g_NetCtrl:Send("house", "C2GSRecievePartnerTrain", t)
end

function C2GSUnChainPartnerReward(type, level)
	local t = {
		type = type,
		level = level,
	}
	g_NetCtrl:Send("house", "C2GSUnChainPartnerReward", t)
end

function C2GSFriendHouseProfile()
	local t = {
	}
	g_NetCtrl:Send("house", "C2GSFriendHouseProfile", t)
end

function C2GSRecieveHouseCoin(frd_pid)
	local t = {
		frd_pid = frd_pid,
	}
	g_NetCtrl:Send("house", "C2GSRecieveHouseCoin", t)
end

function C2GSAddPartnerGift(cnt, cost)
	local t = {
		cnt = cnt,
		cost = cost,
	}
	g_NetCtrl:Send("house", "C2GSAddPartnerGift", t)
end

function C2GSWorkDeskSpeedFinish(pos, cost)
	local t = {
		pos = pos,
		cost = cost,
	}
	g_NetCtrl:Send("house", "C2GSWorkDeskSpeedFinish", t)
end

