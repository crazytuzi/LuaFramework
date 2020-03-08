Ui = Ui or {}

Ui.UIAnchor = luanet.import_type("UIAnchor");
Ui.GameObject = luanet.import_type("UnityEngine.GameObject");
Ui.CameraMgr = luanet.import_type("CameraMgr");
Ui.Effect = luanet.import_type("RepresentMgr");
Ui.ToolFunction = luanet.import_type("ToolFunction");
Ui.Screen = luanet.import_type("UnityEngine.Screen");
Ui.ResourceLoader = luanet.import_type("ResourceLoader");
Ui.RepresentSetting = luanet.import_type("RepresentSetting");
Ui.NpcViewMgr = luanet.import_type("NpcViewMgr");

local UiManager = luanet.import_type("UiManager");
Ui.UiManager = UiManager;
Ui.SoundManager = luanet.import_type("SoundManager");

local CoreDll = luanet.import_type("CoreInterface.CoreDll")
Ui.CoreDll = CoreDll;

local Updater = luanet.import_type("Updater");
Ui.Updater = Updater;

local Application = luanet.import_type("UnityEngine.Application")
Ui.Application = Application;

Ui.FTDebug = luanet.import_type("FtDebug");
Ui.SceneMgr = Ui.SceneMgr or luanet.import_type("UnityEngine.SceneManagement.SceneManager");
Ui.SceneMgr_CS = Ui.SceneMgr_CS or luanet.import_type("SceneMgr");

Ui.CoroutineManager = Ui.CoroutineManager or luanet.import_type("CoroutineManager");

local TouchMgr = luanet.import_type("TouchMgr");
local SkillController = luanet.import_type("SkillController");
local SdkMgr = luanet.import_type("SdkInterface")

-- 注意：此枚举要与C#内的Ui_Layer 保持一致
Ui.LAYER_BG 		= 1;			-- 背景层
Ui.LAYER_HOME 		= 2;			-- 主界面层
Ui.LAYER_NORMAL		= 3;			-- 普通浮动层
Ui.LAYER_PANDORA	= 4;			-- tencent pandora 精细化运营UI
Ui.LAYER_EXCLUSIVE	= 5;			-- 独占层
Ui.LAYER_POPUP		= 6;			-- 弹出式菜单层
Ui.LAYER_GUIDE		= 7;			-- 引导层
Ui.LAYER_INFO		= 8;			-- 提示层（各种提示界面等）
Ui.LAYER_LOADING	= 9;			-- 加载图所处层
Ui.LAYER_DEBUG		= 10;			-- 调试层

Ui.BUTTON_STATE = {
	Normal = 0,
	Hover = 1,
	Pressed = 2,
	Disabled = 3,
}

local tbUI_EVENT =
{
	-- 以下顺序要满足 C# 内对应枚举顺序
	"tbOnClick",
	"tbOnSubmit",
	"tbOnDoubleClick",
	"tbOnHover",
	"tbOnPress",
	"tbOnSelect",
	"tbOnScroll",
	"tbOnDrag",
	"tbOnDrop",
	"tbOnKey",
	"tbOnDragEnd",
	"tbOnLongPress",
	"tbUiInputOnChange",
	"tbUiPopupOnChange",

	"tbOnCallBack",
}

Ui.tbQualityRGB = {
    "ffffff",
    "62cc40",
    "2fb7ee",
    "e43eff",
    "fdaf07",
    "d6df3d",
}

Ui.bInitVoiceCfg = false

local tbQuickUseItemClass =
{
	"RandomItem",
	"TimeCase",
	"AlphaChargeAward",
	"Speaker",
	"SkillBookExp",
	"FurnitureItem",
	"AddPlayerLevel",
	"LotteryTicket",
	"WeddingWelcome", --婚礼请柬
	"HouseWaiYiItem", --家园皮肤
	"Toy",
	"ShengDianLing",
	"RechargeSumOpenKey",--充值返利钥匙
	"AddExtDayTargetActvie",--桂花糕
}


