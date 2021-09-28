--[[
    SectSelectLayer.lua
    描述: 门派选择界面
    创建人: yanghongsheng
    创建时间: 2017.8.23
-- ]]


--[[
	params:
		selectId 	-- 选中门派id

]]

local SectSelectLayer = class("SectSelectLayer", function(params)
    return display.newLayer()
end)

function SectSelectLayer:ctor(params)
	-- 初始化成员
	-- 选中门派id
	self.selectId = params.selectId or 1

	-- 子页面的parent
    self.mSubLayerParent = ui.newStdLayer()
    self:addChild(self.mSubLayerParent)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 创建底部导航和顶部玩家信息部分
	self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	-- 初始化界面
	self:initUI()
end

-- 初始化界面
function SectSelectLayer:initUI()
	local topPosY = 1136 - 110
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_69.png", cc.size(620, 145))
    listBg:setPosition(320, topPosY)
    self.mParentLayer:addChild(listBg)
    -- 门派列表
    self.sectListView = ccui.ListView:create()
    self.sectListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.sectListView:setBounceEnabled(true)
    self.sectListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.sectListView:setContentSize(cc.size(580, 150))
    self.sectListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.sectListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.sectListView:setPosition(320, topPosY)
    self.sectListView:setItemsMargin(-20)
    self.mParentLayer:addChild(self.sectListView)

    self:refreshList()

    self:changePage(self.selectId)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
    self.closeBtn = closeBtn
end

-- 刷新列表
function SectSelectLayer:refreshList()
	-- 项大小
	local cellSize = cc.size(150, 150)
	-- 创建一项
	local function createItem(data)
		local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)

	    -- 点击按钮
	    local tempBtn = ui.newButton({
	    	normalImage = data.headPic..".png",
	    	clickAction = function()
	    		if self.selectId == data.ID then
	    			return
	    		end

	    		self:changePage(data.ID)
	    	end
	    })
	    tempBtn:setPosition(cellSize.width / 2, cellSize.height / 2 + 5)
    	lvItem:addChild(tempBtn)

        return lvItem
	end
	-- 创建一个空项
	local function addNullItem()
		local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)

	    -- 点击按钮
	    local tempBtn = ui.newButton({
	    	normalImage = "mp_91.png",
	    	clickAction = function()
	    		ui.showFlashView({text = TR("敬请期待")})
	    	end
	    })
	    tempBtn:setPosition(cellSize.width / 2, cellSize.height / 2 + 5)
    	lvItem:addChild(tempBtn)

        return lvItem
	end
	-- 清空列表
	self.sectListView:removeAllChildren()
	-- 填充列表
	for _, v in ipairs(SectModel.items) do
		local item = createItem(v)
		self.sectListView:pushBackCustomItem(item)
	end
	-- 添加一个空项
	self.sectListView:pushBackCustomItem(addNullItem())
end

