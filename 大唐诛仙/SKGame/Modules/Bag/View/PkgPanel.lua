-- 背包面板
PkgPanel = BaseClass()

-- 初始化
function PkgPanel:__init(root)
	self.container = root

	self.model = PkgModel:GetInstance()
	self.selectTabId = nil -- 选中标签id
	self.selected = nil -- 当前选中单元格
	
	self.grids = {} -- 所有格子列表[gid]=cell
	self.lockGrids = {} -- gid (锁定)
	self.emptyGrids = {} -- gid(空格子)

	--self.wingUpPanel = nil  --LLL++++

	self:LayoutPkgPanel()
	self:InitEvent()
end
-- 事件
function PkgPanel:InitEvent()
	self.btn_zl.onClick:Add(function ()
		PkgCtrl:GetInstance():C_TidyBag()
		if self.selectTabId == PkgConst.BagTabType.all then
			-- 点击“全部”分页下的整理后，取消背包所有红点提示
			self.model:TridOnGridsNewState()
			self:Update()
		end
	end)
	self.bagGridChangeHandler = self.model:AddEventListener(PkgConst.GridChange, function ( data )
		if self.ui and self.ui.visible then
			self:RenderGrids()
		end
	end)
	-- 监听选择物品变化
	if self.btnBuy then
		self.btnBuy.onClick:Add(function()
			MallController:GetInstance():QuickBuy(PkgConst.BagExtendCardGoodsId , function() 
				--Close Callback
			end)
		end)
	end
end

-- 更新面板数据
function PkgPanel:Update()
	self:UpdateGrids()
	self:UpdateNum()
end
-- 更新格子
function PkgPanel:UpdateGrids()
	local model = self.model
	local selectTabId = self.selectTabId or PkgConst.BagTabType.all
	local onGridsData = model:GetOnGrids()
	local cell = nil
	local i = 1 -- 结尾清空计数
	local onGridsMap = {}

	if selectTabId == PkgConst.BagTabType.all then
		for _, vo in ipairs(onGridsData) do
			cell = self.grids[vo.itemIndex]
			if cell then
				cell:SetData(vo)
				cell:UpdateArrow()
				cell:ShowRed(vo.isNew == true)
				onGridsMap[cell.gid] = true
			else
				print("======== UpdateGrids0 cell == nil")
			end	
		end
	elseif selectTabId == PkgConst.BagTabType.equip then
		for _, vo in ipairs(onGridsData) do
			if vo and vo.goodsType == GoodsVo.GoodType.equipment then
				cell = self.grids[i]
				if cell then
					cell:SetData(vo)
					cell:UpdateArrow()
					cell:ShowRed(vo.isNew == true)
					i = i + 1
					onGridsMap[cell.gid] = true
				else
					print("======== UpdateGrids1 cell == nil")
				end
			end
		end
	elseif selectTabId == PkgConst.BagTabType.xiaohao then
		for _, vo in ipairs(onGridsData) do
			if vo and vo.goodsType == GoodsVo.GoodType.item then
				cell = self.grids[i]
				if cell then
					cell:SetData(vo)
					cell:UpdateArrow()
					cell:ShowRed(vo.isNew == true)
					i = i + 1
					onGridsMap[cell.gid] = true
				else
					print("======== UpdateGrids2 cell == nil")
				end
			end
		end
	else
		for _, vo in ipairs(onGridsData) do
			if vo and vo.goodsType ~= GoodsVo.GoodType.equipment and vo.goodsType ~= GoodsVo.GoodType.item then
				cell = self.grids[i]
				if cell then
					cell:SetData(vo)
					cell:UpdateArrow()
					cell:ShowRed(vo.isNew == true)
					i = i + 1
					onGridsMap[cell.gid] = true
				else
					print("======== UpdateGrids3 cell == nil")
				end
			end
		end
	end
	for j=1,#self.grids do
		local cell = self.grids[j]
		if not onGridsMap[cell.gid] then
			cell:Clear()
			if cell == self.selected then
				cell:SetSelected(false)
				self.pkgInfo:Update(nil, nil)
				self.selected = nil
			end
		end
	end
	if self.selected then
		self:UpdateSelectInfo()
	end

	-- 默认选中物品bid
	local bid = model.selectGoodsBid
	if bid then
		for i,cell in ipairs(self.grids) do
			if cell and cell.data and cell.data.bid == bid then
				self:SelectHandler(cell)
				self.gridPanel.scrollPane:ScrollToView(cell.ui)
				model.selectGoodsBid = nil
				break
			end
		end
	end

