--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/28
    Time: 19:55
   ]]
_G.QiZhanWallView = {};

QiZhanWallView.wallSkn = 'v_tafuben_xiaoguai01_fmt.skn';
QiZhanWallView.wallSkl = 'v_tafuben_xiaoguai01.skl';
QiZhanWallView.wallSan = 'v_tafuben_xiaoguai01.san';

QiZhanWallView.bossWallSkn = 'v_tafuben_bossceng_fmt.skn';
QiZhanWallView.bossWallSkl = 'v_tafuben_bossceng.skl';
QiZhanWallView.bossWallSan = 'v_tafuben_bossceng.san';

QiZhanWallView.TYPE_WALL = 'wall';
QiZhanWallView.TYPE_BOSS_WALL = 'bossWall';
QiZhanWallView.currentWall = nil;
QiZhanWallView.bottomWall = nil;
QiZhanWallView.bottomType = '';
QiZhanWallView.wallZGap = 195;
QiZhanWallView.initialized = false;
function QiZhanWallView:GetFileName(wallType)
	local skn = '';
	local skl = '';
	local san = '';
	if wallType == self.TYPE_WALL then
		skn = self.wallSkn;
		skl = self.wallSkl;
		san = self.wallSan;
	elseif wallType == self.TYPE_BOSS_WALL then
		skn = self.bossWallSkn;
		skl = self.bossWallSkl;
		san = self.bossWallSan;
	end
	return skn, skl, san;
end

function QiZhanWallView:Show(wallType)
	if self.initialized then return; end
	self.initialized = true;
	local skn, skl, san = self:GetFileName(wallType);
	local wall = QiZhanWallAvatar:CreateNewAvatar(skn, skl)
	wall:InitAvatar();
	wall:EnterSceneMap(CPlayerMap:GetSceneMap(), _Vector3.new(0, 0, 0), 0);
	self.bottomWall = wall;
	self.bottomType = wallType;
	self.currentWall = wall;
end

function QiZhanWallView:ToNext(nextWallType)
	local skn, skl, san = self:GetFileName(nextWallType);
	local wall = QiZhanWallAvatar:CreateNewAvatar(skn, skl)
	wall:InitAvatar();
	if self.bottomType == self.TYPE_WALL then
		wall:EnterSceneMap(CPlayerMap:GetSceneMap(), _Vector3.new(0, 0, self.wallZGap), 0);
		wall:ExecAction(san, false, function()
			if not wall then return; end
			wall:GetAnimation(san).current = 0;
			wall:SetPos(_Vector3.new(0, 0, 0));
			self.bottomWall = wall;
			self.bottomType = nextWallType;
		end);
		self.currentWall = wall;
		self.bottomWall:ExitMap();
		self.bottomWall = nil;
	elseif self.bottomType == self.TYPE_BOSS_WALL then
		wall:EnterSceneMap(CPlayerMap:GetSceneMap(), _Vector3.new(0, 0, self.wallZGap), 0);
		wall:ExecAction(san, false, function()
			if not wall then return; end
			wall:GetAnimation(san).current = 0;
			wall:SetPos(_Vector3.new(0, 0, 0));
			self.bottomWall = wall;
			self.bottomType = nextWallType;
		end);
		self.currentWall = wall;
		local bskn, bskl, bsan = self:GetFileName(self.TYPE_BOSS_WALL);
		local tempBottomWall = self.bottomWall;
		self.bottomWall:ExecAction(bsan, false, function()
			tempBottomWall:ExitMap();
		end)
	end

end

function QiZhanWallView:Destroy()
	if self.bottomWall then
		self.bottomWall:ExitMap();
		self.bottomWall = nil;
	end

	if self.currentWall then
		self.currentWall:ExitMap();
		self.currentWall = nil;
	end

	self.bottomType = '';
	self.initialized = false;
end