Ui.tbSafeAreaOffset =
{
	--x,y,width,height
	["Windows"] = {0, 0, 0, 0},
	["iPhone10,3"] = {-40, 3, 80, 60},
	["iPhone10,6"] = {-40, 3, 80, 60},
	["iPhone11,2"] = {-40, 3, 80, 60},
	["iPhone11,4"] = {-40, 3, 80, 60},
	["iPhone11,6"] = {-40, 3, 80, 60},
	["iPhone11,8"] = {-40, 3, 80, 60},
	["iPhone12,1"] = {-40, 3, 80, 60},
	["iPhone12,3"] = {-40, 3, 80, 60},
	["iPhone12,5"] = {-40, 3, 80, 60},

	["vivo NEX"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo X21"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo X21A"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo X23"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Z1"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Z1i"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Z3"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Z3i"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Y85"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Y85A"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo Y97"] = {45, 0, -90, 0, nWidthLimit=1400},
	["vivo V9"] = {45, 0, -90, 0, nWidthLimit=1400},

	["xiaomi Mi8"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8 Explorer"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8 Pro"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8 UD"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8 SE"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8i"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi M1808D2TE"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi M1808D2TC"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi8 Youth"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi Mi 8 Lite"] = {45, 0, -90, 0, nWidthLimit=1400},
	["xiaomi M1805D1SE"] = {45, 0, -90, 0, nWidthLimit=1400},

	["PBEM00"] = {70, 0, -140, 0, nWidthLimit=1400},--oppo R17
	["PBET00"] = {70, 0, -140, 0, nWidthLimit=1400},
	["PACM00"] = {70, 0, -140, 0, nWidthLimit=1400},--R15
	["PACT00"] = {70, 0, -140, 0, nWidthLimit=1400},
	["PADT00"] = {70, 0, -140, 0, nWidthLimit=1400},--A3
	["PADM00"] = {70, 0, -140, 0, nWidthLimit=1400},--A5
	["PBCT10"] = {70, 0, -140, 0, nWidthLimit=1400},--k1
	["PBCM10"] = {70, 0, -140, 0, nWidthLimit=1400},
	['PBFM00']={60, 0, -120, 0, nWidthLimit=1400},
	['PAAM00']={60, 0, -120, 0, nWidthLimit=1400},
	['PCDT00']={60, 0, -120, 0, nWidthLimit=1400},
	['PCDM00']={60, 0, -120, 0, nWidthLimit=1400},
	['PAAT00']={60, 0, -120, 0, nWidthLimit=1400},
	['CPH1851']={60, 0, -120, 0, nWidthLimit=1400},
	['CPH1833']={60, 0, -120, 0, nWidthLimit=1400},
	['CPH1831']={60, 0, -120, 0, nWidthLimit=1400},
	['CPH1835']={60, 0, -120, 0, nWidthLimit=1400},

	['V1818A']={60, 0, -120, 0, nWidthLimit=1400},

	["huawei CLT-L04"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-L09"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-L09C"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-L29"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-L29C"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro
	["huawei CLT-AL01"] = {45, 0, -90, 0, nWidthLimit=1400},--p20 pro

	["huawei Mate 20 Pro UD"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei EML-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-TL00"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-L09"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-L29"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-LX9"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei HMA-L29"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei SNE-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei SNE-LX1"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei LYA-L09"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei LYA-L0C"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei LYA-L29"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	['huawei LYA-TL00']={45, 0, -90, 0, nWidthLimit=1400},
	['huawei LYA-AL00']={45, 0, -90, 0, nWidthLimit=1400},
	['huawei LYA-LX9']={45, 0, -90, 0, nWidthLimit=1400},
	['huawei LYA-AL10']={45, 0, -90, 0, nWidthLimit=1400},
	["huawei EVR-L29"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20
	["huawei EVR-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--mate 20

	["huawei PAR-LX1"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei PAR-LX1M"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei PAR-LX9"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei PAR-TL20"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei PAR-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei ANE-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3
	["huawei INE-LX2"] = {45, 0, -90, 0, nWidthLimit=1400},--nova 3

	["huawei JSN-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 8x
	["huawei JSN-AL00a"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 8x
	["huawei JSN-TL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 8x
	["huawei JSN-L21"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 8x
	["huawei ARE-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 8x

	["huawei COL-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 10
	["huawei COL-AL10"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 10
	["huawei COL-TL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 10
	["huawei COL-TL10"] = {45, 0, -90, 0, nWidthLimit=1400},--honor 10

	["huawei COR-AL00"] = {45, 0, -90, 0, nWidthLimit=1400},--honor play

	['huawei PCT-AL10']={45, 0, -90, 0, nWidthLimit=1400},

	["oneplus A6000"] = {45, 0, -90, 0, nWidthLimit=1400},--6
	["oneplus A6003"] = {45, 0, -90, 0, nWidthLimit=1400},--6
	["oneplus A6013"] = {45, 0, -90, 0, nWidthLimit=1400},--6

	["SM-G9700"] = {110, 0, -220, 0, nWidthLimit=1920},
	["SM-G9730"] = {110, 0, -220, 0, nWidthLimit=1920},
	["SM-G9750"] = {110, 0, -220, 0, nWidthLimit=1920},
}

local tbMeta =
{
	__call = function(self, szUiGroup)
		local tbUi = self.tbUi[szUiGroup];
		if (not tbUi) then
			print(debug.traceback());
		end
		return tbUi;
	end
};

setmetatable(Ui, tbMeta);

function Ui:Init()
	self.tbClass = {};
	self.tbUi = {};
	self.WndState = {};
	self.HyperTextHandle = {};
	self.tbWaitingForOpen = {};
	self.tbNotifyMsgDatas = {}; --通知消息中心
	self.nUnReadNotifyMsgNum = 0;--通知消息中心未读消息数
	self.tbCenterMsg = {};

	self.tbPreLoadUi = {};
end

if not Ui.tbClass then
	Ui:Init();
end

function Ui:CreateClass(szClass)
	self.tbClass[szClass] = self.tbClass[szClass] or {} --Lib:NewClass(Ui.tbDefault);
	return self.tbClass[szClass];
end

function Ui:GetClass(szClass)
	return self.tbClass[szClass];
end

function Ui:MountUi(szUiName)
	if next(self.tbPreLoadUi) then
		table.insert(self.tbPreLoadUi, szUiName);
		return;
	end

	table.insert(self.tbPreLoadUi, szUiName);
	print("UiManager.MountUi", szUiName)
	UiManager.MountUi(szUiName)
end

function Ui:OnLoadUiEnd(szUiName)
	for i = #self.tbPreLoadUi, 0, -1 do
		if szUiName == self.tbPreLoadUi[i] then
			table.remove(self.tbPreLoadUi, i)
		end
	end
	if next(self.tbPreLoadUi) then
		local szNexUi = self.tbPreLoadUi[1]
		UiManager.MountUi(szNexUi);
	else
		Ui:OnPreLoadEmpty()
	end
end

function Ui:OnPreLoadEmpty()
	if self.szPreloadState == "loading" then
		Ui:CloseWindow("MapLoading");
		self.szPreloadState = "end"
	end
end


function Ui:PreloadUiList()
	if not self.szPreloadState then
		self.szPreloadState = "loading";
		local tbPreLoadUi =
		{
			"MessageBox",
			"RoleHead",
			"ChatSmall",
			"FakeJoyStick",
			"SystemNotice",
			"LoadingTips",
			"TopButton",
			"CreateRole",
			"AchievementPanel",
			"NotifyMsgList",
			"MapLoading",
			"WelfareActivity",
		}

		for _, szUiName in ipairs(tbPreLoadUi) do
			self:PreLoadWindow(szUiName);
		end
	end
end

function Ui:PreLoadWindow(szUiName)
	if  self.tbUi[szUiName] then
		Log(">>>> Exist ", szUiName)
		return
	end
	Ui:MountUi(szUiName);
	--UiManager.MountUi(szUiName)
end

-- 打开窗口
function Ui:OpenWindow(szUiName, ...)
	local bRet = Ui:IsForbidShowUI(szUiName);
	if bRet then
		return;
	end

	return self:OpenWindowAtPos(szUiName, -1, -1, ...);
end

function Ui:OpenWindowAtPos(szUiName, nPosX, nPosY, ...)
	local arg = {...};
	self:CheckAndRefreshClass(szUiName);	-- 检查UI脚本对象，发现重载脚本则更新
	local tbWnd = self.tbUi[szUiName];
	if (not tbWnd) then
		Ui:MountUi(szUiName);
		--UiManager.MountUi(szUiName)
		self.tbWaitingForOpen[szUiName] = {nPosX, nPosY, unpack(arg)};
		return;
	end
	self.tbWaitingForOpen[szUiName] = nil;
	if (self:WindowVisible(szUiName) == 1) then
		self:CloseWindowAni(szUiName, false, unpack(arg));		-- 已经打开则需要先执行关闭
	end
	local nRetCode = 1;

	if not tbWnd then
		print("Ui:OpenWindowAtPos", szUiName)
		return;
	end

	if (tbWnd.CanOpenWnd) then
		if (tbWnd:CanOpenWnd() == 0) then
			return;
		end
	end
	if tbWnd.OnOpen then
		local bRet, nOpenRetCode = Lib:CallBack({tbWnd.OnOpen, tbWnd, unpack(arg)});
		nOpenRetCode = nOpenRetCode or 1;
		nRetCode = bRet and nOpenRetCode or 0;		-- 打开前
		if (not bRet) then
			print(nOpenRetCode);
			Log(debug.traceback());
		end
	end
	if nRetCode == 1 then
		self.WndState[szUiName] = 1;
		UiManager.ShowUi(szUiName, nPosX, nPosY, true);
		if tbWnd.OnOpenEnd then
			local bRet, nOpenRetCode = Lib:CallBack({tbWnd.OnOpenEnd, tbWnd, unpack(arg)});
			if (not bRet) then
				print(nOpenRetCode);
				Log(debug.traceback());
			end
		end
		UiNotify.OnNotify(UiNotify.emNOTIFY_WND_OPENED, szUiName);
	else
		self:CloseWindow(szUiName, unpack(arg));		-- 打开失败要执行关闭操作
	end

	if self:IsUiHideVisable(szUiName) then
		tbWnd.pPanel:SetActive("Main", false);
		self.tbHideUi[szUiName] = true;
	end
	--Wnd_BringTop(szUiName);
	return nRetCode;
end

-- 关闭窗口
function Ui:CloseWindow(szUiName, ...)
	Ui:CloseWindowAni(szUiName, true, ...)
end

function Ui:CloseWindowAni(szUiName, bShowCloseAni, ...)
	local arg = {...};
	local tbWnd = self.tbUi[szUiName];
	if (not tbWnd) then
		self.tbWaitingForOpen[szUiName] = nil;
		return;
	end
	if (self:WindowVisible(szUiName) ~= 1) then
		return;											-- 已经关闭了就什么都不做
	end

	if tbWnd.OnClose then
		-- 关闭前
		local bRet, nCloseRetCode = Lib:CallBack({tbWnd.OnClose, tbWnd, unpack(arg)});
		if (not bRet) then
			print(nCloseRetCode);
			Log(debug.traceback());
		end
	end

	if tbWnd.Init then
		-- 存在初始化函数则调用之
		local bRet, nInitRetCode = Lib:CallBack({tbWnd.Init, tbWnd});
		if (not bRet) then
			print(nInitRetCode);
			Log(debug.traceback());
		end
	end

	self.WndState[szUiName] = nil;
	UiManager.HideUi(szUiName, bShowCloseAni);
	UiNotify.OnNotify(UiNotify.emNOTIFY_WND_CLOSED, szUiName);
	Pandora:OnWindowClose(szUiName);
	local tbList = Ui.tbSameWindowList[szUiName]
	if tbList then
		table.remove(tbList)
		if next(tbList) then
			local tbArgs = tbList[#tbList]
			Ui:OpenWindow(szUiName, unpack(tbArgs))
		end
	else
		if self.tbCloseWindowListOverLap[szUiName] then
			self.tbCloseWindowListOverLap[szUiName] = nil
		else
			local tbList = Ui.tbSameWindowListOverLap[szUiName]
			if tbList then
				table.remove(tbList, 1)
				local tbArgs = tbList[1]
				if tbArgs then
					Ui:OpenWindow(szUiName, unpack(tbArgs))
				end
			end
		end

	end
end

function Ui:CloseAllWindow()
	for k,v in pairs(self.WndState) do
		Ui:CloseWindow(k)
	end
	self.tbWaitingForOpen = {}
end

--按队列顺序打开界面，如果嵌套打开同样的界面，会等前面界面结束了再打开新的界面
Ui.tbSameWindowList = {};
function Ui:OpenWindowList(szWnd, ...)
	Ui.tbSameWindowList[szWnd] =Ui.tbSameWindowList[szWnd] or {}
	local tbList = Ui.tbSameWindowList[szWnd]
	table.insert(tbList, 1, {...})
	if #tbList > 1 then
		if #tbList > 3 then --凭证失效这种提示可能会非常多,直接让前面的顶掉保留最后3个
			local tbArgs = tbList[#tbList - 1]
			if not self.tbUi[szWnd] then
				 table.remove(tbList)
			end
			Ui:OpenWindow(szWnd, unpack(tbArgs) )
		end
		return
	end
	Ui:OpenWindow(szWnd, ...)
end

Ui.tbSameWindowListOverLap = {};
Ui.tbCloseWindowListOverLap = {};
function Ui:OpenWindowListOverLap(szWnd, ...)
	Ui.tbSameWindowListOverLap[szWnd] =Ui.tbSameWindowListOverLap[szWnd] or {}
	local tbList = Ui.tbSameWindowListOverLap[szWnd]
	table.insert(tbList, 1, {...})
	if #tbList > 1 then
		if #tbList > 3 then --凭证失效这种提示可能会非常多,直接让前面的顶掉保留最后3个
			table.remove(tbList)
		end
		Ui.tbCloseWindowListOverLap[szWnd] = 1; --
	end
	Ui:OpenWindow(szWnd, ...)
end

function Ui:CloseBlackBgWindow()
	for szUiName, tb in pairs(self.tbUi) do
		if tb.bBlackBg then
			Ui:CloseWindow(szUiName)
		end
	end
end

-- 切换窗口状态，开着的关掉，关着的开起来
function Ui:SwitchWindow(szUiName, ...)
	self:SwitchWindowAtPos(szUiName, -1,-1, ...)
end

function Ui:SwitchWindowAtPos(szUiName, nX, nY, ... )
	local arg = {...};
	if szUiName == "Commander" and Sdk:IsPCVersion() then	-- PC版不允许通过SwitchWindow 打开GM面板
		return;
	end
	if self:WindowVisible(szUiName) ~= 1 then
		self:OpenWindowAtPos(szUiName, nX, nY, unpack(arg));
	else
		self:CloseWindow(szUiName, unpack(arg));
	end
end

-- 查看窗口是否打着
function Ui:WindowVisible(szUiName)
	return self.WndState[szUiName];
end


function Ui:CheckAndRefreshClass(szUiName)
	local tbWnd = self.tbUi[szUiName];
	if tbWnd and tbWnd.szClass then
		if tbWnd._tbBase ~= self.tbClass[tbWnd.szClass] then
			print("Class Reload", tbWnd.UI_NAME, tbWnd.szClass);
			-- 实例的基类不等于模板的基类，说明UI脚本重载过，更新UI脚本对象
			-- 先反注册消息
			if tbWnd.RegisterEvent then
				local tbReg = tbWnd:RegisterEvent();
				for _, tbEvent in pairs(tbReg) do
					UiNotify:UnRegistNotify(tbEvent[1], tbEvent[3] or tbWnd); -- 注册响应事件
				end
			end
			Ui.CreateUiLuaObj(tbWnd.pPanel, tbWnd.szClass, tbWnd.UI_NAME)	-- 重新生成UI脚本对象
		end
	end
end

function Ui.CreateUiLuaObj(pObj, szClass, szUiName)
	local tbClass = Ui.tbClass[szClass];
	local tbWnd
	if (not tbClass) then
		print("[ERR] UI \""..szClass.."\" Class is not Exist");
		return;
	else
		tbWnd = Lib:NewClass(tbClass);
		tbWnd.UI_NAME = szUiName;		-- 为每个窗口表设置实例名
		tbWnd.szClass = szClass;
		Ui.tbUi[szUiName] = tbWnd;
		tbWnd.pPanel = pObj;
		tbWnd._ListOfCom = {};			-- 组件列表，卸载时需要

		if tbWnd.OnCreate then			-- 初始化
			tbWnd:OnCreate();
		end

		-- 注册事件响应
		if tbWnd.RegisterEvent then
			local tbReg = tbWnd:RegisterEvent();
			for _, tbEvent in pairs(tbReg) do
				UiNotify:RegistNotify(tbEvent[1], tbEvent[2], tbEvent[3] or tbWnd); -- 注册响应事件
			end
		end
	end
	Ui:OnLoadUiEnd(szUiName)
	return tbWnd;
end

-- 销毁UI对象
function Ui.OnDestroyUi(szUiName)
	if not Ui.tbUi[szUiName] then
		return;		-- 已经释放或根本就没创建
	end
	local tbWnd = Ui.tbUi[szUiName]
	Ui.tbUi[szUiName] = nil;
	Ui.WndState[szUiName] = nil;
	Ui:OnDestroyWndCom(tbWnd)
end

function Ui:OnDestroyWndCom(tbWnd)
	if tbWnd.RegisterEvent then
		local tbReg = tbWnd:RegisterEvent();
		for _, tbEvent in pairs(tbReg) do
			UiNotify:UnRegistNotify(tbEvent[1], tbEvent[3] or tbWnd); -- 注册响应事件
		end
	end

	for i, szComName in ipairs(tbWnd._ListOfCom) do
		if tbWnd[szComName] then
			self:OnDestroyWndCom(tbWnd[szComName])
		end
	end

	if tbWnd.OnDestroyUi then
        tbWnd:OnDestroyUi()
    end
end

-- 创建组件脚本对象
function Ui.CreateComLua(pObj, tbParent, szSelfName)
	local tbClass = Ui.tbClass[pObj.UiClass];
	local tbCom;
	if (not tbClass) then
		print("[ERR] " .. (tbParent.UI_NAME or "Unknow Ui") .. " WndCom \""..pObj.UiClass.."\" Class is not Exist!");
		return;
	else
		tbCom = Lib:NewClass(tbClass);
		tbCom.pPanel = pObj;
		tbCom._ListOfCom = {};
		tbCom.szClass = pObj.UiClass;
		tbCom.root = tbParent;
		if tbParent then
			tbParent[szSelfName] = tbCom;
			table.insert(tbParent._ListOfCom, szSelfName)
		end

		if tbCom.OnCreate then
			tbCom:OnCreate();
		end
	end

	return tbCom;
end

-- 注册事件响应关联
function Ui.RegisterEvent(pObj, tbLuaObj)
	for nEventKey, szEvent in pairs(tbUI_EVENT) do
		if tbLuaObj[szEvent] then
			for szWndName, _ in pairs(tbLuaObj[szEvent]) do
				pObj:RegisterEvent(nEventKey, szWndName);
			end
		end
	end
end

function Ui.OnUiLoadEnd(pObj, tbLuaObj)
	Ui.RegisterEvent(pObj, tbLuaObj)
	if Ui.tbWaitingForOpen[tbLuaObj.UI_NAME] then
		Ui:OpenWindowAtPos(tbLuaObj.UI_NAME, unpack(Ui.tbWaitingForOpen[tbLuaObj.UI_NAME]));
	end
end

function Ui.OnWndEvent(nEventKey, tbLuaObj, szWnd, ...)
	local szEvent = tbUI_EVENT[nEventKey];
	if not szEvent then
		print("[OnWndEvent] Ui Event unexist!!!", nEventKey);
		return;
	end

	if not tbLuaObj or not tbLuaObj[szEvent] then
		print("Ui or Callback Table is unexist", szEvent);
		return;
	end
	local fnCallback = tbLuaObj[szEvent][szWnd];
	if not fnCallback then
		return
	end

	fnCallback(tbLuaObj, szWnd, ...);
	Operation:MarkOperate();
end

function Ui:CheckWideScreenOffset()
	--Android 9以上通过系统API获取刘海屏大小
	if ANDROID then
		local bRet, nSdkVersion = Lib:CallBack({Sdk.GetAndroidSdkVersion, Sdk})
		if bRet and nSdkVersion >= 28 then
			local tbOffset = {0, 0, 0, 0}
			local bRet, szSafeAreaInset = Lib:CallBack({Sdk.GetSafeAreaInset, Sdk})
			if bRet and szSafeAreaInset and not Lib:IsEmptyStr(szSafeAreaInset) then
				local tbSafeAreaInset = Lib:SplitStr(szSafeAreaInset, "#")
				if #tbSafeAreaInset == 4 then
					local nTop, nBottom, nLeft, nRight = unpack(tbSafeAreaInset)
					nTop = tonumber(nTop)
					nBottom = tonumber(nBottom)
					nLeft = tonumber(nLeft)
					nRight = tonumber(nRight)
					if not (nTop == 0 and nBottom == 0 and nLeft == 0 and nRight == 0) then
						--获取到了安全区
						Ui.bAndroidSafeArea = true --用来决定设置里是否要显示适配刘海屏的选项
						local tbUserSet = Ui:GetPlayerSetting();
						if tbUserSet.nAdaptation == 1 then
							--用户选择了适配（默认选择）
							tbOffset[1] = math.max(nLeft, nRight, 0)				--x
							tbOffset[2] = math.max(nTop, nBottom, 0)				--y
							tbOffset[3] = -(tbOffset[1] * 2) 	--width，乘2是保证横屏状态下屏幕旋转，刘海在左右两侧都能正常显示，Android获取的宽度跟iOS不一样，不能左右相加
							tbOffset[4] = -(tbOffset[2] * 2) 	--height
							Log("Android 9 Screen Offset", unpack(tbOffset))
							return tbOffset
						end
						return
					end
				end
			end
		end
	end
	--Android 9以下或者没有获取到安全区，则根据手动配置来适配
	local szDeviceModel = Ui:GetDeviceModel();
	local tbOffset = self.tbSafeAreaOffset[szDeviceModel];
	if tbOffset and (not tbOffset.nWidthLimit or  tbOffset.nWidthLimit < Ui.Screen.width) then
		return tbOffset
	end
end

function Ui:InitGame()
	--修正safearea
	local tbOffset = Ui:CheckWideScreenOffset()
	if tbOffset then
		Log("Ui Set SafeArea Offset", unpack(tbOffset))
		Ui.UIAnchor.SetSafeAreaOffset(unpack(tbOffset));
	end

	Ui.tbPlayerHeadMgr:Init();
	Guide:RegisterEvent();
	Ui.Hotkey:Init()
	Lib:CallBack({Npc.InitGameC, Npc});

	UiNotify:RegistNotify(UiNotify.emNOTIFY_GAME_INIT_FINISH, self.OnGameInitFinish, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END, self.OnEnterGame,	self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_FIGHT_STATE, self.OnChangeFightState, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CONNECT_SERVER, self.OnStartConnectServer, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CONNECT_SERVER_END, self.OnConnectServerEnd, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_IFLY_IAT_RESULT, self.OnVoice2TxtResult, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self.OnMapLoaded, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnMapEnter, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PARTNER_ADD, self.OnCompanionShow, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_RECONNECT_FAILED, self.OnReConnectFaild, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, self.CheckHasCanQuickUseItem, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_TEAM_UPDATE, self.TeamUpdate, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_DROP_ITEM_TYPE, self.OnDropItemType, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT, self.ChangeAutoFight, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_ADD_SKILL, self.OnAddFightSkill, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_REMOVE_SKILL_STATE, self.OnRemoveSkillState, self);

	UiNotify:RegistNotify(UiNotify.emNOTIFY_RECORD_BEGIN, self.OnScreenRecordStart, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL, TeamMgr.OnLevelChanged, TeamMgr);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_CREATE_ROLE_RESPOND, Sdk.OnRoleCreate, Sdk);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SHAPE_SHIFT, self.AddShapeShift, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_REMOVE_SHAPE_SHIFT, self.RemoveShapeShift, self)

	--Timer:Register(1, Operation.InitGamesir, Operation)
end

function Ui:AddShapeShift()
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end

function Ui:RemoveShapeShift()
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)

    Timer:Register(1, self.UpdateNpcCurHP, self)
end

function Ui:UpdateNpcCurHP()
    local pNpc = me.GetNpc();
    if not pNpc then
    	return;
    end

    if pNpc.nCurLife > pNpc.nMaxLife then
    	pNpc.RestoreHP();
    end
end

function Ui:ChangeQuickUseOpen(nStart)
	local FloatingWindowDisplay = self:GetClass("FloatingWindowDisplay");
	if nStart == 1 then
		if Ui:WindowVisible("FloatingWindowDisplay") == 1 then
			Ui:CloseWindow("FloatingWindowDisplay");
		end
	end
	if nStart == 0 and #FloatingWindowDisplay.tbShowQueue > 0 then
		local nPop = FloatingWindowDisplay.tbShowQueue[#FloatingWindowDisplay.tbShowQueue];
		if me.GetItemInBag(nPop) then
			Ui:OpenWindow("FloatingWindowDisplay", nPop);
		end
	end
end

function Ui:TeamUpdate(szType)
    if szType == "TeamUpdate" then
    	AutoFight:OnUpdateTeamInfo();
    end
end

function Ui:ChangeAutoFight()
    local bAuto = AutoFight:IsAuto();
    if bAuto then
    	ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none);
    end
end

function Ui:OnAddFightSkill(nSkillID, nLevel)
   Lib:CallBack({FightSkill.OnAddFightSkill, FightSkill, nSkillID, nLevel});
end

function Ui:OnRemoveSkillState(nSkillID)
   Lib:CallBack({FightSkill.OnRemoveSkillState, FightSkill, nSkillID});
end

function Ui:OnDropItemType(nType)
	if nType == Item.DROP_OBJ_TYPE_SPE  then
		Ui.SoundManager.PlayUISound(8005);
	elseif nType == Item.DROP_OBJ_TYPE_MONEY then
		Ui.SoundManager.PlayUISound(8004);
	elseif nType == Item.DROP_OBJ_TYPE_ITEM then
		Ui.SoundManager.PlayUISound(8006);
	end
end

function Ui:CanQuickItem(szClass)
	for _, szName in pairs(tbQuickUseItemClass) do
		if string.find(szClass, szName) ~= nil then
			return true;
		end
	end

	return false;
end

Ui.tbNoQuickUseEquip = {
	["JuexueBook"]   = true,
	["MibenBook"]    = true,
	["DuanpianBook"] = true,
}
function Ui:CheckHasCanQuickUseItem(nItemId, bNew, nNumber)
	if not Login.bEnterGame then
		return;
	end

	bNew = (bNew and bNew == 1) and true or false;
	local pItem = me.GetItemInBag(nItemId)
	if pItem and pItem.nEquipPos >= 0 and pItem.nEquipPos < Item.EQUIPPOS_MAIN_NUM then
		if Item.EQUIPPOS_NAME[pItem.nPos] or (bNew and nNumber == 0) then
			Item.GoldEquip:UpdateSuitAttri(me)
			Item.GoldEquip:UpdateTrainAttri(me, pItem.nEquipPos)
		end
	end

	local tbEquip = me.GetEquips(1);
	local FloatingWindowDisplay = self:GetClass("FloatingWindowDisplay");
	if nItemId then
		if pItem and pItem.nEquipPos and
			pItem.nEquipPos ~= -1 and (pItem.nFactionLimit == 0 or pItem.nFactionLimit == me.nFaction) and
			not self.tbNoQuickUseEquip[pItem.szClass] then
			if nNumber <= 0 then
				FloatingWindowDisplay:HaveUse(nItemId);
			else
				if not tbEquip[pItem.nEquipPos] and Item:CheckUsable(pItem, pItem.szClass) == 1 and pItem.nPos == Item.EITEMPOS_BAG then
					for nTempy = 1, nNumber do
						table.insert(FloatingWindowDisplay.tbShowQueue,nItemId);
					end
					if self.nFightState == 0 and me.GetItemInBag(nItemId) then
						Ui:OpenWindow("FloatingWindowDisplay",nItemId);
					end
				end
			end
			return;
		end

		if Ui:CanQuickItem(pItem.szClass) and (bNew or nNumber ~= 0) then
			if nNumber <= 0 then
				FloatingWindowDisplay:HaveUse(nItemId);
			elseif Item:CheckUsable(pItem, pItem.szClass) == 1 then
				for nTempy = 1, nNumber do
					table.insert(FloatingWindowDisplay.tbShowQueue,nItemId);
				end
				if self.nFightState == 0 and me.GetItemInBag(nItemId) then
					Ui:OpenWindow("FloatingWindowDisplay",nItemId);
				end
			end
			return;
		end
	end
end

function Ui:OnCompanionShow(nPartnerId, nIsSync)
--[[
	if not Login.bEnterGame or nIsSync == 1 then
		return;
	end

	if not self:GetClass("CompanionShow").tbShowCompanion then
		self:GetClass("CompanionShow").tbShowCompanion = {};
	end

	if self:WindowVisible("CardPickingResult") == 1 or self.tbWaitingForOpen["CardPickingResult"] then
		table.insert(self:GetClass("CompanionShow").tbShowCompanion,nPartnerId);
		return;
	end

	table.insert(self:GetClass("CompanionShow").tbShowCompanion,nPartnerId);
	if self:WindowVisible("CompanionShow") ~= 1 then
		Ui:OpenWindow("CompanionShow",self:GetClass("CompanionShow").tbShowCompanion[1],0);
	end
]]
	return;
end

function Ui:CloseCompanion(tbCompanion, nType, nCardId)
	if #tbCompanion > 0 then
		Ui:OnCompanionClose(tbCompanion, nType, nCardId)
	else
		if next(Ui:GetClass("CompanionShow").tbShowPartnerCard) then
			Ui:OnCompanionClose(Ui:GetClass("CompanionShow").tbShowPartnerCard, 4, Ui:GetClass("CompanionShow").tbShowPartnerCard[1])
		end
	end
end

function Ui:CloseCardCompanion(tbCompanion, nType)
	if #tbCompanion > 0 then
		Ui:OnCompanionClose(tbCompanion, nType)
	else
		if next(Ui:GetClass("CompanionShow").tbShowCompanion) then
			Ui:OnCompanionClose(Ui:GetClass("CompanionShow").tbShowCompanion, 0)
		end
	end
end

function Ui:OnCompanionClose(tbCompanion, nType, nCardId)
	if #tbCompanion > 0 then
		if nType == 4 then
			Ui:OpenWindow("CompanionShow", nil, nType, tbCompanion[1]);
		else
			Ui:OpenWindow("CompanionShow", tbCompanion[1], nType, nCardId);
		end
	end
end

function Ui:AnormalCloseCompanion()
	self.bNowCompanionShow = false;
end


function Ui:OnGameInitFinish()
	Ui.ToolFunction.LoadMap(Login.szSceneMapName, Login.szSceneCameraName, 0, false)

	Ui:UpdateSoundSetting();
	Ui:UpdateDrawLevel();
	Lib:CallBack({PreloadResource.SetOnceRecycle, PreloadResource, true});

	Lib:CallBack({Operation.InitGamesir, Operation});
end

function Ui:ClearSysNotifyCation()
	Log("Ui:ClearSysNotifyCation==============")
	if ANDROID then
		UiManager.CleanNotification(1)
	elseif IOS then
		UiManager.CleanNotification(0) --有的时候调一次通知栏的会消失，但icon上还有，暂时调2次能解决
		UiManager.CleanNotification(0)
	end
end

function Ui:SetSysNotifyCation()
	if not Login.bEnterGame then
		return
	end
	self:ClearSysNotifyCation()
	local tbSysNotiy = Calendar:GetSysNotiyTable()
	--因为默认是推送消息的，所以存盘的是不发送的条目
	local tbMySysNotify = Client:GetUserInfo("MySysNotify", -1)
	local nNowScends = Lib:GetTodaySec();
	for i,v in ipairs(tbSysNotiy) do
		if not tbMySysNotify[v.szKey] then
			if v.tbTimeGroup then
				for i2, nScends in ipairs(v.tbTimeGroup) do
					if v.bRepeat or nNowScends < nScends then
						local nHour = math.floor(nScends / 3600)
			            local nMinute = math.floor((nScends - nHour * 3600) / 60)
  			            Ui:NotificationMessage(v.szMsg , nHour, nMinute, v.bRepeat)
					end
				end
			end
		end
	end

	WuLinDaHui:SetSysNotifyCation()
end

function Ui:OnApplicationPause(pauseStatus)
	if not pauseStatus then
		self:ClearSysNotifyCation()
	else
		self:SetSysNotifyCation()
	end

	if version_tx then
		Pandora:OnApplicationPause(pauseStatus)
	end
end

function Ui:NotificationMessage(szMsg, nHour, nMinute, bRepeat)
	if version_kor and ANDROID and Ui.ToolFunction.GetAndroidSdkLevel() >= 21 then
    	UiManager.NotificationMessageWithName(szMsg , nHour, nMinute, bRepeat, 1, "icon_silhouette", "")
    else
    	UiManager.NotificationMessage(szMsg , nHour, nMinute, bRepeat, 1)
    end
end

function Ui:OnStartConnectServer()
	Ui:OpenWindow("LoadingTips");
end

function Ui:OnConnectServerEnd(bConnect)
	if bConnect == 0 then
		self:ReConnectFail();
		Log("connect fail !!");
	end

	Ui:CloseWindow("LoadingTips");
	Log("OnConnectServerEnd", bConnect);
end

function Ui:OnEnterGame(bReconnect)
	if not Login.bEnterGame then
		Login.bEnterGame = true --同步完进入游戏了
		Login:ClearNpcs()
	end

	if me.dwID and me.dwID > 0 then
		me.nLocalServerPlayerId = me.dwID 					-- 缓存玩家在本服的id，因为玩家进入跨服me.dwID会变
	end

	self:GetClass("FloatingWindowDisplay").tbShowQueue = {};
	Login:StopSceneSound();

	self:CloseWindow("CreateRole");
	Ui.UiManager.DestroyUi("CreateRole")
	if bReconnect ~= 1 then
		FriendShip:InitBlackList();
		ChatMgr:InitPrivateList();

	end
	self.nFightState = nil
	self:ChangeFightState(me.nFightMode)
	Ui:ClearSysNotifyCation()

	if Ui:WindowVisible("Login") ~= 1 then
		UiManager.DestroyUi("Login");
	end
	if Ui:WindowVisible("LoginBg") ~= 1 then
		UiManager.DestroyUi("LoginBg");
	end

	Operation:ConnectGamesir();
end

function Ui:OnLeaveGame()
	TeamMgr:OnLeaveGame();
	Boss:ClearData();
	FriendShip:InitData();
	MapExplore:ClearData();
	Mail:Clear();
	Kin:ClearCache();
	ChatMgr:OnLeaveGame();
	RankBoard:ClientInit();
	Shop:ClinetInit();
 	Calendar.tbSysNotiy = nil;
 	FactionBattle:OnLeave();
 	Survey:Init()
 	Kin:StopRedPointTimer()
 	Forbid:OnLeaveGame();
 	Kin:EscortFinishInfoClear();
 	DomainBattle:ClearData();
 	DomainBattle.tbCross:ClearData();
 	for i,v in ipairs(self.tbNotifyMsgDatas) do
 		table.remove(self.tbNotifyMsgDatas, 1)
 	end
	self.nUnReadNotifyMsgNum = 0;
	Player.nServerIdentity = nil;
	FightSkill.tbFightSkillSlot = {};
	--self:CloseWindow()
	Activity:ClearData()
	Player.tbServerSyncData = {};
	LingTuZhan:ClearData();

	Player.Stronger:OnLeaveGame()
end

function Ui:OnMapLoaded(nMapTemplateId)
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);
	Ui:OpenWindow("HomeScreenMiniMap");

	Ui:UpdateDrawMapFog();
	Ui:UpateUseRes();
	Ui:UpdateMainUi();
	Ui:CheckAutoHide();
	Ui:CheckHideState(nMapTemplateId)
	Ui:UpdateBlackBg(); -- 处理切换地图后黑背景可能花屏的问题
end

function Ui:UpdateBlackBg()
	UiManager.UpdateBlackBg();
end

function Ui:CheckHideState(nMapTemplateId)
	if Operation:CheckAdjustView() then
		Operation:DoActivePlayerByType()
	end
end

function Ui:OnMapEnter(nMapTemplateId)
    Ui:UpdateMapLoadResPath(nMapTemplateId);
    if self.nLockScreenState then
		Ui:OpenWindow("LockScreenPanel")
	end
	Ui:CloseMapUi(nMapTemplateId)
end

function Ui:DestroyLoadShowUi()
	self.tbLoadShowUI = nil
end

function Ui:UpdateLoadShowUI(nMapTemplateId)
    if not self.tbLoadShowUI or self.tbLoadShowUI.nMapTID ~= nMapTemplateId then
    	return;
    end
    local tbShowUI = self.tbLoadShowUI.tbUi or {};
    for szWnd, _ in pairs(tbShowUI) do
    	self:OpenWindow(szWnd);
    end
end

function Ui:SetLoadShowUI(tbLoad)
    self.tbLoadShowUI = tbLoad;

    local pNpc = me.GetNpc();
    if pNpc then
    	self:UpdateLoadShowUI(me.nMapTemplateId);
    end
end

function Ui:SetMapCloseUI(nMapTId, tbClose)
	self.tbMapCloseUI = self.tbMapCloseUI or {}
	self.tbMapCloseUI[nMapTId] = self.tbMapCloseUI[nMapTId] or {}
	for _, szWnd in ipairs(tbClose or {}) do
		self.tbMapCloseUI[nMapTId][szWnd] = true
	end
end

function Ui:CloseMapUi(nEnterMapTemplateId)
	local tbMapUi = self.tbMapCloseUI or {}
	for nMapTId, tbWnd in pairs(tbMapUi) do
		if nEnterMapTemplateId ~= nMapTId then
			for szWnd in pairs(tbWnd) do
				Ui:CloseWindow(szWnd)
				tbMapUi[nMapTId][szWnd] = nil
			end
		end
	end
end

function Ui:ForbidShowUI(szUI, nMapTemplateId, bForbid)
    self.tbForbidShowUI = self.tbForbidShowUI or {};
    self.tbForbidShowUI[szUI] = nil;
    if not bForbid then
    	return;
    end

    self.tbForbidShowUI[szUI] = nMapTemplateId;
    if Ui:WindowVisible(szUI) == 1 then
    	Ui:CloseWindow(szUI);
    end
end

function Ui:IsForbidShowUI(szUI)
    self.tbForbidShowUI = self.tbForbidShowUI or {};
    local nMapTemplateId = self.tbForbidShowUI[szUI];
    if not nMapTemplateId then
    	return false;
    end

    if nMapTemplateId ~= me.nMapTemplateId then
    	return false;
    end

    return true;
end

function Ui.HyperTextClickHandle(szText, posX, posY)
	Ui.HyperTextHandle:Handle(szText, posX, posY);
end

-- 服务器远程调用
function Ui:OnServerMsgBox(szMsg, nCallbackCount, tbBtn, bIsServer, szNotTipsType, nTime, tbLight)
	local tbOpt = {}
	for i = 1, nCallbackCount do
		table.insert(tbOpt, {
			function (nSelect)
				Dialog:OnMsgBoxSelect(nSelect, bIsServer);
			end, i})
	end

	if szNotTipsType and self:CheckNotShowTips(szNotTipsType) then
		Dialog:OnMsgBoxSelect(1, bIsServer);
		return;
	end

	Ui:OpenWindowList("MessageBox", szMsg, tbOpt, tbBtn, szNotTipsType, nTime, false, tbLight)
end

function Ui:OnChangeFile(szFileName, szDebugPath)
	szDebugPath = string.gsub(szDebugPath, "\\", "/");
	szFileName = string.gsub(szFileName, "\\", "/");
	szFileName = string.sub(szFileName, string.len(szDebugPath) + 1);
	if string.find(szFileName, ".lua$") then
		Ui:OpenWindow("Reload",szFileName);
	end
end

function Ui:OnConnectLost()
	if IsAlone() ~= 1 then
		Ui:ResetCameraAni();
	end

	if not self.bForRetrunLogin and not self.bKickOffline then
		if Ui:WindowVisible("Login") ~= 1 and not self.tbWaitingForOpen["Login"] then
			local nTimeNow = GetTime();
			self.nNextReconnectTime = self.nNextReconnectTime or 0;
			if PlayerEvent.bLogin and self.nNextReconnectTime <= nTimeNow then
				self.nNextReconnectTime = nTimeNow + 10;
				self:ReconnectServer();
			else
				Ui:OpenWindow("MessageBox", "与服务器断开连接",
					{
						{self.ReconnectServer, self},
						{self.ReturnToLogin, self},
					},
					{"重连", "返回首页"}, nil, nil, true);
			end
		end
	end

	ChatMgr:OnLostConnect();
	Map:OnLostConnect();
	House:OnConnectLost();
end

function Ui:ShowVersionTips()
	if IOS then
		Ui:OpenWindow("MessageBox", "检查到有新的版本，点击确定前往更新",
				{
					{function ()
						CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id1086842482");
					end},
				},
				{"确认"}, nil, nil, true);
	else
			Ui:OpenWindow("MessageBox", "检查到有新的版本，请重新下载新版本的客户端",
					{
						{function ()
							Application.OpenURL(Updater.s_szPackUrl);
						end},
					},
					{"确认"}, nil, nil, true);

			local file = io.open(Updater.s_szPersistentDataPath .. Updater.s_szGrayUpdateFile, "w+");
			file:write(tostring(SERVER_VERSION));
			file:close();
	end
end

function Ui:ShowNewPackTips()
	if Updater.s_szPackUrl and Updater.s_szPackUrl ~= "" then
		if IOS then
			Ui:OpenWindow("MessageBox", "检查到有新的版本，点击确定前往更新",
					{
						{function ()
							CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id1086842482");
						end},
						{},
					},
					{"确认", "取消"}, nil, nil, true);
		else
				Ui:OpenWindow("MessageBox", "检查到有新的版本，请重新下载新版本的客户端",
					{
						{function ()
							Application.OpenURL(Updater.s_szPackUrl);
						end},
						{},
					},
					{"确认", "取消"}, nil, nil, true);
		end
	end
end

function Ui:OnReConnectFaild(bCode)
	local szTipMsg;
	if bCode == Env.emHANDSHAKE_ACC_REPLACE then
		szTipMsg = "您的帐号已在别处登录"
	elseif bCode == Env.emHANDSHAKE_VERSION_ERROR then
		Ui:ShowVersionTips()
		return;
	elseif bCode == Env.emHANDSHAKE_ONCEGAME_FORCE_LOGOUT or
		bCode == Env.emHANDSHAKE_ACCUMU_FORCE_LOGOUT or
		bCode == Env.emHANDSHAKE_ADDICTION_CURFEW or
		bCode == Env.emHANDSHAKE_ADDICTION_BAN then

		szTipMsg = AddictionTip:GetHandShakeFailTips(bCode);
	else
		szTipMsg = "请重新登录"
	end

	if szTipMsg then
		self.bForRetrunLogin = true;
		local fnReturnLogin = function ()
			self:ReturnToLogin()
			self.bForRetrunLogin = nil
		end
		Ui:OpenWindow("MessageBox", szTipMsg,
			{
				{fnReturnLogin},
			},
			{"确定"}, nil, nil, true)
	end
end

function Ui:OnShowKickMsg(szMsg)
	self.bKickOffline = true;
	local fnReturnLogin = function ()
		self:ReturnToLogin()
		self.bKickOffline = nil;
	end
	Ui:OpenWindow("MessageBox", szMsg,
		{
			{fnReturnLogin},
		},
		{"确定"}, nil, nil, true)
end

function Ui:ReConnectFail()
	Ui:OpenWindow("MessageBox", "重连失败",
		{
			{self.ReconnectServer, self},
			{self.ReturnToLogin, self},
		},
		{"重试", "返回首页"}, nil, nil, true)
end

function Ui:ResetCameraAni()
	if not Login.bEnterGame then
		return;
	end

	Ui:SetForbiddenOperation(false);
	Ui.CameraMgr.LeaveCameraAnimationState();
	Ui.CameraMgr.RestoreCameraRotation();
end

function Ui:ReconnectServer()
	ReconnectServer()
	Log("Ui ReconnectServer");
end

function Ui:ReturnToLogin()
	self.nLockScreenState = nil
	PlayerEvent.bLogin = false;
	Ui:OnLogoutFinish();
end

function Ui:OnLogoutFinish()
	if PauseRemoteServerReconnect then
		PauseRemoteServerReconnect(1000);
	end

	Loading.nDstMaptemplateId = nil;
	Map:OnLeave(me.nMapTemplateId, me.nMapId)
	self:OnLeaveGame();

	CloseMap();
	Login.bEnterGame = false;
	self:CloseAllWindow();
	Guide:Clear();
	Ui:ShowAllRepresentObj(true);

	Login:OpenLoginScene(true)
	Lib:CallBack({Pandora.OnLogout, Pandora});
	Lib:CallBack({Kin.OnLogout, Kin})
	Lib:CallBack({TeacherStudent.OnLogout, TeacherStudent})
	Lib:CallBack({ImperialTomb.OnLogout, ImperialTomb})
	Lib:CallBack({WelfareActivity.OnLogout, WelfareActivity})
	Lib:CallBack({TimeFrame.OnClientLogout, TimeFrame});
	Lib:CallBack({Wedding.OnLogout, Wedding})
	Lib:CallBack({RegressionPrivilege.OnLogout, RegressionPrivilege})
	Lib:CallBack({Activity.NewYearQAAct.OnLogout, Activity.NewYearQAAct})
	Lib:CallBack({PlayerEvent.OnLogout, PlayerEvent})
	Lib:CallBack({Achievement.OnLogout, Achievement})
	Lib:CallBack({Activity.DongRiJiAct.OnLogout, Activity.DongRiJiAct})
	Lib:CallBack({Activity.DumplingBanquetAct.OnLogout, Activity.DumplingBanquetAct})
	Lib:CallBack({JueXue.OnLogout, JueXue})
	Lib:CallBack({Fuben.LingJueFengWeek.OnLogout, Fuben.LingJueFengWeek})
	ClearTssCacheData();
end

local _tbWndForFightState =
{
	[0] = 			-- 非战斗状态
	{
		"HomeScreenBattle",
		"RoleHead",
		"TopButton",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenMiniMap",
	},
	[1] = 			-- 战斗状态
	{
		"HomeScreenBattle",
		"RoleHead",
		"TopButton",
		"PkMode",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
		"BattleTopButton",
	},
}

local _tbHideWndState =
{
	[Ui.STATE_DEFAULT] = --
	{
		"BattleTopButton",
		"HomeScreenBattle",
	},
	[Ui.STATE_ASYNC_BATTLE] = -- ID：1异步战斗状态
	{
	},
	[Ui.STATE_HIDE_ALL] = 	-- ID：2隐藏UI状态
	{
		"HomeScreenBattle",
	},
	--ID：3群英会用的
	[Ui.STATE_GAME_FIGHT] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenVoice",
		"PkMode",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
	},
	--ID：4 不知道干嘛用的ID
	[Ui.STATE_SPECIAL_FIGHT] =
	{
		"RoleHead",
		"PkMode",
		"FakeJoyStick",
		"HomeScreenBattle",
	},
	--ID：5 地图探索
	[Ui.STATE_MAPEXPLORE] =
	{
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenMiniMap",
		"HomeScreenBattle",
		"TopButton",
		"BattleTopButton",
	},
	--ID：6 通天塔？？？
	[Ui.STATE_TEAM_BATTLE] =
	{
		"RoleHead",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	},
	--ID：7 门派竞技观战？？？
	[Ui.STATE_WATCH_FIGHT] =
	{
		"ChatSmall",
		"FakeJoyStick",
	},
	--ID：8 隐藏小地图模式
	[Ui.STATE_MINI_MAP] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"BattleTopButton",
	},
	--ID：9 副本模式
	[Ui.STATE_FUBEN] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
		"BattleTopButton",
	},
	--ID：10 历代名将、家族战
	[Ui.STATE_BOSS] =
	{
		"RoleHead",
		"PkMode",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
	},
	--ID：11 又通天塔？？？
	[Ui.STATE_TEAMBATTLE] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	},
	--ID：12 白虎堂
	[Ui.STATE_WhiteTigerFuben] =
	{
		"RoleHead",
		"PkMode",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
		"BattleTopButton",
	},
	--ID：13 领土战
	[Ui.STATE_DomainBattle] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenMiniMap",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenTask",
		"HomeScreenVoice",
	},
	--ID：14 擂台（擂主等待挑战者阶段）
	[Ui.STATE_ArenaBattleWait] =
	{
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenMiniMap",
		"RoleHead",
		"ChatSmall",
		"HomeScreenBattle",
	},
	--ID：15 擂台（擂场默认状态）
	[Ui.STATE_ArenaBattleMain] =
	{
		"PkMode",
		"BattleTopButton",
	},
	--ID：16 擂台（战斗阶段）
	[Ui.STATE_ArenaBattleFight] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	},
	--ID：17 华山论剑
	[Ui.STATE_HSLJMap] =
	{
		"RoleHead",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
	},
	--ID：18 华山论剑决赛
	[Ui.STATE_HSLJFinalsMap] =
	{
		"RoleHead",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
	},
	--ID：19 秦始皇陵(首领，BOSS)
	[Ui.STATE_IMPERIAL_TOMB] =
	{
		"RoleHead",
		"PkMode",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"HomeScreenMiniMap",
		"FakeJoyStick",
		"ChatSmall",
		"BattleTopButton",
	},
	--ID：20 华山论剑
	[Ui.STATE_HSLJPKMap] =
	{
		"RoleHead",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	},
	--ID：21 秦始皇陵(首领，BOSS)
	[Ui.STATE_IMPERIAL_ROOM] =
	{
		"RoleHead",
		"PkMode",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"BattleTopButton",
	},
	--ID：22 心魔幻境
	[Ui.STATE_INDIFFER_BATTLE] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenTask",
		"HomeScreenVoice",
	},
	--ID：23 自拍场景
	[Ui.STATE_Selfie] =
	{
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	},
	--ID：24 比武招亲
	[Ui.STATE_BiWuZhaoQinPreMap] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
	},
	--ID：25 花轿游城
	[Ui.STATE_WeddingTour] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenExpBar",
	},
	--ID：26 婚礼副本
	[Ui.STATE_WeddingFuben] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"RoleHead",
		"HomeScreenExpBar",
	},
	--ID：27 求婚界面
	[Ui.STATE_WeddingEngaged] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenMiniMap",
		"RoleHead",
		"HomeScreenExpBar",
	},
	--ID：28 视角调整
	[Ui.STATE_ViewAdjust] =
	{
		"FakeJoyStick",
	},
	--ID：29 视角拍照
	[Ui.STATE_ViewPhoto] =
	{

	},
	--ID：30 双飞
	[Ui.STATE_DoubleFly] =
	{

	},
	--ID：31 天牢
	[Ui.STATE_PRISON] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenMiniMap",
		"RoleHead",
		"HomeScreenExpBar",
		"HomeScreenBattle",
	},
	[Ui.STATE_INDIFFER_BATTLE_2] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenMiniMap",
	},
	[Ui.STATE_DanceACt] =
	{
		"HomeScreenFuben",
	};
	[Ui.STATE_DanceActReadyMap] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenVoice",
		"PkMode",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
	};
	[Ui.STATE_FACTION_BATTLE] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenVoice",
		"PkMode",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
		"TopButton",
	},
	--ID：36 小队寻宝
	[Ui.STATE_KEY_QUEST_FUBEN] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"BattleTopButton",
		"HomeScreenFuben",
		"HomeScreenMiniMap",
	},
	--ID：37 年夜饭模式，topbuton上面的不显示
	[Ui.STATE_DrinkHouseDinner] =
	{
		"RoleHead",
		"HomeScreenBattle",
		"HomeScreenTask",
		"HomeScreenVoice",
		"HomeScreenExpBar",
		"FakeJoyStick",
		"ChatSmall",
		"HomeScreenMiniMap",
		"TopButton",
	},
	--ID：38 烹饪打猎副本
	[Ui.STATE_CookHuntingFuben] =
	{
		"HomeScreenExpBar",
		"ChatSmall",
		"FakeJoyStick",
	},
	--ID：39 烹饪钓鱼副本
	[Ui.STATE_CookFishingFuben] =
	{
		"HomeScreenExpBar",
		"ChatSmall",
	},
}