end
-- 更新选中格子显示的信息
function PkgPanel:UpdateSelectInfo()
	if not self.selected then return end
	local cell = self.selected
	local data = cell:GetData()
	if data == nil then
		self.pkgInfo:Update(nil, nil)
		return
	end
	local cfg = data:GetCfgData()
	self.pkgInfo:Update(data, cfg)
end

-- 更新数量
function PkgPanel:UpdateNum()
	self.txt_num.text = StringFormat("{0}/{1}", #self.model:GetOnGrids(), self.model.bagGrid)
end

-- 布局
function PkgPanel:LayoutPkgPanel()
	local panel = self:CreatePanel(self.container, 0, 0, 1, 1 )
	self.ui = panel -- 为了self.ui 根节点 luaui销毁用到的

	-- 信息部分
	local info = PkgInfoPanel.New()
	if info ~= nil then
		info:AddTo(panel, 695, 110)
		self.pkgInfo = info
		info.btnSell.onClick:Add(function (e)
			if self.selected == nil or not self.selected:GetData() then return end
			local data = self.selected:GetData()
			local cfg = data:GetCfgData()
			if not cfg then return end
			if cfg.sellConfirm == 1 then
				UIMgr.Win_Confirm("提示", StringFormat("您确定要出售 {0} 吗？", data:GetCfgData().name), "确定", "取消", function (  )
					PkgCtrl:GetInstance():C_SellItem(data.id)
				end, nil)
			else
				PkgCtrl:GetInstance():C_SellItem(data.id)
			end
		end, self)
		info.btnUse.onClick:Add(function ( e )
			if self.selected == nil or not self.selected:GetData() then return end
			local data = self.selected:GetData()
			if data.goodsType == GoodsVo.GoodType.equipment then
				PkgCtrl:GetInstance():C_PutOnEquipment(data.equipId)
			else
				local cfg = data:GetCfgData()
				if cfg.useType == 3 then -- 跳转注灵界面
					SkillController:GetInstance():OpenSkillPanel(1)
				elseif cfg.useType == 4 then -- 跳转斗神印界面
					GodFightRuneController:GetInstance():OpenGodFightRunePanel()
				elseif cfg.useType == 5 then --跳转改名界面
				
				elseif cfg.useType == 6 then --秘境
					local enterPanel1 = EnterPanel1.New()
					enterPanel1:Update(cfg)
					UIMgr.ShowCenterPopup(enterPanel1, function()  end)
					PkgCtrl:GetInstance():Close()
				elseif cfg.useType == 7 then --点击技能书，打开技能界面
					SkillController:GetInstance():OpenSkillPanel()
				elseif cfg.useType == 10 then --打开合成界面
					if self.model:IsRoleCareerData( data ) then
						PkgCtrl:GetInstance():OpenByType(PkgConst.PanelType.composition , CompositionModel:GetInstance():GetTargetID(cfg.id))
					else
						UIMgr.Win_FloatTip("物品职业不符")
					end
				elseif cfg.useType == 13 then
					RechargeController:GetInstance():Open(RechargeConst.RechargeType.Turn)
				elseif cfg.useType == 11 then
					RechargeController:GetInstance():Open(RechargeConst.RechargeType.Tomb)
				elseif cfg.useType == 12 then --打开羽化界面++++
						--[[local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
						if mainPlayerVo.wingStyle and mainPlayerVo.wingStyle ~= 0 then
							local wingData = {}  --羽化的羽翼数据++
							if wingData then
								if self.wingUpPanel == nil or not self.wingUpPanel.Inited then
									self.wingUpPanel = WingUpPanel.New()
								end
								self.wingUpPanel:Show(wingData)
								self.wingUpPanel:Open()
							end
						else]]--
							PlayerInfoController:GetInstance():Open(2)
						--end                     --+++++LLL
				else
					if cfg.effectType == 17 then --加buff
						local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
						if mainPlayer and mainPlayer.buffManager and mainPlayer.buffManager:HasBuffGroup(cfg.effectValue) then
							UIMgr.Win_Confirm("温馨提示", "已有该类型buff，再次使用将会覆盖，确定使用？", "确定", "取消", function()
								PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							end, nil)
						else
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
						end
					else
						if cfg.tinyType == GoodsVo.TinyType.hp or cfg.tinyType == GoodsVo.TinyType.mp then
							if self.mphpCD then UIMgr.Win_FloatTip("药品使用冷却中, 请稍后再使用!") return end
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							self.mphpCD = true
							setupFuiOnceRender(self.ui, function ()
								self.mphpCD = false
							end, 6)
						elseif cfg.useType ~= 8 and cfg.useType ~= 9 then
							
							if cfg.useType == 1 and cfg.automatic == 0 and (not TableIsEmpty(cfg.useExpend)) then --添加使用钥匙开箱子的逻辑
								--print("======== 其他情况下的使用 C_UseItem " , data.id)
								local rtnIsEnough = true
								for index = 1 , #cfg.useExpend do
									if cfg.useExpend[index] then
										if PkgModel:GetInstance():GetTotalByBid(cfg.useExpend[index][2]) < cfg.useExpend[index][3] then
											rtnIsEnough = false
											break
										end
									end
								end

								local strDesc = ""
								local strNeedItemDesc = "使用该道具需要消耗:"
								local strHasItemDesc = "当前拥有:"
								for index = 1, #cfg.useExpend do
									if cfg.useExpend[index] then
										local itemCfg = GoodsVo.GetItemCfg(cfg.useExpend[index][2])
										local hasCnt = PkgModel:GetInstance():GetTotalByBid(cfg.useExpend[index][2])
										if itemCfg then
											--local colorCode = "[color="] .. GoodsVo.RareColor[itemCfg.rare or 0] .. "[/color]"
											local strNameWithRare = StringFormat("[color={0}]{1}[/color]" , GoodsVo.RareColor[itemCfg.rare or 0] , itemCfg.name)
											strNeedItemDesc = strNeedItemDesc .. strNameWithRare .. "*" .. cfg.useExpend[index][3]
											strHasItemDesc = strHasItemDesc  .. strNameWithRare .. "*" .. hasCnt
										end
									end
								end
								strDesc = strNeedItemDesc .. "\n\n" .. strHasItemDesc
								UIMgr.Win_Confirm("提示" , strDesc , "确认" , "取消" , function()
									if rtnIsEnough then
										PkgCtrl:GetInstance():C_UseItem(data.id, 1)
									else
										UIMgr.Win_FloatTip("所需物品不足")
									end									
								end , function() 
									--print("取消啦")	
								end)

							else
								PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							end			
						end
					end

					if cfg.useType == 8 then --打开翅膀
						local isActive = WingModel:GetInstance():IsActive(cfg.id)
						if not isActive then
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							PlayerInfoController:GetInstance():Open(2)
						else
							local data1 = GetCfgData("wing"):Get(cfg.id)
							local itemId = data1.decomposeStr[1][2]
							local cfg1 = GoodsVo.GetItemCfg(itemId)
							local str = StringFormat("该羽翼已激活，使用将转化为{0}个{1}？", data1.decomposeStr[1][3], cfg1.name)
							UIMgr.Win_Confirm("温馨提示", str, "确定", "取消", function()
								PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							end, nil)
						end
					elseif cfg.useType == 9 then --打开时装
						if StyleModel:GetInstance():IsActive(cfg.id) then
							UIMgr.Win_FloatTip("你已激活该时装，无法再次使用")
						else
							PkgCtrl:GetInstance():C_UseItem(data.id, 1)
							PlayerInfoController:GetInstance():Open(1)
						end
					end
				end
			end

			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end, self)
	end

	-- 格子部分
	local offX, offY = 140, 180
	local gridW, gridH = 544, 444
	local bg = self:CreateBg( UIPackage.GetItemURL("Common" , "bg_gridpanel"), offX, offY, gridW, gridH, panel )
	local gridPanel = self:CreatePanelV(panel, offX, offY+6, gridW-8, gridH-12)
	self.gridPanel = gridPanel

	self:RenderGrids()

	-- 整理
	local btn = self:CreateButton(panel, UIPackage.GetItemURL("Common","btn_erji1"), UIPackage.GetItemURL("Common","btn_erji2"), offX+20, gridPanel.y+gridPanel.height+22, "整理", 138, 46)
	self.btn_zl = btn

	-- 数量
	local x, y, w, h = gridPanel.x+gridW-160, gridPanel.y+gridPanel.height+22, 150, 40
	bg = self:CreateBg( UIPackage.GetItemURL("Common","shuliangdi"), x, y-4, w, h, panel )
	local txt = createText( "??/??", x+10, y, w, h, 28, nil, nil,newColorByString("222222"))
	self.txt_num = txt
	panel:AddChild(txt)

	local btnBuy = self:CreateButton(panel , UIPackage.GetItemURL("Common" , "btnAddBg0") , UIPackage.GetItemURL("Common" , "btnAddBg0") , x + 110 , y - 6 , "" , 43 , 43)
	self.btnBuy = btnBuy

	-- 标签
	local res0 = UIPackage.GetItemURL("Common","btn_fenye1")
	local res1 = UIPackage.GetItemURL("Common","btn_fenye2")
	local tabDatas = {
		{label="全部", res0=res0, res1=res1, id="0", red=false}, 
		{label="装备", res0=res0, res1=res1, id="1", red=false},
		{label="消耗", res0=res0, res1=res1, id="2", red=false},
		{label="其他", res0=res0, res1=res1, id="3", red=false},
	}

	local function tabClickCallback( idx, id )
		self.selectTabId = id
		local defaultSelectedBid = self.model.selectGoodsBid

		SetTabRedTips(self.tabs, id, false ) -- 点击去掉红点
		self:UpdateGrids()

		if defaultSelectedBid == nil and #self.grids ~= 0 then -- 在没有默认要求选中指定物品时，切换默认选中第一个
			local isDefault = true
			self:SelectHandler(self.grids[1] , isDefault)
			if self.gridPanel then
				self.gridPanel.scrollPane:ScrollTop(true)
			end
		end
	end

	local ctrl, tabs = CreateTabbar(panel, 1, tabClickCallback, tabDatas, offX, offY-50, 0, 138, 133, 46)

	self.tabCtrl = ctrl
	self.tabs = tabs
