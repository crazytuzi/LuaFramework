local M={}
_G.SpineManager=M

-- ******************************************************
-- spine 资源管理接口
-- ******************************************************
M.SCALE_NPC=0.5
M.resRoleArray={}
function M.initNoRelease()
	for i,v in pairs(_G.Cfg.player_init) do
		-- local skinId=10000+v.pro
		-- local skinCnf=_G.Cfg.skill_skin[skinId]
		-- local szSpineName=string.format("spine/%d",skinId)
		-- M.resRoleArray[szSpineName]=true

		local zdName=string.format("spine/1%d020",v.pro)
		local zdMountName=string.format("spine/1%d030",v.pro)
		M.resRoleArray[zdName]=true
		M.resRoleArray[zdMountName]=true
	end
end

M.playerMountRes={}
M.playerPartnerRes={}
M.playerWeaponRes={}
M.playerFeatherRes={}
M.preCityRes={}
function M.resetPlayerMountRes(_mountSkinId)
	print("[SpineManager] resetPlayerMountRes===>>",_mountSkinId)
	M.playerMountRes={}
	if _mountSkinId==nil or _mountSkinId==0 then return end
	M.playerMountRes[string.format("spine/%d",_mountSkinId)]=true
	for k,_ in pairs(M.playerMountRes) do
    	print("@@@@@====>>>>",k)
    end
end
function M.resetPlayerWeaponRes(_weaponId)
	print("[SpineManager] resetPlayerWeaponRes===>>",_weaponId)
	M.playerWeaponRes={}
	if _weaponId==nil or _weaponId==0 then return end
	M.playerWeaponRes[string.format("spine/wq_%d0101",_G.GPropertyProxy:getMainPlay():getPro())]=true
	for k,_ in pairs(M.playerWeaponRes) do
    	print("@@@@@====>>>>",k)
    end
end
function M.resetPlayerFeatherRes(_featherId)
	print("[SpineManager] resetPlayerFeatherRes===>>",_featherId)
	M.playerFeatherRes={}
	if _featherId==nil or _featherId==0 then return end
	M.playerFeatherRes[string.format("spine/%d",_featherId)]=true
	for k,_ in pairs(M.playerFeatherRes) do
    	print("@@@@@====>>>>",k)
    end
end
function M.resetPreCityRes(_szNameArray)
	print("[SpineManager] resetPreCityRes===>>",_szNameArray)
	M.preCityRes={}
	if _szNameArray==nil then return end
	for szSpineName,v in pairs(_szNameArray) do
		M.preCityRes[szSpineName]=szSpineName
	end
	for k,_ in pairs(M.preCityRes) do
    	print("@@@@@====>>>>",k)
    end
end

M.resArray={}
M.resAtlasArray={}
function M.init()
	M.resArray={}
	M.resAtlasArray={}
end

function M.releaseAllSpine(_spineArray)
	_spineArray=_spineArray or {}

	for szSpineName,resData in pairs(M.resArray) do
		local szPng=resData.png

		if not _spineArray[szSpineName] and not M.resRoleArray[szSpineName] and not M.playerWeaponRes[szSpineName] then
			cc.Director:getInstance():getTextureCache():removeTextureForKey(szPng)

			if not M.playerMountRes[szSpineName]
				and not M.playerFeatherRes[szSpineName] then

				local szAtlas=resData.atlas
				local releaseAtlas=""

				M.resAtlasArray[szAtlas][szSpineName]=nil
				if next(M.resAtlasArray[szAtlas])==nil then
					releaseAtlas=szAtlas
					M.resAtlasArray[szAtlas]=nil
				end

				sp.SkeletonAnimation:removeSkeletonCache(szSpineName,releaseAtlas)

				M.resArray[szSpineName]=nil
				gcprint("releaseAllSpine 释放=========>>>>",szSpineName)
			else
				gcprint("releaseAllSpine 主角=========>>>>",szSpineName,cc.Director:getInstance():getTextureCache():getTextureForKey(szPng))
			end
		else
			gcprint("releaseAllSpine 长期=========>>>>",szSpineName)
		end
	end
	gcprint("releaseAllSpine=========>>>> END")
end

function M.releaseSpineInView(_spineArray)
	local function delayFun()
		local nArray={}
		-- 有用到的坐骑
		for _,player in pairs(_G.CharacterManager.m_lpPlayerArray) do
			local mountArray=player.m_mountResArray
			if mountArray~=nil then
				for szName,_ in pairs(mountArray) do
					nArray[szName]=true
				end
			end
		end
		for _,pet in pairs(_G.CharacterManager.m_lpPetArray) do
			nArray[pet.m_szSpineName]=true
		end

		for szSpineName,_ in pairs(_spineArray) do
			local resData=M.resArray[szSpineName]
			if resData~=nil
				and not M.resRoleArray[szSpineName] 
				and not M.playerWeaponRes[szSpineName]
				and not M.playerMountRes[szSpineName]
				and not M.playerFeatherRes[szSpineName]
				and not nArray[szSpineName] then

				local szAtlas=resData.atlas
				local releaseAtlas=""

				M.resAtlasArray[szAtlas][szSpineName]=nil
				if not next(M.resAtlasArray[szAtlas]) then
					cc.Director:getInstance():getTextureCache():removeTextureForKey(resData.png)
					releaseAtlas=szAtlas
					M.resAtlasArray[szAtlas]=nil
				end

				sp.SkeletonAnimation:removeSkeletonCache(szSpineName,releaseAtlas)

				M.resArray[szSpineName]=nil

				GCLOG("releaseSpineInView======>>>>>szSpineName=%s,释放成功..",szSpineName)
			else
				GCLOG("releaseSpineInView======>>>>>szSpineName=%s,不释放..",szSpineName)
			end
		end
	end
	
	if _G.g_Stage==nil or _G.g_Stage.m_finallyInitialize then
		_G.Scheduler:performWithDelay(0.5,delayFun)
	end
