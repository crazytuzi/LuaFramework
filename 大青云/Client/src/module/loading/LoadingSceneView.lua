--[[
切换场景loading
lizhuangzhuang
2014年8月26日10:43:56
]]

_G.UILoadingScene = BaseUI:new("UILoadingScene");

--是否是二包加载
UILoadingScene.firstLoad = false;
UILoadingScene.mapId = 0;
UILoadingScene.timerKey = nil;
UILoadingScene.autoResizeBottom = false;
--二包统计节点
UILoadingScene.LogMap = {
	[10] = 141, [20] = 142, [30] = 143, [40] = 144, [50] = 145,
	[60] = 146, [70] = 147, [80] = 148, [90] = 149
}

--loading图片列表(第一个是default)
UILoadingScene.LoadingImgNormal = {
	"resfile/icon/v_loadingpicture/v_digong.jpg",
	"resfile/icon/v_loadingpicture/v_erbao.jpg",
	"resfile/icon/v_loadingpicture/v_haishendian.jpg",
	"resfile/icon/v_loadingpicture/v_juelongling.jpg",
	"resfile/icon/v_loadingpicture/v_nvwagong.jpg",
	"resfile/icon/v_loadingpicture/v_shenlin.jpg",
	"resfile/icon/v_loadingpicture/v_shilingdu.jpg",
	"resfile/icon/v_loadingpicture/v_xueshan.jpg",
	"resfile/icon/v_loadingpicture/v_yandong.jpg",
	"resfile/icon/v_loadingpicture/v_yanjiang.jpg",
	"resfile/icon/v_loadingpicture/v_fengshenluandou.jpg",
}
--loading图片列表(角色1-90级之间显示)
UILoadingScene.LoadingImgLv1_100 = {
	"resfile/icon/v_loadingpicture/v_funcopen.jpg",
	"resfile/icon/v_loadingpicture/v_funcopen1.jpg",
}

UILoadingScene.LoadingImgLianYun = {
	"resfile/icon/loading_default.jpg",
}

function UILoadingScene:Create()
	self:AddSWF("loadingScene.swf",true,"loading");
	if Version:GetName() == VersionConsts.TXQQ then
		self.LoadingImg = self.LoadingImgLianYun;
	elseif Version:IsLianYun() then
		self.LoadingImg = self.LoadingImgNormal;
	else
		self.LoadingImg = self.LoadingImgNormal;
	end
end
-- function UILoadingScene:getMapId(id)
	-- self.mapId = id
-- end


function UILoadingScene:OnLoaded(objSwf)
	local url = UILoadingScene.LoadingImgLianYun[1];
	objSwf.loader.source = "img://" .. url;
end

function UILoadingScene:NeverDeleteWhenHide()
	return true;
end

function UILoadingScene:GetWidth()
	return 1280;
end

function UILoadingScene:GetHeight()
	return 800;
end

function UILoadingScene:OnResize(wWidth,wHeight)
	
	if not self.bShowState then return; end
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.mcMask._width = wWidth+1;
	objSwf.mcMask._height = wHeight;
	--
	self:ShowLogo();
end

