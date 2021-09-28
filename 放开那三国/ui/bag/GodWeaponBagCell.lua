-- FileName: GodWeaponBagCell.lua 
-- Author: licong 
-- Date: 14-12-16 
-- Purpose: 神兵背包


module("GodWeaponBagCell", package.seeall)

require "script/ui/common/CheckBoxItem"
require "script/ui/item/ItemUtil"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/GodWeaponItemUtil"
require "script/libs/LuaCC"

local _callBack  			= nil -- 回调事件
local _selectList		 	= nil -- 选择的材料列表

--[[
	@des 	:初始化变量
	@param 	:
	@return :
--]]
function init( ... )
	_callBack  			= nil
	_selectList		 	= nil 
end
--------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------------------------
--[[
	@des 	:洗练按钮回调
	@param 	:
	@return :
--]]
function washBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	
	require "script/ui/godweapon/godweaponfix/GodWeaponFixLayer"
	local item_id = tag
	GodWeaponFixLayer.showLayer(item_id)
	-- 设置界面记忆
	GodWeaponFixLayer.setChangeLayerMark( GodWeaponFixLayer.kTagBag )

	-- 记忆神兵背包位置
	BagLayer.setMarkGodWeaponItemId(item_id)
end

--[[
	@des 	:强化按钮回调
	@param 	:
	@return :
--]]
function enhanceBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/godweapon/GodWeaponReinforceLayer"
	local item_id = tag
	GodWeaponReinforceLayer.showReinforceLayer(item_id)
	-- 设置界面记忆
	GodWeaponReinforceLayer.setChangeLayerMark( GodWeaponReinforceLayer.kTagBag )

	-- 记忆神兵背包位置
	BagLayer.setMarkGodWeaponItemId(item_id)
end 