end

-- 选中物品项回调
function PkgPanel:SelectHandler( cell , isDefault)
	if cell and self.selected ~= cell then
		if self.selected then
			self.selected:SetSelected(false)
		end
		self.selected = cell
		cell:SetSelected(true)
	end
	self:UpdateSelectInfo()

	if not isDefault then
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

-- 设置可见
function PkgPanel:SetVisible( bool )
	self.ui.visible = bool
	if bool then
		self.mphpCD = false
		self:RenderGrids()
		self:Update()
	end
end

-- 渲染格子
function PkgPanel:RenderGrids()
	local curGridNum = #self.grids
	local total = self.model.bagGrid
	local createNum = total - curGridNum
	if createNum == 0 then return end
	-- 渲染格子 构建一个格子栏[格位key PkgCell->gid vo->itemIndex] = pkgCell
	local grids, totalW, totalH = CreatePkgCellGrid(self.gridPanel, createNum, 5, 105, 105, 0, 0, function ( cell )
		self:SelectHandler(cell)
	end, curGridNum)
	for _, cell in pairs(grids) do -- 对每个格子构建必要的数据
		cell:AddArrow() -- 添加与身上装备对比的箭头
		cell:AddLock() -- 锁定
		cell:AddBind() -- 绑定
	end
	for _,v in ipairs(grids) do
		table.insert(self.grids, v)
	end
