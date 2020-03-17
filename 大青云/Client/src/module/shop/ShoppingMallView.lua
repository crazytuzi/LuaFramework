--[[
元宝商城
wangshuai
]]

_G.UIShoppingMall = BaseUI:new("UIShoppingMall")

UIShoppingMall.TabIndex = 1;
UIShoppingMall.curPage = 0;
UIShoppingMall.curList = {};

function UIShoppingMall:Create()
	self:AddSWF("shoppingMallView.swf",true,"center")
	self:AddChild( UIShoppingMallTehui, "tehui" );
end;

function UIShoppingMall:OnLoaded(objSwf)
	self:GetChild( "tehui" ):SetContainer(objSwf.childPanel);

	objSwf.closebtn.click = function() self:OnClosePanel()end;

	objSwf.list.itemClick = function(e) self:OnItemClick(e)end;
	objSwf.list.iconRollOver = function(e) self:OnIconOver(e) end;
	objSwf.list.iconRollOut = function() TipsManager:Hide(); end;



	objSwf.btnPre1.click = function() self:PagePre1()end; -- 前
	objSwf.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:PageNext()end; -- 下一个
	objSwf.testQuickBuy._visible = false;
	objSwf.testQuickBuy.click = function (e) self:OnTestQuickBuyClick(e); end;   --测试快速购买  --不要动
		-- body
	local poss = {};
	for i=1,6 do 
		local btn = objSwf["tab_"..i];
		btn.click = function() self:OnTableClick(i)end;
		poss[i] = btn._x;
	end;
	
	local showIndex = 1;  --@haoran for temp
	local showIndex1 = 2;  --@haoran for temp
	local showIndex2 = 3;  --@haoran for temp	
	for i=1,6 do
		local btn = objSwf["tab_"..i];
		if ShopConsts.ShowItemlist[i] then 
			btn.visible = true;
		else
			btn.visible = false;
		end;
		
		if showIndex == i then
			if btn.visible then
				btn._x = poss[showIndex1];
			end
		elseif showIndex1 == i then
			if btn.visible then
				btn._x = poss[showIndex];
			end
		end
		
	end;
	
	-- self.TabIndex = showIndex;
	objSwf.btn_charge.click = function () Version:Charge(); end
	objSwf.btn_charge._visible = Version:IsShowRechargeButton();
end;

function UIShoppingMall:OnShow()
	self:OnShowList()
	self:OnSetText();
	self:PlayShopSound();
--	self:DrawNpc()
	self:ShowRightAvatar()
	SoundManager:PlaySfx(2057)
end;

function UIShoppingMall:DrawNpc()
	local objSwf = self.objSwf;
	if not objSwf then return end

	local avatar = NpcAvatar:NewNpcAvatar(20100247)
	avatar:InitAvatar()
	-- local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,self.selectBossID);

	local drawCfg = self:GetDefaultCfg();
		
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("UIShoppingMall",avatar, objSwf.load_npc,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000);
	else
		self.objUIDraw:SetUILoader(objSwf.load_npc);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end
	local rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
end

function UIShoppingMall:ShowRightAvatar()
	local sen = "v_npc_shangchengnv02.sen";
	local objSwf = self.objSwf;
	if not objSwf then return end
	local viewPort
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1278, 689); end
		self.objUIDraw = UISceneDraw:new("UIShoppingMall", objSwf.load_npc, viewPort);
	end
	self.objUIDraw:SetUILoader(objSwf.load_npc);
	self.objUIDraw:SetScene(sen, function()
		local aniName = "v_npc_shangchengnv02_xiuxian.san";
		if aniName == "" then return end
		--[[
		if self.timerKey then TimerManager:UnRegisterTimer(self.timerKey) end
		self.timerKey = TimerManager:RegisterTimer(function()
			SoundManager:PlaySfx(2057)
			self.objUIDraw:NodeAnimation("v_npc_shangchengnv02_fmt", aniName);
		end,10000,0)
		--]]
		self.objUIDraw:NodeAnimation("v_npc_shangchengnv02_fmt", aniName);
	end);
	self.objUIDraw:SetDraw(true);
end

UIShoppingMall.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(3,0,18),
	VPort = _Vector2.new(600,600),
	Rotation = 0
};
function UIShoppingMall:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIShoppingMall:PlayShopSound()
	if ShopController.isShowShopSound == true then
		SoundManager:PlaySfx(13047);
		--开始计时
		ShopController:StartShopSoundTime();
	end
end

function UIShoppingMall:OpenPanel(index, curPage)
	self.TabIndex = index;
	self.curPage = 0;
	self:Show();
end;

function UIShoppingMall:OnTableClick(index)
	self.TabIndex = index;
	self.curPage = 0;
	self:OnShowList()
end;

function UIShoppingMall:OnSetText()
	local objSwf = self.objSwf;
	objSwf.yuanbao.text = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	objSwf.lijing.text = MainPlayerModel.humanDetailInfo.eaBindMoney