Ui.tbChangeStateForceOpen =
{
	["TopButton"] = 1;
	["HomeScreenBattle"] = 1;
}

local tbWndForFightState = {}
for nState, tbInfo in pairs(_tbWndForFightState) do
	tbWndForFightState[nState] = {}
	for _, szWnd in ipairs(tbInfo) do
		tbWndForFightState[nState][szWnd] = 1;
	end
end

local tbHideWndState = {}
for nState, tbInfo in pairs(_tbHideWndState) do
	tbHideWndState[nState] = {}
	for _, szWnd in ipairs(tbInfo) do
		tbHideWndState[nState][szWnd] = 1;
	end
end

Ui.AUTO_HIDE_FORBID =
{
	fight = true;
}

function Ui:IsAutoHide()
	local szMapType = Map:GetClassDesc(me.nMapTemplateId)
	if me.nFightMode ~= 0 and not self.AUTO_HIDE_FORBID[szMapType] then
		return true;
	end
	return false;
end

function Ui:CheckAutoHide()
	if Ui:IsAutoHide() then
		UiManager.SwitchAutoHide(true);
		UiNotify.OnNotify(UiNotify.emNOTIFY_UI_AUTO_HIDE, true);
	else
		UiManager.SwitchAutoHide(false);
		UiNotify.OnNotify(UiNotify.emNOTIFY_UI_AUTO_HIDE, false);
	end
