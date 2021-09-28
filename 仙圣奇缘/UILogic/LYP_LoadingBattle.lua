--------------------------------------------------------------------------------------
-- 文件名:	LYP_WorldBossRank.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-20 9:37
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_LoadingBattle = class("Game_LoadingBattle")
Game_LoadingBattle.__index = Game_LoadingBattle

function Game_LoadingBattle:ctor()
	self.nMaxCount = 1
	self.nCurCount = 0
end

function Game_LoadingBattle:initWnd()
	local Image_LoadingBase = tolua.cast(self.rootWidget:getChildByName("Image_LoadingBase"), "ImageView")
	self.LoadingBar_Loading = tolua.cast(Image_LoadingBase:getChildByName("LoadingBar_Loading"), "LoadingBar")
	self.Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	
	local Image_NPC = tolua.cast(self.rootWidget:getChildByName("Image_NPC"), "ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	Image_NPC:removeAllNodes()
	Image_NPC:loadTexture(getUIImg("Blank"))
	Image_NPC:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	local Image_Logo = tolua.cast(self.rootWidget:getChildByName("Image_Logo"), "ImageView")
	if g_Cfg.Platform  == kTargetWindows then --Windows
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
			end
		else
			if g_IsXiaoXiaoXianSheng then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
			elseif g_IsXianJianQiTan then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			end
		end
	elseif g_Cfg.Platform  == kTargetAndroid then --Android
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
			end
		else
			if g_IsXiaoXiaoXianSheng then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
			elseif g_IsXianJianQiTan then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			end
		end
	else --iOS越狱
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
			end
		else
			if g_IsXiaoXiaoXianSheng then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
			elseif g_IsXianJianQiTan then
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			else
				Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
			end
		end
	end

	-- 进入战斗之前主动回收一次Lua缓存
	collectgarbage("collect")
    collectgarbage("stop")
 end 

 
function Game_LoadingBattle:closeWnd()
	-- g_FormMsgSystem:UnRegistFormMsg(FormMsg_BattleLoading_Loading)
	-- g_FormMsgSystem:UnRegistFormMsg(FormMsg_BattleLoading_Member)

    self.nMaxCount = 1
	self.nCurCount = 0
	
    if self.armature then
	    self.armature:removeFromParentAndCleanup(true)
	    self.armature = nil
    end

    if self.ntimeid ~= nil then
    	g_Timer:destroyTimerByID(self.ntimeid)
    	self.ntimeid  = nil
    end
	
	self.Image_Background:loadTexture(getUIImg("Blank"))
end

local fTotalTime = 0.25
local nBeginPosX = 340
function Game_LoadingBattle:setProcess(nCurCount)
	if g_WndMgr:getWnd("Game_LoadingBattle") then
		local nPercent = nCurCount/self.nMaxCount
		if self.LoadingBar_Loading and self.LoadingBar_Loading:isExsit() then
			self.LoadingBar_Loading:setPercent(nPercent*100)
		end
		
		if self.armature ~= nil then
			self.armature:setPositionX(nBeginPosX + nPercent*550)
		end
	end
end

function Game_LoadingBattle:showProcess()
    self.nCurCount = self.nCurCount + 1
    self:setProcess(self.nCurCount)
	-- local function loopSetProcess(fInterval, bEnd)
	-- if not g_WndMgr:getWnd("Game_LoadingBattle") then return true end
	  -- nCount = nCount + 1
	  -- self:setProcess(nCount)

	  -- if bEnd and self.func ~= nil then
		 -- self.func()
	  -- end
	-- end

	-- self.ntimeid = g_Timer:pushLimtCountTimer(nProcessScale, 0, loopSetProcess) 
end

function Game_LoadingBattle:LoadingShaderSH3()
	-- g_setImgShader(self.Image_Background, pszBlurFSH3)
	if self.func ~= nil then
		self.func()
	end
end

function Game_LoadingBattle:LoadingMember()
	--内存
	if TbBattleReport then
		self.Image_Background:loadTexture(g_BattleData:getBackgroundPic(1))
	end
	
	self.rootWidget:removeAllNodes()
	local armature, userAnimation = g_CreateCoCosAnimation("BattleLoading", nil, 2)
	userAnimation:playWithIndex(0)
	self.armature = armature
	
	self.rootWidget:addNode(self.armature)
	self.armature:setZOrder(4)
 
    self.armature:setPositionXY(nBeginPosX,140)
    
	
    -- 下一帧
    -- g_FormMsgSystem:SendFormMsg(FormMsg_BattleLoading_Loading, nil)
end

--显示主界面的卡牌详细介绍界面
function Game_LoadingBattle:openWnd(tbData)
	if not tbData then return end
	
	self.nMaxCount = 0
	self.func = nil
	if tbData ~= nil then
		 self.nMaxCount = tbData.nLoop 
		 self.func = tbData.func
		 --g_pushLimtCountTimer(fTotalTime/(self.nMaxCount+1), self.nMaxCount+1, self.func, self.rootWidget)
         g_Timer:pushLimtCountTimer(self.nMaxCount+1, fTotalTime/(self.nMaxCount+1), self.func)
	end
	
    
	-- 预加载窗口缓存防止卡顿
	g_WndMgr:getFormtbRootWidget("Game_BatWin1")
	-- 预加载窗口缓存防止卡顿
	if g_BattleMgr:getIsFirstInThisBattle() then
		g_WndMgr:getFormtbRootWidget("Game_Dialogue")
	end
    
	self.nCurCount = 0
	self:setProcess(0)

	-- g_FormMsgSystem:SendFormMsg(FormMsg_BattleLoading_Member, nil)
	self:LoadingMember()
	-- self:LoadingShaderSH3()
	
	local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
	if wndInstance then
		wndInstance.Image_Background:loadTexture(getUIImg("Blank"))
	end
end