--[[
	@des 	:进化按钮回调
	@param 	:
	@return :
--]]
function evolveBtnCallBack( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local itemInfo = ItemUtil.getItemByItemId(tag)
	-- 处理 神兵强化材料
	if( itemInfo ~= nil and tonumber(itemInfo.itemDesc.isgodexp) == 1 )then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1439"))
		return
	end

	require "script/ui/godweapon/GodWeaponEvolveLayer"
  	GodWeaponEvolveLayer.createLayer(tag)
  	GodWeaponEvolveLayer.setChangeLayerMark(GodWeaponEvolveLayer.kBagTag)

  	-- 记忆神兵背包位置
	BagLayer.setMarkGodWeaponItemId(tag)
end 


--[[
	@des 	:检查被选择的材料
	@param 	:
	@return :
--]]
function handleSelectedCheckedBtn( checkedBtn )
	if(_selectList == nil)then
		return
	end
	if ( table.isEmpty(_selectList) ) then
		checkedBtn:unselected()
	else
		local isIn = false
		for k,v in pairs(_selectList) do
			if ( tonumber(v.item_id) == tonumber(checkedBtn:getTag()) ) then
				isIn = true
				break
			end
		end
		if (isIn) then
			checkedBtn:selected()
		else
			checkedBtn:unselected()
		end
	end
end
--------------------------------------------------------------- 创建cell ----------------------------------------------------------------------------------
--[[
	@des 	:创建cell
	@param 	:p_godData:神兵数据, p_callBack:回调函数, p_isForMaterial:是否作为选择列表, p_isShowExp:是否显示经验, p_selectList:选择的列表数据,p_isIconTouch:图标是否可以点击
			 p_isNoBtn:为true时则没有按钮,p_menuPriority:cell按钮上的优先级
	@return :
--]]
function createCell( p_godData, p_callBack, p_isForMaterial, p_isShowExp, p_selectList, p_isIconTouch, p_isNoBtn,p_menuPriority, p_maxSelectNum,  pIsBag, pIndex )
	-- print("p_godData==>")
	-- print_t(p_godData)
	
	init()

	_callBack = p_callBack
	_selectList = p_selectList

	-- 是否是叠加神兵
	local isMany = false
	if( tonumber(p_godData.itemDesc.maxStacking) > 1 )then
		isMany = true
	end

	local tCell = CCTableViewCell:create()
	-- 背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_1.png",fullRect, insetRect)
    cellBg:setContentSize(CCSizeMake(640,190))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(320,0)
	tCell:addChild(cellBg,1,1)
	local cellBgSize = cellBg:getContentSize()

	-- icon 
	local iconSprite = nil
	if(p_isIconTouch == false)then
		iconSprite = ItemSprite.getItemSpriteByItemId( tonumber(p_godData.item_template_id),nil,nil, tonumber(p_godData.item_id))
	else
		iconSprite = ItemSprite.getItemSpriteById( tonumber(p_godData.item_template_id), tonumber(p_godData.item_id), nil,nil,nil,nil,nil,nil,nil,nil,true,nil,_callBack )
	end
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(cellBgSize.width * 0.1, cellBgSize.height * 0.55))
	cellBg:addChild(iconSprite)

	-- 加锁
	if(p_godData.va_item_text and p_godData.va_item_text.lock and tonumber(p_godData.va_item_text.lock) ==1) then
		local lockSp= CCSprite:create("images/hero/lock.png")
		lockSp:setAnchorPoint(ccp(0.5,0.5))
		lockSp:setPosition(iconSprite:getContentSize().width,iconSprite:getContentSize().height)
		iconSprite:addChild(lockSp,100)
	end

	-- 等级背景
	local fullRect = CCRectMake(0,0,46,23)
    local insetRect = CCRectMake(20,8,5,1)
	local lvBg = CCScale9Sprite:create("images/common/bg/name_1.png",fullRect, insetRect)
	lvBg:setContentSize(CCSizeMake(92,26))
	lvBg:setAnchorPoint(ccp(0,0))
	lvBg:setPosition(ccp(20,25))
	cellBg:addChild(lvBg)

	
    if(isMany)then
    	-- 叠加物品
    	-- 数量
		local numLabel = CCRenderLabel:create( GetLocalizeStringBy("lic_1584") .. p_godData.item_num, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    numLabel:setAnchorPoint(ccp(0.5,0.5))
	    numLabel:setPosition(ccp(lvBg:getContentSize().width*0.5, lvBg:getContentSize().height*0.5))
	    lvBg:addChild(numLabel)
    else
    	-- 等级
	    local lvSp = CCSprite:create("images/common/lv.png")
	    lvSp:setAnchorPoint(ccp(0,0.5))
	    lvSp:setPosition(ccp(8,lvBg:getContentSize().height*0.5))
	    lvBg:addChild(lvSp)
		-- 等级
		local levelLabel = CCRenderLabel:create(p_godData.va_item_text.reinForceLevel, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    levelLabel:setAnchorPoint(ccp(0,0.5))
	    levelLabel:setPosition(ccp(lvSp:getPositionX()+lvSp:getContentSize().width+2, lvBg:getContentSize().height*0.5))
	    lvBg:addChild(levelLabel)
	end

	-- 印章
    local sealSprite = CCSprite:create("images/god_weapon/godtype/" .. p_godData.itemDesc.type .. ".png" )
    sealSprite:setAnchorPoint(ccp(0, 0.5))
    sealSprite:setPosition(ccp(cellBgSize.width*0.2, cellBgSize.height*0.8))
    cellBg:addChild(sealSprite)

	-- 名称
	local quality,_,showEvolveNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(p_godData.item_template_id, p_godData.item_id)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameLabel = CCRenderLabel:create(p_godData.itemDesc.name, g_sFontName, 28, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(cellBgSize.width*0.2 + sealSprite:getContentSize().width + 0.5, cellBgSize.height*0.8))
    cellBg:addChild(nameLabel)

    -- 处理 神兵强化材料
	if( tonumber(p_godData.itemDesc.isgodexp) ~= 1 )then
	    -- 进阶数
	    local fontTab = {}
	    fontTab[1] = CCSprite:create("images/god_weapon/jienum/" .. showEvolveNum .. ".png")
	    fontTab[2] = CCSprite:create("images/god_weapon/jie.png")
	    local evolveFont = BaseUI.createHorizontalNode(fontTab)
	    evolveFont:setAnchorPoint(ccp(1,0))
		evolveFont:setPosition(ccp(iconSprite:getContentSize().width,0))
		iconSprite:addChild(evolveFont)
	end

	-- 品级值
    local potentialLabel = CCRenderLabel:create(p_godData.itemDesc.godarmrank, g_sFontName,25, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    potentialLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    potentialLabel:setAnchorPoint(ccp(0,0.5))
    potentialLabel:setPosition(cellBgSize.width*350.0/640, cellBgSize.height*0.79)
    cellBg:addChild(potentialLabel)

	-- 品级
    local starSp = CCSprite:create("images/god_weapon/pin.png")
    starSp:setAnchorPoint(ccp(0, 0.5))
    starSp:setPosition(ccp(potentialLabel:getPositionX()+potentialLabel:getContentSize().width + 5, potentialLabel:getPositionY()))
    cellBg:addChild(starSp)


    -- 小背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local attrBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    attrBg:setContentSize(CCSizeMake(280,92))
    attrBg:setAnchorPoint(ccp(0,0))
    attrBg:setPosition(ccp(120,40))
    cellBg:addChild(attrBg)

    -- 属性
    local attrTab = GodWeaponItemUtil.getWeaponAbility(p_godData.item_template_id, p_godData.item_id)
	local posX = {0.05,0.05,0.5,0.5}
	local posY = {0.7,0.3,0.7,0.3}
	if(not table.isEmpty(attrTab) )then
		for k,v in pairs(attrTab) do
			local attrLabel = CCLabelTTF:create(v.name .. "+" .. v.showNum ,g_sFontName,23)
			attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
			attrLabel:setAnchorPoint(ccp(0, 0.5))
			attrLabel:setPosition(ccp(attrBg:getContentSize().width*posX[k],attrBg:getContentSize().height*posY[k]))
			attrBg:addChild(attrLabel)
		end
	end

	-- 处理 神兵强化材料
	if( tonumber(p_godData.itemDesc.isgodexp) == 1 )then
		-- 提供经验的数值
		local add_exp = tonumber(p_godData.itemDesc.giveexp)
		if( p_godData.va_item_text and p_godData.va_item_text.reinForceExp )then
			add_exp = add_exp + tonumber(p_godData.va_item_text.reinForceExp)
		end
		local add_exp_label = CCLabelTTF:create(GetLocalizeStringBy("key_2531") .. "+" .. add_exp, g_sFontName, 23)
		add_exp_label:setColor(ccc3(0x78, 0x25, 0x00))
		add_exp_label:setAnchorPoint(ccp(0, 0.5))
		add_exp_label:setPosition(ccp(attrBg:getContentSize().width*posX[1],attrBg:getContentSize().height*posY[1]))
		attrBg:addChild(add_exp_label)
	end

	-- 已洗练属性
	if( not table.isEmpty(p_godData.va_item_text) and not table.isEmpty(p_godData.va_item_text.confirmed) )then 
		local tipSp = CCSprite:create("images/common/havefix.png")
		tipSp:setAnchorPoint(ccp(0,0))
		tipSp:setPosition(ccp(120,15))
		cellBg:addChild(tipSp)
	end

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,1, 9898)
	if(p_menuPriority)then
		menuBar:setTouchPriority(p_menuPriority)
	end

	if( p_isNoBtn ~= true )then
		if( p_isForMaterial )then 
			if( p_isShowExp )then
				if( isMany )then
					-- 已选择数量
					local num = 0
					for k,v in pairs(_selectList) do 
						if(tonumber(v.item_id) == tonumber(p_godData.item_id) )then 
							num = v.num
						end
					end
					local chooseLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1586",num), g_sFontName,20, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
				    chooseLabel:setColor(ccc3(0x00, 0xff, 0x18))
				    chooseLabel:setAnchorPoint(ccp(0.5,0.5))
				    chooseLabel:setPosition(cellBgSize.width*0.8, cellBgSize.height*0.3)
				    cellBg:addChild(chooseLabel)

					-- 选择回调
					local chooseBtnCallBack = function ( )
						-- 音效
						require "script/audio/AudioUtil"
						AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
						local selectList = GodWeaponData.getMaterialSelectList()
						local chooseNum = table.count(selectList)
						if( chooseNum >= p_maxSelectNum )then  
							-- 五个了 不能再选择了
							AnimationTip.showTip(GetLocalizeStringBy("lic_1431"))
							return
						end

						require "script/utils/SelectNumDialog"
					    local dialog = SelectNumDialog:create()
					    dialog:setTitle(GetLocalizeStringBy("lic_1585"))
					    dialog:show(-560, 1010)
					    dialog:setMinNum(0)
					    local maxNum = 50
					    if(tonumber(p_godData.item_num) < 50)then
					    	maxNum = tonumber(p_godData.item_num)
					    end
					    dialog:setLimitNum(maxNum)
					    
					    local curNum = 0
					    for k,v in pairs(selectList) do
					    	if(tonumber(v.item_id) == tonumber(p_godData.item_id))then
					    		curNum = v.num
					    		break
					    	end
					    end
					    dialog:setNum(curNum)
				    	dialog:registerOkCallback(function ()
				          	local chooseNum = dialog:getNum()
				          	chooseLabel:setString(GetLocalizeStringBy("lic_1586",chooseNum))
				         
			          		GodWeaponSelectLayer.checkedSelectCell(p_godData.item_id,chooseNum)
			          		GodWeaponSelectLayer.refreshBottomSprite()
				          	
				        end)

				        -- 最多选择50个
				        local maxLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1587"), g_sFontName,30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
					    maxLabel:setColor(ccc3(0xff, 0xf6, 0x00))
					    maxLabel:setAnchorPoint(ccp(0.5,0.5))
					    maxLabel:setPosition(dialog:getContentSize().width*0.5, dialog:getContentSize().height*0.7)
					    dialog:addChild(maxLabel)
					end 

				 	-- 选择
					local chooseBtn = LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1585"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
					chooseBtn:setAnchorPoint(ccp(0.5, 0.5))
				    chooseBtn:setPosition(ccp(cellBgSize.width*0.85, cellBgSize.height*0.6))
					menuBar:addChild(chooseBtn, 1)
					chooseBtn:registerScriptTapHandler(chooseBtnCallBack)
					
				else
					-- 复选框
					local checkedBtn = CheckBoxItem.create()
					checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
				    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
					menuBar:addChild(checkedBtn, 1, tonumber(p_godData.item_id) )
					checkedBtn:setEnabled(false)
					-- 检查是否被选择
					handleSelectedCheckedBtn(checkedBtn)
				end
			else
				-- 复选框
				local checkedBtn = CheckBoxItem.create()
				checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
			    checkedBtn:setPosition(ccp(cellBgSize.width*580/640, cellBgSize.height*0.5))
				menuBar:addChild(checkedBtn, 1, tonumber(p_godData.item_id) )
				checkedBtn:setEnabled(false)
				-- 检查是否被选择
				handleSelectedCheckedBtn(checkedBtn)
			end
		else
			if( not(BagUtil.isSupportBagCell() and pIsBag) )then
				-- 强化
				local enhanceBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/green01_n.png", "images/common/btn/green01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1422"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
			    enhanceBtn:setPosition(ccp(cellBgSize.width*0.85, cellBgSize.height*0.6))
				menuBar:addChild(enhanceBtn, 1, tonumber(p_godData.item_id))
				enhanceBtn:registerScriptTapHandler(enhanceBtnCallBack)

				-- 进化
				local evolveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/purple01_n.png", "images/common/btn/purple01_h.png",CCSizeMake(134, 64), GetLocalizeStringBy("lic_1423"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				evolveBtn:setAnchorPoint(ccp(0.5, 0.5))
				evolveBtn:registerScriptTapHandler(evolveBtnCallBack)
				evolveBtn:setPosition(ccp(cellBgSize.width*0.85, cellBgSize.height*0.25))
				menuBar:addChild(evolveBtn, 1, tonumber(p_godData.item_id ))

				-- 洗练
				local washBtn = CCMenuItemImage:create("images/god_weapon/xi_n.png", "images/god_weapon/xi_h.png")
				washBtn:setAnchorPoint(ccp(0.5, 0.5))
				washBtn:registerScriptTapHandler(washBtnCallBack)
				washBtn:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.5))
				menuBar:addChild(washBtn, 1, tonumber(p_godData.item_id ))
				-- 处理 神兵强化材料
				if( tonumber(p_godData.itemDesc.isgodexp) == 1 )then
					washBtn:setVisible(false)
				end
				-- 叠加神兵
				if( isMany )then
					enhanceBtn:setVisible(false)
					evolveBtn:setVisible(false)
					washBtn:setVisible(false)
				end
			end
		end
	end

	if(p_godData.equip_hid and tonumber(p_godData.equip_hid) > 0)then
		local localHero = HeroUtil.getHeroInfoByHid(p_godData.equip_hid)
		local heroName = localHero.localInfo.name
		if(HeroModel.isNecessaryHeroByHid(p_godData.equip_hid)) then
			heroName = UserModel.getUserName()
		end
		local onFormationText =  CCRenderLabel:create(GetLocalizeStringBy("key_1381") .. heroName, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    onFormationText:setColor(ccc3(0x8a, 0xff, 0x00))
	    onFormationText:setPosition(ccp(cellBgSize.width*0.7, cellBgSize.height*0.9))
	    cellBg:addChild(onFormationText)
	end

	-- 展开逻辑
	if(isMany == false and BagUtil.isSupportBagCell() and pIsBag)then
		-- 隐藏原来的按钮
		menuBar:setVisible(false)
		-- 展开背景高度
		local openBgHeight = 138
		local addHeight = openBgHeight-10
		-- 展开按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		cellBg:addChild(menu)
		local normal = CCMenuItemImage:create("images/common/down_btn_n.png", "images/common/down_btn_h.png")
		local hight  = CCMenuItemImage:create("images/common/up_btn_n.png", "images/common/up_btn_h.png")
		hight:setAnchorPoint(ccp(0.5, 0.5))
		normal:setAnchorPoint(ccp(0.5, 0.5))
		local openMenuItem = CCMenuItemToggle:create(normal)
		openMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		openMenuItem:addSubItem(hight)
		menu:addChild(openMenuItem)
		openMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.8,cellBg:getContentSize().height*0.45))
		openMenuItem:registerScriptTapHandler(function ( ... )
			-- 展开事件
			local selectIndex = openMenuItem:getSelectedIndex()
			-- print("selectIndex",selectIndex)
			local offsetNum = 0
			if(selectIndex == 0) then
				BagLayer.setOpenIndex(nil)
				offsetNum = -addHeight
			else
				BagLayer.setOpenIndex(pIndex)
				offsetNum = addHeight
			end
			BagLayer.refreshBagTableView(offsetNum,pIndex)
		end)

		-- 展开按钮
		local curOpneIndex = BagLayer.getOpenIndex()
		-- print("cell curOpneIndex",curOpneIndex,pIndex)
		if(pIndex == curOpneIndex)then
			openMenuItem:setSelectedIndex(1)
			local openBg = CCScale9Sprite:create("images/common/bg/bg_9s_11.png")
			openBg:setContentSize(CCSizeMake(600,openBgHeight))
	        openBg:setAnchorPoint(ccp(0.5,0))
	        openBg:setPosition(320,10)
	        tCell:addChild(openBg)
	        cellBg:setAnchorPoint(ccp(0.5,0))
			cellBg:setPosition(openBg:getPositionX(),addHeight)

			-- 按钮
			local buttnMenu = CCMenu:create()
			buttnMenu:setPosition(ccp(0,0))
			openBg:addChild(buttnMenu)
			local btnArr = {}
			local btnPosXArr = {0.85,0.68,0.51,0.34}
			local allOpen = true
		    -- 强化
		    local enhanceMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_s_n.png", "images/common/btn/btn_s_h.png",CCSizeMake(81, 76), GetLocalizeStringBy("lic_1422"),ccc3(0xff, 0xf2, 0x5d),24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			enhanceMenuItem:setAnchorPoint(ccp(0.5, 0.5))
			enhanceMenuItem:registerScriptTapHandler(enhanceBtnCallBack)
			buttnMenu:addChild(enhanceMenuItem, 1, tonumber(p_godData.item_id))
			table.insert(btnArr,enhanceMenuItem)

			-- 进阶
			if( tonumber(p_godData.itemDesc.isgodexp) ~= 1 )then
				local normalFile = "images/common/btn/btn_s_n.png"
				local selectFile = "images/common/btn/btn_s_h.png"
				local fontColor = ccc3(0xff, 0xf2, 0x5d)
			    local developMenuItem =LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1423"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				developMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				developMenuItem:registerScriptTapHandler(evolveBtnCallBack)
				buttnMenu:addChild(developMenuItem, 1, tonumber(p_godData.item_id))
				table.insert(btnArr,1,developMenuItem)
			end

			-- 洗练
			if( tonumber(p_godData.itemDesc.isgodexp) ~= 1 )then
				local normalFile = "images/common/btn/btn_s_n.png"
				local selectFile = "images/common/btn/btn_s_h.png"
				local fontColor = ccc3(0xff, 0xf2, 0x5d)
				local fixMenuItem = LuaCC.create9ScaleMenuItem(normalFile, selectFile,CCSizeMake(81, 76), GetLocalizeStringBy("lic_1822"),fontColor,24,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
				fixMenuItem:setAnchorPoint(ccp(0.5, 0.5))
				fixMenuItem:registerScriptTapHandler(washBtnCallBack)
				buttnMenu:addChild(fixMenuItem, 1, tonumber(p_godData.item_id))
				table.insert(btnArr,1,fixMenuItem)
			end
			
			for i=1,#btnArr do
				if(allOpen)then
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.47))
				else
					btnArr[i]:setPosition(ccp(openBg:getContentSize().width*btnPosXArr[i], openBg:getContentSize().height*0.5))
				end
			end
		else
			openMenuItem:setSelectedIndex(0)
		end
	end

	return tCell
end






