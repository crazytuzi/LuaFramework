--[[
    文件名：KillerValleySelectLayer.lua
	描述：绝情谷选将界面
	创建人：yanghongsheng
	创建时间：2018.1.23
-- ]]

local KillerValleySelectLayer = class("KillerValleySelectLayer", function(params)
    return display.newLayer()
end)

--[[
	params:
		formation = {
			CandidateHeroModelId:候选的学员模型id,以逗号间隔的学员模型Id列表,
	        HeroModelId:当前选中的学员模型Id,
	        RandNum:已刷新的次数，次数大于1则需要消耗资源
		}
		callback 	回调
]]
function KillerValleySelectLayer:ctor(params)
	self.callback = params.callback
	self.mFormationInfo = params.formation or {}

	-- 角色列表
	self.mHeroList = {}
	self.curSelectId = 0

	-- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

	-- 创建标准容器
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    self:initUI()

    if self:initHeroList(self.mFormationInfo) then
    	self:createSelectList()
    else
    	self:requestInfo()
    end    
end

-- 整理数据
function KillerValleySelectLayer:initHeroList(formationInfo)
	-- 没有角色列表数据
	if not formationInfo.CandidateHeroModelId or formationInfo.CandidateHeroModelId == "" then
		return false
	end
	-- 角色列表
	self.mHeroList = {}
	local heroStrList = string.splitBySep(formationInfo.CandidateHeroModelId, ",")
	for _, modelIdStr in pairs(heroStrList) do
		table.insert(self.mHeroList, tonumber(modelIdStr))
	end
	-- 排序
	table.sort(self.mHeroList, function (item1, item2)
		return item1 < item2
	end)
	-- 当前选择角色
	self.curSelectId = formationInfo.HeroModelId

	return true
end

function KillerValleySelectLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("jqg_5.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	-- 标题
	local titleSprite = ui.newSprite("jqg_14.png")
	titleSprite:setPosition(320, 1000)
	self.mParentLayer:addChild(titleSprite)
	-- 提示
	local hintNode = ui.createSpriteAndLabel({
		imgName = "c_25.png",
		scale9Size = cc.size(600, 54),
		labelStr = TR("选择一名侠客，作为您潜入绝情谷的探子"),
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	hintNode:setPosition(320, 600)
	self.mParentLayer:addChild(hintNode)
	-- Q版小人
	self:createQHero()
	-- 选择按钮
	local selectBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("选择"),
			clickAction = function ()
				if not self.curSelectId or self.curSelectId == 0 then
					ui.showFlashView({text = TR("还未选择侠客，请先选择侠客")})
					return
				end
				self:requestSelect()
			end,
		})
	selectBtn:setPosition(320, 200)
	self.mParentLayer:addChild(selectBtn)
	-- 时装按钮
	local fashionBtn = ui.newButton({
			normalImage = "sz_2.png",
			clickAction = function ()
				if not ModuleInfoObj:moduleIsOpen(ModuleSub.eQbanShizhuang, true) then
					return
				end
				LayerManager.addLayer({
                name = "fashion.QFashionSelectLayer",
                data = {
                    combatType = 2,
                    callback = function()
                        self:createQHero()
                    end,
                },
                cleanUp = false
            })
			end,
		})
	fashionBtn:setPosition(170, 330)
	self.mParentLayer:addChild(fashionBtn)
	-- 关闭按钮
	local closeBtn = ui.newButton({
			normalImage = "c_29.png",
			clickAction = function ()
				LayerManager.removeLayer(self)
			end
		})
	closeBtn:setPosition(595, 1035)
	self.mParentLayer:addChild(closeBtn)
end

function KillerValleySelectLayer:createQHero()
	if self.mHeroNode then
		self.mHeroNode:removeFromParent()
		self.mHeroNode = nil
	end
	local heroNode = cc.Node:create()
	self.mParentLayer:addChild(heroNode)
	self.mHeroNode = heroNode

	-- local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
	-- HeroQimageRelation.items[playerModelId].positivePic
	local positivePic, backPic = QFashionObj:getQFashionByDressType(2)
	local zhengmianEffect = ui.newEffect({
		parent = heroNode,
		effectName = positivePic,
		animation = "zou",
		position = cc.p(0,0),
		loop = true,
		endRelease = true,
		scale = 0.6,
	})
	heroNode.zhengmianEffect = zhengmianEffect

	local beimianEffect = ui.newEffect({
		parent = heroNode,
		effectName = backPic,
		animation = "zou",
		position = cc.p(0,0),
		loop = true,
		endRelease = true,
		scale = 0.6,
	})
	beimianEffect:setRotationSkewY(180)
	heroNode.beimianEffect = beimianEffect

	-- 小人移动
	local startPos, endPos = cc.p(50, 450), cc.p(180, 390)
	heroNode:setPosition(startPos)
	local zhengmian = cc.CallFunc:create(function (node)
		node.beimianEffect:setVisible(false)
		node.zhengmianEffect:setVisible(true)
	end)
	local beimian = cc.CallFunc:create(function (node)
		node.beimianEffect:setVisible(true)
		node.zhengmianEffect:setVisible(false)
	end)
	local move1 = cc.MoveTo:create(2.5, endPos)
	local move2 = cc.MoveTo:create(2.5, startPos)
	local seq = cc.Sequence:create(zhengmian, move1, beimian, move2)
	heroNode:runAction(cc.RepeatForever:create(seq))
end

-- 创建选择列表
function KillerValleySelectLayer:createSelectList()
	if not self.mHeroParentNode or not tolua.inull(self.mHeroParentNode) then
		self.mHeroParentNode = cc.Node:create()
		self.mHeroParentNode:setPosition(0, 720)
		self.mParentLayer:addChild(self.mHeroParentNode)
	end
	self.mHeroParentNode:removeAllChildren()

	local col = 4					-- 列数
	local spaceX = 640 / (col+1)	-- 横间距
	local spaceY = 150				-- 纵间距

	-- 循环创建卡牌
	for i, heroModelId in pairs(self.mHeroList) do
		-- 计算坐标
		local x = (((i-1) % col)+1) * spaceX
		local y = math.floor(((i-1) / col)) * spaceY

		-- 创建项
		local item = self:createCardItem(heroModelId)
		item:setPosition(cc.p(x, y))
		self.mHeroParentNode:addChild(item)

		-- 初始选中
		if self.curSelectId and self.curSelectId == heroModelId then
			item:changeState(true)
		end
	end
end

-- 创建卡牌项
function KillerValleySelectLayer:createCardItem(heroModelId)
	-- 父节点
	local itemSize = ui.getImageSize("c_04.png")
	local item = cc.Node:create()
	item:setAnchorPoint(cc.p(0.5, 0.5))
	item:setContentSize(itemSize)

	-- 改变状态函数
	item.changeState = function(obj, isSelected)
		if isSelected then
			if self.curSelectItem then
				self.curSelectItem:changeState(false)
			end
			self.curSelectItem = obj
			obj.checkBox:setCheckState(true)
			self.curSelectId = heroModelId
		else
			if self.curSelectItem == obj then
				self.curSelectItem = nil
				obj.checkBox:setCheckState(false)
				self.curSelectId = 0
			end
		end
	end

	-- 人物头像
	local heroCard = CardNode:create({
			allowClick = true,
	        onClickCallback = function(sender)
	        	item:changeState(not item.checkBox:getCheckState())
	        end,
		})
	heroCard:setHero({ModelId = heroModelId})
	heroCard:setPosition(itemSize.width*0.5, itemSize.height*0.5)
	item:addChild(heroCard)

	-- 选择框
	local checkBox = ui.newCheckbox({
			callback = function (isSelected)
				item:changeState(isSelected)
			end,
		})
	checkBox:setAnchorPoint(cc.p(1, 1))
	checkBox:setPosition(itemSize.width+10, itemSize.height)
	item:addChild(checkBox)
	item.checkBox = checkBox

	return item
end
--=======================网络相关=====================
-- 获取侠客列表
function KillerValleySelectLayer:requestInfo()
	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "RandHeros",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			self:initHeroList(response.Value.FormationInfo)
			-- 创建头像列表
			self:createSelectList()

			if self.callback then
				self.callback(response.Value.FormationInfo)
			end
		end
	})
end
-- 选择侠客
function KillerValleySelectLayer:requestSelect()
	HttpClient:request({
		moduleName = "KillerValley",
		methodName = "SelectHero",
		svrMethodData = {self.curSelectId},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			if self.callback then
				self.callback(response.Value.FormationInfo)
			end
			LayerManager.removeLayer(self)
		end
	})
end

return KillerValleySelectLayer