end
-- 构建一个面板
function PkgPanel:CreatePanel( root, x, y, w, h )
	local panel = UIPackage.CreateObject("Common" , "CustomLayerN")
	root:AddChild(panel)
	if x then panel.x = x end
	if y then panel.y = y end
	if w then panel.width = w end
	if h then panel.height = h end
	return panel
end
-- 构建一个垂直滚动面板
function PkgPanel:CreatePanelV( root, x, y, w, h)
	local panel = UIPackage.CreateObject("Common" , "CustomLayerV")
	root:AddChild(panel)
	if x then panel.x = x end
	if y then panel.y = y end
	if w then panel.width = w end
	if h then panel.height = h end
	return panel
end
-- 构建一个简单按钮
function PkgPanel:CreateButton(root, res0, res1, x, y, label, w, h)
	local btn = UIPackage.CreateObject("Common" , "CustomButton1")
	root:AddChild(btn)
	if res0 then btn:GetChild("upLayer").url = res0 end
	if res1 then btn:GetChild("downLayer").url = res1 end
	if x then btn.x = x end
	if y then btn.y = y end
	if w then btn.width = w end
	if h then btn.height = h end
	if label then btn.title = label end
	setTxtFontOrSize( btn:GetChild("title"), GameConst.defaultFont, 26, newColorByString("2E3341") )
	return btn
end
-- 构建一张背景
function PkgPanel:CreateBg( res, x, y, w, h, root )
	local bg = UIPackage.CreateObject("Common" , "CustomSprite0")
	root:AddChild(bg)
	if x then bg.x = x end
	if y then bg.y = y end
	if w then bg.width = w end
	if h then bg.height = h end
	if label then bg.title = label end
	if res then bg.icon = res end
	return bg
end


function PkgPanel:__delete()
	for i,v in ipairs(self.grids) do
		v:Destroy()
	end
	if self.pkgInfo then
		self.pkgInfo:Destroy()
	end
	if self.model then
		self.model:RemoveEventListener(self.bagGridChangeHandler)
	end
	self.model = nil
	self.pkgInfo = nil
	self.grids = nil
	self.lockGrids  = nil
	self.emptyGrids = nil
	self.btnBuy = nil

	--self.wingUpPanel = nil  --LLL++

	destroyUI( self.ui )
end