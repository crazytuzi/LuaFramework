--------------------------------------------------------------------------------------
-- 文件名:	ServerListInfo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:  致歉公告
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


--[[玩家点击屏幕的时候判断下时间
1，如果是在9月14日 00:00 ~9月15日 11:00。直接弹出这个公告，然后在公告界面关闭的时候，调用创建角色或进入游戏的逻辑。
2，如果不在这个时间段内的话，判断玩家当前账号是否哦是李奎里面记录的老玩家账号列表，如果是，则判断时间，在一周之内，每次点击StartGame都弹出这个公告]]

Sys_EmergencyNotice = class("Sys_EmergencyNotice")
Sys_EmergencyNotice.__index = Sys_EmergencyNotice


function Sys_EmergencyNotice:ctor()

    self.TimeRangType = 
    {
        Type_none        = 1,   --位置类型，不再时间范围
        Type_11hour      = 2,   -- 2015-09-14 00:00:00 到 2015-09-15 11:00:00
        Type_11hour_week = 3    -- 2015-09-15 11:00:00 到 2015-09-21 11:00:00
    }

    --计算时间 
    local t = os.time()
    -- 2015-09-14 00:00:00 到 2015-09-15 11:00:00
    local hourTimeRange = {  tStart = os.time({year=2015, month=9, day=14, hour=0, min=0, sec=0}), 
                            tEnd = os.time({year=2015, month=9, day=15, hour=11, min=0, sec=0})} 
    -- 2015-09-15 11:00:00 到 2015-09-21 11:00:00
    local weekTimeRange = {  tStart = os.time({year=2015, month=9, day=15, hour=11, min=0, sec=0}), 
                            tEnd = os.time({year=2015, month=9, day=21, hour=11, min=0, sec=0})}
                             
    self.CurTimeRangType = nil
    if hourTimeRange.tStart <= t and hourTimeRange.tEnd > t then
        self.CurTimeRangType = self.TimeRangType.Type_11hour
    elseif weekTimeRange.tStart <= t and weekTimeRange.tEnd > t then
        self.CurTimeRangType = self.TimeRangType.Type_11hour_week
    else
        self.CurTimeRangType = self.TimeRangType.Type_none
    end
    
    --加载老账号列表
    self.OldAccounts = g_DataMgr:getCsvConfig("OldAccounts")
    --有没有角色
    self.bNewPlayer = false
    --sorry窗口
    self.EmergencyNoticeWnd = nil
    --外部场景
    self.Scene = nil
end

--检查是不是老账号
function Sys_EmergencyNotice:CheckOldAccounts(uin)
    return self.OldAccounts[uin] ~= nil
end

--sorry公告关闭时调用
function Sys_EmergencyNotice:OnNoticeWndClose()
	if self.EmergencyNoticeWnd then
		self.EmergencyNoticeWnd:removeFromParentAndCleanup(true)
		self.EmergencyNoticeWnd = nil
	end

    if self.bNewPlayer then
        g_MsgMgr:requestRandomName()
    elseif self.Scene ~= nil then
        local loadingCity = Game_LoadingCity.new()
	    loadingCity:initView() 
	    self.Scene:addChild(loadingCity,10)
        RequestLogin()
    end
end

--需不需要saysorry
function Sys_EmergencyNotice:IsSaySorry(bNewPlayer, Scene)

    self.bNewPlayer = bNewPlayer
    self.Scene = Scene
    if self.CurTimeRangType == self.TimeRangType.Type_11hour then 
        self:openEmergencyNotice() return true
    elseif self.CurTimeRangType == self.TimeRangType.Type_11hour_week and self:CheckOldAccounts(g_MsgMgr:getPlatformUin()) then
        self:openEmergencyNotice() return true
    else
        return false
    end
end

--打开sorry窗口
function Sys_EmergencyNotice:openEmergencyNotice()
	self.EmergencyNoticeWnd = GUIReader:shareReader():widgetFromJsonFile("Game_EmergencyNotice.json")
	StartGameLayer:addWidget(self.EmergencyNoticeWnd)
	self.EmergencyNoticeWnd:setTouchEnabled(true)
	self.EmergencyNoticeWnd:addTouchEventListener(function(pSender,eventType) return end)
	local Button_Close = tolua.cast(self.EmergencyNoticeWnd:getChildByName("Button_Return"), "Button")
	local function onClick_Button_Close(pSender, nTag)
		if gSys_EmergencyNotice then
			gSys_EmergencyNotice:OnNoticeWndClose()
		end
	end
	g_SetBtnWithEvent(Button_Close, 1, onClick_Button_Close, true)
	
	local Image_EmergencyNoticePNL = tolua.cast(self.EmergencyNoticeWnd:getChildByName("Image_EmergencyNoticePNL"), "ImageView")
	local Image_Logo = tolua.cast(Image_EmergencyNoticePNL:getChildByName("Image_Logo"), "ImageView")
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
end

gSys_EmergencyNotice = Sys_EmergencyNotice.new()

------------------------------
Game_EmergencyNotice = class("Game_EmergencyNotice")
Game_EmergencyNotice.__index = Game_EmergencyNotice

function Game_EmergencyNotice:initWnd()
    return true
end

function Game_EmergencyNotice:closeWnd()
    gSys_EmergencyNotice:OnNoticeWndClose()
end