function UILoadingScene:OnShow()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- if self.mapId>0 then
		-- local tmaploading = split(t_map[self.mapId].maploading, "#")
		-- local j = math.random(#tmaploading);
		-- local mapImgPath = tmaploading[j];
		-- objSwf.loader.source = "img://resfile/icon/v_loadingpicture/" .. mapImgPath..".jpg";
		-- self.mapId = 0;
	-- end
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mcMask._width = wWidth+1;
	objSwf.mcMask._height = wHeight;
	--
	local tips = LoadingTipsCfg[math.random(1,#LoadingTipsCfg)];
	objSwf.bottom.tfTips.htmlText = tips;
	self:ShowLogo();
	self:ShowTxts();
	self:ShowBottom();
end

function UILoadingScene:ShowLogo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local winW,winH = UIManager:GetWinSize()
--	objSwf.mcLogo._x = winW / 2 - self:GetWidth() / 2 + 30;
--	objSwf.mcLogo._y = winH / 2 - self:GetHeight() / 2 + 30;
	local pos = UIManager:PosGtoL(objSwf,30,30);
	objSwf.mcLogo._x = pos.x;
	objSwf.mcLogo._y = pos.y;
	--[[if winW < 1692 then
		-- 1280+(winW-1280)/2 - winW + objSwf.mcLogo._width;   (winW-1280)/2
		objSwf.mcLogo._x = 1280+(winW-1280)/2 - winW + objSwf.mcLogo._width;
	else
		objSwf.mcLogo._x = 0;
	end
	if winH < 960 then
		objSwf.mcLogo._y = (800-winH)/2;
	else
		objSwf.mcLogo._y = -80;
	end]]
end

function UILoadingScene:ShowBottom()
	if not self.autoResizeBottom then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local winW,winH = UIManager:GetWinSize()
	local pos = UIManager:PosGtoL(objSwf,winW / 2, winH - 100);
	objSwf.bottom._y = pos.y;
end

--准备下一次的图片
function UILoadingScene:ShowLoadingImg()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
	if curRoleLvl then
		if curRoleLvl>0 and curRoleLvl<90 then
			self.LoadingImg = self.LoadingImgLv1_100;
			self.autoResizeBottom = true;
		else
			self.LoadingImg = self.LoadingImgNormal;
			self.autoResizeBottom = false
		end
	end
	local index = math.random(#self.LoadingImg);
	local url = self.LoadingImg[index];
	if _sys:fileExist(url) then
		objSwf.loader.source = "img://" .. url;
	else
		self.timerKey = TimerManager:RegisterTimer(function()
			UILoaderManager:LoadList({url},function()
				if self.bShowState then return; end
				objSwf.loader.source = "img://" .. url;
			end,nil,true);
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end,1000,1);
	end
end

function UILoadingScene:Open(firstLoad)
	self.firstLoad = firstLoad;
	self.isWindow = UIFirstRechargeWindow:IsShow();
	UIFirstRechargeWindow:Hide();
	self:Show();
end

-- 根据资源量分割段落量
function UILoadingScene:delievePara(total)
	local num = math.floor(total /10)
	local para = 5+num;
	return total/para;
end

function UILoadingScene:OnHide()
	Debug('loadingScene onhide');
	if self.firstLoad then
		for k,v in pairs(self.LogMap) do
			LogManager:Send(v);
			self.LogMap[k] = nil;
		end
	end
	self:ShowLoadingImg();
	self.txts = {};
	self.txtss = {};
	self.tn = 0;
	if self.isWindow then
		UIFirstRechargeWindow:Show();
	end
	self.isWindow = nil;
end

----------------------------------------------------------------------------

UILoadingScene.tn = 0;
UILoadingScene.txts = {};
UILoadingScene.txtss = {};
function UILoadingScene:ShowTxts(  )
	self.txts = {'正在加载模型资源 ','正在加载场景资源','正在加载贴图资源','正在加载特效资源','正在进入游戏'};
	self.txtss = {{'正在为您加载坐骑模型','正在为您加载坐骑摄像机','正在为您加载套装模型'},
	{'正在为您加载纹理','正在为您加载场景摄像机','正在为您加载场景音效','正在为您加载场景模型贴图','正在为您加载场景环境细节 ','正在为您加载场景动画'},
	{'正在为您加载主角模型贴图','正在为您加载凹凸贴图','正在为您加载细节贴图','正在为您加载天神变身贴图'},
	{'正在为您加载NPC特效','正在为您加载主角特效','正在为您加载坐骑特效'},
	{'正在更新细节优化','正在更新游戏界面','正在更新'}};
	for i=1,#self.txts do
		for j=1,#self.txtss[i] do
			self.tn = self.tn +1;
		end
	end
end

local num = 1;
function UILoadingScene:Update()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not CPlayerMap.objSceneMap.sceneLoader then return; end
	-- 字节 1KB=1024字节，1MB=1024KB
	-- download 当前已经下载的资源量
	local download = CPlayerMap.objSceneMap.sceneLoader.finishSize;
	-- total    当前场景所需要的总资源量
	local total = CPlayerMap.objSceneMap.sceneLoader.resSize;
	if self.firstLoad then
		-- 加载二包
		if UILoaderManager.groupLoaderList["pack2"] then
			local loader = UILoaderManager.groupLoaderList["pack2"];
			download = download + loader.finishSize;
			total = total + loader.resSize;
		end
		-- 加载玩家数据
		local profPack = "prof" .. MainPlayerModel.sMeShowInfo.dwProf;
		if UILoaderManager.groupLoaderList[profPack] then
			local loader = UILoaderManager.groupLoaderList[profPack];
			download = download + loader.finishSize;
			total = total + loader.resSize;
		end
	end
	if self.firstLoad then
		local percent = toint(download/total*100,0.5);
		for k,v in pairs(self.LogMap) do
			if percent >= k then
				-- 资源加载阶段性打点
				LogManager:Send(v);
				self.LogMap[k] = nil;
			end
		end
	end
	-- 没有资源量
	if total == 0 then
		objSwf.bottom.si.value = 100;
		objSwf.bottom.siUntruth.value = 100;
		local falshPer = 100;
		objSwf.bottom.tfProgress.text = self.txts[5]..' '..falshPer..'%';
		objSwf.bottom.tfProgressFalse.text = self.txtss[5][3] ..' '..falshPer..'%';
	else
		download = download/1024/1024;
		total = total/1024/1024;
		local pgs = math.min(download/total,1)
		local falseCur = math.max(1,math.min(100,math.floor(pgs * self.tn * 100 %100)));
		local ci = 0;
		local curi = 1;   --当前主进度条文字位置
		local curj = 1;   --当前假进度条文字位置
		for i=1,#self.txts do
			for j=1,#self.txtss[i] do
				ci = ci +1;
				if ci == math.floor(pgs * self.tn) then
					curi = i;
					curj = j;
					break;
				end
			end
			if curi ~= 1 then
				break;
			end
		end

		-- 总进度条
		local percent = toint(download/total*100,0.5);
		objSwf.bottom.tfProgress.text = self.txts[curi]..' '..percent..'%';
		objSwf.bottom.si.value = percent;

		-- 假进度条
		if percent >= 100 then
			objSwf.bottom.siUntruth.value = 100
			objSwf.bottom.tfProgressFalse.text = self.txtss[5][3] ..' '..'100%';
		else
			local falsePercent = toint(falseCur,0.5);
			objSwf.bottom.siUntruth.value = falseCur;
			objSwf.bottom.tfProgressFalse.text = self.txtss[curi][curj] ..' '..falsePercent..'%';
		end
	end
end
