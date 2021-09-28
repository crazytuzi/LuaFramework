DCCardsGame = { };

--[[棋牌类游戏，玩了一局游戏
	roomId:房间号 String类型
	id: String类型
	coinType：虚拟币类型，String类型
	lostOrGain：获得或者失去的虚拟币数量，失去虚拟币时，需要传入负值，后台通过该值的正负判断该局游戏的输赢 long long类型
	tax:完成一局游戏时系统需要回收的虚拟币数量（税收）long long类型
	left:玩家剩余的虚拟币总量 long long类型
]]
function DCCardsGame.play(roomId, id, coinType, loseOrGain, tax, left)
	if i3k_game_data_eye_valid() then
		DCLuaCardsGame:play(roomId, id, coinType, loseOrGain, tax, left)
	end
end

--[[玩家房间内丢失虚拟币时调用（完成一局游戏调用play接口后不必再调用该接口）
	roomId:房间号 String类型
	id:虚拟币获得原因 String类型
	coinType：虚拟币类型，String类型
	gain:获得虚拟币数量 long long类型
	left:玩家剩余的虚拟币总量 long long类型
]]
function DCCardsGame.gain(roomId, id, coinType, gain, left)
	if i3k_game_data_eye_valid() then
		DCLuaCardsGame:gain(roomId, id, coinType, gain, left)
	end
end

--[[玩家房间内丢失虚拟币时调用（完成一局游戏调用play接口后不必再调用该接口）
	roomId:房间号 String类型
	id:虚拟币失去原因 String类型
	coinType：虚拟币类型，String类型
	lost:失去虚拟币数量 long long类型
	left:玩家剩余的虚拟币总量 long long类型
]]
function DCCardsGame.lost(roomId, id, coinType, lost, left)
	if i3k_game_data_eye_valid() then
		DCLuaCardsGame:lost(roomId, id, coinType, lost, left)
	end
end

return DCCardsGame;