-- 切换页面
function SectSelectLayer:changePage(Id)
	-- 下层背景
	if not self.bottomBg then
		self.bottomBg = ui.newSprite(SectModel.items[Id].backPic..".jpg")
		self.bottomBg:setPosition(320, 568)
		self.mSubLayerParent:addChild(self.bottomBg, -1)
	else
		self.bottomBg:setTexture(SectModel.items[Id].backPic..".jpg")
	end
	-- 黑色背景
	if not self.blackBg then
		self.blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128))
		self.blackBg:setContentSize(640, 1136)
		self.mSubLayerParent:addChild(self.blackBg, -1)
	end
	-- 创建页面
	local function createLayer()
		local layer = cc.Layer:create()

		local data = SectModel.items[Id]
		
		-- 门派
		local bgSprite = ui.newSprite(data.bgPic..".png")
		bgSprite:setPosition(320, 568)
		layer:addChild(bgSprite)

		-- 绝学id
		local fashionId = Utility.analysisStrResList(data.fashionInfo)[1].resourceTypeSub
		-- 绝学数据
		local fashionData = FashionModel.items[fashionId]
		-- 图框
	    local boxSprite = ui.newScale9Sprite("c_31.png", cc.size(118, 118))
	    boxSprite:setPosition(100, 230)
	    layer:addChild(boxSprite)
		-- 绝学小图
		local fashionCard = require("common.CardNode").new({
				allowClick = true,
				onClickCallback = function()
					self:showSkillDlg(fashionData.RAID, true, cc.p(380, 420))
				end
			})
		fashionCard:setScale(1.2)
		fashionCard:setPosition(100, 230)
		fashionCard:setSkillAttack({modelId = fashionData.RAID, icon = fashionData.skillIcon .. ".png", notShowSkill = true}, {CardShowAttr.eBorder})
		layer:addChild(fashionCard)
		-- 绝学名
		local fashionName = ui.newSprite(fashionData.namePic..".png")
		if fashionName then
			fashionName:setPosition(120, 150)
			layer:addChild(fashionName)
		end
		-- 绝学标签图
		local labelSprite = ui.newSprite("mp_51.png")
		labelSprite:setPosition(150, 260)
		layer:addChild(labelSprite)

		-- 加入门派按钮
		local joinBtn = ui.newButton({
				normalImage = "mp_03.png",
				clickAction = function ()
					if data.ID == 2 then	-- 古墓派彩蛋
						self:createGumuSurprise(data.ID)
					else
						self:requestJoinSect(data.ID)
					end
				end
			})
		joinBtn:setPosition(500, 150)
		layer:addChild(joinBtn)

		return layer
	end

	-- 更新当前id
	self.selectId = Id

	-- 删除老页面
	if not tolua.isnull(self.mSubLayer) then
		self.mSubLayer:removeFromParent()
		self.mSubLayer = nil
	end

	self.mSubLayer = createLayer()

	-- 横移动画
	-- 移动距离
	local distance = 500
	-- 移动时间
	local time = 0.2
	-- 获取节点当前位置
	local x, y = self.mSubLayer:getPosition()
	-- 初始化节点位置
	self.mSubLayer:setPosition(x - distance, y)
	-- 创建动作
	local move = cc.MoveTo:create(time, cc.p(x, y))
	-- 执行动作
	self.mSubLayer:runAction(move)

	self.mSubLayerParent:addChild(self.mSubLayer)
end

-- 创建时装的技能介绍框
function SectSelectLayer:showSkillDlg(modelId, isSkill, pos)
	local dlgBgNode = cc.Node:create()
	self.mParentLayer:addChild(dlgBgNode, 1)

	-- 背景图
	local dlgBgSprite = ui.newSprite("zr_53.png")
	local dlgBgSize = dlgBgSprite:getContentSize()
	dlgBgSprite:setAnchorPoint(cc.p(1, 1))
	dlgBgSprite:setPosition(pos)
	dlgBgNode:addChild(dlgBgSprite)

	-- 技能图标
	local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
	for _,v in ipairs(attackList) do
		attackText = attackText .. Enums.Color.eNormalWhiteH .. v
	end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
		node = dlgBgNode,
		allowTouch = true,
        endedEvent = function(touch, event)
        	dlgBgNode:removeFromParent()
        end
		})
end

-- 创建古墓派彩蛋
function SectSelectLayer:createGumuSurprise(mpId)
	-- 吐口水次数
	self.spitCount = 0
	-- 弹窗回掉函数
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		-- 王重阳图
		local roleSprite = ui.newSprite("mp_47.png")
		roleSprite:setPosition(bgSize.width*0.5, bgSize.height*0.57)
		bgSprite:addChild(roleSprite)
		-- 提示文字
		local hintLabel = ui.createSpriteAndLabel({
				imgName = "c_145.png",
				scale9Size = cc.size(500, 60),
				labelStr = TR("对王重阳画像吐口水，才能入派。"),
				fontSize = 24,
				fontColor = Enums.Color.eWhite,
			})
		hintLabel:setPosition(bgSize.width*0.5, 170)
		bgSprite:addChild(hintLabel)
		-- 离开按钮
		local leaveBtn = ui.newButton({
				text = TR("离开"),
				normalImage = "c_28.png",
				clickAction = function ()
					LayerManager.removeLayer(boxRoot)
				end
			})
		leaveBtn:setPosition(bgSize.width*0.7, 100)
		bgSprite:addChild(leaveBtn)
		-- 吐口水按钮
		local spitBtn = ui.newButton({
				text = TR("吐口水"),
				normalImage = "c_33.png",
				clickAction = function ()
					-- 次数加1
					self.spitCount = self.spitCount + 1
					local effectPositionX = math.random(bgSize.width*0.3, bgSize.width*0.7)
					local effectPositionY = math.random(bgSize.height*0.3, bgSize.height*0.75)
					-- 播放特效
					local koushuiEffect = ui.newEffect({
						parent = bgSprite,
						effectName = "effect_ui_tukoushui",
						position = cc.p(effectPositionX, effectPositionY),
						loop = false,
						endRelease = true,
					})
					-- 播放音效
					MqAudio.playEffect("tukoushui.mp3")

					if self.spitCount == 1 then
						leaveBtn:setTitleText(TR("加入门派"))
						leaveBtn:setClickAction(function ()
							self:requestJoinSect(mpId)
						end)
					end
				end,
			})
		spitBtn:setPosition(bgSize.width*0.3, 100)
		bgSprite:addChild(spitBtn)
		-- 关闭按钮
		local closeBtn = ui.newButton({
				normalImage = "c_29.png",
				clickAction = function ()
					LayerManager.removeLayer(boxRoot)
				end
			})
		closeBtn:setPosition(bgSize.width*0.88, bgSize.height*0.92)
		bgSprite:addChild(closeBtn)
	end
	-- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
        	bgImage = "c_83.png",
        	bgSize = cc.size(640, 1136),
            notNeedBlack = true,
            DIYUiCallback = DIYfunc,
            btnInfos = {},
        	title = "",
        }
    })