end

function Ui:OnChangeFightState(nFightState)
    Ui:ChangeFightState(nFightState, true)
end

function Ui:ChangeFightState(nFightState, bNotForce)
	print("Ui:ChangeFightState", nFightState)
	self:ChangeQuickUseOpen(nFightState);
	Ui:CheckAutoHide()
	--if nFightState ~= 2 and UiManager.SwitchFightState(nFightState == 1) then
	--	UiNotify.OnNotify(UiNotify.emNOTIFY_UI_AUTO_HIDE, nFightState == 1);
	--end

	if self.nFightState ~= nFightState then
		self.nFightState = nFightState
		self:UpdateMainUi(bNotForce)
	end

	Player:UpdateHeadState();
	Guide:OnChangeFightMode(nFightState)
end

function Ui:ChangeUiState(nState, bHideWnd)
	if nState and tbHideWndState[nState] then
		self.tbHideStateUi = tbHideWndState[nState]
	else
		self.tbHideStateUi = nil
	end
	self.nChangeUiState = nState;
	self.bHideStateWnd = bHideWnd;
	Ui:UpdateMainUi()
end

-- 更新主界面
function Ui:UpdateMainUi(bNotForce)
	local bFigthUi = self.nFightState == 1 or self.nFightState == 2;  -- 死亡状态ui暂时和战斗一样
	local tbShowUi = bFigthUi and tbWndForFightState[1] or tbWndForFightState[0];
	local tbHideUi = bFigthUi and tbWndForFightState[0] or tbWndForFightState[1];
	local tbCanShowUi = {};
	for szUi, _ in pairs(tbShowUi) do
		local bOpenWindow = false;
		if (not self.tbHideStateUi) then
			bOpenWindow = true;
		elseif self.tbHideStateUi[szUi] and not self.bHideStateWnd then
			bOpenWindow = true;
		elseif not self.tbHideStateUi[szUi] and self.bHideStateWnd then
			bOpenWindow = true;
		end

		if bOpenWindow then
			if Ui:WindowVisible(szUi) ~= 1 or Ui.tbChangeStateForceOpen[szUi] or not bNotForce then
				self:OpenWindow(szUi);
			end
			tbCanShowUi[szUi] = 1;
	    else
		self:CloseWindow(szUi);
	    end
	end

	for szUi, _ in pairs(tbHideUi) do
		if not tbCanShowUi[szUi] then
			self:CloseWindow(szUi);
		end
	end

	self:UpdateScreenFramePanel()
