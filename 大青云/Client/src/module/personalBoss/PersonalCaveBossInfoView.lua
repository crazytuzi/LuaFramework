--[[
	地宫BOSS 副本显示信息
	2016年6月18日
	chenyujia
]]

_G.UICaveBossInfo = BaseUI:new("UICaveBossInfo");

UICaveBossInfo.list = {};

function UICaveBossInfo:Create()
	self:AddSWF("personalCaveBossInfo.swf", true, "bottom");
end

function UICaveBossInfo:OnLoaded( objSwf )
	objSwf.btn_goon.click = function() self:OnBtnQuitClick(); end
end

function UICaveBossInfo:OnShow()
	self:StartTimer()
	self:ShowBossInfo()
	self:SetMonsterNum(self.monsterNum)
end

function UICaveBossInfo:SetMonsterNum(num)
	self.monsterNum = num
	if not self:IsShow() then return end

	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txt_monster.text = (self.monsterNum or 0) .. "/8"
end

function UICaveBossInfo:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:ShowBossInfo();
	end, 1000, 0 );
end

function UICaveBossInfo:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UICaveBossInfo:OnChangeSceneMap()
	-- 玩家切换地图处理
	local floor = self:getCaveFloor()
	if not floor then
		self:Hide()
		return
	else
		MainMenuController:HideRight()
		self:Show()
	end
	self.floor = floor
end

function UICaveBossInfo:DeleteWhenHide()
	return true;
end

local completeFuc = function()
	AutoBattleController:OpenAutoBattle();
end

--显示名字
function UICaveBossInfo:ShowBossInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.floor then self.floor = 1 end
	for i = 1, 6 do
		if objSwf["floor" ..i] then
			objSwf["floor" ..i]._visible = i == self.floor
		end
	end
	local nIndex = 1
	for k , cfg in ipairs(t_swyj) do
		if cfg.floor == self.floor then
			local monsterCfg = t_monster[toint(cfg.bossId)]
			local icon = ResUtil:GetCaveBossHeadIcon(cfg.panelicon)
			local info = UnionDiGongModel:getBossInfo(k)
			local alive = info and info.state~=1 or false;
			local UI = objSwf["item" ..nIndex]
			if icon ~= UI.icon_head.source then
				UI.icon_head.source = icon
			end
			UI.txt_name.text = monsterCfg.name
			UI.kill._visible = not alive and true or false
			if alive then
				UI.txt_time.text = StrConfig['worldBoss006']
				UI.txt_hp.text = self.list[k] and math.ceil(self.list[k]/cfg.hp * 100) .. "%" or "100%"
				UI.progress.maximum = cfg.hp
				UI.progress.value = self.list[k] or cfg.hp
			else
				UI.txt_time.text = UIPersonalCaveBoss:GetStateTxtInfo(true, cfg)
				UI.progress.value = 0
				UI.txt_hp.text = "0%"
			end
			UI.gogogo.click = function()
				local posVO = split(cfg.bossPosition,",");
				MainPlayerController:DoAutoRun(tonumber(posVO[1]), _Vector3.new(tonumber(posVO[2]), tonumber(posVO[3]), 0), completeFuc);
			end
			nIndex = nIndex + 1
		end
	end
end

function UICaveBossInfo:OnHide()
	MainMenuController:UnhideRight()
	self.list = {}
	self.floor = nil
	self:StopTimer()
end

function UICaveBossInfo:OnBtnQuitClick()
	local msg = ReqQuitDiGongMsg:new();
	MsgManager:Send(msg);
end

function UICaveBossInfo:ResetBossHp(id)
	self.list[id] = nil
end

function UICaveBossInfo:SetBossHp(list)
	for k, v in pairs(list.list) do
		self.list[v.tid] = v.hp
	end
end


function UICaveBossInfo:getCaveFloor()
	local curMapId = CPlayerMap:GetCurMapID()
	if curMapId == 0 then return end
	for k, cfg in pairs(t_swyj) do
		local pos = split(cfg.bossPosition, ',')
		if pos and pos[1] and toint(pos[1]) == curMapId then
			return cfg.floor
		end
	end
end