end

-- 创建加入门派弹窗
function SectSelectLayer:createJoinPopLayer(sectId)
	-- 弹窗回掉函数
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		-- title
		local titleSprite = ui.newSprite("mp_67.png")
		titleSprite:setPosition(bgSize.width*0.5, bgSize.height*0.8)
		bgSprite:addChild(titleSprite)
		self.joinPopSprite = bgSprite
		-- 门派数据
		local sectData = SectModel.items[sectId]
		-- 提示文字
		local hintLabel = ui.newLabel({
				text = TR("恭喜您加入%s,快去看看吧！", sectData.name),
				size = 26,
				color = Enums.Color.eBlack,
			})
		hintLabel:setPosition(bgSize.width*0.5, 255)
		bgSprite:addChild(hintLabel)
		-- 门派图标
		local sectSprite = ui.newSprite(sectData.headPic..".png")
		sectSprite:setPosition(bgSize.width*0.5, 160)
		bgSprite:addChild(sectSprite)
		
	end
	-- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
        	bgImage = "sy_25.png",
        	bgSize = cc.size(506, 387),
            notNeedBlack = true,
            DIYUiCallback = DIYfunc,
            btnInfos = {
            	{
            		text = TR("立即前往"),
            		clickAction = function ()
            			LayerManager.removeLayer(self)
    					LayerManager.addLayer({
    						name = "sect.SectLayer",
    						data = {}
    					})
            		end
            	},
            },
        	title = "",
        }
    })
    -- 弹窗动画
    -- 背面图
    local backSprite = ui.newScale9Sprite("sy_25.png", cc.size(506, 387))
    backSprite:setPosition(self.joinPopSprite:getContentSize().width*0.5, self.joinPopSprite:getContentSize().height*0.5)
    self.joinPopSprite:addChild(backSprite)
    -- 旋转圈数
    local rotateCount = 1
    -- 循环次数
    local loopCount = rotateCount*2
    -- 当前背面
    local isCurBeimian = false
    -- 先隐藏背面显示
    backSprite:setVisible(isCurBeimian)
    -- 动作总时间
    local allTime = 0.2
    -- x最小Scale
    local minScaleX = 0.05
    -- 动作列表
    local actionList = {}
   	-- 循环创建动作
    for i = 1, loopCount do
    	local curScale = Adapter.MinScale * (i / loopCount )
    	local actionTime = allTime / (loopCount*2)

    	local scaleAction = cc.ScaleTo:create(actionTime, minScaleX, curScale)

    	local callAction = cc.CallFunc:create(function (node)
    		isCurBeimian = not isCurBeimian
			backSprite:setVisible(isCurBeimian)
    	end)
    	local scaleAction2 = cc.ScaleTo:create(actionTime, curScale, curScale)

    	table.insert(actionList, scaleAction)
    	table.insert(actionList, callAction)
    	table.insert(actionList, scaleAction2)
    end
    -- 创建序列动作
    local seqAction = cc.Sequence:create(actionList)
    self.joinPopSprite:runAction(seqAction)
end


-----------------服务器相关-----------------
-- 请求初始信息
function SectSelectLayer:requestJoinSect(sectId)
	SectObj:requestJoinSect(sectId, function(response)
		self:createJoinPopLayer(sectId)
	end)
end

return SectSelectLayer