end

--safearea加入黑边
function Ui:UpdateScreenFramePanel()
	local tbOffset = Ui:CheckWideScreenOffset()
	if tbOffset then
		Ui:OpenWindow("ScreenFramePanel");
	end
end

function Ui:IsFightOpenBoxPk(nMapTemplateId)
	if BossLeader:IsBossLeaderMap(nMapTemplateId) or
	 Fuben.WhiteTigerFuben:IsMyMap(nMapTemplateId) or
	  ImperialTomb:IsTombMap(nMapTemplateId) then
		return true;
	end

	return false;
end

function Ui:OnPlayCameraAnimationFinish()
	Fuben:OnPlayCameraAnimationFinish();
	CameraAnimation:OnPlayCameraAnimationFinish()
	House:OnPlayCameraAnimationFinish();
end

function Ui:OnWorldNotify(szMsg, nSenderId, bIsRollMsg)
	--if Operation.bIsNewPhotoState then
	--	return;
	--end
	if nSenderId == 0 or bIsRollMsg == 1 then
		if Ui:WindowVisible("SystemNotice") ~= 1 then
			Ui:OpenWindow("SystemNotice", szMsg);
		else
			Ui("SystemNotice"):ShowMsg(szMsg);
		end
	end

	if nSenderId == 0 then
		return;
	end

	local bCanSend = false;
	for _, nId in pairs(ChatMgr.SystemMsgType or {}) do
		if nSenderId == nId then
			bCanSend = true;
			break;
		end
	end

	if not bCanSend then
		return;
	end

	ChatMgr:OnChannelMessage(ChatMgr.ChannelType.System, nSenderId, "", 0, 0, 0, szMsg);
end

function Ui:DropAward(nPosX, nPosY, tbAward)
	local tbDropInfo = {};
	for _, tbInfo in pairs(tbAward) do
		local awardType = Player.AwardType[tbInfo[1] or "nil"];
		if awardType == Player.award_type_money then
			local szName = Shop:GetMoneyName(tbInfo[1]);
			local nObjID = Shop:GetMoneyObjId(tbInfo[1]);
			if nObjID then
				tbDropInfo.tbUserDef = tbDropInfo.tbUserDef or {};
				table.insert(tbDropInfo.tbUserDef, {nObjID = nObjID, szTitle = string.format("%s * %s", szName, tbInfo[2])});
			end
		elseif awardType == Player.award_type_item then
			tbDropInfo.tbItem = tbDropInfo.tbItem or {};
			table.insert(tbDropInfo.tbItem, {nItemId = tbInfo[2], nCount = tbInfo[3]});
		end
	end
	me.DropItemInPos(nPosX, nPosY, tbDropInfo);
end

function Ui:SetCompareTipsPos()
	local tbEquipTips = Ui("EquipTips")
	local tbCompareTips = Ui("CompareTips")

	tbEquipTips.pPanel:ChangePosition("Main", 133, 234)
	tbCompareTips.pPanel:ChangePosition("Main", -270, 234)
end

function Ui:SetTipsPos()
	local tbEquipTips = Ui("EquipTips")
	tbEquipTips.pPanel:ChangePosition("Main", -84, 234)
end

function Ui.OnScreenClick(szUi, szClickUi)
	local tbWnd = Ui(szUi)
	if tbWnd and tbWnd.OnScreenClick then
		tbWnd:OnScreenClick(szClickUi)
	end
end

