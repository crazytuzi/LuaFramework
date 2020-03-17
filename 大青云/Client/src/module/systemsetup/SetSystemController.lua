_G.SetSystemController = setmetatable({},{__index=IController})
SetSystemController.name = 'SetSystemController'
SetSystemController.hidePfx = false
SetSystemController.hideAttackUI = false
SetSystemController.hideMonster = false
SetSystemController.hideMonsterName = false
SetSystemController.hidePlayerName = false
SetSystemController.showPlayerNumber = 0
SetSystemController.showAllPlayer = true
SetSystemController.renderList = {}
SetSystemController.updateTime = 0
SetSystemController.isHighView = false

function SetSystemController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackSetSystem,self,self.OnBackSetModel);
end

------------交互------------
--发送
function SetSystemController:OnSendSetModel(val,str)
	local msg = ReqSetSystemInfoMsg:new();
	msg.showInfo=val;
	msg.keyStr=str;
	MsgManager:Send(msg);
end
--返回
function SetSystemController:OnBackSetModel(msg)
	local val = msg.showInfo;
	local str = msg.keyStr;
	if val == 0 then
		SetSystemModel:SetFuncInitKey();
		return;
	end
	SetSystemModel:UpDataSetModel(val);
	SetSystemModel:UpDataFuncKey(str);
	if UISystemBasic:IsShow() then
		FloatManager:AddNormal( StrConfig["setsys0200"] );
	end
end
----------------------------

--隐藏所有怪物
function SetSystemController:HideAllMonster()
	SetSystemController.hideMonster = true
	SetSystemController.hideMonsterName = false;
end

--显示所有怪物
function SetSystemController:ShowAllMonster()
	SetSystemController.hideMonster = false
	SetSystemController.hideMonsterName = true;
end

--隐藏特效
function SetSystemController:HidePlayerPfx()
	SetSystemController.hidePfx = true
end

--显示特效
function SetSystemController:ShowPlayerPfx()
	SetSystemController.hidePfx = false
end

--开启背景音效
function SetSystemController:OpenBackSoundVolume()
	SetSystemController.BackSoundMute = false
	SoundManager:SetBackSoundMute(false)
	SoundManager:SetBackSoundStoryMute(false)
end

--隐藏背景音效
function SetSystemController:CloseBackSoundVolume()
	SetSystemController.BackSoundMute = true
	SoundManager:SetBackSoundMute(true)
	SoundManager:SetBackSoundStoryMute(true)
end

--开启游戏音效
function SetSystemController:OpenMusicVolume()
	SetSystemController.MusicMute = false
	SoundManager:SetMusicMute(false)
end

--隐藏游戏音效
function SetSystemController:CloseMusicVolume()
	SetSystemController.MusicMute = true
	SoundManager:SetMusicMute(true)
end

--隐藏所有玩家包括名字
function SetSystemController:HideAllPlayer()
	SetSystemController.showAllPlayer = false
	SetSystemController.showPlayerNumber = 0
	SetSystemController.hidePlayerName = true
end

--隐藏所有玩家不包括名字
function SetSystemController:HideAllPlayerShowName()
	SetSystemController.showAllPlayer = false
	SetSystemController.showPlayerNumber = 0
	SetSystemController.hidePlayerName = false
end

--显示10个玩家
function SetSystemController:Show10Player()
	SetSystemController.showAllPlayer = false
	SetSystemController.showPlayerNumber = 10
	SetSystemController.hidePlayerName = false
end

--显示20个玩家
function SetSystemController:Show20Player()
	SetSystemController.showAllPlayer = false
	SetSystemController.showPlayerNumber = 20
	SetSystemController.hidePlayerName = false
end

--显示30个玩家
function SetSystemController:Show30Player()
	SetSystemController.showAllPlayer = false
	SetSystemController.showPlayerNumber = 30
	SetSystemController.hidePlayerName = false
end

--显示所有玩家
function SetSystemController:ShowAllPlayer()
	SetSystemController.showAllPlayer = true
	SetSystemController.hidePlayerName = false
	SetSystemController.showPlayerNumber = 10000
	SetSystemController.renderList = {}
end

--隐藏受击特效
function SetSystemController:HideAttackUI()
	SetSystemController.hideAttackUI = true
end

----显示受击特效
function SetSystemController:ShowAttackUI()
	SetSystemController.hideAttackUI = false
end

--开启高视角模式
function SetSystemController:OpenHighView()
	SetSystemController.isHighView = true
end

--关闭高视角模式
function SetSystemController:CloseHighView()
	SetSystemController.isHighView = false
end

function SetSystemController:UpdateHidePlayer()
	if SetSystemController.showAllPlayer then
		return
	end
	SetSystemController.renderList = {}
	local adllPlayerList = CPlayerMap:GetAllPlayer()
	local selfCid = MainPlayerController:GetRoleID()
	local selfPos = MainPlayerController:GetPos()
	if not selfPos then
		return
	end
	local list = {}
	local dis = 0
	local pos = nil
	for cid, player in pairs(adllPlayerList) do
		if cid ~= selfCid then
			pos = player:GetPos()
			if pos then
				dis = math.sqrt((selfPos.x - pos.x)^2 + (selfPos.y - pos.y)^2)
				table.insert(list, {dis = dis, cid = cid})
			end
		end
	end
	table.sort(list, function(player_a, player_b)
		return player_a.dis < player_b.dis
	end)
	for i = 1, SetSystemController.showPlayerNumber do
		local char = list[i]
		if char then
			SetSystemController.renderList[char.cid] = true
		end
	end
end

function SetSystemController:Update()
	if GetCurTime() - SetSystemController.updateTime < 1000 then
		return
	end
	SetSystemController.updateTime = GetCurTime()
	SetSystemController:UpdateHidePlayer()
end

--设置高清模式
--isHdMode true 高清 false 非高清
function SetSystemController:SetHdMode(isHdMode)
	if isHdMode == true then
		_G.hdMode = true
	else
		_G.hdMode = false
	end
end

--设置是否开启柔光效果
--isGlowFactor true 开启 false 关闭
function SetSystemController:SetGlowFactor(isGlowFactor)
	if isGlowFactor == true then
		_rd.glowFactor = _G.gameGlowFactor
	else
		_rd.glowFactor = 0
	end
end

_G.DisplayQuality = 
{
	lowQuality = 1,
	midQuality = 2,
	highQuality = 3
}
-- 分为 高中低三档
function SetSystemController:SetDisplayQuality(displayQuality)
	if displayQuality == DisplayQuality.lowQuality then
		_G.lightShadowQuality = DisplayQuality.lowQuality
		--SetSystemController:SetGlowFactor(false);
		SetSystemController:Show10Player();
		CharController:SetCountLimit(enEntType.eEntType_Player,15);
	elseif displayQuality == DisplayQuality.midQuality then
		_G.lightShadowQuality = DisplayQuality.midQuality
		--SetSystemController:SetGlowFactor(false);
		SetSystemController:Show20Player();
		CharController:SetCountLimit(enEntType.eEntType_Player,25);
	elseif displayQuality == DisplayQuality.highQuality then
		_G.lightShadowQuality = DisplayQuality.highQuality
		--SetSystemController:SetGlowFactor(true);
		SetSystemController:ShowAllPlayer();
		CharController:SetCountLimit(enEntType.eEntType_Player,0);
	end
end