end

-- ******************************************************
-- spine 创建接口
-- ******************************************************
function M.createSpine(_szName,_scale)
	local szSkel,szAtlas,szPng=M.getSpineData(_szName)

	local isBinary=_G.FilesUtil:check(szSkel)
    _scale=_scale or 1
    local spine=sp.SkeletonAnimation:createWithCache(_szName,szAtlas,isBinary)
    spine:setScale(_scale)

    M.__addResToArray(_szName,szSkel,szAtlas,szPng)

    return spine
end

function M.createMainPlayer(_scale)
	local myProperty=_G.GPropertyProxy:getMainPlay()
	local pro=myProperty:getPro()
	local weaponId=myProperty:getSkinWeapon()
	local featherId=myProperty:getSkinFeather()
	return M.createPlayer(pro,_scale,weaponId,featherId)
end
function M.createPlayer(_pro,_scale,_weaponId,_featherId)
	local skinId=10000+_pro
	local skinCnf=_G.g_SkillDataManager:getSkinData(skinId)
	local nScale=_scale or skinCnf.scale*0.0001
	local szName=string.format("spine/1%d010",_pro)
	local playerSpine=M.createSpine(szName,nScale)

	return playerSpine
	
	-- local wuqiSpine
	-- if not _weaponId or _weaponId==0 then
	-- 	playerSpine:setSkin("0")
	-- else
 --        local zOrder=_pro==_G.Const.CONST_PRO_ICEGIRL and 1 or -1
 --        wuqiSpine=M.createSpine(string.format("spine/wq_%d0101",_pro),1)
 --        if wuqiSpine then
 --        	playerSpine:addChild(wuqiSpine,zOrder)
 --        end
	-- 	playerSpine:setSkin("101")
	-- end

	-- local featherSpine
	-- if _featherId and _featherId~=0 then
	-- 	featherSpine=M.createSpine(string.format("spine/%d",_featherId),1)
 --        if featherSpine then
 --        	playerSpine:addChild(featherSpine,-10)
 --        end
	-- end

	-- return playerSpine,wuqiSpine,featherSpine
end
function M.createPartner(_partnerId,_scale)
	local partnerCnf=_G.Cfg.partner_init[_partnerId]
	if partnerCnf==nil then return end
	local nScale=_scale or partnerCnf.scale*0.0001
	local szName=string.format("spine/%d",partnerCnf.skin)
	local partnerSpine=M.createSpine(szName,nScale)
	return partnerSpine,szName
end
function M.createNpc(_skinId,_scale)
	local szName=string.format("spine/%d",_skinId)
	local npcSpine=M.createSpine(szName,_scale or M.SCALE_NPC)
	return npcSpine,szName
end


function M.addSpineCache(_szName,_szAtlas)
	if M.resArray[_szName] then return end

	local szSkel,szAtlas,szPng=M.getSpineData(_szName)
	local isBinary=true
    sp.SkeletonAnimation:addSkeletonCache(_szName,szAtlas,isBinary)
    
    M.__addResToArray(_szName,szSkel,szAtlas,szPng)

    print("addSpineCache======>>>>>>>>",_szName,isBinary)
end

function M.__addResToArray(_szName,_szSkel,_szAtlas,_szPng)
	M.resArray[_szName]={}
    M.resArray[_szName].png=_szPng
    M.resArray[_szName].name=_szName
    M.resArray[_szName].atlas=_szAtlas

    if not M.resAtlasArray[_szAtlas] then
    	M.resAtlasArray[_szAtlas]={}
    end

    M.resAtlasArray[_szAtlas][_szName]=true;
end

function M.getSpineData(_szName)
	local szSkel=string.format("%s.skel",_szName)
	local szAtlas,szPng

	local atlasName=_G.Cfg.spine_res[szSkel]
	if atlasName then
		szAtlas=string.format("%s.atlas",atlasName)
		szPng=string.format("%s.png",atlasName)
	else
		szAtlas=string.format("%s.atlas",_szAtlas or _szName)
		szPng=string.format("%s.png",_szAtlas or _szName)
	end
	return szSkel,szAtlas,szPng
end

function M.initRoleCache()
	if _G.SysInfo:isIpNetwork() then
		-- M.addSpineCache("spine/10001")
		-- M.addSpineCache("spine/10002")
		-- M.addSpineCache("spine/10003")
		-- M.addSpineCache("spine/10005")
		M.addSpineCache("spine/11010")
		M.addSpineCache("spine/12010")
	else
		-- M.addSpineCache("spine/10001")
		-- M.addSpineCache("spine/10002")
		-- M.addSpineCache("spine/100021")--职业2的战斗皮肤
		-- M.addSpineCache("spine/10005")
		M.addSpineCache("spine/11010")
		M.addSpineCache("spine/12010")
	end
end