function Ui:OpenTaskDialog(nTaskId, nNpcId, nDialogId, nState)
	local tbDlg = self:GetClass("SituationalDialogue");
	local nLookToNpcId = tbDlg:CheckLookToNpc(nDialogId);
	if nLookToNpcId then
		Npc.NpcShow:LookToNpc(nLookToNpcId, function ()
			Ui:OpenTaskDialog(nTaskId, nNpcId, nDialogId, nState);
		end)
		return;
	end

	Ui:OpenWindow("SituationalDialogue", "ShowTaskDialog", nTaskId, nNpcId, nDialogId, nState);
end

function Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, tbCallBack, nNpcTemplateId)
	local tbDlg = self:GetClass("SituationalDialogue");
	local nLookToNpcId = tbDlg:CheckLookToNpc(nDialogId);

	if nLookToNpcId then
		Npc.NpcShow:LookToNpc(nLookToNpcId, function ()
			Ui:TryPlaySitutionalDialog(nDialogId, bIsOnce, tbCallBack);
		end)
		return;
	end

	if bIsOnce then
		local tbData = Client:GetUserInfo("SituationalDialogue");
		tbData[me.dwID] = tbData[me.dwID] or {};
		if tbData[me.dwID][nDialogId] then
			if tbCallBack then
				local function fnCallback()
					Lib:CallBack(tbCallBack);
				end
				Timer:Register(1, fnCallback);
			end
			return;
		end
		tbData[me.dwID][nDialogId] = 1;
		Client:SaveUserInfo();
	end

	Ui:OpenWindow("SituationalDialogue", "ShowNormalDialog", nDialogId, tbCallBack, nNpcTemplateId);
end

function Ui:BatchPlaySceneAnimation(szObjectName, nStartIdx, nEndIdx, szAnimationName, nSpeed, bFinishHide)
	for i = nStartIdx, nEndIdx do
		Ui.Effect.PlaySceneAnimation(szObjectName .. i, szAnimationName, nSpeed or 1, bFinishHide);
	end
end

function Ui:OnSceneAniFinish(szObjectName, szAnimationName)
	CameraAnimation:OnSceneCameraAnimationFinish(szObjectName);
end

function Ui:SetForbiddenOperation(bForbidden, bNotJoyStick)
	local bJoyStick = true;
	if bForbidden then
		bJoyStick = false;
		bForbidden = true;
	else
		bJoyStick = true;
		bForbidden = false;
	end

	self.bIsForbiddenOperation = bForbidden;
	UiManager.SetForbiddenOperation(bForbidden);

	if not bNotJoyStick then
		Operation:SetJoyStickUp();
		if Login.bEnterGame then
			me.StopDirection();
		end

		TouchMgr.SetJoyStick(bJoyStick);
		if not bJoyStick then
			SkillController.SetJoyStick(false);
		end
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_FORBIDDEN_OPERATION, bForbidden);
	Log("ForbiddenOperation", bForbidden and "true" or "false");
end

Ui.HIDETYPE_DEFAULT = 0
Ui.HIDETYPE_CAM_ANI = 1 --CameraAnimation
Ui.tbUiToHide =
{
	[Ui.HIDETYPE_DEFAULT] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenMiniMap",
		"TopButton",
		"HomeScreenTask",
		"HomeScreenVoice",
		"RoleHead",
		"HomeScreenExpBar",
		"HomeScreenFuben",
		"HomeScreenBattle",
		"Guide",
		"BattleTopButton",
		"QYHLeavePanel",
	},
	[Ui.HIDETYPE_CAM_ANI] =
	{
		"ChatSmall",
		"FakeJoyStick",
		"HomeScreenMiniMap",
		"TopButton",
		"HomeScreenTask",
		"HomeScreenVoice",
		"RoleHead",
		"HomeScreenExpBar",
		"HomeScreenFuben",
		"HomeScreenBattle",
		"Guide",
		"BattleTopButton",
	},
}

function Ui:IsUiHideVisable(szWnd)
    if not self.bHideAlllUi then
    	return false;
    end

    local nType = self.nHideType or Ui.HIDETYPE_DEFAULT
	for _, szUi in pairs(Ui.tbUiToHide[nType]) do
		if szWnd == szUi then
			return true;
		end
	end

	return false;
end

Ui.tbHideUi = Ui.tbHideUi or {};

function Ui:SetAllUiVisable(bShow, nType)
	self.bHideAlllUi = false;

	if not bShow then
		self.bHideAlllUi = true;
	end

	if not bShow then
		self.nHideType = nType or Ui.HIDETYPE_DEFAULT
		for _, szUi in pairs(Ui.tbUiToHide[self.nHideType]) do
			if Ui:WindowVisible(szUi) == 1 and Ui(szUi).pPanel:IsActive("Main") then
				self.tbHideUi[szUi] = true;
				Ui(szUi).pPanel:SetActive("Main", false);
			end
		end
	else
		for szUi in pairs(self.tbHideUi) do
			if Ui:WindowVisible(szUi) == 1 then
				Ui(szUi).pPanel:SetActive("Main", true);
			end
		end
		self.tbHideUi = {};
	end
end