end;
function UIShoppingMall:OnItemClick(e)
	-- 购买
	local id = e.item.id;
	
	--if not sa then return end;
	UIShopBuyConfirm:Open(id, ShopConsts.Policy_Single)
	--ShopController:ReqBuyItem(id,1)
end;

-- 测试快速购买,后期删除
function UIShoppingMall:OnTestQuickBuyClick(e)
	
	-- 测试萌宠获得界面
	-- UILovelyPetShowView:OpenPanel(1);
	--[[
	-- 测试快速购买功能
	-- local itemId = 150100011;  -- 两种购买方式
	-- local itemId = 160200002;  -- 只能使用元宝购买
	local list = {1501000121,1602000022}
	local index = math.random(1,2)
	
	--]]
	-- 150001001  礼金商城
	-- 151900001  绑金商城
	-- UIQuickBuyConfirm:Open(self,151900001)
	-- local itemId = 91
	-- UIQuickBuyConfirm:Open(self,itemId)



	--[[ 	
	-- 测试主线副本进入信息面板
	local list = {1401001,1310001,1410001,1410004,1410007};
	local  index = math.random(1,5)
	self.questId = list[index]
	local func = function()
	end
	UITrunkDungeonInfo:Open(func,self.questId)

	--]]
end

function UIShoppingMall:OnIconOver(e)
	local target = e.renderer;
	local cid = e.item.id;
	local cfg = t_shop[cid];
	TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown);
end;

function UIShoppingMall:OnShowList()
	local objSwf = self.objSwf;
	--  设置table idnex
	objSwf["tab_"..self.TabIndex].selected = true;
	objSwf.childBg._visible = false;
	local showListType = ShopConsts.ShowItemlist[self.TabIndex]
	if not showListType then return end;
	objSwf.childBg._visible = showListType ~=ShopConsts.ST_Tehui;
	self.curList = ShopUtils:OnGetShowTypeList(showListType)
	local list = UIShoppingMall:GetListPage(self.curList,self.curPage)
	local listvo = {};
	for i,info in ipairs(list) do 
		table.push(listvo,info:GetShoppingItemUIData())
	end;
	objSwf.list.dataProvider:cleanUp();
	if showListType == ShopConsts.ST_Tehui then
		self:ShowTehuiPanel( true, listvo, list )
	else
		objSwf.list.dataProvider:push(unpack(listvo));
		self:ShowTehuiPanel( false )
	end
	objSwf.list:invalidateData();

	-- 刷新按钮状态
	self:SetPagebtn();
end;

function UIShoppingMall:ShowTehuiPanel( show, listvo, list )
	if show then
		UIShoppingMallTehui:Open( listvo, list )
	else
		UIShoppingMallTehui:Hide()
	end
end

function UIShoppingMall:IsShowLoading()
	return true;
end

function UIShoppingMall:IsTween()
	return true;
end

function UIShoppingMall:GetPanelType()
	return 1;
end

function UIShoppingMall:IsShowSound()
	return true;
end

function UIShoppingMall:OnClosePanel()
	self:Hide();
end;
function UIShoppingMall:OnHide()
	self.TabIndex = 1
	self.curPage = 0;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
	end
end;

function UIShoppingMall:GetWidth()
 	return 1015
end;
function UIShoppingMall:GetHeight()
	return 666
end;

------ 消息处理 ---- 
function UIShoppingMall:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIShoppingMall:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaUnBindMoney or body.type == enAttrType.eaBindMoney then 
			self:OnSetText();
		end;
	end;
end;



--------------- 分页

---翻页控制
-- 最前
function UIShoppingMall:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	UIShoppingMall:OnShowList()
end;
-- 前
function UIShoppingMall:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage-1;
	UIShoppingMall:OnShowList()
end;
-- 最后
function UIShoppingMall:PageNext1()
	local objSwf = self.objSwf;
	local len = self:GetListLenght(self.curList)
	self.curPage = len;
	UIShoppingMall:OnShowList()
end;
-- 后
function UIShoppingMall:PageNext()
	local objSwf =self.objSwf;
	self.curPage = self.curPage+1;
	local len = self:GetListLenght(self.curList)
	UIShoppingMall:OnShowList()
end;

function UIShoppingMall:SetPagebtn()
	local objSwf = self.objSwf;
	local curpage = self.curPage+1;
	local curTotal = self:GetListLenght(self.curList)+1;
	objSwf.txtPage.text = string.format(StrConfig["shoppingmall003"],curpage,curTotal)
	if curpage == 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	elseif curpage >= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	elseif curpage ~= 0 and curpage ~= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	end;
	if curTotal <= 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	end;
end;

UIShoppingMall.onePage = 8;
-- 得到当前页数下的itemlist
function UIShoppingMall:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	for i=(self.onePage*page)-self.onePage+1,(self.onePage*page) do 
		table.push(vo,list[i])
	end;
	return vo
end;

function UIShoppingMall:GetListLenght(list)
	local lenght = #list/self.onePage;
	return math.ceil(lenght)-1;
end;