function Ui:IsTipsNeverShow(szType)
	local tbSplit = Lib:SplitStr(szType or "", "|")
	return tbSplit[#tbSplit]=="NEVER"
end

function Ui:CheckNotShowTips(szType)
	local bNever = self:IsTipsNeverShow(szType)
	local tbRecord = nil
	if bNever then
		tbRecord = Client:GetUserInfo("ClientNeverTips")
		tbRecord.tbRecord = tbRecord.tbRecord or {}
		return tbRecord.tbRecord[szType]
	else
		tbRecord = Client:GetUserInfo("ClientDailyTips");
		if not tbRecord.nDate or tbRecord.nDate ~= Lib:GetLocalDay() then
			tbRecord.nDate = Lib:GetLocalDay();
			tbRecord.tbOldRecord = tbRecord.tbRecord or {}
			tbRecord.tbRecord = {};
		end
		tbRecord.tbOldRecord = tbRecord.tbOldRecord or tbRecord.tbRecord or {}
		return tbRecord.tbRecord[szType], tbRecord.tbOldRecord[szType]
	end
end

function Ui:SetNotShowTips(szType, value)
	local bNever = self:IsTipsNeverShow(szType)
	local tbRecord = nil
	local bChange = false
	value = value and 1 or nil

	if bNever then
		tbRecord = Client:GetUserInfo("ClientNeverTips")
		tbRecord.tbRecord = tbRecord.tbRecord or {}
	else
		tbRecord = Client:GetUserInfo("ClientDailyTips");
		if not tbRecord.nDate or tbRecord.nDate ~= Lib:GetLocalDay() then
			tbRecord.nDate = Lib:GetLocalDay();
			tbRecord.tbOldRecord = tbRecord.tbRecord or {}
			tbRecord.tbRecord = {};
		end
		tbRecord.tbOldRecord = tbRecord.tbOldRecord or tbRecord.tbRecord or {}
		if tbRecord.tbOldRecord[szType] ~= value then
			tbRecord.tbOldRecord[szType] = value
			bChange = true
		end
	end

	if tbRecord.tbRecord[szType] ~= value then
		tbRecord.tbRecord[szType] = value
		bChange = true
	end
	if bChange then
		Client:SaveUserInfo();
	end
end

function Ui:OnStartVoiceConflict()
	me.CenterMsg(XT("实时语音开启中，不能使用语音聊天"));
end

function Ui.StartVoice(fnCheckStart)
	--if not Sdk:IsPermissionGranted(Sdk.ANDROID_PERMISSON_RECORD_AUDIO) then
	--	Sdk:RequestAndroidPermisson(Sdk.ANDROID_PERMISSON_RECORD_AUDIO);
	--	return;
	--end

	if Ui.nVoiceEndDelayTimer then
		me.CenterMsg(XT("录音失败，请稍后再试"));
		return
	end

	if not Ui.bInitVoiceCfg then
		if not version_tx then
			--除大陆版和新马版 其他版本讯飞返回的翻译暂时置为空
			Ui.UiManager.SetKGSpeachRecognize(false)
		else
			Ui.UiManager.SetKGSpeachRecognize(true)
		end

		Ui.bInitVoiceCfg = true
	end

	if fnCheckStart and not fnCheckStart() then
		return;
	end

	Ui.fnVoiceCallBack = nil

	local fileIdHigh, fileIdLow = FileServer:CreateFileId()

	if ANDROID or IOS then
		Ui:SetMusicVolume(0)
		Ui:SetSoundEffect(0)
		ChatMgr:CloseChatRoomTmp()
		--self.UiManager.StopListen()
		local nRet = 0
		local bUseApolloVoice = ChatMgr:CheckUseApollo()

		if bUseApolloVoice then
			nRet = ChatMgr:StartApolloVoice(fileIdHigh, fileIdLow)
		else
			nRet = UiManager.StartListen(fileIdHigh, fileIdLow)
		end

		if nRet == 0 then
			ChatMgr:StopVoice()
			Ui:OpenWindow("VoiceRecord");
			ChatMgr.bStartedVoice = true
		else
			ChatMgr:CheckMusicVolume()
			me.CenterMsg("开启语音失败");
		end
	end
end

function Ui.EndVoice(fnCallback, bCancel)
	Ui:CloseWindow("VoiceRecord");

	if not ChatMgr.bStartedVoice then
		return
	end

	ChatMgr.bStartedVoice = false

	ChatMgr:RestoreChatRoomTmp()
	ChatMgr:CheckMusicVolume()

	if ANDROID or IOS then
		local bUseApolloVoice = ChatMgr:CheckUseApollo()
		if bUseApolloVoice then
			ChatMgr:StopApolloVoice();
		else
			Ui.UiManager.StopListen()
		end
	end

	Ui.nVoiceEndDelayTimer = Timer:Register(ChatMgr.VOICE_END_DELAY * Env.GAME_FPS, function ( )
		Ui.nVoiceEndDelayTimer = nil
	end)

	ChatMgr:AutoPlayNextVoice()

	Ui.fnVoiceCallBack = nil

	if bCancel then
		me.CenterMsg("您取消了语音输入");
		return;
	end

	if not bCancel and fnCallback then
		Ui.fnVoiceCallBack = fnCallback
	end
end

function Ui.ChangeVoiceState(bCancel)
	if ANDROID or IOS then
		local tbVoiceRecord = Ui("VoiceRecord")
		if tbVoiceRecord then
			tbVoiceRecord:ChangeVoiceState(bCancel);
		end
	end
end

function Ui:OnVoice2TxtResult(szTxt, fileIdHigh, fileIdLow, filePath, voiceTime)
	if self.fnVoiceCallBack then
		if fileIdHigh == 0 then
			me.CenterMsg("语音发送失败");
		end

		self.fnVoiceCallBack(szTxt, fileIdHigh, fileIdLow, filePath, voiceTime)
	end

	self.fnVoiceCallBack = nil;

	if self.nVoiceEndDelayTimer then
		Timer:Close(self.nVoiceEndDelayTimer);
		self.nVoiceEndDelayTimer = nil;
	end
end

function Ui:OpenQuickUseItem(nItemId, szBtnName, bCantClose)
	if Ui:WindowVisible("QuickUseItem") ~= 1 then
		Ui:OpenWindow("QuickUseItem", nItemId, szBtnName, bCantClose);
	else
		Ui("QuickUseItem"):Update(szBtnName);
	end
end

--nManualDelete为1时可使用Ui.Effect.StopEffect(nResId)删除
function Ui:PlayEffect(nResId, nX, nY, nZ, bRenderPos, nManualDelete)
	if bRenderPos then
		Ui.Effect.PlayRenderEffect(nResId, 0, nX or 0, nY or 0, nZ or 0, 0, nManualDelete or 0);
		return;
	end

	if not nX or not nY or nX == 0 or nY == 0 then
		nZ, nX, nY = me.GetWorldPos()
		nZ = 0;
	end

	Ui.Effect.PlayEffect(nResId, nX, nY, nZ or 0, nManualDelete or 0);
end

function Ui:PlayCameraEffect(nResId, nManualDelete)
	Ui.Effect.PlayRenderEffect(nResId, 1, 0, 0, 0, 0, nManualDelete or 0);
end

function Ui:PlayNpcSond(nSoundID)
	if self.nCurSondId then
		self:StopDialogueSound(self.nCurSondId, 500);
	end
	self.nCurSondId = nSoundID;
	self:PlayDialogueSound(nSoundID);
end

function Ui:PlaySceneSound(nSoundID)
	if not nSoundID or nSoundID <= 0 then
		return;
	end

	Ui.SoundManager.PlaySceneSound(nSoundID);
end

function Ui:StopSceneSound(nSoundID, nDuration)
	nDuration = nDuration or 1;
	Ui.SoundManager.StopSceneSound(nSoundID, nDuration);
end


function Ui:PlayDialogueSound(nSoundID)
	if not nSoundID or nSoundID <= 0 then
		return;
	end

	if self.tbSoundSetting[nSoundID] then
		ChatMgr:PlayNpcVoice(self.tbSoundSetting[nSoundID]);
	else
		Ui.SoundManager.PlayDialogueSound(nSoundID);
	end
end

function Ui:StopDialogueSound(nSoundID, nDuration)
	nDuration = nDuration or 1;
	if self.tbSoundSetting[nSoundID] then
		if self.tbSoundSetting[nSoundID] == ChatMgr.VoiceInfo.szCurPlayNpcVoice then
			ChatMgr:StopVoice()
		end
	else
		Ui.SoundManager.StopDialogueSound(nSoundID, nDuration);
	end
end

function Ui:PlayUISound(nSoundID)
	if not nSoundID or nSoundID <= 0 then
		return;
	end

	Ui.SoundManager.PlayUISound(nSoundID);
end

Ui.nSceneSoundScale = Ui.nSceneSoundScale or 100;
Ui.nDialogueSoundScale = Ui.nDialogueSoundScale or 100;
Ui.nEffectSoundScale = Ui.nEffectSoundScale or 100;

function Ui:SetSceneSoundScale(nScale)
	if Ui.nSceneSoundScale == nScale then
		return;
	end

	Ui.nSceneSoundScale = nScale;
	local tbUserSet = Ui:GetPlayerSetting();
	Ui.SoundManager.SetSceneVolume(tbUserSet.fMusicVolume *  (Ui.nSceneSoundScale / 100.0));
end

function Ui:SetDialogueSoundScale(nScale)
    if Ui.nDialogueSoundScale == nScale then
    	return;
    end

	Ui.nDialogueSoundScale = nScale;
	local tbUserSet = Ui:GetPlayerSetting();
    Ui.SoundManager.SetDialogueVolume(tbUserSet.fMusicVolume *  (Ui.nDialogueSoundScale / 100.0));
end

function Ui:SetEffectSoundScale(nScale)
    if Ui.nEffectSoundScale == nScale then
    	return;
    end

	Ui.nEffectSoundScale = nScale;
	local tbUserSet = Ui:GetPlayerSetting();
    Ui.SoundManager.SetUIVolume(tbUserSet.fSoundEffectVolume * (Ui.nEffectSoundScale / 100.0));
    Ui.SoundManager.SetOtherVolume(tbUserSet.fSoundEffectVolume * (Ui.nEffectSoundScale / 100.0));
end

function Ui:SetMusicVolume(fVolume, bSave)
    Ui.SoundManager.SetSceneVolume(fVolume *  (Ui.nSceneSoundScale / 100.0));
    Ui.SoundManager.SetDialogueVolume(fVolume * (Ui.nDialogueSoundScale / 100));

    if bSave then
    	local tbUserSet = Ui:GetPlayerSetting();
    	tbUserSet.fMusicVolume = fVolume;
    end
end

function Ui:SetSoundEffect(fVolume, bSave)
    Ui.SoundManager.SetUIVolume(fVolume * (Ui.nEffectSoundScale / 100.0));
    Ui.SoundManager.SetOtherVolume(fVolume * (Ui.nEffectSoundScale / 100.0));

    if bSave then
    	local tbUserSet = Ui:GetPlayerSetting();
    	tbUserSet.fSoundEffectVolume = fVolume;
    end
end

function Ui:ShowComboKillCount(nComboCount, bNotHide)
    if Ui:WindowVisible("HomeScreenBattleInfo") ~= 1 then
    	Ui:OpenWindow("HomeScreenBattleInfo", nil, nil, nComboCount);
    else
    	local tbWndUi = Ui("HomeScreenBattleInfo");
    	if bNotHide then
    		tbWndUi:PlayComboAni(nComboCount);
    	else
			tbWndUi:PlayComboAni(nComboCount,  tbWndUi.nShowComboTime);
    	end

    end
end

Ui.tbDefDrawLevel =
{
	nHeight = 1;
	nMiddle = 2;
	nLow    = 3;
}

Ui.nRenderFPS = Ui.nRenderFPS or 0;

function Ui:SetRenderFPS(nSetFPS)
	local nRenderFPS = nSetFPS;
	if not nRenderFPS then
		local nDrawLevel = Ui:GetDrawLevel()
	    if nDrawLevel == self.tbDefDrawLevel.nHeight and not ANDROID then
	    	nRenderFPS = 60;
	    else
	    	nRenderFPS = 30;
	    end
	end
	if Ui.bOnSaveBatteryMode then
		nRenderFPS = 15;
	end

    if Ui.nRenderFPS == nRenderFPS then
    	return;
	end

	SetVSyncFPS(nRenderFPS, 0);

	if IOS then
		if nRenderFPS == 45 then
			SetVSyncFPS(nRenderFPS, 1);
			Ui.Effect.SetVSyncFPS(60);
		elseif nRenderFPS == 15 then
			SetVSyncFPS(nRenderFPS, 1);
			Ui.Effect.SetVSyncFPS(30);
		else
			Ui.Effect.SetVSyncFPS(nRenderFPS);
		end
	else
		Ui.Effect.SetVSyncFPS(nRenderFPS);
	end

	Ui.nRenderFPS = nRenderFPS;
	Log("SetRenderFPS", nRenderFPS);
end

function Ui:UpdateDrawLevel()
	self:SetRenderFPS();
	local tbUserSet = Ui:GetPlayerSetting();
    self:SetMaxShowNpcCount(tbUserSet.nMaxPlayerCount);
    self:UpdateDrawMapFog();
    Ui:UpateUseRes();
	Ui:UpdateShaderLevel();
    Log("UpdateDrawLevel", Ui:GetDrawLevel());
end

function Ui:UpdateShaderLevel()
	local nDrawLevel = Ui:GetDrawLevel()
	local bUseLowShader = true;
	local tbDrawLevel = self.tbDefDrawLevel;
	if ANDROID then
	    if nDrawLevel == tbDrawLevel.nHeight then
	    	bUseLowShader = false;
	    end
	else
		if nDrawLevel == tbDrawLevel.nHeight or nDrawLevel == tbDrawLevel.nMiddle then
	    	bUseLowShader = false;
	    end
	end

	if bUseLowShader then
		Ui.Effect.ChangeNpcShaderLevel("FTGame/CharacterColourHighX", "FTGame/CharacterColourNormalX");
	else
		Ui.Effect.ChangeNpcShaderLevel("FTGame/CharacterColourNormalX", "FTGame/CharacterColourHighX");
	end
end

Ui.tbCanLoadResCount =
{
	{nMin = 0, 	nMax = 0, nCount = 2};
	{nMin = 1, 	nMax = 8, nCount = 30};
	{nMin = 9, 	nMax = 19, nCount = 40};
	{nMin = 20, nMax = 29, nCount = 50};
	{nMin = 30, nMax = 999999, nCount = 100};
}

function Ui:UpdateCanLoadResPath(nShowCount)
	if not nShowCount then
		return;
	end

	self.nLoadResShowCount = nShowCount;
	for _, tbInfo in pairs(Ui.tbCanLoadResCount) do
		if tbInfo.nMin <= nShowCount and nShowCount <= tbInfo.nMax then
			Ui.Effect.SetCanLoadResPath(1, tbInfo.nCount);
			return;
		end
	end

    Ui.Effect.SetCanLoadResPath(1, 10);
end

function Ui:SetMaxShowNpcCount(nMaxCount, bSave)
	local nCurCount = nMaxCount;
	if nCurCount >= 30 then
		nCurCount = 66;
	end

	if Ui.tbTaskListener:IsWorking() then
		nCurCount = 0
	end

    Ui.Effect.SetMaxShowNpcCount(nCurCount);

    if bSave then
    	local tbUserSet = Ui:GetPlayerSetting();
    	tbUserSet.nMaxPlayerCount = nMaxCount;
    end

    Ui:UpdateCanLoadResPath(nCurCount);
    Log("Ui SetMaxShowNpcCount", nMaxCount, nCurCount);
end

--不限制模型加载数
Ui.tbLoadResPathMap =
{
	[1041] = 1,
	[1042] = 1,
	[1043] = 1,
	[1044] = 1,
	[1045] = 1,
	[1046] = 1,
	[1056] = 1,
	[1047] = 1,
	[1057] = 1,
}

function Ui:UpdateMapLoadResPath(nMapTemplateId)
    if Ui.tbLoadResPathMap[nMapTemplateId] then
    	Ui.Effect.SetCanLoadResPath(1, 256);
    else
    	local nCount = self.nLoadResShowCount or 10;
    	Ui:UpdateCanLoadResPath(nCount);
    end
end

function Ui:CheckUpdateUseRes()
    if IOS or not me then
    	return false;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
    	return false;
    end

    local bUsePerformance = Map:IsPerformance(pNpc.nMapTemplateId);
    local nDrawLevel = Ui:GetDrawLevel()
    if nDrawLevel ~= self.tbDefDrawLevel.nLow then
    	bUsePerformance = false;
    end

    return bUsePerformance;
end

function Ui:GetUseLowRes()
    if not me then
    	return true;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
    	return true;
    end

    local bUsePerformance = Map:IsPerformance(pNpc.nMapTemplateId);
    return bUsePerformance;
end

function Ui:UpateUseRes()
	local nDrawLevel = Ui:GetDrawLevel()
	local bUsePerformance = Ui:GetUseLowRes();
	if nDrawLevel == self.tbDefDrawLevel.nLow then
		bUsePerformance = true;
	end

	Ui.Effect.SetUseLowRes(bUsePerformance);

	local bRetcode = Ui:CheckUpdateUseRes();
    if bRetcode then
    	self:SetRenderFPS(24);
    else
    	self:SetRenderFPS();
    end
end

function Ui:LoadPerformanceSetting()
    self.tbPerformanceSetting = {};
    local tbFileData = Lib:LoadTabFile("Setting/PerformanceSetting.tab", {IsFog = 1, ShowPlayerCount = 1});
    for _, tbInfo in pairs(tbFileData) do
    	if Lib:IsEmptyStr(tbInfo.DrawLevel) then
    		tbInfo.nDrawLevel = self.tbDefDrawLevel.nLow;
    	else
    		tbInfo.nDrawLevel = tonumber(tbInfo.DrawLevel);
    	end
    	self.tbPerformanceSetting[tbInfo.Type] = tbInfo;
    end

    local tbDefInfo = {IsFog = 0, ShowPlayerCount = 10, nDrawLevel = self.tbDefDrawLevel.nLow};
    if IOS then
    	tbDefInfo.IsFog = 1;
    	tbDefInfo.ShowPlayerCount = 15;
    end

    if Client:IsLowMemryDevice() then
    	Log("IsLowMemryDevice");
    	tbDefInfo.IsFog = 0;
    	tbDefInfo.ShowPlayerCount = 0;
    end

    self.tbPerformanceSetting["-1"] = tbDefInfo;
end

Ui.tbDeviceIOSPerformance =
{
	["iPhone"] = 8;
	-- ["iPod"] = 7; -- ipod 6是1G内存
	["iPad"] = 5;
};

function Ui:GetIOSPerformanceInfo(szType)
	local tbIOSPerformance = {IsFog = 1, ShowPlayerCount = 20, nDrawLevel = Ui.tbDefDrawLevel.nMiddle};
    for szDevice, nVersion in pairs(self.tbDeviceIOSPerformance) do
    	local _, _, nCurVersion, nNextVersion = string.find(szType, szDevice.."(%d),(%d)");
    	if nCurVersion then
    		nCurVersion = tonumber(nCurVersion);
    		if nCurVersion >= nVersion then
    			return tbIOSPerformance;
    		end
    	end
    end
end

function Ui:GetPerformanceInfo(szType)
    if not self.tbPerformanceSetting then
    	Ui:LoadPerformanceSetting();
    end

    local tbInfo = self.tbPerformanceSetting[szType];
    if tbInfo then
    	return tbInfo;
    end

    if IOS then
		tbInfo = Ui:GetIOSPerformanceInfo(szType);
    end

    if tbInfo then
    	return tbInfo;
    end

    return self.tbPerformanceSetting["-1"];
end

function Ui:UpdateDrawMapFog()
    if not me then
    	return;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
    	return;
    end

    local tbUserSet = Ui:GetPlayerSetting();
    local tbMap = {[999] = 1, [1] = 1, [15] = 1, [1000] = 1};
    local bShow = false;

    if tbMap[pNpc.nMapTemplateId] then
    	bShow = true;
    end

    if not Map:IsHouseMap(pNpc.nMapTemplateId) then
        Ui.Effect.ShowFog(bShow);
    end
end

function Ui:ClearCanLoadResPath()
    if Ui.Effect then
		Ui.Effect.ClearCanLoadResPath();
	end
end

function Ui:GetPlayerSetting()
    local tbUserSet = Client:GetUserInfo("PlayerSettings", -1);
    tbUserSet.fSoundEffectVolume =  tbUserSet.fSoundEffectVolume or 1;
    tbUserSet.fMusicVolume =  tbUserSet.fMusicVolume or 1;
    tbUserSet.nAdaptation = tbUserSet.nAdaptation or 1;

    if Client:IsLowMemryDevice() then
    	tbUserSet.nMaxPlayerCount = 0;
    	tbUserSet.nIsFog = 0;
    	tbUserSet.nDrawLevel = Ui.tbDefDrawLevel.nLow;
    end

    local szDeviceMode = nil;
    local tbDefPerformance = nil;
    if not tbUserSet.nDrawLevel or not tbUserSet.nMaxPlayerCount or not tbUserSet.nIsFog then
    	szDeviceMode = Ui:GetDeviceModel();
    	tbDefPerformance = self:GetPerformanceInfo(szDeviceMode);
    end

    if not tbUserSet.nDrawLevel then
    	tbUserSet.nDrawLevel = tbDefPerformance.nDrawLevel;
    end

    if not tbUserSet.nMaxPlayerCount then
    	tbUserSet.nMaxPlayerCount = tbDefPerformance.ShowPlayerCount;
    end

    if not tbUserSet.nIsFog then
    	tbUserSet.nIsFog = tbDefPerformance.IsFog;
    end

    return tbUserSet;
end

function Ui:GetDrawLevel()
	if Ui.tbTaskListener:IsWorking() then
		return Ui.tbDefDrawLevel.nLow
	end
	return Ui:GetPlayerSetting().nDrawLevel
end

function Ui:GetDeviceModel()
	if not self.szDeviceModel then
		if WINDOWS then
			self.szDeviceModel = "Windows";
		else
			self.szDeviceModel = self.UiManager.GetDeviceModel();
		end
	end

	return self.szDeviceModel;
end

function Ui:UpdateSoundSetting()
    local tbUserSet = Ui:GetPlayerSetting();
    Ui:SetMusicVolume(tbUserSet.fMusicVolume);
    Ui:SetSoundEffect(tbUserSet.fSoundEffectVolume);
end

function Ui:ShowAllRepresentObj(bShow)
	local nType = 0;
	if bShow then
		nType = 1;
	end
	Ui.Effect.ShowAllRepresentObj(nType);
end

function Ui.OnAniCommander(tbTable, szCommander)
	Ui.tbAniCommander = tbTable;
	local szLoadString = "local self = Ui.tbAniCommander; "..szCommander
	local fnExc = loadstring(szLoadString);
	if fnExc then
		xpcall(fnExc, Lib.ShowStack);
	end
end

function Ui:AddCenterMsg(szMsg, bSysMsg, nSysMsgType)
	local szCenterMsgUi = "GetNotice"
	if not self.tbUi[szCenterMsgUi] or self:WindowVisible(szCenterMsgUi) ~= 1 then
		self:OpenWindow(szCenterMsgUi)
	end

	if type(szMsg) ~= "string" and type(szMsg) ~= "number" then
		return;
	end

	szMsg = tostring(szMsg);
	szMsg = KLib.CutUtf8(szMsg, KLib.GetUtf8Len(szMsg));

	table.insert(self.tbCenterMsg, szMsg)
	if bSysMsg then
		me.Msg(szMsg, nSysMsgType)
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_CENTER_MSG);
end

function Ui:FetchCenterMsg()
	local tbRet = self.tbCenterMsg;
	self.tbCenterMsg = {}
	return tbRet;
end

function Ui:ShowBlackMsg(szMsg, bSysMsg)
	if bSysMsg then
		me.Msg(szMsg);
	end
	self:OpenWindow("TaskNotice", szMsg)
end

function Ui.OnAniEnd(tbWndCom, szAni)
	if tbWndCom.OnAniEnd then
		tbWndCom:OnAniEnd(szAni)
	end
	if tbWndCom.UI_NAME then
		UiNotify.OnNotify(UiNotify.emNOTIFY_ANIMATION_FINISH, tbWndCom.UI_NAME, szAni);
	end
end

function Ui:StartProcess(szMsg, nInterval)
	Ui:OpenWindow("NpcStrip", szMsg, nInterval);
end

function Ui:CloseProcess()
	local bProcessShow = (Ui:WindowVisible("NpcStrip") == 1);
	UiNotify.OnNotify(UiNotify.emNOTIFY_BREAK_GENERALPROCESS, bProcessShow);
	Ui:CloseWindow("NpcStrip");
end

function Ui:NpcBubbleTalk(npc, szContent, nDuration, nMaxCount, nDealyTime)
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(nDealyTime * Env.GAME_FPS, self.NpcBubbleTalk, self, npc, szContent, nDuration, nMaxCount);
		return;
	end

	local tbNpcInfo = {};
	if type(npc) == "number" then
		tbNpcInfo[1] = npc;
	elseif type(npc) == "table" then
		tbNpcInfo = npc;
	end

	local nCount = 1;
	for i, nNpcId in pairs(tbNpcInfo) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			if nMaxCount and nCount > nMaxCount then
				break;
			end
			pNpc.BubbleTalk(szContent, tostring(nDuration));
			nCount = nCount + 1;
		end
	end
end


function Ui:OnScreenRecordStart(nRet)
	if nRet == 1 then
		me.CenterMsg("Record Start");
		self:OpenWindow("ScreenRecord");
	else
		me.CenterMsg("Record Start Failed!!!!!");
	end
end

function Ui:DoLeftInfoUpdate(...)
	UiNotify.OnNotify(UiNotify.emNOTIFY_QYHLEFT_INFO_UPDATE, ...);
end

function Ui:OnHelpClicked(szName)
    Ui:OpenWindow("GeneralHelpPanel", szName)
end

function Ui:SwitchSaveBatteryMode(bForceClose)
	self.bOnSaveBatteryMode = not self.bOnSaveBatteryMode;
	if bForceClose then
		self.bOnSaveBatteryMode = nil;
	end
    local tbUserSet = Ui:GetPlayerSetting();
	if self.bOnSaveBatteryMode then
		Ui.nLastUserDrawLevel = tbUserSet.nDrawLevel
		Ui.ToolFunction.SetScreenBrightness(Ui.SCREEN_BRIGH_LOW)
		tbUserSet.nDrawLevel = Ui.tbDefDrawLevel.nLow;
	else
		Ui.ToolFunction.SetScreenBrightness(Ui.SCREEN_BRIGH_NORMAL)
    	local tbDefPerformance = self:GetPerformanceInfo(Ui:GetDeviceModel());
    	tbUserSet.nDrawLevel = Ui.nLastUserDrawLevel or tbDefPerformance.nDrawLevel;
	end
	Ui:UpdateDrawLevel();

	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_SAVE_BATTERY_MODE)
end

function Ui:ShowDebugInfo(bShow)
	self.bShowDebugInfo = bShow;
	self.FTDebug.bShowDebugInfo = bShow;
end

function Ui:SetDebugInfo(szInfo, fX, fY, fWight, fHeight)
	if not self.bShowDebugInfo then
		return;
	end

	self.FTDebug.SetDebugInfo(szInfo, fX or 0, fY or 0, fWight or 1024, fHeight or 768);
end

function Ui:OnCallFromUnity(szFunc, ...)
	return false;
end

function Ui:LoadUiSetting()
	self.tbUiSetting = LoadTabFile("Setting/Ui/Load.tab", "sd", "Name", {"Name", "BackBtnClose"});
end

Ui:LoadUiSetting();

function Ui:OnReturnPressed()
	local szTopPanelName = UiManager.GetTopPanelName();
	if Lib:IsEmptyStr(szTopPanelName) then
		Operation.OnTouchReturn();
	elseif self.tbUiSetting[szTopPanelName] then
		Operation.OnTouchReturn(szTopPanelName, self.tbUiSetting[szTopPanelName].BackBtnClose == 1);
	end
end

Ui.tbTempShowAwards = {};
Ui.nLastShowLogway = -1;
-- 7 帧内获得同样来源的奖励就合并
function Ui:MergeShowAwardTips(tbAward, nLogWay, bHideMsg)
	if Ui.nLastShowLogway ~= nLogWay then
		if next(self.tbTempShowAwards) then
			Ui:OpenAwardUi(self.tbTempShowAwards, self.nLastShowLogway)
			self.tbTempShowAwards = {};
		end
		self.nLastShowLogway = nLogWay
	end
	for i,v in ipairs(tbAward) do
		table.insert(self.tbTempShowAwards, v)
	end
	if not self.nTimerMergeAwardTips then
		self.nTimerMergeAwardTips = Timer:Register(7, function ( )
			if next(self.tbTempShowAwards) then
				Ui:OpenAwardUi(self.tbTempShowAwards, self.nLastShowLogway, bHideMsg)
				self.tbTempShowAwards = {};
			end
			self.nTimerMergeAwardTips = nil
		end)
	end
end

function Ui:HideOthers(tbShowNpcIds)
	self:SetAllUiVisable(false)
	self:ShowAllRepresentObj(false)
	for _, nId in ipairs(tbShowNpcIds) do
        self.Effect.ShowNpcRepresentObj(nId, true)
    end
end

function Ui:ShowOthers()
	self:SetAllUiVisable(true)
	self:ShowAllRepresentObj(true)
end

function Ui:NotfifyGetAward(tbAward, bMsg, bShowUi, nLogReazon)
	if bMsg then
		local tbAwardDes = Lib:GetAwardDesCount(tbAward, me);
		local szLogWay = Env.tbLogWayDesc[nLogReazon]
		szLogWay = Lib:IsEmptyStr(szLogWay) and "" or string.format("（%s）", szLogWay);

		for _, tbDes in pairs(tbAwardDes) do
			local szMsg = "";
			if tbDes.szEmotionDesc and tbDes.szEmotionDesc ~= "" then
				szMsg = string.format("获得%s%s", tbDes.szEmotionDesc, szLogWay);
			else
				szMsg = string.format("获得%s%s", tbDes.szDesc, szLogWay);
			end
			me.CenterMsg(szMsg, true)
		end
	elseif bShowUi then
		self:OpenAwardUi(tbAward, nLogReazon)
	end
end

-- 将奖励动画Ui和系统提示逻辑分开
function Ui:OpenAwardUi(tbAward, nLogReazon, bHideMsg)
	Ui:OpenWindow("AwardTips", tbAward, nLogReazon)
	if not bHideMsg then
		self:SendChatTip(tbAward, nLogReazon)
	end
end

function Ui:SendChatTip(tbAward, nLogWay)
	local tbAwardDes = Lib:GetAwardDesCount(tbAward, me)
	for _, tbDes in pairs(tbAwardDes) do
		local szLogWay = Env.tbLogWayDesc[nLogWay]
		szLogWay = Lib:IsEmptyStr(szLogWay) and "" or string.format("（%s）", szLogWay);
		local szMsg = Lib:IsEmptyStr(tbDes.szEmotionDesc) and
			string.format("获得%s%s", tbDes.szDesc or "", szLogWay) or
			string.format("获得%s%s", tbDes.szEmotionDesc or "", szLogWay);
		me.Msg(szMsg)
	end
end

function Ui.OnHotKey(nKey)
	Ui.Hotkey:OnHotKey(nKey)
end

function Ui.OnCheckAnyKey(nKey)
	Ui.Hotkey:OnCheckAnyKey(nKey)
end

function Ui:OnIOSBatteryStateChange(nState, nIsCharging)
	Log("OnIOSBatteryStateChange", nState, nIsCharging);
	UiNotify.OnNotify(UiNotify.emNOTIFY_ON_BATTERY_STATE_CHANGE, nIsCharging == 1);
end

function Ui:OnAndroidBatteryStateChange(bIsCharging)
	Log("OnAndroidBatteryStateChange", tostring(bIsCharging));
	UiNotify.OnNotify(UiNotify.emNOTIFY_ON_BATTERY_STATE_CHANGE, bIsCharging);
end

function Ui:OnVerifyPackRet()
	Log("Ui:OnVerifyPackRet")
	Ui:OpenWindow("MessageBox", "客户端出现异常请重新安装", {{},},{"确认"}, nil, nil, true);
end

function Ui:GetUiManualSize()
	if not self.nManualHeight or not self.nManualWidth then
		local gameObject = Ui.UiManager.m_uiRoot;
		local uiRoot = gameObject:GetComponent("UIRoot");
		if Ui.Screen.width / Ui.Screen.height > 1280 / 720 then
			self.nManualHeight = uiRoot.manualHeight;
			self.nManualWidth = self.nManualHeight * Ui.Screen.width / Ui.Screen.height;
		else
			self.nManualWidth = 1280 / 720 * 640;
			self.nManualHeight = self.nManualWidth * Ui.Screen.height / Ui.Screen.width;
		end
	end
	return self.nManualWidth, self.nManualHeight;
end

function Ui:GetUiMoveRatio()
	if not self.nRatioX or not self.nRatioY then
		local nManualWidth, nManualHeight = self:GetUiManualSize();

		self.nRatioX = nManualWidth / Ui.Screen.width;
		self.nRatioY = nManualHeight / Ui.Screen.height;
	end
	return self.nRatioX, self.nRatioY;
end
